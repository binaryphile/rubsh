#!/usr/bin/env bash
# Functions dealing with files and paths

# https://stackoverflow.com/questions/192292/bash-how-best-to-include-other-scripts/12694189#12694189
[[ -n $_rubsh_lib ]] || {
  if [[ -d ${BASH_SOURCE%/*} ]]; then
    declare -r _rubsh_lib="${BASH_SOURCE%/*}"
  else
    declare -r _rubsh_lib="$PWD"
  fi
}

[[ -z $_rubsh_file ]] || return 0
# shellcheck disable=SC2155,SC2046
declare -r _rubsh_file="$(set -- $(sha1sum "${BASH_SOURCE}"); printf "%s" "$1")"

source "$_rubsh_lib"/core.sh

# TODO: use _sh.value etc?
file.basename()   { eval printf "%s" "\${$1##*/}" ;}
file.dirname()    { eval printf "%s" "\${$1%/*}"  ;}
file.exist? ()    { eval [[ -f \$"$1" ]]          ;}
file.readlink()   { eval readlink "\$$1"          ;}
file.symlink? ()  { eval [[ -h \$"$1" ]]          ;}
