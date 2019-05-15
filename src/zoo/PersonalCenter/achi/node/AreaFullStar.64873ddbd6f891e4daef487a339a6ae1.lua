--[[
 * AreaFullStar
 * @date    2018-04-03 13:58:47
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local AreaFullStar = class(AchiNode)

function AreaFullStar:ctor()
	self.id = AchiId.kAreaFullStar
	self.levelType = self:genLevelType(GameLevelType.kMainLevel)
	self.requiredDataIds = {
		AchiDataType.kLevelId,
		AchiDataType.kOldStar,
		AchiDataType.kNewStar
	}
end

local function getStartLastLevelId( levelId )
	return math.ceil(levelId / 15 - 1)*15+1, math.ceil(levelId / 15)*15
end

function AreaFullStar:onCheckReach(data)
	local ladder = self.ladder

	local levelId = data[AchiDataType.kLevelId]

	if not self:isGetNewStar( data ) or data[AchiDataType.kOldStar] >= 3 then
		return false
	end

	local firstLevelId, lastLevelId = getStartLastLevelId(levelId)
	local isFullStar = true
	for levelId=firstLevelId,lastLevelId do
		local scoreRef = UserManager.getInstance():getUserScore(levelId)
		if not scoreRef or scoreRef.star < 3 then
			isFullStar = false
			break
		end
	end

	if isFullStar then
		self.reachCount = self.reachCount + 1
		return self:isReachLadder(self.reachCount)
	end

	return false
end

function AreaFullStar:getTargetValue()
	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	local max = math.floor(topLevelId / 15)
	local fullStarCount = 0
	for count=1,max do
		local isFullStar = true
		for index=1,15 do
			local levelId = 15*(count-1) + index
			local ref = UserManager:getInstance():getUserScore(levelId)
			if not ref or ref.star < 3 then
				isFullStar = false
				break
			end
		end

		if isFullStar then
			fullStarCount = fullStarCount + 1
		end
	end
	return fullStarCount
end

Achievement:registerNode(AreaFullStar.new())