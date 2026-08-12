# Brand asset provenance

The Brand System ZIP remains read-only and unmodified.

| Mobile destination | Official source | Transformation | Dimensions / purpose |
|---|---|---|---|
| `assets/brand/app/waflo-app-icon-1024.png` | `App/waflo-app-icon-1024.png` | Exact copy | 1024×1024 source authority |
| `assets/brand/app/waflo-apple-app-store-icon-1024.png` | `App/waflo-apple-app-store-icon-1024.png` | Exact copy | 1024×1024 iOS authority |
| `assets/brand/app/waflo-android-adaptive-foreground-432.png` | `App/waflo-android-adaptive-foreground-432.png` | Exact copy | 432×432 adaptive foreground |
| `assets/brand/app/waflo-android-monochrome-432.png` | `App/waflo-android-monochrome-432.png` | Exact copy | 432×432 Android themed icon |
| `assets/brand/logo/waflo-mark-primary-512.png` | `Logo/PNG/waflo-mark-primary-512.png` | Exact copy | Light-surface compact mark |
| `assets/brand/logo/waflo-mark-white-1024.png` | `Logo/PNG/waflo-mark-white-1024.png` | Exact copy | Dark-surface compact mark |
| `assets/brand/logo/waflo-logo-primary-horizontal-1600.png` | `Logo/PNG/waflo-logo-primary-horizontal-1600.png` | Exact copy | 1600×440 light lockup |
| `assets/brand/logo/waflo-logo-white-horizontal-1600.png` | `Logo/PNG/waflo-logo-white-horizontal-1600.png` | Exact copy | 1600×440 dark lockup |
| `android/.../drawable-nodpi/ic_launcher_foreground.png` | official adaptive foreground | Exact native copy | 432×432 adaptive layer |
| `android/.../drawable-nodpi/ic_launcher_monochrome.png` | official monochrome icon | Exact native copy | 432×432 themed layer |
| `android/.../mipmap-*/ic_launcher.png` | official app icon 1024 | Aspect-preserving downscale | 48/72/96/144/192 px legacy launchers |
| `android/.../drawable-nodpi/waflo_splash_mark.png` | official primary mark | Aspect-preserving downscale | 192×192 native splash |
| `ios/.../AppIcon.appiconset/*.png` | official Apple icon 1024 | Aspect-preserving resize; RGB/opaque output | Apple-required 20–1024 px matrix |
| `ios/.../LaunchImage.imageset/*.png` | official primary mark | Aspect-preserving resize | 160/320/480 px launch mark |

Fonts are covered in `TYPOGRAPHY.md`. No social, print, board, concept, or unrelated export was copied into the application bundle.
