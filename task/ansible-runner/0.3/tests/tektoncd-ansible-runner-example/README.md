# Tektoncd Ansible Runner Examples

A repo to hold Ansible runner examples for the Tektoncd Task `ansible-runner`


## Common Tasks

```shell
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/git-clone/0.1/git-clone.yaml
kubectl apply -f  https://raw.githubusercontent.com/tektoncd-ansible-runner-example/catalog/master/playbooks-pvc.yaml
```

## Examples

Run the following Task to clone this repository 

```shell
tkn task start git-clone \
  --workspace=name=output,claimName=ansible-playbooks \
  --param=url=https://github.com/kameshsampath/tektoncd-ansible-runner-example \
  --param=revision=master \
  --param=deleteExisting=true \
  --showlog
```

### Service Account

You need proper RBAC in Kubernetes to allow it to perform the example tasks:

```shell
kubectl apply -f  https://raw.githubusercontent.com/tektoncd-ansible-runner-example/master/kubernetes/ansible-deployer.yaml
```

### Listing pods

```shell
 tkn task start ansible-runner \
   --serviceaccount ansible-deployer-account \
   --param=project-dir=kubernetes \
   --param=args='-p list-pods.yml' \
   --workspace=name=runner-dir,claimName=ansible-playbooks \
   --showlog
```

### Create Deployment

```shell
 tkn task start ansible-runner \
   --serviceaccount ansible-deployer-account \
   --param=project-dir=kubernetes \
   --param=args='-p create-deployment.yml' \
   --workspace=name=runner-dir,claimName=ansible-playbooks \
   --showlog
```

### Create Service

```shell
 tkn task start ansible-runner \
   --serviceaccount ansible-deployer-account \
   --param=project-dir=kubernetes \
   --param=args='-p create-service.yml' \
   --workspace=name=runner-dir,claimName=ansible-playbooks \
   --showlog
```
