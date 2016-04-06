# hex utils

This is a (hopefully smallish) utility library with various functions from
books, such as "On Lisp", "Let Over Lambda", "Land of Lisp" and a handful of
things I personally found helpful and thought would be nice in a library.

I know that there are a bunch of Lisp utility libraries out there, but this is
my own personal "Batman Utility Belt"!!

If you are going to include this in one of your projects, please be sure to 
`(use-package "HEX-UTILS")` or have it in the `:use` part of your `defpackage`
as this is very macro-heavy, and the macros may not expand into your namespace
successfully unless you do this.  Not a big deal, but could prevent headaches!
If you know how to fix this, feel free to fork and make a pull request!
