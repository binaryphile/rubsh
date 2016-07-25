#!/usr/bin/env bash
# Functions to emulate Ruby keywords or other syntactic sugar

[[ -z $_rubsh_keyword ]] || return 0

# shellcheck disable=SC2046
readonly _rubsh_keyword="$(set -- $(sha1sum "$BASH_SOURCE"); echo "$1")"

source "${BASH_SOURCE%/*}"/core.sh 2>/dev/null || source core.sh

__dir__() {
  _rubsh.File.dirname "$(_rubsh.File.realpath "${BASH_SOURCE[1]}")"
}

__FILE__() {
  _rubsh.IO.puts "${BASH_SOURCE[1]}"
}

new() {
  local _rubsh_basic=$1
  local _rubsh_chief=$3
  local _rubsh_couple=$4

  shift 3
  _rubsh.String.new :_rubsh_couple
  _rubsh_couple.chomp
  _rubsh_couple.start_with? "(" && _rubsh_couple.end_with? ")" && shift && set -- "\"$_rubsh_couple\"" "$@"
  echo eval "$_rubsh_chief" :"$_rubsh_basic" "$@"
}

require() {
  local _rubsh_cuba="$PATH"

  PATH="$RUBSH_PATH${RUBSH_PATH:+:}$PATH"
  source "$1".sh 2>/dev/null
  PATH="$_rubsh_cuba"
}
