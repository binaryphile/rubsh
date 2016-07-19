#!/usr/bin/env bash
# Rubsh - Ruby-inspired datatype improvements for bash

[[ -z $_rubsh ]] || return 0

# shellcheck disable=SC2046
readonly _rubsh="$(set -- $(sha1sum "$BASH_SOURCE"); printf "%s" "$1")"

source "${BASH_SOURCE%/*}"/core.sh 2>/dev/null || source core.sh

_rubsh_init() {
  local module
  local modules

  read -d "" -a modules <<EOS
array
constant
dir
file
io
keyword
pathname
string
EOS

  for module in "${modules[@]}"; do
    # shellcheck disable=SC2154
    source "$_rubsh_lib"/"$module".sh
  done
}

_rubsh_init
unset -f _rubsh_init
