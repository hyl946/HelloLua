--[[
 * PassHighestLevel
 * @date    2018-04-09 17:55:11
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local PassHighestLevel = class(ShareOnly)

function PassHighestLevel:ctor()
	self.id = AchiId.kPassHighestLevel
	self.levelType = self:genLevelType(GameLevelType.kMainLevel)
	require "zoo.panel.share.SharePyramidPanel"
	self.sharePanel = SharePyramidPanel
	self.requiredDataIds = {
		AchiDataType.kRankData,
	}
end

function PassHighestLevel:getShareConfig()
	local shareConfig = AchiNode.getShareConfig(self)
	shareConfig.shareTitle = shareConfig.shareTitle.."_1"
	return shareConfig
end

function PassHighestLevel:requireData(data)
	if not self:isHighestLevel(data) then
		return
	end

	local scheduleScriptFuncID
	local function onSuccess( evt )
		local data = { 
			rank=evt.data.rank or 0,
			friendRank=evt.data.friendRank or 0
		}
		Notify:dispatch("AchiEventDataUpdate",AchiDataType.kRankData,data)
		cancelTimeOut(scheduleScriptFuncID)
	end

	local function onFail( ... )
		local data = { rank=0,friendRank=0 }
		Notify:dispatch("AchiEventDataUpdate",AchiDataType.kRankData, data)
		cancelTimeOut(scheduleScriptFuncID)
	end

	local http = recordAndGetTopLevelRank.new(false)
	http:addEventListener(Events.kComplete,onSuccess)
	http:addEventListener(Events.kError,onFail)

	scheduleScriptFuncID = setTimeOut(function( ... )
		local data = { rank=0,friendRank=0,t3=1 }
		Notify:dispatch("AchiEventDataUpdate", AchiDataType.kRankData, data)
		http:removeAllEventListeners()
	end,0.4)

	http:load(kMaxLevels)
end

function PassHighestLevel:isHighestLevel(data)
	return MetaManager.getInstance():getMaxNormalLevelByLevelArea() == data[AchiDataType.kLevelId]
end

function PassHighestLevel:onCheckReach(data)
	if not self:isNotRepeatLevel( data, true ) then
		return false
	end

	return self:isHighestLevel(data)
end

Achievement:registerNode(PassHighestLevel.new())