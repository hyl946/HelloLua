
require "zoo.panelBusLogic.FinishChildLadyBugTaskLogic"

---------------------------------------------------
-------------- LadyBugMissionManager
---------------------------------------------------

LadyBugMissionState = {

	NOT_OPENED_YET				= 1,
	WAIT_TIME_TO_OPEN			= 2,
	OPENED					= 3,	

	NOT_OPEN_BUT_FINISHED			= 4,

	FINISHED_WAIT_RECEIVE_REWARD		= 5,
	FINISHED_AND_RECEIVED_REWARD		= 6,

	NOT_FINISHED_IN_TIME_CLOSE		= 7,
	NOT_FINISHED_IN_TIME_CLOSE_FORCE = 8,
	NONE					= 9,
}

local sharedInstance = false

assert(not LadyBugMissionManager)
LadyBugMissionManager = class()

function LadyBugMissionManager:init(...)
	assert(#{...} == 0)

	------------------------
	-- Pase The Meta Config
	-- --------------------
	local ladyBugMissions = MetaManager.getInstance().ladybug_reward
	local numberOfTotalMission = #ladyBugMissions

	-- -------------------
	-- Init Mission State
	-- ----------------
	self.missionState 			= {}
	self.missionFinishedMsgSendedFlag	= {}
	self.missionToStartOrToEndTime		= {}

	-- 提前调用，初始化数据
	self:changeTaskStateWhenTimeChange()

	if self:isMissionStarted() then
		local function oneSecondCallback()
			self:changeTaskStateWhenTimeChange()
		end
		self:startOneSecondTimer(oneSecondCallback)
	end
end

function LadyBugMissionManager:tryStartMission(successCallback, failCallback)
	-- 尝试启动任务
	local topLevel = UserManager:getInstance().user:getTopLevelId()	
	if not self:isLadybugMissionEverStarted() and
		topLevel >= 3 then

		local function localSuccessCallback()

			self:changeTaskStateWhenTimeChange()
			local function oneSecondCallback()
				self:changeTaskStateWhenTimeChange()
			end
			self:startOneSecondTimer(oneSecondCallback)
			self:setupNotification()
			if successCallback then
				successCallback()
			end
		end
		local function localFailCallback()
			if failCallback then
				failCallback()
			end
		end
		self:sendStartLadyBugMissionMsg(localSuccessCallback, localFailCallback)
		return true
	else
		return false
	end
end

function LadyBugMissionManager:isLadybugMissionEverStarted(...)
	assert(#{...} == 0)

	if #self.missionState > 0 then
		return true
	end

	return false
end

function LadyBugMissionManager:getTaskTime(taskId, ...)
	assert(type(taskId) == "number")
	assert(#{...} == 0)

	local taskTime = self.missionToStartOrToEndTime[taskId]
	return taskTime
end

function LadyBugMissionManager:isMissionStarted(...)
	assert(#{...} == 0)
	if PlatformConfig:isPlayDemo() then
		return false
	end
	for k,v in ipairs(self.missionState) do
		if v == LadyBugMissionState.FINISHED_AND_RECEIVED_REWARD or
			v == LadyBugMissionState.NOT_FINISHED_IN_TIME_CLOSE or
			v == LadyBugMissionState.NOT_FINISHED_IN_TIME_CLOSE_FORCE then
			-- Do Nothing
		else
			return true
		end
	end

	return false
end

function LadyBugMissionManager:changeTaskStateWhenTimeChange(...)


	assert(#{...} == 0)

	------------------
	-- Cur Time
	-- ----------------

	local manualAdjustForDebugPurpose	= 24*60*60 *0
	local curTimeInSecond			= os.time() + manualAdjustForDebugPurpose

	if not __g_utcDiffSeconds then __g_utcDiffSeconds = 0 end
	local curServerTime = curTimeInSecond + __g_utcDiffSeconds

	-----------------
	-- LadyBugInfos
	-- ---------------

	local ladyBugInfos	= UserManager:getInstance().ladyBugInfos
	local tasks		= MetaManager.getInstance().ladybug_reward

	---- -------------------
	---- Check Mission State
	---- ----------------

	for k,info in pairs(ladyBugInfos) do

		local taskMeta = MetaManager.getInstance():ladybugReward_getLadyBugRewardMeta(info.id)
		assert(taskMeta)

		local startTimeStamp		= math.floor(info.startTime / 1000)
		local taskEndTimeStamp		= math.floor(info.endTime / 1000)
		
		if curServerTime < startTimeStamp then
			-- Not Opened Yet

			if self:checkMissionPassed(taskMeta) then
				-- Mission Passed
				self.missionState[info.id]		= LadyBugMissionState.NOT_OPEN_BUT_FINISHED
				self.missionToStartOrToEndTime[info.id]	= startTimeStamp - curServerTime
				
			else
				-- Mission Not Passed
				self.missionState[info.id] 		= LadyBugMissionState.NOT_OPENED_YET
				self.missionToStartOrToEndTime[info.id] = startTimeStamp - curServerTime
			end
		
		elseif curServerTime > taskEndTimeStamp then
			-- Mission Time Passed

			if info.canReward and info.reward == 0 then
				-- Can Reward, And Not Received
				--self.missionState[info.id] = LadyBugMissionState.FINISHED_WAIT_RECEIVE_REWARD
				self.missionState[info.id]	= LadyBugMissionState.NOT_FINISHED_IN_TIME_CLOSE

			elseif info.canReward and info.reward == 1 then
				-- Can Reward, And Received
				self.missionState[info.id] = LadyBugMissionState.FINISHED_AND_RECEIVED_REWARD

			elseif not info.canReward then
				-- Can't Reward
				self.missionState[info.id] =  LadyBugMissionState.NOT_FINISHED_IN_TIME_CLOSE
			else
				assert(false)
			end

			self.missionToStartOrToEndTime[info.id] = false
		else
			-- In Mission Time
			self.missionState[info.id] = LadyBugMissionState.OPENED

			if info.canReward and info.reward == 0 then
				-- Can Reward, And Not Received
				self.missionState[info.id] = LadyBugMissionState.FINISHED_WAIT_RECEIVE_REWARD

			elseif info.canReward and info.reward == 1 then
				-- Can Reward, And Received
				self.missionState[info.id] = LadyBugMissionState.FINISHED_AND_RECEIVED_REWARD

			elseif not info.canReward then
				-- Can't Reward

				if self:checkMissionPassed(taskMeta) then
					-- Mission Already Passed

					-- Can Reward, And Not Received
					self.missionState[info.id] = LadyBugMissionState.FINISHED_WAIT_RECEIVE_REWARD

					if not self.missionFinishedMsgSendedFlag[info.id] then
						self.missionFinishedMsgSendedFlag[info.id] = true

						local function onFinishMsgSuccess()
							--self:askHomeScenePopoutTheLadyBugPanel()
						end
						local function onFail()

							self.missionFinishedMsgSendedFlag[info.id] = false
						end
						local finishTaskLogic =  FinishChildLadyBugTaskLogic:create(info.id)
						finishTaskLogic:start(onFinishMsgSuccess, onFail)
					end
				else
					-- Mission Not Finished
					self.missionState[info.id] 			= LadyBugMissionState.OPENED
					self.missionToStartOrToEndTime[info.id]		= taskEndTimeStamp - curServerTime
				end
			else
				assert(false)
			end
		end
	end
	
	for index,v in ipairs(self.missionState) do
		-- If Current Task Is Finished
		if v == LadyBugMissionState.FINISHED_WAIT_RECEIVE_REWARD or
			v == LadyBugMissionState.FINISHED_AND_RECEIVED_REWARD then

			-- If Next Task State Is LadyBugMissionState.NOT_OPENED_YET
			-- Then Change It TO 
			local nextTaskIndex = index + 1

			if self.missionState[nextTaskIndex] and 
				self.missionState[nextTaskIndex] == LadyBugMissionState.NOT_OPENED_YET then
				self.missionState[nextTaskIndex] = LadyBugMissionState.WAIT_TIME_TO_OPEN
			end
		end
	end

	----------------------------------------
	-- Get Time To Display In Lady Bug Icon
	-- --------------------------------------

	local timeToDisplay = false

	for k,v in ipairs(self.missionState) do

		if v == LadyBugMissionState.WAIT_TIME_TO_OPEN or
			v == LadyBugMissionState.OPENED or
			v == LadyBugMissionState.NOT_OPEN_BUT_FINISHED then
			
			if not timeToDisplay then
				timeToDisplay = self.missionToStartOrToEndTime[k] 
			end

			if timeToDisplay > self.missionToStartOrToEndTime[k] then
				timeToDisplay = self.missionToStartOrToEndTime[k]
			end
		end
	end

	if timeToDisplay then
		-- Hour:Minute:Second Format
		-- Note: Convert Time Format Shoud Placed In LadyBugBtn, Not There
		hmfFormt = convertSecondToHHMMSSFormat(timeToDisplay)
		self:askHomeSceneUpdateLadyBugBtnTimeLabel(hmfFormt)
	else
		self:askHomeSceneUpdateLadyBugBtnTimeLabel("")
	end

	--------------------------------------------
	-- Get If Shoud Display Tip In Lady Bug Icon
	-- --------------------------------------
	local hasNotReceivedReward = false
	local hasNewOpenedMission = false
	for k,v in ipairs(self.missionState) do
		if v == LadyBugMissionState.FINISHED_WAIT_RECEIVE_REWARD then
			hasNotReceivedReward = true
		elseif v == LadyBugMissionState.OPENED then
			hasNewOpenedMission = true
		end
	end

	if hasNotReceivedReward then
		self:askHomeSceneToDisplayLadyBugTip(IconTipState.kReward)
	else
		if hasNewOpenedMission then 
			self:askHomeSceneToDisplayLadyBugTip(IconTipState.kNormal)
		else
			self:askHomeSceneToClearLadyBugTip()
		end
	end

	-----------------------------------------
	-- Check If Lady Bug Task Should Over
	-- ------------------------------------
	-- When All Task Is NOT_FINISHED_IN_TIME_CLOSE Or FINISHED_AND_RECEIVED_REWARD, 
	-- Then Lady BUg Task SHould Close
	
	local shouldClose = true
	for k,v in ipairs(self.missionState) do

		if v == LadyBugMissionState.NOT_FINISHED_IN_TIME_CLOSE or
			v == LadyBugMissionState.FINISHED_AND_RECEIVED_REWARD then

		else
			shouldClose = false
		end
	end

	if shouldClose then
		for k, v in ipairs(self.missionState) do
			if v == LadyBugMissionState.NOT_FINISHED_IN_TIME_CLOSE then
				self.missionState[k] = LadyBugMissionState.NOT_FINISHED_IN_TIME_CLOSE_FORCE
			end
		end
		self:askHomeSceneRemoveLadyBugButton()
		self:stopOneSecondTimer()
	end
end

-----------------------
-- One Second Timer
-- ---------------------

function LadyBugMissionManager:startOneSecondTimer(callback, ...)
	assert(type(callback) == "function")
	assert(#{...} == 0)

	self.isOneSecondTimerRunning = true
	
	local oneSecondTimer	= OneSecondTimer:create()
	self.oneSecondTimer	= oneSecondTimer
	oneSecondTimer:setOneSecondCallback(callback)
	oneSecondTimer:start()
end

function LadyBugMissionManager:stopOneSecondTimer(...)
	assert(#{...} == 0)

	if self.isOneSecondTimerRunning then
		self.isOneSecondTimerRunning = false
		self.oneSecondTimer:stop()
	end
end

function LadyBugMissionManager:getTaskState(taskId, ...)
	assert(type(taskId) == "number")
	assert(#{...} == 0)

	local state = self.missionState[taskId]
	--assert(state)
	return state
end

function LadyBugMissionManager:askHomeScenePopoutTheLadyBugPanel(...)
	assert(#{...} == 0)

	---local runningScene = Director:sharedDirector():getRunningScene()
	---if runningScene == HomeScene:sharedInstance() then
	---	HomeScene:sharedInstance():popoutLadyBugPanel()
	---end
end

function LadyBugMissionManager:askHomeSceneToDisplayLadyBugTip(tipState)
	local runningScene = Director:sharedDirector():getRunningScene()
	if runningScene == HomeScene:sharedInstance() then
		if runningScene.ladybugButton then
			runningScene.ladybugButton:updateIconTipShow(tipState)
		end
	end
end

function LadyBugMissionManager:askHomeSceneToClearLadyBugTip()
	local runningScene = Director:sharedDirector():getRunningScene()
	if runningScene == HomeScene:sharedInstance() then
		if runningScene.ladybugButton then
			runningScene.ladybugButton:stopHasNotificationAnim()
		end
	end
end

function LadyBugMissionManager:askHomeSceneUpdateLadyBugBtnTimeLabel(timeString, ...)
	assert(#{...} == 0)

	local runningScene = Director:sharedDirector():getRunningScene()
	if runningScene == HomeScene:sharedInstance() then
		HomeScene:sharedInstance():updateLadyBugBtnTimeLabel(timeString)
	end
end

function LadyBugMissionManager:askHomeSceneRemoveLadyBugButton(...)
	assert(#{...} == 0)

	local runningScene = Director:sharedDirector():getRunningScene()

	if runningScene == HomeScene:sharedInstance() then
		HomeScene:sharedInstance():removeLadyBugButton()
	end
end

function LadyBugMissionManager:checkMissionPassed(taskMeta, ...)
	assert(taskMeta)
	assert(#{...} == 0)

	-- Goal Type
	local goalType	= taskMeta.goalType[1].itemId
	local goalValue	= taskMeta.goalType[1].num

	if goalType == 1 then
		-------------------
		-- Pass Which Level
		-- -----------------
		local targetLevelScore	= UserManager.getInstance():getUserScore(goalValue)
		
		if targetLevelScore and targetLevelScore.star >= 1 or UserManager.getInstance():hasPassedByTrick(goalValue) then
			-- Passed The Level, Acomplish The Task
			return true

		else
			-- Not Acomplish
			-- Do Nothing

			return false
		end

	elseif goalType == 2 then
		--------------------------------
		-- Three Star Pass Which Level
		-- ----------------------------

		local targetLevelScore	= UserManager.getInstance():getUserScore(goalValue)

		if targetLevelScore and targetLevelScore.star >= 3 then
			-- Passed The Level , Acomplish The Task
			return true
		else
			-- Not Acomplish
			-- Do Nothing

			return false
		end

	elseif goalType == 3 then
		-----------------
		-- Get The Fruit
		-- -------------

		return false
	end
end

function LadyBugMissionManager:checkEachMission(...)
	assert(#{...} == 0)
	
	local tasks = MetaManager.getInstance().ladybug_reward

	for k,v in pairs(tasks) do

		if self:checkMissionPassed(v) then

			if self.missionState[v.id] == LadyBugMissionState.OPENED then
				-- Send Finish Child Lady Bug Task Message

				if not self.missionFinishedMsgSendedFlag[v.id] then
					self.missionFinishedMsgSendedFlag[v.id] = true

					local function onFinishMsgSuccess()
						--self:askHomeScenePopoutTheLadyBugPanel()
					end
					local finishTaskLogic =  FinishChildLadyBugTaskLogic:create(v.id)
					finishTaskLogic:start(onFinishMsgSuccess)
				end
			end
		else
			-- Do Nothing
		end
	end

	-- --------------------------
	-- Check If All Task Finished
	-- --------------------------
	local allTaskFinished = true
		
	for k,v in pairs(self.missionState) do

		if v == LadyBugMissionState.FINISHED_AND_RECEIVED_REWARD
			or v == LadyBugMissionState.NOT_FINISHED_IN_TIME_CLOSE then
			-- Do Nothing
		else
			allTaskFinished = false
		end
	end

	if allTaskFinished then
		self:stopOneSecondTimer()
	end
end

function LadyBugMissionManager:onTopLevelChange(...)
	assert(#{...} == 0)

	-- Check If New Top Level Is The Trigger Of Start Lady Bug Mission

	if UserManager:getInstance().user:getTopLevelId() == 7 then


		local function onSendStartLadyBugMissionMsg()

			self:changeTaskStateWhenTimeChange()

			local function oneSecondCallback()
				self:changeTaskStateWhenTimeChange()
			end
			self:startOneSecondTimer(oneSecondCallback)

			HomeScene:sharedInstance():startLadyBug()

			self:setupNotification()
		end

		-- Start The Lady Bug Mission
		self:sendStartLadyBugMissionMsg(onSendStartLadyBugMissionMsg)
	end
	
	self:checkEachMission()
end

function LadyBugMissionManager:sendStartLadyBugMissionMsg(successCallback, onFail, ...)
	assert(false == successCallback or type(successCallback) == "function")
	assert(#{...} == 0)

	local function onSuccess(event)
		assert(event)
		assert(event.name == Events.kComplete)

		if successCallback then
			successCallback()
		end
	end

	local function onFailed()
		if onFail then
			onFail()
		end
	end

	local http = StartLadyBugTask.new()
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFailed)
	http:load()
end

function LadyBugMissionManager:onLevelPassedCallback(passedLevel, ...)
	assert(type(passedLevel) == "number")
	assert(#{...} == 0)
	
	self:checkEachMission()
end

function LadyBugMissionManager:printLadyBugMissionState(state)

	if state == LadyBugMissionState.NOT_OPENED_YET then
		if _G.isLocalDevelopMode then printx(0, "LadyBugMissionState.NOT_OPENED_YET") end

	elseif state == LadyBugMissionState.WAIT_TIME_TO_OPEN then
		if _G.isLocalDevelopMode then printx(0, "LadyBugMissionState.WAIT_TIME_TO_OPEN") end

	elseif state == LadyBugMissionState.OPENED then
		if _G.isLocalDevelopMode then printx(0, "LadyBugMissionState.OPENED") end

	elseif state == LadyBugMissionState.FINISHED_WAIT_RECEIVE_REWARD then
		if _G.isLocalDevelopMode then printx(0, "LadyBugMissionState.FINISHED_WAIT_RECEIVE_REWARD") end

	elseif state == LadyBugMissionState.FINISHED_AND_RECEIVED_REWARD then
		if _G.isLocalDevelopMode then printx(0, "LadyBugMissionState.FINISHED_AND_RECEIVED_REWARD") end

	elseif state == LadyBugMissionState.NOT_FINISHED_IN_TIME_CLOSE then
		if _G.isLocalDevelopMode then printx(0, "LadyBugMissionState.NOT_FINISHED_IN_TIME_CLOSE") end

	elseif state == LadyBugMissionState.NOT_FINISHED_IN_TIME_CLOSE_FORCE then
		if _G.isLocalDevelopMode then printx(0, "LadyBugMissionState.NOT_FINISHED_IN_TIME_CLOSE_FORCE") end

	else
		if _G.isLocalDevelopMode then printx(0, "state: " .. state) end
		assert(false)
	end
end

function LadyBugMissionManager:sharedInstance(...)
	assert(#{...} == 0)

	if not sharedInstance then

		sharedInstance = LadyBugMissionManager.new()
		sharedInstance:init()
	end

	return sharedInstance
end

function LadyBugMissionManager:setupNotification()
	local ladyBugInfos = UserManager:getInstance().ladyBugInfos
	local startRefTime = ladyBugInfos[1].endTime - 43200000
	LocalNotificationManager:getInstance():setLadyBugMissionNotification(startRefTime, table.size(ladyBugInfos))
end

function LadyBugMissionManager:cancelNotificationToday(taskId)
	local ladyBugInfos = UserManager:getInstance().ladyBugInfos
	for k, v in pairs(ladyBugInfos) do
		if v.id == taskId then
			if 0 == v.endTime % 100000 then
				LocalNotificationManager:getInstance():cancelLadyBugMissionNotificationToday()
			end
			break
		end
	end
end

function LadyBugMissionManager:setMissionRewardCallback(callback)
	self.missionRewardCallback = callback
end

function LadyBugMissionManager:activateMissionRewardCallback(taskId)
	if taskId == 1 then
		local ladyBugInfos = UserManager:getInstance().ladyBugInfos
		for k, v in pairs(ladyBugInfos) do
			if v.id == taskId then
				if 0 == v.endTime % 100000 then
					if self.missionRewardCallback then self.missionRewardCallback() end
					break
				end
			end
		end
	end
end