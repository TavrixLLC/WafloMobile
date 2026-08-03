# Exact two-state stamp grid

`StampProgress.slots` has exactly two enum values: `filled` and `empty`. Indices below progress are filled; all other indices are empty. Goal-ready is all filled and final redemption is all empty. Rewards never replace a stamp and the renderer has no third, milestone, final-slot, check, star, gift, trophy, number, or badge state.

Artwork is loaded by HTTPS URL and SHA-256 digest. The bounded digest cache rejects wrong type, size, or digest and evicts least-recently-used entries. A load failure uses the same two-state contract colors: solid circle for filled and outlined circle for empty.

The Wrap remains LTR inside RTL so earned chronology is not reversed. One semantic summary announces `progress of goal`; individual slots are excluded from semantics.
