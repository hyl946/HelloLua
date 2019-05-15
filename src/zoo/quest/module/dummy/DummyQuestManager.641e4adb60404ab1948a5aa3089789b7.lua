require 'zoo.quest.QuestEvent'
require 'zoo.quest.QuestEventDispatcher'

local Quest = require 'zoo.quest.Quest'
local QuestFactory = require 'zoo.quest.QuestFactory'

require 'zoo.quest.QuestChangeContext'

local function deferFunc( func )
	return function ( ... )
		local params = {...}
		setTimeOut(function (  )
			func(unpack(params))
		end, 0.0001)
	end
end

local function bind( func, p )
	return function (...)
		return func(p, ...)
	end
end

local DummyQuestManager = class()

local ThisModuleId = 1


function DummyQuestManager:ctor( ... )
	self:registerListeners()
	self:reset()
end

local instance 
function DummyQuestManager:getInstance( ... )
	if not instance then
		instance = DummyQuestManager.new()
	end
	return instance
end

function DummyQuestManager:registerListeners( ... )
	_G.questEvtDp:ad(QuestEventType.kFinish, self.onQuestFinish, self)
	_G.questEvtDp:ad(QuestEventType.kQuestUpdate, self.onQuestUpdate, self)
end

function DummyQuestManager:getQuestList( ... )
	return table.simpleClone(self.questList or {}) or {}
end

function DummyQuestManager:reset( ... )
	for _, quest in pairs(self:getQuestList()) do
		quest:dispose()
	end
	self.questList = {}
end


local DATA = {quests = {
	{_type = 11, relTarget = 10, num = 0},
	{_type = 11, relTarget = 10, num = 0},
	{_type = 11, relTarget = 10, num = 0},
	{_type = 11, relTarget = 10, num = 0},
	{_type = 11, relTarget = 10, num = 0},
}}

--每次UserManager中任务数据变化时, 都reset并readFromUserData
function DummyQuestManager:readFromUserData(  )
	self:reset()

	local questSystemInfo = DATA or {}

	for _, groupData in ipairs(questSystemInfo.quests) do
		self:addQuest(groupData)
	end

end

function DummyQuestManager:writeToUserData(  )
	self:_writeToUserData(DATA)
end

function DummyQuestManager:_writeToUserData( data )

end

function DummyQuestManager:addQuest(rawData)
	local quest =  QuestFactory:createQuestByRawData(rawData, 0, ThisModuleId)
	if quest then
		table.insert(self.questList, quest)
		_G.questEvtDp:dp(_G.QuestEvent.new(_G.QuestEventType.kTrigger, quest))
		quest:active()
	end
end

function DummyQuestManager:removeQuest( quest )
	quest:dispose()
	table.removeValue(self.questList, quest)
end

function DummyQuestManager:updateQuest( quest, rawData )
	quest:dispose()
	quest:setQuestData(rawData)
	quest:active()
end

function DummyQuestManager:isEnabled( ... )
	return __WIN32
end

function DummyQuestManager:onQuestFinish( evt )
	local quest = evt.data
	if quest and quest.getModuleId and quest:getModuleId() == ThisModuleId then
		self:writeToUserData()
		self:tryTriggerTasks()
	end
end

function DummyQuestManager:onQuestUpdate( evt )
	local quest = evt and evt.data and evt.data.quest
	if quest and quest.getModuleId and quest:getModuleId() == ThisModuleId then
		self:writeToUserData()
	end
end


function DummyQuestManager:isAllFinished( ... )
	for _, v in ipairs(self:getQuestList()) do
		if not v:isFinished() then
			return false
		end
	end
	return true
end

function DummyQuestManager:tryTriggerTasks( )
	DATA = DATA
	DummyQuestManager:getInstance():readFromUserData()
end

return DummyQuestManager