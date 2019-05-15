local WechatPayment = class(PaymentBase)

local WechatSDKPayNode = class(SDKPayNode)
function WechatSDKPayNode:ctor( payment )
	self.name = "WechatSDKPay"
end

function WechatSDKPayNode:execute()
	PaymentNode.execute(self)

	local sdkCallback = self:buildCallback()

	local payment = self.payment
	local goodsInfo = payment.data.goodsInfo

    payment.delegate:WXbuy(goodsInfo.tradeId,
	    					goodsInfo.partnerId, 
	    					goodsInfo.prepayId,
							goodsInfo.nonceStr,
							goodsInfo.timeStamp,
							goodsInfo.signStr, 
							sdkCallback) 
end

function WechatPayment:ctor()
	self.type = Payments.WECHAT
    if PaymentManager.getInstance():checkUseNewWechatPay(PlatformConfig.name) then
    	self.orderHttp = DoWXOrderV2Http
    else
    	self.orderHttp = DoWXOrderHttp
	end
end

function WechatPayment:buildPaymentNode(stageType)
	if stageType == PayStage.kSdkPay then
		return WechatSDKPayNode.new(self)
	else
		return PaymentBase.buildPaymentNode(self, stageType)
	end
end

--与后端交互使用Http的参数
function WechatPayment:getOrderPara()
	local ip = "127.0.0.1"
	if AndroidPayment.getInstance():forceHeWechatPayment() then 
		ip = ip.."@he"
	end
	local goodsInfo = self.data.goodsInfo
	local goodsIdInfo = goodsInfo.goodsIdInfo
	local wxAppId = AndroidPayment.getInstance().wxPaymentId

	return {
				PlatformConfig.name,
	            goodsInfo.signForThirdPay, 
	            goodsInfo.tradeId, 
	            goodsIdInfo:getGoodsPayCodeId(), 
	            goodsIdInfo:getGoodsType(),
	            goodsInfo.amount, 
	            goodsInfo.goodsName, 
	            goodsInfo.totalFee * 100,
	            ip,
	            wxAppId
        	}
end

function WechatPayment:clone()
	local PaymentConfigs = require "zoo.payment.logic.PaymentConfig"
	local payment = WechatPayment.new()
	local config = PaymentConfigs[self.type]
    config.type = self.type
	payment:init(config)
	payment.enabled = self.enabled
	payment.delegate = self.delegate

	return payment
end

function WechatPayment:buy( goodsInfo, payCallback )
	local quickPay = UserManager:getInstance():isWechatSigned() and PaymentManager.getInstance():checkCanWechatQuickPay(goodsInfo.totalFee)
	if quickPay then
		PaymentBase:buyWithType(Payments.WECHAT_QUICK_PAY, goodsInfo, payCallback)
	else
		PaymentBase.buy(self:clone(), goodsInfo, payCallback)
	end
end

PaymentBase:register(WechatPayment.new())