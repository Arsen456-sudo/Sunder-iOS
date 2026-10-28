#!/usr/bin/env python3
"""Export a committed, iOS-focused source tree without private history or old media.

Never overwrites an existing directory, initializes Git, pushes, or changes visibility.
This source snapshot is not a compiled/cleared binary release.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[2]
MEDIA = {".png", ".jpg", ".jpeg", ".svg", ".gif", ".webp", ".pdf", ".mp3", ".m4a",
         ".wav", ".ogg", ".caf", ".aiff", ".ttf", ".otf", ".ttc", ".woff", ".woff2",
         ".ico", ".icns", ".mp4", ".mov", ".zip", ".gz", ".xz", ".ipa", ".a", ".so", ".dylib",
         ".o", ".dll", ".exe", ".jar", ".aar", ".class", ".wasm", ".7z", ".p12", ".p8", ".mobileprovision",
         ".db", ".sqlite", ".sqlite3", ".db3", ".log", ".ips", ".crash",
         ".apk", ".aab", ".dmg", ".deb", ".rpm", ".msi", ".pkg", ".appx", ".msix",
         ".webm", ".heic", ".heif", ".avif", ".tif", ".tiff", ".bmp", ".aac", ".flac", ".opus"}
OMIT = ("apps/multiplatform/", "website/", "blog/", "media-logos/", "images/", "fastlane/",
        "tests/", "packages/", ".codex/", ".codex-remote-attachments/")
SECRET_MARKERS = [
    re.compile(rb"-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----"),
    re.compile(rb"\b(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,})\b"),
    re.compile(rb"\b(?:AKIA|ASIA)[A-Z0-9]{16}\b"),
    re.compile(rb"\bxox[baprs]-[A-Za-z0-9-]{20,}\b"),
    re.compile(rb"\bAIza[A-Za-z0-9_-]{35}\b"),
]


def export(destination):
    destination = destination.resolve()
    if destination == ROOT or destination.is_relative_to(ROOT) or destination.exists():
        raise SystemExit("Choose a new, nonexistent directory outside the private checkout.")
    revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    safe_media = {}
    def committed_json(path):
        return json.loads(subprocess.check_output(["git", "show", revision + ":" + path], cwd=ROOT))

    logos = committed_json("docs/fork/LOGO_REMOVAL.json")
    for change in logos["changes"]:
        if change["path"].startswith("apps/ios/") and change.get("replacement_sha256"):
            safe_media[change["path"]] = change["replacement_sha256"]
    sounds = committed_json("docs/fork/ios/SYNTHESIZED_SOUNDS.json")
    for sound in sounds["files"]:
        safe_media[sound["path"]] = sound["sha256"]
    records = []
    excluded = []
    destination.mkdir(parents=True)
    incomplete = destination / "INCOMPLETE_EXPORT"
    incomplete.write_text("Do not publish: source export has not completed.\n", encoding="utf-8")
    process = subprocess.Popen(["git", "-c", "core.autocrlf=false", "archive", "--format=tar", revision], cwd=ROOT, stdout=subprocess.PIPE)
    try:
        with tarfile.open(fileobj=process.stdout, mode="r|") as archive:
            for member in archive:
                if member.isdir():
                    continue
                relative = Path(member.name)
                target = (destination / relative).resolve()
                if relative.is_absolute() or ".." in relative.parts or not target.is_relative_to(destination):
                    raise ValueError("Unsafe archive path")
                name = relative.as_posix()
                reason = None
                if name.startswith(OMIT) or (name.startswith("apps/") and not name.startswith("apps/ios/")):
                    reason = "Non-iOS frontend/SDK, historical media/test fixture suite, or local tooling"
                elif name == ".gitmodules":
                    reason = "Submodule configuration belongs to the omitted Android frontend"
                elif not member.isfile():
                    reason = "Non-regular Git entry is not materialized in this snapshot"
                elif any(part.endswith((".framework", ".xcframework", ".app", ".bundle")) for part in relative.parts):
                    reason = "Compiled platform bundle is not source"
                elif relative.suffix.lower() in MEDIA and name not in safe_media:
                    reason = "Unreviewed/prebuilt media is not part of this iOS source snapshot"
                if reason:
                    excluded.append({"path": name, "reason": reason})
                    continue
                data = archive.extractfile(member).read()
                if relative.suffix.lower() in MEDIA:
                    if hashlib.sha256(data).hexdigest() != safe_media[name]:
                        raise ValueError("Approved media hash mismatch: " + name)
                elif b"\0" not in data[:8192] and any(marker.search(data) for marker in SECRET_MARKERS):
                    raise ValueError("Credential/private-key marker requires review before export: " + name)
                transformed = False
                if name == "README.md":
                    data = ("# Sunder iOS source\n\n"
                            "Independent client based on [SimpleX Chat](https://github.com/simplex-chat/simplex-chat),\n"
                            "without affiliation or endorsement by SimpleX Chat Ltd. Original authors' rights\n"
                            "and notices remain in [LICENSE](LICENSE) and [NOTICE.md](NOTICE.md).\n\n"
                            "This is an iOS-focused source snapshot. See [SOURCE_SNAPSHOT.md](SOURCE_SNAPSHOT.md)\n"
                            "for scope and [SOURCE_EXPORT.json](SOURCE_EXPORT.json) for source revision, hashes\n"
                            "and omissions. Android/Desktop, web/SDK clients, historical promotional material\n"
                            "and the upstream test/fixture suite remain outside this focused snapshot.\n\n"
                            "The iOS app uses native symbols, a neutral procedural preset texture, temporary\n"
                            "plain icon slots and original synthesized call cues. Custom user media support remains.\n"
                            "Read [iOS development instructions](apps/ios/README.md) and [dependency evidence](docs/fork/ios/README.md).\n\n"
                            "No compiled IPA or working-build guarantee is included. Own signing/Keychain/App Groups,\n"
                            "native-library provenance, complete binary notices and device checks remain binary-release\n"
                            "requirements. Set SunderRepositoryURL and SunderSourceRef in the iOS Info.plist and regenerate notices\n"
                            "before distributing a binary. Original operator conditions remain in [PRIVACY.md](PRIVACY.md).\n").encode("utf-8")
                    transformed = True
                if name == ".github/ISSUE_TEMPLATE/config.yml":
                    data = b"blank_issues_enabled: true\n"
                    transformed = True
                # Preserve license texts; remove rendered illustration embeds from ordinary docs.
                if relative.suffix.lower() == ".md" and not any(word in relative.name.lower() for word in ["license", "licence", "copying", "notice"]):
                    original = data.decode("utf-8")
                    text = re.sub(r'!\[[^\]]*\]\([^\n]*?\)', '[Illustration omitted in this iOS source snapshot.]', original)
                    text = re.sub(r'<img\b[^>]*>', '[Illustration omitted in this iOS source snapshot.]', text, flags=re.I)
                    if text != original:
                        text += "\n\nSnapshot modification: illustration embeds omitted by Sunder source export.\n"
                        data = text.encode("utf-8")
                        transformed = True
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(data)
                if member.mode & 0o111:
                    target.chmod(target.stat().st_mode | 0o111)
                records.append({"path": name, "sha256": hashlib.sha256(data).hexdigest(),
                                "git_mode": "100755" if member.mode & 0o111 else "100644",
                                "documentation_modified": transformed})
        # Tar iteration stops at its end marker; drain padding so Git can close a Windows pipe.
        while process.stdout.read(65536):
            pass
        if process.wait() != 0:
            raise RuntimeError("git archive failed")
    finally:
        if process.poll() is None:
            process.terminate()
    manifest = {"source_revision": revision, "scope": "iOS-focused source snapshot; no binary release or legal certification",
                "private_history_exported": False, "git_initialized": False, "files": records, "excluded": excluded}
    (destination / "SOURCE_EXPORT.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8", newline="\n")
    (destination / "SOURCE_SNAPSHOT.md").write_text(
        "# Sunder iOS source snapshot\n\nPrepared from private preparation commit `" + revision + "`.\n"
        "This directory contains no .git history, ignored local files or downloaded native binaries.\n"
        "Original code copyright/license texts remain; SOURCE_EXPORT.json records omissions and doc edits.\n"
        "Non-iOS apps/services, web/SDK clients, historical website/blog/promotional material and the upstream\n"
        "test fixture suite are omitted. They remain in the private source; test targets are not supported\n"
        "by this focused export. Runtime Haskell/iOS source and platform build inputs are retained.\n"
        "The retained build/source tree targets iOS; unrelated frontend builds are not supported here.\n"
        "Private source/support links still need a final public repository destination.\n"
        "A native build, own signing/keychain configuration, exact native-library provenance, full\n"
        "third-party binary notices and device checks remain prerequisites for distributing an IPA.\n"
        "This snapshot is prepared for review; it does not change repository visibility or guarantee\n"
        "that every remaining source-license/service question is resolved.\n\n"
        "SOURCE_EXPORT.json records original Git executable modes. When initializing a new Git repo\n"
        "on Windows, run git add first, then restore 100755 entries using git update-index --chmod=+x\n"
        "before committing. Do not copy .git metadata from the old private checkout.\n",
        encoding="utf-8", newline="\n")
    incomplete.unlink()
    print(json.dumps({"directory": str(destination), "revision": revision, "files": len(records), "excluded": len(excluded)}))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("destination", type=Path)
    export(parser.parse_args().destination)
