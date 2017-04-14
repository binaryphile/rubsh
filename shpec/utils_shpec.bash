source import.bash

shpec_helper_imports=(
  initialize_shpec_helper
  shpec_cwd
  shpec_cleanup
  stop_on_error
)
eval "$(importa shpec-helper shpec_helper_imports)"
initialize_shpec_helper
stop_on_error=true
stop_on_error

source "$(shpec_cwd)"/../lib/rubsh.bash

is_function () { declare -f "$1" >/dev/null 2>&1 ;}
