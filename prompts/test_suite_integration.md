# Prompt: Generate Comprehensive Test Suite

<!-- Recommend using o3-mini (or similar fast advanced reasoning model) -->

<!-- Update and copy prompt from here -->

Conduct a comprehensive review of the codebase. 

Review the shared context and configurations to identify any existing tests, tests framework and libraries in use.

**Your task** is to generate a comprehensive suite of integration tests.

---

**Language:** Typescript v5.8.3
**Test Frameworks:** vitest v3.1.4
**Test Libraries:** @testing-library/react MSW
**Test Coverage:** istanbul

---

## **Test Directory Structure**

* All tests MUST BE organised in centralised `tests/` directory structure
* Mirror `src/` under `unit/` and `integration/`
* Separate test types (unit, integration, e2e, smoke) to control execution scope and speed
* Keep static data in `fixtures/`
* Keep mocks in `mocks/`
* Centralise setup in `setup/` so your runner config stays clean and consistent across test suites.

Below is our centralised `tests/` directory structure.

```
tests/
├── unit/                           # Isolated, fast-running tests
│
├── integration/                    # Tests exercising multiple modules
│   ├── pages/                      # Page-level component tests
│   │   └── ProductList.test.tsx
│   ├── stores/                     # State-management (e.g. Zustand, Redux) tests
│   │   └── cartStore.test.ts
│   └── api/                        # HTTP handler / BFF route tests
│       └── productsRoute.test.ts
│
├── e2e/                            # End-to-end browser flow tests
├── smoke/                          # Lightweight sanity checks
│
├── fixtures/                       # Static test data (JSON, HTML, snapshots)
│   ├── users.json
│   └── ...
│
├── mocks/                          # Custom HTTP or module mocks
│   ├── server.ts                   # MSW server setup
│   └── fetchMock.ts
│
├── helpers/                        # Reusable test utilities & custom matchers
│   └── renderWithProviders.tsx
│
└── setup/                          # Global setup & teardown code
    ├── vitest.setup.ts             # Vitest config, global mocks, a11y rules
    └── teardown.ts                 # Cleanup after all tests complete
```

---

## **RULES FOR INTEGRATION TESTS**

All integration tests MUST follow these guidelines:

* **Coverage:** Integration tests **SHALL** achieve overall coverage of at least 50 %.
* **Real Modules:** Integration tests **SHALL** exercise multiple real modules together and **MUST NOT** mock internal code under test.
* **Selective Mocking:** Integration tests **MAY** mock external third-party services (e.g. payment gateways, external APIs) but **SHALL NOT** mock the modules under test.
* **Dedicated Environment:** Integration tests **SHALL** run against a dedicated test database or service instance that **MUST** be reset between runs.
* **State Isolation:** Integration tests **SHALL** reset or reseed data before each test to avoid cross-test contamination.
* **Meaningful Scenarios:** Integration tests **SHOULD** cover key user flows and feature interactions rather than single-unit behaviours.
* **Clear Naming:** Integration tests **SHOULD** use descriptive names indicating the components or pages under test and the expected outcome.
* **Single Responsibility:** Integration tests **SHOULD** verify one high-level scenario per test.
* **Setup & Teardown:** Setup and teardown hooks **SHOULD** be used to initialise services and clean up state.
* **Assert Real Outcomes:** Integration tests **SHALL** verify real side effects (database writes, HTTP status codes, rendered DOM).
* **Error Handling:** Integration tests **SHOULD** include tests for failure modes (e.g. network errors, validation failures).
* **Performance Awareness:** Integration tests **SHOULD** be reasonably fast and **SHOULD NOT** process large data volumes unless specifically testing performance.
* **Arrange-Act-Assert:** Integration tests **MUST** follow the Arrange-Act-Assert pattern.
* **Automate in CI:** Integration tests **SHALL** be integrated into the CI pipeline with appropriate test-environment provisioning.
* **Document Complex Scenarios:** Integration tests **SHOULD** include comments when scenarios involve non-obvious setup or multiple external dependencies.

---