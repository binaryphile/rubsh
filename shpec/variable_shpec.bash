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

describe "a variable"
  it "can have an object assigned to it"
    Object .new sample
    sample .object_id
    assert equal 0 "$__"
  end
end
