-- @Author: dan.liang
-- @Date:   2016-05-31 11:16:54
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   dan.liang
-- @Last Modified time: 2019-01-29 19:31:05

require "hecore.class"
require "zoo.util.DcUtil"
require "zoo.dc.DcDataHelper"

local function getCurrencyName(currencyType)
	local category = nil
	if currencyType == DcDataCurrencyType.kCoin then
		category = "coin"
	elseif currencyType == DcDataCurrencyType.kGold then
		category = "happy coin"								--原报表无人维护 这个字段不改了
	elseif currencyType == DcDataCurrencyType.kRmb then
		category = "rmb"
	else
		category = "unknown_currency"
		assert(false, "undefined currency type:"..tostring(currencyType))
	end
	return category
end

GameCurrencyDcDataBuilder = class()

function GameCurrencyDcDataBuilder:ctor()
	self._dcData = {}
end

function GameCurrencyDcDataBuilder:createConsumeBuilder(currencyType, cost)
	local builder = GameCurrencyDcDataBuilder.new()
	builder:initConsumeData(currencyType, cost)
	return builder
end

function GameCurrencyDcDataBuilder:createGainBuilder(source, currencyType, amount)
	local builder = GameCurrencyDcDataBuilder.new()
	builder:initGainData(source, currencyType, amount)
	return builder
end

function GameCurrencyDcDataBuilder:initConsumeData(currencyType, cost)
	self._dcData = {
		feature = nil,
		item_id = nil,
		item_name = nil,
		cost = nil,
		allcost = nil,
		num = nil,
		total_num = nil,
		current_stage = nil,
		meta_level_id = nil,
		high_stage = nil,
		stage_mode = nil,
		activity_id = nil,
		source = nil,
	}
	self:init()
	self:setCostAmount(cost)
	if currencyType == DcDataCurrencyType.kCoin then
		self:setTotalNum(UserManager:getInstance().user:getCoin())
	elseif currencyType == DcDataCurrencyType.kGold then
		self:setTotalNum(UserManager:getInstance().user:getCash())
	end
end

function GameCurrencyDcDataBuilder:initGainData(source, currencyType, amount)
	self._dcData = {
		feature = nil,
		pay_type = nil,
		pay_value = nil,
		source = nil,
		currency = nil,
		num = nil,
		total_num = nil,
		current_stage = nil,
		meta_level_id = nil,
		high_stage = nil,
		stage_mode = nil,
		activity_id = nil,

		value_happycoin = nil,
		value_rmb = nil,
	}
	self:init()
	self:setSource(source):setCurrency(currencyType):setGainAmount(amount)
	if currencyType == DcDataCurrencyType.kCoin then
		self:setTotalNum(UserManager:getInstance().user:getCoin())
	elseif currencyType == DcDataCurrencyType.kGold then
		self:setTotalNum(UserManager:getInstance().user:getCash())
	end
end

function GameCurrencyDcDataBuilder:init()
	self:setHighStage(UserManager:getInstance().user:getTopLevelId()) 
	self:setStageMode(DcDataStageMode.kNotInLevel)
end

function GameCurrencyDcDataBuilder:setFeature(feature)
	self._dcData.feature = feature
	return self
end

function GameCurrencyDcDataBuilder:setPayType(payType)
	self._dcData.pay_type = payType
	return self
end

function GameCurrencyDcDataBuilder:setPayValue(payValue)
	self._dcData.pay_value = payValue
	return self
end

function GameCurrencyDcDataBuilder:setSource(source)
	self._dcData.source = source
	return self
end

function GameCurrencyDcDataBuilder:setCurrency(currencyType)
	if currencyType then
		self._dcData.currency = getCurrencyName(currencyType)
	end
	return self
end

function GameCurrencyDcDataBuilder:setHappyCoin(happycoin)
	self._dcData.value_happycoin = happycoin
	return self
end

function GameCurrencyDcDataBuilder:setGainAmount(amount)
	self._dcData.num = amount
	return self
end

function GameCurrencyDcDataBuilder:setCostAmount(amount)
	self._dcData.cost = amount
	return self
end

function GameCurrencyDcDataBuilder:setRmb(rmb)
	self._dcData.value_rmb = rmb
	return self
end

function GameCurrencyDcDataBuilder:setActivityId(actId)
	self._dcData.activity_id = actId
	return self
end

function GameCurrencyDcDataBuilder:setGoodsId(goodsId)
	self._dcData.item_id = goodsId
	return self
end

function GameCurrencyDcDataBuilder:setSourceGoodsId(goodsId)
	self._dcData.goodsId = goodsId
	return self
end

function GameCurrencyDcDataBuilder:setGoodsName(goodsName)
	self._dcData.item_name = goodsName
	return self
end

function GameCurrencyDcDataBuilder:setGoodsNum(num)
	self._dcData.num = num
	if self._dcData.cost then
		local _num = num or 1 
		self._dcData.allcost = self._dcData.cost * _num
	end
	return self
end

function GameCurrencyDcDataBuilder:setTotalNum(totalNum)
	self._dcData.total_num = totalNum
	return self
end

function GameCurrencyDcDataBuilder:setValueForKey(key, value)
	self._dcData[key] = value
	return self
end

function GameCurrencyDcDataBuilder:setCurrentStage(currentStage)
	if type(currentStage) == "number" and currentStage > 0 then
		self._dcData.current_stage = currentStage
		self._dcData.meta_level_id = LevelMapManager.getInstance():getMetaLevelId(currentStage)
		local stageMode = DcDataHelper:getStageModeByLevelId(currentStage)
		self:setStageMode(stageMode)
	end
	return self
end

function GameCurrencyDcDataBuilder:setStageMode(stageMode)
	self._dcData.stage_mode = stageMode
	return self
end

function GameCurrencyDcDataBuilder:setHighStage(highStage)
	self._dcData.high_stage = highStage
	return self
end

function GameCurrencyDcDataBuilder:dcData()
	return self._dcData
end

------------------------------- GameCurrencyDcUtil -------------------------------

GameCurrencyDcUtil = {}

function GameCurrencyDcUtil:sendDcData(acType, category, subCategry, dcData)
	local data = {}
	data.category = category
	data.sub_category = subCategry
	for k, v in pairs(dcData) do
		data[k] = v
	end
	-- mylog("sendDcData:", table.tostring(data))
	DcUtil:log(acType, data)
end

function GameCurrencyDcUtil:logCreateCurrency(dcData , levelId)
	dcData.playId = UserContext:getCurrPlayId() --GamePlayContext:getInstance():getIdStr()
	dcData.playInfo = GamePlayContext:getInstance():getPlayInfoDCStr()
	dcData.stage_state = DcUtil:tryGetStageState( levelId )
	GameCurrencyDcUtil:sendDcData(AcType.kCreateCoin, "currency", "create", dcData)
end

function GameCurrencyDcUtil:logConsumeCurrency(currencyType, dcData , levelId)
	local category = getCurrencyName(currencyType)

	dcData.playId = UserContext:getCurrPlayId() --GamePlayContext:getInstance():getIdStr()
	dcData.playInfo = GamePlayContext:getInstance():getPlayInfoDCStr()
	dcData.stage_state = DcUtil:tryGetStageState( levelId )
	GameCurrencyDcUtil:sendDcData(AcType.kVirtualGoods, category, "consume", dcData)
end

function GameCurrencyDcUtil:dcBuyCurrency(buyCurrencyType, buyNum, costCurrencyType, costNum, levelId)
	local source = nil
	if costCurrencyType == DcDataCurrencyType.kGold then
		source = "buy_gold"
	elseif costCurrencyType == DcDataCurrencyType.kRmb then
		source = "buy_rmb"
	elseif costCurrencyType == DcDataCurrencyType.kCoin then
		source = "buy_coin"
	end

	local builder = GameCurrencyDcDataBuilder:createGainBuilder(source, buyCurrencyType, buyNum)
	if costCurrencyType == DcDataCurrencyType.kGold then
		builder:setHappyCoin(costNum)
	elseif costCurrencyType == DcDataCurrencyType.kRmb then
		builder:setRmb(costNum)
	end
	builder:setCurrentStage(levelId)
	GameCurrencyDcUtil:logCreateCurrency(builder:dcData() , levelId)
end

function GameCurrencyDcUtil:dcCreateCurrency(source, currencyType, num, levelId, activityId)
	local builder = GameCurrencyDcDataBuilder:createGainBuilder(source, currencyType, num)
	builder:setCurrentStage(levelId):setActivityId(activityId)
	GameCurrencyDcUtil:logCreateCurrency(builder:dcData() , levelId)
end

function GameCurrencyDcUtil:dcConsumeCurrency(feature, currencyType, cost, goodsId, goodsNum, levelId, activityId)
	if currencyType == DcDataCurrencyType.kCoin then
		Notify:dispatch("AchiEventDataUpdate",AchiDataType.kUseCoinAddCount, cost)
	elseif currencyType == DcDataCurrencyType.kGold then
		Notify:dispatch("AchiEventDataUpdate",AchiDataType.kUseWindmillAddCount, cost)
	end

	local builder = GameCurrencyDcDataBuilder:createConsumeBuilder(currencyType, cost)
	if type(goodsId) == "number" then
		local goodsName = DcDataHelper:getGoodsNameById(goodsId)
		builder:setGoodsId(goodsId):setGoodsName(goodsName)
	end
	builder:setFeature(feature):setGoodsNum(goodsNum):setCurrentStage(levelId):setActivityId(activityId)
	GameCurrencyDcUtil:logConsumeCurrency(currencyType, builder:dcData() , levelId)
end

function GameCurrencyDcUtil:dcCreateCoin(source, num, levelId, activityId)
	GameCurrencyDcUtil:dcCreateCurrency(source, DcDataCurrencyType.kCoin, num, levelId, activityId)
end

function GameCurrencyDcUtil:dcCreateHappyCoin(source, num, levelId, activityId)
	GameCurrencyDcUtil:dcCreateCurrency(source, DcDataCurrencyType.kGold, num, levelId, activityId)
end

function GameCurrencyDcUtil:dcConsumeCoin(cost, goodsId, goodsNum, levelId, activityId)
	GameCurrencyDcUtil:dcConsumeCurrency(nil, DcDataCurrencyType.kCoin, cost, goodsId, goodsNum, levelId, activityId)
end

function GameCurrencyDcUtil:dcConsumeHappyCoin(cost, goodsId, goodsNum, levelId, activityId)
	GameCurrencyDcUtil:dcConsumeCurrency(nil, DcDataCurrencyType.kGold, cost, goodsId, goodsNum, levelId, activityId)
end

function GameCurrencyDcUtil:dcConsumeRmb(cost, goodsId, goodsNum, levelId, activityId)
	GameCurrencyDcUtil:dcConsumeCurrency(nil, DcDataCurrencyType.kRmb, cost, goodsId, goodsNum, levelId, activityId)
end