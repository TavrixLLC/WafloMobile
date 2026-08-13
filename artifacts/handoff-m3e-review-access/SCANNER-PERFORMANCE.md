# Scanner performance

The beam uses one transform animation inside a `RepaintBoundary`; camera preview construction and recognition do not depend on animation ticks. No blur, shader loop, particle system, or animation-driven network work was added. Animation is active only while the adapter reports scanning.

No connected camera device was available for frame-time profiling. Hardware profiling remains required for startup latency, camera frame throughput, torch behavior, and background/resume under thermal load.
