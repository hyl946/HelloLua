ObstacleFootprintManager = {}
---------------------------------------------
--		记录各个障碍的各种行为（AI用）
---------------------------------------------

-- 类型键值表
ObstacleFootprintType = {
	k_Light = "ice",
	k_Fudge = "goldenPod",
	k_Snow = "snow",
	k_Gift = "gift",
	k_GreyFurball = "greyFurball",
	k_AddTime = "addTimeAnimal",
	k_Lock = "cage",
	k_CrystalBall = "crystalBall",
	k_Poison = "poison",
	k_Coin = "coin",
	k_BrownFurball = "brownFurball",
	k_Roost = "roost",
	k_DigGround = "cloud",
	k_DigJewel = "diamondCloud",
	k_Balloon = "balloon",
	k_UFO = "ufo",
	k_Rocket = "rocket",
	k_PoisonBottle = "octopus",
	k_TileBlocker = "trapdoor",
	k_BigMonster = "yeti",
	k_BlackFurball = "blackFurball",
	k_KindMimosa = "mimosa",
	k_Snail = "snail",
	k_Transmission = "conveyor",
	k_SeaAnimal = "arcticAnimal",
	k_MagicLamp = "genie",
	k_Honey = "honey",
	k_HoneyBottle = "honeyBottle",
	k_Sand = "sand",
	k_Icicle = "icicle",
	k_MagicStone = "magicStone",
	k_BottleBlocker = "explosiveBottle",
	k_CrystalStone = "colorRobot",
	k_Totems = "thunderBird",
	k_Lotus = "lotusPond",
	k_SuperCute = "whiteFurball",
	k_Puffer = "pufferfish",
	k_Missile = "frozenMissile",
	k_BlockerCoverMaterial = "stump",
	k_BlockerCover = "leafPile",
	k_Blocker195 = "starBottle",
	k_Blocker199 = "jellyfish",
	k_ColorFilter = "colorFilter",
	k_Chameleon = "chameleonEgg",
	k_Blocker207 = "padlockKey",
	k_Blocker206 = "padlock",
	k_Pacman = "pacman",
	k_Blocker211 = "hermitCrab",
	k_Turret = "turret",
	k_Ghost = "ghost",
	k_SunFlask = "sunFlask",
	k_Sunflower = "sunflower",
	k_Squid = "squid",
	k_LotusBlocker = "lotus",
	k_Biscuit = "biscuit",
}

-- 行为键值表
ObstacleFootprintAction = {
	k_Hit = "hit",
	k_Eliminate = "eliminate",
	k_Collect = "collect",
	k_List = "list",
	k_Appear = "appear",
	k_BlockEffect = "blockEffect",
	k_GenerateSubItem = "generateSubItem",
	k_Waste = "waste",
	k_AddStep = "addStep",
	k_Lift = "lift",
	k_Covered = "covered_timestep",
	k_Attack = "attack",
	k_HugeAttack = "hugeAttack",
	k_Steps = "steps",
	k_HitTargets = "hit_target",
	k_Active = "active",
	k_Upgrade = "upgrade",
	k_Expand = "expand",
	k_BackOff = "backOff",
	k_Unlocked = "unlocked_timestep",
	k_IntendedSteps = "intended_steps",
	k_Charge = "charge",
	k_Generate = "generate", -- 与generateSubItem的区别：后面会附有具体obstacle
	k_GridCount = "grid_count",
}

-- 子类型键值表
ObstacleFootprintSubType = {
	k_Arctic_PolarBear = "polarBear",
	k_Arctic_Penguin = "penguin",
	k_Arctic_Seal = "seal",
}

-- 键值<-->行为映射表，初始化用
ObstacleFootprintTypeToActionMap = {
	[ObstacleFootprintType.k_Light] = {"k_Hit", "k_Eliminate"},
	[ObstacleFootprintType.k_Fudge] = {"k_Collect"},
	[ObstacleFootprintType.k_Snow] = {"k_Hit", "k_Eliminate"},
	[ObstacleFootprintType.k_Gift] = {"k_List"},
	[ObstacleFootprintType.k_GreyFurball] = {"k_Eliminate"},
	[ObstacleFootprintType.k_AddTime] = {"k_Appear", "k_Eliminate"},
	[ObstacleFootprintType.k_Lock] = {"k_Eliminate"},
	[ObstacleFootprintType.k_CrystalBall] = {"k_List", "k_Eliminate", "k_Appear"},
	[ObstacleFootprintType.k_Poison] = {"k_Eliminate", "k_Appear"},
	[ObstacleFootprintType.k_Coin] = {"k_Eliminate", "k_Appear", "k_BlockEffect"},
	[ObstacleFootprintType.k_BrownFurball] = {"k_Appear", "k_GenerateSubItem"},
	[ObstacleFootprintType.k_Roost] = {"k_Appear", "k_GenerateSubItem", "k_Hit"},
	[ObstacleFootprintType.k_DigGround] = {"k_Hit", "k_Eliminate"},
	[ObstacleFootprintType.k_DigJewel] = {"k_Collect"},
	[ObstacleFootprintType.k_Balloon] = {"k_Eliminate", "k_Waste", "k_AddStep"},
	[ObstacleFootprintType.k_UFO] = {"k_Hit", "k_Lift"},
	[ObstacleFootprintType.k_Rocket] = {"k_Eliminate"},
	[ObstacleFootprintType.k_PoisonBottle] = {"k_GenerateSubItem"},
	[ObstacleFootprintType.k_TileBlocker] = {"k_Covered"},
	[ObstacleFootprintType.k_BigMonster] = {"k_Hit", "k_Attack", "k_HugeAttack", "k_Eliminate"},
	[ObstacleFootprintType.k_BlackFurball] = {"k_Hit", "k_Eliminate", "k_Attack"},
	[ObstacleFootprintType.k_KindMimosa] = {"k_Covered"},
	[ObstacleFootprintType.k_Snail] = {"k_Collect", "k_Steps"},
	[ObstacleFootprintType.k_Transmission] = {"k_Covered"},
	[ObstacleFootprintType.k_SeaAnimal] = {"k_List"},
	[ObstacleFootprintType.k_MagicLamp] = {"k_Hit", "k_Attack"},
	[ObstacleFootprintType.k_Honey] = {"k_Eliminate"},
	[ObstacleFootprintType.k_HoneyBottle] = {"k_Hit", "k_GenerateSubItem"},
	[ObstacleFootprintType.k_Sand] = {"k_Eliminate"},
	[ObstacleFootprintType.k_Icicle] = {"k_Hit", "k_Eliminate"},
	[ObstacleFootprintType.k_MagicStone] = {"k_Hit", "k_HitTargets"},
	[ObstacleFootprintType.k_BottleBlocker] = {"k_Hit", "k_Eliminate"},
	[ObstacleFootprintType.k_CrystalStone] = {"k_Active", "k_Attack"},
	[ObstacleFootprintType.k_Totems] = {"k_Attack", "k_HitTargets"},
	[ObstacleFootprintType.k_Lotus] = {"k_Eliminate", "k_Upgrade", "k_Expand"},
	[ObstacleFootprintType.k_SuperCute] = {"k_BackOff"},
	[ObstacleFootprintType.k_Puffer] = {"k_Eliminate", "k_HitTargets", "k_BlockEffect"},
	[ObstacleFootprintType.k_Missile] = {"k_Eliminate", "k_HitTargets"},
	[ObstacleFootprintType.k_BlockerCoverMaterial] = {"k_Hit", "k_Eliminate", "k_GenerateSubItem"},
	[ObstacleFootprintType.k_BlockerCover] = {"k_Hit", "k_Eliminate"},
	[ObstacleFootprintType.k_Blocker195] = {"k_Active", "k_Attack", "k_HugeAttack"},
	[ObstacleFootprintType.k_Blocker199] = {"k_Hit", "k_Active", "k_Attack", "k_HitTargets"},
	[ObstacleFootprintType.k_ColorFilter] = {"k_Hit", "k_HitTargets"},
	[ObstacleFootprintType.k_Chameleon] = {"k_Eliminate"},
	[ObstacleFootprintType.k_Blocker207] = {"k_Eliminate"},
	[ObstacleFootprintType.k_Blocker206] = {"k_Unlocked"},
	[ObstacleFootprintType.k_Pacman] = {"k_Attack", "k_HitTargets"},
	[ObstacleFootprintType.k_Blocker211] = {"k_Attack", "k_HitTargets"},
	[ObstacleFootprintType.k_Turret] = {"k_Attack", "k_HitTargets"},

	[ObstacleFootprintType.k_Ghost] = {"k_Appear", "k_Collect", "k_Steps", "k_IntendedSteps"},
	[ObstacleFootprintType.k_SunFlask] = {"k_Appear", "k_Hit", "k_Attack", "k_HitTargets"},
	[ObstacleFootprintType.k_Sunflower] = {"k_Attack", "k_Charge"},
	[ObstacleFootprintType.k_Squid] = {"k_List", "k_Attack", "k_HitTargets"},	--"appear_","charge_"额外检测生成
	[ObstacleFootprintType.k_LotusBlocker] = {"k_List", "k_Appear", "k_Hit", "k_Attack"},	--"generate_"额外检测生成
	[ObstacleFootprintType.k_Biscuit] = {"k_Upgrade", "k_Charge", "k_Attack", "k_HitTargets"},	--"appear","grid_count"额外检测生成
}

-- 会产生子类型的类型，需要把子类型的键值也加上
ObstacleFootprintHasSubType = { 
	[ObstacleFootprintType.k_BrownFurball] = ObstacleFootprintType.k_GreyFurball,
	[ObstacleFootprintType.k_DigJewel] = ObstacleFootprintType.k_DigGround,
	[ObstacleFootprintType.k_PoisonBottle] = ObstacleFootprintType.k_Poison,
	[ObstacleFootprintType.k_HoneyBottle] = ObstacleFootprintType.k_Honey,
	[ObstacleFootprintType.k_BlockerCoverMaterial] = ObstacleFootprintType.k_BlockerCover,
	[ObstacleFootprintType.k_Blocker206] = ObstacleFootprintType.k_Blocker207,
}

-- 需要检测初始数量的类型
ObstacleFootprintCheckInitAmountType = { 
	[ObstacleFootprintType.k_AddTime] = GameItemType.kAddTime,
	[ObstacleFootprintType.k_CrystalBall] = GameItemType.kCrystal,
	[ObstacleFootprintType.k_Poison] = GameItemType.kVenom,
	[ObstacleFootprintType.k_Coin] = GameItemType.kCoin,
	[ObstacleFootprintType.k_BrownFurball] = GameItemFurballType.kBrown,
	[ObstacleFootprintType.k_Roost] = GameItemType.kRoost,
	[ObstacleFootprintType.k_Ghost] = TileConst.kGhost,
	[ObstacleFootprintType.k_SunFlask] = GameItemType.kSunFlask,
	[ObstacleFootprintType.k_Squid] = GameItemType.kSquid,
	[ObstacleFootprintType.k_LotusBlocker] = GameItemType.kWanSheng,
}

-- 部分需要列出映射的情况
ObstacleFootprintItemTypeToFootprintName = { 
	[TileConst.kAnimal] = "animal",
	[100001] = "lineEffect",
	[100002] = "wrapEffect",
	[100003] = "magicBird",
	[TileConst.kMagicLamp] = ObstacleFootprintType.k_MagicLamp,
	[TileConst.kBottleBlocker] = ObstacleFootprintType.k_BottleBlocker,
	[TileConst.kPacman] = ObstacleFootprintType.k_Pacman,
	[TileConst.kCrystalStone] = ObstacleFootprintType.k_CrystalStone,
	[TileConst.kTotems] = ObstacleFootprintType.k_Totems,
	[TileConst.kColorFilter] = ObstacleFootprintType.k_ColorFilter,
	[TileConst.kFrosting1] = ObstacleFootprintType.k_Snow,
	[TileConst.kFrosting2] = ObstacleFootprintType.k_Snow,
	[TileConst.kFrosting3] = ObstacleFootprintType.k_Snow,
	[TileConst.kFrosting4] = ObstacleFootprintType.k_Snow,
	[TileConst.kFrosting5] = ObstacleFootprintType.k_Snow,
	[TileConst.kLock] = ObstacleFootprintType.k_Lock,
	[TileConst.kCoin] = ObstacleFootprintType.k_Coin,
	[TileConst.kCrystal] = ObstacleFootprintType.k_CrystalBall,
	[TileConst.kDigGround_1] = ObstacleFootprintType.k_DigGround,
	[TileConst.kDigGround_2] = ObstacleFootprintType.k_DigGround,
	[TileConst.kDigGround_3] = ObstacleFootprintType.k_DigGround,
	[TileConst.kGreyCute] = ObstacleFootprintType.k_GreyFurball,
	[TileConst.kBrownCute] = ObstacleFootprintType.k_BrownFurball,
	[TileConst.kBlackCute] = ObstacleFootprintType.k_BlackFurball,
	[TileConst.kPoison] = ObstacleFootprintType.k_Poison,
	[TileConst.kHoney] = ObstacleFootprintType.k_Honey,
	[TileConst.kHoneyBottle] = ObstacleFootprintType.k_HoneyBottle,
	[TileConst.kSand] = ObstacleFootprintType.k_Sand,
	[TileConst.kMagicStone_Up] = ObstacleFootprintType.k_MagicStone,
	[TileConst.kMagicStone_Right] = ObstacleFootprintType.k_MagicStone,
	[TileConst.kMagicStone_Down] = ObstacleFootprintType.k_MagicStone,
	[TileConst.kMagicStone_Left] = ObstacleFootprintType.k_MagicStone,
	[TileConst.kSuperCute] = ObstacleFootprintType.k_SuperCute,
	[TileConst.kPuffer] = ObstacleFootprintType.k_Puffer,
	[TileConst.kPufferActivated] = ObstacleFootprintType.k_Puffer,
	[TileConst.kMissile] = ObstacleFootprintType.k_Missile,
	[TileConst.kChameleon] = ObstacleFootprintType.k_Chameleon,
	[TileConst.kBlocker207] = ObstacleFootprintType.k_Blocker207,
	[TileConst.kTurret] = ObstacleFootprintType.k_Turret,
	[TileConst.kSunFlask] = ObstacleFootprintType.k_SunFlask,
	[TileConst.kGhost] = ObstacleFootprintType.k_Ghost,
}

-- function ObstacleFootprintManager:init()
-- 	printx(11, "============== + ObstacleFootprintManager, init !!!!! ==================")
-- end

function ObstacleFootprintManager:initData(gameBoardLogic, levelConfig)
	self.mainLogic = gameBoardLogic
	self.footprintMap = {}	-- clear old data

	self:fillInFeatureKeyOnInit(levelConfig)
	self:setInitAmountOfObstacle()

	-- printx(11, "Obstacle Footprint after init:", table.tostringByKeyOrder(self.footprintMap))
end

----------------------------------------------------------------------------------------------------------
function ObstacleFootprintManager:fillInFeatureKeyOnInit(levelConfig)
	local featureMap = GamePlayContext:getInstance():getFeatureMap()
	-- printx(11, "= = = Feature Key = = =", table.tostringByKeyOrder(featureMap))

	for key, _ in pairs(featureMap) do
		-- local key = string.lower(k)
		self:_setInitRecordOfType(key, levelConfig)

		-- 会产生其他障碍的，增加那些障碍的Key，保持Map键值数量稳定
		if ObstacleFootprintHasSubType[key] then
			local subType = ObstacleFootprintHasSubType[key]
			self:_setInitRecordOfType(subType, levelConfig)
		end
	end
end

function ObstacleFootprintManager:_setInitRecordOfType(key, levelConfig)
	local actionTypes = ObstacleFootprintTypeToActionMap[key]
	if actionTypes then
		for _, actionType in pairs(actionTypes) do
			if ObstacleFootprintAction[actionType] then
				local actionType = ObstacleFootprintAction[actionType]
				-- 有list的情况
				if actionType == ObstacleFootprintAction.k_List then
					if key == ObstacleFootprintType.k_Gift then
						local giftPropList = self:_getPossibleGiftListOfLevel(levelConfig)
						for propID, _ in pairs(giftPropList) do
							self:setRecord(key, actionType, 0, propID)
						end
					elseif key == ObstacleFootprintType.k_CrystalBall then
						for colour = 1, 6 do 
							self:setRecord(key, actionType, 0, colour)
						end
					elseif key == ObstacleFootprintType.k_SeaAnimal then
						if levelConfig.gameMode == GameModeType.SEA_ORDER then
							local animalList = self:_getPossibleSeaAnimalListOfLevel(levelConfig)
							-- printx(11, "arctic animalList", table.tostring(animalList))
							for animalName, _ in pairs(animalList) do
								self:setRecord(key, actionType, 0, animalName)
							end
						end
					elseif key == ObstacleFootprintType.k_Squid then
						local possibleTargets = SquidLogic:getPossibleCollectTargetOfLevel(levelConfig)
						for targetID, _ in pairs(possibleTargets) do
							local targetName = self:getSquidTargetSuffix(targetID)
							local actionType1 = ObstacleFootprintAction.k_Appear.."_"..targetName
							local actionType2 = ObstacleFootprintAction.k_Charge.."_"..targetName
							self:setRecord(key, actionType1, 0)
							self:setRecord(key, actionType2, 0)
						end
					elseif key == ObstacleFootprintType.k_LotusBlocker then
						self:addLotusBlockerOtherInitKey(key, levelConfig)
					end
				else
					self:setRecord(key, actionType, 0)
				end
			end
		end
	end

	if key == ObstacleFootprintType.k_Biscuit then
		self:addBiscuitOtherInitKey()
	end
end

function ObstacleFootprintManager:_getPossibleGiftListOfLevel(levelConfig)
	local giftList = {}
	local canReadFromConfig = false
	if levelConfig and levelConfig.gift then
		for _, val in pairs(levelConfig.gift) do
			local allProps = string.split(val, ",")
			for k, v in pairs(allProps) do
				local propPairs = string.split(v, "_")
				local propID = propPairs[1]
				if propID and not giftList[propID] then
					giftList[propID] = true
					canReadFromConfig = true
				end
			end
		end
	end

	if not canReadFromConfig then
		local allPropsIDs = {"10025", "10026", "10027", "10028", "10053", "10065", "10108", "10112"}	-- 所有可能出现的礼盒
		for index = 1, #allPropsIDs do 
			giftList[allPropsIDs[index]] = true
		end
	end

	return giftList
end

function ObstacleFootprintManager:_getPossibleSeaAnimalListOfLevel(levelConfig)
	local animalType = {}

	local function transSeaAnimalTypeToName(seaAnimalType)
		if seaAnimalType == SeaAnimalType.kPenguin or seaAnimalType == SeaAnimalType.kPenguin_H then
			return ObstacleFootprintSubType.k_Arctic_Penguin
		elseif seaAnimalType == SeaAnimalType.kSeal or seaAnimalType == SeaAnimalType.kSeal_V then
			return ObstacleFootprintSubType.k_Arctic_Seal
		elseif seaAnimalType == SeaAnimalType.kSeaBear then
			return ObstacleFootprintSubType.k_Arctic_PolarBear
		else
			return nil
		end
	end

	local boardMap = self.mainLogic.boardmap
	for r = 1, #boardMap do 
		for c = 1, #boardMap[r] do 
			local boardItem = boardMap[r][c]
			if boardItem then
				if boardItem.seaAnimalType and boardItem.seaAnimalType ~= 0 then
					local animalName = transSeaAnimalTypeToName(boardItem.seaAnimalType)
					if animalName and not animalType[animalName] then
						animalType[animalName] = true
					end
				end
			end
		end
	end

	return animalType
end

function ObstacleFootprintManager:getSquidTargetSuffix(targetID)
	-- printx(11, "= = = getSquidTargetSuffix!", targetID)
	local targetName = ObstacleFootprintItemTypeToFootprintName[targetID]
	if not targetName then
		targetName = "unkown"..targetID
	end
	-- printx(11, "= = = targetName:", targetName)
	return targetName
end

function ObstacleFootprintManager:getLotusBlockerGenerateActionType(itemID, animalDef)
	-- printx(11, "++++ getLotusBlockerGenerateActionType", itemID, animalDef)

	if itemID == 2 then
		-- 动物类别时，区分下是不是特效动物
		local itemSpecialType = AnimalTypeConfig.getSpecial(animalDef)
		if itemSpecialType == AnimalTypeConfig.kLine or itemSpecialType == AnimalTypeConfig.kColumn then
			itemID = 100001 -- 借用下鱿鱼的数字设定
		elseif itemSpecialType == AnimalTypeConfig.kWrap then
			itemID = 100002 -- 借用下鱿鱼的数字设定
		elseif itemSpecialType == AnimalTypeConfig.kColor then
			itemID = 100003 -- 这个跟鱿鱼无关了，创造一个新的
		end
	end
	local targetName = ObstacleFootprintItemTypeToFootprintName[itemID]

	if not targetName then
		targetName = "unkown"..targetID
	end

	local actionType = ObstacleFootprintAction.k_Generate.."_"..targetName
	return actionType
end

function ObstacleFootprintManager:addLotusBlockerOtherInitKey(key, levelConfig)

	local function addRecordOfItemType(itemType, animalDef)
		local actionType = self:getLotusBlockerGenerateActionType(itemType, animalDef)
        self:setRecord(key, actionType, 0)
        -- 会生成的子类型已经在 getFeatureMap 中加入了！真厉害！
	end

    local function addRecordByWanShengConfig( config )
        for i,v in pairs(config) do
        	if v.mType > 0 and v.num > 0 then
	            local ItemId = v.mType + 1
	            addRecordOfItemType(ItemId, v.animalDef)
	        end
        end
    end

    local function addRecordByWanShengDefaultConfig( config )
        if not config.mType or not config.num then return end
        if config.mType == 0 and config.num == 0 then return end

        if config.mType > 0 and config.num > 0 then
            local ItemId = config.mType + 1
    		addRecordOfItemType(ItemId, config.animalDef)
        end
    end

    -- printx(11, "wanShengConfig", table.tostringByKeyOrder(levelConfig.wanShengConfig))
    -- printx(11, "wanShengDropConfig", table.tostringByKeyOrder(levelConfig.wanShengDropConfig))
    -- printx(11, "wanShengNormalConfig", table.tostringByKeyOrder(levelConfig.wanShengNormalConfig))

	if levelConfig.wanShengConfig then addRecordByWanShengConfig(levelConfig.wanShengConfig) end
    if levelConfig.wanShengDropConfig then addRecordByWanShengConfig(levelConfig.wanShengDropConfig) end
    if levelConfig.wanShengNormalConfig then addRecordByWanShengDefaultConfig(levelConfig.wanShengNormalConfig) end
end

function ObstacleFootprintManager:addBiscuitOtherInitKey()
	local boardmap = self.mainLogic.boardmap
    for r = 1, #boardmap do 
        for c = 1, #boardmap[r] do 
            local boardData = boardmap[r][c]
            if boardData.biscuitData then
            	self:addRecord(ObstacleFootprintType.k_Biscuit, ObstacleFootprintAction.k_Appear, 1)

            	local gridCount = 0
            	if boardData.biscuitData.nRow and boardData.biscuitData.nCol then
            		gridCount = boardData.biscuitData.nRow * boardData.biscuitData.nCol
            	end
            	self:addRecord(ObstacleFootprintType.k_Biscuit, ObstacleFootprintAction.k_GridCount, gridCount)
            end
        end
    end
end

----------------------------------------------------------------------------------------------------------
function ObstacleFootprintManager:setRecord(obstacleType, actionType, setVal, subType)
	-- printx(11, "= = = = ObstacleFootprint setRecord:")
	-- printx(11, obstacleType, actionType, addVal, subType)
	assert(type(setVal) == "number")

	local recordKey = self:getRecordKey(obstacleType, actionType, subType)
	self.footprintMap[recordKey] = setVal
end

function ObstacleFootprintManager:addRecord(obstacleType, actionType, addVal, subType)
	-- printx(11, "= = = = ObstacleFootprint addRecord:")
	-- printx(11, obstacleType, actionType, addVal, subType)
	assert(type(addVal) == "number")

	if addVal ~= 0 then
		local recordKey = self:getRecordKey(obstacleType, actionType, subType)
		if not self.footprintMap[recordKey] then self.footprintMap[recordKey] = 0 end
		self.footprintMap[recordKey] = self.footprintMap[recordKey] + addVal
		-- printx(11, "Obstacle Footprint:", table.tostringByKeyOrder(self.footprintMap))
	end
end

function ObstacleFootprintManager:getRecordKey(obstacleType, actionType, subType)
	local recordKey = obstacleType.."_"..actionType

	-- printx(11, obstacleType, actionType, addVal, subType)
	if actionType == ObstacleFootprintAction.k_List and subType then
		if obstacleType == ObstacleFootprintType.k_CrystalBall then
			local colorTypeConfig = {"blue", "green", "brown", "purple", "red", "yellow"}
			local suffix = colorTypeConfig[subType]
			recordKey = obstacleType.."_"..suffix
		else
			recordKey = obstacleType.."_"..subType
		end
	end

	return recordKey
end

----------------------------------------------------------------------------------------------------------
function ObstacleFootprintManager:setInitAmountOfObstacle()
	for k, v in pairs(ObstacleFootprintCheckInitAmountType) do
		if k == ObstacleFootprintType.k_Squid then
			-- 鱿鱼需要按类型统计appear
			local amountByTarget = SquidLogic:getSquidAmountOnBoardByTargetType(self.mainLogic)
			for targetType, amountVal in pairs(amountByTarget) do
				local targetName = self:getSquidTargetSuffix(targetType)
				local actionStr = ObstacleFootprintAction.k_Appear.."_"..targetName
				self:addRecord(k, actionStr, amountVal)
			end
		else
			local isFurball = false
			local isGhost = false
			if k == ObstacleFootprintType.k_BrownFurball then 
				isFurball = true 
			elseif k == ObstacleFootprintType.k_Ghost then
				isGhost = true
			end

			local amount = self.mainLogic:getItemAmountOfType(v, isFurball, isGhost)
			if amount > 0 then
				self:addRecord(k, ObstacleFootprintAction.k_Appear, amount)
			end
		end
	end

	self:initScanBoard()
end

function ObstacleFootprintManager:initScanBoard()
	local tileBlockerCoverAmount = 0
	local lockedTransmissionAmount = 0

	local boardmap = self.mainLogic.boardmap
	for r = 1, #boardmap do 
		for c = 1, #boardmap[r] do 
			local boardItem = boardmap[r][c]
			if boardItem then
				if boardItem.isReverseSide and self:tileBlockerHasSthInCover(r, c) then
					self:addRecord(ObstacleFootprintType.k_TileBlocker, ObstacleFootprintAction.k_Covered, 1)
				end

				if boardItem.transType > 0 and boardItem.isTransLock then
					lockedTransmissionAmount = lockedTransmissionAmount + 1
				end
			end
		end
	end

	self:addRecord(ObstacleFootprintType.k_TileBlocker, ObstacleFootprintAction.k_Covered, tileBlockerCoverAmount)
	self:addRecord(ObstacleFootprintType.k_Transmission, ObstacleFootprintAction.k_Covered, lockedTransmissionAmount)
end

function ObstacleFootprintManager:tileBlockerHasSthInCover(r, c)
	local item = self.mainLogic.gameItemMap[r][c]
	if item and not item.isEmpty then
		-- printx(11, "hasItem", table.tostringByKeyOrder(item))
		return true
	end

	local boardItem = self.mainLogic.boardmap[r][c]
	if boardItem then
		if boardItem.iceLevel > 0 or boardItem.sandLevel > 0 or boardItem.blockerCoverMaterialLevel > 0 or boardItem.lotusLevel > 0 
			or boardItem.isCollector or boardItem.snailRoadType > 0 or boardItem.isSnailCollect or boardItem.blockerCoverFlag > 0 
			or boardItem.colorFilterColor > 0 
			then
			-- printx(11, "hasBoardItem", table.tostringByKeyOrder(boardItem))
			return true
		end
	end

	return false
end

----------------------------------------------------------------------------------------------------------
function ObstacleFootprintManager:addAppearOnCannonProduce(data)
	-- printx(11, "addAppearOnCannonProduce", table.tostringByKeyOrder(data))
	if data then
		if data.ItemType == GameItemType.kAddTime then
			self:addRecord(ObstacleFootprintType.k_AddTime, ObstacleFootprintAction.k_Appear, 1)
		elseif data.ItemType == GameItemType.kCrystal then
			self:addRecord(ObstacleFootprintType.k_CrystalBall, ObstacleFootprintAction.k_Appear, 1)
		elseif data.ItemType == GameItemType.kCoin then
			self:addRecord(ObstacleFootprintType.k_Coin, ObstacleFootprintAction.k_Appear, 1)
		elseif data.ItemType == GameItemType.kWanSheng then
			self:addRecord(ObstacleFootprintType.k_LotusBlocker, ObstacleFootprintAction.k_Appear, 1)
		end

		if data.furballLevel >= 1 and data.furballType == GameItemFurballType.kBrown then
			self:addRecord(ObstacleFootprintType.k_BrownFurball, ObstacleFootprintAction.k_Appear, 1)
		end
	end
end

function ObstacleFootprintManager:addCrystalBallEliminateRecord(item)
	-- printx(11, "addCrystalBallEliminateRecord, flag:", flag)
	self:addRecord(ObstacleFootprintType.k_CrystalBall, ObstacleFootprintAction.k_Eliminate, 1)

	if item then
		-- local colourIndex = AnimalTypeConfig.colorTableToIndex[item._encrypt.ItemColorType]
		--注意，上面这种写法是非法的，因为_encrypt.ItemColorType是加密的，实际的内存引用地址可能会变化
		
		local colourIndex = AnimalTypeConfig.convertColorTypeToIndex( item._encrypt.ItemColorType )
		self:addRecord(ObstacleFootprintType.k_CrystalBall, ObstacleFootprintAction.k_List, 1, colourIndex)
	end
end

function ObstacleFootprintManager:addBlockEffectRecord(item)
	if item then
		if item.ItemType == GameItemType.kCoin then
			self:addRecord(ObstacleFootprintType.k_Coin, ObstacleFootprintAction.k_BlockEffect, 1)
			-- printx(11, debug.traceback())
		elseif item.ItemType == GameItemType.kPuffer then
			self:addRecord(ObstacleFootprintType.k_Puffer, ObstacleFootprintAction.k_BlockEffect, 1)
		end
	end
end

----------------------------------------------------------------------------------------------------------
function ObstacleFootprintManager:getMergedFinalPlayInfo(oldPlayInfo)
	-- printx(11, "oldPlayInfo", table.tostringByKeyOrder(oldPlayInfo))
	local mergedInfo = {}

	if oldPlayInfo then
		for k, v in pairs(oldPlayInfo) do
			mergedInfo[k] = v
		end
	end

	--
--
--

	
	for key, val in pairs(self.footprintMap) do
		mergedInfo[key] = val
	end
	
	-- printx(11, "mergedInfo", table.tostringByKeyOrder(mergedInfo))
	return mergedInfo
end

-- ObstacleFootprintManager:init()