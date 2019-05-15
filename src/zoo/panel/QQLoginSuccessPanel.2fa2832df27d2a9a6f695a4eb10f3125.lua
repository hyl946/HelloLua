
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2014Äê01ÔÂ 1ÈÕ 14:53:58
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- QQLoginSuccessPanel
---------------------------------------------------

assert(not QQLoginSuccessPanel)
assert(BasePanel)
QQLoginSuccessPanel = class(BasePanel)

function QQLoginSuccessPanel:init(title,message)

	----------------------
	-- Get UI Componenet
	-- -----------------
	self.ui	= self:buildInterfaceGroup("qqloginsuccesspanel")--ResourceManager:sharedInstance():buildGroup("QQLoginSuccessPanel")

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
    self.closeBtn	= self.ui:getChildByName("closeBtn")

	assert(self.panelTitle)
	assert(self.desLabel)
	assert(self.confirmBtnRes)

	--------------------
	-- Create UI Componenet
	-- ----------------------
	self.confirmBtn		= GroupButtonBase:create(self.confirmBtnRes)

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
	-- self.desLabel:setString(message)

	local function setRichText(textLabel, str)
		textLabel:setVisible(false)
		local width = textLabel:getDimensions().width
		local pos = textLabel:getPosition()
		local richText = TextUtil:buildRichText(str, width, textLabel:getFontName(), textLabel:getFontSize(), textLabel:getColor())
		richText:setPosition(ccp(pos.x, pos.y))
		self.ui:addChildAt(richText, textLabel:getZOrder())
	end
	setRichText(self.desLabel, message)

	local confirmBtnKey	= "button.ok"
	local confirmBtnValue = Localization:getInstance():getText(confirmBtnKey, {})
	self.confirmBtn:setString(confirmBtnValue)

	----------------------
	-- Add Event Listener
	-- -------------------
	
	local function onConfirmBtnTapped(event)
		self:onConfirmBtnTapped(event)
	end
	self.confirmBtn:addEventListener(DisplayEvents.kTouchTap, onConfirmBtnTapped)

    self.closeBtn:setTouchEnabled(true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, onConfirmBtnTapped)
end

function QQLoginSuccessPanel:onConfirmBtnTapped(event, ...)
	self:onCloseBtnTapped()
end

function QQLoginSuccessPanel:popout(...)
	assert(#{...} == 0)

	self.popoutShowTransition = function( ... )
		local parent = self:getParent()
		if parent then
			self:setToScreenCenterHorizontal()
			self:setToScreenCenterVertical()		
		end		
		self.allowBackKeyTap = true
	end

	PopoutQueue:sharedInstance():push(self, true, false)
end

function QQLoginSuccessPanel:setCloseButtonCallback( func )
	self.closeButtonCallback = func
end

function QQLoginSuccessPanel:onCloseBtnTapped(...)
	assert(#{...} == 0)

	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self, true)

	local scene = Director.sharedDirector():getRunningScene()
	if scene then 
		local homeScene = tolua.cast(scene,"HomeScene")
		if homeScene then homeScene:updateButtons() end
	end

	if type(self.closeButtonCallback) == "function" then
		self.closeButtonCallback()
	end
end

function QQLoginSuccessPanel:create(title,message)
	local newQQLoginSuccessPanel = QQLoginSuccessPanel.new()
	newQQLoginSuccessPanel:loadRequiredResource(PanelConfigFiles.panel_game_setting)
	newQQLoginSuccessPanel:init(title,message)
	return newQQLoginSuccessPanel
end

function QQLoginSuccessPanel:loadRequiredResource( panelConfigFile )
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:create(panelConfigFile)
end

function QQLoginSuccessPanel:getHCenterInScreenX(...)
	assert(#{...} == 0)

	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local selfWidth		= 715

	local deltaWidth	= visibleSize.width - selfWidth
	local halfDeltaWidth	= deltaWidth / 2

	return visibleOrigin.x + halfDeltaWidth
end