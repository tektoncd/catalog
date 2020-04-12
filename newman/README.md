# Newman

[Newman](https://github.com/postmanlabs/newman) is a tool that is used to test REST APIs, it is the CLI equivalent of the popular tool [Postman](https://www.postman.com) enabling developers to run their Postman collections on the command line.

This task integrates Newman into Tekton enabling Pipelines to use it for automated testing of APIs.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/newman/newman.yaml
```

## Requirements

Newman (and Postman) use the concept of environments to enable the same tests to be executed against different environments (Dev, QA, Production, etc). The way this works is that developers typically specify variables in the collection that are then defined in an environment file. These variables are delineated with ``{{ }}``` in the collection and replaced at runtime with the key-value pairs defined in the envrionment file.

Since this is an important feature of an API testing tool, the tekton task supports this by defining a configmap called ```newman-env```. Within this configmap you can define multiple environment files enabling the pipeline to re-use the same test against multiple environments.

Here is an example ```newman-env``` configmap with multiple environment entries:

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: newman-env
data:
  newman-dev-env.json: |-
    {
      "id": "106ad0b7-2293-413b-9135-341e5a3f3c31",
      "name": "dev",
      "values": [
        {
          "key": "scheme",
          "value": "http",
          "enabled": true
        },
        {
          "key": "host",
          "value": "my-dev.ca",
          "enabled": true
        }
      ],
      "_postman_variable_scope": "environment"
    }
  newman-test-env.json: |-
    {
      "id": "106ad0b7-2293-413b-9135-341e5a3f3c32",
      "name": "test",
      "values": [
        {
          "key": "scheme",
          "value": "https",
          "enabled": true
        },
        {
          "key": "host",
          "value": "my-test.ca",
          "enabled": true
        }
      ],
      "_postman_variable_scope": "environment"
    }
```

Since it is very unlikely that developers would use Newman without an environment, the configmap is required to use this task.

## Inputs
### Parameters

- **COLLECTION**: The Postman collection that is to be executed by Newman. This will typically be a remote URL to the collection.
- **ENVIRONMENT**: The name of the environment file to use based on the supplied ```newman-env``` configmap. In the example about, this could be ```newman-dev-env.json```.

## Usage

This TaskRun runs a simple test against the Toronto Transit Commission's API, it requires the newman-env configmap from the tests folder.

```
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: newman-run
spec:
  taskRef:
    name: newman
  inputs:
    params:
    - name: COLLECTION
      value: https://raw.githubusercontent.com/gnunn1/catalog/master/newman/tests/newman-test-collection.json
    - name: ENVIRONMENT
      value: newman-env.json
```