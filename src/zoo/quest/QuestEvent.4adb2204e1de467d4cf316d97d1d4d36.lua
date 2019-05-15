require "hecore.EventDispatcher"

local getTotalStarByLevelId = require('zoo.quest.misc.misc').getTotalStarByLevelId

_G.QuestEventType = {}

local offlineHttpAdapterMap = {}

local function registerEventType( eventType )
	QuestEventType[eventType] = eventType
end

local function defaultOfflineHttpAdapter( ... )
	-- body
end

local function registerOfflineHttpEventType( eventType, offlineHttpAdapter )
	registerEventType(eventType)
	offlineHttpAdapterMap[eventType] = offlineHttpAdapter or defaultOfflineHttpAdapter
end


registerEventType 'kFinish'
registerEventType 'kSubQuestFinish'
registerEventType 'kTrigger'
registerEventType 'kSubQuestTrigger'
registerEventType 'kAfterPassOrFailLevel'
registerEventType 'kAfterPickFruit'
registerEventType 'kAfterQuitLevel'
registerEventType 'kAfterReplayLevel'
registerEventType 'kQuestUpdate'
registerEventType 'kSubQuestUpdate'
registerEventType 'kUsePreProps'
registerEventType 'kAskForHelpAfterPassOrFailLevel'
registerEventType 'kAfterEnergyRequest'
registerEventType 'kAfterLevelUp'
registerEventType 'kAfterAFHSuccess'


local QuestEvent = class(Event)

function QuestEvent:matchEventType( eventTypes )
	return table.indexOf(eventTypes, self.name) ~= nil
end

function QuestEvent:isPassLevel()
	if self:matchEventType{_G.QuestEventType.kAfterPassOrFailLevel} then
		return self.data.passLevel
	end
	return false
end


function QuestEvent:isPassNewLevel( ... )
	return self:isPassLevel() and (not self.data.hadPassed)
end

function QuestEvent:hasPassed( ... )
	return self.data.hadPassed
end

function QuestEvent:hasNewStar( ... )
	return self:isPassLevel() and self.data.star > (self.data.oldStar or 0)
end

function QuestEvent:isUnfullStarBeforeThisPlay( ... )
	if self:matchEventType{_G.QuestEventType.kAfterPassOrFailLevel} then
		local levelId = self.data.levelId
		local oldStar = self.data.oldStar
		if levelId and oldStar then
			if getTotalStarByLevelId(levelId) > oldStar then
				return true
			end
		end
	end	
	return false
end

function QuestEvent:matchLevelType( levelTypes )
	if self:matchEventType{
		_G.QuestEventType.kAfterPassOrFailLevel, 
		_G.QuestEventType.kAfterQuitLevel, 
		_G.QuestEventType.kAfterReplayLevel, 
		_G.QuestEventType.kAskForHelpAfterPassOrFailLevel, 
	} then
		return table.indexOf(levelTypes, self.data.levelType) ~= nil
	end
	return false
end

function QuestEvent:getPassLevelStar( ... )
	if self:isPassLevel() then
		return self.data.star
	end
	return 0
end

function QuestEvent:getLevelId( ... )
	if self:matchEventType{
		_G.QuestEventType.kAfterPassOrFailLevel, 
		_G.QuestEventType.kAfterQuitLevel, 
		_G.QuestEventType.kAfterReplayLevel, 
		_G.QuestEventType.kAskForHelpAfterPassOrFailLevel, 
	} then
		return self.data.levelId
	end
	return 0
end

_G.QuestEvent = QuestEvent
_G.QuestEvent.offlineHttpAdapterMap = offlineHttpAdapterMap
