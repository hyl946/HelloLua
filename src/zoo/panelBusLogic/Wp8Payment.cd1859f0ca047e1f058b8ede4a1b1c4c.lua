Wp8Payments = {
--    CHINA_MOBILE = 1,
    IAPPPAY = 4,
    MSPAY = 5,
    ALIPAY = 6,
    IAP = 7,
}

Payments = Wp8Payments

Wp8SupportedPayments = {
	-- [Wp8Payments.CHINA_MOBILE] = {1,2,3},
	--[Wp8Payments.IAPPPAY] = {1,2,3,4,5},
	-- [Wp8Payments.MSPAY] = {},
	-- [Wp8Payments.ALIPAY] = {76,77,78,79,80},
	[Wp8Payments.IAP] = {97,98,99,100,101},
}

local mmAppId = "300008276251"
local mmAppKey = "3BA7DC3A10380449"
CMccPayment:GetInstance():Init(mmAppId, mmAppKey)

Wp8Payment = class()

local forceChoose = false
local billIdSeq = 0
local gspAppId = "5000105666"

function Wp8Payment:create(goodsId)
	local logic = Wp8Payment.new()
	if logic:init(goodsId) then
		return logic
	else
		logic = nil
		return nil
	end
end

function Wp8Payment:init(goodsId)
	self.goodsId = goodsId
	self.goodsType = 2
	return true
end

function Wp8Payment:iapppayStart(uid, orderId, price)
	local pay_start = os.time()
	local function onPurchaseCallback(r)
		local pay_duration = os.time() - pay_start
		local alreadySuccess = false
		if r == 1 then
			alreadySuccess = true
		end
		local intervals = {1}
		if alreadySuccess then
			intervals = {2, 4, 8}
		elseif pay_duration > 60 then
			intervals = {2, 4, 4}
		elseif pay_duration > 40 then
			intervals = {2, 4}
		elseif pay_duration > 20 then
			intervals = {2, 2}
		end
		local trytimes = 0
		local function __checkOrder()
			local function onFail()
				Wp8Utils:CloseLoading()
				if alreadySuccess then
					CommonTip:showTip("支付已经完成，但是到账会稍有延迟", "positive", nil, 3)
					if self.cancelCallback then self.cancelCallback() end
				else
					if self.failCallback then self.failCallback() end
				end
			end
			local function onSuccess()
				Wp8Utils:CloseLoading()
				if self.successCallback then self.successCallback() end
			end
			local function onRequestError( evt )
				evt.target:removeAllEventListeners()
				if trytimes < #intervals then
					if _G.isLocalDevelopMode then printx(0, "__checkOrder retry when onRequestError") end
					trytimes = trytimes + 1
					setTimeOut(__checkOrder, intervals[trytimes])
				else
					if _G.isLocalDevelopMode then printx(0, "__checkOrder fail onRequestError") end
					onFail()
				end
			end
			local function onRequestFinish( evt )
				evt.target:removeAllEventListeners()
				if evt.data and evt.data.finished then
					if evt.data.success then
						if _G.isLocalDevelopMode then printx(0, "__checkOrder success") end
						onSuccess()
					else
						if _G.isLocalDevelopMode then printx(0, "__checkOrder finish but not success") end
						onFail()
					end
				elseif trytimes < #intervals then
					if _G.isLocalDevelopMode then printx(0, "__checkOrder retry when onRequestFinish") end
					trytimes = trytimes + 1
					setTimeOut(__checkOrder, intervals[trytimes])
				else
					if _G.isLocalDevelopMode then printx(0, "__checkOrder fail onRequestFinish") end
					onFail()
				end
			end
			local http = QueryQihooOrderHttp.new(true)
			http:addEventListener(Events.kComplete, onRequestFinish)
			http:addEventListener(Events.kError, onRequestError)
			http:load(self.billId)
		end
		trytimes = trytimes + 1
		setTimeOut(__checkOrder, intervals[trytimes])
		Wp8Utils:ShowLoading()
	end
	IappPay:GetInstance():StartPay(tostring(uid), self.goodsId, tostring(orderId), price, onPurchaseCallback)
end

function Wp8Payment:doIapppay()
	local user = UserManager:getInstance().user
	local uid = user.uid
	billIdSeq = billIdSeq + 1
	self.billId = uid .. "_" .. os.time() .. "_" .. billIdSeq
	local exchangeMeta = self:getMetaData(self.goodsId)
	local extend_table = {billId=self.billId, itemId=10000+self.goodsId, goodsType=2, itemPrice=exchangeMeta.rmb}
	local cjson = require("cjson")
	local extend = cjson.encode(extend_table)
	local url = 'http://web.pay.cn.happyelements.com/userpayment/76/1/init/'..gspAppId..'/'..uid
	local request = HttpRequest:createPost(url)
	request:setConnectionTimeoutMs(10 * 1000)
	request:setTimeoutMs(30 * 1000)
	request:addPostValue("random", os.time() .. "")
	request:addPostValue("product_id", (10000 + self.goodsId) .. "")
	request:addPostValue("price", string.format("%.2f", exchangeMeta.rmb / 100.0))
	request:addPostValue("client", "windowsphone")
	request:addPostValue("client_version", MetaInfo:getInstance():getApkVersion())
	request:addPostValue("locale", MetaInfo:getInstance():getCountry())
	request:addPostValue("language", MetaInfo:getInstance():getLanguage())
	request:addPostValue("platform", "windowsphone")
	request:addPostValue("extend", extend)
	request:addPostValue("store", "microsoft")

	local function initOrderFinish(response)
		Wp8Utils:CloseLoading()
		if response.httpCode == 200 then
			local orderId = nil
			local function safeParseRsp()
				if _G.isLocalDevelopMode then printx(0, response.body) end
				local rsp_table = cjson.decode(response.body)
				if rsp_table.result == "success" then
					orderId = rsp_table.order_id
				end
			end
			pcall(safeParseRsp)
			if orderId then
				self:iapppayStart(uid, orderId, exchangeMeta.rmb)
			else
				if _G.isLocalDevelopMode then printx(0, response.body) end
				CommonTip:showTip("创建订单失败", "negative")
				if cancelCallback then cancelCallback() end
			end
		else
			if _G.isLocalDevelopMode then printx(0, table.tostring(response)) end
			CommonTip:showTip("网络异常，创建订单失败", "negative")
			if cancelCallback then cancelCallback() end
		end
	end
	Wp8Utils:ShowLoading(500)
	HttpClient:getInstance():sendRequest(initOrderFinish, request)
end

function Wp8Payment:doMobilePay()
	local function onPurchaseCallback(r, para)
		if _G.isLocalDevelopMode then printx(0, "onPurchaseCallback " .. r) end
		if r == 1 then
			local function onSuccess()
				if self.successCallback then self.successCallback() end
			end
			local function onFail(evt)
				if self.failCallback then self.failCallback(evt) end
			end
			local http = IngameHttp.new(true)
			http:ad(Events.kComplete, onSuccess)
			http:ad(Events.kError, onFail)
			local orderId = para.tradeId
			local channelId = "wp8_china_mobile"
			local detail = ""
			if para and type(para) == "table" then
				detail = table.serialize(para)
			end
			http:load(self.goodsId, orderId, channelId, self.goodsType, detail)
		elseif r == 0 then
			if self.failCallback then self.failCallback() end
		elseif r == -1 then
			if self.cancelCallback then self.cancelCallback() end
		else end
	end

	local mobile_mock = false
	if mobile_mock then
		local mock_tradeId = user.uid .. "_" .. os.time()
		onPurchaseCallback(1, {tradeId = mock_tradeId})
	else
		local payCode = self:getMetaData(self.goodsId).mmPaycode
		CMccPayment:GetInstance():Order(payCode, 1, onPurchaseCallback)
	end
end

function Wp8Payment:getMetaData( goodsId )
	return MetaManager:getInstance().product_wp8[goodsId]
end

function Wp8Payment:doAlipay()
	if _G.isLocalDevelopMode then printx(0, "wp8 ALIPAY...") end
	local function onRequestFinish(evt)
        evt.target:removeAllEventListeners()
        
		local function callback( code )
			if code == 0 then
				require "zoo.panelBusLogic.IngamePaymentLogic"
				IngamePaymentLogic:checkOnlinePay(self.tradeId, self.successCallback, self.failCallback, true)
			elseif code == 1 then
				if self.cancelCallback then self.cancelCallback() end
			elseif code == 2 then
				if self.failCallback then self.failCallback() end
			end
		end
		Alipay:GetInstance():StartPay(evt.data.url, callback)
    end 

    local function onRequestError(evt)
        evt.target:removeAllEventListeners()
        if self.failCallback then self.failCallback(evt.data) end
    end

    local function onRequestCancel(evt)
    	evt.target:removeAllEventListeners()
    	if self.cancelCallback then self.cancelCallback() end
	end

    local function buywithPostLogin()
    	local exchangeMeta = self:getMetaData(self.goodsId)
    	self.tradeId = "wp" .. UserManager:getInstance().uid .. "_" .. os.time()
    	self.platform = StartupConfig:getInstance():getPlatformName()
    	self.goodsName = Localization:getInstance():getText("goods.name.text"..tostring(10000 + self.goodsId))

        local http = DoWpAliPaymentOrder.new(true)
        http:addEventListener(Events.kComplete, onRequestFinish)
        http:addEventListener(Events.kError, onRequestError)
        http:addEventListener(Events.kCancel, onRequestCancel)
        http:syncLoad(
                        self.platform, 
                        nil, 
                        self.tradeId,
                        self.goodsId + 10000, 
                        self.goodsType, 
                        1, 
                        self.goodsName, 
                        exchangeMeta.rmb
                    )
	end

	local function onUserNotLogin()
    	if self.failCallback then self.failCallback(-6) end
    end

	RequireNetworkAlert:callFuncWithLogged(buywithPostLogin, onUserNotLogin, -999)
end

function Wp8Payment:checkOnlinePay(msg)
	local function onRequestFinish(evt)
        evt.target:removeAllEventListeners()
        WP8Iap:GetInstance():DoFulfillment(self.goodsId + 10000)
        if self.successCallback then self.successCallback() end
    end 

    local function onRequestError(evt)
        evt.target:removeAllEventListeners()
        if self.failCallback then self.failCallback(evt.data) end
    end

    local function onRequestCancel(evt)
    	evt.target:removeAllEventListeners()
    	if self.cancelCallback then self.cancelCallback() end
	end

    local function serverCheck()
        local http = WPIAPOffineHttp.new(true)
        http:addEventListener(Events.kComplete, onRequestFinish)
        http:addEventListener(Events.kError, onRequestError)
        http:addEventListener(Events.kCancel, onRequestCancel)
        --id, orderId, tradeId, detail
        http:syncLoad(
                        self.goodsId,  
                        self.tradeId,
                        self.tradeId,
                        msg
                    )
	end

	local function onUserNotLogin()
    	if self.failCallback then self.failCallback(-6) end
    end

	RequireNetworkAlert:callFuncWithLogged(serverCheck, onUserNotLogin, -999)
end

function Wp8Payment:doIAP()
	local exchangeMeta = self:getMetaData(self.goodsId)
    self.tradeId = "wpiap" .. UserManager:getInstance().uid .. "_" .. os.time()
    self.platform = StartupConfig:getInstance():getPlatformName()
    self.goodsName = Localization:getInstance():getText("goods.name.text"..tostring(10000 + self.goodsId))


	local function callback( code, msg )
		if code == 0 then
			self:checkOnlinePay(msg)
		elseif code == 1 then
			if self.cancelCallback then self.cancelCallback() end
		elseif code == 2 then
			if self.failCallback then self.failCallback() end
		end
	end
	WP8Iap:GetInstance():StartPay(tostring(self.goodsId), tostring(exchangeMeta.rmb), callback)
end

function Wp8Payment:__buy(successCallback, failCallback, cancelCallback)
	self.successCallback = successCallback
	self.failCallback = failCallback
	self.cancelCallback = cancelCallback
  
	local function startPayment(paymentType)
		self.paymentType = paymentType
		if not paymentType then 
			if cancelCallback then cancelCallback() end
			return
		end
		local user = UserManager:getInstance().user
		if not user or not user.uid then
			he_log_error("cat not get user id")
			failCallback()
			return
		end
		
		if paymentType == Wp8Payments.IAPPPAY then
			self:doIapppay()
		elseif paymentType == Wp8Payments.CHINA_MOBILE then
			self:doMobilePay()
		elseif paymentType == Wp8Payments.ALIPAY then
			self:doAlipay()
		elseif paymentType == Wp8Payments.IAP then
			self:doIAP()
		end
	end
	
	local paymentsToShow = {}
	for k,v in pairs(Wp8SupportedPayments) do
		for __,v2 in ipairs(v) do 
			if v2 == self.goodsId then
				paymentsToShow[k] = true
				break
			end
		end
	end
	
	local snum = 0
	local usedPayment
	for k,v in pairs(paymentsToShow) do
		if v then 
			snum = snum + 1 
			usedPayment = k
		end
	end
	if _G.isLocalDevelopMode then printx(0, "Wp8 paymentsToShow num " .. snum) end
	if not forceChoose and snum == 1 then
		startPayment(usedPayment)
	else
		require 'zoo.panel.ChoosePaymentPanel'
		local panel = ChoosePaymentPanel:create(paymentsToShow)
		if panel then panel:popout(startPayment) end
	end
end

function Wp8Payment:buy(successCallback, failCallback, cancelCallback)
	RealNameManager:checkOnPay(function ( ... )
		self:__buy(successCallback, failCallback, cancelCallback)
	end, function ( ... )
		local errCode = RealNameManager.errCode
		local errMsg = RealNameManager.errMsg
		if failCallback then
			failCallback(errCode, errMsg)
		end
	end)
end