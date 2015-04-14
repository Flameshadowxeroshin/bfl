bfl
===

A brainfuck library written in Lua and an interpreter using that library.

bfl features
==

* Runs in Lua 5.1 through 5.3. May run on 5.0.
* Produces intermediate Lua code that, while garbage, can be saved for later.
* Reasonable performance. Runs about as fast as a basic C interpreter with LuaJIT!
* No program-imposed limits on memory array size or cell size.
* Every test I've run on it seems to work just fine, as long as it's small enough. Really large programs don't compile.

! is not supported.

anyfuck features
==

* Support for brainfuck and multiple brainfuck dialects.
* Records time both for compilation and execution. And you can't turn it off.
