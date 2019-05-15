--[[
 * GiftPackDiscountButton
 * @date    2019-01-07 16:37:55
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"

GiftPackDiscountButton = class(IconButtonBase)

function GiftPackDiscountButton:ctor()
    self.idPre = "GiftPackDiscountButton"
    self.playTipPriority = 1010
end

function GiftPackDiscountButton:init(goodsId)
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_giftpack_discount')
    IconButtonBase.init(self, self.ui)
    self.goodsId = goodsId

    self["tip"..IconTipState.kReward] = Localization:getInstance():getText("gift.pack.discount.button.tip.reward")

    self.rewardDot = self:addRedDotReward()
    self.rewardDot:setVisible(false)

    self:startCountdown(GiftPack:getPackDeadline(goodsId)/1000)

    self:update()
end

function GiftPackDiscountButton:update()
    local hasAnyReward = GiftPack:hasAnyReward()
    self.rewardDot:setVisible(hasAnyReward)
    if hasAnyReward then
        self:playRedDotJumpAni(self.rewardDot)
        self:playHasRewardAni()
        self:showTip(IconTipState.kReward)
    else
        self:stopHasRewardAni()
        self:stopRedDotJumpAni(self.rewardDot)
        self:stopHasNotificationAnim()
    end

    if not GiftPack:isEnabledNewerPackOne() then
        GiftPack:removeHomeIcon(self.goodsId)
    else
        local goodsIds = GiftPack:getNewerPackOneGoodsIds()
        if GiftPack:hasAllBought(goodsIds) or GiftPack:hasExpPack( goodsIds ) then
            self:stopCountdown()
            self:setCustomizedLabel('')
            self:setOriLabelVisible(true)
        end
    end
end

function GiftPackDiscountButton:showTip(tipState)
    if not tipState then return end 

    if self.tipState == tipState then
        return
    end

    self:stopHasNotificationAnim()

    self.tipState = tipState
    self.id = self.idPre .. self.tipState
    local tips = self["tip"..self.tipState]
    if tips then 
        self:setTipPosition(IconButtonBasePos.RIGHT)
        self:setTipString(tips)
        self:playHasNotificationAnim()
    end
end

function GiftPackDiscountButton:create(goodsId)
    local btn = GiftPackDiscountButton.new()
    btn:init(goodsId)
    btn:initShowHideConfig(ManagedIconBtns.GIFT_PACK_DISCOUNT)
    return btn
end

GiftPackYouhuiButton = class(IconButtonBase)

function GiftPackYouhuiButton:ctor()
    self.idPre = "GiftPackYouhuiButton"
    self.playTipPriority = 1010
end

function GiftPackYouhuiButton:init(goodsId)
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_giftpack_youhui')
    IconButtonBase.init(self, self.ui)

    self.goodsId = goodsId

    self:startCountdown(GiftPack:getPackDeadline(goodsId)/1000, nil, function ()
        GiftPack:removeHomeIcon(goodsId)
    end)
end

function GiftPackYouhuiButton:update()
    if not GiftPack:checkPack(self.goodsId) then
        GiftPack:removeHomeIcon(self.goodsId)
    end
end

function GiftPackYouhuiButton:create(goodsId)
    local btn = GiftPackYouhuiButton.new()
    btn:init(goodsId)
    btn:initShowHideConfig(ManagedIconBtns.GIFT_PACK_YOUHUI)
    return btn
end