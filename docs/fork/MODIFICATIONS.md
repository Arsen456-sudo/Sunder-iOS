# Fork modification record

Upstream: https://github.com/simplex-chat/simplex-chat
Baseline: `79d91e716dbb8aae80327f580aac9a6b42426466` (`stable`, upstream commit date 2026-10-21).
Private destination: https://github.com/Arsen456-sudo/SimpleX-Private

## 2026-10-28 — preparation stage 1

- Record Sunder as the maintainer-selected product name for the preparation documents.
- Add an independent-fork README notice, attribution, contribution/security guidance,
  publication checklist and draft privacy/release documentation in English.
- Inventory tracked media/graphics/fonts, original license files and dependency source pins.
- Retrieve pinned dependency license evidence, including the three entries with missing
  metadata in the existing Haskell report. Original generated reports are not rewritten.
- Add local signing/credential/diagnostic ignore rules without untracking or deleting files.
- Route repository ownership and ordinary issue templates to this fork, remove the
  inherited repository funding destination, and guard upstream-only workflows.

Application source, runtime behavior, original operator conditions and existing copyright/
license files are unchanged. No graphics have been removed, recolored or relicensed.
The application name, signing identifiers, protocol and database are unchanged.
No tests or builds are run in this preparation stage. The repository remains private.

Preparation does not resolve the graphic permission question. Track subsequent work in
`PUBLICATION_CHECKLIST.md`; record exact changed source versions with future binaries.

## 2026-10-28 — preparation stage 2

- Remove 88 optional illustration files (5,230,933 bytes) from the current tree;
  exact paths and original hashes are in REMOVED_ILLUSTRATIONS.json.
- Select 17 existing iOS no-illustration branches; retain their system symbols,
  gradients, layout and action handlers. Disable illustration imports on both platforms.
- Prepare Sunder iOS display-name overrides and Android/Desktop app-name resources;
  replace the welcome logo with text. App icons and other legacy graphics remain pending.
- Adapt iOS Help & support using existing rows: independent source, license, notices,
  issue tracker and original operator conditions. Remove investment promotion from settings.
- Replace the root README with an independent development overview. The upstream README
  remains available in Git history and upstream; this is not deletion of license notices.
- Update product/spec documentation for presentation-only changes.

No protocol, encryption, database, bundle/signing identifiers or operator-acceptance logic
was changed. New source/issue links currently require access to the private repository;
they are development destinations, not public release source availability. An immutable
source manifest and accessible notices must be provided with any distributed binary.
No build or tests were run. No history rewrite, public visibility change or permission
request was performed. Remaining graphic assets and dependency evidence are not cleared.

## 2026-10-28 — preparation stage 3: temporary logo removal

- Remove bundled SimpleX/Flux logo images, the spoiler watermark, QR branding overlays
  (including exported QR images) and the custom CallKit template. Operator names, legal
  attribution, URLs, selection handlers and conditions remain intact.
- Use existing SF network symbols / MR network symbols and provider text in operator UI.
  Kotlin welcome and lock-screen headers use the existing localized app_name resource.
- Preserve required launcher/preview dimensions with opaque flat-color technical placeholders.
  Native desktop packages use platform default icons. Tray status/unread markers remain
  visible as basic rings; Android notification marks become unbranded vector rings.
- Keep empty Kotlin metadata resource slots where generated names are still referenced.
  Internal type/resource filenames are not product branding and are not broadly renamed.
- Exact deleted/substituted resource paths and hashes are in LOGO_REMOVAL.json. The asset
  CSV retains original hashes as baseline evidence; replacement hashes are in that manifest.

Concealed spoiler text still uses transparent foreground/opaque background until revealed.
QR payloads, error correction, sharing callbacks and server acceptance logic are unchanged.
No network/storage/signing/notification-delivery logic is changed. No builds or tests run.
This removes bundled logo artwork, not all inherited visual assets or repository artwork.
Website/blog/media/store screenshots and Git history remain a separate review scope.
The repository remains private; deletion does not establish blanket publication clearance.

## 2026-10-28 — preparation stage 4: iOS evidence and offline notices

- Inspect the seven pinned Swift manifests and trees, including vendor/resource scopes.
- Recover 18 empty historical Haskell report notices into separate versioned evidence files;
  preserve the original notice/report files unchanged and do not assume binary matching.
- Download the pinned 34,279,775-byte WebRTC archive outside the repository for read-only
  inspection; verify its manifest SHA-256 and preserve the archive's LICENSE notice.
  No binary is executed. Full WebRTC third-party closure remains unverified.
- Inventory 88 current tracked iOS media files: 44 neutral icon placeholders, 18 wallpapers,
  18 other graphics, three badge images, two symbols and three sounds. Original resources
  remain pending permission/provenance review. No tracked custom iOS fonts were found.
- Generate and bundle selectable offline attribution/license text with a recorded input
  manifest. Help & support uses an existing NavigationLink and lazy standard SwiftUI text
  destination instead of private online legal links. Source/issues links remain private.
- Update iOS build/resource instructions to match the disabled illustration import.

Original LICENSE/policy/dependency notices remain unchanged. No core/network/database,
server acceptance, signing, bundle IDs or extension logic changes. No native build/tests,
device validation, source publication or Git history rewrite was performed. This is not
a verified final IPA SBOM or a declaration that remaining assets/binaries can be published.
See docs/fork/ios/README.md and REVIEW_SUMMARY.json for evidence and unresolved gates.

## 2026-10-28 — preparation stage 5: actionable iOS/public-source cleanup

- Remove all 44 remaining original bundled iOS media files plus obsolete asset metadata.
  Keep 44 previously generated neutral packaging PNGs; add three original PCM WAV cues.
- Replace wallpaper illustrations with a cached UIKit dot tile, badge artwork/statuses
  with native symbols; preserve palette IDs, custom images, statuses and badge verification.
- Replace nine embedded sample/default-avatar image literals in six source files, including
  two Haskell ImageData constants. No core logic, identity or serialization changes.
- Remove upstream investment cards/sheets/country gate and promotion URLs. Preserve factual
  badge attribution, operator conditions and actual upstream component-version references.
- Configure fork source/support via a single HTTPS Info.plist key; no public URL is invented.
- Scan 71,099 reachable text blobs (6,494,114,092 bytes); review 16 PEM-marker findings as
  upstream public test fixtures/format strings, without storing secret values. Scoped scan
  limitations and separate current-tree review remain explicit; no absolute security claim.
- Review private GitHub metadata: four workflows disabled, zero runs and zero artifacts.
- Add non-destructive iOS-focused source export: no private history, ignored files or old
  site/blog/Android/Desktop/SDK/test-fixture media; preserve runtime source and legal records.
  The private original repository/history is retained and its visibility is not changed.

No builds/tests/device validation were run. Native provenance/third-party closure and own
signing/Keychain/App Groups/APNs must be resolved before distributing a working IPA.

Stage 5 also updates 44 localized InfoPlist caption files and four extension display-name
build settings. Copyright statements, executable/module identities and all signing/entitlement
settings are retained. SunderSourceRef supplements the HTTPS repository URL for accurate
source navigation; publication/binary configuration must point to the final source revision.
