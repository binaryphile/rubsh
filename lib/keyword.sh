#!/usr/bin/env bash
# Functions to emulate Ruby keywords or other syntactic sugar

[[ -z $_rubsh_keyword ]] || return 0

# shellcheck disable=SC2046
readonly _rubsh_keyword="$(set -- $(sha1sum "$BASH_SOURCE"); printf "%s" "$1")"

source "${BASH_SOURCE%/*}"/core.sh 2>/dev/null || source core.sh

__dir__() {
  _rubsh.File.dirname "$(_rubsh.File.realpath "${BASH_SOURCE[1]}")"
}

__FILE__() {
  _rubsh.IO.puts "${BASH_SOURCE[1]}"
}

new() {
  local varname="$1"
  local constructor="$3"
  local initializer="$4"

  shift 3
  _rubsh.String.new initializer
  initializer.chomp
  initializer.start_with? "(" && initializer.end_with? ")" && shift && set -- "\"$initializer\"" "$@"
  eval "$constructor" "$varname" "$@"
}

require() {
  local path="$PATH"

  export PATH="$RUBSH_PATH${RUBSH_PATH:+:}$PATH"
  source "$1".sh 2>/dev/null
  export PATH="$path"
}
