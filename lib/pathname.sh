#!/usr/bin/env bash
# Functions dealing with files and paths

# https://stackoverflow.com/questions/192292/bash-how-best-to-include-other-scripts/12694189#12694189
[[ -n $_rubsh_lib ]] || {
  [[ -d ${BASH_SOURCE%/*} ]] && _rubsh_lib="${BASH_SOURCE%/*}" || _rubsh_lib="$PWD"
  declare -r _rubsh_lib
}

source "$_rubsh_lib"/core.sh

_rubsh_pathname.present? && return 0
# shellcheck disable=SC2034
_String.new _rubsh_pathname "$(set -- $(sha1sum "${BASH_SOURCE}"); printf "%s" "$1")"
# shellcheck disable=SC2034
declare -r _rubsh_pathname

require "file"

# TODO: use alias_function
path.basename() { file.basename "$@"  ;}
path.dirname()  { file.dirname  "$@"  ;}
path.exist? ()  { file.exist?   "$@"  ;}
path.readlink() { file.readlink "$@"  ;}

# https://github.com/basecamp/sub/blob/master/libexec/sub
path.realdirpath() {
  local cwd
  local name
  local path

  eval "local path=\"\$$1\""
  cwd="$(pwd)"
  while ! _String.blank? path; do
    cd "$(file.dirname path)"
    # shellcheck disable=SC2034
    name="$(path.basename path)"
    # shellcheck disable=SC2034
    path="$(file.readlink name || true)"
  done
  pwd
  cd "$cwd"
}
