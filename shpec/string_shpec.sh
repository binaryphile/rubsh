#!/usr/bin/env bash

library=../lib/string.sh
source "${BASH_SOURCE%/*}/$library" 2>/dev/null || source "$library"
unset -v library

describe "String.class"
  it "returns \"String\""
    (
    # shellcheck disable=SC2034
    sample="text"
    assert equal "$(String.class :sample)" "String"
    )
  end
end

describe "String.split"
  it "splits on the specified delimiter"
    (
    # shellcheck disable=SC2034
    sample="a/b/c"
    result=""
    String.split :sample :result "/"
    assert equal "$(_rubsh.Shell.class :result)" "array"
    assert equal "$(_rubsh.Array.to_s :result)" "a b c"
    )
  end

  it "splits on the specified variable if supplied"
    (
    # shellcheck disable=SC2034
    sample="a/b/c"
    # shellcheck disable=SC2034
    delimiter="/"
    result=""
    String.split :sample :result :delimiter
    assert equal "$(_rubsh.Shell.class :result)" "array"
    assert equal "$(_rubsh.Array.to_s :result)" "a b c"
    )
  end

  it "splits on the shell IFS (normally whitespace) if nothing specified"
    (
    # shellcheck disable=SC2034
    sample="a  b 	c"
    result=""
    String.split :sample :result
    assert equal "$(_rubsh.Shell.class :result)" "array"
    assert equal "$(_rubsh.Array.to_s :result)" "a b c"
    )
  end
end

describe "String.eql?"
  it "exists"
    (
    # shellcheck disable=SC2034
    sample="abc"
    String.eql? :sample "abc"
    assert equal $? 0
    )
  end
end

describe "String.blank?"
  it "exists"
    (
    # shellcheck disable=SC2034
    blank=""
    String.blank? :blank
    assert equal $? 0
    )
  end
end

describe "String.new"
  it "allows an initializer"
    (
    # shellcheck disable=SC2034
    sample=""
    String.new :sample "text"
    # shellcheck disable=SC2034
    sample.eql? "text"
    assert equal $? 0
    )
  end

  it "adds a blank? method"
    (
    # shellcheck disable=SC2034
    sample=""
    String.new :sample
    sample.blank?
    assert equal $? 0
    )
  end

  it "adds a blank? method which detects non-blanks"
    (
    # shellcheck disable=SC2034
    sample="a"
    String.new :sample
    sample.blank?
    assert equal $? 1
    )
  end

  it "adds a eql? method"
    (
    # shellcheck disable=SC2034
    sample="a"
    String.new :sample
    sample.eql? "a"
    assert equal $? 0
    )
  end

  it "adds a eql? method which detects inequality"
    (
    # shellcheck disable=SC2034
    sample="a"
    String.new :sample
    sample.eql? "b"
    assert equal $? 1
    )
  end

  it "adds the rest of the String methods"
    (
    # shellcheck disable=SC2034
    sample="a"
    String.new :sample
    # shellcheck disable=SC2034
    result=""
    sample.split :result
    )
  end
end

describe "String.start_with?"
  it "identifies a starting character by reference"
    (
    # shellcheck disable=SC2034
    sample="a test"
    String.start_with? :sample "a"
    assert equal $? 0
    )
  end

  it "identifies a non-starting character by reference"
    (
    # shellcheck disable=SC2034
    sample="a test"
    String.start_with? :sample "b"
    assert equal $? 1
    )
  end

  it "identifies a starting character by value"
    (
    # shellcheck disable=SC2034
    String.start_with? "a test" "a"
    assert equal $? 0
    )
  end

  it "identifies a non-starting character by value"
    (
    # shellcheck disable=SC2034
    sample="a test"
    String.start_with? "a test" "b"
    assert equal $? 1
    )
  end
end
