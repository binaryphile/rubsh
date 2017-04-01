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
    assert equal '' "$__"
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
    assert equal '' "$__"
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
      assert equal Class "$__"
    end

    it "Class is class Class"
      Class .class
      assert equal Class "$__"
    end
  end

  describe methods
    it "lists an array string of Object methods"
      Object .methods
      assert equal '([0]="ancestors" [1]="instance_methods" [2]="new" [3]="superclass" [4]="class" [5]="methods" [6]="set" [7]="to_s")' "$__"
    end

    it "only lists Object methods defined on it when given false"
      Object .methods false
      assert equal '()' "$__"
    end

    it "lists an array string of Class methods"
      Class .methods
      assert equal '([0]="ancestors" [1]="instance_methods" [2]="new" [3]="superclass" [4]="class" [5]="methods" [6]="set" [7]="to_s")' "$__"
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
    it "puts the contents of the associated variable in __ in eval form"; (
      Class=sample
      Class .to_s
      assert equal '"sample"' "$__"
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
      assert equal '([0]="ancestors" [1]="instance_methods" [2]="new" [3]="superclass" [4]="class" [5]="methods" [6]="set" [7]="to_s")' "$__"
    end

    it "only lists Class methods defined on it when given false"
      Class .instance_methods false
      assert equal '([0]="ancestors" [1]="instance_methods" [2]="new" [3]="superclass")' "$__"
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
        Class .new =Myclass
        is_function Myclass
        assert equal 0 $?
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "fails on other than ="; (
        stop_on_error off
        Class .new .Myclass
        assert unequal 0 $?
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "is of the class of the receiver"; (
        Class .new =Myclass
        Myclass .class
        assert equal Class "$__"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "has the instance methods of the class"; (
        Class .new =Myclass
        Myclass .methods
        methods=$__
        Class .instance_methods
        assert equal "$methods" "$__"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

      it "has the superclass Object"; (
        Class .new =Myclass
        Myclass .superclass
        assert equal Object "$__"
        return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
      end

    #   it "returns nothing"; (
    #     unset -v __
    #     Class .new Myclass
    #     assert equal '' "$__"
    #     return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    #   end
    # end
    #
    # describe Object
    #   it "creates a function"; (
    #     Object .new myobject
    #     is_function myobject
    #     assert equal 0 $?
    #     return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    #   end
    #
    #   it "is of the class of the receiver"; (
    #     Object .new myobject
    #     myobject .class
    #     assert equal Object "$__"
    #     return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    #   end
    #
    #   it "has the instance methods of the class"; (
    #     Object .new myobject
    #     myobject .methods
    #     methods=$__
    #     Object .instance_methods
    #     assert equal "$methods" "$__"
    #     return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    #   end
    # end
    #
    # describe Array
    #   it "creates a function"; (
    #     Array .new myarray
    #     is_function myarray
    #     assert equal 0 $?
    #     return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    #   end
    #
    #   it "is of the class of the receiver"; (
    #     Array .new myarray
    #     myarray .class
    #     assert equal Array "$__"
    #     return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    #   end
    #
    #   it "has the instance methods of the class"; (
    #     Array .new myarray
    #     myarray .methods
    #     methods=$__
    #     Array .instance_methods
    #     assert equal "$methods" "$__"
    #     return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    #   end
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

# describe Array
#   it "is a function"
#     is_function Array
#     assert equal 0 $?
#   end
#
#   describe new
#     it "assigns the contents of a new array"; (
#       return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
#     end
#   end
#   # describe concat
#   #   it "concatenates an array with this one"
#   #     Array .new samples
#   #     return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
#   #   end
#   # end
# end
