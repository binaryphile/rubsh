#!/usr/bin/env bash
# Functions to emulate Ruby keywords or other syntactic sugar

[[ -z $_rubsh_keywords ]] || return 0

# shellcheck disable=SC2046,SC2155
declare -r _rubsh_keywords="$(set -- $(sha1sum "$BASH_SOURCE"); printf "%s" "$1")"

source "${BASH_SOURCE%/*}"/core.sh 2>/dev/null || source core.sh

_rubsh_init() {
  local alias
  local aliases

  # shellcheck disable=SC2034
  read -d "" -a aliases <<EOS
require
EOS


  for alias in "${aliases[@]}"; do
    _sh.alias_function "$alias" _rubsh_core."$alias"
  done
}

_rubsh_init
unset -f _rubsh_init

new() { eval "$3" "$1" "$4" ;}
