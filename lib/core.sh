#!/usr/bin/env bash
# Core functions used by other modules

[[ -z $_rubsh_core ]] || return 0

# shellcheck disable=SC2046
readonly _rubsh_core=$(set -- $(sha1sum "$BASH_SOURCE"); echo "$1")

# https://stackoverflow.com/questions/192292/bash-how-best-to-include-other-scripts/12694189#12694189
[[ -n $_rubsh_lib ]]  || readonly _rubsh_lib=$(cd "${BASH_SOURCE%/*}" >/dev/null 2>&1; printf "%s" "$PWD")

# https://stackoverflow.com/questions/10582763/how-to-return-an-array-in-bash-without-using-globals/15982208#15982208
# Print array definition to use with assignments, for loops, etc.
#   varname: the name of an array variable.
_rubsh.Array.inspect() {
    local _rubsh_cactus

    _rubsh_cactus=$(_rubsh.Symbol.to_s "$1")
    _rubsh_cactus=$(declare -p $_rubsh_cactus)
    _rubsh_cactus=${_rubsh_cactus#declare\ -a\ *=}
    # Strip keys so printed definition will be a simple list (like when using
    # "${array[@]}").  One side effect of having keys in the definition is
    # that when appending arrays (i.e. `a1+=$( my_a.inspect a2 )`), values at
    # matching indices merge instead of pushing all items onto array.
    _rubsh_cactus=${_rubsh_cactus//\[[0-9]\]=}
    echo "${_rubsh_cactus:1:-1}"
}

_rubsh.Array.to_s() { eval echo \$\{"$(_rubsh.Symbol.to_s "$1")"[*]\} ;}

_rubsh.core.alias() {
  local _rubsh_alex
  local _rubsh_burger
  local _rubsh_casino=$2
  _rubsh.Shell.dereference :_rubsh_casino
  _rubsh_burger=$(_rubsh.Symbol.to_s "$1")

  for _rubsh_alex in "${_rubsh_casino[@]}"; do
    _rubsh_alex=$(_rubsh.Symbol.to_s "$_rubsh_alex")
    _rubsh.Shell.alias_function ":$_rubsh_burger.$_rubsh_alex" ":_rubsh.$_rubsh_burger.$_rubsh_alex"
  done
}

_rubsh.core.alias_method() {
  local _rubsh_agent
  local _rubsh_canyon
  local _rubsh_cargo

  _rubsh_agent=$(_rubsh.Symbol.to_s "$1")
  _rubsh_canyon=$(_rubsh.Symbol.to_s "$2")
  _rubsh_cargo=$(_rubsh.Symbol.to_s "$3")
  eval "$_rubsh_agent.$_rubsh_canyon () { $_rubsh_cargo.$_rubsh_canyon $1 \"\$@\" ;}" ;}

_rubsh.File.basename() {
  local _rubsh_bandit=$1
  ! _rubsh.Shell.variable? "$_rubsh_bandit" || _rubsh.Shell.dereference :_rubsh_bandit

  _rubsh_bandit=${_rubsh_bandit%/}
  echo "${_rubsh_bandit##*/}"
}

_rubsh.File.dirname() {
  local _rubsh_aspirin="$1"
  ! _rubsh.Shell.variable? "$_rubsh_aspirin" || _rubsh.Shell.dereference :_rubsh_aspirin

  [[ $_rubsh_aspirin =~ / ]] || { echo "."; return ;}
  _rubsh_aspirin=${_rubsh_aspirin%/}
  echo "${_rubsh_aspirin%/*}"
}

_rubsh.File.realpath(){
  local _rubsh_bonus=$1
  ! _rubsh.Shell.variable? "$_rubsh_bonus" || _rubsh.Shell.dereference :_rubsh_bonus

  readlink -f "$_rubsh_bonus"
}

# Same as Array.inspect() but preserves keys.
_rubsh.Hash.inspect() {
    local r

    r=$( declare -p $1 )
    echo "${r#declare\ -a\ *=}"
}

# shellcheck disable=SC2059
_rubsh.IO.printf() {
  local _rubsh_ipr_format=$1
  local _rubsh_ipr_subst=$2

  ! _rubsh.Shell.variable? "$_rubsh_ipr_format" || _rubsh.Shell.dereference :_rubsh_ipr_format
  ! _rubsh.Shell.variable? "$_rubsh_ipr_subst" || _rubsh.Shell.dereference :_rubsh_ipr_subst
  shift 2
  printf "$_rubsh_ipr_format" "$_rubsh_ipr_subst" "$@"
}

_rubsh.IO.puts() {
  local _rubsh_detect=$1

  _rubsh.Shell.variable? "$_rubsh_detect" || { _rubsh.IO.printf "%s\n" "$*"; return ;}
  _rubsh.Shell.dereference :_rubsh_detect
  _rubsh.IO.printf "%s\n" "$_rubsh_detect"
}

_rubsh.Shell.alias_function() { eval "$(_rubsh.Symbol.to_s "$1") () { $(_rubsh.Symbol.to_s "$2") \"\$@\" ;}" ;}

_rubsh.Shell.assign_literal() {
  local _rubsh_angel
  _rubsh_angel=$(_rubsh.Symbol.to_s "$1")
  local -a _rubsh_ary=$2

  local "$_rubsh_angel" && _rubsh.Shell.passback_as "$1" "${_rubsh_ary[@]}"
}

_rubsh.Shell.class() {
  local _rubsh_anatomy
  local _rubsh_result

  _rubsh_anatomy=$(_rubsh.Symbol.to_s "$1")
  _rubsh_result=$(declare -p "$_rubsh_anatomy" 2>/dev/null) || return
  case $_rubsh_result in
    declare\ -a* )
      printf "array\n"
      ;;
    * )
      printf "string\n"
      ;;
  esac
}

_rubsh.Shell.dereference() {
  local _rubsh_sde_ref

  _rubsh_sde_ref=$(_rubsh.Shell.to_s "$1")
  _rubsh.Shell.assign_literal :_rubsh_sde_ref "$(_rubsh.Shell.inspect "$_rubsh_sde_ref")"
  local $(_rubsh.Symbol.to_s "$1") && _rubsh.Shell.passback_as "$1" "${_rubsh_sde_ref[@]}"
}

# TODO: implement with send?
_rubsh.Shell.inspect() {
  case $(_rubsh.Shell.class "$1") in
    "array" )
      _rubsh.Array.inspect "$1"
      ;;
    * )
      _rubsh.String.inspect "$1"
      ;;
  esac
}

# Assign variable one scope above the caller
# Usage: local "$1" && _rubsh.Shell.passback_as $1 "value(s)"
# Param: $1  Variable name to assign value to
# Param: $*  Value(s) to assign.  If multiple values, an array is
#            assigned, otherwise a single value is assigned.
# NOTE: For assigning multiple variables, use 'passbacks_as'.  Do NOT
#       use multiple 'passback_as' calls, since one call might
#       reassign a variable to be used by another call.
# See: http://fvue.nl/wiki/Bash:_Passing_variables_by_reference
_rubsh.Shell.passback_as() {
  local _rubsh_chaos
  _rubsh_chaos=$(_rubsh.Symbol.to_s "$1")

  if unset -v "$_rubsh_chaos"; then           # Unset & validate varname
    if (( $# == 2 )); then
      printf -v "$_rubsh_chaos" "%s" "$2" # Return single value
    else
      # TODO: declare?
      # shellcheck disable=SC1083
      eval "$_rubsh_chaos"=\(\"\${@:2}\"\)  # Return array
    fi
  fi
}

# Assign variables one scope above the caller
# Usage: local varname [varname ...] &&
#        _rubsh.core.sh.upvars [-v varname value] | [-aN varname [value ...]] ...
# Available OPTIONS:
#     -aN  Assign next N values to varname as array
#     -v   Assign single value to varname
# Return: 1 if error occurs
_rubsh.Shell.passbacks_as() {
    if ! (( $# )); then
        echo "${FUNCNAME[0]}: usage: ${FUNCNAME[0]} [-v varname"\
            "value] | [-aN varname [value ...]] ..." 1>&2
        return 2
    fi
    while (( $# )); do
        case $1 in
            -a*)
                # Error checking
                [[ ${1#-a} ]] || { echo "bash: ${FUNCNAME[0]}: \`$1': missing"\
                    "number specifier" 1>&2; return 1; }
                printf %d "${1#-a}" &> /dev/null || { echo "bash:"\
                    "${FUNCNAME[0]}: \`$1': invalid number specifier" 1>&2
                    return 1; }
                # Assign array of -aN elements
                # shellcheck disable=SC1083,SC2086,SC2015
                [[ "$2" ]] && unset -v "$2" && eval "$2"=\(\"\${@:3:${1#-a}}\"\) &&
                shift $((${1#-a} + 2)) || { echo "bash: ${FUNCNAME[0]}:"\
                    "\`$1${2+ }$2': missing argument(s)" 1>&2; return 1; }
                ;;
            -v)
                # Assign single value
                # shellcheck disable=SC1083,SC2086,SC2015
                [[ "$2" ]] && unset -v "$2" && eval "$2"=\"\$3\" &&
                shift 3 || { echo "bash: ${FUNCNAME[0]}: $1: missing"\
                "argument(s)" 1>&2; return 1; }
                ;;
            --help) echo "\
Usage: local varname [varname ...] &&
   ${FUNCNAME[0]} [-v varname value] | [-aN varname [value ...]] ...
Available OPTIONS:
-aN VARNAME [value ...]   assign next N values to varname as array
-v VARNAME value          assign single value to varname
--help                    display this help and exit
--version                 output version information and exit"
                return 0 ;;
            --version) echo "\
${FUNCNAME[0]}-0.9.dev
Copyright (C) 2010 Freddy Vulto
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law."
                return 0 ;;
            *)
                echo "bash: ${FUNCNAME[0]}: $1: invalid option" 1>&2
                return 1 ;;
        esac
    done
}

_rubsh.Shell.symbol? () { [[ $1 == :* ]] ;}

_rubsh.Shell.to_s() {
  case "$(_rubsh.Shell.class "$1")" in
    "array" )
      _rubsh.Array.to_s "$1"
      ;;
    * )
      _rubsh.String.to_s "$1"
      ;;
  esac
}

_rubsh.Shell.variable? () { declare -p "$(_rubsh.Symbol.to_s "$1")" >/dev/null 2>&1 ;}

_rubsh.String.blank? () {
  local _rubsh_distant
  _rubsh_distant=$(_rubsh.Symbol.to_s "$1")

  [[ -z ${!_rubsh_distant} || ${!_rubsh_distant} =~ ^[[:space:]]+$ ]]
}

_rubsh.String.chomp() {
  local _rubsh_client=$1
  _rubsh.Shell.dereference :_rubsh_client

  _rubsh_client=${_rubsh_client#"${_rubsh_client%%[![:space:]]*}"}   # remove leading whitespace characters
  _rubsh_client=${_rubsh_client%"${_rubsh_client##*[![:space:]]}"}   # remove trailing whitespace characters
  local $(_rubsh.Symbol.to_s "$1") && _rubsh.Shell.passback_as "$1" "$_rubsh_client"
}

_rubsh.String.end_with? () {
  _rubsh_blonde=$1
  _rubsh.Shell.dereference :_rubsh_blonde

  [[ $_rubsh_blonde == *"$2" ]]
}

_rubsh.String.eql? () {
  local _rubsh_america
  _rubsh_america=$(_rubsh.Symbol.to_s "$1")
  [[ ${!_rubsh_america:-} == "$2" ]]
}

_rubsh.String.inspect() {
    local _rubsh_sin_ref

    _rubsh_sin_ref=$(_rubsh.Symbol.to_s "$1")
    _rubsh_sin_ref="$(declare -p "$_rubsh_sin_ref")"
    _rubsh_sin_ref=${_rubsh_sin_ref#declare\ -?\ *=\"}
    echo "${_rubsh_sin_ref%\"}"
}

_rubsh.String.new() {
  local _rubsh_catalog
  local _rubsh_burma

  # shellcheck disable=SC2034
  read -d "" -a _rubsh_burma <<EOS
:blank?
:chomp
:end_with?
:eql?
:inspect
:present?
:start_with?
:to_s
EOS

  for _rubsh_catalog in "${_rubsh_burma[@]}"; do
    _rubsh.core.alias_method "$1" "$_rubsh_catalog" :_rubsh.String
  done

  (( $# > 1 )) || return 0

  local "$1" && _rubsh.Shell.passback_as "$1" "$2"
}

_rubsh.String.present? () { ! _rubsh.String.blank? "$@" ;}

_rubsh.String.start_with? () {
  _rubsh_ssw_string=$1
  _rubsh.Shell.variable? "$1" && _rubsh.Shell.dereference :_rubsh_ssw_string
  [[ $_rubsh_ssw_string == "$2"* ]]
}

_rubsh.String.symbol? () {
  [[ $1 =~ ^:[_[:alpha:]][_?.=[:alnum:]]*$ ]]
}

_rubsh.String.to_s() { eval echo \"\$"$(_rubsh.Symbol.to_s "$1")"\" ;}

_rubsh.Symbol.to_s() {
  _rubsh.String.symbol? "$1" || return
  echo "${1#:}"
}
