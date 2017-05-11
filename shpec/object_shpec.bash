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

export RUBSH_PATH=$(shpec_cwd)/../lib
source "$RUBSH_PATH"/keywords.rubsh
$(require object)

function? () { declare -f "$1" >/dev/null 2>&1 ;}

describe Object
  describe class
    it "returns the class of the object"; (
      _shpec_failures=0
      Object .new sample
      sample .class
      assert equal object "$__"
      return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
    end
  end

  describe methods
    it "has a return type of Array"; (
      _shpec_failures=0
      Object .new sample
      sample .methods
      assert equal array "${__typeh[$__]}"
      return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
    end

    it "has a return class of Array"; (
      _shpec_failures=0
      Object .new sample
      sample .methods
      assert equal array "${__classh[$__]}"
      return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
    end

    it "lists the first three methods"; (
      _shpec_failures=0
      Object .new sample
      sample .methods
      local -n array=$__
      expecteds=(
        class
        methods
        puts
      )
      IFS=$'\n'
      assert equal "${expecteds[*]}" "$(echo "${array[*]:0:3}" | sort)"
      return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
    end
  end

  describe puts
    it "returns nil"; (
      _shpec_failures=0
      Object .new sample
      sample .puts "hello" >/dev/null
      assert equal nil "$__"
      return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
    end

    it "echos a single argument"; (
      _shpec_failures=0
      Object .new sample
      assert equal hello "$(sample .puts hello)"
      return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
    end

    it "echos multiple arguments joined with a newline"; (
      _shpec_failures=0
      Object .new sample
      assert equal $'hello\nthere' "$(sample .puts hello there)"
      return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
    end
  end
end
