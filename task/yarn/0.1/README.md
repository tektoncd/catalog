# YARN CLI

This task can be used to run `yarn` goals on a source code with the default environment as `CI=true` and has some pre-defined scripts in `package.json` file.

## Install the Task

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/yarn/0.1/yarn.yaml
```

## Parameters

- **PATH_CONTEXT**: The path where `package.json` and `yarn.lock` of the project iares defined. (_Default: `"."`_)

- **ARGS**: The yarn goals you want to run. (_Default: `version`_)

- **IMAGE**: The node image you want to use. (_Default: docker.io/library/node:12-alpine@sha256:12048cdfd75d944df35f3144132d9bdeee78015fbd6df765edad1be46599b110_)

## Workspaces

- **source**: The place which consists of the project.

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x`, and `linux/ppc64le` platforms.

## Usage 

1. Apply the [`git-clone`](https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.2/git-clone.yaml) task which will help to clone the repository.

2. Apply the sample [yarn-run.yaml](https://raw.githubusercontent.com/tektoncd/catalog/main/task/yarn/0.1/tests/yarn-run.yaml) which will clone the [tektoncd/hub](https://github.com/tektoncd/hub) repo and perform few npm goals:-
   - install dependencies using `yarn install` or just `yarn`  
   - run unit tests using `yarn test`
   - run build tests using `yarn run build`

