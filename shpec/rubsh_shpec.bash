source import.bash

shpec_helper_imports=(
  initialize_shpec_helper
  stop_on_error
)
eval "$(importa shpec-helper shpec_helper_imports)"
initialize_shpec_helper
stop_on_error=true
stop_on_error

shpec_test=true
eval "source $shpec_cwd/../lib/rubsh.bash"

is_function () { declare -f "$1" >/dev/null ;}

describe Object
  it "is a function"
    is_function Object
    assert equal 0 $?
  end

  describe class
    it "Object is class Class"
      Object class
      assert equal Class "$__"
    end

    it "Class is class Class"
      Class class
      assert equal Class "$__"
    end
  end

  describe methods
    it "lists an array string of Object methods"
      Object methods
      assert equal '([0]="ancestors" [1]="instance_methods" [2]="new" [3]="superclass" [4]="class" [5]="methods")' "$__"
    end

    it "only lists Object methods defined on it when given false"
      Object methods false
      assert equal '()' "$__"
    end

    it "lists an array string of Class methods"
      Class methods
      assert equal '([0]="ancestors" [1]="instance_methods" [2]="new" [3]="superclass" [4]="class" [5]="methods")' "$__"
    end

    it "only lists Class methods defined on it when given false"
      Class methods false
      assert equal '()' "$__"
    end
  end
end

describe Class
  it "is a function"
    is_function Class
    assert equal 0 $?
  end

  describe ancestors
    it "lists an array string of Class ancestor classes"
      Class ancestors
      assert equal '([0]="Class" [1]="Object")' "$__"
    end

    it "lists an array string of Object ancestor classes"
      Object ancestors
      assert equal '([0]="Object")' "$__"
    end
  end

  describe instance_methods
    it "lists an array string of Class instance methods"
      Class instance_methods
      assert equal '([0]="ancestors" [1]="instance_methods" [2]="new" [3]="superclass" [4]="class" [5]="methods")' "$__"
    end

    it "only lists Class methods defined on it when given false"
      Class instance_methods false
      assert equal '([0]="ancestors" [1]="instance_methods" [2]="new" [3]="superclass")' "$__"
    end

    it "lists an array string of Object instance methods"
      Object instance_methods
      assert equal '([0]="class" [1]="methods")' "$__"
    end

    it "only lists Object methods defined on it when given false"
      Object instance_methods false
      assert equal '([0]="class" [1]="methods")' "$__"
    end
  end

  describe new
    it "creates a function"; (
      Class new myclass
      is_function myclass
      assert equal 0 $?
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "is of the class of the receiver"; (
      Class new myclass
      myclass class
      assert equal Class "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "has the instance methods of the class"; (
      Class new myclass
      myclass methods
      methods=$__
      Class instance_methods
      assert equal "$methods" "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end
  end

  describe superclass
    it "gives the superclass of Class as Object"
      Class superclass
      assert equal Object "$__"
    end

    it "gives the superclass of Object as empty string"
      Object superclass
      assert equal '' "$__"
    end
  end
end
