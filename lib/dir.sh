#!/usr/bin/env bash
# Functions dealing with directories

[[ -z $_rubsh_dir ]] || return 0

# shellcheck disable=SC2046
readonly _rubsh_dir="$(set -- $(sha1sum "$BASH_SOURCE"); printf "%s" "$1")"

source "${BASH_SOURCE%/*}"/core.sh 2>/dev/null || source core.sh

Dir.chmod() {
  local _rubsh_var="$1"
  _rubsh.Shell.dereference _rubsh_var

  chmod "$2" "$_rubsh_var"
}

Dir.exist? () {
  local _rubsh_var="$1"
  _rubsh.Shell.dereference _rubsh_var

  [[ -d $_rubsh_var ]]
}

Dir.mkdir() {
  local _rubsh_var="$1"
  _rubsh.Shell.dereference _rubsh_var

  (( $# > 1 )) || {
    mkdir -p "$_rubsh_var"
    return
  }
  mkdir -pm "$2" "$_rubsh_var"
}

Dir.new() {
  local method
  local methods

  # shellcheck disable=SC2034
  read -d "" -a methods <<'EOS'
chmod
exist?
mkdir
symlink?
touch
EOS

  for method in "${methods[@]}"; do
    _rubsh.core.alias_method "$1" "$method" "Dir"
  done

  (( $# > 1 )) || return 0

  local "$1" && _rubsh.Shell.passback_as "$1" "$2"
}

Dir.symlink? () {
  local _rubsh_var="$1"
  _rubsh.Shell.dereference _rubsh_var

  [[ -h $_rubsh_var ]]
}

Dir.touch() {
  local _rubsh_var="$1"
  _rubsh.Shell.dereference _rubsh_var

  touch "$_rubsh_var"
}