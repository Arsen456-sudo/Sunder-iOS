# Standard Apple component adoption

AppearanceSettings is the unchanged reference. Current implementation uses the
same NavigationView, List, Section, Picker, Toggle, Button and toolbar APIs for
menus/forms/navigation. This is not a claim that message/media content is a settings
form or that SwiftUI has been rewritten into UIKit.

## Concrete replacements after device feedback
- Avatar menu: a system NavigationView and one List with standard sections/rows,
  profile switching, native title/Done and appearance Menu. No List inside another
  ScrollView; no custom glass cards or hand-sized horizontal profile strip.
- Chat-list top/bottom controls: standard ToolbarItem/ToolbarItemGroup, with original
  avatar, compose, connection-status and stopped-chat actions.
- Contact/group/server profiles: native large title and toolbar, standard grouped
  information and native actions. Server selection uses Picker rows.
- Chat/folders/calls: standard native button styles and bar materials; original
  message/editor/voice/call content and actions remain.
- Profile confirmation: system sheet with List, preserving the profile image,
  badges, text and every original callback after dismissal.

The custom glass navigation controller, manual scroll probe and custom segmented
selector are removed. Shared SystemInterface.swift supplies defaults, not a custom
visual replacement. UIKit media/editor bridges and old-OS fallback code remain.

## Inventory and verification
SYSTEM_UI_INVENTORY.json records the current view sources and helpers, not a count
of screens or proof of visual verification. Run scripts/ios/audit-system-ui.py and
--check to update/verify; CI checks it. A successful compile cannot validate all
routes, accessibility sizes, light/dark variants or presentation sequences.

## Maintainer design constraint and control correction (2026-10-30)
Navigation and interactive chrome must use Apple's current native design, with
UIKit controls where explicit geometry/behavior is needed. Do not substitute
translucent colored rectangles or generic TextFields for system search controls.
iOS 26 is the available build SDK baseline; iOS 27 appearance is not verified.

ChatListNativeSearch now embeds UISearchBar with delegated text/focus/cancel and
link-progress bindings, shared by chat/contact/member/message searches. Main
profile/compose/unread controls use UIButton.Configuration.glass/prominentGlass
on iOS 26, a 44-point square intrinsic size and capsule corner style. Avatar pixels
are center-cropped to a 28-point circle once per source image, with original colors.
Native toolbar shared backgrounds are disabled only where UIKit supplies glass,
including the reachable toolbar. No extra backdrop is stacked over these buttons.

Settings navigation labels use semantic primary foreground, independent of action
tint. Compose ordinary actions use semantic label colors; warning/destructive and
incognito distinctions are retained. The conversation no longer forces an opaque
navigation-bar background, and its top container extends beneath that bar. Existing
virtualized-list insets, pagination and voice gestures are retained. Device checks
must include large text, keyboard/cancel, search links, dark/light and push/back.

Safe-area review: only the message-list layer extends under the top navigation
bar. Composer, search inset and overlay controls retain their safe-area layout.

## Main navigation revision (2026-10-30)
- UIKit UITabBarController with three persistent roots and native UISearchTab.
- Profile tab uses a circular, original-color avatar; UIKit button image views use
  fixed centered bounds to avoid inherited symbol baseline placement.
- Main Edit/folder manager, smaller normal chat rows, explicit native top search
  with a separate Close action, and one pinned UIKit folder selector.
- Folder membership reuses ChatTag APIs, including non-destructive multi-folder
  selection and retry of partially saved folders. Other account routes are retained.
- Main roots remain SwiftUI content hosted by UIKit; this is not a full rewrite of
  each settings/chat/profile implementation. Device checks are still required.

## Native integration correction (2026-10-30)
UIScrollEdgeElementContainerInteraction now attaches the 40-point folder control
to its actual vertical list. UISearchController owns the main navigation search;
native UIBarButtonItem identifiers and non-shared native backgrounds drive changes
without custom animation timing. Compose uses an unresized system toolbar symbol.
Ordinary chat title/avatar are separate items; notes/selection retain old routes.
The Profile tab has its own localized label. Root-depth callbacks hide tabs below
settings/profile roots and exclude modal wrappers. Grouped settings use native
background/default controls; existing SwiftUI content remains hosted by UIKit.
Delete is visible in folder editing and confirms before removing only its tag.
All device appearance and transition acceptance checks remain pending installation.

## Three-island correction (2026-10-31)
Default chat title is cleared at its source. Native UIKit fixed center/trailing
item groups place the sole title in the center and avatar at the trailing edge.
A fixed ToolbarSpacer actually separates unread and compose groups on the list.
Leading/context/avatar identifiers remain stable for native UIKit transitions.
Back action and native navigation delegate are unchanged. Group caches and scoped
cleanup preserve message selection; notes/secondary routes stay unchanged.
Source verification is not a substitute for installed-device visual acceptance.

## Compact-phone correction (2026-10-31)
The earlier centerItemGroups attempt is superseded: chat title uses principal,
avatar trailing, independent native glass styles and no shared toolbar backing.
SunderToolbarIdentity has been removed, rather than repeatedly moving UIKit items
after layout. Root tab hiding uses native will callbacks and animated:false,
including selection/interactive-cancel restoration. Device acceptance remains pending.

## Native matched-header follow-up (2026-10-31)
Title is now a source-owned UIKit center UIBarButtonItem matching sunder.context,
not a principal titleView or a relocated trailing SwiftUI item. It uses native glass
backing, a 44pt hosted action, and native editor navigation style. Avatar image is
32pt in its separate native bar item. Search delegates cancel layout to the system.
FolderControl has actual UIGlassEffect; the native tab bar is explicitly associated
with the list's bottom soft scroll-edge effect. Ordinary list taps no longer wait
250ms before selecting the route; async loading and cancelled publication are guarded.
Windows source checks are not device visual/performance verification. CI must compile
and iPhone checks must cover both navigation directions, narrow widths, long titles,
search cancel, light/dark themes, folder overflow and rapid open/back navigation.

## Compact-title/shared-edge correction (2026-10-31)
Device feedback supersedes the centerItemGroups experiment: title was absent. The
header returns to principal placement with a single 44pt native glassEffect capsule.
The failed adapter is deleted; avatar/back stay separate and retain native transitions.
Bottom .soft behavior now belongs to SunderTabsController via content-scroll
registration for all three roots, without the search-owned bottom interaction.
Device visibility/blur and the outstanding unread-to-title morph must be checked
separately from compilation. No custom blur or animation engine is introduced.

## Toolbar availability correction (2026-10-31)
Run 41209965480 failed on ToolbarContentBuilder.buildIf availability for iOS15.
Availability now lives in the outer ViewBuilder; modern toolbar is iOS26-only.
Avatar menu indicator is hidden while long-press actions remain. Automatic role and
principal title replace the installed prior build's failed editor-center experiment.
CI and actual avatar-only appearance remain separate verification steps.

## Full-page chat profiles (2026-10-31)
Contact/group/channel profiles opened from chat now use the same content in a
native pushed destination with back, without their modal NavigationView/Done.
Other modal callers retain defaults. Privacy/style and group cleanup are retained.
Avatar artwork increases to 34pt; no other island geometry or native animations
change. A redundant MainActor Task hop is removed from row entry. No measured
latency gain is claimed. Unread-filter-to-principal-title matching remains unresolved
and is not claimed fixed; prior center-group implementations failed on device.

## Profile and native identity stabilization (2026-10-31)
User feedback reports a profile push hang. NavStackCompat's synthesized path is
replaced by persistent @State, preserving nested destinations. The group-profile
initial synchronous core read is moved to the existing async API path. Destination
avatar native identity is restored without regrouping or geometry changes; existing
center items are identified only if UIKit exposes them. Structural header diagnostics
contain counts/presence only. No custom animator is introduced; full unread-to-title
morphing and stability require actual iPhone evidence rather than compile success.

## USB reproduction and targeted correction (2026-10-31)
Captured build23 logs during user-reproduced profile hang. Findings: one SwiftUICore
state-during-update fault; sustained repeated action-label work; header titleView=true,
centerItems=0 and legacy right-bar count=0. Raw logs/tooling are ignored under build/.
No explicit cycle-detected message or symbolicated main-thread sample was obtained.
Isolate profile destination and its captures; defer/coalesce model visibility callbacks
while hiding native tabs synchronously; resolve semantic IDs from actual grouped
native items and preserve groups through search. No geometry/role/animation redesign.
These are runtime-informed changes, not a claim that the new build has been tested
on device or that filter-to-title matching is complete. Re-test both after install.

## Symbolicated build24 hang samples (2026-10-31)
Installed source tag verified over USB. Two runnable main-thread snapshots were
symbolicated using the phone's matching cache; sampled work includes SwiftUI graph
updates and DeprecatedAlertBridge.update(environment:), not a core/network wait.
The narrow workaround replaces DismissAction properties only in the main contact/
group profile views with presentationMode-backed dismiss(). All actions remain.
Unread sharing is disabled once per actual resolved item; metadata logs use primitive
values so match flags/group size are visible. A multi-item native group may ignore
that property. Full filter-to-title morph is still a known gap. New build phone
validation remains mandatory; no full stability claim or latency percentage is made.
Raw samples, device cache and tools are ignored build artifacts, not published assets.

## Independent full-screen profile recovery (2026-10-31)
Verified disk build25 IPA marker/hash and installed phone marker match the intended
source; unchanged bugs are code failures, not stale file replacement. Remove the
failing chat-stack profile push. Reuse the original profile NavigationView and
DismissAction in an independent fullScreenCover, with leading back and modal Done
fallback. All content and privacy remain; cleanup runs after dismissal. This is a
full-screen system presentation, not a push. Native filter-to-title morph is not
changed or claimed solved. Device validation must precede a stability claim.
