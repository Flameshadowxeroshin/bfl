--bfl r2.2 by tertu
--this is public domain software.
--This library includes functions to convert bf code to Lua, optimizing it slightly.
--anyfuck.lua, a bf interpreter for Lua using bfl, should be included.
local bfl = {}

local function tableShallowCopy(tInput)
	local tOutput = {}
	for key,value in pairs(tInput) do
		tOutput[key] = value
	end
	return tOutput
end

local oPackedInstructions = {
	[">"] = "mp=(mp+$)@";
	["<"] = "mp=(mp-$)@";
	["+"] = "m[mp]=(m[mp]+$)&";
	["-"] = "m[mp]=(m[mp]-$)&";
	["."] = "io.write(string.rep(string.char(m[mp]%256),$))"}

local packedInstructions = oPackedInstructions

local oUnpackedInstructions = {
	[","] = "m[mp]=io.read(1):byte()&";
	["["] = "while m[mp]~=0 do";
	["]"] = "end"}

local unpackedInstructions = oUnpackedInstructions

local function setArrayCellModCode(arrayModCode, cellModCode)
	packedInstructions = tableShallowCopy(oPackedInstructions)
	unpackedInstructions = tableShallowCopy(oUnpackedInstructions)
	for key,sInst in pairs(packedInstructions) do
		packedInstructions[key] = sInst:gsub("%@",arrayModCode)
		packedInstructions[key] = sInst:gsub("%&",cellModCode)
	end
	for key,sInst in pairs(unpackedInstructions) do
		unpackedInstructions[key] = sInst:gsub("%&",cellModCode)
	end
end

setArrayCellModCode("","")


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
	local tokenInProgress = nil

	local function processCharacter(currentCharacter)
		if (not tokenInProgress) or tokenInProgress[1]~=currentCharacter then
			if tokenInProgress then
				table.insert(tokenTable, tokenInProgress)
			end
			tokenInProgress = {op=currentCharacter, count=0}
		end
		tokenInProgress.count = tokenInProgress.count + 1
	end

	sProgram:gsub("(.)",processCharacter)
	table.insert(tokenTable, tokenInProgress)
	return tokenTable
end

function bfl.decodeToken(tToken, arrayModCode, cellModCode)
	if arrayModCode or cellModCode
		arrayModCode = arrayModCode or ""
		cellModCode = cellModCode or ""
		setArrayCellModCode(arrayModCode,cellModCode)
	end
	local character = tToken[1]
	local codeBlock = packedInstructions[character] or unpackedInstructions[character]
	if codeBlock == nil then return "" end
	if packedInstructions[character] then
		codeBlock = codeBlock:gsub("%$",tostring(tToken[2]))
	end
	if unpackedInstructions[character] then
		local tsBlock = {}
		for i=1,tToken[2] do
			table.insert(tsBlock,codeBlock)
		end
		codeBlock = table.concat(body,"\n")
	end
	return codeBlock
end

function bfl.buildFromString(sProgram)
	local tokens = bfl.tokenize(sProgram)
	--modifications suggested by rdebath, they speed up the compile significantly
	local body = {header}
	for _,token in ipairs(tokens) do
		body[#body+1] = bfl.decodeToken(token)
	end
	return table.concat(body,"\n")
end

return bfl