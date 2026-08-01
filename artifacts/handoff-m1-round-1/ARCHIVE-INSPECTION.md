# Archive inspection

The portable archive is created from Git-tracked source with `/artifacts`
export-ignored, so it cannot contain itself or local raw evidence. The scanner
lists entries before extraction, rejects traversal/absolute names and all
specified Flutter/Android/iOS generated paths, extracts to a temporary directory,
and scans text for home-directory and SDK assignments.

Archive result:

- Source commit: `9cf0c89`
- Filename: `waflo-mobile-m1-round-1-portable-source.zip`
- Size: 1,365,175 bytes
- Entries: 393
- SHA-256: `d9d0906df20d58e835da320cb20373014c4cd3fe2a8208617f2ca4f3d1bde289`
- Extraction and archive scan: PASS

Final raw output is `raw-test-output/archive-scan-final.log`. The extracted source can
regenerate Flutter/Dart configuration and generated API sources from committed
inputs.
