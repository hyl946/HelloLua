
local Qixi2017TipPanel = class(BasePanel)

function Qixi2017TipPanel:create(passed)
    local panel = Qixi2017TipPanel.new()
    panel:init(passed)
    return panel
end

function Qixi2017TipPanel:init(passed)
    local ui = ResourceManager:sharedInstance():buildGroup("qixi_2017/qixi_2017_tip_panel")
    BasePanel.init(self, ui)
    
    self.bg1 = self.ui:getChildByName('bg1')
    self.bg2 = self.ui:getChildByName('bg2')

    self.ui:getChildByName('passed'):setVisible(passed)
    self.ui:getChildByName('normal'):setVisible(not passed)
    
end

function Qixi2017TipPanel:popout()

    local originSize = self.ui:getGroupBounds().size
    local wSize = Director:sharedDirector():getWinSize()
    local vSize = Director:sharedDirector():getVisibleSize()
    local vOrigin = Director:sharedDirector():getVisibleOrigin()
    local size = self.ui:getGroupBounds().size

    self:setPosition(ccp(vSize.width / 2, (vSize.height - size.height) / 2 + vOrigin.y + originSize.height / 3 - vSize.height))
    self:setScale(0)

    local function onTimeout() self:fadeOut() end

    local duration = duration or 2

    local function onScaled() 
        self.schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, duration, false) 
    end
        
    self:runAction(CCSequence:createWithTwoActions(CCEaseBackOut:create(CCScaleTo:create(0.2, 1)), CCCallFunc:create(onScaled)))

    PopoutManager:sharedInstance():add(self, false)

    self:enableAutoClose(function ( ... )
        self:fadeOut()
    end)

end

function Qixi2017TipPanel:enableAutoClose(closeFunc)
    local function onTouchCurrentLayer(eventType, x, y)
        if not self.isDisposed then
            local worldPosition = ccp(x, y)
            local panelGroupBounds = self.ui:getGroupBounds()
            if panelGroupBounds:containsPoint(worldPosition) then
            else
                self:disableAutoClose()
                if closeFunc then
                    closeFunc()
                end
            end
            return true
        end
    end
    self.ui:registerScriptTouchHandler(onTouchCurrentLayer, false, 0, true)
    self.ui.refCocosObj:setTouchEnabled(true)
end

function Qixi2017TipPanel:disableAutoClose()
    if not self.isDisposed then
        self.ui:unregisterScriptTouchHandler()
        self.ui.refCocosObj:setTouchEnabled(false) 
    end
end


function Qixi2017TipPanel:fadeOut()
    if self.schedule and (not self.ui.isDisposed) then

        Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule)
        self.schedule = nil

        local function doFade()
            if not self.ui.isDisposed then
                self.bg1:runAction(CCFadeOut:create(0.2))
                self.bg2:runAction(CCFadeOut:create(0.2))
            end
        end
        self:stopAllActions()
        local fade = CCSpawn:createWithTwoActions(CCMoveBy:create(0.2, ccp(0, 100)), CCCallFunc:create(doFade))
        local function removeSelf()
            if not self.ui.isDisposed then self:removeSelf() end
        end
        self:runAction(CCSequence:createWithTwoActions(fade, CCCallFunc:create(removeSelf)))
    else 
        return 
    end
end

function Qixi2017TipPanel:removeSelf()
    PopoutManager:sharedInstance():remove(self, true)
end

return Qixi2017TipPanel
