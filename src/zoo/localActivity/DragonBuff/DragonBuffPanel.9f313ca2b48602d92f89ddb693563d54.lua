local DragonBuffPanel = class(BasePanel)

local ProgressBar = class(BaseUI)

function ProgressBar:init(ui)
	BaseUI.init(self, ui)

	local childIndex = self.ui:getChildIndex(self.ui:getChildByName("bg"))
	self.bar = self.ui:getChildByName("bar")
	self.mask = self.ui:getChildByName("mask")

    self.cellection = self.ui:getChildByName("cellection")
    

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
        self.numLabel:setPosition(ccp(106, -25))
	end
	self.numLabel:setText(curNum.."/"..totalNum)
	local size = self.numLabel:getGroupBounds().size
	local percentage = curNum / totalNum
	self:setPercentage(percentage)

    local iconPos = 106+size.width/2+2
    if iconPos > 155 then
        self.cellection:setVisible(false)
    else
        self.cellection:setPositionX( iconPos )
        self.cellection:setVisible(true)
    end
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

function DragonBuffPanel:ctor()
end

function DragonBuffPanel:init()

    --需要检测是否已经结算了。

	local groupName = self:getGroupName()
	if not groupName then 
		return false
	end
	self.ui = self:buildInterfaceGroup(groupName)
    BasePanel.init(self, self.ui)

    local info = DragonBuffManager.getInstance():getDragonBuffInfo()

    local curHaveNum = info.points
    local NextLevelNum = info.nextAllPoints
    local CurNeedAllNum =  DragonBuffManager.getInstance():getNeedPointsAll( info.grade )

    if info then
        self.LevelPanel = self:buildInterfaceGroup("CountdownParty2018/levelpanel_"..info.grade )
        self.LevelPanel:setPosition( ccp(-175,53) )
	    self.ui:addChild( self.LevelPanel )

        self.progressBar = ProgressBar:create( self.LevelPanel:getChildByName("progressBar") )
    else
        return false
    end


    self:update( curHaveNum, NextLevelNum, CurNeedAllNum, info.grade + info.gradeEx )

    
    local function UpdateTime()
        if self.tip and self.bIsUpdateTime then

            local CurTime = Localhost:time()
            local EndTime = info.expireTimestamp

            local CanUseTime = ( EndTime - CurTime )/1000
            if CanUseTime < 0 then
                CanUseTime = 0
            end

            local Minuts = math.floor( CanUseTime/60 )
            local second = CanUseTime%60

            local Time = ""

            if info.grade >= 5 then
                Time = string.format('特效时间[#FF0000]00:%02d:%02d[/#]内,收集粽子保持吧', Minuts, second)
            else
                Time = string.format('特效时间[#FF0000]00:%02d:%02d[/#]内,收集粽子升级吧', Minuts, second)
            end
            self.tip:setRichText(Time, "05394F")
        end
    end

    if info.grade > 1 then
        self.shopSchedId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(UpdateTime, 1, false)

        if self.shopSchedId then
            UpdateTime()
        end
    end

    return true
end

function DragonBuffPanel:dispose()
    if self.shopSchedId then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.shopSchedId)
        self.shopSchedId = nil
    end
end

function DragonBuffPanel:update( curNum, NextNum, CurNeedAllNum, CurLevel )
	if self.isDisposed then return end

    local LevelUpCurNum = curNum - CurNeedAllNum
    local LevelUpNextNum = NextNum - CurNeedAllNum

	--进度条
	self.progressBar:setNumberShow( curNum, NextNum )

	local showTip = false 
	local tipStr = nil
	local tipScale = nil

    local bIsGameEnd = false 
    if self.panelType == ActPanelType.kSuc or self.panelType == ActPanelType.kFail  then
    	bIsGameEnd = true
    end

    self.bIsUpdateTime = false
    if bIsGameEnd then
        local bIsUpadte = DragonBuffManager.getInstance().bLevelUp 
        if bIsUpadte then 
		    showTip = true

            if CurLevel <= 5 then
		        tipStr = localize("特效升级啦！继续加油哦")
            else
                tipStr = localize("继续收集保持最高级特效吧！")
            end
		    tipScale = 0.6
	    else
            if CurLevel == 1 then
                showTip = true
                tipStr = localize("闯关收集粽子升级特效吧")
            else
                showTip = true
                tipStr = localize("00:00:00")
                self.bIsUpdateTime = true
            end
		    tipScale = 0.5
	    end
    else
        if CurLevel == 1 then
            showTip = true
            tipStr = localize("闯关收集粽子升级特效吧")
        else
            showTip = true
            tipStr = localize("00:00:00")
            self.bIsUpdateTime = true
        end
		tipScale = 0.5
    end
 
	--tip显示
	if showTip then 
		if not self.tip then 
			self.tip = BitmapText:create("", "fnt/tutorial_white.fnt")
            self.tip:setAnchorPoint(ccp(0.5, 0.5))
			self.ui:addChild(self.tip)
		end
	    self.tip:setRichText(tipStr, "05394F")
	    self.tip:setScale(tipScale)
	    self.tip:setPosition(ccp(-175,15))
	else
		if self.tip then self.tip:removeFromParentAndCleanup(true) end
	end
end

function DragonBuffPanel:getGroupName()
	local groupName = nil
--	if self.panelType == ActPanelType.kSuc or self.panelType == ActPanelType.kStart then 
--		groupName = "CountdownParty2018/panel_suc"
--	elseif self.panelType == ActPanelType.kFail then 
--		groupName = "CountdownParty2018/panel_fail"
--	end	

    groupName = "CountdownParty2018/panel_suc"
	return groupName
end

function DragonBuffPanel:playShowAni()
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

function DragonBuffPanel:create(panelType)
	local panel = DragonBuffPanel.new()
	panel.panelType = panelType
    panel:loadRequiredResource("tempFunctionRes/CountdownParty/DragonBuffPanel.json")
    if panel:init() then 
    	return panel
    end
end

return DragonBuffPanel