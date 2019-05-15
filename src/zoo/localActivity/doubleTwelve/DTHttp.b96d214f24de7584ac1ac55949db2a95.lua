--=====================================================
-- DTHttp
-- by zhijian.li
-- (c) copyright 2009 - 2016, www.happyelements.com
-- All Rights Reserved. 
--=====================================================
-- filename:  DTHttp.lua
-- author:    zhijian.li
-- e-mail:    zhijian.li@happyelements.com
-- created:   2016/11/21
-- descrip:   2016双十二活动 部分请求
--=====================================================

DTCashInfo = class(HttpBase)
function DTCashInfo:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("double12CashInfo error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("double12CashInfo success !")
			context:onLoadingComplete(data)
		end
	end

	self.transponder:call("double12CashInfo", {}, loadCallback, rpc.SendingPriority.kHigh, false)
end


DTBuyCash = class(HttpBase)
function DTBuyCash:load(goldLevel)
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("double12BuyCash error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("double12BuyCash success !")
			context:onLoadingComplete(data)
		end
	end

	if NetworkConfig.useLocalServer then 
		UserService.getInstance():cacheHttp("double12BuyCash", {level = goldLevel})
		if NetworkConfig.writeLocalDataStorage then 
			Localhost:getInstance():flushCurrentUserData()
		else 
			if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.2") end 
		end
		context:onLoadingComplete()
	else
		if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
		self.transponder:call("double12BuyCash", {level = goldLevel}, loadCallback, rpc.SendingPriority.kHigh, false)
	end
end