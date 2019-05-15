require 'zoo.quest.QuestEvent'
require 'zoo.quest.QuestEventDispatcher'

local Quest = require 'zoo.quest.Quest'
local QuestFactory = require 'zoo.quest.QuestFactory'
local QuestActLogic = require 'zoo.quest.QuestActLogic'
local QuestHttp = require 'zoo.quest.QuestHttp'
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

_G.QuestManager = class()

local ThisModuleId = 0

function QuestManager:ctor( ... )

	self:registerListeners()
	self:reset()
end

local instance 
function QuestManager:getInstance( ... )
	if not instance then
		instance = QuestManager.new()
	end
	return instance
end

function QuestManager:registerListeners( ... )
	_G.questEvtDp:ad(QuestEventType.kFinish, self.onQuestFinish, self)
	_G.questEvtDp:ad(QuestEventType.kQuestUpdate, self.onQuestUpdate, self)

	_G.questEvtDp:ad(QuestEventType.kAfterPassOrFailLevel, deferFunc(self.afterLevel), self)
	_G.questEvtDp:ad(QuestEventType.kAfterQuitLevel, deferFunc(self.afterLevel), self)
	_G.questEvtDp:ad(QuestEventType.kAfterReplayLevel, deferFunc(self.afterLevel), self)
end

function QuestManager:afterLevel( event )
	for i, v in ipairs(_G.QuestChangeContext:getInstance():getData(ThisModuleId, true) or {}) do
		local quest = v.quest
		local _, _type = quest:getIdAndType()
		local t4 = 0
		if quest:isFinished() then
			t4 = 1
		end

		DcUtil:UserTrack({
			category='taskact', 
			sub_category='stage_end', 
			current_stage = event:getLevelId(), 
			meta_level_id = LevelMapManager.getInstance():getMetaLevelId(event:getLevelId()),
			t1 = _type, 
			t2 = v.newData.num - v.oldData.num, 
			t3 = v.newData.num, 
			t4 = t4,
			t5 = quest:getRelTarget(), 
		})

	end
end

function QuestManager:getQuestList( ... )
	return table.simpleClone(self.questList or {}) or {}
end

function QuestManager:getMaxGroupId( ... )
	local maxGroupId = -1
	for _, v in ipairs(self:getQuestList()) do
		maxGroupId = math.max(maxGroupId, v:getGroupId())
	end
	return maxGroupId
end

function QuestManager:getUnfinishedQuestsByGroupId( groupId )
	local ret = {}
	for _, v in ipairs(self:getQuestList()) do
		if (not groupId) or groupId == v:getGroupId() then
			if not v:isFinished() then
				table.insert(ret, v)
			end
		end
	end
	return ret
end

function QuestManager:getQuestsByGroupId( groupId )
	local ret = {}
	for _, v in ipairs(self:getQuestList()) do
		if (not groupId) or groupId == v:getGroupId() then
			table.insert(ret, v)
		end
	end
	return ret
end

function QuestManager:reset( ... )
	for _, quest in pairs(self:getQuestList()) do
		quest:dispose()
	end
	self.questList = {}
	self.questGroupRewarded = {}
end

function QuestManager:afterGotReward( groupId )
	table.insert(self.questGroupRewarded, groupId)
end

--每次UserManager中任务数据变化时, 都reset并readFromUserData
function QuestManager:readFromUserData(  )
	self:reset()

	local questSystemInfo = UserManager:getInstance().questSystemInfo or {}
	self.questGroupRewarded = table.clone(questSystemInfo.rewarded or {}, true)

	for groupId, groupData in pairs(questSystemInfo.quests) do
		for _, questRawData in ipairs(groupData) do
			self:addQuest(questRawData, groupId)
		end
	end

	QuestActLogic:updateTipView()
end

function QuestManager:writeToUserData(  )
	self:_writeToUserData(UserManager:getInstance().questSystemInfo)
	self:_writeToUserData(UserService:getInstance().questSystemInfo)
	Localhost:getInstance():flushCurrentUserData()
end

function QuestManager:_writeToUserData( questSystemInfo )
	-- body
	questSystemInfo.rewarded = table.clone(self.questGroupRewarded, true)
	questSystemInfo.quests = {}

	for _, quest in ipairs(self.questList) do
		local groupId = quest:getGroupId()
		if not questSystemInfo.quests[groupId] then
			questSystemInfo.quests[groupId] = {}
		end
		table.insert(questSystemInfo.quests[groupId], QuestFactory:encodeQuest(quest))
	end
end

function QuestManager:addQuest(rawData, groupId)
	local quest =  QuestFactory:createQuestByRawData(rawData, groupId)
	if quest then
		table.insert(self.questList, quest)
		_G.questEvtDp:dp(_G.QuestEvent.new(_G.QuestEventType.kTrigger, quest))
		quest:active()
	end
end

function QuestManager:removeQuest( quest )
	quest:dispose()
	table.removeValue(self.questList, quest)
end

function QuestManager:updateQuest( quest, rawData )
	quest:dispose()
	quest:setQuestData(rawData)
	quest:active()
end

function QuestManager:isEnabled( ... )
	return __WIN32
end

function QuestManager:onQuestFinish( evt )

	local quest = evt.data

	if quest and quest.getModuleId and quest:getModuleId() == ThisModuleId then
		self:writeToUserData()
		self:tryTriggerTasks()
		QuestActLogic:updateTipView()
	end

	-- local runningScene = Director:sharedDirector():getRunningScene()
	-- if (runningScene.name or '') ~= 'GamePlaySceneUI' then
		-- Notify:dispatch("AutoPopoutEventAwakenAction", FLGOutboxPopoutAction)
	-- end

end

function QuestManager:onQuestUpdate( evt )

	local quest = evt and evt.data and evt.data.quest
	if quest and quest.getModuleId and quest:getModuleId() == ThisModuleId then
		self:writeToUserData()
	end
end

function QuestManager:isAllFinished( ... )
	for _, v in ipairs(self:getQuestList()) do
		if not v:isFinished() then
			return false
		end
	end
	return true
end

function QuestManager:isGroupFinished( groupId )

	local hasThisGroupQuest = false
	for _, v in ipairs(self:getQuestList()) do
		if (v:getGroupId() == groupId) then
			hasThisGroupQuest = true
			if not v:isFinished() then
				return false
			end
		end
	end
	return hasThisGroupQuest
end


function QuestManager:tryTriggerTasks( callback )

	local function onFinish( ... )
		-- body
		if callback then callback() end
	end

	-- 触发
	-- 当前所有任务都完成或没有任务时 去触发新任务 
	-- 一次触发 产生N个新任务， N >= 0


	if QuestActLogic:isActEnabled() then
		if self:isAllFinished() then
			QuestHttp:triggerQuest(function ( info )
				UserManager:getInstance().questSystemInfo:fromLua(info)
				UserService:getInstance().questSystemInfo:fromLua(info)
				QuestManager:getInstance():readFromUserData()
				onFinish()
			end, onFinish, onFinish)
			return
		end
	end
	onFinish()
end

function QuestManager:hadGotRewards( groupId )
	return table.indexOf(self.questGroupRewarded, groupId)
end

function QuestManager:hasRewards( groupId )
	return self:isGroupFinished(groupId) and (not self:hadGotRewards(groupId))
end

function QuestManager:getReward( groupId, success, fail, cancel )
	QuestHttp:getReward(groupId, function ( ... )
		QuestActLogic:updateTipView()
		if success then success(...) end
	end, fail, cancel)
end


function QuestManager:getQuestsWithEndGameTip(levelId, levelType)
	return table.filter(self:getQuestList(), function ( v )
		return v:hasEndGameTip(levelId, levelType)
	end)
end