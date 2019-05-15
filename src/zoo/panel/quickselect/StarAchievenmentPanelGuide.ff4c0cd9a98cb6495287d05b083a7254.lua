local StarAchievenmentPanelGuide = class()

function StarAchievenmentPanelGuide:create(parentPanel)
	if StarAchievenmentPanelGuide:isNeedGuide() then
		local guide = StarAchievenmentPanelGuide.new()
		guide:init(parentPanel)
		return guide
	end
end

function StarAchievenmentPanelGuide:isNeedGuide()
    -- return true 
	local hasGuide = CCUserDefault:sharedUserDefault():getBoolForKey("star.schievement.guide", false)
    return not hasGuide
end

function StarAchievenmentPanelGuide:init(parentPanel)
    self.parentPanel = parentPanel
    if self.parentPanel.ui == nil or self.parentPanel.ui.isDisposed then return end

    local scaleX = parentPanel:getScaleX()
    local scaleY = parentPanel:getScaleY()

    local vSize = CCDirector:sharedDirector():ori_getVisibleSize()
    local vOrigin = CCDirector:sharedDirector():ori_getVisibleOrigin()

    CCUserDefault:sharedUserDefault():setBoolForKey("star.schievement.guide", true)
    CCUserDefault:sharedUserDefault():flush()
    self.ui = Layer:create()
    local guideBgWidth = 960/scaleX
    local guideBgHeight = vSize.height/scaleY
    local posX = (720 - guideBgWidth) / 2 - vOrigin.x / scaleX
    local posY = -guideBgHeight + (vOrigin.y + _G._G.__EDGE_INSETS.top) / scaleY
    self.guideBg = LayerColor:createWithColor(ccc3(0, 0, 0), guideBgWidth, guideBgHeight)
    self.guideBg:setOpacity(200)
    self.guideBg:setPosition(ccp(posX, posY))
    local guideMask = getScale9RoundRectMask(678.2, 290)--LayerColor:createWithColor(ccc3(0, 0, 0), 666, 688)
    guideMask:setPosition(ccp(30, -1224))
    self.rectMask = guideMask.refCocosObj
    self.guideClippingNode =  ClippingNode.new(CCClippingNode:create(guideMask.refCocosObj))
    guideMask:dispose()
    self.guideClippingNode:setInverted(true)
    self.guideClippingNode:addChild(self.guideBg)
    self.ui:addChild(self.guideClippingNode)

    self.swallowLayer = LayerColor:createWithColor(ccc3(0, 0, 0), guideBgWidth, guideBgHeight)
    self.swallowLayer:setOpacity(0)
    self.swallowLayer:setPosition(ccp(posX, posY))
    self.swallowLayer:setTouchEnabled(true, 0, true)
    self.swallowLayer:addEventListener(DisplayEvents.kTouchTap, function() self:nextGuide() end)
    self.ui:addChild(self.swallowLayer)

    if self.parentPanel.ui ~= nil then
        self.parentPanel.ui:addChild(self.ui)
    end

    self.guideStep = 0
    self:nextGuide()
end

local GuideCfg = { 
                  {
                    animKey="tutorial_normal", 
                    npcPos = ccp(544, -527), 
                    tipKey="star.achievement.panel.guide1", 
                    tipPos = ccp(100, -450), 
                    showTime = 6
                    },
                    {
                    animKey="movein_tutorial_4", 
                    npcPos = ccp(528, -398), 
                    tipKey="star.achievement.panel.guide2", 
                    tipPos = ccp(100, -280),
                    showTime = 6
                   },
                }

function StarAchievenmentPanelGuide:nextGuide()

    if self.parentPanel.ui == nil or self.parentPanel.ui.isDisposed then return end

    if self.curStepTimeOutID ~= nil then
        cancelTimeOut(self.curStepTimeOutID)
        self.curStepTimeOutID = nil
    end

    if self.guideStep > 0 then
        if self.guideTip and not self.guideTip.isDisposed then
            self.guideTip:removeFromParentAndCleanup(true)
            self.guideTip = nil
        end
        if self.hand then 
            self.hand:removeFromParentAndCleanup(true)
            self.hand = nil
        end
    end

    self.guideStep = self.guideStep + 1
    local curStep = self.guideStep
    if self.guideStep > #GuideCfg then
        self:guideEnd()
        return
    end
    local cfg = GuideCfg[self.guideStep]
    local action = {}
    if self.guideStep == 1 then
        action.panelName = 'guide_dialogue_star_achievement_2'
    else
        action.panelName = 'guide_dialogue_star_achievement_1'
    end
    self.guideTip = GameGuideUI:dialogue(nil, action, true)
    self.ui:addChild(self.guideTip)

    if self.guideStep == 1 then 
        local guideMask = self.parentPanel:buildInterfaceGroup("new_star/head")
        guideMask:getChildByName("head_top_l"):removeFromParentAndCleanup(true)
        guideMask:getChildByName("head_top_r"):removeFromParentAndCleanup(true)
        guideMask:getChildByName("close_btn"):removeFromParentAndCleanup(true)
        self.parentPanel.head:getChildByName("close_btn"):setVisible(false)
        self.rectMask = guideMask.refCocosObj
        self.rectMask:setPosition(ccp(-15 + 10 + 5, 29))
        self.guideClippingNode:setStencil(self.rectMask)
        self.guideClippingNode:setAlphaThreshold(0.5)
        guideMask:dispose()
        self.guideTip:setPosition(cfg.tipPos)

        self.hand = GameGuideAnims:handclickAnim(0, 0)
        self.hand:setPosition(ccp(460, -280))
        self.ui:addChild(self.hand)
    else
        local guideMask = self.parentPanel:buildInterfaceGroup("new_star/body")
        guideMask:getChildByName("leaf_l"):removeFromParentAndCleanup(true)
        guideMask:getChildByName("leaf_r"):removeFromParentAndCleanup(true)
        guideMask:getChildByName("close_btn"):removeFromParentAndCleanup(true)
        guideMask:getChildByName("title2"):removeFromParentAndCleanup(true)
        self.parentPanel.head:getChildByName("close_btn"):setVisible(true)
        self.rectMask = guideMask.refCocosObj
        self.rectMask:setPosition(ccp(3, 49))
        self.guideClippingNode:setStencil(self.rectMask)
        self.guideClippingNode:setAlphaThreshold(0.5)
        guideMask:dispose()
        self.guideTip:setPosition(cfg.tipPos)
    end

    self.curStepTimeOutID = setTimeOut(function() 
        if curStep == self.guideStep then 
            self:nextGuide() 
        end 
        end, cfg.showTime)
end

function StarAchievenmentPanelGuide:guideEnd( ... )
    if self.ui ~= nil and self.ui:getParent() ~= nil and not self.ui.isDisposed then
        self.ui:removeFromParentAndCleanup(true)
    end
end

return StarAchievenmentPanelGuide