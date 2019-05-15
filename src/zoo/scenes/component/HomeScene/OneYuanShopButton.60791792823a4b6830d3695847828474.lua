require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"


OneYuanShopButton = class(IconButtonBase)

function OneYuanShopButton:create(time, proType)
    local instance = OneYuanShopButton.new()
    instance:init(time, proType)
    instance:initShowHideConfig(ManagedIconBtns.ONEYUANSHOP)
    return instance
end

function OneYuanShopButton:init(time, proType)
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_sales')

    IconButtonBase.init(self, self.ui)
    self:setCdTime()
end

function OneYuanShopButton:stopTimer()
    if self.schedId then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId)
        self.schedId = nil
    end
end

function OneYuanShopButton:setCdTime()
    self:stopTimer()
    if __IOS then 
        self.cdTime = IosPayGuide:getOneYuanShopLeftSeconds() or 0
    elseif __ANDROID then 
        self.cdTime = AndroidSalesManager.getInstance():getItemSalesLeftSeconds() or 0
    else
        self.cdTime = 0
    end
    local function onTick()
        if self.cdTime <= 0 then return end
        if self.isDisposed then return end
        if __IOS then 
            self.cdTime = IosPayGuide:getOneYuanShopLeftSeconds() or 0
        elseif __ANDROID then 
            self.cdTime = AndroidSalesManager.getInstance():getItemSalesLeftSeconds() or 0
        end
        if self.cdTime >= 0 then
            self:setCustomizedLabel(convertSecondToHHMMSSFormat(self.cdTime))
        else
            self:stopTimer()
        end
    end
    if self.cdTime > 0 then
        self.schedId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTick, 1, false)
    end
    onTick()
end

function OneYuanShopButton:dispose()
    self:stopTimer()
    IconButtonBase.dispose(self)
end