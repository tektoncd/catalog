# 42Crunch REST API Static Security Testing

The REST API Static Security Testing task performs a static analysis of the OpenAPI definitions that includes more than 300
checks on best practices and potential vulnerabilities on how the API defines authentication, authorization, transport,
and data coming in and going out.

## Install the Task

Install `42crunch-api-security-audit` task:

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/42crunch-api-security-audit/0.1/raw
```

## Prerequisites

Create an API token in 42Crunch Platform and store it in a secret.

```
apiVersion: v1
kind: Secret
metadata:
  name: 42crunch-api-token
type: Opaque
data:
  X42C_API_TOKEN: "{{BASE64 encoded 42Crunch API Token}}"
```

Save the above YAML to a file called `secret.yaml` inserting encoded token and run `kubectl apply -f secret.yaml` to create the secret.

This task uses Docker image for 42Crunch REST API Static Security Testing which is documented here: https://docs.42crunch.com/latest/content/tasks/integrate_audit_docker_image.htm

## Parameters

| Variable                     | Usage                                                                                                   |
| ---------------------------- | ------------------------------------------------------------------------------------------------------- |
| x42c_repository_url (\*)     | Source control repository URL. Needed to identify API collection on 42Crunch Platform.                  |
| x42c_branch_name (\*\*)      | Source control branch name.                                                                             |
| x42c_tag_name (\*\*)         | Source control tag name.                                                                                |
| x42c_pr_id (\*\*)            | Source control PR ID.                                                                                   |
| x42c_pr_target_branch        | Source control PR target branch name.                                                                   |
| x42c_secret_name (\*)        | Name of the secret that contains the API token to access 42Crunch Platform. Default: 42crunch-api-token |
| x42c_min_score               | Minimum score for OpenAPI files. Default: 75.                                                           |
| x42c_platform_url            | 42Crunch Platform URL. Default: https://platform.42crunch.com.                                          |
| x42c_default_collection_name | The default collection name used when creating collections for discovered apis.                         |
| x42c_log_level               | Log level, one of FATAL, ERROR, WARN, INFO, DEBUG. Default: INFO.                                       |
| x42c_share_everyone          | Share new API collections with everyone, one of: OFF, READ_ONLY, READ_WRITE. Default: OFF.              |

_(\*) = required parameter._

_(\*\*) = either one of these must be set. if x42c_pr_id is set, x42c_pr_target_branch must be set as well._

## Support

Support

The task is maintained by support@42crunch.com. If you run into an issue, or have a question not answered here, you can create a support ticket at https://support.42crunch.com.
