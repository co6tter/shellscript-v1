#!/bin/bash

set -euxCo pipefail
cd "$(dirname "$0")"

readonly SCRIPT_NAME=${0##*/}

print_help() {
  cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS]

Options:
  -h, --help        Print this help message
}
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  -h | --help)
    print_help
    exit 0
    ;;
  *)
    echo "Unknown argument: $1" >&2
    exit 1
    ;;
  esac
done

ghq list --full-path | while read -r repo; do
  if ! git -C "$repo" ls-remote &>/dev/null; then
    echo "delete: $repo"
    rm -rf "$repo"
  fi
done
