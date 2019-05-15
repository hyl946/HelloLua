local HuaweiPayment = class(PaymentBase)

local HuaweiSDKPayNode = class(SDKPayNode)
function HuaweiSDKPayNode:ctor( payment )
	self.name = "HuaweiSDKPay"
end

function HuaweiSDKPayNode:execute()
	PaymentNode.execute(self)

	local sdkCallback = self:buildCallback()
	local payment = self.payment
	local goodsInfo = payment.data.goodsInfo

    payment.delegate:huaweiBuy(goodsInfo.tradeId, 
								goodsInfo.signStr, 
								goodsInfo.params, 
								sdkCallback) 
end

function HuaweiSDKPayNode:onError(data)
	local errCode = data.code
	local errMsg = data.msg

	if errCode == 30008 then --"用户需要重新登录！"
		local function successFunc()
			--直接返回到ingame 重新购买
			SDKPayNode.onError(self, {reTryPay = true})
		end

		local function failFunc(code, msg)
			SDKPayNode.onError(self, {code = code, msg = msg})
		end

		SnsProxy:huaweiIngameLogin(successFunc, failFunc, failFunc)
	else
		-- -65535,需后端查询的errcode
		-- 1.59开始 华为支付 只要失败 就给玩家手动查的机会
		if errCode == 30000 then 	--30000是PAY_STATE_CANCEL
			SDKPayNode.onError(self, data)
		elseif self.next then
		 	self.next:execute({fromSDKErr = true, _errCode = errCode, _errMsg = errMsg})
		else
			SDKPayNode.onError(self, data)
		end
	end
end

local HuaweiServerCheckNode = class(ServerCheckNode)

function HuaweiServerCheckNode:ctor( ... )
    self.name = "HuaweiServerCheckNode"
end

function HuaweiServerCheckNode:execute( data )
	if type(data) == "table" and data.fromSDKErr == true then
		ServerCheckNode.execute(self, data)
	else
		self:onSuccess({})
	end
end

function HuaweiPayment:ctor()
	self.type = Payments.HUAWEI
	self.orderHttp = DoHuaweiOrderHttp
end

function HuaweiPayment:buildPaymentNode(stageType)
	if stageType == PayStage.kSdkPay then
		return HuaweiSDKPayNode.new(self)
	elseif stageType == PayStage.kServerCheck then
		return HuaweiServerCheckNode.new(self)
	else
		return PaymentBase.buildPaymentNode(self, stageType)
	end
end

--与后端交互使用Http的参数
function HuaweiPayment:getOrderPara()
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
	            goodsInfo.totalFee * 100,
        	}
end

PaymentBase:register(HuaweiPayment.new())