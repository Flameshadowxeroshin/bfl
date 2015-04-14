--bfl3 r0 by tertu
--tokens module
local tokens = {}



function tokens.tokenize(sProgram)
	local tokenTable = {}
	local tokenInProgress = nil

	local function processCharacter(currentCharacter)
		if (not tokenInProgress) or tokenInProgress.op~=currentCharacter then
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

return tokens