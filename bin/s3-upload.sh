#!/bin/bash

set -euxCo pipefail
cd "$(dirname "$0")"

readonly SCRIPT_NAME=${0##*/}

ENV_FILE="../.env"

if [ ! -f "$ENV_FILE" ]; then
  echo ".envファイルが見つかりません: $ENV_FILE"
  exit 1
fi

# shellcheck source=../.env
# shellcheck disable=SC1091
source "$ENV_FILE"

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

aws s3 cp "$S3_UPLOAD_PATH" "$S3_PATH" --profile "$AWS_PROFILE"
