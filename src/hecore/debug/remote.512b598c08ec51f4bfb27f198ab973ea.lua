if printx == nil then
	require "hecore.debug.printx"
end

RemoteDebug = {
	logStr = "",
}

local recursion_log = nil
recursion_log = function ( arg, ... )
	local str = arg or "nil"
	if #{...} == 0 then
		return tostring(str) .. "\n"
	end
	return tostring(str) .. " " .. recursion_log(...)
end

function RemoteDebug:log( ... )
	self.logStr = self.logStr .. "[RemoteDebug] " ..  recursion_log(...)
end

function RemoteDebug:logWithLuaPrint( ... )
	if _G.isLocalDevelopMode then printx( -4 , ...) end
	RemoteDebug:uploadLog(...)
end

function RemoteDebug:uploadLogWithChannelAndTag(tag, ...)

end

function RemoteDebug:uploadLogWithTag(tag, ...)
	-- if __WIN32 then return end
	if __WIN32 then printx( -4 , tag , ...) end
	local str = nil
	if #{...} == 0 then
		str = self.logStr
		self.logStr = ""
	else
		str = "[RemoteDebug] " .. recursion_log(...)
	end

	if #{...} == 0 and str == "" and not tag then
		return
	end

	local url = "http://127.0.0.1/log.php"
	if tag then url = url.."?tag="..tostring(tag) end
	local request = HttpRequest:createPost(url)
	request:setConnectionTimeoutMs(2 * 1000)
	request:setTimeoutMs(30 * 1000)

	request:addHeader("Content-Type:application/octet-stream")

	local md5_path = HeResPathUtils:getResCachePath()
	local f = io.open(md5_path .. "/static_config.md5", 'r')
	if f then
  		local md5 = f:read("*all")
  		str = "client md5:"..md5.."\n"..str
  	end

    request:setPostData(str, string.len(str))
    printx( "-4" , str )

	local function onRegisterFinished( response )

	end

    HttpClient:getInstance():sendRequest(onRegisterFinished, request)
end

function RemoteDebug:uploadLog(...)
	RemoteDebug:uploadLogWithTag(nil, ...)
end