#!/usr/bin/env bash
# Functions to emulate Ruby keywords or other syntactic sugar

[[ -z $_rubsh_keywords ]] || return 0

# shellcheck disable=SC2046,SC2155
declare -r _rubsh_keywords="$(set -- $(sha1sum "$BASH_SOURCE"); printf "%s" "$1")"

source "${BASH_SOURCE%/*}"/core.sh 2>/dev/null || source core.sh

_rubsh_init() {
  local aliases

  # shellcheck disable=SC2034
  read -d "" -a aliases <<EOS
require
EOS

  _rubsh.core.alias keyword aliases
}

_rubsh_init
unset -f _rubsh_init

new() {
  local one="$1"
  local three="$3"

  shift; shift; shift
  eval "$three" "$one" "$@"
}
