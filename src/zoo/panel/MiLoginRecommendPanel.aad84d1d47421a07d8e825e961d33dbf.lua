----------------------------------------------
--
-- dan.liang 2014/09/01
--
----------------------------------------------
assert(not MiLoginRecommendPanel)
assert(BasePanel)
MiLoginRecommendPanel = class(BasePanel)

function MiLoginRecommendPanel:create(onCancel)
	local newPanel = MiLoginRecommendPanel.new()
	newPanel:loadRequiredResource(PanelConfigFiles.panel_game_setting)
	newPanel:init(onCancel)
	return newPanel
end

function MiLoginRecommendPanel:init(onCancel)

	self.onCancel = onCancel
	----------------------
	-- Get UI Componenet
	-- -----------------
	self.ui	= self:buildInterfaceGroup("miloginrecommendpanel")

	--------------------
	-- Init Base Class
	-- --------------
	BasePanel.init(self, self.ui)

	-------------------
	-- Get UI Componenet
	-- -----------------
	self.closeBtn		= self.ui:getChildByName("closeBtn")
	-- self.panelTitle		= self.ui:getChildByName("panelTitle")
	self.infoLabel		= self.ui:getChildByName("infoLabel")
	self.normalBtnGrp	= self.ui:getChildByName("normalBtn")
	self.recommendBtnGrp= self.ui:getChildByName("recommendBtn")

	--------------------
	-- Create UI Componenet
	-- ----------------------
	self.normalBtn		= GroupButtonBase:create(self.normalBtnGrp)
	self.recommendBtn	= GroupButtonBase:create(self.recommendBtnGrp)

	--------------
	-- Init UI
	-- ----------
	self.ui:setTouchEnabled(true, 0, true)

	----------------
	-- Update View
	-- --------------
	-- self.panelTitle:setString(title)

	-- self.infoLabel:setString("游戏数据读取成功，因为开心消消乐新版本不再支持微博账号登录，建议您绑定小米账号，获得更多好友，谢谢~")
	self.infoLabel:setDimensions(CCSizeMake(510, 0))
	self.recommendBtn:setColorMode(kGroupButtonColorMode.green)
	-- self.recommendBtn:setString("绑定小米账号")

	self.normalBtn:setColorMode(kGroupButtonColorMode.blue)
	-- self.normalBtn:setString("下次再说")

	local function onCloseBtnTapped(event)
		if _G.isLocalDevelopMode then printx(0, "MiLoginRecommendPanel.onCloseBtnTapped") end
		self:onCloseBtnTapped()
	end
	self.closeBtn:setTouchEnabled(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, onCloseBtnTapped)

	self:setPositionForPopoutManager()
end

function MiLoginRecommendPanel:popout(...)
	assert(#{...} == 0)

	PopoutManager:sharedInstance():add(self, true, false)

	local parent = self:getParent()
	if parent then
		self:setToScreenCenterHorizontal()
		self:setToScreenCenterVertical()		
	end
	self.allowBackKeyTap = true
end

function MiLoginRecommendPanel:onCloseBtnTapped(...)
	assert(#{...} == 0)

	self:dismiss()
	if self.onCancel then self.onCancel() end
end

function MiLoginRecommendPanel:dismiss( ... )
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self, true)
end

function MiLoginRecommendPanel:loadRequiredResource( panelConfigFile )
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:create(panelConfigFile)
end
