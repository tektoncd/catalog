# Composer

This task can be used to run `composer` on a source code in order to install / update libraries.

## Install the Task

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/composer/composer.yaml
```

## Parameters

- **PATH_CONTEXT**: The path where `composer.json` of the project is defined. (_Default: `"."`_)

- **ARGS**: Additional arguments you want to add to composer. (_Default: `install`_)

- **IMAGE**: The composer image you want to use. (_Default: composer:latest)

## Workspaces

- **source**: The location where the codebase can be found.

## Usage

1. Apply the [`git-clone`](https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.2/git-clone.yaml) task which will help to clone the repository.

2. Apply the sample [run.yaml](https://raw.githubusercontent.com/tektoncd/catalog/main/task/composer/tests/run.yaml) which will clone the [drupal](https://github.com/drupal/drupal) repo and install the libraries.
