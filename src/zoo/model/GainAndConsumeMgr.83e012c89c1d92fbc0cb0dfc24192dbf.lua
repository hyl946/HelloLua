require "zoo.common.ItemType"

GainAndConsumeMgr = class()

GoodsType = {
	kItem = 1,
	kCurrency = 2,	
}

MoneyType = {
	kCoin = 1,
	kGold = 2,
	kRmb = 3,
}

local IgnoreItems = {
    ItemType.UNKNOW_1,
    ItemType.STAR_BANK_GOLD,
    ItemType.ENERGY_LIGHTNING,
}

local CurrenyItems = {
	ItemType.COIN,
	ItemType.GOLD,
}

local instance = nil
function GainAndConsumeMgr.getInstance()
	if not instance then
        instance = GainAndConsumeMgr.new()
        instance:init()
    end
    return instance
end

function GainAndConsumeMgr:init()
end

function GainAndConsumeMgr:isIgnoreItem(itemId)
	return table.includes(IgnoreItems, itemId)
end

function GainAndConsumeMgr:isCurrencyItem(itemId)
	return table.includes(CurrenyItems, itemId)
end

function GainAndConsumeMgr:addCoin(addCoinNum)
	UserManager:getInstance():addCoin(addCoinNum)
	UserService:getInstance():addCoin(addCoinNum)
end

function GainAndConsumeMgr:addCash(addCashNum)
	UserManager:getInstance():addCash(addCashNum)
	UserService:getInstance():addCash(addCashNum)
end

function GainAndConsumeMgr:addEnergy(addEnergyNum)
	UserManager:getInstance():addEnergy(addEnergyNum)
	UserService:getInstance():addEnergy(addEnergyNum)
end

function GainAndConsumeMgr:addPropNumber(itemId, deltaNumber)
	if deltaNumber < 0 and ItemType:isTimeProp(itemId) then
		--这里隐含的bug是 限时道具 只能一个一个使用
		UserManager:getInstance():useTimeProp(itemId, deltaNumber)
		UserService:getInstance():useTimeProp(itemId, deltaNumber)
	else
		UserManager:getInstance():addUserPropNumber(itemId, deltaNumber)
		UserService:getInstance():addUserPropNumber(itemId, deltaNumber)
	end
end

function GainAndConsumeMgr:getMoneyType(payType)
	local moneyType = nil
	if payType == DcPayType.kCoin then 
		moneyType = MoneyType.kCoin
	elseif payType == DcPayType.kGold then 
		moneyType = MoneyType.kGold
	elseif payType == DcPayType.kRmb then 
		moneyType = MoneyType.kRmb
	end

	return moneyType
end

function GainAndConsumeMgr:getDcPayType(moneyType)
	local dcPayType = DcPayType.kFree
	if moneyType == MoneyType.kCoin then 
		dcPayType = DcPayType.kCoin
	elseif moneyType == MoneyType.kGold then 
		dcPayType = DcPayType.kGold
	elseif moneyType == MoneyType.kRmb then 
		dcPayType = DcPayType.kRmb
	end

	return dcPayType
end

function GainAndConsumeMgr:dcGainItem(feature, itemId, itemNum, source, levelId, activityId, payType, payValue, goodsId)
	if self:isCurrencyItem(itemId) then
		local currencyType
		if itemId == ItemType.COIN then
			currencyType = DcDataCurrencyType.kCoin
		elseif itemId == ItemType.GOLD then
			currencyType = DcDataCurrencyType.kGold
		end
		local dcBuilder = GameCurrencyDcDataBuilder:createGainBuilder(source, currencyType, itemNum)
		dcBuilder:setFeature(feature):setPayType(payType):setPayValue(payValue):setCurrentStage(levelId):setActivityId(activityId):setSourceGoodsId(goodsId)
		--这个是兼容老版本 bi统计必须字段
		if payType == DcPayType.kCoin then 
			dcBuilder:setCoin(payValue)
		elseif payType == DcPayType.kGold then
			dcBuilder:setHappyCoin(payValue)
		elseif payType == DcPayType.kRmb then
			dcBuilder:setRmb(payValue)
		end
		GameCurrencyDcUtil:logCreateCurrency(dcBuilder:dcData() , levelId)
	else
		local dcBuilder = GameItemDcDataBuilder:create(itemId, itemNum) 
		dcBuilder:setFeature(feature):setPayType(payType):setPayValue(payValue):setSource(source):setCurrentStage(levelId):setActivityId(activityId):setGoodsId(goodsId)
		GameItemDcUtil:logGetItem(dcBuilder:dcData(), levelId)
	end
end

function GainAndConsumeMgr:dcConsumeItem(feature, itemId, itemNum, levelId, activityId, source)
	local dcBuilder = GameItemDcDataBuilder:create(itemId, itemNum) 
 	dcBuilder:setFeature(feature):setCurrentStage(levelId):setActivityId(activityId):setSource(source)

 	if itemId ~= ItemType.INGREDIENT then
	 	local goodsMeta = MetaManager.getInstance():getGoodMetaByItemID(itemId)
	 	if goodsMeta then
	 		local coin = goodsMeta.coin or 0
	 		local happycoin = goodsMeta.qCash or 0
	 		local rmb = goodsMeta.rmb or 0
	 		dcBuilder:setCoin(coin * itemNum):setHappyCoin(happycoin * itemNum):setRmb(rmb * itemNum)
	 	end
	 end

	if GameBoardLogic:getCurrentLogic() then -- 本关引导使用的道具id
		dcBuilder:setTutorialPropId(GameBoardLogic:getCurrentLogic().triggerGuideProp)
	end

	GameItemDcUtil:logUseItem(dcBuilder:dcData() , levelId)
end

function GainAndConsumeMgr:dcConsumeCurrency(feature, currencyType, cost, goodsId, goodsNum, levelId, activityId, source)
	local dcBuilder = GameCurrencyDcDataBuilder:createConsumeBuilder(currencyType, cost)
	if type(goodsId) == "number" then
		local goodsName = DcDataHelper:getGoodsNameById(goodsId)
		dcBuilder:setGoodsName(goodsName)
	end
	dcBuilder:setFeature(feature):setGoodsId(goodsId):setGoodsNum(goodsNum):setCurrentStage(levelId):setActivityId(activityId):setSource(source)
	GameCurrencyDcUtil:logConsumeCurrency(currencyType, dcBuilder:dcData(), levelId)
end
--------------------------------------------以下 为对外接口--------------------------------------------
--要是有道具 无论获取或者消耗 都不想走统一的加减道具和打点 就调用这个接口
function GainAndConsumeMgr:insertIgnoreItem(itemId)
	table.insertIfNotExist(IgnoreItems, itemId)
end

--需计算获得的道具（非GoodsType.kCurrency）价值时 调用此方法
--@param itemList   item的table
--@param payType 	获得道具时所付出代价的类型 详见DcPayType
--@param price 		实际付出的总价格（rmb单位分） 当payType不为DcPayType.kFree时有意义	
function GainAndConsumeMgr:getPayValueCalculator(itemList, price, payType)
	assert(payType ~= DcPayType.kFree, "this is free item")
	local moneyType = self:getMoneyType(payType)
	local calculator = GoodsBagObject:create(itemList, price, moneyType)
	return calculator
end

--@param feature 	发生的场景模块 详见DcFeatureType
--@param itemId 	获得的道具id（金银币或者需要进背包可以被消耗的道具 忽略列表是IgnoreItems 周赛或者活动中特殊加的item如碎片 头像框需要加入忽略列表） 
--@param itemNum 	道具数量
--@param source 	表明来源的详细说明 自定义的字符串 详见DcSourceType 活动请以DcSourceType.kActPre开头
--@param levelId
--@param activityId
--@param payType 	获得道具时所付出代价的类型 详见DcPayType
--@param payValue 	获得道具时所付出代价的数值
function GainAndConsumeMgr:gainItem(feature, itemId, itemNum, source, levelId, activityId, payType, payValue, goodsId)
	if self:isIgnoreItem(itemId) then return end

	if not payType then payType = DcPayType.kFree end
	if not payValue then payValue = 0 end
	if not source then source = "default" end

	self:dcGainItem(feature, itemId, itemNum, source, levelId, activityId, payType, payValue, goodsId)

	if itemId == ItemType.COIN then
	-- 	self:addCoin(itemNum)
	elseif itemId == ItemType.GOLD then
	-- 	self:addCash(itemNum)
	elseif itemId == ItemType.ENERGY_LIGHTNING then
	-- 	self:addEnergy(itemNum)
	elseif ItemType:isItemNeedToBeAdd(itemId) then
	-- 	self:addPropNumber(itemId, itemNum)
	else
		--除了以上四类 其它的获得即是消耗 打一个道具消耗的点
		self:dcConsumeItem(feature, itemId, itemNum, levelId, activityId, source)
	end
end

function GainAndConsumeMgr:gainMultiItems(feature, itemList, source, levelId, activityId, payType, payValue)
	if not payType then payType = DcPayType.kFree end
	if not payValue then payValue = 0 end
	if not source then source = "default" end

	for i,v in ipairs(itemList) do
		if not self:isIgnoreItem(v.itemId) then
			self:gainItem(feature, v.itemId, v.num, source, levelId, activityId, payType, payValue)
		end 
	end
end

--@param feature 	发生的场景模块 详见DcFeatureType
function GainAndConsumeMgr:consumeItem(feature, itemId, itemNum, levelId, activityId, source)
	if self:isIgnoreItem(itemId) then return end

	if not feature then feature = "unknow" end
	-- if not source then source = "default" end
	if not itemNum then itemNum = 1 end

	self:dcConsumeItem(feature, itemId, itemNum, levelId, activityId, source)
	-- self:addPropNumber(itemId, -itemNum)
end

--@param feature 	发生的场景模块 详见DcFeatureType
--@param currencyType 	消耗的货币类型 详见DcDataCurrencyType
function GainAndConsumeMgr:consumeCurrency(feature, currencyType, cost, goodsId, goodsNum, levelId, activityId, source)
	if not feature then feature = "unknow" end
	-- if not source then source = "default" end

	self:dcConsumeCurrency(feature, currencyType, cost, goodsId, goodsNum, levelId, activityId, source)

	GamePlayContext:getInstance():onBuyProp( feature, currencyType, cost, goodsId, goodsNum, levelId, activityId, source )

	if currencyType == DcDataCurrencyType.kCoin then
		Notify:dispatch("AchiEventDataUpdate",AchiDataType.kUseCoinAddCount, cost)
		-- self:addCoin(-cost)
	elseif currencyType == DcDataCurrencyType.kGold then
		Notify:dispatch("AchiEventDataUpdate",AchiDataType.kUseWindmillAddCount, cost)
		-- self:addCash(-cost)
	end
end