require "zoo.config.PlatformConfig"
require "zoo.util.UpdateCheckUtils"
require "zoo.data.MaintenanceManager"

PushManager = {}

function PushManager:init( ... )
	self.platform2PushType = {}
	self.platform2PushType[PlatformNameEnum.kMI] = "com.happyelements.android.platform.mi.push.MiPushClient"
	self.platform2PushType[PlatformNameEnum.kMiTalk] = "com.happyelements.android.platform.mi.push.MiPushClient"
	self.platform2PushType[PlatformNameEnum.kMiPad] = "com.happyelements.android.platform.mi.push.MiPushClient"
	
	self.platform2PushType[PlatformNameEnum.kMZ] = "com.happyelements.android.platform.meizu.push.MzPushClient"
	--self.platform2PushType[PlatformNameEnum.kHuaWei] = "com.happyelements.android.platform.huawei.push.HuaWeiClient"
	self.platform2PushType[PlatformNameEnum.kOppo] = "com.happyelements.android.platform.oppo.push.OppoPushClient"
	self.platform2PushType[PlatformNameEnum.kBBK] = "com.happyelements.android.platform.vivo.push.VivoPushClient"
end

function PushManager:isEnabled()
	local platform = StartupConfig:getInstance():getPlatformName()

	local keyName = "SystemPushDisable_" ..platform
	if MaintenanceManager:getInstance():isEnabled(keyName) then
		return false
	end

	return self.platform2PushType[platform]
end

function PushManager:isSystemPushOpen()
	return self:isEnabled() or PlatformConfig:isPlatform(PlatformNameEnum.kHuaWei)
end

function PushManager:initSDK()
	if not self:isEnabled() then return false end

	local cbk = luajava.createProxy("com.happyelements.android.InvokeCallback", {
		onSuccess = function (token)
			if not token then return end
			if PlatformConfig:isPlatform(PlatformNameEnum.kOppo) then
				local http = OpNotifyOffline.new(false)
				http:load(14, tostring(token))
			end
		end,
		onError = function (code, errMsg)
			self.manager = nil
		end,
		onCancel = function () 
			self.manager = nil
		end
	});

	local platform = StartupConfig:getInstance():getPlatformName()
	local delegate = self.platform2PushType[platform]
	if not delegate then return false end

	self.manager = luajava.bindClass('com.happyelements.android.push.PushManager')
	if self.manager then
		self.manager:initSDK(delegate, cbk)
	end
end

function PushManager:getContext()
	local MainActivityHolder = luajava.bindClass("com.happyelements.android.MainActivityHolder")
	return MainActivityHolder.ACTIVITY:getContext()
end

function PushManager:setAccount(uid)
	if self.manager then
		self.manager:setAccount(self:getContext(), uid)
	end
end

function PushManager:setAlias(uid)
	if self.manager then
		self.manager:setAlias(self:getContext(), uid)
	end
end

PushManager:init()