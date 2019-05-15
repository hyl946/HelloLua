require "zoo.payment.paycheck.PaymentCheckNode"

PaymentNode = class()

function PaymentNode:ctor(payment)
	self.name = "PaymentNode"
	self.payment = payment
end

function PaymentNode:execute()
	self:print("execute...")
end

function PaymentNode:print( ... )
	local paymentName = self.payment and self.payment.name
	if _G.isLocalDevelopMode then printx(0, "[Payment] stage:", self.name, "of", paymentName, ...) end
end

function PaymentNode:onSuccess(data)
	self:print("onSuccess...")

	if self.next then
		self.next:execute()
	else
		self.payment:payCallback(self.mode, PayResultType.kSuccess, data)
	end
end

function PaymentNode:onError(data)
	self:print("onError, code: ",data.code, "msg: ", data.msg)
	self.payment:payCallback(self.mode, PayResultType.kError, data)
end

function PaymentNode:onCancel(data)
	self:print("onCancel...")
	self.payment:payCallback(self.mode, PayResultType.kCancel, data)
end

PreOrderNode = class(PaymentNode)

function PreOrderNode:ctor( payment )
	self.name = "PreOrderNode"
	self.mode = PayStage.kPreOrder
end

function PreOrderNode:execute()
	PaymentNode.execute(self)

	local payment = self.payment

	local function onRequestFinish(evt)
        evt.target:removeAllEventListeners()
        self:onSuccess(evt.data)
    end 

	local function onRequestError(evt)
        evt.target:removeAllEventListeners()
        self:onError({code = tonumber(evt.data), msg = ""})
    end

    local function onRequestCancel(evt)
        evt.target:removeAllEventListeners()
        self:onCancel({code = -6, msg = ""})
    end

    local function buywithPostLogin()
	    local orderPara = payment:getOrderPara()
        local http = payment.orderHttp.new(true)
        http:addEventListener(Events.kComplete, onRequestFinish)
        http:addEventListener(Events.kError, onRequestError)
        http:addEventListener(Events.kCancel, onRequestCancel)
	    http:syncLoad(unpack(orderPara))
	end

	local function onUserNotLogin()
    	self:onError({code = -6, msg = ""})
    end

    local function doPreOrder()
    	RequireNetworkAlert:callFuncWithLogged(buywithPostLogin, onUserNotLogin, -999)
    end
	
	if PaymentManager.getInstance():isSmsPayLike(payment) then
		local data = payment.data 
		local goodsId = data.goodsInfo.goodsIdInfo:getGoodsId()
		local goodsType = data.goodsInfo.goodsType
    	if PaymentManager.getInstance():isNeedSmsPayOnlineCheck(goodsId, goodsType, payment.type) then
    		doPreOrder()
    	else
    		self:onSuccess()
    	end
    else
    	doPreOrder()
	end
end

function PreOrderNode:onSuccess(data)
	self.payment:onPreOrderSuccess(data)
	if data and self.payment.data and not self.payment.data.goodsInfo then
		PaymentNode.onError(self, {code = -99, msg = ""})
	else
		PaymentNode.onSuccess(self, data)
	end
end

function PreOrderNode:onError(data)
	local payment = self.payment
	data.msg = data.msg .. payment.name .. "payment network error==" .. data.code
	PaymentNode.onError(self, data)
end

function PreOrderNode:onCancel(data)
	self:onError(data)
end

ConfirmNode = class(PaymentNode)

function ConfirmNode:ctor(payment)
	self.name = "ConfirmNode"
	self.mode = PayStage.kConfirm
	self.payment = payment
end

function ConfirmNode:execute()
	local function ok()
		self:onSuccess({})
	end

	local function cancel()
		self:onCancel({})
	end

	local payment = self.payment
	local goodsInfo = payment.data.goodsInfo
	
	local AndroidPayConfirmPanel = require 'zoo.payment.AndroidPayConfirmPanel'
	AndroidPayConfirmPanel:create({name = goodsInfo.goodsName, price = goodsInfo.totalFee}, ok, cancel):popout()
end

function ConfirmNode:onSuccess(data)
	PaymentNode.onSuccess(self, data)
end

function ConfirmNode:onCancel(data)
	PaymentNode.onCancel(self, data)
end


SDKPayNode = class(PaymentNode)

function SDKPayNode:ctor( payment )
	self.name = "SDKPayNode"
	self.mode = PayStage.kSdkPay
end

function SDKPayNode:buildCallback()
	local function sdkPaySuccess(payResult)
		self:onSuccess(payResult)
	end

	local function sdkPayFail(payErrCode, payErrMsg)
		self:onError({code = payErrCode, msg = payErrMsg})
	end

	local function sdkPayCancel()
		self:onCancel()
	end

	local sdkCallback = luajava.createProxy("com.happyelements.android.InvokeCallback", {
        onSuccess = sdkPaySuccess,
        onError = sdkPayFail,
        onCancel = sdkPayCancel
    })

    return sdkCallback
end

function SDKPayNode:execute()
	PaymentNode.execute(self)

	local payment = self.payment
	if PaymentManager.getInstance():isSmsPayLike(payment) then
		payment:createAnimation()
	end
	local sdkCallback = self:buildCallback()

	local data = payment.data
	if data.goodsInfo and data.goodsInfo.tradeId then
	    payment.delegate:buy(data.goodsInfo.tradeId, data.goodsInfo.params, sdkCallback)
	else
		self:onError({code = -99, msg = ""})
	end
end

function SDKPayNode:onSuccess(data)
	local payment = self.payment
	if type(data) == "table" then
		payment.data.sdkSuccessResult = data
	elseif type(data) == "userdata" then
		payment.data.sdkSuccessResult = luaJavaConvert.map2Table(data)
	end 
	PaymentNode.onSuccess(self, {})
end

function SDKPayNode:onError(data)
	PaymentNode.onError(self, data)
end

function SDKPayNode:onCancel(data)
	PaymentNode.onCancel(self, data)
end

ServerCheckNode = class(PaymentNode)

function ServerCheckNode:ctor(payment)
	self.name = "ServerCheckNode"
	self.payment = payment
	self.mode = PayStage.kServerCheck
	self.queryHttp = QueryQihooOrderHttp
end

function ServerCheckNode:execute(extraInfos)
	local payment = self.payment
	local data = payment.data
	local goodsInfo = data.goodsInfo

	if not goodsInfo then
		self:print("pay callback again!")
		return
	end

	if PaymentManager.getInstance():isSmsPayLike(payment) then
		local goodsId = goodsInfo.goodsIdInfo:getGoodsId()
		local goodsType = goodsInfo.goodsType
		if PaymentManager.getInstance():isNeedSmsPayOnlineCheck(goodsId, goodsType, payment.type) then
			self:smsPayOnlineCheck(payment.type)
		else 
			self:ingameSeverCheck()
		end
	else
		self:thirdPartySeverCheck(extraInfos)
	end
end

function ServerCheckNode:onSuccess(data)
	PaymentNode.onSuccess(self, data)
end

function ServerCheckNode:onError(data)
	PaymentNode.onError(self, data)
end

function ServerCheckNode:onCancel(data)
	PaymentNode.onCancel(self, data)
end

local SmsCheckReason = {
	kNet = 0,
	kDelay = 1,
}
function ServerCheckNode:smsPayOnlineCheck(paymentType)
	PaymentCheckManager.getInstance():setNeedPaymentCheck(false)

    local animation
    local retry = 2
    if paymentType == Payments.CHINA_TELECOM then
    	retry = 3 
    end
    local interval = 2

    local queryOnlinePayResult

    local context = self
    local goodsInfo = self.payment.data.goodsInfo
    local tradeId = goodsInfo.tradeId
    local oriTime = os.time()
    local payType = self.payment.type or 0

    local function logError(errCode, checkReason)
    	-- MannualCheckCode.kCheckFail == 10212
    	-- MannualCheckCode.kCancel == 10214
    	local errMsgPre = "sms_check_" .. payType .. "_"
  		if checkReason == SmsCheckReason.kDelay then
  			errMsgPre = errMsgPre.. "d_" 
  		else
  			errMsgPre = errMsgPre.. "n_" 
  		end

    	if errCode == 10212 then
    		errMsgPre = errMsgPre .. "f_" 
    	elseif errCode == 10214 then
    		errMsgPre = errMsgPre .. "c_"
    	end
    	
    	local timeDelta = os.time() - oriTime
    	errMsgPre = errMsgPre .. timeDelta .. "_" .. tradeId
    	he_log_error(errMsgPre)
    end

    local function showManualCheck(checkReason)
		local checkNode = PaymentCheckNode:create()
		checkNode:setDCPrefix(PaymentCheckDCKey.kIn) 	--server check node
		checkNode:setQueryHttp(context.queryHttp)

		local function onSuccess()
			-- context:onSuccess({})
			context:ingameSeverCheck()
		end
		local function onFail(errCode, errMsg)
			logError(errCode, checkReason)

			context:onError({code = errCode, msg = errMsg})
		end

		checkNode:startCheck(tradeId, onSuccess, onFail)
	end

    queryOnlinePayResult = function ()
    	PaymentManager.getInstance():setIsCheckingPayResult(true)

       local function onRequestFinish( evt )
            evt.target:removeAllEventListeners()

            if evt.data and evt.data.finished then
            	if animation then animation:removeFromParentAndCleanup(true) end 
            	PaymentManager.getInstance():setIsCheckingPayResult(false)

                if evt.data.success then
					-- context:onSuccess({})
					context:ingameSeverCheck()
                else
                    context:onError({code = 0, msg = "ServerCheck purchase failed"})
                end
            else
                if retry > 0 then
           	 		setTimeOut(queryOnlinePayResult, interval)
                else
                	if animation then animation:removeFromParentAndCleanup(true) end 
                	PaymentManager.getInstance():setIsCheckingPayResult(false)

                	showManualCheck(SmsCheckReason.kDelay)
                end
            end
        end

        local function onRequestError(evt)
            evt.target:removeAllEventListeners()
            if retry > 0 then
           	 	setTimeOut(queryOnlinePayResult, interval)
           	else
           		if animation then animation:removeFromParentAndCleanup(true) end 
           		PaymentManager.getInstance():setIsCheckingPayResult(false)

            	showManualCheck(SmsCheckReason.kNet)
        	end
        end

        local http = context.queryHttp.new()
        http:addEventListener(Events.kComplete, onRequestFinish)
        http:addEventListener(Events.kError, onRequestError)
        http:addEventListener(Events.kCancel, onRequestError)
        http:load(tradeId)

        interval = interval * 2
        retry = retry - 1
    end

	local scene = Director:sharedDirector():getRunningScene()
    animation = CountDownAnimation:createNetworkAnimation(scene, nil, localize("loading.prop.data"))

    queryOnlinePayResult()
end

function ServerCheckNode:ingameSeverCheck()
	local payment = self.payment
	local data = payment.data
	local payResult = data.sdkSuccessResult
	local goodsInfo = data.goodsInfo

	local function onIngameSuccess(evt)
		if not data.orderCompleted then
			data.orderCompleted = true
			self:onSuccess({})
		else
			local msg = string.format("repeat ingame request: %s", table.tostring(payResult))
			self:onError({code = 0, msg = msg})
		end
	end
	local function onIngameFail(errCode)
		self:onError({code = errCode, msg = "Ingame check failed!"})
	end

	local http = IngameHttp.new(true)
	http:ad(Events.kComplete, onIngameSuccess)
	http:ad(Events.kError, onIngameFail)

	local detail = nil --历史遗留，预留字段

	local goodsId = goodsInfo.goodsIdInfo:getGoodsId()
	http:load(goodsId, payResult.orderId, payResult.channelId, goodsInfo.goodsType, detail, payResult.tradeId)

	if PaymentLimitLogic:isNeedLimit(payment.type) then
		PaymentLimitLogic:buyComplete(payment.type, goodsInfo.totalFee)
		PaymentManager.getInstance():checkPaymentLimit(payment.type)
	end
end

function ServerCheckNode:thirdPartySeverCheck(extraInfos)
	PaymentCheckManager.getInstance():setNeedPaymentCheck(false)

	local context = self
	local goodsInfo = self.payment.data.goodsInfo
	local tradeId = goodsInfo.tradeId

	local function showManualCheck()
		local checkNode = PaymentCheckNode:create()
		checkNode:setDCPrefix(PaymentCheckDCKey.kIn) 	--server check node
		checkNode:setQueryHttp(context.queryHttp)
		if extraInfos then 
			checkNode:setOriErrorInfo(extraInfos._errCode, extraInfos._errMsg)
		end

		local function onSuccess()
			context:onSuccess({})
		end
		local function onFail(errCode, errMsg)
			context:onError({code = errCode, msg = errMsg})
		end

		checkNode:startCheck(tradeId, onSuccess, onFail)
	end
   
    local function onRequestFinish(evt)
        evt.target:removeAllEventListeners()
        PaymentManager.getInstance():setIsCheckingPayResult(false)
    	
        if evt.data and evt.data.finished then
            if evt.data.success then
				self:onSuccess({})
            else
                self:onError({code = 0, msg = "ServerCheck purchase failed clearly"})
            end
        else
        	showManualCheck()
        end
    end

	local function onRequestError(evt)
       	evt.target:removeAllEventListeners()
       	PaymentManager.getInstance():setIsCheckingPayResult(false)
    	
       	showManualCheck()
    end

    PaymentManager.getInstance():setIsCheckingPayResult(true)
    local http = self.queryHttp.new(true)
    http:addEventListener(Events.kComplete, onRequestFinish)
    http:addEventListener(Events.kError, onRequestError)
    http:addEventListener(Events.kCancel, onRequestError)
    http:load(tradeId)
end


RealNameCheckNode = class(PaymentNode)

function RealNameCheckNode:ctor(payment)
	self.name = "RealNameCheckNode"
	self.payment = payment
	self.mode = PayStage.kRealNameCheck
end

function RealNameCheckNode:execute()
	RealNameManager:checkOnPay(function ( ... )
		self:onSuccess({})
	end, function ( ... )
		self:onError(...)
	end)
end

function RealNameCheckNode:onSuccess(data)
	PaymentCheckManager.getInstance():setPaymentCheck(self.payment)
	PaymentNode.onSuccess(self, data)
end

function RealNameCheckNode:onError(errCode)
	local errMsg
	if errCode then
		errMsg = localize("error.tip."..errCode)
	else
		errCode = RealNameManager.errCode
		errMsg = RealNameManager.errMsg
	end

	PaymentNode.onError(self, {code=errCode, msg=errMsg})
end

function RealNameCheckNode:onCancel(data)
	PaymentNode.onCancel(self, data)
end