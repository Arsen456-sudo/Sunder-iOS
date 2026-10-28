# Sunder development and publication preparation

Sunder is the chosen name for the independent client being prepared from SimpleX Chat.
Display names and the iOS welcome screen now use Sunder; complete icon/platform branding remains pending. It is not an official SimpleX Chat release and
is not endorsed or maintained by SimpleX Chat Ltd.

The repository remains private. This directory records preparation work, not a
declaration that the current tree, assets or binaries are cleared for public release.

## Preparation records

- [Publication checklist](PUBLICATION_CHECKLIST.md): completed items, decisions and open work.
- [Modification record](MODIFICATIONS.md): upstream baseline and dated fork changes.
- [Licensing and assets](LICENSING.md): separate code, artwork and trademark rules.
- [Dependency sources](DEPENDENCIES.json), [license-file inventory](LICENSE_FILES.csv)
  and [asset inventory](ASSET_INVENTORY.csv).
- [Resource review summary](RESOURCE_REVIEW.md): counts and limitations of the inventory.
- [Privacy addendum](PRIVACY_ADDENDUM.md) and [release procedure](RELEASING.md).
- [Unsent permission-request draft](PERMISSION_REQUEST_DRAFT.md).

The original `LICENSE`, `assets/ASSETS_LICENSE.md`, `docs/TRADEMARK.md`, `PRIVACY.md`
and existing third-party notices remain in place. This preparation does not relicense
material owned by others. Read the applicable original documents as well.

Bundled application logo removal is recorded in [LOGO_REMOVAL.json](LOGO_REMOVAL.json).
Required app-icon slots temporarily contain plain color fields; no new logo is claimed.
Historical website/blog/media copies and remaining non-logo resources still require review.

The [iOS dependency/resource review](ios/README.md) records pinned manifests, remaining
resources, recovered notice evidence and unresolved native-binary gates. The main iOS
target now includes an offline notice viewer; this is not full release/publication clearance.

[Focused public-source export](PUBLIC_SOURCE_EXPORT.md) prepares a new directory without
private history or old non-iOS media. Remaining original iOS resources and promotional
entry points are now replaced/removed; see ios/CURRENT_MEDIA.json. The original private
repository remains unchanged in visibility; native binary release still has separate gates.
