#!/usr/bin/lua
--anyfuck.lua r2.01 by tertu
--this is the initial ugly version of anyfuck.
--requires Lua 5.2 or later.
--this is public domain software.
if loadstring then load = loadstring end
local function foreachChar(s,fn)
	s:gsub(".",fn)
end

function makeSimpleFindReplace(translationTable,reqSpace)
	if reqSpace then
		local newTransTable = {}
		for sWord, bfInst in pairs(translationTable) do
			newTransTable[sWord.."%s*$"] = bfInst
		end
		translationTable = newTransTable
	end
	return function(s)
		for sWord,bfInst in pairs(translationTable) do
			s=s:gsub(sWord,bfInst)
		end
		return s
	end
end

local idioms = {
	brainfuck = function(s) return s end
}

--fred: There Once Was a Fish Named Fred
--NOTE: The language definition does not specify whether it is case-sensitive
--or not. In the interest of making things easier for myself, I have decided that
--it is.
idioms.fred = makeSimpleFindReplace({
	there="<",once=">",was="+",a="-",fish=".",
	named="[",Fred="]"},
true)

--headsecks
--A fun little language where byte values become brainfuck instructions.
function idioms.headsecks(s)
	local out = ""
	s:gsub(".", 
		function(c) 
			local v = (c:byte()-1)%8+1 
			out = out..("+-<>.,[]"):sub(v,v) end)
	return out
end

if not arg then
	print("This program cannot be run in an interactive Lua session.")
	return 1
end

if #arg==0 then
	print(string.format("usage: %s (-i idiom) program\nthe default idiom is brainfuck.",arg[0]))
	local idin = "supported idioms: "
	for k,_ in pairs(idioms) do idin=idin..k.." " end
	print(idin)
	return 1
end

local chosenIdiom = "brainfuck"
local fileName = ""

local nextIsIdiom = false
local showTime = false

for a=1, #arg do
	if arg[a] == "-i" then nextIsIdiom = true
	elseif nextIsIdiom then if idioms[arg[a]] then chosenIdiom = arg[a] end
	elseif arg[a] == "-t" then showTime = true
	else fileName = arg[a] end
end

bfl = require"bfl"
if not bfl then
	print("couldn't load the bfl library, make sure it is installed")
	return 1
end
local f = io.open(fileName,"r")
if not f then
	if fileName == "" then print("no file name given") else
	print("couldn't open file "..fileName) end
	return 1
end
local t = f:read("*all")
local cloq = os.clock()
local prgm = load(bfl.buildFromString(idioms[chosenIdiom](t)))
if prgm == nil then
	print("bf compile error, probably mismatched []")
	return 1
end
if showTime then print(string.format("compiled in %d ms",(os.clock()-cloq)*1000)) end
local cloq = os.clock()
prgm()
print()
if showTime then print(string.format("executed in %d ms",(os.clock()-cloq)*1000)) end
