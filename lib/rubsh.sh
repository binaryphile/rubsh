#!/usr/bin/env bash
# Rubsh - Ruby-inspired datatype improvements for bash

# https://stackoverflow.com/questions/192292/bash-how-best-to-include-other-scripts/12694189#12694189
[[ -n $_rubsh_lib ]] || {
  [[ -d ${BASH_SOURCE%/*} ]] && _rubsh_lib="${BASH_SOURCE%/*}" || _rubsh_lib="$PWD"
  declare -r _rubsh_lib
}

[[ -z $_rubsh ]] || return 0
# shellcheck disable=SC2046,SC2155
declare -r _rubsh="$(set -- $(sha1sum "${BASH_SOURCE}"); printf "%s" "$1")"

source "$_rubsh_lib"/core.sh

_rubsh_init() {
  local module
  local modules

  read -d "" -a modules <<EOS
array
string
file
pathname
EOS

  for module in "${modules[@]}"; do
    require "$module"
  done
}

_rubsh_init
unset -f _rubsh_init
