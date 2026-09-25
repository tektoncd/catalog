# Prometheus Gate Example

When provided with a valid Prometheus API endpoint and an event sink, the sample Pipeline will await there being 0 *kube_endpoint_address_not_ready* metrics for 5 minutes before proceding to the second step, which sends a CloudEvent.

## Params

**prometheus_endpoint**: The API endpoint of your local (or remote) Prometheus API. The gate will use this endpoint to submit a range query every minute.

**promotion_sink**: The URI to an event endpoint that can recieve events.

## PipelineRun

Edit the provided Pipeline run `gated-pipeline-run` to contain your prometheus API endpoint URI and an event sink promotion_sink.

Once it is accurate, run the pipleine with `kubectl apply -f ./pipelinerun.yaml`.
