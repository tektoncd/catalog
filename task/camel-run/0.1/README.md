# Camel run

This Task runs [Apache Camel](https://camel.apache.org/) integrations using [Camel JBang](https://camel.apache.org/manual/camel-jbang.html).

Camel JBang is a lightweight tool for running Camel routes without requiring complex setup or operators. It supports multiple runtimes (Camel Main, Spring Boot, Quarkus) and provides features like live reload, developer console, and observability.

## Install the Task

```shell
kubectl apply -f https://github.com/tektoncd/catalog/raw/main/task/camel-run/0.1/camel-run.yaml
```

## Prerequisites

When using this task in a pipeline with `git-clone` task (as shown in the samples), you need to install the git-clone task first, if it is not already available:

```shell
kubectl apply -f https://github.com/tektoncd/catalog/raw/main/task/git-clone/0.10/git-clone.yaml
```

## Parameters

- **camel-jbang-image**: The name of the image containing the Camel JBang CLI (_default:_ docker.io/apache/camel-jbang:4.17.0). For production use, consider using a digest reference like `docker.io/apache/camel-jbang@sha256:7979e8c9e25d6ff136372f60ad7be74af3e1cee2e279d95b666bdae40d3b64e4`
- **filename**: The Camel file(s) to run. Multiple files separated by space (_default:_ empty, will use application.properties). _Format:_ `"file1.yaml file2.yaml"` or `"route.yaml"`
- **runtime**: Runtime to use. Valid values: `camel-main`, `spring-boot`, `quarkus` (_default:_ camel-main).
- **dependencies**: Additional dependencies to add. Comma-separated list (_default:_ empty). _Format:_ `"org.apache.camel:camel-http,org.apache.camel:camel-jackson"`
- **properties**: Comma separated list of properties files (_default:_ empty). _Format:_ `"application.properties,custom.properties"`
- **property**: Additional properties in key=value format. Multiple properties separated by space (_default:_ empty). _Format:_ `"key1=value1 key2=value2"`
- **port**: Port for embedded HTTP server. Use 0 for dynamic port, -1 to disable (_default:_ "-1").
- **max-seconds**: Maximum seconds to run before stopping. Use 0 for unlimited (_default:_ "0").
- **logging-level**: Logging level: ERROR, WARN, INFO, DEBUG, or TRACE (_default:_ info).
- **dev**: Enable dev mode with live reload when source files are updated (_default:_ "false").
- **console**: Enable developer console at /q/dev (_default:_ "false").
- **observe**: Enable observability services including health and metrics endpoints (_default:_ "false").
- **extra-args**: Additional arguments to pass to camel run command (_default:_ empty).
- **output-log**: Path to save camel run output log. If empty, no log file will be generated (_default:_ "$(workspaces.source.path)/camel-run.log").

## Workspaces

* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) containing the Camel source files to run.

## Results

- **exit-code**: The exit code from the camel run command.

## Platforms

The Task can be run on `linux/amd64` platform.

## Security

This task runs as a non-root user (UID 1000) for security. The task uses environment variables to pass parameters to the script, preventing script injection vulnerabilities.

## Usage

### Basic Usage

Run a simple Camel route:

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: camel-run-example
spec:
  taskRef:
    name: camel-run
  params:
    - name: filename
      value: route.yaml
  workspaces:
    - name: source
      persistentVolumeClaim:
        claimName: camel-source-pvc
```

### With Properties and Dependencies

Run a Camel route with external dependencies and properties:

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: camel-run-advanced
spec:
  taskRef:
    name: camel-run
  params:
    - name: filename
      value: route.yaml
    - name: dependencies
      value: "org.apache.camel:camel-http,org.apache.camel:camel-opentelemetry2"
    - name: properties
      value: "application.properties"
    - name: property
      value: "camel.component.http.timeout=5000"
    - name: port
      value: "8080"
    - name: logging-level
      value: "DEBUG"
  workspaces:
    - name: source
      persistentVolumeClaim:
        claimName: camel-source-pvc
```

### Dev Mode with Console

Run in development mode with live reload and developer console:

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: camel-run-dev
spec:
  taskRef:
    name: camel-run
  params:
    - name: filename
      value: route.yaml
    - name: dev
      value: "true"
    - name: console
      value: "true"
    - name: port
      value: "8080"
  workspaces:
    - name: source
      persistentVolumeClaim:
        claimName: camel-source-pvc
```

### Using Different Runtime

Run with Quarkus runtime:

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: camel-run-quarkus
spec:
  taskRef:
    name: camel-run
  params:
    - name: filename
      value: route.yaml
    - name: runtime
      value: "quarkus"
  workspaces:
    - name: source
      persistentVolumeClaim:
        claimName: camel-source-pvc
```

## Integration with Pipelines

Use the [sample pipeline](../0.1/samples/run-basic.yaml) as a reference for integrating camel-run into a complete CI/CD pipeline that fetches code from Git and runs the Camel integration.

### Circuit Breaker Example

The sample pipeline demonstrates running the [circuit-breaker example](https://github.com/apache/camel-jbang-examples/tree/main/circuit-breaker) from the Apache Camel JBang examples repository. This example shows how to use the Circuit Breaker Enterprise Integration Pattern (EIP) with Camel JBang. The pipeline:

1. Fetches the camel-jbang-examples repository using the git-clone task
2. Runs the circuit-breaker route for 30 seconds
3. Demonstrates how the circuit breaker state changes from closed to open when failures occur

The circuit-breaker example is ideal for demonstrating Camel's resilience patterns and can be monitored to observe state transitions during execution.

To run the sample pipeline:

```shell
# Install required tasks
kubectl apply -f https://github.com/tektoncd/catalog/raw/main/task/git-clone/0.10/git-clone.yaml
kubectl apply -f https://github.com/tektoncd/catalog/raw/main/task/camel-run/0.1/camel-run.yaml

# Run the sample pipeline
kubectl apply -f https://github.com/tektoncd/catalog/raw/main/task/camel-run/0.1/samples/run-basic.yaml
```
