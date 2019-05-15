
--获取促销信息
GetAndroidSalesPromotionInitInfo = class(HttpBase)
function GetAndroidSalesPromotionInitInfo:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetAndroidSalesPromotionInitInfo error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetAndroidSalesPromotionInitInfo success !")
			context:onLoadingComplete(data)
		end
	end

	self.transponder:call("getAndroidPromotionInfo", {}, loadCallback, rpc.SendingPriority.kHigh, false)
end

--触发促销
TriggerAndroidSalesPromotion = class(HttpBase)
function TriggerAndroidSalesPromotion:load(triggerLocation)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("TriggerAndroidSalesPromotion error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("TriggerAndroidSalesPromotion success !")
			context:onLoadingComplete(data)
		end
	end

	self.transponder:call("triggerAndroidPromotion", {place = triggerLocation}, loadCallback, rpc.SendingPriority.kHigh, false)
end