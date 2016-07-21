#!/usr/bin/env bash
# Functions dealing with files

[[ -z $_rubsh_file ]] || return 0

# shellcheck disable=SC2046
readonly _rubsh_file="$(set -- $(sha1sum "$BASH_SOURCE"); printf "%s" "$1")"

source "${BASH_SOURCE%/*}"/core.sh 2>/dev/null || source core.sh

_rubsh_init() {
  local aliases

  # shellcheck disable=SC2034
  read -d "" -a aliases <<EOS
basename
dirname
realpath
EOS

  _rubsh.core.alias File aliases
}

_rubsh_init
unset -f _rubsh_init

File.absolute_path() {
  local basename
  local _rubsh_var="$1"
  ! _rubsh.sh.is_var "$_rubsh_var" || _rubsh.Shell.dereference _rubsh_var

  _rubsh_var="${_rubsh_var%/}"
  basename="$(_rubsh.File.basename "$_rubsh_var")"

  (
  [[ $basename =~ [^.] ]] || { cd "$_rubsh_var" >/dev/null; _rubsh.IO.puts "$PWD"; return ;}
  cd "$(_rubsh.File.dirname "$_rubsh_var")" >/dev/null
  _rubsh.IO.puts "$PWD/$basename"
  )
}

File.append() {
  local _rubsh_var="$1"
  ! _rubsh.sh.is_var "$_rubsh_var" || _rubsh.Shell.dereference _rubsh_var

  cat <<<"$2" >>"$_rubsh_var"
}

File.chmod() {
  local _rubsh_var="$1"
  ! _rubsh.sh.is_var "$_rubsh_var" || _rubsh.Shell.dereference _rubsh_var

  chmod "$2" "$_rubsh_var"
}

File.exist? () {
  local _rubsh_var="$1"
  ! _rubsh.sh.is_var "$_rubsh_var" || _rubsh.Shell.dereference _rubsh_var

  [[ -f $_rubsh_var ]]
}

File.new() {
  local method
  local methods

  # shellcheck disable=SC2034
  read -d "" -a methods <<'EOS'
absolute_path
append
basename
chmod
dirname
exist?
qgrep
readlink
realpath
symlink?
touch
EOS

  for method in "${methods[@]}"; do
    _rubsh.core.alias_method "$1" "$method" "File"
  done

  (( ${#@} > 1 )) || return 0

  local "$1" && _rubsh.Shell.passback_as "$1" "$2"
}

File.qgrep() {
  local _rubsh_var="$1"
  ! _rubsh.sh.is_var "$_rubsh_var" || _rubsh.Shell.dereference _rubsh_var

  grep -q "$2" "$_rubsh_var"
}

File.readlink() {
  local _rubsh_var="$1"
  ! _rubsh.sh.is_var "$_rubsh_var" || _rubsh.Shell.dereference _rubsh_var

  readlink "$_rubsh_var"
}

File.symlink? () {
  local _rubsh_var="$1"
  ! _rubsh.sh.is_var "$_rubsh_var" || _rubsh.Shell.dereference _rubsh_var

  [[ -h $_rubsh_var ]]
}

File.touch() {
  local _rubsh_var="$1"
  ! _rubsh.sh.is_var "$_rubsh_var" || _rubsh.Shell.dereference _rubsh_var

  touch "$_rubsh_var"
}
