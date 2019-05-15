local WechatQuickPayment = class(PaymentBase)

local WechatQuickPreOrderNode = class(PreOrderNode)

function WechatQuickPreOrderNode:ctor(payment)
	self.name = 'WechatQuickPreOrderNode'
end

function WechatQuickPreOrderNode:onSuccess( data )
	local payment = self.payment
	local price = payment.data.goodsInfo.totalFee

	UserManager:getInstance():getDailyData():setWxPayCount(UserManager:getInstance():getDailyData():getWxPayCount()+1)
	UserManager:getInstance():getDailyData():setWxPayRmb(UserManager:getInstance():getDailyData():getWxPayRmb()+price)
	UserService:getInstance():getDailyData():setWxPayCount(UserService:getInstance():getDailyData():getWxPayCount()+1)
	UserService:getInstance():getDailyData():setWxPayRmb(UserService:getInstance():getDailyData():getWxPayRmb()+price)

	PreOrderNode.onSuccess(self, data)
end

function WechatQuickPreOrderNode:onError(data)
	local code = data.code
	local shouldCheck = false
    if code == 730241 or code == 731307 then --已经解约
        UserManager.getInstance().userExtend.wxIngameState = 2
        UserService.getInstance().userExtend.wxIngameState = 2
        if NetworkConfig.writeLocalDataStorage then 
            Localhost:getInstance():flushCurrentUserData()
        else 
            self:print("Did not write user data to the device.") 
        end
    elseif code == 731308 then -- 支付达到上限
        UserManager.getInstance():getDailyData():setWxPayCount(5)
        UserService.getInstance():getDailyData():setWxPayCount(5)
    else
    	shouldCheck = true
    end

    if shouldCheck and self.next then
     	self.next:execute({fromSDKErr = true})
    else
	    data.msg = localize('error.tip.'..code)
		PreOrderNode.onError(self, data)
	end
end

local WechatQuickServerCheckNode = class(ServerCheckNode)

function WechatQuickServerCheckNode:ctor()
    self.name = "WechatQuickServerCheckNode"
end

function WechatQuickServerCheckNode:execute(data)
	if type(data) == "table" and data.fromSDKErr == true then
		ServerCheckNode.execute(self)
	else
		self:onSuccess({})
	end
end


function WechatQuickPayment:ctor()
	self.type = Payments.WECHAT_QUICK_PAY
	self.orderHttp = WxIngame
end

--与后端交互使用Http的参数
function WechatQuickPayment:getOrderPara()
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

function WechatQuickPayment:buildPaymentNode(stageType)
	if stageType == PayStage.kPreOrder then
		return WechatQuickPreOrderNode.new(self)
	elseif stageType == PayStage.kServerCheck then
        return WechatQuickServerCheckNode.new(self)
	else
		return PaymentBase.buildPaymentNode(self, stageType)
	end
end

PaymentBase:register(WechatQuickPayment.new())