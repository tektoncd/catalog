#!/bin/bash
# This will create a Jenkins deployment, a jenkins service, grab the password,
# gets a 'crumb' and generate a secret out of it for our task to run against to.

cat <<EOF | kubectl apply -f- -n "${tns}"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
spec:
  selector:
    matchLabels:
      run: jenkins
  replicas: 1
  template:
    metadata:
      labels:
        run: jenkins
    spec:
      containers:
      - name: jenkins
        image: jenkins/jenkins:2.263.2-lts-centos7@sha256:666a183ad54ddd2ccd1f4bc84dadf0085254a528ab96b98a790569a6c8ca3799
        ports:
        - containerPort: 8080
        volumeMounts:
          - name: jenkins-home
            mountPath: /var/jenkins_home
      volumes:
        - name: jenkins-home
          emptyDir: {}
EOF

kubectl -n "${tns}" wait --for=condition=available --timeout=600s deployment/jenkins
kubectl -n "${tns}" expose deployment jenkins --target-port=8080

set +e
lock=0
while true;do
    apitoken="$(kubectl -n "${tns}" exec deployment/jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null)"
    [[ -n "${apitoken}" ]] && break
    sleep 5
    lock=$((lock+1))
    if [[ "${lock}" == 60 ]];then
        echo "Error waiting for jenkins to generate a password"
        exit 1
    fi
done
set -e


# We need to execute the script on the pods, since it's too painful with direct exec the commands
cat <<EOF>/tmp/script.sh
#!/bin/bash
cookiejar=\$(mktemp)
apitoken=\$(cat /var/jenkins_home/secrets/initialAdminPassword)
while [[ -z "\${crumb}" ]];do
      crumb=\$(curl --fail -s -u "admin:\${apitoken}" --cookie-jar "\${cookiejar}" 'jenkins:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,%22:%22,//crumb)')
      sleep 2
done
set -e
cat <<XXMLOF>/tmp/job.xml
<?xml version='1.1' encoding='UTF-8'?>
<project>
  <actions/>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <hudson.model.ParametersDefinitionProperty>
      <parameterDefinitions>
        <hudson.model.StringParameterDefinition>
          <name>Word</name>
          <description></description>
          <defaultValue>Bird it is!</defaultValue>
          <trim>false</trim>
        </hudson.model.StringParameterDefinition>
      </parameterDefinitions>
    </hudson.model.ParametersDefinitionProperty>
  </properties>
  <builders>
    <hudson.tasks.Shell>
      <command>echo &quot;Hello \\\${Word}&quot;</command>
      <configuredLocalRules/>
    </hudson.tasks.Shell>
  </builders>
  <publishers/>
  <buildWrappers/>
</project>
XXMLOF
curl -f -s -X POST -H "\${crumb}" --cookie "\${cookiejar}" -u "admin:${apitoken}" -X POST -H "Content-Type:application/xml" -d @/tmp/job.xml "jenkins:8080/createItem?name=test"
echo \${crumb}|sed 's/Jenkins-Crumb://'
EOF
tar cf - /tmp/script.sh|kubectl -n "${tns}" exec -i deployment/jenkins -- tar xf - -C /
crumb=$(kubectl -n "${tns}" exec -i deployment/jenkins -- /bin/bash /tmp/script.sh)

kubectl delete secret jenkins-credentials 2>/dev/null || true
kubectl create secret generic -n "${tns}" jenkins-credentials --from-literal=apitoken="${apitoken}" --from-literal=username="admin"
