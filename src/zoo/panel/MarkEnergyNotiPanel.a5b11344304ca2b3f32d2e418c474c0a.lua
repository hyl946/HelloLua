require "zoo.panel.basePanel.BasePanel"

MarkEnergyNotiOnceMinshengPanel = class(BasePanel)
function MarkEnergyNotiOnceMinshengPanel:create(parent, finishCallback, boxPosition)
    local panel = MarkEnergyNotiOnceMinshengPanel.new()
    panel:_init(parent, finishCallback, boxPosition)
    return panel
end

function MarkEnergyNotiOnceMinshengPanel:_init(parent, finishCallback, boxPosition)
    self:loadRequiredResource(PanelConfigFiles.panel_mark_energy_notionce)

    local panel = self:buildInterfaceGroup("panelmarkenergynotionce_minsheng")
    self:init(panel)
    self:setScale(1 / parent:getScale())

    local mask = LayerColor:create()
    mask:setContentSize(CCSizeMake(3000, 3000)) -- 足够大
    mask:setOpacity(200)
    mask:ignoreAnchorPointForPosition(false)
    mask:setAnchorPoint(ccp(0, 0))
    parent:addChild(mask)

    parent:addChild(self)
    local size = self:getGroupBounds().size
    local vs = Director:sharedDirector():getVisibleSize()
    local vo = Director:sharedDirector():getVisibleOrigin()

    local wPos = ccp(vo.x + vs.width/2 - size.width/2, vo.y + vs.height/2 + size.height/2)
    self:setPosition(parent:convertToNodeSpace(wPos))
    mask:setPosition(parent:convertToNodeSpace(ccp(0, 0)))

    local position = panel:convertToNodeSpace(ccp(boxPosition.x, boxPosition.y))
    local duration=3
    local function flyItem(item)
        local function onCheck()
            item:removeFromParentAndCleanup(false)
            self:addChild(item)
        end

        local size = item:getContentSize()
        local arr1 = CCArray:create()
        arr1:addObject(CCDelayTime:create(duration))
        arr1:addObject(CCCallFunc:create(onCheck))
        arr1:addObject(CCSpawn:createWithTwoActions(CCEaseBackIn:create(CCMoveTo:create(0.375,
            ccp(position.x - size.width / 2, position.y + size.height / 2))),
            CCScaleTo:create(0.375, 1)))
        arr1:addObject(CCToggleVisibility:create())
        item:runAction(CCSequence:create(arr1))
    end
    flyItem(panel:getChildByName("item"))
    flyItem(panel:getChildByName("itemMinsheng"))

    local function onStep()
        mask:setVisible(false)
        panel:setVisible(false)
    end
        
    local function onEnd()
        self:removeFromParentAndCleanup()
        if finishCallback then finishCallback() end
    end

    local arr1 = CCArray:create()
    arr1:addObject(CCDelayTime:create(duration+0.1))
    arr1:addObject(CCToggleVisibility:create())
    arr1:addObject(CCCallFunc:create(onStep))
    arr1:addObject(CCDelayTime:create(2))
    arr1:addObject(CCCallFunc:create(onEnd))
    mask:runAction(CCSequence:create(arr1))
end

MarkEnergyNotiOncePanel = class(BasePanel)
function MarkEnergyNotiOncePanel:create(parent, finishCallback, boxPosition)
    local panel = MarkEnergyNotiOncePanel.new()
    panel:_init(parent, finishCallback, boxPosition)
    return panel
end

function MarkEnergyNotiOncePanel:_init(parent, finishCallback, boxPosition)
    self:loadRequiredResource(PanelConfigFiles.panel_mark_energy_notionce)

    local panel = self:buildInterfaceGroup("panelmarkenergynotionce_xmas")
    self:init(panel)
    self:setScale(1 / parent:getScale())

    local mask = LayerColor:create()
    mask:setContentSize(CCSizeMake(3000, 3000)) -- 足够大
    mask:setOpacity(200)
    mask:ignoreAnchorPointForPosition(false)
    mask:setAnchorPoint(ccp(0, 0))
    parent:addChild(mask)

    parent:addChild(self)
    local size = self:getGroupBounds().size
    local vs = Director:sharedDirector():getVisibleSize()
    local vo = Director:sharedDirector():getVisibleOrigin()

    local wPos = ccp(vo.x + vs.width/2 - size.width/2, vo.y + vs.height/2 + size.height/2)
    self:setPosition(parent:convertToNodeSpace(wPos))
    mask:setPosition(parent:convertToNodeSpace(ccp(0, 0)))

    local bg = panel:getChildByName("bg")
    local bg2 = panel:getChildByName('bg2')
    local text = panel:getChildByName("text")
    local glow = panel:getChildByName("glow")
    local number = panel:getChildByName("number")
    local star = panel:getChildByName("star")
    local lightItem = panel:getChildByName("lightitem")
    local item = panel:getChildByName("item")
    local close = panel:getChildByName("close")

    local position = panel:convertToNodeSpace(ccp(0, -400))
    local recPosition = item:getPosition()
    recPosition = {x = recPosition.x, y = recPosition.y}
    item:setPositionY(position.y)
    star:setVisible(false)
    star:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
    bg:setOpacity(0)
    bg2:setOpacity(0)
    mask:setOpacity(0)
    text:setString(Localization:getInstance():getText("mark.panel.noti.once.title", {n = '\n'}))
    text:setOpacity(0)
    glow:setVisible(false)
    number:setVisible(false)
    lightItem:setVisible(false)
    close:setVisible(false)
    position = panel:convertToNodeSpace(ccp(boxPosition.x, boxPosition.y))
    local size = lightItem:getContentSize()
    lightItem:setPositionXY(position.x - size.width / 2, position.y + size.height / 2)

    local scene = Director:sharedDirector():getRunningScene()
    local swallowTouchLayer
    if scene and not scene.isDisposed then
        swallowTouchLayer = LayerColor:create()
        local wSize = Director:sharedDirector():getWinSize()
        swallowTouchLayer:changeWidthAndHeight(wSize.width, wSize.height)
        swallowTouchLayer:setOpacity(0)
        swallowTouchLayer:setTouchEnabled(true, 0, true)
        scene:addChild(swallowTouchLayer, SceneLayerShowKey.POP_OUT_LAYER)
    end

    local arr1 = CCArray:create()
    arr1:addObject(CCEaseBackOut:create(CCMoveTo:create(0.625, ccp(recPosition.x, recPosition.y))))
    arr1:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.12, ccp(0, -10)), CCScaleTo:create(0.12, 1, 0.9)))
    arr1:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.12, ccp(0, 20)), CCScaleTo:create(0.12, 1)))
    arr1:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.12, ccp(0, -12)), CCScaleTo:create(0.12, 1, 0.97)))
    arr1:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.08, ccp(0, 2)), CCScaleTo:create(0.08, 1)))
    arr1:addObject(CCDelayTime:create(2.3))
    local bSize = item:getContentSize()
    arr1:addObject(CCSpawn:createWithTwoActions(CCEaseBackIn:create(CCMoveTo:create(0.375,
        ccp(position.x - size.width / 2, position.y + size.height / 2))),
        CCScaleTo:create(0.375, size.width / bSize.width)))
    arr1:addObject(CCToggleVisibility:create())
    item:runAction(CCSequence:create(arr1))
    local arr2 = CCArray:create()
    arr2:addObject(CCDelayTime:create(0.5))
    arr2:addObject(CCFadeIn:create(0.3))
    arr2:addObject(CCDelayTime:create(2.3))
    arr2:addObject(CCFadeOut:create(0.2))
    local arr2_1 = CCArray:create()
    arr2_1:addObject(CCDelayTime:create(0.5))
    arr2_1:addObject(CCFadeIn:create(0.3))
    arr2_1:addObject(CCDelayTime:create(2.3))
    arr2_1:addObject(CCFadeOut:create(0.2))
    local arr2_2 = CCArray:create()
    arr2_2:addObject(CCDelayTime:create(0.5))
    arr2_2:addObject(CCFadeTo:create(0.3, 200))
    arr2_2:addObject(CCDelayTime:create(2.3))
    arr2_2:addObject(CCFadeTo:create(0.2, 0))
    bg:runAction(CCSequence:create(arr2))
    bg2:runAction(CCSequence:create(arr2_1))
    mask:runAction(CCSequence:create(arr2_2))
    local arr3 = CCArray:create()
    arr3:addObject(CCDelayTime:create(0.5))
    arr3:addObject(CCFadeIn:create(0.3))
    arr3:addObject(CCDelayTime:create(2.3))
    arr3:addObject(CCFadeOut:create(0.2))
    text:runAction(CCSequence:create(arr3))
    local arr4 = CCArray:create()
    arr4:addObject(CCDelayTime:create(1))
    arr4:addObject(CCToggleVisibility:create())
    arr4:addObject(CCDelayTime:create(2.3))
    arr4:addObject(CCToggleVisibility:create())
    number:runAction(CCSequence:create(arr4))
    local arr5 = CCArray:create()
    arr5:addObject(CCDelayTime:create(0.9))
    arr5:addObject(CCToggleVisibility:create())
    arr5:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.6, 7), CCFadeOut:create(0.6)))
    star:runAction(CCSequence:create(arr5))
    local arr6 = CCArray:create()
    arr6:addObject(CCDelayTime:create(3.74))
    arr6:addObject(CCToggleVisibility:create())
    arr6:addObject(CCDelayTime:create(0.17))
    arr6:addObject(CCFadeOut:create(0.17))
    local function animFinish()
        if swallowTouchLayer and not swallowTouchLayer.isDisposed then
            swallowTouchLayer:removeFromParentAndCleanup(true)
        end
        mask:removeFromParentAndCleanup(true)
        if finishCallback then finishCallback() end
    end
    arr6:addObject(CCCallFunc:create(animFinish))
    lightItem:runAction(CCSequence:create(arr6))
end

MarkGetEnergyNotiPanel = class(BasePanel)
function MarkGetEnergyNotiPanel:create(boxPosition, callback)
    local panel = MarkGetEnergyNotiPanel.new()
    panel:_init(boxPosition, callback)
    return panel
end

function MarkGetEnergyNotiPanel:_init(boxPosition, callback)
    self.callback = callback

    self:loadRequiredResource(PanelConfigFiles.panel_mark_energy_notionce)

    self.panel = self:buildInterfaceGroup("panelmarkenergynotionce")
    self:init(self.panel)
    self:setPositionForPopoutManager()

    self.bg = self.panel:getChildByName("bg")
    self.text = self.panel:getChildByName("text")
    self.glow = self.panel:getChildByName("glow")
    self.number = self.panel:getChildByName("number")
    self.star = self.panel:getChildByName("star")
    local lightItem = self.panel:getChildByName("lightitem")
    self.item = self.panel:getChildByName("item")
    self.close = self.panel:getChildByName("close")

    local recPosition = self.item:getPosition()
    recPosition = {x = recPosition.x, y = recPosition.y}
    self.size = lightItem:getContentSize()
    self.item:setScale(self.size.width / self.item:getContentSize().width)
    self.boxPosition = boxPosition
    self.star:setVisible(false)
    self.star:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
    self.bg:setOpacity(0)
    self.text:setString(Localization:getInstance():getText("mark.panel.noti.get.title", {n = '\n'}))
    self.text:setOpacity(0)
    self.close:setVisible(false)
    self.glow:setScale(0)
    self.number:setVisible(false)
    lightItem:setVisible(false)

    local arr1 = CCArray:create()
    arr1:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(0.4, ccp(recPosition.x, recPosition.y)),
        CCScaleTo:create(0.4, 1)))
    local function onReach()
        self.close:setTouchEnabled(true)
        self.allowBackKeyTap = true
    end
    arr1:addObject(CCCallFunc:create(onReach))
    arr1:addObject(CCDelayTime:create(3.1))
    local function onClose() self:onCloseBtnTapped() end
    arr1:addObject(CCCallFunc:create(onClose))
    self.item:runAction(CCSequence:create(arr1))
    local arr2 = CCArray:create()
    arr2:addObject(CCDelayTime:create(0.14))
    arr2:addObject(CCFadeIn:create(0.29))
    self.bg:runAction(CCSequence:create(arr2))
    local arr3 = CCArray:create()
    arr3:addObject(CCDelayTime:create(0.14))
    arr3:addObject(CCFadeIn:create(0.29))
    self.text:runAction(CCSequence:create(arr3))
    local arr4 = CCArray:create()
    arr4:addObject(CCDelayTime:create(0.5))
    arr4:addObject(CCToggleVisibility:create())
    self.close:runAction(CCSequence:create(arr4))
    local arr5 = CCArray:create()
    arr5:addObject(CCDelayTime:create(0.4))
    arr5:addObject(CCToggleVisibility:create())
    arr5:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.6, 7), CCFadeOut:create(0.6)))
    self.star:runAction(CCSequence:create(arr5))
    local arr6 = CCArray:create()
    arr6:addObject(CCDelayTime:create(0.4))
    arr6:addObject(CCScaleTo:create(0.12, 2))
    self.glow:runAction(CCRepeatForever:create(CCRotateBy:create(1, 120)))
    self.glow:runAction(CCSequence:create(arr6))
    local arr7 = CCArray:create()
    arr7:addObject(CCDelayTime:create(0.3))
    arr7:addObject(CCToggleVisibility:create())
    self.number:runAction(CCSequence:create(arr7))

    self.close:addEventListener(DisplayEvents.kTouchTap, onClose)

    local scene = HomeScene:sharedInstance()
    local energyButton = scene.energyButton
    if energyButton and not energyButton.isDisposed then
        energyButton:setTempEnergyState(UserEnergyState.COUNT_DOWN_TO_RECOVER)
    end
end

function MarkGetEnergyNotiPanel:popout()
    PopoutManager:sharedInstance():add(self, false, false)
    local position = self.panel:convertToNodeSpace(ccp(self.boxPosition.x, self.boxPosition.y))
    self.item:setPositionXY(position.x - self.size.width / 2, position.y - self.size.height / 2)
end

function MarkGetEnergyNotiPanel:onCloseBtnTapped()
    if not self.allowBackKeyTap then return end
    self.allowBackKeyTap = false
    local scene = HomeScene:sharedInstance()
    local energyButton = scene.energyButton
    if not energyButton or energyButton.isDisposed then
        PopoutManager:sharedInstance():remove(self)
        return
    end
    energyButton:setTempEnergyState(nil)

    local function onAllOver()
        PopoutManager:sharedInstance():remove(self)
        local scene = HomeScene:sharedInstance()
        if scene and not scene.isDisposed then
            scene:checkDataChange()
            local button = scene.energyButton
            if button and not button.isDisposed then
                button:updateView()
            end
        end
        if self.callback then self.callback() end
    end

    local bounds = self.item:getGroupBounds()
    self.item:setVisible(false)

    local anim = FlyTopEnergyBottleAni:create(ItemType.INFINITE_ENERGY_BOTTLE)
    anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
    anim:setFinishCallback(onAllOver)
    anim:play()

    self.bg:runAction(CCFadeOut:create(0.25))
    self.text:runAction(CCFadeOut:create(0.25))
    self.glow:runAction(CCToggleVisibility:create())
    self.number:runAction(CCFadeOut:create(0.25))
    self.close:setVisible(false)
    self.star:setVisible(false)
end


MarkRemindRemarkAnim = class(Layer)
function MarkRemindRemarkAnim:create(parentPanel, require, reward)
	local anim = MarkRemindRemarkAnim.new()
	anim:_init(parentPanel, require, reward)
	return anim
end

function MarkRemindRemarkAnim:_init(parentPanel, require, reward)
	self:initLayer()

	self.parentPanel = parentPanel
	local remarkparent = self.parentPanel.remark.groupNode:getParent()
	local priseparent = self.parentPanel.priseButton:getParent()
	self.parentPanel.remark.groupNode:removeFromParentAndCleanup(false)
    self.parentPanel.remarkLable:removeFromParentAndCleanup(false)
	remarkparent:addChildAt(self.parentPanel.remark.groupNode, 10000) -- 呵呵
    remarkparent:addChildAt(self.parentPanel.remarkLable, 10000) -- 呵呵
    self.saveLableColor = self.parentPanel.remarkLable:getColor()
    self.parentPanel.remarkLable:setColor(ccc3(252, 82, 73))
	self.parentPanel.priseButton:removeFromParentAndCleanup(false)
	priseparent:addChildAt(self.parentPanel.priseButton, 10000) -- 呵呵

	self.parentPanel.ui:addChildAt(self, math.min(self.parentPanel.remark.groupNode:getZOrder()-1, self.parentPanel.priseButton:getZOrder()-1))
	self:setPosition(ccp(0, 0))
	local action = {panelName = 'guide_dialogue_remark', panDelay = 0.3, panFade = 1}
	local panel = GameGuideUI:dialogue( nil , action )
    self.panel = panel
    panel.ui:getChildByName('keepname_lable1'):setString("明日")
    panel.ui:getChildByName('keepname_lable3'):setString("签到，赶快")
    panel.ui:getChildByName('keepname_lable4'):setString("补签，领取签到")
    panel.ui:getChildByName('keepname_lable6'):setString("（价值" .. reward .. "风车币）")
    local richLable = panel.ui:getChildByName('keepname_lable2')
    richLable:setRichText("重新开始", richLable.fntColor or "ffff00")
    richLable = panel.ui:getChildByName('keepname_lable5')
    richLable:setRichText("28天宝箱", richLable.fntColor or "ffff00")

	local mask = LayerColor:create()
    self.mask = mask
	mask:setContentSize(CCSizeMake(3000, 3000))
	mask:setOpacity(200)
	mask:ignoreAnchorPointForPosition(false)
	mask:setAnchorPoint(ccp(0, 0))
	local vs = Director:sharedDirector():ori_getVisibleSize()
	local vo = Director:sharedDirector():getVisibleOrigin()
	mask:setPosition(self.parentPanel:convertToNodeSpace(ccp(0, 0)))

	self.parentPanel:addChild(mask)
	self.parentPanel:addChild(panel)
    local pos = self:convertToNodeSpace(self.parentPanel.remark.groupNode:getParent():convertToWorldSpace(self.parentPanel.remark.groupNode:getPosition()))
    pos.x = pos.x + 50
	panel:setPosition(pos)

    mask:setTouchEnabled(true, 0, true)
    mask:ad(DisplayEvents.kTouchTap, function () 
        if not self.isDisposed then
            self:clear()
        end
    end)

end

function MarkRemindRemarkAnim:clear()
    self.parentPanel.remarkLable:setColor(self.saveLableColor)
	self.mask:removeFromParentAndCleanup(true)
    self.panel:removeFromParentAndCleanup(true)
end