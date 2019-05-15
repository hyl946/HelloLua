
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


local Qixi2018CollectPanel = class(BasePanel)

function Qixi2018CollectPanel:ctor()
end

function Qixi2018CollectPanel:init()
	local groupName = self:getGroupName()
	if not groupName then 
		return false
	end
	self.ui = self:buildInterfaceGroup(groupName)
    BasePanel.init(self, self.ui)

    self.contentUI = self.ui:getChildByName("content")
    
    if self.panelType == ActPanelType.kFullStart then 
        
    elseif self.panelType == ActPanelType.kFullSucessEnd or self.panelType == ActPanelType.kFullLoseEnd then
        --显示获得数量
        local ratio = 1
        if self.panelType == ActPanelType.kFullSucessEnd then
    	    ratio = 10
        end

        self.collectionGot = BitmapText:create("", "tempFunctionRes/CountdownParty/fnt/2018newyeareve_5.fnt")
		self.contentUI:addChild(self.collectionGot)
		self.collectionGot:setAnchorPoint(ccp(0, 0.5))
		-- self.collectionGot:setScale(0.8)
		self.collectionGot:setPosition(ccp(120/0.7, 6/0.7))
		--失败面板获得的收集物
		local mainLogic = GameBoardLogic:getCurrentLogic()
		if mainLogic then 
			local numToShow = "x"..tostring(mainLogic.actCollectionNum * ratio) 
			self.collectionGot:setText(numToShow)
		end
    else
        local contentBg = self.contentUI:getChildByName("bg")
        contentBg:setOpacity(0)

        local tipPosUI = self.contentUI:getChildByName("tipPos")
        tipPosUI:setVisible(false)
        local tipPos = tipPosUI:getPosition()
        self.tipPosX = tipPos.x
        self.tipPosY = tipPos.y


        --目标图
        local turntable = self.contentUI:getChildByName("turntable")

        local bgList = {}
        bgList[1] = turntable:getChildByName("bg1")
        bgList[2] = turntable:getChildByName("bg2")
        bgList[3] = turntable:getChildByName("bg3")
        bgList[4] = turntable:getChildByName("bg4")
        bgList[5] = turntable:getChildByName("bg32")
        bgList[6] = turntable:getChildByName("bg42")

        for i,v in ipairs(bgList) do
            if v then
                v:setVisible(fasle)
            end
        end

        local rewardList = Qixi2018CollectManager.getInstance():getRewardList()
        local bTreeFull = Qixi2018CollectManager.getInstance().bTreeFull
        local bHeadFull = Qixi2018CollectManager.getInstance().bHeadFull


        local function GetIsReward( index)
            for i,v in pairs(rewardList) do
                if v == index then
                    return true
                end
            end

            return false
        end

        --显示没领的第一个袋子
        for i=1,4 do
            local bReward = GetIsReward( i )
            if bReward == false then
                if i == 3 then
                    if bTreeFull == 1 then
                        bgList[5]:setVisible(true)
                    else
                        bgList[i]:setVisible(true)
                    end
                elseif i == 4 then
                    if bHeadFull == 1 then
                        bgList[6]:setVisible(true)
                    else
                        bgList[i]:setVisible(true)
                    end
                else
                    bgList[i]:setVisible(true)
                end
                break
            end
        end
        

        self.progressBar = ProgressBar:create(self.contentUI:getChildByName("progressBar"))

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
		    self.collectionGot:setScale(0.8)
		    self.collectionGot:setPosition(ccp(154-3/0.7, -17+2))
		    --失败面板获得的收集物
		    local mainLogic = GameBoardLogic:getCurrentLogic()
		    if mainLogic then 
			    local numToShow = "x"..tostring(mainLogic.actCollectionNum * ratio) 
			    self.collectionGot:setText(numToShow)
		    end
		    -- self.collectionGot:setText("x100")
        end

        self:update()
	end	

    return true
end

function Qixi2018CollectPanel:update()
	if self.isDisposed then return end

	local curNum, maxNum = Qixi2018CollectManager.getInstance():getProgressShowNum()
    local bAllReward = Qixi2018CollectManager.getInstance():getIsAllReward()


    local targetMaxNum =  Qixi2018CollectManager.getInstance().limitList[4] or 0
    if curNum > targetMaxNum then
        curNum = targetMaxNum
    end

	--进度条
	self.progressBar:setNumberShow(curNum, maxNum)

	local showTip = false 
	local tipStr = nil
	local tipScale = nil

    if bAllReward then
        showTip = false
    else
        if curNum >= maxNum then
            showTip = true
            tipStr = localize("可以[#CA0305]领奖[/#]啦！")
		    tipScale = 0.5
	    elseif curNum >= maxNum * 0.7 then 
		    showTip = true
		    tipStr = localize("还差一点就可以[#CA0305]领奖[/#]啦！")
		    tipScale = 0.5
	    end
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
--	    self.contentUI:setPosition(ccp(pos.x, pos.y))
	else
		if self.tip then self.tip:removeFromParentAndCleanup(true) end
		local pos = ContentPos[self.panelType].low
--	    self.contentUI:setPosition(ccp(pos.x, pos.y))
	end
end

function Qixi2018CollectPanel:getGroupName()
	local groupName = nil
	if self.panelType == ActPanelType.kSuc then 
		groupName = "Qixi2018Panel/panel_suc"
        Qixi2018CollectManager.getInstance():setCurIsShowStartPanel(false)
	elseif self.panelType == ActPanelType.kFail then 
		groupName = "Qixi2018Panel/panel_fail"
        Qixi2018CollectManager.getInstance():setCurIsShowStartPanel(false)
	elseif self.panelType == ActPanelType.kStart then 
		groupName = "Qixi2018Panel/panel_start"
        Qixi2018CollectManager.getInstance():setCurIsShowStartPanel(true)
    elseif self.panelType == ActPanelType.kFullStart then 
        groupName = "Qixi2018Panel/panel_fullstart"
        Qixi2018CollectManager.getInstance():setCurIsShowStartPanel(true)
    elseif self.panelType == ActPanelType.kFullSucessEnd then 
        groupName = "Qixi2018Panel/panel_fullpasslevel"
        Qixi2018CollectManager.getInstance():setCurIsShowStartPanel(false)
    elseif self.panelType == ActPanelType.kFullLoseEnd then 
        groupName = "Qixi2018Panel/panel_fullpasslevel"
        Qixi2018CollectManager.getInstance():setCurIsShowStartPanel(false)
	end	
	return groupName
end

function Qixi2018CollectPanel:playShowAni()
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

function Qixi2018CollectPanel:create(panelType)
	local panel = Qixi2018CollectPanel.new()
	panel.panelType = panelType
    panel:loadRequiredResource("tempFunctionRes/CountdownParty/Qixi2018Panel.json")
    if panel:init() then 
    	return panel
    end
end

return Qixi2018CollectPanel