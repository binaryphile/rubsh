Rubsh
=====

Enhanced data types for bash, inspired by Ruby - lovingly pronounced
"rubbish"

Bash, while powerful, has a frequently frustrating programming model.
Among other things, its combination of dynamic scoping, limited data
types and expansion-based command processing can make it tricky to learn
and difficult to accomplish complex tasks.

Fortunately, bash does a lot for you as well.  If there is system
manipulation to be done on a Unix system, it can typically be done with
bash, and frequently with a minimum of syntax.  Using bash for logic
rather than system manipulation is where Bash tends to fall down.

While there are many ways bash could stand improvement, rubsh focuses on
one: making it easier to work with bash's built-in data types.

The way rubsh attempts to do so is by providing an object-model for
those data types, including methods and inheritance.  While it does not
provide much in the way of structured data typing beyond the basic
string, array and hash (a.k.a. associative array) types, rubsh does
provide useful and intuitive methods for manipulating them.

It cribs some of its organization from ruby's core libraries, making
functionality easier to absorb and remember.  Rubsh also borrows file
and path manipulation concepts from ruby's apis.

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
manipulate them are new to bash.

Each class is actually a bash function.  According to the ruby
convention for class names, they are all capitalized as shown above.

These classes are used to create "object" instances, which correspond to
individual variables you might use in your script.  The objects
themselves are also simply bash functions, created for you by rubsh's
normal syntax.

The first argument to the objects (i.e. functions) are usually the names
of methods, methods provided by the classes.  While method names are
just normal string arguments, for the sake of similarity to ruby syntax,
they are invoked with a leading dot like so:

    File .new myfile

This roughly corresponds to ruby's:

    myfile = File.new

This rubsh command would make a function called "myfile", which has
knowledge of all of the File class's associated methods.  "myfile" is
the object instance of the File class.

The "myfile" instance is supposed to represent what would normally be a
bash variable holding a filename.  However, since "myfile" is a
function, it doesn't work as a bash variable.  You can't reference it
with "$myfile" and it doesn't hold a value.

Instead, rubsh makes it appear as though the function is a variable by
presuming it should reference the value of the actual bash "myfile"
variable when the function is called.

The "myfile" bash variable has a separate existence, but once set, the
"myfile" object uses the variable's value automatically.  In fact, the
object is fairly useless without the corresponding variable.

The normal usage therefore is to first declare or set the bash variable,
then use the ".new" method of the desired class to create the object:

    myfile=~/sample.txt
    File .new myfile

Or:

    $(File .new myfile ~/sample.txt)

The new "myfile" object then has its own methods:

    myfile .write "some text for a file"
    myfile .append "some text for the end of a file"

As you can see, while rubsh is inspired by ruby's api, rubsh doesn't shy
away from amending it to be more bash-y.  Ruby would require you to open
a file with a mode and to close the file as well, but rubsh does away
with that in favor of direct one-line access.  The simplicity also means
rubsh is not as powerful as ruby, but rubsh is pretty ok with that
trade-off.

The "myfile" object's target is defined by the "myfile" variable.  Set
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
    another method, including arrays and hashes

-   ruby block syntax for functional-style methods

-   passing arguments by object (i.e. variable)

-   a ruby-like DSL for creating classes using an actual object-model

-   a near-complete lack of dollar signs and quotation marks

-   compatibility with regular bash syntax

Installation
------------

Clone and put `lib` in your path, then use `source rubsh.bash` in your
scripts.

Usage
-----

    #!/usr/bin/env bash

    source rubsh.bash

    [...do rubbishy stuff...]
