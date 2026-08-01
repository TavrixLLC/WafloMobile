# Archive inspection

The portable archive is created from Git-tracked source with `/artifacts`
export-ignored, so it cannot contain itself or local raw evidence. The scanner
lists entries before extraction, rejects traversal/absolute names and all
specified Flutter/Android/iOS generated paths, extracts to a temporary directory,
and scans text for home-directory and SDK assignments.

Archive result:

- Source commit: `b0e862f`
- Filename: `waflo-mobile-m1-round-1-portable-source.zip`
- Size: 853,946 bytes
- Entries: 372
- SHA-256: `3eff33f12a5e55f059273ffcd973c6f8c462977bfd984c647e2f1fb7de0b2ee0`
- Extraction and archive scan: PASS

Raw output is `raw-test-output/archive-scan.log`. The extracted source can
regenerate Flutter/Dart configuration and generated API sources from committed
inputs.
