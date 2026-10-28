# Sunder iOS dependency and resource review

Date: 2026-10-28. This source-based review is not a final IPA SBOM or publication clearance.

## Evidence collected

- Seven exact Swift package manifests and repository trees, with source URLs and hashes:
  [SWIFT_SOURCE_REVIEW.json](SWIFT_SOURCE_REVIEW.json). SwiftyGif's original raw URL fails;
  the canonical renamed repository provides the same pinned commit. Pins are not changed.
- [RESOURCE_REVIEW.csv](RESOURCE_REVIEW.csv) inventories current tracked iOS media/fonts.
  Exact-name source matches are only hints: wallpaper and other dynamic lookup paths exist.
- Eighteen original Haskell notice files were empty. Full versioned report notices were
  recovered separately from Hackage, preserving original files unchanged:
  [SUPPLEMENTAL_EVIDENCE.json](SUPPLEMENTAL_EVIDENCE.json). The historical versions must
  still be matched to the actual native libraries before release.
- The 34,279,775-byte WebRTC M110 archive was downloaded for read-only inspection outside
  this repository. Its SHA-256 matches the exact Swift manifest. No binary was executed.
  [WEBRTC_ARCHIVE_REVIEW.json](WEBRTC_ARCHIVE_REVIEW.json) records entries and the extracted
  root LICENSE notice. A filename scan found no separate third-party notice file; embedded
  binary contents and the full underlying build dependency inventory were not audited.
- No tracked custom font files were found in the iOS source tree. This is not a claim about
  every eventual binary or the whole repository. ElegantEmojiPicker bundles JSON/icons;
  Yams compiles vendored CYaml. Root package labels do not certify imported data/artwork.

## Swift package evidence

| Package | Root license evidence / scope | Exact revision |
|---|---|---|
| codescanner | MIT | `34da57fb63b47add20de8a85da58191523ccce57` |
| elegant-emoji-picker | MIT | `71d2d46092b4d550cc593614efc06438f845f6e6` |
| ink | MIT | `bcc9f219900a62c4210e6db726035d7f03ae757b` |
| lzstring-swift | WTFPL-2.0 | `7f62f21de5b18582a950e1753b775cc614722407` |
| swiftygif | MIT | `5e8619335d394901379c9add5c4c1c2f420b3800` |
| webrtc | BSD-3-Clause (root/archive notice; third-party closure pending) | `34bedc50f9c58dccf4967ea59c7e6a47d620803b` |
| yams | MIT (root); vendored CYaml provenance remains separately reviewed | `9234124cff5e22e178988c18d8b95a8ae8007f76` |

No additional remote Swift source package dependency is declared in these inspected
manifests. Vendored C code and the WebRTC binary remain separate dependency scopes.
Root license texts are preserved in ../licenses/; supplemental sources are recorded here.

## Offline notice collection

Run `python scripts/ios/generate-sunder-notices.py` from the repository root (or any directory
using the script's absolute path). `--check` verifies generated text/input hashes without
writing. Generation uses local evidence only and requires no native build/network access.

The generator's `canonical` helper normalizes CRLF to LF; `generate` builds the ordered
collection and manifest, and its nested `add` helper validates local input boundaries,
skips empty files, rejects HTML responses and records content hashes. Original evidence
files remain unchanged. Scoped Git attributes preserve evidence/notice formatting with LF.

The main iOS target bundles `Shared/SunderNotices.txt`; Help & support opens it with native
SwiftUI navigation, lazy text sections and selection. Text loading occurs off the main
thread on first opening. No web rendering, telemetry or private GitHub access is required.
The text deliberately includes conservative historical/core evidence and does not assert
that every listed package ships in a particular IPA. See [NOTICES_INPUTS.json](NOTICES_INPUTS.json).

## Open items

Original wallpapers, badges, symbols and audio have not been cleared. Do not remove
wallpaper files without changing force-unwrapped dynamic lookups safely. No resource is
silently granted the root AGPL just because the application code uses it.

The local ignored `apps/ios/Libraries` artifacts are absent. Xcode expects native GMP,
GMPXX, libffi and Haskell archives. The helper downloads `latest` archives, so exact version,
source/build provenance and applicable obligations remain unverified. No assumption that
the historical Haskell license report matches these artifacts is made.

Full WebRTC third-party notices, CYaml vendor matching, actual archive contents and
extension-specific packaging still require review. Source-access links currently point to
a private development repository; they are not immutable public release-source manifests.

No native build, automated tests, device validation, history rewrite or public visibility
change was performed. See [REVIEW_SUMMARY.json](REVIEW_SUMMARY.json) for machine-readable scope
and [the overall checklist](../PUBLICATION_CHECKLIST.md) for remaining publication work.

## Superseding stage 5 media state

RESOURCE_REVIEW.csv above is a historical stage-4 inventory. All 44 original media entries
from that inventory are now removed. CURRENT_MEDIA.json records 44 neutral icon PNGs and
three original generated WAVs; ORIGINAL_MEDIA_REMOVAL.json and EMBEDDED_MEDIA_REMOVAL.json
record removed/replaced material. Core media values and previews use neutral image data.
The remaining dependency/binary gates above still apply; no new binary clearance is claimed.
