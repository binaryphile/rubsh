#!/usr/bin/env bash
# Functions dealing with files and paths

[[ -z $_rubsh_file ]] || return 0

# shellcheck disable=SC2046,SC2155
declare -r _rubsh_file="$(set -- $(sha1sum "${BASH_SOURCE}"); printf "%s" "$1")"

source "${BASH_SOURCE%/*}"/core.sh 2>/dev/null || source core.sh

# TODO: use _sh.value etc?
file.basename()   { eval printf "%s" "\${$1##*/}" ;}
file.dirname()    { eval printf "%s" "\${$1%/*}"  ;}
file.exist? ()    { eval [[ -f \$"$1" ]]          ;}
file.readlink()   { eval readlink "\$$1"          ;}
file.symlink? ()  { eval [[ -h \$"$1" ]]          ;}
