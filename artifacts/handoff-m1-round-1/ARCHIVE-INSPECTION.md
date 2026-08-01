# Archive inspection

The portable archive is created from Git-tracked source with `/artifacts`
export-ignored, so it cannot contain itself or local raw evidence. The scanner
lists entries before extraction, rejects traversal/absolute names and all
specified Flutter/Android/iOS generated paths, extracts to a temporary directory,
and scans text for home-directory and SDK assignments.

Final archive filename, SHA-256, entry count, and passing raw scan are added after
the source commit is created.
