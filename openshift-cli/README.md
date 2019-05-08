## Openshift-Client

`oc` is a tool which is used to interact with OpenShift from the command line. The following section provides two examples to interact with OpenShift Cluster from Tekton Pipelines.

The `Dockerfile` of the `oc` binary has been added and the image is available [here]( https://quay.io/repository/openshift-pipeline/openshift-cli).

## Prerequisite 

Tekton needs to be installed on your OpenShift Cluster. Documentation for the same can be found [here](https://github.com/tektoncd/pipeline/blob/master/docs/install.md#installing-tekton-pipelines-on-openshift).

## Install the Task

   ```
   oc apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/openshift-cli/openshift-client-task.yaml
   ```

## Inputs

### Parameters

 - command - command to execute like `get pods` (default: `help`)

## Usage:

- Using `oc` on the same cluster using serviceAccount

- Using `oc` on a different cluster using clusterResource

## Using oc on the same cluster using serviceAccount

You can use the serviceAccount resource to interact on the same cluster with `oc` as follows: 

1. To interact with OpenShift in the cluster using `oc`, you need to create the [serviceAccount](https://docs.openshift.com/container-platform/3.11/dev_guide/service_accounts.html) resource with the required permissions and use that in the taskrun.
    
    - Create the serviceAccount resource.
    
        ```
        oc apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/openshift-cli/taskUsingServiceaccount/serviceaccount.yaml 
        ```
    
    - Create the role for the serviceAccount resource.
    
        ```
        oc apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/openshift-cli/taskUsingServiceaccount/role.yaml 
        ```
    
    - Create the roleBinding for the serviceAccount resource.
    
        ```
        oc apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/openshift-cli/taskUsingServiceaccount/rolebinding.yaml 
        ```
    
2. Create a pipeline which have the tasks for interacting with OpenShift.
    ```
    oc apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/openshift-cli/taskUsingServiceaccount/ocpipeline.yaml 
    ```

3. Create a pipelinerun to execute the pipeline just created.
    ```
    oc apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/openshift-cli/taskUsingServiceaccount/ocpipelinerun.yaml 
    ```

4. Check the logs of the pipeline by accessing the logs of a freshly created pods(Each task have one Pod).

## Using oc on a different cluster using clusterResource

You can use the clusterResource to interact on a different cluster with `oc` as follows: 

1. Create a [clusterResource](https://github.com/tektoncd/pipeline/blob/master/docs/resources.md#cluster-resource) with details for the second cluster. For example, here is a [sample ClusterResource](https://raw.githubusercontent.com/tektoncd/catalog/master/openshift-cli/taskUsingClusterResource/resource.yaml):

    ```yaml
    apiVersion: tekton.dev/v1alpha1
    kind: PipelineResource
    metadata:
      name: cluster-details
    spec:
      type: cluster
      params:
      - name: url
        value: cluster url
      - name: name
        value: oc-test
      - name: username
        value: test
      - name: token
        value: akakkakaaa
      - name: cadata
        value: data
    ```
 
2. Create a pipeline which have the tasks used to interact with the OpenShift Cluster
    
    ```
    oc apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/openshift-cli/taskUsingClusterResource/ocpipeline.yaml 
    ```

3. Create a pipelinerun to execute the pipeline you created. Make sure that the ClusterResource Name is used correctly in the pipelinerun.

    ```
    oc apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/openshift-cli/taskUsingClusterResource/ocpipelinerun.yaml 
    ```

4. Check the logs of the pipelinerun by accessing the logs of the freshly created pods(Each task have one Pod).