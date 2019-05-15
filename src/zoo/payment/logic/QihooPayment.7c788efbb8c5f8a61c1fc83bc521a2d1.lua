local QihooSdkPayNode = class(SDKPayNode)
function QihooSdkPayNode:ctor(payment)
	self.name = "QihooSdkPayNode"
end

function QihooSdkPayNode:onError(data)
	local errCode = data.code
	local errMsg = data.msg

	if errCode == 4010201 or errCode == 4009911 then 
	--4010201 access token失效 提示重新登录
	--4009911 QT失效 提示重新登录
		self:onCancel(data)
		CommonTip:showTip(localize("本次支付失败，请在联网状态下重新登录。"), "negative")
	else
		-- 360也和华为一样 失败就给玩家手动查询的机会
		if errCode == -1 then 		-- -1 支付取消	
			SDKPayNode.onError(self, data)
		elseif self.next then
			self.next:execute({fromSDKErr = true, _errCode = errCode, _errMsg = errMsg})
		else
			SDKPayNode.onError(self, data)
		end
	end
end

local QihooServerCheckNode = class(ServerCheckNode)
function QihooServerCheckNode:ctor( ... )
    self.name = "QihooServerCheckNode"
end

function QihooServerCheckNode:execute( data )
	if type(data) == "table" and data.fromSDKErr == true then
		ServerCheckNode.execute(self, data)
	else
		self:onSuccess({})
	end
end

local QihooPayment = class(PaymentBase)
function QihooPayment:ctor()
	self.type = Payments.QIHOO
end

function QihooPayment:buildPaymentNode(stageType)
	if stageType == PayStage.kSdkPay then
		return QihooSdkPayNode.new(self)
	elseif stageType == PayStage.kServerCheck then
		return QihooServerCheckNode.new(self)
	else
		return PaymentBase.buildPaymentNode(self, stageType)
	end
end

PaymentBase:register(QihooPayment.new())


------------------------------------------------------------
-----------------------   qihoo_wx   -----------------------
------------------------------------------------------------

local QihooWXSdkPayNode = class(QihooSdkPayNode)
function QihooWXSdkPayNode:ctor(payment)
	self.name = "QihooWXSdkPayNode"
end

function QihooWXSdkPayNode:execute()
	PaymentNode.execute(self)

	local payment = self.payment
	local sdkCallback = self:buildCallback()

	local data = payment.data
	payment.delegate:weixinPayBuy(data.goodsInfo.tradeId, data.goodsInfo.params, sdkCallback)
end


local QihooWXPayment = class(PaymentBase)
function QihooWXPayment:ctor()
	self.type = Payments.QIHOO_WX
end

function QihooWXPayment:buildPaymentNode(stageType)
	if stageType == PayStage.kSdkPay then
		return QihooWXSdkPayNode.new(self)
	elseif stageType == PayStage.kServerCheck then
		return QihooServerCheckNode.new(self)
	else
		return PaymentBase.buildPaymentNode(self, stageType)
	end
end

PaymentBase:register(QihooWXPayment.new())

------------------------------------------------------------
-----------------------   qihoo_ali   ----------------------
------------------------------------------------------------
local QihooAliSdkPayNode = class(QihooSdkPayNode)

function QihooAliSdkPayNode:ctor(payment)
	self.name = "QihooAliSdkPayNode"
end

function QihooAliSdkPayNode:execute()
	PaymentNode.execute(self)

	local payment = self.payment
	local sdkCallback = self:buildCallback()

	local data = payment.data
	payment.delegate:aliPayBuy(data.goodsInfo.tradeId, data.goodsInfo.params, sdkCallback)
end

local QihooAliPayment = class(PaymentBase)

function QihooAliPayment:ctor()
	self.type = Payments.QIHOO_ALI
end

function QihooAliPayment:buildPaymentNode(stageType)
	if stageType == PayStage.kSdkPay then
		return QihooAliSdkPayNode.new(self)
	elseif stageType == PayStage.kServerCheck then
		return QihooServerCheckNode.new(self)
	else
		return PaymentBase.buildPaymentNode(self, stageType)
	end
end

PaymentBase:register(QihooAliPayment.new())