# Repository launch-leftover audit

The active Mobile source was searched for TODO, FIXME, HACK, placeholder, Lorem, example.com, localhost, 127.0.0.1, 10.0.2.2, debugPrint, and print calls.

## Classified current-source hits

| Hit | Classification | Action |
|---|---|---|
| `android/app/src/development/res/xml/network_security_config.xml` localhost / `10.0.2.2` | APPROVED DEVELOPMENT ONLY | Kept. This resource exists only in the development source set. |
| `config/development.json` `10.0.2.2` | APPROVED DEVELOPMENT ONLY | Kept for Android-emulator backend development. |
| `lib/app/environment.dart` localhost/loopback checks | RELEASE SECURITY GUARD | Kept. These checks reject unsafe release origins; they do not provide a fallback. |
| Scanner `placeholderBuilder` identifiers | FRAMEWORK API NAME | Kept. They render black camera placeholders and contain no placeholder product copy. |
| iOS storyboard `placeholderIdentifier` nodes | XCODE SCHEMA | Kept. Standard Interface Builder first-responder metadata. |

No TODO, FIXME, HACK, Lorem, example.com, debugPrint, or print call was found in current non-test product source by this scan.

## Environment conclusion

- Staging fixed origin: `https://api-staging.waflo.app`
- Production fixed origin: `https://api.waflo.app`
- No release host selector or release loopback fallback exists.
- The retired dotted staging hostname appears only in an intentional rejection test and historical evidence.
