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
  up         Start Docker Compose project.
  down       Stop Docker Compose project.
  <project>  The name of the project defined in the .env file (e.g. P1, P2).

Options:
  -h, --help        Print this help message
}
EOF
}

COMMAND=
PROJECT=

while [[ $# -gt 0 ]]; do
  case "$1" in
  -h | --help)
    print_help
    exit 0
    ;;
  up | down)
    if [ -z "$COMMAND" ]; then
      COMMAND="$1"
    else
      echo "Command already specified as '$COMMAND'."
      exit 1
    fi
    ;;
  *)
    if [ -z "$PROJECT" ]; then
      PROJECT="$1"
    else
      echo "Project already specified as '$PROJECT'."
      exit 1
    fi
    ;;
  esac
  shift
done

if [ -z "$COMMAND" ]; then
  echo "Error: No command specified. Use 'up' or 'down'."
  print_help
  exit 1
fi

if [ -z "$PROJECT" ]; then
  echo "Error: No project specified."
  print_help
  exit 1
fi

DB_REPOS_VAR="${PROJECT}_DBS"
BE_REPOS_VAR="${PROJECT}_BES"

DB_REPOS=${!DB_REPOS_VAR}
BE_REPOS=${!BE_REPOS_VAR}

if [ -z "$DB_REPOS" ] || [ -z "$BE_REPOS" ]; then
  echo "指定されたプロジェクトが見つかりません: $PROJECT"
  exit 1
fi

run_docker_compose() {
  REPO=$1
  ACTION=$2
  OPTION=${3:-}

  if [ ! -d "$REPO" ]; then
    echo "リポジトリディレクトリが見つかりません: $REPO"
    exit 1
  fi

  cd "$REPO" || exit
  if [ -n "$OPTION" ]; then
    echo "Running 'docker compose $ACTION $OPTION' in $REPO..."
    docker compose "$ACTION" "$OPTION"
  else
    echo "Running 'docker compose $ACTION' in $REPO..."
    docker compose "$ACTION"
  fi
  cd - >/dev/null || exit
}

case $COMMAND in
up)
  for DB_REPO in $DB_REPOS; do
    run_docker_compose "$DB_REPO" "up" "-d"
  done

  for BE_REPO in $BE_REPOS; do
    run_docker_compose "$BE_REPO" "up" "-d"
  done
  ;;
down)
  for DB_REPO in $DB_REPOS; do
    run_docker_compose "$DB_REPO" "down"
  done

  for BE_REPO in $BE_REPOS; do
    run_docker_compose "$BE_REPO" "down"
  done
  ;;
esac
