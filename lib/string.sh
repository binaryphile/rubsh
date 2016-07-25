#!/usr/bin/env bash
# Functions for string testing and manipulation

[[ -z $_rubsh_string ]] || return 0

# shellcheck disable=SC2046
readonly _rubsh_string="$(set -- $(sha1sum "$BASH_SOURCE"); echo "$1")"

source "${BASH_SOURCE%/*}"/core.sh 2>/dev/null || source core.sh

_rubsh_init() {
  local aliases

  # shellcheck disable=SC2034
  read -d "" -a aliases <<EOS
:blank?
:chomp
:end_with?
:eql?
:inspect
:start_with?
:to_s
EOS

  _rubsh.core.alias :String :aliases
}

_rubsh_init
unset -f _rubsh_init

String.class() {
  _rubsh.IO.puts "String"
}

String.new() {
  local method
  local methods

  # shellcheck disable=SC2034
  read -d "" -a methods <<EOS
:blank?
:class
:chomp
:end_with?
:eql?
:inspect
:split
:start_with?
:to_s
EOS

  for method in "${methods[@]}"; do
    _rubsh.core.alias_method "$1" "$method" :String
  done

  (( $# > 1 )) || return 0

  local "$(_rubsh.Symbol.to_s "$1")" && _rubsh.Shell.passback_as "$1" "$2"
}

String.split() {
  local _rubsh_block=$1
  local _rubsh_bruce=${3:-}

  ! _rubsh.Shell.variable? "$_rubsh_block" || _rubsh.Shell.dereference :_rubsh_block
  ! _rubsh.Shell.variable? "$_rubsh_bruce" || _rubsh.Shell.dereference :_rubsh_bruce
  if [[ -z $_rubsh_bruce ]]; then
    read -ra _rubsh_block <<<"$_rubsh_block"
  else
    IFS="$_rubsh_bruce" read -ra _rubsh_block <<<"$_rubsh_block"
  fi
  local "$(_rubsh.Symbol.to_s "$2")" && _rubsh.Shell.passback_as "$2" "${_rubsh_block[@]}"
}
