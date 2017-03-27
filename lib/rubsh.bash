[[ -n ${_rubsh:-} && -z ${reload:-} ]] && return
[[ -n ${reload:-}                   ]] && { unset -v reload && echo reloaded || return ;}
[[ -z ${_rubsh:-}                   ]] && readonly _rubsh=loaded

unset   -v  __classh __method_bodyh __
declare -Ag __classh __method_bodyh
__=''

defs () { IFS=$'\n' read -rd '' "$1" ||: ;}

defs __method_bodyh[Object.ancestors] <<'end'
  __='([0]="Object")'
end

defs __method_bodyh[Object.class] <<'end'
  __=${__classh[Object]}
end

defs __method_bodyh[Object.methods] <<'end'
  local cls=$1
  local show_inherited=${2:-true}

  case $show_inherited in
    'false' ) __='()'                                           ;;
    'true'  ) __='([0]="ancestors" [1]="class" [2]="methods")'  ;;
    *       ) return 1                                          ;;
  esac
end

defs __method_bodyh[Class.ancestors] <<'end'
  __='([0]="Class" [1]="Object")'
end

defs __method_bodyh[Class.methods] <<'end'
  local cls=$1
  local show_inherited=${2:-true}

  case $show_inherited in
    'false' ) __='()'                                           ;;
    'true'  ) __='([0]="ancestors" [1]="class" [2]="methods")'  ;;
    *       ) return 1                                          ;;
  esac
end

__dispatch () {
  local method=$1; shift
  local self=${FUNCNAME[1]}
  local statement

  printf -v statement 'function __ { %s ;}; __ "$self" "$@"' "${__method_bodyh[$self.$method]}"
  eval "$statement"
}

for class in Object Class; do
  __classh[$class]=Class
  printf -v statement 'function %s { __dispatch "$@" ;}' "$class"
  eval "$statement"
done
unset -v class statement
