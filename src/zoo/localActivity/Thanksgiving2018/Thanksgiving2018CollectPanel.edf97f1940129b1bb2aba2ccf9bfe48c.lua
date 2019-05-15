
local ProgressBar = class(BaseUI)

local ActPanelType = {
	kSuc = 1,
	kFail = 2,
	kStart = 3,
    kFullStart = 4,
    kFullSucessEnd = 5,
    kFullLoseEnd = 6,
}

local ContentPos = {
	[ActPanelType.kSuc] = {high = {x = -300, y = 109}, low = {x = -300, y = 99}},
	[ActPanelType.kFail] = {high = {x = -300, y = 109}, low = {x = -300, y = 99}},
	[ActPanelType.kStart] = {high = {x = -290, y = 105}, low = {x = -290, y = 95}},
}


function ProgressBar:init(ui)
	BaseUI.init(self, ui)

	local childIndex = self.ui:getChildIndex(self.ui:getChildByName("bg"))
	self.bar = self.ui:getChildByName("bar")
	self.mask = self.ui:getChildByName("mask")
--	local collection = self.ui:getChildByName("cellection")
--	self.labelPos = collection:getPosition()

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
	self.numLabel:setPosition(ccp(106,-24))
	local percentage = curNum / totalNum
	self:setPercentage(percentage)
end

function ProgressBar:create(ui)
	local bar = ProgressBar.new()
	bar:init(ui)
	return bar
end


local Thanksgiving2018CollectPanel = class(BasePanel)

function Thanksgiving2018CollectPanel:ctor()
end

function Thanksgiving2018CollectPanel:dispose()
    BasePanel.dispose(self)

    if self.panelType == ActPanelType.kSuc then
        Thanksgiving2018CollectManager.getInstance():ClearLevelID()
    end
end

function Thanksgiving2018CollectPanel:init()
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


    --目标图
    local turntable = self.contentUI:getChildByName("turntable")
    local redPoint = turntable:getChildByName("redPoint")
    redPoint:setVisible(false)

    self.progressBar = ProgressBar:create(self.contentUI:getChildByName("progressBar"))

    local showCollectGot = false 
    local ratio = 1
    if self.panelType == ActPanelType.kSuc then
    	showCollectGot = true
    	ratio = 10
    elseif self.panelType == ActPanelType.kFail then
    	showCollectGot = true
    end


    local curNum, maxNum = Thanksgiving2018CollectManager.getInstance():getProgressShowNum()
    if curNum > maxNum then
        local CanPlayNum = math.floor(curNum/maxNum)
        self.redPointNum = BitmapText:create(""..CanPlayNum, "fnt/tutorial_white.fnt")
		redPoint:addChild(self.redPointNum)
		self.redPointNum:setAnchorPoint(ccp(0.5, 0.5))
		self.redPointNum:setScale(0.8)
		self.redPointNum:setPosition(ccp(8+7/0.7,8+10/0.7))
        redPoint:setVisible(true)
    end

    self:update()

    return true
end

function Thanksgiving2018CollectPanel:update()
	if self.isDisposed then return end

	local curNum, maxNum = Thanksgiving2018CollectManager.getInstance():getProgressShowNum()

	--进度条
	self.progressBar:setNumberShow(curNum, maxNum)

	local showTip = false 
	local tipStr = nil
	local tipScale = nil

--    if bAllReward then
--        showTip = false
--    else
        if curNum >= maxNum then
            showTip = true
            tipStr = localize("可以[#CA0305]抽奖[/#]啦！")
		    tipScale = 0.5
	    elseif curNum >= maxNum * 0.7 then 
		    showTip = true
		    tipStr = localize("马上就可以转[#CA0305]实物转盘[/#]啦！")
		    tipScale = 0.5
        else
            showTip = true
		    tipStr = localize("加油获取[#CA0305]叶子[/#]吧！")
		    tipScale = 0.5
	    end
--    end

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
--	    self.contentUI:setPosition(ccp(pos.x, pos.y))
	else
		if self.tip then self.tip:removeFromParentAndCleanup(true) end
		local pos = ContentPos[self.panelType].low
--	    self.contentUI:setPosition(ccp(pos.x, pos.y))
	end
end

function Thanksgiving2018CollectPanel:getGroupName()
	local groupName = nil
	if self.panelType == ActPanelType.kSuc then 
		groupName = "ThankGivingPanel/panel_suc"
	elseif self.panelType == ActPanelType.kFail then 
		groupName = "ThankGivingPanel/panel_fail"
	elseif self.panelType == ActPanelType.kStart then 
		groupName = "ThankGivingPanel/panel_start"
	end	
	return groupName
end

function Thanksgiving2018CollectPanel:playShowAni()
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

function Thanksgiving2018CollectPanel:create(panelType)
	local panel = Thanksgiving2018CollectPanel.new()
	panel.panelType = panelType
    panel:loadRequiredResource("tempFunctionRes/CountdownParty/ThankGivingPanel.json")
    if panel:init() then 
    	return panel
    end
end

return Thanksgiving2018CollectPanel