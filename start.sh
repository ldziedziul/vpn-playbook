#!/bin/bash

set -e

readonly REPOSITORY="$(git remote get-url origin)"
TARGET="$(pwd)"

RED=""
GREEN=""
BLUE=""
RESET=""

error() {
    echo "${RED}""Error: $*""${RESET}" >&2
    exit 1
}

ok() {
    echo "${GREEN}""Info   | OK        | $*""${RESET}"
}

installing() {
    echo "${BLUE}""Info   | Install   | $*""${RESET}"
}

generate_temp_dir() {
    PLAYBOOK_LOCATION=$(mktemp -d -t playbook)
    trap 'rm -rf "$PLAYBOOK_LOCATION"' EXIT
    git clone -q --depth=1 "${REPOSITORY}" "$PLAYBOOK_LOCATION" || error "git clone of playbook repo failed, run with --local if already cloned"
    TARGET="$PLAYBOOK_LOCATION"
}

if [ -t 1 ]; then
    RED=$(printf '\033[31m')
    GREEN=$(printf '\033[32m')
    BLUE=$(printf '\033[34m')
    RESET=$(printf '\033[m')
fi

if ! command -v git &> /dev/null;
    then
        installing "git"
        sudo apt update && sudo apt install git
    else
        ok "git"
fi

[[ "$1" = "--local" ]] && echo "Using local copy" || generate_temp_dir

for arg do
  shift
  [ "$arg" = "--local" ] && continue
  set -- "$@" "$arg"
done


if ! command -v ansible &> /dev/null;
    then
        installing "ansible" && apt update && apt install ansible
    else
        ok "ansible"
fi

cd "$TARGET" && ansible-playbook playbook.yml -K "$@"
