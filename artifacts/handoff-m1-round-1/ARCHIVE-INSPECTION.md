# Archive inspection

The portable archive is created from Git-tracked source with `/artifacts`
export-ignored, so it cannot contain itself or local raw evidence. The scanner
lists entries before extraction, rejects traversal/absolute names and all
specified Flutter/Android/iOS generated paths, extracts to a temporary directory,
and scans text for home-directory and SDK assignments.

Archive result:

- Source commit: `8dc7410`
- Filename: `waflo-mobile-m1-round-1-portable-source.zip`
- Size: 1,365,437 bytes
- Entries: 393
- SHA-256: `76f2eef86d0210eb412cd33534a790618f7a37257f6e3d6acbcb38d0ee0f6e8d`
- Extraction and archive scan: PASS

Final raw output is `raw-test-output/archive-scan-final.log`. The extracted source can
regenerate Flutter/Dart configuration and generated API sources from committed
inputs.
