require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"


PennyPayIcon = class(IconButtonBase)

function PennyPayIcon:create()
    local instance = PennyPayIcon.new()
    instance:init()
    instance:initShowHideConfig(ManagedIconBtns.ONEYUANSHOP)
    return instance
end

function PennyPayIcon:init()
    self.ui = ResourceManager:sharedInstance():buildGroup('penny_icon')
    IconButtonBase.init(self, self.ui)
    self.ui:setTouchEnabled(true)
    self.ui:setButtonMode(true)
    self:setCdTime()
end

function PennyPayIcon:stopTimer()
    if self.schedId then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId)
        self.schedId = nil
    end
end

function PennyPayIcon:setCdTime()
    self:stopTimer()
    self.cdTime = PromotionManager:getInstance():getPennyPayRestTime()
    local function onTick()
        if self.isDisposed then return end
        if self.cdTime > 0 then
            self.cdTime = PromotionManager:getInstance():getPennyPayRestTime()
        else
            self:stopTimer()
            PromotionManager:getInstance():onTimeOut()
        end
    end
    if self.cdTime > 0 then
        self.schedId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTick, 1, false)
    end
    onTick()
end

function PennyPayIcon:dispose()
    self:stopTimer()
    IconButtonBase.dispose(self)
end