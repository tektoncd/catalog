# AB-load

The ab-load task execute an http/https load test again't a targeted endpoint using the Apache benchmark toolkit.

## Install the AB-load task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/ab-load/0.1/ab-load.yaml
```

## Parameters

| Key              | Default                             | Description                                                                                                     |
| ---------------- | ----------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| url              |                                     | The URL targeted by the load test (must end with / if root domain is targeted)                                  |
| method           | `GET`                               | The HTTP method name                                                                                            |
| type             | `application/x-www-form-urlencoded` | The http type of payload sended to the target endpoint (for POST and PUT method)                                |
| size             | `1000`                              | Number of requests to perform                                                                                   |
| concurrency      | `10`                                | Number of concurent requests to execute                                                                         |
| timeout          | `5`                                 | Seconds to wait for each response before ending up the connection and considering it's a bad answer             |
| additionnalFlags | `-k -I`                             | All ab command supported flag (ex: -k for keepalive or -I for insecure https connection)                        |
| payload          | `content.txt`                       | Name of the file with content to send for POST or PUT request. The file is stored in the body-content workspace |
| image            | `quay.io/startx/apache:alpine3`     | The image name to use for this task                                                                             |


## Workspaces

| Key          | Mount           | Description                                                                                                                                                                                                   |
| ------------ | --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| body-content | `/tmp/postfile` | Data to send to the endpoint must have a `content` key with content ready to send to the endpoint. Could be from a `configMap`, a `secret` or a `persistentVolumeClaim` as soon as they have a `content` key. |

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

Theses examples use a default configuration set to :

- Execute `1000` requests for each test, with
- `10` concurrency request are executed a the same time
- requests timeout after `5` seconds 
- Connection use http keepalive session
- insecure connection could be used

### Simple Http GET example


```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: ab-load-get-example-run
spec:
  taskRef:
    name: ab-load
  params:
    - name: url
      value: "https://startx.free.beeceptor.com/"
```


### Simple Http POST example

If you plan to target a POST endpoint, you should create an `ab-load-post-example` configMap ([example](https://github.com/tektoncd/catalog/tree/main/task/ab-load/0.1/samples/ab-load-post-example.yaml)) prior to executing your ab POST load test.


```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: ab-load-post-example-run
spec:
  taskRef:
    name: ab-load
  params:
    - name: url
      value: "https://startx.free.beeceptor.com/"
    - name: method
      value: POST
  workspaces:
  - name: body-content
    configMap:
      name: ab-load-post-example
```