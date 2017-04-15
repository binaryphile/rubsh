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

describe self
  describe main
    it "returns 'main'"
      self
      assert equal '"main"' "$__"
    end

    it "is of class Object"
      self .class
      assert equal '"Object"' "$__"
    end
  end
end