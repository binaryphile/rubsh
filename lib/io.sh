#!/usr/bin/env bash
# Functions to deal with I/O

[[ -z $_rubsh_io ]] || return 0

# shellcheck disable=SC2046
readonly _rubsh_io="$(set -- $(sha1sum "$BASH_SOURCE"); echo "$1")"

source "${BASH_SOURCE%/*}"/core.sh 2>/dev/null || source core.sh

# shellcheck disable=SC2034
stderr=stderr
# shellcheck disable=SC2034
stdout=stdout

_rubsh_init() {
  local aliases

  # shellcheck disable=SC2034
  read -d "" -a aliases <<EOS
:printf
:puts
EOS

  _rubsh.core.alias :IO :aliases
}

_rubsh_init
unset -f _rubsh_init

# TODO: more clever way to instantiate std IO objects so they take filehandle arguments
stderr.printf() { IO.printf "$@" 1>&2  ;}
stderr.puts()   { IO.puts "$@" 1>&2    ;}

_rubsh.Shell.alias_function :stdout.printf :IO.printf
_rubsh.Shell.alias_function :stdout.puts :IO.puts
_rubsh.Shell.alias_function :puts :IO.puts
