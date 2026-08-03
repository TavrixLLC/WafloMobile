# ADR 0005: Mutation ambiguity recovery

Status: Accepted

Unknown transport outcome is neither success nor failure. The original command ID and safe fields are journaled, and the command-status endpoint determines `PROCESSING`, `COMPLETED`, `FAILED`, or `NOT FOUND`. A new command ID is never created for recovery.
