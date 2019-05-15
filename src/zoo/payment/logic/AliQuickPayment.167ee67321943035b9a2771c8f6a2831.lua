local AliQuickPreOrderNode = class(PreOrderNode)

function AliQuickPreOrderNode:ctor(payment)
	self.name = 'AliQuickPreOrderNode'
end

function AliQuickPreOrderNode:onSuccess( data )
	local payment = self.payment
	local price = payment.data.goodsInfo.totalFee

	UserManager:getInstance():setAliKfDailyLimit(UserManager:getInstance():getAliKfDailyLimit() - price)
	UserManager:getInstance():setAliKfMonthlyLimit(UserManager:getInstance():getAliKfMonthlyLimit() - price)
	
	PreOrderNode.onSuccess(self, data)
end

function AliQuickPreOrderNode:onError(data)
	local code = data.code
	local msg = data.msg
	local shouldCheck = false
    if code == 730241 then --已经解约
    	UserManager.getInstance().userExtend.aliIngameState = 2
		UserService.getInstance().userExtend.aliIngameState = 2
		if NetworkConfig.writeLocalDataStorage then 
			Localhost:getInstance():flushCurrentUserData()
		else 
			self:print("Did not write user data to the device.") 
		end
    elseif code == 730253 then
        AliQuickPayPromoLogic:removeHomeSceneButton()
    else
    	shouldCheck = true
    end

    if shouldCheck and self.next then
    	self.next:execute({fromSDKErr = true})
    else
	   	local AliQuickPayGuide = require "zoo.panel.alipay.AliQuickPayGuide"
	    msg = AliQuickPayGuide.getErrorMessage(code, "ali.quick.pay.error")

	    PreOrderNode.onError(self, {code = code, msg = msg})
    end
end


local AliQuickServerCheckNode = class(ServerCheckNode)

function AliQuickServerCheckNode:ctor()
    self.name = "AliQuickServerCheckNode"
    self.queryHttp = QueryAliOrderHttp
end

function AliQuickServerCheckNode:execute(data)
	if type(data) == "table" and data.fromSDKErr == true then
		ServerCheckNode.execute(self)
	else
		self:onSuccess({})
	end
end


local AliQuickPayment = class(PaymentBase)

function AliQuickPayment:ctor()
	self.type = Payments.ALI_QUICK_PAY
	self.orderHttp = GetAliIngamePayment
end

--与后端交互使用Http的参数
function AliQuickPayment:getOrderPara()
	local goodsInfo = self.data.goodsInfo
	local goodsIdInfo = goodsInfo.goodsIdInfo
	
	return {
				goodsInfo.tradeId,
				PlatformConfig.name,
				goodsIdInfo:getGoodsPayCodeId(),
				goodsIdInfo:getGoodsType(),
	            goodsInfo.amount, 
	            goodsInfo.goodsName, 
	            goodsInfo.totalFee,
	            goodsInfo.signForThirdPay,
        	}
end

function AliQuickPayment:buildPaymentNode(stageType)
	if stageType == PayStage.kPreOrder then
		return AliQuickPreOrderNode.new(self)
	elseif stageType == PayStage.kServerCheck then
        return AliQuickServerCheckNode.new(self)
	else
		return PaymentBase.buildPaymentNode(self, stageType)
	end
end

PaymentBase:register(AliQuickPayment.new())