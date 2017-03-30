Rubsh
=====

Enhanced data types for bash, inspired by Ruby - lovingly pronounced
"rubbish"

Bash, while powerful, has a frequently frustrating programming model.
Among other things, its combination of dynamic scoping, limited data
types and expansion-based command processing can make it tricky to learn
and difficult to accomplish complex tasks.

Fortunately, bash does a lot for you as well. If there is system
manipulation to be done on a Unix system, it can typically be done with
bash, and frequently with a minimum of syntax. Using bash for logic
rather than system manipulation is where Bash tends to fall down.

While there are many ways bash could stand improvement, rubsh focuses on
one: making it easier to work with bash's built-in data types.

The way rubsh attempts to do so is by providing an object-model for
those data types, including methods and inheritance. While it does not
provide much in the way of structured data typing beyond the basic
string, array and hash (a.k.a. associative array) types, rubsh does
provide useful and intuitive methods for manipulating them.

It cribs some of its organization from ruby's core libraries, making
functionality easier to absorb and remember. Rubsh also borrows file and
path manipulation concepts from ruby's apis.

How It Works
------------

Rubsh provides some basic classes:

-   String - self-explanatory

-   Array - some sorely-needed standard functions for manipulating lists
    of strings

-   Hash - associative array manipulation

-   File, Dir - reading, writing and testing files and directories

-   Path - working with directory and file names

Rubsh doesn't change the underlying data types, so for example, hashes
can still only store strings as values, but the methods available to
manipulate them are new with rubsh.

Each class is actually a bash function. According to the ruby convention
for class names, they are all capitalized as shown above.

These classes are used to create "object" instances, which correspond to
individual variables you might use in your script. The objects
themselves are also simply bash functions, created for you by rubsh's
normal syntax.

The first argument to the objects (i.e. functions) are usually the names
of methods, provided by the classes. While method names are just normal
string arguments, for the sake of similarity to ruby syntax, they are
invoked with a leading dot like so:

    File .new =myfile

This roughly corresponds to ruby's:

    myfile = File.new

Naturally, in order for rubsh to work, its functions ("File" in this
case) need to be the first word in the command line, which dictates some
differences from ruby's syntax.  Therefore the object name comes after
instead of in front of the assignment.

The equals sign attached to the object name hints to rubsh that this is
the object to create, rather than a normal argument to the .new method.
If there weren't such an argument, File.new would create an anonymous
file object, to be used by chaining with another method call or to be
consumed as the argument to a method call. But we'll get to that in a
bit.

This rubsh command would create a bash function called "myfile", which
has knowledge of all of the File class's associated methods.  myfile is
the object instance of the File class.

The myfile is supposed to represent what would normally be a bash
variable holding a filename. However, since myfile is a bash function,

it doesn't work as a bash variable. You can't reference it with
"$myfile" and it doesn't hold a value.

Instead, rubsh makes it appear as though the function is a variable by
presuming it should reference the value of the actual bash myfile
variable when the function is called.

The myfile bash variable has a separate existence, but once set, the
myfile function uses the variable's value automatically.  In fact, the
object is fairly useless without the corresponding variable.

Therefore you could just set the bash variable, then use the ".new"
method of the desired class to create the object:

    myfile=~/sample.txt
    File .new =myfile

File .new can't do this for you normally, since it could only create
global variables and rubsh avoids using the global namespace as much as
possible.  Instead, you can use the special form:

    $(File .new ^myfile ~/sample.txt)

Note the caret instead of dot for the object name.  This tells the
method to generate a statement on stdout, which the bash shell
substitution then evaluates in the local context, instantiating the
object and declaring the corresponding bash variable locally (like the
`local` bash built-in) in one go.  The caret is supposed to be
reminiscent of bash's redirection operators.

The new myfile object then has its own methods:

    myfile .write "some text for a file"
    myfile .append "some text for the end of a file"

As you can see, while rubsh is inspired by ruby's api, rubsh doesn't shy
away from amending it to be more bash-ish. For example, Ruby would
require you to open a file with a mode (and to close the file as well),
but rubsh does away with that in favor of a one-liner more like the
usual `echo "some text" >$filename`.

This simplicity also means rubsh is not as powerful as ruby, but rubsh
is pretty ok with that.

The myfile object's target is defined by the myfile variable. Set
the variable and you change what the object operates on:

    myfile=~/other_file.txt
    myfile .write "this appears in other_file.txt"

You can also use the "set" method instead of manipulating the variable
directly:

    myfile .set ~/other_file.txt

Features
--------

-   ruby-inspired apis for common objects

-   the ability to return arrays and hashes from methods

-   automatic chaining of the result of one method call to the input of
    another method, including arrays and hashes (this is not piping of
    stdout)

-   ruby block syntax for functional-style methods

-   passing arguments by object (i.e. variable)

-   a ruby-like DSL for creating classes using an actual object-model

-   a near-complete lack of dollar signs and quotation marks

-   economic use of bash's variable and function namespaces

-   intermixability with regular bash syntax

Installation
------------

Clone and put `lib` in your path, then use `source rubsh.bash` in your
scripts.

Usage
-----

    #!/usr/bin/env bash

    source rubsh.bash

    [...do rubbishy stuff...]
