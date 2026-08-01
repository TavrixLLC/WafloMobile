# Accessibility

M1 uses Material semantics, minimum 48×48 targets, high-contrast color plus icons/text, directional layouts, scrollable large-text screens, tooltips, live regions for loading/errors, and an obscured manual QR fallback. The scanner overlay is a normal layout and does not trap focus; its semantic label contains instructions, never QR content.

Automated widget evidence covers RTL, 200% text scale, semantics, safe obscured input, and blocked-state actions. Golden evidence includes a semantics-debugger view. Physical TalkBack and VoiceOver review is still required on release-candidate devices because screen-reader behavior cannot be certified from this Windows host.
