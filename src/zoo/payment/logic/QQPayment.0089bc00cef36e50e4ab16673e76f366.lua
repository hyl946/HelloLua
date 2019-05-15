local QQPayment = class(PaymentBase)

local QQSDKPayNode = class(SDKPayNode)
function QQSDKPayNode:ctor( payment )
	self.name = "QQSDKPay"
end

function QQSDKPayNode:execute()
	PaymentNode.execute(self)

	local sdkCallback = self:buildCallback()

	local payment = self.payment
	local goodsInfo = payment.data.goodsInfo

    payment.delegate:buyWithToken(goodsInfo.tradeId, 
									goodsInfo.params, 
									goodsInfo.tokenUrl, 
									sdkCallback)
end

function QQPayment:ctor()
	self.type = Payments.QQ
	self.orderHttp = DoMSDKOrderHttp
end

function QQPayment:buildPaymentNode(stageType)
	if stageType == PayStage.kSdkPay then
		return QQSDKPayNode.new(self)
	else
		return PaymentBase.buildPaymentNode(self, stageType)
	end
end

--与后端交互使用Http的参数
function QQPayment:getOrderPara()
	local goodsInfo = self.data.goodsInfo
	local goodsIdInfo = goodsInfo.goodsIdInfo

	if goodsInfo.loginType==0 then
		self.orderHttp = DoMSDKOrderHttp
	else
		self.orderHttp = DoYsdkOrderHttp
	end
	
	return {
				PlatformConfig.name,
	            goodsInfo.signForThirdPay, 
	            goodsInfo.tradeId, 
	            goodsIdInfo:getGoodsPayCodeId(), 
	            goodsIdInfo:getGoodsType(),
	            goodsInfo.amount, 
	            goodsInfo.goodsName, 
	            goodsInfo.totalFee * 100,
	            goodsInfo.openId,
	            goodsInfo.accessToken,
	            goodsInfo.payToken,
	            goodsInfo.pf,
	            goodsInfo.pfKey,
	            goodsInfo.loginType,
        	}
end

function QQPayment:buildGoodsInfo(goodsInfo)
	PaymentBase.buildGoodsInfo(self, goodsInfo)

	local payParamTable = {}
	local openId = "12345"
	if _G.sns_token and _G.sns_token.openId then 
		openId = _G.sns_token.openId
	end
	local payParamMap = self.delegate:getPayParam(openId)
	if payParamMap then 
        payParamTable = luaJavaConvert.map2Table(payParamMap)
    end
    goodsInfo.openId = payParamTable.openId
    goodsInfo.pf = payParamTable.pf
	goodsInfo.pfKey = payParamTable.pfKey
	goodsInfo.accessToken = payParamTable.accessToken
	goodsInfo.payToken = payParamTable.payToken
	goodsInfo.loginType = payParamTable.loginType or 0

	return goodsInfo
end

PaymentBase:register(QQPayment.new())