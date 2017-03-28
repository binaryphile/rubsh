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

  describe ancestors
    it "lists an array string of ancestor classes"
      Object ancestors
      assert equal '([0]="Object")' "$__"
    end
  end

  describe class
    it "is class Class"
      Object class
      assert equal Class "$__"
    end
  end

  describe instance_methods
    it "lists an array string of instance methods"
      Object instance_methods
      assert equal '([0]="class" [1]="methods")' "$__"
    end

    it "only lists methods defined on it when given false"
      Object instance_methods false
      assert equal '([0]="class" [1]="methods")' "$__"
    end
  end

  describe methods
    it "lists an array string of methods"
      Object methods
      assert equal '([0]="ancestors" [1]="instance_methods" [2]="class" [3]="methods")' "$__"
    end

    it "only lists methods defined on it when given false"
      Object methods false
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
    it "lists an array string of ancestor classes"
      Class ancestors
      assert equal '([0]="Class" [1]="Object")' "$__"
    end
  end

  describe instance_methods
    it "lists an array string of instance methods"
      Class instance_methods
      assert equal '([0]="ancestors" [1]="instance_methods" [2]="class" [3]="methods")' "$__"
    end

    it "only lists methods defined on it when given false"
      Class instance_methods false
      assert equal '([0]="ancestors" [1]="instance_methods")' "$__"
    end
  end

  describe methods
    it "lists an array string of methods"
      Class methods
      assert equal '([0]="ancestors" [1]="instance_methods" [2]="class" [3]="methods")' "$__"
    end

    it "only lists methods defined on it when given false"
      Class methods false
      assert equal '()' "$__"
    end
  end
end
