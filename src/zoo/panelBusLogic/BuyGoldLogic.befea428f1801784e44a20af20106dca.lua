require "zoo.data.MetaManager"
require "zoo.payment.paymentDC.DCWindmillObject"

if __IOS then
	require "zoo.util.IosPayment"
elseif __ANDROID then
	require "zoo.panelBusLogic.IngamePaymentLogic"
elseif __WP8 then
	require "zoo.panelBusLogic.Wp8Payment"
end

BuyGoldLogic = class()

function BuyGoldLogic:create()
	local logic = BuyGoldLogic.new()
	return logic
end

function BuyGoldLogic:getMeta()
	if __IOS then
		self.meta = MetaManager:getInstance().product
	elseif __ANDROID then
		self.meta = MetaManager:getInstance().product_android
	elseif __WP8 then
		self.meta = MetaManager:getInstance().product_wp8
	else -- on PC there should not be any gold buying stuff 'cause nothing can be bought
		self.meta = MetaManager:getInstance().product;
	end
	for k, v in ipairs(self.meta) do
		if string.len(v.productId) == 0 then v.productId = tostring(k) end
	end
	return self.meta
end

function BuyGoldLogic:getProductInfo(successCallback, failCallback, timeoutCallback, cancelCallback)
	if not self.meta then self:getMeta() end
	local goldList, counter = {}, 0
	local scene = Director:sharedDirector():getRunningScene()

	local animation
	local function removeLoading()
		if self.schedule then
			Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule)
			self.schedule = nil
		else return end
		animation:removeFromParentAndCleanup(true)
		self.schedule = nil
	end
	local function onCloseButtonTap()
		removeLoading()
		if cancelCallback then cancelCallback() end
	end
	animation = CountDownAnimation:createNetworkAnimation(scene, onCloseButtonTap)
	-- scene:addChild(animation, SceneLayerShowKey.TOP_LAYER)
	for __, v in ipairs(self.meta) do

		--新版风车币商店 强行多一档风车币
		if HappyCoinShopFactory:getInstance():shouldUseNewfeatures() then
			if v.id == 40 then
				v.show = true
			end
		end

		if MaintenanceManager:getInstance():isEnabled('AppleVerification') then
			if v.id == 133 then
				v.show = true
			end
		end

		if v.show then
			if __IOS and v.id == 8 then
				if MaintenanceManager:getInstance():isEnabled("CoinPanelCny1") then 
					counter = counter + 1
					goldList[tostring(counter)] = v.productId
				end
			elseif __IOS and v.id == 9 then
				if MaintenanceManager:getInstance():isEnabled("CoinPanelCny3") then
					counter = counter + 1
					goldList[tostring(counter)] = v.productId
				end
			elseif __IOS and v.id == 10 then
			elseif __IOS and v.id == 11 then
			elseif __IOS and v.id == 12 then
			elseif __IOS and v.id == 13 then
			elseif __IOS and v.id == 14 then
			else
				counter = counter + 1
				goldList[tostring(counter)] = v.productId
			end
		end
	end




	--促销礼包
	local promotionProcuctIds = {
		['1'] = 'com.happyelements.animal.gold.cn.41',
		['2'] = 'com.happyelements.animal.gold.cn.42',
		['3'] = 'com.happyelements.animal.gold.cn.43',
		['4'] = 'com.happyelements.animal.gold.cn.44',
		['5'] = 'com.happyelements.animal.gold.cn.45',
		['6'] = 'com.happyelements.animal.gold.cn.51',
	}

	local function unionList( l1, l2 )
		local t = {}
		local index = 1

		for k, v in pairs(l1) do
			t[tostring(index)] = v
			index = index + 1
		end

		for k, v in pairs(l2) do
			t[tostring(index)] = v
			index = index + 1
		end

		return t
	end



	local function onSuccess(iapConfig)

		local promotionIapConfigs = {}
		local happyCoinIapConfig = {}

		if __IOS then

			local counter = 0

			for key, value in pairs(iapConfig) do
				if table.exist(promotionProcuctIds, value.productIdentifier) then
					table.insert(promotionIapConfigs, value)
				else
					happyCoinIapConfig[tostring(counter)] = value
					counter = counter + 1
				end
			end


			require 'zoo.panel.happyCoinShop.PromotionFactory'
			PromotionManager:getInstance():setIapConfig(promotionIapConfigs)
		else
			happyCoinIapConfig = iapConfig
		end

		if self.schedule then
			removeLoading()
			self.iapConfig = happyCoinIapConfig
			if successCallback then successCallback(happyCoinIapConfig) end
		end
	end
	local function onFail(evt)
		if self.schedule then
			removeLoading()
			if failCallback then failCallback(evt) end
		end
	end
	local function onTimeout()
		if self.schedule then
			removeLoading()
			if timeoutCallback then timeoutCallback() end
		end
	end



	if __IOS then -- IOS
		self.schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, 20, false)
		IosPayment:showPayment(unionList(goldList, promotionProcuctIds), onSuccess, onFail)
	elseif __ANDROID then -- ANDROID

		local tempPayment = AndroidPayment.getInstance():getDefaultSmsPayment()

		local res = {}
		for k, v in ipairs(self.meta) do
			if v.id ~= 16 and v.id ~= 17 and v.id ~= 18 and v.id ~= 29 then -- hide gold payments
				res[tostring(k - 1)] = v
				res[tostring(k - 1)].iapPrice = v.rmb / 100

				-- 默认支付方式是MDO时，单独处理为整5、10的值
				-- if tempPayment == Payments.MDO then
				-- 	if v.rmb == 1200 then res[tostring(k - 1)].iapPrice = 10
			 --        elseif v.rmb == 2800 then
			 --        	res[tostring(k - 1)].iapPrice = 25
			 --        	res[tostring(k - 1)].extra = true
			 --        end
				-- end
				--[[
				-- 当运营商是移动且平台是91或多库的时候单独处理为整5、10的值
				local telecomOperator = SnsProxy:getOperatorOne()
				if telecomOperator == TelecomOperators.CHINA_MOBILE then
				    if enableMdoPayement then
				    	if PlatformConfig:isBaiduPlatform() then
					        if v.rmb == 1200 then res[tostring(k - 1)].iapPrice = 10
					        elseif v.rmb == 2800 then
					        	res[tostring(k - 1)].iapPrice = 25
					        	res[tostring(k - 1)].extra = true
					        end
				        end
				    end
				end
				]]--

				res[tostring(k - 1)].productIdentifier = v.productId
			end
		end
		self.schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, 20, false)

		-- 如果仅支持短代，不显示这些单价>30的商品
		if not PlatformConfig:isBigPayPlatform() then
			for k, v in pairs(res) do 
				if v.iapPrice > 30 then
					res[k] = nil
				end
			end
		end

		onSuccess(res)
	elseif __WP8 then
		local res = {}
		for k, v in ipairs(self.meta) do
			res[tostring(k - 1)] = v
			res[tostring(k - 1)].iapPrice = v.rmb / 100
			res[tostring(k - 1)].productIdentifier = v.productId
		end
		self.schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, 20, false)
		onSuccess(res)
	else -- I don't wanna fake a group of info to fool testers, so just skip.
		self.schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, 20, false)
		
		onSuccess({["0"] = {productIdentifier = "com.happyelements.animal.gold.cn.1", iapPrice = 6}, 
			       ["1"] = {productIdentifier = "com.happyelements.animal.gold.cn.2", iapPrice = 30}, 
			       ["2"] = {productIdentifier = "com.happyelements.animal.gold.cn.3", iapPrice = 128},
			       ["3"] = {productIdentifier = "com.happyelements.animal.gold.cn.4", iapPrice = 18},  
			       ["4"] = {productIdentifier = "com.happyelements.animal.gold.cn.8", iapPrice = 1},  
			       ["5"] = {productIdentifier = "com.happyelements.animal.gold.cn.9", iapPrice = 3},  
			       });
	end
end

function BuyGoldLogic:setDcParams( feature, source )
	-- body
	self.dcFeature = feature
	self.dcSource = source
end

function BuyGoldLogic:buy(index, data, successCallback, failCallback, cancelCallback)
	local function onSuccess()
		local user = UserManager:getInstance().user
		local serv = UserService:getInstance().user
		local oldCash = user:getCash()
		local newCash = oldCash + self.meta[index].cash;
		user:setCash(newCash)
		serv:setCash(newCash)

		local userExtend = UserManager:getInstance().userExtend
		if type(userExtend) == "table" then userExtend.payUser = true end
		if __IOS or __WIN32 then
			UserManager:getInstance():getUserExtendRef():setLastPayTime(Localhost:time())
			UserService:getInstance():getUserExtendRef():setLastPayTime(Localhost:time())
		end

		local priceInFen = 0
		if __WP8 or __ANDROID then
			priceInFen = self.meta[index].rmb
		else
			priceInFen = self.meta[index].price and self.meta[index].price  * 100 or 0
		end		

		local level = nil
		if GameBoardLogic:getInstance() then
			level = GameBoardLogic:getInstance().level
		end

		if not __ANDROID then -- android consumeCurrency点在IngamePaymentLogic:deliverItems()里面打点了
			GainAndConsumeMgr.getInstance():consumeCurrency(self.dcFeature or DcFeatureType.kStore, DcDataCurrencyType.kRmb, priceInFen, 
											10000 + index, 1, level, nil, self.dcSource or DcSourceType.kStoreBuyGold)
		end
		GainAndConsumeMgr.getInstance():gainItem(self.dcFeature or DcFeatureType.kStore, ItemType.GOLD, self.meta[index].cash, self.dcSource or DcSourceType.kStoreBuyGold, level, nil, DcPayType.kRmb, priceInFen, index)

		if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
		else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
		if successCallback then
			successCallback()
		end

		if __IOS or __WIN32 then 
			GlobalEventDispatcher:getInstance():dispatchEvent(
				Event.new(kGlobalEvents.kConsumeComplete,{
					price=self.meta[index].price,
					props=Localization:getInstance():getText("consume.history.panel.gold.text",{n=self.meta[index].cash}),
					goodsId=index,
					goodsType=2,
				})
			)
		end
	end
	local function onFail(errCode, errMsg, noTip)
		if failCallback then
			failCallback(errCode, errMsg, noTip)
		end
	end
	local function onCancel(ignoreTip)
		if not ignoreTip then 
			CommonTip:showTip(Localization:getInstance():getText("buy.gold.panel.err.undefined"), "negative", nil, 2)
		end
		if cancelCallback then
			cancelCallback()
		end
	end
	if __IOS then -- IOS
		local dcIosInfo = DCIosRmbObject:create()
	    dcIosInfo:setGoodsId(data.productIdentifier)
	    dcIosInfo:setGoodsType(2)
	    dcIosInfo:setGoodsNum(1)
	    dcIosInfo:setRmbPrice(data.iapPrice)
	    PaymentIosDCUtil.getInstance():setIosRmbPayStart(dcIosInfo)

		local peDispatcher = PaymentEventDispatcher.new()
		local function successDcFunc(evt)
			dcIosInfo:setResult(IosRmbPayResult.kSuccess)
        	PaymentIosDCUtil.getInstance():sendIosRmbPayEnd(dcIosInfo)
		end
		local function failedDcFunc(evt)
			local data = evt.data
			local errCode = data.errCode
			local errMsg = data.errMsg
			dcIosInfo:setResult(IosRmbPayResult.kSdkFail, errCode, errMsg)
        	PaymentIosDCUtil.getInstance():sendIosRmbPayEnd(dcIosInfo)
		end
		local function productIdChangeDcFunc(evt)
			PaymentIosDCUtil.getInstance():sendIosProductIdChange(dcIosInfo, evt.data.newProductId)
		end
		peDispatcher:addEventListener(PaymentEvents.kIosBuySuccess, successDcFunc)
		peDispatcher:addEventListener(PaymentEvents.kIosBuyFailed, failedDcFunc)
		peDispatcher:addEventListener(PaymentEvents.kIosProductIdChange, productIdChangeDcFunc)
		IosPayment:buy(data.productIdentifier, data.iapPrice, data.priceLocale, data.id, onSuccess, onFail, peDispatcher)
	elseif __ANDROID then -- ANDROID
		local reBuyCount = 1
		if data and data.reBuyCount then
			reBuyCount = data.reBuyCount
		end
		local logic = IngamePaymentLogic:create(index, GoodsType.kCurrency, self.dcFeature or DcFeatureType.kStore, self.dcSource or DcSourceType.kStoreBuyGold)
		logic:setReBuyCount(reBuyCount)
		logic:ignoreSecondConfirm(true)
		logic:buy(onSuccess, onFail, onCancel)
	elseif __WP8 then
		local logic = Wp8Payment:create(index)
		logic:buy(onSuccess, onFail, onCancel)
	else -- on PC, there is no payment, u should not have come here!
		local http = IngameHttp.new(false)
		http:ad(Events.kComplete, onSuccess)
		http:ad(Events.kError, onFail)
		local tradeId = Localhost:time()
		http:load(index, tradeId, "chinaMobile", 2, nil, tradeId)
	end
end