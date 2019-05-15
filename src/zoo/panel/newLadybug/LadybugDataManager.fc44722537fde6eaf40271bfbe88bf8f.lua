--2017-05-08 19:49:00
--在功能开发完毕的当晚，宏超先生对功能提出若干较大修改，令人防不胜防。对宏超仇恨值 +1

--宏超累计获得的仇恨值: 1

local ONE_DAY_MS = 24*3600*1000

local LadybugHttp = require 'zoo.panel.newLadybug.LadybugHttp'
local LadybugNoticeButton = require 'zoo.panel.newLadybug.LadybugNoticeButton'
local LadybugAnimation = require 'zoo.panel.newLadybug.LadybugAnimation'
local LadybugGuidePanel = require 'zoo.panel.newLadybug.LadybugGuidePanel'


local DefaultRewardConfig = {
	[1] = {
		{itemId = 10052, num = 1},
		{itemId = 2, num = 3000},
	},
	[2] = {
		{itemId = 10052, num = 2},
		{itemId = 2, num = 3000},
	},
	[3] = {
		{itemId = 10052, num = 3},
		{itemId = 2, num = 3000},
	},
	[4] = {
		{itemId = 10052, num = 4},
		{itemId = 2, num = 3000},
	},
	[5] = {
		{itemId = 10052, num = 5},
		{itemId = 2, num = 3000},
	},
	[6] = {
		{itemId = 10052, num = 6},
		{itemId = 2, num = 3000},
	},
	[7] = {
		{itemId = 10052, num = 7},
		{itemId = 2, num = 3000},
	},
	[8] = {
		{itemId = 10052, num = 8},
		{itemId = 2, num = 3000},
	}
}

local DefaultExtraReward = {{
	itemId = 2,
	num = 10
}}

local TaskTargetType = {
	kMainLevel = 1,
	kSeasonWeekly = 2
}

local DefaultTaskTarget = {
	[1] = {
		taskType = TaskTargetType.kMainLevel,
		level = 12,
		star = 0,
	},
	[2] = {
		taskType = TaskTargetType.kMainLevel,
		level = 21,
		star = 0,
	},
	[3] = {
		taskType = TaskTargetType.kMainLevel,
		level = 31,
		star = 0,
	},
	[4] = {
		taskType = TaskTargetType.kMainLevel,
		level = 40,
		star = 0,
	},
	[5] = {
		taskType = TaskTargetType.kMainLevel,
		level = 47,
		star = 0,
	},
	[6] = {
		taskType = TaskTargetType.kMainLevel,
		level = 54,
		star = 0,
	},
	[7] = {
		taskType = TaskTargetType.kMainLevel,
		level = 62,
		star = 3,
	},
	[8] = {
		taskType = TaskTargetType.kSeasonWeekly,
		num = 3,
	},
}

local MinLevel = 7

local function getDayStartTimeByTS(ts)
	ts = math.floor(ts / 1000)
	if ts ~= nil then
		local utc8TimeOffset = 57600
		local dayInSec = 86400
		ts = ts - ((ts - utc8TimeOffset) % dayInSec)
		ts = ts * 1000
		return ts
	end

	return 0
end

local LadybugDataManager = class()

function LadybugDataManager:ctor( ... )
	self:init()
end

local instance 

function LadybugDataManager:getInstance( ... )
	if not instance then
		instance = LadybugDataManager.new()
	end
	return instance
end

function LadybugDataManager:onTaskFinish( id )
	
end

function LadybugDataManager:onTaskStart( id )

end

function LadybugDataManager:init( ... )
	self:initRewardConfig()
	self:initExtraReward()
	self:initTaskTarget()
end


function LadybugDataManager:getMetaConfig( ... )
	local meta = {}

	local fake_activity_id = 139
	local config = MetaManager:getInstance().activity_rewards
	for _, item in pairs(config) do
		if tonumber(item.activityId) == fake_activity_id then
			table.insert(meta, item)
		end
	end
	return meta
end

function LadybugDataManager:initRewardConfig( ... )
	-- body
	self.rewardConfig = DefaultRewardConfig

	local metaRewardConfig = self:getMetaConfig()
	if metaRewardConfig then
		for index, item in ipairs(metaRewardConfig) do
			local rewardId = tonumber(item.rewardId) + 1
			self.rewardConfig[rewardId] = item.rewards
		end
	end

	
end

function LadybugDataManager:initExtraReward( ... )
	-- body
	self.extraConfig = DefaultExtraReward

	local metaRewardConfig = self:getMetaConfig()
	if metaRewardConfig then
		for index, item in ipairs(metaRewardConfig) do
			local rewardId = tonumber(item.rewardId) + 1
			if rewardId == 0 then
				self.extraConfig = item.rewards
				break
			end
		end
	end

end

function LadybugDataManager:initTaskTarget( ... )
	-- body
	self.taskTarget = DefaultTaskTarget
end

function LadybugDataManager:shouldTriggerTask( ... )
	local topLevel = UserManager.getInstance():getUserRef():getTopLevelId()
	return topLevel >= MinLevel and topLevel <= self:getMaxTaskLevel()
end

function LadybugDataManager:calcProperTask( ... )


	if self:hadTrigger() then
		if self:hadAllFinish() then
			return nil
		end
	end


	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	local passed = UserManager.getInstance():hasPassedLevelEx(topLevelId)
	if (not passed) and topLevelId > 1 then
		topLevelId = topLevelId - 1
	end

	--以下代码和 任务类型极度相关，如果更改任务类型，需要review以下代码
	local nextTaskId = nil

	for i = 1, #(self.taskTarget) do
		local taskTarget = self.taskTarget[i]

		if taskTarget.taskType == TaskTargetType.kMainLevel then

			local star = 0
			local score = UserManager.getInstance():getUserScore(taskTarget.level)
			if score then
				star = score.star
			end

			if taskTarget.star > star or taskTarget.level > topLevelId then
				nextTaskId = i 
				break
			end
		end
	end

	if not nextTaskId then
		nextTaskId = 8
	end

	return nextTaskId
end

function LadybugDataManager:calcNextTaskId( ... )
	if self:hadTrigger() then
		if self:hadAllFinish() then
			return nil
		end

		local info = UserManager:getInstance().newLadyBugInfo
		if self:hadFinish(info) then
			if info.id < 8 then
				return info.id + 1
			else
				return nil
			end
		else
			return info.id
		end
	else
		if self:shouldTriggerTask() then


			return self:calcProperTask()

		else
			return nil
		end
	end
end

function LadybugDataManager:getMaxTaskLevel( ... )
	local level = 62
	for k, v in ipairs(self.taskTarget) do
		if v.taskType == TaskTargetType.kMainLevel then
			level = math.max(level, v.level)
		end
	end
	return level
end

function LadybugDataManager:triggerTask(successCallback, failCallback, cancelCallback)
	LadybugHttp:trigger(successCallback, failCallback, cancelCallback)
end

function LadybugDataManager:getAllOldReward(successCallback, failCallback, cancelCallback)
	LadybugHttp:getAllOldReward(function ( evt )
		local rewardItems = {}
		if evt and evt.data and evt.data.rewardItems then
			rewardItems = evt.data.rewardItems
		end

		if #rewardItems > 0 then
			DcUtil:UserTrack({
				category="ladybug",
				sub_category="ladybug_reward" 
			})
		end

		if successCallback then
			successCallback(rewardItems)
		end
	end, failCallback, cancelCallback)
end

function LadybugDataManager:getReward(successCallback, failCallback, cancelCallback )
	local info = UserManager:getInstance().newLadyBugInfo
	if self:hadFinishWithoutGetReward(info) then

		LadybugHttp:getReward(info.id, function ( evt )
			local rewardItems = {}

			if evt and evt.data and evt.data.rewardItems then
				rewardItems = evt.data.rewardItems or {}
			end

			if #rewardItems > 0 then
				DcUtil:UserTrack({
					category="ladybug",
					sub_category="ladybug_child_task" ,
					t1 = info.id,
					t2 = 2,
					curTime = Localhost:time()
				})
			end

			info.reward = true
			self:checkDataChange()
			self:refreshIcon()

			if successCallback then
				successCallback(rewardItems)
			end

		end, function ( evt )
			if evt and evt.data then
				local errCode = tostring(evt.data)
				if errCode == '730722' then

					DcUtil:UserTrack({
						category="ladybug",
						sub_category="ladybug_child_task" ,
						t1 = info.id,
						t2 = 2,
						curTime = Localhost:time()
					})

					info.reward = true

					self:checkDataChange()
					self:refreshIcon()

					if successCallback then
						successCallback({})
					end
					return
				end
			end

			if failCallback then
				failCallback(evt)
			end

		end, cancelCallback)
	end
end

function LadybugDataManager:isNoticeButtonNode( level )
	return self.noticeButton and self.noticeButton.__level == level
end

function LadybugDataManager:getCurTaskId( ... )
	local info = UserManager:getInstance().newLadyBugInfo
	if self:isValidInfo(info) then
		return info.id
	end
end

function LadybugDataManager:getTaskInfo( ... )
	return UserManager:getInstance().newLadyBugInfo
end

function LadybugDataManager:getRewardConfig( taskId )
	-- body
	return table.union(
		self.rewardConfig[taskId],
		self.extraConfig
	)
end

function LadybugDataManager:getTaskTarget( taskId )
	return self.taskTarget[taskId]
end

function LadybugDataManager:hadTrigger( ... )
	if PlatformConfig:isPlayDemo() then
		return false
	end
	local info = UserManager:getInstance().newLadyBugInfo
	return self:isValidInfo(info)
end

function LadybugDataManager:hadAllFinish( ... )
	local info = UserManager:getInstance().newLadyBugInfo
	return self:isValidInfo(info) and info.id == #(self.taskTarget) and self:hadGotReward(info)
end

function LadybugDataManager:hadGotReward( info )
	return info.reward == true
end

function LadybugDataManager:hadFinish( info )
	local target = self.taskTarget[info.id]
	if target.taskType == TaskTargetType.kMainLevel then
		local topLevelId = UserManager:getInstance().user:getTopLevelId()
		local passed = UserManager.getInstance():hasPassedLevelEx(topLevelId)
		if (not passed) and topLevelId > 1 then
			topLevelId = topLevelId - 1
		end

		local star = 0
		local score = UserManager.getInstance():getUserScore(target.level)
		if score then
			star = score.star
		end

		if topLevelId >= target.level and star >= target.star then
			return true
		else
			return false
		end
	elseif target.taskType == TaskTargetType.kSeasonWeekly then
		local playCounter = tonumber(info.extra) or 0
		return playCounter >= target.num
	else
		return false
	end
end

function LadybugDataManager:canGetReward( info )
	return self:isValidInfo(info) and self:hadFinish(info) and (not self:hadGotReward(info)) and self:isInValidRewardTime(info)
end

function LadybugDataManager:hadFinishWithoutGetReward( info )
	-- if _G.isLocalDevelopMode then printx(0, table.tostring(info)) end

	return self:isValidInfo(info) and self:hadFinish(info) and (not self:hadGotReward(info))
end

function LadybugDataManager:getRewardAvailableTime( info )
	if self:hadFinishWithoutGetReward(info) and (not self:isInValidRewardTime(info)) then
		-- local lastFinishDay = getDayStartTimeByTS(info.lastFinishTime)
		-- return lastFinishDay + 24*3600*1000 - Localhost:time()
		return info.lastFinishTime + ONE_DAY_MS - Localhost:time()
	else
		return 0
	end
end

-- 这行注释没用 [至少和上一次任务完成 不在同一天]
function LadybugDataManager:isInValidRewardTime( info )
	-- local lastFinishDay = getDayStartTimeByTS(info.lastFinishTime)
	-- local now = getDayStartTimeByTS(Localhost:time())
	-- if _G.isLocalDevelopMode then printx(0, now, lastFinishDay, info.lastFinishTime) end
	-- return info.id == 1 or info.lastFinishTime == info.lastRewardTime or now > lastFinishDay
	return true
end

function LadybugDataManager:__isValidExtraReward( info )

	if self:hadFinish(info) then
		-- return getDayStartTimeByTS(info.finishTime) - getDayStartTimeByTS(info.lastRewardTime) <= 0
		return info.finishTime - info.lastRewardTime <= ONE_DAY_MS
	else
		-- return getDayStartTimeByTS(info.lastRewardTime) == getDayStartTimeByTS(Localhost:time())
		return Localhost:time() - info.lastRewardTime <= ONE_DAY_MS
	end
end

function LadybugDataManager:getExtraRewardRestTime(info )
	if self:isValidInfo(info) then
		if self:hadFinish(info) then
			return 0
		elseif not self:isValidExtraReward(info) then
			return 0
		else
			-- return getDayStartTimeByTS(info.lastRewardTime) + 24*3600*1000 - Localhost:time()
			return info.lastRewardTime + ONE_DAY_MS - Localhost:time()
		end
	else
		return 0
	end
end

function LadybugDataManager:isValidExtraReward( info )
	return self:isValidInfo(info) and self:__isValidExtraReward(info)
end

function LadybugDataManager:isValidInfo( info )
	if type(info) ~= 'table' then
		return false
	end

	local taskId = tonumber(info.id) or 0
	if taskId >= 1 and taskId <= #(self.taskTarget) then
		return true
	else
		return false
	end
end

function LadybugDataManager:onEnterHomeScene(forcePopout, popoutResult)
	if self:hadTrigger() then
		if not self:hadAllFinish() then

			self:checkDataChange()

			self:createIcon()
			self:createNoticeButton()

			if forcePopout and self.level_2_to_3 then
				DcUtil:UserTrack({
					category="ladybug",
					sub_category="ladybug_init" ,
					t1 = 1
				})

				self.level_2_to_3 = false
				popoutResult(self:checkPopoutPanel())
			else
				if popoutResult then popoutResult(false) end
			end

		else
			if popoutResult then popoutResult(false) end
		end 
	else
		if self:shouldTriggerTask() then
			self:triggerTask(function ( ... )

				
				DcUtil:UserTrack({
					category="ladybug",
					sub_category="ladybug_child_task" ,
					t1 = self:getCurTaskId(),
					t2 = 0,
					curTime = Localhost:time()
				})


				self:createIcon()
				self:createNoticeButton()


				if forcePopout and self.level_2_to_3 then

					DcUtil:UserTrack({
						category="ladybug",
						sub_category="ladybug_init" ,
						t1 = 1
					})

					self.level_2_to_3 = false

					popoutResult(self:checkPopoutPanel())
				else
					if popoutResult then popoutResult(false) end
				end

			end, function ( ... )
				if popoutResult then popoutResult(false) end
			end, function ( ... )
				if popoutResult then popoutResult(false) end
			end)
		else
			if popoutResult then popoutResult(false) end
		end
	end
end

function LadybugDataManager:createIcon( ... )
	if not self.icon then
		local NewLadybugButton = require 'zoo.panel.newLadybug.NewLadybugButton'
		self.icon = NewLadybugButton:create()
		self.icon:addToUi()


		HomeScene:sharedInstance():addEventListener(SceneEvents.kEnterForeground,function()
			self:delayRefreshIcon()
		end)
	end
end

function LadybugDataManager:deleteIcon( ... )
	if self.icon and (not self.icon.isDisposed) then
		self.icon:removeFromUi()
	end
	self.icon = nil
end

function LadybugDataManager:checkPopoutPanel()
	local taskInfo = self:getTaskInfo()
    return self:isValidInfo(taskInfo)
end

function LadybugDataManager:popoutPanel()
    if not self:checkPopoutPanel() then
    	return
    end
    local LadybugTaskPanel = require 'zoo.panel.newLadybug.LadybugTaskPanel'
	LadybugTaskPanel:create():popout(closeCallback)
end

function LadybugDataManager:onPassMainLevel( ... )

	local topLevel = UserManager.getInstance():getUserRef():getTopLevelId()

	if topLevel == 3 then
		-- setTimeOut(function ( ... )
		-- 	self:onEnterHomeScene()
		-- end, 2)
	end

	self:checkDataChange()
	self:refreshIcon()

end

function LadybugDataManager:onPlaySeasonWeekly( ... )
	local taskId = self:getCurTaskId()

	if taskId then
	
		local taskTarget = self.taskTarget[taskId]

		if taskTarget.taskType == TaskTargetType.kSeasonWeekly then

			local extra = UserManager:getInstance().newLadyBugInfo.extra
			extra = (tonumber(extra) or 0) + 1
			UserManager:getInstance().newLadyBugInfo.extra = tostring(extra)
			UserService:getInstance().newLadyBugInfo.extra = tostring(extra)
			self:checkDataChange()

			if extra >= taskTarget.num then
				if self.icon and (not self.icon.isDisposed) then
					self.icon:setRewarcIconVisible(true)
				end
			end

			self:refreshIcon()
		end
	end

end

function LadybugDataManager:getKey( taskId )
	local uid = UserManager.getInstance().uid or "0"
	return 'new.ladybug.finish.'.. tostring(uid).. '.'..tostring(taskId)
end

function LadybugDataManager:writeFinishTime( taskId , time)
	time = time or Localhost:time()

	local task_status

	local info = UserManager:getInstance().newLadyBugInfo
	if self:isValidInfo(info) and info.id == taskId and Localhost:time() - info.lastRewardTime > ONE_DAY_MS then
		task_status = 1
	else
		task_status = 4
	end

	DcUtil:UserTrack({
		category="ladybug",
		sub_category="ladybug_child_task" ,
		t1 = taskId,
		t2 = task_status,
		curTime = Localhost:time()
	})

	CCUserDefault:sharedUserDefault():setStringForKey(self:getKey(taskId), tostring(time))
end

function LadybugDataManager:getFinishTime( taskId )

	local info = UserManager:getInstance().newLadyBugInfo
	if info and info.finishTimes and (tonumber(info.finishTimes[taskId]) or 0) > 0 then
		return tonumber(info.finishTimes[taskId])
	end

	return tonumber(CCUserDefault:sharedUserDefault():getStringForKey(self:getKey(taskId), 0)) or 0
end

function LadybugDataManager:checkDataChange( ... )
	local info = UserManager:getInstance().newLadyBugInfo
	if not self:isValidInfo(info) then
		return
	end

	--不只是一个动画
	if self.noticeButton then
		local level = self.noticeButton.__level
		if level and level <= 62 then

			local properTaskId = self:calcProperTask()

			if not properTaskId then
				return
			end

			local newlevel = 0
			local lastMainLevelTaskFinish = false

			local target = self:getTaskTarget(properTaskId)
			if target.taskType == TaskTargetType.kMainLevel then 
				newlevel = target.level 
				if target.star < 3 then
					newlevel = newlevel + 1
				end
			else
				lastMainLevelTaskFinish = true
			end

			if newlevel > level or lastMainLevelTaskFinish then

				local showRewardIcon = false

				if properTaskId == info.id + 1 and self:hadFinish(info) and self:canGetReward(info) then
					showRewardIcon = true
				end

				self:playTaskFinishAnim(showRewardIcon)

				if self:getFinishTime(properTaskId-1) == 0 then
					self:writeFinishTime(properTaskId-1)
				end

			end
		end
	end




	if self:hadFinish(info) then
		if (tonumber(info.finishTime) or 0) == 0 then
			info.finishTime = Localhost:time()
			if self:getFinishTime(info.id) == 0 then
				self:writeFinishTime(info.id)
			end
		end
	end

	info.canReward = self:canGetReward(info)

	if self:hadGotReward(info) then
		if info.id < #(self.taskTarget) then
			info.id = info.id + 1
			info.lastRewardTime = Localhost:time()
			info.lastFinishTime = info.finishTime
			info.finishTime = self:getFinishTime(info.id) or 0
			info.reward = false
			info.canReward = false
			info.extra = '0'
			
		else
			self:deleteIcon()
		end
	end

	if info.id > 7 then
		self:deleteNoticeButton()
	else
		self:refreshNoticeButton()
	end

	UserService:getInstance().newLadyBugInfo:fromLua(info)

	-- self:processNotification()

end

function LadybugDataManager:refreshIcon( ... )
	if (not self.icon) or (self.icon.isDisposed) then
		return
	end
	
	self.icon:refreshState()
end

function LadybugDataManager:delayRefreshIcon( ... )
	if (not self.icon) or (self.icon.isDisposed) then
		return
	end

	self.icon:runAction(CCCallFunc:create(function ( ... )
		self:refreshIcon()
	end))
end

function LadybugDataManager:refreshNoticeButton( ... )
	local info = self:getTaskInfo()
	local taskId = self:getCurTaskId()


	if taskId then

		local properTaskId = self:calcProperTask()

		if not properTaskId then
			self:deleteNoticeButton()
			return
		end

		local target = self:getTaskTarget(properTaskId)
		if target.taskType ~= TaskTargetType.kMainLevel then 
			self:deleteNoticeButton()
			return
		end
		local level = target.level 
		if target.star < 3 then
			level = level + 1
		end
		if self.noticeButton then
			self.noticeButton:setPosByLevel(level)
		end
	end
end

function LadybugDataManager:onFriendPicUpdate( ... )
	if self.noticeButton and (not self.noticeButton.isDisposed) and self.noticeButton.level then
		self.noticeButton:setPosByLevel(self.noticeButton.level)
	end
end

function LadybugDataManager:createNoticeButton( ... )
	if not self.noticeButton then
		self.noticeButton = LadybugNoticeButton:create()
		local worldScene = HomeScene:sharedInstance().worldScene
		worldScene.iconButtonLayer:addChild(self.noticeButton)
		self:refreshNoticeButton()
	end

end

function LadybugDataManager:deleteNoticeButton( ... )
	if self.noticeButton and (not self.noticeButton.isDisposed) then
		self.noticeButton:removeFromParentAndCleanup(true)
	end
	self.noticeButton = nil
end

function LadybugDataManager:getNoticeButtonLevel( ... )
	if self.noticeButton then
		return self.noticeButton.level
	end
end

function LadybugDataManager:playTaskFinishAnim( showRewardIcon )

	local function __anim(delay)
		if not self.noticeButton then return end
		if not self.icon then return end
		self.icon:setRewarcIconVisible(false)
		local anim = LadybugAnimation:create(showRewardIcon, delay)
		anim:setLadybugIcon(self.icon)
		anim:setNoticeButton(self.noticeButton)
		anim:setIconShowCallback(function ( ... )
			if self.icon and (not self.icon.isDisposed) then
				self.icon:setRewarcIconVisible(true)
			end
		end)
		anim:play()
	end


	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	local userIconLevelId = HomeScene:sharedInstance().worldScene.userIconLevelId

	if topLevelId == 63 and userIconLevelId ~= topLevelId then
		__anim(2)
	else
		__anim()
	end

end

function LadybugDataManager:onTopLevelChanged( ... )
	if self.noticeButton then
		self.noticeButton:onTopLevelChanged(true)
	end

	if UserManager.getInstance():getUserRef():getTopLevelId() == 7 then
		self.level_2_to_3 = true
	end
end

function LadybugDataManager:popoutGuide( ... )

	if (not self.icon) or self.icon.isDisposed then return end

	local bounds = self.icon:getGroupBounds()

	LadybugGuidePanel:createGuideTwo(ccp(
		bounds:getMidX(),
		bounds:getMidY()
	)):popout()


end

function LadybugDataManager:refreshGoldCoinButton( ... )
	if HomeScene:sharedInstance().coinButton then
        HomeScene:sharedInstance():checkDataChange()
        HomeScene:sharedInstance().coinButton:updateView()
    end
    if HomeScene:sharedInstance().goldButton then
        HomeScene:sharedInstance():checkDataChange()
        HomeScene:sharedInstance().goldButton:updateView()
    end
end

--今日任务 明日任务 完成 未完成
function LadybugDataManager:getTaskState( info )
	local finished = self:isValidInfo(info) and self:hadFinish(info)
	local todayTask = self:isValidInfo(info) and self:isInValidRewardTime(info)
	return todayTask, finished
end

function LadybugDataManager:processNotification( ... )
	LocalNotificationManager:getInstance():cancelNewLadybugTaskNoti()
	local info = UserManager:getInstance().newLadyBugInfo
	local restTime = tonumber(self:getExtraRewardRestTime(info)) or 0
	restTime = restTime / 1000
	if restTime > 4*3600 then
		LocalNotificationManager:getInstance():setNewLadybugTaskNoti(
			Localhost:timeInSec() + restTime - 4*3600
		)
	end
end

LadybugDataManager.TaskTargetType = TaskTargetType

return LadybugDataManager