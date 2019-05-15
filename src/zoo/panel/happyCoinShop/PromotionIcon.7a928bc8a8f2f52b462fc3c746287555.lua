require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"


PromotionIcon = class(IconButtonBase)

function PromotionIcon:create()
    local instance = PromotionIcon.new()
    instance:init()
    instance:initShowHideConfig(ManagedIconBtns.ONEYUANSHOP)
    return instance
end

function PromotionIcon:init()
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_sales')
    IconButtonBase.init(self, self.ui)
    self:setCdTime()
end

function PromotionIcon:stopTimer()
    if self.schedId then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId)
        self.schedId = nil
    end
end

function PromotionIcon:setCdTime()
    self:stopTimer()
    self.cdTime = PromotionManager:getInstance():getRestTime()
    local function onTick()
        if self.isDisposed then return end
        if self.cdTime > 0 then
            self:setCustomizedLabel(convertSecondToHHMMSSFormat(self.cdTime))
            self.cdTime = PromotionManager:getInstance():getRestTime()
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

function PromotionIcon:dispose()
    self:stopTimer()
    IconButtonBase.dispose(self)
end