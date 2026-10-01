# apko Task Tests

This directory contains test files for the apko Task.

## Prerequisites

- A Kubernetes cluster with Tekton Pipelines installed
- `kubectl` configured to communicate with your cluster
- Access to a container registry for pushing images

## Test Files

- `test-apko-config.yaml`: Contains a ConfigMap with a sample apko configuration
- `apko-test.yaml`: A TaskRun that uses the apko Task

## Running the Tests

1. Apply the test configuration:

   ```bash
   kubectl apply -f test-apko-config.yaml
   ```

2. Update the `apko-test.yaml` file with your container registry credentials:
   - Set `spec.params[0].value` to your container registry URL
   - Set `spec.params[1].value` to your container registry password or token

3. Apply the TaskRun:

   ```bash
   kubectl apply -f apko-test.yaml
   ```

4. Monitor the TaskRun:

   ```bash
   tkn taskrun logs -f apko-test
   ```

## Test Verification

After the TaskRun completes successfully, verify:

1. The image was built and pushed to your container registry
2. The TaskRun outputs the image digest and URL
3. The image can be pulled and runs the specified command

## Cleanup

To clean up the test resources:

```bash
kubectl delete -f test-apko-config.yaml
kubectl delete taskrun apko-test
```

## Note

These tests require access to a container registry and valid credentials. The tests are skipped by default in CI/CD pipelines.
