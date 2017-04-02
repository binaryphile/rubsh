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

is_function () { declare -f "$1" >/dev/null ;}

describe class
  it "sets __class"; (
    class Sample
    assert equal Sample "$__class"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "fails if the inheritance operator is not :"; (
    stop_on_error off
    class Sample , Class
    assert unequal 0 $?
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "fails if the superclass is given but the class already exists as a function"; (
    Sample () { :;}
    stop_on_error off
    class Sample : Class
    assert unequal 0 $?
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "fails if the superclass is given but doesn't already exist as a function"; (
    unset -f Test
    stop_on_error off
    class Sample : Test
    assert unequal 0 $?
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "tracks the superclass"; (
    Test () { :;}
    class Sample : Test
    assert equal Test "${__superh[Sample]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "creates the class function"; (
    class Sample
    is_function Sample
    assert equal 0 $?
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "sets the class to Class"; (
    class Sample
    assert equal Class "${__classh[Sample]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "returns nothing"; (
    unset -v __
    class Sample
    assert equal '""' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end

describe def
  it "tracks the method's class"; (
    class Sample
    def sample ''
    assert equal ' sample ' "${__methodsh[Sample]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "tracks the class of the method"; (
    class Sample
    def sample ''
    assert equal ' Sample ' "${__method_classesh[sample]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "records the method body"; (
    class Sample
    def sample 'example'
    assert equal example "${__method_bodyh[Sample.sample]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "returns nothing"; (
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
      assert equal '([0]="ancestors" [1]="declare" [2]="instance_methods" [3]="new" [4]="superclass" [5]="class" [6]="methods" [7]="set" [8]="to_s")' "$__"
    end

    it "only lists Object methods defined on it when given false"
      Object .methods false
      assert equal '()' "$__"
    end

    it "lists an array string of Class methods"
      Class .methods
      assert equal '([0]="ancestors" [1]="declare" [2]="instance_methods" [3]="new" [4]="superclass" [5]="class" [6]="methods" [7]="set" [8]="to_s")' "$__"
    end

    it "only lists Class methods defined on it when given false"
      Class .methods false
      assert equal '()' "$__"
    end
  end

  describe set
    it "sets the associated variable with the output left in __ by the following command"; (
      Class .set printf -v __ sample
      assert equal sample "$Class"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end
  end

  describe to_s
    it "returns a printable string from the associated variable"; (
      Class=sample
      Class .to_s
      assert equal 'sample' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
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
      assert equal '([0]="ancestors" [1]="declare" [2]="instance_methods" [3]="new" [4]="superclass" [5]="class" [6]="methods" [7]="set" [8]="to_s")' "$__"
    end

    it "only lists Class methods defined on it when given false"
      Class .instance_methods false
      assert equal '([0]="ancestors" [1]="declare" [2]="instance_methods" [3]="new" [4]="superclass")' "$__"
    end

    it "lists an array string of Object instance methods"
      Object .instance_methods
      assert equal '([0]="class" [1]="methods" [2]="set" [3]="to_s")' "$__"
    end

    it "only lists Object methods defined on it when given false"
      Object .instance_methods false
      assert equal '([0]="class" [1]="methods" [2]="set" [3]="to_s")' "$__"
    end
  end

  describe new
    describe Class
      it "creates a function"; (
        Class .new Myclass
        is_function Myclass
        assert equal 0 $?
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "creates a function with the assignment syntax"; (
        Class Myclass =
        is_function Myclass
        assert equal 0 $?
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "fails on other than = or ^"; (
        stop_on_error off
        Class Myclass .
        assert unequal 0 $?
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "is of the class of the receiver"; (
        Class .new Myclass
        Myclass .class
        assert equal '"Class"' "$__"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "is of the class of the receiver with assignment syntax"; (
        Class Myclass =
        Myclass .class
        assert equal '"Class"' "$__"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "has the instance methods of the class"; (
        Class .new Myclass
        Myclass .methods
        methods=$__
        Class .instance_methods
        assert equal "$methods" "$__"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "has the instance methods of the class with assignment syntax"; (
        Class Myclass =
        Myclass .methods
        methods=$__
        Class .instance_methods
        assert equal "$methods" "$__"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "has the superclass Object"; (
        Class .new Myclass
        Myclass .superclass
        assert equal Object "$__"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "has the superclass Object with assignment syntax"; (
        Class Myclass =
        Myclass .superclass
        assert equal Object "$__"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "returns nothing"; (
        unset -v __
        Class .new Myclass
        assert equal '' "$__"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "returns nothing with assignment syntax"; (
        unset -v __
        Class Myclass =
        assert equal '' "$__"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end
    end

    describe Object
      it "is of the class of the receiver"; (
        Object .new sample
        sample .class
        assert equal '"Object"' "$__"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "is of the class of the receiver with assignment syntax"; (
        Object sample =
        sample .class
        assert equal '"Object"' "$__"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "has the instance methods of the class"; (
        Object .new sample
        sample .methods
        methods=$__
        Object .instance_methods
        assert equal "$methods" "$__"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "has the instance methods of the class with assignment syntax"; (
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
        Array .new samples
        is_function samples
        assert equal 0 $?
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "creates a function with assignment syntax"; (
        Array samples =
        is_function samples
        assert equal 0 $?
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "is of the class of the receiver"; (
        Array .new samples
        samples .class
        assert equal '"Array"' "$__"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "is of the class of the receiver with assignment syntax"; (
        Array samples =
        samples .class
        assert equal '"Array"' "$__"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "has the instance methods of the class"; (
        Array .new samples
        samples .methods
        methods=$__
        Array .instance_methods
        assert equal "$methods" "$__"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "has the instance methods of the class with assignment syntax"; (
        Array samples =
        samples .methods
        methods=$__
        Array .instance_methods
        assert equal "$methods" "$__"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "takes a literal initializer"; (
        Array .new samples '( zero one )'
        assert equal 'declare -a samples='\''([0]="zero" [1]="one")'\' "$(declare -p samples)"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "takes a literal initializer with assignment syntax"; (
        Array samples = '( zero one )'
        assert equal 'declare -a samples='\''([0]="zero" [1]="one")'\' "$(declare -p samples)"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "returns an assigned value unchanged"; (
        Array .new samples '( zero one )'
        assert equal '( zero one )' "$__"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "returns an assigned value unchanged with assignment syntax"; (
        Array samples = '( zero one )'
        assert equal '( zero one )' "$__"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "generates an eval string from a literal initializer"; (
        result=$(Array .declare samples '( zero one )')
        assert equal 'eval declare -a samples=( zero one ); Array .new samples' "$result"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "generates an eval string from a literal initializer with assignment syntax"; (
        result=$(Array samples ^ '( zero one )')
        assert equal 'eval declare -a samples=( zero one ); Array .new samples' "$result"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end
    end

    describe Hash
      it "takes a literal initializer"; (
        declare -A sampleh
        Hash .new sampleh '( [zero]=0 [one]=1 )'
        assert equal 'declare -A sampleh='\''([one]="1" [zero]="0" )'\' "$(declare -p sampleh)"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "takes a literal initializer with assignment syntax"; (
        declare -A sampleh
        Hash sampleh = '( [zero]=0 [one]=1 )'
        assert equal 'declare -A sampleh='\''([one]="1" [zero]="0" )'\' "$(declare -p sampleh)"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "generates an eval string from a literal initializer"; (
        result=$(Hash .declare sampleh '( [zero]=0 [one]=1 )')
        assert equal 'eval declare -A sampleh=( [zero]=0 [one]=1 ); Hash .new sampleh' "$result"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "generates an eval string from a literal initializer with assignment syntax"; (
        result=$(Hash sampleh ^ '( [zero]=0 [one]=1 )')
        assert equal 'eval declare -A sampleh=( [zero]=0 [one]=1 ); Hash .new sampleh' "$result"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end
    end

    describe String
      it "takes a literal initializer"; (
        String .new sample "an example"
        assert equal 'declare -- sample="an example"' "$(declare -p sample)"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "takes a literal initializer with assignment syntax"; (
        String sample = "an example"
        assert equal 'declare -- sample="an example"' "$(declare -p sample)"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "generates an eval string from a literal initializer"; (
        result=$(String .declare sample "an example")
        assert equal 'eval declare -- sample="an example"; String .new sample' "$result"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "generates an eval string from a literal initializer with assignment syntax"; (
        result=$(String sample ^ "an example")
        assert equal 'eval declare -- sample="an example"; String .new sample' "$result"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end
    end
  end

  describe superclass
    it "gives the superclass of Class as Object"
      Class .superclass
      assert equal Object "$__"
    end

    it "gives the superclass of Object as empty string"
      Object .superclass
      assert equal '' "$__"
    end
  end
end

describe "an instance"
  it "is a function"; (
    Object .new sample
    is_function sample
    assert equal 0 $?
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "implicitly calls #to_s"; (
    String .new sample "an example"
    sample
    assert equal 'an example' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end

describe Array
  describe concat
    it "concatenates an array with this one"; (
      Array .new samples '( zero one   )'
      Array .new example '( two  three )'
      samples .concat example
      assert equal 'declare -a samples='\''([0]="zero" [1]="one" [2]="two" [3]="three")'\' "$(declare -p samples)"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "returns the concatenation"; (
      Array .new samples '( zero one   )'
      Array .new example '( two  three )'
      samples .concat example
      assert equal '([0]="zero" [1]="one" [2]="two" [3]="three")' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end
  end

  describe join
    it "joins array elements into a string"; (
      Array .new samples '( zero one )'
      samples .join -
      assert equal 'zero-one' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end
  end

  describe to_s
    it "returns the serialization of the array"; (
      Array .new samples '( zero one )'
      samples .to_s
      assert equal '([0]="zero" [1]="one")' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end
  end
end

describe Hash
  describe map
    it "returns an array of values mapped with a normal block"; (
      declare -A sampleh
      Hash .new sampleh '( [zero]=0 [one]=1 )'
      sampleh .map [ {k,v} '$k: $v' ]
      assert equal '([0]="one: 1" [1]="zero: 0")' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "returns an array of values mapped with a heredoc block"; (
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
    it "renders an evalable string to __"; (
      declare -A sampleh
      Hash .new sampleh '( [zero]=0 [one]=1 )'
      sampleh .to_s
      assert equal '([one]="1" [zero]="0" )' "$__"
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

  it "outputs objects"; (
    String .new sample "an example"
    assert equal "an example" "$(puts sample)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end
