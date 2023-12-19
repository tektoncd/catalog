# Sonatype

Contains all the tasks which use the Sonatype Lifecycle CLI.

## Tasks

This is a description of all the tasks, along with parameters, and installation instructions.

- Neuxs Lifecycle Scan Task (nexus-lifecycle-scan.yml)

----

### Neuxs Lifecycle Scan Task (nexus-lifecycle-scan.yml)

Invokes a Nexus Lifecycle scan

#### Install Task

```shell
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/nexus-lifecycle-scan/0.1/raw
```

#### Parameters

The CLI has it's own default parameters.  This task inherets the default parameters for the CLI.  To learn more about the default parameters, visit the CLI documentation at [Nexus IQ CLI Docs](https://hub.docker.com/r/sonatype/nexus-iq-cli).

name                        | description                                                                                                   | required  | default
---------                   | -------------------------------------------                                                                   | --------  | -------
SERVER_URL                  | URL to the IQ Server that will evaluate policies                                                              |     x     |
AUTHENTICATION              | Authentication credentials to use for the IQ Server                                                           |     x     |
APPLICATION_ID              | Public ID of the application on the IQ Server                                                                 |     x     |
STAGE                       | The stage to run analysis against. Accepted values: [develop, build, stage-release, release, operate]         |     x     | [See CLI Default](https://hub.docker.com/r/sonatype/nexus-iq-cli)
RESULT_FILE                 | Path to a JSON file where the results of the policy evaluation will be stored in a machine-readable format.   |           | [See CLI Default](https://hub.docker.com/r/sonatype/nexus-iq-cli)
REPORT_FORMAT               | The format of the HTML evaluation report. Accepted values: [summary, enhanced]                                |           | [See CLI Default](https://hub.docker.com/r/sonatype/nexus-iq-cli)
FAIL_ON_POLICY_WARNINGS     | Fail on policy evaluation warnings                                                                            |           | [See CLI Default](https://hub.docker.com/r/sonatype/nexus-iq-cli)
IGNORE_SYSTEM_ERRORS        | Ignore system errors (IO, network, server, etc).                                                              |           | [See CLI Default](https://hub.docker.com/r/sonatype/nexus-iq-cli)
PROXY                       | Proxy to use                                                                                                  |           | [See CLI Default](https://hub.docker.com/r/sonatype/nexus-iq-cli)
PROXY_USER                  | Credentials to use for the proxy                                                                              |           | [See CLI Default](https://hub.docker.com/r/sonatype/nexus-iq-cli)
DEBUG                       | Enable debug logs. WARNING: This may expose sensitive information in the log.                                 |           | [See CLI Default](https://hub.docker.com/r/sonatype/nexus-iq-cli)
HELP                        | Show the help screen                                                                                          |           | [See CLI Default](https://hub.docker.com/r/sonatype/nexus-iq-cli)
TARGETS                     | Scan targets                                                                                                  |     x     |

----
