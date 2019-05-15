require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"

MarketButton = class(IconButtonBase)

function MarketButton:init()
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_market')


    if _G.StoreManager:getInstance():isEnabled() then
        self.ui:getChildByPath('wrapper/icon'):removeFromParentAndCleanup(true)
        self.ui:getChildByPath('wrapper/icon2').name = 'icon'
        self.ui:getChildByPath('label'):setVisible(false)
    else
        self.ui:getChildByPath('wrapper/icon2'):removeFromParentAndCleanup(true)
        self:addRedDotDiscount()
        self.ui:getChildByPath('new_label'):setVisible(false)
    end

    IconButtonBase.init(self, self.ui)
end

function MarketButton:create()
    local instance = MarketButton.new()
    instance:initShowHideConfig(ManagedIconBtns.MARKET)
    instance:init()
    return instance
end

function MarketButton:showNew(isShow)
end

function MarketButton:showDiscount(isShow)
end

function MarketButton:showReward(isShow)
end

function MarketButton:buildAnimation()
    local expand1 = CCScaleTo:create(7/24, 1.2)
    local shrink1 = CCScaleTo:create(7/24, 1)
    local expand2 = CCScaleTo:create(7/24, 1.2)
    local shrink2 = CCScaleTo:create(7/24, 1)
    local delay = CCDelayTime:create(90/24)
    local actions = CCArray:create()
    actions:addObject(expand1)
    actions:addObject(shrink1)
    actions:addObject(expand2)
    actions:addObject(shrink2)
    actions:addObject(delay)
    local repeatAction = CCRepeatForever:create(CCSequence:create(actions))
    return repeatAction
end

function MarketButton:playTopTip(tipTxt)
    self.topTip = ResourceManager:sharedInstance():buildGroup("market_btn_tip_homeScene")
    self.topTip:getChildByName('txt'):setString(tipTxt)
    self.ui:addChild(self.topTip)
    self.topTip:setPosition(ccp(0, 105))
    self.topTip:runAction(self:buildAnimation())

end

function MarketButton:stopTopTip()
    if self.topTip then
        self.topTip:removeFromParentAndCleanup(true)
        self.topTip = nil
    end
end

function MarketButton:showThirdPayPromotion(isShow, seconds)
    if self.isDisposed then return end
    if not seconds or seconds <= 0 then
        seconds = 0
    end
    self.thirdPayPromo:setVisible(isShow)
    if isShow then
        self.thirdPayPromo:runAction(self:buildAnimation())
        self:showDiscount(false) --避免冲突
    else
        self.thirdPayPromo:stopAllActions()
    end
    local function timeup()
        if self.isDisposed then return end
        self.thirdPayPromo:stopAllActions()
        self.thirdPayPromo:setVisible(false)
        self:showDiscount(MarketManager:sharedInstance():shouldShowMarketButtonDiscount())
        self:showNew(MarketManager:sharedInstance():shouldShowMarketButtonNew())
        if self.thirdPaySchedId then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.thirdPaySchedId)
        end
    end
    if self.thirdPaySchedId then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.thirdPaySchedId)
    end
    if seconds > 0 then
        self.thirdPaySchedId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(timeup,seconds,false)
    end
end