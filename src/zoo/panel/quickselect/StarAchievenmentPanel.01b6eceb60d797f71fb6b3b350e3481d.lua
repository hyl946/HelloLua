require 'zoo.panel.basePanel.BasePanel'

require 'zoo.panel.quickselect.StarAchievenmentBasicInfo'
require 'zoo.panel.quickselect.TabLevelArea'
require 'zoo.panel.quickselect.TabFourStarLevel'
require 'zoo.panel.quickselect.TabHiddenLevel'
require 'zoo.panel.quickselect.TabAskForHelp'
require 'zoo.panel.quickselect.NewMoreStarPanel'
require 'zoo.panel.quickselect.FourStarGuideIcon'

local XFLogic = require 'zoo.panel.xfRank.XFLogic'


---------------------------------------------------
---------------------------------------------------
-------------- StarAchievenmentPanel
---------------------------------------------------
---------------------------------------------------
-- ResourceManager:sharedInstance():addJsonFile("ui/star_achievement.json")

local function hasAskForHelpTab()
	local info = UserManager.getInstance():getAskForHelpInfo()
	if info and table.size(info) > 0 then
		return true
	end
	return false
end

StarAchievenmentPanel = class(BasePanel)
--__isQQ = PlatformConfig:isQQPlatform()
__isQQ = false
function StarAchievenmentPanel:create(areaId)
	local panel = StarAchievenmentPanel.new()
	panel:loadRequiredResource(PanelConfigFiles.star_achevement)
	-- panel:loadRequiredResource(PanelConfigFiles.four_star_guid)
	panel:init(areaId)
	return panel
end

function StarAchievenmentPanel:unloadRequiredResource()
end

function StarAchievenmentPanel:init(areaId)

	self._afterPopoutCallbacks = {}

	self:initData()
	self.panelLuaName = "StarAchievenmentPanel"
	
	self:initUI()
end
-- function StarAchievenmentPanel:onEnterHandler(event)
-- 	if event == "enter" then
-- 		GameGuide:sharedInstance():onPopup(self)
-- 	end
-- end
function StarAchievenmentPanel:initData()
	self.fourStarDataListCount = #FourStarManager:getInstance():getAllNotToFourStarLevels()
	self.hiddenLevelDataListCount = #FourStarManager:getInstance():getAllNotPerfectHiddenLevels()
	self.completeFourStarCount = #FourStarManager:getInstance():getAllCompleteFourStarLevels()
	self.completeStar3Count = FourStarManager:getInstance():getAllUnlockStar3LevelsNum()

end

function StarAchievenmentPanel:initUI()
	self.ui = self:buildInterfaceGroup("new_star/panel")

	BasePanel.init(self, self.ui, "StarAchievenmentPanel")

	local function onCloseTap( ... )
		self:dispatchEvent(Event.new(FourStarGuideEvent.kReturnQuickSelectPanel))
		self:onCloseBtnTapped()
	end
	
	local vSize = CCDirector:sharedDirector():getVisibleSize()
	local wSize = CCDirector:sharedDirector():getWinSize()
	local vOrigin = CCDirector:sharedDirector():getVisibleOrigin()

	local size = self:getGroupBounds().size
	local scaleY = math.min(vSize.height/(1280 * vSize.width / 720), 1)
	local scaleX = math.min(vSize.width / (720 * vSize.height / 1280), 1)
	self:setScale(math.min(scaleY, scaleX))
	-- if _G.isLocalDevelopMode then printx(0, "self:getGroupBounds().size",size.width,size.height,"scale",self:getScale()) end

	-- self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()
	-- 这个面板有点特殊，需要顶部对齐
	self:setPositionY(0 )

	-----------------------
	-- Create UI Component
	-- -------------------	
	self.head = self.ui:getChildByName("mc_head")
	self.body = self.ui:getChildByName("mc_body")

	self.basicInfoPanel = StarBasicInfoPanel:create(self.head:getChildByName("basic_info"), self)

	self.txtDesc = self.body:getChildByName("txtDesc")
	self.txtDesc4 = self.body:getChildByName("txtDesc4")
	if self.txtDesc4 then
		self.txtDesc4:setString(" ")
	end

	self.title_full_hidden = self.body:getChildByName("title_full_hidden")
	self.title_full_four_star = self.body:getChildByName("title_full_four_star")		

	self.title_full_hidden:setVisible(false)
	self.title_full_four_star:setVisible(false)

	self.mcUndoneHiddenNumTip = getRedNumTip()
	self.body:addChild(self.mcUndoneHiddenNumTip)
	self.mcUndoneHiddenNumTip:setNum(self.hiddenLevelDataListCount)
	self.mcUndoneHiddenNumTip:setPositionXY(595, -548)
	if hasAskForHelpTab() then
		self.mcUndoneHiddenNumTip:setPositionXY(460, -550)
	end


	self.star3NumTip = getRedNumTip()
	self.body:addChild(self.star3NumTip)
	self.star3NumTip:setNum(self.completeStar3Count)
	self.star3NumTip:setPositionXY(425, -548)
	if hasAskForHelpTab() then
		self.star3NumTip:setPositionXY(333, -550)
	end

	-- self.start3Layer = self:buildInterfaceGroup("start3Layer")
	-- self.start4Layer = self:buildInterfaceGroup("start4Layer")

	self.tab1 = TabLevelArea:create(self.body:getChildByName("tabLevelArea"),self)
	self.tab2 = TabFourStarLevel:create(self.body:getChildByName("tabFourStarLevel"),self )
	self.tab3 = TabHiddenLevel:create(self.body:getChildByName("tabHiddenLevel"),self)
	if hasAskForHelpTab() then
		self.tab4 = TabAskForHelp:create(self.body:getChildByName("tabAskForHelp"), self)
	end

	if hasAskForHelpTab() then
		self.body:getChildByName("mc_tab"):setVisible(false)
		self.tab = StarAchievenmentTab:create(self.body:getChildByName("mc_tab4"), 4)
	else
		self.body:getChildByName("tabAskForHelp"):setVisible(false)
		self.body:getChildByName("mc_tab4"):setVisible(false)
		self.tab = StarAchievenmentTab:create(self.body:getChildByName("mc_tab"))
	end

	self.tab:bind(self.tab.tabbutton1,self.tab1)
	self.tab:bind(self.tab.tabbutton2,self.tab2)
	self.tab:bind(self.tab.tabbutton3,self.tab3)
	if hasAskForHelpTab() then
		self.tab:bind(self.tab.tabbutton4, self.tab4)
	end

	self:updateView()

	-- init state ---
	self.tab.tabbutton1:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchTap, self.tab.tabbutton1))

	-- 处理应用宝相关
	if (__isQQ) then
		self.closeButton = self:createTouchButtonBySprite(self.body:getChildByName("close_btn"), onCloseTap)
		self.head:getChildByName("close_btn"):setVisible(false)
		self.head:setVisible(false)
		self.body:getChildByName("leaf_l"):setVisible(false)
		self.body:getChildByName("leaf_r"):setVisible(false)
	else
		self.closeButton = self:createTouchButtonBySprite(self.head:getChildByName("close_btn"), onCloseTap)
		self.body:getChildByName("close_btn"):setVisible(false)
		self.body:getChildByName("title2"):setVisible(false)
	end

	self:initXFRankButton()
end

function StarAchievenmentPanel:initXFRankButton( ... )
	if self.isDisposed then return end

	if not XFLogic:isEnabled() then
		return
	end

	if XFLogic:needShowPreheatButton() then
		return 
	end

	local UIHelper = require 'zoo.panel.UIHelper'
	local iconAnim

	if XFLogic:readCache('show_enter_icon_anim') then
		XFLogic:writeCache('show_enter_icon_anim', false)
		iconAnim = UIHelper:createArmature2('skeleton/xf_icon', 'xf_icon/icon1')
		iconAnim:ad(ArmatureEvents.COMPLETE, function ( ... )
			if self.isDisposed then return end
			if iconAnim.isDisposed then return end
			iconAnim:removeFromParentAndCleanup(true)
			local iconAnim2 = UIHelper:createArmature2('skeleton/xf_icon', 'xf_icon/icon2')
			self.xfIcon:addChild(iconAnim2)
			iconAnim2:playByIndex(0, 1)
		end)

		table.insert(self._afterPopoutCallbacks, function ( ... )
			if self.isDisposed then return end
			iconAnim:setVisible(true)
			iconAnim:playByIndex(0, 1)
		end)
		iconAnim:setVisible(false)

	else
		iconAnim = UIHelper:createArmature2('skeleton/xf_icon', 'xf_icon/icon3')

		if XFLogic:isLFL() and (not XFLogic:hadShowLFLAlert()) then
			table.insert(self._afterPopoutCallbacks, function ( ... )
				if self.isDisposed then return end
				iconAnim:playByIndex(0, 1)
			end)
		end

	end



	local redDot = UIHelper:createUI('ui/xf_homescene_icon.json', 'xf_homescene_icon/redDot')
	redDot:setPosition(ccp(20, 60))



    self.xfIcon = Layer:create()

    local touchLayer = LayerColor:createWithColor(ccc3(255, 0, 0), 110, 100)
    touchLayer:setPosition(ccp(-55, -35))
    touchLayer:setOpacity(0)
    self.xfIcon:addChild(touchLayer)
    self.xfIcon.hitTestPoint = function(ctx, wPos, useGroup)
    	return touchLayer:hitTestPoint(wPos, useGroup)
	end

	self.xfIcon:addChild(iconAnim)

    
	self.xfIcon:addChild(redDot)
	self.xfIcon.redDot = redDot

	self.xfIcon:setPosition(ccp(634, -486))


	self.body:addChild(self.xfIcon)

    self:onShowedLFLAlert()

    XFLogic:addObserver(self)

    UIUtils:setTouchHandler(self.xfIcon, function ( ... )
		if self.isDisposed then return end
		XFLogic:popoutMainPanel(nil, function ( ... )
			if self.isDisposed then return end
			self:onCloseBtnTapped()
		end)
	end)
end

function StarAchievenmentPanel:dispose( ... )
	XFLogic:removeObserver(self)
	BasePanel.dispose(self, ...)	-- body
end

function StarAchievenmentPanel:onShowedLFLAlert( ... )

	if self.isDisposed then return end
	if not self.xfIcon then return end
	if self.xfIcon.isDisposed then return end

	if XFLogic:isLFL() and (not XFLogic:hadShowLFLAlert()) then
    	self.xfIcon.redDot:setVisible(true)
    else
    	self.xfIcon.redDot:setVisible(false)
    end
end

function StarAchievenmentPanel:updateView()
	self.basicInfoPanel:updateView()
end

function StarAchievenmentPanel:checkGuide()
	--if not PlatformConfig:isQQPlatform() then
		local Guide = require 'zoo.panel.quickselect.StarAchievenmentPanelGuide'
		Guide:create(self)
	--end
end

function StarAchievenmentPanel:afterPopout( ... )
	if self.isDisposed then return end
	for _, v in ipairs(self._afterPopoutCallbacks) do
		v()
	end
end

function StarAchievenmentPanel:popoutShowTransition()
	self:checkGuide()

	local headToY = self.head:getPositionY()

	local bodyToY = false
	if (__isQQ) then
		headToY = self.head:getPositionY() + 3000
		bodyToY = self.body:getPositionY() + 200
	else
		bodyToY = self.body:getPositionY()
	end

	self.head:setPositionY(headToY+700)
	self.body:setPositionY(bodyToY+1300)

	self.head:runAction(CCEaseElasticOut:create(CCMoveBy:create(0.6, ccp(0,-700))))


	local array = CCArray:create()
	array:addObject(CCDelayTime:create(0.1))
	array:addObject(CCEaseElasticOut:create(CCMoveBy:create(0.8, ccp(0,-1300)),0.7))
	array:addObject(CCCallFunc:create(function ( ... )
		if self.isDisposed then return end
		self:afterPopout()
	end))
	self.body:runAction(CCSequence:create(array))
	-- he_dumpGLObjectRefs()
end

function StarAchievenmentPanel:popout(close_cb)
	self.allowBackKeyTap = true
	self.close_cb = close_cb
	PopoutQueue:sharedInstance():push(self, true, false)
end

function StarAchievenmentPanel:onCloseBtnTapped( skipModuleNoticeButton )
	PopoutManager:sharedInstance():remove(self, true)
	if self.bgLayer then 
		self.bgLayer:removeFromParentAndCleanup(true)
	end
	self.allowBackKeyTap = false

	if skipModuleNoticeButton then
		ModuleNoticeButton:setPlayNext(false)
	else
		ModuleNoticeButton:tryPopoutStartGamePanel()
	end

	if self.close_cb then self.close_cb() end
end



---------------------------------------------------
---------------------------------------------------
-------------- StarAchievenmentTab
---------------------------------------------------
---------------------------------------------------


assert(not StarAchievenmentTab)
assert(BaseUI)
StarAchievenmentTab = class(BaseUI)

function StarAchievenmentTab:create(ui, items)
	local panel = StarAchievenmentTab.new()
	panel:init(ui, items)
	return panel
end

function StarAchievenmentTab:init(ui, items)
	BaseUI.init(self, ui)

	self:initData(items)

	self:initUI()
end

function StarAchievenmentTab:initData(items)
	-- mapping tab button and view
	self.mapping = {}
	self.items = items or 3
end

function StarAchievenmentTab:initUI()
	self.radioGroup = StarAchievenmentRadioButtonGroup:create(self)

	for i=1, self.items do
		self["tabbutton" ..i] = self:buildTabBtn(self.ui:getChildByName("tabbutton" ..i), i)
		self.radioGroup:add(self["tabbutton" ..i])
	end
end

function StarAchievenmentTab:bind(button,view)
	self.mapping[button] = view
end

function StarAchievenmentTab:buildTabBtn(btnUI, index)
	local normalUI = btnUI:getChildByName('normal')
	local selectedUI = btnUI:getChildByName('selected')
	for i = 1, 4 do
		normalUI:getChildByName('label_'..i):setVisible(i == index)
		selectedUI:getChildByName('label_'..i):setVisible(i == index)
	end
	normalUI:setVisible(index ~= 1)
	selectedUI:setVisible(index == 1)

	btnUI:setTouchEnabled(true)
	btnUI:setButtonMode(true)

	function btnUI:setSelect( bSelected )
		selectedUI:setVisible(bSelected)
		normalUI:setVisible(not bSelected)
	end

	return btnUI
end

---------------------------------------------------
---------------------------------------------------
-------------- StarAchievenmentRadioButtonGroup
---------------------------------------------------
---------------------------------------------------
StarAchievenmentRadioButtonGroup = class()

function StarAchievenmentRadioButtonGroup:create(tab)
	local clazz = StarAchievenmentRadioButtonGroup.new()
	clazz.tab = tab
	clazz.content = {}
	return clazz
end

function StarAchievenmentRadioButtonGroup:add(button)

	local function onButtonTapped()
		for _,v in ipairs(self.content) do
			v:setSelect(false)	
		end
		button:setSelect(true)		

		for but,view in pairs(self.tab.mapping) do
			view:setVisible(false)
		end
		self.tab.mapping[button]:setVisible(true)
	end

	table.insert(self.content,button)
	button:addEventListener(DisplayEvents.kTouchTap, onButtonTapped)
end











