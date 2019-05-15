require "zoo.payment.UMPayPanel"
local UMPayment = class(PaymentBase)

local UmRetCode = {
    SMS_CODE_ERROR = {codes = "86801121,86801147,86801196,86801208,86001047,86001107,86801047,86801118,86801001"},  --验证码错误
    SMS_CODE_EXPIRED = {codes = "86801154,86801191"},  --验证码过期
    SMS_CODE_GET_FAILED = {codes = "86801159,86801205"}, --获取验证码失败
    PROVINCE_FORBIDEN = {codes = "86011927,86801137,86801138,86801139,86801104,86801140,86801141,86801142,86801181,86801191"}, --此省份关停
    CASH_POOR = {codes = "86011926,86011929,86011945,86801143"}, --余额不足
}

for key,code in pairs(UmRetCode) do
    code.is = function ( self, rc )
        return string.find(code.codes, rc) ~= nil
    end
end

local UMPayDelegate = class()

function UMPayDelegate:ctor(payment)
    self.payment = payment
    local function GetOrderIdGenerator()
        self.orderIdGenerator = luajava.bindClass('com.happyelements.android.operatorpayment.OrderIdGenerator')
    end
    pcall(GetOrderIdGenerator)
end

function UMPayDelegate:generateOrderId()
    if self.orderIdGenerator then
        return self.orderIdGenerator:genOrderId()
    end
end

function UMPayDelegate:pay(tradeId, smsCode, sdkCallback)
    --提交验证码并支付
    local function onRequestFinish(evt)
        evt.target:removeAllEventListeners()

        local data = evt.data or {}
        local code = data.code

        if data and code == "0000" then
            sdkCallback.onSuccess(data)
        elseif UmRetCode.SMS_CODE_EXPIRED:is(code) then
            CommonTip:showTip("验证码已过期，请重新获取！", "negative")
        elseif UmRetCode.SMS_CODE_ERROR:is(code) then
            CommonTip:showTip("请输入正确的验证码！", "negative")
        elseif UmRetCode.CASH_POOR:is(code) then
            CommonTip:showTip(data.msg, "negative")
        else
            sdkCallback.onError(data or {code = 2, msg = "data is nil"})
        end
    end 

    local function onRequestError(evt)
        evt.target:removeAllEventListeners()
        local code = tonumber(evt.data)
        
        if code == 730211 then
            sdkCallback.onSuccess({code = 3, msg = "pay timeout and need query online!"})
        else
            sdkCallback.onError({code = code, msg = tostring(code)})
        end
    end

    local function onRequestCancel(evt)
        evt.target:removeAllEventListeners()
        sdkCallback.onCancel({code = -6, msg = ""})
    end

    local function buywithPostLogin()
        local http = UmConfirmPay.new(true)
        http:addEventListener(Events.kComplete, onRequestFinish)
        http:addEventListener(Events.kError, onRequestError)
        http:addEventListener(Events.kCancel, onRequestCancel)
        http:load(tradeId, smsCode)
    end

    local function onUserNotLogin()
        sdkCallback.onError({code = -6, msg = ""})
    end

    RequireNetworkAlert:callFuncWithLogged(buywithPostLogin, onUserNotLogin, -999)
end

local UMPayPanelNode = class(PaymentNode)

function UMPayPanelNode:ctor(payment)
    self.name = "UMPayPanelNode"
    self.payment = payment
end

function UMPayPanelNode:execute()
    PaymentNode.execute(self)

    local cb = {}
    cb.sendSmsCode = function (smsCode )
        local sendSmsCode = self.payment:getData("sendSmsCode")
        if sendSmsCode then
            sendSmsCode(smsCode)
        end
    end

    cb.requestSmsCode = function (mobileid)
        self:onSuccess({mobileid = mobileid})
    end

    cb.cancel = function ()
        self:onCancel({code = 1, msg = "panel cancel"})
    end

    local goodsInfo = self.payment.data.goodsInfo
    local panel = UMPayPanel:create(cb, goodsInfo)
    panel:popout()

    --自动填充短信验证码
    self.payment:setData("setSmsCode", function ( smsCode )
        panel:setSmsCode(smsCode)
    end)

    self.payment:setData("savePhoneNumber", function ( mobileid )
        panel:pushDefaultPhoneNum(mobileid)
    end)

    self.payment:setData("setPayState", function ( state )
        panel:setPayState(state)
    end)

    self.payment:pushClearFunc(function ()
        panel:remove()
    end)
end

function UMPayPanelNode:onSuccess(data)
    --点击获取验证码，表明UMPayPanelNode成功，进入提交订单
    local payment = self.payment
    local goodsInfo = payment.data.goodsInfo
    goodsInfo.mobileid = data.mobileid

    PaymentNode.onSuccess(self, data)
end

function UMPayPanelNode:onCancel(data)
    --关闭面板
    PaymentNode.onCancel(self, data)
end

local UMPayPreOrderNode = class(PreOrderNode)

function UMPayPreOrderNode:ctor()
    self.name = 'UMPayPreOrderNode'
    self.mode = PayStage.kPreOrder
end

function UMPayPreOrderNode:onSuccess(data)
    data = data or {}

    local code = data.code
    if code == "0000" then
        PreOrderNode.onSuccess(self, data)
    elseif UmRetCode.SMS_CODE_GET_FAILED:is(code) then
        CommonTip:showTip("获取验证码失败，请重新获取！", "negative")
    elseif UmRetCode.PROVINCE_FORBIDEN:is(code) then
            CommonTip:showTip("此省份还没开通！", "negative")
    else
        self:onError(data)
    end
end

local UMPayNode = class(SDKPayNode)
function UMPayNode:ctor( payment )
    self.name = "UMPayNode"
    self.mode = PayStage.kSdkPay
end

function UMPayNode:waitSMS()
    local payment = self.payment
    local function sendSmsCode( smsCode )
        self:onSuccessGetSmsCode(smsCode)
    end

    payment:setData("sendSmsCode", sendSmsCode)

    self.isRegisterSMSObserver = false

    if __ANDROID and not PlatformConfig:isCUCCWOPlatform() then

        local mainActivity = luajava.bindClass("com.happyelements.hellolua.MainActivity")

        local function onSuccess(result)
            local tmp = string.match(result, "支付验证码%d+")
            local smsCode = nil

            if tmp then
                smsCode= string.match(tmp, "%d+")
            end

            if smsCode then
                payment:getData("setSmsCode")(smsCode)
            end
        end

        local callback = luajava.createProxy("com.happyelements.android.InvokeCallback", {
            onSuccess = onSuccess,
            onError = nil,
            onCancel = nil
        })

        mainActivity:registerSMSObserver(callback)
        self.isRegisterSMSObserver = true

        local function unRegisterSMSObserver()
            self:unRegisterSMSObserver()
        end

        self.payment:pushClearFunc(unRegisterSMSObserver)
    end
end

function UMPayNode:unRegisterSMSObserver()
    if __ANDROID and not PlatformConfig:isCUCCWOPlatform() and self.isRegisterSMSObserver then
        local mainActivity = luajava.bindClass("com.happyelements.hellolua.MainActivity")
        mainActivity:unRegisterSMSObserver()
        self.isRegisterSMSObserver = false
    end
end

function UMPayNode:onSuccessGetSmsCode(smsCode)
    local payment = self.payment
    local context = self

    self:unRegisterSMSObserver()

    local sdkCallback = {
        onSuccess = function ( data )
            context:onSuccess(data)
        end,
        onError = function ( data )
            context:onError(data)
        end,
        onCancel = function ( data )
            context:onCancel(data)
        end
    }

    local setPayState = self.payment:getData("setPayState")
    if setPayState then
        setPayState(true)
    end

    local goodsInfo = payment.data.goodsInfo
    payment.delegate:pay(goodsInfo.tradeId, smsCode, sdkCallback)
end

function UMPayNode:execute()
    PaymentNode.execute(self)
    self:waitSMS()
end

function UMPayNode:onCancel(data)
    local payment = self.payment
   
    SDKPayNode.onCancel(self, data)
end

function UMPayNode:onError(data)
    local payment = self.payment
    
    SDKPayNode.onError(self, data)
end

function UMPayNode:onSuccess(data)
    local payment = self.payment
   
    SDKPayNode.onSuccess(self, data)
end

local UMPayServerCheckNode = class(ServerCheckNode)

function UMPayServerCheckNode:ctor( ... )
    self.name = "UMPayServerCheckNode"
end

function UMPayServerCheckNode:execute()
    ServerCheckNode.execute(self)
end

function UMPayServerCheckNode:onSuccess( data )
    local savePhoneNumber = self.payment:getData("savePhoneNumber")
    if savePhoneNumber then
        savePhoneNumber(self.payment.data.goodsInfo.mobileid)
    end

    ServerCheckNode.onSuccess(self, data)

    local setPayState = self.payment:getData("setPayState")
    if setPayState then
        setPayState(false)
    end
end

function UMPayServerCheckNode:onError(data)
    ServerCheckNode.onError(self, data)

    local setPayState = self.payment:getData("setPayState")
    if setPayState then
        setPayState(false)
    end
end

function UMPayServerCheckNode:onCancel(data)
    ServerCheckNode.onCancel(self, data)

    local setPayState = self.payment:getData("setPayState")
    if setPayState then
        setPayState(false)
    end
end

function UMPayment:ctor()
	self.type = Payments.UMPAY
	self.orderHttp = DoUMPaymentOrder
end

function UMPayment:buildPaymentNode(stageType)
    if stageType == PayStage.kSdkPay then
        return UMPayNode.new(self)
    elseif stageType == PayStage.kPreOrder then
        return UMPayPreOrderNode.new(self)
    elseif stageType == PayStage.kServerCheck then
        return UMPayServerCheckNode.new(self)
    else
        return PaymentBase.buildPaymentNode(self, stageType)
    end
end

function UMPayment:registerDelegate()
    self.delegate = UMPayDelegate.new(self)
    return true
end

--与后端交互使用Http的参数
function UMPayment:getOrderPara()
	local goodsInfo = self.data.goodsInfo
	local goodsIdInfo = goodsInfo.goodsIdInfo
    
    local ip = MetaInfo:getInstance():getIpAddress()

	return {
				PlatformConfig.name,
	            goodsInfo.signForThirdPay,
	            goodsInfo.tradeId or "123456789", 
	            goodsIdInfo:getGoodsPayCodeId(), 
	            goodsIdInfo:getGoodsType(),
	            goodsInfo.amount,
	            goodsInfo.goodsName, 
	            goodsInfo.totalFee * 100,
                ip,
                goodsInfo.mobileid,
        	}
end

function UMPayment:buildPaymentParams()

end

function UMPayment:needConfirm()
    return false
end

function UMPayment:onPreOrderSuccess(data)
    PaymentBase.onPreOrderSuccess(self, data)
end

function UMPayment:buildPaymentStage()
    self.needPreOrder = true

    local panelNode = UMPayPanelNode.new(self)
    self:pushStage(panelNode)

    PaymentBase.buildPaymentStage(self)
end


function UMPayment:clone()
    local PaymentConfigs = require "zoo.payment.logic.PaymentConfig"
    local payment = UMPayment.new()
    local config = PaymentConfigs[self.type]
    config.type = self.type
    payment:init(config)
    payment.enabled = self.enabled

    local delegate = UMPayDelegate.new(payment)
    payment.delegate = delegate

    return payment
end

--[[
->UMPayPanelNode 支付面板,获取手机号
->PreOrder 获取验证码，提交订单
->UMPayNode 等待验证码下发短信，自动填入
->UMPayDelegate 上传验证码支付
->UMPayServerCheckNode 等待支付结果，轮询？
->完成支付
--]]

function UMPayment:buy( goodsInfo , payCallback)
    -- local payment = self:clone()
    if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>UMPayment:buy>>>>>>>>>>>>") end
	PaymentBase.buy(self, goodsInfo, payCallback)
end

PaymentBase:register(UMPayment.new())