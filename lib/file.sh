#!/usr/bin/env bash
# Functions dealing with files and paths

# https://stackoverflow.com/questions/192292/bash-how-best-to-include-other-scripts/12694189#12694189
[[ -n $_rubsh_lib ]] || {
  [[ -d ${BASH_SOURCE%/*} ]] && _rubsh_lib="${BASH_SOURCE%/*}" || _rubsh_lib="$PWD"
  declare -r _rubsh_lib
}

source "$_rubsh_lib"/core.sh

_rubsh_file.present? 2>/dev/null && return 0
# shellcheck disable=SC2046
_String.new _rubsh_file "$(set -- $(sha1sum "${BASH_SOURCE}"); printf "%s" "$1")"
# shellcheck disable=SC2034
declare -r _rubsh_file

# TODO: use _sh.value etc?
file.basename()   { eval printf "%s" "\${$1##*/}" ;}
file.dirname()    { eval printf "%s" "\${$1%/*}"  ;}
file.exist? ()    { eval [[ -f \$"$1" ]]          ;}
file.readlink()   { eval readlink "\$$1"          ;}
file.symlink? ()  { eval [[ -h \$"$1" ]]          ;}
