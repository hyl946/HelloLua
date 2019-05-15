local UIHelper = require 'zoo.panel.UIHelper'
local ActCollectStarsPanel = class(BasePanel)


local ActPanelType = {
	kSuc = 1,
	kFail = 2,
	kStart = 3,
	kReplay = 4,
	KChangeToStar = 5 ,
}

local ContentPos = {
	[ActPanelType.kSuc] = {high = {x = -300, y = 109}, low = {x = -300, y = 99}},
	[ActPanelType.kFail] = {high = {x = -300, y = 109}, low = {x = -300, y = 99}},
	[ActPanelType.kStart] = {high = {x = -290, y = 105}, low = {x = -290, y = 95}},
}
function ActCollectStarsPanel:dispose()
	CollectStarsManager.getInstance():removeObserver(self) 
	BasePanel.dispose(self)
end

function ActCollectStarsPanel:ctor()

end

function ActCollectStarsPanel:onUpdateStarNum()
	self:update()
end



function ActCollectStarsPanel:init()
	local groupName = self:getGroupName()
	if not groupName then 
		return false
	end

	self.ui = self:buildInterfaceGroup(groupName)
    BasePanel.init(self, self.ui)

    CollectStarsManager.getInstance():addObserver(self) 
    self:update()

    return true
end

function ActCollectStarsPanel:update()
	if self.isDisposed then return end

	self.desclabel = self.ui:getChildByName("desclabel")
	local num1 , num2 ,isbigBox= CollectStarsManager.getInstance():getWinNumString() 

	local fntFileName = 'fnt/animal_num.fnt'
	UIHelper:setRightText( self.desclabel  , num1.."/".. num2,  fntFileName )
	
	local progressValue = math.min( num1/num2 , 1 )
	self.progressbar = self.ui:getChildByName("progressbar")

	if _G.isLocalDevelopMode then printx(103, "ActCollectStarsPanel:update num1 = " ,num1) end
	if _G.isLocalDevelopMode then printx(103, "ActCollectStarsPanel:update num2 = " ,num2) end
	if _G.isLocalDevelopMode then printx(103, "ActCollectStarsPanel:update isbigBox = " ,isbigBox) end
	
	self.progressbar:setScaleX( progressValue )
	self.littleleft = self.ui:getChildByName("littleleft")

	self.littleleft:setVisible( num1 > 0  )
	self.box2 = self.ui:getChildByName("box2")
	self.box1 = self.ui:getChildByName("box1")

	self.box1 :setVisible( not isbigBox )
	self.box2 :setVisible(  isbigBox )
end

function ActCollectStarsPanel:getGroupName()
	local groupName = nil


	-- local scene = Director:sharedDirector():getRunningSceneLua()
	-- if scene and not scene:is(HomeScene) then
	-- 	if self.panelType == ActPanelType.kStart and self.params > 0 then 
	-- 		self.panelType = ActPanelType.kReplay
	-- 	end
	-- end

	-- if self.panelType == ActPanelType.kStart then 
	-- 	groupName = "CollectStars2018/ActCollectStarsPanel_start"
	-- elseif self.panelType == ActPanelType.kReplay then 
	-- 	groupName = "CollectStars2018/ActCollectStarsPanel_replay"
	-- elseif self.panelType == ActPanelType.kFail then 
	-- 	groupName = "CollectStars2018/ActCollectStarsPanel_fail"
	-- elseif self.panelType == ActPanelType.KChangeToStar then 
	-- 	groupName = "CollectStars2018/ActCollectStarsPanel_start"
	-- else
	-- 	groupName = "CollectStars2019/mainpanel"
	-- end
	groupName = "CollectStars2019/mainpanel"
	return groupName
end

function ActCollectStarsPanel:playShowAni()
	local oriScale = self.ui:getScaleX()
	self.ui:setScale(0)
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(0.5))
	arr:addObject(CCEaseElasticOut:create(CCScaleTo:create(0.5, oriScale)))
	-- arr:addObject(CCCallFunc:create(function ()
	-- 	-- to do
	-- end))
	self.ui:runAction(CCSequence:create(arr))
end

function ActCollectStarsPanel:create(panelType, params)
	local panel = ActCollectStarsPanel.new()
	panel.panelType = panelType
	panel.params = params
    panel:loadRequiredResource("tempFunctionRes/CollectStars2018/panel.json")
    if panel:init() then 
    	return panel
    end
end

return ActCollectStarsPanel