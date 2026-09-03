#!/usr/bin/env python3
"""Enforce full line coverage for GameCore's essential business logic."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

ESSENTIAL_FILES = (
    "Sources/GameCore/WinnerSelecting.swift",
    "Sources/GameCore/GameSession.swift",
)
REQUIRED_COVERAGE = 1.0


def load_coverage(package_path: Path) -> dict:
    if not package_path.is_dir():
        raise RuntimeError(
            f"Package not found at {package_path}. Run `make core-test` first."
        )

    test_binaries = tuple(
        package_path.glob(
            ".build/*/debug/GameCorePackageTests.xctest/Contents/MacOS/GameCorePackageTests"
        )
    )
    profiles = tuple(package_path.glob(".build/*/debug/codecov/default.profdata"))
    if len(test_binaries) != 1 or len(profiles) != 1:
        raise RuntimeError("Coverage artifacts not found. Run `make core-test` first.")

    process = subprocess.run(
        [
            "xcrun",
            "llvm-cov",
            "export",
            str(test_binaries[0]),
            "-instr-profile",
            str(profiles[0]),
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(process.stdout)


def source_coverage(report: dict) -> dict[str, float]:
    return {
        file["filename"]: float(file["summary"]["lines"]["percent"]) / 100
        for data in report.get("data", [])
        for file in data.get("files", [])
    }


def coverage_for_suffix(coverage: dict[str, float], suffix: str) -> float:
    matches = [value for path, value in coverage.items() if path.endswith(suffix)]
    if len(matches) != 1:
        raise RuntimeError(
            f"Expected exactly one coverage entry ending in {suffix!r}, found {len(matches)}."
        )
    return matches[0]


def main() -> int:
    if len(sys.argv) != 2:
        print(f"Usage: {Path(sys.argv[0]).name} <GameCore package path>", file=sys.stderr)
        return 2

    try:
        coverage = source_coverage(load_coverage(Path(sys.argv[1])))
        failures: list[str] = []

        for source_file in ESSENTIAL_FILES:
            measured = coverage_for_suffix(coverage, source_file)
            percentage = measured * 100
            print(f"{source_file}: {percentage:.2f}%")
            if measured + sys.float_info.epsilon < REQUIRED_COVERAGE:
                failures.append(f"{source_file}: {percentage:.2f}%")

        if failures:
            print("Essential coverage must remain at 100%:", file=sys.stderr)
            for failure in failures:
                print(f"- {failure}", file=sys.stderr)
            return 1

        print("Essential GameCore coverage: 100%")
        return 0
    except (RuntimeError, subprocess.CalledProcessError, json.JSONDecodeError) as error:
        print(f"Coverage check failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
