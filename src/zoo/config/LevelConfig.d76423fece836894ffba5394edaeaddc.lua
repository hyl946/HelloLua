require "zoo.config.TileMetaData"
require "zoo.config.SnailConfigData"
require "zoo.data.LevelMapManager"
require "zoo.config.UncertainCfgMeta"
require "zoo.config.HedgehogBoxCfg"
require "zoo.config.TileMoveConfig"


-----------------------------------------------------------------------------
-- include 
-----------------------------------------------------------------------------
local function isHorizontalEndessLevel(gameMode)
	return gameMode == GameModeType.OLYMPIC_HORIZONTAL_ENDLESS or gameMode == GameModeType.SPRING_HORIZONTAL_ENDLESS
end

local DependingAssetsTypeNameMap = 
{
	[TileConst.kPortalEnter]	= {"flash/link_item.plist"},
	[TileConst.kPortalExit]		= {"flash/link_item.plist"},
	[TileConst.kFrosting] 		= {"flash/mapSnow.plist"},
	[TileConst.kFrosting1]		= {"flash/mapSnow.plist"},
	[TileConst.kFrosting2]		= {"flash/mapSnow.plist"},
	[TileConst.kFrosting3]		= {"flash/mapSnow.plist"},
	[TileConst.kFrosting4]		= {"flash/mapSnow.plist"},
	[TileConst.kFrosting5]		= {"flash/mapSnow.plist"},
	[TileConst.kLock] 			= {"flash/mapLock.plist"},
	[TileConst.kCrystal]		= {"flash/crystal_anim.plist"},
	[TileConst.kLight1] 		= {"flash/mapLight.plist"},
	[TileConst.kLight2] 		= {"flash/mapLight.plist"},
	[TileConst.kLight3] 		= {"flash/mapLight.plist"},
	[TileConst.kCoin]       	= {"flash/coin.plist"},
	[TileConst.kPoison]     	= {"flash/venom.plist"},
	[TileConst.kPoisonBottle]	= {"flash/venom.plist", "flash/PoisonBottle.plist","flash/octopusForbidden.plist"},
	[TileConst.kGreyCute]		= {"flash/ball_grey.plist"},
	[TileConst.kBrownCute]		= {"flash/ball_brown.plist", "flash/ball_grey.plist"},
	[TileConst.kRoost]			= {"flash/roost.plist"},
	[TileConst.kBalloon]		= {"flash/balloon.plist"},
	[TileConst.kDigGround_1]	= {"flash/dig_block.plist"},
	[TileConst.kDigGround_2]	= {"flash/dig_block.plist"},
	[TileConst.kDigGround_3]	= {"flash/dig_block.plist"},
	[TileConst.kDigJewel_1]		= {"flash/dig_block.plist"},
	[TileConst.kDigJewel_2]		= {"flash/dig_block.plist"},
	[TileConst.kDigJewel_3]		= {"flash/dig_block.plist"},
	[TileConst.kDigJewel_1_blue]= {"flash/dig_block.plist"},
	[TileConst.kDigJewel_2_blue]= {"flash/dig_block.plist"},
	[TileConst.kDigJewel_3_blue]= {"flash/dig_block.plist"},
    [TileConst.kYellowDiamondGrass1]		= {"flash/week_gress.plist"},
	[TileConst.kYellowDiamondGrass2]		= {"flash/week_gress.plist"},
	-- [TileConst.kGoldZongZi]		= {"flash/dig_block.plist"},
	[TileConst.kSuperBlocker]	= {"flash/dig_block.plist"},
	[TileConst.kAddMove]		= {"flash/add_move.plist"},
	[TileConst.kTileBlocker]	= {"flash/TileBlocker.plist"},
	[TileConst.kTileBlocker2]	= {"flash/TileBlocker.plist"},
	[TileConst.kBigMonster]		= {"flash/big_monster.plist", "flash/big_monster_ext.plist"},
	[TileConst.kBlackCute]		= {"flash/ball_black.plist"},
	[TileConst.kMimosaLeft]		= {"flash/mimosa.plist"},
	[TileConst.kMimosaRight]	= {"flash/mimosa.plist"},
	[TileConst.kMimosaUp]		= {"flash/mimosa.plist"},
	[TileConst.kMimosaDown]		= {"flash/mimosa.plist"},
	[TileConst.kKindMimosaLeft]		= {"flash/mimosa.plist"},
	[TileConst.kKindMimosaRight]	= {"flash/mimosa.plist"},
	[TileConst.kKindMimosaUp]		= {"flash/mimosa.plist"},
	[TileConst.kKindMimosaDown]		= {"flash/mimosa.plist"},
	[TileConst.kSnailSpawn]		= {"flash/snail.plist", "flash/snail_road.plist"},
	[TileConst.kSnail]			= {"flash/snail.plist", "flash/snail_road.plist"},
	[TileConst.kSnailCollect]	= {"flash/snail.plist", "flash/snail_road.plist"},
	--[TileConst.kHedgehog]  		= {"flash/snail.plist", "flash/hedgehog.plist","flash/hedgehog_road.plist", "flash/hedgehog_target.plist", "flash/christmas_other.plist",},
	[TileConst.kHedgehog]  		= {"flash/snail.plist", "flash/hedgehog_road.plist", "flash/hedgehog_target.plist", "flash/christmas_other.plist",},
	[TileConst.kMayDayBlocker1] = {"flash/boss_mayday.plist"},
	[TileConst.kMayDayBlocker2] = {"flash/boss_mayday.plist"},
	[TileConst.kMayDayBlocker3] = {"flash/boss_mayday.plist"},
	[TileConst.kMayDayBlocker4] = {"flash/boss_mayday.plist"},
	[TileConst.kRabbitProducer] = {"flash/rabbit.plist"},
	[TileConst.kMagicLamp]		= {"flash/magic_lamp.plist"},
	[TileConst.kHoneyBottle]	= {"flash/honey_bottle.plist"},
	[TileConst.kHoney]			= {"flash/honey_bottle.plist"},
	[TileConst.kAddTime]		= {"flash/add_time.plist"},
	-- [TileConst.kMagicTile]		= {"flash/mole_weeklyRace_magicTile.plist"},
	[TileConst.kSand]			= {"flash/sand_idle_clean.plist", "flash/sand_move.plist"},
	[TileConst.kQuestionMark]	= {"flash/question_mark.plist"},
	[TileConst.kChain1]			= {"flash/ice_chain.plist"},
	[TileConst.kChain1_Up]		= {"flash/ice_chain.plist"},
	[TileConst.kChain1_Right]	= {"flash/ice_chain.plist"},
	[TileConst.kChain1_Down]	= {"flash/ice_chain.plist"},
	[TileConst.kChain1_Left]	= {"flash/ice_chain.plist"},
	[TileConst.kChain2]			= {"flash/ice_chain.plist"},
	[TileConst.kChain2_Up]		= {"flash/ice_chain.plist"},
	[TileConst.kChain2_Right]	= {"flash/ice_chain.plist"},
	[TileConst.kChain2_Down]	= {"flash/ice_chain.plist"},
	[TileConst.kChain2_Left]	= {"flash/ice_chain.plist"},
	[TileConst.kChain3]			= {"flash/ice_chain.plist"},
	[TileConst.kChain3_Up]		= {"flash/ice_chain.plist"},
	[TileConst.kChain3_Right]	= {"flash/ice_chain.plist"},
	[TileConst.kChain3_Down]	= {"flash/ice_chain.plist"},
	[TileConst.kChain3_Left]	= {"flash/ice_chain.plist"},
	[TileConst.kChain4]			= {"flash/ice_chain.plist"},
	[TileConst.kChain4_Up]		= {"flash/ice_chain.plist"},
	[TileConst.kChain4_Right]	= {"flash/ice_chain.plist"},
	[TileConst.kChain4_Down]	= {"flash/ice_chain.plist"},
	[TileConst.kChain4_Left]	= {"flash/ice_chain.plist"},
	[TileConst.kChain5]			= {"flash/ice_chain.plist"},
	[TileConst.kChain5_Up]		= {"flash/ice_chain.plist"},
	[TileConst.kChain5_Right]	= {"flash/ice_chain.plist"},
	[TileConst.kChain5_Down]	= {"flash/ice_chain.plist"},
	[TileConst.kChain5_Left]	= {"flash/ice_chain.plist"},
	[TileConst.kMagicStone_Up]	= {"flash/magic_stone.plist"},
	[TileConst.kMagicStone_Right]= {"flash/magic_stone.plist"},
	[TileConst.kMagicStone_Down]= {"flash/magic_stone.plist"},
	[TileConst.kMagicStone_Left]= {"flash/magic_stone.plist"},
	[TileConst.kMoveTile]		= {"flash/map_move_tile.plist"},
	[TileConst.kBottleBlocker]		= {"flash/bottle_blocker_animals.plist", "flash/bottle_blocker_effect.plist"},
	[TileConst.kCrystalStone]		= {"flash/crystal_stone.plist"},
	[TileConst.kWukong]		= {"flash/wukong.plist" },
	[TileConst.kTotems]			= {"flash/tile_totems.plist", "flash/tile_high_lights.plist"},
	[TileConst.kLotusLevel1]			= {"flash/lotus.plist"},
	[TileConst.kLotusLevel2]			= {"flash/lotus.plist"},
	[TileConst.kLotusLevel3]			= {"flash/lotus.plist"},
	[TileConst.kSuperCute]			= {"flash/ball_super.plist"},

	[TileConst.kDoubleSideTurnTile]	= {"flash/TileBlocker.plist" , "flash/TileDoubleSideBlocker.plist"},
	--[TileConst.kDoubleSideTurnTile]	= {"flash/TileBlocker.plist" , "flash/venom.plist", "flash/PoisonBottle.plist","flash/octopusForbidden.plist"},
	[TileConst.kOlympicBlocker]		= {"flash/autumn2018/mid_autumn_res.plist", "flash/autumn2018/mid_autumn_bomb.plist"},
	[TileConst.kOlympicLockBlocker]	= {"flash/autumn2018/mid_autumn_res.plist"},

	[TileConst.kTangChicken]	= {"flash/nationday2017/nationday2017_in_game.plist"},
	-- [TileConst.kMissile]	= {"flash/missile.plist"},
	[TileConst.kBlockerCoverMaterial]	= {"flash/stake.plist" , "flash/stake_leaf.plist"},
	[TileConst.kBlockerCover]	= {"flash/stake_leaf.plist"},
	[TileConst.kBlocker195]	= {"flash/blocker195.plist"},
	[TileConst.kBlocker199]	= {"flash/blocker199.plist"},
	[TileConst.kColorFilter]	= {"flash/color_filter_a.plist", "flash/color_filter_b.plist"},
	[TileConst.kChameleon] = {"flash/chameleon.plist"},
	[TileConst.kBlocker206]	= {"flash/ball_super.plist" , "flash/lock_box_res.plist"},
	[TileConst.kBlocker207]	= {"flash/crystal_stone.plist" , "flash/lock_box_res.plist"},
	[TileConst.kPacman]	= {"flash/pacman.plist"},
	[TileConst.kPacmansDen]	= {"flash/pacman.plist"},
	[TileConst.kBlocker211] = {"flash/blocker211.plist"}, 
    [TileConst.kTurret]	= {"flash/turret.plist", "flash/turreteffect.plist"},
    [TileConst.kMoleBossCloud]	= {"flash/week_gress4.plist"},
	[TileConst.kGhost]			= {"flash/ghostBlocker.plist"},
	[TileConst.kGhostAppear]	= {"flash/ghostBlocker.plist"},
	[TileConst.kSunFlask] = {"flash/sunFlask.plist"}, 
	[TileConst.kSunflower] = {"flash/sunflower.plist"}, 
	[tostring(TileConst.kGravitySkin) .. "_1"] = { "flash/gravitySkin_Water.plist" }, 
	[tostring(TileConst.kGravitySkin) .. "_2"] = {"flash/sand_idle_clean.plist", "flash/sand_move.plist"}, 
	[tostring(TileConst.kGravitySkin) .. "_3"] = {"flash/honey_bottle.plist"}, 
	-- [TileConst.kGravitySkin] = {"flash/mapLight.plist"}, 
	[TileConst.kSquid] = {"flash/squidBlocker.plist"}, 
    [TileConst.kWanSheng] = {"flash/Smallicon_inItem.plist","flash/tile_wansheng.plist"}, 

    [TileConst.kBiscuit] = {"flash/biscuit_sp.plist"},

}

-----------------------------------------------------------------------------
-- base map config vo [LevelConfig]
-----------------------------------------------------------------------------
LevelConfig = class()

function LevelConfig:ctor()
	self.tileMap = TileMetaData:getEmptyArray()		--地图信息
	self.animalMap = nil							--动物信息
	self.gameMode = ""								--游戏模式
	self.numberOfColors = 6							--颜色数量
	self.defaultColorCfg = 0 						--默认颜色配置 10进制转2进制
	self.scoreTargets = {10000, 20000, 30000}		--1\2\3星目标
	self.randomSeed = 0								--随机种子
	self.portals = nil								--
	self.level = 1 									--等级
	self.dropRules = nil							--掉落规则
    self.moveLimit = 0								--移动限制

    --经典玩法------时间到则结束
	self.timeLimit = -1								--时间限制
	--指定物品消除指定次数
	self.orderMap = {}								--消除指定动物指定数量的列表
	--掉落型游戏方式
	self.ingredients = {}							--原料信息
	self.numIngredientsOnScreen = 1 				--屏幕上已有原料数量
	self.ingredientSpawnDensity = 15 				--原料再生密度？？？
	self.everyStepDropNum = 1						--豆荚每M步生成N个，N默认为1
	--时间限制型挖掘--步数限制型挖掘
	self.digTileMap = {}							--挖掘地图信息
	self.clearTargetLayers = 5 						--目标层数--达到挖掘目标层数 胜利

	self.balloonFrom = 0                          --气球起始剩余步数
	self.addMoveBase = GamePlayConfig_Add_Move_Base   -- 气球爆炸增加的步数

	self.hasDropDownUFO = false                     --是否有UFO

	self.rabbitInitNum = 0							-- 初始兔子数
	self.honeys = 0    
	self.missileSplit = 0                           -- 冰封导弹分裂数

	self.dropBuff = nil								-- 神奇掉落规则    
	self.tileMoveCfg = nil      					-- 移动地块配置  
	self.dropCrystalStoneTypes = nil
	self.singleDropCfg = nil						-- 独立掉落口掉落规则（颜色）{"itemId":[color1, color2, ...], ...}
	self.hScrollWaitCfg = nil

	self.fallingLogic = 0 --  掉落算法版本
    self.productLogic = 0 --  生成口算法版本

    self.sunflowersAppetite = 0

	self.featureMap = {}
end

function LevelConfig:loadConfig(level, levelMeta)
	local config = levelMeta.gameData
	self.level = level 							--等级
	self.gameMode = config.gameModeName				--游戏模式
	self.numberOfColors = config.numberOfColours	--颜色数量
	self.defaultColorCfg = config.defaultColor or 0	--默认颜色配置(兼容原关卡配置 加默认值)
	self.crossStrengthCfg = config.crossStrengthCfg --障碍附加参数（如妖精瓶子的等级）
	self.randomPropData = config.randomPropData --  道具云块
    self.SunmerFish3x3GetNum = 0 --3*3掉落
    self.JamSpeardMaxNum = 0 --果酱收集数

    self.fallingLogic = config.fallingLogic --  掉落算法版本
    self.productLogic = config.productLogic --  生成口算法版本

	local addInfoCfgBySide = config.addInfoCfg and config.addInfoCfg[1] or nil
	self.tileMap = TileMetaData:convertArrayFromBitToTile(config.tileMap, config.tileMap2, self.crossStrengthCfg, config.tileAttrsCfg, addInfoCfgBySide)	--将配置的数据赋值给tilemap。地形信息

    
    local CurLevelType = LevelType:getLevelTypeByLevelId( level )
    if CurLevelType == GameLevelType.kSummerFish then
        for i=1,9 do
            for j=1, 9 do
                local Info = self.tileMap[i][j]:getAddInfoOfProperty( TileConstVirtual.kSeaAnimalProduct )
                if Info  then
                    self.SunmerFish3x3GetNum = string.split(Info, "|")[1]
                    self.SunmerFish3x3GetNum = tonumber( self.SunmerFish3x3GetNum)
                    break
                end
            end
        end
    end

    if self.gameMode == GameModeType.JAM_SPERAD then
        for i=1,9 do
            for j=1, 9 do

                local bEmpty = self.tileMap[i][j]:hasProperty(TileConst.kEmpty)
                
                if not bEmpty then
                    local Info = self.tileMap[i][j]:hasProperty(TileConst.kJamSperad)
                    if not Info  then
                        self.JamSpeardMaxNum = self.JamSpeardMaxNum + 1
                    end
                end
            end
        end
    end


	if config.uncertainCfg1 and config.uncertainCfg2 then
		self.uncertainCfg1 = UncertainCfgMeta:create(config.uncertainCfg1)                      --boss掉血产生的问号障碍配置
		self.uncertainCfg2 = UncertainCfgMeta:create(config.uncertainCfg2)                      --boss死亡产生的问号障碍配置
	end

	if config.snailCfg and config.snailCfg.initNum and config.snailCfg.routeRawData then
		self.snailInitNum = config.snailCfg.initNum
		self.snailMoveToAdd = config.snailCfg.moveToAdd
		self.routeRawData = SnailConfigData:convertArrayFromBitToTile(config.snailCfg.routeRawData)
	end

	-- 礼盒配置
	-- "gift":{"1_0":"10028_1,10026_1,10027_1","1_3":"10025_1"}
	if (config.gift) then
		self.gift = config.gift
	end

	-- 鱿鱼配置
	-- "squidConfig":{"2_6":"87_2","6_5":"100001_3","3_2":"201_36","7_2":"7_48"}
	if (config.squidConfig) then
		self.squidConfig = config.squidConfig
	end

    -- 万生配置
	-- "wanShengConfig":{"5_5":{"num":1,"attr":"","mType":2}
	if (config.wanShengConfig) then
		self.wanShengConfig = config.wanShengConfig
	end

    -- 万生掉落配置
	-- "wanShengDropConfig":{"5_5":{"num":1,"attr":"","mType":2}
	if (config.wanShengDropConfig) then
		self.wanShengDropConfig = config.wanShengDropConfig
	end

    -- 万生默认配置
	-- "wanShengNormalConfig":{"num":1,"attr":"","mType":2}
	if (config.wanShengNormalConfig) then
		self.wanShengNormalConfig = config.wanShengNormalConfig
	end

	if config.hedgehogConfig and config.hedgehogConfig.routeRawData then
		self.snailInitNum = 1
		self.routeRawData = SnailConfigData:convertArrayFromBitToTile(config.hedgehogConfig.routeRawData)
		self.digExtendRouteData = SnailConfigData:convertArrayFromBitToTile(config.hedgehogConfig.digExtendRouteData, true)
	end

	if config.hedgehogBoxCfg then
		self.hedgehogBoxCfg = HedgehogBoxCfg:create(config.hedgehogBoxCfg)
	end

	self:updateScoreTargets(levelMeta)		--分数目标

	self.randomSeed = config.randomSeed				--随机种子----服务器将随机种子发给客户端--
	self.portals = config.portals or {}				--
	self.animalMap = config.specialAnimalMap		--特殊的动物地图


	local function getBottleBlockerColor( tileDef )
		if tileDef and tileDef:hasProperty(TileConst.kBottleBlocker) and tileDef:getCrossStrengthColor() ~= 0 then
			local colorDef = bit.lshift( 1 , tileDef:getCrossStrengthColor() )
			local def = bit.bor( colorDef , 0 )
			return def
		end

		return nil
	end

	for r = 1, #self.tileMap do
		for c = 1, #self.tileMap[r] do
			local tileDef = self.tileMap[r][c]
			local color = getBottleBlockerColor( tileDef )
			if color then
				self.animalMap[r][c] = color
			end
		end
	end

	
    self.moveLimit = config.moveLimit 				--移动步数限制
	self.timeLimit = config.timeLimit				--时间限制
	self.replaceColorMaxNum = config.replaceColorMaxNum
	self.addMoveBase = config.addMoveBase
	self.balloonFrom = config.balloonFrom
	self.hasDropDownUFO = config.hasDropDownUFO     --是否有UFO
	self.pm25 = config.pm25
	if config.trans2 then 
		self.trans = config.trans2
		self.transType = 2
	else
		self.trans = config.trans
		self.transType = 1
	end
	
	self.seaAnimalMap = config.seaAnimalMap
	self.seaFlagMap = config.seaFlagMap
	self.dropBuff = config.dropBuff
	self.tileMoveCfg = TileMoveConfig:create(config.moveTileCfg, self.gameMode)


	----------以下为 老版本数据的掉落规则
	self.dropRules = config.dropRules 				--
	self.dropCrystalStoneTypes = self:getRealColorValues(config.dropCrystalStoneTypes)
	self.singleDropCfg = self:initSingleDropConfig(config.singleDrop, config.dropCrystalStoneTypes)
	----------------------------

	----------以下为 新版本数据的掉落规则
	self.productRuleGroup = config.productRuleGroup or {}
	self.productRuleConfig = config.productRuleConfig or {}
	self.productRuleGlobalConfig = config.productRuleGlobalConfig or {}
	----------------------------


	if config.hScrollWaitCfg then
		self.hScrollWaitCfg = {}
		for col, num in pairs(config.hScrollWaitCfg) do
			self.hScrollWaitCfg[tonumber(col)] = tonumber(num)
		end
	end

	self.rabbitInitNum = config.rabbitInitNum   	-- 初始兔子数量
	self.honeys = config.honeys                     -- 蜂蜜罐转化为蜂蜜的数量
	self.blockerCoverTarNum1 = config.blockerCoverTarNum1 or 0
	self.blockerCoverTarNum2 = config.blockerCoverTarNum2 or 0
	self.blockerCoverTarNum3 = config.blockerCoverTarNum3 or 0
	self.missileSplit = config.missileSplit
	self.sunflowersAppetite = config.sunflowersAppetite
	if self.timeLimit == nil then 
		self.timeLimit = 0;
	end
	self.addTime = config.addTime or 5 --时间关每个单位增加时间
	if config.gourdNums then--星星瓶配置解析
		self.blocker195Nums = {}
		for k, v in ipairs(config.gourdNums) do
			for k1, v1 in pairs(v) do
				self.blocker195Nums[k1] = v1
			end
		end
	end
	self.blocker199Cfg = self:getRealColorValues(config.tile198Cfg)--水母宝宝配置解析
	if config.tile205Cfg then --配对锁配置解析
		self.blocker206Cfg = {}
		for k, v in ipairs(config.tile205Cfg) do
			for k1, v1 in pairs(v) do
				self.blocker206Cfg[tonumber(k1)] = tonumber(v1)
			end
		end
	end

	--解析吃豆人配置
	if config.pacmanData then
		local pacmanConfigData = {}
		pacmanConfigData["devourCount"] = config.pacmanData["devourCount"]
		pacmanConfigData["stepNum"] = config.pacmanData["stepNum"]
		pacmanConfigData["unlockNum"] = config.pacmanData["unlockNum"]
		pacmanConfigData["boardMaxNum"] = config.pacmanData["boardMaxNum"]
		pacmanConfigData["boardMinNum"] = config.pacmanData["boardMinNum"]
		pacmanConfigData["produceMaxNum"] = config.pacmanData["produceMaxNum"]
		local colourData = config.pacmanData["colourData"]
		local permittedColours = {}
		if colourData then
			for i, v in pairs(colourData) do
				-- local realColour = AnimalTypeConfig.convertIndexToColorType(i)
                table.insert(permittedColours, i)
            end
		end
		pacmanConfigData["permittedColours"] = permittedColours

		self.pacmanConfig = pacmanConfigData
		-- printx(11, "pacmanConfig:", table.tostring(self.pacmanConfig))
	end

	if config.ghostData then
		local ghostConfigData = {}
		ghostConfigData["stepNum"] = config.ghostData["stepNum"]
		ghostConfigData["unlockNum"] = config.ghostData["unlockNum"]
		ghostConfigData["boardMaxNum"] = config.ghostData["boardMaxNum"]
		ghostConfigData["boardMinNum"] = config.ghostData["boardMinNum"]
		ghostConfigData["produceMaxNum"] = config.ghostData["produceMaxNum"]
		self.ghostConfig = ghostConfigData
		-- printx(11, "ghostConfig:", table.tostring(self.ghostConfig))
	end

	local function createDigTileMapByConfig(gameMode, digTileMap, digTileMap2, tileAttrsCfg, addInfoCfg)
		local digTileAttrsCfg = nil
		if tileAttrsCfg then
			digTileAttrsCfg = {}
			if isHorizontalEndessLevel(gameMode) then
				for r = 1, #tileAttrsCfg do
					digTileAttrsCfg[r] = {}
					for c = 10, table.maxn(tileAttrsCfg[r]) do
						digTileAttrsCfg[r][c-9] = tileAttrsCfg[r][c]
					end
				end
			else
				for r = 10, #tileAttrsCfg do
					digTileAttrsCfg[r-9] = tileAttrsCfg[r]
				end
			end
		end
		local digAddInfoCfg = {}
		if not table.isEmpty(addInfoCfg) then
			if isHorizontalEndessLevel(gameMode) then
				for r = 1, table.maxn(addInfoCfg) do
					digAddInfoCfg[r] = {}
					if addInfoCfg[r] then
						for c = 10, table.maxn(addInfoCfg[r]) do
							digAddInfoCfg[r][c-9] = addInfoCfg[r][c]
						end
					end
				end
			else
				for r = 10, table.maxn(addInfoCfg) do
					digAddInfoCfg[r-9] = addInfoCfg[r]
				end
			end
		end
		return TileMetaData:convertArrayFromBitToTile(digTileMap or {}, digTileMap2, nil, digTileAttrsCfg, digAddInfoCfg)
	end

	local function createDigTileMap()
		self.digTileMap = createDigTileMapByConfig(self.gameMode, config.digTileMap, config.digTileMap2, config.tileAttrsCfg, addInfoCfgBySide)
	end

    if self.gameMode == GameModeType.CLASSIC then				--经典玩法--时间到则结束
	elseif self.gameMode == GameModeType.ORDER or self.gameMode == GameModeType.SEA_ORDER then	--指定物品消除指定次数
		self.orderMap = config.orderList 			
	elseif self.gameMode == GameModeType.DROP_DOWN or self.gameMode == GameModeType.TASK_UNLOCK_DROP_DOWN then 			--下落型玩法
		self.ingredients = config.ingredients
		self.numIngredientsOnScreen = config.numIngredientsOnScreen
		self.ingredientSpawnDensity = config.ingredientSpawnDensity
		self.everyStepDropNum = config.everyStepDropNum or 1
		if self.everyStepDropNum < 1 then self.everyStepDropNum = 1 end
	elseif self.gameMode == GameModeType.DIG_TIME then			--时间限制型挖掘
		createDigTileMap()
		self.clearTargetLayers = config.clearTargetLayers	--目标层数--达到挖掘目标层数 胜利
	elseif self.gameMode == GameModeType.DIG_MOVE then			--步数限制型挖掘
		createDigTileMap()
		self.clearTargetLayers = config.clearTargetLayers	--目标层数--达到挖掘目标层数 胜利
	elseif self.gameMode == GameModeType.DIG_MOVE_ENDLESS then
		createDigTileMap()
		self.clearTargetLayers = config.clearTargetLayers
	elseif self.gameMode == GameModeType.MAYDAY_ENDLESS 
		or self.gameMode == GameModeType.HALLOWEEN 
		or self.gameMode == GameModeType.WUKONG_DIG_ENDLESS 
		or self.gameMode == GameModeType.MOLE_WEEKLY_RACE
		then
		createDigTileMap()
		self.clearTargetLayers = config.clearTargetLayers
		if self.gameMode == GameModeType.HALLOWEEN then
			self.dragonBoatPropGen = config.dragonBoatPropGen	-- 端午关卡道具掉落配置
		end

		if self.gameMode == GameModeType.WUKONG_DIG_ENDLESS then
			self.monkeyChestConfig = config.monkeyChestConfig
		end
	elseif self.gameMode == GameModeType.HEDGEHOG_DIG_ENDLESS then
		createDigTileMap()
		self.clearTargetLayers = config.clearTargetLayers
	elseif self.gameMode == GameModeType.OLYMPIC_HORIZONTAL_ENDLESS then
		createDigTileMap()
		self.clearTargetLayers = config.clearTargetLayers
	elseif self.gameMode == GameModeType.SPRING_HORIZONTAL_ENDLESS then
		createDigTileMap()
		self.clearTargetLayers = config.clearTargetLayers
    elseif self.gameMode == GameModeType.JAM_SPERAD then	--指定物品消除指定次数
		self.orderMap = config.orderList 		
        
        if self.orderMap then
            for k,v in pairs(self.orderMap) do
                local ts1 = 0
                local ts2 = 0
                local ts3 = 0
                for k2,v2 in pairs(v) do
                    if k2 == "k" then
                        local thestrings = v2:split("_")
                        ts1 = tonumber(thestrings[1])
                        ts2 = tonumber(thestrings[2])
                    end
                    if k2 == "v" then
                        ts3 = tonumber(v2)
                    end
                end

                --果酱的目标是算出来的
                if ts1 == GameItemOrderType.kOthers and ts2 == GameItemOrderType_Others.kJamSperad then
                    ts3 = self.JamSpeardMaxNum - ts3

                    local info = {}
                    info['k']=""..ts1.."_"..ts2
                    info['v']=ts3
  
                    self.orderMap[k] = info
                end
            end
        end
	end

	self.pluginMode = config.pluginMode

	if config.backSideTileMap then
		--printx( 1 , "   LevelConfig:loadConfig    config.backSideTileMap    --- > " , table.tostring(config.backSideTileMap))
        local addInfoCfgBySide = config.addInfoCfg and config.addInfoCfg[2] or nil
		for r = 1, 9 do
            if config.backSideTileMap[r] then
                for c = 1, 9 do
                    local datastr = config.backSideTileMap[r][c]
                    if datastr then
                        local dataArr = string.split(datastr , ";")
                        local tileMapData = dataArr[1]
                        local tileMap2Data = dataArr[2]
                        local specialAnimalMapData = dataArr[3]
                        local crossStrengthCfgData = dataArr[4]
                        local tileAttrsCfgData = dataArr[5]
                        local seaAnimalData = dataArr[6]
                        local seaFlagData = dataArr[7]
                        --printx( 1 , "    RRR   LevelConfig:loadConfig    config.backSideTileMap  datastr = " , datastr)

                        local addInfoData = nil
                        if addInfoCfgBySide and addInfoCfgBySide[r] then
                        	addInfoData = addInfoCfgBySide[r][c]
                        end

                        if not self.backSideTileMap then
                        	self.backSideTileMap = {}
                        end

                        if not self.backSideTileMap[r] then
                        	self.backSideTileMap[r] = {}
                        end
                        local backTileMapData = TileMetaData:buildTileData( r , c , tileMapData , tileMap2Data , crossStrengthCfgData, addInfoData)

                        self.backSideTileMap[r][c] = { 
                        	tileData = backTileMapData ,
                        	animalData = specialAnimalMapData ,
                        }

                        if not self.backSeaAnimalMap then
                        	self.backSeaAnimalMap = {}
                        end

                        --printx( 1 , "   seaAnimalData = " , seaAnimalData)
                        if seaAnimalData and tonumber(seaAnimalData) ~= 0 then
                        	--printx( 1 , "        LevelConfig:loadConfig    config.backSideTileMap    seaAnimalData " , seaAnimalData , r,c)
	                        if not self.backSeaAnimalMap[r] then
	                        	self.backSeaAnimalMap[r] = {}
	                        end
	                        self.backSeaAnimalMap[r][c] = tonumber(seaAnimalData)
                        end

                        local tileDef = self.backSideTileMap[r][c].tileData
						local bottleBlockerColor = getBottleBlockerColor( tileDef )
						if bottleBlockerColor then
							self.backSideTileMap[r][c].animalData = bottleBlockerColor
						end

                        if not self.backSeaFlagMap then
                        	self.backSeaFlagMap = {}
                        end

                        if seaFlagData and tonumber(seaFlagData) ~= 0 then
                        	--printx( 1 , "        LevelConfig:loadConfig    config.backSideTileMap    seaFlagData " , seaFlagData , r,c)
	                        if not self.backSeaFlagMap[r] then
	                        	self.backSeaFlagMap[r] = {}
	                        end
	                        self.backSeaFlagMap[r][c] = tonumber(seaFlagData)
                        end
                        
                    end
                end
            end
        end

        --printx( 1 , "   self.backSeaAnimalMap = " , table.tostring(self.backSeaAnimalMap))
	end
end

function LevelConfig:updateScoreTargets(levelMeta)
	self.scoreTargets = levelMeta:getScoreTargets()
end

function LevelConfig:initSingleDropConfig(singleDrop, dropCrystalStoneTypes)
	local ret = {}
	if dropCrystalStoneTypes and #dropCrystalStoneTypes > 0 then -- 将水晶石也加到统一处理
		ret[TileConst.kCrystalStone] = LevelConfig:getRealColorValues(dropCrystalStoneTypes)
	end

	if singleDrop and table.size(singleDrop) > 0 then
		for itemId, colors in pairs(singleDrop) do
			if colors and #colors > 0 then
				ret[tonumber(itemId)+1] = LevelConfig:getRealColorValues(colors)
			end
		end
	end
	return ret
end

function LevelConfig:getRealColorValues(colors)
	local ret = {}
	if colors and #colors > 0 then
		for _, v in pairs(colors) do
			local c = AnimalTypeConfig.convertIndexToColorType(v)
			if c then table.insert(ret, c) end
		end
	end
	return ret
end

function LevelConfig:isIceOrSnowOrHoneyLevel()
	do return true end
	if self.gameMode == GameModeType.LIGHT_UP then
		return true
	end

	if self.orderMap then
		for i,v in ipairs(self.orderMap) do
			if v.k == GameItemOrderType.kSpecialTarget.."_"..GameItemOrderType_ST.kSnowFlower or
			   v.k == GameItemOrderType.kOthers.."_"..GameItemOrderType_Others.kHoney then
			   return true
			end
		end
	end

	return false
end

function LevelConfig:dispose()
	self.timeLimit = nil
	self.digTileMap = nil
	self.clearTargetLayers = nil
	self.ingredients = nil
	self.numIngredientsOnScreen = nil
	self.ingredientSpawnDensity = nil
	self.everyStepDropNum = nil
end

function LevelConfig:create(id, levelMeta)
	local lc = LevelConfig.new()
	lc:loadConfig(id, levelMeta)
	return lc
end

function LevelConfig:getDropRules()					--获取掉落规则
	local ret = {}
	for k,v in ipairs(self.dropRules) do
		table.insert(ret, v:clone())
	end
	return ret
end

function LevelConfig:getFeatureMap()
	return self.featureMap or {}
end

function LevelConfig:tryToAddFeatureMap( tileId )
	if TileConstName[ tileId ] then
		local tcn = TileConstName[ tileId ]
		self.featureMap[ tcn.name ] = { tileId = tileId , chsName = tcn.chsName}
	end
end

function LevelConfig:forceToAddFeatureMap( tileId , name , chsName , datas )
	self.featureMap[ name ] = { tileId = tileId , chsName = chsName}
end

--关卡依赖的特殊素材诸如毛球、毒液、气球等,不包含普通动物或特效
function LevelConfig:getDependingSpecialAssetsList(levelType , replayMode)
	local resNameMap = {}
	local propertiesMap = {}

	self.featureMap = {}



	local function calculateTileNeedAssets(tileMap)
		for r = 1, #tileMap do
			for c = 1, #tileMap[r] do
				local tile = tileMap[r][c]
				for tileProperty, resList in pairs(DependingAssetsTypeNameMap) do

					local needPrint = false
					-- if tostring(TileConst.kGravitySkin) .. "_1" == tileProperty then
					-- 	printx( 1 , "!!!!!!!!!!!!!!~~~WQDSQSQS  " , r , c , "tileProperty =" , tileProperty)
					-- 	needPrint = true
					-- end

					local tilePropertyArr = string.split( tostring(tileProperty) , "_" )
					tileProperty = tonumber(tilePropertyArr[1])
					local tileAttr = tonumber(tilePropertyArr[2])
					-- if needPrint then printx( 1 , "tileProperty = " , tileProperty , "tileAttr" , tileAttr) end
					local attrMatch = true
					if tileAttr then
						attrMatch = false
						local attr = tile:getAttrOfProperty(tileProperty)
						-- if needPrint then printx( 1 , "tileAttr" , tileAttr , "attr" , attr , tostring(tileAttr) == tostring(attr)) end
						if tostring(tileAttr) == tostring(attr) then
							attrMatch = true
						end
					end
					-- if needPrint then printx( 1 , "attrMatch = " , attrMatch ) end
					if tile:hasProperty(tileProperty) and attrMatch then
						propertiesMap[tileProperty] = true
						for k,v in pairs(resList) do 
							resNameMap[v] = true
						end
					end
				end

				local propertys = tile:getAllPropertys()
				local _k , _v = 0 , 0

				for _k , _v in pairs( propertys ) do
					self:tryToAddFeatureMap( _v )
				end
			end
		end
	end

	calculateTileNeedAssets(self.tileMap)

	local function calculateBackSideTileTileNeedAssets(tileMap)
		for r = 1, 9 do
			if tileMap[r] then
				for c = 1, 9 do
					local tile = tileMap[r][c]
					if tile and tile.tileData then
						for tileProperty, resList in pairs(DependingAssetsTypeNameMap) do
							local tilePropertyArr = string.split( tostring(tileProperty) , "_" )
							tileProperty = tonumber(tilePropertyArr[1])
							local tileAttr = tonumber(tilePropertyArr[2])
							local attrMatch = true
							if tileAttr then
								attrMatch = false
								local attr = tile.tileData:getAttrOfProperty(tileProperty)
								if tostring(tileAttr) == tostring(attr) then
									attrMatch = true
								end
							end
							if tile.tileData:hasProperty(tileProperty) and attrMatch then
								propertiesMap[tileProperty] = true
								for k,v in pairs(resList) do 
									resNameMap[v] = true
								end
							end
						end

						local propertys = tile.tileData:getAllPropertys()
						local _k , _v = 0 , 0

						for _k , _v in pairs( propertys ) do
							self:tryToAddFeatureMap( _v )
						end
					end
				end
			end
		end
	end
	

	if self.backSideTileMap then calculateBackSideTileTileNeedAssets(self.backSideTileMap) end

	----------问号障碍需要素材
	local function calculateUncertainCfgNeedAssets( uncertainCfg )
		-- body
		if not uncertainCfg then return end
		resNameMap["flash/question_mark.plist"] = true
		for k, v in pairs(uncertainCfg.allItemList) do
			for tileProperty, resList in pairs(DependingAssetsTypeNameMap) do 

				local tilePropertyArr = string.split( tostring(tileProperty) , "_" )
				tileProperty = tonumber(tilePropertyArr[1])

				if tileProperty == v.changeItem + 1 then 
					for k1, v1 in pairs(resList) do
						resNameMap[v1] = true
					end
					propertiesMap[tileProperty] = true
				end
			end

			self:tryToAddFeatureMap( v.changeItem + 1 )
		end
	end
	calculateUncertainCfgNeedAssets(self.uncertainCfg1)
	calculateUncertainCfgNeedAssets(self.uncertainCfg2)


    ----------万生素材
    local function AddAssetsByWanShengConfig( config )
        for i,v in pairs(config) do
            local ItemId = v.mType + 1
            local resList = DependingAssetsTypeNameMap[ItemId]

            if resList then
                for k,v in pairs(resList) do 
			        resNameMap[v] = true
		        end
            end
            propertiesMap[ItemId] = true
            self:tryToAddFeatureMap( ItemId )
        end
    end

    local function AddAssetsByWanShengDefaultConfig( config )
        if not config.mType or not config.num then return end
        if config.mType == 0 and config.num == 0 then return end

        local ItemId = config.mType + 1
        local resList = DependingAssetsTypeNameMap[ItemId]

        if resList then
            for k,v in pairs(resList) do
			    resNameMap[v] = true
		    end
        end
        propertiesMap[ItemId] = true
        self:tryToAddFeatureMap( ItemId )
    end

    if self.wanShengConfig then AddAssetsByWanShengConfig(self.wanShengConfig) end
    if self.wanShengDropConfig then AddAssetsByWanShengConfig(self.wanShengDropConfig) end
    if self.wanShengNormalConfig then AddAssetsByWanShengDefaultConfig(self.wanShengNormalConfig) end

	----------掉落素材
	local function addAssetsByDropRules( dropRules , isNewVer )
		for k,v in pairs( dropRules ) do
			local rule = v
			if isNewVer then
				rule = v.dropRuleVO
			end
			-- printx( 1 , "1111111111111111111" , rule.itemID)
			local itemId = ResUtils:getDropRuleItemId(rule.itemID) + 1
			if DependingAssetsTypeNameMap[itemId] then
				for _, res in pairs(DependingAssetsTypeNameMap[itemId]) do 
					resNameMap[res] = true
				end
				propertiesMap[itemId] = true
			end

			self:tryToAddFeatureMap( itemId )
		end
	end

	if self.productRuleGroup and #self.productRuleGroup > 0 then
		for k,v in ipairs(self.productRuleGroup) do
			-- printx( 1 , "2222222222222222 " , table.tostring(v)  )
			addAssetsByDropRules( v , true )
		end
	else
		addAssetsByDropRules( self.dropRules )
	end
	

	--传送带
	if self.trans then
		resNameMap["flash/transmission.plist"] = true
		propertiesMap[TileConst.kTransmission] = true
		self:tryToAddFeatureMap( TileConst.kTransmission )
	end

	if self.sunflowersAppetite and self.sunflowersAppetite > 0 then
		gAnimatedObject:loadRes('gaf/sunflowerBlocker/sunflowerBlast.gaf')
	end

	--ufo素材
	if self.hasDropDownUFO then
		-- debug.debug() 
		resNameMap["flash/ufo_rocket.plist"] = true
		propertiesMap[TileConst.kRocket] = true
		self:forceToAddFeatureMap( -10000 , "ufo" , "飞碟" )
		-- resNameMap["flash/UFO.plist"] = true
	end

	--挖地关卡需要加载挖地云块素材，并且需要遍历digTileMap中的item类型信息
	if self.pm25 > 0 then
		resNameMap["flash/dig_block.plist"] = true
	end

	if self.gameMode == GameModeType.DIG_MOVE or self.gameMode == GameModeType.DIG_TIME then
		calculateTileNeedAssets(self.digTileMap)
	elseif self.gameMode == GameModeType.DIG_MOVE_ENDLESS or self.gameMode == GameModeType.MAYDAY_ENDLESS
	or self.gameMode == GameModeType.HALLOWEEN 
	or self.gameMode == GameModeType.HEDGEHOG_DIG_ENDLESS
	or self.gameMode == GameModeType.WUKONG_DIG_ENDLESS
	or self.gameMode == GameModeType.OLYMPIC_HORIZONTAL_ENDLESS
	or self.gameMode == GameModeType.SPRING_HORIZONTAL_ENDLESS
	or self.gameMode == GameModeType.MOLE_WEEKLY_RACE
	then
	 	if self.gameMode == GameModeType.HALLOWEEN  then
	 		-- resNameMap["flash/xmas_boss.plist"] = true
	 		-- resNameMap["flash/dragonboat_boss1.plist"] = true
	 		-- resNameMap["flash/dragonboat_boss2.plist"] = true
	 		-- resNameMap["flash/dragonboat_boss3.plist"] = true
	 		-- resNameMap["flash/qixi_boss.plist"] = true
			
			resNameMap["flash/add_five_step_ani.plist"] = true
			resNameMap["flash/dig_block.plist"] = true
			-- resNameMap["flash/halloween_2015.plist"] = true
			-- resNameMap["flash/boss_pumpkin.plist"] = true
			-- resNameMap["flash/boss_pumpkin_die.plist"] = true
			-- resNameMap["flash/boss_pumpkin_ghost_1.plist"] = true
			-- resNameMap["flash/boss_pumpkin_ghost_2.plist"] = true
			resNameMap["flash/ball_brown.plist"] = true
			resNameMap["flash/ball_grey.plist"] = true
			resNameMap["flash/venom.plist"] = true
			resNameMap["flash/mapLock.plist"] = true
			resNameMap["flash/coin.plist"] = true
			resNameMap["flash/venom.plist"] = true
			resNameMap["flash/PoisonBottle.plist"] = true
	 	end

	 	if self.gameMode == GameModeType.MOLE_WEEKLY_RACE then
	 		resNameMap["flash/add_five_step_ani.plist"] = true
			resNameMap["flash/dig_block.plist"] = true
			resNameMap["flash/ball_brown.plist"] = true
			resNameMap["flash/ball_grey.plist"] = true
			resNameMap["flash/venom.plist"] = true
			resNameMap["flash/mapLock.plist"] = true
			resNameMap["flash/coin.plist"] = true
			resNameMap["flash/venom.plist"] = true
			resNameMap["flash/PoisonBottle.plist"] = true
			resNameMap["flash/balloon.plist"] = true
			
			resNameMap["flash/mole_weeklyRace_seed.plist"] = true
			resNameMap["flash/mole_weeklyRace_otherSkill.plist"] = true
			resNameMap["flash/honey_bottle.plist"] = true
			resNameMap["flash/mole_weeklyRace_magicTile.plist"] = true

            resNameMap["flash/week_gress.plist"] = true
            resNameMap["flash/week_gress4.plist"] = true

            resNameMap["materials/MoleWeekly.plist"] = true


            --boss 资源的加载
			local groupID = MoleWeeklyRaceConfig:getRealCurrGroupID()

            function GetBossLevel( GroupID )
                local level = 1
                if GroupID >=1 and GroupID <=3 then
                    level = 1
                elseif GroupID >=4 and GroupID <=6 then
                    level = 2
                elseif GroupID >=7 and GroupID <=9 then
                    level = 3
                else
                    level = 4
                end

                return level
            end

            local level = GetBossLevel( groupID )

            gAnimatedObject:loadRes("gaf/MoleWeekly_Boss/boss"..level.."/boss"..level..".gaf")

            --+5步爆炸资源
            gAnimatedObject:loadRes('gaf/weekly_2018s1/bomb_add_step/bomb_add_step.gaf')
            --
	 	end

	 	if self.gameMode == GameModeType.MAYDAY_ENDLESS then
	 		
	 		resNameMap["flash/boss_mayday.plist"] = true
	 		resNameMap["flash/question_mark.plist"] = true
	 		-- resNameMap["flash/weekly/ingame_res.plist"] = true
	 		-- resNameMap["flash/animation/spring_festival.plist"] = true
	 		--resNameMap["flash/animation/boss_cat_item.plist"] = true
	 		--resNameMap["flash/animation/boss_cat_item_use.plist"] = true
	 	end

	 	if self.gameMode == GameModeType.HEDGEHOG_DIG_ENDLESS then
	 		resNameMap["flash/hedgehog_road.plist"] = true
	 		--FrameLoader:loadArmature("skeleton/hedgehog_V3_animation")
			resNameMap["flash/ball_brown.plist"] = true
			resNameMap["flash/ball_grey.plist"] = true
			resNameMap["flash/venom.plist"] = true
			resNameMap["flash/mapLock.plist"] = true
			resNameMap["flash/coin.plist"] = true
			resNameMap["flash/venom.plist"] = true
			resNameMap["flash/PoisonBottle.plist"] = true
	 	end
	 	if self.gameMode == GameModeType.OLYMPIC_HORIZONTAL_ENDLESS then
			resNameMap["flash/mapLight.plist"] = nil
			--resNameMap["flash/mapSnow.plist"] = nil
			-- resNameMap["flash/olympic/olympic_ingame_animations.plist"] = true

			resNameMap["flash/autumn2018/mid_autumn_bg.plist"] = true
			resNameMap["flash/autumn2018/mid_autumn_ani_res.plist"] = true
	 	end
	 	if self.gameMode == GameModeType.SPRING_HORIZONTAL_ENDLESS then
	 		resNameMap["flash/nationday2017/board_view_effects.plist"] = true
	 		-- resNameMap["flash/spring2017/spring_explore_effect.plist"] = true
			resNameMap["flash/nationday2017/olympic_resource.plist"] = true
	 		resNameMap["flash/nationday2017/nationday2017_game_bg.plist"] = true
	 	end
		resNameMap["flash/add_move.plist"] = true
		calculateTileNeedAssets(self.digTileMap)
	elseif self.gameMode == GameModeType.RABBIT_WEEKLY then
		-- TODO
		resNameMap["flash/ufo_rocket.plist"] = true
	elseif self.gameMode == GameModeType.SEA_ORDER then
		resNameMap["flash/sea_animal.plist"] = true

        if LevelType:isSummerFishLevel(self.level) then
            resNameMap["materials/SummerFish.plist"] = true
        end

		self:forceToAddFeatureMap( -10001 , "arcticAnimal" , "海洋生物" )
	elseif self.gameMode == GameModeType.DROP_DOWN then
		self:tryToAddFeatureMap(TileConst.kFudge)
    elseif self.gameMode == GameModeType.JAM_SPERAD then
        resNameMap["flash/JamSperad.plist"] = true
	end

	if levelType == GameLevelType.kSpring2018 then
		resNameMap["flash/spring2018/ingame.plist"] = true
	end

	if self:isIceOrSnowOrHoneyLevel() then
		resNameMap["flash/animation/targetTips.plist"] = true
	end

    local isActivitySupport = DragonBuffManager:getInstance():isActivitySupport()
    if isActivitySupport then
        FrameLoader:loadArmature('skeleton/dragonbuff')
    end

    local isActivitySupport = SpringFestival2019Manager.getInstance():getCurIsActSkill()
    if isActivitySupport then
        resNameMap["flash/SpringFestival_2019/SpringFestivalRes_2019.plist"] = true
    end

    local isActRecallA2019 = RecallA2019Manager.getInstance():getActMission()
    if isActRecallA2019 then
        resNameMap["tempFunctionRes/RecallA2019/RecallA2019_MissionIcon.plist"] = true
    end

    local isActTurnTable2019 = TurnTable2019Manager.getInstance():isActivitySupport( self.level )
    if isActTurnTable2019 then
        resNameMap["tempFunctionRes/TurnTable2019/TurnTable2019_MissionIcon.plist"] = true
    end

    local result = {}

	if GameInitBuffLogic:hasAnyInitBuffIncludedReplay() then

		FrameLoader:loadArmature(PreBuffLogic:getInitFlyAnimSkeletonSourceName())
 		PreBuffLogic:logSkeletonLoadOrRemove( "load" )

		if GameInitBuffLogic:needLoadBuffBoomRes() then

			resNameMap["flash/buff_boom_res.plist"] = true
			FrameLoader:loadArmature("skeleton/BuffBoomAnimation")
			
			result.removeArmatureRes = function () 
				FrameLoader:unloadArmature("skeleton/BuffBoomAnimation", true)
				
				if not PreBuffLogic:getUpgradeAnimationPlaying() then
					FrameLoader:unloadArmature(PreBuffLogic:getInitFlyAnimSkeletonSourceName(), true)
					PreBuffLogic:logSkeletonLoadOrRemove( "remove" )
				end
			end
		else
			result.removeArmatureRes = function () 

				if not PreBuffLogic:getUpgradeAnimationPlaying() then
					FrameLoader:unloadArmature(PreBuffLogic:getInitFlyAnimSkeletonSourceName(), true)
					PreBuffLogic:logSkeletonLoadOrRemove( "remove" )
				end
			end
		end

		if GameInitBuffLogic:needLoadFirecrackerRes() then
			resNameMap["flash/firecrackerBlocker.plist"] = true
		end
	end

	if ScoreBuffBottleLogic:hasScoreBuffForAsset(self.level) then 
		resNameMap["flash/scoreBuffBottle.plist"] = true
		gAnimatedObject:loadRes('gaf/scoreBuffBottle/ScoreBuffBottle_throw.gaf')
	end

	-- FOR TEST
	resNameMap["flash/tile_high_lights.plist"] = true

	--[[if LevelType:isYuanxiao2017Level(self.level) then
		if resNameMap["flash/coin.plist"] ~= nil then
			resNameMap["activity/DragonBoat2017/res/lantern.plist"] = true
			resNameMap["flash/coin.plist"] = nil
		end
	end]]--

	
	-- printx( 1 , "LevelConfig:getDependingSpecialAssetsList ------------------------ self.featureMap =" , table.tostring(self.featureMap))

	for resName, v in pairs(resNameMap) do
		table.insert(result, resName)
	end

	return result , self.featureMap
end

-----------------------------------------------------------------------------
-- sharedLevelData
-----------------------------------------------------------------------------

LevelDataManager = class()

function LevelDataManager:ctor()	
	self.levelDatas = {}
end

function LevelDataManager:getAllLevels()
    return table.keys(self.levelDatas)
end

-- 获取解析过后的关卡配置 LevelConfig
function LevelDataManager:getLevelConfigByID( id , alwaysCreateNewInstance )
	
	if alwaysCreateNewInstance then
		local levelMeta = LevelMapManager.getInstance():getMeta(id)
		return LevelConfig:create(id, levelMeta)
	end

	if not self.levelDatas[id] then
		local levelMeta = LevelMapManager.getInstance():getMeta(id)
		if not levelMeta then
			return nil
		end
		self.levelDatas[id] = LevelConfig:create(id, levelMeta)
	end

	assert(self.levelDatas[id])
	return self.levelDatas[id]
end

function LevelDataManager:clearLevelConfigById(levelId)
	self.levelDatas[levelId] = nil
end

-- function LevelDataManager:getMainLevelTotalStar()
-- 	if self.mainLevelTotalStar == nil then
-- 		local starSum = 0
-- 		local maxId = MetaManager.getInstance():getMaxNormalLevelByLevelArea()
-- 		local minId = 1
-- 		for levelId = minId, maxId do
-- 			starSum = starSum + #(LevelMapManager.getInstance():getMeta(levelId):getScoreTargets())
-- 		end
-- 		self.mainLevelTotalStar = starSum
-- 	end
-- 	return self.mainLevelTotalStar
-- end

-- function LevelDataManager:getHiddenLevelTotalStar()
-- 	if self.hiddenLevelTotalStar == nil then
-- 		local starSum = 0
-- 		local levelIdGroup = MetaManager.getInstance():getHideAreaLevelIds()
-- 		table.each(
-- 			levelIdGroup,
-- 			function (levelId)
-- 				if levelId then
-- 					local levelData = LevelMapManager.getInstance():getMeta(levelId)
-- 					if levelData and levelData:getScoreTargets() then
-- 						starSum = starSum + #(levelData:getScoreTargets())
-- 					end
-- 				end
-- 			end
-- 		)
-- 		self.hiddenLevelTotalStar = starSum
-- 	end
-- 	return self.hiddenLevelTotalStar
-- end

function LevelDataManager:getMoveLimitOfLevels()
	local topLevel = MetaManager:getInstance():getMaxNormalLevelByLevelArea()
	local str = ""
	for i=1, topLevel do
		local levelConfig = LevelDataManager.sharedLevelData():getLevelConfigByID(i)
		str = str .. levelConfig.moveLimit .. "\n"
	end

	local filePath = HeResPathUtils:getUserDataPath() .. "/level_move_limit.txt"
    local file = io.open(filePath, "w")
    
    if not file then 
    	return 
    end

	local success = file:write(str)
   
    if success then
        file:flush()
        file:close()
    else
        file:close()
        self:catchException("open "..kResultFileName.." failed when flush called 2")
    end
end

local ldm__ = nil

function LevelDataManager.sharedLevelData()
	if not ldm__ then
		ldm__ = LevelDataManager.new()
	end
	return ldm__
end
