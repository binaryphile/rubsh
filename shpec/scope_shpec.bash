source import.bash

shpec_helper_imports=(
  initialize_shpec_helper
  shpec_cwd
  stop_on_error
)
eval "$(importa shpec-helper shpec_helper_imports)"
initialize_shpec_helper
stop_on_error=true
stop_on_error

source "$(shpec_cwd)"/../lib/rubsh

describe __ruby_scopeh
  it "is a hash"; (
    _shpec_failures=0
    [[ $(declare -p __ruby_scopeh) == 'declare -A'* ]]
    assert equal 0 $?
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end
end
