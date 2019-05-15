require 'zoo.util.OpenUrlUtil'
require 'zoo.panel.broadcast.AutoClosePanel'
require "zoo.panel.ConsumeHistoryPanel"


WechatFriendPayTip= class(AutoClosePanel)

function WechatFriendPayTip:create(string, isShowLogBtn, afterClose)
	local instance = WechatFriendPayTip.new()
	instance:loadRequiredResource(PanelConfigFiles.common_message)
	instance:init(string, isShowLogBtn, afterClose)
	return instance
end

function WechatFriendPayTip:init(string, isShowLogBtn, afterClose)
	BasePanel.init(self, self:buildInterfaceGroup('broadcast/wechatFriendPayTipPanel'))

	self.afterClose = afterClose

	if isShowLogBtn == nil then
		isShowLogBtn = true
	end

	self.text = self.ui:getChildByName("text")

	self.link = self.ui:getChildByName("logLink")
	self.bg = self.ui:getChildByName("bg")

	local bgBounds = self.bg:getGroupBounds(self.ui)
	local bgTop = bgBounds.origin.y + bgBounds.size.height

	local textBounds = self.text:getGroupBounds(self.ui)
	local textTop = textBounds.origin.y + textBounds.size.height
	local textOldHeight = self.text:getDimensions().height

	self.text:setDimensions(CCSizeMake(self.text:getDimensions().width, 0)) 
	self.text:setString(string)

	local textBottom = textTop - self.text:getContentSize().height

	local bgBottom

	self.link:setAnchorPoint(ccp(0, 1))
	self.link:setPositionY(self.link:getPositionY() - (textTop - textBottom) + textOldHeight)
	if isShowLogBtn then
		local linkInput = Layer:create()
		linkInput:setTouchEnabled(true)
		linkInput:addEventListener(DisplayEvents.kTouchBegin,function()
			linkInput:setTouchEnabled(false)
			self:runAction(CCCallFunc:create(function( ... )
				ConsumeHistoryPanel:create():popout()
			end))
		end)
		local size = self.link:getContentSize()
		linkInput:setPositionY(0)
		linkInput:setContentSize(CCSizeMake(size.width, size.height))
		self.link:addChild(linkInput)
		bgBottom = self.link:getGroupBounds(self.ui).origin.y

		local underLine = LayerColor:createWithColor(
			ccc4(0x36, 0x9e, 0x1a), 
			self.link:getContentSize().width,
			2
		)
		self.link:addChild(underLine)
		
	else
		self.link:setVisible(false)
		bgBottom = textBottom
	end

	self.bg:setPreferredSize(CCSizeMake(self.bg:getGroupBounds().size.width, bgTop - bgBottom+12))
	self:enableAutoClose(function() self:closeRightNow() end)
end

function WechatFriendPayTip:getID()
	return -1
end

function WechatFriendPayTip:getPriority()
	return 2001
end

function WechatFriendPayTip:getGoldIconWorldPosXY()
	local visibleSize = Director:sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
	local winSize = Director:sharedDirector():getWinSize()
	local panelSize = self:getGroupBounds().size
	return winSize.width/2, visibleOrigin.y + visibleSize.height - 32 - panelSize.height / 2
end

function WechatFriendPayTip:isCareGuide()
    return false
end

function WechatFriendPayTip:isCarePanel()
    return false
end

function WechatFriendPayTip:isCareHomeQueue()
	return false
end