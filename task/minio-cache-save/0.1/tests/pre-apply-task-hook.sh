#!/bin/bash

cat <<EOF | kubectl apply -f- -n "${tns}"
# Deploys a new MinIO Pod into the metadata.namespace Kubernetes namespace
#
# The `spec.containers[0].args` contains the command run on the pod
# The `/data` directory corresponds to the `spec.containers[0].volumeMounts[0].mountPath`
# That mount path corresponds to a Kubernetes HostPath which binds `/data` to a local drive or volume on the worker node where the pod runs
#
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: minio
  name: minio
spec:
  containers:
  - name: minio
    image: quay.io/minio/minio:latest
    command:
    - /bin/bash
    - -c
    args:
    - minio server /data --console-address  :8080 --address :80
    volumeMounts:
    - mountPath: /data
      name: localvolume # Corresponds to the `spec.volumes` Persistent Volume
  volumes:
  - name: localvolume
    emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: minio
spec:
  ports:
    - port: 8080
      protocol: TCP
      targetPort: 8080
      name: console
    - port: 80
      protocol: TCP
      targetPort: 80
      name: api
  selector:
    app: minio
  sessionAffinity: None
  type: ClusterIP
---
apiVersion: v1
kind: Secret
metadata:
  name: minio-secret
type: Opaque
data:
  # bNkgKrYHlVf2aRRx
  accessKey: bWluaW9hZG1pbg==
  # anrmkT2fZa8hxr7qCl8CoyRr6JBllEij
  secretKey: bWluaW9hZG1pbg==
EOF


kubectl -n "${tns}" wait --for=condition=Ready=True --timeout=600s pod/minio
