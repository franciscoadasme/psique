"""PSIQUE: Protein Secondary Structure Identification on the basis of
Quaternions and Electronic structure calculations."""

from __future__ import annotations

import os
import platform
import subprocess
import sys
from pathlib import Path
from typing import Any

__version__ = "1.1.2"

__all__ = ["binary_path", "run"]


def binary_path() -> str:
    """Return the absolute path to the PSIQUE binary for the current platform."""
    name = "psique.exe" if platform.system() == "Windows" else "psique"
    path = Path(__file__).parent / "bin" / name
    if not path.exists():
        raise FileNotFoundError(
            f"PSIQUE binary not found at {path}. "
            f"This platform ({platform.system()} {platform.machine()}) "
            "may not be supported."
        )
    if platform.system() != "Windows" and not os.access(path, os.X_OK):
        path.chmod(path.stat().st_mode | 0o111)
    return str(path)


def run(*args: str, **kwargs: Any) -> subprocess.CompletedProcess[bytes]:
    """Run PSIQUE with the given arguments.

    Accepts the same keyword arguments as subprocess.run().
    """
    return subprocess.run([binary_path(), *args], **kwargs)


def _cli_entry() -> None:
    result = subprocess.run([binary_path(), *sys.argv[1:]])
    raise SystemExit(result.returncode)
