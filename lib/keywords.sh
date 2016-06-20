#!/usr/bin/env bash
# Functions to emulate Ruby keywords or other syntactic sugar

# https://stackoverflow.com/questions/192292/bash-how-best-to-include-other-scripts/12694189#12694189
[[ -n $_rubsh_lib ]] || {
  if [[ -d ${BASH_SOURCE%/*} ]]; then
    declare -r _rubsh_lib="${BASH_SOURCE%/*}"
  else
    declare -r _rubsh_lib="$PWD"
  fi
}

[[ -z $_rubsh_keywords ]] || return 0
# shellcheck disable=SC2046,SC2155
declare -r _rubsh_keywords="$(set -- $(sha1sum "${BASH_SOURCE}"); printf "%s" "$1")"

source "$_rubsh_lib"/core.sh

_rubsh_init() {
  local alias
  local aliases

  # shellcheck disable=SC2034
  read -d "" -a aliases <<EOS
require
EOS

  for alias in "${aliases[@]}"; do
    _sh.alias_function "$alias" _core."$alias"
  done
}

_rubsh_init
unset -f _rubsh_init

new() {
  eval "$3" "$1" "$4"
}
