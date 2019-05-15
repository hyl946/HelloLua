require "zoo.data.LocalNotificationUtil"

LocalNotificationType = {
	kEnergyFull = 1,
	kWeeklyRaceReward = 2,
	kMarkFinalReward = 3,
	kUnlockAskForHelp = 4,			--后端直接推送
	kUnlockGetHelp = 5,				--后端直接推送
	kBeyondFriendAtTopLevel = 6, 	--PushNotify 后端推送
	kLeaveForThree = 11,
	kLeaveForFive = 12,
	kLeaveForSeven = 13,
	kLadyBugMissionStart = 15,
	kLadyBugMissionEnd = 16,
	kSharePassFriendScore = 17,		--PushNotify 后端推送
	kSharePassFriendLevel = 18,		--PushNotify 后端推送
	kAskForEnergy = 19,				--后端直接推送
	kCallBackActivity = 20,			--后端直接推送
	kAnniversaryCakeFriend = 21,	--活动 后端直接推送
	kAnniversaryCakeFinish = 22,	--活动 前端本地推送
	kDragonBoatZongziFinish = 24,   --活动 前端包粽子直接完成
	kSummerShowOffPassFriend = 25,  --周赛 夏日周赛超越好友炫耀
	kSummerShareFinish = 26, 		--活动 前端冰淇淋完成推送
	kQiXiShareFinish = 27,          --活动 前端七夕情人节装扮完成推送
	kMidAutumnShare = 28,			--活动
	kPushEnergy     = 29,           -- 消息中心免费精力
	-- 30、31后端占用
	kNdShare2015	= 32,			--活动 国庆分享、感恩节分享
	kNdShare2015SendGift = 33,		--活动 国庆分享、感恩节分享
	kDengchaoEnergy = 34,           -- 邓超送精力
	kSpringShowOffPassFriend = 35,  --周赛 春季周赛超越好友炫耀
	kSpringFestival2016 = 36, 		--2016活动关卡 中午
	kSpringFestival2016_2 = 37,		--2016活动关卡 晚上
	kIosSalesProp = 38,				--IOS破冰道具促销 
	kIosSalesHappyCoin = 39,		--IOS破冰风车币促销
	kAndroidSalesProp = 40,				--ANDROID破冰道具促销 
	kAndroidSalesHappyCoin = 41,		--ANDROID破冰风车币促销
	kUserCallBack1 = 43, --回流用户连登录 领奖提示
	kUserCallBack2 = 44, --回流用户连登录 领奖提示
	kUserCallBack3 = 45, --回流用户连登录 领奖提示
	kSharePassNationScore = 50,
	kSharePassNationLevel = 51,
	kWeeklyShowOffPassNation = 52,
	kActivity1 = 53,				--活动会用到的推送1
	kActivity2 = 54,				--活动会用到的推送2 
	kNewLadyBugTask = 55,
	KAskForHelpReq = 57,			-- 请求好友代打
	KAskForHelpSuccess = 58,		-- 好友代打成功
	kNewUser = 61,					-- 新用户
	kGoldFruit = 62,					-- 金银果树——风车币
	kGiftPack1 = 63, --新手礼包
	kGiftPack2 = 64, --新手礼包
}

--由后端发起的推送 不需要在本地加优先级
LocalNotificationPriority = {
	[LocalNotificationType.kEnergyFull] 				= 100,
	[LocalNotificationType.kWeeklyRaceReward] 			= 31,
	[LocalNotificationType.kMarkFinalReward] 			= 51,
	[LocalNotificationType.kLeaveForThree] 				= 3,
	[LocalNotificationType.kLeaveForFive] 				= 2,
	[LocalNotificationType.kLeaveForSeven] 				= 1,
	[LocalNotificationType.kLadyBugMissionStart] 		= 41,
	[LocalNotificationType.kLadyBugMissionEnd] 			= 11,
	[LocalNotificationType.kNewLadyBugTask] 			= 12,
	[LocalNotificationType.kPushEnergy] 				= 61,			--这个就是天天推 万恶的小河马
	[LocalNotificationType.kIosSalesProp] 				= 71,
	[LocalNotificationType.kIosSalesHappyCoin] 			= 72,
	[LocalNotificationType.kActivity1] 					= 54,
	[LocalNotificationType.kActivity2] 					= 55,
	[LocalNotificationType.kGiftPack1] 					= 4,
	[LocalNotificationType.kGiftPack2] 					= 5,
}

--推送音效id 应和下面目录里的音效文件对应
--\local\trunk\engine\he.core\platform\android\gsp-android\project\res\raw
LocalNotificationVoice = table.const{
	[LocalNotificationType.kMarkFinalReward] 			= 1,
	-- [LocalNotificationType.kEnergyFull] 				= 1,
	-- [LocalNotificationType.kWeeklyRaceReward] 		= 2,
	-- [LocalNotificationType.kLeaveForThree] 			= 4,
	-- [LocalNotificationType.kLeaveForFive] 			= 5,
}

local MAX_NUM_PER_DAY = 100  
local function getDayStartTimeByTS(ts)
	local utc8TimeOffset = 57600 -- (24 - 8) * 3600
	local oneDaySeconds = 86400 -- 24 * 3600
	return ts - ((ts - utc8TimeOffset) % oneDaySeconds)
end

local LocalNotificationVO = class()

function LocalNotificationVO:ctor()
	self.typeId = nil
	self.timeStamp = nil
	self.body = nil
	self.action = nil
	self.labelType = nil
	self.isOpen = false
end

-- return isValid
function LocalNotificationVO:decode(src)
	self.typeId = tonumber(src.typeId)
	self.timeStamp = tonumber(src.timeStamp)
	self.body = tostring(src.body)
	self.action = tostring(src.action)
	self.labelType = tonumber(src.labelType) or 0

	if src.typeId and type(src.typeId) == "number"
		and src.timeStamp and type(src.timeStamp) == "number"
		and src.body and type(src.body) == "string"
		and src.action and type(src.action) == "string"
		then

		-- time validate, from 9:00 ~ 22:00 every day
		local dayStartTime = getDayStartTimeByTS(self.timeStamp)
		if self.timeStamp > dayStartTime + 7 * 3600 and self.timeStamp < dayStartTime + 22 * 3600 then
			return true
		end
	end

	return false
end

function LocalNotificationVO:toObject()
	return {typeId = self.typeId, timeStamp = self.timeStamp, body = self.body, action = self.action, labelType = self.labelType, isOpen = self.isOpen}
end

LocalNotificationManager = class()

local kStorageFileName = "notification"
local kLocalDataExt = ".ds"
local instance = nil

function LocalNotificationManager.getInstance()
	if not instance then
		instance = LocalNotificationManager.new()
		instance:init()
	end
	return instance
end

function LocalNotificationManager:init()

	self:parseRawConfig(MetaManager:getInstance().local_notification)

	self.mapByDay = {}
	
	local path = HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName .. kLocalDataExt
	local file, err = io.open(path, "r")

	if file and not err then
		local content = file:read("*a")
		io.close(file)

        local fields = nil
        local function decodeContent()
            fields = amf3.decode(content)
        end
        pcall(decodeContent)

		if fields and type(fields) == "table" and #fields > 0 then
			for i, v in ipairs(fields) do
				local vo = LocalNotificationVO.new()	
				if vo:decode(v) then 
					self:_addNotifyVO(vo, true)
				end
			end
		end
	end
end

function LocalNotificationManager:getNotifyLabel(keyPre, typeNum)
	typeNum = tonumber(typeNum)
	if not typeNum or typeNum < 2 then 
		return keyPre , 0
	end

	local uid = UserManager.getInstance().user.uid or "0"
	local uidLast = tonumber(string.sub(tostring(uid), -1)) or 0
	local keyLast = (uidLast % typeNum) + 1
	local finalKey = keyPre .. keyLast
	return finalKey, keyLast
end

function LocalNotificationManager:_addNotifyVO(notifyVO, notNeedDC)
	if notifyVO.timeStamp <= os.time() then 
		return 
	end

	local day = getDayStartTimeByTS(notifyVO.timeStamp)
	if not self.mapByDay[day] then
		self.mapByDay[day] = {}
	end

	notifyVO.isOpen = true
	table.insert(self.mapByDay[day], notifyVO)
	self:reorderNotify(day, notifyVO, notNeedDC)
end

function LocalNotificationManager:reorderNotify(dayKey, notifyVO, notNeedDC)
	local function sortFunc(notiVo1, notiVo2)
		local order1 = LocalNotificationPriority[notiVo1.typeId]
		local order2 = LocalNotificationPriority[notiVo2.typeId]
		if notiVo1.typeId > 1000 and order1 ==nil then
			order1 = LocalNotificationPriority[ LocalNotificationType.kActivity1 ]
		end
		if notiVo2.typeId > 1000 and order2 ==nil then
			order2 = LocalNotificationPriority[ LocalNotificationType.kActivity1 ]
		end

		if order1 and order2 then 
			return order1<order2
		else
			return false
		end
	end
	if #self.mapByDay[dayKey]>MAX_NUM_PER_DAY then 
		local tempTable = self.mapByDay[dayKey]
		table.sort(tempTable, sortFunc)
		self.mapByDay[dayKey] = {}
		for i,v in ipairs(tempTable) do
			if i <= MAX_NUM_PER_DAY then
				table.insert(self.mapByDay[dayKey], v)
			end
		end
	end
end

function LocalNotificationManager:getConfigByType(typeId)

	for k, v in pairs(self.config) do
		if v.typeId == typeId then
			return v
		end
	end
	return nil
end

function LocalNotificationManager:parseRawConfig(config)
	local function parseSingleEntry(entry)
		local uid_configs = {}
		if entry.uids then
			local parts = string.split(entry.uids, '#')
			for i=1, #parts do
				local v = parts[i]
				if v then
					local uids = string.split(v, ':')
					table.insert(uid_configs, {min = tonumber(uids[1]), max = tonumber(uids[2])})
				end
			end
		end
		local uid_count = #uid_configs

		local text_count = 0
		local texts = {}
		for i=1, 3 do
			if entry['text'..tostring(i)] then
				text_count = text_count + 1
				table.insert(texts, entry['text'..tostring(i)])
			end
		end
		local actions = {}
		for i=1, 3 do
			if entry['action'..tostring(i)] then
				table.insert(actions, entry['action'..tostring(i)])
			end
		end
		local ret = {}
		ret.id = tonumber(entry.id)
		ret.typeId = tonumber(entry.typeId)
		ret.texts = texts
		ret.text_count = text_count
		ret.uids = uid_configs
		ret.uid_count = uid_count
		ret.actions = actions
		ret.ver = tonumber(entry.ver) or 0
		if (text_count ~= #actions) then
			assert(false, '配置错误')
			-- debug.debug()
		end
		return ret
	end
	local new_config = {}
	for k, v in pairs(config) do
		local parsed_entry = parseSingleEntry(v)
		table.insert(new_config, parsed_entry)
	end
	table.sort(new_config, function(v1, v2) return v1.id < v2.id end)
	self.config = new_config
end

function LocalNotificationManager:addNotifyFromConfig(typeId, timeStamp, noIO)
	local config = self:getConfigByType(typeId)
	if not config then 
		assert(false, '缺配置')
		return 
	end

	local ver = config.ver or 0
	local my_uid = tonumber(UserManager:getInstance().user.uid or '12345')
	if not my_uid then my_uid = 0 end
	my_uid = my_uid % 10000 -- 保留后4位
	local body, action, labelType
	if config.text_count == 1 then
		if config.uid_count == 0 then
			-- 所有玩家，同一个文案
			assert(config.texts[1], tostring(typeId) .. '配置错')
			body = config.texts[1]
			action = config.actions[1]
			labelType = 1
		elseif config.uid_count <= 3 then
			-- 玩家分段，同一个文案
			local index = 0
			for k, v in pairs(config.uids) do
				if my_uid >= v.min and my_uid <= v.max then
					index = k
					break
				end
			end
			if index > 0 then
				body = config.texts[1]
				action = config.actions[1]
				labelType = index
			end
		else
			assert(false, tostring(typeId) .. '配置错')
		end
	elseif config.text_count > 1 then
		if config.uid_count == 0 then
			-- 所有玩家，随机文案
			local index = math.random(1, config.text_count)
			body = config.texts[index]
			action = config.actions[index]
			labelType = index

		elseif config.text_count == config.uid_count then
			-- 按尾号段区分文案
			local index = 0
			for k, v in pairs(config.uids) do
				if my_uid >= v.min and my_uid <= v.max then
					index = k
					break
				end
			end

			if index > 0 then
				body = config.texts[index]
				action = config.actions[index]
				labelType = index
			end
		else
			assert(false, tostring(typeId) .. '配置错')
		end
	end
	-- 
	if body and action and labelType then
		self:addNotify(typeId, timeStamp, body, action, ver*100 + labelType, noIO)
	end
end

function LocalNotificationManager:addNotify(typeId, date, body, action, labelType, noIO)
	local vo = LocalNotificationVO.new()	
	local val = { typeId = typeId, timeStamp = date, body = body, action = action, labelType = labelType }
	if vo:decode(val) then 
		self:_addNotifyVO(vo)
	end

	if not noIO then 
		self:flushToStorage()
	end
end

function LocalNotificationManager:deleteNotify(notifyVO)
	local dayStartTS = getDayStartTimeByTS(notifyVO.timeStamp)
	local dayList = self.mapByDay[dayStartTS]
	if dayList then
		local newList = {}
		for i, vo in ipairs(dayList) do
			if vo.typeId == notifyVO.typeId and vo.timeStamp == notifyVO.timeStamp then 
				DcUtil:sendLocalNotify(vo.typeId, vo.timeStamp, -1)
				self:cancelSingleAndroidNotification(vo)
			else
				table.insert(newList, vo)
			end
		end
		if #newList > 0 then 
			self.mapByDay[dayStartTS] = newList
		else
			self.mapByDay[dayStartTS] = nil
		end
	end
end

function LocalNotificationManager:getNotiListByDay(ts)
	local dayStartTS = getDayStartTimeByTS(ts)
	if self.mapByDay and self.mapByDay[dayStartTS] then
		return self.mapByDay[dayStartTS]
	end
end

function LocalNotificationManager:getNotiByDayAndType(dayStartTS, typeId)
	local tempList = self:getNotiListByDay(dayStartTS)
	if not tempList then return nil end
	for i, vo in ipairs(tempList) do
		if vo.typeId == typeId then
			return vo
		end
	end
end

function LocalNotificationManager:getNotiByType(typeId)
	local sameTypeNoti = {}
	for _, notiList in pairs(self.mapByDay) do
		for i, vo in ipairs(notiList) do
			if vo.typeId == typeId then
				table.insert(sameTypeNoti, vo)
			end
		end
	end
	return sameTypeNoti
end

function LocalNotificationManager:pushAllNotifications()
	if _G.isLocalDevelopMode then printx(0, "pushAllNotifications") end
	for _, notiList in pairs(self.mapByDay) do
		for i, vo in ipairs(notiList) do
			local timeOffset = vo.timeStamp - os.time()
			if _G.isLocalDevelopMode then printx(0, "pushSingleNotification typeId: " .. vo.typeId .. " timeOffset: " .. timeOffset) end
			self:pushSingleNotification(timeOffset, vo.action, vo.body, vo.typeId, vo.timeStamp, vo.labelType)
		end
	end
end

local notificationUtil = nil
function LocalNotificationManager:pushSingleNotification(timeOffset, action, body, typeId, timeStamp, labelType)
	if __ANDROID and not notificationUtil then
		if PrepackageUtil:isPreNoNetWork() then return end
		notificationUtil = luajava.bindClass("com.happyelements.hellolua.share.NotificationUtil")
	end
	
	local bodyFinal = LocalNotificationUtil.getInstance():convertStr(body)
	if __IOS then			
		local alertId = self:getAndroidAlarmId(typeId, timeStamp)
		local voiceId = self:getNotiVoiceId(typeId)
		labelType = tostring(labelType) or "0"
		WeChatProxy:scheduleLocalNotification_alertBody_alertAction_alertId_voiceId_labelType(timeOffset, bodyFinal, action, alertId, voiceId, labelType)
	end
	if __ANDROID then
		-- use alarmId to ensure every piece of alarm will work, otherwise just the last one work
		local function addLocal()
			local alarmId = self:getAndroidAlarmId(typeId, timeStamp)
			local voiceId = self:getNotiVoiceId(typeId)
			notificationUtil:addLocalNotification(timeOffset, bodyFinal, alarmId, voiceId, labelType)
		end
		pcall(addLocal)
	end
	if __WP8 then
		Wp8Utils:scheduleLocalNotification(timeOffset, action, bodyFinal)
	end
end

function LocalNotificationManager:getNotiVoiceId(typeId)
	for k,v in pairs(LocalNotificationVoice) do
		if typeId == k then 
			return v
		end
	end
	return 0	
end

function LocalNotificationManager:getAndroidAlarmId(typeId, timeStamp)
	return typeId .. ":" .. timeStamp
end

function LocalNotificationManager:cancelSingleAndroidNotification(notifyVO)
	if __ANDROID and not notificationUtil then
		if PrepackageUtil:isPreNoNetWork() then return end
		notificationUtil = luajava.bindClass("com.happyelements.hellolua.share.NotificationUtil")
	end
	if __ANDROID then
		local function cancelLocal()
			local alarmId = self:getAndroidAlarmId(notifyVO.typeId, notifyVO.timeStamp)
			notificationUtil:cancelLocalNotification(alarmId)
		end
		pcall(cancelLocal)
	end
end

function LocalNotificationManager:cancelAllAndroidNotification()
	--这里是取消安卓的推送 并没有清理本地的数据 数据方面各功能根据需求自行维护
	if __ANDROID and not notificationUtil then
		if PrepackageUtil:isPreNoNetWork() then return end
		notificationUtil = luajava.bindClass("com.happyelements.hellolua.share.NotificationUtil")
	end
	if __ANDROID then
		for _, notiList in pairs(self.mapByDay) do
			for i, vo in ipairs(notiList) do
				self:cancelSingleAndroidNotification(vo)
			end
		end
	end

	--精力的推送没别的要求 清数据取消的操作放这就行
	LocalNotificationManager.getInstance():cancelEnergyFullNotification()
end

function LocalNotificationManager:validateNotificationTime()
	local now = os.time()
	for day, notiList in pairs(self.mapByDay) do
		local newList = {}
		for i, vo in ipairs(notiList) do
			if vo.timeStamp > now then
				table.insert(newList, vo)
			else
				DcUtil:sendLocalNotify(vo.typeId, vo.timeStamp, -1)
				self:cancelSingleAndroidNotification(vo)
			end
		end
		if #newList > 0 then 
			self.mapByDay[day] = newList
		else
			self.mapByDay[day] = nil
		end
	end
	self:flushToStorage()
end

function LocalNotificationManager:flushToStorage()
	local notiList = {}
	for _, unit in pairs(self.mapByDay) do
		for i, notiVO in ipairs(unit) do
			table.insert(notiList, notiVO:toObject())
		end
	end

	local content = amf3.encode(notiList)
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
        if _G.isLocalDevelopMode then printx(0, "write file failure " .. filePath) end
    end
end

function LocalNotificationManager:setMarkRewardNotification(leftDay)
	assert(leftDay == 1 or leftDay == 2)
	self:cancelAllMarkNotification()

	local todayTime = getDayStartTimeByTS(os.time())
	if leftDay >= 1 then
		local tomorrowTS = todayTime + 24 * 3600 + 12 * 3600 + math.random(60 * 60) - 30 * 60
		if _G.isLocalDevelopMode then printx(0, "setMarkRewardNotification leftDay 1 " .. tomorrowTS) end
		if not self:getNotiByDayAndType(tomorrowTS, LocalNotificationType.kMarkFinalReward) then
			if _G.isLocalDevelopMode then printx(0, "addNotify leftDay 1", tomorrowTS) end
			self:addNotifyFromConfig(LocalNotificationType.kMarkFinalReward, tomorrowTS)
		end
	end

	if leftDay >= 2 then
		local dayAfterTomorrowTS = todayTime + 48 * 3600 + 12 * 3600 + math.random(60 * 60) - 30 * 60
		if _G.isLocalDevelopMode then printx(0, "setMarkRewardNotification leftDay 2 " .. dayAfterTomorrowTS) end
		if not self:getNotiByDayAndType(dayAfterTomorrowTS, LocalNotificationType.kMarkFinalReward) then
			if _G.isLocalDevelopMode then printx(0, "addNotify leftDay 2", dayAfterTomorrowTS) end
			self:addNotifyFromConfig(LocalNotificationType.kMarkFinalReward, dayAfterTomorrowTS)	
		end
	end
end

function LocalNotificationManager:cancelMarkNotificationToday(dayToCancel)
	local todayTime = os.time()
	local tomorrowTime = todayTime + 24 * 3600
	local dayAfterTomorrowTime = tomorrowTime + 24 * 3600

	local cancelVOList = {}
	local todayVO = self:getNotiByDayAndType(todayTime, LocalNotificationType.kMarkFinalReward)
	table.insert(cancelVOList, todayVO)
	if dayToCancel then
		if dayToCancel[1] then
			local tomorrowVO = self:getNotiByDayAndType(tomorrowTime, LocalNotificationType.kMarkFinalReward)
			table.insert(cancelVOList, tomorrowVO)
		end
		if dayToCancel[2] then
			local dayAfterTomorrowVO = self:getNotiByDayAndType(dayAfterTomorrowTime, LocalNotificationType.kMarkFinalReward)
			table.insert(cancelVOList, dayAfterTomorrowVO)
		end
	end

	for i, vo in ipairs(cancelVOList) do
		if vo then
			self:deleteNotify(vo)
			self:flushToStorage()
		end
	end
end

function LocalNotificationManager:cancelAllMarkNotification()
	local sameTypeNoti = self:getNotiByType(LocalNotificationType.kMarkFinalReward)
	if #sameTypeNoti > 0 then
		for i,v in ipairs(sameTypeNoti) do
			self:deleteNotify(v)
		end
		self:flushToStorage()
	end
end


-- 删除了 since 1.51
function LocalNotificationManager:setWeeklyRaceRewardNotification()
	-- self:cancelWeeklyRaceRewardNotification()

	-- local function getWeekDay()
	-- 	local wday = tonumber(os.date("%w"))
	-- 	if wday == 0 then
	-- 		return 7
	-- 	end
	-- 	return wday
	-- end
	-- local now = os.time()
	-- local weekDay = getWeekDay()
	-- local startTimeOnToday = getDayStartTimeByTS(now)
	-- local startTimeOnThisWeek = startTimeOnToday - (weekDay - 1) * 24 * 3600
	-- local targetTime = startTimeOnThisWeek + 7 * 24 * 3600 + 10 * 3600 + math.random(60 * 60) - 30 * 60
	-- if _G.isLocalDevelopMode then printx(0, "setWeeklyRaceRewardNotification " .. targetTime) end

	-- if not self:getNotiByDayAndType(targetTime, LocalNotificationType.kWeeklyRaceReward) then
	-- 	self:addNotifyFromConfig(LocalNotificationType.kWeeklyRaceReward, targetTime)
	-- end
end

function LocalNotificationManager:cancelWeeklyRaceRewardNotification()
	-- local sameTypeNoti = self:getNotiByType(LocalNotificationType.kWeeklyRaceReward)
	-- if #sameTypeNoti > 0 then
	-- 	for i,v in ipairs(sameTypeNoti) do
	-- 		self:deleteNotify(v)
	-- 	end
	-- 	self:flushToStorage()
	-- end
end

function LocalNotificationManager:setTestNotification()
	local now = os.time()
	local ts1 = now + 20
	local ts2 = now + 120
	-- self:addNotify(LocalNotificationType.kLeaveForFive, ts1, "test notification 1", "action")
	-- self:addNotify(LocalNotificationType.kWeeklyRaceReward, ts2, "testnotification2", "action")

	-- notificationUtil = luajava.bindClass("com.happyelements.hellolua.share.NotificationUtil")
	-- notificationUtil:addLocalNotification(15,"test","100:1246546456464", 2, 1)
	-- self:addNotifyFromConfig(LocalNotificationType.kMarkFinalReward, tomorrowTS)
	self:addNotifyFromConfig(LocalNotificationType.kMarkFinalReward, ts1)
	for _, notiList in pairs(self.mapByDay) do
		for i, vo in ipairs(notiList) do
			local timeOffset = vo.timeStamp - os.time()
			self:pushSingleNotification(timeOffset, vo.action, vo.body, vo.typeId, vo.timeStamp, vo.labelType)
			CommonTip:showTip(string.format("type:%d,t:%ds,id:%d", vo.typeId, timeOffset, vo.labelType), "positive")
		end
	end

	-- local now = 1416130560
	-- local weekDay = tonumber(os.date("%w"))
	-- local startTimeOnToday = getDayStartTimeByTS(now)
	-- local startTimeOnThisWeek = startTimeOnToday - (weekDay - 1) * 24 * 3600
	-- local targetTime = startTimeOnThisWeek + 7 * 24 * 3600 + 10 * 3600
end

---- server pushNotify
local passLevelCache = {}
function LocalNotificationManager:setPassLevelFlag(levelId, star, score)
	if star < 1 or not LevelType:isMainLevel(levelId) then
		passLevelCache = {}
		return
	end
	passLevelCache.levelId = levelId
	passLevelCache.star = star
	passLevelCache.score = score
end

local function now()
	return os.time() + (__g_utcDiffSeconds or 0)
end

-- function LocalNotificationManager:sendBeyondFriendsNotification(levelId, friendRankList)
-- 	local maxNormalLevelId = MetaManager.getInstance():getMaxNormalLevelByLevelArea()
-- 	local friendUserVOList = FriendManager.getInstance().friends
-- 	local selfUId = UserManager:getInstance().user.uid

-- 	local friendRankMap = {}
-- 	local selfRankIndex = nil
-- 	local selfScore = nil
-- 	for rank, user in ipairs(friendRankList) do
-- 		if user.uid == selfUId then 
-- 			selfRankIndex = rank 
-- 			selfScore = user.score
-- 		end
-- 		friendRankMap[user.uid] = rank
-- 	end

-- 	if passLevelCache and (passLevelCache.levelId ~= levelId or passLevelCache.score ~= selfScore) then
-- 		passLevelCache = {}
-- 		return
-- 	end
-- 	passLevelCache = {}
-- 	if not selfRankIndex then return end

-- 	local friendsAtTopLevel = {}
-- 	for uid, vo in pairs(friendUserVOList) do
-- 		if vo:getTopLevelId() == maxNormalLevelId then
-- 			table.insert(friendsAtTopLevel, vo)
-- 		end
-- 	end

-- 	if #friendsAtTopLevel > 0 then
-- 		local result = {}
-- 		for i, v in ipairs(friendsAtTopLevel) do
-- 			local friendRank = friendRankMap[v.uid]
-- 			if friendRank and type(friendRank) == "number" and friendRank > selfRankIndex then
-- 				table.insert(result, v.uid)
-- 			end
-- 		end

-- 		if #result > 0 then
-- 			local msg = Localization:getInstance():getText("push.surpass.text", {num = levelId})
-- 			local targetTime = now()
-- 			-- local now = os.time()
-- 			-- local dayStartTime = getDayStartTimeByTS(now)
-- 			-- if now > dayStartTime + 10 * 3600 then
-- 			-- 	targetTime = dayStartTime + 24 * 3600 + 10 * 3600
-- 			-- else
-- 			-- 	targetTime = dayStartTime + 10 * 3600
-- 			-- end
-- 			local http = PushNotifyHttp.new()
-- 			http:load(result, msg, LocalNotificationType.kBeyondFriendAtTopLevel, targetTime * 1000)
-- 		end
-- 	end
-- end

function LocalNotificationManager:setLeaveNotification(leaveType)
	if RecallManager.getInstance():getLevelStayState() then 
		local todayTime = getDayStartTimeByTS(os.time())
		local timeDelta = 12 * 3600 + math.random(60 * 60) - 30 * 60
		local timeForOneDay = 24 * 3600
		local timeStamp = nil
		local textToShow = nil
		local threeDayTipFlag,sevenDayTipFlag = RecallManager.getInstance():getRecallNotifyTipState()
		local stayForLevel = true
		local currentStayLevel = UserManager:getInstance().user:getTopLevelId()
		if currentStayLevel%15==0 then 
			local scoreOfLevel = UserManager.getInstance():getUserScore(currentStayLevel)
			if scoreOfLevel then
				if scoreOfLevel.star ~= 0 or UserManager.getInstance():hasPassedByTrick(currentStayLevel) then 
					stayForLevel = false
				end
			end
		end
		if leaveType == LocalNotificationType.kLeaveForThree then
			timeStamp = todayTime + 3 * timeForOneDay + timeDelta
			if threeDayTipFlag then 
				if stayForLevel then 
					textToShow = "notification_recall_checkpoint_day3_1" 
				else
					textToShow = "notification_recall_area_day3_1"
				end
			else
				if stayForLevel then 
					textToShow = "notification_recall_checkpoint_day3_2" 
				else
					textToShow = "notification_recall_area_day3_2"
				end
			end
		elseif leaveType == LocalNotificationType.kLeaveForFive then
			timeStamp = todayTime + 7 * timeForOneDay + timeDelta
			if stayForLevel then 
				textToShow = "notification_recall_checkpoint_day5" 
			else
				textToShow = "notification_recall_area_day5"
			end
		elseif leaveType == LocalNotificationType.kLeaveForSeven then 
			timeStamp = todayTime + 10 * timeForOneDay + timeDelta
			if sevenDayTipFlag then 
				if stayForLevel then 
					textToShow = "notification_recall_checkpoint_day7_1" 
				else
					textToShow = "notification_recall_area_day7_1"
				end
			else
				if stayForLevel then 
					textToShow = "notification_recall_checkpoint_day7_2" 
				else
					textToShow = "notification_recall_area_day7_2"
				end
			end
		end

		if timeStamp then 
			if not self:getNotiByDayAndType(timeStamp, leaveType) then
				he_log_info("LocalNotificationManager*****timeStamp==="..timeStamp.."   leaveType==="..leaveType)
				local labelKey, labelType = self:getNotifyLabel(textToShow)
				self:addNotify(leaveType, timeStamp, 
					Localization:getInstance():getText(labelKey), 
					Localization:getInstance():getText("push.prompt.view.details"), labelType)	
			end
		end
	end
end

function LocalNotificationManager:cancelLeaveNotification(leaveType)
	local sameTypeNoti = self:getNotiByType(leaveType)
	if #sameTypeNoti > 0 then
		for i,v in ipairs(sameTypeNoti) do
			self:deleteNotify(v)
		end
		self:flushToStorage()
	end
end

function LocalNotificationManager:setAllLeaveNotification()
	self:cancelAllLeaveNotification()
	self:setLeaveNotification(LocalNotificationType.kLeaveForThree)
	self:setLeaveNotification(LocalNotificationType.kLeaveForFive)
	self:setLeaveNotification(LocalNotificationType.kLeaveForSeven)
end

function LocalNotificationManager:cancelAllLeaveNotification()
	self:cancelLeaveNotification(LocalNotificationType.kLeaveForThree)
	self:cancelLeaveNotification(LocalNotificationType.kLeaveForFive)
	self:cancelLeaveNotification(LocalNotificationType.kLeaveForSeven)
end

function LocalNotificationManager:pocessRecallNotification()
	--这个参数从配置读取
	local needRecallNotify = MaintenanceManager:getInstance():isEnabled("RecallNotify");
	if needRecallNotify then 
		he_log_info("LocalNotificationManager********setAllLeaveNotification()")
		self:setAllLeaveNotification()
	else
		he_log_info("LocalNotificationManager********cancelAllLeaveNotification()")
		self:cancelAllLeaveNotification()
	end
end


-- 删除 since 1.51
function LocalNotificationManager:setLadyBugMissionNotification(startTime, taskNum)
	-- if type(startTime) ~= "number" then return end
	-- self:cancelAllLadyBugMissionNotification()
	
	-- startTime = getDayStartTimeByTS(startTime / 1000)
	
	-- local needIO = false 
	-- for i = 1, taskNum do
	-- 	local start = startTime + (i - 1) * 86400 + 9 * 3600 + math.random(60 * 60)
	-- 	local finish = startTime + (i - 1) * 86400 + 20 * 3600 + math.random(60 * 60) - 30 * 60
	-- 	if i ~= 1 then
	-- 		if not self:getNotiByDayAndType(start, LocalNotificationType.kLadyBugMissionStart) then
	-- 			needIO = true
	-- 			self:addNotifyFromConfig(LocalNotificationType.kLadyBugMissionStart, start)
	-- 		end
	-- 	end

	-- 	if not self:getNotiByDayAndType(finish, LocalNotificationType.kLadyBugMissionEnd) then
	-- 		needIO = true
	-- 		self:addNotifyFromConfig(LocalNotificationType.kLadyBugMissionEnd, finish)
	-- 	end
	-- end

	-- --写入操作放在循环后统一做
	-- if needIO then 
	-- 	self:flushToStorage()
	-- end
end

-- 删除 since 1.51
function LocalNotificationManager:cancelLadyBugMissionNotificationToday()
	-- local now = os.time()
	-- local vo = self:getNotiByDayAndType(now, LocalNotificationType.kLadyBugMissionStart)
	-- if vo then
	-- 	self:deleteNotify(vo)
	-- 	self:flushToStorage()
	-- end
	-- vo = self:getNotiByDayAndType(now, LocalNotificationType.kLadyBugMissionEnd)
	-- if vo then
	-- 	self:deleteNotify(vo)
	-- 	self:flushToStorage()
	-- end
end

-- 删除 since 1.51
function LocalNotificationManager:cancelAllLadyBugMissionNotification()
	-- local sameTypeNoti = self:getNotiByType(LocalNotificationType.kLadyBugMissionStart)
	-- if #sameTypeNoti > 0 then
	-- 	for i,v in ipairs(sameTypeNoti) do
	-- 		self:deleteNotify(v)
	-- 	end
	-- 	self:flushToStorage()
	-- end

	-- sameTypeNoti = self:getNotiByType(LocalNotificationType.kLadyBugMissionEnd)
	-- if #sameTypeNoti > 0 then
	-- 	for i,v in ipairs(sameTypeNoti) do
	-- 		self:deleteNotify(v)
	-- 	end
	-- 	self:flushToStorage()
	-- end
end

function LocalNotificationManager:setIosSalesPromotionNoti(promotionType, notiTime)
	if type(notiTime) ~= "number" then return end

	if promotionType == IosOneYuanPromotionType.OneYuanFCash then 
		if not self:getNotiByDayAndType(notiTime, LocalNotificationType.kIosSalesHappyCoin) then
			self:addNotifyFromConfig(LocalNotificationType.kIosSalesHappyCoin, notiTime)
		end
	else
		if not self:getNotiByDayAndType(notiTime, LocalNotificationType.kIosSalesProp) then
			self:addNotifyFromConfig(LocalNotificationType.kIosSalesProp, notiTime)
		end
	end
end

function LocalNotificationManager:cancelAllIosSalesPromotion()
	local sameTypeNoti = self:getNotiByType(LocalNotificationType.kIosSalesProp)
	if #sameTypeNoti > 0 then
		for i,v in ipairs(sameTypeNoti) do
			self:deleteNotify(v)
		end
		self:flushToStorage()
	end

	sameTypeNoti = self:getNotiByType(LocalNotificationType.kIosSalesHappyCoin)
	if #sameTypeNoti > 0 then
		for i,v in ipairs(sameTypeNoti) do
			self:deleteNotify(v)
		end
		self:flushToStorage()
	end
end

function LocalNotificationManager:setAndroidSalesPromotionNoti(promotionType, notiTime)
	if type(notiTime) ~= "number" then return end

	if promotionType == AndroidSalesPromotionType.GoldSales then 
		if not self:getNotiByDayAndType(notiTime, LocalNotificationType.kAndroidSalesHappyCoin) then
			self:addNotifyFromConfig(LocalNotificationType.kAndroidSalesHappyCoin, notiTime)
		end
	else
		if not self:getNotiByDayAndType(notiTime, LocalNotificationType.kAndroidSalesProp) then
			self:addNotifyFromConfig(LocalNotificationType.kAndroidSalesProp, notiTime)
		end
	end
end

function LocalNotificationManager:cancelAllAndroidSalesPromotion()
	local sameTypeNoti = self:getNotiByType(LocalNotificationType.kAndroidSalesProp)
	if #sameTypeNoti > 0 then
		for i,v in ipairs(sameTypeNoti) do
			self:deleteNotify(v)
		end
		self:flushToStorage()
	end

	sameTypeNoti = self:getNotiByType(LocalNotificationType.kAndroidSalesHappyCoin)
	if #sameTypeNoti > 0 then
		for i,v in ipairs(sameTypeNoti) do
			self:deleteNotify(v)
		end
		self:flushToStorage()
	end
end

function LocalNotificationManager:setEnergyFullNotification()
	local enable = CCUserDefault:sharedUserDefault():getBoolForKey("game.local.notification")
	if _G.isLocalDevelopMode then printx(0, "setEnergyFullNotification enter--->enable==", enable) end
	local fullEnergyTimeOff = UserService:getInstance():computeFullEnergyTime()
	if enable and fullEnergyTimeOff > 0 then 
		local targetTime = os.time() + fullEnergyTimeOff
		if _G.isLocalDevelopMode then printx(0, "setEnergyFullNotification--->targetTime==" .. targetTime) end

		if not self:getNotiByDayAndType(targetTime, LocalNotificationType.kEnergyFull) then
			-- local labelKey, labelType = self:getNotifyLabel("message.center.notif.goback", 3)
			self:addNotifyFromConfig(LocalNotificationType.kEnergyFull, targetTime)
		end
	end
end

function LocalNotificationManager:cancelEnergyFullNotification()
	local sameTypeNoti = self:getNotiByType(LocalNotificationType.kEnergyFull)
	if #sameTypeNoti > 0 then
		for i,v in ipairs(sameTypeNoti) do
			self:deleteNotify(v)
		end
		self:flushToStorage()
	end
end

function LocalNotificationManager:setActivityNoti1(notiTime, title, content)
	if not self:getNotiByDayAndType(notiTime, LocalNotificationType.kActivity1) then
		local labelType = 0
		self:addNotify(LocalNotificationType.kActivity1, notiTime, title, content, labelType)
	end
end

function LocalNotificationManager:cancelActivityNoti1()
	local sameTypeNoti = self:getNotiByType(LocalNotificationType.kActivity1)
	if #sameTypeNoti > 0 then
		for i,v in ipairs(sameTypeNoti) do
			self:deleteNotify(v)
		end
		self:flushToStorage()
	end
end

function LocalNotificationManager:setActivityNoti2(notiTime, title, content)
	if not self:getNotiByDayAndType(notiTime, LocalNotificationType.kActivity2) then
		local labelType = 0
		self:addNotify(LocalNotificationType.kActivity2, notiTime, title, content, labelType)
	end
end

function LocalNotificationManager:cancelActivityNoti2()
	local sameTypeNoti = self:getNotiByType(LocalNotificationType.kActivity2)
	if #sameTypeNoti > 0 then
		for i,v in ipairs(sameTypeNoti) do
			self:deleteNotify(v)
		end
		self:flushToStorage()
	end
end

function LocalNotificationManager:setActivityNotiWithActID(notiTime, title, content , actID)
	if not self:getNotiByDayAndType(notiTime, actID ) then
		local labelType = 0
		self:addNotify( actID , notiTime, title, content, labelType)
	end
end

function LocalNotificationManager:cancelActivityNotiWithActID( actID )
	local sameTypeNoti = self:getNotiByType( actID  )
	if #sameTypeNoti > 0 then
		for i,v in ipairs(sameTypeNoti) do
			self:deleteNotify(v)
		end
		self:flushToStorage()
	end
end


function LocalNotificationManager:setNewLadybugTaskNoti(notiTime)
	if not self:getNotiByDayAndType(notiTime, LocalNotificationType.kNewLadyBugTask) then
		local labelKey, labelType = self:getNotifyLabel("lady.bug.notification.finish.body", 3)
		self:addNotify(
			LocalNotificationType.kNewLadyBugTask, 
			notiTime,  
			Localization:getInstance():getText(labelKey), 
			Localization:getInstance():getText("push.prompt.view.details"), 
			labelType)
	end
end

function LocalNotificationManager:cancelNewLadybugTaskNoti()
	local needFlush = false
	local sameTypeNoti = self:getNotiByType(LocalNotificationType.kNewLadyBugTask)
	if #sameTypeNoti > 0 then
		for i,v in ipairs(sameTypeNoti) do
			self:deleteNotify(v)
		end
		needFlush = true
	end
	return needFlush and self:flushToStorage()
end

function LocalNotificationManager:setGiftPackNoti(notiTime, tp, title)
	if not self:getNotiByDayAndType(notiTime, tp) then
		self:addNotify(
			tp, 
			notiTime,  
			title, 
			Localization:getInstance():getText("push.prompt.view.details"), 
			0)
	end
end

function LocalNotificationManager:cancelGiftPackNoti(tp)
	local needFlush = false
	local sameTypeNoti = self:getNotiByType(tp)
	if #sameTypeNoti > 0 then
		for i,v in ipairs(sameTypeNoti) do
			self:deleteNotify(v)
		end
		needFlush = true
	end
	return needFlush and self:flushToStorage()
end

function LocalNotificationManager:cancelNotiByType(target)
	local needFlush = false
	local sameTypeNoti = self:getNotiByType(target)
	if #sameTypeNoti > 0 then
		for i,v in ipairs(sameTypeNoti) do
			self:deleteNotify(v)
		end
		needFlush = true
	end
	return needFlush and self:flushToStorage()
end

function LocalNotificationManager:checkGoldFruit(fruitTime)
	print("LocalNotificationManager:checkGoldFruit",fruitTime)
	self:cancelNotiByType(LocalNotificationType.kGoldFruit)
	if fruitTime and fruitTime>0 then
		local curHour = os.date("%H",fruitTime)
		curHour = tonumber(curHour)
		if curHour>=22 or curHour<7 then
			local fix=curHour>=22 and 7+24-curHour or 7-curHour
			fruitTime = fruitTime+fix*3600
		end

		self:addNotifyFromConfig(LocalNotificationType.kGoldFruit, fruitTime)
	end
end
