



local AreaTaskModel = class()

function AreaTaskModel:safeGetTopLevel( ... )
	local topLevelId = 0 
	if UserManager:getInstance().user then
		topLevelId = UserManager:getInstance().user:getTopLevelId()
	end
	return topLevelId
end



function AreaTaskModel:ctor( ... )
	
end

function AreaTaskModel:checkTaskExpire( ... )
	-- local curTasks = self:__getTaskInfos().areaTasks
	-- local filteredExpiredTasks = self:__getFilteredExpiredTasks(curTasks)
	-- if #filteredExpiredTasks ~= #curTasks then
		-- self:writeAreaTasks(filteredExpiredTasks)
	-- end
	-- return filteredExpiredTasks
end

function AreaTaskModel:__getFilteredExpiredTasks( curTasks )
	-- body
	local filteredExpiredTasks = table.filter(curTasks, function ( item )
		return not self:isExpired(item)
	end)
	return filteredExpiredTasks
end

function AreaTaskModel:__getFilteredRewardedTasks( curTasks )
	-- body
	local filteredRewardedTasks = table.filter(curTasks, function ( item )
		return not item.rewarded
	end)
	return filteredRewardedTasks
end

function AreaTaskModel:writeAreaTasks( areaTasks, updateMaxTriggerAreaId, updateCDBTimeWhenRewarded, updateCDBTimeWhenTriggered )
	local areaTaskInfo = UserManager:getInstance():getAreaTaskInfo():encode()

	local levelIdMapTaskInfo = {}
	for _, taskInfo in ipairs(areaTaskInfo.areaTasks) do
		levelIdMapTaskInfo[taskInfo.levelId] = taskInfo
	end

	for _, taskInfo in ipairs(areaTasks) do
		if levelIdMapTaskInfo[taskInfo.levelId] then

			for k, v in pairs(taskInfo) do
				levelIdMapTaskInfo[taskInfo.levelId][k] = v
			end
		else
			table.insert(areaTaskInfo.areaTasks, taskInfo)
		end
	end
	if updateMaxTriggerAreaId then

		local t = table.reduce(areaTasks, function ( a, b )
			local la = a.levelId or 0
			local lb = b.levelId or 0
			return la > lb and a or b
		end) or {}

		-- local maxAreaId = self:getAreaIdByLevelId(
		-- 	t.levelId or 0
		-- ) or 0x7FFFFFFF

		-- if areaTaskInfo.maxTriggeredAreaId ~= 0x7FFFFFFF then
		-- 	areaTaskInfo.maxTriggeredAreaId = math.max(areaTaskInfo.maxTriggeredAreaId, maxAreaId)
		-- else
		-- 	areaTaskInfo.maxTriggeredAreaId = maxAreaId
		-- end
	end

	if updateCDBTimeWhenRewarded then
		areaTaskInfo.coolDownBeginTime = Localhost:time()
	end

	if updateCDBTimeWhenTriggered then
		for _, v in ipairs(areaTaskInfo.areaTasks or {}) do
			areaTaskInfo.coolDownBeginTime = math.max(areaTaskInfo.coolDownBeginTime, v.endTime or 0)
		end
	end

	UserManager:getInstance():setAreaTaskInfo(areaTaskInfo)
	UserService:getInstance():setAreaTaskInfo(areaTaskInfo)
	Localhost:getInstance():flushCurrentUserData()
end

function AreaTaskModel:setAreaTaskInfo( areaTaskInfo )
	UserManager:getInstance():setAreaTaskInfo(areaTaskInfo)
	UserService:getInstance():setAreaTaskInfo(areaTaskInfo)
	Localhost:getInstance():flushCurrentUserData()
end

function AreaTaskModel:__getTaskInfos( ... )

	local areaTaskInfo = UserManager:getInstance():getAreaTaskInfo()

	local areaTasks = areaTaskInfo.areaTasks

	areaTasks = table.filter(areaTasks, function ( taskInfo )
		local levelId = taskInfo.levelId or 0
		return levelId <= kMaxLevels
	end)

	local topLevelId = AreaTaskModel:safeGetTopLevel()
	local topAreaId = self:getAreaIdByLevelId(topLevelId) or 0

	-- local maxTriggeredAreaId = areaTaskInfo.maxTriggeredAreaId

	local availableTaskAreaIds = {}

	-- for i = maxTriggeredAreaId + 1, topAreaId do
		-- if i >= 40006 then
			-- table.insert(availableTaskAreaIds, i)
		-- end
	-- end


	local globalMaxLevel = UserManager:getInstance():getGlobalMaxLevel() or 0x7FFFFFFF
	local globalMaxAreaId = math.floor((globalMaxLevel - 1) / 15) + 40001


	if (topAreaId >= 40006) and topAreaId <= globalMaxAreaId - 2 then
		if not table.find(self:__getFilteredExpiredTasks(areaTasks) or {}, function ( v )
			return topAreaId == self:getAreaIdByLevelId(v.levelId or 1)
		end) then
			table.insert(availableTaskAreaIds, topAreaId)
		end
	end

	if #availableTaskAreaIds > 0 then
		table.sort(availableTaskAreaIds)
		availableTaskAreaIds = {availableTaskAreaIds[#availableTaskAreaIds]}
	end



	-- ========================= --

	areaTasks = table.map(function ( taskItem )


		local newTaskItem = table.clone(taskItem or {}, true) or {}

		newTaskItem.rewards = table.filter(newTaskItem.rewards or {}, function ( v )
			return table.exist(ItemType, v.itemId or -1)
		end)

		return newTaskItem

	end, areaTasks or {})

	-- ========================= --

	return {
		areaTasks = areaTasks or {}, 
		availableTaskAreaIds = availableTaskAreaIds or {}
	}
end	


--当前已触发的有效的任务 
-- 未领取 未过期
function AreaTaskModel:getCurTaskInfos( ... )
	local curTasks = self:__getTaskInfos().areaTasks
	local filteredExpiredTasks = self:__getFilteredExpiredTasks(curTasks)
	return self:__getFilteredRewardedTasks(filteredExpiredTasks)
end


-- 未领取
function AreaTaskModel:getCurTaskInfosWithExpired( ... )
	local curTasks = self:__getTaskInfos().areaTasks
	return self:__getFilteredRewardedTasks(curTasks)
end

function AreaTaskModel:getCurTaskInfosAll( ... )
	local curTasks = self:__getTaskInfos().areaTasks
	return curTasks
end

function AreaTaskModel:findTaskInfoByLevelId( levelId )
	return table.find(self:getCurTaskInfosAll(), function ( v )
		return v.levelId == levelId
	end)
end

--某个区域的任务 包含已过期的
function AreaTaskModel:getTaskInfosByAreaId( areaId )
	local levelStart = ((areaId - 40000) - 1) * 15 + 1
	local levelEnd = levelStart + 14
	return table.filter(self:getCurTaskInfosWithExpired(), function ( v )
		return v.levelId >= levelStart and v.levelId <= levelEnd
	end)
end


function AreaTaskModel:getAllTaskInfosByAreaId( areaId )
	local levelStart = ((areaId - 40000) - 1) * 15 + 1
	local levelEnd = levelStart + 14
	return table.filter(self:getCurTaskInfosAll(), function ( v )
		return v.levelId >= levelStart and v.levelId <= levelEnd
	end)
end

--未领取 未过期 未完成
function AreaTaskModel:getCurUnfinishedInfos( ... )
	local taskInfoList = self:getCurTaskInfos()
	return table.filter(taskInfoList, function ( taskInfo )
		return not self:isTaskFinished(taskInfo)
	end)
end

--可触发任务的区域id
function AreaTaskModel:getAvailableTaskAreaIds( ... )
	return self:__getTaskInfos().availableTaskAreaIds
end

function AreaTaskModel:getAreaIdByLevelId( levelId )
	local levelAreaRef = MetaManager:getInstance():getLevelAreaRefByLevelId(levelId)
	if levelAreaRef then
		local areaId = levelAreaRef.id
		return areaId
	end
end

function AreaTaskModel:isExpired( taskInfo )
	local expired = true
	if taskInfo and taskInfo.endTime then
		expired = taskInfo.endTime > 0 and taskInfo.endTime < Localhost:time()
	end
	return expired
end

function AreaTaskModel:isTaskFinished( taskInfo )

	local topLevelId = self:safeGetTopLevel()

	if topLevelId >= taskInfo.levelId and (not self:isExpired(taskInfo)) then
		return true
	end

	if taskInfo.finished then
		return true
	end

	return false
end

function AreaTaskModel:filterFinishedTasks( taskInfoList )
	return table.filter(taskInfoList, function ( taskInfo )
		return self:isTaskFinished(taskInfo)
	end)
end

function AreaTaskModel:isInCD( cdTime )
	local areaTaskInfo = UserManager:getInstance():getAreaTaskInfo()
	local coolDownBeginTime = areaTaskInfo.coolDownBeginTime or 0

	return Localhost:time() < cdTime + coolDownBeginTime
end

function AreaTaskModel:triggerNewTask( onSuccess, onFail, onCancel )

	local availableTaskAreaIds = self:getAvailableTaskAreaIds()

	if #availableTaskAreaIds <= 0 then
		if onSuccess then onSuccess({}) end
		return
	end

	local taskInfoList = {}
	for _, areaId in ipairs(availableTaskAreaIds) do
		local areaTaskCfg = MetaManager:getInstance():getAreaTaskCfg(areaId) or {}

		local tmp = {}

		for index, taskCfg in ipairs(areaTaskCfg.tasks or {}) do
			local taskInfo = {}
			taskInfo.endTime = Localhost:time() + taskCfg.duration
			taskInfo.beginTime = Localhost:time()
			taskInfo.levelId = taskCfg.levelId

			if self.rewardsStrategy then
				taskInfo.rewards, taskInfo.rewardId = self.rewardsStrategy:process(taskCfg)
			else
				taskInfo.rewards = table.clone(taskCfg.rewards, true)
			end

			taskInfo.index = index
			taskInfo.rewarded = false
			taskInfo.finished = false
			taskInfo.finished = self:isTaskFinished(taskInfo)

			if not taskInfo.finished then
				table.insert(tmp, taskInfo)
			else
			end
		end

		if #tmp >= 3 then
			taskInfoList = table.union(taskInfoList, tmp)
		end

	end

	if #taskInfoList <= 0 then
		if onSuccess then onSuccess({}) end
		return
	end

	HttpBase:offlinePost(kHttpEndPoints.areaTaskTrigger, {areaTask = taskInfoList}, function ( ... )


		DcUtil:UserTrack({category='ui', sub_category='area_goal', t1 = self:safeGetTopLevel()}, true)


		self:writeAreaTasks(taskInfoList, true, false, true)

		if onSuccess then onSuccess(availableTaskAreaIds) end
	end, onFail, onCancel)
end



function AreaTaskModel:getRewards( taskInfo, onSuccess, onFail, onCancel)
	
	HttpBase:offlinePost(kHttpEndPoints.areaTaskReward, {levelId = taskInfo.levelId}, function ( ... )

		local curTaskInfos = self:getCurTaskInfosWithExpired()
		local newTaskInfos = table.map(function ( v )
			if v.levelId == taskInfo.levelId then
				v.rewarded = true
			end
			return v
		end, curTaskInfos)

		local finisedThirdTask = false
		finisedThirdTask = taskInfo.index == 3

		self:writeAreaTasks(newTaskInfos, nil, finisedThirdTask)

		local rewards = table.clone(taskInfo.rewards, true)


		local onlyInfiniteBottle = table.filter(rewards, function ( tRewardItem )
			return tRewardItem.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE
		end)

		-- local withoutInfiniteBottle = table.filter(rewards, function ( tRewardItem )
			-- return tRewardItem.itemId ~= ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE
		-- end)

		local tInfiniteRewardItem = onlyInfiniteBottle[1] --如果有 那么应该仅有一项

		UserManager:getInstance():addRewards(rewards)
		UserService:getInstance():addRewards(rewards)
		GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kLevelArea, rewards, DcSourceType.kNormalAreaReward)

		if tInfiniteRewardItem then
			local logic = UseEnergyBottleLogic:create(tInfiniteRewardItem.itemId, DcFeatureType.kLevelArea, DcSourceType.kNormalAreaReward)
			logic:setUsedNum(tInfiniteRewardItem.num)
			logic:setSuccessCallback(function ( ... )
				-- body
				-- printx(61, 'xxxxxxxxxxxxx')
				HomeScene:sharedInstance():checkDataChange()
				HomeScene:sharedInstance().energyButton:updateView()
			end)
			logic:setFailCallback(function ( evt )
				-- body
				-- printx(61, 'yyyyyyyyyyyyyyy', table.tostring(evt))
			end)
			logic:start(true)

			-- printx(61, 'xxxxxxxxxxxxx yyyyyyyyyyyyyyy')
		end


		

		Localhost:getInstance():flushCurrentUserData()
		HomeScene:sharedInstance():checkDataChange()
		local scene = HomeScene:sharedInstance()
		if scene.coinButton then scene.coinButton:updateView() end
		if scene.goldButton then scene.goldButton:updateView() end
		scene:checkDataChange()

		local t3 = ''

		for _, v in ipairs(taskInfo.rewards) do
			t3 = t3 .. tostring(v.itemId) .. ':' .. tostring(v.num) .. ','
		end

		DcUtil:UserTrack({category='ui', sub_category='area_goal', t2 = taskInfo.levelId, t3 = t3}, true)

		if onSuccess then onSuccess(taskInfo.rewards) end



	end, onFail, onCancel)

end

--当前有效的 为领奖 但已完成 的任务
function AreaTaskModel:getFinishedTasks( ... )
	return self:filterFinishedTasks(self:getCurTaskInfosWithExpired())
end

function AreaTaskModel:checkFinished( ... )

	local anyJustFinished = false

	local findThirdTask = false

	local curTaskInfos = self:getCurTaskInfos()

	for _, taskInfo in ipairs(curTaskInfos) do

		local _tmp = taskInfo.finished

		taskInfo.finished = self:isTaskFinished(taskInfo)

		if (not _tmp) and taskInfo.finished then
			--todo notify server i finished a task
			anyJustFinished = true
			findThirdTask = taskInfo.index == 3
		end

	end

	self:writeAreaTasks(curTaskInfos, false, anyJustFinished and findThirdTask)

	return anyJustFinished
end

return AreaTaskModel