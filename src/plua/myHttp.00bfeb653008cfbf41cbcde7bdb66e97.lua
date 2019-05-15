HttpRequest = class(myCCAction)

function HttpRequest:ctor()
end

function HttpRequest:createGet(url)
	local req = HttpRequest.new()
	req.url = url
	return req
end

function HttpRequest:createPost(url)
	local req = HttpRequest.new()
	req.url = url
	return req
end

function HttpRequest:update(dt)
	if self.curFrame > 0 then
		if self.onFnished ~= nil then
			self.onFnished({httpCode = 404})
		end
		return true
	end
	self.curFrame = self.curFrame + 1
	return false
end

function HttpRequest:setConnectionTimeoutMs(timeout)
	self.timeout = timeout
end
    
function HttpRequest:setTimeoutMs(timeoutMs)
	self.timeoutMs = timeoutMs
end

function HttpRequest:addHeader(head)
	
end

function HttpRequest:setPostData(data, len)
	
end

HttpClient = class()
local HttpClientInstance = nil
function HttpClient:getInstance()
	if HttpClientInstance == nil then
		HttpClientInstance = HttpClient.new()
	end
	return HttpClientInstance
end

function HttpClient:sendRequest(backFunc, req)
	req.onFnished = backFunc
	req.actionQuere[1].onFnished = backFunc
	myActionManager:getInstance():addAction(req)
end