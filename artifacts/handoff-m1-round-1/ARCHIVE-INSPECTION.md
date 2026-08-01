# Archive inspection

The portable archive is created from Git-tracked source with `/artifacts`
export-ignored, so it cannot contain itself or local raw evidence. The scanner
lists entries before extraction, rejects traversal/absolute names and all
specified Flutter/Android/iOS generated paths, extracts to a temporary directory,
and scans text for home-directory and SDK assignments.

Archive result:

- Source commit: `65bf590`
- Filename: `waflo-mobile-m1-round-1-portable-source.zip`
- Size: 853,892 bytes
- Entries: 372
- SHA-256: `c9557ffabc970821c762df1f967c4590cada450284d80171eab4c03d9e076ec6`
- Extraction and archive scan: PASS

Raw output is `raw-test-output/archive-scan.log`. The extracted source can
regenerate Flutter/Dart configuration and generated API sources from committed
inputs.
