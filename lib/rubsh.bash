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
