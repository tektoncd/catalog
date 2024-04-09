# YQ Task

The following task is used to execute a given JQ script and expose its result. It is able to work with both JSON string and file as input to the script.

## Installing the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/jq/0.1/raw
```

## Parameters

- **script**: JQ script that will be executed. If none is provided, the command jq '.' will be executed by default.
- **image**: The jq image to use.
- **input**: The input to be passed to the JQ command. It can be a JSON string or a file name.
- **stringOrFile**: Flag used to determine whether the input passed will be a JSON string or file.

## Workspaces

- **source** : The workspace containing files on which we want to do the replacement on a single file.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

For an example of real-world usage, check the **tests** directory for this task for an example of how it can be used.

For cases where it is necessary to pass large JSON sections as input parameter, it is recommended to enter the full path of a file as the parameter's value. Therefore, the **stringOrFile** parameter must be properly configured.

The **stringOrFile** parameter is of type **enum** and requires the **enable-param-enum parameter** to be enabled in TektonConfig.