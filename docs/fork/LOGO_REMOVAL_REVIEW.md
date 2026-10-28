# Temporary bundled-logo removal review

Date: 2026-10-28. Previous checkpoint: a84ddab7f.
Scope: application resource/presentation preparation, not a public-release audit.

Two consecutive final static review passes found no additional issues after fixes.
Checks covered:

- Manifest hashes and exact deletion scope: 42 deleted resources, 85 substitutions,
  7 new metadata/vector slots. See LOGO_REMOVAL.json for precise paths and hash conventions.
- 80 flat PNGs retain original dimensions, valid CRC/compression, opaque RGB encoding
  and one uniform fill. These are technical placeholders, not final app artwork.
- 23 remaining iOS asset catalogs have valid JSON and existing referenced image files;
  obsolete empty image-set directories were removed from the local checkout too.
- Changed SVG/XML/plist/JSON resources parse and git diff --check passes.
- 145 existing license/notice/policy paths are preserved, accounting for Git CRLF conversion.
- QR generation payload/correction and screenshot/share code are preserved; Kotlin preview
  and export both omit addLogo. Device scan/export appearance is not validated.
- Spoiler hiding/reveal code is unchanged; removing the watermark does not expose text.
- Call lifecycle code after provider configuration is unchanged. The optional custom
  CallKit template is omitted; native appearance remains to be checked on a device.
- Operator names, selection and conditions remain; only their rendering was changed.
- No Haskell core, model, entitlement or Xcode project changes; no new backend/permissions.
- Scoped product/spec/concept/impact documentation and source links were reviewed.

No native builds or automated tests were run. This does not validate device behavior,
notification visibility across Android versions, signing, packaging on every desktop OS,
the remaining dependency licenses or rights to other assets/history. Website/blog/media
copies and screenshots remain pending. Repository visibility/history are unchanged.
