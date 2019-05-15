--=====================================================
-- DTPromotionManager
-- by zhijian.li
-- (c) copyright 2009 - 2016, www.happyelements.com
-- All Rights Reserved. 
--=====================================================
-- filename:  DTPromotionManager.lua
-- author:    zhijian.li
-- e-mail:    zhijian.li@happyelements.com
-- created:   2016/11/21
-- descrip:   2016双十二活动 风车币面板促销管理类
--=====================================================
require "zoo.localActivity.doubleTwelve.DTHttp"
require "zoo.localActivity.doubleTwelve.DTAnimation"

DTPromotionManager = class()

local kStorageFileName = "dt_promotion"
local instance = nil
local beginTime = {year=2016, month=12, day=12, hour=0, min=0, sec=0}
local endTime_Ios = {year=2016, month=12, day=14, hour=23, min=59, sec=59}
local endTime_Adr = {year=2016, month=12, day=14, hour=23, min=59, sec=59}

DTGoldLevel = table.const{
	kLv1 = 6,
	kLv2 = 18,
	kLv3 = 30,
	kLv4 = 128,	
}

DTAndroidGoldLevel = table.const{
	kLv1 = 6,
	kLv2 = 12,
	kLv3 = 28,
}

function DTPromotionManager.getInstance()
	if not instance then
		instance = DTPromotionManager.new()
		instance:init()
	end
	return instance
end

function DTPromotionManager:init()
	self:resetProInfo()
end

function DTPromotionManager:resetProInfo()
	self.adProInfo = {}
	self.iosProInfo = {
		[DTGoldLevel.kLv1] = nil,
		[DTGoldLevel.kLv2] = nil,
		[DTGoldLevel.kLv3] = nil,
		[DTGoldLevel.kLv4] = nil,
	}
end

function DTPromotionManager:isSupportForPromotion()
	-- local platforms = {
	-- 	PlatformNameEnum.kJJ,
	-- 	PlatformNameEnum.k189Store,
	-- 	PlatformNameEnum.kJinliPre,
	-- 	PlatformNameEnum.kLenovoPre,
	-- 	PlatformNameEnum.kCoolpadPre,
	-- 	PlatformNameEnum.kZTEMINIPre,
	-- 	PlatformNameEnum.kAsusPre,
	-- }
	-- if __ANDROID then 
	-- 	for i, v in ipairs(platforms) do
	-- 		if PlatformConfig:isPlatform(v) then
	-- 			return false
	-- 		end
	-- 	end
	-- end

	-- if UserManager:getInstance().user:getTopLevelId() < 20 then 
	-- 	return false 
	-- end

	-- if Localhost:time() < os.time(beginTime) * 1000 then
	-- 	return false
	-- end
	
	-- local endTime
	-- if __ANDROID then 
	-- 	endTime = endTime_Adr
	-- elseif __IOS or __WIN32 then 
	-- 	endTime = endTime_Ios
	-- else
	-- 	return false
	-- end
	-- if Localhost:time() > os.time(endTime) * 1000 then
	-- 	return false
	-- end

	-- return true

	return false
end

function DTPromotionManager:sendServerCashBuy(goldPrice, endCallback)
	local function sendToServer()
		local function onSuccess(evt)
			if endCallback then endCallback() end
		end
		local function onFail(evt)
			if endCallback then endCallback() end
		end
		local function onCancel(evt)
			if endCallback then endCallback() end
		end
		local http = DTBuyCash.new(true)
		http:addEventListener(Events.kComplete, onSuccess)
		http:addEventListener(Events.kError, onFail)
		http:addEventListener(Events.kCancel, onCancel)
		http:load(goldPrice)
	end

	if __IOS or __WIN32 then 
		for k,v in pairs(DTGoldLevel) do
			if goldPrice == v then 
				sendToServer()
				break
			end
		end
	elseif __ANDROID then 
		for k,v in pairs(DTAndroidGoldLevel) do
			if goldPrice == v then
				--今天是否买过判断
				if not DTPromotionManager.getInstance():checkIsSameDayBuy() then 
					sendToServer()
				end
				break
			end
		end
	else
		if endCallback then endCallback() end
	end
end

-----------------------ios-----------------------
function DTPromotionManager:loadIosData(sucFunc, failFunc)
	local function onSuccess(evt)
		self:resetProInfo()
		local serverData = evt.data
		if serverData.infoList then 
			for k,v in pairs(serverData.infoList) do
				local endTime = tonumber(v.endTime) or 0
				if endTime > Localhost:time() then 
					for m,n in pairs(DTGoldLevel) do
						if v.level == n then 
							local info = {}
							info.goldPirce = v.level
							info.time = endTime
							info.itemId = v.itemId
							info.itemNum = v.num
							self.iosProInfo[v.level] = info
						end
					end
				end
			end
		end
		if sucFunc then sucFunc() end
	end
	local function onFail(evt)
		if failFunc then failFunc() end
	end
	local function onCancel(evt)
		if failFunc then failFunc() end
	end
	local http = DTCashInfo.new(true)
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFail)
	http:addEventListener(Events.kCancel, onCancel)
	http:syncLoad()
end

function DTPromotionManager:getIosPromotionDataByPrice(goldPrice)
	for k,v in pairs(self.iosProInfo) do
		if k == goldPrice then 
			return v
		end
	end
end

function DTPromotionManager:removeIosPromotionDataByPrice(goldPrice)
	for k,v in pairs(self.iosProInfo) do
		if k == goldPrice then 
			self.iosProInfo[k] = nil
			return 
		end
	end
end

-----------------------android-----------------------
function DTPromotionManager:loadAndroidData(sucFunc, failFunc)
	local function onSuccess(evt)
		self:resetProInfo()
		self:updateMarketIconShow(false)
		local serverData = evt.data
		if serverData.infoList then 
			for k,v in pairs(serverData.infoList) do
				for m,n in pairs(DTAndroidGoldLevel) do
					if v.level == n then 
						local info = {}
						info.goldPirce = v.level
						info.itemId = v.itemId
						info.itemNum = v.num
						self.adProInfo = info
						self:updateMarketIconShow(true)
						break
					end
				end
			end
		end
		if sucFunc then sucFunc() end
	end
	local function onFail(evt)
		if failFunc then failFunc() end
	end
	local function onCancel(evt)
		if failFunc then failFunc() end
	end
	local http = DTCashInfo.new(true)
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFail)
	http:addEventListener(Events.kCancel, onCancel)
	http:load()
end

function DTPromotionManager:getAndroidPromotionData()
	return self.adProInfo
end

function DTPromotionManager:updateLastBuyTime()
	self.lastPromotionBuyTime = Localhost:timeInSec()
end

local function getDayStartTimeByTS(ts)
	local utc8TimeOffset = 57600 -- (24 - 8) * 3600
	local oneDaySeconds = 86400 -- 24 * 3600
	return ts - ((ts - utc8TimeOffset) % oneDaySeconds)
end

function DTPromotionManager:checkIsSameDayBuy()
	if self.lastPromotionBuyTime then 
		local nowDayStart = getDayStartTimeByTS(Localhost:timeInSec())
		local lastBuyDayStart = getDayStartTimeByTS(self.lastPromotionBuyTime)
		if nowDayStart > lastBuyDayStart then 
			return false
		else
			return true
		end
	else
		return false
	end
end

function DTPromotionManager:updateMarketIconShow(showFlag)
	local homeScene = HomeScene:sharedInstance()
	if homeScene and homeScene.marketButton then 
		homeScene.marketButton:showReward(showFlag)
	end
end