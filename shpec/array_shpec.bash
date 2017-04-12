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

source "$(shpec_cwd)"/../lib/rubsh.bash

describe Array
  describe concat
    it "concatenates an array with this one"; (
      _shpec_failures=0
      Array .new samples '( zero one   )'
      Array .new example '( two  three )'
      samples .concat example
      assert equal 'declare -a samples='\''([0]="zero" [1]="one" [2]="two" [3]="three")'\' "$(declare -p samples)"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "returns the concatenation"; (
      _shpec_failures=0
      Array .new samples '( zero one   )'
      Array .new example '( two  three )'
      samples .concat example
      assert equal '([0]="zero" [1]="one" [2]="two" [3]="three")' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end
  end

  describe join
    it "joins array elements into a string"; (
      _shpec_failures=0
      Array .new samples '( zero one )'
      samples .join -
      assert equal 'zero-one' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end
  end

  describe to_s
    it "returns a string interpretation of an array"; (
      _shpec_failures=0
      Array .new samples '( zero one )'
      samples .to_s
      assert equal '([0]="zero" [1]="one")' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end
  end
end
