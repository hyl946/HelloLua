require "zoo.gamePlay.BoardLogic.ProductItemDiffChangeLogic"

local __logicVer = 1

ProductItemLogic = class{}
--产生顺序， 应包括所有可能掉落规则中存在的类型
--有专有掉落口的 cannonType = 专有掉落类型 否则就用GameBoardFallType.kNone
-- cannonId = 独立的掉落口id，没有的不写
local ProductRuleOrder = table.const{
	-- itemId 只当做key使用，注意和itemID（配置中droprule用到的itemID）的区别
	{cannonType = TileConst.kCannonBlocker195, itemId = TileConst.kBlocker195, property = Blocker195CollectType.kLine},
	{cannonType = TileConst.kCannonBlocker195, itemId = TileConst.kBlocker195, property = Blocker195CollectType.kWrap},
	{cannonType = TileConst.kCannonBlocker195, itemId = TileConst.kBlocker195, property = Blocker195CollectType.kLock},
	{cannonType = TileConst.kCannonBlocker195, itemId = TileConst.kBlocker195, property = Blocker195CollectType.kCoin},
	{cannonType = TileConst.kCannonBlocker195, itemId = TileConst.kBlocker195, property = Blocker195CollectType.kSnow},
	{cannonType = TileConst.kCannonBlocker195, itemId = TileConst.kBlocker195, property = Blocker195CollectType.kGreyCute},
	{cannonType = TileConst.kCannonBlocker195, itemId = TileConst.kBlocker195, property = Blocker195CollectType.kBrownCute},
	{cannonType = TileConst.kCannonBlocker195, itemId = TileConst.kBlocker195, property = Blocker195CollectType.kBlackCute},
	{cannonType = TileConst.kCannonBlocker195, itemId = TileConst.kBlocker195, property = Blocker195CollectType.kPoison},
	{cannonType = TileConst.kCannonBlocker195, itemId = TileConst.kBlocker195, property = Blocker195CollectType.kDigGround},
	{cannonType = TileConst.kCannonBlocker195, itemId = TileConst.kBlocker195, property = Blocker195CollectType.kHoneyBottle},
	{cannonType = TileConst.kCannonBlocker195, itemId = TileConst.kBlocker195, property = Blocker195CollectType.kHoney},
	{cannonType = TileConst.kCannonBlocker195, itemId = TileConst.kBlocker195, property = Blocker195CollectType.kSand},
	{cannonType = TileConst.kCannonBlocker195, itemId = TileConst.kBlocker195, property = Blocker195CollectType.kBottleBlocker},
	{cannonType = TileConst.kCannonBlocker195, itemId = TileConst.kBlocker195, property = Blocker195CollectType.kSuperCute},
	{cannonType = TileConst.kCannonBlocker195, itemId = TileConst.kBlocker195, property = Blocker195CollectType.kPuffer},
	{cannonType = TileConst.kCannonBlocker195, itemId = TileConst.kBlocker195, property = Blocker195CollectType.kMissile},
	{cannonType = TileConst.kCannonBlocker195, itemId = TileConst.kBlocker195, property = Blocker195CollectType.kColorFilter},
	{cannonType = TileConst.kCannonBlocker195, itemId = TileConst.kBlocker195, property = Blocker195CollectType.kChameleon},
	{cannonType = TileConst.kCannonBlocker195, itemId = TileConst.kBlocker195, property = Blocker195CollectType.kGhost},
	{cannonType = TileConst.kCannonPuffer, itemId = TileConst.kPuffer},
	{cannonType = TileConst.kCannonPufferActivated, itemId = TileConst.kPufferActivated},
	{cannonType = TileConst.kCannonTotems, itemId = TileConst.kTotems},
	{cannonType = TileConst.kCannonHoneyBottle, itemId = TileConst.kHoneyBottle}, 
	{cannonType = TileConst.kCannonBalloon, itemId = TileConst.kBalloon}, 
	{cannonType = 0, itemId = TileConst.kAddTime}, 
	{cannonType = 0, itemId = TileConst.kAddMove}, 
	{cannonType = TileConst.kCannonBlocker207, itemId = TileConst.kBlocker207}, 
	{cannonType = TileConst.kCannonGreyCuteBall, itemId = TileConst.kGreyCute}, 
	{cannonType = TileConst.kCannonBrownCuteBall, itemId = TileConst.kBrownCute}, 
	{cannonType = TileConst.kCannonBlackCuteBall, itemId = TileConst.kBlackCute}, 
	{cannonType = TileConst.kCannonCoin, itemId = TileConst.kCoin}, 
	{cannonType = TileConst.kCannonCandyMissile, itemId = TileConst.kMissile},	
	{cannonType = TileConst.kCannonCrystallBall, itemId = TileConst.kCrystal}, 
	{cannonType = 0, itemId = TileConst.kQuestionMark}, 
	{cannonType = TileConst.kCannonRocket, itemId = TileConst.kRocket}, 
	{cannonType = TileConst.kCannonCrystalStone, itemId = TileConst.kCrystalStone},
	{cannonType = TileConst.kCannonDrip, itemId = TileConst.kDrip},
	{cannonType = TileConst.kCannonCandyLineEffectColumn, itemId = TileConst.kCannonCandyLineEffectColumn},	
	{cannonType = TileConst.kCannonCandyLineEffectRow, itemId = TileConst.kCannonCandyLineEffectRow},	
	{cannonType = TileConst.kCannonCandyWrapEffect, itemId = TileConst.kCannonCandyWrapEffect},	
	{cannonType = TileConst.kCannonCandyMagicBird, itemId = TileConst.kCannonCandyMagicBird},
	{cannonType = TileConst.kCannonChameleon, itemId = TileConst.kChameleon},
    {cannonType = TileConst.kWanShengDrop, itemId = TileConst.kWanSheng},
}

local checkBlockCanProductReason = table.const{
	kSuccessByNormal = 1,
	kSuccessByMinNum = 2,
	kFailedByMoveTarget = 3,
	kFailedByBlockSpawnDensity = 4,
	kFailedByMaxNum = 5,
	kFailedByDropNumLimit = 6,
	kFailedByUnknow = 7,
}

function ProductItemLogic:getTileFallTypes(tileDef)
	local types = {}

	--TODO jinghui 下面这些值在两个表里面都是完全相同，可以改成循环（区别是GameBoardFallType中的kNone和kCannonAll有特殊用途）
	if tileDef:hasProperty(TileConst.kCannonPuffer)then table.insert(types, TileConst.kCannonPuffer) end
	if tileDef:hasProperty(TileConst.kCannonPufferActivated)then table.insert(types, TileConst.kCannonPufferActivated) end
	if tileDef:hasProperty(TileConst.kCannonAnimal)then table.insert(types, TileConst.kCannonAnimal) end	--是否是生成口	--39
	if tileDef:hasProperty(TileConst.kCannonIngredient)then table.insert(types, TileConst.kCannonIngredient) end	--是否是生成口	--40
	if tileDef:hasProperty(TileConst.kCannonBlock)then table.insert(types, TileConst.kCannonBlock) end	--是否是生成口	--41
	if tileDef:hasProperty(TileConst.kCannonCoin) then table.insert(types, TileConst.kCannonCoin) end 
	if tileDef:hasProperty(TileConst.kCannonCrystallBall) then table.insert(types, TileConst.kCannonCrystallBall) end 
	if tileDef:hasProperty(TileConst.kCannonBalloon) then table.insert(types, TileConst.kCannonBalloon) end 
	if tileDef:hasProperty(TileConst.kCannonHoneyBottle) then table.insert(types, TileConst.kCannonHoneyBottle) end 
	if tileDef:hasProperty(TileConst.kCannonGreyCuteBall) then table.insert(types, TileConst.kCannonGreyCuteBall) end 
	if tileDef:hasProperty(TileConst.kCannonBrownCuteBall) then table.insert(types, TileConst.kCannonBrownCuteBall) end 
	if tileDef:hasProperty(TileConst.kCannonBlackCuteBall) then table.insert(types, TileConst.kCannonBlackCuteBall) end 
	if tileDef:hasProperty(TileConst.kCannonRocket) then table.insert(types, TileConst.kCannonRocket) end 
	if tileDef:hasProperty(TileConst.kCannonCrystalStone) then table.insert(types, TileConst.kCannonCrystalStone) end 
	if tileDef:hasProperty(TileConst.kCannonTotems) then table.insert(types, TileConst.kCannonTotems) end 
	if tileDef:hasProperty(TileConst.kCannonDrip) then table.insert(types, TileConst.kCannonDrip) end 
	if tileDef:hasProperty(TileConst.kCannonCandyLineEffectColumn) then table.insert(types, TileConst.kCannonCandyLineEffectColumn) end 
	if tileDef:hasProperty(TileConst.kCannonCandyLineEffectRow) then table.insert(types, TileConst.kCannonCandyLineEffectRow) end 
	if tileDef:hasProperty(TileConst.kCannonCandyWrapEffect) then table.insert(types, TileConst.kCannonCandyWrapEffect) end 
	if tileDef:hasProperty(TileConst.kCannonCandyMagicBird) then table.insert(types, TileConst.kCannonCandyMagicBird) end 
	if tileDef:hasProperty(TileConst.kCannonCandyColouredAnimal) then table.insert(types, TileConst.kCannonCandyColouredAnimal) end 
	if tileDef:hasProperty(TileConst.kCannonCandyMissile) then table.insert(types, TileConst.kCannonCandyMissile) end
	if tileDef:hasProperty(TileConst.kCannonBlocker195) then 
		local subtypes = tileDef:getAttrOfProperty(TileConst.kCannonBlocker195):split('~')
		for _, subtype in pairs(subtypes) do
			table.insert(types, TileConst.kCannonBlocker195..'_'..subtype)
		end
	end
	if tileDef:hasProperty(TileConst.kCannonChameleon) then table.insert(types, TileConst.kCannonChameleon) end
	if tileDef:hasProperty(TileConst.kCannonBlocker207) then table.insert(types, TileConst.kCannonBlocker207) end
	if tileDef:hasProperty(TileConst.kWanShengDrop) then table.insert(types, TileConst.kWanShengDrop) end

	if not tileDef:hasProperty(TileConst.kCannon) then types = {} end --处理脏数据，没有生成口的格子，即时有掉落数据，也不生效。

	if #types <= 0 and tileDef:hasProperty(TileConst.kCannon) then table.insert(types, TileConst.kCannon) end	--是否是生成口	--5
	
	return types
end

function ProductItemLogic:init(mainLogic, config , logicVer)

	__logicVer = logicVer or 1
	mainLogic.ingredientsMoveCount = 0
	mainLogic.ingredientSpawnDensity = config.ingredientSpawnDensity
	if not mainLogic.ingredientSpawnDensity then
		mainLogic.ingredientSpawnDensity = 5
	end
	mainLogic.ingredientsShouldCome = false
	mainLogic.ingredientsTotalCount = mainLogic.ingredientsTotal - config.numIngredientsOnScreen
	mainLogic.everyStepDropNum = config.everyStepDropNum
	mainLogic.dropNumCached = 0

	mainLogic.snailCount = mainLogic.snailCount or 0
	mainLogic.snailMoveCount = 0
	mainLogic.snailSpawnDensity = config.snailMoveToAdd
	mainLogic.snailTotalCount = mainLogic:getSnailTotalCount()

	mainLogic.blockProductRules = {};

	mainLogic.cachePool = {}
	mainLogic.productCannonCountMap = {}

	--------------------------------------------
	--以下字段是新掉落规则框架下的字段
	mainLogic.singleDropConfigGroup = {}         --分组存储的掉落颜色配置
	mainLogic.productRuleGroup = {}              --分组存储的掉落规则配置
	mainLogic.productRuleConfig = {}             --储存每个掉落口对应的组ID，默认配置存在坐标0_0上
	mainLogic.productRuleGlobalConfig = {}       --全局配置的Q和P信息，将覆盖productRuleGroup里的对应字段
	mainLogic.cachePoolV2 = {}                   --新版cachePool，分组存储

	mainLogic.defaultProductRule = {}
	---------------------------------------------


	local function getItemTypeInfoByItemID( itemID )

		local itemType
		local specialType = 0
		local otherInfo = nil
		local itemId, itemIdParams = ResUtils:getDropRuleItemId( itemID )

		if itemId == TileConst.kCrystal - 1 then
			itemType = GameItemType.kCrystal 
		elseif itemId == TileConst.kBalloon - 1 then
			itemType = GameItemType.kBalloon 
		elseif itemId == TileConst.kCoin - 1 then
			itemType = GameItemType.kCoin
		elseif itemId == TileConst.kMissile - 1 then 
			itemType = GameItemType.kMissile
		elseif itemId == TileConst.kBlackCute -1 then
			itemType = GameItemType.kBlackCuteBall
		elseif itemId == TileConst.kHoneyBottle - 1 then
			itemType = GameItemType.kHoneyBottle
		elseif itemId == TileConst.kAddTime - 1 then
			itemType = GameItemType.kAddTime
		elseif itemId == TileConst.kQuestionMark - 1 then
			itemType = GameItemType.kQuestionMark
		elseif itemId == TileConst.kBrownCute - 1 then
			itemType = GameItemType.kAnimal
		elseif itemId == TileConst.kGreyCute -1 then
			itemType = GameItemType.kAnimal
		elseif itemId == TileConst.kAddMove - 1 then 
			itemType = GameItemType.kAddMove
		elseif itemId == TileConst.kRocket - 1 then 
			itemType = GameItemType.kRocket
		elseif itemId == TileConst.kCrystalStone - 1 then 
			itemType = GameItemType.kCrystalStone
		elseif itemId == TileConst.kTotems - 1 then 
			itemType = GameItemType.kTotems
		elseif itemId == TileConst.kDrip - 1 then 
			itemType = GameItemType.kDrip
		elseif itemId == TileConst.kPuffer - 1 then
			itemType = GameItemType.kPuffer
			otherInfo = PufferState.kNormal
		elseif itemId == TileConst.kPufferActivated - 1 then 
			itemType = GameItemType.kPuffer
			otherInfo = PufferState.kActivated
		elseif itemId == TileConst.kCannonCandyLineEffectColumn - 1 then 
			itemType = GameItemType.kAnimal
			specialType = AnimalTypeConfig.kColumn
		elseif itemId == TileConst.kCannonCandyLineEffectRow - 1 then 
			itemType = GameItemType.kAnimal
			specialType = AnimalTypeConfig.kLine
		elseif itemId == TileConst.kCannonCandyWrapEffect - 1 then 
			itemType = GameItemType.kAnimal
			specialType = AnimalTypeConfig.kWrap
		elseif itemId == TileConst.kCannonCandyMagicBird - 1 then 
			itemType = GameItemType.kAnimal
			specialType = AnimalTypeConfig.kColor
		elseif itemId == TileConst.kCannonCandyColouredAnimal - 1 then 
			itemType = GameItemType.kAnimal
		elseif itemId == TileConst.kBlocker195 - 1 then
			itemType = GameItemType.kBlocker195
			otherInfo = itemIdParams
		elseif itemId == TileConst.kChameleon - 1 then 
			itemType = GameItemType.kChameleon
		elseif itemId == TileConst.kBlocker207 - 1 then
			itemType = GameItemType.kBlocker207
        elseif itemId == TileConst.kWanSheng - 1 then
			itemType = GameItemType.kWanSheng
		end

		return itemType , specialType , otherInfo
	end

	if config.productRuleGroup and #config.productRuleGroup > 0 then
		mainLogic.productRuleConfig = config.productRuleConfig or {}
		mainLogic.defaultProductRuleGroupId = mainLogic.productRuleConfig["0_0"]
		mainLogic.productRuleGlobalConfig = config.productRuleGlobalConfig or {}

		for k,v in ipairs( config.productRuleGroup ) do
			mainLogic.productRuleGroup[k] = {}
			mainLogic.singleDropConfigGroup[k] = {}
			mainLogic.cachePoolV2[k] = {}
			for k2 , v2 in ipairs( v ) do

				local itemType , specialType , otherInfo = getItemTypeInfoByItemID( v2.dropRuleVO.itemID )
				mainLogic.cachePoolV2[k][ v2.dropRuleVO.itemID ] = {}

				if itemType then
					local dropRuleVO = self:buildBlockRule( itemType , v2.dropRuleVO , specialType , otherInfo , mainLogic.productRuleGlobalConfig )
					table.insert( mainLogic.productRuleGroup[k] , dropRuleVO )

					if v2.singleDrop then
						for k3 , v3 in pairs(v2.singleDrop) do
							

							mainLogic.singleDropConfigGroup[k][ tonumber(k3) + 1 ] = LevelConfig:getRealColorValues(v3) --这里的k3是tileId(PC版本，需要+1)，如果以后有类似于带颜色的星星瓶之类的道具，那就跪了
						end
					end

					if v2.dropCrystalStoneTypes then
						mainLogic.singleDropConfigGroup[k][ TileConst.kCrystalStone ] = LevelConfig:getRealColorValues(v2.dropCrystalStoneTypes)
					end
					
				end
			end
			-- v.dropRuleVO
		end

		if mainLogic.defaultProductRuleGroupId and mainLogic.productRuleGroup[ mainLogic.defaultProductRuleGroupId ] then
	 		mainLogic.defaultProductRule = mainLogic.productRuleGroup[ mainLogic.defaultProductRuleGroupId ]
	 	end
	else
		mainLogic.cachePoolV2[1] = {}

		for __, v in ipairs(config.dropRules) do

			local itemType , specialType , otherInfo = getItemTypeInfoByItemID( v.itemID )

			-- mainLogic.cachePool[v.itemID] = {}
			if itemType then 
				local dropRuleVO = self:buildBlockRule( itemType , v , specialType , otherInfo )
				table.insert( mainLogic.defaultProductRule , dropRuleVO )

				-- printx( 1 , "AQAAAAAAAAAAAAAAAAAAAAAAAAAAA dropRuleVO = " , table.tostring(dropRuleVO) )

				mainLogic.cachePoolV2[1][ dropRuleVO.id ] = {}
			end
		end

		if #mainLogic.defaultProductRule > 0 then
			mainLogic.defaultProductRuleGroupId = 1
			mainLogic.productRuleGroup[ mainLogic.defaultProductRuleGroupId ] = mainLogic.defaultProductRule
			mainLogic.productRuleConfig["0_0"] = mainLogic.defaultProductRuleGroupId
		end

		if config.singleDropCfg then
			mainLogic.singleDropConfigGroup[1] = config.singleDropCfg
			-- mainLogic.singleDrop = config.singleDropCfg
		end
	end
 	
 	--
--
--
--
--
--
--
--
--
--




	ProductItemLogic:initRabbitProducer(mainLogic)
	-- local function getItemTypeInfoByItemID( itemID )

end


function ProductItemLogic:getCurrCachePool( mainLogic , r , c )
	if mainLogic.productRuleConfig[ tostring(r) .. "_" .. tostring(c) ] then
		local ruleGroupId = mainLogic.productRuleConfig[ tostring(r) .. "_" .. tostring(c) ]
		local rules = mainLogic.productRuleGroup[ ruleGroupId ]
		if rules and #rules > 0 then

			local cachePool = mainLogic.cachePoolV2[ ruleGroupId ]
			if not cachePool then
				assert( false , "updateCachePoolV2 cachePool is nil  AAA  level:" .. tostring(mainLogic.level) 
					.. " moves:" .. tostring(mainLogic.realCostMove) .. " r:" .. tostring(r) .. " c:" .. tostring(c) 
					.. " ruleGroupId:" .. tostring(ruleGroupId))
				return {}
			end

			return cachePool
		else
			return self:getDefaultCachePool( mainLogic )
		end
		
	else
		return self:getDefaultCachePool( mainLogic )
	end
end

function ProductItemLogic:getDefaultCachePool( mainLogic )
	if mainLogic.cachePoolV2[ mainLogic.productRuleConfig[ "0_0" ] ] then
		return mainLogic.cachePoolV2[ mainLogic.productRuleConfig[ "0_0" ] ]
	else
		return mainLogic.cachePool
	end
end

function ProductItemLogic:getCurrProductRules( mainLogic , r , c )

	-- printx( 1 , "getCurrProductRules  `````````````````````" , r , c)
	-- printx( 1 , "getCurrProductRules  productRuleConfig =" , table.tostring( mainLogic.productRuleConfig ) )
	if mainLogic.productRuleConfig[ tostring(r) .. "_" .. tostring(c) ] then
		local ruleGroupId = mainLogic.productRuleConfig[ tostring(r) .. "_" .. tostring(c) ]
		local rules = mainLogic.productRuleGroup[ ruleGroupId ]

		if rules and #rules > 0 then
			return rules
		else
			return mainLogic.defaultProductRule
		end
	else
		return mainLogic.defaultProductRule
	end
end

function ProductItemLogic:getDefaultProductRules( mainLogic )
	return mainLogic.defaultProductRule
end

function ProductItemLogic:getCurrSingleDropCfg( mainLogic , r , c )
	local id = self:getDropRuleGroupIdByPos( mainLogic , r , c )
	if mainLogic.singleDropConfigGroup then
		return mainLogic.singleDropConfigGroup[id]
	end
end

function ProductItemLogic:getDefaultSingleDropCfg( mainLogic )
	if mainLogic.singleDropConfigGroup then
		return mainLogic.singleDropConfigGroup[ mainLogic.defaultProductRuleGroupId ]
	end
end

function ProductItemLogic:getDropRuleGroupIdByPos( mainLogic , r , c )
	if mainLogic.productRuleConfig[ tostring(r) .. "_" .. tostring(c) ] then
		return mainLogic.productRuleConfig[ tostring(r) .. "_" .. tostring(c) ]
	else
		return mainLogic.defaultProductRuleGroupId
	end
end

function ProductItemLogic:buildBlockRule( itemType , ruleConfig , specialType , otherInfo , globalConfig )
	local blockRule = {}
	blockRule.id = ruleConfig.itemID --唯一标识
	blockRule.itemID = ResUtils:getDropRuleItemId(ruleConfig.itemID)  --TileId
	blockRule.itemType = itemType
	blockRule.specialType = specialType
	blockRule.otherInfo = otherInfo
	blockRule.blockProductType = ruleConfig.ruleType
	blockRule.blockMoveCount = 0  --当前已经走了多少步，即CurrM
	blockRule.blockMoveTarget = 0  --每走多少步触发掉落，即M
	blockRule.blockShouldCome = false
	
	if ruleConfig.ruleType == 1 or ruleConfig.ruleType == 4 or ruleConfig.ruleType == 5 then 
		blockRule.blockMoveTarget = ruleConfig.thresholdSteps                --每移动blockMoveTarget掉落
		blockRule.blockSpawnDensity = ruleConfig.dropNum or 1                --每次最多掉落个数(每次触发后应该产生的个数，即N)
		blockRule.blockSpawned = 0--blockRule.blockSpawnDensity          --一次触发掉落已经产生的个数（每次触发后实际产生的个数，即currN）
		blockRule.maxNum = ruleConfig.maxNum or 0                            --棋盘上最多存在的个数
		blockRule.minNum = ruleConfig.minNum or 0 	
		if blockRule.minNum > blockRule.maxNum and blockRule.maxNum > 0 then blockRule.minNum = blockRule.maxNum end
		blockRule.dropNumLimit = ruleConfig.dropTotalNum or 0                --掉落dropNumLimit个不再掉落（最大掉落个数，即T）
		blockRule.totalDroppedNum = 0                                    --本局已经掉落的个数（当前掉落个数）

		if globalConfig then
			if globalConfig[ blockRule.id ] then
				local gcfg = globalConfig[ blockRule.id ]
				blockRule.maxNum = gcfg.maxNum or 0
				if gcfg.minNum and gcfg.minNum > 0 then
					blockRule.minNum = gcfg.minNum or 0
				end
				if blockRule.minNum > blockRule.maxNum and blockRule.maxNum > 0 then blockRule.minNum = blockRule.maxNum end
			end
		end

	elseif ruleConfig.ruleType == 2 then
		blockRule.blockSpawned = 0
		blockRule.maxNum = 0
		blockRule.minNum = 0
		blockRule.blockSpawnDensity = ruleConfig.thresholdSteps
		blockRule.dropNumLimit = ruleConfig.dropTotalNum or 0
		blockRule.totalDroppedNum = 0
	end

	return blockRule
end

function ProductItemLogic:initRabbitProducer(mainLogic)
	local producers = {}
	for r = 1, #mainLogic.boardmap do 
		for c = 1, #mainLogic.boardmap[r] do 
			local board = mainLogic.boardmap[r][c]
			if board and board.isRabbitProducer then
				table.insert(producers, {r = r, c = c})
			end
		end
	end
	mainLogic.rabbitProducers = producers
end


function ProductItemLogic:getProductItemIdByCannonType( cannonType )
	for k,v in pairs( ProductRuleOrder ) do
		if v.cannonType == cannonType then
			return v.itemId
		end
	end

	return cannonType
end

function ProductItemLogic:product(mainLogic, r, c)

	if not mainLogic.boardmap[r][c].isProducer then return nil end
	
	local theGameBoardFallType = mainLogic.boardmap[r][c].theGameBoardFallType
	-- printx( 1 , "  =================== ProductItemLogic:product ======================== " , r, c)
	ProductItemLogic:updateCachePoolV2( mainLogic , r , c )

	-- printx( 1 , "ProductItemLogic:product " , r , c ,"  cachePoolV2 =" , table.tostring(mainLogic.cachePoolV2)  , "\n==================================\n\n\n\n")

	if not mainLogic.productCannonCountMap then
		mainLogic.productCannonCountMap = {}
	end

	if table.exist(theGameBoardFallType, TileConst.kCannonIngredient) then
		local res = ProductItemLogic:productIngredient(mainLogic)
		if res then return res end 
	end

	for k = 1, #ProductRuleOrder do 
		local ruleItem = ProductRuleOrder[k]
		local cannonType = ruleItem.cannonType
		local ruleId = ruleItem.itemId - 1
		if ruleItem.property then
			cannonType = cannonType .. '_' .. ruleItem.property
			ruleId = ruleId .. '_' .. ruleItem.property
		end
		--if _G.isLocalDevelopMode then printx(0, "theGameBoardFallType",table.tostring(theGameBoardFallType)) end
		--if _G.isLocalDevelopMode then printx(0, "???????;;;;;;;;;;;;;;;;; ", cannonType, ruleId) end
		if table.exist(theGameBoardFallType, cannonType) then 
			--if _G.isLocalDevelopMode then printx(0, "??????? ", k, ruleItem.cannonType,table.tostring(ruleItem)) end
			local res = ProductItemLogic:productBlock(mainLogic, ruleId, ruleItem.itemId - 1 , r, c)
			-- if _G.isLocalDevelopMode then printx(0, "%%%%%% prepare product block %%%%%%",ruleItem.itemId - 1 ,"row",r,"col",c, table.tostring(res)) end
			if res then 
				ProductItemDiffChangeLogic:falsify(res , cannonType , {r=r,c=c})
				return res 
			end
		end
	end

	if table.exist(theGameBoardFallType, TileConst.kCannonCandyColouredAnimal) then
		--printx( 1 , "ProductItemLogic:product ??????????????????????????????????????????????????   ")
		local res = ProductItemLogic:productBlock(mainLogic, TileConst.kCannonCandyColouredAnimal - 1, TileConst.kCannonCandyColouredAnimal - 1, r, c)
		if res then 
			ProductItemDiffChangeLogic:falsify(res , TileConst.kCannonCandyColouredAnimal , {r=r,c=c})
			return res 
		end 
	end

	if table.exist(theGameBoardFallType, TileConst.kCannonBlock) then
		local res = ProductItemLogic:productBlock(mainLogic, nil, nil, r, c)
		if res then 
			ProductItemDiffChangeLogic:falsify(res , TileConst.kCannonBlock , {r=r,c=c})
			return res 
		end 
	end

	if table.exist(theGameBoardFallType, TileConst.kCannon) then
		local res = ProductItemLogic:productIngredient(mainLogic)
		if not res then res = ProductItemLogic:productBlock(mainLogic, nil, nil, r, c) end
		if res then 
			ProductItemDiffChangeLogic:falsify(res , TileConst.kCannon , {r=r,c=c})
			return res 
		end 
	end

	res = ProductItemLogic:productAnimal(mainLogic , r , c)
	--printx( 1 , "ProductItemLogic:product 	!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   ")
	ProductItemDiffChangeLogic:falsify(res , TileConst.kCannonAnimal , {r=r,c=c})

	return res
end

function ProductItemLogic:productAnimal(mainLogic)
	local res = GameItemData:create()
	res._encrypt.ItemColorType = mainLogic:randomColor()
	res.ItemType = GameItemType.kAnimal
	return res
end

function ProductItemLogic:productAnimalBySingleDropColor(mainLogic  , tileConfigId , r , c )
	local gameItemData = GameItemData:create()
	gameItemData.ItemType = GameItemType.kAnimal
	gameItemData._encrypt.ItemColorType = mainLogic:randomSingleDropColor( tileConfigId , r , c )
	return gameItemData
end



function ProductItemLogic:productIngredient(mainLogic)
	--ingredientsCount 			已经收集的数量
	--ingredientsTotal 			需要掉落的豆荚总数
	--ingredientsTotalCount  	还可以掉落多少个
	--ingredientsMoveCount 		上次生成后的累计步数
	--ingredientSpawnDensity	间隔步数
	--everyStepDropNum          一次掉落个数
	--ingredientsShouldCome 	棋盘上没有会设置成true，强行掉落
	if mainLogic.ingredientsCount < mainLogic.ingredientsTotal and mainLogic.ingredientsTotalCount > 0 and (mainLogic.ingredientsMoveCount >=
		mainLogic.ingredientSpawnDensity or mainLogic.ingredientsShouldCome) then

		mainLogic.ingredientsMoveCount = 0
		mainLogic.ingredientsShouldCome = false

		local dropNum = mainLogic.everyStepDropNum
		if dropNum > mainLogic.ingredientsTotalCount then dropNum = mainLogic.ingredientsTotalCount end

		mainLogic.dropNumCached = mainLogic.dropNumCached + dropNum
		mainLogic.ingredientsTotalCount = mainLogic.ingredientsTotalCount - dropNum
	end

	if mainLogic.dropNumCached > 0 then
		mainLogic.dropNumCached = mainLogic.dropNumCached - 1
		
		local res = GameItemData:create()
		res.ItemType = GameItemType.kIngredient
		if mainLogic.theGamePlayType == GameModeTypeId.TASK_UNLOCK_DROP_DOWN_ID then 
			res:initUnlockAreaDropDownModeInfo()
		end
		return res
	else
		return nil
	end
end


function ProductItemLogic:createBlockPreBuildData( itemID , otherInfo , count )
	local datas = {}
	datas.itemID = itemID
	datas.otherInfo = otherInfo
	datas.count = count

	return datas
end

function ProductItemLogic:__getCachePoolItemCount( cachePool , dropRuleId )
	if cachePool and cachePool[dropRuleId] then

		local list = cachePool[dropRuleId]

		if __logicVer == 2 then
			if list[1] then
				local preBuildData = list[1]
				-- printx( 1 , "ProductItemLogic:getCachePoolItemCount  11111111111111  " , preBuildData.count )
				return preBuildData.count
			end
		else
			return #list
		end
	end
	-- printx( 1 , "ProductItemLogic:getCachePoolItemCount  22222222222222  0" )
	return 0
end

function ProductItemLogic:getCachePoolItemCountAtWholeBoard( mainLogic , dropRuleId )
	local totalCount = 0
	for k , v in  ipairs( mainLogic.cachePoolV2 ) do
		local cachePool = v
		local count = self:__getCachePoolItemCount( cachePool , dropRuleId )
		totalCount = totalCount + count
	end
	return totalCount
end


function ProductItemLogic:getCachePoolItemCount( mainLogic , dropRuleId , r , c )

	local cachePool = self:getCurrCachePool( mainLogic ,  r , c )
	-- printx( 1 , "getCachePoolItemCount   " , dropRuleId ,  r , c  ,"  cachePool =" , table.tostring(cachePool) )
	local count = self:__getCachePoolItemCount( cachePool , dropRuleId )
	-- printx( 1 , "ProductItemLogic:getCachePoolItemCount  22222222222222  0" )
	return count
end

function ProductItemLogic:createProductData( mainLogic , itemID , otherInfo , r , c )
	local gameItemData = GameItemData:create()
	if itemID == TileConst.kCrystal - 1 then
		gameItemData.ItemType = GameItemType.kCrystal
		gameItemData._encrypt.ItemColorType = mainLogic:randomColor()

	elseif itemID == TileConst.kBalloon - 1 then
		gameItemData.ItemType = GameItemType.kBalloon
		gameItemData._encrypt.ItemColorType = mainLogic:randomColor()
		gameItemData.balloonFrom = mainLogic.balloonFrom
		gameItemData.isFromProductBalloon = true
	elseif itemID == TileConst.kCoin - 1 then 
		gameItemData.ItemType = GameItemType.kCoin
	elseif itemID == TileConst.kBlackCute - 1 then
		gameItemData.ItemType = GameItemType.kBlackCuteBall 
		gameItemData.blackCuteStrength = 2
		gameItemData.blackCuteMaxStrength = gameItemData.blackCuteStrength
	elseif itemID == TileConst.kHoneyBottle - 1 then
		gameItemData.ItemType = GameItemType.kHoneyBottle
		gameItemData.honeyBottleLevel = 1
	elseif itemID == TileConst.kQuestionMark - 1 then
		gameItemData.ItemType = GameItemType.kQuestionMark
		gameItemData._encrypt.ItemColorType = mainLogic:randomColor()
	elseif itemID == TileConst.kAddTime - 1 then
		gameItemData._encrypt.ItemColorType = mainLogic:randomColor()
		gameItemData.ItemType = GameItemType.kAddTime
		gameItemData.addTime = mainLogic.addTime or 5
	elseif itemID == TileConst.kAddMove - 1 then 
		gameItemData._encrypt.ItemColorType = mainLogic:randomColor()
		gameItemData.ItemType = GameItemType.kAddMove
		gameItemData.numAddMove = mainLogic.addMoveBase or GamePlayConfig_Add_Move_Base
	elseif itemID == TileConst.kGreyCute - 1 then
		gameItemData.ItemType = GameItemType.kAnimal
		gameItemData._encrypt.ItemColorType = mainLogic:randomColor()
		gameItemData.furballLevel = 1
		gameItemData.furballType = GameItemFurballType.kGrey
	elseif itemID == TileConst.kBrownCute- 1 then
		gameItemData.ItemType = GameItemType.kAnimal
		gameItemData._encrypt.ItemColorType = mainLogic:randomColor()
		gameItemData.furballLevel = 1
		gameItemData.furballType = GameItemFurballType.kBrown
	elseif itemID == TileConst.kRocket- 1 then
		gameItemData.ItemType = GameItemType.kRocket
		gameItemData._encrypt.ItemColorType = mainLogic:randomColor()
	elseif itemID == TileConst.kCrystalStone - 1 then
		gameItemData.ItemType = GameItemType.kCrystalStone
		-- gameItemData._encrypt.ItemColorType = mainLogic:randomCrystalStoneColor()
		gameItemData._encrypt.ItemColorType = mainLogic:randomSingleDropColor(TileConst.kCrystalStone , r , c)
	elseif itemID == TileConst.kTotems - 1 then
		gameItemData.ItemType = GameItemType.kTotems
		gameItemData._encrypt.ItemColorType = mainLogic:randomSingleDropColor(TileConst.kTotems , r , c)
	elseif itemID == TileConst.kDrip - 1 then
		gameItemData.ItemType = GameItemType.kDrip
		gameItemData._encrypt.ItemColorType = AnimalTypeConfig.kDrip
		gameItemData.dripState = DripState.kNormal
	elseif itemID == TileConst.kPuffer - 1 then
		gameItemData.ItemType = GameItemType.kPuffer
		gameItemData.pufferState = PufferState.kNormal
	elseif itemID == TileConst.kPufferActivated - 1 then
		gameItemData.ItemType = GameItemType.kPuffer
		gameItemData.pufferState = PufferState.kActivated
	elseif itemID == TileConst.kCannonCandyLineEffectColumn - 1 then
		gameItemData.ItemType = GameItemType.kAnimal
		gameItemData._encrypt.ItemColorType = mainLogic:randomColor()
		gameItemData.ItemSpecialType = AnimalTypeConfig.kColumn -- 256
	elseif itemID == TileConst.kCannonCandyLineEffectRow - 1 then
		gameItemData.ItemType = GameItemType.kAnimal
		gameItemData._encrypt.ItemColorType = mainLogic:randomColor()
		gameItemData.ItemSpecialType = AnimalTypeConfig.kLine 
	elseif itemID == TileConst.kCannonCandyWrapEffect - 1 then
		gameItemData.ItemType = GameItemType.kAnimal
		gameItemData._encrypt.ItemColorType = mainLogic:randomColor()
		gameItemData.ItemSpecialType = AnimalTypeConfig.kWrap
	elseif itemID == TileConst.kCannonCandyMagicBird - 1 then
		gameItemData.ItemType = GameItemType.kAnimal
		-- gameItemData._encrypt.ItemColorType = mainLogic:randomColor()
		gameItemData.ItemSpecialType = AnimalTypeConfig.kColor 
	elseif itemID == TileConst.kCannonCandyColouredAnimal - 1 then
		gameItemData.ItemType = GameItemType.kAnimal
		gameItemData._encrypt.ItemColorType = mainLogic:randomSingleDropColor(TileConst.kCannonCandyColouredAnimal , r , c)
	elseif itemID == TileConst.kMissile - 1 then
		gameItemData.ItemType = GameItemType.kMissile
		gameItemData.missileLevel = 3
	elseif itemID == TileConst.kBlocker195 - 1 then
		gameItemData.ItemType = GameItemType.kBlocker195
		gameItemData.subtype = otherInfo
	elseif itemID == TileConst.kChameleon - 1 then
		gameItemData.ItemType = GameItemType.kChameleon
	elseif itemID == TileConst.kBlocker207 - 1 then
		gameItemData.ItemType = GameItemType.kBlocker207
    elseif itemID == TileConst.kWanSheng - 1 then
		gameItemData.ItemType = GameItemType.kWanSheng
        gameItemData.wanShengLevel = 1
        gameItemData.wanShengConfig = nil
	end
	
	return gameItemData
end

function ProductItemLogic:createProductDataFromCachePool( mainLogic , dropRuleId , r , c )
	--if _G.isLocalDevelopMode then printx(0, "%%%%% buildBlockData %%%%%",blockRule.itemID) end

	local cachePool = self:getCurrCachePool( mainLogic ,  r , c )

	if cachePool[dropRuleId] then
		local list = cachePool[dropRuleId]

		if __logicVer == 2 then
			if list[1] then
				local preBuildData = list[1]
				local itemID = preBuildData.itemID
				local otherInfo = preBuildData.otherInfo

				preBuildData.count = preBuildData.count - 1

				if preBuildData.count == 0 then
					table.remove( list , 1 )
				end

				local item = self:createProductData( mainLogic , itemID , otherInfo , r , c )

				return item
			end
		else
			if #list > 0 then

			end
			return table.remove( list )
		end

	end
	-- printx( "ProductItemLogic:createProductDataFromCachePool  !!!!!!!!!!!!!!!!!!!!!!!  return nil")
	return nil
end

function ProductItemLogic:getItemAmountByItemType(mainLogic, rule, passCacheAmout)
	-- body
	local boardAmout = 0
	if rule.itemID == TileConst.kBrownCute - 1 then 
		boardAmout = mainLogic:getFurballAmout(GameItemFurballType.kBrown)
	elseif rule.itemID == TileConst.kGreyCute - 1 then 
		boardAmout = mainLogic:getFurballAmout(GameItemFurballType.kGrey)
	elseif rule.itemID == TileConst.kBlocker207 - 1 then--计算翻转地格反面
		boardAmout = mainLogic:getItemAmountByItemType(rule.itemType,rule.specialType,rule.otherInfo, true)
	else
		--printx( 1 , "   WTF!!!!!!!!!!!!!!!!!!"  , rule.itemType,rule.specialType,rule.otherInfo )
		boardAmout = mainLogic:getItemAmountByItemType(rule.itemType,rule.specialType,rule.otherInfo)
	end

	-- local cacheAmout = self:getCachePoolItemCount( mainLogic , rule.id )
	local cacheAmout = self:getCachePoolItemCountAtWholeBoard( mainLogic , rule.id )
	--printx( 1 , "     ProductItemLogic:getItemAmountByItemType     rule.itemID = " , rule.itemID  , "    boardAmout = " , boardAmout , "   cacheAmout = " , cacheAmout)

	if passCacheAmout then
		return boardAmout
	else
		return cacheAmout + boardAmout
	end
end

function ProductItemLogic:isBlockCanProduct(mainLogic, rule)
	
	local resultNum , ResultReason = self:countNeedProductBlockNum(mainLogic,rule)
	local productResult = resultNum and resultNum > 0
	return productResult , resultNum , ResultReason
end

function ProductItemLogic:countNeedProductBlockNum(mainLogic, rule)
	-- printx( 1 , "   ===================ProductItemLogic:countNeedProductBlockNum===================  ")
	local needprint = false
	if mainLogic.theCurMoves == 17 then
		--needprint = true
	end

	local resultNum = 0 
	local currAmount = 0

	if rule.blockProductType == 5 then
		currAmount = ProductItemLogic:getItemAmountByItemType(mainLogic, rule , true)
	else
		currAmount = ProductItemLogic:getItemAmountByItemType(mainLogic, rule)
	end

	local function getResultNum()
		--
--
--
--
--
--
--


		if rule.blockProductType == 4 then
			if rule.minNum > 0 and currAmount < rule.minNum then
				resultNum = rule.minNum - currAmount
			else
				resultNum = rule.blockSpawnDensity - rule.blockSpawned
			end
		elseif rule.blockProductType == 5 then
			if rule.minNum > 0 and currAmount < rule.minNum then
				local count1 = rule.minNum - currAmount
				local count2 = rule.blockSpawnDensity - rule.blockSpawned

				if count1 > count2 then
					resultNum = count1
				else
					resultNum = count2
				end
			elseif rule.maxNum > 0 then

				local count1 = rule.blockSpawnDensity - rule.blockSpawned
				local count2 = count1
				if count1 + currAmount > rule.maxNum then
					count2 = rule.maxNum - currAmount
				end

				if count2 < 0 then count2 = 0 end
				resultNum = count2

			else
				resultNum = rule.blockSpawnDensity - rule.blockSpawned
			end
		else
			resultNum = rule.blockSpawnDensity - rule.blockSpawned
		end
		
		if rule.dropNumLimit > 0 and resultNum + rule.totalDroppedNum > rule.dropNumLimit then
			--
--
--
--
--

			resultNum = rule.dropNumLimit - rule.totalDroppedNum
		end

		if rule.blockProductType == 1 and rule.maxNum > 0 and resultNum + currAmount > rule.maxNum then
			--
--
--
--
--

			resultNum = rule.maxNum - currAmount
		end
		--
--
--
--
--

		return resultNum
	end

	if rule.blockProductType == 1 or rule.blockProductType == 4 or rule.blockProductType == 5 then
		-- 特殊处理指定颜色掉落口,这条规则永远生效
		-- if (rule.itemID == TileConst.kCannonCandyColouredAnimal - 1) then
		-- 	return 1,checkBlockCanProductReason.kSuccessByNormal
		-- end

		if rule.dropNumLimit > 0 and rule.totalDroppedNum >= rule.dropNumLimit  then
			--
--
--
--
--

			return resultNum , checkBlockCanProductReason.kFailedByDropNumLimit
		end

		local isOverMaxNum = false
		if rule.maxNum > 0 and currAmount >= rule.maxNum then
			isOverMaxNum = true
		end

		local isLessThenMinNum = false
		if rule.minNum > 0 and currAmount < rule.minNum then
			isLessThenMinNum = true
		end

		if rule.blockSpawned < rule.blockSpawnDensity then
			if isOverMaxNum then
				--
--
--
--
--

				return resultNum , checkBlockCanProductReason.kFailedByMaxNum
			else
				local r = checkBlockCanProductReason.kSuccessByNormal
				if isLessThenMinNum then
					r = checkBlockCanProductReason.kSuccessByMinNum
				elseif rule.blockMoveCount >= rule.blockMoveTarget then
					r = checkBlockCanProductReason.kSuccessByNormal
				else
					--
--
--
--
--

					return resultNum , checkBlockCanProductReason.kFailedByMoveTarget
				end

				return getResultNum() , r
			end
		else
			--
--
--
--
--


			if ( rule.blockProductType == 4 or rule.blockProductType == 5 ) and isLessThenMinNum then
				return getResultNum() , checkBlockCanProductReason.kSuccessByMinNum
			else
				return resultNum , checkBlockCanProductReason.kFailedByBlockSpawnDensity
			end
			
		end

	elseif rule.blockProductType == 2 then 

		if rule.dropNumLimit > 0 and rule.totalDroppedNum >= rule.dropNumLimit  then
			return resultNum , checkBlockCanProductReason.kFailedByDropNumLimit
		end

		if rule.blockMoveCount > rule.blockSpawnDensity or rule.blockShouldCome then 
			return 1
		end
	end

	return resultNum , checkBlockCanProductReason.kFailedByUnknow
end


function ProductItemLogic:productBlock(mainLogic, ruleId, ruleItemId, r, c)
	local function addProductCannonCountMap()

		local rst = true
		if not mainLogic.productCannonCountMap[ tostring(r) .. "_" .. tostring(c) ] then
			mainLogic.productCannonCountMap[ tostring(r) .. "_" .. tostring(c) ] = 0
		end

		mainLogic.productCannonCountMap[ tostring(r) .. "_" .. tostring(c) ] = mainLogic.productCannonCountMap[ tostring(r) .. "_" .. tostring(c) ] + 1

		if mainLogic.productCannonCountMap[ tostring(r) .. "_" .. tostring(c) ] > 2 then
			rst = false
		end	

		--printx( 1 , "   +++++++++++++++  addProductCannonCountMap  +++++++++++++++++  " , r , c , ruleItemId)
		--printx( 1 , "   +++++++++++++++  addProductCannonCountMap  +++++++++++++++++  conut = " , mainLogic.productCannonCountMap[ tostring(r) .. "_" .. tostring(c) ])
		return rst
	end
	
	-- printx( 1 , "productBlock  ruleId" , ruleId , "ruleItemId" , ruleItemId , "r" , r , "c" , c )
	

	if ruleId then
		-- printx( 1 , "productBlock   getItemAmountByItemType" , self:getCachePoolItemCount( mainLogic , ruleId , r, c ))
		if self:getCachePoolItemCount( mainLogic , ruleId , r, c ) > 0  then 
			local itemRule = nil

			local productRules = self:getCurrProductRules( mainLogic , r , c )

			for k, rules in pairs( productRules ) do
				if rules.id == ruleId then
					itemRule = rules
					break
				end
			end

			if itemRule and ( itemRule.blockProductType == 4 --[[or itemRule.blockProductType == 5]] ) then
				local currAmount = ProductItemLogic:getItemAmountByItemType(mainLogic, itemRule, true)
				if itemRule.maxNum > 0 and currAmount >= itemRule.maxNum then
					--printx( 1 , "     ProductItemLogic:productBlock   itemRule.blockProductType == 4  22222 " ,ruleItemId , currAmount , itemRule.maxNum)
					return nil
				end
			end

			if ruleItemId == TileConst.kDrip - 1 then
				if addProductCannonCountMap() then
					return self:createProductDataFromCachePool( mainLogic , ruleId , r , c )
				else
					return nil
				end
			elseif ruleItemId == TileConst.kBlocker195 - 1 then
				if ProductItemLogic:canProductBlocker195(mainLogic, itemRule.otherInfo , r , c) then 
					return self:createProductDataFromCachePool( mainLogic , ruleId , r , c )
				else
					return nil
				end
			elseif ruleItemId == TileConst.kCoin - 1 and mainLogic.theGamePlayType == GameModeTypeId.SPRING_HORIZONTAL_ENDLESS_ID then
				local boardData = mainLogic.boardmap[r][c]
				if boardData:tryProductFallType(TileConst.kCannonCoin) then
					boardData:addProductFallType(TileConst.kCannonCoin)
					return self:createProductDataFromCachePool( mainLogic , ruleId , r , c )
				else
					return nil
				end
			else
				return self:createProductDataFromCachePool( mainLogic , ruleId , r , c )
			end
		elseif ruleItemId == TileConst.kCannonCandyColouredAnimal - 1 then
			--if _G.isLocalDevelopMode then printx(0, "identified color animal which does NOT in cache pool") end
			-- debug.debug()
			return self:productAnimalBySingleDropColor( mainLogic , TileConst.kCannonCandyColouredAnimal , r , c )
		end
	else
		for k = 1, #ProductRuleOrder do
			local ruleItem = ProductRuleOrder[k]
			local ruleId = ruleItem.itemId - 1
			if ruleItem.property then
				ruleId = ruleId .. '_' .. ruleItem.property
			end
			if self:getCachePoolItemCount( mainLogic , ruleId , r , c ) > 0 then

				local rule = nil
				local productRules = self:getCurrProductRules( mainLogic , r , c )
				for k, v in pairs( productRules ) do
					if v.id == ruleId then
						rule = v
						break
					end
				end
				if rule and ( rule.blockProductType == 4 --[[or rule.blockProductType == 5]] ) then
					local currAmount = ProductItemLogic:getItemAmountByItemType(mainLogic, rule, true)
					if rule.maxNum > 0 and currAmount >= rule.maxNum then
						return nil
					end
				end

				if ruleItem.itemId == TileConst.kDrip then
					if addProductCannonCountMap() then
						--printx( 1 , "   Product  Drip  222")
						return self:createProductDataFromCachePool( mainLogic , ruleId , r , c )
					else
						--printx( 1 , "   Pass  Drip  222")
						return nil
					end
				elseif ruleItem.itemId == TileConst.kBlocker195 then
					if ProductItemLogic:canProductBlocker195(mainLogic, ruleItem.property , r , c) then 
						return self:createProductDataFromCachePool( mainLogic , ruleId , r , c )
					end
				elseif ruleItemId == TileConst.kCoin - 1 and mainLogic.theGamePlayType == GameModeTypeId.SPRING_HORIZONTAL_ENDLESS_ID then
					local boardData = mainLogic.boardmap[r][c]
					if boardData:tryProductFallType(TileConst.kCannonCoin) then
						boardData:addProductFallType(TileConst.kCannonCoin)
						return self:createProductDataFromCachePool( mainLogic , ruleId , r , c )
					end
				else
					return self:createProductDataFromCachePool( mainLogic , ruleId , r , c )
				end
			end
		end
	end
end

function ProductItemLogic:updateCachePoolV2( mainLogic , r , c )

	local needPrint = false

	-- if (r == 5 and c == 4) or (r == 5 and c == 6) then
	-- 	needPrint = true
	-- end

	--[[
		function ProductItemLogic:getCurrCachePool( mainLogic , r , c )
		function ProductItemLogic:getDefaultCachePool( mainLogic )
		function ProductItemLogic:getCurrProductRules( mainLogic , r , c )
		function ProductItemLogic:getDefaultProductRules( mainLogic )
	]]
	 
	-- if needPrint then printx( 1 , "updateCachePoolV2  ~~~~~~~~~~~~~~" , r , c ) end

	local cachePool = self:getCurrCachePool( mainLogic , r , c )
	local productRules = self:getCurrProductRules( mainLogic , r , c )

	-- if needPrint then
	-- 	printx( 1 , "updateCachePoolV2  cachePoolV2 =" , table.tostring(cachePool) )
	-- 	printx( 1 , "updateCachePoolV2  productRules =" , table.tostring(productRules) )
	-- end


	for k, v in pairs( productRules ) do

		local needUpdate = false
		local ruleData = nil
		if cachePool[v.id] then
			if #cachePool[v.id] == 0 then
				needUpdate = true
			elseif cachePool[v.id][1].count == 0 then
				needUpdate = true
			end
			ruleData = cachePool[v.id]
		end

		-- if needPrint then printx( 1 , "updateCachePoolV2  needUpdate" , needUpdate , "v.id" , v.id ) end

		if needUpdate then

			local productResult , resultNum , ResultReason = self:isBlockCanProduct( mainLogic , v )
			
			-- if needPrint then  
			-- 	printx( 1 , "updateCachePoolV2  try  create ~~~~~~~~~~~~~~~~~~~  ",productResult , resultNum , ResultReason)
			-- end

			if productResult then

				if __logicVer == 2 then
					local res = self:createBlockPreBuildData( v.itemID , v.otherInfo , resultNum )
					
					local datas = nil
					local done = false
					for k1,v1 in ipairs( ruleData ) do
						datas = v1

						if datas.itemID == res.itemID and datas.otherInfo == res.otherInfo then
							datas.count = datas.count + res.count
							done = true
							break
						end
					end

					if not done then
						-- printx( 1 , "ProductItemLogic:updateCachePool   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  " , v.id  ,table.tostring(res))
						table.insert( ruleData , res)
					end

					v.totalDroppedNum = v.totalDroppedNum + res.count
					v.blockSpawned = v.blockSpawned + res.count
				else

					for i=1 , resultNum do
						v.totalDroppedNum = v.totalDroppedNum + 1
						v.blockSpawned = v.blockSpawned + 1

						local res = self:createProductData( mainLogic , v.itemID , v.otherInfo , r , c )

						table.insert( ruleData , res)
					end
				end
				
				v.blockMoveCount = 0
				v.blockShouldCome = false
				v.needClearBlockSpawnedNextStep = true
			end
		end
	end
end


function ProductItemLogic:addStep(mainLogic)
	
	mainLogic.ingredientsMoveCount = mainLogic.ingredientsMoveCount + 1
	mainLogic.snailMoveCount = mainLogic.snailMoveCount + 1

	for groupId , rule in ipairs( mainLogic.productRuleGroup ) do

		local blockProductRules = rule

		for k,v in pairs( blockProductRules ) do
			v.blockMoveCount = v.blockMoveCount + 1
			--printx( 1 , "   ProductItemLogic:addStep    v.blockMoveCount = " , blockMoveCount)
			if v.needClearBlockSpawnedNextStep then
				v.needClearBlockSpawnedNextStep = false
				v.blockSpawned = 0
			end
		end
	end
	--printx( 1 , "   +++++++++++++++  ProductItemLogic:addStep  +++++++++++++++++  " , table.tostring(mainLogic.productCannonCountMap) )
	mainLogic.productCannonCountMap = {}
end

function ProductItemLogic:resetStep(mainLogic, type)
	
	if type == GameItemType.kIngredient then
		mainLogic.ingredientsMoveCount = 0
	else
		--虽然写了这么多种类别，但是只有 kIngredient 调用了这个函数 ！？
		for groupId , rule in ipairs( mainLogic.productRuleGroup ) do
			local blockProductRules = rule
			for k,v in pairs(blockProductRules) do
				if 	(type == GameItemType.kCrystal and v.itemID == TileConst.kCrystal - 1)
					or (type == GameItemType.kCoin and v.itemID == TileConst.kCoin - 1) 
					or (type == GameItemType.kMissile and v.itemID == TileConst.kMissile -1)
					or (type == GameItemType.kBalloon and v.itemID == TileConst.kBalloon - 1)
					or (type == GameItemType.kBlackCuteBall and v.itemID == TileConst.kBlackCute - 1)
					or (type == GameItemType.kHoneyBottle and v.itemID == TileConst.kHoneyBottle - 1 )
					or (type == GameItemType.kQuestionMark and v.itemID == TileConst.kQuestionMark - 1 ) then
						v.blockMoveCount = 0
				end
			end
		end
	end
	--printx( 1 , "   +++++++++++++++  ProductItemLogic:resetStep  +++++++++++++++++  " , table.tostring(mainLogic.productCannonCountMap) )
	mainLogic.productCannonCountMap = {}
end

function ProductItemLogic:shoundCome(mainLogic, type)

	if type == GameItemType.kIngredient then
		mainLogic.ingredientsShouldCome = true
	end

	--不理解这里写这么多种类别干什么，明明只有 kCrystal，kCoin，kIngredient 这三种类型会调用这个函数

	for groupId , rule in ipairs( mainLogic.productRuleGroup ) do
		local blockProductRules = rule

		for k, v in pairs(blockProductRules) do
			if (type == GameItemType.kCrystal and v.itemID == TileConst.kCrystal - 1 )
				or (type == GameItemType.kBalloon and v.itemID == TileConst.kBalloon - 1)
				or (type == GameItemType.kCoin and v.itemID == TileConst.kCoin -1)
				or (type == GameItemType.kMissile and v.itemID == TileConst.kMissile -1)
				or (type == GameItemType.kBlackCuteBall and v.itemID == TileConst.kBlackCute - 1)
				or (type == GameItemType.kHoneyBottle and v.itemID == TileConst.kHoneyBottle - 1) 
				or (type == GameItemType.kQuestionMark and v.itemID == TileConst.kQuestionMark - 1 ) then 

				v.blockShouldCome = true
			end
		end
	end
end

function ProductItemLogic:productRabbit(mainLogic, count, callback, isInit)
	if not mainLogic.rabbitProducers then 
		ProductItemLogic:initRabbitProducer(mainLogic)
	end

	------------    helper functions    --------------
	local function isAnimalOrCrystal(item)
		return item.ItemType == GameItemType.kAnimal 
		and item.ItemSpecialType == 0 
		or item.ItemType == GameItemType.kCrystal
	end

	local function isSpecialItem(item)
		return item.ItemType == GameItemType.kAnimal 
		and item.ItemSpecialType ~= 0 
		and item.ItemSpecialType ~= AnimalTypeConfig.kColor
	end

	local function isBirdItem(item)
		return item.ItemType == GameItemType.kAnimal 
		and item.ItemSpecialType == AnimalTypeConfig.kColor
	end

	local function getShiftToPosition(pos)
		local top, topL, topR, topTop
		local shiftToPos = nil
		top = mainLogic.gameItemMap[pos.r-1][pos.c]
		topL = mainLogic.gameItemMap[pos.r-1][pos.c-1]
		topR = mainLogic.gameItemMap[pos.r-1][pos.c+1]
		topTop = mainLogic.gameItemMap[pos.r-2][pos.c]
		local function __canShiftTo(item)
			if not item then return false end
			-- if _G.isLocalDevelopMode then printx(0, item.x, item.y, item.ItemType, GameItemType.kAnimal, item.ItemSpecialType, AnimalTypeConfig.kColor) end
			if item.isEmpty or (item.ItemType == GameItemType.kAnimal and item.ItemSpecialType == AnimalTypeConfig.kColor)
			or item.isBlock or item.ItemType == GameItemType.kRabbit then
				return false
			else 
				local board = mainLogic.boardmap[item.y][item.x]
				if board and board.isRabbitProducer then
					return false
				end
			end
			return true
		end

		if __canShiftTo(top) then
			shiftToPos = {r = pos.r-1, c = pos.c}
		elseif __canShiftTo(topL) then
			shiftToPos = {r = pos.r-1, c = pos.c-1}
		elseif __canShiftTo(topR) then
			shiftToPos = {r = pos.r-1, c = pos.c+1}
		elseif __canShiftTo(topTop) then
			shiftToPos = {r = pos.r-2, c = pos.c}
		end
		return shiftToPos
	end

	local function getColorForRabbit(r, c)
		local item = mainLogic.gameItemMap[r][c]
		if item._encrypt.ItemColorType and AnimalTypeConfig.isColorTypeValid(item._encrypt.ItemColorType) then
			return item._encrypt.ItemColorType
		else
			local function randomColor( mainLogic, r, c )
				local colorList = mainLogic.mapColorList
				local selectColorList = {}
				for k, v in pairs(colorList) do 
					if not mainLogic:checkMatchQuick(r, c, v) then 
						table.insert(selectColorList, v)
					end
				end
				if #selectColorList > 0 then
					return selectColorList[mainLogic.randFactory:rand(1,#selectColorList)]
				else
					return colorList[1]
				end
			end
			return randomColor(mainLogic, r, c)
		end
	end

	local function produceRabbitDirect(rabbitPos, shiftToPos, color, level)
		-- produce rabbit
		local item = mainLogic.gameItemMap[rabbitPos.r][rabbitPos.c]
		item:changeToRabbit(color, level)
		item:changeRabbitState(GameItemRabbitState.kSpawn)
		item.isNeedUpdate = true

		-- shift item elsewhere
		if shiftToPos then
			local ox = mainLogic.gameItemMap[shiftToPos.r][shiftToPos.c].x
			local oy = mainLogic.gameItemMap[shiftToPos.r][shiftToPos.c].y
			mainLogic.gameItemMap[shiftToPos.r][shiftToPos.c] = mainLogic.gameItemMap[rabbitPos.r][rabbitPos.c]:copy()
			mainLogic.gameItemMap[shiftToPos.r][shiftToPos.c].isNeedUpdate = true
			mainLogic.gameItemMap[shiftToPos.r][shiftToPos.c].x = ox
			mainLogic.gameItemMap[shiftToPos.r][shiftToPos.c].y = oy
		end
	end

	--------------------------------------------------------

	local animal = {}
	local special = {}
	local birds = {}

	for k, v in pairs(mainLogic.rabbitProducers) do 
		local item = mainLogic.gameItemMap[v.r][v.c]
		if isAnimalOrCrystal(item) then
			table.insert(animal, {r = v.r, c = v.c})
		elseif isSpecialItem(item) then
			table.insert(special, {r = v.r, c = v.c})
		elseif isBirdItem(item) then
			table.insert(birds, {r = v.r, c = v.c})
		end
	end

	-- if _G.isLocalDevelopMode then printx(0, '#animal', #animal, '#special', #special, '#birds', #birds) end

	local genCount = 0
	for i = 1, count do 
		local rabbitPos, shiftToPos
		if #animal > 0 then
			local selector = mainLogic.randFactory:rand(1, #animal)
			rabbitPos = animal[selector]
			table.remove(animal, selector)
		elseif #special > 0 then
			local selector = mainLogic.randFactory:rand(1, #special)
			rabbitPos = special[selector]
			table.remove(special, selector)
		elseif #birds > 0 then
			local selector = mainLogic.randFactory:rand(1, #birds)
			rabbitPos = birds[selector]
			table.remove(birds, selector)

			-- 如果可能，把鸟移到别处
			shiftToPos = getShiftToPosition(rabbitPos)
		end
		
		if rabbitPos then
			genCount = genCount + 1
			
			if _G.isLocalDevelopMode then printx(0, 'rabbitPos', rabbitPos.r, rabbitPos.c, 'shiftToPos', shiftToPos and shiftToPos.r or 'nil', shiftToPos and shiftToPos.c or 'nil') end

			local rabbitColor = getColorForRabbit(rabbitPos.r, rabbitPos.c)
			local rabbitLevel = mainLogic.gameMode:isDoubleRabbitStage() and 2 or 1

			if isInit then
				produceRabbitDirect(rabbitPos, shiftToPos, rabbitColor, rabbitLevel)
			else
				local action = GameBoardActionDataSet:createAs(
					GameActionTargetType.kGameItemAction,
					GameItemActionType.kItem_Rabbit_Product,
					rabbitPos,
					shiftToPos,
					GamePlayConfig_MaxAction_time
					)
				action.completeCallback = callback
				action.color = rabbitColor
				action.level = rabbitLevel
				mainLogic:addGameAction(action)	
			end
		end
	end

	return genCount
end

function ProductItemLogic:productSnail( mainLogic , callback)
	-- body
	if mainLogic.snailCount < mainLogic.snailTotalCount  and 
		(mainLogic.snailMoveCount >= mainLogic.snailSpawnDensity or mainLogic:getSnailOnScreenCount() == 0) then 
		local spailSpawnList_1 = {}
		local spailSpawnList_2 = {}
		for r = 1, #mainLogic.boardmap do 
			for c = 1, #mainLogic.boardmap[r] do 
				local board = mainLogic.boardmap[r][c]
				if board.isSnailProducer then 
					local item = mainLogic.gameItemMap[r][c]
					if item 
						and (item.ItemType == GameItemType.kAnimal or item.ItemType == GameItemType.kCrystal) 
						and item:isAvailable() 
						and item.beEffectByMimosa ~= GameItemType.kKindMimosa then

						local pos = IntCoord:create(r, c)
						if item.ItemSpecialType == 0 then
							table.insert(spailSpawnList_1, pos)
						else
							table.insert(spailSpawnList_2, pos)
						end
					end
				end
			end
		end

		local randomItem = spailSpawnList_1[mainLogic.randFactory:rand(1,#spailSpawnList_1)]
		if not randomItem then 
			randomItem = spailSpawnList_2[mainLogic.randFactory:rand(1,#spailSpawnList_2)]
		end

		if randomItem then 
			mainLogic.snailCount = mainLogic.snailCount + 1
			mainLogic.snailMoveCount = 0
			local action = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItem_Snail_Product,
				randomItem,
				nil,
				GamePlayConfig_MaxAction_time
				)

			action.completeCallback = callback
			action.direction = mainLogic.boardmap[randomItem.x][randomItem.y].snailRoadType
			mainLogic:addGameAction(action)
			return 1
		end

	end
	return 0

end

local function getBlocker195CollectAmount(mainLogic, collectType)--棋盘上星星瓶收集物个数	--翻译：棋盘上(正反)还剩余多少个可以收集
	local count = 0
	local function getBlockerCount(board, item)
		if (collectType == Blocker195CollectType.kLock and item.cageLevel > 0) or 
			(collectType == Blocker195CollectType.kSnow and item.snowLevel > 0) or 
			(collectType == Blocker195CollectType.kSand and board.sandLevel > 0) or 
			(collectType == Blocker195CollectType.kDigGround and item.digGroundLevel > 0) or 
			(collectType == Blocker195CollectType.kBottleBlocker and item.ItemType == GameItemType.kBottleBlocker) or 
			(collectType == Blocker195CollectType.kColorFilter and board.colorFilterBLevel > 0) or 
			(collectType == Blocker195CollectType.kCoin and item.ItemType == GameItemType.kCoin) or 
			(collectType == Blocker195CollectType.kGreyCute and item.furballType == GameItemFurballType.kGrey) or 
			(collectType == Blocker195CollectType.kBrownCute and item.furballType == GameItemFurballType.kBrown) or 
			(collectType == Blocker195CollectType.kBlackCute and item.ItemType == GameItemType.kBlackCuteBall) or 
			(collectType == Blocker195CollectType.kHoneyBottle and item.ItemType == GameItemType.kHoneyBottle) or 
			(collectType == Blocker195CollectType.kHoney and item.honeyLevel > 0 ) or 
			(collectType == Blocker195CollectType.kPuffer and item.ItemType == GameItemType.kPuffer and item.pufferState == PufferState.kNormal) or 
			(collectType == Blocker195CollectType.kPuffer.."kActivated" and item.ItemType == GameItemType.kPuffer and item.pufferState == PufferState.kActivated) or 
			(collectType == Blocker195CollectType.kMissile and item.ItemType == GameItemType.kMissile) or 
			(collectType == Blocker195CollectType.kChameleon and item.ItemType == GameItemType.kChameleon) or
			(collectType == Blocker195CollectType.kGhost and item:seizedByGhost())
			then 
			count = count + 1
		end
	end

	for r = 1, #mainLogic.gameItemMap do 
		for c = 1, #mainLogic.gameItemMap[r] do
			local board = mainLogic.boardmap[r][c] 
			local item = mainLogic.gameItemMap[r][c]
			getBlockerCount(board, item)
			if board:isDoubleSideTileBlock() then
				board = mainLogic.backBoardMap[r][c]
				item = mainLogic.backItemMap[r][c]
				getBlockerCount(board, item)
			end
		end
	end
	return count
end

function ProductItemLogic:getCurrProductRuleByItemId( mainLogic, itemId , r , c )
	local blockProductRules = self:getCurrProductRules( mainLogic , r , c )
	for _, v in pairs( blockProductRules ) do
		if v.itemID == itemId then 
			return v
		end
	end
	return nil
end

function ProductItemLogic:canProductBlocker195(mainLogic, collectType , r , c)--是否符合星星瓶自设的生成条件
	local bDebug = false
	local function getLeftDropNum(dropRule)
		if dropRule then
			local leftDropNum = dropRule.dropNumLimit - dropRule.totalDroppedNum + self:getCachePoolItemCount( mainLogic , dropRule.id , r , c )
			return leftDropNum
		else
			return 0
		end
	end

	if bDebug then printx(1, "canProductBlocker195-collectType", collectType) end
	if table.exist({Blocker195CollectType.kLock, Blocker195CollectType.kSnow, Blocker195CollectType.kSand, Blocker195CollectType.kDigGround, 
		Blocker195CollectType.kBottleBlocker, Blocker195CollectType.kColorFilter}, collectType) then
		local blockerAmount = getBlocker195CollectAmount(mainLogic, collectType)
		local needCollectAmount = mainLogic.blocker195Nums[collectType]
		if blockerAmount < needCollectAmount then 
			if bDebug then printx(1, "canProductBlocker195", 1) end
			return false
		else
			if bDebug then printx(1, "canProductBlocker195", 2) end
			return true
		end
	elseif table.exist({Blocker195CollectType.kCoin, Blocker195CollectType.kGreyCute, Blocker195CollectType.kBrownCute, 
		Blocker195CollectType.kBlackCute, Blocker195CollectType.kHoneyBottle, Blocker195CollectType.kHoney, 
		Blocker195CollectType.kPuffer, Blocker195CollectType.kMissile, Blocker195CollectType.kChameleon, Blocker195CollectType.kGhost}, 
		collectType) then
		local collectDropRule = self:getCurrProductRuleByItemId( mainLogic, tonumber(collectType) , r , c)
		local leftDropNum = getLeftDropNum(collectDropRule)
		local blockerAmount = getBlocker195CollectAmount(mainLogic, collectType)
		local needCollectAmount = mainLogic.blocker195Nums[collectType]
		if bDebug then printx(1, blockerAmount, leftDropNum, needCollectAmount) end

		if collectDropRule and collectDropRule.dropNumLimit == 0 then
			if bDebug then printx(1, "canProductBlocker195", 3) end
			return true
		end

		if collectType == Blocker195CollectType.kGhost then
			local leftGhostCanAppearAmount = GhostLogic:calculateGhostsLeftMaxAppearAmount(mainLogic)
			if leftGhostCanAppearAmount < 0 then 	--未限制最大产量
				return true
			else
				if blockerAmount + leftGhostCanAppearAmount < needCollectAmount then
					return false
				else
					return true
				end
			end
		end

		local otherDropRule
		if collectType == Blocker195CollectType.kGreyCute then
			otherDropRule = self:getCurrProductRuleByItemId( mainLogic, tonumber(Blocker195CollectType.kBrownCute) , r , c)
			if otherDropRule and otherDropRule.dropNumLimit == 0 then
				if bDebug then printx(1, "canProductBlocker195", "3_1") end
				return true
			end
		end
			
		if collectType == Blocker195CollectType.kHoney then 
			otherDropRule = self:getCurrProductRuleByItemId( mainLogic, tonumber(Blocker195CollectType.kHoneyBottle) , r , c)
			if otherDropRule and otherDropRule.dropNumLimit == 0 then
				if bDebug then printx(1, "canProductBlocker195", "3_2") end
				return true
			end
		end

		if collectType == Blocker195CollectType.kPuffer then
			otherDropRule = self:getCurrProductRuleByItemId( mainLogic, tonumber(Blocker195CollectType.kPuffer) + 1 , r , c)
			if otherDropRule and otherDropRule.dropNumLimit == 0 then
				if bDebug then printx(1, "canProductBlocker195", "3_3") end
				return true
			end
		end

		if collectType == Blocker195CollectType.kGreyCute then
			local brownCuteAmount = getBlocker195CollectAmount(mainLogic, Blocker195CollectType.kBrownCute)
			local brownCuteLeftDropNum = getLeftDropNum(otherDropRule)
			local greyCuteWeight = blockerAmount + leftDropNum
			local brownCuteWeight = brownCuteAmount + brownCuteLeftDropNum
			if greyCuteWeight + 2 * brownCuteWeight < needCollectAmount then
				if bDebug then printx(1, "canProductBlocker195", 4) end
				return false
			end  
		elseif collectType == Blocker195CollectType.kHoney then 
			local honeyBottleAmount = getBlocker195CollectAmount(mainLogic, Blocker195CollectType.kHoneyBottle)
			local honeyBottleLeftDropNum = getLeftDropNum(otherDropRule)
			local honeySplitNum = (mainLogic.honeys == nil and 0 or mainLogic.honeys)
			local honeyWeight = blockerAmount + honeySplitNum * (honeyBottleAmount + honeyBottleLeftDropNum)
			if honeyWeight < needCollectAmount then
				if bDebug then printx(1, "canProductBlocker195", 5) end
				return false
			end
		elseif collectType == Blocker195CollectType.kPuffer then
			local pufferActiveAmount = getBlocker195CollectAmount(mainLogic, collectType.."kActivated")
			local pufferActiveLeftDropNum = getLeftDropNum(otherDropRule)
			local pufferWeight = blockerAmount + leftDropNum
			local pufferActiveWeight = pufferActiveAmount + pufferActiveLeftDropNum
			if pufferWeight + pufferActiveWeight < needCollectAmount then
				if bDebug then printx(1, "canProductBlocker195", 9) end
				return false
			end
		elseif blockerAmount + leftDropNum < needCollectAmount then
			if bDebug then printx(1, "canProductBlocker195", 6 , blockerAmount , leftDropNum , needCollectAmount ) end
			return false
		end

		if bDebug then printx(1, "canProductBlocker195", 7) end
		return true

	else
		if bDebug then printx(1, "canProductBlocker195", 8) end
		return true--持续生成,无附加条件 
	end
end