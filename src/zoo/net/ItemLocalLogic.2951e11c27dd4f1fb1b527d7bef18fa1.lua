require "zoo.data.MetaManager"
require "zoo.net.UserLocalLogic"
require "hecore.debug.remote"

local NO_DIFF = 0

ItemConstans = create_encrypt_const_integer_table("ItemConstans", {
	ITEM_COIN = 2, --金币
	ITEM_POINT = 3, --积分
	ITEM_ENERGY = 4, --精力值
	ITEM_MARK = 5, --补签
	ITEM_MOVE = 6, --最终加5步
	ITEM_FURIT_ACCELERATE = 7, --果实加速
	ITEM_LADY_BUG_RESTART = 8, --购买瓢虫任务重启
	ITEM_CASH = 14, --风车币
	ITEM_ENERGY_PROP = 100, --精力值上限

	ITEM_TYPE_OTHER = 0, --资源类
	ITEM_TYPE_PROP = 1, --道具类
	ITEM_TYPE_DECO = 2, --装扮类
	ITEM_TYPE_FUNC = 3, --功能礼包类
	ITEM_TYPE_QPOINT = 4, --区域解锁
	ITEM_TYPE_BAG = 5, --背包扩容类
	ITEM_TYPE_RANGE = 10000, --item分段范围

	BUY_MOVE_COUNT = 5, --加五步

	ITEM_ID_LEVEL_AREA_MIN = 40001, --Q点购买区域解锁时 id的最小值,表示第1个区域
	ITEM_ID_LEVEL_AREA_MAX = 40200, --Q点购买区域解锁时 id的最大值,表示第200个区域
})

PropRewardType = table.const{
	PROP_REWARD_TYPE_NONE = 0,
	PROP_REWARD_TYPE_MOVE = 1,
	PROP_REWARD_TYPE_COIN = 2,
	PROP_REWARD_TYPE_ENERGY = 3,
	PROP_REWARD_TYPE_GOLD_BEAN = 4,
	PROP_REWARD_TYPE_ACCELERATE_FURIT = 5,
	PROP_REWARD_TYPE_ENERGY_PLUS = 6,
	PROP_REWARD_TYPE_NOT_CONSUME_ENERGY = 7,
	PROP_REWARD_TYPE_RABBIT_MATCH_TIME = 9
}

function getItemIdByType( itemId )
	return math.floor(itemId / ItemConstans.ITEM_TYPE_RANGE)
end

ConsumeItem = class()
function ConsumeItem:ctor( itemId, num )
	self.itemId = itemId or 0
	self.num = num or 0
end

ItemLocalLogic = class()
function ItemLocalLogic:add( uid, itemId, num, requestTime )
	itemId = itemId or 0
	num = num or 0
	local user = UserService.getInstance().user
	local itemType = getItemIdByType(itemId)
	if itemType == ItemConstans.ITEM_TYPE_OTHER then
		if itemId == ItemConstans.ITEM_COIN then return UserLocalLogic:addCoin(uid, num)
		elseif itemId == ItemConstans.ITEM_CASH then return UserLocalLogic:addCash(uid, num)
		elseif itemId == ItemConstans.ITEM_ENERGY then return UserLocalLogic:addEnergy(uid, num, requestTime)
		elseif itemId == ItemConstans.ITEM_POINT then return UserLocalLogic:addPoint(uid, num)
		elseif itemId == ItemConstans.ITEM_MARK then return ItemLocalLogic:addMarkNum(uid)
		elseif itemId == ItemConstans.ITEM_MOVE then return StageInfoLocalLogic:addBuyMove( uid, ItemConstans.BUY_MOVE_COUNT ) 
		--ItemLocalLogic:addBuyMove(uid, ItemConstans.BUY_MOVE_COUNT)
		end
	elseif itemType == ItemConstans.ITEM_TYPE_PROP then 
		if ItemType:isTimeProp(itemId) then
			return ItemLocalLogic:addTimeProp( uid , itemId , num )
		else
			return ItemLocalLogic:addProp(uid, itemId, num)
		end
	elseif itemType == ItemConstans.ITEM_TYPE_DECO then return ItemLocalLogic:addDeco(uid, itemId, num)
	elseif itemType == ItemConstans.ITEM_TYPE_FUNC then return ItemLocalLogic:addFunc(uid, itemId, num)
	elseif itemType == ItemConstans.ITEM_TYPE_QPOINT then 
		if itemId >= ItemConstans.ITEM_ID_LEVEL_AREA_MIN and itemId <= ItemConstans.ITEM_ID_LEVEL_AREA_MAX then
			return ItemLocalLogic:unLockLevelAreaByQPoint(uid, itemId, num)
		end
	else
		if _G.isLocalDevelopMode then printx(0, "ITEM_TYPE_NOT_SUPPORT", itemId, num) end
		return false, ZooErrorCode.ITEM_TYPE_NOT_SUPPORT
	end
end

function ItemLocalLogic:addMarkNum( uid )
	local mark = UserManager.getInstance().mark
	mark.markNum = mark.markNum + 1
	mark.addNum = mark.addNum + 1
	UserService.getInstance().mark.markNum = mark.markNum
	UserService.getInstance().mark.addNum = mark.addNum

	local markMeta = MetaManager.getInstance():getMarkByNum(mark.markNum)
	if markMeta then ItemLocalLogic:rewards(uid, markMeta.rewards) end
	return true
end

--http://svn.happyelements.net/repos/svndata2/animal/java/trunk/animal-service/src/main/java/com/happyelements/animal/service/impl/PropServiceImpl.java
function ItemLocalLogic:addProp( uid, itemId, num )
	if num < 0 then return false, ZooErrorCode.INVALID_PARAMS end
	-- if itemId == ItemType.SMALL_ENERGY_BOTTLE then
	-- 	Notify:dispatch("AchiEventDataUpdate",AchiDataType.kGetPrimaryEnergyAddCount, num)
	-- end
	local propMeta = MetaManager:getInstance():getPropMeta(itemId)
	if propMeta and propMeta.type then
		local prop = UserService.getInstance():getUserProp(itemId)
		if prop then
			prop:setNum(prop:getNum() + num)
		else
			prop = PropRef.new()
			prop.itemId = itemId
			prop:setNum(num)
			UserService.getInstance():addUserProp(prop)
		end
		return true
	end
	return false, ZooErrorCode.CONFIG_ERROR
end
function ItemLocalLogic:subProp( uid, itemId, num )
	local prop = UserService.getInstance():getUserProp(itemId)
	if prop then
		if prop:getNum() >= num then
			prop:setNum(prop:getNum() - num)
			return true
		else return false, ZooErrorCode.PROP_NOT_ENOUGH end
	end
	return false, ZooErrorCode.CONFIG_ERROR
end
--http://svn.happyelements.net/repos/svndata2/animal/java/trunk/animal-service/src/main/java/com/happyelements/animal/service/impl/DecoServiceImpl.java
function ItemLocalLogic:addDeco( uid, itemId, num )
	if num < 0 then return false, ZooErrorCode.INVALID_PARAMS end
	local deco = UserService.getInstance():getUserDeco(itemId)
	if deco then
		deco:setNum(deco:getNum() + num)
	else
		deco = DecoRef.new()
		deco.itemId = itemId
		deco:setNum(num)
		UserService.getInstance():addUserDeco(deco)
	end
	return true
end
function ItemLocalLogic:subDeco( uid, itemId, num )
	local deco = UserService.getInstance():getUserDeco(itemId)
	if deco then
		if deco:getNum() >= num then
			deco:setNum(deco:getNum() - num)
			return true
		else return false, ZooErrorCode.DECO_NOT_ENOUGH end
	else return false, ZooErrorCode.CONFIG_ERROR end
end
--http://svn.happyelements.net/repos/svndata2/animal/java/trunk/animal-service/src/main/java/com/happyelements/animal/service/impl/FuncServiceImpl.java
function ItemLocalLogic:addFunc( uid, itemId, num )
	if num < 0 then return false, ZooErrorCode.INVALID_PARAMS end
	local func = UserService.getInstance():getUserDeco(itemId)
	if func then
		func:setNum(func:getNum() + num)
	else
		func = FuncRef.new()
		func.itemId = itemId
		func:setNum(num)
		UserService.getInstance():addUserFunc(func)
	end
	return true
end
function ItemLocalLogic:subFunc( uid, itemId, num )
	local func = UserService.getInstance():getUserDeco(itemId)
	if func then
		if func:getNum() >= num then
			func:setNum(func:getNum() - num)
			return true
		else return false, ZooErrorCode.FUNC_NOT_ENOUGH end
	else return false, ZooErrorCode.CONFIG_ERROR end
end

--http://svn.happyelements.net/repos/svndata2/animal/java/trunk/animal-service/src/main/java/com/happyelements/animal/service/impl/LevelAreaServiceImpl.java
function ItemLocalLogic:unLockLevelAreaByQPoint( uid, itemId, num )
	local user = UserService.getInstance().user
	local config = MetaManager:getInstance():getLevelAreaById(itemId)
	if config then
		if (user:getTopLevelId() + 1) == config.minLevel then
			local success, err = UserLocalLogic:updateTopLevelId(uid, config.minLevel, 0)
			if err ~= nil then return false, err end
			user:setTopLevelId(config.minLevel)
		end
	end
	return true
end

--http://svn.happyelements.net/repos/svndata2/animal/java/trunk/animal-service/src/main/java/com/happyelements/animal/service/impl/ItemServiceImpl.java
function ItemLocalLogic:mergeRewards( rewardItems )
	if rewardItems == nil or #rewardItems == 0 then return nil end
	local mapRewardItems = {} --<number, number>
	for i,v in ipairs(rewardItems) do
		local itemId = v.itemId
		local amount = mapRewardItems[itemId] or 0
		amount = amount + v.num
		mapRewardItems[itemId] = amount
	end

	local mergedRewardItems = {}
	for k,v in pairs(mapRewardItems) do
		local entry = RewardItemRef.new(k, v)
		table.insert(mergedRewardItems, entry)
	end
	return mergedRewardItems
end
function ItemLocalLogic:rewards( uid, rewardItems, requestTime )
	if rewardItems == nil or #rewardItems == 0 then return nil end
	local mergedRewardItems = ItemLocalLogic:mergeRewards(rewardItems)
	for i,v in ipairs(mergedRewardItems) do
		local success, err = ItemLocalLogic:add(uid, v.itemId, v.num, requestTime)
		if err ~= nil then return false, err end
	end
	return true
end

--http://svn.happyelements.net/repos/svndata2/animal/java/trunk/animal-service/src/main/java/com/happyelements/animal/service/impl/ScoreServiceImpl.java
function ItemLocalLogic:getUserScores( uid, levelIds )
	local result = {}
	local scores = UserService.getInstance().scores
	local mapScore = {}
	for i,v in ipairs(scores) do
		mapScore[v.levelId] = v
	end
	for i,v in ipairs(levelIds) do
		local score = mapScore[v]
		table.insert(result, score)
	end
	return result
end
--http://svn.happyelements.net/repos/svndata2/animal/java/trunk/animal-service/src/main/java/com/happyelements/animal/service/impl/ScoreServiceImpl.java
function ItemLocalLogic:getUserAllScores( uid )
	local user = UserService.getInstance().user
	local topLevelId = user:getTopLevelId()
	local levelIds = {}
	for i=1,topLevelId do table.insert(levelIds, i) end
	local hideLevelIds = MetaManager.getInstance():getHideAreaLevelIds()
	for i,v in ipairs(hideLevelIds) do table.insert(levelIds, v) end
	--digger match activity level id start
	return ItemLocalLogic:getUserScores(uid, levelIds)
end

--http://svn.happyelements.net/repos/svndata2/animal/java/trunk/animal-service/src/main/java/com/happyelements/animal/service/impl/HideAreaServiceImpl.java
--TODO: test this.
function ItemLocalLogic:checkHideAreaUnLocked( uid, hideLevelId )
	local target = MetaManager.getInstance():getHideAreaByHideLevelId(hideLevelId)
	assert(target, "hide area config error!")
	local checkResult = false
	local ANIMAL_SCORE_THREE_STAR = 3
	
	if #target.continueLevels > 0 then
		local animalScores = ItemLocalLogic:getUserScores(uid, target.continueLevels)
		local totalStar = 0
		for i,v in ipairs(animalScores) do
			totalStar = totalStar + v.star
		end

		if totalStar >= (ANIMAL_SCORE_THREE_STAR * #target.continueLevels) then
			checkResult = true
		end
	end
	
	if not checkResult and target.hideAreaId ~= 0 then
		local dependMeta = MetaManager.getInstance().hide_area[target.hideAreaId]
		assert(dependMeta, "[dependMeta] hide area config error!")
		local dependHideLevelIds = {}
		for i,v in ipairs(dependMeta.hideLevelRange) do
			table.insert(dependHideLevelIds, v + LevelConstans.HIDE_LEVEL_ID_START)
		end

		local animalScores = ItemLocalLogic:getUserScores(uid, dependHideLevelIds)
		local totalStar = 0
		for i,v in ipairs(animalScores) do
			totalStar = totalStar + v.star
		end
		if totalStar >= (ANIMAL_SCORE_THREE_STAR * #dependHideLevelIds) then
			checkResult = true
		end
	end

	return checkResult
end

function ItemLocalLogic:getPropCount( uid, itemId )
	local prop = UserService.getInstance():getUserProp(itemId)
	if prop then return prop:getNum() or 0 end
	return 0
end
function ItemLocalLogic:getDecoCount( uid, itemId )
	local deco = UserService.getInstance():getUserDeco(itemId)
	if deco then return deco:getNum() or 0 end
	return 0
end
function ItemLocalLogic:getFuncCount( uid, itemId )
	local func = UserService.getInstance():getUserFunc(itemId)
	if func then return func:getNum() or 0 end
	return 0
end
--http://svn.happyelements.net/repos/svndata2/animal/java/trunk/animal-service/src/main/java/com/happyelements/animal/service/impl/ItemServiceImpl.java
function ItemLocalLogic:hasConsume( uid, consumeItem )
	if not consumeItem then return true end
	local user = UserService.getInstance().user
	local itemId = consumeItem.itemId
	local amount = consumeItem.num
	local itemType =  getItemIdByType(itemId)
	if itemType == ItemConstans.ITEM_TYPE_OTHER then
		if itemId == ItemConstans.ITEM_COIN then
			if user:getCoin() < amount then return false, ZooErrorCode.COIN_NOT_ENOUGH end
		elseif itemId == ItemConstans.ITEM_CASH then
			if user:getCash() < amount then return false, ZooErrorCode.CASH_NOT_ENOUGH end
		elseif itemId == ItemConstans.ITEM_ENERGY then 
			if user:getEnergy() < amount then return false, ZooErrorCode.ENERGY_NOT_ENOUGH end
		elseif itemId == ItemConstans.ITEM_POINT then 
			if user.point < amount then return false, ZooErrorCode.POINT_NOT_ENOUGH end
		end
	elseif itemType == ItemConstans.ITEM_TYPE_PROP then 
		local propCount = ItemLocalLogic:getPropCount(uid, itemId)
		if propCount < amount then return false, ZooErrorCode.PROP_NOT_ENOUGH end
	elseif itemType == ItemConstans.ITEM_TYPE_DECO then
		local decoCount = ItemLocalLogic:getDecoCount(uid, itemId)
		if decoCount < amount then return false, ZooErrorCode.DECO_NOT_ENOUGH end
	elseif itemType == ItemConstans.ITEM_TYPE_FUNC then
		local funcCount = ItemLocalLogic:getFuncCount(uid, itemId)
		if funcCount < amount then return false, ZooErrorCode.FUNC_NOT_ENOUGH end
	else
		return false, ZooErrorCode.ITEM_TYPE_NOT_SUPPORT
	end
	return true
end

function ItemLocalLogic:hasConsumes( uid, consumeItems )
	if not consumeItems or #consumeItems == 0 then return true end

	for i,v in ipairs(consumeItems) do
		local succeed, err = ItemLocalLogic:hasConsume(uid, v)
		if succeed then
			--do nothing.
		else return false, err end
	end
	return true
end

function ItemLocalLogic:consume( uid, consumeItem )
	if not consumeItem then return true end
	local user = UserService.getInstance().user
	local itemId = consumeItem.itemId
	local amount = consumeItem.num
	local itemType =  getItemIdByType(itemId)
	if itemType == ItemConstans.ITEM_TYPE_OTHER then
		if itemId == ItemConstans.ITEM_COIN then return UserLocalLogic:subCoin(uid, amount) 
		elseif itemId == ItemConstans.ITEM_CASH then return UserLocalLogic:subCash(uid, amount) 
		elseif itemId == ItemConstans.ITEM_ENERGY then return UserLocalLogic:subEnergy(uid, amount) 
		elseif itemId == ItemConstans.ITEM_POINT then return UserLocalLogic:subPoint(uid, amount) end
	elseif itemType == ItemConstans.ITEM_TYPE_PROP then return ItemLocalLogic:subProp(uid, itemId, amount) 
	elseif itemType == ItemConstans.ITEM_TYPE_DECO then return ItemLocalLogic:subDeco(uid, itemId, amount) 
	elseif itemType == ItemConstans.ITEM_TYPE_FUNC then return ItemLocalLogic:subFunc(uid, itemId, amount) 
	else return false, ZooErrorCode.ITEM_TYPE_NOT_SUPPORT end
	return true
end

function ItemLocalLogic:consumes( uid, consumeItems )
	if not consumeItems or #consumeItems == 0 then return true end

	for i,v in ipairs(consumeItems) do
		local succeed, err = ItemLocalLogic:consume(uid, v)
		if succeed then
			--do nothing.
		else return false, err end
	end
	
	return true
end

function ItemLocalLogic:hasEnoughTimeProps(uid, itemIds)
	local itemNums = {}
	for _,v in pairs(itemIds) do
		local num = itemNums[v] or 0
		itemNums[v] = num + 1
	end

	for itemId,num in pairs(itemNums) do
		if UserService.getInstance():getUserTimePropNumber(itemId) < num then
			return false, ZooErrorCode.PROP_NOT_ENOUGH
		end
	end
	return true
end

function ItemLocalLogic:useTimeProps(uid, itemIds)
	for _,v in pairs(itemIds) do
		UserService.getInstance():useTimeProp(v)
	end
end

function ItemLocalLogic:addTimeProp( uid  ,itemId , num, expireTime )

	if num < 0 then return false, ZooErrorCode.INVALID_PARAMS end
	local propMeta = MetaManager:getInstance():getPropMeta(itemId)
	if propMeta and propMeta.type then
		UserService.getInstance():addTimeProp( itemId , num, expireTime )
		return true
	end
	return false, ZooErrorCode.CONFIG_ERROR
end