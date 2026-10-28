# Sunder iOS-focused public-source preparation

The private working repository retains upstream graphics/history and its original main
branch. Do not treat that entire history as sanitized by current-file deletion.

`python scripts/ios/export-public-source.py NEW_DIRECTORY` reads the committed Git tree
and writes a fresh external directory. Existing destinations are refused. No .git metadata,
ignored local data, native build downloads, repository creation/push or visibility change.
SOURCE_EXPORT.json records file hashes, excluded entries and doc illustration edits;
SOURCE_SNAPSHOT.md explains scope. An INCOMPLETE_EXPORT marker remains on a failed export.

This export targets iOS runtime source plus shared Haskell/runtime/build inputs. It omits
Android/Desktop, web/SDK clients, the upstream test/fixture suite, historical site/blog and
promotional media, unreviewed image/audio/font/prebuilt files. Those remain privately
available. Only hash-approved neutral iOS icon PNGs and original generated WAV cues pass
the media allowlist. Original licenses/copyright/policies and dependency provenance remain.
Ordinary Markdown illustration embeds are replaced with explicit omission text; license
texts are not rewritten. This is not a full upstream development checkout or a tested IPA.

The resulting directory is suitable for a final source-publication review and a new clean
Git history. It does not prove a native build, an immutable binary/source match, every
dependency/service permission, or complete security review. The configured source URL is
still the existing private development repository until a final destination is selected.

Before distributing binaries: configure own bundle/signing IDs and consistent Keychain/
App Groups; the upstream Team ID/access group must not be mistaken for the maintainer's.
Provide exact native library sources/versions/notices and full WebRTC dependency closure,
verify the final archive, offline notices, push service compatibility and device behavior.
These are separate from preparing a public source snapshot. No Apple account is invented.

The focused export also excludes other non-iOS apps/service entry points; shared runtime
code remains under src/. Original Git executable modes are recorded per retained file.
For publishing a new Git repository from Windows, stage files first, then restore script
executable bits from SOURCE_EXPORT.json (100755) with git update-index --chmod=+x before
the first commit. This avoids losing executable permissions on NTFS.

The public README is generated for this focused snapshot, and the issue-template config
does not retain private contact links. A credential-marker gate rejects matching text
before it is written; this supplements, rather than certifies, the recorded privacy review.
Configure SunderRepositoryURL (HTTPS repository root, without .git) and SunderSourceRef
(an actual corresponding source commit/tag/ref) before distributing a binary; regenerate
offline notices after either changes.

Publishing source and distributing an IPA are separate scopes. Native binary/signing/device
gates above do not imply that source-code publication requires a working IPA. The prepared
snapshot contains no old private Git history; the original repository remains private.
