---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2018-06-12 19:40:21
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2018-06-20 14:25:22
---------------------------------------------------------------------------------------
local DataConvertor = {
	key = "$a*qw^@_@Gl)bs+2",
	iv = "0102030405060700",
}

function DataConvertor:convertD(bytes)
	local len, ret = HeMathUtils:packData(bytes, string.len(bytes), self.key, self.iv, 3)
	if len > 0 and ret then
		return string.sub(ret, 1, len)
	else
		return nil
	end
end

function DataConvertor:convertU(bytes)
	local len, ret = HeMathUtils:unpackData(bytes, string.len(bytes), self.key, self.iv, 2)
	if len > 0 and ret then
		return string.sub(ret, 1, len)
	else
		return nil
	end
end

local AISeedRequest = class()

function AISeedRequest:ctor(requestUrl, debugMode)
	self.requestUrl = requestUrl
	self.debugMode = debugMode
	self.canceled = false
	self.startTime = 0
	self.reqStartTime = nil
end

function AISeedRequest:start(levelId, params, callback)
	self.reqStartTime = HeTimeUtil:getCurrentTimeMillis()

	local request = HttpRequest:createPost(self.requestUrl)
	request:setConnectionTimeoutMs(2000)
	request:setTimeoutMs(10000)
	request:addHeader("Content-Type:application/x-www-form-urlencoded")
	request:addPostValue("method", "get")
	local sign = HeMathUtils:md5(params .. DataConvertor.key)
	request:addPostValue("sign", sign)

	if self.debugMode then
		request:addPostValue("param", params)
		request:addPostValue("test", true)
	else
		params = DataConvertor:convertD(params)
		request:addPostValue("param", params)
	end
	local function callbackHanler(response)
		if self.canceled then return end

		if _G.isLocalDevelopMode then printx(0, "callbackHanler response = ", table.tostring(response)) end
		local responseData = nil
		if response then
			local responseTime = HeTimeUtil:getCurrentTimeMillis()
			if response.httpCode == 200 then
				if self.debugMode then
					responseData = table.deserialize(response.body)
				else
					responseData = DataConvertor:convertU(response.body)
					responseData = table.deserialize(responseData)
				end
				if responseData then
					if responseData.result ~= 200 then
						HEAICore:dc("performance", { level = levelId, err = "invalid_response", req_t = self.reqStartTime, resp_t = responseTime, t1 = responseData.result})
						he_log_error("request seeds data error:" .. tostring(levelId) .. ", result:" .. tostring(responseData.result))
					else
						HEAICore:dc("performance", { level = levelId, err = "success", req_t = self.reqStartTime, resp_t = responseTime})
					end
				else
					HEAICore:dc("performance", { level = levelId, err = "invalid_body", req_t = self.reqStartTime, resp_t = responseTime})
					he_log_error("request seeds body error:" .. tostring(levelId) .. ", body:" .. tostring(response.body))
				end
			elseif response.httpCode == 0 then -- 网络错误
				HEAICore:dc("performance", { level = levelId, err = "curl_error", req_t = self.reqStartTime, resp_t = responseTime, t1 = response.errorCode, t2 = response.errorMsg})
				-- he_log_error("request seeds http error:" .. tostring(levelId) .. ", httpCode:" .. tostring(httpCode))
			else
				HEAICore:dc("performance", { level = levelId, err = "http_error", req_t = self.reqStartTime, resp_t = responseTime, t1 = response.httpCode})
			end
		else
			-- 按道理走不到这里来
			he_log_error("request seeds response error:" .. tostring(levelId))
		end

		if type(callback) == "function" then
			callback(responseData)
		end
	end
    HttpClient:getInstance():sendRequestImmediate(callbackHanler, request)
    self.startTime = os.time()
end

function AISeedRequest:cancel(isTimeout)
	self.canceled = true

	if self.startTime <= 0 then return end

	if isTimeout then
		HEAICore:dc("performance", { level = levelId, err = "timeout", req_t = self.reqStartTime, resp_t = HeTimeUtil:getCurrentTimeMillis()})
	else
		local waitTime = os.time() - self.startTime
		if waitTime > 1 then
			HEAICore:dc("performance", { level = levelId, err = "cancel", req_t = self.reqStartTime, resp_t = HeTimeUtil:getCurrentTimeMillis(), t1 = waitTime})
		end
	end
end

return AISeedRequest