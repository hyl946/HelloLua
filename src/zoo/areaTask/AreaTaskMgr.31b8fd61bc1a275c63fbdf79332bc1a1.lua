local TickTaskMgr = require 'zoo.areaTask.TickTaskMgr'
local AreaTaskModel = require 'zoo.areaTask.AreaTaskModel'
local TaskFlowerIcon = require 'zoo.areaTask.TaskFlowerIcon'

local FlowerIconPriority = require 'zoo.data.FlowerIconPriority'

local MAINTENANCE_KEY_1 = 'AreaTask'
local MAINTENANCE_KEY_2 = 'NewAreaTask'

local Strategy = class()

function Strategy:ctor( mgr )
	self.mgr = mgr
end

function Strategy:process( ... )

end

local CDStrategy = class(Strategy)

function CDStrategy:process( ... )

	local nMSPerDay = 24 * 3600 * 1000
	-- body

	local szCdStr = MaintenanceManager:getInstance():getExtra(MAINTENANCE_KEY_2) or '7|10|20'
	local tCdList = string.split(szCdStr, '|') or {}

	local nDefault = 7

	local eTag = UserTagManager:getUserTag( UserTagNameKeyFullMap.kLevelUp)
	if (not eTag) or eTag == UserTagValueMap[UserTagNameKeyFullMap.kLevelUp].kNone or eTag == UserTagValueMap[UserTagNameKeyFullMap.kLevelUp].kLow then
		return (tonumber(tCdList[1] or nDefault) or nDefault) * nMSPerDay
	end

	if eTag == UserTagValueMap[UserTagNameKeyFullMap.kLevelUp].kNormal then
		return (tonumber(tCdList[2] or nDefault) or nDefault) * nMSPerDay
	end

	if eTag == UserTagValueMap[UserTagNameKeyFullMap.kLevelUp].kHigh then
		return (tonumber(tCdList[3] or nDefault) or nDefault) * nMSPerDay
	end

	return nDefault * nMSPerDay
end



local RewardsStrategy = class(Strategy)

function RewardsStrategy:process( taskCfg )

	if not taskCfg then return {} end
	if not taskCfg.rewardsList then return {} end

	local eTag = UserTagManager:getUserTag( UserTagNameKeyFullMap.kLevelUp)
	if (not eTag) or eTag == UserTagValueMap[UserTagNameKeyFullMap.kLevelUp].kNone or eTag == UserTagValueMap[UserTagNameKeyFullMap.kLevelUp].kLow then
		return taskCfg.rewardsList[1] or {}, taskCfg.rewardId
	end

	if eTag == UserTagValueMap[UserTagNameKeyFullMap.kLevelUp].kNormal then
		return taskCfg.rewardsList[2] or {}, taskCfg.rewardId
	end

	if eTag == UserTagValueMap[UserTagNameKeyFullMap.kLevelUp].kHigh then
		return taskCfg.rewardsList[3] or {}, taskCfg.rewardId
	end

	return {}, taskCfg.rewardId
end



local AreaTaskMgr = class()

_G.AreaTaskMgr = AreaTaskMgr

local instance

function AreaTaskMgr:getInstance( ... )
	if not instance then
		self:createInstance()
	end
	return instance
end

function AreaTaskMgr:createInstance( ... )
	if not instance then
		instance = AreaTaskMgr.new()
	end
end

function AreaTaskMgr:ctor( ... )
	self.data = AreaTaskModel.new()

	self.tickTaskMgr = TickTaskMgr.new()
	local CHECK_TASK_TASK_ID = 1
	self.tickTaskMgr:setTickTask(CHECK_TASK_TASK_ID, function ( ... )
		self:refreshFlower()
	end)
	self.tickTaskMgr:start()

	HomeScene:sharedInstance():ad(HomeSceneEvents.USERMANAGER_TOP_LEVEL_ID_CHANGE, function ( ... )
		self:onTopLevelChanged(true)
	end)

	AskForHelpManager.getInstance():addEventListener(AFHEvents.kAFHSuccessEvent, function ( ... )
		self:pullAllTaskInfo(function ( ... )
			self:onTopLevelChanged()
		end)
	end)

	self.callback_delayed = {}

	local __popout
	__popout = function( ... )
		local curScene = Director:sharedDirector():getRunningScene()
		if curScene == HomeScene:sharedInstance() then
			self:onUserIconMoved()
		end
	end
	GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kUserIconMoved, __popout)

end

function AreaTaskMgr:pullAllTaskInfo( onFinish )
	HttpBase:syncPost('areaTaskInfo', {}, function ( evt )
		local evt = evt or {}
		local data = evt.data or {}
		local serverAreaTaskInfo = data.areaTaskInfo or {}

		for _, taskInfo in ipairs(serverAreaTaskInfo.areaTasks or {}) do
			local levelId = taskInfo.levelId
			if levelId then
				local localInfo = self:__findTaskInfoByLevelIdAll(levelId)
				if localInfo then
					-- for k, v in pairs(localInfo) do
						-- taskInfo[k] = v
					-- end

					taskInfo.rewarded = taskInfo.rewarded or localInfo.rewarded
					taskInfo.finished = taskInfo.finished or localInfo.finished
				end
			end
		end
		self:getModel():setAreaTaskInfo(serverAreaTaskInfo)
		if onFinish then onFinish() end
	end, function ( ... )
		if onFinish then onFinish() end
	end, function ( ... )
		if onFinish then onFinish() end
	end)
end

function AreaTaskMgr:onUserIconMoved( ... )
	for i, v in ipairs(self.callback_delayed or {}) do
		v()
	end
	self.callback_delayed = {}
end

local groupNameList = {}
--A1 ~ Z1
for i = 1, 26 do
	table.insert(groupNameList, string.char(65 + i - 1) .. '1')
end

function AreaTaskMgr:isEnabled( ... )

	if self.__cache_isenable ~= nil then
		return self.__cache_isenable
	end

	
	self.__cache_isenable = false

	local uid = UserManager:getInstance():getUID() or "12345"


	if not self.__cache_isenable then
		if MaintenanceManager:getInstance():isEnabledInGroup(MAINTENANCE_KEY_2, 'A1', uid) then
			self.__cache_isenable = true
			self.rewardsStrategy = nil
			self.cdStrategy = CDStrategy.new()
			self.__cache_isenable_new = true
		end
	end

	if not self.__cache_isenable then
		if MaintenanceManager:getInstance():isEnabledInGroup(MAINTENANCE_KEY_2, 'A2', uid) or __WIN32 then
			self.__cache_isenable = true
			self.rewardsStrategy = RewardsStrategy.new()
			self.cdStrategy = CDStrategy.new()
			self.__cache_isenable_new = true
		end
	end

	if not self.__cache_isenable then
		for _, groupName in ipairs(groupNameList) do
			if MaintenanceManager:getInstance():isEnabledInGroup(MAINTENANCE_KEY_1, groupName, uid) and groupName ~= 'A1'then
				self.__cache_isenable = true
				self.rewardsStrategy = nil
				self.cdStrategy = nil
			end
		end
	end

	self.data.rewardsStrategy = self.rewardsStrategy
		
	return self.__cache_isenable
end

function AreaTaskMgr:getModel( ... )
	return self.data
end

function AreaTaskMgr:printLocalData( ... )
	-- printx(61, table.tostring(self:getModel():getCurTaskInfos()))
end

function AreaTaskMgr:onLevelSuccess( levelId )
	
	local taskInfo = self:findTaskInfoByLevelId(levelId + 1)
	if taskInfo and self:getModel():isTaskFinished(taskInfo) then
		ShareManager:disableShareUi()
	end
end


--随时可调 每秒要调 根据当前 任务情况 创建/删除/刷新 关卡花上的任务icon  只有当前有效的未完成任务 拥有关卡挂任务icon
function AreaTaskMgr:refreshFlower( ... )

	if not self:isEnabled() then
		return false
	end
	-- if not UserManager:getInstance():hasBAFlag(kBAFlagsIdx.kAreaTaskAnimation) then
		-- return
	-- end

	if not self.taskFlowerNodes then
		self.taskFlowerNodes = {}
	end

	local curTaskInfos = self:getModel():getCurUnfinishedInfos()

	local newAddTaskInfos = {}
	local invalidRemoveFlowerNodes = {}


	for levelId, node in pairs(self.taskFlowerNodes) do
		node.mark = false
	end

	for _, taskInfo in ipairs(curTaskInfos) do
		local levelId = taskInfo.levelId or 0
		if self.taskFlowerNodes[levelId] then
			self.taskFlowerNodes[levelId].mark = true
		else
			table.insert(newAddTaskInfos, taskInfo)
		end
	end



	for levelId, node in pairs(self.taskFlowerNodes) do
		if not node.mark then
			table.insert(invalidRemoveFlowerNodes, node)
		end
	end

	for _, node in ipairs(invalidRemoveFlowerNodes) do
		if not node.isDisposed then
			local taskInfo = node:getData()
			self.taskFlowerNodes[taskInfo.levelId or 0] = nil
			self:removeFromStage(node)
			node:dispose()
		end
	end

	for _, taskInfo in ipairs(newAddTaskInfos) do
		local node = TaskFlowerIcon:create()
		node:setData(taskInfo)
		self:addToStage(node)

		node:shake()

		self.taskFlowerNodes[taskInfo.levelId] = node
	end


	for _, node in pairs(self.taskFlowerNodes) do
		if not node.isDisposed then
			node:refreshUI()
		end
	end


	if #newAddTaskInfos + #invalidRemoveFlowerNodes > 0 then
		FlowerIconPriority:refresh()
	end

	newAddTaskInfos = {}
	invalidRemoveFlowerNodes = {}
end

function AreaTaskMgr:addToStage( node )
	if node.isDisposed then return end

	HomeScene:sharedInstance().worldScene.chestLayer:addChild(node)

	local taskInfo = node:getData()

	local levelId = taskInfo.levelId or 0

	local levelNode = HomeScene:sharedInstance().worldScene.levelToNode[levelId]

	if levelNode then
		local pos = levelNode:getPosition()
		node:setPosition(ccp(pos.x, pos.y))
	end
end

function AreaTaskMgr:removeFromStage( node )
	if node.isDisposed then return end

	local taskInfo = node:getData()
	local levelId = taskInfo.levelId or 0

	node:removeFromParentAndCleanup(false)

end

function AreaTaskMgr:onTopLevelChanged(delayPopout)

	if not self:isEnabled() then
		return false
	end

	if self:getModel():checkFinished() then

		local function __callback( ... )
			self:getRewardAndBroadcast()
		end

		if delayPopout then
			table.insert(self.callback_delayed, __callback)
		else
			__callback()
		end
	end

	if self:getModel():isInCD(self:getCDTime()) then
		return
	end


	if __IOS then
		if not self.__cache_isenable_new then
			return false
		end
	end

	self:getModel():triggerNewTask(function ( taskInfos )
		local canPop = false
		if #taskInfos > 0 then
			local topLevelId = self:getModel():safeGetTopLevel()
    		local areaId = math.floor((topLevelId - 1) / 15) + 40001

			Notify:dispatch("AutoPopoutEventAwakenAction", AreaTaskTriggerPopoutAction, areaId)
		end
	end)
end

function AreaTaskMgr:getCDTime( ... )

	if self.__cache__cd then
		return self.__cache__cd
	end


	if self.cdStrategy then
		self.__cache__cd = self.cdStrategy:process()
	else
		local cdStr = MaintenanceManager:getInstance():getExtra(MAINTENANCE_KEY_1) or ''
		local cdList = string.split(cdStr, ':')

		local uid = UserManager:getInstance():getUID() or "12345"
		local cd = 0
		for index, groupName in ipairs(groupNameList) do
			if MaintenanceManager:getInstance():isEnabledInGroup(MAINTENANCE_KEY_1, groupName, uid) and groupName ~= 'A1' then
				cd = (tonumber(cdList[index] or 0) or 0) * 60 * 1000
			end
		end
		self.__cache__cd = cd
	end
	
	return self.__cache__cd
end

function AreaTaskMgr:checkCanPop( cb )
	if not self:isEnabled() then
		if cb then cb(false) end
		return
	end

	local function checkFirst()
		local active30Days = tonumber(UserManager.getInstance().active30Days) or 0
		if active30Days >= 22 then
			if cb then cb(false) end
			return
		end

		--had tasks
		local curTaskInfos = self:getModel():getCurUnfinishedInfos()
		local hadFirstTask = table.find(curTaskInfos, function (v)
			return v and v.index == 1
		end)

		if not hadFirstTask then
			if cb then cb(false) end
			return
		end

		if cb then cb(true) end
	end 


	if __IOS then
		if not self.__cache_isenable_new then
			if cb then cb(false) end
			return
		end
	end


	if not self:getModel():isInCD(self:getCDTime()) then
		--TODO:need trigger
		self:getModel():triggerNewTask(function ( taskInfos )
			checkFirst()
		end)
	else
		if cb then cb(false) end
	end
end

function AreaTaskMgr:onEnterHomeScene( ... )

	if not self:isEnabled() then
		return false
	end

	if __IOS then
		if not self.__cache_isenable_new then
			return false
		end
	end


	if self:getModel():isInCD(self:getCDTime()) then
		return
	end

	self:getModel():triggerNewTask(function ( taskInfos )
		local canPop = #taskInfos > 0
		if canPop then
			local AreaTaskInfoPanel = require 'zoo.areaTask.AreaTaskInfoPanel'
	        local levelId = taskInfos[#taskInfos].levelId
	        local areaId = math.floor((levelId - 1) / 15) + 40001
	        local panel = AreaTaskInfoPanel:create(areaId)
	        panel:popoutPush()
		end
	end)
end

function AreaTaskMgr:onPopoutAction( onFinish, notPush )

	if not self:isEnabled() then
		if onFinish then onFinish() end
		return false
	end

	-- self:getRewardAction(onFinish, notPush)
	if onFinish then onFinish() end

	self:getRewardAndBroadcast()

end

function AreaTaskMgr:getRewardAndBroadcast( ... )
	-- body

	local tasks = self:getModel():getFinishedTasks() or {}
	local counter = #tasks + 1

	local taskInfos  = {}

	local rewards = {}

	local function __rewarded( ... )
		-- body
		counter = counter - 1
		if counter <= 0 then
			if #rewards > 0 then
			end
		end
	end

	for _, taskInfo in pairs(tasks) do

		self:getModel():getRewards(taskInfo, function ( _rewards )
			rewards = table.union(rewards, _rewards)
			BroadcastManager:getInstance():onAreaTaskRewarded(taskInfo, _rewards)
			__rewarded()
		end, function ( ... )
			__rewarded()
		end, function ( ... )
			__rewarded()
		end)
	end

	__rewarded()
end

function AreaTaskMgr:getRewardAction( onFinish, notPush)

	local max_continue_counter = 3

	local __getreward
	__getreward = function ( continue )
		if continue and max_continue_counter > 0 then
			max_continue_counter = max_continue_counter - 1
			self:__getRewardAction(__getreward, notPush)
		else
			if onFinish then onFinish() end
		end
	end
	self:__getRewardAction(__getreward, notPush)
end

function AreaTaskMgr:__getRewardAction( onFinish, notPush )
	
	local tasks = self:getModel():getFinishedTasks()


	if #tasks <= 0 then
		if onFinish then onFinish(false) end
	else
		local taskInfo = tasks[1]
		self:getModel():getRewards(taskInfo, function ( rewards )
			
			local AreaTaskRewardPanel = require 'zoo.areaTask.AreaTaskRewardPanel'
			local panel = AreaTaskRewardPanel:create(rewards)
			panel:ad(PopoutEvents.kRemoveOnce, function ( ... )
				if onFinish then onFinish(true) end
			end)
			if notPush then
				panel:popout()
			else
				panel:popoutPush()
			end
		end, function ( ... )
			if onFinish then onFinish(false) end
		end, function ( ... )
			if onFinish then onFinish(false) end
		end)
	end
end

function AreaTaskMgr:findFlourByLevelId( levelId )
	if self.taskFlowerNodes then
		return self.taskFlowerNodes[levelId]
	end
end

function AreaTaskMgr:findTaskInfoByLevelId( levelId )
	-- body
	local taskInfos = self:getModel():getCurTaskInfosWithExpired()

	local taskInfo = table.find(taskInfos, function ( v )
		return v.levelId == levelId
	end)

	return taskInfo

end

function AreaTaskMgr:__findTaskInfoByLevelIdAll( levelId )
	-- body
	local taskInfos = self:getModel():getCurTaskInfosAll()

	local taskInfo = table.find(taskInfos, function ( v )
		return v.levelId == levelId
	end)

	return taskInfo

end

function AreaTaskMgr:hasTaskAndFinished( levelId )
	if not self:isEnabled() then
		return false
	end	
	self:getModel():checkFinished()
	local taskInfos = self:getModel():getFinishedTasks()
	local taskInfo = table.find(taskInfos, function ( v )
		return v.levelId == levelId
	end)
	return taskInfo
end

function AreaTaskMgr:getRewardByLevelId( levelId , onFinish)
	local taskInfo = self:findTaskInfoByLevelId(levelId)
	if (not taskInfo) or (not self:getModel():isTaskFinished(taskInfo)) then
		if onFinish then onFinish() end
	else
		self:getModel():getRewards(taskInfo, function ( rewards )
			local AreaTaskRewardPanel = require 'zoo.areaTask.AreaTaskRewardPanel'
			local panel = AreaTaskRewardPanel:create(rewards)
			panel:ad(PopoutEvents.kRemoveOnce, function ( ... )
				if onFinish then onFinish(true) end
			end)
			panel:popout()
		end, function ( ... )
			if onFinish then onFinish(false) end
		end, function ( ... )
			if onFinish then onFinish(false) end
		end)
	end
end

function AreaTaskMgr:updateFlourVisible( )
	if self.taskFlowerNodes then
		for levelId, v in pairs(self.taskFlowerNodes) do
			if not v.isDisposed then
				v:setVisible(FlowerIconPriority:canShow(FlowerIconPriority.PRIORITY.kTASK, levelId))
			end
		end
	end
end


FlowerIconPriority:setCheckFunc(FlowerIconPriority.PRIORITY.kTASK, function ( levelId )
	return AreaTaskMgr:getInstance():findFlourByLevelId(levelId) ~= nil
end)

FlowerIconPriority:setRefreshFunc(FlowerIconPriority.PRIORITY.kTASK, function ( levelId )
	return AreaTaskMgr:getInstance():updateFlourVisible()
end)

