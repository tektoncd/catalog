# Prometheus Gate

A simple gate task which will query the prometheus API in a loop and await a matching status for N length of time.

Code for the gate container is located at [github.com/iancoffey/prometheus-gate](https://github.com/iancoffey/prometheus-gate).

## Strategy

Currently, it is possible to enforce that a returned range query values all meet min, max and equals comparisons. Soon, p95 and p99 will be added as well.

- *`min`* - enforce a minimum value for the time period
- *`max`* - enforce value does not exceed target during time period
- *`equals`* - enforce a target equals value for the entire time period

## Range Query

The gate can make use of any valid [range query](https://prometheus.io/docs/prometheus/latest/querying/api/#range-queries). This approach works best when the dataset returned is tighly scoped via the range query itself. The gate considers an empty dataset as a failure to be retried.

### Parameters

* **prometheus_endpoint:**: Prometheus API endpoint
* **range_query:**: The range query to use to define SLO
* **range_time:**: The time we want to assert fits the SLO`
* **target_value:**: The target value to assert
* **target_strategy:**: min, max or equals. p95/99 not supported yet
* **timeout:**: Maximum ticker time for gate
* **tick_time:**: How often to try to assert the desired SLO

## Platforms

The Task can be run on `linux/amd64` platform.