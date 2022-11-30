# Gitlab | jq

Query the [Gitlab REST API](https://docs.gitlab.com/ee/api/#rest-api) and filter the response with [jq](https://stedolan.github.io/jq/).

## Params

* **PATH**: Example: "projects/278964/merge_requests"

* **FILTER**: The jq filter expression. See the jq manual for syntax: https://stedolan.github.io/jq/manual. By default outputs the web_url of the returned object(s). Outputs the id if web_url is not available.
 (_default:_ `if type == "array" then .[].web_url else .web_url end // if type == "array" then .[].id else .id end`)

* **DATA**: JSON body to send, if any.

* **METHOD**: The HTTP method. Uses curl default if empty.

* **JQ_EXTRA_ARGS**: Extra parameters to the jq command.

* **GITLAB_TOKEN_SECRET_NAME**: The name of the Kubernetes secret that contains the GitLab token
 (_default:_ `gitlab-api-secret`)

* **GITLAB_TOKEN_SECRET_KEY**: The key within the Kubernetes secret that contains the GitLab token
 (_default:_ `token`)

* **GITLAB_HOST_URL**: The GitLab host URL
 (_default:_ `https://gitlab.com`)

* **API_PATH_PREFIX**: The API path prefix
 (_default:_ `api/v4`)

* **CURL_IMAGE**: The image to send the request to the API. (_default:_ `docker.io/curlimages/curl@sha256:d6a01c11f0633375a173960ad741eca7460cbc776bb3bc2370e5571478b99459`)

* **JQ_IMAGE**: The image to filter the API response. (_default:_ `docker.io/stedolan/jq@sha256:a61ed0bca213081b64be94c5e1b402ea58bc549f457c2682a86704dd55231e09`)

* **RESPONSE_BODY_PATH**: Where to save the API response body before filtering it. (_default:_ `/workspace/gitlab_response.json`)

## Results

* **output**: Output of the Gitlab API response filter.

# Usage

```yaml
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: example-run
spec:
  pipelineSpec:
    tasks:
      - name: get-stars
        taskRef:
          name: gitlab-jq
        params:
          - name: PATH
            value: projects/8
          - name: FILTER
            value: >-
              .star_count
      - name: add-star
        taskRef:
          name: gitlab-jq
        params:
          - name: PATH
            value: projects/8/star
          - name: METHOD
            value: POST
```

# Limitations

The jq filter must be selective enough so that the jq output is no more than 4KB.
The maximum size of a Task's results is limited by the container termination message feature of Kubernetes.
See [#4808](https://github.com/tektoncd/pipeline/issues/4808).
