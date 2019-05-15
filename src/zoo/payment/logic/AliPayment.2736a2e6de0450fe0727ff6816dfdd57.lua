local AliPayment = class(PaymentBase)

local AliSDKPayNode = class(SDKPayNode)
function AliSDKPayNode:ctor( payment )
	self.name = "AliSDKPay"
end

function AliSDKPayNode:execute()
	PaymentNode.execute(self)

	local sdkCallback = self:buildCallback()

	local payment = self.payment
	local goodsInfo = payment.data.goodsInfo

    payment.delegate:ALIbuy(goodsInfo.tradeId, goodsInfo.signStr, sdkCallback)
end

function AliSDKPayNode:onError(data)
	local errCode = data.code
	local errMsg = data.msg

	if errCode == 8000 then 
		-- "8000"代表支付结果因为支付渠道原因或者系统原因还在等待支付结果确认，最终交易是否成功以服务端异步通知为准（小概率状态）
		if self.next then
			self.next:execute({fromSDKErr = true})
		end
	else
		SDKPayNode.onError(self, {code = errCode, msg = errMsg})
	end
end


local AliServerCheckNode = class(ServerCheckNode)

function AliServerCheckNode:ctor( ... )
    self.name = "AliServerCheckNode"
end

function AliServerCheckNode:execute( data )
	if type(data) == "table" and data.fromSDKErr == true then
		ServerCheckNode.execute(self)
	else
		self:onSuccess({})
	end
end


function AliPayment:ctor()
	self.type = Payments.ALIPAY
	self.orderHttp = DoAliOrderHttp
end

function AliPayment:buildPaymentNode(stageType)
	if stageType == PayStage.kSdkPay then
		return AliSDKPayNode.new(self)
	elseif stageType == PayStage.kServerCheck then
		return AliServerCheckNode.new(self)
	else
		return PaymentBase.buildPaymentNode(self, stageType)
	end
end

--与后端交互使用Http的参数
function AliPayment:getOrderPara()
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
	            goodsInfo.totalFee
        	}
end

function AliPayment:clone()
	local PaymentConfigs = require "zoo.payment.logic.PaymentConfig"
	local payment = AliPayment.new()
	local config = PaymentConfigs[self.type]
    config.type = self.type
	payment:init(config)
	payment.enabled = self.enabled
	payment.delegate = self.delegate

	return payment
end

function AliPayment:buy( goodsInfo, payCallback )

	--大部分是破冰礼包
	local goodIdsNoQuickPay = {18, 282, 283, 284, 285, 286, 366, 367, 368, 372, 478}

	local goodsId = goodsInfo.goodsIdInfo:getGoodsId()

	local aliSignPayment = PaymentBase:getPayment( Payments.ALI_SIGN_PAY )
	if not UserManager.getInstance():isAliSigned() 
		and aliSignPayment:isEnabled() 
		and PaymentManager.getInstance():checkCanAliQuickPay(goodsInfo.totalFee) 
        and table.exist(goodIdsNoQuickPay, goodsId) == false
    then
       	PaymentBase:buyWithType(Payments.ALI_SIGN_PAY, goodsInfo, payCallback)
	elseif UserManager.getInstance():isAliSigned()
		-- and goodsId ~= 478
		and PaymentManager.getInstance():checkCanAliQuickPay(goodsInfo.totalFee, goodsId) 
	then 
		DcUtil:UserTrack({category='alipay_mmpay', sub_category='mmpay_limit', T1=0})
		PaymentBase:buyWithType(Payments.ALI_QUICK_PAY, goodsInfo, payCallback)
	else
		if UserManager:getInstance():getAliKfMonthlyLimit() <= 0 or UserManager:getInstance():getAliKfDailyLimit() <= 0 then
			DcUtil:UserTrack({category='alipay_mmpay', sub_category='mmpay_limit', T1=1})
		end
		PaymentBase.buy(self:clone(), goodsInfo, payCallback)
	end
end

PaymentBase:register(AliPayment.new())