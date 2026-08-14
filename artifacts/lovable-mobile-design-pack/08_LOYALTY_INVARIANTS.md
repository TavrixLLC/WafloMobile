# Loyalty invariants

The main stamp grid has exactly two states: FILLED and EMPTY.

- 0/8: eight EMPTY.
- 5/8: exactly five FILLED and three EMPTY.
- 8/8: eight FILLED.

Reward readiness and milestones are outside the grid. Never place a star, gift, check, badge, number, completed-cycle marker, or third color state in a stamp slot.

After final redemption, the authoritative view is progress 0, reward not ready, completed cycles incremented, and every slot EMPTY. Mobile never invents or optimistically commits loyalty state.
