# Codecov

Upload your code coverage to [codecov.io](https://codecov.io)

## Installing the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/codecov/0.1/raw
```

## Parameters

- **codecov-token-secret**: Name of the secret holding the codecov token. (_Default_: `codecov-token`)
- **codecov-token-secret-key**: Name of the secret key holding the codecov token. (_Default_: `token`)
- **args**: Extra arguments to be passed to the codecov script, more details [here](https://docs.codecov.io/docs/about-the-codecov-bash-uploader#arguments) (_Default_: [`-Z`])

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

Generate the code coverage file for your project inside your workspace, see here
for the [codecov.io](https://codecov.io) documentation:

https://docs.codecov.io/docs/supported-languages

Follow with the codecov task to upload the coverage.

See [this sample](./samples/codecov.sample.yaml) for a task uploading the
coverage of a python application.
