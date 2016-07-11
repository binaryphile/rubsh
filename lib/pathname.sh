#!/usr/bin/env bash
# Functions dealing with files and paths

[[ -z $_rubsh_pathname ]] || return 0

# shellcheck disable=SC2046,SC2155
declare -r _rubsh_pathname="$(set -- $(sha1sum "$BASH_SOURCE"); printf "%s" "$1")"

source "${BASH_SOURCE%/*}"/core.sh 2>/dev/null || source core.sh
# shellcheck disable=SC2154
source "$_rubsh_lib"/file.sh

# TODO: use alias_function
Pathname.basename() { File.basename "$@"  ;}
Pathname.dirname()  { File.dirname  "$@"  ;}
Pathname.exist? ()  { File.exist?   "$@"  ;}
Pathname.readlink() { File.readlink "$@"  ;}

# https://github.com/basecamp/sub/blob/master/libexec/sub
Pathname.realdirpath() {
  local cwd
  local name
  local path

  eval "local path=\"\$$1\""
  cwd="$(pwd)"
  while ! _String.blank? path; do
    cd "$(File.dirname path)"
    # shellcheck disable=SC2034
    name="$(Pathname.basename path)"
    # shellcheck disable=SC2034
    path="$(File.readlink name || true)"
  done
  pwd
  cd "$cwd"
}
