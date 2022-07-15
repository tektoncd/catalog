# Ansible Runner

Ansible Runner Task allows running the Ansible Playbooks using the [ansible-runner](https://ansible-runner.readthedocs.io/) tool.

The latest versions of ansible-runner requires [`community.general`](https://github.com/ansible-collections/community.general) to be installed from ansible-collections.

## Creating the Task

Create the Task and other resources:

```shell
kubectl apply --filename https://api.hub.tekton.dev/v1/resource/tekton/task/ansible-runner/0.2/raw
```

Verify the created tasks:

```shell
tkn task ls
```

## Parameters

* **project-dir**: The ansible-runner private data dir
* **args:**: The array of arguments to pass to the runner command (_default:_ --help)
* **user-home**: Absolute path to the user's home directory. (_default:_ /tekton/home)

## Workspaces

* **runner-dir**: A [workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) to hold the `private_data_dir` as described in https://ansible-runner.readthedocs.io/en/latest/intro.html#runner-input-directory-hierarchy[Runner Directory]

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

The TaskRun uses the repository https://github.com/vinamra28/tektoncd-ansible-runner-example, that houses some example playbooks.

All the examples will be run in namespace called `funstuff`. Create the namespace and shift the context to it:

```shell
   kubectl create ns funstuff && \
   kubectl config set-context --current --namespace=funstuff
```

### Create the PVC and clone example sources

```shell
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/git-clone/0.5/raw \
  -f  https://raw.githubusercontent.com/tektoncd/catalog/main/task/ansible-runner/0.2/support/playbooks-pvc.yaml
```

Do the git clone of the examples repository:

```shell
tkn task start git-clone \
  --workspace=name=output,claimName=ansible-playbooks \
  --param=url=https://github.com/vinamra28/tektoncd-ansible-runner-example \
  --param=revision=master \
  --param=deleteExisting=true \
  --showlog
```

### Create the Service Account

As we will do get, list and create on the namespace, lets use a service account that has right RBAC:

```shell
kubectl apply -f  https://raw.githubusercontent.com/tektoncd/catalog/main/task/ansible-runner/0.2/support/ansible-deployer.yaml
```

### Run Tasks

List the pods of `kube-system` namespace:

```shell
 tkn task start ansible-runner \
   --serviceaccount ansible-deployer-account \
   --param=project-dir=kubernetes \
   --param=args=-p,list-pods.yml \
   --workspace=name=runner-dir,claimName=ansible-playbooks \
   --showlog
```

### Create Deployment

Create a deployment in  `funstuff` namespace:

```shell
 tkn task start ansible-runner \
   --serviceaccount ansible-deployer-account \
   --param=project-dir=kubernetes \
   --param=args=-p,create-deployment.yml \
   --workspace=name=runner-dir,claimName=ansible-playbooks \
   --showlog
```

### Create Service

Create a service in `funstuff` namespace:

```shell
 tkn task start ansible-runner \
   --serviceaccount ansible-deployer-account \
   --param=project-dir=kubernetes \
   --param=args=-p,create-service.yml \
   --workspace=name=runner-dir,claimName=ansible-playbooks \
   --showlog
```
