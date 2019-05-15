

local AskForHelpRules = class()

function AskForHelpRules:isValidMessage(uid, levelId)
	local uid = tostring(uid) or ""
	local levelId = tonumber(levelId) or 0

	local helpData = AskForHelpManager.getInstance():getHelpData()
	local info = helpData.recentHelpOtherRecords or {}
	for k,v in pairs(info) do
		if v.success  and v.levelId == levelId and v.uid == uid then
			return false
		end
	end
	return true
end

return AskForHelpRules

