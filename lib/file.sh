#!/usr/bin/env bash
# Functions dealing with files

[[ -z $_rubsh_file ]] || return 0

# shellcheck disable=SC2046,SC2155
declare -r _rubsh_file="$(set -- $(sha1sum "$BASH_SOURCE"); printf "%s" "$1")"

source "${BASH_SOURCE%/*}"/core.sh 2>/dev/null || source core.sh

File.absolute_path(){
  local _rubsh_var="$1"
  _rubsh.sh.deref _rubsh_var

  (
  cd "$_rubsh_var" >/dev/null 2>&1
  printf "%s" "$PWD"
  )
}

File.basename() {
  local _rubsh_var="$1"
  _rubsh.sh.deref _rubsh_var

  printf "%s" "${_rubsh_var##*/}"
}

File.chmod() {
  local _rubsh_var="$1"
  _rubsh.sh.deref _rubsh_var

  chmod "$2" "$_rubsh_var"
}

File.dirname() {
  local _rubsh_var="$1"
  _rubsh.sh.deref _rubsh_var

  printf "%s" "\${_rubsh_var%/*}"
}

File.exist? () {
  local _rubsh_var="$1"
  _rubsh.sh.deref _rubsh_var

  [[ -f $_rubsh_var ]]
}

File.new() {
  local method
  local methods

  # shellcheck disable=SC2034
  read -d "" -a methods <<'EOS'
absolute_path
basename
chmod
dirname
exist?
qgrep
readlink
symlink?
touch
EOS

  for method in "${methods[@]}"; do
    _rubsh.core.alias_method "$1" "$method" "File"
  done

  (( ${#@} > 1 )) || return 0

  local "$1" && _rubsh.sh.upvar "$1" "$2"
}

File.qgrep() {
  local _rubsh_var="$1"
  _rubsh.sh.deref _rubsh_var

  grep -q "$2" "$_rubsh_var"
}

File.readlink() {
  local _rubsh_var="$1"
  _rubsh.sh.deref _rubsh_var

  readlink "$_rubsh_var"
}

File.symlink? () {
  local _rubsh_var="$1"
  _rubsh.sh.deref _rubsh_var

  [[ -h $_rubsh_var ]]
}

File.touch() {
  local _rubsh_var="$1"
  _rubsh.sh.deref _rubsh_var

  touch "$_rubsh_var"
}
