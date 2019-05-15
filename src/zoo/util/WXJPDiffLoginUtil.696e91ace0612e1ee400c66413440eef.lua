require "hecore.class"

WXJPDiffLoginUtil = class()
local instance = nil

-- wakeType = "jp_wake_diff"
-- wakeType = "jp_wake_login"

-- loginType = "jp_login_wx"
-- loginType = "jp_login_qq"

local WXJP_WAKE_KEY = "wxjp.login.wake.type"
local WXJP_LOGIN_KEY = "wxjp.login.platform.type"

function WXJPDiffLoginUtil.getInstance()
	if not instance then
		instance = WXJPDiffLoginUtil.new()
		instance:init()
	end
	return instance
end

function WXJPDiffLoginUtil:init()
	self.delayHandleDiff = false
	self.userDefault = CCUserDefault:sharedUserDefault()
	self.wakeType = self.userDefault:getStringForKey(WXJP_WAKE_KEY, "")
	self.loginType = self.userDefault:getStringForKey(WXJP_LOGIN_KEY, "")
end

function WXJPDiffLoginUtil:setDiffLoginState(wakeType, loginType)
	self.wakeType = wakeType
	self.loginType = loginType

	self.userDefault:setStringForKey(WXJP_WAKE_KEY, wakeType)
	self.userDefault:setStringForKey(WXJP_LOGIN_KEY, loginType)
	self.userDefault:flush()
end

function WXJPDiffLoginUtil:getWakeType()
	return self.wakeType 
end

function WXJPDiffLoginUtil:getLoginType()
	return self.loginType 
end

function WXJPDiffLoginUtil:clean()
	self.wakeType = nil
	self.loginType = nil
	self.delayHandleDiff = nil
	self.delayHandleAuto = nil

	self.userDefault:setStringForKey(WXJP_WAKE_KEY, "")
	self.userDefault:setStringForKey(WXJP_LOGIN_KEY, "")
	self.userDefault:flush()
end

function WXJPDiffLoginUtil:handleDiffLogin()
	local wakeType = self:getWakeType()
	if wakeType then
		local success, scene = pcall(function ()
			return Director:sharedDirector():getRunningScene()
		end)
		if success then 
			if wakeType == "jp_wake_diff" then
				local autoLogin = false
				if scene.name == "JPPreloadingScene" then 
					if not scene.loadStable then 
						self:setDelayHandleDiff(true)
						return 
					end
					if scene.isDoingAutoLogin then 
						scene:stopAutoLogin()
						autoLogin = true
					end
				end
				self:showDiffLoginPanel(function ()
					SnsProxy:logout()
					Localhost:getInstance():clearLastLoginUserData()
					PrepackageUtil:restart(500)
				end, function ()
					self:clean()
					if autoLogin then 
						scene:tryAutoLogin()
					end
				end)
			elseif wakeType == "jp_wake_login" then
				if scene.name == "JPPreloadingScene" then 
					if not scene.loadStable then 
						self:setDelayHandleAuto(true)
					else
						if scene.authButton1 and scene.authButton1:isVisible() then 
							scene:tryAutoLogin()
						end
					end
				end
			end
		else
			if wakeType == "jp_wake_diff" then 
				self:setDelayHandleDiff(true)
			elseif wakeType == "jp_wake_login" or wakeType == "jp_wake_no_scene" then
				self:setDelayHandleAuto(true)
			end
		end
	end
end

function WXJPDiffLoginUtil:setDelayHandleDiff(isDelay)
	self.delayHandleDiff = isDelay
end

function WXJPDiffLoginUtil:getDelayHandleDiff()
	return self.delayHandleDiff
end

function WXJPDiffLoginUtil:setDelayHandleAuto(isDelay)
	self.delayHandleAuto = isDelay
end

function WXJPDiffLoginUtil:getDelayHandleAuto()
	return self.delayHandleAuto
end

function WXJPDiffLoginUtil:showDiffLoginPanel(confirmFunc, cancelFunc)
	require "zoo.panel.CommonTipWithBtn"
	local tipConfig = {tip = localize("wxjp.loading.tips.preloading.warnning"), yes = "确定", no = "取消", noFadeOut = true}
	CommonTipWithBtn:showTip(tipConfig, "negative", function ()
		if confirmFunc then confirmFunc() end
	end, function ()
		if cancelFunc then cancelFunc() end
	end)
end

function setWXJPLoginState(wakeType, loginType)
	WXJPDiffLoginUtil.getInstance():setDiffLoginState(wakeType, loginType)
	WXJPDiffLoginUtil.getInstance():handleDiffLogin()
end
