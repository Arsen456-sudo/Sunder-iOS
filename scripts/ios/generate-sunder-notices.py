#!/usr/bin/env python3
"""Generate Sunder's offline iOS notice collection from preserved source evidence.

This is a conservative development collection, not a resolved binary license audit.
Run from any directory with Python 3.9+. No network access or native build is needed.
"""

import argparse
import hashlib
import json
import plistlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "apps/ios/Shared/SunderNotices.txt"
MANIFEST = ROOT / "docs/fork/ios/NOTICES_INPUTS.json"


def canonical(data):
    return data.replace(b"\r\n", b"\n")


def generate():
    entries = []
    seen = set()

    def add(relative_path, title, provenance):
        path = (ROOT / relative_path).resolve()
        if not path.is_relative_to(ROOT):
            raise ValueError("Notice input outside repository")
        if relative_path in seen:
            return
        seen.add(relative_path)
        data = canonical(path.read_bytes())
        if not data.strip():
            return
        text = data.decode("utf-8-sig")
        if text.lstrip().lower().startswith(("<!doctype html", "<html")):
            raise ValueError("HTML response is not a license notice: " + relative_path)
        entries.append({
            "path": relative_path,
            "title": title,
            "provenance": provenance,
            "sha256_lf": hashlib.sha256(data).hexdigest(),
            "text": text,
        })

    add("NOTICE.md", "Sunder and upstream attribution", "Repository notice")
    add("LICENSE", "GNU Affero General Public License, version 3", "Root source-code license")
    evidence = json.loads((ROOT / "docs/fork/LICENSE_EVIDENCE.json").read_text(encoding="utf-8"))
    for source in evidence["sources"]:
        if source.get("file", "").endswith("-LICENSE.txt"):
            add(source["file"], source["identity"], source["source"] + " @ " + source["revision"])

    paths = (ROOT / "docs/dependencies/licences/haskell").rglob("*")
    for path in sorted(paths, key=lambda item: item.relative_to(ROOT).as_posix()):
        if path.is_file():
            relative = path.relative_to(ROOT).as_posix()
            add(relative, path.parent.name + " / " + path.name,
                "Historical Haskell report evidence; match against the actual native build before release")
    for relative in ["docs/dependencies/licences/apps/sqlcipher/LICENSE.md",
                     "docs/dependencies/licences/apps/webrtc/LICENSE"]:
        add(relative, Path(relative).parent.name, "Preserved upstream dependency notice")

    supplemental = json.loads((ROOT / "docs/fork/ios/SUPPLEMENTAL_EVIDENCE.json").read_text(encoding="utf-8"))
    for source in supplemental["empty_haskell_notice_recovery"]:
        if "file" in source:
            add(source["file"], source["package_version"] + " / recovered notice", source["url"])
    for source in supplemental["sources"]:
        if "libyaml-upstream-License" in source.get("file", ""):
            add(source["file"], "libyaml / supplemental upstream notice",
                source["url"] + " — exact Yams vendored revision remains to be matched")

    archive = json.loads((ROOT / "docs/fork/ios/WEBRTC_ARCHIVE_REVIEW.json").read_text(encoding="utf-8"))
    if archive.get("checksum_verified"):
        for notice in archive["notice_files"]:
            add(notice["file"], "WebRTC / notice inside the checksum-verified archive",
                archive["url"] + " / " + notice["archive_path"])

    configuration = plistlib.loads((ROOT / "apps/ios/SimpleX--iOS--Info.plist").read_bytes())
    repository = configuration["SunderRepositoryURL"]
    source_ref = configuration.get("SunderSourceRef", "main")
    if not repository.startswith("https://"):
        raise ValueError("SunderRepositoryURL must be a valid HTTPS repository destination")
    introduction = """Sunder — licenses and copyright notices

Independent client based on SimpleX Chat. Not endorsed by SimpleX Chat Ltd.
Original copyright and applicable license terms belong to their respective authors.

This development notice collection preserves available source and dependency notices.
It is deliberately broader than a verified list of components in a final IPA. Historical
Haskell report versions may differ from an eventual native build. Binary/source matching,
WebRTC third-party components, native library notices and remaining resource provenance
still need review. Inclusion here is not blanket permission for other artwork or binaries.

Graphics and trademarks have separate terms; see the preserved policies in the source.
The complete source corresponding to any distributed binary must be provided separately.
Configured source repository: {repository}
Configured source revision/ref: {source_ref}
Development repositories may require permission to access.

License texts follow. Original words are retained; line endings are normalized to LF.
""".format(repository=repository, source_ref=source_ref)
    sections = [introduction.strip()]
    for entry in entries:
        sections.append(entry["title"] + "\n\n" + entry["provenance"] + "\n\n" + entry["text"].strip())
    result = ("\n\f\n".join(sections) + "\n").encode("utf-8")
    record = {
        "scope": "Development notice collection, not a final IPA SBOM or publication clearance",
        "generator": "scripts/ios/generate-sunder-notices.py",
        "repository_url": repository,
        "source_ref": source_ref,
        "normalization": "Input and output content hashes use LF line endings",
        "output": OUTPUT.relative_to(ROOT).as_posix(),
        "output_sha256_lf": hashlib.sha256(result).hexdigest(),
        "inputs": [{key: value for key, value in entry.items() if key != "text"} for entry in entries],
    }
    return result, (json.dumps(record, indent=2, ensure_ascii=False) + "\n").encode("utf-8")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Verify checked-in generated content without writing")
    args = parser.parse_args()
    content, metadata = generate()
    if args.check:
        if canonical(OUTPUT.read_bytes()) != content or canonical(MANIFEST.read_bytes()) != metadata:
            raise SystemExit("Offline notices are stale; run this script without --check")
        print("Offline notice content and input hashes match.")
    else:
        OUTPUT.parent.mkdir(parents=True, exist_ok=True)
        MANIFEST.parent.mkdir(parents=True, exist_ok=True)
        OUTPUT.write_bytes(content)
        MANIFEST.write_bytes(metadata)
        print("Generated offline notices:", len(content), "bytes")
