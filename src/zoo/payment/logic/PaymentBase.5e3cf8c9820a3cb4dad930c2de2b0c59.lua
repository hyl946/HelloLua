PaymentBase = class()

DelegateNotRegistered = {__index = function (t,k)
    return function ( ... ) if _G.isLocalDevelopMode then printx(0, "This delegate has not been registered!!!") end end
  end}
setmetatable(DelegateNotRegistered, DelegateNotRegistered)

local PaymentHolder = {}

PayResultType = table.const{
	kSuccess = 0,
	kError = 1,
	kCancel = 2,
}

PayStage = table.const{
	kSdkPay = 0,
	kPreOrder = 1,
	kSdkNotRegister = 2,
	kConfirm = 3,
	kServerCheck = 4,
	kOutServerCheck = 5,  --支付sdk没回调时的订单查询
	kRealNameCheck = 6
}

PaymentLevel = table.const{
	kLvNone = 0,
	kLvOne = 1,
	kLvTwo = 2,
}

local PaymentConfigs = require "zoo.payment.logic.PaymentConfig"

require "zoo.payment.logic.PaymentNode"

function PaymentBase:ctor()
	self.name = "UNSUPPORT"
	self.type = Payments.UNSUPPORT
	self.mode = PaymentMode.kUnknown
	self.productName = "UNSUPPORT"
	self.delegate = DelegateNotRegistered
	self.delegateName = nil
	self.enabled = false
	self.windMillEnabled = false --风车币栏显示开关
	self.data = {}
	self.orderHttp = nil
	self.needPreOrder = true
	self.serverCheck = false
	self.subPayments = nil
	self.isSubPayment = false
	self.isNoSDK = false
	self.platform = PlatformConfig.name
	self.beLimited = false
	if __ANDROID then
		self.manager = luajava.bindClass("com.happyelements.hellolua.aps.APSManager"):getInstance()
	end
end

function PaymentBase:init( config )
	self:print("init name:", config.name)
	local c = config or {}
	self.name = c.name
	self.type = c.type
	self.mode = PaymentMode[c.mode]
	self.productName = c.productName
	self.iconName = c.iconName
	self.iconTip = c.iconTip
	self.delegateName = c.delegate
	self.serverCheck = c.serverCheck
	self.subPayments = c.subPayments
	self.isSubPayment = c.isSubPayment or false
	self.isNoSDK = c.isNoSDK or false
	self.payLevel = c.payLevel

	if c.operator then
		self.operator = TelecomOperators[c.operator]
	end

	if self.orderHttp == nil and self.needPreOrder == true then
		self.orderHttp = DoOrderHttp
	end

	self.windMillEnabled = true

	self:buildPaymentStage()
end

local function CreateSubPayment( subPayments )
	if subPayments and type(subPayments) == "table" then
		for _,payType in ipairs(subPayments) do
			PaymentBase:create(payType)
		end
	end
end

function PaymentBase:create( payType )
	local config = PaymentConfigs[payType]
    config.type = payType

    if config.deprecated then return end

	local payment = PaymentHolder[config.type] or PaymentBase.new()
	payment:init(config)
	PaymentHolder[config.type] = payment

	CreateSubPayment(payment.subPayments)

	return payment
end

local function GetPaymentWithProductName( name )
	for payType,payment in pairs(PaymentHolder) do
		if payment.productName == name then
			if payment.mode == PaymentMode.kSms then
				if payment:isEnabled() then
					return payment
				end
			else
				return payment
			end
		end
	end

	return PaymentBase.new()
end

function PaymentBase:getPayment( payTypeOrProductName )
	local payment = nil
	if payTypeOrProductName == nil then
		payment = PaymentBase.new()
	elseif type(payTypeOrProductName) == "string" then
		payment = GetPaymentWithProductName(payTypeOrProductName)
	else 
		payment = PaymentHolder[payTypeOrProductName] or PaymentBase.new()
		payment.type = payTypeOrProductName
	end

	return payment
end

--[[
	return {key = payType, value = payment}
--]]
function PaymentBase:getPayments()
	local payments = {}
	for payType,payment in pairs(PaymentHolder) do
		if not payment.isSubPayment then
			payments[payType] = payment
		end
	end
	return payments
end

function PaymentBase:checkPaymentEabled(paymentType)
	for payType,payment in pairs(PaymentHolder) do
		if payType == paymentType and payment:isEnabled() then
			return true
		end
	end
	return false
end

--param onlyLvOne为true 只检测第一梯队的三方是否可用
function PaymentBase:checkThirdPartyPaymentEabled(onlyLvOne)
	for payType,payment in pairs(PaymentHolder) do
		if payment.enabled and payment.mode == PaymentMode.kThirdParty then
			if onlyLvOne then 
				if payment:getPaymentLevel() == PaymentLevel.kLvOne then 
					return true
				end
			else
				return true
			end
		end
	end
	return false
end

function PaymentBase:findPayment( func )
	for payType,payment in pairs(PaymentHolder) do
		if payment.enabled then
			if func(payType) then
				return payType
			end
		end
	end
end

function PaymentBase:checkPaymentForPromotion()
	for payType, payment in pairs(PaymentHolder) do
		if payment.enabled and payment.mode == PaymentMode.kThirdParty then
			if payment:getPaymentLevel() == PaymentLevel.kLvOne then 
				if payType ~= Payments.WO3PAY and payType ~= Payments.TELECOM3PAY then
					return true
				end
			end
		end
	end
	return false
end

function PaymentBase:isChinaMobile(payType)
	local payment = self:getPayment(payType)
	return payment.operator == TelecomOperators.CHINA_MOBILE
end

function PaymentBase:isChinaUnicom( payType )
	local payment = self:getPayment(payType)
	return payment.operator == TelecomOperators.CHINA_UNICOM
end

function PaymentBase:isChinaTelecom( payType )
	local payment = self:getPayment(payType)
	return payment.operator == TelecomOperators.CHINA_TELECOM
end

function PaymentBase:register(payment)
	if PaymentHolder[payment.type] == nil then
		PaymentHolder[payment.type] = payment
	else
		self:print("This payment ", payment.type, " Already registered!")
	end
end

function PaymentBase:getPaymentLevel()
	return self.payLevel
end

function PaymentBase:setEnabled( enabled )
	if self.type == Payments.UNSUPPORT then
		return
	end

	local paymentEnabled = enabled

	if paymentEnabled and self.mode == PaymentMode.kSms then
		local operator = AndroidPayment.getInstance():getOperator()
		if self.operator ~= operator then
			paymentEnabled = false
		end
	elseif paymentEnabled and (self.type == Payments.TELECOM3PAY or self.type == Payments.WO3PAY) then
		local operator = AndroidPayment.getInstance():getOperator()
		if operator == TelecomOperators.NO_SIM or operator == TelecomOperators.UNKNOWN then
			paymentEnabled = false
		end
	end

	if paymentEnabled == true then
		local payment = PaymentHolder[self.type]
		if payment == nil then
			PaymentHolder[self.type] = self
		end
		--init
		if self.name == "UNSUPPORT" then
			PaymentBase:create(self.type)
		end

		paymentEnabled = paymentEnabled and self:registerDelegate()
	end

	self.enabled = paymentEnabled

	if paymentEnabled == true then
		if self.subPayments and type(self.subPayments) == "table" then
			for _,payType in ipairs(self.subPayments) do
				local payment = self:getPayment(payType)
				payment.parentType = self.type
				payment.delegate = self.delegate --主要是用于subPayment生成tradeId
				payment:setEnabled(true)
			end
		end
	end

	self:print(self.enabled and "enable" or "disable", ",platform =", self.platform)
end

function PaymentBase:isEnabled(noLimit)
	if self.enabled then
		if self.delegate and self.delegate:getError() ~= 0 then
			self:setEnabled(false)
		end
	end

	if noLimit then
		return self.enabled
	else
		return self.enabled and not self.beLimited
	end
end

function PaymentBase:setBeLimited(value)
	self.beLimited = value
end

function PaymentBase:isBeLimited()
	return self.beLimited
end

function PaymentBase:setWindMillEnabled( enabled )
	self.windMillEnabled = enabled or false
end

function PaymentBase:isWindMillEnabled()
	return self.windMillEnabled and self.enabled
end

function PaymentBase:registerDelegate()
	local enabled = true
	if self.delegateName ~= nil 
		and self.delegate == DelegateNotRegistered 
		and self.manager 
		and not self.isNoSDK
	then
		local function javaRegisterPayment()
			printx(0, 'init_sms_payment javaRegisterPayment, self.delegateName=' .. tostring(self.delegateName))

			local success = self.manager:registerPayment(self.type, self.delegateName)
			if success then
				self.delegate = self.manager:getPaymentDelegate(self.type)
				enabled = true
			else
				enabled = false
			end
		end

		local status, _ = pcall(javaRegisterPayment)
		if not status then
			enabled = false
		end
		-- local operator = AndroidPayment.getInstance():getOperator()
		-- DcUtil:UserTrack({category="payment", sub_category="init_payment", init_ret=(enabled and 1 or 0), pay_type=self.type, operator = operator})
	end

	if(self.type == Payments.CHINA_MOBILE) then
		self.sdk_initialized = false
		if(not enabled) then
			self.sdk_initialized = true
		end

		if(not self.sdk_initialized) then
			local hwndTicker = nil
			local function freeTicker()
				if(hwndTicker) then
	                cancelTimeOut(hwndTicker)
					hwndTicker = nil
				end
			end

			local function onTimeout()
				freeTicker()
				self.sdk_initialized = true
			end

			local function onSdkInitialized(evt)
				freeTicker()
				self.sdk_initialized = true
			end

			hwndTicker = setTimeOut(onTimeout, 15)
			AndroidEventDispatcher:getInstance():addEventListener("CMCC_SDK.INIT_FINISH", onSdkInitialized)
		end
	end

	return enabled
end

function PaymentBase:buildPaymentStage()
	if self.needPreOrder then
		local preOrder = self:buildPaymentNode(PayStage.kPreOrder)
		self:pushStage(preOrder)
	end
	
	if self:needConfirm() then
        local confirm = self:buildPaymentNode(PayStage.kConfirm)
        self:pushStage(confirm)
	end

	if not self.isNoSDK then
		local sdkPay = self:buildPaymentNode(PayStage.kSdkPay)
		self:pushStage(sdkPay)
	end

	if self.serverCheck then
		local checkPay = self:buildPaymentNode(PayStage.kServerCheck)
		self:pushStage(checkPay)
	end

	self:pushTopState(self:buildPaymentNode(PayStage.kRealNameCheck))
end

function PaymentBase:pushStage( stage )
	self:print("build Payment Stage:", stage.name)

	if self.headStage == nil then
		self.headStage = stage
	else
		self.lastStage.next = stage
	end

	self.lastStage = stage
end

function PaymentBase:pushTopState( stage )
	self:print("build Payment top Stage:", stage.name)

	if self.headStage == nil then
		self.headStage = stage
		self.lastStage = stage
	else
		stage.next = self.headStage
		self.headStage = stage
	end

end

function PaymentBase:buildPaymentNode(stageType)
	if stageType == PayStage.kPreOrder then
		return PreOrderNode.new(self)
	elseif stageType == PayStage.kConfirm then
		return ConfirmNode.new(self)
	elseif stageType == PayStage.kSdkPay then
		return SDKPayNode.new(self)
	elseif stageType == PayStage.kServerCheck then
		return ServerCheckNode.new(self)
	elseif stageType == PayStage.kRealNameCheck then
		return RealNameCheckNode.new(self)
	end
end

function PaymentBase:print( ... )
	local name = self.name
	if name == "UNSUPPORT" or name == nil then
		name = ""
	end
	if _G.isLocalDevelopMode then printx(0, "[Payment] ", name, ...) end
end

function PaymentBase:pushClearFunc( func )
	local clearFuncTab = self.data.cft
	if clearFuncTab == nil then
		self.data.cft = {}
		clearFuncTab = self.data.cft
	end

	if func then
		table.insert(clearFuncTab, func)
	end
end

function PaymentBase:setData( key, value )
	if key and value then
		self.data = self.data or {}
		self.data[key] = value
	end
end

function PaymentBase:getData( key )
	if self.data and key then
		return self.data[key]
	end
end

function PaymentBase:buildGoodsInfo(goodsInfo)
	if self.data.goodsInfo == nil then
		self.data.goodsInfo = goodsInfo

		local goodsId = goodsInfo.goodsIdInfo:getGoodsId()
		local goodsType = goodsInfo.goodsIdInfo:getGoodsType()
		if goodsType == 2 then
			goodsId = goodsId + 10000
		end

		goodsInfo.tradeId = self.delegate:generateOrderId(goodsId)
		goodsInfo.goodsName = localize("goods.name.text"..tostring(goodsInfo.goodsIdInfo:getGoodsNameId()))
		goodsInfo.signForThirdPay = PaymentManager.getInstance():getSignForThirdPay(goodsInfo.goodsIdInfo)
		self:buildPaymentParams()
	end

	return self.data.goodsInfo
end
--TODO:统一goodsinfo的创建
function PaymentBase:buildPaymentParams()
	local params = luajava.newInstance("java.util.HashMap")
	params:put("uid", UserManager:getInstance().uid or "12345")
	params:put("amount", self.amount)

	local goodsParams = nil
	local paramTable = {}

	local goodsInfo = self.data.goodsInfo
	local goodsPayCodeId = goodsInfo.goodsIdInfo:getGoodsPayCodeId()

	local goodsPaycodeMeta = MetaManager:getGoodPayCodeMeta(goodsPayCodeId)
	

	--之所以这几个三方平台单独拿出来 是因为现在会有goods表里有的商品但goods_pay_code表里没有 即goodsPaycodeMeta可能为空
	--所以这个参数要自己手动构建 之后不用在后台申请计费点的三方支付 都自己构建
	if self.type == Payments.QQ or self.type == Payments.WDJ or 
        self.type == Payments.HUAWEI or self.type == Payments.MI_ALIPAY or 
        self.type == Payments.MI_WXPAY or self.type == Payments.MIDAS
    then 
		paramTable.price = goodsInfo.totalFee
		paramTable.props = goodsInfo.goodsName
		goodsParams = luaJavaConvert.table2Map(paramTable)
	elseif self.type == Payments.QIHOO or self.type == Payments.QIHOO_WX or self.type == Payments.QIHOO_ALI then 
		paramTable.price = goodsInfo.totalFee
		paramTable.props = goodsInfo.goodsName
		paramTable.id = goodsPayCodeId
		goodsParams = luaJavaConvert.table2Map(paramTable)
	else
		if goodsPaycodeMeta then 
			goodsParams = luaJavaConvert.table2Map(goodsPaycodeMeta)
			goodsParams:put("props", goodsInfo.goodsName)
		end
	end
	if goodsParams then 
		params:put("meta", goodsParams)
	end

	local extraData = {}
	if self.type == Payments.QQ then
        local extendinfo = { 
            platform = PlatformConfig.name, 
            itemId = tostring(goodsPayCodeId), 
            itemAmount = tostring(goodsInfo.amount), 
            itemPrice = tostring(goodsInfo.totalFee * 10), 
            realAmount = tostring(goodsInfo.amount), 
            curLevel = tostring(UserManager:getInstance().user:getTopLevelId()),
            goodsType = tostring(goodsInfo.goodsIdInfo:getGoodsType())
        }
        if goodsInfo.signForThirdPay then 
        	extendinfo.signStr = tostring(goodsInfo.signForThirdPay)
        end
		extraData.ext = table.serialize(extendinfo)
	elseif self.type == Payments.QIHOO or self.type == Payments.QIHOO_WX or self.type == Payments.QIHOO_ALI then 
		extraData.ext1 = tostring(self.type)
	end

	if self.type == Payments.CHINA_MOBILE then
		extraData.ext = goodsInfo.tradeId
	end

	params:put("extraData", luaJavaConvert.table2Map(extraData))
	goodsInfo.params = params
	return params
end

--与后端交互使用Http的参数
function PaymentBase:getOrderPara()
	local goodsInfo = self.data.goodsInfo
	local goodsIdInfo = goodsInfo.goodsIdInfo
	return {goodsInfo.tradeId, goodsIdInfo:getGoodsPayCodeId(), goodsInfo.goodsType, goodsInfo.amount}
end

function PaymentBase:payCallback( stage, resultType, result)
	self:print("pay end stage:", stage, "resultType:", resultType, result and result.code, result and result.msg)

	if self.data.goodsInfo == nil then
		self:print("pay callback again!!!") 
		return 
	end
	--Call the clearing function for each payment node.
	local clearFuncTab = self.data.cft
	if clearFuncTab then
		for index = #clearFuncTab, 1, -1 do
			clearFuncTab[index]()
		end
	end

	result = result or {}

	if self.animation then
        PopoutManager:sharedInstance():remove(self.animation)
        self.animation = nil
    end

    local data = self.data
    local goodsInfo = data.goodsInfo

    result.tradeId = goodsInfo.tradeId
    result.orderId = goodsInfo.tradeId
    result.goodsInfo = goodsInfo
    result.payType = self.parentType or self.type
    result.subPayType = self.type
    result.stage = stage
    result.resultType = resultType

    if data.sdkSuccessResult and type(data.sdkSuccessResult) == "table" then
    	for k,v in pairs(data.sdkSuccessResult) do
    		result[k] = v
    	end
    end

    if self.type == Payments.ALI_SIGN_PAY then
    	result.subPayType = Payments.ALI_QUICK_PAY
    end

    self.data.payCallback(result)

    if self.type == Payments.CHINA_MOBILE and resultType == PayResultType.kCancel then
    	--do nothing, mm 取消不清除数据，移动mm会在home键出去，返回游戏时调用cancel
    else
    	self.data = {}
    end
end

function PaymentBase:createAnimation()
	local scene = Director:sharedDirector():getRunningScene()
    self.animation = CountDownAnimation:createNetworkAnimationInHttp(scene)
    self.animation.onKeyBackClicked = function(self) end
end

function PaymentBase:buyWithType( payType, goodsInfo, payCallback)
	local payment = PaymentHolder[payType]
	if payment then
		payment.data = {}
		payment:buy(goodsInfo, payCallback)
	else
		if _G.isLocalDevelopMode then printx(0, "[warnning] this payment (", payType, ") is not support!!!") end
	end
end

function PaymentBase:needConfirm()
	if __ANDROID and MaintenanceManager:getInstance():isEnabled("TelecomNeedConfirm", true) then
		return self.type == Payments.CHINA_TELECOM or self.type == Payments.TELECOM3PAY
	end
	return false
end

function PaymentBase:buy(goodsInfo, payCallback)
	self.data.payCallback = payCallback

	self:buildGoodsInfo(goodsInfo)

	if self.delegate == DelegateNotRegistered and not self.isNoSDK then
		self:payCallback(PayStage.kSdkNotRegister, PayResultType.kError, {code = 0, msg = "RRR PaymentType not registered!"})
		return
	end

	if self.headStage then
		self.headStage:execute()
	end

end

function PaymentBase:onPreOrderSuccess(data)
	if data then
		if self.data.goodsInfo then
			for k,v in pairs(data) do
				self.data.goodsInfo[k] = v
			end
		end
	end
end