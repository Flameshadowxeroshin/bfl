bfl
===

A brainfuck library written in Lua and an interpreter using that library.

bfl features
==

* Runs in both Lua 5.1 and 5.2. May run on 5.0.
* Produces intermediate Lua code that can be saved for later.
* Reasonable performance. Runs about 5-6 times slower than a good C interpreter.
* No limits on memory array size or cell size, limited only by Lua numbers.
* Every test I've run on it seems to work just fine.

Currently, there isn't support for !, so some code that depends on that won't work.

anyfuck features
==

* Support for brainfuck and multiple brainfuck dialects.
* Records time both for compilation and execution.