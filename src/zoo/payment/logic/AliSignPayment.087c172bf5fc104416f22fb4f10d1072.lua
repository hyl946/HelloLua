local AliSignPayment = class(PaymentBase)
local AliQuickPayGuide = require "zoo.panel.alipay.AliQuickPayGuide"

local originPrint = print
local print = function ( ... )
    originPrint("[Payment] AliSignPayment ", ...)
end

local AliSignDelegate = class()

function AliSignDelegate:ctor(payment, aliDelegate)
    self.payment = payment
    self.aliDelegate = aliDelegate
    self.waitingAliApp = false

    local function payReturn( event )
        self:onAliAppReturn(event.data.url)
    end
    self.payReturn = payReturn
    GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kAliSignAndPayReturn, payReturn)
end

function AliSignDelegate:generateOrderId(goodId)
    return self.aliDelegate:generateOrderId(goodId)
end

function AliSignDelegate:pay(goodsInfo, params, sdkCallback)
    self.sdkCallback = sdkCallback
    if _G.isLocalDevelopMode then printx(0, "AliSignPayment:pay()") end

    local sign = tostring(goodsInfo.signedString)
    local paraString = self:getParamString(params)

    local sign_type = 'MD5'
    paraString = paraString ..string.format('&sign=%s&sign_type=%s', sign, sign_type)
    paraString = 'https://mapi.alipay.com/gateway.do?'..paraString

    if _G.isLocalDevelopMode then printx(0, "AliSignDelegate paraString:", paraString) end

    paraString = HeDisplayUtil:urlEncode(paraString)
    paraString = 'alipays://platformapi/startapp?appId=20000067&url='..paraString
    if __ANDROID then
        local function startActivity()
            self.waitingAliApp = true

            local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder')
            local Intent = luajava.bindClass('android.content.Intent')
            local Uri =  luajava.bindClass('android.net.Uri') 
            local intent = luajava.newInstance('android.content.Intent')
            intent:setAction(Intent.ACTION_VIEW);
            intent:setData(Uri:parse(paraString))

            local context = MainActivityHolder.ACTIVITY:getContext()
            context:startActivity(intent)
        end
        if not pcall(startActivity) then
            self.waitingAliApp = false
            self.sdkCallback.onError({})
        end
    end
end

function AliSignDelegate:getParamString(params)
    local paraString = ""
    for k, v in pairs(params) do
        paraString = paraString..k..'='..HeDisplayUtil:urlEncode(v).."&"
    end
    paraString = string.sub(paraString, 1, -2)
    return paraString
end

function AliSignDelegate:onAliAppReturn(url)
    if not url or not self.waitingAliApp then return end

    local function sdkPaySuccess()
        self.waitingAliApp = false
        self.sdkCallback.onSuccess({})
    end
    local function sdkPayFail()
        self.waitingAliApp = false
        self.sdkCallback.onError({})
    end
    local function sdkPayCancel()
        self.waitingAliApp = false
        self.sdkCallback.onCancel({})
    end

    local params = UrlParser:parseUrlScheme(url)

    local scene = Director:sharedDirector():getRunningScene()

    if params and params.para and params.para.is_success == tostring("T") then
        if _G.isLocalDevelopMode then printx(0, 'AliSignDelegate:onAliAppReturn successCallback') end
        if scene then
            scene:runAction(CCCallFunc:create(sdkPaySuccess))
        else
            sdkPaySuccess()
        end  
    elseif params and params.para and params.para.is_success == tostring("F") then
        if _G.isLocalDevelopMode then printx(0, 'AliSignDelegate:onAliAppReturn failCallback') end
        if scene then
            scene:runAction(CCCallFunc:create(sdkPayFail))
        else
            sdkPayFail()
        end
    else
        if _G.isLocalDevelopMode then printx(0, 'AliSignDelegate:onAliAppReturn cancelCallback') end
        if scene then
            scene:runAction(CCCallFunc:create(sdkPayCancel))
        else
            sdkPayCancel()
        end
    end

    GlobalEventDispatcher:getInstance():rm(kGlobalEvents.kAliSignAndPayReturn, self.payReturn)
end

local AliSignPreOrderNode = class(PreOrderNode)

function AliSignPreOrderNode:ctor()
    self.name = 'AliSignPreOrderNode'
end

function AliSignPreOrderNode:onError(data)
    local payment = self.payment
    local dcPara = payment.data.dcPara
    local r = 3
    DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'app_result', result = r, t1 = dcPara.t1, t2 = dcPara.t2})

    if payment and payment.cleanState then
        payment:cleanState()
    end

    PreOrderNode.onError(self, data)
end

function AliSignPreOrderNode:onCancel(data)
    local payment = self.payment
    local dcPara = payment.data.dcPara
    local r = 0
    DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'app_result', result = r, t1 = dcPara.t1, t2 = dcPara.t2})


    if payment and payment.cleanState then
        payment:cleanState()
    end

    PreOrderNode.onCancel(self, data)
end

local AliSignSDKPayNode = class(SDKPayNode)
function AliSignSDKPayNode:ctor( payment )
    self.name = "AliSignSDKPayNode"
end

function AliSignSDKPayNode:execute()
    PaymentNode.execute(self)
    local payment = self.payment
    local data = payment.data
    local goodsInfo = data.goodsInfo

    local context = self

    local sdkCallback = {
        onSuccess = function ( data )
            payment:cleanState()
            context:onSuccess(data)
        end,
        onError = function ( data )
            payment:cleanState()
            context:onError(data)
        end,
        onCancel = function ( data )
            payment:cleanState()
            context:onCancel(data)
        end
    }

    self.payment.delegate:pay(goodsInfo, data.params, sdkCallback)
end

function AliSignSDKPayNode:onCancel(data)
    local payment = self.payment
    local dcPara = payment.data.dcPara
    local r = 0
    DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'app_result', result = r, t1 = dcPara.t1, t2 = dcPara.t2})
    SDKPayNode.onCancel(self, data)
end

function AliSignSDKPayNode:onError(data)
    local payment = self.payment
    local dcPara = payment.data.dcPara
    local r = 3
    DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'app_result', result = r, t1 = dcPara.t1, t2 = dcPara.t2})
    
    if self.next then
        self.next:execute()
    else
        SDKPayNode.onError(self, data)
    end
end

function AliSignSDKPayNode:onSuccess(data)
    local payment = self.payment
    local dcPara = payment.data.dcPara
    local r = 2
    DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'app_result', result = r, t1 = dcPara.t1, t2 = dcPara.t2})
    SDKPayNode.onSuccess(self, data)
end

local AliSignServerCheckNode = class(ServerCheckNode)

function AliSignServerCheckNode:ctor( ... )
    self.name = "AliSignServerCheckNode"
    self.queryHttp = QueryAliOrderHttp
end

local function WriteAliSign()
    UserManager.getInstance().userExtend.aliIngameState = 1
    UserService.getInstance().userExtend.aliIngameState = 1
    if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
    else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
end

function AliSignServerCheckNode:onSuccess( data )
   WriteAliSign()
   ServerCheckNode.onSuccess(self, data)
end

function AliSignServerCheckNode:onError( data )
    if data.code == 0 then
        WriteAliSign()
    end
     --这种情况下玩家已付款成功 但是查询未到账 不弹重买面板 直接失败
    data.noRePay = true
    ServerCheckNode.onError(self, data)
end

function AliSignPayment:ctor()
	self.type = Payments.ALI_SIGN_PAY
	self.orderHttp = DoAliOrderHttp
end

function AliSignPayment:buildPaymentNode(stageType)
    if stageType == PayStage.kSdkPay then
        return AliSignSDKPayNode.new(self)
    elseif stageType == PayStage.kPreOrder then
        return AliSignPreOrderNode.new(self)
    elseif stageType == PayStage.kServerCheck then
        return AliSignServerCheckNode.new(self)
    else
        return PaymentBase.buildPaymentNode(self, stageType)
    end
end

local function checkAliSignPay()
    if AliQuickPayPromoLogic:isEntryEnabled() then
        return false
    end
    local isInstalled = false
    if __ANDROID then
        local function safeCheck()
            local MainActivityHolder = luajava.bindClass("com.happyelements.android.MainActivityHolder")
            local context = MainActivityHolder.ACTIVITY
            local packageManager = context:getPackageManager()
            local info = packageManager:getPackageInfo('com.eg.android.AlipayGphone', 64)

            if info ~= nil and info.applicationInfo and info.applicationInfo.enabled then
                isInstalled = true
            end
        end
        local ret = pcall(safeCheck)

    end

    if _G.isLocalDevelopMode then printx(0, 'isInstalled', isInstalled) end

    return isInstalled
end

function AliSignPayment:isEnabled()
    local maintenacenOk = MaintenanceManager:getInstance():isEnabled('AliSignAndPay')
    self:print('_G.use_ali_quick_pay ', _G.use_ali_quick_pay, 'maintenacenOk ', maintenacenOk)

    return self.enabled and _G.use_ali_quick_pay and maintenacenOk
end

function AliSignPayment:registerDelegate()
    local delegate = AliSignDelegate.new(self, self.delegate)
    --PaymentBase已经把alipay的java delegate设为了self.delegate
    self.delegate = delegate
    return checkAliSignPay()
end

--与后端交互使用Http的参数
function AliSignPayment:getOrderPara()
	local goodsInfo = self.data.goodsInfo
	local goodsIdInfo = goodsInfo.goodsIdInfo

	return {
				PlatformConfig.name,
	            goodsInfo.signForThirdPay,
	            goodsInfo.tradeId, 
	            goodsIdInfo:getGoodsPayCodeId(), 
	            goodsIdInfo:getGoodsType(),
	            goodsInfo.amount, 
	            goodsInfo.goodsName, 
	            goodsInfo.totalFee,
                "true",                                     --表明此次为签约并支付
        	}
end

function AliSignPayment:cleanState()
    _G.use_ali_quick_pay = false
end

function AliSignPayment:parseSignStr(signStr)
    local data = {}
    if signStr and string.len(signStr) > 0 then
        local params = string.split(signStr, "&")
        for _, p in pairs(params) do
            local kvPairs = string.split(p, "=")
            if #kvPairs > 1 then
                if kvPairs[1] == "agreement_sign_parameters" then 
                    data[kvPairs[1]] = kvPairs[2]
                else
                    data[kvPairs[1]] = string.gsub(kvPairs[2], "\"", "")
                end
            end
        end
    end
    return data
end

function AliSignPayment:onPreOrderSuccess(data)
    if data and data.signStr then
        local signData = AliSignPayment:parseSignStr(data.signStr)
        self.data.params = signData
    end
    PaymentBase.onPreOrderSuccess(self, data)
end

function AliSignPayment:buildDcParams( goodsInfo )
	local entryType = 4
    if goodsInfo.goodsType == 2 then
        entryType = 1
    end
    local payType = PaymentManager:getInstance():getDefaultPayment()
    local userType = 4

    local payment = PaymentBase:getPayment(payType)
    
    if payType == Payments.ALIPAY then
        userType = 2
    elseif payType == Payments.WECHAT then
        userType = 3
    elseif payType ~= Payments.UNSUPPORT and payment.mode == PaymentMode.kSms then
        userType = 1
    end
    local paraT1 = entryType * 10 + userType

    local popoutTimes = AliQuickPayGuide.getPopoutTimes() + 1
    if not AliQuickPayGuide:isGuideTime() and entryType == 1 then
        popoutTimes = 4
    elseif entryType == 4 then -- 因为提前加了1
        popoutTimes = popoutTimes - 1
    end

    self.data.dcPara = {t1 = paraT1, t2 = popoutTimes}
end

function AliSignPayment:clone()
    local PaymentConfigs = require "zoo.payment.logic.PaymentConfig"
    local payment = AliSignPayment.new()
    local config = PaymentConfigs[self.type]
    config.type = self.type
    payment:init(config)
    payment.enabled = self.enabled

    local delegate = AliSignDelegate.new(payment, self.delegate.aliDelegate)
    payment.delegate = delegate

    return payment
end

function AliSignPayment:buy( goodsInfo , payCallback)
    local payment = self:clone()
    payment:buildGoodsInfo(goodsInfo)
	payment:buildDcParams(goodsInfo)

    local dcPara = payment.data.dcPara
    DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'app_enter', t1 = dcPara.t1, t2 = dcPara.t2})

	PaymentBase.buy(payment, goodsInfo, payCallback)

    if AliQuickPayGuide.isGuideTime() then
        AliQuickPayGuide.updateGuideTimeAndPopCount()
    end
end

PaymentBase:register(AliSignPayment.new())