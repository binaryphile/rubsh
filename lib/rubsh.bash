[[ -n ${_rubsh:-} && -z ${reload:-} ]] && return
[[ -n ${reload:-}                   ]] && { unset -v reload && echo reloaded || return ;}
[[ -z ${_rubsh:-}                   ]] && readonly _rubsh=loaded

unset   -v  __classh __method_classesh __methodsh __method_bodyh __superh __
declare -Ag __classh __method_classesh __methodsh __method_bodyh __superh
__=''

__methodsh=(
  [Class]=' ancestors instance_methods '
  [Object]=' class methods '
)

__superh[Class]=Object

__method_classesh=(
  [ancestors]=' Class '
  [instance_methods]=' Class '
  [class]=' Object '
  [methods]=' Object '
)

for class in Object Class; do
  __classh[$class]=Class
  printf -v statement 'function %s { __dispatch "$@" ;}' "$class"
  eval "$statement"
done
unset -v class statement

defs () { IFS=$'\n' read -rd '' "$1" ||: ;}

defs __method_bodyh[Class.ancestors] <<'end'
  local class=$1
  local ancestors=( $class )

  while [[ " ${!__superh[*]} " == *" $class "* && -n ${__superh[$class]} ]]; do
    class=${__superh[$class]}
    ancestors+=( "$class" )
  done
  __=$(declare -p ancestors)
  __=${__#*=}
  __=${__:1:-1}
end

defs __method_bodyh[Class.instance_methods] <<'end'
  local class=$1
  local inherited=${2:-true}
  local array

  case $inherited in
    'false' ) array=( ${__methodsh[$class]} )            ;;
    'true'  ) __='([0]="ancestors" [1]="class" [2]="methods")'  ;;
    *       ) return 1                                          ;;
  esac
  __=$(declare -p array)
  __=${__#*=}
  __=${__:1:-1}
end

defs __method_bodyh[Object.class] <<'end'
  __=${__classh[$1]}
end

defs __method_bodyh[Object.methods] <<'end'
  local class=$1
  local inherited=${2:-true}

  case $inherited in
    'false' ) __='()'                                                                 ;;
    'true'  ) __='([0]="ancestors" [1]="class" [2]="instance_methods" [3]="methods")' ;;
    *       ) return 1                                                                ;;
  esac
end

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
