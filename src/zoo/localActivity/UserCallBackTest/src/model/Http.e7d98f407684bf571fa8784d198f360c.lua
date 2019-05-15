local activityReward = class(HttpBase)
function activityReward:load(actId, id, extra)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("activityReward error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("activityReward success !")
			
			context:onLoadingComplete(data)
		end
	end

	self.transponder:call("activityReward", {actId = actId, rewardId = id, extra = extra}, loadCallback, rpc.SendingPriority.kHigh, false)
end

local getUserCallbackInfo = class(HttpBase)
function getUserCallbackInfo:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("getUserCallbackInfo error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("getUserCallbackInfo success !")
			context:onLoadingComplete(data)
		end
	end

	self.transponder:call("getUserCallbackInfo", {}, loadCallback, rpc.SendingPriority.kHigh, false)
end

return 
{
	activityReward = activityReward,
	getUserCallbackInfo = getUserCallbackInfo
}