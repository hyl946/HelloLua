local UIHelper = require 'zoo.panel.UIHelper'

local EnergyAlertPanel = class(BasePanel)

function EnergyAlertPanel:create(min, finishCallback)
    local panel = EnergyAlertPanel.new()
    panel:loadRequiredResource("ui/GiftPackEnergy.json")
    panel:init(min, finishCallback)
    return panel
end

function EnergyAlertPanel:popoutShowTransition( ... )
    self.allowBackKeyTap = false
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
end

function EnergyAlertPanel:popout()
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():add(self, true, false)
    self:popoutShowTransition()
end

function EnergyAlertPanel:onCloseBtnTapped()
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self)
end

function EnergyAlertPanel:init(min, finishCallback)
    self.ui = self:buildInterfaceGroup('giftpack.energy/panelmarkenergynotionce_xmas')
    BasePanel.init(self, self.ui)

    local bg = self.ui:getChildByName("bg")
    local bg2 = self.ui:getChildByName('bg2')
    local text = self.ui:getChildByName("text")
    local glow = self.ui:getChildByName("glow")
    local number = self.ui:getChildByName("number")
    local star = self.ui:getChildByName("star")
    local lightItem = self.ui:getChildByName("lightitem")


    local newItem = ResourceManager:sharedInstance():buildItemSpriteWithDecorate(10098, min or 30)
    newItem.name = 'item'

    local item = self.ui:getChildByName("item")
    local itemPos = item:getPosition()
    item:removeFromParentAndCleanup(true)
    item = newItem
    newItem:setPosition(ccp(itemPos.x + 50, itemPos.y - 50))
    newItem:setAnchorPoint(ccp(0.5, 0.5))
    self.ui:addChild(newItem)

    local scaleFactor = 1.25

    newItem:setScale(scaleFactor)


    local close = self.ui:getChildByName("close")

    local position = self.ui:convertToNodeSpace(ccp(0, -400))
    local recPosition = item:getPosition()
    recPosition = {x = recPosition.x, y = recPosition.y}
    item:setPositionY(position.y)
    star:setVisible(false)
    star:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
    bg:setOpacity(0)
    bg2:setOpacity(0)
    -- mask:setOpacity(0)
    local txt = "%d分钟无限精力已激活，\n抓紧时间闯关吧~"
    text:setString(string.format(txt, min or 30))
    text:setOpacity(0)
    glow:setVisible(false)
    number:setVisible(false)
    lightItem:setVisible(false)
    close:setVisible(false)
    -- position = self.ui:convertToNodeSpace(ccp(boxPosition.x, boxPosition.y))
    local size = lightItem:getContentSize()
    -- lightItem:setPositionXY(position.x - size.width / 2, position.y + size.height / 2)

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


    arr1:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.12, ccp(0, -10)), CCScaleTo:create(0.12, 1 * scaleFactor, 0.9 * scaleFactor)))
    arr1:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.12, ccp(0, 20)), CCScaleTo:create(0.12, 1 * scaleFactor)))
    arr1:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.12, ccp(0, -12)), CCScaleTo:create(0.12, 1 * scaleFactor, 0.97 * scaleFactor)))
    arr1:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.08, ccp(0, 2)), CCScaleTo:create(0.08, 1 * scaleFactor)))
    arr1:addObject(CCDelayTime:create(2.3))
    local bSize = item:getContentSize()
    -- arr1:addObject(CCSpawn:createWithTwoActions(CCEaseBackIn:create(CCMoveTo:create(0.375,
    --     ccp(position.x - size.width / 2, position.y + size.height / 2))),
    --     CCScaleTo:create(0.375, size.width / bSize.width)))
    -- arr1:addObject(CCToggleVisibility:create())
    item:runAction(CCSequence:create(arr1))
    local arr2 = CCArray:create()
    arr2:addObject(CCDelayTime:create(0.5))
    arr2:addObject(CCFadeIn:create(0.3))
    arr2:addObject(CCDelayTime:create(2.3))
    -- arr2:addObject(CCFadeOut:create(0.2))
    local arr2_1 = CCArray:create()
    arr2_1:addObject(CCDelayTime:create(0.5))
    arr2_1:addObject(CCFadeIn:create(0.3))
    arr2_1:addObject(CCDelayTime:create(2.3))
    -- arr2_1:addObject(CCFadeOut:create(0.2))
    local arr2_2 = CCArray:create()
    arr2_2:addObject(CCDelayTime:create(0.5))
    arr2_2:addObject(CCFadeTo:create(0.3, 200))
    arr2_2:addObject(CCDelayTime:create(2.3))
    arr2_2:addObject(CCFadeTo:create(0.2, 0))
    bg:runAction(CCSequence:create(arr2))
    bg2:runAction(CCSequence:create(arr2_1))
    -- mask:runAction(CCSequence:create(arr2_2))
    local arr3 = CCArray:create()
    arr3:addObject(CCDelayTime:create(0.5))
    arr3:addObject(CCFadeIn:create(0.3))
    arr3:addObject(CCDelayTime:create(2.3))
    -- arr3:addObject(CCFadeOut:create(0.2))
    text:runAction(CCSequence:create(arr3))
    local arr4 = CCArray:create()
    arr4:addObject(CCDelayTime:create(1))
    arr4:addObject(CCToggleVisibility:create())
    arr4:addObject(CCDelayTime:create(2.3))
    -- arr4:addObject(CCToggleVisibility:create())
    number:runAction(CCSequence:create(arr4))
    local arr5 = CCArray:create()
    arr5:addObject(CCDelayTime:create(0.9))
    arr5:addObject(CCToggleVisibility:create())
    -- arr5:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.6, 7), CCFadeOut:create(0.6)))
    star:runAction(CCSequence:create(arr5))
    local arr6 = CCArray:create()
    arr6:addObject(CCDelayTime:create(3.74))
    -- arr6:addObject(CCToggleVisibility:create())
    arr6:addObject(CCDelayTime:create(0.17))
    -- arr6:addObject(CCFadeOut:create(0.17))
    local function animFinish()
        if swallowTouchLayer and not swallowTouchLayer.isDisposed then
            swallowTouchLayer:removeFromParentAndCleanup(true)
        end
        
        self:onCloseBtnTapped()

        if finishCallback then finishCallback() end
    end
    arr6:addObject(CCCallFunc:create(animFinish))
    lightItem:runAction(CCSequence:create(arr6))
end

return EnergyAlertPanel