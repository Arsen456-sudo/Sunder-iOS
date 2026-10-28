# Publication preparation checklist

Started: 2026-10-28. Repository: Arsen456-sudo/SimpleX-Private.
Source baseline: `79d91e716dbb8aae80327f580aac9a6b42426466` (upstream `stable`).
Status: private development. No public release approval or legal certification is implied.

## 1. Code licensing and provenance

- [x] Identify the upstream commit and preserve original copyright/license texts.
- [x] Record the dated fork changes separately from upstream changes.
- [x] Explain code/asset/trademark licenses separately rather than marking everything AGPL.
- [x] Inventory existing license files with hashes and descriptive license-family hints.
- [x] Retrieve missing-report license evidence for pinned direct-sqlcipher, sqlcipher-simple
  and simplexmq sources; preserve full notices and exact source revisions.
- [x] Record Cabal, SwiftPM and Git submodule references as source evidence.
- [x] Inspect all seven pinned iOS Swift manifests/trees and checksum-verify the WebRTC archive.
- [x] Recover the 18 empty historical Haskell notice texts as separate versioned evidence.
- [x] Inventory remaining tracked iOS media and classify pending source/right questions.
- [ ] Finish dependency review for the actual selected platform, release configuration,
  bundled native/prebuilt libraries, fonts and transitive dependencies. Inventory is not a complete SBOM.
- [ ] Verify Corresponding Source availability and any relinking/source obligations for
  every dependency in the actual released binary, including LGPL components where shipped.

## 2. Artwork and branding

- [x] Identify the proprietary asset policy and separate trademark policy.
- [x] Inventory tracked graphic/media/font files and Android drawable XML with hashes.
- [x] Prepare a request clarifying source-repository publication, modified-app distribution,
  screenshots and the policy's broad reference to visual designs. The request is not sent.
- [x] Record the maintainer-selected product name: Sunder (2026-10-28).
- [ ] Assess independent name/logo availability before claiming exclusive brand rights.
- [ ] Decide which existing resources have an applicable grant or separate third-party license.
  Do not assume every file in the inventory has the same owner or license.
- [x] Remove the optional 88-file illustration pack and select existing fallback presentation.
- [x] Remove bundled logo artwork and QR/watermark branding; retain neutral technical icons.
  Website/blog/media copies and Git history are not covered by this app-resource stage.
- [ ] Obtain written permission or replace remaining affected resources with original/compatible material.
  Track grant/evidence per resource or explicitly covered group, including copies with matching hashes.
- [ ] Resolve the treatment of retained resources in public source and Git history. Removing
  a current resource does not remove older copies; any history rewrite needs a separate agreed plan.
- [x] Apply Sunder visible iOS names/permission captions, temporary neutral icons and native symbols.
  Protocol identifiers, operator names and original legal attribution are intentionally retained.
- [x] Remove remaining original iOS media and promotional entry points; keep native/procedural replacements.
- [x] Prepare focused export excluding old site/blog/media and private history, with an omission manifest.
- [ ] Review the final source destination and any future store listing/screenshots before publication.

## 3. Repository ownership and contribution process

- [x] Provide an independent root README; preserve the upstream version in Git history.
- [x] Provide fork-specific contribution/security guidance and ordinary issue/PR templates.
- [x] Route CODEOWNERS to this repository's maintainer and remove inherited donation destinations
  from GitHub's repository funding configuration. No replacement payment destination is invented.
- [x] Guard upstream-only workflow jobs, including the CLA bot, against execution in this fork.
  Do not request a SimpleX CLA merely for contributions to this independent repository.
- [ ] Configure and verify a private vulnerability contact before inviting security reports.
  This is a project-readiness recommendation, not an additional AGPL condition.
- [ ] Adapt in-app support, donation and source links after branding is decided.
  iOS Help & support is adapted; remaining platform and promotional destinations need review.

## 4. Service access and privacy

- [x] Preserve the original operator Conditions of Use and acceptance-related application code.
- [x] Draft an accurate addendum that distinguishes the fork from upstream-operated services.
- [ ] Verify onboarding acceptance before network access for supported operators.
- [ ] Complete source/license notices across supported platforms and make release source accessible.
  iOS now bundles available license/attribution text with an offline viewer. Development
  source/issues links remain private; final binary/source matching and full notice closure are open.
- [ ] Review protocol age/compatibility, upstream limits, bot behavior, consent, absence of
  tracking/analytics, and preservation of end-to-end encryption against the actual release.
- [ ] Review iOS signing/App Groups/APNs as a separate compatibility task if iOS is selected;
  publishing source or obtaining a signing account does not itself configure push service.
- [ ] Update the addendum for any future services, data processing, crash reporting or logs.

## 5. Release, exposure and distribution

- [x] Document a procedure linking each future binary to immutable source and build inputs.
- [x] Add ignore rules for common local signing files, credentials and diagnostic outputs.
- [x] Perform documented current-tree and all-reachable-local-history credential-pattern reviews;
  classify findings and keep secret values out of reports. No absolute personal-data/security claim.
- [x] Ensure export excludes ignored files, .git and historical fixture/media scope.
- [ ] Review final exported content and destination before external publication.
- [x] Inspect private GitHub metadata: all four workflows disabled, zero runs and zero artifacts.
  The original default branch/history remain private; focused export creates no Git history.
- [ ] Run the requested platform build and device checks before claiming it works. No tests
  or builds have been run as part of this documentation/resource preparation.
- [ ] Confirm complete source/notices accompany released packages, and record checksums.
- [ ] Decide separately whether to publish an unchanged source fork or distribute an independent
  modified application. The asset/service/distribution questions are not interchangeable.
- [ ] Review this list with the resolved evidence, then authorize a visibility change explicitly.

Completed checkboxes describe preparation performed, not approval to publish the application.
