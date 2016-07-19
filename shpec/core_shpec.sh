#!/usr/bin/env bash

library=../lib/core.sh
source "${BASH_SOURCE%/*}/$library" 2>/dev/null || source "$library"

init() {
  _rubsh.IO.printf "%s" "$(mktemp --directory)"
}

cleanup() {
  validate_dirname "$1"
  rm -rf -- "$1"
}

validate_dirname() {
  [[ $1 =~ ^/tmp/tmp\. ]]   || exit
  [[ -d $1 ]]               || exit
}

describe "_rubsh.Array.to_s"
  it "renders a string version of an array"
    # shellcheck disable=SC2034
    sample_a=( "a" "b" "c" )
    # shellcheck disable=SC2034
    expected_s='("a" "b" "c")'
    # shellcheck disable=SC2034
    result_s="$(_rubsh.Array.to_s sample_a)"
    assert equal "$expected_s" "$result_s"
  end
end

describe "_rubsh.core.alias"
  it "aliases String.blank? function to core"
    # shellcheck disable=SC2034
    aliases_a=( "blank?" )
    _rubsh.core.alias String aliases_a
    # shellcheck disable=SC2034
    blank_s=""
    String.blank? blank_s
    assert equal $? 0
  end
end

describe "_rubsh.File.dirname"
  it "determines the directory name with multiple components by reference"
    (
    sample="/home/gumby/work/ruby.rb"
    assert equal "$(_rubsh.File.dirname sample)" "/home/gumby/work"
    )
  end

  it "determines the directory name without components by reference"
    (
    sample="ruby.rb"
    assert equal "$(_rubsh.File.dirname sample)" "."
    )
  end

  it "determines the directory name with multiple components by value"
    (
    sample="/home/gumby/work/ruby.rb"
    assert equal "$(_rubsh.File.dirname "$sample")" "/home/gumby/work"
    )
  end

  it "determines the directory name without components by value"
    (
    sample="ruby.rb"
    assert equal "$(_rubsh.File.dirname "$sample")" "."
    )
  end
end

describe "_rubsh.File.realpath"
  it "determines the directory name with multiple components without symlinks or dots by reference"
    (
    temp="$(init)"
    validate_dirname "$temp"
    mkdir "$temp"/dir2
    touch "$temp"/dir2/file
    ln -sf dir2 "$temp"/dir
    sample="$temp"/../.."$temp"/dir/file
    assert equal "$(_rubsh.File.realpath sample)" "$temp"/dir2/file
    cleanup "$temp"
    )
  end

  it "determines the directory name with multiple components without symlinks or dots by value"
    (
    temp="$(init)"
    validate_dirname "$temp"
    mkdir "$temp"/dir2
    touch "$temp"/dir2/file
    ln -sf dir2 "$temp"/dir
    sample="$temp"/../.."$temp"/dir/file
    assert equal "$(_rubsh.File.realpath "$sample")" "$temp"/dir2/file
    cleanup "$temp"
    )
  end
end

describe "_rubsh.IO.printf"
  it "printfs to stdout"
  (
  sample="test"
  assert equal "$(_rubsh.IO.printf "%s\n" "$sample")" "$(printf "%s\n" "$sample")"
  )
  end
end

describe "_rubsh.IO.puts"
  it "puts to stdout"
  (
  sample="test"
  assert equal "$(_rubsh.IO.puts "$sample")" "$(printf "%s\n" "$sample")"
  )
  end
end

describe "_rubsh.sh.alias_function"
  it "aliases a function"
    sample_f() { echo "hello"; }
    _rubsh.sh.alias_function sample2_f sample_f
    assert equal "$(sample2_f)" "hello"
  end
end

describe "_rubsh.sh.class"
  it "reports if it is an array"
    # shellcheck disable=SC2034
    sample_a=( 1 2 3 )
    assert equal "$(_rubsh.sh.class sample_a)" "array"
  end

  it "reports if it is a string"
    # shellcheck disable=SC2034
    sample_s="value"
    assert equal "$(_rubsh.sh.class sample_s)" "string"
  end
end

describe "_rubsh.sh.deref"
  it "dereferences a scalar variable"
    # shellcheck disable=SC2034
    sample_s="text sample"
    # shellcheck disable=SC2034
    indirect_v="sample_s"
    _rubsh.sh.deref indirect_v
    assert equal "$indirect_v" "text sample"
  end

  it "dereferences an array variable"
    # shellcheck disable=SC2034
    sample_a=( "testing" "one" "two" )
    # shellcheck disable=SC2034
    indirect_v="sample_a"
    _rubsh.sh.deref indirect_v
    assert equal "$(_rubsh.sh.class indirect_v)" "array"
    assert equal "${indirect_v[*]}" "${sample_a[*]}"
  end
end

describe "_rubsh.sh.is_var"
  it "detects a variable"
    sample_s="test"
    _rubsh.sh.is_var sample_s
    assert equal $? 0
  end

  it "doesn't detect a function"
    sample2_f() { echo hello ;}
    _rubsh.sh.is_var sample2_f
    assert equal $? 1
  end

  it "doesn't detect an undefined variable"
    _rubsh.sh.is_var no_var
    assert equal $? 1
  end
end

describe "_rubsh.sh.value"
  it "returns a scalar value"
    # shellcheck disable=SC2034
    sample_s="value text"
    assert equal "$(_rubsh.sh.value sample_s)" "$sample_s"
  end

  it "returns an array value"
    # shellcheck disable=SC2034
    sample_a=( "one" "two" "three" )
    assert equal "$(_rubsh.sh.value sample_a)" "$(printf "%s " "${sample_a[@]}")"
  end
end

describe "_rubsh.String.blank?"
# TODO: fail undefined test
  it "checks for empty string"
    # shellcheck disable=SC2034
    sample_s=""
    _rubsh.String.blank? sample_s
    assert equal $? 0
  end

  it "checks for string with only spaces"
    # shellcheck disable=SC2034
    sample_s=" "
    _rubsh.String.blank? sample_s
    assert equal $? 0
  end

  it "checks for string with only tabs"
    # shellcheck disable=SC2034
    sample_s=" 	"
    _rubsh.String.blank? sample_s
    assert equal $? 0
  end

  it "doesn't match strings with characters"
    # shellcheck disable=SC2034
    sample_s="ab "
    _rubsh.String.blank? sample_s
    assert equal $? 1
  end
end

describe "_rubsh.String.chomp"
  it "leaves a non-whitespace-surrounded string alone"
    sample_s="abc"
    result_s="abc"
    _rubsh.String.chomp sample_s
    assert equal "$sample_s" "$result_s"
  end

  it "removes whitespace from the start of a string"
    sample_s="	abc"
    result_s="abc"
    _rubsh.String.chomp sample_s
    assert equal "$sample_s" "$result_s"
  end

  it "removes whitespace from the end of a string"
    sample_s="abc 	"
    result_s="abc"
    _rubsh.String.chomp sample_s
    assert equal "$sample_s" "$result_s"
  end

  it "removes whitespace from both ends  of a string"
    sample_s=" abc 	"
    result_s="abc"
    _rubsh.String.chomp sample_s
    assert equal "$sample_s" "$result_s"
  end
end

describe "_rubsh.String.end_with?"
  it "affirms the positive"
    sample_s="a test"
    _rubsh.String.end_with? sample_s "t"
    assert equal $? 0
  end

  it "denies the negative"
    sample_s="a test"
    _rubsh.String.end_with? sample_s "r"
    assert equal $? 1
  end
end

describe "_rubsh.String.eql?"
  it "checks equality"
    # shellcheck disable=SC2034
    sample_s="abc"
    _rubsh.String.eql? sample_s "$sample_s"
    assert equal $? 0
  end

  it "fails inequality"
    # shellcheck disable=SC2034
    sample_s="abc"
    _rubsh.String.eql? sample_s ""
    assert equal $? 1
  end
end

describe "_rubsh.String.start_with?"
  it "affirms the positive"
    sample_s="a test"
    _rubsh.String.start_with? sample_s "a"
    assert equal $? 0
  end

  it "denies the negative"
    sample_s="a test"
    _rubsh.String.start_with? sample_s "r"
    assert equal $? 1
  end
end
