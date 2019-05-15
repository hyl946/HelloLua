--=====================================================
-- PhoneLoginManager  UrlParamUtil
-- by zhijian.li
-- (c) copyright 2009 - 2016, www.happyelements.com
-- All Rights Reserved. 
--=====================================================
-- filename:  PhoneLoginManager.lua 
-- author:    zhijian.li
-- e-mail:    zhijian.li@happyelements.com
-- created:   2016/12/20
-- descrip:   360手机登录控制
--=====================================================
local UrlParamUtil = class()
function UrlParamUtil:ctor()
	self.secret = nil
	self.paramTable = nil
end

function UrlParamUtil:init()
	self.secret = "NMMOtnfjiHiMvgJSYHkyvoAnrVCMLoDC"
	self.paramTable = {}
end

function UrlParamUtil:add(key, value)
	local pair = {}
	pair.key = key
	pair.value = value
	table.insert(self.paramTable, pair)
end

function UrlParamUtil:getParamsStr()
	local finalStr = ""
	if #self.paramTable > 0 then 
		table.sort(self.paramTable, function (a, b)
			if a and b and a.key and b.key then 
				return a.key < b.key
			end
		end)
		for i,v in ipairs(self.paramTable) do
			finalStr = finalStr .. v.key .. "=" .. v.value .. "&"
		end
		local signStr = finalStr .. "secret" .. "=" .. self.secret
		signStr = HeMathUtils:md5(signStr)
		signStr = string.upper(signStr)
		finalStr = finalStr .. "sign" .. "=" .. signStr
	end
	return finalStr
end

function UrlParamUtil:create()
	local params = UrlParamUtil.new()
	params:init()
	return params
end


PhoneLoginManager = class()

local instance = nil
local LoginCheckKey = "login_has_check"
local PhoneLoginKey = "can_phone_login"

function PhoneLoginManager.getInstance()
	if not instance then
		instance = PhoneLoginManager.new()
		instance:init()
	end
	return instance
end

function PhoneLoginManager:init()
	self.checkOver = false
	self.needCheck = false
	self.addPhoneLogin = false

	local checkTable = PlatformConfig:getPhoneLoginLimitPF() or {}
	if __ANDROID and not PlatformConfig:isPlayDemo() then 
		for i,v in ipairs(checkTable) do
			if PlatformConfig:isPlatform(v) then 
				self.needCheck = true
				break
			end
		end
	end
	if self.needCheck then 
		local hasChecked = CCUserDefault:sharedUserDefault():getBoolForKey(LoginCheckKey, false)
		if hasChecked then 
			self.needCheck = false
			local canPhoneLogin = CCUserDefault:sharedUserDefault():getBoolForKey(PhoneLoginKey, false)
			if canPhoneLogin then
				self.addPhoneLogin = true
			else
				self.addPhoneLogin = false
			end
		end
	end
end

function PhoneLoginManager:checkPhoneLogin()
	local function onCallback(response)
		if response.httpCode ~= 200 then 
			self.addPhoneLogin = false
		else
			local resp = table.deserialize(response.body)
			if resp and resp.code and resp.code == 0 then 
				if resp.msg and resp.msg == "true" then 
					self.addPhoneLogin = true
				else
					self.addPhoneLogin = false
				end
			else
				self.addPhoneLogin = false
			end
			CCUserDefault:sharedUserDefault():setBoolForKey(LoginCheckKey, true)
			CCUserDefault:sharedUserDefault():setBoolForKey(PhoneLoginKey, self.addPhoneLogin)
		end
		self.checkOver = true
	end

	if self.needCheck then 
		local url = NetworkConfig.dynamicHost
		local pf = StartupConfig:getInstance():getPlatformName()
		local params = UrlParamUtil:create()
		params:add("action", "phone")
		params:add("deviceId", MetaInfo:getInstance():getUdid())
		params:add("platform", pf)
		local paramsStr= params:getParamsStr()
		url = url .. "prelogin?" .. paramsStr

		if _G.isLocalDevelopMode then printx(0, "PhoneLoginManager===url===", url) end

		local request = HttpRequest:createGet(url)

		local timeout = 3
	  	local connection_timeout = 2

	  	if __WP8 then 
	    	timeout = 30
	    	connection_timeout = 5
	  	end

	    request:setConnectionTimeoutMs(connection_timeout * 1000)
	    request:setTimeoutMs(timeout * 1000)

   		HttpClient:getInstance():sendRequest(onCallback, request)
   	end
end

function PhoneLoginManager:waitForCheckResult(callback)
	local function check()
		if self.checkOver then 
			self:setPhonePlatformAuth()
			if callback then callback() end
		else
			setTimeOut(check, 0.5)
		end
	end
	if self.needCheck then
		check()
	else
		self:setPhonePlatformAuth()
		if callback() then callback() end
	end
end

function PhoneLoginManager:setPhonePlatformAuth()
    if self.addPhoneLogin then
        PlatformConfig:setPhonePlatformAuth()
    end
end
