AndroidShare = class()

local instance
function AndroidShare.getInstance()
	if not instance then
		instance = AndroidShare.new()
		instance:init()
	end
	return instance
end

function AndroidShare:getAPSMgr()
	return luajava.bindClass("com.happyelements.hellolua.aps.APSManager")
end

function AndroidShare:init()
	self.supportedShares = {}
end

function AndroidShare:initShareConfig(shareConfig)
	if not shareConfig then return end

	if type(shareConfig) == "number" then
		self:registerShare(shareConfig)
	elseif type(shareConfig) == "table" then
		for _, shareType in ipairs(shareConfig) do
			self:registerShare(shareType)
		end
	end
	self:registerShare(PlatformShareEnum.kSYS_WECHAT)
end

function AndroidShare:registerShare(shareType)
	if _G.isLocalDevelopMode then printx(0, "AndroidShare:registerShare:", shareType) end
	if not shareType or type(shareType) ~= "number" then return end

	if shareType ~= PlatformShareEnum.kUnsupport then
		local success = AndroidShare:getAPSMgr():getInstance():registerShare(shareType)
		self.supportedShares[shareType] = true
		if not success then
			he_log_error("registerShare failed.shareType="..tostring(shareType)..",platform="..PlatformConfig.name)
		end
	end
end

function AndroidShare:isShareSupported(shareType)
	if not shareType then return false end
	return self.supportedShares[shareType] == true
end

function AndroidShare:getShareDelegate(shareType)
	if not shareType or type(shareType) ~= "number" then
		return nil
	end
	return AndroidShare:getAPSMgr():getInstance():getShareDelegate(shareType)
end