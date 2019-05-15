require 'zoo.util.OpenUrlUtil'

local PromotionGoodsIdOffset = 5000

ThirdPayGuidePanel = class(BasePanel)
function ThirdPayGuidePanel:create(paymentType)
    local instance = ThirdPayGuidePanel.new()
    instance:loadRequiredResource(PanelConfigFiles.third_pay_guide_panel)
    instance:init(paymentType)
    return instance
end
function ThirdPayGuidePanel:init(paymentType)
    local ui = self:buildInterfaceGroup('ThirdPayGuidePanel')
    BasePanel.init(self, ui)
    local txt = ui:getChildByName('txt')
    txt:setString(localize('pay.fail.help.text'))
    local btn = GroupButtonBase:create(ui:getChildByName('btn'))
    btn:setString(localize('hide.area.panel.go.and.see.btn'))
    btn:ad(DisplayEvents.kTouchTap, function () self:onBtnTapped() end)
    local closeBtn = ui:getChildByName('closeBtn')
    closeBtn:setTouchEnabled(true, 0, true)
    closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)
    self.paymentType = paymentType
end
function ThirdPayGuidePanel:onBtnTapped()
    DcUtil:UserTrack({category = "pay", sub_category = "pay_help_panel_click"}, true)
    self:onCloseBtnTapped()
    OpenUrlUtil:openUrl(ThirdPayGuideLogic:getHelpAddress(self.paymentType))
end
function ThirdPayGuidePanel:onCloseBtnTapped()
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self, true)
    if self.closeCallback then
        self.closeCallback()
    end
end
function ThirdPayGuidePanel:popout(closeCallback)
    DcUtil:UserTrack({category = "pay", sub_category = "pay_help_panel_pop"}, true)
    PopoutManager:sharedInstance():add(self, false, false)
    self:setToScreenCenterVertical()
    self:setPositionY(self:getPositionY() + 130)
    self:runAction(CCEaseElasticOut:create(CCMoveBy:create(0.8, ccp(0, -130))))

    self.allowBackKeyTap = true
    self.closeCallback = closeCallback
end

ThirdPayGuideLogic = class()

local instance = nil
function ThirdPayGuideLogic:get()
    if not instance then
        instance = ThirdPayGuideLogic.new()
        instance:init()
    end
    return instance
end

function ThirdPayGuideLogic:init()

end

function ThirdPayGuideLogic:onPayFailure(paymentType, closeCallback)
    if _G.StoreManager and _G.StoreManager:safeIsEnabled() then
        if closeCallback then closeCallback() end
        return
    end
    if CCUserDefault:sharedUserDefault():getBoolForKey("third.pay.first.failure.has.played", false) then
        if closeCallback then closeCallback() end
        return
    end
    ThirdPayGuidePanel:create(paymentType):popout(closeCallback)
    CCUserDefault:sharedUserDefault():setBoolForKey("third.pay.first.failure.has.played", true)
end

function ThirdPayGuideLogic:isPromotionGoods(goodsId)
    -- 活动期间有限商城风车币特价，不出这个特价
    if _G.thirdPayConfig and _G.thirdPayConfig.isSupport() then
        return nil
    end
    local isInTable = ThirdPayPromotionConfig[goodsId]
    return isInTable
end

function ThirdPayGuideLogic:shouldShowMarketBtnTip()
    if _G.thirdPayConfig and _G.thirdPayConfig.isSupport() then
        local yearDay = os.date('*t', Localhost:time() / 1000).yday  -- 虽然yday并不是全局唯一，但是在活动中可以保证是不重复的
        if not CCUserDefault:sharedUserDefault():getBoolForKey("third.pay.market.tip."..yearDay, false) then
            return true
        end
    end
    return false
end

function ThirdPayGuideLogic:MarketBtnTipPlayed()
    local yearDay = os.date('*t', Localhost:time() / 1000).yday
    CCUserDefault:sharedUserDefault():setBoolForKey("third.pay.market.tip."..yearDay, true)
end

function ThirdPayGuideLogic:getHelpAddress(paymentType)
    if paymentType == Payments.WECHAT or paymentType == Payments.QQ then
        return 'http://xiaoqu.qq.com/mobile/detail.html?&&_wv=1027#bid=130050&pid=4748639-1433834487&source=barindex&from=buluoadmin'
    elseif paymentType == Payments.ALIPAY then
        return 'http://xiaoqu.qq.com/mobile/detail.html?&&_wv=1027#bid=130050&pid=4748639-1433834948&source=barindex&from=buluoadmin'
    end
end