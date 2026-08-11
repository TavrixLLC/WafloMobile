# Retail-path performance

The fast path avoids dashboard aggregation and decorative transition delays.
Home launches the scanner with one explicit tap. Scanner candidates are
single-flight and UI rendering is paused during resolve. Mutation submission is
single-flight, and success exposes Scan next customer without unwinding a stack
of modal routes.

Controllers own networking and state; widgets render immutable projections.
The scanner and privacy overlay react directly to lifecycle changes. Haptics
are fire-and-forget and failure-safe, so platform feedback cannot delay the
transaction.

No performance number is claimed without a physical profile build. Staging E2E
should capture Home→scanner, scan→customer, submit→success, and success→scanner
latency on representative low/mid-range Android hardware and an iPhone.
