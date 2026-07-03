

# Tekton Task: Submit Python Scripts to Ray Cluster

This Tekton Task allows you to submit Python scripts to a **Ray cluster** running on Kubernetes. Scripts can be stored in a **ConfigMap**, making pipelines modular, and Tekton handles the job submission via the Ray Job API.

---

## Features

* Submits Python scripts to a Ray cluster via **Ray Job API**
* Supports inline Python commands or scripts stored in **ConfigMaps**
* Fully parameterized Task (`rayAddress`, `entrypoint`, `workingDir`)
* Captures **Ray Job ID** and **Job Status** as Tekton results
* Works with Ray clusters deployed via **KubeRay operator**

---

## Prerequisites

* Kubernetes cluster with **Tekton Pipelines** installed
* **Ray cluster** deployed on Kubernetes using **KubeRay operator**
* Optional: ConfigMap containing your Python script
* Basic understanding of Tekton **Task** and **TaskRun** concepts

---

## Components

### 1. ConfigMap: `ray-python-script`

Holds the Python script to execute on the Ray cluster.

Example:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: ray-python-script
data:
  script.py: |
    #!/usr/bin/env python3
    import ray
    ray.init()
    print("Ray cluster resources:", ray.cluster_resources())
```

---

### 2. Tekton Task: `ray-job-submit`

Defines the steps to:

* Mount the script from the ConfigMap or run inline commands
* Submit the job to the Ray cluster via Ray Job API
* Capture Job ID and status as Tekton results

---

### 3. Tekton TaskRun: `ray-job-from-configmap`

Used to trigger the Task with parameters like:

* `rayAddress`: Ray head service URL
* `entrypoint`: Python command or file
* `workingDir`: Directory inside the workspace

Example TaskRun:

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: ray-job-from-configmap
  labels:
    app.kubernetes.io/version: "0.1"
  annotations:
    tekton.dev/pipelines.minVersion: '0.12.1'
    tekton.dev/categories: "Batch,AI"
    tekton.dev/tags: ray, ai, python, cluster
    tekton.dev/displayName: "Ray Job Submit from ConfigMap"
    tekton.dev/platforms: "linux/amd64"
spec:
  taskRef:
    name: ray-job-submit
  workspaces:
    - name: source
      configMap:
        name: ray-python-script
  params:
    - name: rayAddress
      value: "http://raycluster-kuberay-head-svc:8265"
    - name: entrypoint
      value: "python script.py"
    - name: workingDir
      value: "."
```

---

## How It Works

1. **Mount ConfigMap**: The Python script is mounted into `/workspace/source`.
2. **Submit job**: Tekton Task uses `ray job submit` to execute the script on the Ray cluster.
3. **Capture results**: Tekton records `jobId` and `jobStatus` for further automation or monitoring.
4. **View logs**: Ray prints script output to Tekton logs for debugging and auditing.

---

## Usage Workflow

1. Deploy **KubeRay Operator** and a **RayCluster**.
2. Create a **ConfigMap** containing your Python script.
3. Apply the **Tekton Task** definition.
4. Trigger the Task using a **TaskRun** and provide parameters like `rayAddress` and `entrypoint`.
5. Check logs and results:

```bash
kubectl logs taskrun/ray-job-from-configmap -f
kubectl get taskrun ray-job-from-configmap -o yaml
```

---

## Example Use Case

* Connect to a Ray cluster
* Inspect cluster resources
* Run distributed Python tasks (e.g., map-reduce, ML training)
* Retrieve Job ID and final status for CI/CD or automation pipelines

---

## Best Practices

* Keep Python scripts modular and reusable via ConfigMaps
* Avoid embedding cluster URLs in scripts—use Task parameters
* Use Task results (`jobId`, `jobStatus`) for downstream automation
* Monitor Tekton logs for job execution and debugging


