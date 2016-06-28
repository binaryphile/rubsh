#!/usr/bin/env bash
# Functions to emulate Ruby keywords or other syntactic sugar

[[ -z $_rubsh_keywords ]] || return 0

# shellcheck disable=SC2046,SC2155
declare -r _rubsh_keywords="$(set -- $(sha1sum "$BASH_SOURCE"); printf "%s" "$1")"

source "${BASH_SOURCE%/*}"/core.sh 2>/dev/null || source core.sh

_rubsh_init() {
  local aliases

  # shellcheck disable=SC2034
  read -d "" -a aliases <<EOS
require
EOS

  _rubsh.core.alias keyword aliases
}

_rubsh_init
unset -f _rubsh_init

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
