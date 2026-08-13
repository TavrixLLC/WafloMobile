# Scanner design

The camera remains the hero. The adaptive square target uses four Flow Coral brackets, a faint boundary, dimmed exterior, concise location context, accessible close/torch controls, and a restrained 2.3-second beam. The beam is isolated in a repaint boundary and does not rebuild the camera subtree.

Optical detection and server resolution are deliberately distinct: **QR detected** immediately locks the scanner; **Loading customer…** represents Backend authority. Invalid codes remain in the scanner and re-arm after a controlled debounce. Network failure says the QR was detected but the customer could not be loaded.

The second visual pass removed duplicate invalid-state copy and replaced the truncating large-text header with an adaptive **Scan customer** label. The final 200% screenshot shows the entire action label without reducing system text scale.
