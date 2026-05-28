---
name: commit-message
description: This skill should be used when the user asks to "create a commit", "generate commit message", "commit changes", "make a commit", mentions "conventional commits", or discusses commit message formatting. Provides guided workflow for creating properly formatted commit messages with line length validation and required trailers.
version: 0.3.0
---

# Commit Messages for tektoncd/catalog

This skill covers only catalog-specific commit conventions. Standard
conventional commits format is assumed as prior knowledge.

## Scope Rules (Catalog-Specific)

Derive scope from staged file paths:

| File pattern | Scope | Example |
|---|---|---|
| `task/<name>/*` | task name | `feat(git-clone): add depth param` |
| `stepaction/<name>/*` | stepaction name | `feat(git-clone): add stepaction` |
| `pipeline/<name>/*` | pipeline name | `fix(buildpacks): fix workspace` |
| `test/*` | `test` or resource name | `test(git-clone): add SSH e2e` |
| `hack/*` | `hack` or script name | `fix(setup-kind): update K8s ver` |
| `.github/workflows/*` | `ci` | `ci(github): add matrix version` |
| Root files | filename | `docs(CONTRIBUTING): update` |

If files span multiple resources, ask the user.

## Required Trailer

Every commit **must** include this trailer (tektoncd upstream requirement):

```text
Signed-off-by: Full Name <email@example.com>
```

**Signed-off-by** certifies the Developer Certificate of Origin (DCO).
Detect from `$GIT_AUTHOR_NAME`/`$GIT_AUTHOR_EMAIL` first, then
`git config user.name`/`git config user.email`. Ask user if neither is set.

## Optional Trailer (AI-Assisted Work)

When a commit is authored with AI assistance, add:

```text
Assisted-by: Claude Sonnet 4 (via Claude Code)
```

Use the actual model name. This is not a Tekton requirement — it is
optional attribution for AI-assisted contributions.

## Version Copy Convention

When a task is copied from version X to Y, commit the copy separately:

```text
chore(git-clone): copy task from 0.9 to 0.10

Signed-off-by: ...
```

Then make changes in a follow-up commit with `feat`/`fix`/etc. type.
This is critical for clean diffs during review.

## Gitlint Enforcement

The project uses `.gitlint` with these rules:
- Subject hard limit: 72 chars (target 50)
- Body wrap: 72 chars per line
- No `WIP`/`TODO` in subject
- `body-is-missing` is ignored (body optional)

## Workflow

1. `git diff --cached --name-only` to determine scope
2. Generate message with proper type and scope
3. Add required Signed-off-by; add Assisted-by when AI-assisted
4. **Display to user and wait for confirmation before committing**
5. Use heredoc format: `git commit -m "$(cat <<'EOF' ... EOF)"`
