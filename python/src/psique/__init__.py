"""PSIQUE: Protein Secondary Structure Identification on the basis of
Quaternions and Electronic structure calculations."""

from __future__ import annotations

import json
import os
import platform
import subprocess
import sys
from dataclasses import dataclass
from enum import Enum, unique
from pathlib import Path

__version__ = "1.1.2"

__all__ = ["binary_path", "run"]


@unique
class SecondaryStructureKind(Enum):
    """The kind of secondary structure."""

    BETA_STRAND = "E"
    HELIX_3_10 = "G"
    HELIX_ALPHA = "H"
    HELIX_GAMMA = "F"
    HELIX_PI = "I"
    LEFT_HELIX_3_10 = "g"
    LEFT_HELIX_ALPHA = "h"
    LEFT_HELIX_GAMMA = "f"
    LEFT_HELIX_PI = "i"
    NONE = "0"
    POLYPROLINE = "P"

    def __str__(self) -> str:
        return self.name


@dataclass
class ResidueId:
    """The ID of a residue."""

    chain: str
    name: str
    insertion: str
    number: int

    @classmethod
    def from_json(cls, data: dict) -> ResidueId:
        return cls(
            chain=data["chain"],
            name=data["name"],
            insertion=data["insertion"],
            number=data["number"],
        )


@dataclass
class SecondaryStructure:
    """A secondary structure segment."""

    start: ResidueId
    end: ResidueId
    kind: SecondaryStructureKind

    @classmethod
    def from_json(cls, data: dict) -> SecondaryStructure:
        return cls(
            start=ResidueId.from_json(data["start"]),
            end=ResidueId.from_json(data["end"]),
            kind=SecondaryStructureKind(data["sec"]),
        )


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


def assign(path: str | Path) -> list[SecondaryStructure]:
    """Assign the secondary structure of a protein structure using PSIQUE."""
    output = subprocess.check_output([binary_path(), "--format", "json", str(path)])
    return [
        SecondaryStructure.from_json(ss)
        for ss in json.loads(output)["secondary_structures"]
    ]


def _cli_entry() -> None:
    result = subprocess.run([binary_path(), *sys.argv[1:]])
    raise SystemExit(result.returncode)
