--[[
 * AreaAllThreeStars
 * @date    2018-04-09 19:52:35
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local AreaAllThreeStars = class(ShareOnly)

function AreaAllThreeStars:ctor()
	self.id = AchiId.kAreaAllThreeStars
	self.levelType = self:genLevelType(GameLevelType.kMainLevel)
	require "zoo.panel.share.ShareTrophyPanel"
	self.sharePanel = ShareTrophyPanel
	self.requiredDataIds = {AchiDataType.kOldScore,AchiDataType.kNewStar,AchiDataType.kOldStar}
end

function AreaAllThreeStars:getShareConfig()
	local shareConfig = AchiNode.getShareConfig(self)
	shareConfig.shareTitle1 = "show_off_desc_40_1"
	return shareConfig
end

local function getStartLastLevelId( levelId )
	return math.ceil(levelId / 15 - 1)*15+1, math.ceil(levelId / 15)*15
end

function AreaAllThreeStars:onCheckReach(data)
	local levelId = data[AchiDataType.kLevelId]
	local firstLevelId,lastLevelId = getStartLastLevelId(levelId)

	if not self:isGetNewStar(data) or data[AchiDataType.kOldStar] >= 3 then
		return false
	end
	
	local isFullStar = true
	for levelId=firstLevelId,lastLevelId do
		local scoreRef = UserManager:getInstance():getUserScore(levelId)
		if not scoreRef or scoreRef.star < 3 then
			isFullStar = false
			break
		end
	end

	return isFullStar
end

Achievement:registerNode(AreaAllThreeStars.new())