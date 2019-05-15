local IosGuideModel = class()

local MIN_INTERVAL = 20 * 24 * 3600 * 1000 

local configPath = HeResPathUtils:getUserDataPath() .. '/ios_pay_guide_config_'..(UserManager:getInstance().uid or '0')
local forcePopKey = "ios.sales.promotion.pop"

local function readConfig()
	local _config = {}

    local file = io.open(configPath, "r")
    if file then
        local data = file:read("*a") 
        file:close()
        if data then
            _config = table.deserialize(data) or {}
        end
    end
    return _config
end

local function writeConfig(data)
    local file = io.open(configPath,"w")
    if file then 
        file:write(table.serialize(data or {}))
        file:close()
    end
end

local __model = nil

function IosGuideModel:create()
	if not __model then
		__model = IosGuideModel.new()
	end

	return __model
end

function IosGuideModel:ctor()
	self.oneYuanPropInfo = {}
	self.oneYuanFCashInfo = {}
end

local function getPromotionInfoByType(type, rawData)
	for __,v in ipairs(rawData) do
		if tonumber(v.type) == type then
			return v
		end
	end
end

function IosGuideModel:serialize()
	local oneYuanPromotionInfo = {self.oneYuanPropInfo, self.oneYuanFCashInfo}
	writeConfig(oneYuanPromotionInfo)
end

function IosGuideModel:deserialize()
	local info = readConfig()
	
	self:initPromotionInfo(info)
end

function IosGuideModel:getOneYuanShopProductID()
	return self.oneYuanPropInfo.productId or 0
end

function IosGuideModel:getOneYuanShopEndTime()
	return tonumber(self.oneYuanPropInfo.endTime) or 0
end

function IosGuideModel:getOneYuanShopPrice()
	return tonumber(self.oneYuanPropInfo.originPrice) or 0
end

function IosGuideModel:getOneYuanShopType()
	return tonumber(self.oneYuanPropInfo.type) or 0
end

function IosGuideModel:getFCashEndTime()
	return tonumber(self.oneYuanFCashInfo.endTime) or 0
end

function IosGuideModel:getPromotionLevel()
	return self.promotionLevel or 0
end

function IosGuideModel:isInFCashPromotion()
	local lastOccurTime = tonumber(self.oneYuanFCashInfo.lastOccurTime) or 0

	local now = Localhost:time()
	return now >lastOccurTime and now < self:getFCashEndTime() and not self.oneYuanFCashInfo.bought
end

function IosGuideModel:isInOneYuanShopPromotion()
	local lastOccurTime = tonumber(self.oneYuanPropInfo.lastOccurTime) or 0

	local now = Localhost:time()
	if _G.isLocalDevelopMode then printx(0, "#########################now: ", now, ", endtime:", self:getOneYuanShopEndTime(), now < self:getOneYuanShopEndTime()) end
	return now >lastOccurTime and now < self:getOneYuanShopEndTime() and not self.oneYuanPropInfo.bought
end

function IosGuideModel:hasTriggeredFCash()
    local now = Localhost:time()
    local lastOccurTime = self.oneYuanFCashInfo.lastOccurTime or 0

    return now - lastOccurTime < MIN_INTERVAL
end

function IosGuideModel:hasTriggeredOneYuanShop()
    local now = Localhost:time()
    local lastOccurTime = self.oneYuanPropInfo.lastOccurTime or 0

    return now - lastOccurTime < MIN_INTERVAL
end

function IosGuideModel:getOneYuanFCashLeftSeconds()
	local seconds = self:getFCashEndTime() - Localhost:time()
	return seconds < 0 and 0 or seconds/1000
end

function IosGuideModel:getOneYuanShopLeftSeconds()
	local seconds = self:getOneYuanShopEndTime() - Localhost:time()
	return seconds < 0 and 0 or seconds/1000
end

function IosGuideModel:getFailGuidePopped()
	return CCUserDefault:sharedUserDefault():getBoolForKey("ios.failed.guide.popped", false)
end

function IosGuideModel:setFailGuidePopped()
	CCUserDefault:sharedUserDefault():setBoolForKey("ios.failed.guide.popped", true)
end

function IosGuideModel:loadPromotionInfo(completeCallback, errorCallback, needLoading)
	local function onRequestFinish(evt)
		local promotions = evt.data and evt.data.promotions or {}
	 	self.promotionLevel = evt.data and evt.data.layerIndex
		self:initPromotionInfo(promotions)
		self:serialize()

		if completeCallback then completeCallback() end
	end

	local function onRequestError(evt)
		self:deserialize()

		if errorCallback then
			errorCallback()
		else
			if completeCallback then completeCallback() end
		end
	end

	local http = GetIosOneYuanPromotionInitInfo.new(needLoading)
    http:addEventListener(Events.kComplete, onRequestFinish)
	http:addEventListener(Events.kError, onRequestError)
    http:syncLoad()
end

function IosGuideModel:initPromotionInfo(promotions)
	local propPromotionInfo = nil
	local tempPromotionType = nil
	for k,v in pairs(IosOneYuanPromotionType) do
		if v == IosOneYuanPromotionType.OneYuanFCash then 
			self.oneYuanFCashInfo = getPromotionInfoByType(IosOneYuanPromotionType.OneYuanFCash, promotions) or {}
		else
			--ios道具购买促销 因为版本兼容问题 要特殊处理:如果同时收到多条道具促销信息 只取type最大的来处理
			local tempPromotionInfo = getPromotionInfoByType(v, promotions)
			if tempPromotionInfo then 
				if not propPromotionInfo then 
					propPromotionInfo = tempPromotionInfo
					tempPromotionType = v
				elseif tempPromotionType and v > tempPromotionType then
					propPromotionInfo = tempPromotionInfo
					tempPromotionType = v
				end
			end
		end
	end
	self.oneYuanPropInfo = propPromotionInfo or {}
end

function IosGuideModel:dcForTriggerSuccess(promotionType)
	local dcType = nil
	local dcGrade = nil
	local dcGoodsId = nil
	if promotionType == IosOneYuanPromotionType.OneYuanFCash then
		dcType = 2
	else
		dcType = 1
		local promotionRef = self:getOneYuanShopProductInfo()
		if promotionRef then 
			dcGrade = promotionRef.pLevel 
			dcGoodsId = promotionRef.goodsId
		end
	end

	local dc_data = {
		sub_category = "ios_rmb_promotion",
		type = dcType,
		grade = dcGrade,
		goods_id = dcGoodsId,	
	}
	DcUtil:activity(dc_data)
end

function IosGuideModel:triggerPromotion(promotionType, completeCallback, errorCallback)
	local function onRequestFinish(evt)
		local promotion = evt.data and evt.data.promotion or {}
		if promotionType == IosOneYuanPromotionType.OneYuanFCash then
			self.oneYuanFCashInfo = promotion or {}
		else
			self.oneYuanPropInfo = promotion or {}
		end
		self:serialize()
		self:dcForTriggerSuccess(promotionType)
		if completeCallback then completeCallback() end
	end

	local function onRequestError(evt)
		if errorCallback then
			errorCallback()
		end
	end
	--请求新的道具促销时 重置强弹的本地标识
	IosGuideModel:cleanSecondDayPop()

	local http = TriggerIosOneYuanPromotion.new()
    http:addEventListener(Events.kComplete, onRequestFinish)
	http:addEventListener(Events.kError, onRequestError)
    http:syncLoad(promotionType)
end

function IosGuideModel:oneYuanFCashBought()
	self.oneYuanFCashInfo.bought = true
	self:serialize()
end

function IosGuideModel:oneYuanPropBought()
	self.oneYuanPropInfo.bought = true
	self:serialize()
end

function IosGuideModel:resetOneYuanShop(completeCallback, failedCallback)
	local function onRequestFinish(evt)
		local promotion = evt.data and evt.data.promotion or {}
		self.oneYuanPropInfo = promotion or {}

		self:serialize()
		if completeCallback then completeCallback() end
	end

	local function onRequestError(evt)
		CommonTip:showTip("重置道具失败，请重试！","negative")
		if failedCallback then failedCallback() end
	end

	local http = ResetIosOneYuanShop.new()
    http:addEventListener(Events.kComplete, onRequestFinish)
	http:addEventListener(Events.kError, onRequestError)
    http:syncLoad()
end

local function getDayStartTimeByTS(ts)
	local utc8TimeOffset = 57600 -- (24 - 8) * 3600
	local oneDaySeconds = 86400 -- 24 * 3600
	return ts - ((ts - utc8TimeOffset) % oneDaySeconds)
end

local function now()
	return os.time() + (__g_utcDiffSeconds or 0)
end

function IosGuideModel:getNeedSecondDayPop()
	local hasForcePop = CCUserDefault:sharedUserDefault():getBoolForKey(forcePopKey)
	if not hasForcePop then 
		local popEndTime = self:getOneYuanShopEndTime()
		if popEndTime and popEndTime > 0 then 
			local nowDay = getDayStartTimeByTS(now())
			local endDay = getDayStartTimeByTS(popEndTime/1000)
			if nowDay == endDay then 
				CCUserDefault:sharedUserDefault():setBoolForKey(forcePopKey, true)
				CCUserDefault:sharedUserDefault():flush()
				return true
			end
		end
	end
	return false
end

function IosGuideModel:cleanSecondDayPop()
	CCUserDefault:sharedUserDefault():setBoolForKey(forcePopKey, false)
	CCUserDefault:sharedUserDefault():flush()
end

function IosGuideModel:getOneYuanShopProductInfo()
	local oneYuanShopPID = self:getOneYuanShopProductID()

	local ret
	local product
	for k, v in ipairs(MetaManager:getInstance().product) do
		if v.id == oneYuanShopPID then product = v end
	end
	if product then 
		local meta = MetaManager:getInstance():getGoodMeta(product.goodsId)
		local pConfig = IosSalesManager:getPromitonConfigById(oneYuanShopPID)
		if pConfig then 
			ret = {id = product.id, price = product.price, items = getMetaItems(meta.items), goodsId = product.goodsId,
					productIdentifier = product.productId, iapPrice = product.price, priceLocale = "CNY", discount = product.discount, 
					oriPrice = pConfig.oriPrice, pLevel = pConfig.pLevel}
		else
			ret = {id = product.id, price = product.price, items = getMetaItems(meta.items), goodsId = product.goodsId,
					productIdentifier = product.productId, iapPrice = product.price, priceLocale = "CNY", discount = product.discount}
		end
	end
	return ret
end

return IosGuideModel

