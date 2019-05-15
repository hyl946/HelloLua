-- Copyright C2009-2015 www.happyelements.com, all rights reserved.
-- Create Date:	2015年10月26日 10:27:57
-- Author:	xiaoguang.nan
-- Email:	xiaoguang.nan@happyelements.com
---------------------------------------------------
--[[
					MissionLogic

	
	MissionLogic为任务系统业务层的入口类。

	
	任务系统分为三层：
		视图层 - 位于zoo.mission.panels包下，纯视图逻辑，包括UI和动画，
				 入口类为【MissionPanelLogic】
		业务层 - 位于zoo.mission.missionCreator包下，负责封装后端接口，维护本地持久化数据，并根据后端配置执行创建任务的逻辑，
				 入口类为【MissionLogic】
		框架层 - 位于zoo.mission.commonMissionFrame包下，负责将一个业务层的“任务”解析为一组通用的“条件”队列，
				 并在恰当的游戏操作后检测该“条件”的进度是否变更，是否达成。
				 框架层只负责检测任务的进度变更和状态变更（未完成-->已完成）
				 入口类为【MissionManager】

		Wiki地址：http://wiki.happyelements.net/pages/viewpage.action?pageId=20262811

]]
---------------------------------------------------

require "zoo.mission.missionCreator.MissionCreator"
require "zoo.mission.commonMissionFrame.managers.MissionManager"
require "zoo.mission.commonMissionFrame.data.MissionData"
require "zoo.mission.CMF_DataConverter"
require "zoo.mission.panels.MissionPanelLogic"
require "zoo.util.DcUtil"

MissionState = {
	kWaitForRefresh = 0,
	kStart = 1,
	kInProgress = 2,
	kFinished = 3,
	kRewarded = 4,
}

MissionLogicEvents = {
	kMissionStart = "MissionLogicEvents.kMissionStart", --视图需要刷新任务（每日在空槽创建新任务）
	kMissionProgress = "MissionLogicEvents.kMissionProgress", -- 视图刷新进度
	kMissionState = "MissionLogicEvents.kMissionState", --视图状态变更
	--kMissionEnd = "MissionLogicEvents.kMissionEnd",
	kMissionExpired = "MissionLogicEvents.kMissionExpired",--限时任务过期
	kMissionExtraReward = "MissionLogicEvents.kMissionExtraReward", --获取到任务的额外奖励
	kMissionReward = "MissionLogicEvents.kMissionReward",--领奖成功
	kMissionRefresh = "MissionLogicEvents.kMissionRefresh",
	kTankStart = "MissionLogicEvents.kTankStart",
	kTankProgress = "MissionLogicEvents.kTankProgress",
	kTankReward = "MissionLogicEvents.kTankReward",
	kMssionCreateFail = "MissionLogicEvents.kMssionCreateFail",
	kMssionRewardFail = "MissionLogicEvents.kMssionRewardFail"
}

local specialMissionDuration = 36000000
local updateDataInterval = 180000

MissionLogic = class(EventDispatcher)

local instance = nil
function MissionLogic:getInstance()
	if not instance then
		instance = MissionLogic.new()
		MissionPanelLogic:init(instance)
		instance:init()
	end
	return instance
end

function MissionLogic:getSpecialMissionDuration()
	return specialMissionDuration
end

function MissionLogic:getMissionUserNeedLevel()
	return 62
end

function MissionLogic:ctor()
	self.missionList = {}
	self.missionCreateTimes = {}
	self.specialReward = {}
	self.countCurrent = 3 -- 逆向计数
	self.countTotal = 3
	self.loginList = {}
	self.lastReturn = 0
	self.lastUpdateTime = 0
	self.newExtraRewards = {}
end

function MissionLogic:init()
	
	self:readFromLocalData()
	local config = {}
	local now = Localhost:time()
	local leaveTime = RecallManager:getInstance():getLastLeaveTime()
	if leaveTime then
		leaveTime = leaveTime * 1000
	else
		leaveTime = now
	end
	local dayTime = 86400000
	local create = UserManager:getInstance().mark.createTime
	local loginDay = math.floor((now - create) / dayTime) * dayTime + create
	local loginDayNum = math.ceil((now - create) / dayTime)
	local sevenDaysBefore = loginDayNum - 7
	if not table.indexOf(self.loginList, loginDayNum) then
		table.insert(self.loginList, loginDayNum)
	end
	self.loginList = table.filter(self.loginList, function(v) return v >= sevenDaysBefore end)
	config.loginCountInPassedSevenDays = #self.loginList - 1

	if self.lastReturn ~= 0 and loginDay - leaveTime < dayTime then
		config.lastReturnTime = self.lastReturn
	else
		if loginDay - leaveTime > dayTime * 7 then
			self.lastReturn = now
			config.lastReturnTime = now
		else
			self.lastReturn = 0
			config.lastReturnTime = 0
		end
	end
	MissionCreator:getInstance():setCreateInfo(config)
	self:writeToLocalData()

	local function onProgress(evt)
		self:onMissionProgressChange(evt.data)
	end
	MissionManager:getInstance():addEventListener(MissionFrameEvent.kProgressChanged, onProgress)
	local function onState(evt)
		self:onMissionStateChange(evt.data)
	end
	MissionManager:getInstance():addEventListener(MissionFrameEvent.kStateChanged, onState)
	
	MissionManager:getInstance():checkAll()
	
	self:refreshData(false)
	--HomeScene:sharedInstance():createMissionButton()
	local function onTryCreateMission()
		MissionPanelLogic:tryToUpdateMissionButton()
	end

	MissionPanelLogic:tryCreateMission( onTryCreateMission , onTryCreateMission , false )
	--MissionPanelLogic:tryToUpdateMissionButton()
end

function MissionLogic:iconTapped(successCallback, failCallback , needLoadingLock)
	if needLoadingLock ~= false then needLoadingLock = true end
	if Localhost:time() - self.lastUpdateTime > updateDataInterval then -- 3 minutes
		local function onSuccess()
			if successCallback then successCallback() end
			self:checkCreateMission()
		end
		local function onFail(err)
			if err < 0 then
				if #self.missionList >= 4 then
					if successCallback then successCallback() end
				else
					if failCallback then failCallback() end
				end
			else
				if failCallback then failCallback(err) end
			end
		end
		local function onCancel()
			if #self.missionList >= 4 then
				if successCallback then successCallback() end
			else
				if failCallback then failCallback() end
			end
		end
		self:refreshData(needLoadingLock, onSuccess, onFail, onCancel)
	else
		self:checkCreateMission()
		if successCallback then successCallback() end
	end
end

function MissionLogic:getReward(indices, successCallback, failCallback, cancelCallback)
	local function onSuccess(evt)
		local function addRewards(rewards)
			if rewards then
				-- 注释掉因为暂时不用了 再启用请加打点
				assert(false, "look at here!")
				-- UserManager:getInstance():addRewards(rewards)
	    		-- UserService:getInstance():addRewards(rewards)
	    	end
		end
		if type(evt.data.rewards) == "table" then
			addRewards(evt.data.rewards)
		end
		if type(evt.data.extraRewards) == "table" then
			addRewards(evt.data.extraRewards)
		end
		if type(evt.data.tankRewards) == "table" then
			addRewards(evt.data.tankRewards)
		end
		if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
		else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

		if not evt.data.positions then evt.data.positions = {} end
		local evtData = table.filter(indices, function(v) return not table.indexOf(evt.data.positions,v) end)
		self:dispatchEvent(Event.new(MissionLogicEvents.kMssionRewardFail, { missionPositions = evtData } , self))

		-- 更新任务数据
		for i, v in ipairs(evt.data.positions or {}) do
			self.missionList[v].state = MissionState.kRewarded
			self.missionList[v].lastUpdateTime = Localhost:time()
			MissionManager:getInstance():removeMission(self.missionList[v].id + v * 100000)
			MissionCreator:getInstance():addAppearMission(self.missionList[v].id)
		end
		self.specialReward = evt.data.nextTankRewards or {}
		self.countCurrent = evt.data.remainTankLevel or 0
		self.countTotal = evt.data.maxTankLevel or 3
		self:writeToLocalData()

		-- 反向插入事件
		local eventList = {}
		local indexList = evt.data.positions or {}
		local count = #indexList
		for i = 1, math.min(count, self.countTotal - self.countCurrent) do
			table.insert(eventList, Event.new(MissionLogicEvents.kTankProgress,
				{current = self.countCurrent + i - 1, total = self.countTotal}, self))
			table.insert(eventList, Event.new(MissionLogicEvents.kMissionReward, {
					index = indexList[count - i + 1] , 
					tankNextTankRewards = self.specialReward ,
					tankCurrent = self.countCurrent , 
					tankTotal = self.countTotal ,
				}, self))
			table.remove(indexList)
		end
		if type(evt.data.tankRewards) == "table" and #evt.data.tankRewards > 0 and
			type(evt.data.extraTankRewards) == "table" and #evt.data.extraTankRewards > 0 then
			self.specialReward = evt.data.nextTankRewards or {}
			table.insert(eventList, Event.new(MissionLogicEvents.kTankStart,
				{rewards = evt.data.nextTankRewards or {}}, self))
			self:dispatchEvent(Event.new(MissionLogicEvents.kTankReward, nil, self))
			for i = 1, math.min(#indexList, self.countTotal) do
				table.insert(eventList, Event.new(MissionLogicEvents.kTankProgress,
					{current = i - 1, total = self.countTotal}, self))
				table.insert(eventList, Event.new(MissionLogicEvents.kMissionReward, {
						index = indexList[count - i + 1] , 
					tankNextTankRewards = self.specialReward ,
					tankCurrent = self.countCurrent , 
					tankTotal = self.countTotal ,
					}, self))
				table.remove(indexList)
			end
			table.insert(eventList, Event.new(MissionLogicEvents.kTankStart,
				{rewards = evt.data.extraTankRewards or {}}, self))
			self:dispatchEvent(Event.new(MissionLogicEvents.kTankReward, nil, self))
		elseif type(evt.data.tankRewards) == "table" and #evt.data.tankRewards > 0 then
			self.specialReward = evt.data.nextTankRewards or {}
			table.insert(eventList, Event.new(MissionLogicEvents.kTankStart,
				{rewards = evt.data.nextTankRewards or {}}, self))
			self:dispatchEvent(Event.new(MissionLogicEvents.kTankReward, nil, self))
		end
		count = #indexList
		if count > 0 then
			for i = 1, math.min(count, self.countTotal) do
				table.insert(eventList, Event.new(MissionLogicEvents.kTankProgress,
					{current = i - 1, total = self.countTotal}, self))
				table.insert(eventList, Event.new(MissionLogicEvents.kMissionReward, {
						index = indexList[count - i + 1] , 
					tankNextTankRewards = self.specialReward ,
					tankCurrent = self.countCurrent , 
					tankTotal = self.countTotal ,
					}, self))
				table.remove(indexList)
			end
		end

		-- 释放事件
		for i = #eventList, 1, -1 do
			self:dispatchEvent(eventList[i])
		end

		self:checkCreateMission()	-- 创建新任务
		if successCallback then successCallback() end	-- 成功回调
	end
	local function onFail(evt)
		if failCallback then failCallback(evt.data) end
	end
	local function onCancel()
		if cancelCallback then cancelCallback() end
	end

	for i,v in ipairs(indices) do
		if not self.missionList[v] or self.missionList[v].state ~= MissionState.kFinished then
			return false
		end
	end

	local http = GetMissionRewardHttp.new(true)
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFail)
	http:addEventListener(Events.kCancel, onCancel)
	http:syncLoad(indices)

	return true
end

function MissionLogic:terminateMission(index, successCallback, failCallback, cancelCallback)
	local now = Localhost:time()
	local create = UserManager:getInstance().mark.createTime
	local todayStart = math.floor((now - create) / 86400000) * 86400000 + create

	local mission = self.missionList[index]
	if not mission then return false end
	if mission.state == MissionState.kFinished then -- 已完成未领奖时不能放弃
		return false
	end
	if (mission.state ~= MissionState.kStart and mission.state ~= MissionState.kInProgress) or
		now - mission.createTime < 864000000 then -- 十天未完成才可以放弃
		return false
	end

	self:doCreateMission({index}, successCallback, failCallback, cancelCallback)
	return true
end

function MissionLogic:readFromLocalData()
	local data = Localhost:readFromStorage("userMission.ds")
	if not data then return end
	self.missionList = data.missionList or {}
	self.specialReward = data.specialReward or {}
	self.countTotal = data.countTotal or 3
	self.countCurrent = data.countCurrent or 3
	self.loginList = table.clone(data.loginList or {})
	self.lastReturn = data.lastReturn or 0
	for i,v in ipairs(self.missionList) do
		local data = MissionCreator:getInstance():createMissionByConfig(v)
		self.missionList[i] = data
		local insertData = CMF_DataConverter:getCMFSourceData(data)
		if insertData and (data.state == MissionState.kStart or data.state == MissionState.kInProgress or
			data.state == MissionState.kFinished) then
			insertData.id = insertData.id + i * 100000
			if i == 4 then
				if data.createTime + specialMissionDuration - Localhost:time() > 0 then
					MissionManager:getInstance():addMission(insertData)
				end
				self:refreshExpireTimer()
			else
				MissionManager:getInstance():addMission(insertData)
			end
		end
	end
end

function MissionLogic:writeToLocalData()
	local data = {
		missionList = table.clone(self.missionList),
		specialReward = self.specialReward,
		countCurrent = self.countCurrent,
		countTotal = self.countTotal,
		loginList = table.clone(self.loginList),
		lastReturn = self.lastReturn
	}

	-- 将任务进度转换成字符串表示
	for i,v in ipairs(data.missionList) do
		v.taskId = v.id
		v.id = nil
		v.condition = nil
		if v.state == MissionState.kStart or v.state == MissionState.kInProgress then
			v.progress = self:getProgressStrFromMissionManager(i * 100000 + v.taskId)
		else
			v.progress = self:getProgressStrFromMissionList(v.taskId)
		end
	end
	Localhost:writeToStorage(data, "userMission.ds")
end

function MissionLogic:getMissionData(position)
	local missionList = MissionLogic:getInstance().missionList
	local mission = self.missionList[position]
	local data = {}
	if mission then
		for k,v in pairs(mission) do
			data[k] = v
		end

		data.condition = nil
		data.progress = nil

		local CMFData = MissionManager:getInstance():getMission(position * 100000 + data.id)

		if CMFData then
			data.progressInfo = CMFData:getCompleteConditionValueData()
			data.doActions = CMFData:getDoActions()
		else
			--printx( 1 , "   WWWWWWWWWWWWWWWWWWW  getMissionData by CMFData " , table.tostring(data) )
		end
	end

	return data
end

function MissionLogic:refreshData(showLoadAnim, successCallback, failCallback, cancelCallback)
	local function onSuccess(evt)
		if type(evt) == "table" and type(evt.data) == "table" then
			local config = {
				weeklyAppear = evt.data.weeklyTaskTypeCount,
				dailyAppear = evt.data.dailyTaskTypeCount,
				appeardMission = evt.data.createdTaskIds,
			}
			MissionCreator:getInstance():setCreateInfo(config)

			self.countTotal = evt.data.maxTankLevel
			self.countCurrent = evt.data.remainTankLevel
			self.specialReward = evt.data.tankRewards
			for i,v in ipairs(self.missionList) do
				MissionManager:getInstance():removeMission(i * 100000 + v.id)
			end

			local originMissionList = self.missionList
			self.missionList = {}
			for i,v in ipairs(evt.data.tasks) do
				local data = MissionCreator:getInstance():createMissionByConfig(v)
				local insertData = CMF_DataConverter:getCMFSourceData(data , i == 4)
				table.insert(self.missionList, data)
				if insertData and (data.state == MissionState.kStart or
					data.state == MissionState.kInProgress or data.state == MissionState.kFinished) then
					if data.id == 4 then
						if data.createTime + specialMissionDuration - Localhost:time() > 0 then
							insertData.id = insertData.id + i * 100000
							MissionManager:getInstance():addMission(insertData)
						end
						self:refreshExpireTimer()
					else
						insertData.id = insertData.id + i * 100000
						MissionManager:getInstance():addMission(insertData)
					end
				end
				local dData = originMissionList[i]
				if type(dData) == "table" and dData.id == data.id then
					if #dData.extraRewards ~= #data.extraRewards then
						self.newExtraRewards[i] = true
						self:dispatchEvent(Event.new(MissionLogicEvents.kMissionExtraReward, {index = i}, self))
					end
				else
					self.newExtraRewards[i] = nil
				end
			end

			self.lastUpdateTime = Localhost:time()
			self:writeToLocalData()
			self:dispatchEvent(Event.new(MissionLogicEvents.kMissionRefresh, nil , self))
		end
		if successCallback then successCallback() end
		MissionManager:getInstance():checkAll()
	end
	local function onFail(evt)
		if failCallback then failCallback(evt.data) end
	end
	local function onCancel()
		if cancelCallback then cancelCallback() end
	end
	local http = GetMissionInfoHttp.new(showLoadAnim)
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFail)
	http:addEventListener(Events.kCancel, onCancel)
	http:syncLoad()
end

function MissionLogic:checkCreateMission()
	local refreshIndices = {}
	local now = Localhost:time()
	local create = UserManager:getInstance().mark.createTime
	local dayTime = 86400000
	local todayStart = math.floor((now - create) / dayTime) * dayTime + create

	for i,v in ipairs(self.missionList) do
		local missionStart = math.floor((v.createTime - create) / dayTime) * dayTime + create
		local missionFinish = math.floor((v.finishTime - create) / dayTime) * dayTime + create
		if i == 4 then -- 限时任务特殊处理
			if (v.state == MissionState.kWaitForRefresh or -- 待刷新
				v.state == MissionState.kRewarded and todayStart > v.createTime or -- 今天以前生成且现在已完成
				(v.state == MissionState.kStart or v.state == MissionState.kInProgress) and now > v.createTime + specialMissionDuration and todayStart > v.createTime) and -- 过期未完成且今天以前生成
				self.missionList[1].state == MissionState.kRewarded and self.missionList[1].lastUpdateTime > todayStart then -- 主线任务今天完成且已领奖
				table.insert(refreshIndices, i)
			end
		else
			if (v.state == MissionState.kWaitForRefresh) or -- 待刷新
				(v.state == MissionState.kRewarded and todayStart > v.createTime and todayStart > v.finishTime) or -- 今天以前创建、完成且已领奖
				(v.type ~= MissionTypes.kTopLevel and v.state == MissionState.kStart and todayStart - dayTime * 2 > v.createTime) then -- 无进度且过了4天
				table.insert(refreshIndices, i)
			end
		end
	end

	local dcList = {}
	for i,v in ipairs(refreshIndices) do
		if v ~= 4 then dcList[v] = self.missionList[v].id end
	end

	local function successCallback(positions)
		for i,v in ipairs(positions) do
			if dcList[v] then
				DcUtil:missionLogicRefreshMission(MissionCreator:getInstance():getMissionSubType(dcList[v]))
			end
		end
	end
	if #refreshIndices > 0 then
		self:doCreateMission(refreshIndices, successCallback)
	end
end

function MissionLogic:doCreateMission(indices, successCallback, failCallback, cancelCallback)
	local resIndices = {}
	local function onCreateSuccess(evt)
		
		for i,v in ipairs(evt.data.positions or {}) do
			MissionManager:getInstance():removeMission(self.missionList[v].id + v * 100000)
			local mission = MissionCreator:getInstance():createMissionByConfig(evt.data.tasks[i])
			local data = CMF_DataConverter:getCMFSourceData(mission)
			local oldState = self.missionList[v].state
			MissionCreator:getInstance():addAppearType(mission.type)
			self.missionList[v] = mission
			self.newExtraRewards[v] = nil
			if data then
				data.id = data.id + v * 100000
				MissionManager:getInstance():addMission(data)
				if v == 4 then
					self:refreshExpireTimer()
				end
				self:dispatchEvent(Event.new(MissionLogicEvents.kMissionStart,
					{index = v, data = mission, oldMissionState = oldState}, self))
			end
			
			DcUtil:missionLogicCreateMission(MissionCreator:getInstance():getMissionSubType(mission.id))
		end
		local resultList = evt.data.positions or {}
		local faliedMissions = table.filter(resIndices, function(j) return  not table.indexOf(resultList,j)   end)
		for i,v in ipairs(faliedMissions) do
			self:dispatchEvent(Event.new(MissionLogicEvents.kMssionCreateFail, { errorId = 2 , missionPositions = {[1] = v} } , self))
		end
		self:writeToLocalData()
		if #faliedMissions > 0 then
			DcUtil:missionCreateFail(3)
		end
		MissionManager:getInstance():checkAll()
		if successCallback then successCallback(evt.data.positions or {}) end
	end
	local function onCreateFail(evt)
		self:dispatchEvent(Event.new(MissionLogicEvents.kMssionCreateFail, { errorId = 1 , missionPositions = resIndices }, self))
		DcUtil:missionCreateFail(2)
		if failCallback then failCallback(evt.data) end
	end
	local function onCreateCancel()
		if cancelCallback then cancelCallback() end
	end
	local function onUpdateSuccess(evt)
		if evt and evt.data then
			local config = {
				weeklyAppear = evt.data.weeklyTaskTypeCount,
				dailyAppear = evt.data.dailyTaskTypeCount,
				appeardMission = evt.data.createdTaskIds,
			}
			for i,v in ipairs(evt.data.loginInfo or {}) do
				if not table.indexOf(self.loginList, v) then
					table.insert(self.loginList, v)
				end
			end
			local now = Localhost:time()
			local dayTime = 86400000
			local create = UserManager:getInstance().mark.createTime
			local loginDay = math.ceil((now - create) / dayTime)
			local sevenDaysBefore = loginDay - 7
			self.loginList = table.filter(self.loginList, function(v) return v >= sevenDaysBefore end)
			while #self.loginList > 8 do
				table.remove(self.loginList, 1)
			end
			config.loginCountInPassedSevenDays = #self.loginList - 1
			MissionCreator:getInstance():setCreateInfo(config)
		end
		local missions = {}
		local tasks = {}
		for i,v in ipairs(self.missionList) do
			table.insert(tasks, v.id)
		end
		
		MissionCreator:getInstance():clearCreation()
		for i, v in ipairs(indices) do
			MissionCreator:getInstance():setRunningMissions(tasks)
			local mission = MissionCreator:getInstance():createMission(v, v == 4)
			if not mission then
				MissionCreator:getInstance():clearRunningMissions()
				local evtData = table.filter(indices, function(j) return not table.indexOf(resIndices,j) end)
				self:dispatchEvent(Event.new(MissionLogicEvents.kMssionCreateFail, { errorId = 3 , missionPositions = evtData } , self))
				DcUtil:missionCreateFail(1)
				break
			end
			mission.taskId = mission.id
			mission.id = nil
			mission.condition = nil
			if mission then
				table.insert(resIndices, v)
				table.insert(missions, mission)
				tasks[v] = mission.taskId
			end
			MissionCreator:getInstance():clearRunningMissions()
			MissionCreator:getInstance():addCreateAppearType(mission.type)
		end
		if #resIndices > 0 then
			local http = CreateMissionHttp.new()
			http:addEventListener(Events.kComplete, onCreateSuccess)
			http:addEventListener(Events.kError, onCreateFail)
			http:addEventListener(Events.kCancel, onCreateCancel)
			http:syncLoad(MissionCreator:getInstance():getLoginAfterLose(), resIndices, missions, self.loginList)
		else
			if successCallback then successCallback({data = {positions = {}}}) end
		end
	end
	local function onUpdateFail(evt)
		DcUtil:missionCreateFail(2)
		if failCallback then failCallback(evt.data) end
	end
	local function onUpdateCancel(evt)
		if cancelCallback then cancelCallback() end
	end
	if Localhost:time() - self.lastUpdateTime > updateDataInterval then -- 3 minutes
		local http = GetMissionInfoHttp.new()
		http:addEventListener(Events.kComplete, onUpdateSuccess)
		http:addEventListener(Events.kError, onUpdateFail)
		http:addEventListener(Events.kCancel, onUpdateCancel)
		http:syncLoad()
	else
		onUpdateSuccess()
	end
end

function MissionLogic:onMissionProgressChange(data)
	local mission = self.missionList[math.floor(data.missionId / 100000)]
	if not mission then return end
	if mission.state ~= MissionState.kStart and mission.state ~= MissionState.kInProgress then
		return
	end
	mission.state = MissionState.kInProgress
	self:writeToLocalData()
	self:dispatchEvent(Event.new(MissionLogicEvents.kMissionProgress, {position = math.floor(data.missionId / 100000),
		id = mission.id, index = data.extendInfo, current = data.newValue, total = data.targetValue}, self))
	local progress = self:getProgressStrFromMissionManager(data.missionId)
	local http = UpdateMissionHttp.new()
	http:load(math.floor(data.missionId / 100000), mission.id, mission.state, progress)
end

local missionStateTrans = {
	[MissionDataState.STARTED] = MissionState.kStart,
	[MissionDataState.IN_PROGRESS] = MissionState.kInProgress,
	[MissionDataState.COMPLETED] = MissionState.kFinished,
}
function MissionLogic:onMissionStateChange(data)
	local mission = self.missionList[math.floor(data.missionId / 100000)]
	if not mission then return end
	local state = missionStateTrans[data.newState]
	if mission.state ~= MissionState.kStart and mission.state ~= MissionState.kInProgress then
		return
	end
	mission.state = missionStateTrans[data.newState]
	self:writeToLocalData()
	self:dispatchEvent(Event.new(MissionLogicEvents.kMissionState, {position = math.floor(data.missionId / 100000),
		id = mission.id, state = mission.state}, self))
	if mission.state == MissionState.kFinished then
		mission.finishTime = Localhost:time()
		DcUtil:missionLogicFinishMission(MissionCreator:getInstance():getMissionSubType(mission.id))
	end
	local http = UpdateMissionHttp.new()
	http:load(math.floor(data.missionId / 100000), mission.id, mission.state)
end

function MissionLogic:getProgressStrFromMissionManager(missionId)
	if MissionManager:getInstance():getMission(missionId) ~= nil then
		local values = MissionManager:getInstance():getMissionCompleteConditionValueData(missionId)
		local res = {}
		
		for i,v in ipairs(values) do
			if type(v.extendInfo) == "number" and v.extendInfo > 0 then
				table.insert(res, {extendInfo = v.extendInfo, current = v.current, total = v.total})
			end
		end
		table.sort(res, function(a, b) return a.extendInfo < b.extendInfo end)

		local progress = ""
		for i,v in ipairs(res) do
			progress = progress..tostring(v.current)..'/'..tostring(v.total)..','
		end

		if string.sub(progress, -1) == "," then
			progress = string.sub(progress, 1, -2)
		end

		return progress
	else
		return ""
	end
end

function MissionLogic:getProgressStrFromMissionList(missionId)
	local progress = ""

	for i,v in ipairs(self.missionList) do
		for j,w in ipairs(v.progress or {}) do
			progress = progress..tostring(w.current)..'/'..tostring(w.total)..','
		end
	end

	if string.sub(progress, -1) == "," then
		progress = string.sub(progress, 1, -2)
	end

	return progress
end

function MissionLogic:getAppearingTypes()
	local ret = {}
	for i,v in ipairs(self.missionList) do
		if v.type ~= 0 and not table.indexOf(ret, v.type) then
			table.insert(ret, v.type)
		end
	end
	return ret
end

function MissionLogic:getRunningTypes()
	local ret = {}
	for i,v in ipairs(self.missionList) do
		if not table.indexOf(ret, v.type) and
			v.state ~= MissionState.kStart and v.state ~= MissionState.kInProgress then
			table.insert(ret, v.type)
		end
	end
	return ret
end

function MissionLogic:getRunningIds()
	local ret = {}
	for i,v in ipairs(self.missionList) do
		table.insert(ret, v.id)
	end
	return ret
end

function MissionLogic:getExpireTime(index)
	if index == 4 and type(self.missionList[4]) == "table" and self.missionList[4].createTime ~= 0 and 
		(self.missionList[4].state == MissionState.kStart or self.missionList[4].state == MissionState.kInProgress) then
		return self.missionList[4].createTime + specialMissionDuration
	end
	return 0
end

function MissionLogic:refreshExpireTimer()
	if self.scheduler then
		Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
		self.scheduler = nil
	end
	local mission = self.missionList[4]
	if mission and (mission.state == MissionState.kStart or mission.state == MissionState.kInProgress) then
		local function onTimeout()
			if self.scheduler then
				Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
				self.scheduler = nil
			end
			MissionManager:getInstance():removeMission(400000 + mission.id)
			self:dispatchEvent(Event.new(MissionLogicEvents.kMissionExpired, {index = 4}, self))
		end

		local delta = mission.createTime + specialMissionDuration - Localhost:time()
		if delta > 0 then
			self.scheduler = Director:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, math.floor(delta / 1000) , false)
		end
	end
end

function MissionLogic:getExtraRewardFlag(index)
	return self.newExtraRewards[index] == true
end

function MissionLogic:setExtraRewardFlag(index, value)
	self.newExtraRewards[index] = value == true
end