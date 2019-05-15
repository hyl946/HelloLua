--=====================================================
-- PaymentCheckNode
-- by zhijian.li
-- (c) copyright 2009 - 2016, www.happyelements.com
-- All Rights Reserved. 
--=====================================================
-- filename:  PaymentCheckNode.lua
-- author:    zhijian.li
-- e-mail:    zhijian.li@happyelements.com
-- created:   2016/10/20
-- descrip:   针对支付sdk没回调的情况下~主动发起订单结果查询
--=====================================================

PaymentCheckNode = class()

PaymentCheckDCKey = {
    kOut = "out_",
    kIn = "in_",    
}

local ErrorCode = {
    kNetError = 10121,
    kCheckFail = 10122,
    kNoMoreCheck = 10123,
}

local MannualCheckCode = {
    kSuccess = 10200,
    kNetError = 10211,
    kCheckFail = 10212,
    kNoResult = 10213,
    kCancel = 10214,
    kNetCancel = 10215,
    kUnknow = 10216,
}

function PaymentCheckNode:ctor()
	self.isChecking = false 
end

function PaymentCheckNode:init()
    self.dcPrefix = PaymentCheckDCKey.kOut
    self.errSource = "O"
    self.queryHttp = QueryQihooOrderHttp
end

function PaymentCheckNode:setOriErrorInfo(errCode, errMsg)
    self.oriErrCode = errCode
    self.oriErrMsg = errMsg
end

function PaymentCheckNode:setDCPrefix(preFix)
    self.dcPrefix = preFix    
end

function PaymentCheckNode:setQueryHttp(queryHttp)
    self.queryHttp = queryHttp
end

function PaymentCheckNode:getErrSourceKey()
    if self.dcPrefix == PaymentCheckDCKey.kIn then 
        self.errSource = "I"
    end
    return self.errSource
end

function PaymentCheckNode:startCheck(tradeId, onSuccess, onFail)
    PaymentManager.getInstance():setIsCheckingPayResult(true)
    self.isChecking = true

    self:showManualCheckPanel(tradeId, onSuccess, onFail)
end

function PaymentCheckNode:addMaskAnimation()
    local scene = Director:sharedDirector():getRunningScene()
    if scene then 
        self.animation = CountDownAnimation:createNetworkAnimation(scene, nil, Localization:getInstance():getText("loading.prop.data"))
    end
end

function PaymentCheckNode:removeMaskAnimation()
    if self.animation then self.animation:removeFromParentAndCleanup(true) end
end

function PaymentCheckNode:showManualCheckPanel(tradeId, onSuccess, onFail)
    local context = self

    local CheckMainPanel = require "zoo.payment.paycheck.CheckMainPanel"
    local checkPanel = CheckMainPanel:create()
    checkPanel:setTipShow(localize("payment.delay.optimization.refresh"))

    local checkMsg = ""
    local dcPrefix = self.dcPrefix
    local function onCheckResult(checkCode)
        checkMsg = checkMsg .. checkCode
        DcUtil:dcForManualOrderCheck(dcPrefix.."result", tradeId, checkCode, self.oriErrCode, self.oriErrMsg)
        if checkCode == MannualCheckCode.kSuccess then 
            if checkPanel then checkPanel:remove() end
            PaymentManager.getInstance():setIsCheckingPayResult(false)
            if onSuccess then onSuccess() end
        elseif checkCode == MannualCheckCode.kCheckFail then 
            local CheckFAQPanel = require "zoo.payment.paycheck.CheckFAQPanel"
            local faqPanel = CheckFAQPanel:create()
            local tradeIdStr = "\n错误码："..self:getErrSourceKey()..tradeId
            faqPanel:setTipShow(localize("payment.delay.optimization.fail")..tradeIdStr)
            local function payFailWithFaq()
                if checkPanel then checkPanel:remove() end
                PaymentManager.getInstance():setIsCheckingPayResult(false)
                if onFail then onFail(MannualCheckCode.kCheckFail, checkMsg) end
            end
            faqPanel:setFaqCallback(function ()
                DcUtil:dcForManualOrderCheck(dcPrefix.."faq_result", tradeId, 0)
                if payFailWithFaq then payFailWithFaq() end
            end)
            faqPanel:setCancelCallback(function ()
                DcUtil:dcForManualOrderCheck(dcPrefix.."faq_result", tradeId, 1)
                if payFailWithFaq then payFailWithFaq() end
            end)
            faqPanel:popout()
        elseif checkCode == MannualCheckCode.kNoResult then 
            if checkPanel then checkPanel:setTipShow(localize("payment.delay.optimization.no.result")) end
        elseif checkCode == MannualCheckCode.kNetError or checkCode == MannualCheckCode.kNetCancel then 
            if checkPanel then checkPanel:setTipShow(localize("payment.delay.optimization.network.problems")) end
        elseif checkCode == MannualCheckCode.kCancel then 
            PaymentManager.getInstance():setIsCheckingPayResult(false)
            if onFail then onFail(MannualCheckCode.kCancel, checkMsg) end
        end
    end

    local function onRequestFinish(evt)
        if not checkPanel or checkPanel.isDisposed then return end
        if evt.data and evt.data.finished then
            if evt.data.success then
                onCheckResult(MannualCheckCode.kSuccess)
            else
                onCheckResult(MannualCheckCode.kCheckFail)
            end
        else
            onCheckResult(MannualCheckCode.kNoResult)
        end
    end

    local function onRequestError(evt)
        if not checkPanel or checkPanel.isDisposed then return end
        onCheckResult(MannualCheckCode.kNetError)
    end

    local function onRequestCancel(evt)
        if not checkPanel or checkPanel.isDisposed then return end
        onCheckResult(MannualCheckCode.kNetCancel)
    end

    checkPanel:setCheckCallback(function ()
        local http = context.queryHttp.new(true)
        http:addEventListener(Events.kComplete, onRequestFinish)
        http:addEventListener(Events.kError, onRequestError)
        http:addEventListener(Events.kCancel, onRequestCancel)
        http:load(tradeId)
    end)
    checkPanel:setCancelCallback(function ()
        onCheckResult(MannualCheckCode.kCancel)
    end)
    checkPanel:popout()
end

function PaymentCheckNode:create(payment)
	local checkNode = PaymentCheckNode.new()
	checkNode.payment = payment
	checkNode:init()
	return checkNode
end