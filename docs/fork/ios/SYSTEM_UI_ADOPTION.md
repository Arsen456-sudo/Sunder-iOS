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
