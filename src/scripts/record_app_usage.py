#!/usr/bin/env python3
import json
import os
import sys
import tempfile

CACHE_DIR = os.path.expanduser("~/.cache/brain-desktop")
USAGE_FILE = os.path.join(CACHE_DIR, "app_usage.json")


def main():
    if len(sys.argv) < 2:
        return

    name = sys.argv[1].strip()
    if not name:
        return

    os.makedirs(CACHE_DIR, exist_ok=True)

    try:
        with open(USAGE_FILE, "r", encoding="utf-8") as f:
            usage = json.load(f)
        if not isinstance(usage, dict):
            usage = {}
    except (OSError, ValueError, TypeError):
        usage = {}

    usage[name] = int(usage.get(name, 0)) + 1

    fd, tmp = tempfile.mkstemp(prefix="app_usage.", dir=CACHE_DIR, text=True)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump(usage, f, ensure_ascii=False, sort_keys=True)
            f.write("\n")
        os.replace(tmp, USAGE_FILE)
    finally:
        try:
            os.unlink(tmp)
        except FileNotFoundError:
            pass


if __name__ == "__main__":
    main()
