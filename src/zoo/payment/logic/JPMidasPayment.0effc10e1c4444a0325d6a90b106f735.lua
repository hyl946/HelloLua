
local JPMidasPayNode = class(SDKPayNode)
function JPMidasPayNode:ctor( payment )
	self.name = "JPMidasPay"
end

function JPMidasPayNode:execute()
	PaymentNode.execute(self)

	local sdkCallback = self:buildCallback()

	local payment = self.payment
	local goodsInfo = payment.data.goodsInfo

    payment.delegate:buyWithToken(goodsInfo.tradeId, 
									goodsInfo.params, 
									goodsInfo.tokenUrl, 
									sdkCallback)
end

function JPMidasPayNode:onError(data)
	local code = data.code
    if code and code == WXJPPackageUtil.getInstance().errorCode1 then --客户端判定登录态失效（比如微信后台主动取消游戏关联）
	 	WXJPPackageUtil.getInstance():showLoginExpirePanel(function ()
	 		data.code =  WXJPPackageUtil.getInstance().errorCode2
	 		PaymentNode.onError(self, data)
	 	end, function ()
	 		data.code =  WXJPPackageUtil.getInstance().errorCode3
	 		PaymentNode.onError(self, data)
	 	end, function ()
	 		data.code =  WXJPPackageUtil.getInstance().errorCode4
	 		PaymentNode.onError(self, data)
	 	end)
 	else
 		PaymentNode.onError(self, data)
    end
end


local JPMidasPreOrderNode = class(PreOrderNode)
function JPMidasPreOrderNode:ctor(payment)
	self.name = 'JPMidasPreOrderNode'
end

function JPMidasPreOrderNode:onError(data)
	local code = data.code
    if code and code == 730213 then --服务器判定微信的token过期 主动刷新下 以便下次成功下单
    	--这个方法刷新的token 支付不成功 fuck 弃用
  		-- WXJPPackageUtil.getInstance():refreshWXToken()
	 	WXJPPackageUtil.getInstance():showLoginExpirePanel(function ()
	 		data.code =  WXJPPackageUtil.getInstance().errorCode2
	 		PreOrderNode.onError(self, data)
	 	end, function ()
	 		data.code =  WXJPPackageUtil.getInstance().errorCode3
	 		PreOrderNode.onError(self, data)
	 	end, function ()
	 		data.code =  WXJPPackageUtil.getInstance().errorCode4
	 		PreOrderNode.onError(self, data)
	 	end)
 	else
 		PreOrderNode.onError(self, data)
    end
end


local JPMidasPayment = class(PaymentBase)
function JPMidasPayment:ctor()
	self.type = Payments.MIDAS
	self.orderHttp = DoMidasOrderHttp
end

function JPMidasPayment:buildPaymentNode(stageType)
	if stageType == PayStage.kSdkPay then
		return JPMidasPayNode.new(self)
	elseif stageType == PayStage.kPreOrder then
        return JPMidasPreOrderNode.new(self)
	else
		return PaymentBase.buildPaymentNode(self, stageType)
	end
end

--与后端交互使用Http的参数
function JPMidasPayment:getOrderPara()
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
	            goodsInfo.openId,
	            goodsInfo.accessToken,
	            goodsInfo.payToken,
	            goodsInfo.pf,
	            goodsInfo.pfKey,
	            goodsInfo.loginType,
        	}
end

function JPMidasPayment:buildGoodsInfo(goodsInfo)
	PaymentBase.buildGoodsInfo(self, goodsInfo)

	local payParamTable = {}
	-- local openId = tostring(UserManager:getInstance().uid) or "12345"
	local openId = "12345"
	if _G.sns_token and _G.sns_token.openId then 
		openId = _G.sns_token.openId
	end
	local payParamMap = WXJPPackageUtil.getInstance():getPayParam(openId)
	if payParamMap then 
        payParamTable = luaJavaConvert.map2Table(payParamMap)
    end
    goodsInfo.openId = payParamTable.openId
    goodsInfo.pf = payParamTable.pf
	goodsInfo.pfKey = payParamTable.pfKey
	goodsInfo.accessToken = payParamTable.accessToken
	goodsInfo.payToken = payParamTable.payToken
	local loginType = 0
	if payParamTable.loginType == "login_qq" then 
		loginType = 1
	elseif payParamTable.loginType == "login_wx" then 
		loginType = 2
	end
	goodsInfo.loginType = loginType

	return goodsInfo
end

PaymentBase:register(JPMidasPayment.new())