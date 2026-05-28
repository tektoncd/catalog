---
paths:
  - "test/**"
  - "hack/**"
  - "task/**/tests/**"
---

# Test Infrastructure Rules

- Hook scripts (`pre-apply-task-hook.sh`, `pre-apply-taskrun-hook.sh`) are
  sourced via `source`, so they can export environment variables
- Use helper functions: `add_sidecar_registry`, `add_sidecar_secure_registry`,
  `add_task`
- For external API mocking, place fixture rules in `tests/fixtures/` and
  override the API URL parameter to `http://localhost:8080`
- Test YAMLs in `tests/` are applied in a random namespace — do not hardcode
  namespace names
- CI only tests tasks modified in the PR unless `TEST_RUN_ALL_TESTS` is set
