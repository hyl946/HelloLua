---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2018-06-01 16:10:25
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   dan.liang
-- @Last Modified time: 2018-08-23 14:20:36
---------------------------------------------------------------------------------------
require "zoo.util.KeyChainUtil"

UserAgreementAlertPanel = class(BasePanel)

function UserAgreementAlertPanel:create()
	local panel = UserAgreementAlertPanel.new()
	panel:loadRequiredResource("ui/announcement_panel.json")
	panel:init()
	return panel	
end
function UserAgreementAlertPanel:ctor( ... )
end
function UserAgreementAlertPanel:dispose( ... )
	BasePanel.dispose(self)
end

function UserAgreementAlertPanel:init()
	self.ui = self:buildInterfaceGroup("AnnouncementPanel/agreement_alert")
	BasePanel.init(self, self.ui)

	local visibleSize = Director.sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()

	local bg = self.ui:getChildByName("bg")
	local size = bg:getGroupBounds().size

	local btn = GroupButtonBase:create(self.ui:getChildByName('confirm_btn'))
	btn:setColorMode(kGroupButtonColorMode.blue)
	btn:setString("知道啦")
	btn:addEventListener(DisplayEvents.kTouchTap,function(event) self:onKeyBackClicked() end)

	local link = self.ui:getChildByName("link_text")
	link:setTouchEnabled(true)
	link:addEventListener(DisplayEvents.kTouchTap,function(event)
		if __WIN32 then
			CommonTip:showTip("用户协议")
		end
		require('zoo.webview.WebView'):openUserArgument()
		end)
end

function UserAgreementAlertPanel:popout(closeCallback)
	PopoutQueue:sharedInstance():push(self, false, false)
	self.allowBackKeyTap = false

	local visibleSize = Director.sharedDirector():getVisibleSize()
	local scale = visibleSize.height / 1280

	local bounds = self.ui:getChildByName("bg"):getGroupBounds()

	self:setPositionX(visibleSize.width/2 - bounds.size.width/2)
	self:setPositionY(-visibleSize.height/2 + bounds.size.height/2)
	self.closeCallback = closeCallback
end

function UserAgreementAlertPanel:onKeyBackClicked()
	PopoutManager:sharedInstance():remove(self)
	self.allowBackKeyTap = false
	if self.closeCallback then
		self.closeCallback() 
	end
end

function UserAgreementAlertPanel:checkNeedPopout()
	local popFlag = KeyChainUtil:getValue("agreement_accept", "0", KeyChainType.APP_GROUP)
	popFlag = tonumber(popFlag) or 0
	if popFlag > 0 then
		return false
	else
	    if not CCUserDefault:sharedUserDefault():getBoolForKey("agreement_accept", false) then
	        local lastLoginUser = Localhost:getLastLoginUserConfig()
	        if self.detectLocalOldUser or (lastLoginUser.uid ~= 0 and lastLoginUser.uid ~= lastLoginUser.sk ) then
	            -- 老用户才需要提示
	            return true
	        else
	            UserAgreementAlertPanel:saveAcceptFlag()
	            return false
	        end
	    else
	    	-- 之前已经记录了,改记到keychain里
	    	UserAgreementAlertPanel:saveAcceptFlag(true)
	    	return false
	    end
	end
end

function UserAgreementAlertPanel:saveAcceptFlag(onlyKeychain)
	local ret = KeyChainUtil:setValue("agreement_accept", "1", KeyChainType.APP_GROUP)
	if not ret and not onlyKeychain then -- 万一keychain写失败
        CCUserDefault:sharedUserDefault():setBoolForKey("agreement_accept", true)
        CCUserDefault:sharedUserDefault():flush()
	end
end