#!/usr/bin/env bash

library=../lib/file.sh
source "${BASH_SOURCE%/*}/$library" 2>/dev/null || source "$library"
unset -v library

init() {
  result=$(mktemp --directory) || return
  _rubsh.IO.puts "$result"
}

cleanup() {
  validate_dirname "$1" || return
  rm -rf -- "$1"
}

validate_dirname() { [[ $1 == /tmp/tmp.* && -d $1 ]] ;}

describe "File.absolute_path"
  it "returns the full pathname by reference"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    cd "$temp"
    sample=file1
    assert equal "$(File.absolute_path :sample)" "$temp/$sample"
    cleanup "$temp"
    )
  end

  it "returns the full pathname by value"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    cd "$temp"
    sample=file1
    assert equal "$(File.absolute_path "$sample")" "$temp/$sample"
    cleanup "$temp"
    )
  end

  it "returns the full pathname with only relative by reference"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    cd "$temp"
    sample=..
    assert equal "$(File.absolute_path :sample)" "${temp%/*}"
    cleanup "$temp"
    )
  end

  it "returns the full pathname with only relative by value"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    cd "$temp"
    sample=..
    assert equal "$(File.absolute_path "$sample")" "${temp%/*}"
    cleanup "$temp"
    )
  end
  it "returns the full pathname without trailing slash by reference"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    cd "$temp"
    sample=dir1/
    assert equal "$(File.absolute_path :sample)" "$temp/dir1"
    cleanup "$temp"
    )
  end

  it "returns the full pathname without trailing slash by value"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    cd "$temp"
    sample=dir1/
    assert equal "$(File.absolute_path "$sample")" "$temp/dir1"
    cleanup "$temp"
    )
  end
end

describe "File.append"
  it "appends to a file by value"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    _rubsh.IO.puts "test" > "$temp"/file
    File.append "$temp"/file "line2"
    assert equal "$(tail -1 "$temp"/file)" "line2"
    cleanup "$temp"
    )
  end

  it "appends to a file by reference"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    _rubsh.IO.puts "test" > "$temp"/file
    # shellcheck disable=SC2034
    myfile=$temp/file
    File.append :myfile "line2"
    assert equal "$(tail -1 "$temp"/file)" "line2"
    cleanup "$temp"
    )
  end
end

describe "File.basename"
  it "finds the base name of a file by reference"
    (
    # shellcheck disable=SC2034
    sample=/home/gumby/work/ruby.rb
    result=$(File.basename :sample)
    assert equal "$result" "ruby.rb"
    )
  end

  it "finds the base name of a file by value"
    (
    # shellcheck disable=SC2034
    sample=/home/gumby/work/ruby.rb
    result=$(File.basename "$sample")
    assert equal "$result" "ruby.rb"
    )
  end

  it "finds the base name of trailing slash by reference"
    (
    # shellcheck disable=SC2034
    sample=/home/gumby/work/ruby.rb/
    result=$(File.basename :sample)
    assert equal "$result" "ruby.rb"
    )
  end

  it "finds the base name of a trailing slash by value"
    (
    # shellcheck disable=SC2034
    sample=/home/gumby/work/ruby.rb/
    result=$(File.basename "$sample")
    assert equal "$result" "ruby.rb"
    )
  end
end

describe "File.chmod"
  it "changes file mode by reference"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample=$temp/file
    install -m 660 /dev/null "$temp"/file
    File.chmod :sample 770
    assert equal "$(stat -c "%a" "$sample")" "770"
    cleanup "$temp"
    )
  end

  it "changes file mode by value"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample=$temp/file
    install -m 660 /dev/null "$temp"/file
    File.chmod "$sample" 770
    assert equal "$(stat -c "%a" "$sample")" "770"
    cleanup "$temp"
    )
  end
end

describe "File.directory?"
  it "detects a directory by value"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample=$temp/dir
    mkdir "$sample"
    File.directory? "$sample"
    assert equal $? 0
    cleanup "$temp"
    )
  end

  it "detects a directory by reference"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample=$temp/dir
    mkdir "$sample"
    File.directory? :sample
    assert equal $? 0
    cleanup "$temp"
    )
  end

  it "detects a non-directory by value"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample=$temp/file
    touch "$sample"
    File.directory? "$sample"
    assert equal $? 1
    cleanup "$temp"
    )
  end

  it "detects a non-directory by reference"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample=$temp/file
    touch "$sample"
    File.directory? :sample
    assert equal $? 1
    cleanup "$temp"
    )
  end

  it "detects a directory symlink by value"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample_dir=$temp/dir
    sample_link=$temp/dir2
    mkdir "$sample_dir"
    ln -sf "$sample_dir" "$sample_link"
    File.directory? "$sample_link"
    assert equal $? 0
    cleanup "$temp"
    )
  end

  it "detects a directory symlink by reference"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample_dir=$temp/dir
    sample_link=$temp/dir2
    mkdir "$sample_dir"
    ln -sf "$sample_dir" "$sample_link"
    File.directory? :sample_link
    assert equal $? 0
    cleanup "$temp"
    )
  end

  it "detects a non-directory symlink by value"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample_file=$temp/file
    sample_link=$temp/file2
    touch "$sample_file"
    ln -sf "$sample_file" "$sample_link"
    File.directory? "$sample_link"
    assert equal $? 1
    cleanup "$temp"
    )
  end

  it "detects a non-directory symlink by reference"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample_file=$temp/file
    sample_link=$temp/file2
    touch "$sample_file"
    ln -sf "$sample_file" "$sample_link"
    File.directory? :sample_link
    assert equal $? 1
    cleanup "$temp"
    )
  end
end

describe "File.dirname"
  it "determines the directory name with multiple components by reference"
    (
    sample=/home/gumby/work/ruby.rb
    assert equal "$(File.dirname :sample)" "/home/gumby/work"
    )
  end

  it "determines the directory name with multiple components by value"
    (
    sample=/home/gumby/work/ruby.rb
    assert equal "$(File.dirname "$sample")" "/home/gumby/work"
    )
  end

  it "determines the directory name without components by reference"
    (
    sample=ruby.rb
    assert equal "$(File.dirname :sample)" "."
    )
  end

  it "determines the directory name without components by value"
    (
    sample=ruby.rb
    assert equal "$(File.dirname "$sample")" "."
    )
  end

  it "determines the directory name with a trailing slash by reference"
    (
    sample=/home/gumby/work/ruby/
    assert equal "$(File.dirname :sample)" "/home/gumby/work"
    )
  end

  it "determines the directory name with a trailing slash by value"
    (
    sample=/home/gumby/work/ruby/
    assert equal "$(File.dirname "$sample")" "/home/gumby/work"
    )
  end
end

describe "File.executable?"
  it "detects an executable directory by value"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample_dir=$temp/dir
    mkdir -m 770 "$sample_dir"
    File.executable? "$sample_dir"
    assert equal $? 0
    cleanup "$temp"
    )
  end

  it "detects an executable directory by reference"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample_dir=$temp/dir
    mkdir -m 770 "$sample_dir"
    File.executable? :sample_dir
    assert equal $? 0
    cleanup "$temp"
    )
  end

  it "detects a non-executable directory"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample_dir=$temp/dir
    mkdir -m 660 "$sample_dir"
    File.executable? "$sample_dir"
    assert equal $? 1
    cleanup "$temp"
    )
  end

  it "detects an executable file by value"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample_file=$temp/file
    install -m 770 /dev/null "$sample_file"
    File.executable? "$sample_file"
    assert equal $? 0
    cleanup "$temp"
    )
  end

  it "detects an executable file by reference"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample_file=$temp/file
    install -m 770 /dev/null "$sample_file"
    File.executable? :sample_file
    assert equal $? 0
    cleanup "$temp"
    )
  end

  it "detects a non-executable file"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample_file=$temp/file
    install -m 660 /dev/null "$sample_file"
    File.executable? "$sample_file"
    assert equal $? 1
    cleanup "$temp"
    )
  end

  it "detects a symlink to an executable file"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample_file=$temp/file
    sample_link=$temp/file2
    install -m 770 /dev/null "$sample_file"
    ln -sf "$sample_file" "$sample_link"
    File.executable? "$sample_link"
    assert equal $? 0
    cleanup "$temp"
    )
  end

  it "detects a symlink to an executable directory"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample_dir=$temp/dir
    sample_link=$temp/dir2
    mkdir -m 770 "$sample_dir"
    ln -sf "$sample_dir" "$sample_link"
    File.executable? "$sample_link"
    assert equal $? 0
    cleanup "$temp"
    )
  end
end

describe "File.file?"
  it "detects a file by value"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample=$temp/file
    touch "$sample"
    File.file? "$sample"
    assert equal $? 0
    cleanup "$temp"
    )
  end

  it "detects a file by reference"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample=$temp/file
    touch "$sample"
    File.file? :sample
    assert equal $? 0
    cleanup "$temp"
    )
  end

  it "detects a non-file by value"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample=$temp/dir
    mkdir "$sample"
    File.file? "$sample"
    assert equal $? 1
    cleanup "$temp"
    )
  end

  it "detects a non-file by reference"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample=$temp/dir
    mkdir "$sample"
    File.file? :sample
    assert equal $? 1
    cleanup "$temp"
    )
  end

  it "detects a file symlink by value"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample_file=$temp/file
    sample_link=$temp/file2
    touch "$sample_file"
    ln -sf "$sample_file" "$sample_link"
    File.file? "$sample_link"
    assert equal $? 0
    cleanup "$temp"
    )
  end

  it "detects a file symlink by reference"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample_file=$temp/file
    sample_link=$temp/file2
    touch "$sample_file"
    ln -sf "$sample_file" "$sample_link"
    File.file? :sample_link
    assert equal $? 0
    cleanup "$temp"
    )
  end

  it "detects a non-file symlink by value"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample_dir=$temp/dir
    sample_link=$temp/dir2
    mkdir "$sample_dir"
    ln -sf "$sample_dir" "$sample_link"
    File.file? "$sample_link"
    assert equal $? 1
    cleanup "$temp"
    )
  end

  it "detects a non-file symlink by reference"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    #shellcheck disable=SC2154
    sample_dir=$temp/dir
    sample_link=$temp/dir2
    mkdir "$sample_dir"
    ln -sf "$sample_dir" "$sample_link"
    File.file? :sample_link
    assert equal $? 1
    cleanup "$temp"
    )
  end
end

describe "File.join"
  it "returns a path from two elements by value"
    (
    sample=/home/gumby/work
    file=ruby.rb
    assert equal "$(File.join "$sample" "$file")" /home/gumby/work/ruby.rb
    )
  end

  it "returns a path from two elements by reference"
    (
    sample=/home/gumby/work
    file=ruby.rb
    assert equal "$(File.join :sample :file)" /home/gumby/work/ruby.rb
    )
  end
end

describe "File.qgrep"
  it "detects the presence of text within a file by reference"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    sample=$temp/file
    _rubsh.IO.puts "hello" > "$sample"
    File.qgrep :sample "hello"
    assert equal $? 0
    cleanup "$temp"
    )
  end

  it "detects the absence of text within a file by reference"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    sample=$temp/file
    _rubsh.IO.puts "hello" > "$sample"
    File.qgrep :sample "what"
    assert equal $? 1
    cleanup "$temp"
    )
  end

  it "detects the presence of text within a file by value"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    sample=$temp/file
    _rubsh.IO.puts "hello" > "$sample"
    File.qgrep "$sample" "hello"
    assert equal $? 0
    cleanup "$temp"
    )
  end

  it "detects the absence of text within a file by value"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    sample=$temp/file
    _rubsh.IO.puts "hello" > "$sample"
    File.qgrep "$sample" "what"
    assert equal $? 1
    cleanup "$temp"
    )
  end
end

describe "File.readlink"
  it "returns the target of a link by reference"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    sample=$temp/file
    ln -sf file2 "$sample"
    assert equal "$(File.readlink :sample)" file2
    cleanup "$temp"
    )
  end

  it "returns the target of a link by value"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    sample=$temp/file
    ln -sf file2 "$sample"
    assert equal "$(File.readlink "$sample")" file2
    cleanup "$temp"
    )
  end
end

describe "File.realpath"
  it "determines the directory name with multiple components without symlinks or dots by reference"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    mkdir "$temp"/dir2
    touch "$temp"/dir2/file
    ln -sf dir2 "$temp"/dir
    sample=$temp/../..$temp/dir/file
    assert equal "$(File.realpath :sample)" "$temp"/dir2/file
    cleanup "$temp"
    )
  end

  it "determines the directory name with multiple components without symlinks or dots by value"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    mkdir "$temp"/dir2
    touch "$temp"/dir2/file
    ln -sf dir2 "$temp"/dir
    sample=$temp/../..$temp/dir/file
    assert equal "$(File.realpath "$sample")" "$temp"/dir2/file
    cleanup "$temp"
    )
  end
end

describe "File.symlink?"
  it "detects a symlink by reference"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    sample=$temp/file
    ln -sf file2 "$sample"
    File.symlink? :sample
    assert equal $? 0
    cleanup "$temp"
    )
  end

  it "detects a non-symlink by reference"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    sample=$temp/file
    File.symlink? :sample
    assert equal $? 1
    cleanup "$temp"
    )
  end

  it "detects a symlink by value"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    sample=$temp/file
    ln -sf file2 "$sample"
    File.symlink? "$sample"
    assert equal $? 0
    cleanup "$temp"
    )
  end

  it "detects a non-symlink by value"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    sample=$temp/file
    File.symlink? "$sample"
    assert equal $? 1
    cleanup "$temp"
    )
  end
end

describe "File.touch"
  it "updates the modified time on a file by reference"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    sample=$temp/file
    touch "$sample"
    sleep 0.1
    time=$(stat -c "%y" "$sample")
    File.touch :sample
    assert unequal "$time" "$(stat -c "%y" "$sample")"
    cleanup "$temp"
    )
  end

  it "updates the modified time on a file by value"
    (
    temp=$(init) || exit
    validate_dirname "$temp" || exit
    sample=$temp/file
    touch "$sample"
    sleep 0.1
    time=$(stat -c "%y" "$sample")
    File.touch "$sample"
    assert unequal "$time" "$(stat -c "%y" "$sample")"
    cleanup "$temp"
    )
  end
end
