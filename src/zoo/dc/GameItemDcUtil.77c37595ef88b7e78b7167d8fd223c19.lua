require "hecore.class"
require "zoo.util.DcUtil"
require "zoo.dc.DcDataHelper"
require "zoo.payment.GoodsBagObject"
------------------------------------------
GameItemDcDataBuilder = class()

function GameItemDcDataBuilder:ctor()
	self._dcData = {
		feature = nil,
		pay_type = nil,
		pay_value = nil,
		source = nil,
		item_id = nil,
		item_name = nil,
		total_num = nil,
		current_stage = nil,
		meta_level_id = nil,
		high_stage = nil,
		num = nil,
		stage_mode = nil,
		activity_id = nil,
		tutorial_condition = nil,
		goodsId = nil,

		value_happycoin = nil,
		value_coin = nil,
		value_rmb = nil,
	}
end

function GameItemDcDataBuilder:create(itemId, num)
	local builder = GameItemDcDataBuilder.new()
	builder:init(itemId, num)
	return builder
end

function GameItemDcDataBuilder:init(itemId, num)
	self:setHighStage(UserManager:getInstance().user:getTopLevelId()) 
	self:setStageMode(DcDataStageMode.kNotInLevel)

	if itemId then
		self:setItemId(itemId)
		self:setTotalNum(UserManager:getInstance():getUserPropNumber(itemId))
	end
	if num then
		self:setNum(num)
	end
end

function GameItemDcDataBuilder:setFeature(feature)
	self._dcData.feature = feature
	return self
end

function GameItemDcDataBuilder:setPayType(payType)
	self._dcData.pay_type = payType
	return self
end

function GameItemDcDataBuilder:setPayValue(payValue)
	self._dcData.pay_value = payValue
	return self
end

function GameItemDcDataBuilder:setSource(source)
	self._dcData.source = source
	return self
end

function GameItemDcDataBuilder:setHappyCoin(happycoin)
	self._dcData.value_happycoin = happycoin
	return self
end

function GameItemDcDataBuilder:setCoin(coin)
	self._dcData.value_coin = coin
	return self
end

function GameItemDcDataBuilder:setRmb(rmb)
	self._dcData.value_rmb = rmb
	return self
end

function GameItemDcDataBuilder:setActivityId(actId)
	self._dcData.activity_id = actId
	return self
end

function GameItemDcDataBuilder:setGoodsId(goodsId)
	self._dcData.goodsId = goodsId
	return self
end

function GameItemDcDataBuilder:setItemId(itemId)
	self._dcData.item_id = itemId
	self._dcData.item_name = DcDataHelper:getPropNameById(itemId)
	return self
end

function GameItemDcDataBuilder:setNum(num)
	self._dcData.num = num
	return self
end

function GameItemDcDataBuilder:setTotalNum(totalNum)
	self._dcData.total_num = totalNum
	return self
end

function GameItemDcDataBuilder:setTutorialPropId(propId)
	self._dcData.tutorial_condition = propId
	return self
end

function GameItemDcDataBuilder:setValueForKey(key, value)
	self._dcData[key] = value
	return self
end

function GameItemDcDataBuilder:setCurrentStage(currentStage)
	if type(currentStage) == "number" and currentStage > 0 then
		self._dcData.current_stage = currentStage
		self._dcData.meta_level_id = LevelMapManager.getInstance():getMetaLevelId(currentStage)
		local stageMode = DcDataHelper:getStageModeByLevelId(currentStage)
		self:setStageMode(stageMode)
	end
	return self
end

function GameItemDcDataBuilder:setStageMode(stageMode)
	self._dcData.stage_mode = stageMode
	return self
end

function GameItemDcDataBuilder:setHighStage(highStage)
	self._dcData.high_stage = highStage
	return self
end

function GameItemDcDataBuilder:dcData()
	return self._dcData
end

------------------------------- GameItemDcUtil -------------------------------
GameItemDcUtil = class()

function GameItemDcUtil:sendDcData(acType, category, subCategry, dcData)
	local data = {}
	data.category = category
	data.sub_category = subCategry
	for k, v in pairs(dcData) do
		data[k] = v
	end
	-- mylog("sendDcData:", table.tostring(data))
	DcUtil:log(acType, data)
end

function GameItemDcUtil:logGetItem(dcData , levelId)
	if not dcData then
		dcData = {}
	end
	dcData.playId = UserContext:getCurrPlayId() --GamePlayContext:getInstance():getIdStr()
	dcData.playInfo = GamePlayContext:getInstance():getPlayInfoDCStr()
	dcData.stage_state = DcUtil:tryGetStageState( levelId )

	local function addFailInfo()
		if GamePlayContext:getInstance().inLevel then
			if not levelId then
				levelId = GamePlayContext:getInstance().levelInfo.levelId or 0
			end
			local failCountBeaforPassLevel = -1
			if levelId == GamePlayContext:getInstance().levelInfo.currTopLevelId then
				failCountBeaforPassLevel = GamePlayContext:getInstance().levelInfo.currTopLevelFailCount
			end

			dcData.fail_count = failCountBeaforPassLevel
			dcData.cont_fail_count = FUUUManager:getLevelContinuousFailNum( levelId )
			dcData.start_level_total_count = FUUUManager:getLevelTotalPlayed( levelId )
			dcData.end_level_total_count = ( GamePlayContext:getInstance():getTotalEndLevelCount() or 0 )
		end
	end

	xpcall( addFailInfo , __G__TRACKBACK__)
	

	GameItemDcUtil:sendDcData(AcType.kRewardItem, "item", "origin", dcData)
end

function GameItemDcUtil:logUseItem(dcData , levelId)
	if not dcData then
		dcData = {}
	end
	dcData.playId = UserContext:getCurrPlayId() --GamePlayContext:getInstance():getIdStr()
	dcData.playInfo = GamePlayContext:getInstance():getPlayInfoDCStr()
	dcData.stage_state = DcUtil:tryGetStageState( levelId )
	GameItemDcUtil:sendDcData(AcType.kUseItem, "item", "use", dcData)
end

function GameItemDcUtil:dcGetItemNormal(itemId, num, source, levelId, activityId)
	source = source or "unknown"
	local dcBuilder = GameItemDcDataBuilder:create(itemId, num) 
 	dcBuilder:setSource(source):setCurrentStage(levelId):setActivityId(activityId)
	GameItemDcUtil:logGetItem(dcBuilder:dcData() , levelId)
end

function GameItemDcUtil:dcGetItemBuyWithGameCoin(itemId, num, price, levelId)
	local dcBuilder = GameItemDcDataBuilder:create(itemId, num) 
 	dcBuilder:setSource("buy_coin"):setCoin(price):setCurrentStage(levelId)
	GameItemDcUtil:logGetItem(dcBuilder:dcData() , levelId)
end

function GameItemDcUtil:dcGetItemBuyWithHappyCoin(itemId, num, price, levelId)
	local dcBuilder = GameItemDcDataBuilder:create(itemId, num) 
 	dcBuilder:setSource("buy_happycoin"):setHappyCoin(price):setCurrentStage(levelId)
	GameItemDcUtil:logGetItem(dcBuilder:dcData() , levelId)
end

function GameItemDcUtil:dcGetItemBuyWithRmb(itemId, num, price, levelId)
	local dcBuilder = GameItemDcDataBuilder:create(itemId, num) 
 	dcBuilder:setSource("buy_rmb"):setRmb(price):setCurrentStage(levelId)
	GameItemDcUtil:logGetItem(dcBuilder:dcData() , levelId)
end

function GameItemDcUtil:dcUseItem(itemId, num, levelId)
	num = num or 1
	local dcBuilder = GameItemDcDataBuilder:create(itemId, num) 
 	dcBuilder:setCurrentStage(levelId)

 	if itemId ~= ItemType.INGREDIENT then
	 	local goodsMeta = MetaManager.getInstance():getGoodMetaByItemID( itemId )
	 	if goodsMeta then
	 		local coin = goodsMeta.coin or 0
	 		local happycoin = goodsMeta.qCash or 0
	 		local rmb = goodsMeta.rmb or 0
	 		dcBuilder:setCoin(coin * num):setHappyCoin(happycoin * num):setRmb(rmb * num)
	 	end
	 end

	if GameBoardLogic:getCurrentLogic() then -- 本关引导使用的道具id
		dcBuilder:setTutorialPropId(GameBoardLogic:getCurrentLogic().triggerGuideProp)
	end

	GameItemDcUtil:logUseItem(dcBuilder:dcData() , levelId)
end