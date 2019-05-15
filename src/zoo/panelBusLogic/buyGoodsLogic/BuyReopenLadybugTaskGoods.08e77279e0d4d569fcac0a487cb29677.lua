
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2014年01月11日 21:12:11
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- BuyReopenLadybugTaskGoods
---------------------------------------------------

assert(not BuyReopenLadybugTaskGoods)
BuyReopenLadybugTaskGoods = class()

function BuyReopenLadybugTaskGoods:init(taskDay, ...)
	assert(type(taskDay) == "number")
	assert(#{...} == 0)

	self.taskDay	= taskDay
end

function BuyReopenLadybugTaskGoods:start(isShowTip, successCallback, failCallback, ...)
	assert(type(isShowTip) == "boolean")
	assert(not successCallback or type(successCallback) == "function")
	assert(not failCallback or type(failCallback) == "function")
	assert(#{...} == 0)

	local curTimeInSecond	= os.time() 
	if not __g_utcDiffSeconds then __g_utcDiffSeconds = 0 end
	local curServerTime = curTimeInSecond + __g_utcDiffSeconds

	local function onSuccess()
		-- Open The Lady Bug Task
		local ladyBugInfo 	= UserManager:getInstance():ladyBugInfos_getLadyBugInfoById(self.taskDay)
		ladyBugInfo.startTime	= tostring(curServerTime) .. "000"
		ladyBugInfo.endTime	= tostring(curServerTime + 24*60*60) .. "000"
		ladyBugInfo.reward	= 0
		ladyBugInfo.canReward	= false

		-- fix bug: write new data to file
		local service_ladyBugInfo 	= UserService:getInstance():ladyBugInfos_getLadyBugInfoById(self.taskDay)
		service_ladyBugInfo.startTime	= tostring(curServerTime) .. "000"
		service_ladyBugInfo.endTime	= tostring(curServerTime + 24*60*60) .. "000"
		service_ladyBugInfo.reward	= 0
		service_ladyBugInfo.canReward	= false
		if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
		else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
		-- end of fix

		-- Callback
		if successCallback then
			successCallback()
		end
	end

	local function onFail(errorCode)
		if _G.isLocalDevelopMode then printx(0, "BuyReopenLadybugTaskGoods:onFail Called !") end
		if _G.isLocalDevelopMode then printx(0, "event.data: " .. errorCode) end

		if failCallback then
			failCallback(errorCode)
		end
	end
	
	local reopenLadybugTaskId	= 28
	local buy = BuyLogic:create(reopenLadybugTaskId, MoneyType.kGold, DcFeatureType.kLadyBug, DcSourceType.kLadybugReopen, self.taskDay)
	buy:getPrice()
	buy:start(1, onSuccess, onFail, true)
end

function BuyReopenLadybugTaskGoods:create(taskDay, ...)
	assert(type(taskDay) == "number")
	assert(#{...} == 0)

	local newBuyReopenLadybugTaskGoods = BuyReopenLadybugTaskGoods.new()
	newBuyReopenLadybugTaskGoods:init(taskDay)
	return newBuyReopenLadybugTaskGoods
end
