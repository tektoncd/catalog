---
paths:
  - "task/**/*.yaml"
  - "stepaction/**/*.yaml"
  - "pipeline/**/*.yaml"
---

# Task YAML Rules

- Never use `$(params.*)` inside `script` blocks — pass via `env` or `args`
- Reference images by digest (`@sha256:...`), not by tag
- Run steps as non-root unless explicitly required
- Include `app.kubernetes.io/version` label matching the directory version
- Include `tekton.dev/pipelines.minVersion` annotation
- Include `spec.description` with one-line summary + detailed paragraph
- Provide default values for parameters wherever reasonable
- Use `set -e` (or `set -euo pipefail`) in bash scripts
