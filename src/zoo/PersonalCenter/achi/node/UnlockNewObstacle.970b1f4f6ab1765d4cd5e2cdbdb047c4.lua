--[[
 * UnlockNewObstacle
 * @date    2018-04-02 10:36:47
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local UnlockNewObstacle = class(AchiNode)

function UnlockNewObstacle:ctor()
	self.id = 50
	self.levelType = self:genLevelType(GameLevelType.kMainLevel)
	self.requiredDataIds = {
		AchiDataType.kOldScore,
		AchiDataType.kLevelId,
		AchiDataType.kOldIsJumpLevel,
	}
	
	require "zoo.panel.share.ShareUnlockNewObstaclePanel"
	self.sharePanel = ShareUnlockNewObstaclePanel
end

function UnlockNewObstacle:calLadder()
	local ladder = self.ladder
	local highestLevelId = MetaManager.getInstance():getMaxNormalLevelByLevelArea()

	for count = #ladder, 1 do
		local levelId = ladder[count]
		if levelId > highestLevelId then
			table.remove(self.ladder, count)
		end
	end
end

function UnlockNewObstacle:onCheckReach(data)
	local isReach = self:isNotRepeatLevel(data) and self:isReachLadder(data[AchiDataType.kLevelId], true)
	self.reachCount = self:getTargetValue()
	return isReach
end

function UnlockNewObstacle:getTargetValue()
	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	local highestLevelId = MetaManager.getInstance():getMaxNormalLevelByLevelArea()
	topLevelId = topLevelId < highestLevelId and topLevelId or highestLevelId
	return topLevelId
end

Achievement:registerNode(UnlockNewObstacle.new())