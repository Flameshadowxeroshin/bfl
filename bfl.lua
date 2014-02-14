--bfl r1a by tertu
--licensed under cc0
--This library includes functions to convert bf code to Lua, optimizing it slightly.
--bf.lua, a bf interpreter for Lua using bfl, should be included.
local bfl = {}
local joinFormat = "%s\n%s"

local packedInstructions = {
	[">"] = "mp=(mp+$)@";
	["<"] = "mp=(mp-$)@";
	["+"] = "m[mp]=(m[mp]+$)&";
	["-"] = "m[mp]=(m[mp]-$)&";
	["."] = "io.write(string.rep(string.char(m[mp]%256),$))"}

local unpackedInstructions = {
	[","] = "m[mp]=io.read(1):byte()&";
	["["] = "while m[mp]~=0 do";
	["]"] = "end"}

local function prepToken(tToken,character)
	tToken[1] = character
	tToken[2] = 1
	return tToken
end

local header = [[local m = {}
setmetatable(m, {__index = function() return 0 end})
local mp = 1
]]

function bfl.tokenize(sProgram)
	local tokenTable = {}
	local tokenInProgress = {}
	local currentCharacter = ""
	local lengthCounter = 0
	for position=1,#sProgram+1 do
		currentCharacter = sProgram:sub(position,position)
		if #tokenInProgress == 0 then
			prepToken(tokenInProgress, currentCharacter)
		elseif tokenInProgress[1] ~= currentCharacter then
			table.insert(tokenTable, tokenInProgress)
			tokenInProgress = prepToken({},currentCharacter)
		elseif #sProgram==position then
			table.insert(tokenTable, tokenInProgress)
		else
			tokenInProgress[2] = tokenInProgress[2]+1
		end
	end
	return tokenTable
end

--old token decoder. doesn't support wrapping.
--[[
function bfl.decodeToken(tToken)
	local character = tToken[1]
	if packedInstructions[character] then
		local s = packedInstructions[character]:gsub("%$", tToken[2])
		return s
	elseif unpackedInstructions[character] then
		local line = unpackedInstructions[character]
		local outputBlock = line
		for count=1,tToken[2]-1 do
			outputBlock = string.format(joinFormat, outputBlock, line)
		end
		return outputBlock
	end
	return ""
end]]

--Bad arrayModCode or cellModCode values will render the Lua uncompilable.
function bfl.decodeToken(tToken, arrayModCode, cellModCode)
	arrayModCode = arrayModCode or ""
	cellModCode = cellModCode or ""
	local elements = {["$"]=tToken[2], ["@"]=arrayModCode, ["&"]=cellModCode}
	local function elementReplace(c) return elements[c] end
	local character = tToken[1]
	local codeBlock = packedInstructions[character] or unpackedInstructions[character]
	if codeBlock == nil then return "" end
	if packedInstructions[character] then
		codeBlock = codeBlock:gsub("(%$)",elementReplace)
	end
	codeBlock = codeBlock:gsub("(%@)",elementReplace)
	codeBlock = codeBlock:gsub("(%&)",elementReplace)
	if unpackedInstructions[character] then
		codeBlock = codeBlock:gsub("(%&)",elementReplace)
		local tBlock = ""
		for i=1,tToken[2] do
			tBlock = joinFormat:format(tBlock, codeBlock)
		end
		codeBlock = tBlock
	end
	return codeBlock
end

function bfl.buildFromString(sProgram)
	local tokens = bfl.tokenize(sProgram)
	local body = header
	for _,token in ipairs(tokens) do
		body = string.format(joinFormat, body, bfl.decodeToken(token))
	end
	return body
end

return bfl