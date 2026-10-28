# Release preparation procedure

This is a future-release procedure, not a claim that a build or public release is ready.

1. Resolve the publication checklist for the exact release scope: source repository,
   modified application, platforms, artwork, service access and dependencies.
2. Choose and apply approved independent branding without changing protocol/storage IDs blindly.
3. Record an immutable commit/tag, source location, submodule references, package locks,
   selected platform/flavor, native library source/build inputs and toolchain versions.
4. Build only through a reviewed fork-specific workflow. Upstream release, website, CLA,
   schedule and matrix jobs are not this fork's release pipeline and are guarded.
5. Perform the agreed build/device/security/accessibility checks; record actual outcomes.
6. Prepare source and license access from the application. For each binary distribution,
   include clear access to its exact Corresponding Source, necessary build scripts,
   notices and dependency source/relinking information where required.
7. Include a source/build manifest and SHA-256 checksums with release artifacts. Keep
   required source available; a mutable latest-branch link alone is insufficient.
8. Inspect repository refs/history, artifacts/logs and screenshots before public exposure.
   Ignore rules do not erase previous commits; rotate an actual leaked credential.
9. Review the completed evidence and explicitly authorize publication. Neither a private
   push nor a commented-out feature proves that a later public release is compliant.

Keep Apple/server credentials outside the repository. Do not increase paid CI budgets,
change visibility or publish a binary merely as a side effect of preparing this procedure.
