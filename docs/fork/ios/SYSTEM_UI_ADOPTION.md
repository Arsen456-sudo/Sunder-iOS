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
