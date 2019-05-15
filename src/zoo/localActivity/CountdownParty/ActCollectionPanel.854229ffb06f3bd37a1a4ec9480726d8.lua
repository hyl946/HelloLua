local ActCollectionPanel = class(BasePanel)

local ProgressBar = class(BaseUI)

function ProgressBar:init(ui)
	BaseUI.init(self, ui)

	local childIndex = self.ui:getChildIndex(self.ui:getChildByName("bg"))
	self.bar = self.ui:getChildByName("bar")
	self.mask = self.ui:getChildByName("mask")
	local collection = self.ui:getChildByName("cellection")
	self.labelPos = collection:getPosition()

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
	clipping:setPosition(ccp(self.barInitialPosX, self.barInitialPosY + 4))

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
	if not self.numLabel then 
		self.numLabel = BitmapText:create("", "tempFunctionRes/CountdownParty/fnt/2018newyeareve.fnt")
		self.ui:addChild(self.numLabel)
		self.numLabel:setScale(0.7)
	end
	self.numLabel:setText(curNum.."/"..totalNum)
	local size = self.numLabel:getGroupBounds().size
	self.numLabel:setPosition(ccp(self.labelPos.x - size.width/2 - 1, self.labelPos.y - 21))
	local percentage = curNum / totalNum
	self:setPercentage(percentage)
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

function ActCollectionPanel:ctor()
end

function ActCollectionPanel:init()
	local groupName = self:getGroupName()
	if not groupName then 
		return false
	end
	self.ui = self:buildInterfaceGroup(groupName)
    BasePanel.init(self, self.ui)

    self.contentUI = self.ui:getChildByName("content")
    local contentBg = self.contentUI:getChildByName("bg")
    contentBg:setOpacity(0)

    local tipPosUI = self.contentUI:getChildByName("tipPos")
    tipPosUI:setVisible(false)
    local tipPos = tipPosUI:getPosition()
    self.tipPosX = tipPos.x
    self.tipPosY = tipPos.y

    self.progressBar = ProgressBar:create(self.contentUI:getChildByName("progressBar"))

    local turntableUI = self.contentUI:getChildByName("turntable")
    self.redDotUI = turntableUI:getChildByName("redDot")
    self.redDotUI:setVisible(false)
    self.lotteryNum = self.redDotUI:getChildByName("label")

    local showCollectGot = false 
    local ratio = 1
    if self.panelType == ActPanelType.kSuc then
    	showCollectGot = true
    	ratio = 10
    elseif self.panelType == ActPanelType.kFail then
    	showCollectGot = true
    end

    if showCollectGot then
		self.collectionGot = BitmapText:create("", "tempFunctionRes/CountdownParty/fnt/2018newyeareve_5.fnt")
		self.contentUI:addChild(self.collectionGot)
		self.collectionGot:setAnchorPoint(ccp(0, 0.5))
		-- self.collectionGot:setScale(0.8)
		self.collectionGot:setPosition(ccp(154, -17))
		--失败面板获得的收集物
		local mainLogic = GameBoardLogic:getCurrentLogic()
		if mainLogic then 
			local numToShow = "x"..tostring(mainLogic.actCollectionNum * ratio) 
			self.collectionGot:setText(numToShow)
		end
		-- self.collectionGot:setText("x100")
    end

    self:update()
    return true
end

function ActCollectionPanel:update()
	if self.isDisposed then return end

	local curNum, maxNum = CountdownPartyManager.getInstance():getProgressShowNum()
	local lotteryNum = CountdownPartyManager.getInstance():getLotteryNum()
	--进度条
	self.progressBar:setNumberShow(curNum, maxNum)

	local showTip = false 
	local tipStr = nil
	local tipScale = nil
	if lotteryNum > 0 then 
		showTip = true
		tipStr = localize("可以[#CA0305]抽奖[/#]啦！")
		tipScale = 0.6
	elseif curNum >= maxNum * 0.7 then 
		showTip = true
		tipStr = localize("还差一点就可以[#CA0305]抽奖[/#]啦！")
		tipScale = 0.5
	end

	--转盘标识
	if lotteryNum > 0 then 
    	self.redDotUI:setVisible(true)
    	self.lotteryNum:setString(localize("奖"))
    else
    	self.redDotUI:setVisible(false)
    end

	--tip显示
	if showTip then 
		if not self.tip then 
			self.tip = BitmapText:create("", "fnt/tutorial_white.fnt")
			self.contentUI:addChild(self.tip)
		end
	    self.tip:setRichText(tipStr, "05394F")
	    self.tip:setScale(tipScale)
	    self.tip:setPosition(ccp(self.tipPosX, self.tipPosY))

	    local pos = ContentPos[self.panelType].high
	    self.contentUI:setPosition(ccp(pos.x, pos.y))
	else
		if self.tip then self.tip:removeFromParentAndCleanup(true) end
		local pos = ContentPos[self.panelType].low
	    self.contentUI:setPosition(ccp(pos.x, pos.y))
	end
end

function ActCollectionPanel:getGroupName()
	local groupName = nil
	if self.panelType == ActPanelType.kSuc then 
		groupName = "CountdownParty2017/panel_suc"
	elseif self.panelType == ActPanelType.kFail then 
		groupName = "CountdownParty2017/panel_fail"
	elseif self.panelType == ActPanelType.kStart then 
		groupName = "CountdownParty2017/panel_start"
	end	
	return groupName
end

function ActCollectionPanel:playShowAni()
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

function ActCollectionPanel:create(panelType)
	local panel = ActCollectionPanel.new()
	panel.panelType = panelType
    panel:loadRequiredResource("tempFunctionRes/CountdownParty/panel.json")
    if panel:init() then 
    	return panel
    end
end

return ActCollectionPanel