#!/usr/bin/env bash
# Functions to interact with shell variables, functions and the environment

[[ -z $_rubsh_shell ]] || return 0

# shellcheck disable=SC2046
readonly _rubsh_shell="$(set -- $(sha1sum "$BASH_SOURCE"); printf "%s" "$1")"

source "${BASH_SOURCE%/*}"/core.sh 2>/dev/null || source core.sh

_rubsh_init() {
  local aliases

  # shellcheck disable=SC2034
  read -d "" -a aliases <<EOS
dereference
variable?
EOS

  _rubsh.core.alias Shell aliases
}

_rubsh_init
unset -f _rubsh_init