source import.bash

shpec_helper_imports=(
  initialize_shpec_helper
  stop_on_error
)
eval "$(importa shpec-helper shpec_helper_imports)"
initialize_shpec_helper
stop_on_error=true
stop_on_error

shpec_test=true
eval "source $shpec_cwd/../lib/rubsh.bash"

