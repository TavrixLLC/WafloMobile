# Archive inspection

The portable archive is created from Git-tracked source with `/artifacts`
export-ignored, so it cannot contain itself or local raw evidence. The scanner
lists entries before extraction, rejects traversal/absolute names and all
specified Flutter/Android/iOS generated paths, extracts to a temporary directory,
and scans text for home-directory and SDK assignments.

Archive result:

- Source commit: `c58f8ab`
- Filename: `waflo-mobile-m1-round-1-portable-source.zip`
- Size: 1,365,229 bytes
- Entries: 393
- SHA-256: `cabf9c758519fb411bd775d0bbbb869c8008b6a30ce6092b2e75f472730a6ca1`
- Extraction and archive scan: PASS

Final raw output is `raw-test-output/archive-scan-final.log`. The extracted source can
regenerate Flutter/Dart configuration and generated API sources from committed
inputs.
