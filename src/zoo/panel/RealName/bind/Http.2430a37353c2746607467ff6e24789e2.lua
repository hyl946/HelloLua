local http = class(HttpBase)
function http:load(params)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("realNameAuthSnsPlatform error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("realNameAuthSnsPlatform success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call("realNameAuthSnsPlatform", params or {}, loadCallback, rpc.SendingPriority.kHigh, false)
end

function http:sendRealNameReq(openId, accessToken, sucessCallback, failCallback, cancelCallback)
	local function onSuccess(evt)
		if sucessCallback then sucessCallback(evt) end
	end

	local function onFail(evt)
	    if failCallback then failCallback(evt) end
	end

	local function onCancel()
		if cancelCallback then cancelCallback() end
	end

	self:ad(Events.kComplete, onSuccess)
	self:ad(Events.kError, onFail)
	self:ad(Events.kCancel, onCancel)

	local snsPlatform = PlatformConfig:getPlatformAuthName(PlatformAuthEnum.k360)
	self:syncLoad({openId=openId, accessToken=accessToken, snsPlatform=snsPlatform})
end

return http