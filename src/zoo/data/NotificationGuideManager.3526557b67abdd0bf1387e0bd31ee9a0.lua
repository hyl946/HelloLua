NotiGuideTriggerType = table.const{
	kEnergyZero = 1,		-- 精力
	kFriendEnergy = 2,		-- 送精力
	kFriendUnlock = 3,		-- 帮忙解锁
	kAskForHelp = 4,		-- 发送好友代打*
	kMarkChest = 5,			-- 签到完成后，若2天内可以领取签到最后大宝箱
	kUserCallBack = 6,		-- 领取完回流奖励，若第2天仍有回流奖励可领*
	kPassAllLevel = 7,		-- 当前版本最高关通关后
}

NotificationGuideManager = class()
local instance = nil

function NotificationGuideManager.getInstance()
	if not instance then
		instance = NotificationGuideManager.new()
		instance:init()
	end
	return instance
end

function NotificationGuideManager:init()
	self.hasTriggerTypeTable = {}
	self.lastTriggerTime = 0

	self.askForHelpNeedCheck = false

	self.maxLevel = 0
	self.maxLevel = tonumber(Cookie:getInstance():read(CookieKey.kMaxLevelNotificationGuide)) or 0

	local notificationReminder = UserManager.getInstance().notificationReminder or {}
	for k,v in pairs(notificationReminder) do
        local tm = tonumber(v.second)
		self.hasTriggerTypeTable[v.first] = tm
        if tm > self.lastTriggerTime then
            self.lastTriggerTime = tm
        end
	end
end

function NotificationGuideManager:isEnable()
	local isNotificationOpened = true
	if __ANDROID then
		pcall(function()
			local NotificationsUtils = luajava.bindClass("com.happyelements.android.utils.NotificationsUtils")
			local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder')
			local context = MainActivityHolder.ACTIVITY:getContext()
			
			isNotificationOpened = NotificationsUtils:isNotificationEnabled(context)
		end)
	elseif __IOS then
		isNotificationOpened = AnimalIosUtil:getNotiPermissionOpen()
	elseif __WIN32 then
		isNotificationOpened = false
	end

	return not isNotificationOpened
end

-- 类型是否开启
function NotificationGuideManager:checkType(triggerType)
	for k,v in pairs(NotiGuideTriggerType) do
		if triggerType == v then 
			return true
		end
	end
	return false
end

function NotificationGuideManager:checkTimeCanTrigger(nowTime)
	local oneDaySec = 86400000
	if self.lastTriggerTime + oneDaySec * 10 < nowTime then 
		return true
	end
	return false
end


function NotificationGuideManager:hasTriggered(triggerType)
	if UserManager.getInstance():hasNotifyData(triggerType) then 
		return true
	end
	return false
end

function NotificationGuideManager:checkTypeCanTrigger(triggerType)
	if not self:checkType(triggerType) then 
		return false
	end

	if self:hasTriggered(triggerType) then 
		return false
	end
	return true
end

function NotificationGuideManager:checkPassAllLevelCanTrigger(maxLevel)
	if maxLevel > self.maxLevel then 
		return true
	end
	return false
end

function NotificationGuideManager:setAskForHelpNeedCheck(val)
	local uid = UserManager:getInstance():getUID()
	CCUserDefault:sharedUserDefault():setBoolForKey("NotificationGuideManager.askForHelpNeedCheck" ..uid, val)
	self.askForHelpNeedCheck = val
end

function NotificationGuideManager:writeMaxLevel(maxLevel)
	Cookie:getInstance():write(CookieKey.kMaxLevelNotificationGuide, maxLevel)
end

function NotificationGuideManager:check(guideTriggerType, extraData)
	if guideTriggerType == NotiGuideTriggerType.kPassAllLevel then 
		if not self:checkPassAllLevelCanTrigger(extraData) then 
			return false
		end
	else
		if not self:checkTypeCanTrigger(guideTriggerType) then 
			return false
		end

		if not self:checkTimeCanTrigger(Localhost:time()) then 
			return false
		end
	end
	return true
end

function NotificationGuideManager:popoutIfNecessary(guideTriggerType, extraData)
	-- if not self:isEnable() then return end

	-- if not self:check(guideTriggerType, extraData) then return end

	-- if guideTriggerType == NotiGuideTriggerType.kAskForHelp then
	-- 	return self:setAskForHelpNeedCheck(true)
	-- end 

	-- if guideTriggerType == NotiGuideTriggerType.kPassAllLevel then
	-- 	self.maxLevel = extraData
	-- 	self:writeMaxLevel(extraData)
	-- end
	
	-- self:setAskForHelpNeedCheck(false)
	-- self:onNotified(guideTriggerType)
	
	-- require "zoo.panel.NotificationGuidePanel"
	-- NotificationGuidePanel:create(guideTriggerType):popout()
	
	Notify:dispatch("AutoPopoutEventAwakenAction", 
					NotificationGuidePopoutAction,
					{guideTriggerType= guideTriggerType, extraData = extraData})
end

function NotificationGuideManager:onNotified(eGuideTriggerType)
	local http = OpNotifyOffline.new(false)
	http:load(OpNotifyOfflineType.kAdviseOpenNotification, tostring(eGuideTriggerType))

	local tm = Localhost:time()
	if tm > self.lastTriggerTime then
		self.lastTriggerTime = tm
	end
	UserManager.getInstance():updateNotifyData(eGuideTriggerType, tm)
	Localhost:flushCurrentUserData()
end

function NotificationGuideManager:onEnter()
	if self.askForHelpNeedCheck and self:check(NotiGuideTriggerType.kAskForHelp) then
		
		self:onNotified(NotiGuideTriggerType.kAskForHelp)

		require "zoo.panel.NotificationGuidePanel"
		NotificationGuidePanel:create(NotiGuideTriggerType.kAskForHelp):popout()
		self:setAskForHelpNeedCheck(false)
	end
end