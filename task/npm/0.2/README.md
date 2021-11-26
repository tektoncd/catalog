# NPM CLI

This task can be used to run `npm` or `yarn` goals on a source code with the default environment as `CI=true` and has some pre-defined scripts in `package.json` file.

## Install the Task

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/npm/0.2/npm.yaml
```

## Parameters

- **COMMAND**: The name of your prefered package manager, `yarn` or `npm`. (_Default: `npm`_)

- **PATH_CONTEXT**: The path where `package.json` and `yarn.lock` of the project is defined. (_Default: `"."`_)

- **ARGS**: The npm goals or yarn commands you want to run. (_Default: `version`_)

- **IMAGE**: The node image you want to use. (_Default: docker.io/library/node:12-alpine@sha256:12048cdfd75d944df35f3144132d9bdeee78015fbd6df765edad1be46599b110_)

## Workspaces

- **source**: The place which consists of the project.

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x`, and `linux/ppc64le` platforms.

## Usage for npm 

1. Apply the [`git-clone`](https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.2/git-clone.yaml) task which will help to clone the repository.

2. Apply the sample [npm-run.yaml](https://raw.githubusercontent.com/tektoncd/catalog/main/task/npm/0.2/tests/npm-run.yaml) which will clone the [tektoncd/hub](https://github.com/tektoncd/hub) repo and perform few npm goals:-
   - install dependencies using `npm clean-install`
   - perform `eslint` check on the source code using `npm run lint`.
   - run unit tests using `npm run test`
   - run build tests using `npm run build`

## Usage for yarn  

1. Apply the [`git-clone`](https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.2/git-clone.yaml) task which will help to clone the repository.

2. Apply the sample [yarn-run.yaml](https://raw.githubusercontent.com/tektoncd/catalog/main/task/npm/0.2/tests/yarn-run.yaml) which will clone the [tektoncd/hub](https://github.com/tektoncd/hub) repo and perform few yarn commands:-
   - install dependencies using `yarn install`.   
   - run unit tests using `yarn test`
   - run build tests using `yarn run build`