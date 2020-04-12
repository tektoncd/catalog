## Execute Tests

To execute the tests, you must add the ```cm-newman-env.yaml``` configmap prior to running the tests. Please use these commands to execute the test:

```
kubectl apply -f ../newman.yaml
kubectl apply -f cm-newman-env.yaml
kubectl apply -f pipeline.yaml
```