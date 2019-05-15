require 'zoo.panel.basePanel.BasePanel'

require 'zoo.panel.quickselect.StarAchievenmentBasicInfo'
require 'zoo.panel.quickselect.TabLevelArea'
require 'zoo.panel.quickselect.TabFourStarLevel'
require 'zoo.panel.quickselect.TabHiddenLevel'
require 'zoo.panel.quickselect.TabAskForHelp'
require 'zoo.panel.quickselect.NewMoreStarPanel'
require 'zoo.panel.quickselect.FourStarGuideIcon'
require("zoo/panel/quickselect/StarAchievenmentPanel_ListPanel.lua")
require("zoo/panel/quickselect/StarAchievenmentPanel_DownBar.lua")
local UIHelper = require 'zoo.panel.UIHelper'
local XFLogic = require 'zoo.panel.xfRank.XFLogic'

local winSize = Director:sharedDirector():getWinSize()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()

---------------------------------------------------
---------------------------------------------------
-------------- StarAchievenmentPanel_New
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

StarAchievenmentPanel_New = class(BasePanel)
--__isQQ = PlatformConfig:isQQPlatform()
__isQQ = false
function StarAchievenmentPanel_New:create(areaId)
	local panel = StarAchievenmentPanel_New.new()
	panel:loadRequiredResource( "ui/StarAchievenmentPanel/StarAchievenmentPanel_New.json" )
	-- panel:loadRequiredResource(PanelConfigFiles.four_star_guid)
	panel:init(areaId)
	return panel
end

function StarAchievenmentPanel_New:unloadRequiredResource()

end

function StarAchievenmentPanel_New:init(areaId)

	self._afterPopoutCallbacks = {}

	self:initData()
	
	self:initUI()

end

function StarAchievenmentPanel_New:afterPopout( ... )
	if self.isDisposed then return end
	for k, v in ipairs(self._afterPopoutCallbacks) do
		if _G.isLocalDevelopMode  then printx(100 , "afterPopout k = " ,k ) end
		v()
	end
end

function StarAchievenmentPanel_New:initXFRankButton( ... )
	if self.isDisposed then return end

	if not XFLogic:isEnabled() then
		if _G.isLocalDevelopMode  then printx(100 , "XFLogic isEnabled" ) end
		return
	end

	if XFLogic:needShowPreheatButton() then
		if _G.isLocalDevelopMode  then printx(100 , "XFLogic needShowPreheatButton" ) end
		return 
	end

	-- local UIHelper = require 'zoo.panel.UIHelper'

	local iconAnim = UIHelper:createArmature2('skeleton/xf_icon2', 'xf_icon2/icon')
	iconAnim:gotoAndStopByIndex(1,0)

	local hasIt = XFLogic:readCache('sjsma_first_how_enter_icon_anim') 

	if not hasIt then
		XFLogic:writeCache('sjsma_first_how_enter_icon_anim', true)
		iconAnim:ad(ArmatureEvents.COMPLETE, function ( ... )
			if self.isDisposed then return end
			if iconAnim.isDisposed then return end
			iconAnim:removeAllEventListeners()
			iconAnim:playByIndex(1, 1)
		end)

		table.insert(self._afterPopoutCallbacks, function ( ... )
			if self.isDisposed then return end
			iconAnim:setVisible(true)
			iconAnim:playByIndex(0, 1)
		end)
		iconAnim:setVisible(false)

	else

		if XFLogic:isLFL() and (not XFLogic:hadShowLFLAlert())  then
			table.insert(self._afterPopoutCallbacks, function ( ... )
				if self.isDisposed then return end
				iconAnim:playByIndex(1, 0)
			end)
		end

	end

	local redDot = UIHelper:createUI('ui/xf_homescene_icon.json', 'xf_homescene_icon/redDot')
	redDot:setPosition(ccp(70, -10))

    self.xfIcon = Layer:create()

    local touchLayer = LayerColor:createWithColor(ccc3(255, 0, 0), 110, 100)
    touchLayer:setPosition(ccp(-20, -80))
    touchLayer:setOpacity(0)
    self.xfIcon:addChild(touchLayer)
    self.xfIcon.hitTestPoint = function(ctx, wPos, useGroup)
    	return touchLayer:hitTestPoint(wPos, useGroup)
	end

	self.xfIcon:addChild(iconAnim)

    
	self.xfIcon:addChild(redDot)
	self.xfIcon.redDot = redDot


	self.xfIcon:setPosition(ccp( self.ui:getChildByName('closebtn'):getPosition().x - 20, self.ui:getChildByName('closebtn'):getPosition().y - 80 ))

	self.ui:addChild(self.xfIcon)

    self:onShowedLFLAlert()

    XFLogic:addObserver(self)

    local function closeCallback( ... )
    	if self.isDisposed then return end
    	self:setVisible(true)
    	if _G.isLocalDevelopMode  then printx(100 , "XFLogic closeCallback " ) end
    	if _G.isLocalDevelopMode  then printx(100 , "XFLogic closeCallback " ) end
    	if _G.isLocalDevelopMode  then printx(100 , "XFLogic closeCallback " ) end
    	if _G.isLocalDevelopMode  then printx(100 , "XFLogic closeCallback " ) end
    end 

    local function closeAllCallback( ... )
    	if self.isDisposed then return end

    	if _G.isLocalDevelopMode  then printx(100 , "XFLogic closeAllCallback " ) end
    	if _G.isLocalDevelopMode  then printx(100 , "XFLogic closeAllCallback " ) end
    	if _G.isLocalDevelopMode  then printx(100 , "XFLogic closeAllCallback " ) end
    	if _G.isLocalDevelopMode  then printx(100 , "XFLogic closeAllCallback " ) end
    	if _G.isLocalDevelopMode  then printx(100 , "XFLogic closeAllCallback " ) end
    	self:onCloseBtnTapped()
    end 


    UIUtils:setTouchHandler(self.xfIcon, function ( ... )
		if self.isDisposed then return end
		XFLogic:popoutMainPanel(nil, function ( ... )
			if self.isDisposed then return end
			self:setVisible(false)
		end , nil , closeCallback , closeAllCallback )

		DcUtil:openStarAchWIthID( 3 )
	end)

end


function StarAchievenmentPanel_New:onShowedLFLAlert( ... )

	if self.isDisposed then return end
	if not self.xfIcon then return end
	if self.xfIcon.isDisposed then return end

	if XFLogic:isLFL() and (not XFLogic:hadShowLFLAlert()) then
    	self.xfIcon.redDot:setVisible(true)
    else
    	self.xfIcon.redDot:setVisible(false)
    end
end

function StarAchievenmentPanel_New:initUI()
	self.ui = self:buildInterfaceGroup("StarAchievenmentPanel_New/mainpanel")

	UIUtils:adjustUI(self.ui, 180, nil, nil, 1724, nil)

	BasePanel.init(self, self.ui, "StarAchievenmentPanel_New")

	if self.ui:getChildByName('starrankmainicon') then
		self.ui:getChildByName('starrankmainicon'):setVisible(false)
	end
	
	-- local function onCloseTap( ... )
	-- 	self:dispatchEvent(Event.new(FourStarGuideEvent.kReturnQuickSelectPanel))
	-- 	self:onCloseBtnTapped()
	-- end
	
	UIUtils:setTouchHandler(  self.ui:getChildByName('closebtn') , function ()
        self:onCloseBtnTapped(  )
     end)
	-- UIUtils:setTouchHandler(  self.ui:getChildByName('starrankmainicon') , function ()
 --        self:onCloseBtnTapped(  )
 --     end)
	UIUtils:setTouchHandler(  self.ui:getChildByName('tab1_nor') , function ()
        self:upteTabByID( 1 )
     end)
	UIUtils:setTouchHandler(  self.ui:getChildByName('tab2_nor') , function ()
        self:upteTabByID( 2 )
     end)
	UIUtils:setTouchHandler(  self.ui:getChildByName('tab3_nor') , function ()
        self:upteTabByID( 3 )
     end)

	self:upteTabByID( 1 )

	
	local bg = Sprite:create("ui/StarAchievenmentPanel/mainbg.png")
    bg:setAnchorPoint(ccp(0, 1))
    self.ui:addChildAt(bg, 0)
    
    

end

function StarAchievenmentPanel_New:initData()

	-- self.fourStarDataListCount = #FourStarManager:getInstance():getAllNotToFourStarLevels()
	-- self.hiddenLevelDataListCount = #FourStarManager:getInstance():getAllNotPerfectHiddenLevels()
	-- self.completeFourStarCount = #FourStarManager:getInstance():getAllCompleteFourStarLevels()
	-- self.completeStar3Count = FourStarManager:getInstance():getAllUnlockStar3LevelsNum()


	
end

function StarAchievenmentPanel_New:updateTitle()

	if self.isDisposed then return end

	if self.updateOnce == true then
        return
    end
    self.updateOnce = true

	self.maintitle = self.ui:getChildByName('maintitle')
	self.closebtn = self.ui:getChildByName('closebtn')

	self.listpanel = StarAchievenmentPanel_ListPanel:create(self)
	self.ui:addChild( self.listpanel )

    self.maintitle:setAnchorPoint( ccp( 0 , 1 ) )
    self.closebtn:setAnchorPoint( ccp( 0 , 1 ) )

    self.listpanel:setAnchorPoint( ccp( 0 , 1 ) )

    -- local worldPos_Close = self.maintitle:convertToWorldSpace(ccp(0,0))
    local vOrigin = Director:sharedDirector():getVisibleOrigin()
    local targetPosY = vOrigin.y + visibleSize.height 
    targetPosY = self.ui:convertToNodeSpace( ccp( 0, targetPosY ) ).y

    local height = visibleSize.height - ( 150 - 66 )
    local nowScale = self.ui:getScale()


    self.maintitle:setPositionY( targetPosY + 66 )
    self.closebtn:setPositionY( targetPosY )

    self.listpanel:setPositionY( targetPosY +66 -150 )
    self.listpanel:setPositionX( 960/2 -688/2 + 5 )
    self.listpanel:setHeight( height / nowScale ,nowScale )

    self.downBar = StarAchievenmentPanel_DownBar:create( self )

    self.ui:addChild( self.downBar )
    -- self.downBar:setAnchorPoint( ccp( 0 , 0 ) )
    self.downBar:setPositionX( 960/2 - 800/2 )

    local nodePos = self.ui:convertToNodeSpace(ccp(0,0))

    self.downBar:setPositionY( nodePos.y +185 +vOrigin.y)

    self.downBar:afterPopout( nowScale )

    if _G.isLocalDevelopMode  then printx(100 , "updateTitle nodePos.y = " , nodePos.y ) end

    self:initXFRankButton()

end



function StarAchievenmentPanel_New:upteTabByID( tabIndex )

	if self.isDisposed then return end

	-- if _G.isLocalDevelopMode  then printx(100 , "upteTabByID tabIndex = " , tabIndex ) end

	for i=1,3 do

		local showSel = i == tabIndex 
		local showNor = i ~= tabIndex 
		-- if _G.isLocalDevelopMode  then printx(100 , "upteTabByID i = showSel = showNor = " , i ,showSel ,showNor ) end

		local tabNode = "tab"..i.."_sel"
		if self.ui:getChildByName( tabNode ) then
			self.ui:getChildByName( tabNode ):setVisible( showSel )
		end
		tabNode = "tab"..i.."_nor"
		if self.ui:getChildByName( tabNode ) then
			self.ui:getChildByName( tabNode ):setVisible( showNor )
		end
	end





end

function StarAchievenmentPanel_New:dispose( ... )
	local scene = HomeScene:sharedInstance()
	if scene then
		if scene.starRewardButton then 
			scene.starRewardButton:updateView() 
		end
	end
	XFLogic:removeObserver(self)
	BasePanel.dispose(self, ...)	-- body

	CCTextureCache:sharedTextureCache():removeTextureForKey(
        CCFileUtils:sharedFileUtils():fullPathForFilename(
            SpriteUtil:getRealResourceName('ui/StarAchievenmentPanel/mainbg.png')
        )
    )
end



function StarAchievenmentPanel_New:updateView()
	if self.isDisposed then return end

	self.basicInfoPanel:updateView()
end

function StarAchievenmentPanel_New:checkGuide()
	if self.isDisposed then return end

	local Guide = require 'zoo.panel.quickselect.StarAchievenmentPanel_NewGuide'
	Guide:create(self)



end



function StarAchievenmentPanel_New:popoutShowTransition()
	if self.isDisposed then return end
	 
	-- local winSize = CCDirector:sharedDirector():getVisibleSize()

	-- local w = 960
	-- local h = 1724

	-- local r = winSize.height / h
	-- if r < 1.0 then
	-- 	self:setScale(r)
	-- end

	-- local x = self:getHCenterInParentX()
	-- local y = self:getVCenterInParentY()
	-- self:setPosition(ccp(x, y))

	self:updateTitle()

	self:afterPopout()

end

function StarAchievenmentPanel_New:popout(close_cb)

	self.allowBackKeyTap = true
	self.close_cb = close_cb
	PopoutQueue:sharedInstance():push(self, true, false)

end


function StarAchievenmentPanel_New:popout_Add(close_cb)

	self.allowBackKeyTap = true
	self.close_cb = close_cb
	PopoutQueue:sharedInstance():add(self, true, false)

end

function StarAchievenmentPanel_New:onCloseBtnTapped( skipModuleNoticeButton )


	PopoutManager:sharedInstance():remove(self, true)

end

