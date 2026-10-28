# Licensing scope and evidence

Review date: 2026-10-28. This is a technical preparation record, not a legal opinion.

## Source code

The root `LICENSE` is GNU AGPL version 3. Preserve original notices and mark changes/dates.
Modified covered work must be distributed under the applicable AGPL terms, with the
Corresponding Source required for released binaries. The network-source provision must
also be addressed when applicable. Do not remove downstream rights or silently replace
the whole project's license with a permissive or proprietary one. Check file-specific
declarations; a dependency can have different compatible terms.

The original root and package license files remain unchanged. This fork's original
documentation contributions are Copyright 2026 the repository contributors and provided
under AGPL-3.0-only, without relicensing any quoted, copied or incorporated upstream material.

## Graphics and visual designs

`assets/ASSETS_LICENSE.md` expressly excludes covered graphic assets from the code license.
It permits use as part of an unmodified application and requires permission for other
uses described there. Its scope is not limited to the assets directory, and it includes
visual designs. Do not claim that changing only the name or recoloring an icon resolves it.

`ASSET_INVENTORY.csv` is a list of files to investigate, not a legal determination that
every item is proprietary. Some resources may have independent authors/licenses or be
generated from code; record evidence before deciding what may remain. Do not delete,
relicense or replace graphics mechanically based only on the filename or inventory.

GitHub's public-repository view/fork permissions are distinct from permission to ship a
modified application. Confirm the intended source-publication and distribution scope,
especially for a standalone copy retaining all history. Keep the repository private
while unresolved use of assets in a modified product is being assessed.

## Branding

Read `docs/TRADEMARK.md`. Do not brand the independent client with SimpleX's name/logo or
imply endorsement without permission. Attribution and descriptions of SimpleX network
compatibility are different from product branding. Keep original copyright statements.
The maintainer selected Sunder as the independent product name. Stage 2 prepares display
names and the welcome mark; full icon/platform branding remains pending. Internal identifiers
are unchanged; third-party name clearance has not been assessed.

## Dependencies

Keep `docs/dependencies/`, bundled notices and external license evidence. The generated
Haskell report has missing metadata for three sources. Evidence at the actual Cabal pins:

| Source | License evidence | Pinned commit |
|---|---|---|
| direct-sqlcipher | MIT text, Copyright Irene Knapp | f814ee68b16a9447fbb467ccc8f29bdd3546bfd9 |
| sqlcipher-simple | Multiple BSD-3-Clause notices; retain all | a46bd361a19376c5211f1058908fc0ae6bf42446 |
| simplexmq | AGPLv3 license text; retain its additional file notices | efaad8e73436d60f5052f07dda6b71151ad5039b |

`LICENSE_EVIDENCE.json` records downloads, hashes and unresolved retrievals. A retrieved
root license does not prove the license of every bundled artifact or transitive dependency.
The Haskell report's old version labels do not override the commits in `cabal.project`.
For pinned `android-support`, the root-license endpoint returned 404 and its package metadata
has only a commented-out, empty license field. The metadata is preserved as evidence; permission
and applicable full notices remain unresolved. Do not infer a license from the parent application.
The VLC notice present is LGPLv2.1; apply obligations only to the configurations that ship it.

## Service conditions

Operator Conditions of Use in `PRIVACY.md` apply separately when using the operators'
infrastructure. Preserve user acceptance and the security/privacy/compatibility requirements.
Do not silently rename the operator, substitute our own terms, or assume that copyright
licensing alone grants arbitrary service access. See `PRIVACY_ADDENDUM.md`.

## Originals and references

- https://github.com/simplex-chat/simplex-chat/blob/stable/LICENSE
- https://github.com/simplex-chat/simplex-chat/blob/stable/assets/ASSETS_LICENSE.md
- https://github.com/simplex-chat/simplex-chat/blob/stable/docs/TRADEMARK.md
- https://simplex.chat/privacy/
- https://docs.github.com/en/site-policy/github-terms/github-terms-of-service#5-license-grant-to-other-users

The local upstream baseline recorded in `MODIFICATIONS.md` identifies the version examined;
these moving web links are useful for checking subsequent policy changes.
