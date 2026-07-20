"""
wt - Git worktree helper

Usage:
  wt create <branch>   Create a new worktree for the given branch
  wt list              List all worktrees
  wt remove <branch>   Remove a worktree
"""

import argparse
import json
import subprocess
import shutil
import sys
from pathlib import Path


def run(cmd: list[str], cwd: Path | None = None, check: bool = True) -> subprocess.CompletedProcess:
    print(f"  → {' '.join(cmd)}")
    return subprocess.run(cmd, cwd=cwd, check=check)


def get_repo_name() -> str:
    result = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        capture_output=True, text=True, check=True
    )
    return Path(result.stdout.strip()).name


def get_repo_root() -> Path:
    result = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        capture_output=True, text=True, check=True
    )
    return Path(result.stdout.strip())


def worktree_base(repo_name: str) -> Path:
    return Path.home() / ".worktrees" / repo_name


def create(branch: str, base_branch: str | None = None):
    repo_name = get_repo_name()
    repo_root = get_repo_root()
    target = worktree_base(repo_name) / branch

    if target.exists():
        print(f"✗ Worktree already exists at {target}")
        sys.exit(1)

    target.parent.mkdir(parents=True, exist_ok=True)

    # Check if branch exists locally or remotely
    local = subprocess.run(["git", "branch", "--list", branch], capture_output=True, text=True)
    remote = subprocess.run(["git", "branch", "-r", "--list", f"origin/{branch}"], capture_output=True, text=True)

    print(f"\n📁 Creating worktree for branch '{branch}' at {target}\n")

    if local.stdout.strip():
        # Branch exists locally
        run(["git", "worktree", "add", str(target), branch])
    elif remote.stdout.strip():
        # Branch exists on remote, track it
        run(["git", "worktree", "add", "--track", "-b", branch, str(target), f"origin/{branch}"])
    else:
        # New branch — create from base or current HEAD
        if base_branch:
            run(["git", "worktree", "add", "-b", branch, str(target), base_branch])
        else:
            run(["git", "worktree", "add", "-b", branch, str(target)])

    # Copy .env if it exists
    env_src = repo_root / ".env"
    if env_src.exists():
        env_dst = target / ".env"
        shutil.copy2(env_src, env_dst)
        print(f"\n📋 Copied .env → {env_dst}")
    else:
        print(f"\n⚠  No .env found in {repo_root}, skipping copy")

    # Install deps and distribute env vars (pnpm repos only)
    package_json = target / "package.json"
    if package_json.exists():
        print(f"\n📦 Running pnpm install...\n")
        run(["pnpm", "install"], cwd=target)
        scripts = json.loads(package_json.read_text()).get("scripts", {})
        if "sync-env" in scripts:
            run(["pnpm", "sync-env"], cwd=target)

    print(f"\n✓ Worktree ready at {target}")
    print(f"  cd {target}")


def list_worktrees():
    run(["git", "worktree", "list"])


def remove(branch: str):
    repo_name = get_repo_name()
    target = worktree_base(repo_name) / branch

    print(f"\n🗑  Removing worktree at {target}\n")
    run(["git", "worktree", "remove", str(target)])
    print(f"\n✓ Removed worktree for '{branch}'")


def main():
    parser = argparse.ArgumentParser(
        prog="wt",
        description="Git worktree helper",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )
    sub = parser.add_subparsers(dest="cmd", required=True)

    # create
    p_create = sub.add_parser("create", help="Create a new worktree")
    p_create.add_argument("branch", help="Branch name")
    p_create.add_argument("--from", dest="base_branch", default=None,
                          help="Base branch to create from (default: current HEAD)")

    # list
    sub.add_parser("list", help="List all worktrees")

    # remove
    p_remove = sub.add_parser("remove", help="Remove a worktree")
    p_remove.add_argument("branch", help="Branch name")

    args = parser.parse_args()

    try:
        if args.cmd == "create":
            create(args.branch, args.base_branch)
        elif args.cmd == "list":
            list_worktrees()
        elif args.cmd == "remove":
            remove(args.branch)
    except subprocess.CalledProcessError as e:
        print(f"\n✗ Command failed: {e}")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\nAborted.")
        sys.exit(1)


if __name__ == "__main__":
    main()
