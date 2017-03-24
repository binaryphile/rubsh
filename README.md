Rubsh
=====

Ruby-inspired datatype enhancements for bash - pronounced "rubbish"

Rubsh is a trashy attempt at making bash scripting a bit more ruby-ish.

When sourced, rubsh adds a set of functions to your bash environment
that allow you to do ruby-like operations with data types. The
underlying bash semantics are unchanged, so you can mix rubsh with
regular bash and make your scripting just a bit rubbish. Or you can go
full rubsh, which will make your scripts look a good bit more like ruby
and just confuse the hell out of bashers and rubyists alike.

This library is for you if you like watching people's heads explode.

Why? Bash is pretty annoying, but it's really good at system-level
manipulation and it's on every platform. Rubsh makes it just slightly
less annoying to work with. Or maybe just different?

Examples
--------

    $ source rubsh.bash

    $ File.new filename

    $ filename=test.txt

    $ String.new text

    $ text="Some sample text"

    $ filename.write text

    $ cat test.txt

    Some sample text

Installation
------------

Clone and put `lib` in your path, then use `source rubsh.bash` in your
scripts.

Usage
-----

    #!/usr/bin/env bash

    source rubsh.bash

    [...do rubbishy stuff...]
