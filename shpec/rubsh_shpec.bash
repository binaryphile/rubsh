source import.bash

shpec_helper_imports=(
  initialize_shpec_helper
  shpec_source
  stop_on_error
)
eval "$(importa shpec-helper shpec_helper_imports)"
initialize_shpec_helper
stop_on_error=true
stop_on_error

shpec_source lib/rubsh.bash

describe ___methodh
  it "catalogues the methods of classes"
    read -r expected <<'    EOS' ||:
      declare -A __methodh='([Object]="set to_s " [Array]="append join " [Class]="new inherit " [Hash]="map " [File]="each write " [Path]="expand_path " )'
    EOS
    assert equal "$expected" "$(declare -p __methodh)"
  end
end

describe __
  it "is blank"
    assert equal 'declare -- __=""' "$(declare -p __)"
  end
end

# describe ___class
#   it "is not set"
#     stop_on_error off
#     declare -p ___class >/dev/null 2>&1
#     assert unequal 0 $?
#     stop_on_error
#   end
# end
#
# describe Class.new
#   it "creates methods"; (
#     Class.new Class sample
#     assert equal $'declare -f sample\ndeclare -f sample.set\ndeclare -f sample.to_s' "$(declare -F | grep sample)"
#     return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
#   end
# end
#
# describe Class.inherit
#   it "creates a method from a list"; (
#     name=sample
#     methods=( example )
#     Class.inherit Class name example
#     assert equal $'declare -f sample\ndeclare -f sample.set\ndeclare -f sample.to_s' "$(declare -F | grep sample)"
#     return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
#   end
# end
