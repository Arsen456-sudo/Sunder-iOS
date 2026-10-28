#!/usr/bin/env python3
"""Generate original neutral PCM call cues for Sunder, without sampled audio.

New code and generated cues: Copyright 2026 repository contributors, AGPL-3.0-only.
"""
import hashlib
import io
import json
import math
from pathlib import Path
import struct
import wave

ROOT = Path(__file__).resolve().parents[2]
RATE = 22050


def cue(duration, intervals):
    samples = []
    for index in range(round(duration * RATE)):
        time = index / RATE
        value = 0.0
        for start, end, frequency in intervals:
            if start <= time < end:
                fade = min((time - start) / 0.025, (end - time) / 0.025, 1.0)
                value += 0.14 * fade * math.sin(2 * math.pi * frequency * time)
        samples.append(struct.pack("<h", round(max(-1, min(1, value)) * 32767)))
    result = io.BytesIO()
    with wave.open(result, "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(RATE)
        output.writeframes(b"".join(samples))
    return result.getvalue()


if __name__ == "__main__":
    definitions = {
        "connecting_call": (1.6, [(0.0, 0.4, 440), (0.55, 0.95, 440)]),
        "in_call": (0.25, [(0.0, 0.2, 523.25)]),
        "ringtone2": (2.4, [(0.0, 0.3, 440), (0.35, 0.65, 554.37),
                            (0.8, 1.1, 440), (1.15, 1.45, 554.37)]),
    }
    records = []
    for name, (duration, intervals) in definitions.items():
        data = cue(duration, intervals)
        path = ROOT / "apps/ios/sounds" / (name + ".wav")
        path.write_bytes(data)
        records.append({"path": path.relative_to(ROOT).as_posix(), "sha256": hashlib.sha256(data).hexdigest(),
                        "sample_rate": RATE, "seconds": duration, "origin": "New mathematical sine cues; no sampled upstream audio"})
    target = ROOT / "docs/fork/ios/SYNTHESIZED_SOUNDS.json"
    target.write_text(json.dumps({"license": "AGPL-3.0-only", "generator": "scripts/ios/generate-sunder-sounds.py", "files": records}, indent=2) + "\n", encoding="utf-8", newline="\n")
    print("Generated three original PCM call cues.")
