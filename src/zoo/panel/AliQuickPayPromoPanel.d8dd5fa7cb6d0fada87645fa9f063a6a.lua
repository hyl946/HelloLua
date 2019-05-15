
AliQuickPayPromoPanel = class(BasePanel)

function AliQuickPayPromoPanel:create(...)
    local instance = AliQuickPayPromoPanel.new()
    instance:loadRequiredResource('ui/ali_mm_promo_panel.json')
    instance:init(...)
    return instance
end

function AliQuickPayPromoPanel:init(buySuccessCallback)
    local ui = self.builder:buildGroup('alipay_promo_panel')
    BasePanel.init(self, ui)

    self.buyButton = GroupButtonBase:create(self.ui:getChildByName('buyBtn'))
    self.buyButton:setColorMode(kGroupButtonColorMode.blue)
    self.helpButton = self.ui:getChildByName('helpBtn')

    self.text = self.ui:getChildByName('text')
    self.text:setString(localize('alipay.kf.1fenpay.title'))
    self.closeBtn = self.ui:getChildByName('closeBtn')

    self.buyButton:setEnabled(true)
    self.buyButton:setString('')
    self.buyButton:ad(DisplayEvents.kTouchTap, function () self:onBuyButtonTapped() end)

    self.helpButton:setTouchEnabled(true, 0, true)
    self.helpButton:ad(DisplayEvents.kTouchTap, function () self:onHelpButtonTapped() end)

    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)

    self.ui:getChildByName('flyPos'):setVisible(false)
    

    self.goodsId = 70 -- test

    self.buySuccessCallback = buySuccessCallback

end 

function AliQuickPayPromoPanel:removeSelf()
    PopoutManager:sharedInstance():remove(self, true)
end

function AliQuickPayPromoPanel:onCloseBtnTapped()
    self.allowBackKeyTap = false
    self:removeSelf()
end

function AliQuickPayPromoPanel:onBuyButtonTapped()
    if self.isInRequest then return end

    self.isInRequest = true
    local flyPos = self.ui:getChildByName('flyPos'):getParent():convertToWorldSpace(self.ui:getChildByName('flyPos'):getPosition())

    local function addReward()
        local user = UserManager:getInstance().user
        local serv = UserService:getInstance().user
        local oldCash = user:getCash()
        local newCash = oldCash + 30;
        user:setCash(newCash)
        serv:setCash(newCash)

        local userExtend = UserManager:getInstance().userExtend
        if type(userExtend) == "table" then userExtend.payUser = true end
        if __IOS or __WIN32 then
            UserManager:getInstance():getUserExtendRef():setLastPayTime(Localhost:time())
            UserService:getInstance():getUserExtendRef():setLastPayTime(Localhost:time())
        end

        GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kTrunk, ItemType.GOLD, 30, DcSourceType.kAliQuickPayPro)
   
        if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
        else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

        if __IOS or __WIN32 then 
            GlobalEventDispatcher:getInstance():dispatchEvent(
                Event.new(kGlobalEvents.kConsumeComplete,{
                    price=0.01,
                    props=Localization:getInstance():getText("consume.history.panel.gold.text",{n=30}),
                    goodsId=self.goodsId,
                    goodsType=2
                })
            )
        end
    end

    local function playFlyGold()
        local anim = FlyItemsAnimation:create({{itemId = ItemType.GOLD, num = 30}})
        anim:setWorldPosition(flyPos)
        anim:play()
    end

    local function onBuySuccess()
        addReward()
        playFlyGold()
        AliQuickPayPromoLogic:endPromotion()
        if self.buySuccessCallback then
            self.buySuccessCallback()
        end
        PlatformConfig:setCurrentPayType()
        if self.isDisposed then return end
        self.isInRequest = false
        self.buyButton:setEnabled(false)
        self:removeSelf()
    end

    local function onBuyFail(errCode, errMsg)
        if errMsg then
            CommonTip:showTip(errMsg, 'negative', nil, 4)
        end
        PlatformConfig:setCurrentPayType()
        if self.isDisposed then return end
        self.isInRequest = false
        self.buyButton:setEnabled(true)
        if errCode == 730253 then
            self:removeSelf()
        end
    end

    local function onBuyCancel()
        PlatformConfig:setCurrentPayType()
        if self.isDisposed then return end
        self.isInRequest = false
        self.buyButton:setEnabled(true)
    end

    local function onSignSuccess()
        PlatformConfig:setCurrentPayType(Payments.ALIPAY)
        self.buyLogic = IngamePaymentLogic:create(self.goodsId, GoodsType.kCurrency, DcFeatureType.kTrunk, DcSourceType.kAliQuickPayPro)
        self.buyLogic:ignoreSecondConfirm(true)
        self.buyLogic:buy(onBuySuccess, onBuyFail, onBuyCancel, true)
    end
    local function onSignCancel()
        self.isInRequest = false
        self.buyButton:setEnabled(true)
    end

    self.buyButton:setEnabled(false)

    if not UserManager:getInstance():isAliSigned() then
        -- local AliPaymentSignAccountPanel = require "zoo.panel.alipay.AliPaymentSignAccountPanel"
        -- local panel = AliPaymentSignAccountPanel:create(AliQuickSignEntranceEnum.PROMO_PANEL)
        -- panel:setReduceShowOption(AliPaymentSignAccountPanel.showOneFen)
        -- panel:popout(onSignCancel, onSignSuccess)
        local function onSignCallback(ret, data)
            if ret == AlipaySignRet.Success then
                if self.isDisposed then return end
                onSignSuccess()
            elseif ret == AlipaySignRet.Cancel then
                onSignCancel()
            elseif ret == AlipaySignRet.Fail then
            end
        end
        AlipaySignLogic.getInstance():startSign(AliQuickSignEntranceEnum.PROMO_PANEL, onSignCallback)
    else
        onSignSuccess()
    end
    DcUtil:UserTrack({category = 'alipay_mm_299_event', sub_category = '1fen_pay_button'})
end

function AliQuickPayPromoPanel:onHelpButtonTapped()
    local AliQuickPayInfoPanel = require 'zoo.panel.alipay.AliQuickPayInfoPanel'
    AliQuickPayInfoPanel:create():popout()
    -- 转移到panel里面打点
    -- DcUtil:UserTrack({category = 'alipay_mm_299_event', sub_category = '299_help'})
end

function AliQuickPayPromoPanel:popout()
    self.allowBackKeyTap = true
    self:setPositionForPopoutManager()
    PopoutQueue:sharedInstance():push(self, true, false)
end

function AliQuickPayPromoPanel:dispose()
    PlatformConfig:setCurrentPayType()
    BasePanel.dispose(self)
end