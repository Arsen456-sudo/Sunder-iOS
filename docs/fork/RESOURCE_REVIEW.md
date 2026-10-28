# Resource and license inventory review

Date: 2026-10-28. Baseline: `79d91e716dbb8aae80327f580aac9a6b42426466`.

## Scope

- 1436 tracked graphic/media/font/drawable candidates indexed with SHA-256.
- 1306 unique asset hashes; 77 duplicate-hash groups.
- 143 existing license/notice files indexed and preserved byte-for-byte.
- 10 Cabal source pins and 7 SwiftPM pins recorded.
- 16 pinned root-license texts retrieved;
  1 retrievals still require review.

The asset CSV starts every resource as unreviewed. Neither a filename, shared directory,
duplicate hash nor a license-family hint proves ownership or permission. Audio and fonts
also need review under their actual terms rather than an assumed graphic-asset grant.

## Asset candidates by top-level directory

- `apps`: 531
- `assets`: 88
- `blog`: 187
- `docs`: 244
- `fastlane`: 9
- `images`: 14
- `media-logos`: 8
- `packages`: 11
- `tests`: 4
- `website`: 340

## Original notice family hints

- AGPLv3-text: 5
- BSD-style-review-specific-notices: 106
- LGPL-text-review-version-and-use: 1
- MIT-style-text: 10
- Manual-review-required: 20
- Proprietary-graphic-policy: 1

## Limits

This is an inventory, not a complete legal or security audit. Root license retrieval is
evidence for further component-specific review. Untracked/downloaded libraries, generated
resources, transitive dependencies and every configuration's binary contents are not cleared.
No app code, identifiers, data storage, signing capabilities or assets were changed.
No tests/builds were run; no public visibility or message to an external author was requested.

## Stage 2 delta — 2026-10-28

The counts above describe the original inventory, not the remaining current tree.
88 optional image files have been removed from their recorded paths (5,230,933 bytes).
Their CSV rows now record removal; the remaining 1348 candidates are still pending review.
See REMOVED_ILLUSTRATIONS.json for exact evidence. Existing system-symbol/icon fallbacks
are used instead. This does not establish rights to all retained visual designs or icons.
Original images remain in Git history. No history rewrite or public release was performed.
Stage 1's statement that app source/assets were unchanged applies only to that checkpoint.

## Stage 3 delta — temporary bundled logo removal

See LOGO_REMOVAL.json for deletions and substitutions, including required plain launcher
placeholders and basic notification/tray markers. Original CSV hashes remain provenance
evidence, not hashes of the new placeholder files. No original logo has been relicensed.
Some resource names remain for compatibility but no longer contain the original artwork.
Unreviewed wallpapers, other illustrations/icons, website/blog assets and historical copies
remain pending; counts from the original inventory are not current remaining-file totals.

## Stage 4 iOS scope

Current iOS media, including audio and neutral substitutes, is separately indexed in
ios/RESOURCE_REVIEW.csv (88 files). Forty-four are known plain icon replacements; remaining
original graphics/symbols/wallpapers and three sounds need source/right resolution. No
tracked custom font files were found in the iOS source tree. Package-bundled resources
and vendored/binary dependencies are separately described in ios/REVIEW_SUMMARY.json.

## Stage 5 iOS resolution and export boundary

All 44 original media files remaining in the stage-4 iOS inventory are removed. Native
symbols/procedural texture and three original synthesized cues replace functional uses.
CURRENT_MEDIA.json is the current iOS allowlist; the old CSV remains historical evidence.
Other platform/website/blog media remains in the private working tree and is omitted
from the focused source snapshot together with private history; see PUBLIC_SOURCE_EXPORT.md.
