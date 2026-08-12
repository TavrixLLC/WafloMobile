# Arabic brand pass

Arabic remains a first-class locale with true RTL layout and Noto Sans Arabic rendering.

Reviewed areas:

- Home and scan-first hierarchy
- Scanner frame, close/flash controls, instructions, and status
- Customer identity and 0/8, 5/8, 8/8 loyalty states
- Stamp/purchase inputs and confirmations
- Reward-ready and redeem flows
- Manager approval required/pending/rejected states
- Success and blocked/error states
- App Lock, Device & Security, and Settings
- 200% text behavior and mixed Latin/currency content

The Arabic Home review fixture uses natural merchant/location context (`قهوة النهر`, `الفرع الرئيسي`) instead of leaving the main identity hierarchy in English. Directional layout uses `EdgeInsetsDirectional` and direction-aware alignment; the main loyalty grid remains a neutral two-state visual that does not depend on language.

No runtime font loading or LTR-only layout branch was introduced.
