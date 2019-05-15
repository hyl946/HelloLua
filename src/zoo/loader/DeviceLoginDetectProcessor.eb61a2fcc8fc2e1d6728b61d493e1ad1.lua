
local Processor = class(EventDispatcher)

Processor.events = {
    kSuccess = "success",
    kFail = "fail",
    kError = "error",
}

Processor.config = {
	kMinLoginCount = 2,
	kMinTopLevel = 10,
}

Processor.reasonType = {
	kQQPlatformIncorrect = 1,	-- 应用宝/非应用宝安装包错误
	kSNSChangeToGuest = 2,		-- 登录方式由SNS账号登录变为游客登录
	kAccountIncorrect = 3,		-- 相同的loginType(非游客)不同的账号
	kLoginTypeNotExist = 4,		-- 原账号使用的loginType在当前Platform不支持
	kSNSChangeToSNS = 5,		-- 登录方式变化(非游客)
}

function Processor:start(loginType)
	if PrepackageUtil:isPreNoNetWork() then
		self:dispatchEvent(Event.new(Processor.events.kFail, nil, self))
		return
	end

    if not __ANDROID then
		self:dispatchEvent(Event.new(Processor.events.kFail, nil, self))
		return
    end
    
    local uid = UserManager:getInstance().uid
    if not uid or kDeviceID == uid or (uid and type(uid) == 'number' and Cookie.getInstance():read("loginInfo" .. uid)) then
		self:dispatchEvent(Event.new(Processor.events.kFail, nil, self))
		return
	else
		self.currentLoginType = loginType
		self:getAnotherServerInfo()
		self:getServerInfo()
    end
end

function Processor:getServerInfo()
	local function onSuccess(evt)
		local loginInfos = evt.data
		self.serverInfo = loginInfos
		self:handleAllServerLoginInfo()
	end

	local function onFailed(evt)
		local err = evt.data
		self:dispatchEvent(Event.new(Processor.events.kError, err, self))
	end

	local http = GetLoginInfosHttp.new()
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFailed)
	http:load()
end

function Processor:getAnotherServerInfo()
    local uid = UserManager:getInstance().uid
	if uid and type(uid) == "number" then
		if Cookie.getInstance():read("loginAnotherServer" .. uid) then
			self.anotherServerInfo = ""
			self:handleAllServerLoginInfo()
			return
		end
	end

	-- local qqServerURL = "http://10.130.136.61/" -- for test
	local qqServerURL = "http://mobile.app100718846.twsapp.com/"
	local otherServerURL = "http://animalmobile.happyelements.cn/"
	local isYYB = PlatformConfig:isQQPlatform()
	local url = isYYB and otherServerURL or qqServerURL 
	url = url .. "queryLoginInfo?deviceUdid=" .. MetaInfo:getInstance():getUdid()
	
	local timeout = 5
	local connection_timeout = 2
	local request = HttpRequest:createGet(url)
    request:setConnectionTimeoutMs(connection_timeout * 1000)
    request:setTimeoutMs(timeout * 1000)

	local function onResponse(response)
		if uid and type(uid) == "number" then
        	Cookie.getInstance():write("loginAnotherServer" .. uid, "1")
     	end
    	if response.httpCode == 200 then 
    		self.anotherServerInfo = response.body
    		self:handleAllServerLoginInfo()
    	else
    		self:dispatchEvent(Event.new(Processor.events.kError, err, self))
    	end
	end

	HttpClient:getInstance():sendRequest(onResponse, request)
end

function Processor:handleAllServerLoginInfo()
	if self.serverInfo and self.anotherServerInfo then
		local anotherServerUser = nil
		local maxLoginCountServerUser = nil
		if self.anotherServerInfo and self.anotherServerInfo ~= "" then
			local anotherServerGroup = self.anotherServerInfo:split(",")
			local loginCount = tonumber(anotherServerGroup[1])
			local loginType = tonumber(anotherServerGroup[2])
			local topLevelId = tonumber(anotherServerGroup[3])
			local platform = tostring(anotherServerGroup[4])
			if loginCount ~= nil and loginType ~= nil and topLevelId ~= nil then
				if loginCount > Processor.config.kMinLoginCount and topLevelId > Processor.config.kMinTopLevel then
					anotherServerUser = {
						loginCount = loginCount, 
						loginType = loginType, 
						topLevelId = topLevelId,
						platform = platform
					}
				end
			end
		end

		local loginInfos = self.serverInfo.loginInfos
		if loginInfos and type(loginInfos) == 'table' and #loginInfos > 0 then
			local maxLoginCount = loginInfos[1].loginCount
			for i, v in ipairs(loginInfos) do
				if v.loginCount > maxLoginCount then
					maxLoginCount = v.loginCount
				end
			end

			local maxLoginCountGroup = {}
			for i, v in ipairs(loginInfos) do
				if v.loginCount == maxLoginCount then
					table.insert(maxLoginCountGroup, v)
				end
			end

			local maxTopLevelLoginInfo = maxLoginCountGroup[1]
			for i, v in ipairs(maxLoginCountGroup) do
				if v.topLevelId > maxTopLevelLoginInfo.topLevelId then
					maxTopLevelLoginInfo = v
				end
			end

			local finalLoginInfo = maxTopLevelLoginInfo

			if finalLoginInfo.loginCount > Processor.config.kMinLoginCount and finalLoginInfo.topLevelId > Processor.config.kMinTopLevel then
				maxLoginCountServerUser = finalLoginInfo
			end
		end

		local function alertQQPlatformSwitch()
			local data = {
				reason = Processor.reasonType.kQQPlatformIncorrect,
				params = {
					currentLoginType = self.currentLoginType,
					targetTopLevelId = anotherServerUser.topLevelId,
					targetLoginType = anotherServerUser.loginType,
					targetPlatform = anotherServerUser.platform
				}
			}
			self:dispatchEvent(Event.new(Processor.events.kSuccess, data, self))
		end

		local function isLoginTypeInCurrentPlatform(loginType)
			local authConfig = PlatformConfig.authConfig
			if PlatformConfig:hasAuthConfig(loginType) then
				return true
			else
				return false
			end
		end

		local function alertLoginTypeOrAccountChange()
			if maxLoginCountServerUser.uid == UserManager:getInstance().uid then
				self:dispatchEvent(Event.new(Processor.events.kFail, nil, self))
				return
			end
			
			local data = nil
			if self.currentLoginType == maxLoginCountServerUser.loginType then
				if self.currentLoginType ~= PlatformAuthEnum.kGuest then
					data = { reason = Processor.reasonType.kAccountIncorrect }
				end
			else
				if maxLoginCountServerUser.loginType == PlatformAuthEnum.kGuest then
					self:dispatchEvent(Event.new(Processor.events.kFail, nil, self))
					return
				end
				if isLoginTypeInCurrentPlatform(maxLoginCountServerUser.loginType) then
					if self.currentLoginType == PlatformAuthEnum.kGuest then
						data = { reason = Processor.reasonType.kSNSChangeToGuest }
					else
						data = { reason = Processor.reasonType.kSNSChangeToSNS }
					end
				else
					data = { reason = Processor.reasonType.kLoginTypeNotExist }
				end
			end

			if data then
				data.params = {
					currentLoginType = self.currentLoginType,
					targetLoginType = maxLoginCountServerUser.loginType,
					targetTopLevelId = maxLoginCountServerUser.topLevelId,
					targetPlatform = maxLoginCountServerUser.platform
				}
				self:dispatchEvent(Event.new(Processor.events.kSuccess, data, self))
			else
				self:dispatchEvent(Event.new(Processor.events.kFail, nil, self))
			end
		end

		if anotherServerUser and maxLoginCountServerUser then
			if anotherServerUser.loginCount > maxLoginCountServerUser.loginCount then
				alertQQPlatformSwitch()
			else
				alertLoginTypeOrAccountChange()
			end
		elseif anotherServerUser then
			alertQQPlatformSwitch()
		elseif maxLoginCountServerUser then
			alertLoginTypeOrAccountChange()
		else
			self:dispatchEvent(Event.new(Processor.events.kFail, nil, self))
		end
	end
end

return Processor
