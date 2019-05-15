
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2014年01月 5日 19:50:16
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"

---------------------------------------------------
-------------- MessageButton
---------------------------------------------------
assert(not MessageButton)
assert(IconButtonBase)

MessageButton = class(IconButtonBase)
function MessageButton:ctor()
	self.id = "MessageButton"
    self.playTipPriority = 40
end

function MessageButton:playHasNotificationAnim()
end

function MessageButton:stopHasNotificationAnim()
end

function MessageButton:init()
	-- Get Resource 
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_mail')

	
	-- Init Base Class
	--BaseUI.init(self, self.ui)
	IconButtonBase.init(self, self.ui)

	----------------
	-- Update UI
	-- --------------
	local requestNumber = UserManager:getInstance().requestNum
	local tipLabelTxtKey	= "message.center.coin.new.mail.tips"
	local tipLabelTxtValue	= Localization:getInstance():getText(tipLabelTxtKey, {})

	self:setTipString(tipLabelTxtValue)
	--------------------------
	-- Notification Anim
	-- --------------------
    self.redDotReward = self:addRedDotReward()
    self.numTip = self:addRedDotNum()
    self.iconAFH = self.ui:getChildByName("flag_help")
    self.iconAFH:setVisible(false)

	if requestNumber > 0 then
		self:playHasNotificationAnim()
	end
	self:updateView()
end

function MessageButton:updateView() 
	self:stopHasNumberAni()
    self:stopHasRewardAni()
    self:stopRedDotJumpAni(self.redDotReward)


	if AskForHelpManager:getInstance():hasNewMessageFlag() then
		self.iconAFH:setVisible(true)
		self.numTip:setVisible(false)
        self.redDotReward:setVisible(false)
    elseif NewVersionUtil:hasUpdateReward() then
    	self.iconAFH:setVisible(false)
        self.numTip:setVisible(false)
        self.redDotReward:setVisible(true)
        self:playRedDotJumpAni(self.redDotReward)
        self:playHasRewardAni()
    else
    	self.iconAFH:setVisible(false)
    	self.numTip:setVisible(true)
	    self.redDotReward:setVisible(false)
		local requestNumber = UserManager:getInstance().requestNum
		self.numTip:setNum(requestNumber)
	    if requestNumber > 0 then
	        self:playHasNumberAni()
	    end
    end
end

function MessageButton:create()
	local newMessageButton = MessageButton.new()
	newMessageButton:initShowHideConfig(ManagedIconBtns.MESSAGE)
	newMessageButton:init()
	return newMessageButton
end
