--这个需求开始于 2018-12-14
--但在2019-01-10 19:39 还在改需求



local Quest = class()

function Quest:ctor(  )

	self.id = 0
	self._type = 0
	self.groupId = 0
	--毫秒

	self.moduleId = 0 

	-- self.triggerTS = 0
	self.data = {}

	self.finished = false

	self.listeners = {}

	self._subQuest = false
end

function Quest:thisIsASubQuest()
	self._subQuest = true
end

function Quest:isSubQuest( ... )
	return self._subQuest
end

function Quest:afterUpdate( ... )
	if self:isSubQuest() then
		_G.questEvtDp:dp(_G.QuestEvent.new(_G.QuestEventType.kSubQuestUpdate, {oldData = self._backupData, newData = self.data, quest = self}))
	else
		_G.questEvtDp:dp(_G.QuestEvent.new(_G.QuestEventType.kQuestUpdate, {oldData = self._backupData, newData = self.data, quest = self}))
	end
	self:backupData()
end

--初次创建一个任务加入QuestManager时调用
--工厂方法负责调用 begin
function Quest:setIdAndType( id, type )
	self.id = id
	self._type = type
end

function Quest:getIdAndType( ... )
	return self.id, self._type
end

function Quest:setGroupId( groupId )
	self.groupId = groupId
end

function Quest:getGroupId( ... )
	return self.groupId
end

function Quest:setModuleId( moduleId )
	self.moduleId = moduleId
end

function Quest:getModuleId( ... )
	return self.moduleId
end

function Quest:setQuestData( rawData )
	self.data.rawData = table.clone(rawData, true)
	self:decode(rawData)
	self:backupData()
end

function Quest:backupData( ... )
	self._backupData = table.clone(self.data or {}, true)
end

--工厂方法负责调用 end

--任务数据就绪之后调用， 该方法令未完成的任务对象开始工作，开始接受各种事件 更新自己的状态....
function Quest:active( ... )
	--finished long ago, just a historical quest
	self.finished = self:_isFinished()
	if not self.finished then
		self:registerAllListener()
	end
end

-- getter
function Quest:isFinished( ... )
	return self.finished
end


-- 各个任务子类 在适当的实际主动调用该方法
-- 触发一次 任务是否完成的检测
-- 通常在任务数据变化时调用
function Quest:checkFinish( ... )
	local finished = self:_isFinished()
	if finished then
		self:_finish()
	end
	return self:isFinished()
end

-- setter
function Quest:_finish( ... )
	self:beforeFinish()
	self.finished = true
	self:afterFinish()
end


function Quest:beforeFinish( ... )
	--已完成的任务 不需要再检测各种任务相关事件
	self:unregisterAllListener()
end


function Quest:afterFinish( ... )
	--notify everyone: i have finished...
	--注意: 这个事件不仅说给 围观任务系统的人听
	--      这个事件本身也可能会导致另外的任务发生变化,  假如有一个任务的目标是 完成N个其他任务....
	if self:isSubQuest() then
		_G.questEvtDp:dp(_G.QuestEvent.new(_G.QuestEventType.kSubQuestFinish, self))
	else
		_G.questEvtDp:dp(_G.QuestEvent.new(_G.QuestEventType.kFinish, self))
	end
end

-- 回收所有资源
function Quest:dispose( ... )
	self:unregisterAllListener()
end

--- listener helper
function Quest:registerListener( eventType, func )
	local listener = _G.questEvtDp:ad(eventType, func, self)
	table.insert(self.listeners, {eventType, func, listener})
end

function Quest:unregisterListener( eventType, func )
	local v, index = table.find(self.listeners, function ( v )
		return v[1] == eventType and v[2] == func
	end)

	_G.questEvtDp:rm(eventType, v[3])
	table.remove(self.listeners, index)
end
--
function Quest:unregisterAllListener( ... )
	for _, v in ipairs(table.simpleClone(self.listeners) or {}) do
		self:unregisterListener(v[1], v[2])
	end
end

-- 子类实现 注册所有自己需要的数据变化listener
function Quest:registerAllListener( ... )
	-- error('method[registerAllListener] has no implementation.')
end

function Quest:doAction( ... )
	return false
end

function Quest:encode( ... )
	return {
		relTarget = self.data.relTarget,
		num = self.data.num,
	}
end

function Quest:_isFinished( ... )
	return self.data.num >= self.data.relTarget
end

function Quest:decode( rawData )
	self.data.relTarget = rawData.relTarget
	self.data.num = rawData.num
	self.data.num = math.min(self.data.num, self.data.relTarget)
end

function Quest:getDesc( ... )
	-- body
	if self.moduleId > 0 then
		return localize('quest.desc.' .. self._type .. ':' .. self.moduleId, {
			relTarget = self.data.relTarget,
		})
	end

	return localize('quest.desc.' .. self._type, {
		relTarget = self.data.relTarget,
	})
end

function Quest:createIcon( ... )
	local UIHelper = require 'zoo.panel.UIHelper'
	local icon = UIHelper:createSpriteFrame('flash/quest-icon.json', 'quest-icon-dir/default0000')
	return icon
end

function Quest:getNum( ... )
	return self.data.num
end

function Quest:getRelTarget( ... )
	return self.data.relTarget
end

function Quest:hasEndGameTip( ... )
	return false
end

function Quest:getEndGameTip( ... )
	return 
end

function Quest:getEndGameTipText( ... )
	local _type = self._type
	return localize('quest.endgame.time.' .. _type)
end

return Quest