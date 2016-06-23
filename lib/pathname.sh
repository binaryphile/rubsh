#!/usr/bin/env bash
# Functions dealing with files and paths

[[ -z $_rubsh_pathname ]] || return 0

# shellcheck disable=SC2046,SC2155
declare -r _rubsh_pathname="$(set -- $(sha1sum "${BASH_SOURCE}"); printf "%s" "$1")"

source "${BASH_SOURCE%/*}"/core.sh 2>/dev/null || source core.sh

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
