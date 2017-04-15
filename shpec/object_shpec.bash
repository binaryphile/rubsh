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

is_function () { declare -f "$1" >/dev/null 2>&1 ;}

describe Object
  it "is a function"
    is_function Object
    assert equal 0 $?
  end

  it "has class Class"
    Object .class
    assert equal 'Class' "${!__}"
  end

  it "has a numeric object id"
    Object .object_id
    (( ${!__} + 1 ))
    assert equal 0 $?
  end

  it "has no superclass"
    Object .superclass
    assert equal 'nil' "${!__}"
  end
end
