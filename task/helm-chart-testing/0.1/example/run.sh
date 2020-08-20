kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/git-cli/0.1/git-cli.yaml

https://raw.githubusercontent.com/tektoncd/catalog/master/task/git-clone/0.2/git-clone.yaml

kubectl apply -f pipeline.yaml
kubectl apply -f ../helm-chart-testing.yaml

kubectl delete -f pvc.yaml
kubectl create -f pvc.yaml

tkn pipeline start git-clone-chart-testing \
	  --workspace name=shared-data,claimName=paul-test-2 \
		--workspace name=input,emptyDir="" \
		-p repo-url=https://github.com/paulczar/charts.git \
		-p revision=jj-makes-me-mad \
		-n tekton-pipelines -s default
