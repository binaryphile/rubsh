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

export RUBSH_PATH="$(shpec_cwd)"/../lib
source "$RUBSH_PATH"/keywords.rubsh

$(require class)
$(require object)

function? () { declare -f "$1" >/dev/null 2>&1 ;}

describe Object
  # describe new
  #   it "creates a new instance"; (
  #     _shpec_failures=0
  #     Object .new object
  #     function? object
  #     assert equal 0 $?
  #     return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  #   end
  # end

  describe class
    it "returns the class of the object"; (
      _shpec_failures=0
      Object .new object
      object .class
      assert equal object "$__"
      return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
    end
  end
end
