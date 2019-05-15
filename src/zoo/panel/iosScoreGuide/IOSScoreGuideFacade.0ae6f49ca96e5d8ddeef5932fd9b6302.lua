require "zoo.panel.iosScoreGuide.IOSScoreGuidePanel"



kUserLevelPhase = {
	kNone = 0,
	kPhase1 = 1,
	kPhase2 = 2,
	kPhase3 = 3,
	kPhase4 = 4,
	kPhase5 = 5,
	kPhase6 = 6,
	kPhase7 = 7,
	kPhase8 = 8,
	kPhase9 = 9,
}


kIOSScoreGuideData = {
	kToday = "iosscoreguide.today",		-- 最后一次通新关的日期
	kTodayPassLevelCount = "iosscoreguide.todayPassLevelCount", -- 最后一天通关次数
	kUserPhase = "iosscoreguide.phase", --用户处于的阶段
	kCloseTime = "iosscoreguide.closeTime", -- 主动关闭次数
	kReopenTimestamp = "iosscoreguide.reopenTimestamp", -- 重新开启该功能的时间戳
	kCurrentUserId = "iosscoreguide.userId", -- 当前登录的用户
	kReActivePrefix = "iosscoreguide.reactive", -- 是否已经重新激活本活动，当用户关闭3次本来应该再也不弹出，20160712修改需求为可以再重新激活
}


kPassLevelState = {
	kSuccess = 1,
	kFail = 2,
	kQuit = 3,
	kJump = 4,
}

kRequestReviewType = {
	kNoReview = 0,
	kInAppReview = 1,
	kGuideReview = 2,
}

IOSScoreGuideFacade = class()
-- -- 玩家处于的触发阶段
-- IOSScoreGuideFacade.phase = kUserLevelPhase.kNone
local instance = nil
function IOSScoreGuideFacade:getInstance()
	if instance == nil then instance = IOSScoreGuideFacade.new() end
	return instance
end

function IOSScoreGuideFacade:getScoreGuideData()
	if not self.scoreGuideData then
		self.scoreGuideData = IOSScoreGuideDataRef.new()
		local localData = Localhost.getInstance():readIOSScoreReviewData()
		if localData then
			self.scoreGuideData:decode(localData)
		end
		self:addGuideReviewDataUpdateListener()
		if _G.isLocalDevelopMode then RemoteDebug:uploadLogWithTag("getScoreGuideData", table.tostring(self.scoreGuideData:encode())) end
	end
	local year = os.date("*t").year
	if self.scoreGuideData.year ~= year then
		self.scoreGuideData:resetViewData()
		self.scoreGuideData.year = year
		Localhost.getInstance():writeIOSScoreReviewData(self.scoreGuideData:encode())
	end
	return self.scoreGuideData
end

function IOSScoreGuideFacade:addGuideReviewDataUpdateListener()
	local function onGuideReviewDataUpdate()
		self.scoreGuideData = nil
		self:getScoreGuideData()
	end
	GlobalEventDispatcher:getInstance():addEventListener("ios.guidereview.update", onGuideReviewDataUpdate)
end

function IOSScoreGuideFacade:flushScoreGuideData(dataRef)
	Localhost.getInstance():writeIOSScoreReviewData(dataRef:encode())
end

function IOSScoreGuideFacade:decideReviewType()
	local guideData = self:getScoreGuideData()
	local systemVersion = AppController:getSystemVersion() or 7
	local numVersion = tonumber(_G.bundleVersion:split(".")[2]) or 0

	if _G.isLocalDevelopMode then RemoteDebug:uploadLogWithTag("decideReviewType", table.tostring(guideData:encode())) end

	if numVersion - guideData.lastGuideVer <= 1 then -- 非跨版本
		return kRequestReviewType.kNoReview
	end
	if systemVersion >= 10.3 and guideData.lastGuideType ~= kRequestReviewType.kInAppReview and guideData.inAppReview < 3 then
		return kRequestReviewType.kInAppReview
	end
	return kRequestReviewType.kGuideReview
end

function IOSScoreGuideFacade:sendReviewNotify(reviewType)
	local guideData = self:getScoreGuideData()
	guideData.lastGuideType = reviewType
	guideData.lastGuideVer = tonumber(_G.bundleVersion:split(".")[2])
	if reviewType == kRequestReviewType.kInAppReview then
		guideData.inAppReview = guideData.inAppReview + 1
	elseif reviewType == kRequestReviewType.kInAppReview then
		guideData.guideReview = guideData.guideReview + 1
	end
	self:flushScoreGuideData(guideData)
	-- notify server
	local params = {
		udid = MetaInfo:getInstance():getUdid(),
		reviewType = reviewType,
	}
	local http = OpNotifyOffline.new()
	http:load(OpNotifyOfflineType.kiOSReview, table.serialize(params))
end

local __doRequestReview = nil
function IOSScoreGuideFacade:requestReview(reviewType)
	if self.isRequestingReview then return end
	local topLevel = UserManager:getInstance().user.topLevelId
	if reviewType == kRequestReviewType.kInAppReview then
		self.isRequestingReview = true
		local function doRequestReview()
			AppController:tryRequestReview()
			local showTime = self.scoreGuideData.inAppReview
			DcUtil:UserTrack({category = 'ios_review', sub_category = 'end', stage = topLevel, type = reviewType, times = showTime + 1})

			self:sendReviewNotify(reviewType)
			self.isRequestingReview = false
			if __doRequestReview then
				GlobalEventDispatcher:getInstance():removeEventListener(kGlobalEvents.kEnterHomeScene, __doRequestReview)
				__doRequestReview = nil
			end
		end
		if not PopoutManager:haveWindowOnScreen() then
			doRequestReview()
		else
			if __doRequestReview then
				GlobalEventDispatcher:getInstance():removeEventListener(kGlobalEvents.kEnterHomeScene, __doRequestReview)
				__doRequestReview = nil
			end
			__doRequestReview = doRequestReview
			GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kSceneNoPanel, __doRequestReview)
		end
	elseif reviewType == kRequestReviewType.kGuideReview then
		self.isRequestingReview = true
		local showTime = self.scoreGuideData.guideReview
		
		local function popoutPanel()
			local panel = IOSScoreGuidePanel:create(showTime+1)
			panel:popout()
			self:sendReviewNotify(reviewType)
			self.isRequestingReview = false
		end
		AsyncLoader:getInstance():waitingForLoadComplete(popoutPanel)
	end
end

function IOSScoreGuideFacade:isIgnoredForUser()
	if MaintenanceManager:getInstance():isEnabled("IOSScoreGuideOnlyGreaterMem", true) then
		local physicalMemory = NSProcessInfo:processInfo():physicalMemory() or 0
    	physicalMemory = physicalMemory / (1024 * 1024)
    	if physicalMemory < 2000 then return true end
	end

	local guideData = self:getScoreGuideData()
	local systemVersion = AppController:getSystemVersion() or 7
	local numVersion = tonumber(_G.bundleVersion:split(".")[2]) or 0
	if numVersion - guideData.lastGuideVer <= 0 then -- 非跨版本
		return true
	end

	if _G.isLocalDevelopMode then RemoteDebug:uploadLogWithTag("__isIgnoredForUser", self.oriCloseTime, self.oriReopenTimestamp) end
	if not self.oriCloseTime or not self.oriReopenTimestamp then
		-- 兼容老版本防打扰记录
		local config = CCUserDefault:sharedUserDefault()
		self.oriCloseTime = config:getIntegerForKey(kIOSScoreGuideData.kCloseTime)
		self.oriReopenTimestamp = tonumber(config:getStringForKey(kIOSScoreGuideData.kReopenTimestamp,"")) or 0
	end
	if self.oriCloseTime >= 3 or os.time() < self.oriReopenTimestamp then
		if _G.isLocalDevelopMode then RemoteDebug:uploadLogWithTag("isIgnoredForUser", self.oriCloseTime, self.oriReopenTimestamp) end
		return true
	end
	return false
end

function IOSScoreGuideFacade:calcUserPhase(topLevel)
	local phase = kUserLevelPhase.kNone
	if topLevel <= 40 then
		phase = kUserLevelPhase.kPhase1
	elseif 40 < topLevel and topLevel <= 100 then
		phase = kUserLevelPhase.kPhase2
	elseif 100 < topLevel and topLevel <= 300 then
		phase = kUserLevelPhase.kPhase3
	elseif 300 < topLevel then
		phase = kUserLevelPhase.kPhase4
	end
	return phase
end

function IOSScoreGuideFacade:init()
	self:checkReActive()

	-- if _G.isLocalDevelopMode then printx(0, "topLevel..........",UserManager:getInstance().user.topLevelId) end
	if (not self:isOpen()) then 
		return 
	end

	local config = CCUserDefault:sharedUserDefault()
	-- 计算今天日期
	local todayString = os.date("%Y-%m-%d")
	local lastdayString = config:getStringForKey(kIOSScoreGuideData.kToday)

	if (todayString ~= lastdayString) then
		-- 新的一天,清空次数
		config:setStringForKey(kIOSScoreGuideData.kToday,todayString)
		config:setIntegerForKey(kIOSScoreGuideData.kTodayPassLevelCount,0)
		config:setIntegerForKey(kIOSScoreGuideData.kUserPhase, -1)
		config:flush()
	end

	-- 计算用户阶段
	local userPhase = config:getIntegerForKey(kIOSScoreGuideData.kUserPhase,-1)
	self.phase = userPhase

	-- 已经存在用户阶段，不再改变
	if (userPhase > 0) then
		return 
	end

	if self.phase <= 0 then
		self.phase = self:calcUserPhase(UserManager:getInstance().user.topLevelId)
		config:setIntegerForKey(kIOSScoreGuideData.kUserPhase,self.phase)
		config:flush()
		if _G.isLocalDevelopMode then printx(0, "flush userPhase") end
	end
end

function IOSScoreGuideFacade:passLevel(levelId)
	if (not self:isOpen()) then 
		return 
	end

	if (not UserManager:getInstance().user) then 
		return
	end
	-- 首次通关才可以哦
	-- 0630 跳关也可以添加 JumpLevelLogic
	-- if _G.isLocalDevelopMode then printx(0, "passlevel",tonumber(levelId),UserManager:getInstance().user.topLevelId) end
	if (tonumber(levelId) < 10000 and tonumber(levelId) == tonumber(UserManager:getInstance().user.topLevelId)) then
		local config = CCUserDefault:sharedUserDefault()
		config:setIntegerForKey(kIOSScoreGuideData.kTodayPassLevelCount, config:getIntegerForKey(kIOSScoreGuideData.kTodayPassLevelCount, 0) + 1)
		config:flush()
	end
end

function IOSScoreGuideFacade:setPassLevelState(state)
	if (not self:isOpen()) then 
		return 
	end
	self.passLevelState = state
end

function IOSScoreGuideFacade:returnFromGamePlay()
	if (not self:isOpen()) then 
		return 
	end
	-- 必须是获胜才弹出哦
	if (self.passLevelState ~= kPassLevelState.kSuccess) then
		return
	end
	
	local config = CCUserDefault:sharedUserDefault()
	local passLevelCount = config:getIntegerForKey(kIOSScoreGuideData.kTodayPassLevelCount, 0)
	local pop = false
	local topLevel = UserManager:getInstance().user.topLevelId

	if (self.phase == kUserLevelPhase.kPhase1) then
		if topLevel == 23 then pop = true end
	elseif (self.phase == kUserLevelPhase.kPhase2) then
		if passLevelCount >= 4 then pop = true end
	elseif (self.phase == kUserLevelPhase.kPhase3) then
		if passLevelCount >= 3 then pop = true end
	elseif (self.phase == kUserLevelPhase.kPhase4) then
		if passLevelCount >= 2 then pop = true end
	end
	if _G.isLocalDevelopMode then RemoteDebug:uploadLogWithTag("returnFromGamePlay", pop, self.phase, passLevelCount) end
	if pop and ReachabilityUtil:isNetworkReachable() then
		local reviewType = self:decideReviewType()
		if reviewType and reviewType ~= kRequestReviewType.kNoReview then
			self:requestReview(reviewType)
		end
	end
end

-- 在当前基础上，设置重启该活动的时间戳
-- delta为秒
function IOSScoreGuideFacade:setReopenTimestamp(delta)
	-- local ts = os.time()+delta
	-- local config = CCUserDefault:sharedUserDefault()
	-- config:setStringForKey(kIOSScoreGuideData.kReopenTimestamp, tostring(ts))

	-- -- 清空用户阶段
	-- config:setIntegerForKey(kIOSScoreGuideData.kUserPhase,0)
	-- config:flush()
end

-- 设置关闭面板次数
function IOSScoreGuideFacade:setCloseTime(time)
	-- local config = CCUserDefault:sharedUserDefault()
	-- config:setIntegerForKey(kIOSScoreGuideData.kCloseTime,999)
	-- -- 清空用户阶段
	-- config:setIntegerForKey(kIOSScoreGuideData.kUserPhase,0)
	-- config:flush()
end

function  IOSScoreGuideFacade:checkReActive()
	if (not __IOS) then
		return
	end
	local config = CCUserDefault:sharedUserDefault()
	local reopenTimestamp = config:getIntegerForKey(kIOSScoreGuideData.kReopenTimestamp)
	if reopenTimestamp > 0 and os.time() > reopenTimestamp then -- 兼容原来的防打扰记录的用户数据(一次性)
		self:reActiveThisActivety(config)
	end
end

function IOSScoreGuideFacade:isAvailbleForUser(uid)
	uid = tonumber(uid)
	if not uid then return false end

	if not MaintenanceManager.getInstance():isEnabled("IOSScoreGuideNew", false) then
		return false
	end
	local mt = MaintenanceManager:getInstance():getMaintenanceByKey("IOSScoreGuideNew")
	local endNum = uid % 100
	for _, v in pairs(string.split(mt.extra or "", ",")) do
		local s2 = string.split(v, "-")
		local num1, num2 = -1, -1
		if #s2 > 0 then
			num1 = tonumber(s2[1])
			num2 = tonumber(s2[#s2])

			if num1 > num2 then num1, num2 = num2, num1 end
			if endNum >= num1 and endNum <= num2 then
				return true
			end
		end
	end
	return false
end

-- 该功能是否处于开启状态
function IOSScoreGuideFacade:isOpen()
	if (not __IOS) then
		return false
	end
	if self:isIgnoredForUser() then
		return false
	end
	if not self:isAvailbleForUser(UserManager:getInstance().uid) then
		return false
	end
	return true
end

-- 重置活动数据
function IOSScoreGuideFacade:reActiveThisActivety(config)
	config:setIntegerForKey(kIOSScoreGuideData.kTodayPassLevelCount,0)
	config:setIntegerForKey(kIOSScoreGuideData.kUserPhase,-1)
	config:setIntegerForKey(kIOSScoreGuideData.kCloseTime,0)
	config:setIntegerForKey(kIOSScoreGuideData.kReopenTimestamp, 0)
	config:flush()
	self.oriCloseTime = 0
	self.oriReopenTimestamp = 0
end
