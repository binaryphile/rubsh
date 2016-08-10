#!/usr/bin/env bash

library=../lib/shell.sh
source "${BASH_SOURCE%/*}/$library" 2>/dev/null || source "$library"
unset -v library

describe "Shell.alias_function"
  it "aliases a function"
    (
    sample() { echo "hello"; }
    Shell.alias_function :sample2 :sample
    assert equal "$(sample2)" "hello"
    )
  end
end

describe "Shell.assign_literal"
  it "assigns a string literal to a variable"
    (
    sample=""
    Shell.assign_literal :sample "value"
    assert equal "$(Shell.class :sample)" "string"
    assert equal "$sample" "value"
    )
  end

  it "assigns an array literal to a variable"
    (
    sample=""
    Shell.assign_literal :sample '("one" "two" "three")'
    assert equal "$(Shell.class :sample)" "array"
    assert equal "${sample[*]}" "one two three"
    )
  end
end

describe "Shell.class"
  it "reports if it is an array"
    (
    # shellcheck disable=SC2034
    sample=( 1 2 3 )
    assert equal "$(Shell.class :sample)" "array"
    )
  end

  it "reports if it is a string"
    (
    # shellcheck disable=SC2034
    sample="value"
    assert equal "$(Shell.class :sample)" "string"
    )
  end

  it "errors if it is not a variable"
    (
    Shell.class :sample
    assert equal $? 1
    )
  end
end

describe "Shell.dereference"
  it "dereferences a scalar variable"
    (
    # shellcheck disable=SC2034
    sample="some text"
    # shellcheck disable=SC2034
    indirect=":sample"
    Shell.dereference :indirect
    assert equal "$(Shell.class :indirect)" "string"
    assert equal "$indirect" "some text"
    )
  end

  it "dereferences an array variable"
    (
    # shellcheck disable=SC2034
    sample=( "testing" "one" "two" )
    # shellcheck disable=SC2034
    indirect=":sample"
    Shell.dereference :indirect
    assert equal "$(Shell.class :indirect)" "array"
    assert equal "${#indirect[@]}" 3
    assert equal "${indirect[*]}" "testing one two"
    )
  end
end

describe "Shell.inspect"
  it "returns a literal string representation"
    (
    # shellcheck disable=SC2034
    sample="value text"
    assert equal "$(Shell.inspect :sample)" "value text"
    )
  end

  it "returns a literal array representation"
    (
    # shellcheck disable=SC2034
    sample=( "one" "two" "three" )
    assert equal "$(Shell.inspect :sample)" '("one" "two" "three")'
    )
  end
end

describe "Shell.passback_as"
  it "returns a single value in a variable"
    (
    func() { Shell.passback_as :sample "example text" ;}
    sample=""
    func
    assert equal "$sample" "example text"
    )
  end
end

describe "Shell.symbol?"
  it "detects a variable"
    (
    Shell.symbol? :sample
    assert equal $? 0
    )
  end

  it "doesn't detect a string"
    (
    Shell.symbol? sample
    assert equal $? 1
    )
  end
end

describe "Shell.to_s"
  it "returns a string"
    (
    # shellcheck disable=SC2034
    sample="value text"
    assert equal "$(Shell.to_s :sample)" "value text"
    )
  end

  it "returns a concatenated string"
    (
    # shellcheck disable=SC2034
    sample=( "one" "two" "three" )
    assert equal "$(Shell.to_s :sample)" "one two three"
    )
  end
end

describe "Shell.variable?"
  it "detects a variable"
    (
    sample=test
    Shell.variable? :sample
    assert equal $? 0
    )
  end

  it "doesn't detect a function"
    (
    sample2() { echo hello ;}
    Shell.variable? :sample2
    assert equal $? 1
    )
  end

  it "doesn't detect an undefined variable"
    (
    Shell.variable? :no_var
    assert equal $? 1
    )
  end
end
