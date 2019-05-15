require "zoo.util.IosPaymentCallback"
require 'zoo.gameGuide.IosPayGuide'
require "zoo.payment.PaymentEventDispatcher"
require "zoo.payment.paymentDC.PaymentIosDCUtil"
require "zoo.payment.paymentDC.DCIosRmbObject"
require "zoo.panel.endGameProp.EndGamePropABCTest"

IosPayment = {}

local instance = nil
local repairOrderTable = {}

function IosPayment:getInstance()
	if not instance then
		instance = ShowPayment:instance();
	end
	return instance;
end

function IosPayment:showPayment(filterSkuIds, getFunc, errorFunc)
	local callback = IosPaymentCallback:init_getFunc_completeFunc_errorFunc(getFunc, nil, errorFunc)
	return IosPayment:getInstance():showPayment_callback(filterSkuIds, callback)
end

function IosPayment:__buy(productId, price, currency, extend, completeFunc, errorFunc, dcEventDispatcher)
	local function onSuccess(a_orderId, a_errorInfo, a_productId)
		if productId and a_productId and productId ~= a_productId then 
			if dcEventDispatcher then 
				dcEventDispatcher:dispatchIosProductIdChange(a_productId)
			end
		end
		if dcEventDispatcher then 
			dcEventDispatcher:dispatchIosBuySuccess()
		end

		StageInfoLocalLogic:addPaymentOrderId( UserManager:getInstance().uid, a_orderId)

		-- EndGamePropABCTest.getInstance():setBecomePayUser(true)
		UserManager:getInstance():getUserExtendRef().payUser = true
		UserService:getInstance():getUserExtendRef().payUser = true
		UserManager:getInstance():getUserExtendRef():setLastPayTime(Localhost:time())
		UserService:getInstance():getUserExtendRef():setLastPayTime(Localhost:time())


		UserManager:getInstance():getUserExtendRef():setLastApplePayTime(Localhost:time())
		UserService:getInstance():getUserExtendRef():setLastApplePayTime(Localhost:time())

		completeFunc(a_orderId, a_errorInfo, a_productId)
	end

	local function onConfirmFail(errCode, errMsg)
		if dcEventDispatcher then 
			dcEventDispatcher:dispatchIosBuyFailed(errCode, errMsg)
		end
		local IosPayGuideProxy = HappyCoinShopFactory:getInstance():getIosPayGuide()
		if IosPayGuideProxy:tryPopFailGuidePanel(errorFunc) then
			return 
		else
			local noTip = false
			if errCode and type(errCode) == "number" and errCode == 2 then
				noTip = true
				CommonTip:showTipWithErrCode(localize("ios.pay.error.common"), errCode, "negative", nil, 3)
			end
			errorFunc(errCode, errMsg, noTip)
		end
	end
	local function onFail(nsError)
		local errCode = -1
		local errMsg = ""
		pcall(function ()
			if nsError then errCode = nsError.code end
		end)

		local shouldConfirm, orderId = self:shouldManualConfirm(errCode)
		if shouldConfirm then 
			self:showManualConfirm(orderId, errCode, onSuccess, onConfirmFail)
		else
			onConfirmFail(errCode, errMsg)
		end
	end

	local callback = IosPaymentCallback:init_getFunc_completeFunc_errorFunc(nil, onSuccess, onFail)
		
	--extend 被用于传 <product id,  注意不是productId
	extend = tostring(extend) or ''

	return IosPayment:getInstance():buy_price_currency_extend_callback(productId, price, currency, extend, callback)
end

function IosPayment:shouldManualConfirm(errCode)
	--#define ERROR_CODE_ORDER_CONFIRM     30003
	--#define ERROR_CODE_ORDER_CONFIRM_NET 30009

	if errCode and (errCode == 30003 or errCode == 30009) then
		local orderId = IosPayment:getInstance():hasOrderToConfirm()
		if orderId == "nil" then
			return false 
		else
			return true, orderId
		end
	end
	return false
end

function IosPayment:onGameEnterForeground()
	IosPayment:getInstance():onGameEnterForeground()
end

function IosPayment:cleanConfirmOrderId()
	IosPayment:getInstance():cleanConfirmOrderId()
end

local IosMannualCheckCode = {
    kSuccess = 10200,
    kNetError = 10211,
    kCheckFail = 10212,
    kNoResult = 10213,
    kCancel = 10214,
    kDrop = 10215,
}
function IosPayment:showManualConfirm(orderId, oriErrCode, onSuccess, onFail)
    local context = self

    local scene = Director:sharedDirector():getRunningScene()
    local animation 
    local CheckMainPanel = require "zoo.payment.paycheck.CheckMainPanel"
    local checkPanel = CheckMainPanel:create()
    checkPanel:setTipShow(localize("payment.delay.optimization.refresh"))

    local checkMsg = ""
    local dcPrefix = "ios_"
    local function onCheckResult(checkCode, subErrCode, ...)
    	if animation then animation:removeFromParentAndCleanup(true) end 
        checkMsg = checkMsg .. checkCode .. "_"

        DcUtil:dcForManualOrderCheck(dcPrefix.."result", orderId, checkCode, subErrCode, oriErrCode)
        if checkCode == IosMannualCheckCode.kSuccess then 
            if checkPanel then checkPanel:remove() end
            if onSuccess then onSuccess(...) end
        elseif checkCode == IosMannualCheckCode.kCheckFail then 
            local CheckFAQPanel = require "zoo.payment.paycheck.CheckFAQPanel"
            local faqPanel = CheckFAQPanel:create()
            local tradeIdStr = "\nID:"..orderId.."_"..oriErrCode
            faqPanel:setTipShow(localize("payment.delay.optimization.fail")..tradeIdStr)
            local function payFailWithFaq()
            	IosPayment:cleanConfirmOrderId()
                if checkPanel then checkPanel:remove() end
                if onFail then onFail(IosMannualCheckCode.kCheckFail, checkMsg) end
            end
            faqPanel:setFaqCallback(function ()
                DcUtil:dcForManualOrderCheck(dcPrefix.."faq_result", orderId, 0)
                if payFailWithFaq then payFailWithFaq() end
            end)
            faqPanel:setCancelCallback(function ()
                DcUtil:dcForManualOrderCheck(dcPrefix.."faq_result", orderId, 1)
                if payFailWithFaq then payFailWithFaq() end
            end)
            faqPanel:popout()
        elseif checkCode == IosMannualCheckCode.kNoResult then 
            if checkPanel then checkPanel:setTipShow(localize("payment.delay.optimization.no.result")) end
        elseif checkCode == IosMannualCheckCode.kNetError then 
            if checkPanel then checkPanel:setTipShow(localize("payment.delay.optimization.network.problems")) end
        elseif checkCode == IosMannualCheckCode.kDrop then 
            if checkPanel then checkPanel:setTipShow(localize("payment.delay.optimization.network.problems")) end
        elseif checkCode == IosMannualCheckCode.kCancel then
        	IosPayment:cleanConfirmOrderId()
            if onFail then onFail(IosMannualCheckCode.kCancel, checkMsg) end
        end
    end

	local function onCheckSuccess(_orderId, _errorInfo, _productId)
    	onCheckResult(IosMannualCheckCode.kSuccess, nil, _orderId, _errorInfo, _productId)
    end

    local function onCheckFail(nsError)
    	local errCode = -1
		-- local errMsg = ""
		pcall(function ()
			if nsError then errCode = nsError.code end
		end)
		-- #define ERROR_CODE_ORDER_CONFIRM_0   30010
		-- #define ERROR_CODE_ORDER_CONFIRM_1   30011
		-- #define ERROR_CODE_ORDER_CONFIRM_2   30012
		-- #define ERROR_CODE_ORDER_CONFIRM_3   30013
		-- #define ERROR_CODE_ORDER_CONFIRM_4   30014
		if errCode == 30010 or errCode == 30011 or 
			errCode == 30012 or errCode == 30013 then
			onCheckResult(IosMannualCheckCode.kCheckFail, errCode)
		elseif errCode == 30009 then 
			onCheckResult(IosMannualCheckCode.kNetError, errCode)
		elseif errCode == 30014 then 
			onCheckResult(IosMannualCheckCode.kDrop, errCode)
		else
			--imposible so far
			onCheckResult(IosMannualCheckCode.kNoResult, errCode)
		end
    end

    checkPanel:setCheckCallback(function ()
    	animation = CountDownAnimation:createNetworkAnimation(scene, nil, localize("订单确认中，请稍后~"))
		local callback = IosPaymentCallback:init_getFunc_completeFunc_errorFunc(nil, onCheckSuccess, onCheckFail)
    	IosPayment:getInstance():manualConfirmOrder(orderId, callback)
    end)
    checkPanel:setCancelCallback(function ()
        onCheckResult(IosMannualCheckCode.kCancel)
    end)
    checkPanel:popout()
end

local function repairOrderComplete(orderId, errorInfo, productId)
	if not orderId or not productId then return end

	local orderInfo = {}
	orderInfo.orderId = orderId
	orderInfo.errorInfo = errorInfo 
	local productMeta = MetaManager:getInstance().product
	for i,v in ipairs(productMeta) do
		if v.productId == productId then
			orderInfo.productInfo = v
			break
		end
	end
	repairOrderTable[orderId] = orderInfo

	IosPayment:showRepairOrderFinished()
end

local function repairOrderError(nsError)
end

-- function IosPayment:testRepairOrder()
-- 	repairOrderComplete(12345, nil, "com.happyelements.animal.gold.cn.1")
-- 	repairOrderComplete(1235, nil, "com.happyelements.animal.gold.cn.29")
-- 	repairOrderComplete(1234, nil, "com.happyelements.animal.gold.cn.39")
-- end

local repairOrderCallback = IosPaymentCallback:init_getFunc_completeFunc_errorFunc(nil, repairOrderComplete, repairOrderError)
function IosPayment:registerCallback()
	IosPayment:getInstance():registerCallback(repairOrderCallback)
end

function IosPayment:showRepairOrderFinished()
	if repairOrderTable then 
		local cloneTable = table.clone(repairOrderTable)
		local repairOrderNum = 0
		local user = UserManager:getInstance().user
		local serv = UserService:getInstance().user

		for m,n in pairs(repairOrderTable) do
			local productInfo = n.productInfo
			if productInfo then 
				repairOrderNum = repairOrderNum + 1
				if productInfo.goodsId then 
					local meta = MetaManager:getInstance():getGoodMeta(productInfo.goodsId)
					local valueCalculator = GainAndConsumeMgr.getInstance():getPayValueCalculator(meta.items, productInfo.price * 100, DcPayType.kRmb)
					for __, v in pairs(meta.items) do
						UserManager:getInstance():addReward(v, true)
						UserService:getInstance():addReward(v)
						local value = valueCalculator:getItemSellPrice(v.itemId)
						GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kTrunk, v.itemId, v.num, DcSourceType.KIosReapir, nil, nil, DcPayType.kRmb, value, productInfo.goodsId)
					end

					GainAndConsumeMgr.getInstance():consumeCurrency(DcFeatureType.kTrunk, DcDataCurrencyType.kRmb, productInfo.price * 100, 
													productInfo.goodsId, 1, nil, nil, DcSourceType.KIosReapir)
				else
					UserManager:getInstance():addCash(productInfo.cash, true)
					UserService:getInstance():addCash(productInfo.cash)
		            GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kTrunk, ItemType.GOLD, productInfo.cash, DcSourceType.KIosReapir, nil, nil, DcPayType.kRmb, productInfo.price*100, productInfo.productId)			
					--这里的goodsId特殊处理为ios productId
					GainAndConsumeMgr.getInstance():consumeCurrency(DcFeatureType.kTrunk, DcDataCurrencyType.kRmb, productInfo.price * 100, 
													productInfo.productId, 1, nil, nil, DcSourceType.KIosReapir)
				end
			end
			cloneTable[m] = nil
		end

		--弹tip
		if repairOrderNum > 0 then 
			local tip = Localization:getInstance():getText("您有"..repairOrderNum.."笔之前未到账的订单已到账，请注意查收~")
			local goldTip = ConsumeTipPanel:createWithString(tip, false)
			goldTip:popout()
		end
		--删除修复完成的订单
		repairOrderTable = cloneTable or {}
	end
end

function IosPayment:buy(productId, price, currency, extend, completeFunc, errorFunc, dcEventDispatcher)
	local function preOrderSucc()
		self:__buy(productId, price, currency, extend, completeFunc, errorFunc, dcEventDispatcher)
	end

	local function preOrderFail(evt)
		local errCode = evt.data
		if errCode then
			if errCode == -6 then 
				CommonTip:showNetworkAlert()
				if errorFunc then
					errorFunc(errCode, nil, true)
				end
			else
				CommonTip:showTipWithErrCode(localize("ios.pay.error.common"), errCode, "negative", nil, 3)
			end
			if dcEventDispatcher then
				dcEventDispatcher:dispatchIosBuyFailed(errCode)
			end
		end
	end
	RealNameManager:checkOnPay(function ()
		self:preOrder(productId, extend, preOrderSucc, preOrderFail)
	end, function (errCode)
		local errMsg
		if errCode then
			errMsg = localize("error.tip."..errCode)
		else
			errCode = RealNameManager.errCode
			errMsg = RealNameManager.errMsg
		end
		
		if errorFunc then
			errorFunc(errCode, errMsg, false)
		end

		if dcEventDispatcher then
			dcEventDispatcher:dispatchIosBuyFailed(errCode, errMsg)
		end
	end)
end

function IosPayment:preOrder(productId, metaId, sucCallback, failCallback)
	local http = IosPreOrderHttp.new(true)
	http:addEventListener(Events.kComplete, sucCallback)
	http:addEventListener(Events.kError, failCallback)
	local data = {}
	data.productId = productId
	data.metaId = metaId
	http:syncLoad(data)
end