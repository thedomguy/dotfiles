#!/usr/bin/env python3
"""Offer and restore the saved AeroSpace workspace snapshot at login."""

from __future__ import annotations

import json
import fcntl
import logging
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path
from typing import Any


SCRIPT_DIR = Path(__file__).resolve().parent
STATE_DIR = Path.home() / ".local/state/aerospace"
HOLD_PATH = STATE_DIR / "restore-pending"
PROFILE_PATH = STATE_DIR / "session-snapshot.json"
LOG_PATH = Path.home() / "Library/Logs/AeroSpace/session-restore.log"
LOCK_PATH = Path.home() / "Library/Logs/AeroSpace/session-restore.lock"
AEROSPACE = shutil.which("aerospace") or str(Path.home() / ".local/bin/aerospace")
OPEN = "/usr/bin/open"
OSASCRIPT = "/usr/bin/osascript"
SWIFT = "/usr/bin/swift"
WINDOW_FORMAT = (
    "%{window-id} %{app-name} %{app-bundle-id} %{window-title} "
    "%{workspace} %{window-layout} %{workspace-root-container-layout}"
)


def setup_logging() -> None:
    LOG_PATH.parent.mkdir(parents=True, exist_ok=True)
    logging.basicConfig(
        filename=LOG_PATH,
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
    )


def load_profile() -> dict[str, Any]:
    with PROFILE_PATH.open(encoding="utf-8") as source:
        return json.load(source)


def run_aerospace(*arguments: str) -> str:
    result = subprocess.run(
        [AEROSPACE, *arguments],
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        detail = result.stderr.strip() or result.stdout.strip()
        raise RuntimeError(f"aerospace {' '.join(arguments)} failed: {detail}")
    return result.stdout.strip()


def list_windows() -> list[dict[str, Any]]:
    output = run_aerospace("list-windows", "--all", "--json", "--format", WINDOW_FORMAT)
    return json.loads(output)


def title_matches(pattern: str, title: str) -> bool:
    return re.search(pattern, title, flags=re.IGNORECASE) is not None


def resolve_targets(
    profile: dict[str, Any], windows: list[dict[str, Any]]
) -> tuple[list[dict[str, Any]], list[str]]:
    """Match saved windows to live ones: exact title first, then by app in saved order."""
    entries = [
        (workspace, target)
        for workspace in profile["workspaces"]
        for target in workspace["windows"]
    ]
    chosen: dict[int, dict[str, Any]] = {}
    used_ids: set[int] = set()

    def free(bundle_id: str) -> list[dict[str, Any]]:
        return [
            window
            for window in windows
            if window["app-bundle-id"] == bundle_id
            and int(window["window-id"]) not in used_ids
        ]

    def claim(index: int, window: dict[str, Any]) -> None:
        chosen[index] = window
        used_ids.add(int(window["window-id"]))

    for index, (_, target) in enumerate(entries):
        candidates = free(target["bundleId"])
        if "title" in target:
            matches = [w for w in candidates if w["window-title"] == target["title"]]
        else:
            matches = [
                w for w in candidates if title_matches(target["titleRegex"], w["window-title"])
            ]
            if not matches and target.get("fallbackTitleNotRegex"):
                excluded = target["fallbackTitleNotRegex"]
                matches = [w for w in candidates if not title_matches(excluded, w["window-title"])]
            if len(matches) != 1:
                matches = []
        if matches:
            claim(index, matches[0])

    for index, (_, target) in enumerate(entries):
        if index in chosen or "title" not in target:
            continue
        candidates = free(target["bundleId"])
        if candidates:
            claim(index, candidates[0])

    resolved: list[dict[str, Any]] = []
    missing: list[str] = []
    for index, (workspace, target) in enumerate(entries):
        window = chosen.get(index)
        if window is None:
            missing.append(target["label"])
            continue
        resolved.append(
            {
                **target,
                "windowId": str(window["window-id"]),
                "originalWorkspace": str(window["workspace"]),
                "targetWorkspace": str(workspace["name"]),
            }
        )
    return resolved, missing


def launch_missing_apps(
    profile: dict[str, Any], windows: list[dict[str, Any]], attempted: set[str]
) -> None:
    running_bundles = {window["app-bundle-id"] for window in windows}
    needed_bundles = {
        target["bundleId"]
        for workspace in profile["workspaces"]
        for target in workspace["windows"]
        if target["bundleId"] not in running_bundles
        and target["bundleId"] not in attempted
    }
    for bundle_id in sorted(needed_bundles):
        attempted.add(bundle_id)
        logging.info("Opening app %s", bundle_id)
        subprocess.run([OPEN, "-b", bundle_id], check=False, capture_output=True, text=True)


def wait_for_targets(
    profile: dict[str, Any], timeout_seconds: int = 90
) -> tuple[list[dict[str, Any]], list[str]]:
    deadline = time.monotonic() + timeout_seconds
    last_windows: list[dict[str, Any]] = []
    attempted_launches: set[str] = set()
    while True:
        last_windows = list_windows()
        resolved, missing = resolve_targets(profile, last_windows)
        if not missing:
            return resolved, []

        launch_missing_apps(profile, last_windows, attempted_launches)
        if time.monotonic() >= deadline:
            return resolved, missing
        time.sleep(2)


def display_dialog(message: str, *, alert: bool = False) -> str:
    if alert:
        script = (
            'on run argv\n'
            'display dialog (item 1 of argv) with title "AeroSpace Snapshot Restore" '
            'buttons {"OK"} default button "OK"\n'
            'end run'
        )
        args = [OSASCRIPT, "-e", script, message]
    else:
        script = (
            'on run argv\n'
            'set result to display dialog (item 1 of argv) '
            'with title "AeroSpace Snapshot Restore" '
            'buttons {"Skip", "Restore"} default button "Restore" cancel button "Skip"\n'
            'return button returned of result\n'
            'end run'
        )
        args = [OSASCRIPT, "-e", script, message]
    result = subprocess.run(args, check=False, capture_output=True, text=True)
    if result.returncode != 0:
        logging.info("Dialog dismissed or unavailable: %s", result.stderr.strip())
        return "Skip"
    return result.stdout.strip().split(":")[-1].strip()


def current_display_width(fallback: int) -> int:
    source = (
        'import CoreGraphics; '
        'let bounds = CGDisplayBounds(CGMainDisplayID()); '
        'print(Int(bounds.width))'
    )
    result = subprocess.run(
        [SWIFT, "-e", source], check=False, capture_output=True, text=True, timeout=20
    )
    if result.returncode == 0:
        try:
            return int(result.stdout.strip().splitlines()[-1])
        except (ValueError, IndexError):
            pass
    logging.warning("Could not read display width; using saved width %s", fallback)
    return fallback


def resize_workspace(
    profile: dict[str, Any], workspace: dict[str, Any], targets: list[dict[str, Any]]
) -> None:
    windows = [w for w in workspace["windows"] if not w.get("floating")]
    if len(windows) < 2 or "accordion" in workspace["rootLayout"]:
        return

    display_width = current_display_width(int(profile["monitorWidth"]))
    available_tiles = (
        display_width
        - int(profile["outerLeft"])
        - int(profile["outerRight"])
        - int(profile["innerGap"]) * (len(windows) - 1)
    )
    by_label = {target["label"]: target for target in targets}

    # AeroSpace's absolute resize value is the target width in points. Setting
    # each tile except the last leaves the final tile the remaining width.
    for window in windows[:-1]:
        target = by_label[window["label"]]
        width = round(available_tiles * float(window["tileWidthShare"]))
        run_aerospace(
            "resize",
            "--window-id",
            target["windowId"],
            "width",
            str(width),
        )


def restore(profile: dict[str, Any]) -> None:
    targets, missing = wait_for_targets(profile)
    if missing:
        detail = "Could not identify these saved windows:\n\n" + "\n".join(
            f"• {label}" for label in missing
        )
        logging.error(detail)
        HOLD_PATH.parent.mkdir(parents=True, exist_ok=True)
        HOLD_PATH.touch()
        display_dialog(
            detail
            + "\n\nNo windows were moved. Open the saved windows and use Alt-Shift-R to try again.",
            alert=True,
        )
        return

    stage = f"codex-restore-stage-{os.getpid()}"
    originals = {target["windowId"]: target["originalWorkspace"] for target in targets}
    try:
        for target in targets:
            run_aerospace(
                "move-node-to-workspace",
                "--window-id",
                target["windowId"],
                stage,
            )

        for workspace in profile["workspaces"]:
            for saved_window in workspace["windows"]:
                target = next(item for item in targets if item["label"] == saved_window["label"])
                run_aerospace(
                    "move-node-to-workspace",
                    "--window-id",
                    target["windowId"],
                    str(workspace["name"]),
                )

        for workspace in profile["workspaces"]:
            name = str(workspace["name"])
            workspace_targets = [
                target for target in targets if target["targetWorkspace"] == name
            ]
            for target in workspace_targets:
                if target.get("floating"):
                    run_aerospace("layout", "--window-id", target["windowId"], "floating")
            tiled = [t for t in workspace_targets if not t.get("floating")]
            for target in tiled:
                run_aerospace("layout", "--window-id", target["windowId"], "tiling")
            if tiled:
                # Changes the layout of the container holding the tiled windows.
                run_aerospace(
                    "layout", "--window-id", tiled[0]["windowId"], workspace["rootLayout"]
                )
            resize_workspace(profile, workspace, workspace_targets)

        run_aerospace("workspace", str(profile["focusedWorkspace"]))
        HOLD_PATH.unlink(missing_ok=True)
        logging.info("Restored profile %s", profile["name"])
        subprocess.run(
            [
                OSASCRIPT,
                "-e",
                'display notification "Saved workspaces and split sizes restored." '
                'with title "AeroSpace Snapshot Restore"',
            ],
            check=False,
            capture_output=True,
            text=True,
        )
    except Exception:
        logging.exception("Restore failed; returning staged windows to their prior workspaces")
        for window_id, workspace_name in originals.items():
            try:
                if any(
                    int(item["window-id"]) == int(window_id)
                    and str(item["workspace"]) == stage
                    for item in list_windows()
                ):
                    run_aerospace(
                        "move-node-to-workspace",
                        "--window-id",
                        window_id,
                        workspace_name,
                    )
            except Exception:
                logging.exception("Could not recover window %s", window_id)
        HOLD_PATH.parent.mkdir(parents=True, exist_ok=True)
        HOLD_PATH.touch()
        display_dialog(
            "The snapshot restore did not finish. Any staged windows were returned to their previous workspaces. See the AeroSpace restore log for details.",
            alert=True,
        )


SWIFT_BOUNDS = (
    "import CoreGraphics; import Foundation; "
    "var out: [String: Any] = [\"windows\": [:], \"width\": Int(CGDisplayBounds(CGMainDisplayID()).width)]; "
    "var wins: [String: Double] = [:]; "
    "for w in (CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String: Any]]) ?? [] { "
    "if let n = w[\"kCGWindowNumber\"] as? Int, let b = w[\"kCGWindowBounds\"] as? [String: Double], "
    "let x = b[\"X\"], let wd = b[\"Width\"] { wins[\"\\(n)\"] = x; wins[\"\\(n)w\"] = wd } }; "
    "out[\"windows\"] = wins; "
    "print(String(data: try! JSONSerialization.data(withJSONObject: out), encoding: .utf8)!)"
)


def save() -> None:
    """Write the live layout to PROFILE_PATH. Skips when AeroSpace has no tiled windows."""
    windows = list_windows()
    if not any(w["window-layout"] != "floating" for w in windows):
        logging.info("Save skipped: no tiled windows")
        return
    if HOLD_PATH.exists():
        logging.info("Save skipped: restore did not complete; press Alt-Shift-R or skip")
        return

    result = subprocess.run(
        [SWIFT, "-e", SWIFT_BOUNDS], check=False, capture_output=True, text=True, timeout=60
    )
    if result.returncode != 0:
        raise RuntimeError(f"Could not read window bounds: {result.stderr.strip()}")
    bounds = json.loads(result.stdout.strip().splitlines()[-1])
    positions = bounds["windows"]

    previous: dict[str, Any] = {}
    if PROFILE_PATH.exists():
        previous = load_profile()

    grouped: dict[str, list[dict[str, Any]]] = {}
    for window in windows:
        grouped.setdefault(str(window["workspace"]), []).append(window)

    workspaces = []
    for name in sorted(grouped, key=lambda item: (not item.isdigit(), int(item) if item.isdigit() else 0, item)):
        members = sorted(
            grouped[name], key=lambda w: positions.get(str(w["window-id"]), 0.0)
        )
        tiled = [w for w in members if w["window-layout"] != "floating"]
        widths = [positions.get(f"{w['window-id']}w", 0.0) for w in members]
        total = sum(
            width for w, width in zip(members, widths) if w["window-layout"] != "floating"
        ) or float(len(tiled) or 1)
        root = (tiled or members)[0]["workspace-root-container-layout"]
        workspaces.append(
            {
                "name": name,
                "rootLayout": root,
                "windows": [
                    {
                        "label": f"{w['app-name']}: {w['window-title'][:60]}",
                        "bundleId": w["app-bundle-id"],
                        "title": w["window-title"],
                        "floating": w["window-layout"] == "floating",
                        "tileWidthShare": round((width or total / len(tiled or [0])) / total, 6),
                    }
                    for w, width in zip(members, widths)
                ],
            }
        )

    focused = run_aerospace("list-workspaces", "--focused")
    profile = {
        "version": 2,
        "name": "auto-saved snapshot",
        "capturedAt": time.strftime("%Y-%m-%d %H:%M"),
        "monitorWidth": int(bounds["width"]),
        "outerLeft": previous.get("outerLeft", 10),
        "outerRight": previous.get("outerRight", 10),
        "innerGap": previous.get("innerGap", 10),
        "focusedWorkspace": focused,
        "workspaces": workspaces,
    }

    comparable = {k: v for k, v in profile.items() if k != "capturedAt"}
    if comparable == {k: v for k, v in previous.items() if k != "capturedAt"}:
        return

    PROFILE_PATH.parent.mkdir(parents=True, exist_ok=True)
    temporary = PROFILE_PATH.with_suffix(".tmp")
    temporary.write_text(json.dumps(profile, indent=2) + "\n", encoding="utf-8")
    temporary.replace(PROFILE_PATH)
    logging.info("Saved snapshot: %d windows", len(windows))


def prompt() -> None:
    logging.info("Prompt requested")
    profile = load_profile()
    lines = [
        f"Workspace {workspace['name']}: "
        + ", ".join(window["label"] for window in workspace["windows"])
        for workspace in profile["workspaces"]
    ]
    message = (
        f"Restore the saved AeroSpace snapshot ({profile.get('capturedAt', 'unknown date')})?\n\n"
        + "\n".join(lines)
        + "\n\nRestore will reopen missing apps, return the matched windows to these "
        "workspaces, and reapply the saved split sizes."
    )
    choice = display_dialog(message)
    if choice == "Restore":
        restore(profile)
    else:
        HOLD_PATH.unlink(missing_ok=True)
        logging.info("User skipped profile %s", profile["name"])


def main() -> int:
    setup_logging()
    LOCK_PATH.parent.mkdir(parents=True, exist_ok=True)
    lock_file = LOCK_PATH.open("w", encoding="utf-8")
    try:
        fcntl.flock(lock_file, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        logging.info("Ignoring duplicate restore invocation")
        return 0

    action = sys.argv[1] if len(sys.argv) > 1 else "prompt"
    try:
        if action == "prompt":
            prompt()
        elif action == "save":
            save()
        elif action == "restore":
            restore(load_profile())
        else:
            print(f"Usage: {Path(sys.argv[0]).name} [prompt|restore|save]", file=sys.stderr)
            return 2
    except Exception as error:
        logging.exception("AeroSpace snapshot restore error")
        print(f"AeroSpace snapshot restore error: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
