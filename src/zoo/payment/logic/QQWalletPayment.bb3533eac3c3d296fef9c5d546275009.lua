local QQWalletPayment = class(PaymentBase)

local QQWalletSDKPayNode = class(SDKPayNode)
function QQWalletSDKPayNode:ctor( payment )
	self.name = "QQWalletSDKPay"
end

function QQWalletSDKPayNode:execute()
	PaymentNode.execute(self)

	local sdkCallback = self:buildCallback()

	local payment = self.payment
	local goodsInfo = payment.data.goodsInfo

    payment.delegate:QQWalletBuy(
                                goodsInfo.tokenId, 
                                goodsInfo.tradeId, 
                                goodsInfo.pubAcc,
                                goodsInfo.nonce,
                                goodsInfo.timeStamp,
                                goodsInfo.bargainorId,
                                goodsInfo.sigType,
                                goodsInfo.sig,
				                sdkCallback
                            )  
end

function QQWalletPayment:ctor()
	self.type = Payments.QQ_WALLET
	self.orderHttp = DoQQPaymentOrder
end

function QQWalletPayment:buildPaymentNode(stageType)
	if stageType == PayStage.kSdkPay then
		return QQWalletSDKPayNode.new(self)
	else
		return PaymentBase.buildPaymentNode(self, stageType)
	end
end

--与后端交互使用Http的参数
function QQWalletPayment:getOrderPara()
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
	            goodsInfo.totalFee * 100
        	}
end

PaymentBase:register(QQWalletPayment.new())