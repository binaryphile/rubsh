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

describe Class
  it "is a function"
    is_function Class
    assert equal 0 $?
  end

  it "is a variable"
    assert equal class "$Class"
  end

  it "has a super of Object"
    assert equal Object "${__superh[$Class]}"
  end
end

describe ancestors
  it "lists an array string of Class ancestor classes, starting with the class itself"
    Class .ancestors
    assert equal 'Class Object' "$__a"
  end

  it "lists an array string of Object ancestor classes"
    Object .ancestors
    assert equal '([0]="Object")' "$__"
  end
end

describe instance_methods
  it "lists an array string of Class instance methods"
    Class .instance_methods
    assert equal '([0]="ancestors" [1]="declare" [2]="instance_methods" [3]="new" [4]="superclass" [5]="class" [6]="methods")' "$__"
  end

  it "only lists Class methods defined on it when given false"
    Class .instance_methods false
    assert equal '([0]="ancestors" [1]="declare" [2]="instance_methods" [3]="new" [4]="superclass")' "$__"
  end

  it "lists an array string of Object instance methods"
    Object .instance_methods
    assert equal '([0]="class" [1]="methods")' "$__"
  end

  it "only lists Object methods defined on it when given false"
    Object .instance_methods false
    assert equal '([0]="class" [1]="methods")' "$__"
  end
end

describe new
  describe Class
    it "creates a function"; (
      _shpec_failures=0
      Class .new Myclass
      is_function Myclass
      assert equal 0 $?
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "creates a function with the assignment syntax"; (
      _shpec_failures=0
      Class Myclass =
      is_function Myclass
      assert equal 0 $?
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "fails on other than := or ="; (
      _shpec_failures=0
      stop_on_error off
      Class Myclass a
      assert unequal 0 $?
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "is of the class of the receiver"; (
      _shpec_failures=0
      Class .new Myclass
      Myclass .class
      assert equal '"Class"' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "is of the class of the receiver with assignment syntax"; (
      _shpec_failures=0
      Class Myclass =
      Myclass .class
      assert equal '"Class"' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "has the instance methods of the class"; (
      _shpec_failures=0
      Class .new Myclass
      Myclass .methods
      methods=$__
      Class .instance_methods
      assert equal "$methods" "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "has the instance methods of the class with assignment syntax"; (
      _shpec_failures=0
      Class Myclass =
      Myclass .methods
      methods=$__
      Class .instance_methods
      assert equal "$methods" "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "has the superclass Object"; (
      _shpec_failures=0
      Class .new Myclass
      Myclass .superclass
      assert equal '"Object"' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "has the superclass Object with assignment syntax"; (
      _shpec_failures=0
      Class Myclass =
      Myclass .superclass
      assert equal '"Object"' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "returns nothing"; (
      _shpec_failures=0
      unset -v __
      Class .new Myclass
      assert equal '' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "returns nothing with assignment syntax"; (
      _shpec_failures=0
      unset -v __
      Class Myclass =
      assert equal '' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end
  end

  describe Object
    it "is of the class of the receiver"; (
      _shpec_failures=0
      Object .new sample
      sample .class
      assert equal '"Object"' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "is of the class of the receiver with assignment syntax"; (
      _shpec_failures=0
      Object sample =
      sample .class
      assert equal '"Object"' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "has the instance methods of the class"; (
      _shpec_failures=0
      Object .new sample
      sample .methods
      methods=$__
      Object .instance_methods
      assert equal "$methods" "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "has the instance methods of the class with assignment syntax"; (
      _shpec_failures=0
      Object sample =
      sample .methods
      methods=$__
      Object .instance_methods
      assert equal "$methods" "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end
  end

  describe Array
    it "creates a function"; (
      _shpec_failures=0
      Array .new samples
      is_function samples
      assert equal 0 $?
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "creates a function with assignment syntax"; (
      _shpec_failures=0
      Array samples =
      is_function samples
      assert equal 0 $?
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "is of the class of the receiver"; (
      _shpec_failures=0
      Array .new samples
      samples .class
      assert equal '"Array"' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "is of the class of the receiver with assignment syntax"; (
      _shpec_failures=0
      Array samples =
      samples .class
      assert equal '"Array"' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "has the instance methods of the class"; (
      _shpec_failures=0
      Array .new samples
      samples .methods
      methods=$__
      Array .instance_methods
      assert equal "$methods" "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "has the instance methods of the class with assignment syntax"; (
      _shpec_failures=0
      Array samples =
      samples .methods
      methods=$__
      Array .instance_methods
      assert equal "$methods" "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "takes a literal initializer"; (
      _shpec_failures=0
      Array .new samples '( zero one )'
      assert equal 'declare -a samples='\''([0]="zero" [1]="one")'\' "$(declare -p samples)"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "takes a literal initializer with assignment syntax"; (
      _shpec_failures=0
      Array samples = '( zero one )'
      assert equal 'declare -a samples='\''([0]="zero" [1]="one")'\' "$(declare -p samples)"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "returns an assigned value unchanged"; (
      _shpec_failures=0
      Array .new samples '( zero one )'
      assert equal '( zero one )' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "returns an assigned value unchanged with assignment syntax"; (
      _shpec_failures=0
      Array samples = '( zero one )'
      assert equal '( zero one )' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "generates an eval string from a literal initializer"; (
      _shpec_failures=0
      result=$(Array .declare samples '( zero one )')
      assert equal 'eval declare -a samples=( zero one ); Array .new samples' "$result"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "generates an eval string from a literal initializer with assignment syntax"; (
      _shpec_failures=0
      result=$(Array samples := '( zero one )')
      assert equal 'eval declare -a samples=( zero one ); Array .new samples' "$result"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "allows evaluation of method calls as arguments"; (
      _shpec_failures=0
      Array .new samples '( zero one )'
      Array .new results samples
      assert equal 'declare -a results='\''([0]="zero" [1]="one")'\' "$(declare -p results)"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "allows evaluation of method calls as arguments with assignment syntax"; (
      _shpec_failures=0
      Array samples = '( zero one )'
      Array results = samples
      assert equal 'declare -a results='\''([0]="zero" [1]="one")'\' "$(declare -p results)"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end
  end

  describe Hash
    it "takes a literal initializer"; (
      _shpec_failures=0
      declare -A sampleh
      Hash .new sampleh '( [zero]=0 [one]=1 )'
      assert equal 'declare -A sampleh='\''([one]="1" [zero]="0" )'\' "$(declare -p sampleh)"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "takes a literal initializer with assignment syntax"; (
      _shpec_failures=0
      declare -A sampleh
      Hash sampleh = '( [zero]=0 [one]=1 )'
      assert equal 'declare -A sampleh='\''([one]="1" [zero]="0" )'\' "$(declare -p sampleh)"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "generates an eval string from a literal initializer"; (
      _shpec_failures=0
      result=$(Hash .declare sampleh '( [zero]=0 [one]=1 )')
      assert equal 'eval declare -A sampleh=( [zero]=0 [one]=1 ); Hash .new sampleh' "$result"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "generates an eval string from a literal initializer with assignment syntax"; (
      _shpec_failures=0
      result=$(Hash sampleh := '( [zero]=0 [one]=1 )')
      assert equal 'eval declare -A sampleh=( [zero]=0 [one]=1 ); Hash .new sampleh' "$result"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "allows evaluation of method calls as arguments"; (
      _shpec_failures=0
      declare -A sampleh resulth
      Hash .new sampleh '( [zero]=0 [one]=1 )'
      Hash .new resulth sampleh
      assert equal 'declare -A resulth='\''([one]="1" [zero]="0" )'\' "$(declare -p resulth)"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "allows evaluation of method calls as arguments with assignment syntax"; (
      _shpec_failures=0
      declare -A sampleh resulth
      Hash sampleh = '( [zero]=0 [one]=1 )'
      Hash resulth = sampleh
      assert equal 'declare -A resulth='\''([one]="1" [zero]="0" )'\' "$(declare -p resulth)"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end
  end

  describe String
    it "takes a literal initializer"; (
      _shpec_failures=0
      String .new sample "an example"
      assert equal 'declare -- sample="an example"' "$(declare -p sample)"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "takes a literal initializer with assignment syntax"; (
      _shpec_failures=0
      String sample = "an example"
      assert equal 'declare -- sample="an example"' "$(declare -p sample)"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "generates an eval string from a literal initializer"; (
      _shpec_failures=0
      result=$(String .declare sample "an example")
      assert equal 'eval declare -- sample="an example"; String .new sample' "$result"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "generates an eval string from a literal initializer with assignment syntax"; (
      _shpec_failures=0
      result=$(String sample := "an example")
      assert equal 'eval declare -- sample="an example"; String .new sample' "$result"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "allows evaluation of method calls as arguments"; (
      _shpec_failures=0
      String .new sample "an example"
      String .new result sample
      assert equal '"an example"' "$result"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "allows evaluation of method calls as arguments with assignment syntax"; (
      _shpec_failures=0
      String sample = "an example"
      String result = sample
      assert equal '"an example"' "$result"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "allows reassigning an existing object variable"; (
      _shpec_failures=0
      String .new sample "an example"
      String .new sample "another example"
      assert equal 'another example' "$sample"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end
  end
end

describe superclass
  it "gives the superclass of Class as Object"
    Class .superclass
    assert equal '"Object"' "$__"
  end

  it "gives the superclass of Object as empty string"
    Object .superclass
    assert equal '""' "$__"
  end
end
