# Sunder preparation inspection

Date: 2026-10-28. This is a limited preparation review, not publication clearance.

- Read 2916 eligible current text files using three narrow secret-pattern rules.
- Found one private-key-header match: the unchanged upstream TLS test fixture
  `tests/fixtures/tls/server.key`, referenced by the test code and present since an upstream
  2022 commit. This is known public test material, not a new maintainer credential.
  Do not reuse it for production. Matching key contents are not published in this report.
- The detailed local inspection report is outside this repository at
  `C:\NeoSignal\build\research\sunder-current-tree-inspection.json`.
- This does not cover all personal information, arbitrary passwords, binary contents,
  full Git history or future Actions artifacts. No claim that the repository is secret-free is made.
- All existing license files, the original root operator policy and trademark policy
  were preserved byte-for-byte by the preparation script.
- Application source, identifiers, assets, protocol and database behavior remain unchanged.
- No tests or builds were run. Graphics permission and remaining checklist items are unresolved.

## Stage 2 scope update — 2026-10-28

The unchanged-source statement above applies to stage 1. Stage 2 changes presentation,
display names and iOS help destinations, and removes the optional illustration overlay.
See STAGE2_SUMMARY.json and REMOVED_ILLUSTRATIONS.json. No runtime validation is claimed.
Original operator conditions, license texts, protocol and storage remain unchanged.

## Stage 3 scope update

Bundled logos and their call sites were inspected. Logo-free presentation retains provider
names, QR modules/payloads, spoiler hiding and normal notification/status resources.
The stage manifest records original and replacement hashes. Static resource checks do not
validate a native build, QR scan on a device, notification appearance or overall asset rights.

## Reachable history and current-tree review

HISTORY_SECRET_REVIEW.json records a five-rule scan of 71,099 candidate blobs / about
6.5 GB from all local refs. Sixteen marker hits are upstream public TLS fixtures or test
format/empty-key literals; no GitHub/AWS/Slack/Google-token rule matched. Findings do not
contain secret values. Current-tree review is separately recorded; ignored data and Git
metadata are never copied by the exporter. This is not an arbitrary-secret/person-data
certification. REMOTE_REVIEW.json records disabled workflows and zero runs/artifacts.
