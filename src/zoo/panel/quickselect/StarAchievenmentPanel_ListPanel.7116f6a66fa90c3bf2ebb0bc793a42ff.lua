require 'zoo.panel.basePanel.BasePanel'

require 'zoo.panel.quickselect.StarAchievenmentBasicInfo'


-- require 'zoo.panel.quickselect.TabHiddenLevel'
-- require 'zoo.panel.quickselect.TabAskForHelp'
require 'zoo.panel.quickselect.NewMoreStarPanel'
require 'zoo.panel.quickselect.FourStarGuideIcon'


require("zoo/panel/quickselect/TabLevelArea_New.lua")
require("zoo/panel/quickselect/TabFourStarLevel_New.lua")
require("zoo/panel/quickselect/TabHiddenLevel_New.lua")



local UIHelper = require 'zoo.panel.UIHelper'

local XFLogic = require 'zoo.panel.xfRank.XFLogic'

local winSize = Director:sharedDirector():getWinSize()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()

---------------------------------------------------
---------------------------------------------------
-------------- StarAchievenmentPanel_ListPanel
---------------------------------------------------
---------------------------------------------------


StarAchievenmentPanel_ListPanel = class(BasePanel)
--__isQQ = PlatformConfig:isQQPlatform()
__isQQ = false
function StarAchievenmentPanel_ListPanel:create( hostPanel )
	local panel = StarAchievenmentPanel_ListPanel.new()
	panel.hostPanel = hostPanel
	panel:init()


	return panel
end

function StarAchievenmentPanel_ListPanel:unloadRequiredResource()
end

function StarAchievenmentPanel_ListPanel:init()

	self:initData()
	
	self:initUI()

end


function StarAchievenmentPanel_ListPanel:initData()

	self.fourStarDataListCount = #FourStarManager:getInstance():getAllNotToFourStarLevels()
	self.hiddenLevelDataListCount = #FourStarManager:getInstance():getAllNotPerfectHiddenLevels()
	self.completeFourStarCount = #FourStarManager:getInstance():getAllCompleteFourStarLevels()
	self.completeStar3Count = FourStarManager:getInstance():getAllUnlockStar3LevelsNum()

	if _G.isLocalDevelopMode  then printx(100 , " self.hiddenLevelDataListCount " , self.hiddenLevelDataListCount ) end
	if _G.isLocalDevelopMode  then printx(100 , " self.completeStar3Count " , self.completeStar3Count ) end

end


function StarAchievenmentPanel_ListPanel:onCloseBtnTapped(  )
	self.hostPanel:onCloseBtnTapped()
end

function StarAchievenmentPanel_ListPanel:setHeight( height , nowScale )

	local downBarHeight = 200 

	self.mainpanel_mainbg:setContentSize(CCSizeMake( 688,  (height - 94 -downBarHeight)  ))

	local heightNode = height - 130  - downBarHeight

	self.tab1content1:setContentSize(CCSizeMake( 650, heightNode ) )
	self.tab1content2:setContentSize(CCSizeMake( 650, heightNode ) )
	self.tab1content3:setContentSize(CCSizeMake( 650, heightNode ) )

	self.txtDesc4:setPositionY( - 94 - heightNode + 5 )
	
	self.tab1 = TabLevelArea_New:create( self.tab1content1 ,self ,heightNode)
	self.tab2 = TabHiddenLevel_New:create( self.tab1content2 ,self ,heightNode)
	self.tab3 = TabFourStarLevel_New:create( self.tab1content3 ,self ,heightNode)
		


	self:upteTabByID( 1 )

end

function StarAchievenmentPanel_ListPanel:initUI()

	local ui = UIHelper:createUI('ui/StarAchievenmentPanel/StarAchievenmentPanel_New.json', 'StarAchievenmentPanel_New/listpanel')
    self.ui = ui
	BasePanel.init(self, self.ui, "StarAchievenmentPanel_ListPanel")

	self.mainpanel_mainbg = self.ui:getChildByName('mainpanel_mainbg') 
	self.tab1content1 = self.ui:getChildByName('tab1content1') 
	self.tab1content2 = self.ui:getChildByName('tab1content2') 
	self.tab1content3 = self.ui:getChildByName('tab1content3') 

	self.txtDesc4 = self.ui:getChildByName('txtDesc4') 
	self.txtDesc4 :setString( "还有更多四星关等你发现哦~" )


	self.tab1_nor = self.ui:getChildByName('tab1_nor') 
	self.tab2_nor = self.ui:getChildByName('tab2_nor') 
	self.tab3_nor = self.ui:getChildByName('tab3_nor') 

	self.tab1_sel = self.ui:getChildByName('tab1_sel') 
	self.tab2_sel = self.ui:getChildByName('tab2_sel') 
	self.tab3_sel = self.ui:getChildByName('tab3_sel') 

	UIUtils:setTouchHandler(  self.ui:getChildByName('closebtn') , function ()
        self:onCloseBtnTapped(  )
     end)
	UIUtils:setTouchHandler(  self.ui:getChildByName('starrankmainicon') , function ()
        self:onCloseBtnTapped(  )
     end)

	UIUtils:setTouchHandler(  self.ui:getChildByName('tab1_nor') , function ()
        self:upteTabByID( 1 )
     end , nil , 0.3)
	UIUtils:setTouchHandler(  self.ui:getChildByName('tab2_nor') , function ()
        self:upteTabByID( 2 )
     end,nil , 0.3)
	UIUtils:setTouchHandler(  self.ui:getChildByName('tab3_nor') , function ()
        self:upteTabByID( 3 )
     end,nil , 0.3)

	self.mcUndoneHiddenNumTip1 = getRedNumTip()

	self.mcUndoneHiddenNumTip1:setNum(self.hiddenLevelDataListCount)
	self.mcUndoneHiddenNumTip1:setPositionXY(140, 70)

	self.mcUndoneHiddenNumTip2 = getRedNumTip()

	self.mcUndoneHiddenNumTip2:setNum(self.hiddenLevelDataListCount)
	self.mcUndoneHiddenNumTip2:setPositionXY(140, 50)
	
	self.tab2_sel:addChild( self.mcUndoneHiddenNumTip1  )
	self.tab2_nor:addChild( self.mcUndoneHiddenNumTip2  )

	self.star3NumTip1 = getRedNumTip()

	self.star3NumTip1:setNum(self.completeStar3Count)
	self.star3NumTip1:setPositionXY(140, 70)


	self.star3NumTip2 = getRedNumTip()

	self.star3NumTip2:setNum(self.completeStar3Count)
	self.star3NumTip2:setPositionXY(140, 50)

	self.tab3_sel:addChild( self.star3NumTip1  )
	self.tab3_nor:addChild( self.star3NumTip2  )



end


function StarAchievenmentPanel_ListPanel:upteTabByID( tabIndex )

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

		if self["tab"..i] then
			self["tab"..i]:setVisible( showSel )
		end

	end

	self.txtDesc4:setVisible( tabIndex == 3 )


	DcUtil:openStarAchWIthID( tabIndex - 1  )
end

function StarAchievenmentPanel_ListPanel:dispose( ... )
	BasePanel.dispose(self, ...)	-- body
end



