[[ -n ${_rubsh:-} && -z ${reload:-} ]] && return
[[ -n ${reload:-}                   ]] && { unset -v reload && echo reloaded || return ;}
[[ -z ${_rubsh:-}                   ]] && readonly _rubsh=loaded

