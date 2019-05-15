----------------------------------------------
--
-- dan.liang 2014/08/29
--
----------------------------------------------
assert(not MiLoginSelectPanel)
assert(BasePanel)
MiLoginSelectPanel = class(BasePanel)

function MiLoginSelectPanel:create(onSelect, onCancel)
	local newPanel = MiLoginSelectPanel.new()
	newPanel:loadRequiredResource(PanelConfigFiles.panel_game_setting)
	newPanel:init(onSelect, onCancel)
	return newPanel
end

function MiLoginSelectPanel:init(onSelect, onCancel)
	self.onSelect = onSelect
	self.onCancel = onCancel
	----------------------
	-- Get UI Componenet
	-- -----------------
	self.ui	= self:buildInterfaceGroup("miloginselectpanel")
	--------------------
	-- Init Base Class
	-- --------------
	BasePanel.init(self, self.ui)

	-------------------
	-- Get UI Componenet
	-- -----------------
	self.closeBtn		= self.ui:getChildByName("closeBtn")
	self.panelTitle		= self.ui:getChildByName("panelTitle")
	self.firstBtnGrp	= self.ui:getChildByName("firstBtn")
	self.firstBtnDes	= self.ui:getChildByName("firstBtnDes")
	self.secondBtnGrp	= self.ui:getChildByName("secondBtn")
	self.secondBtnDes	= self.ui:getChildByName("secondBtnDes")

	--------------------
	-- Create UI Componenet
	-- ----------------------
	self.firstBtn		= GroupButtonBase:create(self.firstBtnGrp)
	self.secondBtn		= GroupButtonBase:create(self.secondBtnGrp)

	--------------
	-- Init UI
	-- ----------
	self.ui:setTouchEnabled(true, 0, true)

	----------------
	-- Update View
	-- --------------
	local title = Localization:getInstance():getText("loading.tips.choosing.login.sns.tittle")
	self.panelTitle:setString(title)

	self.firstBtn:setColorMode(kGroupButtonColorMode.green)
	local pfMi = Localization:getInstance():getText("platform.mi")
	self.firstBtn:setString(Localization:getInstance():getText("loading.tips.start.btn.qq", {platform=pfMi}))
	self.firstBtnDes:setString(Localization:getInstance():getText("mi.login.tips"))
	local btn1Size = self.firstBtn:getGroupBounds().size
	self.firstBtnDes:setDimensions(CCSizeMake(btn1Size.width, 0))

	self.secondBtn:setColorMode(kGroupButtonColorMode.blue)
	local pfWeibo = Localization:getInstance():getText("platform.weibo")
	self.secondBtn:setString(Localization:getInstance():getText("loading.tips.start.btn.qq", {platform=pfWeibo}))
	self.secondBtnDes:setString(Localization:getInstance():getText("weibo.login.tips.for.mi"))
	local btn2Size = self.secondBtn:getGroupBounds().size
	self.secondBtnDes:setDimensions(CCSizeMake(btn2Size.width + 50, 0))

	-- add listeners
	local function onMiLoginBtnTapped(evt)
		self:onDismiss()
		if self.onSelect then self.onSelect(PlatformAuthEnum.kMI) end
	end
	self.firstBtn:addEventListener(DisplayEvents.kTouchTap, onMiLoginBtnTapped)

	local function onWeiboLoginBtnTapped(evt)
		self:onDismiss()
		if self.onSelect then self.onSelect(PlatformAuthEnum.kWeibo) end
	end
	self.secondBtn:addEventListener(DisplayEvents.kTouchTap, onWeiboLoginBtnTapped)

	local function onCloseBtnTapped(evt)
		self:onCloseBtnTapped()
	end
	self.closeBtn:setTouchEnabled(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, onCloseBtnTapped)

	self:setPositionForPopoutManager()
end

function MiLoginSelectPanel:popout(...)
	assert(#{...} == 0)

	PopoutManager:sharedInstance():add(self, true, false)

	local parent = self:getParent()
	if parent then
		self:setToScreenCenterHorizontal()
		self:setToScreenCenterVertical()		
	end
	self.allowBackKeyTap = true
end

function MiLoginSelectPanel:onCloseBtnTapped(...)
	assert(#{...} == 0)

	self:onDismiss()
	if self.onCancel then self.onCancel() end
end

function MiLoginSelectPanel:onDismiss( ... )
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self, true)
end

function MiLoginSelectPanel:loadRequiredResource( panelConfigFile )
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:create(panelConfigFile)
end

