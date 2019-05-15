


BuyLogic = class()

function BuyLogic:create(goodsId, moneyType, feature, source, targetId)
	local logic = BuyLogic.new()
	if logic:init(goodsId, moneyType, feature, source, targetId) then
		return logic
	else
		logic = nil
		return nil
	end
end

function BuyLogic:init(goodsId, moneyType, feature, source, targetId)
	if moneyType ~= MoneyType.kCoin and moneyType ~= MoneyType.kGold then return false end

	local meta = MetaManager:getInstance():getGoodMeta(goodsId)
	local user = UserManager:getInstance().user
	self.items = {}
	for __, v in ipairs(meta.items) do table.insert(self.items, {itemId = v.itemId, num = v.num}) end
	self.goodsId = goodsId
	self.meta = meta
	self.moneyType = moneyType
	self.user = user
	self.feature = feature
	self.source = source
	self.targetId = targetId or goodsId

	local stageInfo = StageInfoLocalLogic:getStageInfo( user.uid );
	self.levelId = -1
	if stageInfo then
		self.levelId = stageInfo.levelId
	end

	return true
end

function BuyLogic:setFeatureAndSource(feature, source)
	self.feature = feature
	self.source = source
end

function BuyLogic:setActivityId(activityId)
	self.activityId = activityId
end

-- 返回值：实际价格（可能是折扣价，0即为不可买），可买最高数量（仅与限购相关），折扣前价格（如果折扣了的话）
-- 实际价格为0表示出错，不考虑另外的返回值；可买数量为-1表示不限购买数量；折扣前价格为0表示当前就是原价
function BuyLogic:getPrice()
	local num = UserManager:getInstance():getDailyBoughtGoodsNumById(self.goodsId)

	local realPrice = 0
	local buyLimit = 0
	local originalPrice = 0

	if self.moneyType == MoneyType.kCoin then 
		realPrice = self.meta.coin
		buyLimit = -1 
		originalPrice = 0
	elseif self.moneyType == MoneyType.kGold then

		if self.meta.discountQCash ~= 0 then -- 打折
			realPrice = self.meta.discountQCash
			originalPrice = self.meta.qCash
		else
			realPrice = self.meta.qCash
			originalPrice = 0
		end
		if self.meta.limit == 0 then
			buyLimit = -1
		else 
			if num >= self.meta.limit then
				buyLimit = 0
			else
				buyLimit = self.meta.limit - num
			end
		end
	end
	self.price = realPrice
	return realPrice, buyLimit, originalPrice


	-- if self.moneyType == 1 then -- 银币
	-- 	self.price = self.meta.coin -- 银币没有折扣和限购
	-- 	return self.price, -1, 0
	-- elseif self.moneyType == 2 then -- 金币
	-- 	if self.meta.discountQCash ~= 0 then
	-- 		if self.meta.limit == 0 then -- 折扣且不限购
	-- 			self.price = self.meta.discountQCash
	-- 			return self.price, -1, self.meta.qCash
	-- 		elseif num >= self.meta.limit then -- 折扣但限购数量用完了，不能买
	-- 			self.price = self.meta.discountQCash
	-- 			return self.price, 0, self.meta.qCash
	-- 		else
	-- 			self.price = self.meta.discountQCash
	-- 			return self.price, self.meta.limit - num, self.meta.qCash
	-- 		end
	-- 	else
	-- 		self.price = self.meta.qCash
	-- 		return self.price, -1, 0
	-- 	end
	-- else
	-- 	return 0
	-- end
end

-- static function
function BuyLogic:getDiscountPercentageForDisplay(original, discounted)
	local real = math.floor(100 * discounted / original)
	local level = 10 -- discount level: 95, 90, 85, 80
	local result = math.ceil(real / level) * level 
	if result % 10 == 0 then 
		if result == 100 then return 9 end
		return result / 10  -- 9 zhe, 8 zhe
	else
		return result -- 95 zhe, 85 zhe
	end
end

function BuyLogic:setCancelCallback(cancelCallback)
	self.cancelCallback = cancelCallback
end

function BuyLogic:__checkMoneyEnough(num, successCallback, failCallback, load, price)
	if PrepackageUtil:isPreNoNetWork() and self.moneyType == MoneyType.kGold then
		PrepackageUtil:showInGameDialog()
		return 
	end
	
	local event = {}
	local money = self.user:getCash()
	if self.moneyType == MoneyType.kCoin then money = self.user:getCoin() end
	self.num = num
	if price then self.price = price end
	if _G.isLocalDevelopMode then printx(0, "self.price, self.num", self.price, self.num) end
	if not self:energyLimitItem(self.goodsId) and money < self.price * self.num then
		local errorCode = nil
		if self.moneyType == MoneyType.kCoin then 
			errorCode = 730321		-- 银币不够
		elseif self.moneyType == MoneyType.kGold then 
			errorCode = 730330 
		end		-- 金币不够
		if failCallback then failCallback(errorCode) end
		return
	end

	if successCallback then successCallback() end
end

function BuyLogic:__start(num, successCallback, failCallback, load, price, online)

	local list
	local function onSuccess(evt)
		evt.target:removeAllEventListeners()
		self:updatePropCount()
		if successCallback then
			successCallback(evt.data)
		end
	end
	local function onFail(evt)
		evt.target:removeAllEventListeners()
		if failCallback then
			failCallback(evt.data)
		end
	end
	local function onCancel(evt)
		evt.target:removeAllEventListeners()
		if self.cancelCallback then
			self.cancelCallback()
		end
	end
	if load ~= false or online then 
		load = true 
	end

	if online then 
        local http = BuyHttpOnline.new(load)
	    http:ad(Events.kComplete, onSuccess)
	    http:ad(Events.kCancel, onCancel)
	    http:ad(Events.kError, onFail)
		http:syncLoad(self.goodsId, self.num, self.moneyType, self.targetId)
	else
        local http = BuyHttp.new(load)
	    http:ad(Events.kComplete, onSuccess)
	    http:ad(Events.kCancel, onCancel)
	    http:ad(Events.kError, onFail)
		http:load(self.goodsId, self.num, self.moneyType, self.targetId)
	end
end

function BuyLogic:start(num, successCallback, failCallback, load, price, online)
	if self.moneyType == MoneyType.kGold then
		self:__checkMoneyEnough(num, function ( ... )
			RealNameManager:checkOnPay(function ( ... )
				self:__start(num, successCallback, failCallback, load, price, online)
			end, failCallback)
		end, failCallback, load, price)
	else
		self:__checkMoneyEnough(num, function ( ... )
			self:__start(num, successCallback, failCallback, load, price, online)
		end, failCallback, load, price)
	end
end

function BuyLogic:energyLimitItem(goodsId)
	return goodsId == 70 
end

function BuyLogic:updatePropCount()
	if _G.isLocalDevelopMode then printx(0, "BuyLogic:updatePropCount") end

	-- 扣钱
	local dcPayType = GainAndConsumeMgr.getInstance():getDcPayType(self.moneyType)
	local valueCalculator = GainAndConsumeMgr.getInstance():getPayValueCalculator(self.items, self.price, dcPayType)
	if self.moneyType == MoneyType.kCoin then
		UserManager:getInstance():addCoin(-self.price * self.num)
		GainAndConsumeMgr.getInstance():consumeCurrency(self.feature, DcDataCurrencyType.kCoin, self.price, self.goodsId, self.num, self.levelId, self.activityId, self.source)
	elseif self.moneyType == MoneyType.kGold then
		UserManager:getInstance():addCash(-self.price * self.num)
		GainAndConsumeMgr.getInstance():consumeCurrency(self.feature, DcDataCurrencyType.kGold, self.price, self.goodsId, self.num, self.levelId, self.activityId, self.source)
	end

	for __,v in ipairs(self.items) do
		if v.itemId ~= ItemType.ENERGY_LIGHTNING then
			local value = valueCalculator:getItemSellPrice(v.itemId)
			if v.itemId == ItemType.COIN then
				UserManager:getInstance():addCoin(v.num * self.num, true)
			elseif ItemType:isItemNeedToBeAdd(v.itemId) then
				UserManager:getInstance():addUserPropNumber(v.itemId, v.num * self.num)
			end
			GainAndConsumeMgr.getInstance():gainItem(self.feature, v.itemId, v.num * self.num, self.source, self.levelId, self.activityId, dcPayType, value * self.num, self.goodsId)
		end
	end

	-- 更新本日购买列表
	if _G.isLocalDevelopMode then printx(0, "Update buyed list") end
	local meta = MetaManager:getInstance():getGoodMeta(self.goodsId)
	if meta and meta.limit > 0 then
		UserManager:getInstance():addBuyedGoods(self.goodsId, self.num)
	end
end

function BuyLogic:itemsNotToBeAdded(itemId)
	local itemType = math.floor(itemId / 10000)
	if _G.isLocalDevelopMode then printx(0, "itemType = ", itemType) end
	if itemType == 1 then return false end
	return true
end