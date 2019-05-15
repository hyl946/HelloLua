local TradeUtils = require 'zoo.panel.endGameProp.lottery.TradeUtils'
local CommonViewLogic = require 'zoo.panel.store.views.CommonViewLogic'
local BuyGoodsBtnLogic = {}

BuyGoodsBtnLogic.Mode = {
	kBuyWithGold = 1,
	kBuyWithRMB = 2,
	kBuyWithGoldIfEnoughOtherwiseRMB = 3,
}


function BuyGoodsBtnLogic:removeLoadingAnim( context )
	if not context then return end
	if context.loadingAnimation then
		context.loadingAnimation:removeFromParentAndCleanup(true)
		context.loadingAnimation = nil
	end
end

function BuyGoodsBtnLogic:showLoadingAnim( context )
	if context.ui.isDisposed then return end
	if context.loadingAnimation then
		return
	end
	context.loadingAnimation = CountDownAnimation:createNetworkAnimation(
		Director:sharedDirector():getRunningScene(), 
		nil,
		localize("")
	)
end


function BuyGoodsBtnLogic:init( buttonGroup, goodsId, mode, successCallback, failCallback, cancelCallback, updateGold)
	if buttonGroup.__BuyGoodsBtnLogic_Context then
		return 
	end
	buttonGroup.__BuyGoodsBtnLogic_Context = {}
	local context = buttonGroup.__BuyGoodsBtnLogic_Context

	context.mode = mode
	context.buyMode = nil

	context.successCallback = successCallback
	context.failCallback = failCallback
	context.cancelCallback = cancelCallback
	context.updateGold = updateGold

	context.goodsId = goodsId

	context.ui = buttonGroup
	context.btnIconText = context.ui:getChildByName('with-icon')
	context.btnText = context.ui:getChildByName('no-icon')
	context.aliQuickPayTip = context.ui:getChildByName('ali-quick-tip')

	context.aliQuickPayTip:setVisible(false)

	if mode == BuyGoodsBtnLogic.Mode.kBuyWithGold then
		context.buyMode = mode
	end

	if mode == BuyGoodsBtnLogic.Mode.kBuyWithRMB then
		context.buyMode = mode
	end

	if mode == BuyGoodsBtnLogic.Mode.kBuyWithGoldIfEnoughOtherwiseRMB then
		if self:isGoldEnough(goodsId) then
			context.buyMode = BuyGoodsBtnLogic.Mode.kBuyWithGold
		else
			context.buyMode = BuyGoodsBtnLogic.Mode.kBuyWithRMB
		end
	end

	if not __ANDROID then
		context.buyMode = BuyGoodsBtnLogic.Mode.kBuyWithGold
	end

	local button

	-- 只支持安卓
	if context.buyMode == BuyGoodsBtnLogic.Mode.kBuyWithRMB then
		context.btnText:setVisible(false)
		button = ButtonIconsetBase:create(context.btnIconText)
		button:setColorMode(kGroupButtonColorMode.blue)

		local finalPrice = TradeUtils:getRmbPrice(goodsId)
		local oriPrice = TradeUtils:getRmbOriPrice(goodsId)

		button:setString(BuyHappyCoinManager:getCurrencySymbol('cny') .. tostring(finalPrice))
		CommonViewLogic:setDiscountRmbAndRmb(context.ui:getChildByName('discountUI'), finalPrice, oriPrice)


		context.paymentDecisionInfo = {}

		local function handlePayment(decision, paymentType, dcAndroidStatus, otherPaymentTable, repayChooseTable)
			BuyGoodsBtnLogic:removeLoadingAnim(context)

			if context.ui.isDisposed then
				return
			end
			context.paymentDecisionInfo.adDecision = decision
			context.paymentDecisionInfo.adPaymentType = paymentType
			context.paymentDecisionInfo.dcAndroidStatus = dcAndroidStatus
			context.paymentDecisionInfo.adRepayChooseTable = repayChooseTable
			context.paymentShowConfig = PaymentManager.getInstance():getPaymentShowConfig(context.paymentDecisionInfo.adPaymentType, finalPrice)
			local UIHelper = require 'zoo.panel.UIHelper'
			local payIcon = UIHelper:createSpriteFrame('ui/common_pay_icon.json', 'common_pay_icon/' .. context.paymentShowConfig.smallIcon)
			payIcon:setAnchorPoint(ccp(0, 1))
			button:setIcon(payIcon)



			context.dcAndroidInfo = DCAndroidRmbObject:create()
			context.dcAndroidInfo:setGoodsId(context.goodsId)
			context.dcAndroidInfo:setGoodsType(GoodsType.kItem)
			context.dcAndroidInfo:setGoodsNum(1)
			context.dcAndroidInfo:setTypeStatus(context.paymentDecisionInfo.dcAndroidStatus)
			if context.paymentDecisionInfo.adDecision == IngamePaymentDecisionType.kPayFailed then 	
				if context.paymentDecisionInfo.adPaymentType == AndroidRmbPayResult.kCloseAfterNoNetWithoutSec then 
					context.dcAndroidInfo:setInitialTypeList(PaymentManager.getInstance():getDefaultThirdPartPayment())
				end
			else
				context.dcAndroidInfo:setInitialTypeList(context.paymentDecisionInfo.adPaymentType)
			end

			context.fakeConfirmPanelDelegate = {
				removePopout = function ( ... )
					if context.ui.isDisposed then
						return
					end
					context.ui:callAncestors('hideForBuying')
				end,
				getParent = function ( ... )
					if context.ui.isDisposed then
						return
					end
					return context.ui:getAncestorByClass(BasePanel):getParent()
				end
			}

			if context.paymentDecisionInfo.adPaymentType == Payments.ALIPAY then

				if UserManager.getInstance():isAliSigned() 
					and PaymentManager.getInstance():checkCanAliQuickPay(TradeUtils:getRmbPrice(context.goodsId), context.goodsId) 
					then
					context.aliQuickPayTip:setVisible(true)
				end
			end

		end

		BuyGoodsBtnLogic:showLoadingAnim(context)

		PaymentManager.getInstance():getBuyItemDecision(handlePayment, context.goodsId)

	elseif context.buyMode == BuyGoodsBtnLogic.Mode.kBuyWithGold then
		context.btnText:setVisible(false)
		button = ButtonIconsetBase:create(context.btnIconText)

		button:setColorMode(kGroupButtonColorMode.blue)
		button:setIconByFrameName("common_icon/item/icon_coin_small0000")

		local finalPrice = TradeUtils:getCashPrice(goodsId)
		local oriPrice = TradeUtils:getCashOriPrice(goodsId)

		button:setString(tostring(finalPrice))
		CommonViewLogic:setDiscountRmbAndRmb(context.ui:getChildByName('discountUI'), finalPrice, oriPrice)


		local dcWindmillInfo = DCWindmillObject:create()
		dcWindmillInfo:setGoodsId(context.goodsId)
		context.dcWindmillInfo = dcWindmillInfo
	end

	button:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
		if context.ui.isDisposed then return end	
		if context.buyMode == BuyGoodsBtnLogic.Mode.kBuyWithRMB then
			BuyGoodsBtnLogic:buyWithRMB(context)
		elseif context.buyMode == BuyGoodsBtnLogic.Mode.kBuyWithGold then
			BuyGoodsBtnLogic:buyWithGold(context)
		end
	end))

	context.onCloseBtnTapped = function ( ... )
		if context.ui.isDisposed then return end

		BuyGoodsBtnLogic:dcForOnCloseBtn(context)

	end

	return context
end

function BuyGoodsBtnLogic:dcForOnCloseBtn( context )
	if context.ui.isDisposed then return end

	if context.dcAndroidInfo then
		local payResult = context.dcAndroidInfo:getResult()
		-- 虽然我写了个if，但预期是 总通过这个if
		if payResult ~= IngamePaymentDecisionType.kPayWithWindMill then
			local noDC = false 
			if payResult and payResult == AndroidRmbPayResult.kNoNet then  
				context.dcAndroidInfo:setResult(AndroidRmbPayResult.kCloseAfterNoNet)
			elseif payResult and payResult == AndroidRmbPayResult.kNoPaymentAvailable then 
				context.dcAndroidInfo:setResult(AndroidRmbPayResult.kCloseAfterNoPaymentAvailable)
			elseif payResult and payResult == AndroidRmbPayResult.kNoRealNameAuthed then 
	    		context.dcAndroidInfo:setResult(AndroidRmbPayResult.kCloseAfterNoRealNameAuthed)
			else
				local typeChoose = context.dcAndroidInfo.typeChoose
				if typeChoose then 
					if payResult and payResult == AndroidRmbPayResult.kSuccess then 
						he_log_error("zhijianxxxcheck----11")
						noDC = true
					end
				end
				if not noDC then 
					context.dcAndroidInfo:setResult(AndroidRmbPayResult.kCloseDirectly)
				end
			end
			if not noDC then 
				PaymentDCUtil.getInstance():sendAndroidRmbPayEnd(context.dcAndroidInfo)
			end
		end
	end

	if context.dcWindmillInfo then
		local payResult = context.dcWindmillInfo:getResult()
		if payResult and payResult == DCWindmillPayResult.kNoWindmill then 
			context.dcWindmillInfo:setResult(DCWindmillPayResult.kCloseAfterNoWindmill)
		elseif payResult and payResult == DCWindmillPayResult.kFail then 
			context.dcWindmillInfo:setResult(DCWindmillPayResult.kCloseAfterFail)
		elseif payResult and payResult == DCWindmillPayResult.kNoRealNameAuthed then 
			context.dcWindmillInfo:setResult(DCWindmillPayResult.kCloseAfterNoRealNameAuthed)
		else
			context.dcWindmillInfo:setResult(DCWindmillPayResult.kCloseDirectly)
		end
		if __ANDROID then
			PaymentDCUtil.getInstance():sendAndroidWindmillPayEnd(context.dcWindmillInfo)
		else
			PaymentIosDCUtil.getInstance():sendIosWindmillPayEnd(context.dcWindmillInfo)
		end
	end
end

function BuyGoodsBtnLogic:buyWithRMB( context )
	if not context.buyLogic then
		local goodsIdInfo = GoodsIdInfoObject:create(context.goodsId, GoodsType.kItem)
		PaymentDCUtil.getInstance():sendAndroidRmbPayStart(context.dcAndroidInfo)
		local logic = IngamePaymentLogic:createWithGoodsInfo(goodsIdInfo, context.dcAndroidInfo, DcFeatureType.kStagePlay, DcSourceType.kIngamePropBuy)
		logic:setBuyConfirmPanel(context.fakeConfirmPanelDelegate)
		context.buyLogic = logic
		context.buyLogic:endGameBuy(context.paymentDecisionInfo.adDecision, context.paymentDecisionInfo.adPaymentType, function ( ... )
    		context.successCallback(context.goodsId)
		end, context.failCallback, context.cancelCallback, nil, context.paymentDecisionInfo.adRepayChooseTable)
		context.ui:callAncestors('setActiveIngamePayLogic', context.buyLogic)
	end
end



function BuyGoodsBtnLogic:onUserTapCloseBtn( ... )
	-- body
end

function BuyGoodsBtnLogic:buyWithGold( context )
    local buyLogic = BuyLogic:create(context.goodsId, MoneyType.kGold, DcFeatureType.kStagePlay, DcSourceType.kIngamePropBuy)
    local logic = WMBBuyItemLogic:create()
    logic:buy(context.goodsId, 1, context.dcWindmillInfo, buyLogic, function ( ... )
    	context.successCallback(context.goodsId)
    end, context.failCallback, context.cancelCallback, context.updateGold)
end

function BuyGoodsBtnLogic:isGoldEnough( goodsId )
	if __ANDROID then
		return PaymentManager:getInstance():checkCanWindMillPay(goodsId)
	elseif __IOS then
		return TradeUtils:isGoldEnough(goodsId)
	else
		return false
	end
end


return BuyGoodsBtnLogic