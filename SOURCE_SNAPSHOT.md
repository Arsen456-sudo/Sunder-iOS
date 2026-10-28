# Sunder iOS source snapshot

Prepared from private preparation commit `50e50f2ef6868d714b36821e8e96caa930864134`.
This directory contains no .git history, ignored local files or downloaded native binaries.
Original code copyright/license texts remain; SOURCE_EXPORT.json records omissions and doc edits.
Non-iOS apps/services, web/SDK clients, historical website/blog/promotional material and the upstream
test fixture suite are omitted. They remain in the private source; test targets are not supported
by this focused export. Runtime Haskell/iOS source and platform build inputs are retained.
The retained build/source tree targets iOS; unrelated frontend builds are not supported here.
Private source/support links still need a final public repository destination.
A native build, own signing/keychain configuration, exact native-library provenance, full
third-party binary notices and device checks remain prerequisites for distributing an IPA.
This snapshot is prepared for review; it does not change repository visibility or guarantee
that every remaining source-license/service question is resolved.

SOURCE_EXPORT.json records original Git executable modes. When initializing a new Git repo
on Windows, run git add first, then restore 100755 entries using git update-index --chmod=+x
before committing. Do not copy .git metadata from the old private checkout.

Subsequent maintenance commits
------------------------------
SOURCE_EXPORT.json describes the initial source export. Later tracked changes are
recorded by Git commits; use the current commit and CI SOURCE_COMMIT.txt for an exact
build reference. The export manifest is not a rolling hash list of later commits.
