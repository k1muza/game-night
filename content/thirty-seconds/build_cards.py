#!/usr/bin/env python3
"""Sprint build launcher. Node.js >=18 required; no external packages."""
from pathlib import Path
import subprocess
if __name__ == "__main__":
    raise SystemExit(subprocess.call(["node", str(Path(__file__).with_name("sprint_core.cjs")), "build"]))
