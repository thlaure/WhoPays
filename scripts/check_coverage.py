#!/usr/bin/env python3
"""Enforce full line coverage for WhoPays' essential business logic."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

ESSENTIAL_FILES = (
    "WhoPays/Domain/WinnerSelecting.swift",
    "WhoPays/Presentation/GameSession.swift",
)
REQUIRED_COVERAGE = 1.0


def load_coverage(result_bundle: Path) -> dict:
    if not result_bundle.exists():
        raise RuntimeError(
            f"Result bundle not found at {result_bundle}. Run `make test` first."
        )

    process = subprocess.run(
        ["xcrun", "xccov", "view", "--report", "--json", str(result_bundle)],
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(process.stdout)


def app_source_coverage(report: dict) -> dict[str, float]:
    for target in report.get("targets", []):
        if target.get("name") == "WhoPays.app":
            return {
                file["path"]: float(file["lineCoverage"])
                for file in target.get("files", [])
            }

    raise RuntimeError("Coverage report does not contain the WhoPays.app target.")


def coverage_for_suffix(coverage: dict[str, float], suffix: str) -> float:
    matches = [value for path, value in coverage.items() if path.endswith(suffix)]
    if len(matches) != 1:
        raise RuntimeError(
            f"Expected exactly one coverage entry ending in {suffix!r}, found {len(matches)}."
        )
    return matches[0]


def main() -> int:
    if len(sys.argv) != 2:
        print(f"Usage: {Path(sys.argv[0]).name} <TestResults.xcresult>", file=sys.stderr)
        return 2

    try:
        coverage = app_source_coverage(load_coverage(Path(sys.argv[1])))
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

        print("Essential business logic coverage: 100%")
        return 0
    except (RuntimeError, subprocess.CalledProcessError, json.JSONDecodeError) as error:
        print(f"Coverage check failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
