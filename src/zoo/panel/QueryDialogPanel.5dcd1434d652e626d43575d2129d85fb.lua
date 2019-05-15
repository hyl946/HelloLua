
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2014Äê01ÔÂ 1ÈÕ 14:53:58
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- QueryDialogPanel
---------------------------------------------------

assert(not QueryDialogPanel)
assert(BasePanel)
QueryDialogPanel = class(BasePanel)

function QueryDialogPanel:init(title,message,okCallback,cancelCallback)

	----------------------
	-- Get UI Componenet
	-- -----------------
	self.ui	= self:buildInterfaceGroup("querydialogpanel")--ResourceManager:sharedInstance():buildGroup("QueryDialogPanel")

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

	self.okCallback 	= okCallback
	self.cancelCallback	= cancelCallback

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

function QueryDialogPanel:onConfirmBtnTapped(event, ...)
	self:onCloseBtnTapped()
end

function QueryDialogPanel:onCancelBtnTapped(event, ...)
	self:onCloseBtnTapped()
end

function QueryDialogPanel:popout(...)
	assert(#{...} == 0)

	PopoutManager:sharedInstance():add(self, true, false)
	self:setToScreenCenterHorizontal()
	self:setToScreenCenterVertical()
	self.allowBackKeyTap = true
end

function QueryDialogPanel:onCloseBtnTapped(...)
	assert(#{...} == 0)

	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self, true)
end

function QueryDialogPanel:create(title,message,okCallback,cancelCallback)
	local newQueryDialogPanel = QueryDialogPanel.new()
	newQueryDialogPanel:loadRequiredResource(PanelConfigFiles.panel_game_setting)
	newQueryDialogPanel:init(title,message,okCallback,cancelCallback)
	return newQueryDialogPanel
end

function QueryDialogPanel:loadRequiredResource( panelConfigFile )
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:create(panelConfigFile)
end

function QueryDialogPanel:getHCenterInScreenX(...)
	assert(#{...} == 0)

	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local selfWidth		= 715

	local deltaWidth	= visibleSize.width - selfWidth
	local halfDeltaWidth	= deltaWidth / 2

	return visibleOrigin.x + halfDeltaWidth
end

function QueryDialogPanel:onKeyBackClicked()
	if self.cancelCallback ~= nil then self.cancelCallback() end
	self:onCancelBtnTapped()
end