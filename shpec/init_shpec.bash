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
source "$RUBSH_PATH"/require.rubsh
$(require init)

function? () { declare -f "$1" >/dev/null 2>&1 ;}
variable? () { declare -p "$1" >/dev/null 2>&1 ;}

describe RUBSH_ROOT
  it "is one up from this directory"
    assert equal "$(readlink -f "$(shpec_cwd)"/..)" "$RUBSH_ROOT"
  end
end

describe RUBSH_VERSION
  it "the current version"
    assert equal "$(cat "$RUBSH_ROOT"/VERSION)" "$RUBSH_VERSION"
  end
end

describe __class
  it "has an id value of 'object'"
    assert equal object "$__class"
  end
end

describe false
  it "is a variable with an id value of 'false'"
    assert equal false "$false"
  end

  it "has a type of 'false'"
    assert equal false "${__typeh[false]}"
  end

  it "has a class of 'false_class'"
    assert equal false_class "${__classh[false]}"
  end
end

describe nil
  it "is a variable with an id value of 'nil'"
    assert equal nil "$nil"
  end

  it "has a type of 'nil'"
    assert equal nil "${__typeh[nil]}"
  end

  it "has a class of 'nil_class'"
    assert equal nil_class "${__classh[nil]}"
  end
end

describe self
  it "is a variable with an id value of 'top_self'"
    assert equal top_self "$self"
  end
end

describe top_self
  it "has a class of 'object'"
    assert equal object "${__classh[top_self]}"
  end
end

describe true
  it "is a variable with an id value of 'true'"
    assert equal true "$true"
  end

  it "has a type of 'true'"
    assert equal true "${__typeh[true]}"
  end

  it "has a class of 'true_class'"
    assert equal true_class "${__classh[true]}"
  end
end

describe Class
  it "is a function"
    function? Class
    assert equal 0 $?
  end

  it "has a constant defined"
    assert equal class "${__constanth[Class]}"
  end

  it "is recorded as a class"
    [[ -n ${__classesh[class]} ]]
    assert equal 0 $?
  end

  it "strictly has the class of its singleton class"
    assert equal class_singleton "${__classh[class]}"
  end

  it "has a super of 'object'"
    assert equal object "${__superh[class]}"
  end

  it "has a type of 'class'"
    assert equal class "${__typeh[class]}"
  end

  it "is not a singleton"
    [[ -z ${__singletonh[class]:-} ]]
    assert equal 0 $?
  end

  it "has a hidden classname variable"
    assert equal Class "${__ivarh[class.name]}"
  end
end

describe FalseClass
  it "is a function"
    function? FalseClass
    assert equal 0 $?
  end

  it "has a constant defined"
    assert equal false_class "${__constanth[FalseClass]}"
  end

  it "is recorded as a class"
    [[ -n ${__classesh[false_class]} ]]
    assert equal 0 $?
  end

  it "has the class of Class"
    assert equal class "${__classh[false_class]}"
  end

  it "has a super of class's singleton"
    assert equal class_singleton "${__superh[false_class]}"
  end

  it "has a type of 'class'"
    assert equal class "${__typeh[false_class]}"
  end

  it "is a singleton"
    [[ -n ${__singletonh[false_class]:-} ]]
    assert equal 0 $?
  end

  it "has a hidden classname variable"
    assert equal FalseClass "${__ivarh[false_class.name]}"
  end
end

describe NilClass
  it "is a function"
    function? NilClass
    assert equal 0 $?
  end

  it "has a constant defined"
    assert equal nil_class "${__constanth[NilClass]}"
  end

  it "is recorded as a class"
    [[ -n ${__classesh[nil_class]} ]]
    assert equal 0 $?
  end

  it "has the class of Class"
    assert equal class "${__classh[nil_class]}"
  end

  it "has a super of class's singleton"
    assert equal class_singleton "${__superh[nil_class]}"
  end

  it "has a type of 'class'"
    assert equal class "${__typeh[nil_class]}"
  end

  it "is a singleton"
    [[ -n ${__singletonh[nil_class]:-} ]]
    assert equal 0 $?
  end

  it "has a hidden classname variable"
    assert equal NilClass "${__ivarh[nil_class.name]}"
  end
end

describe Object
  it "is a function"
    function? Object
    assert equal 0 $?
  end

  it "has a constant defined"
    assert equal object "${__constanth[Object]}"
  end

  it "is recorded as a class"
    [[ -n ${__classesh[object]} ]]
    assert equal 0 $?
  end

  it "strictly has the class of its singleton class"
    assert equal object_singleton "${__classh[object]}"
  end

  it "has no super (empty)"
    assert equal '' "${__superh[object]}"
  end

  it "has a type of 'class'"
    assert equal class "${__typeh[object]}"
  end

  it "is not a singleton"
    [[ -z ${__singletonh[object]:-} ]]
    assert equal 0 $?
  end

  it "has a hidden classname variable"
    assert equal Object "${__ivarh[object.name]}"
  end
end

describe TrueClass
  it "is a function"
    function? TrueClass
    assert equal 0 $?
  end

  it "has a constant defined"
    assert equal true_class "${__constanth[TrueClass]}"
  end

  it "is recorded as a class"
    [[ -n ${__classesh[true_class]} ]]
    assert equal 0 $?
  end

  it "has the class of Class"
    assert equal class "${__classh[true_class]}"
  end

  it "has a super of class's singleton"
    assert equal class_singleton "${__superh[true_class]}"
  end

  it "has a type of 'class'"
    assert equal class "${__typeh[true_class]}"
  end

  it "is a singleton"
    [[ -n ${__singletonh[true_class]:-} ]]
    assert equal 0 $?
  end

  it "has a hidden classname variable"
    assert equal TrueClass "${__ivarh[true_class.name]}"
  end
end

describe __Class
  it "is not a function"
    ! function? __Class
    assert equal 0 $?
  end

  it "is not recorded as a class"
    [[ -z ${__classesh[class_singleton]:-} ]]
    assert equal 0 $?
  end

  it "has the class of itself"
    assert equal class_singleton "${__classh[class_singleton]}"
  end

  it "has a super of attached class's superclass's singleton"
    assert equal object_singleton "${__superh[class_singleton]}"
  end

  it "has a type of 'class'"
    assert equal class "${__typeh[class_singleton]}"
  end

  it "is a singleton"
    [[ -n ${__singletonh[class_singleton]} ]]
    assert equal 0 $?
  end

  it "has a hidden attachment variable"
    assert equal class "${__ivarh[class_singleton.attached]}"
  end
end

describe __Object
  it "is not a function"
    ! function? __Object
    assert equal 0 $?
  end

  it "is not recorded as a class"
    [[ -z ${__classesh[object_singleton]:-} ]]
    assert equal 0 $?
  end

  it "has the class of itself"
    assert equal object_singleton "${__classh[object_singleton]}"
  end

  it "has a super of 'class'"
    assert equal class "${__superh[object_singleton]}"
  end

  it "has a type of 'class'"
    assert equal class "${__typeh[object_singleton]}"
  end

  it "is a singleton"
    [[ -n ${__singletonh[object_singleton]} ]]
    assert equal 0 $?
  end

  it "has a hidden attachment variable"
    assert equal object "${__ivarh[object_singleton.attached]}"
  end
end
