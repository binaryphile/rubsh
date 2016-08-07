#!/usr/bin/env bash
# Functions for string testing and manipulation

[[ -z $_rubsh_symbol ]] || return 0

# shellcheck disable=SC2046
readonly _rubsh_symbol="$(set -- $(sha1sum "$BASH_SOURCE"); echo "$1")"
export _rubsh_symbol

source "${BASH_SOURCE%/*}"/core.sh 2>/dev/null || source core.sh

_rubsh_init() {
  local aliases

  # shellcheck disable=SC2034
  read -d "" -a aliases <<EOS
:to_s
EOS

  _rubsh.core.alias :Symbol :aliases
}

_rubsh_init
unset -f _rubsh_init

Symbol.new() {
  local method
  local methods

  # shellcheck disable=SC2034
  read -d "" -a methods <<EOS
:to_s
EOS

  for method in "${methods[@]}"; do
    _rubsh.core.alias_method "$1" "$method" :String
  done

  (( $# > 1 )) || return 0

  local "$(_rubsh.Symbol.to_s "$1")" && _rubsh.Shell.passback_as "$1" "$2"
}
export -f Symbol.new
