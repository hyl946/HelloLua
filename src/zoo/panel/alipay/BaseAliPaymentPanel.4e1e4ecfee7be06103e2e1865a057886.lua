local Input = require "zoo.panel.phone.Input"
local AliQuickPayGuide = require "zoo.panel.alipay.AliQuickPayGuide"

AliQuickSignEntranceEnum = {
	MARKET_PANEL = 1,
	NEW_GAME_SETTINGS_PANEL = 2,
	CHOOSE_PAYMENT_PANEL = 3,
	BUY_IN_GAME_PANEL = 4,
	VERIFY_PANEL = 5,
    PROMO_PANEL = 6,
}

local BaseAliPaymentPanel = class(BasePanel)

function BaseAliPaymentPanel:adaptResolution()
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	local gamebg = self.ui:getChildByName("bg")
	local size = gamebg:getGroupBounds().size
	size = {width = size.width, height = size.height}
	if _G.isLocalDevelopMode then printx(0, "size: ", size.width, size.height) end
	local scale = vSize.height / size.height
	self:setScale(scale)
	self:setPositionX(vOrigin.x + (vSize.width - size.width * scale) / 2)
	self:setPositionY(0)
end

function BaseAliPaymentPanel:initInput(inputBGName, placeHolder, inputMode, maxLength, hideClearButton)
	local length = maxLength or 50
	local input = Input:create(self.ui:getChildByName(inputBGName), self, hideClearButton)
	input:setText("")
	input:setFontColor(ccc3(180,94,16))
	input:setPlaceholderFontColor(ccc3(241, 208, 165))
	input:setMaxLength(length)
	input:setInputMode(inputMode)
	self.ui:addChild(input)
	input:setPlaceHolder(placeHolder)
	input:setClearButtonBG(1)
	return input
end

function BaseAliPaymentPanel:DCEntrance(step, popoutTimes)
    local payType = 4
    local defaultPayment = PaymentManager:getInstance():getDefaultPayment()
    if  defaultPayment == Payments.ALIPAY then
    	payType = 2	
    elseif defaultPayment == Payments.WECHAT then
    	payType = 3
    elseif PaymentManager:checkPaymentTypeIsSms(defaultPayment) then
        payType = 1
    end

    local guideFlag
    if self.entrance == AliQuickSignEntranceEnum.BUY_IN_GAME_PANEL then
    	guideFlag = 0
    else
    	guideFlag = AliQuickPayGuide.isGuideTime() and 0 or 1
    end
    if _G.isLocalDevelopMode then printx(0, "self.entrance: "..tostring(self.entrance)..",guideFlag: "..tostring(guideFlag)) end



    self.payType = payType
    self.popoutTimes = popoutTimes
    self.guideFlag = guideFlag
    self.step = step
    self.t1 = 10*self.entrance + self.payType
    self.t2 = (self.guideFlag == 1) and 4 or self.popoutTimes

    DcUtil:UserTrack({ category='alipay_mianmi_accredit',
                       sub_category='accredit_flow_source', 
                       t1 = self.t1,
                       t2 = self.t2,
                       -- t3 = popoutTimes,
                       t4 = guideFlag,
                       t5 = step,})
end

function BaseAliPaymentPanel:popout(cancelCallback, signSuccessCallback)
	self.cancelCallback = cancelCallback
	self.signSuccessCallback = signSuccessCallback

	self.allowBackKeyTap = true
	PopoutManager:sharedInstance():add(self, true, false)
end

function BaseAliPaymentPanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self, true)
end

return BaseAliPaymentPanel