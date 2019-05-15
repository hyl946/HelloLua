local SuperCls = require("zoo/localActivity/UserCallBackTest/src/model/ActRewardModel.lua")
local Model = class(SuperCls)

local config = require("zoo/localActivity/UserCallBackTest/Config.lua")
local http = require("zoo/localActivity/UserCallBackTest/src/model/Http.lua")

local __instance

function Model:create()
	local model = Model.new()
	model:init()
	return model
end

function Model:init()
	SuperCls.init(self, "UserCallBackTest", config, http)
end

function Model:getInstance()
	if __instance == nil then
		__instance = Model.create()

		-- __instance:openTest()
	end

	return __instance
end

function Model:getInfoAsync(sucessCallBack, failCallBack)
	local function onSuccess( evt )
		-- if _G.isLocalDevelopMode then printx(100, "UserCallBackPopoutAction Model.onSuccess data = " , table.tostring(evt.data) ) end
		self:getInfoSucess(evt)
		if sucessCallBack then sucessCallBack() end
	end

	local function onFail( evt ) 
		if _G.isLocalDevelopMode then printx(100, "UserCallBackPopoutAction Model.onFail" ) end
		local errcode = evt and evt.data or nil
 	    	if errcode then
 			local scene = Director:sharedDirector():run()
			if  scene ~= nil and scene:is(HomeScene) then
				CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(errcode)), "negative")
			end
	    end
		if failCallBack then failCallBack() end
	end

	local function onCancel()
		if _G.isLocalDevelopMode then printx(100, "UserCallBackPopoutAction Model.onCancel" ) end
		if failCallBack then failCallBack() end
	end

	if _G.isLocalDevelopMode then printx(100, "UserCallBackPopoutAction Model.getInfoAsync" ) end

	local http = self.http.getUserCallbackInfo.new(true)
	http:ad(Events.kComplete, onSuccess)
	http:ad(Events.kError, onFail)
	http:setCancelCallback(onCancel)
	http:syncLoad(self.config.actId, id)
end

function Model:openTest()
	self.received = false
	self.endTime = Localhost:timeInSec() * 1000 + 86400000 * 7.5 --单位 ms
	config.setEndTime(self.endTime/1000)
	self.currentRewardIndex = 1
	self.group = 2

	self.boxRewardCfg = {}
	for id=1, 7 do
		local rewardData = {id = id, rewardId = id, conditions = 999, rewards = {{itemId = 2, num=500}, {itemId = 10001, num = 1}, {itemId = 10002, num = 1}, {itemId = 10003, num = 1}, {itemId = 10004, num = 1}}}
		self.boxRewardCfg[id] = rewardData
	end
end

function Model:getInfoSucess(evt)
	-- print("==============get level act info [[ " .. self.actKey .. " ]]")
 -- 	print("==============act data:" .. table.tostring(evt.data))
--[[
		<property code="received" type="boolean" desc="当天是否已领取奖励"/>
		<property code="endTime" type="long" desc="活动截止时间"/>
		<list code="rewardConfig" ref="Rewards" desc="奖励配置"/>
		<property code="currentRewardIndex" type="int" desc="当前能领取奖励的index 从0开始"/>
]]
 	self.received = evt.data.received
	self.endTime = evt.data.endTime or 0 --单位 ms
	config.setEndTime(self.endTime/1000)
	self.currentRewardIndex = evt.data.currentRewardIndex or 1
	-- self.group = evt.data.group
	self.group = evt.data.subGroup
	self.rewardTimes = evt.data.rewardTimes
	self.LevelId = evt.data.levelId
	-- local buffEndTime = tonumber(evt.data.preBuffEndTime) or 0
	-- if buffEndTime > Localhost:time() then

	--初始给本地时间
    UserCallbackManager:getInstance():InitActivityStartEndTime( self.endTime )
	UserCallbackManager.getInstance():InitBuffInfo( self.group, self.rewardTimes, self.LevelId )
	-- end
	
	self.boxRewardCfg = {}
	local rewardCfg = evt.data.rewardConfig or {}
	for id=1, #rewardCfg do
		local rewardData = {id = id, rewardId = self:getRewardIDByDayID(id), conditions = 999, rewards = rewardCfg[id].rewards}
		self.boxRewardCfg[id] = rewardData

		-- if self.group == 1 then
		-- 	if id == 1 or id == 2 then
		-- 		local itemInfo = {}
		-- 		itemInfo.Buff = true
		-- 		itemInfo.BuffLevel = 5

		-- 		table.insert( self.boxRewardCfg[id].rewards , itemInfo ) 
		-- 	end
		-- elseif self.group == 2 then
		-- 	if id == 1  then
		-- 		local itemInfo = {}
		-- 		itemInfo.Buff = true
		-- 		itemInfo.BuffLevel = 3

		-- 		table.insert( self.boxRewardCfg[id].rewards , itemInfo ) 
		-- 	end
		-- elseif self.group == 3 then
		-- 	if id == 1 or id == 2 or id == 3 then
		-- 		local itemInfo = {}
		-- 		itemInfo.Buff = true
		-- 		itemInfo.BuffLevel = 2+id

		-- 		table.insert( self.boxRewardCfg[id].rewards , itemInfo ) 
		-- 	end
		-- end
	end

	self:setNotification()
end

function Model:getTodayID()
	if self.received then
		return self.currentRewardIndex % 100 -1
	end

	return self.currentRewardIndex % 100
end

function Model:getTodayRewardID()
	if self.received then
		return self.currentRewardIndex - 1
	end

	return self.currentRewardIndex
end

function Model:getRewardIDByDayID(dayID)
	return self.currentRewardIndex - self.currentRewardIndex % 100 + dayID
end

function Model:hasAvailableReward( ... )
	return not self.received, self:getTodayID()
end

function Model:hasNextBoxToAchive( ... )
	return self:getTodayID() < 7 and Localhost:getTodayStart() <= self:getActEndDayStart()
end

function Model:setBoxRewardCfg(obj)
	self.boxRewardCfg = obj
end

function Model:getBoxRewardCfg()
	return self.boxRewardCfg
end

function Model:getActivityRewardSucess(evt, successCallback)

	DcUtil:log(AcType.kUserTrack, {category = "recall", sub_category = "recall_reward", id = self.currentRewardIndex%100})
	DcUtil:log(AcType.kUserTrack, {category = "recall", sub_category = "reward_id", id = self.group})

	-- if UserCallbackManager.getInstance():getUserGroup() == UserCallbackManager.UserGroup.kGroupNewB and 
	--  	self.currentRewardIndex%100 == 1 then 
	-- 	UserCallbackManager.getInstance():setBuffEndTime(Localhost:time() + 60 * 60 * 1000)
	-- end

 	local CurDay = self.currentRewardIndex%100

 	local rewardInfo = {}
 	rewardInfo.first = CurDay
 	rewardInfo.second = Localhost:time()
 	self.rewardTimes[CurDay] = rewardInfo
	UserCallbackManager.getInstance():InitBuffInfo( self.group, self.rewardTimes, self.LevelId )

	self.received = true
	self.currentRewardIndex = self.currentRewardIndex + 1
	self:updateRewardTipView()
	SuperCls.getActivityRewardSucess(self, evt, successCallback)
	
	if self:isActEnd() then
		self:writeLocalDataByKey("hasGuideVer2", false)
		self:onActEnd()
		self:cancelNotification()
	-- else
		-- self:setNotification()
	end
end

function Model:onActEnd()
	config.isActEnd = function() return true end
	config.icon = nil
	local userCallbackActInfo = UserManager:getInstance().userCallbackActInfo or {}
	userCallbackActInfo.see = false
	HomeScene:sharedInstance():removeHomeSceneUserCallBackButton()

end

if Localhost.getTodayStart == nil then
	--获取当日开始时间 单位 s
	function Localhost:getDayStartTimeByTS(ts)
		if ts ~= nil then
			local utc8TimeOffset = 57600
			local dayInSec = 86400
			return ts - ((ts - utc8TimeOffset) % dayInSec)
		end	
		return 0
	end
	--获取今天开始时间 单位 s
	function Localhost:getTodayStart()
		return Localhost:getDayStartTimeByTS(Localhost:timeInSec())
	end
end

function Model:isActEnd()
	local isEnd = (self:getTodayID() >= 7 and self.received) or 
				  Localhost:getTodayStart() > self:getActEndDayStart() or
				  (self.received and (Localhost:getTodayStart() + 86402) > self:getActEndDayStart())
	return isEnd
end

function Model:getActEndDayStart()
	return Localhost:getDayStartTimeByTS(self.endTime/1000)
end

function Model:actEndLogic()
	
end

function Model:getDcRawData()
	return {}
end

function Model:setNotification()
	self:cancelNotification()

	local notiAry = self:getNotiIDAry()
	if LocalNotificationPriority ~= nil then
		for i=1, #notiAry do
			if LocalNotificationPriority[notiAry[i]] == nil then
				LocalNotificationPriority[notiAry[i]] = 20
			end
		end
	end

	local function setNotifForDay(dayStartTs)
		local ver = tonumber(string.split(_G.bundleVersion, ".")[2])
		if ver < 52 then
			local targetTime = dayStartTs + 12.5 * 3600 + math.random(60 * 60)
			local tag = math.random(3)
			local bodyTxt = Localization:getInstance():getText("3009.recall_noti_reward_" .. tag)
			local actionTxt = Localization:getInstance():getText("3009.recall_noti_reward_" .. tag .. "_" .. tag)
			LocalNotificationManager:getInstance():addNotify(notiAry[tag], targetTime, bodyTxt, actionTxt)

			targetTime = targetTime + 7 * 3600
			tag = math.random(3)
			bodyTxt = Localization:getInstance():getText("3009.recall_noti_reward_" .. tag)
			actionTxt = Localization:getInstance():getText("3009.recall_noti_reward_" .. tag .. "_" .. tag)
			LocalNotificationManager:getInstance():addNotify(notiAry[tag], targetTime, bodyTxt, actionTxt)
		else
			local targetTime = dayStartTs + 12.5 * 3600 + math.random(60 * 60)
			LocalNotificationManager:getInstance():addNotifyFromConfig(43, targetTime, true)

			targetTime = targetTime + 7 * 3600
			LocalNotificationManager:getInstance():addNotifyFromConfig(43, targetTime, true)
		end
	end

	local now = Localhost:timeInSec()
	local nextDayStartTs = Localhost:getDayStartTimeByTS(now + 86400) -- 明天
	local endDayStartTs = self:getActEndDayStart() -- 结束后一天
	if endDayStartTs - nextDayStartTs > 86400 * 30 then -- 30天限制, 应该不会走进来，但是我的win32上会出现，导致卡死，因此加上这个保险
		endDayStartTs = nextDayStartTs + 86400 * 30
	end

	-- local counter = 1
	while (nextDayStartTs < endDayStartTs) do
		-- print('------------- counter', counter)
		-- counter = counter + 1
		setNotifForDay(nextDayStartTs)
		nextDayStartTs = nextDayStartTs + 86400
	end
	LocalNotificationManager:getInstance():flushToStorage()

	-- print(table.tostring(LocalNotificationManager:getInstance().mapByDay)) debug.debug()
end

function Model:hasPushNotiByDay(targetTime)
	local pushFlag = false
	local notiAry = self:getNotiIDAry()
	for i=1, #notiAry do
		if not pushFlag and LocalNotificationManager:getInstance():getNotiByDayAndType(targetTime, notiAry[i]) ~= nil then
			pushFlag = true
		end
	end
	return pushFlag
end

function Model:getNotiIDAry()
	return {43, 44, 45}
end

function Model:cancelNotification()
	local now = os.time()
	local notiAry = self:getNotiIDAry()
	for i=1, #notiAry do
		local noties = LocalNotificationManager:getInstance():getNotiByType(notiAry[i])
		if #noties > 0 then
			for i=1, #noties do
				local vo = noties[i]
				LocalNotificationManager:getInstance():deleteNotify(vo)
			end
		end
	end
	LocalNotificationManager:getInstance():flushToStorage()
end

function Model:showPriceTag()
	return self.group == 5
end

function Model:getBuffIconNames()
	return {"buff_icon_1", "buff_icon_2", "buff_icon_3", "buff_icon_4", "buff_icon_1"}
end

return Model