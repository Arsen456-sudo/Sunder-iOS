# Stage 5 static review

Date: 2026-10-28. Preparation base: fbf664947.

Two final consecutive static passes found no additional issues after fixes.

- Forty-four remaining original bundled media files are absent. The remaining media
  registry contains 44 previously generated neutral PNGs and three original PCM WAVs.
- Asset-catalog references resolve. WAV headers, durations, mono 16-bit 22,050-Hz format
  and bounded nonzero amplitude were checked. No phone/audio-device playback is claimed.
- Call playback source is identical except resource extensions/provenance comments.
  Preset IDs, palette/scale tables, caching and custom-image logic remain identical.
- Status source differs only in native Image constructors. Badge verification/expiry
  branches and UIKit/SwiftUI counterparts retain their checks and size/opacity logic.
- Nine embedded image substitutions in six source files are valid neutral PNG data.
  Removing image literals/comments from comparisons leaves surrounding code unchanged,
  including the two shared Haskell constants. No cryptographic/command logic was changed.
- Investment types, entry points, sheet, country gate and fundraising URL actions are gone.
  Factual badge/operator attribution and legal conditions remain.
- Visible branding changes preserve localized copyright strings. Xcode project changes
  are exactly four extension display-name values; signing/entitlement settings are untouched.
- All 145 original protected notice/policy paths remain unchanged. No Keychain/App Group,
  entitlement or Shared model changes were introduced.
- Offline-notice regeneration/input hash verification passes. Source-navigation ref and
  HTTPS repository configuration are documented; source links target the development ref.
- Python syntax, authored diffs, privacy review classification and disabled remote-workflow
  state were checked. Current/reachable-history scans document their exact limits.
- The exporter uses committed inputs, a media-hash allowlist, fresh-path checks and a
  credential-marker gate. Actual snapshot contents must also be checked after export.

No native compilation, automated tests or device checks were run. This is source
preparation, not a working IPA claim. Native binary/source provenance, full third-party
binary notices, own signing/Keychain/App Groups/APNs and device behavior remain binary
release gates. Private history and repository visibility are not rewritten by this work.
