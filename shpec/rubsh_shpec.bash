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

is_function () { declare -f "$1" >/dev/null ;}

describe Object
  it "is a function"
    is_function Object
    assert equal 0 $?
  end

  describe ancestors
    it "lists an array string of ancestor classes"
      Object ancestors
      assert equal '' "$__"
    end
  end
end

describe Class
  it "is a function"
    is_function Class
    assert equal 0 $?
  end

  describe ancestors
    it "lists an array string of ancestor classes"
      Class ancestors
      assert equal '([0]="Object")' "$__"
    end
  end
end
