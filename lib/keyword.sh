#!/usr/bin/env bash
# Functions to emulate Ruby keywords or other syntactic sugar

[[ -z $_rubsh_keyword ]] || return 0

# shellcheck disable=SC2046
readonly _rubsh_keyword="$(set -- $(sha1sum "$BASH_SOURCE"); printf "%s" "$1")"

source "${BASH_SOURCE%/*}"/core.sh 2>/dev/null || source core.sh

new() {
  local varname="$1"
  local constructor="$3"
  local initializer="$4"

  shift; shift; shift
  _rubsh.String.new initializer
  initializer.chomp
  initializer.start_with? "(" && initializer.end_with? ")" && shift && set -- "\"$initializer\"" "$@"
  eval "$constructor" "$varname" "$@"
}

require() {
  local path="$PATH"

  export PATH="$RUBSH_PATH${RUBSH_PATH:+:}$PATH"
  source "$1".sh 2>/dev/null || source "$1"
  export PATH="$path"
}
