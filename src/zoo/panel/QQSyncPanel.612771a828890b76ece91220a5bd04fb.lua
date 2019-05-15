
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2014Äê01ÔÂ 1ÈÕ 14:53:58
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- QQSyncPanel
---------------------------------------------------

assert(not QQSyncPanel)
assert(BasePanel)
QQSyncPanel = class(BasePanel)

function QQSyncPanel:init(title,message,okCallback,cancelCallback)

	----------------------
	-- Get UI Componenet
	-- -----------------
	self.ui	= self:buildInterfaceGroup("qqsyncpanel")--ResourceManager:sharedInstance():buildGroup("QQSyncPanel")

	--------------------
	-- Init Base Class
	-- --------------
	BasePanel.init(self, self.ui)

	-------------------
	-- Get UI Componenet
	-- -----------------
	self.panelTitle		= self.ui:getChildByName("panelTitle")
	self.desLabel		= self.ui:getChildByName("desLabel")
	self.confirmBtnRes	= self.ui:getChildByName("confirmBtn")
	self.cancelBtnRes   = self.ui:getChildByName("cancelBtn")

	assert(self.panelTitle)
	assert(self.desLabel)
	assert(self.confirmBtnRes)
	assert(self.cancelBtnRes)

	self.cancelCallback	= cancelCallback

	--------------------
	-- Create UI Componenet
	-- ----------------------
	self.confirmBtn		= GroupButtonBase:create(self.confirmBtnRes)
	self.cancelBtn      = GroupButtonBase:create(self.cancelBtnRes)

	--------------
	-- Init UI
	-- ----------
	self.ui:setTouchEnabled(true, 0, true)

	----------------
	-- Update View
	-- --------------
	local bg = self.ui:getChildByName("_scale9Bg")
	self.panelTitle:setText(title)
    local size = self.panelTitle:getContentSize()
    local scale = 65 / size.height
    self.panelTitle:setScale(scale)
    self.panelTitle:setPositionX((bg:getGroupBounds().size.width - size.width * scale) / 2)
    
	self.desLabel:setString(message)

	local confirmBtnKey	= "loading.tips.preloading.warnning.btn"
	local confirmBtnValue	= Localization:getInstance():getText(confirmBtnKey, {})
	self.confirmBtn:setString(confirmBtnValue)
	self.confirmBtn:setColorMode(kGroupButtonColorMode.blue)

	local cancelBtnKey	= "button.cancel"
	local cancelBtnValue	= Localization:getInstance():getText(cancelBtnKey, {})
	self.cancelBtn:setString(cancelBtnValue)

	----------------------
	-- Add Event Listener
	-- -------------------
	
	local function onConfirmBtnTapped(event)
		if okCallback ~= nil then okCallback() end
		self:onConfirmBtnTapped(event)
	end
	self.confirmBtn:addEventListener(DisplayEvents.kTouchTap, onConfirmBtnTapped)

	local function onCancelBtnTapped(event)
		if cancelCallback ~= nil then cancelCallback() end
		self:onCancelBtnTapped(event)
	end
	self.cancelBtn:addEventListener(DisplayEvents.kTouchTap, onCancelBtnTapped)
end

function QQSyncPanel:onConfirmBtnTapped(event, ...)
	self:onCloseBtnTapped()
end

function QQSyncPanel:onCancelBtnTapped(event, ...)
	self:onCloseBtnTapped()
end

function QQSyncPanel:popout(...)
	assert(#{...} == 0)

	PopoutManager:sharedInstance():add(self, true, false)
	self:setToScreenCenterHorizontal()
	self:setToScreenCenterVertical()
	self.allowBackKeyTap = true
end

function QQSyncPanel:onCloseBtnTapped(...)
	assert(#{...} == 0)

	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self, true)
end

function QQSyncPanel:create(title,message,okCallback,cancelCallback)
	local newQQSyncPanel = QQSyncPanel.new()
	newQQSyncPanel:loadRequiredResource(PanelConfigFiles.panel_game_setting)
	newQQSyncPanel:init(title,message,okCallback,cancelCallback)
	return newQQSyncPanel
end

function QQSyncPanel:loadRequiredResource( panelConfigFile )
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:create(panelConfigFile)
end

function QQSyncPanel:onKeyBackClicked( ... )
	if self.cancelCallback then self.cancelCallback() end
	self:onCloseBtnTapped()
end

function QQSyncPanel:getHCenterInScreenX(...)
	assert(#{...} == 0)

	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local selfWidth		= 715

	local deltaWidth	= visibleSize.width - selfWidth
	local halfDeltaWidth	= deltaWidth / 2

	return visibleOrigin.x + halfDeltaWidth
end