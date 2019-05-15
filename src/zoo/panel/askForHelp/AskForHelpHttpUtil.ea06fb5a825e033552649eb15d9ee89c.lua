require "zoo.net.Http" 

-- Info
AskForHelpGetInfoHttp = class(HttpBase)
function AskForHelpGetInfoHttp:load(params)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			context:onLoadingError(err)
		else
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call("substituteInfo", params or {}, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- CheckCondition
AskForHelpCheckConditionHttp = class(HttpBase)
function AskForHelpCheckConditionHttp:load(params)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			context:onLoadingError(err)
		else
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call("subsCheck", params or {}, loadCallback, rpc.SendingPriority.kHigh, false)
end


