RecallRewardType = {NO_REWARD = 0,
					LEVEL_SHORT = 1,
					LEVEL_MIDDLE = 2,
					LEVEL_LONG = 3,
					AREA_SHORT = 11,
					AREA_MIDDLE = 12,
					AREA_LONG = 13
					}

local RecallVO = class()

function RecallVO:ctor()
	self.lastLeaveTime = nil
	self.lastTopLevel = nil
	self.stayForLastLevel = nil
	self.threeDayTipFlag = nil
	self.sevenDayTipFlag = nil
end

-- return isValid
function RecallVO:decode(src)
	if src.lastLeaveTime and type(src.lastLeaveTime) == "number"
		and src.lastTopLevel and type(src.lastTopLevel) == "number"
		and src.stayForLastLevel and type(src.stayForLastLevel) == "number"
		and src.threeDayTipFlag and type(src.threeDayTipFlag) == "boolean"
		and src.sevenDayTipFlag and type(src.sevenDayTipFlag) == "boolean" then

		self.lastLeaveTime = src.lastLeaveTime
		self.lastTopLevel = src.lastTopLevel
		self.stayForLastLevel = src.stayForLastLevel
		self.threeDayTipFlag = src.threeDayTipFlag
		self.sevenDayTipFlag = src.sevenDayTipFlag
		he_log_info("RecallVO.lastLeaveTime===============>"..src.lastLeaveTime)
		he_log_info("RecallVO.lastTopLevel================>"..src.lastTopLevel)
		he_log_info("RecallVO.stayForLastLevel============>"..src.stayForLastLevel)

		return true
	end
	return false
end

function RecallVO:toObject()
	return {lastLeaveTime = self.lastLeaveTime, lastTopLevel = self.lastTopLevel, stayForLastLevel = self.stayForLastLevel, threeDayTipFlag = self.threeDayTipFlag, sevenDayTipFlag = self.sevenDayTipFlag}
end


RecallManager = class()
local kStorageFileName = "recallInfo"
local kLocalDataExt = ".ds"
local instance = nil
local oneDaySeconds = 86400
--卡区或者卡关停留天数的限制
local stayForDaysLimit = 3
--当前召回奖励状态
local currentRewardState = RecallRewardType.NO_REWARD
--当前需解锁区域Id
local needUnlockAreaId = nil
--是否本地重置过玩家流失状态
localReset = false

function RecallManager.getInstance()
	if not instance then
		instance = RecallManager.new()
		instance:init()
	end
	return instance
end

function RecallManager:init()
	self:getConfigMaxLevel()
	self:initLocalService()

	self.recallInfoVO = nil
	local path = HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName .. kLocalDataExt
	local file, err = io.open(path, "rb")
	he_log_info("RecallManager====init")
	if file and not err then
		local content = file:read("*a")
		io.close(file)

        local fields = nil
        local function decodeContent()
            fields = amf3.decode(content)
        end
        pcall(decodeContent)

		if fields and type(fields) == "table" then
			self.recallInfoVO = RecallVO.new()
			if not self.recallInfoVO:decode(fields) then
				he_log_info("RecallManager====local data of recallInfo.ds is incorrect")
				self.recallInfoVO = nil
			end
		end
	end
end

function RecallManager:getConfigMaxLevel()
	self.configTopLevelId = MetaManager.getInstance():getMaxNormalLevelByLevelArea()
end

function RecallManager:initLocalService()
	local cachedLocalUserData = Localhost.getInstance():readLastLoginUserData()
	if cachedLocalUserData and cachedLocalUserData.user then
		UserManager:getInstance():decode(cachedLocalUserData.user)
	end
end

function RecallManager:flushToStorage()
	if self.recallInfoVO then 
		local content = amf3.encode(self.recallInfoVO:toObject())
		local filePath = HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName .. kLocalDataExt
	    local file = io.open(filePath, "wb")
	    assert(file, "persistent file failure " .. kStorageFileName)
	    if not file then return end
		local success = file:write(content)
	   
	    if success then
	        file:flush()
	        file:close()
	    else
	        file:close()
	        he_log_info("write file failure " .. filePath)
	    end
	end
end

--离开游戏前调用
function RecallManager:updateRecallInfo()
	if self.recallInfoVO then
		local currentLevel = UserManager:getInstance().user:getTopLevelId()
		if currentLevel == self.recallInfoVO.lastTopLevel then 
			local timePass = os.time() - self.recallInfoVO.lastLeaveTime
			if timePass <= 0 then 
				timePass = 0
			end
			self.recallInfoVO.stayForLastLevel = self.recallInfoVO.stayForLastLevel + timePass
			self.recallInfoVO.lastLeaveTime = os.time()
		else
			self.recallInfoVO.lastLeaveTime = os.time()
			self.recallInfoVO.lastTopLevel = currentLevel
			self.recallInfoVO.stayForLastLevel = 0
		end
	else
		self.recallInfoVO = RecallVO.new()
		self.recallInfoVO:decode(self:getOriginalRecallInfo())
	end
	self:flushToStorage()
end

function RecallManager:getOriginalRecallInfo()
	local originalInfo = {}
	originalInfo.lastLeaveTime = os.time()
	originalInfo.lastTopLevel = UserManager:getInstance().user:getTopLevelId()
	originalInfo.stayForLastLevel = 0
	originalInfo.threeDayTipFlag = true
	originalInfo.sevenDayTipFlag = true
	return originalInfo
end

--是否满足卡关或者卡区的条件 用以判断是否发送召回推送和获取召回奖励状态时的校验
function RecallManager:getLevelStayState()
	if self.recallInfoVO then
		local currentStayLevel = self.recallInfoVO.lastTopLevel
		if currentStayLevel%15==0 then 
			local scoreOfLevel = UserManager:getInstance():getUserScore(currentStayLevel)
			if scoreOfLevel then
				if scoreOfLevel.star ~= 0 or JumpLevelManager:getLevelPawnNum(currentStayLevel) > 0 then 
					--排除最高关卡通关的卡区情况 
					if currentStayLevel >= self.configTopLevelId then 
						return false
					end
				end
			end
		end

		--离开之前在同一关卡停留的天数
		local stayLastDay = self.recallInfoVO.stayForLastLevel/oneDaySeconds
		he_log_info("RecallManager***stayLastDay===============>"..stayLastDay)
		if stayLastDay>=stayForDaysLimit then 
			return true
		end
	end
	return false
end

--三天和十天召回的 同一种召回不可连续两次使用相同文案 这里取得文案状态 
function RecallManager:getRecallNotifyTipState()
	if self.recallInfoVO then 
		return self.recallInfoVO.threeDayTipFlag, self.recallInfoVO.sevenDayTipFlag
	end
	return true,true
end

local function getDayStartTimeByTS(ts)
	local utc8TimeOffset = 57600 -- (24 - 8) * 3600
	local oneDaySeconds = 86400 -- 24 * 3600
	return ts - ((ts - utc8TimeOffset) % oneDaySeconds)
end

function RecallManager:getLeaveDay()
	local today = getDayStartTimeByTS(os.time())

	local lastLeaveTime =  self:getLastLeaveTime() or 0

	local lastLoginDay = getDayStartTimeByTS(lastLeaveTime)
	local leaveTime = today - lastLoginDay
	--离开的天数
	local leaveDay = leaveTime/oneDaySeconds

	return leaveDay
end

function RecallManager:getRecallRewardState()
	if self.recallInfoVO then 
		local levelStayState = self:getLevelStayState()
		if not levelStayState then 
			return RecallRewardType.NO_REWARD
		end
		local today = getDayStartTimeByTS(os.time())
		local lastLoginDay = getDayStartTimeByTS(self.recallInfoVO.lastLeaveTime)
		local leaveTime = today - lastLoginDay
		if leaveTime <= 0 then 
			return RecallRewardType.NO_REWARD
		end
		--离开的天数
		local leaveDay = leaveTime/oneDaySeconds
		he_log_info("RecallManager***leaveDay===============>"..leaveDay)
		if leaveDay >= 3 then 
			local currentStayLevel = self.recallInfoVO.lastTopLevel
			--卡关还是卡区
			local stayForLevel = true
			if currentStayLevel%15==0 then 
				local scoreOfLevel = UserManager:getInstance():getUserScore(currentStayLevel)
				if scoreOfLevel then
					--有星级 表明此关已过 就是卡区解锁了
					if scoreOfLevel.star ~= 0 or JumpLevelManager:getLevelPawnNum(currentStayLevel) > 0 then 
						stayForLevel = false
					end
				end
			end
			if leaveDay < 7 then 
				if self.recallInfoVO.threeDayTipFlag then 
					self.recallInfoVO.threeDayTipFlag = false
				else
					self.recallInfoVO.threeDayTipFlag = true
				end  
				--三天和七天的召回文案有特殊处理 这里写入本地
				self:flushToStorage()
				if stayForLevel then 
					return RecallRewardType.LEVEL_SHORT
				else
					if currentStayLevel < self.configTopLevelId then 
						return RecallRewardType.AREA_SHORT
					else
						--卡的是当前关卡配置的最高区域  不该走卡区解锁流程
						return RecallManager.NO_REWARD
					end
				end
			elseif leaveDay >= 7 and leaveDay < 10 then
				if stayForLevel then 
					return RecallRewardType.LEVEL_MIDDLE
				else
					if currentStayLevel < self.configTopLevelId then 
						return RecallRewardType.AREA_MIDDLE
					else
						return RecallManager.NO_REWARD
					end
				end
			elseif leaveDay >= 10 then
				if self.recallInfoVO.sevenDayTipFlag then 
					self.recallInfoVO.sevenDayTipFlag = false
				else
					self.recallInfoVO.sevenDayTipFlag = true
				end 
				self:flushToStorage()
				if stayForLevel then 
					return RecallRewardType.LEVEL_LONG
				else
					if currentStayLevel < self.configTopLevelId then 
						return RecallRewardType.AREA_LONG
					else
						return RecallManager.NO_REWARD
					end
				end
			end
		end
	end
	return RecallRewardType.NO_REWARD
end

--当召回奖励领取完  调用一下
function RecallManager:resetRecallRewardState()
	localReset = true
end

--设定从服务端获取的 玩家流失状态
function RecallManager:checkServerRewardState(recallRewardState)
	if not recallRewardState then 
		he_log_info("Warning:RecallManager******get nil recallRewardState from server")
		return RecallRewardType.NO_REWARD
	end
	for k,v in pairs(RecallRewardType) do
		if recallRewardState == v then 
			he_log_info("Debug:RecallManager******currentRewardState from server is == "..recallRewardState)
			return recallRewardState
		end
	end
	he_log_info("Error:RecallManager******recallRewardState from server is incorrect !!!")
	return RecallRewardType.NO_REWARD
end

--获取服务端返回的 玩家流失状态 以此状态为准
function RecallManager:getFinalRewardState()
	if localReset then 
		currentRewardState = RecallRewardType.NO_REWARD
	else
		currentRewardState = self:checkServerRewardState(UserManager:getInstance().lostType)
	end
	--currentRewardState = RecallRewardType.AREA_LONG
	he_log_info("RecallManager****currentRewardState=========>"..currentRewardState)
	return currentRewardState
end

--设定需要解锁的区域Id
function RecallManager:setNeedUnlockAreaId(lockedAreaId)
	needUnlockAreaId = lockedAreaId
end

--获取需要解锁的区域Id
function RecallManager:getNeedUnlockAreaId()
	return needUnlockAreaId
end

--获得10天卡关道具奖励
function RecallManager:getRecallItems()
	return {10057, 10026, 10027}
end

--获取3天或7天卡区任务关卡id  
function RecallManager:getAreTaskLevelId()
	--判定是否是最高关卡
	local levelId = UserManager:getInstance().user:getTopLevelId()
	local currentArea = math.floor(levelId/15)
	if currentArea < 1 then
		currentArea = 1 
	end
	if self:getFinalRewardState() == RecallRewardType.AREA_SHORT then 
		return (170002 + currentArea*2 - 1)
	else
		return (170002 + currentArea*2)
	end
end

--获取10天流失 卡关状态
function RecallManager:getRecallLevelState(levelId)
	return false
	-- if not levelId then return false end
	-- if self:getFinalRewardState() == RecallRewardType.LEVEL_LONG and levelId == UserManager:getInstance().user:getTopLevelId() then
	-- 	return true
	-- else
	-- 	return false
	-- end
end

function RecallManager:getLastLeaveTime()
	if self.recallInfoVO then
		return self.recallInfoVO.lastLeaveTime
	end
	return nil
end