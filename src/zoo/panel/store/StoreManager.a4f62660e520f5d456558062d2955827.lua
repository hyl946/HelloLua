require 'zoo.panel.store.views.StoreTip'

_G.StoreManager = class()


StoreManager.EnterFlag = {
	kEndGamePanelDiscount5Step = 1,
	kEndGamePanel2Step = 2,
}

function StoreManager:isEnabled( ... )
	return require('zoo.panel.store.StoreSwitch'):isEnabled()
end

function StoreManager:safeIsEnabled( ... )
	if StoreManager:getInstance() then
		return StoreManager:getInstance():isEnabled()
	end
	return false
end

local instance 

function StoreManager:createInstance( ... )
	if not instance then
		instance = StoreManager.new()
		require 'zoo.panel.store.BuyGoodsLogic'
	end
end

function StoreManager:getInstance( ... )
	return instance
end

local storePanelInstance

function StoreManager:createStorePanel( ... )
	storePanelInstance = require('zoo.panel.store.StorePanel'):create()
	return storePanelInstance
end

function StoreManager:getPanelInstance( ... )
	return storePanelInstance
end

function StoreManager:loadIosProductInfo( successCallback, failCallback )

	local loadingAnimation
	local hadCancel

	local function onSuccess( ... )
		if hadCancel then return end
		if successCallback then successCallback() end
		if loadingAnimation then
			loadingAnimation:removeFromParentAndCleanup(true)
		end
	end

	local function onFail( ... )
		if hadCancel then return end
		if failCallback then failCallback() end
		if loadingAnimation then
			loadingAnimation:removeFromParentAndCleanup(true)
		end
	end



	if self._loaded then 
		if onSuccess then onSuccess() end
		return
	end

	self.iapConfig = {}
	self._loaded = true


	loadingAnimation = CountDownAnimation:createNetworkAnimation(
		Director:sharedDirector():getRunningScene(), 
		function()
			loadingAnimation:removeFromParentAndCleanup(true)
			onFail()
			hadCancel = true
		end,
		localize("")
	)

	if __WIN32 then
		if onSuccess then onSuccess() end
		return
	end

	if not __IOS then return end


	local promotionList = {
		['1'] = 'com.happyelements.animal.gold.cn.41',
		['2'] = 'com.happyelements.animal.gold.cn.42',
		['3'] = 'com.happyelements.animal.gold.cn.43',
		['4'] = 'com.happyelements.animal.gold.cn.44',
		['5'] = 'com.happyelements.animal.gold.cn.45',
		['6'] = 'com.happyelements.animal.gold.cn.51',
	}

	local giftList = {}
	local metaMgr = MetaManager:getInstance()
	local index = 0
	for _, goodsId in ipairs(_G.StoreConfig.GiftGoodsIds) do
		local productMeta = metaMgr:getProductMetaByGoodsId(goodsId)
		if productMeta and productMeta.productId and #(productMeta.productId) > 0 then
			index = index + 1
			giftList[tostring(index)] = productMeta.productId
		end
	end

	local starBankList = {
		['1'] = 'com.happyelements.animal.gold.cn.67',
		['2'] = 'com.happyelements.animal.gold.cn.68',
		['3'] = 'com.happyelements.animal.gold.cn.69',
		['4'] = 'com.happyelements.animal.gold.cn.70',
		['5'] = 'com.happyelements.animal.gold.cn.71',
		['6'] = 'com.happyelements.animal.gold.cn.73',
		['7'] = 'com.happyelements.animal.gold.cn.106',
		['8'] = 'com.happyelements.animal.gold.cn.107',
	}

	local serverConfigList = {
		['1'] = 'com.happyelements.animal.gold.cn.113',
	}


	index = 0
	local goldList = {}
	for _, v in pairs(metaMgr.product) do
		if v.showCode == 2 and v.productId and #(v.productId) > 0 then
			index = index + 1
			goldList[tostring(index)] = v.productId
		end
	end


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

	local list = {}

	list = unionList(list, giftList)
	list = unionList(list, starBankList)
	list = unionList(list, promotionList)
	list = unionList(list, serverConfigList)
	list = unionList(list, goldList)

	self:_askAppStore(list, onSuccess, onFail)

end

function StoreManager:_askAppStore( list, onSuccess, onFail )

	local hadTimeOut = false
	local timer

	IosPayment:showPayment(list, function ( iapConfig )
		if hadTimeOut then return end
		for key, value in pairs(iapConfig) do
			table.insert(self.iapConfig, value)
		end
		if onSuccess then onSuccess() end

		if timer then
			cancelTimeOut(timer)
			timer = nil
		end

	end, function ( ... )
		if hadTimeOut then return end
		if onFail then onFail() end
		if timer then
			cancelTimeOut(timer)
			timer = nil
		end
	end)

	timer = setTimeOut(function ( ... )
		hadTimeOut = true
		if onFail then onFail() end
	end, 20)

end

function StoreManager:getIosProductInfoByGoodsId( goodsId )
	local metaMgr = MetaManager:getInstance()
	local productMeta = metaMgr:getProductMetaByGoodsId(goodsId)
	if productMeta then
		return self:getIosProductInfoByProductMeta(productMeta)
	end
end


function StoreManager:getIosProductInfoByProductMeta( productMeta )
	for _, v in ipairs(self.iapConfig) do
		if v.productIdentifier == productMeta.productId then
			return {
				iapPrice = v.iapPrice,
				priceLocale = v.priceLocale,
				productIdentifier = v.productIdentifier,
			}
		end
	end

	return {
		iapPrice = productMeta.price,
		priceLocale = "CNY",
		productIdentifier = productMeta.productId,
	}
end

function StoreManager:getAndroidGoodsPrice( goodsIdInfo )
	if goodsIdInfo:getGoodsType() == GoodsType.kCurrency then
		local meta = MetaManager:getInstance():getProductAndroidMeta(goodsIdInfo:getGoodsId())
		if meta and meta.rmb then
			return (tonumber(meta.rmb) or 0) / 100
		end
	elseif goodsIdInfo:getGoodsType() == GoodsType.kItem then
		local goodsMeta = MetaManager:getInstance():getGoodMeta(goodsIdInfo:getGoodsId())
		return tonumber(goodsMeta.thirdRmb) / 100
	else
		return 0
	end
end


-- [RemoteDebug] {
--   1 = {
--     proudctPrice = "¥1.00",
--     iapPrice = 1,
--     priceLocale = "CNY",
--     proudctDescription = "在风车币商店中购买100个风车币。点击右上角第二个金色风车币泡泡可以进入风车币商店，风车币可以用于在游戏中购买游戏道具。",
--     productIdentifier = "com.happyelements.animal.gold.cn.45",
--     productTitle = "100风车币特惠购",
--   },
--   2 = {
--     proudctPrice = "¥128.00",
--     iapPrice = 128,
--     priceLocale = "CNY",
--     proudctDescription = "含1600风车币、2个加5步、1个魔法棒、4个中级精力瓶。风车币可在道具商店购买道具。加5步可将剩余步数加5。魔法棒可将任一障碍或动物变成直线特效。中级精力瓶可补充精力。",
--     productIdentifier = "com.happyelements.animal.gold.cn.44",
--     productTitle = "128元风车币礼包",
--   },
--   3 = {
--     proudctPrice = "¥30.00",
--     iapPrice = 30,
--     priceLocale = "CNY",
--     proudctDescription = "在风车币商店购买340个风车币。",
--     productIdentifier = "com.happyelements.animal.gold.cn.51",
--     productTitle = "30元权益礼包",
--   },
--   4 = {
--     proudctPrice = "¥30.00",
--     iapPrice = 30,
--     priceLocale = "CNY",
--     proudctDescription = "含360风车币、1个魔法棒、1个爆炸直线、2个中级精力瓶。风车币在商店购买道具。魔法棒可将任1动物变为直线特效。爆炸直线可在关卡内生成1个爆炸和1个直线特效。中级精力瓶可补充精力。",
--     productIdentifier = "com.happyelements.animal.gold.cn.43",
--     productTitle = "30元风车币礼包",
--   },
--   5 = {
--     proudctPrice = "¥12.00",
--     iapPrice = 12,
--     priceLocale = "CNY",
--     proudctDescription = "含150风车币、1个加5步、1个中级精力瓶。风车币可用于在道具商店购买道具。加5步可将剩余步数加5。中级精力瓶可补充精力。在“风车币商店”中购买此商品。",
--     productIdentifier = "com.happyelements.animal.gold.cn.42",
--     productTitle = "12元风车币礼包",
--   },
--   6 = {
--     proudctPrice = "¥3.00",
--     iapPrice = 3,
--     priceLocale = "CNY",
--     proudctDescription = "含40风车币、1个小木槌、1个爆炸直线，1个中级精力瓶。风车币用于道具商店购买道具。小木槌可消除障碍、动物1次。爆炸直线可在关卡内生成1个爆炸和1个直线特效。中级精力瓶可补充精力",
--     productIdentifier = "com.happyelements.animal.gold.cn.41",
--     productTitle = "3元礼包",
--   },
-- }

return StoreManager