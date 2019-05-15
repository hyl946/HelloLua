local RecallA2019CollectionPanel = class(BasePanel)

local ProgressBar = class(BaseUI)

function ProgressBar:init(ui)
	BaseUI.init(self, ui)

	local childIndex = self.ui:getChildIndex(self.ui:getChildByName("bg"))
	self.bar = self.ui:getChildByName("bar")
	self.mask = self.ui:getChildByName("mask")
	self.numLabel = self.ui:getChildByName("num")
    self.numLabel:setAnchorPoint(ccp(0.5,0.5))
    local numLabelPos = self.numLabel:getPosition()
    self.numLabel:setPosition(ccp(numLabelPos.x+55/0.7, numLabelPos.y-15/0.7))
    self.numLabel:changeFntFile('fnt/friends2.fnt')
--    self.numLabel:setColor(hex2ccc3('804A4A'))
--    self.numLabel:setScale(0.8)

	self.barInitialPosX = self.bar:getPositionX()
	self.barInitialPosY = self.bar:getPositionY()
	self.barWidth = self.bar:getGroupBounds().size.width

	self.mask:removeFromParentAndCleanup(false)
	self.bar:removeFromParentAndCleanup(false)

	local cppClippingNode = CCClippingNode:create(self.mask.refCocosObj)
	local clipping = ClippingNode.new(cppClippingNode)
	clipping:setAlphaThreshold(0.1)
	clipping:addChild(self.bar)
	self.ui:addChildAt(clipping, childIndex+1)
	clipping:setPosition(ccp(self.barInitialPosX-2, self.barInitialPosY+2))

	self.progressBarToControl = self.bar
	self.mask:dispose()

	self:setPercentage(0)
end

function ProgressBar:setPercentage(percentage, ani)
	if percentage < 0 then
		percentage = 0
	elseif percentage > 1 then
		percentage = 1
	end

	local width = self.barWidth * percentage
	local newPosX = -self.barWidth + width
	if ani then 
		self.progressBarToControl:stopAllActions()
		self.progressBarToControl:runAction(CCMoveTo:create(0.2, ccp(newPosX, self.barInitialPosY)))
	else
		self.progressBarToControl:setPositionX(newPosX)
	end
end

function ProgressBar:setNumberShow(curNum, totalNum)
	self.numLabel:setText(curNum.."/"..totalNum)
	local size = self.numLabel:getGroupBounds().size
--	self.numLabel:setPosition(ccp(self.labelPos.x - size.width/2 - 1, self.labelPos.y - 21))
	local percentage = curNum / totalNum
	self:setPercentage(percentage)

----   test
--    local percent = 1
--    local function callend()
--        percent = percent + 0.01
--        if percent > 1 then percent = 0 end
--        self:setPercentage(percent)

--    end
--    local array = CCArray:create()
--    array:addObject(CCDelayTime:create(0.1))
--    array:addObject(CCCallFunc:create(callend))
--    self:runAction( CCRepeatForever:create( CCSequence:create(array) ))
end

function ProgressBar:create(ui)
	local bar = ProgressBar.new()
	bar:init(ui)
	return bar
end




local ActPanelType = {
	kSuc = 1,
	kFail = 2,
	kStart = 3,
}

local ContentPos = {
	[ActPanelType.kSuc] = {high = {x = -300, y = 109}, low = {x = -300, y = 99}},
	[ActPanelType.kFail] = {high = {x = -300, y = 109}, low = {x = -300, y = 99}},
	[ActPanelType.kStart] = {high = {x = -290, y = 105}, low = {x = -290, y = 95}},
}

function RecallA2019CollectionPanel:ctor()
end

function RecallA2019CollectionPanel:init()
	local groupName = self:getGroupName()
	if not groupName then 
		return false
	end
	self.ui = self:buildInterfaceGroup(groupName)
    BasePanel.init(self, self.ui)

    self.tip = self.ui:getChildByName("text")
    self.tip:setAnchorPoint(ccp(1, 1))
    self.tip:setScale(0.6)
    self.tip:setPositionX( self.tip:getPositionX()+142/0.7 )

    self.ticket = self.ui:getChildByName("ticket")
    self.ticketPos = self.ticket:getPosition()

    self.progressBar = ProgressBar:create(self.ui:getChildByName("progress"))

	self.collectionGot = BitmapText:create("", "fnt/friends1.fnt")
	self.ui:addChild(self.collectionGot)
	self.collectionGot:setAnchorPoint(ccp(0, 0.5))
	self.collectionGot:setScale(0.8)
	self.collectionGot:setPosition(ccp(-49/0.7, 63/0.7))

    self:update()
    return true
end

function RecallA2019CollectionPanel:update()
	if self.isDisposed then return end

    local function getTicketIDNum( info )
        local ticketID = 50050
        local ticketNum = 0
        for i,v in ipairs(info.rewards) do
            if v.itemId == ticketID then
                ticketNum = v.num
                break
            end
        end

        return ticketNum
    end

    local needShowGetRewardAnim = RecallA2019Manager.getInstance().needShowGetRewardAnim
    if needShowGetRewardAnim then
        
        local function TicketFly()
            if self.isDisposed then return end

            local ticketIcon = Sprite:createWithSpriteFrameName("RecallA2019_startPanelTip/ticket0000")
            ticketIcon:setPosition( ccp(self.ticketPos.x+25,self.ticketPos.y-23) )
            self.ui:addChildAt( ticketIcon,12 )

            -- 屏幕适配
	        local wSize = CCDirector:sharedDirector():getWinSize()
	        local vSize = CCDirector:sharedDirector():getVisibleSize()
	        local vOrigin = CCDirector:sharedDirector():getVisibleOrigin()

            local ticketWorldPos= ticketIcon:getParent():convertToWorldSpace( ticketIcon:getPosition() )
            ticketWorldPos.x = 60
            local newPos = self.ui:convertToNodeSpace( ticketWorldPos )

            local myMissionIcon = Sprite:createWithSpriteFrameName("RecallA2019_startPanelTip/myMission0000")
            myMissionIcon:setPosition( newPos )
            self.ui:addChildAt( myMissionIcon,11 )
            local MissionPos = myMissionIcon:getPosition()

            local function missionIconCallend()
                if self.isDisposed then return end
                myMissionIcon:removeFromParentAndCleanup(true)
            end

            local function callend()
                if self.isDisposed then return end
                ticketIcon:removeFromParentAndCleanup(true)

                local array = CCArray:create()
                array:addObject( CCDelayTime:create(0.3) )
                array:addObject( CCFadeOut:create(0.2) )
                array:addObject(CCCallFunc:create(missionIconCallend))

                myMissionIcon:runAction( CCSequence:create(array) )
            end

            local array = CCArray:create()
            array:addObject( CCFadeIn:create(0.2) )
            array:addObject( CCScaleTo:create(0.2, 1.3, 1.3 ) )
            array:addObject( CCEaseBackInOut:create(CCMoveTo:create(0.5, ccp(MissionPos.x, MissionPos.y)))  )
            array:addObject(CCCallFunc:create(callend))

            ticketIcon:runAction( CCSequence:create(array) )

            RecallA2019Manager.getInstance().needShowGetRewardAnim = false
        end

        setTimeOut( TicketFly, 1.2)
    end

    local topLevelId = UserManager:getInstance().user:getTopLevelId()
    local info = RecallA2019Manager.getInstance():getMissonInfo( topLevelId )

    if info then
        local curNum = info.currentValue
        local maxNum = info.targetValue
        local NeedNum = info.targetValue - info.currentValue

        --进度条
	    self.progressBar:setNumberShow(curNum, maxNum)

	    local tipStr = "再通过[#CA0305]"..NeedNum.."[/#]关可获得\n赢取幸运玩偶大奖!"
	    --tip显示
	    self.tip:setRichText(tipStr, "804A4A")
        --

        local ticketNum = getTicketIDNum(info)

        local numToShow = "x"..ticketNum
		self.collectionGot:setText(numToShow)
    end

end

function RecallA2019CollectionPanel:getGroupName()
	local groupName = nil
	if self.panelType == ActPanelType.kSuc then 
		groupName = "RecallA2019_startPanelTip/startPanelTip"
	elseif self.panelType == ActPanelType.kFail then 
		groupName = "RecallA2019_startPanelTip/FailtPanelTip"
	elseif self.panelType == ActPanelType.kStart then 
		groupName = "RecallA2019_startPanelTip/startPanelTip"
	end	

    local ver = tonumber(string.split(_G.bundleVersion, ".")[2])
    if ver <= 64 then
        groupName = "RecallA2019_startPanelTip/FailtPanelTip"
    end
	return groupName
end

function RecallA2019CollectionPanel:playShowAni()
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

function RecallA2019CollectionPanel:create(panelType)
	local panel = RecallA2019CollectionPanel.new()
	panel.panelType = panelType
    panel:loadRequiredResource("tempFunctionRes/RecallA2019/RecallA2019Tip.json")
    if panel:init() then 
    	return panel
    end
end

return RecallA2019CollectionPanel