local TurnTable2019CollectionPanel = class(BasePanel)


local ActPanelType = {
	kSuc = 1,
	kFail = 2,
	kStart = 3,
}

function TurnTable2019CollectionPanel:ctor()
end

function TurnTable2019CollectionPanel:init()
	local groupName = self:getGroupName()
	if not groupName then 
		return false
	end
	self.ui = self:buildInterfaceGroup(groupName)
    BasePanel.init(self, self.ui)

    self.tip1 = self.ui:getChildByName("text1")
    self.tip2 = self.ui:getChildByName("text2")

    self.gold = self.ui:getChildByName("gold")
    self.silver = self.ui:getChildByName("silver")
    
    self.tip1:setVisible(false)
    self.tip2:setVisible(false)
    self.gold:setVisible(false)
    self.silver:setVisible(false)

    self:update()
    return true
end

function TurnTable2019CollectionPanel:update()
	if self.isDisposed then return end

    local levelPlayedCount
    local canGetInfo
    if self.panelType == ActPanelType.kStart then
        levelPlayedCount = TurnTable2019Manager.getInstance():getLevelPlayedCount( self.levelId )
        canGetInfo = TurnTable2019Manager.getInstance():curLevelCanGet( self.levelId, levelPlayedCount )
    else
        levelPlayedCount = TurnTable2019Manager.getInstance().levelPlayedCount
        canGetInfo = TurnTable2019Manager.getInstance().curLevelCanGetInfo
    end
    
    if levelPlayedCount == 0 then
        self.tip1:setVisible(true)
    else
        self.tip2:setVisible(true)
    end

    local ticketNum = canGetInfo.ticketNum
    if canGetInfo.TicketType == 1 then
        --银
        self.silver:setVisible(true)

        local ticketNum = BitmapText:create( "x"..ticketNum ,"fnt/friends1.fnt")
        ticketNum:setAnchorPoint(ccp(0, 0.5))
        ticketNum:setScale(1.5)
        ticketNum:setPosition(ccp(73,35))
        self.silver:addChild(ticketNum)
    elseif canGetInfo.TicketType == 2 then
        --金
        self.gold:setVisible(true)

        local ticketNum = BitmapText:create( "x"..ticketNum ,"fnt/friends1.fnt")
        ticketNum:setAnchorPoint(ccp(0, 0.5))
        ticketNum:setScale(1.5)
        ticketNum:setPosition(ccp(73,35))
        self.gold:addChild(ticketNum)
    end
end

function TurnTable2019CollectionPanel:getGroupName()
	local groupName = nil
	if self.panelType == ActPanelType.kSuc then 
		groupName = "TurnTable2019_startPanelTip/FailtPanelTip"
	elseif self.panelType == ActPanelType.kFail then 
		groupName = "TurnTable2019_startPanelTip/FailtPanelTip"
	elseif self.panelType == ActPanelType.kStart then 
		groupName = "TurnTable2019_startPanelTip/startPanelTip"
	end	

	return groupName
end

function TurnTable2019CollectionPanel:playShowAni()
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

function TurnTable2019CollectionPanel:create( panelType, levelId )
	local panel = TurnTable2019CollectionPanel.new()
	panel.panelType = panelType
    panel.levelId = levelId
    panel:loadRequiredResource("tempFunctionRes/TurnTable2019/TurnTable2019Tip.json")
    if panel:init() then 
    	return panel
    end
end

return TurnTable2019CollectionPanel