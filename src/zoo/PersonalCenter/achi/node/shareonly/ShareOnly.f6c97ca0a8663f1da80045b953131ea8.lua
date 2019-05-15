--[[
 * ShareOnly
 * @date    2018-04-10 10:14:23
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local config = unpack(require "zoo.PersonalCenter.achi.Config")
table.insert(config, {id = AchiId.kPassHighestLevel})
table.insert(config, {id = AchiId.kFristRankFriend})
table.insert(config, {id = AchiId.kAreaAllThreeStars})
table.insert(config, {id = AchiId.kPassLevelFourStars})
-- table.insert(config, {id = AchiId.kScoreOverFriend})
-- table.insert(config, {id = AchiId.kLevelOverFriend})
table.insert(config, {id = AchiId.kScoreOverNation})
table.insert(config, {id = AchiId.kLevelOverNation})

ShareOnly = class(AchiNode)

function ShareOnly:setup()
	self.priority = 0
	self.type = AchiType.SHARE
	self.category = 0

	self.state = AchiNodeState.WAIT_DATA

	if self.requiredDataIds then
		for _,dataId in ipairs(self.requiredDataIds) do
			Achievement:addDataMap(dataId, self)
		end
	end

	--share
	local SharePriority = (require "zoo.PersonalCenter.achi.ShareConfig")
	self.sharePriority = SharePriority[self.id]
end