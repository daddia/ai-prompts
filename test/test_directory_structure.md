# Test Directory Structure and Guidelines

When generating or reviewing tests, strictly adhere to the following rules:

All automated tests MUST reside under a single top-level `tests/` folder.

```
tests/
├── unit/                           # Isolated, fast‐running tests
├── integration/                    # Tests exercising multiple modules/components
├── e2e/                            # End-to-end user-flow tests
├── smoke/                          # Quick sanity checks against critical paths
├── fixtures/                       # Static test data (JSON, HTML, snapshots)
├── mocks/                          # HTTP or module mocks and fakes
├── helpers/                        # Shared utilities, custom matchers, factories
└── setup/                          # Global setup/teardown, test-runner configuration
```

## **Test Rules**

1. **Centralised Structure**

   * All tests MUST live under a single top-level `tests/` directory.
   * No tests should be co-located with source files.
   * Maintain a clearn mirror of `src/` layout inside `tests/unit/` and `tests/integration/`.

2. **Test Type Separation**

   * `unit/` – Fast, single-module, isolated, single-module tests (<100 ms).
   * `integration/` – Multi-module or external-dependency tests (e.g. DB, APIs).
   * `e2e/` – Full-stack user-flow or browser/API end-to-end tests.
   * `smoke/` – Quick sanity checks for critical paths (app start, health endpoints).

3. **Naming & Conventions**

   * Test files MUST end with `.test.(js|ts)`.
   * Directory names are lowercase and singular (e.g. `unit/`, not `units/`).

4. **Fixtures & Mocks**

   * `fixtures/`: Store static JSON, HTML or snapshot files.
   * `mocks/`: Custom stubs for HTTP endpoints or module overrides. Organise by service name.

5. **Helpers & Shared Utilities**

   * `helpers/`: Factories, custom matchers, and data-builder functions to reduce duplication.
   * Keep helper functions pure and side-effect free.

6. **Global Setup**

   * `setup/`: Centralise test-runner config and hooks.
   * Centralise teardown.
   * Avoid per-test boilerplate; use top-level hooks instead.

7. **Performance & Determinism**

   * Keep unit tests sub-100 ms; move any I/O or slow tests to `integration/` or `e2e/`.
   * Reset global state between tests; rely on fixtures/mocks to eliminate flakiness.

8. **Coverage & CI**

   * Enforce ≥ 80 % overall coverage and ≥ 90 % on critical modules via your test-runner config.
   * Run `unit/` and `smoke/` on every PR; schedule `integration/` and `e2e/` in nightly or merge-to-main pipelines.

9. **Documentation**

   * Include a brief `tests/README.md` summarising how to run and extend the test suite.

---
