# GitHub app token

A task to get a user token from a github application

## Workspaces

- **secrets**: A workspace containing the private key of the application.

## Secret

This GitHub applications needs a private key to sign your request with JWT. 

[This](../0.1/samples/secret.yaml) example can be referred to create the secret

Refer [this](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html) guide for setting up AWS Credentials and Region.


## Params

* **installation_id:** The GitHub app installation ID _eg:_ `123456`
* **application_id:** The GitHub application ID. _e.g:_ `123456`
* **private_key_path:** The path to the key inside the secret workspace, _default:_
  `private.key`
* **token_expiration_minutes:**: The time to expirations of the token in minutes _default:_ `10`


### Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/github-app-token/0.1/raw
```

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

After creating the task with the parameters, you should have the token as result in the task which can
be used in your pipeline to do github operations from the app as the target user.

See [this](../0.1/samples/run.yaml) taskrun example on how to start the task directly.

