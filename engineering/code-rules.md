# **Code Generation Rules, Standards, and Guidelines**

This document outlines the rules and guidelines to follow when generating code.

## **RULES FOR CODE FORMATTING AND LINTING:**

- **Adhere to Coding Standards**: All code must comply with an established style guide (e.g., PEP 8 for Python, PSR-12 for PHP, Airbnb for JavaScript).
- **Automate Code Formatting**: All code must be formatted as expected by automated tools (e.g., Prettier, Black, clang-format).
- **Enforce Linting**: All code must pass linting checks using standardised tools (e.g., ESLint, pylint, RuboCop) to catch errors and style violations. Ensure lines are not longer than 80 characters.
- **Integrate into CI/CD**: All repositories include automated formatting and linting checks in the CI pipeline to ensure consistency before merging.
- **Document Formatting Rules**: All projects must include clear documentation of the formatting and linting rules for easy reference by every team member.

---

## **RULES FOR CODE BLOCK**

All code files must start with a header block at the top of the source code file, and include metadata about the file, helping developers understand its purpose, authorship, and other relevant details.

### Key Elements:
- **Filename**: Helps track files easily.
- **Description**: Provides a brief explanation of the file’s purpose.
- **Author**: Identifies the creator and contact.
- **Date**: Indicates when the file was created (or last updated).
- **Version**: Specifies the file's version.
- **License**: Declares the file's legal usage terms.
- **Copyright**: Protects intellectual property.
- **Repository**: Links to the source control location.

--- 

## **RULES FOR LOGGING:**

All code must have appropriate logging implemented.

- **Define Log Levels**: All logs MUST be differentiated by severity (DEBUG, INFO, WARN, ERROR, FATAL) to facilitate filtering and analysis.  
- **Do not Log Sensitive Data**: Under no circumstances SHOULD confidential or personal information be logged in order to uphold security and compliance standards.  
- **Use Structured Loggin**: All log messages MUST be formatted (e.g., in JSON) with key-value pairs to ensure they are easily searchable and analyzable.  
- **Log Meaningful Events Only**: Log entries MUST capture events that contribute to troubleshooting or performance monitoring, avoiding any unnecessary or redundant logging.  
- **Include Contextual Information**: Every log entry MUST include relevant context such as timestamps, request IDs, user IDs, and component names to streamline debugging efforts.  
- **Implement Asyncronous Logging**: Employ asynchronous logging mechanisms to prevent any adverse impact on the main application threads.  
- **Configure Logging Externally**: All logging configurations (log level, format, output destination) MUST be externalized to enable modifications without altering the code base.  
- **Test Critical Logging Paths**: Ensure that tests validate critical error paths and essential event logging to confirm the robustness of the logging strategy.

---

## **RULES FOR TRACING:**

All code must have appropriate tracing implemented.

- **Instrument Key Operations**: Instrument only business-critical operations to ensure that traces remain clear and meaningful.
- **Correlate Traces with Logs and Metrics**: Use unique trace identifiers across logs and metrics to provide complete end-to-end visibility for every request.
- **Use Standardized Protocols**: Adopt industry standards, such as OpenTelemetry, to generate consistent and interoperable trace data.
- **Propagate Context Across Services**: Ensure that trace context is passed reliably across all distributed systems to maintain trace continuity.
- **Implement Sampling Strategies**: Apply trace sampling to balance system overhead with the need for detailed trace information during anomalies.
- **Include Metadata**: Enrich every trace with pertinent metadata, including user IDs and service names, to enhance context and analysis.
- **Leverage Asynchronous Trace Collection**: Collect trace data asynchronously to minimize any potential performance impact on the application.
- **Monitor and Alert on Trace Anomalies**: Establish monitoring systems to promptly alert on unusual trace patterns that indicate potential issues.
- **Document Tracing Architecture**: Maintain comprehensive documentation of the tracing strategy, including instrumentation points, sampling algorithms, and context propagation guidelines.
- **Test Trace Integrity**: Rigorously validate that trace context is preserved correctly across service boundaries through automated integration tests.
- **Align with Business Transactions**: Structure traces to follow business transactions, ensuring that issues can be diagnosed from the user’s perspective.

---

## **RULES FOR DOCUMENTATION:**

All code must be documented in a clear, consistently, and concisely manner.

- **Maintain Consistency**: Use the Google style format, to maintain consistent documentation across the codebase.
- **Write Clear and Concise Docstrings**: Use meaningful docstrings for modules, classes, and functions that describe purpose, inputs, outputs, and exceptions.
- **Update Documentation Regularly**: Keep inline comments and docstrings in sync with code changes to avoid outdated information.
- **Comment the "Why," Not Just the "What"**: Focus on explaining the reasoning behind complex logic or design decisions rather than stating the obvious.
- **Use Inline Comments Sparingly**: Reserve inline comments for particularly non-obvious lines of code while ensuring that well-named variables and functions keep the code self-explanatory.
- **Document Edge Cases and Limitations**: Clearly note any known issues, assumptions, or limitations in the documentation.
- **Keep External Documentation Linked**: Ensure that high-level architecture or design documents are referenced in the code where appropriate.
- **Include Examples When Helpful**: Provide code examples within documentation to illustrate typical usage scenarios or complex interactions.
- **Structure for Automated Documentation Tools**: Ensure the documentation is structured for documentation generators (e.g., Sphinx).

---
