require "zoo.net.Http"
HttpsClient = class(HttpBase)

HTTPS_ROOT_URL = "https://animalaccount.happyelements.com/"

if PlatformConfig:isQQPlatform() then
	HTTPS_ROOT_URL = "http://mobaccount.app100718846.twsapp.com/"
end

if StartupConfig:getInstance():isLocalDevelopMode() then -- debug 版本
	HTTPS_ROOT_URL = "https://10.130.137.97/animal-account/"
end


local sessionId = ""

function HttpsClient.setSessionId(sId)
	if not string.isEmpty(sId) then
		sessionId = sId
	end
end

function HttpsClient:ctor(endPoint, postData, onSuccess, onError)
	self.endPoint = endPoint
	self.postData = postData
	self.onSuccess = onSuccess
	self.onError = onError

	self.timeout = 1
end

function HttpsClient:setCustomizedOnError()
	self.customizedOnError = true
end

function HttpsClient:create(endPoint, postData, onSuccess, onError)
	local client = HttpsClient.new(endPoint, postData, onSuccess, onError)
	return client
end

local v = _G.bundleVersion
local pf = StartupConfig:getInstance():getPlatformName()

function HttpsClient:send()

	local request = HttpRequest:createPost(HTTPS_ROOT_URL..self.endPoint .. "?_v=" .. v .. "&pf=" .. pf)
	request:setConnectionTimeoutMs(10 * 1000)
	request:setTimeoutMs(30 * 1000)

	if self.postData then
		for k,v in pairs(self.postData) do
			request:addPostValue(k, v)
		end
	end

	if not string.isEmpty(sessionId) then
		request:addPostValue("sessionId", sessionId)
	end

	local function onResponse(response)
		if self.isCancelRequest then
			return
		end

		if response and response.httpCode == 200 then
			if self.onSuccess then
				if type(response.body) == "string" then
                	local data = table.deserialize(response.body)

                	if not data or type(data)~="table" then
                		CommonTip:showTip("response data cannot be nil!", "negative",nil,2)
                	elseif tonumber(data.ret) ~= 200 then
                		self.onError(data.ret, data.message,data)
                	else
                		self.onSuccess(data)
                	end
				end
			end
		else
			if self.customizedOnError then
					if self.onError then
						self.onError(response.errorCode, response.errorMsg)
					end 
			else
				local content = localize("error.tip.network.failure")
					
				CommonTip:showTip(content, "negative", nil, 2)
			end
		end

		self:_stopTime()
    	self:_removeAnimation()
	end

	HttpClient:getInstance():sendRequest(onResponse, request)
	self:_startTime()
end