#!/usr/bin/env bash
# post-sync-keyword.sh
# https://github.com/necrose99/gentoo-config
# Self-seeding Gentoo dev environment: auto-apply ~ARCH keywords for installed repos
# Works in chroot, Docker, or host system
# Features:
#   - Auto-detect installed repos
#   - Apply ~ARCH keywords for all packages in those repos
#   - Optional cleanup of stale keywords (--clean)
#   - Optional dry-run (--dry-run)
#   - Ensures /etc/portage/scripts exists for further helpers

set -euo pipefail

ROOT=${ROOT:-/}        # Set to /mnt/gentoo or leave empty for host
ARCH=$(uname -m)       # Auto-detect architecture
CLEAN=false
DRYRUN=false

# Parse flags
for arg in "$@"; do
    case $arg in
        --clean) CLEAN=true ;;
        --dry-run) DRYRUN=true ;;
        *) ;;
    esac
done

# Ensure scripts dir exists
scripts_dir="$ROOT/etc/portage/scripts"
mkdir -p "$scripts_dir"
echo "[INFO] Ensure $scripts_dir exists for future helper scripts"

# Detect installed overlays
repos=$(eselect repository list 2>/dev/null | awk '{print $1}' | grep -v "^$")
if [[ -z "$repos" ]]; then
    # fallback if no eselect or inside minimal container
    repos=(gentoo pentoo)
fi

echo "[INFO] Detected repos: $repos"

# Iterate over repos and apply keywords
for repo in $repos; do
    dir="$ROOT/etc/portage/package.accept_keywords"
    mkdir -p "$dir"
    file="$dir/${repo}-repo"

    # Remove stale entries if cleanup enabled
    if [[ "$CLEAN" == true && -f "$file" ]]; then
        grep -v "::" "$file" | sort -u > "$file.tmp"
        mv "$file.tmp" "$file"
        echo "[INFO] Cleaned stale entries in $file"
    fi

    # Add keyword line if missing
    line="*/*::${repo} ~${ARCH}"
    if ! grep -Fxq "$line" "$file" 2>/dev/null; then
        if [[ "$DRYRUN" == true ]]; then
            echo "[DRYRUN] Would add: $line to $file"
        else
            echo "$line" >> "$file"
            sort -u "$file" -o "$file"
            echo "[INFO] Keywords applied for repo $repo in $file"
        fi
    else
        echo "[INFO] Line already present for $repo: $line"
    fi
done

echo "[INFO] Post-sync keyword script completed."
