source import.bash

shpec_helper_imports=(
  initialize_shpec_helper
  shpec_cwd
  shpec_cleanup
  stop_on_error
)
eval "$(importa shpec-helper shpec_helper_imports)"
initialize_shpec_helper
stop_on_error=true
stop_on_error

source "$(shpec_cwd)"/../lib/rubsh.bash

is_function () { declare -f "$1" >/dev/null 2>&1 ;}

describe class
  it "sets __class"; (
    _shpec_failures=0
    class Sample
    assert equal Sample "$__class"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "fails if the inheritance operator is not :"; (
    _shpec_failures=0
    stop_on_error off
    class Sample , Class
    assert unequal 0 $?
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "fails if the superclass is given but the class already exists as a function"; (
    _shpec_failures=0
    Sample () { :;}
    stop_on_error off
    class Sample : Class
    assert unequal 0 $?
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "fails if the superclass is given but doesn't already exist as a function"; (
    _shpec_failures=0
    unset -f Test
    stop_on_error off
    class Sample : Test
    assert unequal 0 $?
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "tracks the superclass"; (
    _shpec_failures=0
    Test () { :;}
    class Sample : Test
    assert equal Test "${__superh[Sample]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "creates the class function"; (
    _shpec_failures=0
    class Sample
    is_function Sample
    assert equal 0 $?
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "sets the class to Class"; (
    _shpec_failures=0
    class Sample
    assert equal Class "${__classh[Sample]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "returns nothing"; (
    _shpec_failures=0
    unset -v __
    class Sample
    assert equal '""' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end

describe def
  it "tracks the method's class"; (
    _shpec_failures=0
    class Sample
    def sample ''
    assert equal ' sample ' "${__methodsh[Sample]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "tracks the class of the method"; (
    _shpec_failures=0
    class Sample
    def sample ''
    assert equal ' Sample ' "${__method_classesh[sample]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "records the method body"; (
    _shpec_failures=0
    class Sample
    def sample 'example'
    assert equal example "${__method_bodyh[Sample.sample]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "records the method body given as a heredoc"; (
    _shpec_failures=0
    class Sample
    def sample <<'    end'
      example
    end
    assert equal '      example' "${__method_bodyh[Sample.sample]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "returns nothing"; (
    _shpec_failures=0
    unset -v __
    class Sample
    def sample ''
    assert equal '""' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end

describe Object
  it "is a function"
    is_function Object
    assert equal 0 $?
  end

  it "has no super"
    [[ -z ${__superh[Object]-} ]]
    assert equal 0 $?
  end

  describe class
    it "Object is class Class"
      Object .class
      assert equal '"Class"' "$__"
    end

    it "Class is class Class"
      Class .class
      assert equal '"Class"' "$__"
    end
  end

  describe methods
    it "lists an array string of Object methods"
      Object .methods
      assert equal '([0]="ancestors" [1]="declare" [2]="instance_methods" [3]="new" [4]="superclass" [5]="class" [6]="methods")' "$__"
    end

    it "only lists Object methods defined on it when given false"
      Object .methods false
      assert equal '()' "$__"
    end

    it "lists an array string of Class methods"
      Class .methods
      assert equal '([0]="ancestors" [1]="declare" [2]="instance_methods" [3]="new" [4]="superclass" [5]="class" [6]="methods")' "$__"
    end

    it "only lists Class methods defined on it when given false"
      Class .methods false
      assert equal '()' "$__"
    end
  end
end

describe Class
  it "is a function"
    is_function Class
    assert equal 0 $?
  end

  it "has a super of Object"
    assert equal Object "${__superh[Class]}"
  end

  describe ancestors
    it "lists an array string of Class ancestor classes, starting with the class itself"
      Class .ancestors
      assert equal '([0]="Class" [1]="Object")' "$__"
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
end

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

describe Hash
  describe =
    it "sets the associated variable with a literal string"; (
      _shpec_failures=0
      declare -A sampleh
      Hash .new sampleh '( [zero]=0 )'
      sampleh .= '( [one]=1 )'
      assert equal 'declare -A sampleh='\''([one]="1" )'\' "$(declare -p sampleh)"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "sets the associated variable with the output left in __ by the last command"; (
      _shpec_failures=0
      declare -A sampleh resulth
      Hash .new sampleh '( [zero]=0 )'
      Hash .new resulth '( [one]=1 )'
      sampleh .= resulth
      assert equal 'declare -A sampleh='\''([one]="1" )'\' "$(declare -p sampleh)"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end
  end

  describe map
    it "returns an array of values mapped with a normal block"; (
      _shpec_failures=0
      declare -A sampleh
      Hash .new sampleh '( [zero]=0 [one]=1 )'
      sampleh .map [ {k,v} '$k: $v' ]
      assert equal '([0]="one: 1" [1]="zero: 0")' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "returns an array of values mapped with a heredoc block"; (
      _shpec_failures=0
      declare -A sampleh
      Hash .new sampleh '( [zero]=0 [one]=1 )'
      sampleh .map do {k,v} <<'      end'
        $k: $v
      end
      assert equal '([0]="one: 1" [1]="zero: 0")' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end
  end

  describe to_s
    it "returns a string interpretation of a hash"; (
      _shpec_failures=0
      declare -A sampleh
      Hash .new sampleh '( [zero]=0 [one]=1 )'
      sampleh .to_s
      assert equal '([one]="1" [zero]="0" )' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end
  end
end

describe String
  describe inspect
    it "returns an eval'able right-hand side string representation of the contents of the object"; (
      _shpec_failures=0
      String .new sample "an example"
      sample .inspect
      assert equal '"an example"' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end
  end

  describe =
    it "sets the associated variable with a literal string"; (
      _shpec_failures=0
      String .new sample "an example"
      sample .= "a result"
      assert equal "a result" "$sample"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "sets the associated variable with the output left in __ by the last command"; (
      _shpec_failures=0
      String .new sample "an example"
      String .new result "a result"
      sample .= result
      assert equal "a result" "$sample"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end
  end

  describe to_s
    it "returns a printable string from the associated variable"; (
      _shpec_failures=0
      String .new sample "an example"
      sample .to_s
      assert equal "an example" "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end
  end

  describe upcase
    it "returns an upper-cased version of the string"; (
      _shpec_failures=0
      String .new sample "an example"
      sample .upcase
      assert equal "AN EXAMPLE" "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end
  end

  describe upcase!
    it "changes the string to upper-case"; (
      _shpec_failures=0
      String .new sample "an example"
      sample .upcase!
      assert equal "AN EXAMPLE" "$sample"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end
  end
end

describe puts
  it "prints the given argument"
    assert equal "an example" "$(puts "an example")"
  end

  it "prints additional arguments on successive lines"
    assert equal $'an example\nof two arguments' "$(puts "an example" "of two arguments")"
  end

  it "calls to_s on an object"; (
    _shpec_failures=0
    String .new sample "an example"
    assert equal "an example" "$(puts sample)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "calls to_s on the output of a method"; (
    _shpec_failures=0
    Array .new samples '( zero one )'
    assert equal "zero-one" "$(puts samples .join -)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end

describe __dispatch
  it "allows a literal String object"; (
    _shpec_failures=0
    String "an example" .class
    assert equal '"String"' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "calls #inspect on a bare object literal"; (
    _shpec_failures=0
    String "an example"
    assert equal '"an example"' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "allows a literal Array object"; (
    _shpec_failures=0
    Array '( zero one )' .class
    assert equal '"Array"' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "allows a literal Hash object"; (
    _shpec_failures=0
    Hash '( [zero]=0 [one]=1 )' .class
    assert equal '"Hash"' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "implicitly calls #inspect"; (
    _shpec_failures=0
    String .new sample "an example"
    sample
    assert equal '"an example"' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "allows a bare = on .= calls"; (
    _shpec_failures=0
    String .new sample "an example"
    sample = "a result"
    assert equal "a result" "$sample"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "allows braces on method calls"; (
    _shpec_failures=0
    unset -v sample
    unset -f sample
    String .new { sample "an example" }
    is_function sample
    assert equal 0 $?
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "does basic method chaining with braces"; (
    _shpec_failures=0
    Array .new samples '( one two )'
    samples .join { - } .class
    assert equal '"String"' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end

describe require
  it "loads a rubsh file from a specified path without an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    echo 'sample=example' >"$dir"/sample.rubsh
    require "$dir"/sample
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a rubsh file from a specified path with an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    echo 'sample=example' >"$dir"/sample.rubsh
    require "$dir"/sample.rubsh
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a bash file from a specified path without an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    echo 'sample=example' >"$dir"/sample.bash
    require "$dir"/sample
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a bash file from a specified path with an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    echo 'sample=example' >"$dir"/sample.bash
    require "$dir"/sample.bash
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a sh file from a specified path without an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    echo 'sample=example' >"$dir"/sample.sh
    require "$dir"/sample
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a sh file from a specified path with an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    echo 'sample=example' >"$dir"/sample.sh
    require "$dir"/sample.sh
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a rubsh file from RUBSH_PATH without an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    export RUBSH_PATH=$dir
    echo 'sample=example' >"$dir"/sample.rubsh
    require sample.rubsh
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a rubsh file from RUBSH_PATH with an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    export RUBSH_PATH=$dir
    echo 'sample=example' >"$dir"/sample.rubsh
    require sample.rubsh
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a bash file from RUBSH_PATH without an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    export RUBSH_PATH=$dir
    echo 'sample=example' >"$dir"/sample.bash
    require sample
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a bash file from RUBSH_PATH with an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    export RUBSH_PATH=$dir
    echo 'sample=example' >"$dir"/sample.bash
    require sample.bash
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a sh file from RUBSH_PATH without an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    export RUBSH_PATH=$dir
    echo 'sample=example' >"$dir"/sample.sh
    require sample
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a sh file from RUBSH_PATH with an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    export RUBSH_PATH=$dir
    echo 'sample=example' >"$dir"/sample.sh
    require sample.sh
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a rubsh file from the local directory without an extension"; (
    _shpec_failures=0
    unset -v sample
    echo 'sample=example' >sample.rubsh
    require sample
    assert equal example "$sample"
    $rm sample.rubsh
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a rubsh file from the local directory with an extension"; (
    _shpec_failures=0
    unset -v sample
    echo 'sample=example' >sample.rubsh
    require sample.rubsh
    assert equal example "$sample"
    $rm sample.rubsh
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a bash file from the local directory without an extension"; (
    _shpec_failures=0
    unset -v sample
    echo 'sample=example' >sample.bash
    require sample
    assert equal example "$sample"
    $rm sample.bash
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a bash file from the local directory with an extension"; (
    _shpec_failures=0
    unset -v sample
    echo 'sample=example' >sample.bash
    require sample.bash
    assert equal example "$sample"
    $rm sample.bash
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a sh file from the local directory without an extension"; (
    _shpec_failures=0
    unset -v sample
    echo 'sample=example' >sample.sh
    require sample
    assert equal example "$sample"
    $rm sample.sh
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a sh file from the local directory with an extension"; (
    _shpec_failures=0
    unset -v sample
    echo 'sample=example' >sample.sh
    require sample.sh
    assert equal example "$sample"
    $rm sample.sh
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "doesn't reload a loaded file"; (
    _shpec_failures=0
    echo 'sample=example' >sample.rubsh
    require sample
    unset -v sample
    require sample
    assert unequal example "${sample-}"
    $rm sample.rubsh
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end

describe README
  it "Output"; (
    _shpec_failures=0
    assert equal "hello, world!" "$(puts "hello, world!")"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "String Creation"; (
    _shpec_failures=0
    String sample = "an example"
    assert equal "an example" "$(puts sample)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Array Creation"; (
    _shpec_failures=0
    Array samples = '( zero one )'
    assert equal '([0]="zero" [1]="one")' "$(puts samples)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Hash Creation"; (
    _shpec_failures=0
    declare -A sampleh
    Hash sampleh = '( [zero]=0 [one]=1 )'
    assert equal '([one]="1" [zero]="0" )' "$(puts sampleh)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Assignment"; (
    _shpec_failures=0
    String sample = "an example"
    sample = "a new hope"
    assert equal "a new hope" "$(puts sample)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Calling Methods"; (
    _shpec_failures=0
    Array samples = '( zero one )'
    assert equal "zero-one" "$(puts samples .join -)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Method chaining"; (
    _shpec_failures=0
    Array samples = '( zero one )'
    assert equal ZERO-ONE "$(puts samples .join { - } .upcase)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Blocks"; (
    _shpec_failures=0
    declare -A sampleh
    Hash sampleh = '( [zero]=0 )'
    assert equal '([0]="zero: 0")' "$(puts sampleh .map [ {k,v} '$k: $v' ])"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Object Literals"; (
    _shpec_failures=0
    assert equal "HELLO, WORLD!" "$(puts String "hello, world!" .upcase)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Class Creation"; (
    _shpec_failures=0
    class Fruit; {
      def tasty? <<'      end'
        puts "Heck yeah!"
      end

      def fresh? <<'      end'
        puts "You bet."
      end
    }

    Fruit .new myfruit
    assert equal "You bet." "$(myfruit .fresh?)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Inheritance 1"; (
    _shpec_failures=0
    class Fruit; {
      def tasty? <<'      end'
        puts "Heck yeah!"
      end

      def fresh? <<'      end'
        puts "You bet."
      end
    }

    class Banana : Fruit; {
      def fresh? <<'      end'
        puts "Not so much."
      end
    }

    Banana .new mybanana
    assert equal "Not so much." "$(mybanana .fresh?)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Inheritance 2"; (
    _shpec_failures=0
    class Fruit; {
      def tasty? <<'      end'
        puts "Heck yeah!"
      end

      def fresh? <<'      end'
        puts "You bet."
      end
    }

    class Banana : Fruit; {
      def fresh? <<'      end'
        puts "Not so much."
      end
    }

    Banana .new mybanana
    assert equal "Heck yeah!" "$(mybanana .tasty?)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Introspection 1"; (
    _shpec_failures=0
    assert equal '"Class"' "$(puts Array .class)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Introspection 2"; (
    _shpec_failures=0
    assert equal '"Object"' "$(puts Array .superclass)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Introspection 3"; (
    _shpec_failures=0
    assert equal '([0]="Array" [1]="Object")' "$(puts Array .ancestors)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Introspection 4"; (
    _shpec_failures=0
    assert equal '([0]="ancestors" [1]="declare" [2]="instance_methods" [3]="new" [4]="superclass" [5]="class" [6]="methods")' "$(puts Class .methods)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Introspection 5"; (
    _shpec_failures=0
    assert equal '([0]="ancestors" [1]="declare" [2]="instance_methods" [3]="new" [4]="superclass")' "$(puts Class .instance_methods false)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end
