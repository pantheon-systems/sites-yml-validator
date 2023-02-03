#!/bin/bash
#
# Calculate a hash unique to the current state of the code including all uncommitted changes.
# Stages all changes to a temporary git index, then calls `git write-tree`.

set -euo pipefail

tmp="$(mktemp)"
trap 'rm -f $tmp' EXIT
cat "$(git rev-parse --git-dir)/index" > "$tmp"
export GIT_INDEX_FILE="$tmp"
git add -A
git write-tree | head -c 7
