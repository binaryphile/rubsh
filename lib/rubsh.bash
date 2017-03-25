[[ -n ${_rubsh:-} ]] && return
readonly _rubsh=loaded

unset -v __ __bodyh __methodh __parenth
declare -Ag __bodyh __methodh __parenth
__=''

__methodh[Class]=new
IFS=$'\n' read -rd '' __bodyh[Class.new] <<'end' ||:
  local self=$1
  local statement

  printf -v statement '%s () { :;}' "$self"
  eval "$statement"
  __parenth[$self]=Class
end

Class () {
  local method=$1; shift
  local statement

  [[ ${__methodh[Class]} == *$method* ]] || return
  printf -v statement '__ () { %s ;}; __ "$@"' "${__bodyh[Class.$method]}"
  eval "$statement"
}

# __dispatch () {
#   local class=$1
#   local self=$2
#   local method=$3
#
#   while [[ ${__methodh[$class]} != *$method* && -n ${__parenth[$class]} ]]; do
#     class=${__parenth[$class]}
#   done
#   [[ -n ${__methodh[$class]} ]] || return
#   "$class" "${__methodh[$class]}" "$self"
# }
#
# filename each
# { File filename $method ;}
# File 
# { self=$1; method=$2; shift 2; eval ${bodyh[$self.$method]} ;}

# class () {
#   __class=$1 # global
#   local __parent=${3:-}
#
#   [[ -n $__parent ]] && { __parenth[$__class]=$__parent; return ;}
#   if [[ $__class != 'Object' ]]; then __parenth[$__class]=Object; fi
# }
#
# def () {
#   local method=$1
#   local body=${2:-$(</dev/stdin)}
#   local tmp=()
#
#   eval "$__class.$method () { $body ;}"
#   tmp=( ${__methodh[$__class]} "$method" )
#   __methodh[$__class]=${tmp[*]}
#   __bodyh[$__class.$method]=$body
# }
#
# class Class; {
#   def new <<'  end'
#     local class=$1; shift
#     local self
#
#     for self in "$@"; do
#       [[ -n ${__parenth[$class]} ]] && eval "${__parenth[$class]}".new "$@"
#       __inherit "$class" "$self"
#     done
#   end
# }
#
# class Object , Class; {
#   def set <<'  end'
#     local -n __self=$1; shift
#
#     __=''
#     "$@"
#     eval __self="$__"
#   end
#
#   def to_s <<'  end'
#     local self=$1
#
#     __=$(declare -p "$self" 2>/dev/null) || return
#     __=${__#declare -* $self=}
#   end
# }
#
# class Array; {
#   def append <<'  end'
#     local -n __vals=$1; shift
#     local __statement
#
#     case $# in
#       '0' ) return;;
#       '1' )
#         printf -v __statement '__vals+=( "${%s[@]}" )' "$1"
#         eval "$__statement"
#         ;;
#       * ) "$@"; __vals+=( "${__[@]}" );;
#     esac
#   end
#
#   def join <<'  end'
#     local -n __vals=$1; shift
#     local IFS=$1
#
#     __=${__vals[*]}
#   end
# }
#
# class Hash; {
#   def map <<'  end'
#     local -n __valh=$1
#     local __keyparm=$3
#     local __valparm=$4
#     local __lambda=$5
#     local "$__keyparm"
#     local "$__valparm"
#     local __key
#     local __retvals=()
#     local __statement
#
#     printf -v __statement '__retvals+=( "$(puts "%s")" )' "$__lambda"
#
#     for __key in "${!__valh[@]}"; do
#       printf -v "$__keyparm" '%s' "$__key"
#       printf -v "$__valparm" '%s' "${__valh[$__key]}"
#       eval "$__statement"
#     done
#
#     __=( "${__retvals[@]}" )
#   end
# }
#
# class String
#
# defs () { IFS=$'\n' read -rd '' "$1" ||: ;}
#
# puts () { printf '%s\n' "$1" ;}
#
# class File , Path; {
#   def each <<'  end'
#     local __filename=${!1}
#     local __lineparm=$3
#     local __lambda=${4:-$(</dev/stdin)}
#     local "$__lineparm"
#
#     while read -r "$__lineparm"; do
#       eval "$__lambda"
#     done <"$__filename" ||:
#   end
#
#   def write <<'  end'
#     local __filename=${!1}; shift
#     local __string
#
#     case $# in
#       '0' ) return              ;;
#       '1' ) __string=${!1}      ;;
#       *   ) "$@"; __string=$__  ;;
#     esac
#     puts "$__string" >"$__filename"
#   end
# }
#
# class Path; {
#   def expand_path <<'  end'
#     local __pathname=${!1}
#     local __filename
#
#     unset -v CDPATH
#     [[ -e $__pathname ]] && {
#       __filename=$(basename "$__pathname")
#       __pathname=$(dirname "$__pathname")
#     }
#     [[ -d $__pathname ]] || return
#     __pathname=$(cd "$__pathname"; pwd)
#     __=$__pathname${__filename:+/}${__filename:-}
#   end
# }

[[ -n $shpec_test ]] && return
unset -v __class
unset -f class def
