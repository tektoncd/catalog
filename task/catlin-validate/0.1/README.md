# Catlin Validate

* [Catlin](https://github.com/tektoncd/catlin) is a command-line tool that Lints Tekton Resources and Catalogs.
* Catlin Validate task supports running catlin validate for
    * An isolated task yaml that you want to submit to tekton catalog
    * A set of tasks that you want to submit to tekton catalog

## Catlin validate use cases

### Run catlin validate to quickly validate a sample task
* Imagine you are developing a task and you quickly want to run a catlin validate to check if this task can be submitted to the tekton catalog
* Without downloading catlin or having any knowledge on how to run catlin you can check if your task passes all catlin checks by simply running a taskrun
* A working taskrun is provided in the [tests](../0.1/tests/taskrun-success.yaml) folder. 
* [This](../0.1/tests/taskrun-success.yaml) taskrun validates a sample hello task. 
* The hello task yaml which we want to validate is injected in the source workspace in the appropriate folder structure using  [this](../0.1/tests/source-success-configmap.yaml) configMap.
* The filepath of the hello.yaml is supplied as a catlin-input using [this](../0.1/tests/input-configmap.yaml) configMap
* Thus without knowing anything about how to run catlin validate you can quickly lint your task yaml by simply following above steps

### Integrate catlin as a part of CI/CD pipelines for task
* You may have an internal tekton catalog or want to contribute to open source tekton catalog and before submitting your task to these you might want to run catlin validate checks as a part of a PR pipeline
* To acheive this you can easily integrate catlin-validate task to validate your task yamls as part of a PR CI/CD tekton pipeline. 


### Run catlin validate for multiple task submissions in your tekton catalog
* You might have multiple tasks submitted as a part of a PR to the tekton catalog
* Catlin Validate Task can be run to validate all the task files in the inputFile provided to the task
* Simply put the paths of all tasks in $(params.inputFile) and catlin validate task will lint all the tasks
* Check [Results](#results) to see what is the final result of the task when multiple tasks are provided as input to catlin-validate



## Parameters

### outputFile 
Name of the file that holds catlin validate output for each task. This file will be available in [catlin-output](#catlin-output) workspace
### inputFile
File that contains catlin input. This file contains relative paths to the task yaml's delimited by newline. Paths should adhere to the tekton task catalog standards. Check [input-configmap](../0.1/tests/input-configmap.yaml) for an example of an inputFile

### ignoreWarnings
Ignores any warnings in catlin output. If catlin output has only success and warnings, all warnings are ignored and final catlin output will be success


## Workspaces

### source
This workspace contains files on which catlin will be run. This can be the git repo of your tekton catalog. task yamls in this folder should have a path that follows tekton-catalog folder structure. Check [this](../0.1/tests/source-success-configmap.yaml) configmap and how it is injected into the cource workspace in [this](../0.1/tests/taskrun-success.yaml) taskrun as an example
### catlin-input
A workspace that contains [$(params.inputFile)](#inputfile) Check [this](../0.1/tests/input-configmap.yaml) configmap and how it is injected onto the catlin-input workspace in [this](../0.1/tests/taskrun-success.yaml) taskrun as an example
### catlin-output
A workspace that contains output of catlin validate. Output of each catlin validate command is sent to [$(params.outputFle)](#outputfile) in this workspace

## Results

### catlin-status
* catlin-status contains the final catlin-validate task result Success, Warning or Failure  which will depend on the cumulative output of catlin validate on all tasks
    * Final result will be success if there is no error and no warning for any of the task specified in [inputFile](#inputfile). 
    * Final result will be warning if there is no error and a warning for any of the task specified in [inputFile](#inputfile).
    * Final result will be failure if there an error in even one of the tasks specified in [inputFile](#inputfile)
    * Output for each catlin validate commmand is stored in [outFile](#outputfile) in [catlin-output](#catlin-output) workspace


## Platforms

The Task can be run on `linux/amd64` platform.

## Example
* [tests](../0.1/tests) folder contains an example which you can use as a reference to create a taskrun that will lint your task before submitting it to a tekton catalog
* You will need a kubernetes cluster to test the catlin task. You can use [minikube](https://minikube.sigs.k8s.io/docs/start/) or [Kind](https://kind.sigs.k8s.io/) to install a kubernetes cluster locally.

### Catlin Validate Success
* Follow the below steps to run the sample taskrun in your local cluster which validates a properly constructed task that adheres to catlin linting standards
```
git clone https://github.com/tektoncd/catalog.git
cd catalog/task/catlin-validate/0.1/tests
kubectl apply -f input-configmap.yaml
kubectl apply -f source-success-configmap.yaml
kubectl create -f taskrun-success.yaml
kubectl logs catlin-run-pod 
```
* Pod log output
```Defaulted container "step-catlin" out of: step-catlin, prepare (init), place-scripts (init), working-dir-initializer (init)
-------catlin output--------
FILE: /workspace/source/task/hello/0.1/hello.yaml

-------catlin output end--------
```



### Catlin Validate Warn
* Follow the below steps to run the sample taskrun in your local cluster which validates a task that has a warning.
* **Note** Warning will not fail the task. Task will still succeed but with [catlin-status](#catlin-status) as warning
```
git clone https://github.com/tektoncd/catalog.git
cd catalog/task/catlin-validate/0.1/tests
kubectl apply -f input-configmap.yaml
kubectl apply -f source-warn-configmap.yaml
kubectl create -f taskrun-warn.yaml
kubectl logs catlin-run-pod 
```
* Pod log output
```Defaulted container "step-catlin" out of: step-catlin, prepare (init), place-scripts (init), working-dir-initializer (init)
-------catlin output--------
FILE: /workspace/source/task/hello/0.1/hello.yaml
WARN : Step "echo" uses image "$(params.image)" that contains variables; skipping validation

-------catlin output end--------
```
* Catlin output logs are also stored in [$(params.outputFile)](#outputfile) in [catlin-output](#catlin-output) workspace. This workspace can be passed on to other tasks in case other tasks need to consume this output. An example would be git-comment task can use this workspace to post the catlin output logs to the PR created to add a task to tekton catalog


### Catlin Validate Error
* Follow the below steps to run the sample taskrun in your local cluster which validates a task that is non-conforming to the tekton-catalog standards
* **Note** Error will result in [catlin-status](#catlin-status) having the value as failure.
```
git clone https://github.com/tektoncd/catalog.git
cd catalog/task/catlin-validate/0.1/tests
kubectl apply -f input-configmap.yaml
kubectl apply -f source-error-configmap.yaml
kubectl create -f taskrun-error.yaml
kubectl logs catlin-run-pod 
```
* Pod logs output
```
Defaulted container "step-catlin" out of: step-catlin, prepare (init), place-scripts (init), working-dir-initializer (init)
Error: /workspace/source/task/hello/0.1/hello.yaml failed validation
-------catlin output--------
FILE: /workspace/source/task/hello/0.1/hello.yaml
ERROR: Resource path is invalid; expected path: task/hello/hello.yaml
ERROR: Task: tekton.dev/v1beta1 - name: "hello" must have a label "app.kubernetes.io/version" to indicate version
ERROR: Task: tekton.dev/v1beta1 - name: "hello" is missing a mandatory annotation for minimum pipeline version("tekton.dev/pipelines.minVersion")
ERROR: Task: tekton.dev/v1beta1 - name: "hello" is missing a mandatory annotation for category("tekton.dev/categories")
ERROR: Category not defined
You can choose from the categories present at location: https://raw.githubusercontent.com/tektoncd/hub/main/config.yaml"
HINT : Task: tekton.dev/v1beta1 - name: "hello" is missing a readable display name annotation("tekton.dev/displayName")
ERROR: Task: tekton.dev/v1beta1 - name: "hello" must have a description
HINT : Task: tekton.dev/v1beta1 - name: "hello" is easily discoverable if it has annotation for tag "tekton.dev/tags"
HINT : Task: tekton.dev/v1beta1 - name: "hello" is more usable if it has "tekton.dev/platforms" annotation about platforms to run
WARN : Step "echo" uses image "alpine"; consider using a fully qualified name - e.g. docker.io/library/ubuntu:1.0
ERROR: Step "echo" uses image "alpine" which must be tagged with a specific version

-------catlin output end--------
```

* Catlin output is also stored in [$(params.outputFile)](#outputfile) in [catlin-output](#catlin-output) workspace. This workspace can be passed on to other tasks in case other tasks need to consume this output. An example would be binding the output workspace to a workspace in git-comment to post the catlin output as a comment for a PR of a new task submission
