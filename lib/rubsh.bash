[[ -n ${_rubsh-} && -z ${reload-} ]] && return
[[ -n ${reload-}                  ]] && { unset -v reload && echo reloaded || return ;}
[[ -z ${_rubsh-}                  ]] && readonly _rubsh=loaded

set -f

unset   -v  __classh __method_classesh __methodsh __method_bodyh __superh __ __class __a __h __s
declare -Ag __classh __method_classesh __methodsh __method_bodyh __superh __h
__a=()

class () {
  __class=$1 # global
  local super=${3-String}
  local statement

  [[ -z ${2-}  || $2 == ':' ]] || return
  [[ -n $super ]] && {
    ! declare -f "$__class" >/dev/null 2>&1 || return
      declare -f "$super"   >/dev/null 2>&1 || return
    __superh[$__class]=$super
  }
  printf -v statement 'function %s { __dispatch "$@" ;}' "$__class"
  eval "$statement"
  __classh[$__class]=Class
  __methodsh[$__class]=' '
  __classh[__]=String
  __='""'
}

def () {
  local method=$1
  local body=${2-$(</dev/stdin)}

  __methodsh[$__class]+="$method "
  [[ -z ${__method_classesh[$method]-} ]] && __method_classesh[$method]=' '
  __method_classesh[$method]+="$__class "
  __method_bodyh[$__class.$method]=$body
  __classh[__]=String
  __='""'
}

class Object : ''; {
  def class << '  end'
    __=${__classh[$1]}
    __=$(declare -p __)
    __=${__#*=}
    __classh[__]=String
  end

  def methods <<'  end'
    local self=$1
    local inherited=${2-true}
    local class=${__classh[$self]}
    local methods=()

    case $inherited in
      'false' ) ;;
      'true'  )
        methods=( ${__methodsh[$class]} )
        while [[ -n ${__superh[$class]-} ]]; do
          class=${__superh[$class]}
          methods+=( ${__methodsh[$class]} )
        done
        ;;
      * ) return 1;;
    esac
    __inspect methods
    __classh[__]=Array
  end
}

class Class : Object; {
  def ancestors <<'  end'
    local class=$1
    local ancestors=( $class )

    while [[ -n ${__superh[$class]-} ]]; do
      class=${__superh[$class]}
      ancestors+=( "$class" )
    done
    __inspect ancestors
    __classh[__]=Array
  end

  def declare <<'  end'
    local class=$1
    local self=$2; shift 2
    local value=${1-}
    local format

    ! declare -f "$self" >/dev/null 2>&1 || return
    value=$(declare -p value)
    value=${value#*=}
    case $class in
      'Array' ) printf 'eval declare -a %s=%s; %s .new %s\n' "$self" "${value:1:-1}" "$class" "$self" ;;
      'Hash'  ) printf 'eval declare -A %s=%s; %s .new %s\n' "$self" "${value:1:-1}" "$class" "$self" ;;
      *       ) printf 'eval declare -- %s=%s; %s .new %s\n' "$self" "$value"        "$class" "$self" ;;
    esac
    __=$value
    __classh[__]=String
  end

  def instance_methods <<'  end'
    local class=$1
    local inherited=${2-true}
    local instance_methods=( ${__methodsh[$class]} )

    case $inherited in
      'false' ) ;;
      'true'  )
        while [[ -n ${__superh[$class]-} ]]; do
          class=${__superh[$class]}
          instance_methods+=( ${__methodsh[$class]} )
        done
        ;;
      * ) return 1;;
    esac
    __inspect instance_methods
    __classh[__]=Array
  end

  def new <<'  end'
    local class=$1
    local self=$2; shift 2
    local value=${1-}
    local format
    local stdout
    local statement

    printf -v statement 'function %s { __dispatch "$@" ;}' "$self"
    eval "$statement"
    [[ $class == 'Class' ]] && __superh[$self]=Object
    __classh[$self]=$class
    __=''
    [[ -z $value ]] && return
    declare -f "$value" >/dev/null 2>&1 && {
      "$@"
      value=$__
    }
    case $value in
      '('* ) format='%s=%s';;
         * ) format='%s=%q';;
    esac
    printf -v statement "$format" "$self" "$value"
    eval "$statement"
    __=$value
    __classh[__]=String
  end

  def superclass <<'  end'
    local class=$1

    __=${__superh[$class]-}
    __classh[__]=String
  end
}

class Array : Object; {
  def concat <<'  end'
    local -n __vals=$1; shift
    local __results=()
    local __statement

    "$@"
    eval __results="$__"
    __vals+=( "${__results[@]}" )
    __inspect __vals
    __=${__:1:-1}
    __inspect "$__"
    __classh[__]=Array
  end

  def inspect <<'  end'
    __=$(declare -p "$1" 2>/dev/null) || return
    __=${__#*=}
    __=${__:1:-1}
    __classh[__]=Array
  end

  def join <<'  end'
    local -n __vals=$1
    local IFS=${2- }

    __=${__vals[*]}
    __classh[__]=String
  end

  def to_s <<'  end'
    __=$(declare -p "$1" 2>/dev/null) || return
    __=${__#*=}
    __=${__:1:-1}
    __classh[__]=String
  end
}

class Hash : Object; {
  def = <<'  end'
    local -n __self=$1; shift
    local statement

    { declare -f "$1" >/dev/null 2>&1 && [[ " ${!__classh[*]} " == *" $1 "* ]] ;} && {
      "$@"
      eval __self="$__"
      return
    }
    eval __self="$1"
    __=$1
    __classh[__]=String
  end

  def inspect <<'  end'
    __=$(declare -p "$1" 2>/dev/null) || return
    __=${__#*=}
    __=${__:1:-1}
    __classh[__]=Hash
  end

  def map <<'  end'
    local -n __valh=$1
    local __keyparm=$3
    local __valparm=$4
    local __lambda=${5-$(</dev/stdin)}
    local "$__keyparm"
    local "$__valparm"
    local __key
    local __retvals=()
    local __statement

    [[ $2 == 'do' ]] && __lambda=${__lambda#${__lambda%%[![:space:]]*}}
    printf -v __statement '__retvals+=( "$(puts "%s")" )' "$__lambda"

    for __key in "${!__valh[@]}"; do
      printf -v "$__keyparm" '%s' "$__key"
      printf -v "$__valparm" '%s' "${__valh[$__key]}"
      eval "$__statement"
    done

    __inspect __retvals
    __classh[__]=Array
  end

  def to_s <<'  end'
    __=$(declare -p "$1" 2>/dev/null) || return
    __=${__#*=}
    __=${__:1:-1}
    __classh[__]=String
  end
}

class String : Object; {
  def = <<'  end'
    local -n __self=$1; shift

    unset -v __
    { declare -f "$1" >/dev/null 2>&1 && [[ " ${!__classh[*]} " == *" $1 "* ]] ;} && {
      "$@"
      eval __self="$__"
      __classh[__]=String
      return
    }
    __self=$1
    __=$1
    __classh[__]=String
  end

  def inspect <<'  end'
    __=$(declare -p "$1" 2>/dev/null) || return
    __=${__#*=}
    __classh[__]=String
  end

  def to_s <<'  end'
    __=$(declare -p "$1" 2>/dev/null) || return
    __=${__#*=}
    __=${__:1:-1}
    __classh[__]=String
  end

  def upcase <<'  end'
    __=${!1^^}
    __classh[__]=String
  end

  def upcase! <<'  end'
    local -n __self=$1

    __self=${__self^^}
    __=$__self
    __classh[__]=String
  end
}

puts () {
  { declare -f "$1" >/dev/null 2>&1 && [[ " ${!__classh[*]} " == *" $1 "* ]] ;} && {
    "$1" .to_s
    printf '%s\n' "$__"
    return
  }
  printf '%s\n' "$@"
  __='""'
  __classh[__]=String
}

__dispatch () {
  local method=${1-.inspect}; shift ||:
  local receiver=${FUNCNAME[1]}
  local class=${__classh[$receiver]}
  local anon
  local i
  local rest=()
  local statement

  [[ $method != '.'* ]] && {
    case $method in
      '=' ) method=.=;;
      *   )
        case ${1-} in
          '='   ) set -- "$method" "${@:2}"; method=.new     ;;
          ':='  ) set -- "$method" "${@:2}"; method=.declare ;;
          * )
            [[ $class == 'Class' ]] || return
            case $receiver in
              'Array' ) anon=__a  ;;
              'Hash'  ) anon=__h  ;;
              *       ) anon=__s  ;;
            esac
            set -- "$anon" "$@"
            "$receiver" .new "$anon" "$method"
            "$@"
            return
            ;;
          * ) return 1;;
        esac
        ;;
    esac
  }
  method=${method#.}
  while [[ ${__method_classesh[$method]} != *" $class "* ]]; do
    [[ -n ${__superh[$class]-} ]] || return
    class=${__superh[$class]}
  done
  [[ -n ${__method_bodyh[$class.$method]-} ]] || return
  [[ ${1-} == '{' ]] && {
    for (( i = 1; i <= $#; i++ )); do
      [[ ${!i} == '}' ]] && break;
    done
    [[ ${!i} == '}' ]] || return
    rest=( "${@:i+1}" )
    set -- "${@:2:i-2}"
  }
  printf -v statement 'function __ { %s ;}; __ "$receiver" "$@"' "${__method_bodyh[$class.$method]}"
  eval "$statement"
  ! (( ${#rest[@]} )) && return
  "${__classh[__]-}" "$__" "${rest[@]}"
}

__inspect () {
  __=$(declare -p "$1" 2>/dev/null) || return
  __=${__#*=}
  if [[ $__ == \'* ]]; then __=${__:1:-1}; fi
}
