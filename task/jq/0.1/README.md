# JQ Task

The following task is used to execute a given JQ script and expose its result. It is able to work with both JSON string and file as input to the script.

## Installing the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/jq/0.1/raw
```

## Parameters

- **options**: JQ options that will be used. If none is provided, the default value "" will be used."
- **filter**: JQ filter that will be executed. If none is provided, the the filter '.' will be executed by default. The filter does not need to be wrapped with ''.
- **image**: The jq image to use.
- **input**: The input to be passed to the JQ command. It can be a JSON string or a file name. In case of file pass the entire path where the file is mounted.
- **stringOrFile**: Flag used to determine whether the input passed will be a JSON string or file. Use **string** or **file**.

## Workspaces

- **source** : The workspace containing files on which we want to handle. This workspace can be a persistent volume or configmap.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

For an example of real-world usage, check the [**tests**](https://github.com/tektoncd/catalog/tree/main/task/jq/0.1/tests) directory for an example of how it can be used.

For cases where it is necessary to pass large JSON sections as input parameter, it is recommended to enter the full path of a file as the parameter's value. Therefore, the **stringOrFile** parameter must be properly configured.