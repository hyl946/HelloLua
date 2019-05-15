local Quest = require 'zoo.quest.Quest'

local QuestMix = class(Quest)

function QuestMix:decode( rawData )
	self.data.subQuestList = {}
	local QuestFactory = require 'zoo.quest.QuestFactory'
	for _, v in ipairs(rawData.subRawData) do
		local quest = QuestFactory:createQuestByRawData(v, -1)
		if quest then
			table.insert(self.data.subQuestList, quest)
			_G.questEvtDp:dp(_G.QuestEvent.new(_G.QuestEventType.kSubQuestTrigger, quest))
			quest:thisIsASubQuest()
			quest:active()
		end
	end 

end

function QuestMix:encode( ... )
	local rawData = {}
	rawData.subRawData = {}
	for _, v in ipairs(self.data.subQuestList) do
		table.insert(rawData.subRawData, v:encode())
	end
	return rawData
end

function QuestMix:_isFinished( ... )
	for _, subQuest in ipairs(self.data.subQuestList) do
		if not subQuest:_isFinished() then
			return false
		end
	end
	return true
end

function QuestMix:registerAllListener( ... )
	self:registerListener(_G.QuestEventType.kSubQuestFinish, self.onSubQuestFinish)
	self:registerListener(_G.QuestEventType.kSubQuestUpdate, self.onSubQuestUpdate)
end

function QuestMix:onSubQuestUpdate( ... )
	self:afterUpdate()
end

function QuestMix:onSubQuestFinish( ... )
	self:afterUpdate()
	self:checkFinish()
end


function QuestMix:doAction( ... )
	for _, subQuest in ipairs(self.data.subQuestList) do
		if not subQuest:_isFinished() then
			return subQuest:doAction()
		end
	end
	return false
end

return QuestMix