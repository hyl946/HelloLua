--[[
 * FiveTimesFourStar
 * @date    2018-04-03 15:07:38
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local FiveTimesFourStar = class(AchiNode)

function FiveTimesFourStar:ctor()
	self.id = 70
	self.levelType = self:genLevelType(GameLevelType.kMainLevel)
	self.requiredDataIds = {
		AchiDataType.kNewStar,
		AchiDataType.kOldStar,
	}
	require "zoo.panel.share.Share5Time4StarPanel"
	self.sharePanel = Share5Time4StarPanel
end

function FiveTimesFourStar:calLadder()
	local highestLevel = MetaManager.getInstance():getMaxNormalLevelByLevelArea()
	local list = FourStarManager:getInstance():getAllFourStarLevels()

	local ladder = {}
	local max = 0
	for _,data in ipairs(list) do
		if data.level <= highestLevel then
			max = max + 1
			table.insert(ladder, max*5)
		end
	end
	self.ladder = ladder
end

function FiveTimesFourStar:onCheckReach(data)
	if data[AchiDataType.kNewStar] == 4 and self:isGetNewStar( data ) then
		self.reachCount = self.reachCount + 1
		return self:isReachLadder(self.reachCount)
	end
	return false
end

function FiveTimesFourStar:getTargetValue()
	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	local highestLevelId = MetaManager.getInstance():getMaxNormalLevelByLevelArea()

	if highestLevelId < topLevelId then
		topLevelId = highestLevelId
	end

	local refs = UserManager.getInstance():getScoreRef()
	local count = 0

	for i,ref in ipairs(refs) do
		if ref.star == 4 and ref.levelId <= topLevelId then
			count = count + 1
		end
	end
	return count
end

Achievement:registerNode(FiveTimesFourStar.new())

local TotalFourStarCount = class(AchiNode)

function TotalFourStarCount:ctor()
	self.id = 520
	self.levelType = self:genLevelType(GameLevelType.kMainLevel)
	self.requiredDataIds = {
		AchiDataType.kNewStar,
		AchiDataType.kOldStar,
	}
end

function TotalFourStarCount:onCheckReach(data)
	if data[AchiDataType.kNewStar] == 4 and self:isGetNewStar( data ) then
		self.reachCount = self.reachCount + 1
		return self:isReachLadder(self.reachCount)
	end
	return false
end

function TotalFourStarCount:getTargetValue()
	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	local highestLevelId = MetaManager.getInstance():getMaxNormalLevelByLevelArea()

	if highestLevelId < topLevelId then
		topLevelId = highestLevelId
	end

	local refs = UserManager.getInstance():getScoreRef()
	local count = 0

	for i,ref in ipairs(refs) do
		if ref.star == 4 and ref.levelId <= topLevelId then
			count = count + 1
		end
	end
	return count
end

Achievement:registerNode(TotalFourStarCount.new())