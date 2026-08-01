# Archive inspection

The portable archive is created from Git-tracked source with `/artifacts`
export-ignored, so it cannot contain itself or local raw evidence. The scanner
lists entries before extraction, rejects traversal/absolute names and all
specified Flutter/Android/iOS generated paths, extracts to a temporary directory,
and scans text for home-directory and SDK assignments.

Archive result:

- Source commit: `90f5784`
- Filename: `waflo-mobile-m1-round-1-portable-source.zip`
- Size: 853,759 bytes
- Entries: 372
- SHA-256: `2df60763d8c4dbc410e4f2ce85f58dfb18a2ffd2ef487e27161b92e4d750d4e6`
- Extraction and archive scan: PASS

Raw output is `raw-test-output/archive-scan.log`. The extracted source can
regenerate Flutter/Dart configuration and generated API sources from committed
inputs.
