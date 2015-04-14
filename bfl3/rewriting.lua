--bfl3 r0 by tertu
--rewriting module
--operations:
--[[
cell 
]]
local rewriting = {}

--rewriting.translate(tkParsed)
--Takes tokens in tkParsed, and turns them into the standard representation
function rewriting.translateOneToken(tkParsed)
	local tkOutput = {op=nil, offset=nil, relative=false, count=0}
	if tCurrent.char == "+" then
		op="cell"
		count=tCurrent.count
	elseif tCurrent.char == "-" then
		op="cell"
		count=-tCurrent.count
	elseif tCurrent.char == "<" then
		op="memory"
		count=-tCurrent.count
	elseif tCurrent.char == ">" then
		op="memory"
		count=tCurrent.count
	elseif tCurrent.char == "." then
		op="output"
		count=tCurrent.count
	elseif tCurrent.char == "," then
		op="input"
		count=tCurrent.count
	elseif tCurrent.char == "[" then
		--whilestart isn't a real operation but we don't check loops here so
		op="whilestart!"
	elseif tCurrent.char == "]" then
		op="whileend!"
	else
		return nil
	end
	return tkOutput
end
