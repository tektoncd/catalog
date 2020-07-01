# CloudEvent Task

Task to send a single CloudEvent to a specified sink.

## Parameters

* **sink**: Sink is the uri to send the event to

* **eventID**: Event ID to send

* **eventType**: The event type to send

  _default_: "tekton.cloudevent.message"

* **source**: Source to be set in the Cloudevent metadata.

  _default_: "cloudevent-catalog-task"

* **data**: Data payload to deliver

  _default_: ""`

## Development

The `ko` tool is required to update the task.yaml - see these [installation instructions](https://github.com/google/ko#installation).

Once you have ko, you can build the binary and resolve the task yaml into installable yaml.

`ko resolve -f config/task.yaml > task.yaml`

The go import path will be replaced in the yaml by the built container.
