#!/usr/bin/env bash
# Functions to emulate Ruby constants

[[ -z $_rubsh_constant ]] || return 0

# shellcheck disable=SC2046
readonly _rubsh_constant="$(set -- $(sha1sum "$BASH_SOURCE"); printf "%s" "$1")"

source "${BASH_SOURCE%/*}"/core.sh 2>/dev/null || source core.sh
