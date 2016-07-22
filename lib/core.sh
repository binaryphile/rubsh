#!/usr/bin/env bash
# Core functions used by other modules

[[ -z $_rubsh_core ]] || return 0

# shellcheck disable=SC2046
readonly _rubsh_core="$(set -- $(sha1sum "$BASH_SOURCE"); printf "%s" "$1")"

# https://stackoverflow.com/questions/192292/bash-how-best-to-include-other-scripts/12694189#12694189
[[ -n $_rubsh_lib ]]  || readonly _rubsh_lib="$(cd "${BASH_SOURCE%/*}" >/dev/null 2>&1; printf "%s" "$PWD")"

# https://stackoverflow.com/questions/10582763/how-to-return-an-array-in-bash-without-using-globals/15982208#15982208
# Print array definition to use with assignments, for loops, etc.
#   varname: the name of an array variable.
_rubsh.Array.to_s() {
    local r

    r=$( declare -p $1 )
    r=${r#declare\ -a\ *=}
    # Strip keys so printed definition will be a simple list (like when using
    # "${array[@]}").  One side effect of having keys in the definition is
    # that when appending arrays (i.e. `a1+=$( my_a.to_s a2 )`), values at
    # matching indices merge instead of pushing all items onto array.
    r=${r//\[[0-9]\]=}
    echo "${r:1:-1}"
}

_rubsh.core.alias() {
  local alias
  eval local -a aliases="$(_rubsh.Shell.value "$2")"

  # shellcheck disable=SC2154
  for alias in "${aliases[@]}"; do
    _rubsh.Shell.alias_function "$1.$alias" "_rubsh.$1.$alias"
  done
}

_rubsh.core.alias_method() {
  eval "$1.$2 () { $3.$2 $1 \"\$@\" ;}"
}

_rubsh.File.basename() {
  local _rubsh_var="$1"
  ! _rubsh.Shell.variable? "$_rubsh_var" || _rubsh.Shell.dereference _rubsh_var

  _rubsh_var="${_rubsh_var%/}"
  echo "${_rubsh_var##*/}"
}

_rubsh.File.dirname() {
  local _rubsh_var="$1"
  ! _rubsh.Shell.variable? "$_rubsh_var" || _rubsh.Shell.dereference _rubsh_var

  [[ $_rubsh_var =~ / ]] || { echo "."; return ;}
  _rubsh_var="${_rubsh_var%/}"
  echo "${_rubsh_var%/*}"
}

_rubsh.File.realpath(){
  local _rubsh_var="$1"
  ! _rubsh.Shell.variable? "$_rubsh_var" || _rubsh.Shell.dereference _rubsh_var

  readlink -f "$_rubsh_var"
}

# Same as Array.to_s() but preserves keys.
_rubsh.Hash.to_s() {
    local r

    r=$( declare -p $1 )
    _rubsh.IO.puts "${r#declare\ -a\ *=}"
}

# shellcheck disable=SC2059
_rubsh.IO.printf() { printf "$@" ;}

_rubsh.IO.puts() {
  local _rubsh_var="$1"

  _rubsh.Shell.variable? "$_rubsh_var" || { _rubsh.IO.printf "%s\n" "$*"; return ;}
  _rubsh.Shell.dereference _rubsh_var
  _rubsh.IO.printf "%s\n" "$_rubsh_var"
}

_rubsh.Shell.alias_function() { eval "$1 () { $2 \"\$@\" ;}" ;}

_rubsh.Shell.class() {
  case "$(declare -p "$1" 2>/dev/null)" in
    declare\ -a* )
      printf "array\n"
      ;;
    * )
      printf "string\n"
      ;;
  esac
}

_rubsh.Shell.dereference() {
  local -a _rubsh_ary
  eval _rubsh_ary="$(eval _rubsh.Shell.value "$(_rubsh.Shell.value "$1")")"

  # shellcheck disable=SC2154
  local "$1" && _rubsh.Shell.passback_as "$1" "${_rubsh_ary[@]}"
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
    if unset -v "$1"; then           # Unset & validate varname
        if (( $# == 2 )); then
            eval "$1"=\"\$2\"          # Return single value
        else
            eval "$1"=\(\"\${@:2}\"\)  # Return array
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
                [[ "$2" ]] && unset -v "$2" && eval "$2"=\(\"\${@:3:${1#-a}}\"\) &&
                shift $((${1#-a} + 2)) || { echo "bash: ${FUNCNAME[0]}:"\
                    "\`$1${2+ }$2': missing argument(s)" 1>&2; return 1; }
                ;;
            -v)
                # Assign single value
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

_rubsh.Shell.value()     {
  case "$(_rubsh.Shell.class "$1")" in
    "array" )
      _rubsh.Array.to_s "$1"
      ;;
    * )
      eval echo \"\\\"\$"$1"\\\"\"
      ;;
  esac
}

_rubsh.Shell.variable? () { declare -p "$1" >/dev/null 2>&1 ;}

_rubsh.String.blank? ()  { eval "[[ -z \${$1:-} ]] || [[ \${$1:-} =~ ^[[:space:]]+$ ]]"  ;}

_rubsh.String.chomp() {
  local _rubsh_var="$1"
  _rubsh.Shell.dereference _rubsh_var

  _rubsh_var="${_rubsh_var#"${_rubsh_var%%[![:space:]]*}"}"   # remove leading whitespace characters
  _rubsh_var="${_rubsh_var%"${_rubsh_var##*[![:space:]]}"}"   # remove trailing whitespace characters
  local "$1" && _rubsh.Shell.passback_as "$1" "$_rubsh_var"
}

_rubsh.String.end_with? () {
  _rubsh_var="$1"
  _rubsh.Shell.dereference _rubsh_var
  [[ ${_rubsh_var: -1} == "$2" ]]
}

_rubsh.String.eql? ()    { eval "[[ \${$1:-} == \"$2\" ]]" ;}

_rubsh.String.new() {
  local _rubsh_method
  local _rubsh_methods

  # shellcheck disable=SC2034
  read -d "" -a _rubsh_methods <<EOS
blank?
chomp
end_with?
eql?
present?
start_with?
EOS

  for _rubsh_method in "${_rubsh_methods[@]}"; do
    _rubsh.core.alias_method "$1" "$_rubsh_method" "_rubsh.String"
  done

  (( $# > 1 )) || return 0

  local "$1" && _rubsh.Shell.passback_as "$1" "$2"
}

_rubsh.String.present? () { ! _rubsh.String.blank? "$@" ;}

_rubsh.String.start_with? () {
  _rubsh_var="$1"
  _rubsh.Shell.dereference _rubsh_var
  [[ ${_rubsh_var:0:1} == "$2" ]]
}
