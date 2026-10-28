# Public source snapshot and first device build

The maintainer authorized public source publication and a test IPA build on
2026-10-28. Destination: https://github.com/Arsen456-sudo/Sunder-iOS.
The original private repository and its history remain private. Publication uses
the focused export from scripts/ios/export-public-source.py, including its
credential-marker gate, media allowlist, omission list and per-file hashes.

The in-app source reference is preview-20261028-1. This tag identifies the first
public source snapshot; successful binary compilation is not implied by the tag.

## UI scope and static review

Only the standard top bar of the chat list is replaced with UIKit UINavigationBar.
Existing controls are hosted as children; the root never edits the enclosing
navigation controller, other screens' appearance or its transition delegate.
Search, bottom one-hand toolbar, status polling and sheet actions retain their
existing behavior. AppTheme and ChatModel are explicitly supplied to hosting roots.
No custom blur/background overrides the system bar's rendering.

First review caught missing theme injection into the hosted avatar; corrected.
Export review also caught Git archive applying Windows autocrlf conversion. The
exporter now disables it explicitly; scripts and workflows have LF attributes.
Two subsequent static passes checked hosting ownership, search/one-hand branches,
conversation navigation restoration, bindings/sheet roots, availability guards,
source configuration and workflow permissions. Notice content/input hashes match;
Python scripts parse, plist parses and git diff --check passes. No Swift compilation
or device-layout check was possible on Windows. CI provides the native build check.

## Build scope

The manual workflow selects Xcode 26, builds the iOS core from this source using
flake.lock, caches resulting archives by native inputs, resolves locked Swift
packages, compiles the unsigned Release device application and packages an IPA.
Actions are pinned; credentials are not persisted in checkout. It does not publish
a release or upload signing material. Artifacts expire after three days.

An unsigned test IPA still needs signing. Original Keychain/App Group identifiers,
push compatibility, exact final binary dependency notices, native build success and
real-device validation remain separate release gates. The source snapshot is not
an App Store submission or a claim that these gates have been resolved.

The earlier PUBLIC_EXPORT_READY.json describes the preceding local snapshot,
not this updated public snapshot. SOURCE_EXPORT.json in the new export is the
authoritative file/hash/omission record for this publication.
