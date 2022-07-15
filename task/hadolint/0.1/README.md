# Hadolint

Tekton Task for hadolint https://github.com/hadolint/hadolint

A smarter Dockerfile linter that helps you build Docker images. 
The linter parses the Dockerfile into an AST and performs rules on top of the AST. 
It stands on the shoulders of ShellCheck to lint the Bash code inside `RUN` instructions.

## Install the Task
```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/hadolint/0.1/raw
```

## Pre-requisite
Install git-clone task from catalog
```
https://api.hub.tekton.dev/v1/resource/tekton/task/git-clone/0.3/raw
```

## Workspaces
* **source** : A Workspace containing your source directory.

## Parameters
* **ignore-rules** : A rule to ignore. Comma separated list of rule codes
* **dockerfile-path** : path to Dockerfile.
* **output-format** : The output format for the results [tty | json | checkstyle | codeclimate
        | gitlab_codeclimate | codacy] (default tty).

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

In the [tests](../0.1/tests/run.yaml), folder there is an example of the execution of the task, a [PVC](../0.1/tests/pvc.yaml) is used.


## Rules

An incomplete list of implemented rules. Click on the error code to get more
detailed information.

| Rule                                                         | Default Severity | Description                                                                                                                                         |
| :----------------------------------------------------------- | :--------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------- |
| [DL1001](https://github.com/hadolint/hadolint/wiki/DL1001)   | Ignore           | Please refrain from using inline ignore pragmas `# hadolint ignore=DLxxxx`.                                                                         |
| [DL3000](https://github.com/hadolint/hadolint/wiki/DL3000)   | Error            | Use absolute WORKDIR.                                                                                                                               |
| [DL3001](https://github.com/hadolint/hadolint/wiki/DL3001)   | Info             | For some bash commands it makes no sense running them in a Docker container like ssh, vim, shutdown, service, ps, free, top, kill, mount, ifconfig. |
| [DL3002](https://github.com/hadolint/hadolint/wiki/DL3002)   | Warning          | Last user should not be root.                                                                                                                       |
| [DL3003](https://github.com/hadolint/hadolint/wiki/DL3003)   | Warning          | Use WORKDIR to switch to a directory.                                                                                                               |
| [DL3004](https://github.com/hadolint/hadolint/wiki/DL3004)   | Error            | Do not use sudo as it leads to unpredictable behavior. Use a tool like gosu to enforce root.                                                        |
| [DL3005](https://github.com/hadolint/hadolint/wiki/DL3005)   | Error            | Do not use apt-get dist-upgrade.                                                                                                                    |
| [DL3006](https://github.com/hadolint/hadolint/wiki/DL3006)   | Warning          | Always tag the version of an image explicitly.                                                                                                      |
| [DL3007](https://github.com/hadolint/hadolint/wiki/DL3007)   | Warning          | Using latest is prone to errors if the image will ever update. Pin the version explicitly to a release tag.                                         |
| [DL3008](https://github.com/hadolint/hadolint/wiki/DL3008)   | Warning          | Pin versions in apt-get install.                                                                                                                    |
| [DL3009](https://github.com/hadolint/hadolint/wiki/DL3009)   | Info             | Delete the apt-get lists after installing something.                                                                                                |
| [DL3010](https://github.com/hadolint/hadolint/wiki/DL3010)   | Info             | Use ADD for extracting archives into an image.                                                                                                      |
| [DL3011](https://github.com/hadolint/hadolint/wiki/DL3011)   | Error            | Valid UNIX ports range from 0 to 65535.                                                                                                             |
| [DL3012](https://github.com/hadolint/hadolint/wiki/DL3012)   | Error            | Multiple `HEALTHCHECK` instructions.                                                                                                                |
| [DL3013](https://github.com/hadolint/hadolint/wiki/DL3013)   | Warning          | Pin versions in pip.                                                                                                                                |
| [DL3014](https://github.com/hadolint/hadolint/wiki/DL3014)   | Warning          | Use the `-y` switch.                                                                                                                                |
| [DL3015](https://github.com/hadolint/hadolint/wiki/DL3015)   | Info             | Avoid additional packages by specifying --no-install-recommends.                                                                                    |
| [DL3016](https://github.com/hadolint/hadolint/wiki/DL3016)   | Warning          | Pin versions in `npm`.                                                                                                                              |
| [DL3018](https://github.com/hadolint/hadolint/wiki/DL3018)   | Warning          | Pin versions in apk add. Instead of `apk add <package>` use `apk add <package>=<version>`.                                                          |
| [DL3019](https://github.com/hadolint/hadolint/wiki/DL3019)   | Info             | Use the `--no-cache` switch to avoid the need to use `--update` and remove `/var/cache/apk/*` when done installing packages.                        |
| [DL3020](https://github.com/hadolint/hadolint/wiki/DL3020)   | Error            | Use `COPY` instead of `ADD` for files and folders.                                                                                                  |
| [DL3021](https://github.com/hadolint/hadolint/wiki/DL3021)   | Error            | `COPY` with more than 2 arguments requires the last argument to end with `/`                                                                        |
| [DL3022](https://github.com/hadolint/hadolint/wiki/DL3022)   | Warning          | `COPY --from` should reference a previously defined `FROM` alias                                                                                    |
| [DL3023](https://github.com/hadolint/hadolint/wiki/DL3023)   | Error            | `COPY --from` cannot reference its own `FROM` alias                                                                                                 |
| [DL3024](https://github.com/hadolint/hadolint/wiki/DL3024)   | Error            | `FROM` aliases (stage names) must be unique                                                                                                         |
| [DL3025](https://github.com/hadolint/hadolint/wiki/DL3025)   | Warning          | Use arguments JSON notation for CMD and ENTRYPOINT arguments                                                                                        |
| [DL3026](https://github.com/hadolint/hadolint/wiki/DL3026)   | Error            | Use only an allowed registry in the FROM image                                                                                                      |
| [DL3027](https://github.com/hadolint/hadolint/wiki/DL3027)   | Warning          | Do not use `apt` as it is meant to be a end-user tool, use `apt-get` or `apt-cache` instead                                                         |
| [DL3028](https://github.com/hadolint/hadolint/wiki/DL3028)   | Warning          | Pin versions in gem install. Instead of `gem install <gem>` use `gem install <gem>:<version>`                                                       |
| [DL3029](https://github.com/hadolint/hadolint/wiki/DL3029)   | Warning          | Do not use --platform flag with FROM.                                                                                                               |
| [DL3030](https://github.com/hadolint/hadolint/wiki/DL3030)   | Warning          | Use the `-y` switch to avoid manual input `yum install -y <package>`                                                                                |
| [DL3032](https://github.com/hadolint/hadolint/wiki/DL3032)   | Warning          | `yum clean all` missing after yum command.                                                                                                          |
| [DL3033](https://github.com/hadolint/hadolint/wiki/DL3033)   | Warning          | Specify version with `yum install -y <package>-<version>`                                                                                           |
| [DL3034](https://github.com/hadolint/hadolint/wiki/DL3034)   | Warning          | Non-interactive switch missing from `zypper` command: `zypper install -y`                                                                           |
| [DL3035](https://github.com/hadolint/hadolint/wiki/DL3035)   | Warning          | Do not use `zypper dist-upgrade`.                                                                                                                   |
| [DL3036](https://github.com/hadolint/hadolint/wiki/DL3036)   | Warning          | `zypper clean` missing after zypper use.                                                                                                            |
| [DL3037](https://github.com/hadolint/hadolint/wiki/DL3037)   | Warning          | Specify version with `zypper install -y <package>[=]<version>`.                                                                                     |
| [DL3038](https://github.com/hadolint/hadolint/wiki/DL3038)   | Warning          | Use the `-y` switch to avoid manual input `dnf install -y <package>`                                                                                |
| [DL3040](https://github.com/hadolint/hadolint/wiki/DL3040)   | Warning          | `dnf clean all` missing after dnf command.                                                                                                          |
| [DL3041](https://github.com/hadolint/hadolint/wiki/DL3041)   | Warning          | Specify version with `dnf install -y <package>-<version>`                                                                                           |
| [DL3042](https://github.com/hadolint/hadolint/wiki/DL3042)   | Warning          | Avoid cache directory with `pip install --no-cache-dir <package>`.                                                                                  |
| [DL3043](https://github.com/hadolint/hadolint/wiki/DL3043)   | Error            | `ONBUILD`, `FROM` or `MAINTAINER` triggered from within `ONBUILD` instruction.                                                                      |
| [DL3044](https://github.com/hadolint/hadolint/wiki/DL3044)   | Error            | Do not refer to an environment variable within the same `ENV` statement where it is defined.                                                        |
| [DL3045](https://github.com/hadolint/hadolint/wiki/DL3045)   | Warning          | `COPY` to a relative destination without `WORKDIR` set.                                                                                             |
| [DL3046](https://github.com/hadolint/hadolint/wiki/DL3046)   | Warning          | `useradd` without flag `-l` and high UID will result in excessively large Image.                                                                    |
| [DL3047](https://github.com/hadolint/hadolint/wiki/DL3047)   | Info             | `wget` without flag `--progress` will result in excessively bloated build logs when downloading larger files.                                       |
| [DL3048](https://github.com/hadolint/hadolint/wiki/DL3048)   | Style            | Invalid Label Key                                                                                                                                   |
| [DL3049](https://github.com/hadolint/hadolint/wiki/DL3049)   | Info             | Label `<label>` is missing.                                                                                                                         |
| [DL3050](https://github.com/hadolint/hadolint/wiki/DL3050)   | Info             | Superfluous label(s) present.                                                                                                                       |
| [DL3051](https://github.com/hadolint/hadolint/wiki/DL3051)   | Warning          | Label `<label>` is empty.                                                                                                                           |
| [DL3052](https://github.com/hadolint/hadolint/wiki/DL3052)   | Warning          | Label `<label>` is not a valid URL.                                                                                                                 |
| [DL3053](https://github.com/hadolint/hadolint/wiki/DL3053)   | Warning          | Label `<label>` is not a valid time format - must be conform to RFC3339.                                                                            |
| [DL3054](https://github.com/hadolint/hadolint/wiki/DL3054)   | Warning          | Label `<label>` is not a valid SPDX license identifier.                                                                                             |
| [DL3055](https://github.com/hadolint/hadolint/wiki/DL3055)   | Warning          | Label `<label>` is not a valid git hash.                                                                                                            |
| [DL3056](https://github.com/hadolint/hadolint/wiki/DL3056)   | Warning          | Label `<label>` does not conform to semantic versioning.                                                                                            |
| [DL3057](https://github.com/hadolint/hadolint/wiki/DL3057)   | Ignore           | `HEALTHCHECK` instruction missing.                                                                                                                  |
| [DL3058](https://github.com/hadolint/hadolint/wiki/DL3058)   | Warning          | Label `<label>` is not a valid email format - must be conform to RFC5322.                                                                           |
| [DL3059](https://github.com/hadolint/hadolint/wiki/DL3059)   | Info             | Multiple consecutive `RUN` instructions. Consider consolidation.                                                                                    |
| [DL3060](https://github.com/hadolint/hadolint/wiki/DL3060)   | Info             | `yarn cache clean` missing after `yarn install` was run.                                                                                            |
| [DL4000](https://github.com/hadolint/hadolint/wiki/DL4000)   | Error            | MAINTAINER is deprecated.                                                                                                                           |
| [DL4001](https://github.com/hadolint/hadolint/wiki/DL4001)   | Warning          | Either use Wget or Curl but not both.                                                                                                               |
| [DL4003](https://github.com/hadolint/hadolint/wiki/DL4003)   | Warning          | Multiple `CMD` instructions found.                                                                                                                  |
| [DL4004](https://github.com/hadolint/hadolint/wiki/DL4004)   | Error            | Multiple `ENTRYPOINT` instructions found.                                                                                                           |
| [DL4005](https://github.com/hadolint/hadolint/wiki/DL4005)   | Warning          | Use `SHELL` to change the default shell.                                                                                                            |
| [DL4006](https://github.com/hadolint/hadolint/wiki/DL4006)   | Warning          | Set the `SHELL` option -o pipefail before `RUN` with a pipe in it                                                                                   |
| [SC1000](https://github.com/koalaman/shellcheck/wiki/SC1000) |                  | `$` is not used specially and should therefore be escaped.                                                                                          |
| [SC1001](https://github.com/koalaman/shellcheck/wiki/SC1001) |                  | This `\c` will be a regular `'c'` in this context.                                                                                                  |
| [SC1007](https://github.com/koalaman/shellcheck/wiki/SC1007) |                  | Remove space after `=` if trying to assign a value (or for empty string, use `var='' ...`).                                                         |
| [SC1010](https://github.com/koalaman/shellcheck/wiki/SC1010) |                  | Use semicolon or linefeed before `done` (or quote to make it literal).                                                                              |
| [SC1018](https://github.com/koalaman/shellcheck/wiki/SC1018) |                  | This is a unicode non-breaking space. Delete it and retype as space.                                                                                |
| [SC1035](https://github.com/koalaman/shellcheck/wiki/SC1035) |                  | You need a space here                                                                                                                               |
| [SC1045](https://github.com/koalaman/shellcheck/wiki/SC1045) |                  | It's not `foo &; bar`, just `foo & bar`.                                                                                                            |
| [SC1065](https://github.com/koalaman/shellcheck/wiki/SC1065) |                  | Trying to declare parameters? Don't. Use `()` and refer to params as `$1`, `$2` etc.                                                                |
| [SC1066](https://github.com/koalaman/shellcheck/wiki/SC1066) |                  | Don't use $ on the left side of assignments.                                                                                                        |
| [SC1068](https://github.com/koalaman/shellcheck/wiki/SC1068) |                  | Don't put spaces around the `=` in assignments.                                                                                                     |
| [SC1077](https://github.com/koalaman/shellcheck/wiki/SC1077) |                  | For command expansion, the tick should slant left (\` vs ´).                                                                                        |
| [SC1078](https://github.com/koalaman/shellcheck/wiki/SC1078) |                  | Did you forget to close this double-quoted string?                                                                                                  |
| [SC1079](https://github.com/koalaman/shellcheck/wiki/SC1079) |                  | This is actually an end quote, but due to next char, it looks suspect.                                                                              |
| [SC1081](https://github.com/koalaman/shellcheck/wiki/SC1081) |                  | Scripts are case sensitive. Use `if`, not `If`.                                                                                                     |
| [SC1083](https://github.com/koalaman/shellcheck/wiki/SC1083) |                  | This `{/}` is literal. Check expression (missing `;/\n`?) or quote it.                                                                              |
| [SC1086](https://github.com/koalaman/shellcheck/wiki/SC1086) |                  | Don't use `$` on the iterator name in for loops.                                                                                                    |
| [SC1087](https://github.com/koalaman/shellcheck/wiki/SC1087) |                  | Braces are required when expanding arrays, as in `${array[idx]}`.                                                                                   |
| [SC1095](https://github.com/koalaman/shellcheck/wiki/SC1095) |                  | You need a space or linefeed between the function name and body.                                                                                    |
| [SC1097](https://github.com/koalaman/shellcheck/wiki/SC1097) |                  | Unexpected `==`. For assignment, use `=`. For comparison, use `[ .. ]` or `[[ .. ]]`.                                                               |
| [SC1098](https://github.com/koalaman/shellcheck/wiki/SC1098) |                  | Quote/escape special characters when using `eval`, e.g. `eval "a=(b)"`.                                                                             |
| [SC1099](https://github.com/koalaman/shellcheck/wiki/SC1099) |                  | You need a space before the `#`.                                                                                                                    |
| [SC2002](https://github.com/koalaman/shellcheck/wiki/SC2002) |                  | Useless cat. Consider <code>cmd < file &#124; ..</code> or <code>cmd file &#124; ..</code> instead.                                                 |
| [SC2015](https://github.com/koalaman/shellcheck/wiki/SC2015) |                  | Note that <code>A && B &#124;&#124; C</code> is not if-then-else. C may run when A is true.                                                         |
| [SC2026](https://github.com/koalaman/shellcheck/wiki/SC2026) |                  | This word is outside of quotes. Did you intend to 'nest '"'single quotes'"' instead'?                                                               |
| [SC2028](https://github.com/koalaman/shellcheck/wiki/SC2028) |                  | `echo` won't expand escape sequences. Consider `printf`.                                                                                            |
| [SC2035](https://github.com/koalaman/shellcheck/wiki/SC2035) |                  | Use `./*glob*` or `-- *glob*` so names with dashes won't become options.                                                                            |
| [SC2039](https://github.com/koalaman/shellcheck/wiki/SC2039) |                  | In POSIX sh, something is undefined.                                                                                                                |
| [SC2046](https://github.com/koalaman/shellcheck/wiki/SC2046) |                  | Quote this to prevent word splitting                                                                                                                |
| [SC2086](https://github.com/koalaman/shellcheck/wiki/SC2086) |                  | Double quote to prevent globbing and word splitting.                                                                                                |
| [SC2140](https://github.com/koalaman/shellcheck/wiki/SC2140) |                  | Word is in the form `"A"B"C"` (B indicated). Did you mean `"ABC"` or `"A\"B\"C"`?                                                                   |
| [SC2154](https://github.com/koalaman/shellcheck/wiki/SC2154) |                  | var is referenced but not assigned.                                                                                                                 |
| [SC2155](https://github.com/koalaman/shellcheck/wiki/SC2155) |                  | Declare and assign separately to avoid masking return values.                                                                                       |
| [SC2164](https://github.com/koalaman/shellcheck/wiki/SC2164) |                  | Use <code>cd ... &#124;&#124; exit</code> in case `cd` fails.                                                                                       |
