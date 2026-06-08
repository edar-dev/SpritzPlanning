#!/usr/bin/env python3
"""Remove ARB keys not referenced in lib/ or test/. Run from repo root."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCAN_DIRS = [ROOT / "lib", ROOT / "test"]
ARB_FILES = [ROOT / "lib" / "l10n" / "app_it.arb", ROOT / "lib" / "l10n" / "app_en.arb"]

# l10n.key or context.l10n.key — getter or method with placeholders
L10N_RE = re.compile(r"(?:\bl10n|context\.l10n)\??\.([A-Za-z0-9_]+)")


def collect_used_keys() -> set[str]:
    used: set[str] = set()
    for base in SCAN_DIRS:
        if not base.exists():
            continue
        for path in base.rglob("*.dart"):
            text = path.read_text(encoding="utf-8")
            for match in L10N_RE.finditer(text):
                used.add(match.group(1))
    return used


def prune_arb(path: Path, used: set[str]) -> tuple[int, int]:
    data = json.loads(path.read_text(encoding="utf-8"))
    locale = data.get("@@locale")
    before = len([k for k in data if not k.startswith("@")])
    pruned: dict = {}
    if locale is not None:
        pruned["@@locale"] = locale
    for key, value in data.items():
        if key.startswith("@@"):
            continue
        if key.startswith("@"):
            meta_key = key[1:]
            if meta_key in used:
                pruned[key] = value
            continue
        if key in used:
            pruned[key] = value
    after = len([k for k in pruned if not k.startswith("@")])
    path.write_text(
        json.dumps(pruned, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    return before, after


def main() -> int:
    used = collect_used_keys()
    print(f"Used keys: {len(used)}")
    for arb in ARB_FILES:
        before, after = prune_arb(arb, used)
        print(f"{arb.name}: {before} -> {after} keys (-{before - after})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
