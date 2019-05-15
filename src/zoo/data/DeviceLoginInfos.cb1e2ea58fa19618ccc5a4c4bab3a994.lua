---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2018-01-24 16:23:07
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2018-01-24 21:33:58
---------------------------------------------------------------------------------------
DeviceLoginInfos = {}

function DeviceLoginInfos:requestDeviceLoginInfo(hostUrl, callback)
	local url = hostUrl .. "queryLoginInfo?deviceUdid=" .. MetaInfo:getInstance():getUdid()
	local versionAry = _G.bundleVersion:split(".")
	if versionAry ~= nil and #versionAry >= 2 then
		url = url .. "&version=" .. versionAry[1] .. "." .. versionAry[2]
	else
		url = url .. "&version=0"
	end
	local timeout = 5
	local connection_timeout = 2
	local request = HttpRequest:createGet(url)
    request:setConnectionTimeoutMs(connection_timeout * 1000)
    request:setTimeoutMs(timeout * 1000)

	local function onResponse(response)
    	if response and response.httpCode == 200 then 
    		local data = nil
		 	if response.body ~= nil and #response.body > 0 then
		 		data = table.deserialize(response.body)
		 	end
    		if callback then callback(true, data) end
    	else
    		if callback then callback(false) end
    	end
	end
	HttpClient:getInstance():sendRequest(onResponse, request)
end

function DeviceLoginInfos:setCurrentServerLoginInfos(data)
	self.currentServerLoginInfos = data
end

function DeviceLoginInfos:getCurrentServerLoginInfos()
	return self.currentServerLoginInfos
end

function DeviceLoginInfos:setAnotherServerLoginInfos(data)
	self.anotherServerLoginInfos = data
end

function DeviceLoginInfos:getAnotherServerLoginInfos()
	return self.anotherServerLoginInfos
end