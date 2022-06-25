#!/bin/bash
# This will deploy a cerberus service into the current cluster and
# wait for the signal to be ready for testing

# Adding the startx chart repository to make it easier to deploy cerberus context
helm repo add startx https://startxfr.github.io/helm-repository/packages/
# Install the cerberus instance into $tns namespace
helm install \
--set context.scope=tektoncd \
--set context.cluster=tektontest \
--set context.environment=test \
--set context.component=task \
--set context.app=cerberus-check \
--set context.version=0.1 \
--set project.enabled=false \
--set project.project.name="${tns}" \
--set cerberus.enabled=true \
--set cerberus.expose=false \
--set cerberus.kraken_allowed=false \
--set cerberus.watch_nodes=false \
--set cerberus.watch_cluster_operators=false \
--set cerberus.kubeconfig.mode=token \
--set cerberus.kubeconfig.token.server=https://api.cluster.example.com:6443 \
--set cerberus.kubeconfig.token.token="$(oc whoami -t)" \

kubectl -n "${tns}" wait --for=condition=available --timeout=600s deployment/cerberus
