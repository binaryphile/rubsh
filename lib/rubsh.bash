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
  def class <<'  end'
    __=${__classh[$1]}
  end

  def methods <<'  end'
    local self=$1
    local inherited=${2:-true}
    local array=( ${__methodsh[$__classh[$self]]} )

    case $inherited in
      'false' ) __ary_to_str array ;;
      'true'  ) __='([0]="ancestors" [1]="class" [2]="instance_methods" [3]="methods")' ;;
      *       ) return 1                                                                ;;
    esac
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
    local array

    case $inherited in
      'false' ) array=( ${__methodsh[$class]} )            ;;
      'true'  ) __='([0]="ancestors" [1]="class" [2]="methods")'  ;;
      *       ) return 1                                          ;;
    esac
    __ary_to_str array
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
