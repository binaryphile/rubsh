Rubsh
=====

Enhanced data types for bash, inspired by Ruby - lovingly pronounced
"rubbish"

Bash, while powerful, has a frequently frustrating programming model.
Among other things, its combination of dynamic scoping, limited data
types and expansion-based command processing can make it tricky to learn
and difficult to accomplish complex tasks.

Fortunately, bash does a lot for you as well. If there is system
manipulation to be done on Unix, it can typically be done with bash, and
frequently with a minimum of (albeit strange) syntax. It's using bash
for logic rather than system manipulation where it tends to fall down.

While there are many ways bash could stand improvement, rubsh focuses on
one: making it easier to work with bash's built-in data types.

rubsh provides an object-model for those data types, including methods
and inheritance. rubsh doesn't offer more data types than the basic
string, array and hash (a.k.a. associative array) types, but it does
provide useful and intuitive methods for manipulating them.

It cribs as much of its organization from ruby's core libraries as
possible, making it easier to absorb, especially if you have ruby
experience. But it should also be fairly easy for anyone familiar with
general object-oriented concepts.

How It Works
------------

Rubsh provides some basic classes:

-   **String** - self-explanatory

-   **Array** - some sorely-needed standard functions for manipulating
    lists of strings

-   **Hash** - associative array manipulation

-   **File**, **Dir** - reading, writing and testing files and
    directories

-   **Path** - working with directory and file names

Rubsh doesn't change the underlying data types, so for example, hashes
can still only store strings as values, but the methods available to
manipulate them are new with rubsh.

Each class is actually a bash function. According to the ruby convention
for class names, they are all capitalized as shown above.

These classes are used to create "object" instances, which correspond to
individual variables you might use in your script. The objects
themselves are also simply bash functions, created for you by rubsh.

The first argument to an object (i.e. function) is usually the name of a
method. While method names are just normal string arguments, for the
sake of similarity to ruby syntax, they are supplied with a leading dot:

    File .new <arguments>

Because File is a function, the method name is separated by a space so
that it is the first argument to the function. In this case, the \#new
method creates a new object instance of the File class. This roughly
corresponds to ruby's `File.new`

Naturally, in order for rubsh to work, its functions need to be the
first word in the command line. This dictates some differences from
ruby's syntax.

For example, ruby would normally assign the result of \#new to a
variable:

    myfile = File.new "#{Dir.home}/sample.txt"

You would then call a method such as \#readlines on the myfile object.

rubsh needs File to be first on the command line, so it turns the syntax
around a bit by necessity:

    File myfile := ~/sample.txt

This is an unorthodox call to File\#new, but it is still a method call.
This is one of the few cases where rubsh does some magic to infer the
method from the syntax.

rubsh's File\#new does two things. First, it creates a bash string
variable named myfile. Second, it creates a bash function, also called
myfile.

The string variable stores the given filename, just like any other bash
variable would. It can be used with all the usual bash functions and
expansions for strings.

The function is rubsh's contribution. The myfile function represents the
object instance of the File class. It's what responds to File methods:

    Array lines := myfile .readlines

myfile, the function, knows how to respond to File's methods. When it
needs to determine the filename on which it should operate, it uses
myfile, the variable. Unsurprisingly, changing the myfile variable's
contents changes the filename targeted by the function.

The scope of the myfile variable (local to the current function or
global) depends on a couple things.

If the variable myfile existed when \#new was called, then its existing
scope remains in effect. This way you can directly control the scope
with your own declaration prior to calling \#new.

Otherwise the variable is created globally by default. This may be what
you want, in which case the normal invocation is fine.

Hash variables are the one exception to this, since bash requires
explicit declaration for hashes. To create a hash variable, you should
declare the variable yourself before instantiating the object. Here is
how you declare a global hash variable:

    declare -Ag myhash
    Hash myhash := '( [zero]=0 )'

Global scoping may not always be what you want, however. You may declare
the variable local yourself, similar to the above example:

    local myfile
    File myfile := ~/sample.txt

However there is another, more compact alternative for local declaration
instead:

    $(File myfile = ~/sample.txt)

The equals-caret sign calls File\#declare, which generates a statement
on stdout. The statement declares the variable as local, and also
instantiates the object. The statement is captured and executed by the
bash shell substitution `$()`.

The caret was chosen to be reminiscent of bash's redirection operators.

This method works for hash variables as well, so they do not require a
separate declaration statement:

    $(Hash myhash = '( [zero]=0 )')

There are a number of other useful features which make rubsh quite
pleasurable to work with over standard bash. I invite you to read the
test suite and documentation to learn more.

Features
--------

-   ruby-inspired apis for common objects

-   the ability to return arrays and hashes from methods

-   automatic chaining of the result of one method call to the input of
    another method, including arrays and hashes

-   ruby-inspired block syntax for functional-style methods
    (.each, .map)

-   control over variable scope

-   a near-complete lack of dollar signs and quotation marks

-   a ruby-like DSL for creating classes using an actual object-model

-   economic use of bash's variable and function namespaces

-   interoperability with standard bash syntax

Installation
------------

Clone and put `lib` in your path, then use `source rubsh.bash` in your
scripts.

Usage
-----

    #!/usr/bin/env bash

    source rubsh.bash

    [...do rubbishy stuff...]
