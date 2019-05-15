--add no use line

require "zoo.data.DataRef"
require 'zoo.util.QixiUtil'

local NO_DIFF = 0
function table.addAll(self, t)
  for i,v in ipairs(t) do
  	table.insert(self, v)
  end
end

UserLocalLogic = class()

function UserLocalLogic:checkPassLevelConfig( levelId )
	local levelMapMeta = LevelMapManager.getInstance():getMeta(levelId)
	local levelRewardMeta = MetaManager.getInstance():getLevelRewardByLevelId(levelId)
	assert(levelMapMeta, "levelId :" .. levelId .. ", map_config not exist!")
	assert(levelRewardMeta, "levelId :" .. levelId .. ", level reward config not exist!")
	if levelMapMeta == nil or levelRewardMeta == nil then return nil, nil, ZooErrorCode.CONFIG_ERROR end
	return levelMapMeta, levelRewardMeta
end

function UserLocalLogic:isNotConsumeEnergyBuff(time)
	local userExtend = UserService.getInstance().userExtend
	local now = Localhost:time() 
	if type(time) == "number" then now = time end
	--HeConsts.MILLISECONDS_PER_MINUTE
	return userExtend:getNotConsumeEnergyBuff() + 60000 >= now
end

--http://svn.happyelements.net/repos/svndata2/animal/java/trunk/animal-service/src/main/java/com/happyelements/animal/service/impl/ScoreServiceImpl.java
function UserLocalLogic:startLevel( uid, levelId, gameMode, itemIds, energyBuff, requestTime, gameLevelType, videoPropList )
	if gameLevelType == GameLevelType.kQixi then
		return self:startQixiLevel(uid, levelId, gameMode, itemIds, energyBuff, requestTime)
	end

	if gameLevelType == GameLevelType.kSummerWeekly then
		local matchData = SeasonWeeklyRaceManager:getInstance().matchData
		if not matchData or requestTime < (matchData.updateTime * 1000) then
			return false, ZooErrorCode.LEVEL_INVALID_REQUEST_TIME
		end
	end

	UserLocalLogic:refreshEnergy()
	local user = UserService.getInstance().user
	local consumeEnergy = true

	if energyBuff and self:isNotConsumeEnergyBuff(requestTime) then
		consumeEnergy = false
	end
	
	if CollectStarsYEMgr.getInstance():isBuffEffective(levelId) then
		consumeEnergy = false
	end

	local user_energy_level_consume = MetaManager.getInstance().global.user_energy_level_consume or 5

	if gameLevelType == GameLevelType.kRabbitWeekly or gameLevelType == GameLevelType.kMayDay 
		or gameLevelType == GameLevelType.kTaskForRecall or gameLevelType == GameLevelType.kSummerWeekly
		or gameLevelType == GameLevelType.kOlympicEndless or gameLevelType == GameLevelType.kMidAutumn2018
		or gameLevelType == GameLevelType.kWukong or gameLevelType == GameLevelType.kYuanxiao2017 
		or LevelType.isActivityLevelType(gameLevelType) or gameLevelType == GameLevelType.kMoleWeekly
        or gameLevelType == GameLevelType.kJamSperadLevel
		then
		consumeEnergy = false
	end

	self:refreshEnergy(requestTime)
	if consumeEnergy and user:getEnergy() < user_energy_level_consume then
		return false, ZooErrorCode.ENERGY_NOT_ENOUGH
	end

	local function IsFromVideoAdItem(itemId)
		return videoPropList and table.indexOf(videoPropList, itemId)
	end

	if #itemIds > 0 then
		--前置道具
		local propConfig = MetaManager.getInstance().prop
		local initPropIds = PrePropImproveLogic:getInitialProps(levelId)

		--地推包前置道具特殊处理
		if PublishActUtil:isGroundPublish() then
			initPropIds = PublishActUtil:getTempPropTable()
		end
		--召回功能最高关卡前置道具特殊处理
		if RecallManager.getInstance():getRecallLevelState(levelId) then
			local tempPropIds = table.clone(initPropIds)
			for i,v in ipairs(RecallManager.getInstance():getRecallItems()) do
				local isSame = false
				for m,n in ipairs(initPropIds) do
					if v == n.propId then
						isSame = true
						break
					end
				end
				if not isSame then 
					table.insert(tempPropIds, {propId = v})
				end
			end
			initPropIds = tempPropIds
		end

		local totalAmount = 0
		local oriCoin = user:getCoin()
		UserManager:getInstance().user:setCoin(oriCoin)
		for i,itemId in ipairs(itemIds) do

			local hasProp = false
			if ItemType:isTimeProp(itemId) then
				if UserService.getInstance():getUserTimePropNumber(itemId) > 0 then
					hasProp = true
				end
			else
				if UserService.getInstance():getUserPropNumber(itemId) > 0 then
					hasProp = true
				end
			end


			if hasProp then
				if ItemType:isTimeProp(itemId) then
					local success, expireTime = UserService.getInstance():useTimeProp(itemId)
					if success then
						StageInfoLocalLogic:addPreProp(UserService.getInstance().uid, itemId, expireTime)
					end
				else
					local consume = ConsumeItem.new(itemId, 1)
					local succeed, err = ItemLocalLogic:hasConsume(nil, consume)
					if succeed then
						succeed, err = ItemLocalLogic:consume(nil, consume)
						if not succeed then 
							return false, err 
						end
						StageInfoLocalLogic:addPreProp(UserService.getInstance().uid, itemId, 0)
					else 
						return false, err 
					end
				end
			else
				local isFreeItem = false -- qixi
				if QixiUtil:hasCompeleted() then
					local remainingCount = QixiUtil:getRemainingFreeItem(itemId)
					isFreeItem = (remainingCount > 0)
				end
				local propMeta = propConfig[itemId]
				if propMeta and levelId < propMeta.unlock then
					return false, ZooErrorCode.USE_PROP_LEVEL_ERROR
				end

				if #initPropIds > 0 then 
					local contain = false
					for i,v in ipairs(initPropIds) do
						if v.propId == ItemType:getRealIdByTimePropId(itemId) then 
							contain = true
							break
						end
					end
					if not contain then 
						return false, ZooErrorCode.ADD_PROP_MODE_ERROR_START_LEVEL
					end
				end

				local isCoinBuyItem = true
				local _itemId = ItemType:getRealIdByTimePropId(itemId)
				if ItemType:isHappyCoinPreProps(_itemId) then
					isCoinBuyItem = false
				end

				if not PublishActUtil:isGroundPublish() then
					if IsFromVideoAdItem(itemId) then
						--激励视频来源的道具单独打点
						GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kIncentiveVideo, itemId, 1, DcSourceType.kAdverPre, levelId)
					--召回功能最高关卡前置道具特殊处理 召回加的临时道具不是银币买的 不走购买打点
					elseif RecallManager.getInstance():getRecallLevelState(levelId) then
						if not table.includes(RecallManager.getInstance():getRecallItems(),itemId) then 
							local goodsMeta = MetaManager.getInstance():getGoodMetaByItemID(itemId) 
							if not goodsMeta then
								return false, ZooErrorCode.CONFIG_ERROR
							end

							if not isFreeItem then -- qixi
								if isCoinBuyItem then 
									totalAmount = totalAmount + goodsMeta.coin
									UserManager:getInstance():addCoin(-goodsMeta.coin)
									GainAndConsumeMgr.getInstance():consumeCurrency(DcFeatureType.kStageStart, DcDataCurrencyType.kCoin, goodsMeta.coin, goodsMeta.id, 1, levelId, nil, DcSourceType.kPreProp)
									GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kStageStart, itemId, 1, DcSourceType.kPreProp, levelId, nil, DcPayType.kCoin, goodsMeta.coin, goodsMeta.id)
								else
									he_log_error("UserLocalLogic.pre_prop:"..itemId.."_a_"..levelId)
								end
							else
								QixiUtil:consumeFreeItem(itemId)
								DcUtil:useQixiFreePreProps(itemId) -- qixi
							end
						end
					else
						local goodsMeta = MetaManager.getInstance():getGoodMetaByItemID(itemId) 
						if not goodsMeta then
							return false, ZooErrorCode.CONFIG_ERROR
						end

						if not isFreeItem then -- qixi
							if isCoinBuyItem then
								totalAmount = totalAmount + goodsMeta.coin
								UserManager:getInstance():addCoin(-goodsMeta.coin)
								GainAndConsumeMgr.getInstance():consumeCurrency(DcFeatureType.kStageStart, DcDataCurrencyType.kCoin, goodsMeta.coin, goodsMeta.id, 1, levelId, nil, DcSourceType.kPreProp)
								GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kStageStart, itemId, 1, DcSourceType.kPreProp, levelId, nil, DcPayType.kCoin, goodsMeta.coin, goodsMeta.id)
							else
								he_log_error("UserLocalLogic.pre_prop:"..itemId.."_b_"..levelId) 
							end
						else
							QixiUtil:consumeFreeItem(itemId)
							DcUtil:useQixiFreePreProps(itemId) -- qixi
						end
					end
					StageInfoLocalLogic:addPreProp(UserService.getInstance().uid, itemId, 0)
				end
			end
		end

		local function ones()
			--临时改动，以后统一优化为onDataUpdate
			-- AchievementManager:setData(AchievementManager.COIN_COST_NUM, totalAmount)
		end

		setTimeOut(ones, 3)

		local consume = ConsumeItem.new(ItemConstans.ITEM_COIN, totalAmount)
		local succeed, err = ItemLocalLogic:hasConsume(uid, consume)
		if succeed then
			succeed, err = ItemLocalLogic:consume(uid, consume)
			if not succeed then return false, err end
		else return false, err end
	end

	if consumeEnergy then
		return UserLocalLogic:subEnergy(uid, user_energy_level_consume, requestTime)
	end
	return true
end

function UserLocalLogic:startQixiLevel(uid, levelId, gameMode, itemIds, energyBuff, requestTime)
	if not QixiManager then return false, ZooErrorCode.INVALID_PARAMS end

	local qixi = QixiManager:sharedInstance()
	local success = true
	local errCode = nil
	return success, errCode
end

--http://svn.happyelements.net/repos/svndata2/animal/java/trunk/animal-service/src/main/java/com/happyelements/animal/service/impl/ScoreServiceImpl.java
function UserLocalLogic:updateScore(levelId, score, flashStar, useItem, stageTime, coinAmount, opLog, requestTime)

	local user = UserService.getInstance().user
	local uid = user.uid
	local result = {}

	local topLevelId = user:getTopLevelId()
	if not PublishActUtil:isGroundPublish() then
		if levelId > topLevelId then
			return nil, false, ZooErrorCode.LEVEL_ID_INVALID
		end
	end
	--LevelMapMeta LevelRewardMeta
	local levelStarMeta, rewardConfig, err = UserLocalLogic:checkPassLevelConfig(levelId)
	if err ~= nil then return nil, false, err end
	
	local star = flashStar
	if star ~= 0 then star = levelStarMeta:getStar(score) end

	local oriStar = 0
	local oriScore = 0
	local animalScore = UserService.getInstance():getUserScore(levelId)
	local jumpLevelRef = UserService.getInstance():getUserJumpLevelRef(levelId)
	if animalScore == nil then
		UserLocalLogic:insertNewLevel(uid, levelId, star, score)
		if star > 0 then
			table.addAll(result, UserLocalLogic:getLevelNewStarRewards(star, oriStar, rewardConfig))
		end

		if star > 0 and jumpLevelRef and jumpLevelRef.pawnNum > 0 then
			table.addAll(result, {RewardItemRef.new(ItemType.INGREDIENT, jumpLevelRef.pawnNum)})
			UserService.getInstance():removeJumpLevelRef(levelId)
		end

		if star > 0 and UserManager:getInstance():hasAskForHelpInfo(levelId) then
			AskForHelpManager.getInstance():onPassLevel(levelId)
		end
		
		if star > oriStar then
			if levelId == topLevelId and (not UserLocalLogic:isNewLevelAreaStart(levelId + 1)) then
				local succeed, err = UserLocalLogic:updateTopLevelId(uid, levelId + 1, star - oriStar)
				if err ~= nil then return nil, false, err end
				DcUtil:logLevelUp(levelId + 1)
			else
				local succeed, err = UserLocalLogic:addStar(uid, star - oriStar)
				if err ~= nil then return nil, false, err end
			end
		end
		--refresh global level rank
		if star > 0 then UserLocalLogic:updateLevelScoreRank( levelId, score ) end

		StageInfoLocalLogic:setStageState(uid , 0 , levelId)
		DcUtil:logFirstLevelGame(levelId, math.floor(levelId / 10000), star > 0, useItem, stageTime, 0)
		DcUtil:logBeforeFirstWin(levelId, math.floor(levelId / 10000), star > 0, useItem, stageTime, 0)
	else
		--repeat level
		oriStar = animalScore.star
		oriScore = animalScore.score
		UserLocalLogic:updateRepeatLevel(score, star, animalScore, uid)
		if star > 0 then
			table.addAll(result, UserLocalLogic:getLevelDefaultStarRewards(star > oriStar and oriStar or star, rewardConfig))
			table.addAll(result, UserLocalLogic:getLevelNewStarRewards(star, oriStar, rewardConfig))
		end

		if star >0 and jumpLevelRef and jumpLevelRef.pawnNum > 0 then
			table.addAll(result, {RewardItemRef.new(ItemType.INGREDIENT, jumpLevelRef.pawnNum)})
			UserService.getInstance():removeJumpLevelRef(levelId)
		end

		if star > 0 and UserManager:getInstance():hasAskForHelpInfo(levelId) then
			AskForHelpManager.getInstance():onPassLevel(levelId)
		end

		if oriStar == 0 then
			if star > oriStar then
				if levelId == topLevelId and (not UserLocalLogic:isNewLevelAreaStart(levelId + 1)) then
					local succeed, err = UserLocalLogic:updateTopLevelId(uid, levelId + 1, star - oriStar)
					if err ~= nil then return nil, false, err end
				else
					local succeed, err = UserLocalLogic:addStar(uid, star - oriStar)
					if err ~= nil then return nil, false, err end
				end
			end
		else
			if star > oriStar then
				local succeed, err = UserLocalLogic:addStar(uid, star - oriStar)
				if err ~= nil then return nil, false, err end
			end
		end



		
		if star > 0 and score > oriScore then
			--// refresh the global level rank
			UserLocalLogic:updateLevelScoreRank( levelId, score )
		end

		if oriStar == 0 then
			StageInfoLocalLogic:setStageState(uid , 1 , levelId)
			DcUtil:logBeforeFirstWin(levelId, math.floor(levelId / 10000), star > 0, useItem, stageTime, 0)
		else
			StageInfoLocalLogic:setStageState(uid , 2 , levelId)
		end
	end

	local hasPassedLevel = UserManager:getInstance():hasPassedLevelEx( levelId )

	local coinIncrease_Add = 0

	
	local firstPassed =  star > 0 and hasPassedLevel == false

	-- local oldStar = 0
	-- if animalScore then
	-- 	oldStar = animalScore.star
	-- 	print("oldStar 1= " , oldStar )
	-- end

	-- print("oldStar 2= " , oldStar )

	-- print(debug.traceback())
	-- debug.debug()

    --成就银币加成
    self:addAchiveExtraRewards(result)

    --超难关加成
	local friendHelp = UserManager.getInstance():hasPassedByTrick( levelId )
	if firstPassed  or friendHelp then
		local difficuleLevelExtraReward ,coinIncrease= self:getDifficultLevelExtraRewards(levelId, result)
		table.addAll(result, difficuleLevelExtraReward)
		coinIncrease_Add = coinIncrease
	end

	local succeed, err = UserLocalLogic:rewardPassLevel(result, user, levelId, requestTime)
	if err ~= nil then return nil, false, err end
	--coin blocker
	if star > 0 and coinAmount > 0 then
		--CoinBlockerMeta
		local addCoin, succeed, err = UserLocalLogic:rewardCoinBlocker(levelId, coinAmount)
		if err ~= nil then 
			return nil, false, err 
		elseif addCoin > 0 then
			addCoin = math.ceil( addCoin * (1 + coinIncrease_Add) )
			table.addAll(result, {RewardItemRef.new(ItemConstans.ITEM_COIN, addCoin)})
		end
	end

	return result, true
end



-- 关卡代打更新成绩
function UserLocalLogic:updateScoreAFH(levelId, score, flashStar, useItem, stageTime, coinAmount, opLog, requestTime)
	local user = UserService.getInstance().user
	local uid = user.uid
	local result = {}

	local topLevelId = user:getTopLevelId()
	if not PublishActUtil:isGroundPublish() then
		if levelId > topLevelId then
			return nil, false, ZooErrorCode.LEVEL_ID_INVALID
		end
	end

	local levelStarMeta, rewardConfig, err = UserLocalLogic:checkPassLevelConfig(levelId)
	if err ~= nil then return nil, false, err end
	
	local star = flashStar
	if star ~= 0 then star = levelStarMeta:getStar(score) end

	local oriStar = 0
	local oriScore = 0
	local animalScore = UserService.getInstance():getUserScore(levelId)
	if not animalScore then return nil, false, {} end
	
	if star > 0 then
		table.addAll(result, UserLocalLogic:getLevelNewStarRewards(star, oriStar, rewardConfig))
	end

	-- 代打只会收获COIN/ENERGY_LIGHTNING
	local function rewardFilter(v)
		if not v then return false end
		if v.itemId == ItemType.COIN or v.itemId == ItemType.ENERGY_LIGHTNING then
			return true
		end
		return false
	end
	local mergedRewards = ItemLocalLogic:mergeRewards(result) or {}
	result = table.filter(mergedRewards, rewardFilter)

	local succeed, err = UserLocalLogic:rewardPassLevel(result, user, levelId, requestTime)
	if err ~= nil then return nil, false, err end

	return result, true
end

function UserLocalLogic:insertNewLevel( uid, levelId, star, score )
	local user = UserService.getInstance().user

	local animalScore = ScoreRef.new()
	animalScore.levelId = levelId
	animalScore.uid = user.uid
	animalScore.score = score
	animalScore.star = star
	animalScore.updateTime = Localhost:time()
	-- animalScore.pawnNum = pawnNum or 0
	--TODO: if (star == 0) animalScore.setScore(0);		
	UserService.getInstance():addUserScore(animalScore)	
end

function UserLocalLogic:insertJumpLevelInfo( levelId, pawnNum)
	-- body
	local user = UserService.getInstance().user

	local jumpLevelRef = JumpLevelRef.new()
	jumpLevelRef.levelId = levelId
	jumpLevelRef.pawnNum = pawnNum
	UserService.getInstance():addJumpLevelInfo(jumpLevelRef)
end
function UserLocalLogic:updateRepeatLevel( score, star, oldAnimalScore, uid )
	local dataChanged = false
	if score > oldAnimalScore.score and star > 0 then
		oldAnimalScore.score = score
		dataChanged = true
	end
	if star > oldAnimalScore.star then
		oldAnimalScore.star = star
		dataChanged = true
	end
	if dataChanged then
		oldAnimalScore.updateTime = Localhost:time()
	end
end
function UserLocalLogic:rewardPassLevel( rewards, user, levelId, requestTime )
	local mergedRewards = ItemLocalLogic:mergeRewards(rewards)
	if mergedRewards and #mergedRewards > 0 then
		for i,v in ipairs(mergedRewards) do
			if v.itemId == ItemConstans.ITEM_COIN then
				--TODO: logCreateCoin
			end
			local succeed, err = ItemLocalLogic:add(user.uid, v.itemId, v.num, requestTime)
			if err ~= nil then return false, err end
		end
	end
	return true
end

--http://svn.happyelements.net/repos/svndata2/animal/java/trunk/animal-service/src/main/java/com/happyelements/animal/service/impl/ScoreServiceImpl.java
function UserLocalLogic:updateLevelScoreRank( levelId, score )
	
end

function UserLocalLogic:isNewLevelAreaStart( levelId )
	return MetaManager.getInstance():isMinLevelAreaId(levelId)  
end
function UserLocalLogic:updateHideLevelScore(levelId, score, flashStar, useItem, stageTime, coinAmount, opLog, requestTime)
	local isHideAreaUnLocked = ItemLocalLogic:checkHideAreaUnLocked( uid, levelId )
	
	if not isHideAreaUnLocked then
		if _G.isLocalDevelopMode then printx(0, "HIDE_AREA_ERROR_AREA_UNLOCK") end
		return nil, false, ZooErrorCode.HIDE_AREA_ERROR_AREA_UNLOCK
	end
	local user = UserService.getInstance().user
	local uid = user.uid
	local result = {}

	--LevelMapMeta LevelRewardMeta
	local levelStarMeta, rewardConfig, err = UserLocalLogic:checkPassLevelConfig(levelId)
	if err ~= nil then return nil, false, err end

	local star = flashStar
	if star ~= 0 then star = levelStarMeta:getStar(score) end

	local oriStar = 0
	local oriScore = 0
	local animalScore = UserService.getInstance():getUserScore(levelId)

	if animalScore == nil then
		UserLocalLogic:insertNewLevel(uid, levelId, star, score)
		if star > 0 then
			table.addAll(result, UserLocalLogic:getLevelNewStarRewards(star, oriStar, rewardConfig))
			--refresh global level rank
			UserLocalLogic:updateLevelScoreRank( levelId, score )
		end
		StageInfoLocalLogic:setStageState(uid , 0 , levelId)
		DcUtil:logFirstLevelGame(levelId, math.floor(levelId / 10000), star > 0, useItem, stageTime, 0)
		DcUtil:logBeforeFirstWin(levelId, math.floor(levelId / 10000), star > 0, useItem, stageTime, 0)
	else
		--repeat level
		oriStar = animalScore.star
		oriScore = animalScore.score
		UserLocalLogic:updateRepeatLevel(score, star, animalScore, uid)
		if star > 0 then
			table.addAll(result, UserLocalLogic:getLevelDefaultStarRewards(star > oriStar and oriStar or star, rewardConfig))
			table.addAll(result, UserLocalLogic:getLevelNewStarRewards(star, oriStar, rewardConfig))
		end

		if star > 0 and score > oriScore then
			--// refresh the global level rank
			UserLocalLogic:updateLevelScoreRank( levelId, score )
		end
		if oriStar == 0 then
			StageInfoLocalLogic:setStageState(uid , 1 , levelId)
			DcUtil:logBeforeFirstWin(levelId, math.floor(levelId / 10000), star > 0, useItem, stageTime, 0)
		else
			StageInfoLocalLogic:setStageState(uid , 2 , levelId)
		end
	end

    --成就银币加成
    self:addAchiveExtraRewards(result)

	local succeed, err = UserLocalLogic:rewardPassLevel(result, user, levelId, requestTime)
	if err ~= nil then return nil, false, err end
	--coin blocker
	if star > 0 and coinAmount > 0 then
		local addCoin, succeed, err = UserLocalLogic:rewardCoinBlocker(levelId, coinAmount)
		if err ~= nil then 
			return nil, false, err 
		elseif addCoin > 0 then
			table.addAll(result, {RewardItemRef.new(ItemConstans.ITEM_COIN, addCoin)})
		end
	end

	if star > oriStar then 
		local succeed, err = UserLocalLogic:addHideStar(uid, star - oriStar) 
		if err ~= nil then return nil, false, err end
	end
	return result, true
end

function UserLocalLogic:rewardCoinBlocker(levelId, coinAmount)
	local coinBlockerMeta = MetaManager.getInstance():getCoinBlockersByLevelId(levelId)
	if coinBlockerMeta and type(coinAmount) == "number" and coinAmount <= coinBlockerMeta.coin_amount then
		local coinValue = MetaManager.getInstance().global.coin or 5
		local addCoin = coinValue * coinAmount

		local succeed, err = ItemLocalLogic:add(uid, ItemConstans.ITEM_COIN, addCoin)
		if err == nil then
			GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kStageEnd, ItemType.COIN, addCoin, DcSourceType.kLevelReward, levelId)
		end
		return addCoin, succeed, err
	end
	return 0
end

function UserLocalLogic:updateDiggerMatchLevelScore( levelId, score, flashStar, useItem, stageTime, gemCount, coinAmount, opLog, requestTime )

	local user = UserService.getInstance().user
	local uid = user.uid
	local result = {}

	--LevelMapMeta LevelRewardMeta
	local levelStarMeta, rewardConfig, err = UserLocalLogic:checkPassLevelConfig(levelId)
	if err ~= nil then return nil, false, err end

	local star = flashStar
	if star ~= 0 then star = levelStarMeta:getStar(score) end

	local oriStar = 0
	local animalScore = UserService.getInstance():getUserScore(levelId)
	if animalScore == nil then
		UserLocalLogic:insertNewLevel(uid, levelId, star, score)
		if star > 0 then
			table.addAll(result, UserLocalLogic:getLevelNewStarRewards(star, oriStar, rewardConfig))
		end
	else
		--repeat level
		oriStar = animalScore.star
		UserLocalLogic:updateRepeatLevel(score, star, animalScore, uid)
		if star > 0 then
			table.addAll(result, UserLocalLogic:getLevelDefaultStarRewards(star > oriStar and oriStar or star, rewardConfig))
			table.addAll(result, UserLocalLogic:getLevelNewStarRewards(star, oriStar, rewardConfig))
		end
	end

	local succeed, err = UserLocalLogic:rewardPassLevel(result, user, levelId, requestTime)
	if err ~= nil then return nil, false, err end
	--coin blocker
	if star > 0 and coinAmount > 0 then
		local addCoin, succeed, err = UserLocalLogic:rewardCoinBlocker(levelId, coinAmount)
		if err ~= nil then 
			return nil, false, err 
		elseif addCoin > 0 then
			table.addAll(result, {RewardItemRef.new(ItemConstans.ITEM_COIN, addCoin)})
		end
	end

	UserLocalLogic:recordDailyMaxGemCount(uid, gemCount, levelId)
	UserLocalLogic:recordDailyDigg(uid)
	return result, true
end

function UserLocalLogic:updateMaydayEndlessLevelScore(levelId, score, flashStar, useItem, stageTime, targetCount, coinAmount, opLog, requestTime)
	local user = UserService.getInstance().user
	local uid = user.uid
	local result = {}

	--LevelMapMeta LevelRewardMeta
	local levelStarMeta, rewardConfig, err = UserLocalLogic:checkPassLevelConfig(levelId)
	if err ~= nil then return nil, false, err end

	local star = flashStar
	if star ~= 0 then star = levelStarMeta:getStar(score) end

	local oriStar = 0
	local animalScore = UserService.getInstance():getUserScore(levelId)
	if animalScore == nil then
		-- UserLocalLogic:insertNewLevel(uid, levelId, star, score)
		if star > 0 then
			table.addAll(result, UserLocalLogic:getLevelNewStarRewards(star, oriStar, rewardConfig))
		end
	else
		--repeat level
		oriStar = animalScore.star
		UserLocalLogic:updateRepeatLevel(score, star, animalScore, uid)
		if star > 0 then
			table.addAll(result, UserLocalLogic:getLevelDefaultStarRewards(star > oriStar and oriStar or star, rewardConfig))
			table.addAll(result, UserLocalLogic:getLevelNewStarRewards(star, oriStar, rewardConfig))
		end
	end

	local succeed, err = UserLocalLogic:rewardPassLevel(result, user, levelId, requestTime)
	if err ~= nil then return nil, false, err end
	--coin blocker
	if star > 0 and coinAmount > 0 then
		local addCoin, succeed, err = UserLocalLogic:rewardCoinBlocker(levelId, coinAmount)
		if err ~= nil then 
			return nil, false, err 
		elseif addCoin > 0 then
			table.addAll(result, {RewardItemRef.new(ItemConstans.ITEM_COIN, addCoin)})
		end
	end

	return result, true
end

function UserLocalLogic:updateMoleWeeklyLevelScore(levelId, score, flashStar, useItem, stageTime, targetCount, coinAmount, opLog, requestTime)
	local user = UserService.getInstance().user
	local result = {}

    local star = flashStar or 1

	--coin blocker
	if star > 0 and coinAmount > 0 then
		local addCoin, succeed, err = UserLocalLogic:rewardCoinBlocker(levelId, coinAmount)
		if err ~= nil then 
			return nil, false, err 
		elseif addCoin > 0 then
			table.addAll(result, {RewardItemRef.new(ItemConstans.ITEM_COIN, addCoin)})
		end
	end

	return result, true
end

function UserLocalLogic:updateRabbitWeeklyLevelScore(levelId, score, flashStar, stageTime, coinAmount, targetCount, opLog, activityFlag, requestTime)
	local user = UserService.getInstance().user
	local uid = user.uid
	local result = {}

	--LevelMapMeta LevelRewardMeta
	local levelStarMeta, rewardConfig, err = UserLocalLogic:checkPassLevelConfig(levelId)
	if err ~= nil then return nil, false, err end

	local star = flashStar
	if star ~= 0 then star = levelStarMeta:getStar(score) end

	local oriStar = 0
	-- 不记录分数
	local animalScore = UserService.getInstance():getUserScore(levelId)
	if animalScore == nil then
		UserLocalLogic:insertNewLevel(uid, levelId, star, score)
		if star > 0 then
			table.addAll(result, UserLocalLogic:getLevelNewStarRewards(star, oriStar, rewardConfig))
		end
	else
		--repeat level
		oriStar = animalScore.star
		UserLocalLogic:updateRepeatLevel(score, star, animalScore, uid)
		if star > 0 then
			table.addAll(result, UserLocalLogic:getLevelDefaultStarRewards(star > oriStar and oriStar or star, rewardConfig))
			table.addAll(result, UserLocalLogic:getLevelNewStarRewards(star, oriStar, rewardConfig))
		end
	end

	local succeed, err = UserLocalLogic:rewardPassLevel(result, user, levelId, requestTime)
	if err ~= nil then return nil, false, err end
	--coin blocker
	if star > 0 and coinAmount > 0 then
		local addCoin, succeed, err = UserLocalLogic:rewardCoinBlocker(levelId, coinAmount)
		if err ~= nil then 
			return nil, false, err 
		elseif addCoin > 0 then
			table.addAll(result, {RewardItemRef.new(ItemConstans.ITEM_COIN, addCoin)})
		end
	end
	
	return result, true	
end

function UserLocalLogic:updateActivityLevelScore(levelId, score, flashStar, useItem, stageTime, coinAmount, targetCount, opLog, activityFlag, requestTime)
	if activityFlag == GameLevelType.kQixi then
		if _G.isLocalDevelopMode then printx(0, 'UserLocalLogic:updateActivityLevelScore') end
		QixiManager:sharedInstance():onPassLevel(targetCount)
		return {}, true
	end
end

function UserLocalLogic:updateRecallTaskLevelScore(levelId, score, flashStar, useItem, stageTime, targetCount, coinAmount, opLog, requestTime)
	local user = UserService.getInstance().user
	local uid = user.uid
	local result = {}

	--LevelMapMeta LevelRewardMeta
	local levelStarMeta, rewardConfig, err = UserLocalLogic:checkPassLevelConfig(levelId)
	if err ~= nil then return nil, false, err end

	local star = flashStar
	if star ~= 0 then star = levelStarMeta:getStar(score) end

	local oriStar = 0
	-- 不记录分数
	local animalScore = UserService.getInstance():getUserScore(levelId)
	if animalScore == nil then
		UserLocalLogic:insertNewLevel(uid, levelId, star, score)
		if star > 0 then
			table.addAll(result, UserLocalLogic:getLevelNewStarRewards(star, oriStar, rewardConfig))
		end
		StageInfoLocalLogic:setStageState(uid , 0 , levelId)
		DcUtil:logFirstLevelGame(levelId, 18, star > 0, useItem, stageTime, 0)
		DcUtil:logBeforeFirstWin(levelId, 18, star > 0, useItem, stageTime, 0)
	else
		--repeat level
		oriStar = animalScore.star
		UserLocalLogic:updateRepeatLevel(score, star, animalScore, uid)
		if star > 0 then
			table.addAll(result, UserLocalLogic:getLevelDefaultStarRewards(star > oriStar and oriStar or star, rewardConfig))
			table.addAll(result, UserLocalLogic:getLevelNewStarRewards(star, oriStar, rewardConfig))
		end

		if oriStar == 0 then
			StageInfoLocalLogic:setStageState(uid , 1 , levelId)
			DcUtil:logBeforeFirstWin(levelId, 18, star > 0, useItem, stageTime, 0)
		else
			StageInfoLocalLogic:setStageState(uid , 2 , levelId)
		end
	end

	--coin blocker
	if star > 0 and coinAmount > 0 then
		local addCoin, succeed, err = UserLocalLogic:rewardCoinBlocker(levelId, coinAmount)
		if err ~= nil then 
			return nil, false, err 
		elseif addCoin > 0 then
			table.addAll(result, {RewardItemRef.new(ItemConstans.ITEM_COIN, addCoin)})
		end
	end

	return result, true
end

function UserLocalLogic:updateTaskForUnlockArealevelScore( levelId, score, flashStar, useItem, stageTime, targetCount, coinAmount, opLog, requestTime )
	-- body
	local user = UserService.getInstance().user
	local uid = user.uid
	local result = {}

	--LevelMapMeta LevelRewardMeta
	local levelStarMeta, rewardConfig, err = UserLocalLogic:checkPassLevelConfig(levelId)
	if err ~= nil then return nil, false, err end

	local star = flashStar
	if star ~= 0 then star = levelStarMeta:getStar(score) end

	local oriStar = 0
	-- 不记录分数
	local animalScore = UserService.getInstance():getUserScore(levelId)
	if animalScore == nil then
		UserLocalLogic:insertNewLevel(uid, levelId, star, score)
		if star > 0 then
			table.addAll(result, UserLocalLogic:getLevelNewStarRewards(star, oriStar, rewardConfig))
		end
		StageInfoLocalLogic:setStageState(uid , 0 , levelId)
		DcUtil:logFirstLevelGame(levelId, 18, star > 0, useItem, stageTime, 0)
		DcUtil:logBeforeFirstWin(levelId, 18, star > 0, useItem, stageTime, 0)
	else
		--repeat level
		oriStar = animalScore.star
		UserLocalLogic:updateRepeatLevel(score, star, animalScore, uid)
		if star > 0 then
			table.addAll(result, UserLocalLogic:getLevelDefaultStarRewards(star > oriStar and oriStar or star, rewardConfig))
			table.addAll(result, UserLocalLogic:getLevelNewStarRewards(star, oriStar, rewardConfig))
		end

		if oriStar == 0 then
			StageInfoLocalLogic:setStageState(uid , 1 , levelId)
			DcUtil:logBeforeFirstWin(levelId, 18, star > 0, useItem, stageTime, 0)
		else
			StageInfoLocalLogic:setStageState(uid , 2 , levelId)
		end
	end

	--coin blocker
	if star > 0 and coinAmount > 0 then
		local addCoin, succeed, err = UserLocalLogic:rewardCoinBlocker(levelId, coinAmount)
		if err ~= nil then 
			return nil, false, err 
		elseif addCoin > 0 then
			table.addAll(result, {RewardItemRef.new(ItemConstans.ITEM_COIN, addCoin)})
		end
	end
	return result, true
end

function UserLocalLogic:updateSpring2019LevelScore(levelId, score, flashStar, useItem, stageTime, targetCount, coinAmount, opLog, requestTime)
	local user = UserService.getInstance().user
	local uid = user.uid
	local result = {}

	--LevelMapMeta LevelRewardMeta
	local levelStarMeta, rewardConfig, err = UserLocalLogic:checkPassLevelConfig(levelId)
	if err ~= nil then return nil, false, err end
	
	local star = flashStar
	if star ~= 0 then star = levelStarMeta:getStar(score) end

	local oriStar = 0
	local oriScore = 0
--	local animalScore = UserService.getInstance():getUserScore(levelId) --这里要替换 格子{star = 3}
    local lastLevelStar = SpringFestival2019Manager:getInstance().lastLevelStar or 3

    local animalScore = nil
    if lastLevelStar > 0 then animalScore = { star=lastLevelStar } end

	-- local jumpLevelRef = UserService.getInstance():getUserJumpLevelRef(levelId)
	if animalScore == nil then
		-- UserLocalLogic:insertNewLevel(uid, levelId, star, score)
		if star > 0 then
			table.addAll(result, UserLocalLogic:getLevelNewStarRewards(star, oriStar, rewardConfig))
		end
	else
		--repeat level
		oriStar = animalScore.star
		oriScore = animalScore.score
		if star > 0 then
			table.addAll(result, UserLocalLogic:getLevelDefaultStarRewards(star > oriStar and oriStar or star, rewardConfig))
			table.addAll(result, UserLocalLogic:getLevelNewStarRewards(star, oriStar, rewardConfig))
		end
	end

	local hasPassedLevel = UserManager:getInstance():hasPassedLevelEx( levelId )

	local coinIncrease_Add = 0

	
	local firstPassed =  star > 0 and hasPassedLevel == false

	local succeed, err = UserLocalLogic:rewardPassLevel(result, user, levelId, requestTime)
	if err ~= nil then return nil, false, err end
	--coin blocker
	if star > 0 and coinAmount > 0 then
		--CoinBlockerMeta
		local addCoin, succeed, err = UserLocalLogic:rewardCoinBlocker(levelId, coinAmount)
		if err ~= nil then 
			return nil, false, err 
		elseif addCoin > 0 then
			addCoin = math.ceil( addCoin * (1 + coinIncrease_Add) )
			table.addAll(result, {RewardItemRef.new(ItemConstans.ITEM_COIN, addCoin)})
		end
	end

	return result, true
end

function UserLocalLogic:recordDailyMaxGemCount( uid, gemCount, levelId )
	--TODO: implement it.
end
function UserLocalLogic:recordDailyDigg( uid )
	--TODO: implement it.
end
function UserLocalLogic:getLevelDefaultStarRewards(oriStar, rewardConfig)
	local result = {}
	for i=1,oriStar do
		table.addAll(result, rewardConfig:getDefaultStarRewards(i))
	end
	return result
end
function UserLocalLogic:getLevelNewStarRewards(newStar, oriStar, rewardConfig)
	local result = {}
	for i = oriStar + 1, newStar do
		table.addAll(result, rewardConfig:getNewStarRewards(i))
	end
	return result
end

--http://svn.happyelements.net/repos/svndata2/animal/java/trunk/animal-service/src/main/java/com/happyelements/animal/service/impl/UserServiceImpl.java
function UserLocalLogic:updateTopLevelId( uid, topLevelId, addStar )
	-- AnimalActivity.logUserTopLevelUp(uid, topLevelId);
	return UserLocalLogic:updateUser(uid, NO_DIFF, NO_DIFF, addStar, NO_DIFF, topLevelId, NO_DIFF, NO_DIFF)
end
function UserLocalLogic:addStar( uid, star )
	if star < 0 then return false, ZooErrorCode.INVALID_PARAMS end
	return UserLocalLogic:updateUser(uid, NO_DIFF, NO_DIFF, star, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF)
end
function UserLocalLogic:addHideStar( uid, star )
	if star < 0 then return false, ZooErrorCode.INVALID_PARAMS end
	return UserLocalLogic:updateUser(uid, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, star)
end
function UserLocalLogic:addCoin( uid, coin )
	if coin < 0 then return false, ZooErrorCode.INVALID_PARAMS end
	return UserLocalLogic:updateUser(uid, coin, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF)
end
function UserLocalLogic:subCoin( uid, coin )
	if coin < 0 then return false, ZooErrorCode.INVALID_PARAMS end
	return UserLocalLogic:updateUser(uid, -coin, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF)
end
function UserLocalLogic:addCash( uid, cash )
	if cash < 0 then return false, ZooErrorCode.INVALID_PARAMS end
	return UserLocalLogic:updateUser(uid, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, cash)
end
function UserLocalLogic:subCash( uid, cash )
	if cash < 0 then return false, ZooErrorCode.INVALID_PARAMS end
	return UserLocalLogic:updateUser(uid, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, -cash)
end
function UserLocalLogic:addPoint( uid, point )
	if point < 0 then return false, ZooErrorCode.INVALID_PARAMS end
	return UserLocalLogic:updateUser(uid, NO_DIFF, point, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF)
end
function UserLocalLogic:subPoint( uid, point )
	if point < 0 then return false, ZooErrorCode.INVALID_PARAMS end
	return UserLocalLogic:updateUser(uid, NO_DIFF, -point, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF)
end
function UserLocalLogic:addEnergy( uid, energy, requestTime )
	if energy < 0 then return false, ZooErrorCode.INVALID_PARAMS end
	return UserLocalLogic:updateUser(uid, NO_DIFF, NO_DIFF, NO_DIFF, energy, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, requestTime)
end
function UserLocalLogic:subEnergy( uid, energy, requestTime )
	if energy < 0 then return false, ZooErrorCode.INVALID_PARAMS end
	return 	UserLocalLogic:updateUser(uid, NO_DIFF, NO_DIFF, NO_DIFF, -energy, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, requestTime)
end
function UserLocalLogic:updateStar( uid, star )
	if star < 0 then return false, ZooErrorCode.INVALID_PARAMS end
	return UserLocalLogic:updateUser(uid, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, NO_DIFF, star)
end
--http://svn.happyelements.net/repos/svndata2/animal/java/trunk/animal-service/src/main/java/com/happyelements/animal/service/impl/UserServiceImpl.java
function UserLocalLogic:updateUser( uid, addCoin, addPoint, addStar, addEnergy, topLevelId, image, addHideStar, updateStar, addCash, requestTime)
	local user = UserService.getInstance().user
	addCoin = addCoin or 0
	addPoint = addPoint or 0
	addEnergy = addEnergy or 0
	topLevelId = topLevelId or 0
	image = image or 0
	addHideStar = addHideStar or 0
	updateStar = updateStar or 0
	addCash = addCash or NO_DIFF

	assert(user, "USER_RECORD_NOT_FOUND")
	if image ~= NO_DIFF then user.image = image end
	if addCoin ~= NO_DIFF then
		assert((user:getCoin() + addCoin) >= 0, "COIN_NOT_ENOUGH")
		if user:getCoin() + addCoin < 0 then return false, ZooErrorCode.COIN_NOT_ENOUGH end
		user:setCoin(user:getCoin() + addCoin)	
	end
	if addCash ~= NO_DIFF then
		assert((user:getCash() + addCash) >= 0, "CASH_NOT_ENOUGH")
		if user:getCash() + addCash < 0 then return false, ZooErrorCode.CASH_NOT_ENOUGH end
		user:setCash(user:getCash() + addCash)
	end
	if addPoint ~= NO_DIFF then
		assert((user.point + addPoint) >= 0, "POINT_NOT_ENOUGH")
		if user.point + addPoint < 0 then return false, ZooErrorCode.POINT_NOT_ENOUGH end
		user.point = user.point + addPoint
	end
	user:setStar(user:getStar() + addStar)

	if updateStar ~= NO_DIFF then
		user:setStar(updateStar)
	end

	user:setHideStar(user:getHideStar() + addHideStar)
	if addEnergy ~= NO_DIFF then
		local changedEnergy = 0
		if addEnergy < 0 then
			user = UserLocalLogic:refreshEnergy(requestTime)
			assert(user:getEnergy() + addEnergy >= 0, "ENERGY_NOT_ENOUGH")	
			if user:getEnergy() + addEnergy < 0 then return false, ZooErrorCode.ENERGY_NOT_ENOUGH end		
			user:setEnergy(user:getEnergy() + addEnergy)
			changedEnergy = addEnergy
		else
			local now = Localhost:time()
			if type(requestTime) == "number" then now = requestTime end
			local maxEnergy = MetaManager.getInstance().global.user_energy_max_count or 30
			maxEnergy = maxEnergy + Achievement:getRightsExtra( "EnergyRecoveryUpperLimit" )
			local userExtend = UserService.getInstance().userExtend
			local energyPlusEffectTime = userExtend:getEnergyPlusEffectTime()
			if energyPlusEffectTime > now then
				local propMeta = MetaManager.getInstance():getPropMeta(userExtend.energyPlusId)
				assert(propMeta)
				if propMeta then
					maxEnergy = maxEnergy + propMeta.confidence
				end
			elseif userExtend.energyPlusPermanentId > 0 then
				local propMeta = MetaManager.getInstance():getPropMeta(userExtend.energyPlusPermanentId)
				assert(propMeta)
				if propMeta then
					maxEnergy = maxEnergy + propMeta.confidence
				end
			end

			if user:getEnergy() + addEnergy > maxEnergy then
				user:setEnergy(maxEnergy)
				changedEnergy = maxEnergy - user:getEnergy()
			else
				user:setEnergy(user:getEnergy() + addEnergy)
				changedEnergy = addEnergy
			end
		end
	end

	if topLevelId > NO_DIFF then user:setTopLevelId(topLevelId) end
	return true
end
--http://svn.happyelements.net/repos/svndata2/animal/java/trunk/animal-service/src/main/java/com/happyelements/animal/service/impl/UserServiceImpl.java
function UserLocalLogic:refreshEnergy(time)
	local user = UserService.getInstance().user
	local now = Localhost:time() --long now = timeService.getTime(user.getUid());
	if type(time) == "number" then now = time end
	local maxEnergy = MetaManager.getInstance().global.user_energy_max_count or 30
	maxEnergy = maxEnergy + Achievement:getRightsExtra( "EnergyRecoveryUpperLimit" )
	
	local userExtend = UserService.getInstance().userExtend
	local energyPlusEffectTime = userExtend:getEnergyPlusEffectTime()

	if energyPlusEffectTime > now then
		local propMeta = MetaManager.getInstance():getPropMeta(userExtend.energyPlusId)
		if propMeta then
			maxEnergy = maxEnergy + propMeta.confidence
		end
	elseif userExtend.energyPlusPermanentId > 0 then
		local propMeta = MetaManager.getInstance():getPropMeta(userExtend.energyPlusPermanentId)
		if propMeta then
			maxEnergy = maxEnergy + propMeta.confidence
		end
	end

	if user:getEnergy() < maxEnergy then
		local timePast = now - user:getUpdateTime()
		local user_energy_recover_time_unit = MetaManager.getInstance().global.user_energy_recover_time_unit or 480000
		user_energy_recover_time_unit = user_energy_recover_time_unit * FcmManager:getTimeScale()
		local energyInc = math.floor(timePast / user_energy_recover_time_unit)
		
		if energyInc >= 1 then
			if user:getEnergy() + energyInc >= maxEnergy then
				user:setEnergy(maxEnergy)
				user:setUpdateTime(now)
			else
				user:setEnergy(user:getEnergy() + energyInc)
				local notUsedTime = timePast % user_energy_recover_time_unit
				user:setUpdateTime(now - notUsedTime)
			end
			if _G.isLocalDevelopMode then printx(0, "UserLocalLogic->refreshEnergy, updateTime: ", now, os.date(nil, now/1000), " energy:", user:getEnergy(), " energyInc", energyInc) end
		end
	else
		user:setUpdateTime(now)
	end

	return user
end

function UserLocalLogic:getUserEnergyMaxCount(uid)
	local time = Localhost:time()
	local maxEnergy = (MetaManager.getInstance().global.user_energy_max_count or 30) + Achievement:getRightsExtra( "EnergyRecoveryUpperLimit" )
	local userExtend = UserService.getInstance().userExtend
	local energyPlusEffectTime = userExtend:getEnergyPlusEffectTime()
	if energyPlusEffectTime > time then
		local propMeta = MetaManager.getInstance():getPropMeta(userExtend.energyPlusId)
		if propMeta then
			maxEnergy = maxEnergy + propMeta.confidence
		end
	elseif userExtend.energyPlusPermanentId > 0 then
		local propMeta = MetaManager.getInstance():getPropMeta(userExtend.energyPlusPermanentId)
		if propMeta then
			maxEnergy = maxEnergy + propMeta.confidence
		end
	end
	return maxEnergy
end

function UserLocalLogic:getNewUserRewards(id)
	local user = UserService.getInstance().user
	local uid = user.uid

	local rewards = {}
	if id == 1 then
		rewards ={{itemId = ItemType.INFINITE_ENERGY_BOTTLE, num = 1}}
	else
		rewards = MetaManager.getInstance():getNewUserRewards()
	end

	for i, v in ipairs(rewards) do
		local succeed, err = ItemLocalLogic:add(uid, v.itemId, v.num)
		if err ~= nil then return nil, false, err end
	end

	UserService.getInstance().userExtend:setNewUserReward(id)
	return rewards, true
end

function UserLocalLogic:jumpLevel( levelId, pawnNum)
	-- body
	local user = UserService.getInstance().user
	local uid = user.uid
	local result = {}
	local topLevelId = user:getTopLevelId()
	if levelId > topLevelId then
		return false, "levelId > topLevelId"
	end

	UserLocalLogic:insertJumpLevelInfo(levelId, pawnNum)
	if levelId == topLevelId and (not UserLocalLogic:isNewLevelAreaStart(levelId + 1)) then
		local succeed, err = UserLocalLogic:updateTopLevelId(uid, levelId + 1,0)
		if err ~= nil then return false, "UserLocalLogic:updateTopLevelId() err" end
		DcUtil:logLevelUp(levelId + 1)
	end
	return true
end

function UserLocalLogic:addRewardByGuideFlag(flagIndex)
	local rewardId = kGuideRewardConfig[flagIndex]
	if rewardId then 
		local rewards = MetaManager.getInstance():getRewards(rewardId)
		if rewards then
			local http = GetRewardsOfflineHttp.new()
			http:ad(Events.kComplete, function (evt)
				UserManager:getInstance():addRewards(rewards)
		        UserService:getInstance():addRewards(rewards)
		        GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kGuide, rewards, DcSourceType.kGuideFlagReward..flagIndex)

				UserManager:getInstance():setUserRewardBit(rewardId, true)
				UserService:getInstance():setUserRewardBit(rewardId, true)

				if NetworkConfig.writeLocalDataStorage then 
					Localhost:getInstance():flushCurrentUserData()
				end
			end)

			http:load(rewardId)
		else
			assert(false, string.format("guide flag %s , reward id is %s,no rewards config !!!", flagIndex, rewardId))
		end
	end
end

function UserLocalLogic:setGuideFlag(flagIndex)
	local http = OpNotifyOffline.new()
	local function opSuccess()
		UserManager.getInstance():setGuideFlag(flagIndex)
		UserService.getInstance():setGuideFlag(flagIndex)
		Localhost:getInstance():flushCurrentUserData()

		self:addRewardByGuideFlag(flagIndex)
	end
	local function opFail()
	end
	http:ad(Events.kComplete, opSuccess)
    http:ad(Events.kError, opFail)
	http:load(OpNotifyOfflineType.kSetGuideFlag, flagIndex)
end

function UserLocalLogic:setBAFlag(flagIndex)
	local http = OpNotifyOffline.new()
	local function opSuccess()
		UserManager.getInstance():setBAFlag(flagIndex)
		UserService.getInstance():setBAFlag(flagIndex)
		Localhost:getInstance():flushCurrentUserData()
	end
	local function opFail()
	end
	http:ad(Events.kComplete, opSuccess)
    http:ad(Events.kError, opFail)
	http:load(OpNotifyOfflineType.kSetBAFlag, flagIndex)
end

function UserLocalLogic:clearBAFlag(flagIndex)
	local http = OpNotifyOffline.new()
	local function opSuccess()
		UserManager.getInstance():clearBAFlag(flagIndex)
		UserService.getInstance():clearBAFlag(flagIndex)
		Localhost:getInstance():flushCurrentUserData()
	end
	local function opFail()
	end
	http:ad(Events.kComplete, opSuccess)
    http:ad(Events.kError, opFail)
	http:load(OpNotifyOfflineType.kClearBAFlag, flagIndex)
end

function UserLocalLogic:setBAFlagWrapper(flagIndex, value)
	if value then
		UserLocalLogic:setBAFlag(flagIndex)
	else
		UserLocalLogic:clearBAFlag(flagIndex)
	end
end

function UserLocalLogic:incrCMGameOfflinePayCount()
	local uid = UserManager.getInstance().uid
	local userDailyData = Localhost.getInstance():readLocalDailyData(uid, true)
	local count = userDailyData.cmgameOfflinePayCount or 0
	userDailyData.cmgameOfflinePayCount = count + 1
	Localhost.getInstance():writeLocalDailyData(uid, userDailyData)
end

function UserLocalLogic:getCMGameOfflinePayCount()
	local uid = UserManager.getInstance().uid
	local userDailyData = Localhost.getInstance():readLocalDailyData(uid, true)
	return userDailyData.cmgameOfflinePayCount or 0
end

function UserLocalLogic:isCMGameOfflinePayLimited()
	return UserLocalLogic:getCMGameOfflinePayCount() >= UserManager.getInstance():getCMGameOfflinePayLimit()
end

function UserLocalLogic:getDifficultLevelExtraRewards( levelId, oriRewards )
	local extraRewardConfig = MetaManager:getInstance():getLevelExtraRewards(levelId)
	local ret = {}
	local coinIncrease_Icon = extraRewardConfig.coinIncrease
	--按倍数加 乘法
	for _, rewardItem in ipairs(oriRewards) do
		if rewardItem.itemId == ItemType.COIN or rewardItem.itemId == ItemType.ENERGY_LIGHTNING  then
			table.insert(ret, RewardItemRef.new(
				rewardItem.itemId, 
				math.ceil(rewardItem.num * extraRewardConfig.coinIncrease),
				REWARDITEM_AWARDTYPE.LEVELDIFFCULTFLAG
			))
		end
	end

	-- --加法
	-- table.insert(ret, RewardItemRef.new(
	-- 	ItemType.ENERGY_LIGHTNING, 
	-- 	extraRewardConfig.extraEnergy,
	-- 	REWARDITEM_AWARDTYPE.LEVELDIFFCULTFLAGl
	-- ))

	return ret  ,coinIncrease_Icon
end

function UserLocalLogic:getAchiveExtraRewards( addPercent, oriRewards )

    local ret = {}
    local allCoin = 0
	--按倍数加 乘法
	for _, rewardItem in ipairs(oriRewards) do
		if rewardItem.itemId == ItemType.COIN  then
            allCoin= allCoin + rewardItem.num
		end
	end

    if allCoin > 0 then
        table.insert(ret, RewardItemRef.new(
		    ItemType.COIN, 
		    math.ceil(allCoin * addPercent),
		    REWARDITEM_AWARDTYPE.MARKADD
	    ))

        return ret
    end

    return 
end

function UserLocalLogic:addAchiveExtraRewards( result )
    --成就银币加成
    local addPercent = MetaManager.getInstance():getAchiCoinExtraNum()
    if addPercent > 0 then
        local MarkExtraReward = self:getAchiveExtraRewards(addPercent,result)
        if MarkExtraReward then
		    table.addAll(result, MarkExtraReward)
        end
    end
end