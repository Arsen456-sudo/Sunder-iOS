# Development fork privacy addendum — draft

Date: 2026-10-28. This document is not integrated into app onboarding yet.

The upstream operator privacy policy and Conditions of Use remain in the root `PRIVACY.md`.
Do not replace them with the name of the fork or remove acceptance before service access.
This addendum describes the fork preparation, not the practices of an invented operator.

The preparation includes documentation, inventories, repository configuration and presentation-only changes: illustration removal, display names and iOS support/source links.
They do not add an application backend, analytics, advertising or a diagnostic-upload endpoint,
and do not alter encryption, profile storage, networking or notification registration.
This limited statement is not an audit of every inherited feature or dependency.

Before releasing a modified client, verify operator acceptance, current protocol support,
limits, absence of tracking and preservation of end-to-end encryption. Obtain explicit
consent for transmissions not directly needed for user communications under the applicable
conditions. Explain any future third-party services or reporting in this addendum.

Some upstream branding and promotional destinations remain pending review. iOS Help & support now points to the private Sunder development repository; users following external links contact GitHub under its own policies. This does not add automatic telemetry.
Do not describe the independent fork as officially supported, audited or operated by SimpleX.
iOS push authorization and notification-server compatibility require separate verification.

Public issues, screenshots and CI artifacts can expose personal data. Submit ordinary
fork bugs only after reviewing the information. Follow `SECURITY.md` for vulnerabilities.
A dedicated private fork reporting contact remains to be configured.

The iOS offline notice viewer loads bundled plain UTF-8 text only. It adds no server,
analytics, permission or automatic external request. Opening existing source/issues links
still contacts GitHub. Dependency-evidence downloads performed during preparation do not
add those download operations to the application runtime.
