[[ -n ${_rubsh:-} && -z ${reload:-} ]] && return
[[ -n ${reload:-}                   ]] && { unset -v reload && echo reloaded || return ;}
[[ -z ${_rubsh:-}                   ]] && readonly _rubsh=loaded

unset   -v  __classh __method_classesh __methodsh __method_bodyh __superh __ __class
declare -Ag __classh __method_classesh __methodsh __method_bodyh __superh

class () {
  __class=$1 # global
  local super=${3:-}
  local statement

  printf -v statement 'function %s { __dispatch "$@" ;}' "$__class"
  eval "$statement"
  __classh[$__class]=Class
  [[ -z $super ]] && return
  [[ " ${!__superh[*]} " != *" $__class "* ]] || return
  __superh[$__class]=$super
}

def () {
  local method=$1
  local body=${2:-$(</dev/stdin)}

  __methodsh[$__class]+="$method "
  __method_classesh[$method]+=" $__class "
  __method_bodyh[$__class.$method]=$body
}

class Object; {
  def class '__=${__classh[$1]}'

  def methods <<'  end'
    local self=$1
    local inherited=${2:-true}
    local class=${__classh[$self]}
    local methods=()

    case $inherited in
      'false' ) ;;
      'true'  )
        methods=( ${__methodsh[$class]} )
        while [[ " ${!__superh[*]} " == *" $class "* && -n ${__superh[$class]} ]]; do
          class=${__superh[$class]}
          methods+=( ${__methodsh[$class]} )
        done
        ;;
      * ) return 1;;
    esac
    __ary_to_str methods
  end
}

class Class , Object; {
  def ancestors <<'  end'
    local class=$1
    local ancestors=( $class )

    while [[ " ${!__superh[*]} " == *" $class "* && -n ${__superh[$class]} ]]; do
      class=${__superh[$class]}
      ancestors+=( "$class" )
    done
    __ary_to_str ancestors
  end

  def instance_methods <<'  end'
    local class=$1
    local inherited=${2:-true}
    local instance_methods=( ${__methodsh[$class]} )

    case $inherited in
      'false' ) ;;
      'true'  )
        while [[ " ${!__superh[*]} " == *" $class "* && -n ${__superh[$class]} ]]; do
          class=${__superh[$class]}
          instance_methods+=( ${__methodsh[$class]} )
        done
        ;;
      * ) return 1;;
    esac
    __ary_to_str instance_methods
  end

  def new <<'  end'
    local class=$1
    local self=$2
    local statement

    printf -v statement 'function %s { __dispatch "$@" ;}' "$self"
    eval "$statement"
    __classh[$self]=$class
  end

  def superclass <<'  end'
    local class=$1

    [[ " ${!__superh[*]} " == *" $class " ]] && { __=${__superh[$class]}; return ;}
    __=''
  end
}

class Array; {
  def append <<'  end'
    local -n __vals=$1; shift
    local __statement

    case $# in
      '0' ) return;;
      '1' )
        printf -v __statement '__vals+=( "${%s[@]}" )' "$1"
        eval "$__statement"
        ;;
      * ) "$@"; __vals+=( "${__[@]}" );;
    esac
  end

  def set <<'  end'
    local -n __vals=$1; shift
    local __statement

    case $# in
      '0' ) return;;
      '1' )
        printf -v __statement '__vals=( "${%s[@]}" )' "$1"
        eval "$__statement"
        ;;
      * ) "$@"; __vals=( "${__[@]}" );;
    esac
  end

  def join <<'  end'
    local -n __vals=$1; shift
    local IFS=$1

    __=${__vals[*]}
  end
}

class Hash; {
  def set <<'  end'
    local -n __valh=$1; shift

    case $# in
      '0' ) return          ;;
      '1' ) Hash to_s "$1"  ;;
      *   ) "$@"            ;;
    esac
    eval __valh="$__"
  end

  def map <<'  end'
    local -n __valh=$1
    local __keyparm=$3
    local __valparm=$4
    local __lambda=$5
    local "$__keyparm"
    local "$__valparm"
    local __key
    local __retvals=()
    local __statement

    printf -v __statement '__retvals+=( "$(echo "%s")" )' "$__lambda"

    for __key in "${!__valh[@]}"; do
      printf -v "$__keyparm" '%s' "$__key"
      printf -v "$__valparm" '%s' "${__valh[$__key]}"
      eval "$__statement"
    done

    __ary_to_str __retvals
  end

  def to_s '__ary_to_str "$1"'
}

class String; {
  def set <<'  end'
    local __val=$1; shift

    case $# in
      '0' ) return                              ;;
      '1' ) printf -v "$__val" '%s' "${!1}"     ;;
      *   ) "$@"; printf -v "$__val" '%s' "$__" ;;
    esac
  end
}

puts () { ( IFS=; printf '%s\n' "$*" ) }

class File , Path; {
  def each <<'  end'
    local __filename=${!1}
    local __lineparm=$3
    local __lambda=${4:-$(</dev/stdin)}
    local "$__lineparm"

    while read -r "$__lineparm"; do
      eval "$__lambda"
    done <"$__filename" ||:
  end

  def write <<'  end'
    local __filename=${!1}; shift
    local __string

    case $# in
      '0' ) return              ;;
      '1' ) __string=${!1}      ;;
      *   ) "$@"; __string=$__  ;;
    esac
    echo "$__string" >"$__filename"
  end
}

class Path , String; {
  def expand_path <<'  end'
    local __pathname=${!1}
    local __filename

    unset -v CDPATH
    [[ -e $__pathname ]] && {
      __filename=$(basename "$__pathname")
      __pathname=$(dirname "$__pathname")
    }
    __pathname=$(cd "$__pathname" && pwd) || return
    __=$pathname${filename:+/}${filename:-}
  end
}

__ary_to_str () {
  __=$(declare -p "$1")
  __=${__#*=}
  __=${__:1:-1}
}

__dispatch () {
  local method=$1; shift
  local receiver=${FUNCNAME[1]}
  local class=${__classh[$receiver]}
  local statement

  while [[ ${__method_classesh[$method]} != *" $class "* ]]; do
    [[ " ${!__superh[*]} " == *" $class "* && -n ${__superh[$class]} ]] || return
    class=${__superh[$class]}
  done
  [[ " ${!__method_bodyh[*]} " == *" $class.$method "* && -n ${__method_bodyh[$class.$method]} ]] || return
  printf -v statement 'function __ { %s ;}; __ "$receiver" "$@"' "${__method_bodyh[$class.$method]}"
  eval "$statement"
}
