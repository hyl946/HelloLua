--[[
 * NStarReward
 * @date    2018-04-03 16:00:09
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local NStarReward = class(AchiNode)

function NStarReward:ctor()
	self.id = 90
	self.levelType = self:genLevelType(GameLevelType.kMainLevel, GameLevelType.kHiddenLevel)
	self.requiredDataIds = {
		AchiDataType.kOldStar,
		AchiDataType.kNewStar
	}
	require "zoo.panel.share.ShareNStarRewardPanel"
	self.sharePanel = ShareNStarRewardPanel
end

function NStarReward:calLadder()
	local ladder = {}
	local starReward = MetaManager.getInstance().star_reward
	for _,reward in ipairs(starReward) do
		table.insert(ladder, reward.starNum)
	end
	self.ladder = ladder
end

function NStarReward:onCheckReach(data)
	if not self:isGetNewStar(data) then
		return false
	end

	local curTotalStar 	= UserManager:getInstance().user:getTotalStar()
	self.reachCount = curTotalStar
	return self:isReachLadder(curTotalStar)
end

function NStarReward:getTargetValue()
	return UserManager:getInstance().user:getTotalStar()
end

Achievement:registerNode(NStarReward.new())