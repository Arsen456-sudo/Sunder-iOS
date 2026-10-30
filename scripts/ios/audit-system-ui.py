#!/usr/bin/env python3
"""Reproducible source inventory, not a substitute for device UI validation."""
import argparse
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "docs/fork/ios/SYSTEM_UI_INVENTORY.json"


def inventory():
    shared = ROOT / "apps/ios/Shared"
    files = set((shared / "Views").rglob("*.swift"))
    files.update(shared / name for name in ["SimpleXApp.swift", "ContentView.swift", "Theme/Theme.swift"])
    files.update((ROOT / "apps/ios/SimpleX SE").glob("*.swift"))
    records = []
    for path in sorted(files, key=lambda p: p.relative_to(ROOT).as_posix()):
        raw = path.read_bytes()
        source = raw.decode("utf-8")
        lines = source.splitlines()
        matches = lambda pattern: [i for i, line in enumerate(lines, 1)
                                   if not line.lstrip().startswith("//") and re.search(pattern, line)]
        views = re.findall(r"\bstruct\s+(\w+)[^\n]*:\s*(?:[^\n]*,\s*)?View\b", source)
        records.append({
            "path": path.relative_to(ROOT).as_posix(),
            "sha256": hashlib.sha256(source.replace("\r\n", "\n").encode("utf-8")).hexdigest(),
            "swiftui_view_declarations": views,
            "native_lists_forms": matches(r"\b(?:List|Form)\s*(?:\{|\()"),
            "navigation_containers": matches(r"\b(?:NavigationView|NavigationStack|NavStackCompat)\s*[({]"),
            "system_controls": matches(r"\b(?:Picker|Toggle|Slider|SecureField|TextField|DatePicker|ColorPicker)\s*\("),
            "hidden_navigation": matches(r"\.navigationBarHidden\(true\)"),
            "legacy_material_references": matches(r"ToolbarMaterial\.material\("),
            "native_bridges": matches(r"(?:UIViewRepresentable|UIViewControllerRepresentable|UIHostingController|UIVisualEffectView)"),
            "validation": "Source-pattern inventory; full-screen device validation pending",
        })
    return {
        "reference": "apps/ios/Shared/Views/UserSettings/AppearanceSettings.swift",
        "policy": "SunderSystemInterface at app root, themed screens and presentation boundaries",
        "scope": "Main app view sources and share-extension sources, including content components and non-UI helpers",
        "meaning": "Lexical coverage only; entries are not necessarily distinct screens or reachable routes",
        "file_count": len(records),
        "records": records,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    text = json.dumps(inventory(), indent=2, ensure_ascii=False) + "\n"
    if args.check:
        if not OUTPUT.exists() or OUTPUT.read_text(encoding="utf-8") != text:
            raise SystemExit("System UI inventory is stale; run scripts/ios/audit-system-ui.py")
        print("System UI source inventory matches.")
    else:
        OUTPUT.parent.mkdir(parents=True, exist_ok=True)
        OUTPUT.write_text(text, encoding="utf-8", newline="\n")
        print(f"Inventoried {len(inventory()['records'])} Swift source files.")


if __name__ == "__main__":
    main()
