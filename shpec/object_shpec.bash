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
source "$RUBSH_PATH"/require.rubsh
$(require object)

describe Object
  describe class
    it "returns the class of the object"; (
      _shpec_failures=0
      Object .new object
      object .class
      assert equal Object "$__values[$__]"
      return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
    end
  end
end
