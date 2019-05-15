AutoClosePanel = class(BasePanel)

function AutoClosePanel:ctor()
end

function AutoClosePanel:enableAutoClose(closeFunc)
    self.closeFunc = closeFunc
	local function onTouchCurrentLayer(eventType, x, y)
        if self.isDisposed then return end
        local worldPosition = ccp(x, y)
        local panelGroupBounds = self.ui:getGroupBounds()
        if panelGroupBounds:containsPoint(worldPosition) then
        else
        	self:onAutoClose()
        end
        return panelGroupBounds:containsPoint(worldPosition)
	end
	self.ui:registerScriptTouchHandler(onTouchCurrentLayer, false, 0, true)
    self.ui.refCocosObj:setTouchEnabled(true)
    self.allowBackKeyTap = true
end

function AutoClosePanel:onAutoClose()
    if not self.isDisposed then
        self:disableAutoClose()
        if self.closeFunc then
            self.closeFunc()
        end
    end
end

function AutoClosePanel:disableAutoClose()
    self.allowBackKeyTap = false
	self.ui:unregisterScriptTouchHandler()
	self.ui.refCocosObj:setTouchEnabled(false) 
end

function AutoClosePanel:getID()
    return nil
end

function AutoClosePanel:getType()
    return nil
end

function AutoClosePanel:popout()
    local visibleSize = Director:sharedDirector():getVisibleSize()
    local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
    local panelSize = self:getGroupBounds().size

    if self.ui:getChildByName('bg') then
        panelSize = self.ui:getChildByName('bg'):getGroupBounds().size
    end

    self:setPositionY(panelSize.height + visibleOrigin.y + visibleSize.height)
    self:setPositionX((visibleSize.width - panelSize.width) /2 + visibleOrigin.x)
    Director:sharedDirector():getRunningScene():addChild(self, SceneLayerShowKey.TOP_LAYER)

    -- PopoutQueue:sharedInstance():push(self, false, true)

    local arr = CCArray:create()
    arr:addObject(CCMoveBy:create(0.5, ccp(0, - 32 - panelSize.height)))
    arr:addObject(CCDelayTime:create(4))
    arr:addObject(CCMoveBy:create(0.2, ccp(0,  32 + panelSize.height)))
    arr:addObject(CCCallFunc:create(function()
        self:close()
    end))
    self:runAction(CCSequence:create(arr))
end

function AutoClosePanel:popoutShowTransition()
    
end

function AutoClosePanel:closeRightNow()
    if not self.isDisposed then

        local panelSize = self:getGroupBounds().size

        self:stopAllActions()
        local arr = CCArray:create()
        arr:addObject(CCMoveBy:create(0.2, ccp(0,  32 + panelSize.height)))
        arr:addObject(CCCallFunc:create(function()
            self:close()
        end))
        self:runAction(CCSequence:create(arr))
    end

    -- PopoutManager:sharedInstance():remove(self, false)
    
    -- self:addWithoutPopoutManager()
end

function AutoClosePanel:close()
    if not self.isDisposed then
        self:stopAllActions()
        if self.afterClose then
            self.afterClose()
        end

        -- if self.isWithoutPopoutManager then
        --     self:removeWithoutPopoutManager()
        -- else
        --     PopoutManager:sharedInstance():remove(self, true)
        -- end
        self:removeFromParentAndCleanup(true)
    end
end

-- function AutoClosePanel:addWithoutPopoutManager()
--     self.container = Layer:create()

--     local origin = Director:sharedDirector():getVisibleOrigin()
--     local size = Director:sharedDirector():getVisibleSize()
--     self.container:setPosition(ccp(
--         origin.x,
--         origin.y + size.height
--     ))
--     self.container:addChild(self)

--     local scene =  Director:sharedDirector():getRunningScene()

--     if scene then
--         scene:addChild(self.container, SceneLayerShowKey.TOP_LAYER)
--     end

--     self.isWithoutPopoutManager = true
-- end

-- function AutoClosePanel:removeWithoutPopoutManager()
--     self.container:removeFromParentAndCleanup(true)
-- end

function AutoClosePanel:onKeyBackClicked()
    if self.allowBackKeyTap then
        self:onAutoClose()
    end
end

function AutoClosePanel:onEnterHandler()
end

function AutoClosePanel:isCareGuide()
    return true
end

function AutoClosePanel:isCarePanel()
    return true
end

function AutoClosePanel:isCareHomeQueue()
    return true
end