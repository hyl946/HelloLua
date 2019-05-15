--[[
 * PassLevelFourStars
 * @date    2018-04-10 10:25:48
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local PassLevelFourStars = class(ShareOnly)

function PassLevelFourStars:ctor()
	self.id = AchiId.kPassLevelFourStars
	self.levelType = self:genLevelType(GameLevelType.kMainLevel)
	require "zoo.panel.share.ShareFourStarPanel"
	self.sharePanel = ShareFourStarPanel
	self.requiredDataIds = {
		AchiDataType.kNewStar,
		AchiDataType.kOldStar,
	}
end

function PassLevelFourStars:onCheckReach(data)
	return data[AchiDataType.kNewStar] == 4 and self:isGetNewStar(data)
end

Achievement:registerNode(PassLevelFourStars.new())