require "zoo.data.DataRef"

LoginLocalLogic = class()

function LoginLocalLogic:refresh()
	UserLocalLogic:refreshEnergy()

	local user = UserService.getInstance().user
	local uid = user.uid
	--fix top level ID
	local topLevelId = user:getTopLevelId()
	local nextToplevelId = topLevelId + 1
	if not UserLocalLogic:isNewLevelAreaStart(nextToplevelId) then
		local animalScore = UserService.getInstance():getUserScore(topLevelId)
		if animalScore and animalScore.star >= 1 then
			if _G.isLocalDevelopMode then printx(0, "fix top level ID", nextToplevelId, topLevelId) end
			UserLocalLogic:updateTopLevelId(uid, nextToplevelId, 0)
		end
	end

	local HIDE_LEVEL_ID_START = 10000
	--fix userStar != scores star added
	local totalStar = 0
	local scores = ItemLocalLogic:getUserAllScores( uid )
	for k,score in pairs(scores) do
		if score.levelId < HIDE_LEVEL_ID_START then totalStar = totalStar + score.star end
	end
	if user:getStar() ~= totalStar then
		if _G.isLocalDevelopMode then printx(0, "fix userStar != scores star added", totalStar, user:getStar()) end
		UserLocalLogic:updateStar( uid, totalStar )
	end
	return user
end