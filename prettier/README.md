# Prettier Tasks

This `Task` is for running [Prettier](https://prettier.io/) code formatter against the provided source code in the Workspace. By default this `Task` will check the format of files in the root of your Workspace.

## Workspaces

 - **source**: A workspace for this Task to fetch the source the code. 
 
## Parameters

 - **args**: Prettier arguments used to run Prettier. See [Prettier CLI](https://prettier.io/docs/en/cli.html) for the arguments. (_default:_ `--check .`)
 - **prettierImage**: Prettier image used to run Prettier. (_default:_ elnebuloso/prettier:latest)

## Usage

The following pipeline uses the `prettier-check` `Task` to format the file `build.yaml` from [`catalog/golang`](https://github.com/tektoncd/catalog/tree/v1beta1/golang). The pipeline has two tasks: the [`git-clone`](https://github.com/tektoncd/catalog/blob/v1beta1/git/git-clone.yaml) `Task` is the first task to clone the repository to the "shared-workspace"; the `prettier-check` `Task` runs after `git-clone` `Task` to format the source code.

 - [Formatting a file](./tests/run.yaml)
