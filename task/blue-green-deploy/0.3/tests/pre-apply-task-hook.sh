#!/bin/bash
#This will create a sample deployment version v1 of the application and a service which will point to that deployment

cat <<EOF | kubectl apply -f- -n "${tns}"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
      version: v1
  template:
    metadata:
      labels:
        app: "myapp"
        version: "v1"
    spec:
      containers:
        - name: myapp
          image: quay.io/vinamra2807/social-client:v1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 3000
              name: http
---
apiVersion: v1
kind: Service
metadata:
  name: myapp
  labels:
    app: myapp
spec:
  type: NodePort
  ports:
    - port: 3000
      name: http
  selector:
    app: myapp
    version: v1
EOF

kubectl -n "${tns}" wait --for=condition=available --timeout=600s deployment/myapp-v1
