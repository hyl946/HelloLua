--[[
local encryptKeyMap = {
	ItemColorType = true,
}
]]

local ENABLE_CHECKING = isLocalDevelopMode and false

local function encrypt_class()
	local class_type = {}
	class_type.tv = {}
	class_type.new = function(...)
		local obj = {}
		local _t = {}

		setmetatable(obj, { 
			__index = function(table, key)
				return _t[key]
			end	,

        	__newindex = function(table, key, value)
				local v = AnimalTypeConfig.generateColorType(value)
        		-- rawset(table, key, v)
        		_t[key] = v
			end	
        })

		if obj.ctor then obj:ctor(...) end
		return obj
	end
	return class_type
end

local encryptClass = encrypt_class()

local function simple_class()
	local class_type = {}
	class_type.__index = class_type

	class_type.new = function(...)
		local obj = {}
		obj._encrypt = encryptClass.new()

		if ENABLE_CHECKING then
			setmetatable(obj, { 
				__index = function(table, key)
					assert(key ~= "ItemColorType")
					return class_type[key]
				end,
        		__newindex = function(table, key, value)
					assert(key ~= "ItemColorType")
        			rawset(table, key, value)
				end	
			})
		else
			setmetatable(obj, class_type)
		end

		if obj.ctor then obj:ctor(...) end
		return obj
	end
	return class_type
end


require "zoo.config.TileMetaData"
require "zoo.config.TileConfig"

require "zoo.gamePlay.GamePlayConfig"
require "zoo.gamePlay.config.SeasonWeeklyBossConfig"
require "zoo.animation.TileBottleBlocker"

GameItemData = simple_class()

-- 道具云块的种类
RandomPropType = table.const
{
	kRandomProp1 = 45,
	kRandomProp2 = 46,
	kRandomProp3 = 47,
	kRandomProp4 = 48,
}

GameItemFurballType = table.const
{
	kNone = 0,
	kGrey = 1,				--灰色毛球
	kBrown = 2,				--褐色毛球
}

GameItemCrystalStoneBombType = table.const
{
	kNone = 0,
	kNormal = 1,
	kSpecial = 2, -- 染色宝宝和魔力鸟爆炸特效
}

GameItemRabbitState = table.const
{
	kNone = 0,            --无
	kSpawn = 1,           --刚生成
	kNoTarget = 2,        --消除不加目标
	kSuper = 3,
}

GameItemTotemsState = table.const {
	kNone = 0,
	kWattingActive = 1,
	kActive = 2,
	kWattingBomb = 3,
	kBomb = 4,
}

IngredientShowType = table.const
{
	kIngredient = 0,  --金豆荚
	kAcorn      = 1,  --橡果
}

local sKey = 0
local function KeyGenerate( ... )
	sKey = sKey + 1
	return sKey
end


function GameItemData:ctor()
	------------------------
	----添加属性请修改 ------copy()函数
	------------------------
	self.isLockColorOnInit = false 	--初始化时是否锁定自己的颜色（不参与初始化随即色）
	self.isUsed = true 				--是否可用,地形上有没有这个格子
	self.ItemType = 0				--Item的类型
	self.showType = 0               --item的显示类型，同样的种类有可能显示不同，比如金豆荚和橡果
	self.ItemStatus = 0				--状态
	self._encrypt.ItemColorType = 0			--Item的颜色类型		--0为随机
	self.ItemSpecialType = 0		--Item特殊类型
	self.furballLevel = 0			--毛球等级
	self.furballType = 0
	self.isBrownFurballUnstable = false --褐色毛球不稳定状态(颤抖)
	self.ItemCheckColorType = nil
	
	self.isBlock = false			--是block
	self.snowLevel = 0				--雪花层数
	self.cageLevel = 0				--牢笼的层数
	self.venomLevel = 0				--毒液等级
	self.roostLevel = 0				--鸡窝等级
	self.roostCastCount = 0         --鸡窝放招次数上限（单回合）
	self.digGroundLevel = 0			--无宝石云块的等级
	self.digJewelLevel = 0			--有宝石云块的等级
	self.honeyLevel = 0				--蜂蜜等级
	self.crystalStoneEnergy = 0 	--染色宝宝收集的颜色数量
	self.crystalStoneActive = false 	--染色宝宝是否处于激活状态
	self.crystalStoneBombType = GameItemCrystalStoneBombType.kNone

	self.x = 0
	self.y = 0
	self.w = GamePlayConfig_Tile_Width
	self.h = GamePlayConfig_Tile_Height

	self.isNeedUpdate = false
	self.isEmpty = true
	self.isItemLock = false				--Item被锁定，引爆的特效，在覆盖别人之后，再覆盖回来不会被再次引爆

	self.gotoPos = nil					--正在前往某个位置
	self.comePos = nil					--正在从某个位置引来一个物体
	self.itemSpeed = 0
	self.itemPosAdd = IntCoord:create(0, 0)
	self.ClippingPosAdd = IntCoord:create(0, 0)
	self.EnterClippingPosAdd = IntCoord:create(0, 0)
	self.dataReach = true				--数据到达（+不是Falling）才能参加Match消除计算--数据到达才能参加特效Cover计算
	self.bombRes = nil					--爆炸来源
	self.isProduct = false  			--正在生产----不参与鸟的爆炸
	self.lightUpBombMatchPosList = nil	--消除冰块时，对于特效禽兽，将引爆该特效的match信息存入这个数组
	self.hasGivenScore = false
	self.balloonFrom = 0
	self.balloonConstantPlayAlert = false 	--显示用，气球播放突出表现动画
	self.isFromProductBalloon = false  	--标志位 用来防止新生成的气球步数减一
	self.numAddMove = 0
	self.digBlockCanbeDelete = true    	--item是否可以被消除,false = 被保护，用户地块，宝石，蜂蜜
	self.isReverseSide = false
	self.reverseCount = 3

	self.bigMonsterFrostingType = 0    
	self.bigMonsterFrostingStrength = 0

	self.chestSquarePartType = 0
	self.chestSquarePartStrength = 0

	self.blackCuteMaxStrength = 0		--黑色球最大血量，用于区分黑毛球的类型
	self.blackCuteStrength = 0			--黑色毛球血量
	self.lastInjuredStep = 0

	self.mimosaDirection = 0 			--0=no direction 1 = left 2 = right 3 = up 4 = down
	self.mimosaLevel = 0 
	self.mimosaHoldGrid = {}
	self.beEffectByMimosa = 0

	self.snailRoadType = nil
	self.isSnail = false

	self.hedgehogLevel = 0			 	--刺猬

	self.bossLevel = 0
	self.weeklyBossLevel = 0 			--周赛第二种boss
	self.bossHp = nil
	self.rabbitState = 0
	self.rabbitLevel = 0

	self.forbiddenLevel = 0

	self.lampLevel = 0
	self.honeyBottleLevel = 0
	self.addTime = 0

	self.isProductByBossDie = false
	self.questionMarkProduct = 0

	self.magicStoneDir = 0
	self.magicStoneLevel = 0
	self.magicStoneActiveTimes = 0
	self.magicStoneLocked = false

	self.bottleLevel = 0
	self.bottleState = BottleBlockerState.Waiting
	self.bottleActionRunningCount = 0

	self.wukongProgressCurr = 0
	self.wukongProgressTotal = getBaseWukongChargingTotalValue()
	self.wukongIsReadyToJump = false
	self.wukongState = TileWukongState.kNormal
	self.wukongJumpPos = IntCoord:create(0, 0)
	self.totemsState = GameItemTotemsState.kNone
	self.lotusLevel = 0	--荷塘等级，对应1-3级（大概）

	self.beEffectBySuperCute = false
	self.dripState = 0
	self.dripLeaderPos = IntCoord:create(0, 0)

	self.pufferState = 0
	self.dropProps = nil

	self.olympicBlockerLevel = 0
	self.olympicLockLevel = 0

	self.missileLevel = 0

	self.randomPropType = 0   -- 道具云块标记
	self.randomPropDropId = 0 -- 道具云块掉落的道具id
	self.randomPropLevel = 0 -- 道具云块等级，目前只有1级
	self.hitBySpringBomb = false -- 是否被关卡大招打中

	-- 关联回滚前后礼盒的位置
	self.key = 0

	self.tangChickenNum = 0
	self.blockerCoverLevel = 0--小叶堆等级
	self.subtype = 0--通用，子类型(195的收集key，199的方向)
	self.level = 0--通用，等级/计数器（195的收集数量，199的层数）
	self.isActive = false--通用，是否激活
	self.flag = false --通用，用来标记，一般都是动画需要

	self.colorFilterBLock = false
	self.hasActCollection = false 	--是否有活动的收集物

	self.nextColour = nil		--变色龙用，即将变为的颜色
	self.nextSpecial = nil		--变色龙用，即将变为的SpecialType
	self.originColourAndSpecial = nil 	--"colour,special" 合成前的颜色和special，如，得知魔力鸟由哪色合成，是不是刚刚新合成的特效等（变色龙用）

	self.lockLevel = 0 --配对锁的分组
	self.lockHead = false --配对锁是否显示锁头
	self.needKeys = 0 --配对锁的锁头数字
	self.lockBoxRopeRight = false --是否显示配对锁的绳子
	self.lockBoxRopeLeft = false --是否显示配对锁的绳子
	self.lockBoxRopeDown = false --是否显示配对锁的绳子
	self.lockBoxRopeUp = false --是否显示配对锁的绳子
	self.lockBoxActive = false --配对锁是否为激活状态

	self.pacmanColour = 1		--吃豆人目标颜色（索引值）
	self.pacmanDevourAmount = 0	--吃豆人，已经吃了多少
	self.pacmanIsSuper = nil	--吃豆人是否吃过特效。nil，没有。0，吃过，动画先不更新。1，吃过，动画更新完毕。2，吃过，更新动画正当时。
	self.pacmansDenPos = nil	--（即将生成的）吃豆人是从哪个窝里出来的

    self.turretDir = 0
	self.turretIsTypeRandom = false		-- false：普通炮塔  true：随机炮塔
	self.turretLevel = 0				-- 等级
	self.turretIsSuper = false 			-- 是否被特效激活
	self.turretLocked = false 			-- 本回合是否已经发射过了
    self.updateType = 0 			    --0为normal 1为击打中 2为击打完成

	self.moleBossSeedHP = 0				--鼹鼠周赛，种子的强度（击打几下会破裂）
	self.moleBossSeedCountDown = 0			--鼹鼠周赛，种子的寿命（还有几回合会消失）
	self.moleBossCloudLevel = 0		--周赛boss大招释放的大云块的等级

    self.yellowDiamondLevel = 0			--黄宝石草地的等级
    self.yellowDiamondCanbeDelete = true

    self.coveredByGhost = false 		-- 被幽灵挡着
    self.ghostPaceLength = 0			-- 幽灵能前进多少步
    self.tempGhostPace = 0				-- 因幽灵而产生的移动步数（被推走的为正数（下降），被覆盖的为负数（上升））

    self.blocker199Colors = nil 		--水母宝宝可变颜色
    self.blocker199Dirs = nil 			--水母宝宝旋转方向

    self.blocker83Colors = nil 			--大眼仔可变颜色

    self.isToBlastScoreBuffBottles = false 		--即将爆破的刷星瓶
    self.sunFlaskLevel = 0				-- 向日葵等级
    self.isToBlastFirecracker = false 	--即将爆炸的爆竹

    self.squidDirection = 0				--鱿鱼方向
    self.squidTargetType = 0			--鱿鱼收集物类型
    self.squidTargetNeeded = -1			--鱿鱼收集物总数
    self.squidTargetCount = 0			--鱿鱼收集物收集数
    self.needRemoveEventuallyBySquid = false	--由于鱿鱼的效果，最终需要被移除

    self.wanShengLevel = 0          --万生等级
    self.wanShengConfig = nil        --万生配置

end

function GameItemData:dispose()
end

function GameItemData:create()
	local v = GameItemData.new()
	return v
end

function GameItemData:resetDatas(mode)
	if not mode then mode = gCopyDataMode.kNormal end

	self.isUsed = false 				--是否可用,地形上有没有这个格子
	self.ItemType = 0				--Item的类型
	self.showType = 0               --item的显示类型，同样的种类有可能显示不同，比如金豆荚和橡果
	self.ItemStatus = 0				--状态
	self._encrypt.ItemColorType = 0			--Item的颜色类型		--0为随机
	self.ItemSpecialType = 0		--Item特殊类型
	self.furballLevel = 0			--毛球等级
	self.furballType = 0
	self.isBrownFurballUnstable = false --褐色毛球不稳定状态(颤抖)
	self.ItemCheckColorType = nil   -- 解决变色逻辑和掉落同一帧执行导致视图不能刷新的问题
	
	self.isBlock = false			--是block
	self.snowLevel = 0				--雪花层数
	self.cageLevel = 0				--牢笼的层数
	self.venomLevel = 0				--毒液等级
	self.roostLevel = 0				--鸡窝等级
	self.roostCastCount = 0         --鸡窝放招上限
	self.digGroundLevel = 0
	self.digJewelLevel = 0
	self.honeyLevel = 0				--蜂蜜等级
	self.crystalStoneEnergy = 0
	self.crystalStoneActive = false
	self.crystalStoneBombType = GameItemCrystalStoneBombType.kNone

	self.isNeedUpdate = false
	self.isEmpty = true
	self.isItemLock = false				--Item被锁定，引爆的特效，在覆盖别人之后，再覆盖回来不会被再次引爆

	self.gotoPos = nil					--正在前往某个位置
	self.comePos = nil					--正在从某个位置引来一个物体
	self.itemSpeed = 0
	self.itemPosAdd = IntCoord:create(0, 0)
	self.ClippingPosAdd = IntCoord:create(0, 0)
	self.EnterClippingPosAdd = IntCoord:create(0, 0)
	self.dataReach = true				--数据到达（+不是Falling）才能参加Match消除计算--数据到达才能参加特效Cover计算
	self.bombRes = nil					--爆炸来源
	self.isProduct = false  			--正在生产----不参与鸟的爆炸
	self.lightUpBombMatchPosList = nil	--消除冰块时，对于特效禽兽，将引爆该特效的match信息存入这个数组
	self.hasGivenScore = false
	self.balloonFrom = 0
	self.balloonConstantPlayAlert = false
	self.isFromProductBalloon = false  	--标志位 用来防止新生成的气球步数减一
	self.numAddMove = 0
	self.digBlockCanbeDelete = true    	--地块，宝石块是否可以被消除
	self.isReverseSide = false
	self.reverseCount = 3

	self.bigMonsterFrostingType = 0    
	self.bigMonsterFrostingStrength = 0

	self.chestSquarePartType = 0
	self.chestSquarePartStrength = 0

	self.blackCuteMaxStrength = 0
	self.blackCuteStrength = 0			--黑色毛球血量
	self.lastInjuredStep = 0

	self.mimosaDirection = 0 			--0=no direction 1 = left 2 = right 3 = up 4 = down
	self.mimosaLevel = 0 
	self.mimosaHoldGrid = {}
	self.beEffectByMimosa = 0

	self.snailRoadType = nil
	self.isSnail = false

	self.hedgehogLevel = 0

	self.bossLevel = 0
	self.weeklyBossLevel = 0
	self.bossHp = nil
	self.rabbitState = 0
	self.rabbitLevel = 0

	self.forbiddenLevel = 0

	self.lampLevel = 0
	self.honeyBottleLevel = 0
	self.addTime = 0

	self.isProductByBossDie = false
	self.questionMarkProduct = 0

	self.magicStoneDir = 0
	self.magicStoneLevel = 0
	self.magicStoneActiveTimes = 0
	self.magicStoneLocked = false

	self.bottleLevel = 0
	self.bottleState = BottleBlockerState.Waiting
	self.bottleActionRunningCount = 0

	self.wukongProgressCurr = 0
	self.wukongProgressTotal = getBaseWukongChargingTotalValue()
	self.wukongIsReadyToJump = false
	self.wukongState = TileWukongState.kNormal
	self.wukongJumpPos = IntCoord:create(0, 0)
	self.totemsState = GameItemTotemsState.kNone
	self.lotusLevel = 0

	self.beEffectBySuperCute = false
	self.dripState = 0
	self.dripLeaderPos = IntCoord:create(0, 0)

	self.pufferState = 0
	self.dropProps = nil

	self.olympicBlockerLevel = 0
	self.olympicLockLevel = 0

	self.missileLevel = 0
	self.randomPropType = 0
	self.randomPropDropId = 0
	self.randomPropLevel = 0
	self.hitBySpringBomb = 0
	self.key = 0
	self.blockerCoverLevel = 0--小叶堆等级
	self.subtype = 0
	self.level = 0
	self.isActive = false
	self.flag = false

	if mode == gCopyDataMode.kNormal then
		self.snailRoadType = nil
	elseif mode == gCopyDataMode.kDoubleSideBlockerTurn then
		self.snailTarget = nil
	end

	self.tangChickenNum = 0

	self.colorFilterBLock = false
	self.hasActCollection = false
	self.nextColour = nil
	self.nextSpecial = nil
	self.lockLevel = 0
	self.lockHead = false
	self.needKeys = 0 --配对锁的锁头数字
	self.lockBoxRopeRight = false --是否显示配对锁的绳子
	self.lockBoxRopeLeft = false --是否显示配对锁的绳子
	self.lockBoxRopeDown = false --是否显示配对锁的绳子
	self.lockBoxRopeUp = false --是否显示配对锁的绳子
	self.lockBoxActive = false --配对锁是否为激活状态

	self.pacmanColour = 1
	self.pacmanDevourAmount = 0
	self.pacmanIsSuper = nil
	self.pacmansDenPos = nil

    self.turretDir = 0
	self.turretIsTypeRandom = false
	self.turretLevel = 0
	self.turretIsSuper = false
	self.turretLocked = false

	self.moleBossSeedHP = 0
	self.moleBossSeedCountDown = 0
	self.moleBossCloudLevel = 0

    self.yellowDiamondLevel = 0
    self.yellowDiamondCanbeDelete = true

    self.coveredByGhost = false
    self.ghostPaceLength = 0
    self.tempGhostPace = 0

    self.blocker199Colors = nil
    self.blocker199Dirs = nil

    self.blocker83Colors = nil

    self.isToBlastScoreBuffBottles = false
    self.sunFlaskLevel = 0
    self.isToBlastFirecracker = false

    self.squidDirection = 0
    self.squidTargetType = 0
    self.squidTargetNeeded = -1
    self.squidTargetCount = 0
    self.needRemoveEventuallyBySquid = false

    self.wanShengLevel = 0
    self.wanShengConfig = nil   
end

function GameItemData.copyDatasFrom(toData, fromData , mode )
	if type(fromData) ~= "table" then return end
	if not mode then mode = gCopyDataMode.kNormal end

	toData.isUsed 		= fromData.isUsed
	toData.ItemType 		= fromData.ItemType
	toData.ItemStatus 	= fromData.ItemStatus
	toData._encrypt.ItemColorType = fromData._encrypt.ItemColorType	
	toData.ItemSpecialType = fromData.ItemSpecialType
	toData.furballLevel 	= fromData.furballLevel
	toData.furballType   = fromData.furballType
	toData.isBrownFurballUnstable = fromData.isBrownFurballUnstable
	toData.ItemCheckColorType = fromData.ItemCheckColorType
	
	toData.isBlock 		 = fromData.isBlock
	toData.snowLevel 	 = fromData.snowLevel
	toData.cageLevel 	 = fromData.cageLevel
	toData.venomLevel 	 = fromData.venomLevel
	toData.roostLevel 	 = fromData.roostLevel
	toData.roostCastCount 	 = fromData.roostCastCount
	toData.digGroundLevel = fromData.digGroundLevel
	toData.digJewelLevel  = fromData.digJewelLevel
	toData.balloonFrom    = fromData.balloonFrom
	toData.balloonConstantPlayAlert = fromData.balloonConstantPlayAlert
	toData.isFromProductBalloon = fromData.isFromProductBalloon
	toData.numAddMove	 = fromData.numAddMove
	toData.isReverseSide  = fromData.isReverseSide
	toData.reverseCount   = fromData.reverseCount

	toData.isNeedUpdate = fromData.isNeedUpdate
	toData.isEmpty = fromData.isEmpty
	toData.isItemLock = fromData.isItemLock

	toData.gotoPos = fromData.gotoPos
	toData.comePos = fromData.comePos
	toData.itemSpeed = fromData.itemSpeed
	toData.itemPosAdd = IntCoord:clone(fromData.itemPosAdd)
	toData.ClippingPosAdd = fromData.ClippingPosAdd
	toData.dataReach = fromData.dataReach
	toData.bombRes = fromData.bombRes
	toData.isProduct = fromData.isProduct
	toData.lightUpBombMatchPosList = fromData.lightUpBombMatchPosList
	toData.hasGivenScore =  fromData.hasGivenScore
	toData.digBlockCanbeDelete = fromData.digBlockCanbeDelete
	toData.bigMonsterFrostingType = fromData.bigMonsterFrostingType
	toData.bigMonsterFrostingStrength = fromData.bigMonsterFrostingStrength
	toData.chestSquarePartType = fromData.chestSquarePartType
	toData.chestSquarePartStrength = fromData.chestSquarePartStrength

	toData.blackCuteMaxStrength = fromData.blackCuteMaxStrength
	toData.blackCuteStrength = fromData.blackCuteStrength
	toData.lastInjuredStep = fromData.lastInjuredStep
	
	toData.mimosaDirection = fromData.mimosaDirection
	toData.mimosaLevel = fromData.mimosaLevel
	toData.mimosaHoldGrid = table.clone(fromData.mimosaHoldGrid)
	toData.beEffectByMimosa = fromData.beEffectByMimosa

	
	toData.isSnail = fromData.isSnail
	toData.hedgehogLevel = fromData.hedgehogLevel
	toData.hedge_before = fromData.hedge_before

	toData.wukongProgressCurr = fromData.wukongProgressCurr
	toData.wukongProgressTotal = fromData.wukongProgressTotal
	toData.wukongIsReadyToJump = fromData.wukongIsReadyToJump
	toData.wukongState = fromData.wukongState
	toData.wukongJumpPos = IntCoord:clone(fromData.wukongJumpPos)

	--------------- Mayday Boss Levels -----------
	toData.bossLevel = fromData.bossLevel 
	toData.blood = fromData.blood
	toData.maxBlood = fromData.maxBlood
	toData.moves = fromData.moves
	toData.maxMoves = fromData.maxMoves
	toData.animal_num = fromData.animal_num
	toData.drop_sapphire = fromData.drop_sapphire
	toData.speicial_hit_blood = fromData.speicial_hit_blood
	toData.hitCounter = fromData.hitCounter
	toData.rabbitState = fromData.rabbitState
	toData.rabbitLevel = fromData.rabbitLevel

	toData.weeklyBossLevel = fromData.weeklyBossLevel 
	-- 章鱼冰道具
	toData.forbiddenLevel = fromData.forbiddenLevel

	-- 神灯
	toData.lampLevel = fromData.lampLevel

	--蜂蜜罐子等级
	toData.honeyBottleLevel = fromData.honeyBottleLevel
	toData.honeyLevel  = fromData.honeyLevel

	--增加时间
	toData.addTime = fromData.addTime

	-- 魔法石属性
	toData.magicStoneDir = fromData.magicStoneDir
	toData.magicStoneLevel = fromData.magicStoneLevel
	toData.magicStoneActiveTimes = fromData.magicStoneActiveTimes
	toData.magicStoneLocked = fromData.magicStoneLocked

	toData.isProductByBossDie = fromData.isProductByBossDie
	toData.questionMarkProduct = fromData.questionMarkProduct
	toData.showType = fromData.showType

	toData.bottleLevel = fromData.bottleLevel
	toData.bottleState = fromData.bottleState
	toData.bottleActionRunningCount = fromData.bottleActionRunningCount
	toData.crystalStoneEnergy = fromData.crystalStoneEnergy
	toData.crystalStoneActive = fromData.crystalStoneActive
	toData.crystalStoneBombType = fromData.crystalStoneBombType

	toData.totemsState = fromData.totemsState

	toData.lotusLevel = fromData.lotusLevel

	toData.beEffectBySuperCute = fromData.beEffectBySuperCute
	toData.dripState = fromData.dripState
	toData.dripLeaderPos = IntCoord:clone(fromData.dripLeaderPos)

	toData.pufferState = fromData.pufferState
	toData.dropProps = fromData.dropProps

	toData.olympicBlockerLevel = fromData.olympicBlockerLevel
	toData.olympicLockLevel = fromData.olympicLockLevel

	toData.missileLevel = fromData.missileLevel
	toData.randomPropType = fromData.randomPropType
	toData.randomPropDropId = fromData.randomPropDropId
	toData.randomPropLevel = fromData.randomPropLevel 
	toData.hitBySpringBomb = fromData.hitBySpringBomb

	toData.key = fromData.key
	toData.blockerCoverLevel = fromData.blockerCoverLevel
	toData.subtype = fromData.subtype
	toData.level = fromData.level
	toData.isActive = fromData.isActive
	toData.flag = fromData.flag

	if mode == gCopyDataMode.kNormal then
		toData.snailRoadType = fromData.snailRoadType
	elseif mode == gCopyDataMode.kDoubleSideBlockerTurn then
		toData.snailTarget = fromData.snailTarget
	end

	toData.tangChickenNum = fromData.tangChickenNum

	toData.colorFilterBLock = fromData.colorFilterBLock
	toData.hasActCollection = fromData.hasActCollection
	toData.nextColour = fromData.nextColour
	toData.nextSpecial = fromData.nextSpecial
	toData.lockLevel = fromData.lockLevel
	toData.lockHead = fromData.lockHead
	toData.needKeys = fromData.needKeys
	toData.lockBoxRopeRight = fromData.lockBoxRopeRight
	toData.lockBoxRopeLeft = fromData.lockBoxRopeLeft
	toData.lockBoxRopeDown = fromData.lockBoxRopeDown
	toData.lockBoxRopeUp = fromData.lockBoxRopeUp
	toData.lockBoxActive = fromData.lockBoxActive

	toData.pacmanColour = fromData.pacmanColour
	toData.pacmanDevourAmount = fromData.pacmanDevourAmount
	toData.pacmanIsSuper = fromData.pacmanIsSuper
	toData.pacmansDenPos = fromData.pacmansDenPos

    toData.turretDir = fromData.turretDir
	toData.turretIsTypeRandom = fromData.turretIsTypeRandom
	toData.turretLevel = fromData.turretLevel
	toData.turretIsSuper = fromData.turretIsSuper
	toData.turretLocked = fromData.turretLocked

	toData.moleBossSeedHP = fromData.moleBossSeedHP
	toData.moleBossSeedCountDown = fromData.moleBossSeedCountDown
	toData.moleBossCloudLevel = fromData.moleBossCloudLevel
    toData.yellowDiamondLevel = fromData.yellowDiamondLevel
    toData.yellowDiamondCanbeDelete = fromData.yellowDiamondCanbeDelete
    
    toData.coveredByGhost = fromData.coveredByGhost
    toData.ghostPaceLength = fromData.ghostPaceLength

    toData.blocker199Colors = fromData.blocker199Colors
    toData.blocker199Dirs = fromData.blocker199Dirs

    toData.blocker83Colors = fromData.blocker83Colors

    toData.isToBlastScoreBuffBottles = fromData.isToBlastScoreBuffBottles
    toData.sunFlaskLevel = fromData.sunFlaskLevel
    toData.isToBlastFirecracker = fromData.isToBlastFirecracker

    toData.squidDirection = fromData.squidDirection
    toData.squidTargetType = fromData.squidTargetType
    toData.squidTargetNeeded = fromData.squidTargetNeeded
    toData.squidTargetCount = fromData.squidTargetCount
    toData.needRemoveEventuallyBySquid = fromData.needRemoveEventuallyBySquid

    toData.wanShengLevel = fromData.wanShengLevel
    toData.wanShengConfig = fromData.wanShengConfig
end

function GameItemData:copy()
	local v = GameItemData.new()

	v.x = self.x
	v.y = self.y
	v.w = self.w
	v.h = self.h

	v:copyDatasFrom(self)
	return v
end

function GameItemData:initByConfig( tileDef )
	-- body
	self.x = tileDef.x
	self.y = tileDef.y

	if tileDef:hasProperty(TileConst.kEmpty) then self.isUsed = false else self.isUsed = true end

	if tileDef:hasProperty(TileConst.kNone) then self.isEmpty = true end

	if tileDef:hasProperty(TileConst.kAddMove) then self.ItemType = GameItemType.kAddMove self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kPuffer) then self.ItemType = GameItemType.kPuffer self.isBlock = false self.isEmpty = false self.pufferState = PufferState.kNormal
	elseif tileDef:hasProperty(TileConst.kPufferActivated) then self.ItemType = GameItemType.kPuffer self.isBlock = false self.isEmpty = false self.pufferState = PufferState.kActivated
	elseif tileDef:hasProperty(TileConst.kDrip) then self.ItemType = GameItemType.kDrip self.isBlock = false self.isEmpty = false self._encrypt.ItemColorType = AnimalTypeConfig.kDrip self.dripState = DripState.kNormal
	elseif tileDef:hasProperty(TileConst.kWukong) then self.ItemType = GameItemType.kWukong self.isBlock = true self.isEmpty = false self._encrypt.ItemColorType = AnimalTypeConfig.kBlue self.wukongProgressCurr = 0 self.wukongState = TileWukongState.kNormal
	elseif tileDef:hasProperty(TileConst.kBottleBlocker) then self.ItemType = GameItemType.kBottleBlocker self.isBlock = true self.isEmpty = false self.bottleLevel = tileDef:getCrossStrengthLevel() --[[self.initColor = tileDef:getCrossStrengthColor()]] self.bottleState = BottleBlockerState.Waiting
	elseif tileDef:hasProperty(TileConst.kAddTime) then self.ItemType = GameItemType.kAddTime self.isEmpty = false  --TODO
	elseif tileDef:hasProperty(TileConst.kQuestionMark) then self.ItemType = GameItemType.kQuestionMark self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kTotems) then self.ItemType = GameItemType.kTotems self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kRocket) then self.ItemType = GameItemType.kRocket self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kCrystalStone) then self.ItemType = GameItemType.kCrystalStone self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kBlocker195) then self.ItemType = GameItemType.kBlocker195 self.subtype = tileDef:getAttrOfProperty(TileConst.kBlocker195) self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kBlocker199) then 
		self.ItemType = GameItemType.kBlocker199 self.subtype = tonumber(tileDef:getAttrOfProperty(TileConst.kBlocker199)) 
		self.level = 3 self.isActive = false self.isBlock = true self.isEmpty = false 
		self:initBlocker199AddInfo(tileDef:getAddInfoOfProperty(TileConst.kBlocker199))
	elseif tileDef:hasProperty(TileConst.kBlocker207) then self.ItemType = GameItemType.kBlocker207 self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kAnimal) then self.ItemType = GameItemType.kAnimal self.isEmpty=false
	elseif tileDef:hasProperty(TileConst.kCrystal) then self.ItemType = GameItemType.kCrystal self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kMagicLamp) then 
		self.ItemType = GameItemType.kMagicLamp self.isEmpty = false self.lampLevel = 1 self.isBlock = true
		self:initBlocker83AddInfo(tileDef:getAddInfoOfProperty(TileConst.kMagicLamp))
	elseif tileDef:hasProperty(TileConst.kHoneyBottle) then self.ItemType = GameItemType.kHoneyBottle self.isEmpty = false self.honeyBottleLevel = 1 self.isBlock = false
	elseif tileDef:hasProperty(TileConst.kGift) then self.ItemType = GameItemType.kGift self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kNewGift) then self.ItemType = GameItemType.kNewGift self.isEmpty = false  
	elseif tileDef:hasProperty(TileConst.kFrosting) then self.ItemType = GameItemType.kSnow self.isBlock = true self.isEmpty=false	--判断类型
	elseif tileDef:hasProperty(TileConst.kFrosting1) then self.snowLevel = 1 self.ItemType = GameItemType.kSnow self.isBlock = true	self.isEmpty=false --雪花类型
	elseif tileDef:hasProperty(TileConst.kFrosting2) then self.snowLevel = 2 self.ItemType = GameItemType.kSnow self.isBlock = true self.isEmpty=false
	elseif tileDef:hasProperty(TileConst.kFrosting3) then self.snowLevel = 3 self.ItemType = GameItemType.kSnow self.isBlock = true self.isEmpty=false
	elseif tileDef:hasProperty(TileConst.kFrosting4) then self.snowLevel = 4 self.ItemType = GameItemType.kSnow self.isBlock = true self.isEmpty=false
	elseif tileDef:hasProperty(TileConst.kFrosting5) then self.snowLevel = 5 self.ItemType = GameItemType.kSnow self.isBlock = true self.isEmpty=false
	elseif tileDef:hasProperty(TileConst.kPoison) then self.ItemType = GameItemType.kVenom self.isBlock = true self.venomLevel = 1 self.isEmpty=false	
	elseif tileDef:hasProperty(TileConst.kDigGround_1) then self.digGroundLevel = 1 self.ItemType = GameItemType.kDigGround self.isBlock = true self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kDigGround_2) then self.digGroundLevel = 2 self.ItemType = GameItemType.kDigGround self.isBlock = true self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kDigGround_3) then self.digGroundLevel = 3	self.ItemType = GameItemType.kDigGround self.isBlock = true self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kDigJewel_1) then self.digJewelLevel = 1 self.ItemType = GameItemType.kDigJewel self.isBlock = true self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kDigJewel_2) then self.digJewelLevel = 2 self.ItemType = GameItemType.kDigJewel self.isBlock = true self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kDigJewel_3) then self.digJewelLevel = 3 self.ItemType = GameItemType.kDigJewel self.isBlock = true self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kDigJewel_1_blue) then self.digJewelLevel = 1 self.ItemType = GameItemType.kDigJewel self.isBlock = true self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kDigJewel_2_blue) then self.digJewelLevel = 2 self.ItemType = GameItemType.kDigJewel self.isBlock = true self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kDigJewel_3_blue) then self.digJewelLevel = 3 self.ItemType = GameItemType.kDigJewel self.isBlock = true self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kRoost) then self.ItemType = GameItemType.kRoost self.isBlock = true self.roostLevel = 1 self.roostCastCount = 0 self.isEmpty = false 
	elseif tileDef:hasProperty(TileConst.kPoisonBottle) then self.ItemType = GameItemType.kPoisonBottle self.forbiddenLevel = 0 self.isBlock = true  self.isEmpty = false   --默认毒液瓶
	elseif tileDef:hasProperty(TileConst.kBigMonster) then self.ItemType = GameItemType.kBigMonster self.isBlock = true self.bigMonsterFrostingType = 1 self.isEmpty = false self.bigMonsterFrostingStrength = 1
	elseif tileDef:hasProperty(TileConst.kBigMonsterFrosting1) then self.ItemType = GameItemType.kBigMonsterFrosting self.isBlock = true self.bigMonsterFrostingType = 1 self.isEmpty = false self.bigMonsterFrostingStrength = 1
	elseif tileDef:hasProperty(TileConst.kBigMonsterFrosting2) then self.ItemType = GameItemType.kBigMonsterFrosting self.isBlock = true self.bigMonsterFrostingType = 2 self.isEmpty = false self.bigMonsterFrostingStrength = 1
	elseif tileDef:hasProperty(TileConst.kBigMonsterFrosting3) then self.ItemType = GameItemType.kBigMonsterFrosting self.isBlock = true self.bigMonsterFrostingType = 3 self.isEmpty = false self.bigMonsterFrostingStrength = 1
	elseif tileDef:hasProperty(TileConst.kBigMonsterFrosting4) then self.ItemType = GameItemType.kBigMonsterFrosting self.isBlock = true self.bigMonsterFrostingType = 4 self.isEmpty = false self.bigMonsterFrostingStrength = 1
	elseif tileDef:hasProperty(TileConst.kChestSquare) then self.drop_sapphire = ChestSquareConfig.drop_sapphire  self.ItemType = GameItemType.kChestSquare self.isBlock = true self.chestSquarePartType  = 1 self.isEmpty = false self.chestSquarePartStrength = 1
	-- elseif tileDef:hasProperty(TileConst.kChestSquare1) then self.ItemType = GameItemType.kChestSquarePart self.isBlock = true self.chestSquarePartType = 1 self.isEmpty = false self.chestSquarePartStrength = 1
	elseif tileDef:hasProperty(TileConst.kChestSquare2) then self.ItemType = GameItemType.kChestSquarePart self.isBlock = true self.chestSquarePartType = 2 self.isEmpty = false self.chestSquarePartStrength = 1
	elseif tileDef:hasProperty(TileConst.kChestSquare3) then self.ItemType = GameItemType.kChestSquarePart self.isBlock = true self.chestSquarePartType = 3 self.isEmpty = false self.chestSquarePartStrength = 1
	elseif tileDef:hasProperty(TileConst.kChestSquare4) then self.ItemType = GameItemType.kChestSquarePart self.isBlock = true self.chestSquarePartType = 4 self.isEmpty = false self.chestSquarePartStrength = 1
	elseif tileDef:hasProperty(TileConst.kMimosaLeft) then self.ItemType = GameItemType.kMimosa self.mimosaDirection = 1 self.isBlock = true self.isEmpty = false self.mimosaLevel = 1
	elseif tileDef:hasProperty(TileConst.kMimosaRight) then self.ItemType = GameItemType.kMimosa self.mimosaDirection = 2 self.isBlock = true self.isEmpty = false self.mimosaLevel = 1
	elseif tileDef:hasProperty(TileConst.kMimosaUp) then self.ItemType = GameItemType.kMimosa self.mimosaDirection = 3 self.isBlock = true self.isEmpty = false self.mimosaLevel = 1
	elseif tileDef:hasProperty(TileConst.kMimosaDown) then self.ItemType = GameItemType.kMimosa self.mimosaDirection = 4 self.isBlock = true self.isEmpty = false self.mimosaLevel = 1
	elseif tileDef:hasProperty(TileConst.kKindMimosaLeft) then self.ItemType = GameItemType.kKindMimosa self.mimosaDirection = 1 self.isBlock = true self.isEmpty = false self.mimosaLevel = 1
	elseif tileDef:hasProperty(TileConst.kKindMimosaRight) then self.ItemType = GameItemType.kKindMimosa self.mimosaDirection = 2 self.isBlock = true self.isEmpty = false self.mimosaLevel = 1
	elseif tileDef:hasProperty(TileConst.kKindMimosaUp) then self.ItemType = GameItemType.kKindMimosa self.mimosaDirection = 3 self.isBlock = true self.isEmpty = false self.mimosaLevel = 1
	elseif tileDef:hasProperty(TileConst.kKindMimosaDown) then self.ItemType = GameItemType.kKindMimosa self.mimosaDirection = 4 self.isBlock = true self.isEmpty = false self.mimosaLevel = 1
	elseif tileDef:hasProperty(TileConst.kSnail) then  self.isBlock = true self.isEmpty = false self.isSnail = true
	elseif tileDef:hasProperty(TileConst.kHedgehog) then self.isBlock = true self.isEmpty = false self.hedgehogLevel = 1 self.hedge_before = true
	elseif tileDef:hasProperty(TileConst.kMayDayBlocker1) then self:initMaydayBoss(1)
	elseif tileDef:hasProperty(TileConst.kMayDayBlocker2) then self:initMaydayBoss(2)
	elseif tileDef:hasProperty(TileConst.kMayDayBlocker3) then self:initMaydayBoss(3)
	elseif tileDef:hasProperty(TileConst.kMayDayBlocker4) then self:initMaydayBoss(4)
	elseif tileDef:hasProperty(TileConst.kMaydayBlockerEmpty) then self.ItemType = GameItemType.kBoss self.bossLevel = 0 self.isBlock = true self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kWeeklyBoss) then self:initWeeklyBoss() 
	elseif tileDef:hasProperty(TileConst.kWeeklyBossEmpty) then self.ItemType = GameItemType.kWeeklyBoss self.weeklyBossLevel = 0 self.isBlock = true self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kCoin) then self.ItemType = GameItemType.kCoin self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kBlackCute) then self.ItemType = GameItemType.kBlackCuteBall self.isEmpty = false self.blackCuteStrength = 2 self.blackCuteMaxStrength = self.blackCuteStrength
	elseif tileDef:hasProperty(TileConst.kFudge) then self.ItemType = GameItemType.kIngredient self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kBalloon) then self.ItemType = GameItemType.kBalloon self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kSuperBlocker) then self.ItemType = GameItemType.kSuperBlocker self.isEmpty = false self.isBlock = true
	elseif tileDef:hasProperty(TileConst.kHedgehogBox) then self.ItemType = GameItemType.kHedgehogBox self.isEmpty = false self.isBlock = true
	elseif tileDef:hasProperty(TileConst.kMissile) then self.ItemType = GameItemType.kMissile self.isEmpty = false self.isBlock = false self.missileLevel = 3
	elseif tileDef:hasProperty(TileConst.kChameleon) then self.ItemType = GameItemType.kChameleon self.isEmpty = false 
	elseif tileDef:hasProperty(TileConst.kPacman) then
		self.ItemType = GameItemType.kPacman
		self.pacmanColour = tonumber(tileDef:getAttrOfProperty(TileConst.kPacman))
		self.isBlock = true 
		self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kPacmansDen) then self.ItemType = GameItemType.kPacmansDen self.isBlock = true self.isEmpty = false
	elseif tileDef:hasProperty(TileConst.kOlympicBlocker) then 
		self.ItemType = GameItemType.kOlympicBlocker self.isEmpty = false self.isBlock = true 
		self.olympicBlockerLevel = tonumber(tileDef:getAttrOfProperty(TileConst.kOlympicBlocker))
		if not self.olympicBlockerLevel then
			self.olympicBlockerLevel = 3
			he_log_error("olympicBlockerLevel not defined!!")
		end
	elseif tileDef:hasProperty(TileConst.kTangChicken) then
		self.ItemType = GameItemType.kTangChicken
		self.isEmpty = false
		self.isBlock = true
		self.tangChickenNum = tonumber(tileDef:getAddInfoOfProperty(TileConst.kTangChicken)) or 1 
    elseif tileDef:hasProperty(TileConst.kYellowDiamondGrass1) then 
        self.yellowDiamondLevel = 1 self.ItemType = GameItemType.kYellowDiamondGrass self.isBlock = true self.isEmpty = false
    elseif tileDef:hasProperty(TileConst.kYellowDiamondGrass2) then 
        self.yellowDiamondLevel = 2 self.ItemType = GameItemType.kYellowDiamondGrass self.isBlock = true self.isEmpty = false
    elseif tileDef:hasProperty(TileConst.kSunFlask) then
    	self.ItemType = GameItemType.kSunFlask
    	self.isBlock = true
    	self.isEmpty = false
    	self.sunFlaskLevel = tonumber(tileDef:getAttrOfProperty(TileConst.kSunFlask))
    elseif tileDef:hasProperty(TileConst.kSunflower) then
    	self.ItemType = GameItemType.kSunflower
    	self.isBlock = true
    	self.isEmpty = false
    elseif tileDef:hasProperty(TileConst.kSquid) then
    	self.ItemType = GameItemType.kSquid
    	self.isBlock = true
    	self.isEmpty = false
    	self.squidDirection = tonumber(tileDef:getAttrOfProperty(TileConst.kSquid))
    elseif tileDef:hasProperty(TileConst.kSquidEmpty) then self.ItemType = GameItemType.kSquidEmpty self.isEmpty = false self.isBlock = true
    elseif tileDef:hasProperty(TileConst.kWanSheng) then 
        self.ItemType = GameItemType.kWanSheng 
        self.isEmpty = false 
        self.wanShengLevel = 1 
        self.wanShengConfig = nil
        self.isBlock = true
	end

	-- 标记为可能的道具云块，具体决策在GameMapInitialLogic中
	if tileDef:hasProperty(TileConst.kRandomProp1) then self.randomPropType = RandomPropType.kRandomProp1 end
	if tileDef:hasProperty(TileConst.kRandomProp2) then self.randomPropType = RandomPropType.kRandomProp2 end
	if tileDef:hasProperty(TileConst.kRandomProp3) then self.randomPropType = RandomPropType.kRandomProp3  end
	if tileDef:hasProperty(TileConst.kRandomProp4) then self.randomPropType = RandomPropType.kRandomProp4  end

	if tileDef:hasProperty(TileConst.kGreyCute) then self.furballLevel = 1 self.furballType = GameItemFurballType.kGrey self.isEmpty=false							--毛球类型
	elseif tileDef:hasProperty(TileConst.kBrownCute) then self.furballLevel = 1 self.furballType = GameItemFurballType.kBrown self.isEmpty=false
	elseif tileDef:hasProperty(TileConst.kSuperCute) then 
		self.beEffectBySuperCute = true
		self.isBlock = true 
	end

	if tileDef:hasProperty(TileConst.kGhost) then
		self.coveredByGhost = true
		self.isBlock = true 
	end

	if tileDef:hasProperty(TileConst.kLock) then self.cageLevel = 1 self.isBlock = true self.isEmpty=false		--牢笼类型
	end

	----[[
	if tileDef:hasProperty(TileConst.kLotusLevel1) then
		self.lotusLevel = 1 
	end

	if tileDef:hasProperty(TileConst.kLotusLevel2) then
		self.lotusLevel = 2 
		self.isBlock = true 
	end
	if tileDef:hasProperty(TileConst.kLotusLevel3) then
		self.lotusLevel = 3 
		self.isBlock = true 
	end
	--]]

	if tileDef:hasProperty(TileConst.kHoney) then self.honeyLevel = 1 self.isBlock = true end

	local hasMagicStoneProperty, magicStoneDir = tileDef:hasMagicStoneProperty()
	if hasMagicStoneProperty then -- 魔法石
		self.ItemType = GameItemType.kMagicStone
		self.magicStoneDir = magicStoneDir
		self.magicStoneLevel = TileMagicStoneConst.kInitLevel
		self.isBlock = true
		self.isEmpty=false
	end

    local hasTurretProperty, turretDir, isRandomTurret = TurretLogic:parseConfig(tileDef)
	-- printx(11, "parse turret config. ", hasTurretProperty, turretDir, isRandomTurret)
	if hasTurretProperty then
		self.ItemType = GameItemType.kTurret
		self.turretDir = turretDir
		self.turretIsTypeRandom = isRandomTurret
		self.turretLevel = 0
		self.turretIsSuper = false
		self.turretLocked = false

		self.isBlock = true
		self.isEmpty = false
	end

	if tileDef:hasProperty(TileConst.kOlympicLockBlocker) then
		self.olympicLockLevel = tonumber(tileDef:getAttrOfProperty(TileConst.kOlympicLockBlocker))
		if not self.olympicLockLevel then
			self.olympicLockLevel = 0
			he_log_error("olympicLockLevel not defined!!")
		end
		self.isBlock = true
	end

	if tileDef:hasProperty(TileConst.kTileBlocker2) then self.isReverseSide = true end

	if tileDef:hasProperty(TileConst.kColorFilter) then
		local addInfo = tileDef:getAddInfoOfProperty(TileConst.kColorFilter)
		local filterLv = tonumber(addInfo) or 3
		if filterLv > 0 then  
			self:setColorFilterBLock(true)
			self.isBlock = true
		end
	end
	if tileDef:hasProperty(TileConst.kBlocker206) then 
		local blocker206_addinfo = tileDef:getAddInfoOfProperty(TileConst.kBlocker206)
		local arr = string.split(blocker206_addinfo, "|")
		
		if arr[1] then
			self.lockLevel = tonumber(arr[1]) 
		else
			self.lockLevel = 0
		end

		if arr[2] then
			self.lockHead = tonumber(arr[2]) == 1
		else
			self.lockHead = false
		end
	end
	if tileDef:hasProperty(TileConst.kBlocker211) then 
		self.ItemType = GameItemType.kBlocker211 
		local addInfo = tileDef:getAddInfoOfProperty(TileConst.kBlocker211)
		addInfo = string.split(addInfo, '|')
		self._encrypt.ItemColorType = AnimalTypeConfig.convertIndexToColorType(tonumber(addInfo[1]))
		self.subtype = tonumber(addInfo[2])
		self.level = 0
		self.isBlock = true 
		self.isEmpty = false
		self.isActive = false
	end

	self.key = KeyGenerate()
end

function GameItemData:initBlocker199AddInfo(addInfo)
	self.blocker199Dirs = {1, 2, 3, 4}
	if addInfo then
		addInfo = string.split(addInfo, '|')
		if addInfo[1] then
			local colorInfos = string.split(addInfo[1], ':')
			if #colorInfos > 0 then
				self.blocker199Colors = {}
				for i,v in ipairs(colorInfos) do
					table.insert(self.blocker199Colors, AnimalTypeConfig.convertIndexToColorType(tonumber(v)))
				end
			end
		end

		if addInfo[2] then 
			local dirInfos = string.split(addInfo[2], ':')
			if #dirInfos > 0 then
				self.blocker199Dirs ={}
				for i,v in ipairs(dirInfos) do
					table.insert(self.blocker199Dirs, tonumber(v))
				end

				if #self.blocker199Dirs > 0 then 
					local tempDirs = {}
					--二四象限和顺时针旋转的方向兼容处理
					for i,v in ipairs(self.blocker199Dirs) do
						if v == 2 then
							table.insert(tempDirs, 4)
						elseif v == 4 then
							table.insert(tempDirs, 2)
						else
							table.insert(tempDirs, v)
						end
					end
					table.sort(tempDirs, function (a, b)
						return a < b
					end)
					self.blocker199Dirs = tempDirs
				end
			end
		end
	end
end

function GameItemData:initBlocker83AddInfo(addInfo)
	if addInfo then
		local colorInfos = string.split(addInfo, ':')
		if #colorInfos > 0 then
			self.blocker83Colors = {}
			for i,v in ipairs(colorInfos) do
				table.insert(self.blocker83Colors, AnimalTypeConfig.convertIndexToColorType(tonumber(v)))
			end
		end 
	end
end

function GameItemData:initByAnimalDef(animalDef)--animal的相关初始数据
	if (self:isColorful() or self.ItemType == GameItemType.kCrystalStone) and self.ItemType ~= GameItemType.kDrip then
		self._encrypt.ItemColorType = AnimalTypeConfig.getType(animalDef)
	end
	if self.ItemType == GameItemType.kAnimal then
		self.ItemSpecialType = AnimalTypeConfig.getSpecial(animalDef)
	end
end

function GameItemData:initBalloonConfig( balloonFrom )
	if self.ItemType == GameItemType.kBalloon then
		self.balloonFrom = balloonFrom
	end
end

function GameItemData:initAddMoveConfig(baseAddMove)
	if self.ItemType == GameItemType.kAddMove then
		self.numAddMove = baseAddMove or 5
	end
end

function GameItemData:initAddTimeConfig(baseAddTime)
	if self.ItemType == GameItemType.kAddTime then
		self.addTime = baseAddTime
	end
end

function GameItemData:initSnailRoadType( gameboardData )
	-- body
	if self.isSnail or self:isHedgehog() then 
		self.snailRoadType = gameboardData.snailRoadType
	end

	if self:isHedgehog() then
		gameboardData:changeHedgehogRoadState(HedgeRoadState.kDestroy)
	end
end

function GameItemData:isHedgehog( ... )
	-- body
	return self.hedgehogLevel > 0
end

function GameItemData:changeItemType(colortype, specialtype)
	self._encrypt.ItemColorType = colortype
	self.ItemSpecialType = specialtype
end

function GameItemData:changeToVenom()
	self.ItemType = GameItemType.kVenom
	self.isBlock = true
	self.venomLevel = 1
	self._encrypt.ItemColorType = 0
	self.ItemSpecialType = 0
	self.isEmpty = false
end

function GameItemData:changeToDigGround( digGroundLevel )
	-- body
	digGroundLevel = digGroundLevel or 1
	self.ItemType = GameItemType.kDigGround
	self.isBlock = true
	self.digGroundLevel = digGroundLevel
	self._encrypt.ItemColorType = 0
	self.ItemSpecialType = 0
	self.isEmpty = false
end

function GameItemData:changeToSnail( snailRoadType )
	-- body
	self.ItemType = GameItemType.kNone
	self._encrypt.ItemColorType = 0
	self.ItemSpecialType = 0
	self.isEmpty = false
	self.snailRoadType = snailRoadType
	self.isSnail = true
	self.isNeedUpdate = true
end

function GameItemData:changeToHedgehog( snailRoadType, hedgehogLevel )
	-- body
	self.ItemType = GameItemType.kNone
	self._encrypt.ItemColorType = 0
	self.ItemSpecialType = 0
	self.isEmpty = false
	self.snailRoadType = snailRoadType
	self.hedgehogLevel = hedgehogLevel or 1
	self.isNeedUpdate = true
end

function GameItemData:changeToRabbit( colortype, level )
	self:cleanAnimalLikeData()
	self.isBlock = false
	self._encrypt.ItemColorType = colortype
	self.rabbitLevel = level
	self.ItemType = GameItemType.kRabbit
	self.isEmpty = false
end

function GameItemData:changeToIngredient( ... )
	-- body
	self.ItemType = GameItemType.kIngredient
	self.isBlock = false
	self._encrypt.ItemColorType = 0
	self.ItemSpecialType = 0
	self.isEmpty = false
end

--转换为大眼仔
function GameItemData:changeToMagicLamp()
    
    self:cleanAnimalLikeData()
	self.ItemType = GameItemType.kMagicLamp 
    self.isEmpty = false 
    self.lampLevel = 0 
    self.isBlock = true
	self:initBlocker83AddInfo() --什么都不传走默认的 之后有需求再加参数

--    local mainLogic = GameBoardLogic:getCurrentLogic()
--    if mainLogic then
--        GameMapInitialLogic:randomSetColor(mainLogic, self.y, self.x)
--    end
end

--转换为精灵萌豆
function GameItemData:changeToBottleBlocker( level )
    
    self:cleanAnimalLikeData()
	self.ItemType = GameItemType.kBottleBlocker 
    self.isBlock = true 
    self.isEmpty = false 
    self.bottleLevel = level or 1
    self.bottleState = BottleBlockerState.Waiting

    local mainLogic = GameBoardLogic:getCurrentLogic()
    if mainLogic then
    	self._encrypt.ItemColorType = GameExtandPlayLogic:randomBottleBlockerColor(mainLogic, self.y, self.x)
    end
end

--转换为过滤器
function GameItemData:changeToColorFilter( attr, addInfo )
    self:cleanAnimalLikeData() 
	local filterLv = tonumber(addInfo) or 3
	if filterLv > 0 then  
		self:setColorFilterBLock(true)
		self.isBlock = true
	end
end

--转换为吃豆人
function GameItemData:changeToPacman()
    self:cleanAnimalLikeData() 
	self.ItemType = GameItemType.kPacman
	self.pacmanColour = 0
	self.isBlock = true 
	self.isEmpty = false
end

--转换为1层雪
function GameItemData:changeToFrosting( level )
    self:cleanAnimalLikeData() 
	self.snowLevel = level
    self.ItemType = GameItemType.kSnow 
    self.isBlock = true	
    self.isEmpty=false
end

--转换为牢笼
function GameItemData:changeToLock( level )
	self.cageLevel = 1 
    self.isBlock = true 
    self.isEmpty=false
end

--转换为银币
function GameItemData:changeToCoin( )
    self:cleanAnimalLikeData() 
    self.ItemType = GameItemType.kCoin 
    self.isEmpty = false
end

--转换为水晶球
function GameItemData:changeToCrystal( )
    self.ItemType = GameItemType.kCrystal 
    self.isEmpty = false
end

--转换为1层云
function GameItemData:changeToDigGround( level )
    self:cleanAnimalLikeData() 
    self.digGroundLevel = level
    self.ItemType = GameItemType.kDigGround 
    self.isBlock = true 
    self.isEmpty = false
end

--转换为灰毛球
function GameItemData:changeToGreyCute( )
    self.furballLevel = 1 
    self.furballType = GameItemFurballType.kGrey 
    self.isEmpty=false	
end

--转换为褐毛球
function GameItemData:changeToBrownCute( )
    self.furballLevel = 1 
    self.furballType = GameItemFurballType.kBrown 
    self.isEmpty=false
end

--转换为黑毛球
function GameItemData:changeToBlackCute( )
    self:cleanAnimalLikeData() 

    self.ItemType = GameItemType.kBlackCuteBall
	self.isBlock = true 
    self.isEmpty = false
    self.blackCuteStrength = 2
    self.blackCuteMaxStrength = self.blackCuteStrength
end

--转换为毒液
function GameItemData:changeToPoison( )
    self:cleanAnimalLikeData() 
    self.ItemType = GameItemType.kVenom 
    self.isBlock = true 
    self.venomLevel = 1 
    self.isEmpty=false	
end

--转换为蜂蜜罐
function GameItemData:changeToHoneyBottle( )
    self:cleanAnimalLikeData() 
    self.ItemType = GameItemType.kHoneyBottle 
    self.isEmpty = false 
    self.honeyBottleLevel = 1 
    self.isBlock = false
end

--转换为气鼓鱼
function GameItemData:changeToPuffer( PufferType )
    self:cleanAnimalLikeData() 
    self.ItemType = GameItemType.kPuffer 
    self.isBlock = false 
    self.isEmpty = false 

    if PufferType == 1 then
        self.pufferState = PufferState.kNormal
    else
        self.pufferState = PufferState.kActivated
    end
end

--转换为冰封导弹
function GameItemData:changeToMissile( )
    self:cleanAnimalLikeData() 
    self.ItemType = GameItemType.kMissile 
    self.isEmpty = false 
    self.isBlock = false 
    self.missileLevel = 3
end

--转换为变色龙
function GameItemData:changeToChameleon( )
    self:cleanAnimalLikeData() 
    self.ItemType = GameItemType.kChameleon 
    self.isEmpty = false 
end

--转换为钥匙
function GameItemData:changeToBlocker207( )
    self:cleanAnimalLikeData() 
    self.ItemType = GameItemType.kBlocker207 
    self.isEmpty = false
end

--转换为炮台
function GameItemData:changeToTurret( dir )
    self:cleanAnimalLikeData() 
    self.ItemType = GameItemType.kTurret
	self.turretDir = dir
	self.turretIsTypeRandom = false
	self.turretLevel = 0
	self.turretIsSuper = false
	self.turretLocked = false

	self.isBlock = true
	self.isEmpty = false
end

--转换为太阳瓶
function GameItemData:changeToSunFlask( level )
    self:cleanAnimalLikeData() 
    self.ItemType = GameItemType.kSunFlask
    self.isBlock = true
    self.isEmpty = false
    self.sunFlaskLevel = level
end

--转换为魔法石
function GameItemData:changeToMagicStone( magicStoneDir )
    self:cleanAnimalLikeData() 
    self.ItemType = GameItemType.kMagicStone
	self.magicStoneDir = magicStoneDir
	self.magicStoneLevel = TileMagicStoneConst.kInitLevel
	self.isBlock = true
	self.isEmpty=false
end

--转换为染色宝宝
function GameItemData:changeToCrystalStone( )
    self:cleanAnimalLikeData() 
    self.ItemType = GameItemType.kCrystalStone 

    local mainLogic = GameBoardLogic:getCurrentLogic() 
    if mainLogic then
        self._encrypt.ItemColorType = mainLogic:randomColor()
    else
        self._encrypt.ItemColorType = AnimalTypeConfig.kBlue 
    end
    self.isEmpty = false
end

--转换为闪电鸟
function GameItemData:changeToTotems( animalDef )
    self:cleanAnimalLikeData() 
    self.ItemType = GameItemType.kTotems 
    self.isEmpty = false

    if animalDef then
        self:initByAnimalDef(animalDef)

        if self._encrypt.ItemColorType == AnimalTypeConfig.kRandom then
            local mainLogic = GameBoardLogic:getCurrentLogic() 
            if mainLogic then
                self._encrypt.ItemColorType = mainLogic:randomColor()
            else
                self._encrypt.ItemColorType = AnimalTypeConfig.kBlue 
            end
        end 
    else
        local mainLogic = GameBoardLogic:getCurrentLogic() 
        if mainLogic then
            self._encrypt.ItemColorType = mainLogic:randomColor()
        else
            self._encrypt.ItemColorType = AnimalTypeConfig.kBlue 
        end
    end
end
--转换为动物
function GameItemData:changeToAnimal( animalDef )

    local mainLogic = GameBoardLogic:getCurrentLogic()
    if mainLogic then
        local oldColor
        if self._encrypt.ItemColorType and type(self._encrypt.ItemColorType) == 'table' then
            oldColor = table.clone(self._encrypt.ItemColorType)
        end

        self:cleanAnimalLikeData() 
        self.ItemType = GameItemType.kAnimal
        self.isEmpty=false

        self:initByAnimalDef( animalDef )
        if self.ItemSpecialType ~= 0 then
            if oldColor then
                self._encrypt.ItemColorType = oldColor
            else
                self._encrypt.ItemColorType = mainLogic:randomColor()
            end
        end
    end
end

--转换为随机直线动物
function GameItemData:changeToLineAnimal()

    local mainLogic = GameBoardLogic:getCurrentLogic()
    if mainLogic then
        local oldColor
        if self._encrypt.ItemColorType and type(self._encrypt.ItemColorType) == 'table' then
            oldColor = table.clone(self._encrypt.ItemColorType)
        end

        self:cleanAnimalLikeData() 
        self.ItemType = GameItemType.kAnimal
        self.isEmpty=false

        if oldColor then
            self._encrypt.ItemColorType = oldColor
        else
            self._encrypt.ItemColorType = mainLogic:randomColor()
        end

        local randomNum = mainLogic.randFactory:rand(1, 2)

        if randomNum== 1 then
            self.ItemSpecialType = AnimalTypeConfig.kLine
        else
            self.ItemSpecialType = AnimalTypeConfig.kColumn
        end
    end
end

function GameItemData:checkCanFallingByItemStatus()
	if self.ItemStatus == GameItemStatusType.kNone 
		--or self.ItemStatus == GameItemStatusType.kItemHalfStable
		or self.ItemStatus == GameItemStatusType.kJustArrived then
		return true
	end

	return false
end
-----为Item增加新状态
function GameItemData:AddItemStatus(itemStatus , forceSet)

	if forceSet then
		self.ItemStatus = itemStatus
		return
	end

	if self.ItemStatus == GameItemStatusType.kNone then
		self.ItemStatus = itemStatus
	elseif self.ItemStatus == GameItemStatusType.kIsMatch then
		if itemStatus == GameItemStatusType.kDestroy then
			self.ItemStatus = GameItemStatusType.kDestroy
		end
	elseif self.ItemStatus == GameItemStatusType.kIsSpecialCover then
		if itemStatus == GameItemStatusType.kDestroy then
			self.ItemStatus = GameItemStatusType.kDestroy
		end
	elseif self.ItemStatus == GameItemStatusType.kItemHalfStable
		or self.ItemStatus == GameItemStatusType.kIsFalling
		or self.ItemStatus == GameItemStatusType.kJustStop then

		if itemStatus == GameItemStatusType.kIsMatch 
			or itemStatus == GameItemStatusType.kIsSpecialCover 
			or itemStatus == GameItemStatusType.kDestroy
			then
			self.ItemStatus = itemStatus
		end

		if UseNewFallingLogic then
			if self.ItemStatus == GameItemStatusType.kIsFalling then
				if itemStatus == GameItemStatusType.kItemHalfStable or itemStatus == GameItemStatusType.kJustArrived then
					self.ItemStatus = itemStatus
				end
			end
		else
			if (self.ItemStatus == GameItemStatusType.kIsFalling and itemStatus == GameItemStatusType.kJustStop)
				or (self.ItemStatus == GameItemStatusType.kIsFalling and itemStatus == GameItemStatusType.kItemHalfStable)
				or (self.ItemStatus == GameItemStatusType.kJustStop and itemStatus == GameItemStatusType.kItemHalfStable) then
				self.ItemStatus = itemStatus
			end
		end
	elseif self.ItemStatus == GameItemStatusType.kJustArrived then
		-- if itemStatus == GameItemStatusType.kItemHalfStable or itemStatus == GameItemStatusType.kIsFalling then
			self.ItemStatus = itemStatus
		-- end
	end
end

--自由之身，没有锁，没有毛球，没被翻过去，没被盖住
function GameItemData:isVisibleAndFree()
	if self:isAvailable() 
		and not self:hasLock() 
		and not self:hasFurball()
		then
		return true
	end
	return false
end

-- 是否可以参与三消匹配，但不一定被消除(比如神灯)
function GameItemData:canBeCoverByMatch()
	if not self.isUsed then return false end
	if self.isEmpty then return false end
	if not self:isColorful() then return false end
	if not self:isAvailable() then return false end
	if self:hasFurball() then return false end
	if self:isActiveTotems() then return false end
	if self.lotusLevel == 3 then return false end
	if self.olympicLockLevel > 0 then return false end
	if self.blockerCoverLevel > 0 then return false end

	if self.ItemStatus == GameItemStatusType.kNone
	or self.ItemStatus == GameItemStatusType.kItemHalfStable
	or self.ItemStatus == GameItemStatusType.kJustArrived --此处有坑，深不可测
	then
		return true
	end
	
	return false
end

-- 是否可以影响该物体下的冰块/流沙/木桩
function GameItemData:canEffectLightUp()
	if (not self.isBlock or 
		self.ItemType == GameItemType.kMagicLamp or 
		self.ItemType == GameItemType.kWukong or 
		self.ItemType == GameItemType.kDrip or
		self.ItemType == GameItemType.kPuffer
		)
		and not self.isEmpty
		and not self:hasFurball()
		and not self:hasLock()
		and self:isAvailable()
		and self.isUsed
		and self.ItemType ~= GameItemType.kBlackCuteBall
		and self.ItemType ~= GameItemType.kMissile
		and self.ItemType ~= GameItemType.kChestSquare
		and self.ItemType ~= GameItemType.kChestSquarePart
		and self.ItemType ~= GameItemType.kHoneyBottle
		and self.ItemType ~= GameItemType.kBottleBlocker
		and self.ItemType ~= GameItemType.kCrystalStone
		and self.ItemType ~= GameItemType.kBlocker195
		and self.ItemType ~= GameItemType.kChameleon
		and self.ItemType ~= GameItemType.kBuffBoom
		and self.ItemType ~= GameItemType.kBlocker207
		and self.ItemType ~= GameItemType.kMoleBossSeed
        and self.ItemType ~= GameItemType.kWanSheng
		then
		return true
	end
	return false
end

--http://wiki.happyelements.net/pages/viewpage.action?pageId=22491797
--任何情况下萌豆变色，不消除下面的一级荷塘
--萌豆下只会摆一级荷塘（产品确认）
function GameItemData:canEffectLotus(lotusLevel)
	if self:hasBlocker206() or self:hasSquidLock() then return false end
	if lotusLevel and lotusLevel == 1 and self.ItemType == GameItemType.kBottleBlocker then 
		return false
	end
	return true
end
 
-- 是否会引起四周冰柱被消除,仅在matchCover时
function GameItemData:canEffectChains()
	if self:hasBlocker206() or self:hasSquidLock() then return false end
	if self.ItemType == GameItemType.kBottleBlocker then
		return false
	end
	return true
end

function GameItemData:canEffectAroundOnMatch(considerBottleBlocker)
	--printx(11, "param: ", considerBottleBlocker);
	if self.lotusLevel == 3 then
		return true
	end

	if self:hasLock() then
		return false
	end

	if not considerBottleBlocker and self.ItemType == GameItemType.kBottleBlocker then
		return false
	end

	-- if self.ItemType == GameItemType.kBottleBlocker or self:hasLock() then
	-- 	return false
	-- end

	return true
end

-- 是否可以在三消匹配中被消除,前置判断是canBeCoverByMatch,此处不需重复过滤
function GameItemData:canBeEliminateByMatch()
	if self:hasLock() then return false end
	if self.ItemType == GameItemType.kMagicLamp then return false end
	if self.ItemType == GameItemType.kWukong then return false end
	if self.ItemType == GameItemType.kDrip then return false end
	if self.ItemType == GameItemType.kBottleBlocker then return false end
	if self.ItemType == GameItemType.kQuestionMark then return false end
	if self.ItemType == GameItemType.kTotems then return false end
	if self.beEffectByMimosa == GameItemType.kKindMimosa then return false end
	if self.ItemType == GameItemType.kBlocker199 then return false end
	if self.ItemType == GameItemType.kScoreBuffBottle then return false end
	if self.ItemType == GameItemType.kFirecracker then return false end
	return true
end

-- 是否可以在三消匹配中参与特效合成,前置判断是canBeCoverByMatch,此处不需重复过滤
function GameItemData:canBeMixToSpecialByMatch()
	if self.ItemType == GameItemType.kMagicLamp then return false end
	if self.ItemType == GameItemType.kWukong then return false end
	if self.ItemType == GameItemType.kBottleBlocker then return false end
	if self.ItemType == GameItemType.kQuestionMark then return false end
	if self.ItemType == GameItemType.kTotems then return false end
	if self.ItemType == GameItemType.kBlocker199 then return false end
	if self.ItemType == GameItemType.kScoreBuffBottle then return false end
	if self.ItemType == GameItemType.kFirecracker then return false end
	return true
end

-- 是否可以被普通特效(不包含魔力鸟、魔力鸟+魔力鸟)直接消除
function GameItemData:canBeEliminateBySpecial()
	if (self.ItemType == GameItemType.kAnimal 		-----动物
		or self.ItemType == GameItemType.kCrystal
		or self.ItemType == GameItemType.kGift 
		or self.ItemType == GameItemType.kNewGift
		or self.ItemType == GameItemType.kCoin
		or self.ItemType == GameItemType.kBalloon 
		or self.ItemType == GameItemType.kAddMove
		or self.ItemType == GameItemType.kAddTime
		or self.ItemType == GameItemType.kRocket
		or self.ItemType == GameItemType.kRabbit
		or self.ItemType == GameItemType.kBlocker207
		)
		and not self.isEmpty and not self:hasFurball() and not self:hasLock() 
		and self:isAvailable() and self.digBlockCanbeDelete and self.yellowDiamondCanbeDelete
		then
		return true
	end
	return false
end

-- 是否可以被过滤器直接消除
function GameItemData:canBeEliminateByFilter()
	if (self.ItemType == GameItemType.kAnimal 		-----动物
		or self.ItemType == GameItemType.kCrystal
		or self.ItemType == GameItemType.kGift 
		or self.ItemType == GameItemType.kNewGift
		or self.ItemType == GameItemType.kBalloon 
		or self.ItemType == GameItemType.kRocket
		)
		and not self.isEmpty and not self:hasFurball()  
		and self:isAvailable() 
		then
		return true
	end
	return false
end

-----可以被鸟和动物交换的特效影响并且直接消除
function GameItemData:canBeEliminateByBirdAnimal()
	if (self.ItemType == GameItemType.kAnimal 		----类型
		or self.ItemType == GameItemType.kCrystal
		or self.ItemType == GameItemType.kGift
		or self.ItemType == GameItemType.kNewGift
		or self.ItemType == GameItemType.kBalloon
		or self.ItemType == GameItemType.kAddMove
		or self.ItemType == GameItemType.kAddTime
		or self.ItemType == GameItemType.kRocket
		or self.ItemType == GameItemType.kRabbit
		)
		and not self:hasFurball() and not self:hasLock()
		and self.isProduct == false 				------不是生产状态/通道通过状态
		and self:isAvailable()
		then
		return true
	end
	return false
end

-----可以被鸟和动物交换的特效影响，但不一定直接消除item，有可能影响了item上的牢笼、毛球等
function GameItemData:canBeCoverByBirdAnimal()
	if self.isEmpty == true or not self:isAvailable() or self.beEffectByMimosa > 0 
			or self.lotusLevel == 3 or self.olympicLockLevel > 0 then 
		return false
	end
	if (self.ItemType == GameItemType.kAnimal and self.ItemSpecialType ~= AnimalTypeConfig.kColor)
		or self.ItemType == GameItemType.kCrystal
		or self.ItemType == GameItemType.kGift
		or self.ItemType == GameItemType.kNewGift
		or self.ItemType == GameItemType.kBalloon
		or self.ItemType == GameItemType.kAddMove
		or self.ItemType == GameItemType.kAddTime
		or self.ItemType == GameItemType.kRabbit
		or self.ItemType == GameItemType.kMagicLamp
		or self.ItemType == GameItemType.kWukong
		or (self.ItemType == GameItemType.kBottleBlocker and self.bottleActionRunningCount <= 0)
		or self.ItemType == GameItemType.kQuestionMark
		or self.ItemType == GameItemType.kRocket
		or self.ItemType == GameItemType.kBlocker199
		or self.ItemType == GameItemType.kScoreBuffBottle
		or self.ItemType == GameItemType.kFirecracker
		then														
		return true
	end
	return false
end

function GameItemData:canBecomeSpecialBySwapColorSpecial( )
	-- body
	if self.lotusLevel == 3 or self.olympicLockLevel > 0 then
		return false
	end

	if (self.ItemType == GameItemType.kAnimal
		or self.ItemType == GameItemType.kGift
		or self.ItemType == GameItemType.kNewGift
		or self.ItemType == GameItemType.kCrystal
		or self.ItemType == GameItemType.kBalloon 
		or self.ItemType == GameItemType.kAddMove
		or self.ItemType == GameItemType.kAddTime
		or self.ItemType == GameItemType.kRabbit
		)
		and self:isAvailable()
		then
		return true
	end
	return false
end

-- 对象可以被鸟鸟交换影响
function GameItemData:isItemCanBeCoverByBirdBird()
	if not self:isAvailable() then return false end
	if self.ItemType == GameItemType.kAnimal
		or self.ItemType == GameItemType.kGift
		or self.ItemType == GameItemType.kNewGift
		or self.ItemType == GameItemType.kCrystal
		or self.ItemType == GameItemType.kCoin
		or self.ItemType == GameItemType.kBalloon
		or self.ItemType == GameItemType.kAddMove
		or self.ItemType == GameItemType.kAddTime
		or self.ItemType == GameItemType.kBlackCuteBall
		or self.ItemType == GameItemType.kRabbit
		or self.ItemType == GameItemType.kQuestionMark
		or self.ItemType == GameItemType.kRocket
		or self.ItemType == GameItemType.kCrystalStone
		or self.ItemType == GameItemType.kPuffer
		or self.ItemType == GameItemType.kMissile
		or self.ItemType == GameItemType.kBlocker195
		or self.ItemType == GameItemType.kChameleon
		or self.ItemType == GameItemType.kBuffBoom
		or self.ItemType == GameItemType.kBlocker207
		or self.ItemType == GameItemType.kScoreBuffBottle
		or self.ItemType == GameItemType.kFirecracker
		then
		return true
	end
	return false
end

function GameItemData:isBlockerCanBeCoverByBirdBrid()
	if self:hasBlocker206() or self:hasSquidLock() then return false end
	if self.ItemType == GameItemType.kSnow 
		or self.ItemType == GameItemType.kVenom
		or self.ItemType == GameItemType.kDigGround
		or self.ItemType == GameItemType.kDigJewel
		or self.ItemType == GameItemType.kRandomProp
		or self.ItemType == GameItemType.kWukong
		or self.ItemType == GameItemType.kBottleBlocker
		or self.ItemType == GameItemType.kRoost
		or self.bigMonsterFrostingType > 0 
		or self.chestSquarePartType > 0
		or self.ItemType == GameItemType.kMimosa
		or self.ItemType == GameItemType.kKindMimosa
		or self.beEffectByMimosa > 0
		or self.bossLevel > 0
		or self.weeklyBossLevel > 0
		or self.ItemType == GameItemType.kMagicLamp
		or self.ItemType == GameItemType.kWukong
		or self.ItemType == GameItemType.kHoneyBottle
		or self.ItemType == GameItemType.kMagicStone
		or self.ItemType == GameItemType.kOlympicBlocker
		or self.beEffectBySuperCute
		or self.blockerCoverLevel > 0
		or self.olympicLockLevel > 0
		or self.ItemType == GameItemType.kBlocker199
		or self.colorFilterBLock
		or self.ItemType == GameItemType.kPacman
        or self.ItemType == GameItemType.kTurret
		or self.ItemType == GameItemType.kMoleBossSeed
        or self.ItemType == GameItemType.kYellowDiamondGrass
		or self.moleBossCloudLevel > 0
		or self:isFreeGhost()
		or self.ItemType == GameItemType.kSunFlask
        or self.ItemType == GameItemType.kWanSheng
		then
		return true
	end

	return false
end

-- 对象可以被鸟鸟交换消除
function GameItemData:isItemCanBeEliminateByBirdBird()
	if (self.ItemType == GameItemType.kAnimal
		or self.ItemType == GameItemType.kGift
		or self.ItemType == GameItemType.kNewGift
		or self.ItemType == GameItemType.kCrystal
		or self.ItemType == GameItemType.kBalloon 
		or self.ItemType == GameItemType.kAddMove
		or self.ItemType == GameItemType.kAddTime
		or self.ItemType == GameItemType.kRocket
		or self.ItemType == GameItemType.kRabbit
		)
		and not self:hasLock() 
		and not self:hasFurball()
		and self:isAvailable()
		then
		return true
	end
	return false
end

function GameItemData:canBeEffectByHammer()
	if self:hasActiveSuperCuteBall() 
		or self.olympicLockLevel > 0 
		or self.blockerCoverLevel > 0 
		or self.colorFilterBLock 
		or self:isFreeGhost() 
		then
		return true
	end

	if self.ItemType == GameItemType.kNone 
		or self.ItemType == GameItemType.kIngredient
		or self.ItemType == GameItemType.kPoisonBottle
		or self.ItemType == GameItemType.kHedgehogBox
		or ( self.ItemType == GameItemType.kDrip and self.beEffectByMimosa == 0 )
		or ( self.bigMonsterFrostingType > 0 and self.bigMonsterFrostingStrength <= 0 )
		or (self.chestSquarePartType > 0 and self.chestSquarePartStrength <=0 )
		or self.isReverseSide
		or self.isSnail
		or self:isHedgehog()
		or self:isActiveTotems()
		or self.ItemType == GameItemType.kSuperBlocker 
		or (self.ItemType == GameItemType.kWukong 
			and (self.wukongState == TileWukongState.kReadyToJump or self.wukongState == TileWukongState.kOnActive) )
		or self.ItemType == GameItemType.kTangChicken
		or (self.ItemType == GameItemType.kBlocker195 and self.isActive and self.beEffectByMimosa == 0 and self.honeyLevel == 0)--小木槌不能敲星星瓶【满】
		or (self.ItemType == GameItemType.kChameleon and not self:hasLock())
		or self:hasBlocker206()
		or self.ItemType == GameItemType.kPacmansDen
		or self:isBlocker211Active()
		or self.ItemType == GameItemType.kSunflower
		or self:hasSquidLock()
		then
		return false
	end
	return true
end

function GameItemData:canBeEffectByLineEffectProp()
	if self.ItemType == GameItemType.kNone then
		return false
	end

	-- 覆盖类
	if self:hasBlocker206() or self.isReverseSide then
		return false
	end
	if self:hasActiveSuperCuteBall() 
		or self.blockerCoverLevel > 0 
		or self.colorFilterBLock 
		or self:isFreeGhost() 
		then
		return true
	end

	-- 锁类
	if self:hasFurball() 
		or self.cageLevel ~= 0 
		or self.lotusLevel > 1
		or self.honeyLevel ~= 0 
		or self.beEffectByMimosa == GameItemType.kKindMimosa 
		then
		return true
	end

	-- 其他
	if self:isVisibleAndFree() then
		if self.ItemType == GameItemType.kAnimal 
			or self.ItemType == GameItemType.kCrystal
			or self.ItemType == GameItemType.kBalloon
			or self.ItemType == GameItemType.kAddMove
			or self.ItemType == GameItemType.kAddTime
			or self.ItemType == GameItemType.kNewGift
			or self.ItemType == GameItemType.kVenom
			or self.ItemType == GameItemType.kCoin
			or self.ItemType == GameItemType.kBlocker207
			or self.snowLevel > 0
			or self.ItemType == GameItemType.kDigGround
			or self.ItemType == GameItemType.kDigJewel
			or self.ItemType == GameItemType.kBottleBlocker
			or self.ItemType == GameItemType.kBlocker199
			or self.ItemType == GameItemType.kRoost
			or self.bigMonsterFrostingType > 0 
			or self.ItemType == GameItemType.kHoneyBottle
			or self.ItemType == GameItemType.kMagicStone
			or self.ItemType == GameItemType.kSunFlask
			or self.ItemType == GameItemType.kMissile
			or self.ItemType == GameItemType.kMagicLamp
	        or self.ItemType == GameItemType.kTurret
	        or self.ItemType == GameItemType.kCrystalStone
	        or self.ItemType == GameItemType.kBlocker211
	        or self.ItemType == GameItemType.kKindMimosa
	        or self.ItemType == GameItemType.kPuffer
	        or self.ItemType == GameItemType.kBlackCuteBall
	        or self.ItemType == GameItemType.kScoreBuffBottle
	        or self.ItemType == GameItemType.kFirecracker
	        or self.ItemType == GameItemType.kRocket
            or self.ItemType == GameItemType.kWanSheng
			then
			return true
		end
	end

	return false
end

function GameItemData:isQuestionMarkcanBeDestroy()
	-- body
	if self.ItemType == GameItemType.kDrip then
		return false
	end
	if self:hasFurball() or self:hasLock() or not self:isAvailable() then
		--printx( 1 , "  ++++++  GameItemData:isQuestionMarkcanBeDestroy  +++++")
		--printx( 1 , "  self:hasFurball()")
		return false
	end
	return true
end

----从另一份数据，获取游戏物件信息---类似动物之类的信息---
function GameItemData:getAnimalLikeDataFrom(data)
	--!!!!!!!!
	self.isNeedUpdate = true
	--!!!!!!!!
	self.isEmpty = data.isEmpty
	self.ItemType = data.ItemType
	self.showType = data.showType
	self.ItemStatus = data.ItemStatus
	self._encrypt.ItemColorType = data._encrypt.ItemColorType
	self.ItemSpecialType = data.ItemSpecialType
	self.furballLevel = data.furballLevel
	self.furballType = data.furballType
	self.isBrownFurballUnstable = data.isBrownFurballUnstable
	self.itemSpeed = data.itemSpeed
	self.itemPosAdd = IntCoord:clone(data.itemPosAdd)
	self.bombRes = data.bombRes
	self.isItemLock = data.isItemLock
	self.lightUpBombMatchPosList = data.lightUpBombMatchPosList
	self.hasGivenScore = data.hasGivenScore
	self.balloonFrom = data.balloonFrom
	self.balloonConstantPlayAlert = data.balloonConstantPlayAlert
	self.isFromProductBalloon = data.isFromProductBalloon
	self.numAddMove = data.numAddMove
	self.digJewelLevel = data.digJewelLevel
	self.digGroundLevel = data.digGroundLevel
	self.isReverseSide = data.isReverseSide
	self.bigMonsterFrostingType = data.bigMonsterFrostingType
	self.bigMonsterFrostingStrength = data.bigMonsterFrostingStrength
	self.chestSquarePartType = data.chestSquarePartType
	self.chestSquarePartStrength = data.chestSquarePartStrength
	self.blackCuteMaxStrength = data.blackCuteMaxStrength
	self.blackCuteStrength = data.blackCuteStrength
	self.lastInjuredStep = data.lastInjuredStep
	self.bossLevel = data.bossLevel
	self.weeklyBossLevel = data.weeklyBossLevel
	self.blood = data.blood
	self.maxBlood= data.maxBlood
	self.moves = data.moves
	self.maxMoves = data.moves
	self.animal_num = data.animal_num
	self.drop_sapphire = data.drop_sapphire
	self.speicial_hit_blood = data.speicial_hit_blood
	self.rabbitState = data.rabbitState
	self.rabbitLevel = data.rabbitLevel
	self.lampLevel = data.lampLevel
	self.roostLevel = data.roostLevel
	self.roostCastCount = data.roostCastCount
	self.cageLevel = data.cageLevel
	self.snowLevel = data.snowLevel
	self.venomLevel = data.venomLevel
	self.forbiddenLevel = data.forbiddenLevel
	self.honeyBottleLevel = data.honeyBottleLevel
	self.honeyLevel = data.honeyLevel
	self.addTime = data.addTime
	self.isProductByBossDie = data.isProductByBossDie
	self.questionMarkProduct = data.questionMarkProduct
	-- 魔法石属性
	self.magicStoneLevel = data.magicStoneLevel
	self.magicStoneDir = data.magicStoneDir
	self.magicStoneActiveTimes = data.magicStoneActiveTimes
	self.magicStoneLocked = data.magicStoneLocked

	self.bottleLevel = data.bottleLevel
	self.bottleState = data.bottleState
	self.bottleActionRunningCount = data.bottleActionRunningCount

	self.crystalStoneEnergy = data.crystalStoneEnergy
	self.crystalStoneActive = data.crystalStoneActive
	self.crystalStoneBombType = data.crystalStoneBombType

	self.totemsState = data.totemsState

	self.wukongProgressCurr = data.wukongProgressCurr
	self.wukongProgressTotal = data.wukongProgressTotal
	self.wukongIsReadyToJump = data.wukongIsReadyToJump
	self.wukongState = data.wukongState

	self.wukongJumpPos = IntCoord:clone(data.wukongJumpPos)

	self.lotusLevel = data.lotusLevel
	self.beEffectBySuperCute = data.beEffectBySuperCute
	self.dripState = data.dripState
	self.dripLeaderPos = IntCoord:clone(data.dripLeaderPos)

	self.pufferState = data.pufferState
	self.dropProps = data.dropProps

	self.olympicBlockerLevel = data.olympicBlockerLevel
	self.olympicLockLevel = data.olympicLockLevel

	self.missileLevel = data.missileLevel
	self.randomPropType = data.randomPropType
	self.randomPropDropId = data.randomPropDropId
	self.randomPropLevel = data.randomPropLevel
	self.hitBySpringBomb = data.hitBySpringBomb
	self.key = data.key
	self.blockerCoverLevel = data.blockerCoverLevel
	self.ItemCheckColorType = data.ItemCheckColorType
	self.subtype = data.subtype
	self.level = data.level
	self.isActive = data.isActive
	self.flag = data.flag

	self.colorFilterBLock = data.colorFilterBLock
	self.hasActCollection = data.hasActCollection

	self.nextColour = data.nextColour
	self.nextSpecial = data.nextSpecial
	self.originColourAndSpecial = data.originColourAndSpecial
	self.lockLevel = data.lockLevel
	self.lockHead = data.lockHead

	self.needKeys = data.needKeys --配对锁的锁头数字
	self.lockBoxRopeRight = data.lockBoxRopeRight --是否显示配对锁的绳子
	self.lockBoxRopeLeft = data.lockBoxRopeLeft --是否显示配对锁的绳子
	self.lockBoxRopeDown = data.lockBoxRopeDown --是否显示配对锁的绳子
	self.lockBoxRopeUp = data.lockBoxRopeUp --是否显示配对锁的绳子
	self.lockBoxActive = data.lockBoxActive --配对锁是否为激活状态
	self.pacmanColour = data.pacmanColour
	self.pacmanDevourAmount = data.pacmanDevourAmount
	self.pacmanIsSuper = data.pacmanIsSuper
	self.pacmansDenPos = data.pacmansDenPos

    self.turretDir = data.turretDir
	self.turretIsTypeRandom = data.turretIsTypeRandom
	self.turretLevel = data.turretLevel
	self.turretIsSuper = data.turretIsSuper
	self.turretLocked = data.turretLocked

	self.moleBossSeedHP = data.moleBossSeedHP
	self.moleBossSeedCountDown = data.moleBossSeedCountDown
	self.moleBossCloudLevel = data.moleBossCloudLevel
    self.yellowDiamondLevel = data.yellowDiamondLevel

    self.coveredByGhost = data.coveredByGhost
    self.ghostPaceLength = data.ghostPaceLength

    self.blocker199Colors = data.blocker199Colors
    self.blocker199Dirs = data.blocker199Dirs

    self.blocker83Colors = data.blocker83Colors

    self.isToBlastScoreBuffBottles = data.isToBlastScoreBuffBottles
    self.sunFlaskLevel = data.sunFlaskLevel
    self.isToBlastFirecracker = data.isToBlastFirecracker

    self.squidDirection = data.squidDirection
    self.squidTargetType = data.squidTargetType
    self.squidTargetNeeded = data.squidTargetNeeded
    self.squidTargetCount = data.squidTargetCount
    self.needRemoveEventuallyBySquid = data.needRemoveEventuallyBySquid

    self.wanShengLevel = data.wanShengLevel
    self.wanShengConfig = data.wanShengConfig
end

function GameItemData:cleanAnimalLikeData()
	self.isNeedUpdate = true
	self.isEmpty = true
	self.ItemType = GameItemType.kNone
	self.ItemStatus = GameItemStatusType.kNone
	self._encrypt.ItemColorType = 0
	self.ItemSpecialType = 0
	self.furballLevel = 0
	self.furballType = GameItemFurballType.kNone
	self.isBrownFurballUnstable = false
	self.itemSpeed = 0
	self.itemPosAdd = IntCoord:create(0,0)
	self.bombRes = nil
	self.isItemLock = false
	self.isProduct = false
	self.lightUpBombMatchPosList = nil
	self.hasGivenScore = false
	self.balloonFrom = 0
	self.balloonConstantPlayAlert = false
	self.isFromProductBalloon = false
	self.numAddMove = 0
	self.digJewelLevel = 0
	self.digGroundLevel = 0
	self.isReverseSide = false
	self.bigMonsterFrostingType = 0    
	self.bigMonsterFrostingStrength = 0
	self.chestSquarePartType = 0
	self.chestSquarePartStrength = 0
	self.blackCuteMaxStrength = 0
	self.blackCuteStrength = 0
	self.lastInjuredStep = 0
	self.bossLevel = 0
	self.weeklyBossLevel = 0
	self.blood = 0
	self.maxBlood= 0
	self.moves = 0
	self.maxMoves = 0
	self.animal_num = 0
	self.drop_sapphire = 0
	self.speicial_hit_blood = 0
	self.rabbitState = 0
	self.rabbitLevel = 0
	self.lampLevel = 0
	self.roostLevel = 0
	self.roostCastCount = 0
	self.cageLevel = 0
	self.snowLevel = 0
	self.venomLevel = 0
	self.forbiddenLevel = 0
	self.honeyBottleLevel = 0
	self.honeyLevel = 0
	self.addTime = 0
	self.isProductByBossDie = false
	self.questionMarkProduct = 0
	self.digBlockCanbeDelete = true
	-- 魔法石属性
	self.magicStoneLevel = 0
	self.magicStoneDir = 0
	self.magicStoneActiveTimes = 0
	self.magicStoneLocked = false
	self.showType = 0
	self.bottleLevel = 0
	self.bottleState = BottleBlockerState.Waiting
	self.bottleActionRunningCount = 0
	self.crystalStoneEnergy = 0
	self.crystalStoneActive = false
	self.crystalStoneBombType = GameItemCrystalStoneBombType.kNone

	self.totemsState = GameItemTotemsState.kNone

	-- --刺猬
	-- self.hedgehogLevel = 0

	self.wukongProgressCurr = 0
	self.wukongProgressTotal = getBaseWukongChargingTotalValue()
	--self.wukongState = TileWukongState.kNormal
	self.wukongIsReadyToJump = false
	self.wukongJumpPos = IntCoord:create(0,0)

	self.lotusLevel = 0
	self.dripState = 0
	self.dripLeaderPos = IntCoord:create(0, 0)
	self.beEffectBySuperCute = false

	self.pufferState = 0
	self.isDead = false
	self.dropProps = nil

	self.olympicBlockerLevel = 0
	self.olympicLockLevel = 0

	self.missileLevel = 0
	self.randomPropType = 0
	self.randomPropDropId = 0
	self.randomPropLevel = 0
	self.hitBySpringBomb = false
	self.key = 0
	self.blockerCoverLevel = 0

	self.ItemCheckColorType = nil
	self.isCollectIngredient = nil
	self.subtype = 0
	self.level = 0
	self.isActive = false
	self.flag = false

	self.colorFilterBLock = false
	self.hasActCollection = false

	self.nextColour = nil
	self.nextSpecial = nil
	self.originColourAndSpecial = nil
	self.lockLevel = 0
	self.lockHead = false

	self.needKeys = 0 --配对锁的锁头数字
	self.lockBoxRopeRight = false --是否显示配对锁的绳子
	self.lockBoxRopeLeft = false --是否显示配对锁的绳子
	self.lockBoxRopeDown = false --是否显示配对锁的绳子
	self.lockBoxRopeUp = false --是否显示配对锁的绳子
	self.lockBoxActive = false
	self.pacmanColour = 1
	self.pacmanDevourAmount = 0
	self.pacmanIsSuper = nil
	self.pacmansDenPos = nil

    self.turretDir = 0
	self.turretIsTypeRandom = false
	self.turretLevel = 0
	self.turretIsSuper = false
	self.turretLocked = false

	self.moleBossSeedHP = 0
	self.moleBossSeedCountDown = 0
	self.moleBossCloudLevel = 0
    self.yellowDiamondLevel = 0
    self.yellowDiamondCanbeDelete = true

    self.coveredByGhost = false
    self.ghostPaceLength = 0

    self.blocker199Colors = nil
    self.blocker199Dirs = nil

    self.blocker83Colors = nil

    self.isToBlastScoreBuffBottles = false
    self.sunFlaskLevel = 0
    self.isToBlastFirecracker = false

    self.squidDirection = 0
    self.squidTargetType = 0
    self.squidTargetNeeded = -1
    self.squidTargetCount = 0
    self.needRemoveEventuallyBySquid = false

    self.wanShengLevel = 0
    self.wanShengConfig = nil
end

function GameItemData:isPermanentBlocker()
	local ret = false
	if self.ItemType == GameItemType.kRoost -- 鸡窝
		or self.ItemType == GameItemType.kMimosa -- 含羞草
		or self.ItemType == GameItemType.kKindMimosa  -- 新含羞草
		or self.ItemType == GameItemType.kSuperBlocker -- 无敌障碍
		or self.ItemType == GameItemType.kPoisonBottle -- 章鱼
		or self.ItemType == GameItemType.kPacmansDen
        or self.ItemType == GameItemType.kTurret
		then 
		ret = true
	end
	return ret
end

function GameItemData:checkBlock()--这个方法并不返回当前是不是isBlock，而是检测isBlock的值需不需要改变	
	local oldBlock = self.isBlock;
	self.isBlock = false;

	if self.snowLevel > 0 
		or self.cageLevel > 0
		or self.lotusLevel > 1
		or self.venomLevel > 0
		or self.olympicLockLevel > 0
		or self.ItemType == GameItemType.kRoost
		or self.digJewelLevel > 0 
		or self.digGroundLevel > 0
		or self.bottleLevel > 0
		or self.ItemType == GameItemType.kPoisonBottle
		or not self:isAvailable()
		or self.ItemType == GameItemType.kBigMonsterFrosting
		or self.ItemType == GameItemType.kBigMonster
		or self.ItemType == GameItemType.kChestSquarePart
		or self.ItemType == GameItemType.kChestSquare
		or self.ItemType == GameItemType.kMimosa
		or self.ItemType == GameItemType.kKindMimosa
		-- or self.ItemType == GameItemType.kRandomProp
		or self.randomPropLevel > 0
		or self.snailTarget 
		or self.colorFilterBLock 
		or self.wukongState == TileWukongState.kJumping
		or self.isSnail
		or self:isHedgehog()
		or self.ItemType == GameItemType.kBoss
		or self.ItemType == GameItemType.kWeeklyBoss
		or self.ItemType == GameItemType.kMoleBossCloud
		or self.ItemType == GameItemType.kMagicLamp 
		or self.ItemType == GameItemType.kWukong 
		or self.ItemType == GameItemType.kSuperBlocker
		or self.honeyLevel > 0
		or self.ItemType == GameItemType.kMagicStone
		or self.ItemType == GameItemType.kHedgehogBox
		or self.beEffectByMimosa == GameItemType.kKindMimosa
		or self.ItemType == GameItemType.kOlympicBlocker
		or (self.ItemType == GameItemType.kTotems and self.totemsState ~= GameItemTotemsState.kNone)
		or (self.dripState ~= 0 and self.dripState ~= DripState.kNormal)
		or (self.pufferState == PufferState.kGrow or self.pufferState == PufferState.kExplode )
		or self.blockerCoverLevel > 0
		or self:hasActiveSuperCuteBall()
		or self.ItemType == GameItemType.kTangChicken
		or self.ItemType == GameItemType.kBlocker199
		or self:hasBlocker206()
		or (self.ItemType == GameItemType.kBuffBoom and self.flag)
		or self.ItemType == GameItemType.kPacman
		or self.ItemType == GameItemType.kPacmansDen
        or self.yellowDiamondLevel > 0
		or self:isBlocker211()
        or self.ItemType == GameItemType.kTurret
        or self:seizedByGhost()
        or self.ItemType == GameItemType.kSunFlask
        or self.ItemType == GameItemType.kSunflower
        or (self.ItemType == GameItemType.kChameleon and (self.nextColour or self.nextSpecial))
        or self.ItemType == GameItemType.kSquid
        or self.ItemType == GameItemType.kSquidEmpty
        or self:hasSquidLock()
		then 
		self.isBlock = true 
		self.isUsed = true 
	end

	if self.isBlock == false then  ----雪块 毒液 挖地地块 挖地宝石块 不再是block
		if self.ItemType == GameItemType.kSnow
			or self.ItemType == GameItemType.kVenom
			or self.ItemType == GameItemType.kBottleBlocker
		then
			self.ItemType = GameItemType.kNone
			self:AddItemStatus( GameItemStatusType.kNone , true )
			self._encrypt.ItemColorType = 0
			self.isEmpty = true 
		end
	end

		-- if needDebug and self.x == 8 and self.y == 8 then
		-- 	if _G.isLocalDevelopMode then printx(0, "self.snowLevel",self.snowLevel) end
		-- 	if _G.isLocalDevelopMode then printx(0, "self.cageLevel",self.cageLevel) end
		-- 	if _G.isLocalDevelopMode then printx(0, "self.lotusLevel",self.lotusLevel) end
		-- 	if _G.isLocalDevelopMode then printx(0, "self.venomLevel",self.venomLevel) end
		-- 	if _G.isLocalDevelopMode then printx(0, "self.olympicLockLevel",self.olympicLockLevel) end
		-- 	if _G.isLocalDevelopMode then printx(0, "self.ItemType",self.ItemType) end
		-- 	if _G.isLocalDevelopMode then printx(0, "self.digJewelLevel",self.digJewelLevel) end
		-- 	if _G.isLocalDevelopMode then printx(0, "self.digGroundLevel",self.digGroundLevel) end
		-- 	if _G.isLocalDevelopMode then printx(0, "self.bottleLevel",self.bottleLevel) end
		-- 	if _G.isLocalDevelopMode then printx(0, "self.isAvailable",self:isAvailable()) end
		-- 	if _G.isLocalDevelopMode then printx(0, "self.randomPropLevel",self.randomPropLevel) end
		-- 	if _G.isLocalDevelopMode then printx(0, "self.snailTarget",self.snailTarget) end
		-- 	if _G.isLocalDevelopMode then printx(0, "self.isSnail",self.isSnail) end
		-- 	if _G.isLocalDevelopMode then printx(0, "self.isHedgehog",self:isHedgehog()) end
		-- 	if _G.isLocalDevelopMode then printx(0, "self.honeyLevel",self.honeyLevel) end
		-- 	if _G.isLocalDevelopMode then printx(0, "self.beEffectByMimosa",self.beEffectByMimosa) end
		-- 	if _G.isLocalDevelopMode then printx(0, "self.dripState",self.dripState) end
		-- 	if _G.isLocalDevelopMode then printx(0, "self.pufferState",self.pufferState) end
		-- 	if _G.isLocalDevelopMode then printx(0, "self.hasActiveSuperCuteBall",self:hasActiveSuperCuteBall()) end

		-- 	if _G.isLocalDevelopMode then printx(0, "eeeeeeeeeeeeeeeeeendddddddddddddddd",self.isBlock) end
		-- 	debug.debug()

		-- end

	if oldBlock ~= self.isBlock then
		return true; ----数据变化
	end
	return false;
end

----可以被计入连击数量
function GameItemData:canBeComboNum()
	if self.ItemType == GameItemType.kAnimal then						----小动物
		if self.ItemSpecialType == 0 then
			return true;
		end
	end
	return false;
end

function GameItemData:canBeComboNumCrystal()
	if self.oldItemType == GameItemType.kCrystal 
		or self.ItemType == GameItemType.kCrystal then
		return true
	end
	return false
end

function GameItemData:canBeComboNumBalloon( ... )
	-- body
	if  self.ItemType == GameItemType.kBalloon then 
		if self.ItemSpecialType == 0 then
			return true;
		end
	end
	return false
end

function GameItemData:canBeComboNumRabbit()
	if self.ItemType == GameItemType.kRabbit then
		return true
	end
	return false
end

function GameItemData:canBeComboNumRocket()
	if self.ItemType == GameItemType.kRocket then
		return true
	end
	return false
end

function GameItemData:canBeComboTotems()
	if self.ItemType == GameItemType.kTotems then
		return true
	end
	return false
end

------初始化的时候变成豆荚
function GameItemData:canBeChangeToIngredient()
	if self.ItemType == GameItemType.kAnimal then
		if self.ItemSpecialType == 0 then
			--if _G.isLocalDevelopMode then printx(0, "canBeComboNum true") end
			return true;
		end
	end
end

function GameItemData:canBeEffectByUFO()
	if self.ItemType == GameItemType.kIngredient or 
	   self.ItemType == GameItemType.kRabbit then
		return true
	else
		return false
	end
end

function GameItemData:changeRabbitState(state)
	self.rabbitState = state
end

function GameItemData:hasFurball()
	return self.furballLevel > 0
end

function GameItemData:hasAnyFurball()
	return self.furballLevel > 0 or self.ItemType == GameItemType.kBlackCuteBall or self.beEffectBySuperCute
end

function GameItemData:hasActiveSuperCuteBall()
	return self.beEffectBySuperCute
end

function GameItemData:addFurball(furballType)
	self.furballLevel = 1
	self.furballType = furballType
end

function GameItemData:removeFurball()
	self.furballLevel = 0
	self.furballType = GameItemFurballType.kNone
	self.isBrownFurballUnstable = false
end

function GameItemData:hasLock()
	local result = false
	if self.cageLevel ~= 0 
		or self.lotusLevel > 1
		or self.honeyLevel ~= 0 
		or self.olympicLockLevel > 0
		or self.blockerCoverLevel > 0
		or self:hasBlocker206()
		or self.beEffectByMimosa == GameItemType.kKindMimosa 
		or self:hasSquidLock()
		then
		result = true
	end
	return result
end

--是否参与match， falling
--item被翻转或者置灰
function GameItemData:isAvailable()
	-- body
	if self.isReverseSide 
		or self:hasActiveSuperCuteBall()
		or self.blockerCoverLevel > 0
		or self.beEffectByMimosa == GameItemType.kMimosa 
		or self.colorFilterBLock
		or self:hasBlocker206()
		or self:seizedByGhost()
		or self:hasSquidLock()
		then
		return false
	end
	return true
end

function GameItemData:seizedByGhost()
	return self.coveredByGhost
end

-- 是可移动的自由幽灵（没被其他障碍束缚）
function GameItemData:isFreeGhost()
	local flag = self.coveredByGhost and self:isTopCover(GameItemDataTopCoverName.k_Ghost)
	return flag
end

-- 覆盖类中，指定类型为最外层的覆盖状态
GameItemDataTopCoverName = {
	k_Padlock = "typePadlock",
	k_TileBlocker = "typeTileBlocker", 
	k_SuperFurball = "typeSuperFurball", 
	k_ColourFilter = "typeColourFilter", 
	k_Leafpile = "typeLeafpile", 
	k_Ghost = "typeGhost"
}
function GameItemData:isTopCover(typeName)
	-- 层级由上到下，上层可覆盖下层
	if self:hasBlocker206() then 	-- 1层：挂锁
		if typeName == GameItemDataTopCoverName.k_Padlock then return true else return false end
	else
		if self.isReverseSide or self:hasActiveSuperCuteBall() then 	-- 2层：单面翻板，白毛球
			if self.isReverseSide and typeName == GameItemDataTopCoverName.k_TileBlocker then return true else return false end
			if self:hasActiveSuperCuteBall() and typeName == GameItemDataTopCoverName.k_SuperFurball then return true else return false end
		else
			if self.colorFilterBLock or self.blockerCoverLevel > 0 then 	-- 3层：过滤器，小叶堆（其实白毛球也与此层互斥）
				if self.colorFilterBLock and typeName == GameItemDataTopCoverName.k_ColourFilter then return true else return false end
				if self.blockerCoverLevel > 0 and typeName == GameItemDataTopCoverName.k_Leafpile then return true else return false end
			else
				if self:seizedByGhost() then 	-- 4层：幽灵
					if typeName == GameItemDataTopCoverName.k_Ghost then return true else return false end
				end
			end
		end
	end
	return false
end

function GameItemData:setColorFilterBLock(isLock)
	self.colorFilterBLock = isLock
end

function GameItemData:setHasActCollection(hasCollection)
	self.hasActCollection = hasCollection
end

--是否是有颜色可参与匹配的物体类型
function GameItemData:isColorful()
	if self.ItemType == GameItemType.kAnimal
		or self.ItemType == GameItemType.kCrystal
		or self.ItemType == GameItemType.kGift
		or self.ItemType == GameItemType.kNewGift
		or self.ItemType == GameItemType.kBalloon
		or self.ItemType == GameItemType.kAddMove
		or self.ItemType == GameItemType.kAddTime
		or self.ItemType == GameItemType.kRabbit
		or self.ItemType == GameItemType.kMagicLamp
		or self.ItemType == GameItemType.kWukong
		or (self.ItemType == GameItemType.kDrip and self.dripState == DripState.kNormal)
		or self.ItemType == GameItemType.kQuestionMark
		or (self.ItemType == GameItemType.kBottleBlocker and self.bottleActionRunningCount <= 0) 
		or self.ItemType == GameItemType.kRocket
		or (self.ItemType == GameItemType.kTotems and self.totemsState == GameItemTotemsState.kNone)
		or self:isBlocker199Active()
		or (self.ItemType == GameItemType.kScoreBuffBottle and not self.isToBlastScoreBuffBottles)
		or (self.ItemType == GameItemType.kFirecracker and not self.isToBlastFirecracker)
		then
		return true
	end
	return false
end

-- 是否可以交换移动
function GameItemData:canBeSwap()
	if self:isFreeGhost() then return true end 		--幽灵覆盖时可被移动

	if self.isUsed
		and (not self.isBlock or self.ItemType == GameItemType.kMagicLamp 
			or (self.ItemType == GameItemType.kWukong and self.wukongState ~= TileWukongState.kReadyToJump) 
			or self:isBlocker199Active()
			or self.ItemType == GameItemType.kPacman)
		and not self.isEmpty
		and not self:hasFurball()
		and not self:hasLock()
		and self:isAvailable()
		and self.ItemType ~= GameItemType.kBlackCuteBall
		and self.ItemStatus == GameItemStatusType.kNone --稳定状态的东西，才能移动
		and self.totemsState == GameItemTotemsState.kNone -- 不是激活的小金刚
		then
		return true
	end
	return false
end

--鸡窝升级
function GameItemData:roostUpgrade()
	if self.ItemType == GameItemType.kRoost then
		if self.roostLevel < 4 and self.roostCastCount < 8 then
			self.roostLevel = self.roostLevel + 1
		end
	end
end

function GameItemData:roostReset()
	if self.ItemType == GameItemType.kRoost then
		if self.roostLevel == 4 then
			self.roostLevel = 1
		end
	end
end

function GameItemData:initMaydayBoss(level)
	self.ItemType = GameItemType.kBoss 
	self.bossLevel = level
	self.isBlock = true 
	self.isEmpty = false 
	self.maxBlood = BossConfig[level].blood 
	self.blood = self.maxBlood
	self.moves = BossConfig[level].moves
	self.maxMoves = self.moves
	self.animal_num = BossConfig[level].animal_num
	self.drop_sapphire = BossConfig[level].drop_sapphire
	self.speicial_hit_blood = BossConfig[level].specialHitBlood
	self.hitCounter = 0
end

function GameItemData:initWeeklyBoss()
	self.ItemType = GameItemType.kWeeklyBoss 
	self.weeklyBossLevel = 1 --这个写死即可 用以区分占位格子
	self.isBlock = true 
	self.isEmpty = false 
	self.maxBlood = WeeklyBossConfig.blood 
	self.blood = self.maxBlood
	self.moves = WeeklyBossConfig.moves
	self.maxMoves = self.moves
	self.animal_num = WeeklyBossConfig.animal_num
	self.drop_sapphire = WeeklyBossConfig.drop_sapphire
	self.speicial_hit_blood = WeeklyBossConfig.specialHitBlood
	self.hitCounter = 0
end

function GameItemData:canInfectByHoneyBottle( ... )--是否能被蜂蜜瓶子破裂后飞出的蜂蜜包裹
	if not self:isAvailable() or self:hasLock() then return false end
	if self:hasFurball() then return false end

	if self.ItemType == GameItemType.kAnimal and self.ItemSpecialType ~= AnimalTypeConfig.kColor 
		or self.ItemType == GameItemType.kCrystal
		or self.ItemType == GameItemType.kMagicLamp
		or self.ItemType == GameItemType.kWukong
		or self.ItemType == GameItemType.kRocket
		or self.ItemType == GameItemType.kCrystalStone
		or self.ItemType == GameItemType.kQuestionMark 
		or self.ItemType == GameItemType.kNewGift 
		or self.ItemType == GameItemType.kGift 
		or (self.ItemType == GameItemType.kPuffer and (self.pufferState == PufferState.kNormal or self.pufferState == PufferState.kActivated) )
		or (self.ItemType == GameItemType.kTotems and self.totemsState == GameItemTotemsState.kNone) 
		-- or self.ItemType == GameItemType.kBlocker195    --http://jira.happyelements.net/browse/MA-20253  【障碍兼容】蜂蜜不糊星星瓶
		or self:isBlocker199Active()
		or self.ItemType == GameItemType.kChameleon
		or self.ItemType == GameItemType.kBlocker207
		or self.ItemType == GameItemType.kPacman
		or self.ItemType == GameItemType.kScoreBuffBottle
		or self.ItemType == GameItemType.kFirecracker
		then
		return true
	end
	return false
end

function GameItemData:canInfectByWanSheng( ... )--是否能被万生破裂后飞出的障碍替换
    if self.isEmpty then return false end
	if not self:isAvailable() or self:hasLock() then return false end
	if self:hasFurball() then return false end

	if self.ItemType == GameItemType.kAnimal --是小动物
        and self.lotusLevel == 0 --荷塘
        then
		return true
	end
	return false
end

--是否能被春节技能1打中
function GameItemData:canInfectBySpringFestivalSkill1( ... )
	if not self:isAvailable() or self:hasLock() then return false end
	if self:hasFurball() then return false end

	if self.ItemType == GameItemType.kAnimal 
        and self.ItemSpecialType ~= AnimalTypeConfig.kColor
        and self.ItemSpecialType ~= AnimalTypeConfig.kLine 
        and self.ItemSpecialType ~= AnimalTypeConfig.kColumn 
        and self.ItemSpecialType ~= AnimalTypeConfig.kWrap 
        then
        --是小动物  无特效
		return true
    elseif self.ItemType == GameItemType.kCrystal then
        --水晶球
        return true
    end

	return false
end

--是否能被春节技能1打中
function GameItemData:canInfectBySpringFestivalSkill4( ... )
    return self:canBecomeSpecialBySwapColorSpecial()
end

function GameItemData:changToSpecial( changeItem, changeColor )
	-- body
	self.ItemType = GameItemType.kAnimal
	self.ItemSpecialType = AnimalTypeConfig.getSpecial(changeItem)
	if self.ItemSpecialType == AnimalTypeConfig.kColor then 
		self._encrypt.ItemColorType = 0
	else
		self._encrypt.ItemColorType = changeColor
	end
end

function GameItemData:changeToHedgehogBox( )
	-- body
	self:cleanAnimalLikeData()
	self.isEmpty = false
	self.ItemType = GameItemType.kHedgehogBox
	self.isBlock = true
end

function GameItemData:changToFallingItems( changeItem,changeColor, addMoveBase )
	-- body
	local tile = changeItem + 1
	if tile == TileConst.kGreyCute then self.ItemType = GameItemType.kAnimal self.furballLevel = 1 self.furballType = GameItemFurballType.kGrey self._encrypt.ItemColorType = changeColor
	elseif tile == TileConst.kBrownCute then self.ItemType = GameItemType.kAnimal self.furballLevel = 1 self.furballType = GameItemFurballType.kBrown self._encrypt.ItemColorType = changeColor
	elseif tile == TileConst.kBlackCute then self.ItemType = GameItemType.kBlackCuteBall self.isEmpty = false self.blackCuteStrength = 2 self._encrypt.ItemColorType = 0 self.blackCuteMaxStrength = self.blackCuteStrength
	elseif tile == TileConst.kCoin then self.ItemType = GameItemType.kCoin self._encrypt.ItemColorType = 0
	elseif tile == TileConst.kCrystal then self.ItemType = GameItemType.kCrystal self._encrypt.ItemColorType = changeColor
	elseif tile == TileConst.kAddMove then self.ItemType = GameItemType.kAddMove self.numAddMove = addMoveBase self._encrypt.ItemColorType = changeColor
	end
end

function GameItemData:changToCannotFallingItems( changeItem )
	-- body
	self._encrypt.ItemColorType = 0
	local tile = changeItem + 1
	if tile == TileConst.kPoison then self.ItemType = GameItemType.kVenom  self.venomLevel = 1 
	elseif tile == TileConst.kPoisonBottle then self.ItemType = GameItemType.kPoisonBottle self.forbiddenLevel = 0
	elseif tile == TileConst.kDigJewel_1_blue then self.digJewelLevel = 1 self.ItemType = GameItemType.kDigJewel 
	elseif tile == TileConst.kDigJewel_2_blue then self.digJewelLevel = 2 self.ItemType = GameItemType.kDigJewel
	elseif tile == TileConst.kDigJewel_3_blue then self.digJewelLevel = 3 self.ItemType = GameItemType.kDigJewel
    elseif tile == TileConst.kYellowDiamondGrass1 then self.yellowDiamondLevel = 1 
    elseif tile == TileConst.kYellowDiamondGrass2 then self.yellowDiamondLevel = 2
	end
end

function GameItemData:changeItemFromQuestionMark( changeType, changeItem, changeColor, addMoveBase)
	-- body
	if changeType == UncertainCfgConst.kCanFalling then
		self:changToFallingItems(changeItem, changeColor, addMoveBase)
	elseif changeType == UncertainCfgConst.kCannotFalling then
		self:changToCannotFallingItems(changeItem)
	elseif changeType == UncertainCfgConst.kSpecial then
		self:changToSpecial(changeItem, changeColor)
	elseif changeType == UncertainCfgConst.kProps then
		self.ItemType = GameItemType.kAnimal
	end
end

function GameItemData:canMagicStoneBeActive()
	if self:hasBlocker206() or self:hasSquidLock() then return false end
	if self.ItemType ~= GameItemType.kMagicStone then return false end
	return not self.magicStoneLocked and self.magicStoneActiveTimes < 3
end

function GameItemData:initUnlockAreaDropDownModeInfo( ... )
	-- body
	if self.ItemType == GameItemType.kIngredient then
		self.showType = IngredientShowType.kAcorn
	end
end

function GameItemData:isSpecial()
	return table.includes(AnimalTypeConfig.specialTypeList,self.ItemSpecialType) and not self:hasBlocker206() and not self:hasSquidLock()
end

------- 以下已转移至 CommonMultipleHittingPriorityLogic
-- -- 导弹优先级
-- function GameItemData:isMissileTargetPrior1( ... )
-- 	if self.isReverseSide then return false end

-- 	if not self.colorFilterBLock 
-- 		and (self.cageLevel > 0
-- 				or self.venomLevel > 0
-- 				or self.ItemType == GameItemType.kPoison
-- 				or self.ItemType == GameItemType.kBalloon
-- 				or (self.bigMonsterFrostingStrength and self.bigMonsterFrostingStrength > 0)
-- 				or (self.chestSquarePartStrength and self.chestSquarePartStrength > 0))
-- 				or self.ItemType == GameItemType.kMoleBossSeed
-- 				or (self:isFreeGhost() and GhostLogic:ghostCanMoveUpward(self))
-- 		then
-- 		return true
-- 	end
-- 	return false
-- end

-- function GameItemData:isMissileTargetPrior2( ...)
-- 	if self.isReverseSide then return false end

-- 	if  self.snowLevel > 0 
-- 		or self.ItemType == GameItemType.kHoneyBottle
-- 		or self.furballType == GameItemFurballType.kBrown
-- 		or self.ItemType == GameItemType.kRocket 
-- 		or (self.ItemType == GameItemType.kPuffer and self.pufferState == PufferState.kNormal)
-- 		or self.ItemType == GameItemType.kBottleBlocker
-- 		or self.digGroundLevel > 0
-- 		or self.digJewelLevel > 0
-- 		or self.blockerCoverLevel > 0
-- 		or (self.ItemType == GameItemType.kBlocker199 and not self:isBlocker199Active()) 
-- 		or self.ItemType == GameItemType.kBlocker207
-- 		or self.ItemType == GameItemType.kMoleBossCloud
--         or self.yellowDiamondLevel > 0
-- 		then
-- 		return true
-- 	end

-- 	return false
-- end
-- function GameItemData:isMissileTargetPrior3( ... )
-- if self.isReverseSide then return false end

-- 	if self.ItemType == GameItemType.kCoin
-- 		or self.furballType == GameItemFurballType.kGrey
-- 		or self.ItemType == GameItemType.kBlackCuteBall
-- 		or self.honeyLevel > 0
-- 		then
-- 		return true
-- 	end
-- 	return false
-- end
-- function GameItemData:isMissileTargetPrior4( ... )
-- if self.isReverseSide then return false end

-- 	if (self.ItemType == GameItemType.kCrystalStone and (not self.crystalStoneActive))
-- 		or self.ItemType == GameItemType.kMagicStone
-- 		or self.ItemType == GameItemType.kRoost
-- 		or self.ItemType == GameItemType.kMagicLamp
-- 		or self.ItemType == GameItemType.kKindMimosa
-- 		or self.beEffectBySuperCute == true
-- 		or self:isBlocker199Active()
-- 		or self:canDoBlocker211Collect(nil, true)
--         or self.ItemType == GameItemType.kTurret
-- 		then
-- 		return true
-- 	end
-- 	return false
-- end
-- function GameItemData:isMissileTargetPrior5( ... )
-- if self.isReverseSide then return false end

-- 	if (self.ItemType == GameItemType.kAnimal and not self:isSpecial())
-- 		or self.ItemType == GameItemType.kCrystal
-- 		or (self.ItemType == GameItemType.kMissile and self.missileLevel > 0)
-- 		or (self.ItemType == GameItemType.kBuffBoom and self.level > 0)
-- 		or self.ItemType == GameItemType.kScoreBuffBottle
-- 		then
-- 		return true
-- 	end
-- 	return false
-- end
-- function GameItemData:isMissileTargetPrior6( ... )
-- if self.isReverseSide then return false end

-- 	if self.ItemType == GameItemType.kNewGift
-- 		or (self.pufferState == PufferState.kActivated and self.ItemType == GameItemType.kPuffer)
-- 		or (self.ItemType == GameItemType.kAnimal and self:isSpecial())
-- 		then
-- 		return true
-- 	end
-- 	return false
-- end

-- function GameItemData:isMissileTargetInvalid()
-- 	if self.isReverseSide then return false end

-- 	--有牢笼等的情况下走牢笼优先级
--     if not self:hasLock() and not self:isFreeGhost() then
--     	if self.ItemType == GameItemType.kChameleon 
--     		or self.ItemType == GameItemType.kPacman
--     		then
--     		return true
--     	end
--     end

-- 	if  self.ItemType == GameItemType.kTotems
-- 		or self.ItemType == GameItemType.kPoisonBottle
-- 		or self.beEffectByMimosa > 0 
-- 		or self:hasBlocker206()
-- 		or self.ItemType == GameItemType.kPacmansDen
-- 		then
-- 		return true
-- 	end
-- 	return false
-- end 

function GameItemData:isBigMonsterEffectPrior1( ... )
	-- body
	if not (self:isAvailable() or self:isFreeGhost()) then return false end

	if 	self.honeyLevel > 0 
		or self.snowLevel > 0
		or self.ItemType == GameItemType.kBottleBlocker
		or (self.ItemType == GameItemType.kBlocker199 and not self:isBlocker199Active()) 
		or self.ItemType == GameItemType.kBlocker207
		or (self:isFreeGhost() and GhostLogic:ghostCanMoveUpward(self))
		or self.ItemType == GameItemType.kSunFlask
        or self.ItemType == GameItemType.kWanSheng
		then
		return true
	else
		return false
	end
end

function GameItemData:isBigMonsterEffectPrior2( ... )
	-- body
	if not self:isAvailable() then return false end

	if self.venomLevel > 0 
		or self.ItemType == GameItemType.kCoin
		or self:hasFurball()
		or self.ItemType == GameItemType.kBlackCuteBall
		or self.cageLevel > 0 
		or self.ItemType == GameItemType.kDigGround
		or self.mimosaLevel > 0 
		or self.blockerCoverLevel > 0 
		or self.ItemType == GameItemType.kMimosa
		or self.ItemType == GameItemType.kKindMimosa
		or self.ItemType == GameItemType.kHoneyBottle
		or self.ItemType == GameItemType.kMagicLamp
		or self.ItemType == GameItemType.kWukong
		or self.ItemType == GameItemType.kRoost
		or self.ItemType == GameItemType.kMagicStone
		or self.ItemType == GameItemType.kMissile
		or self.ItemType == GameItemType.kBuffBoom
		or self:isBlocker199Active()
        or self.ItemType == GameItemType.kTurret
		or self.ItemType == GameItemType.kMoleBossSeed
		then
		return true
	else
		return false
	end
end

function GameItemData:isBigMonsterEffectPrior3( ... )
	-- body
	if not self:isAvailable()  then
			return false
	end

	if self.ItemType == GameItemType.kAnimal 
		or self.ItemType == GameItemType.kRocket -- ?
		or self.ItemType == GameItemType.kCrystalStone -- ?
		or self.ItemType == GameItemType.kTotems -- ?
		or self:canDoBlocker211Collect(nil, true)
		or (self.bigMonsterFrostingStrength and self.bigMonsterFrostingStrength > 0)
		or self.ItemType == GameItemType.kScoreBuffBottle
		or self.ItemType == GameItemType.kFirecracker
		then
		return true
	end

	return false
end

function GameItemData:isActiveTotems()
	return self.totemsState == GameItemTotemsState.kActive
end

function GameItemData:getColorIndex()
	return AnimalTypeConfig.convertColorTypeToIndex(self._encrypt.ItemColorType)
end

---------------------------------------------------
--水晶石
---------------------------------------------------
function GameItemData:canCrystalStoneBeCharged()
	if self.ItemType == GameItemType.kCrystalStone
		and not self.crystalStoneActive
		and self:isAvailable()
		and self.honeyLevel <= 0
		and not self:hasLock() then
		return true
	end
	return false
end

function GameItemData:isActiveCrystalStoneAvailble()
	if self:isCrystalStoneActive() then
		if self.isEmpty == true or not self:isAvailable() 
				or self:hasLock() or self.honeyLevel > 0 then
			return false
		else
			return true
		end
	end
	return false
end

function GameItemData:isCrystalStoneActive()
	return self.crystalStoneActive
end

function GameItemData:setCrystalStoneActive(active)
	self.crystalStoneActive = active
end

function GameItemData:chargeCrystalStoneEnergy(addEnergy)
	if addEnergy and addEnergy ~= 0 then
		local oldEnergy = self:getCrystalStoneEnergy()
		self:setCrystalStoneEnergy(oldEnergy + addEnergy)
	end
end

function GameItemData:getCrystalStoneEnergy()
	return self.crystalStoneEnergy or 0
	-- return decryptionFunc(self, "crystalStoneEnergy")
end

function GameItemData:setCrystalStoneEnergy(energy)
	self.crystalStoneEnergy = energy
	-- encryptionFunc(self, "crystalStoneEnergy", energy)
end

function GameItemData:canChargeCrystalStone()
	if (self.ItemType == GameItemType.kAnimal and self.ItemSpecialType ~= AnimalTypeConfig.kColor)
		or self.ItemType == GameItemType.kCrystal
		or self.ItemType == GameItemType.kAddMove
		or self.ItemType == GameItemType.kAddTime
		or self.ItemType == GameItemType.kNewGift
		or self.ItemType == GameItemType.kScoreBuffBottle
		or self.ItemType == GameItemType.kFirecracker
		then
		return true
	end
	return false
end

function GameItemData:canBeCoverByCrystalStone()
	if self.isEmpty == true or not self:isAvailable() 
		or self:hasLock() or self:hasFurball() then
		return false
	end

	if (self.ItemType == GameItemType.kAnimal and self.ItemSpecialType ~= AnimalTypeConfig.kColor)
		or self.ItemType == GameItemType.kCrystal
		or self.ItemType == GameItemType.kAddMove
		or self.ItemType == GameItemType.kAddTime
		or self.ItemType == GameItemType.kNewGift
		or self.ItemType == GameItemType.kGift
		or self.ItemType == GameItemType.kScoreBuffBottle
		or self.ItemType == GameItemType.kFirecracker
		then
		return true
	end
	return false
end

-- 能被特效覆盖
function GameItemData:canBeSpecialCoverByCrystalStone()
	if self.isEmpty == true or not self:isAvailable() 
		or self:hasLock() or self:hasFurball() then
		return false
	end

	if (self.ItemType == GameItemType.kAnimal and self.ItemSpecialType ~= AnimalTypeConfig.kColor)
		or self.ItemType == GameItemType.kCrystal
		then
		return true
	end
	return false
end

---------------------------------------------------
--星星瓶
---------------------------------------------------
function GameItemData:candoBlocker195Collect(collectType, ignoreType)--星星瓶是否可以进行收集
	if self.ItemType == GameItemType.kBlocker195
		and not self.isActive
		and self.honeyLevel <= 0
		and self:isAvailable()
		and self.beEffectByMimosa ~= GameItemType.kKindMimosa
		then
		
		if collectType == self.subtype or ignoreType then
			return true
		end
	end
	return false
end

function GameItemData:isBlocker195Available()--星星瓶【满】是可以交换的
	if self.ItemType == GameItemType.kBlocker195
		and self.isActive
		and self.honeyLevel <= 0
		and self:isAvailable()
		then
		return true
	end
	return false
end
---------------------------------------------------
--199
---------------------------------------------------
-- 水母形态
function GameItemData:isBlocker199Active()
	if self.ItemType == GameItemType.kBlocker199 
		and self.isActive
		then
		return true
	end
end

function GameItemData:hasBlocker206()
	return self.lockLevel > 0
end

function GameItemData:isBlocker211()
	return self.ItemType == GameItemType.kBlocker211
end

function GameItemData:isBlocker211Active()
	if self.ItemType == GameItemType.kBlocker211 
		and self.isActive 
		and self.honeyLevel <= 0
		and self:isAvailable()
		and self.beEffectByMimosa ~= GameItemType.kKindMimosa
		then
		return true
	end
	return false
end

function GameItemData:canDoBlocker211Collect(itemColorType, ingoreColor)
	if self.ItemType == GameItemType.kBlocker211 
		and (ingoreColor or self._encrypt.ItemColorType == itemColorType) 
		and not self.flag
		and not self.isActive
		and self.honeyLevel <= 0
		and self:isAvailable()
		and self.beEffectByMimosa ~= GameItemType.kKindMimosa 
		then
		return true
	end
	return false
end

----------- 变色龙 ------------
function GameItemData:chameleonFreeToTransform()
	if not self.nextColour and not self.nextSpecial then
		return true
	end
	return false
end

function GameItemData:changeToBuffBoom()
	self:cleanAnimalLikeData()
	self.ItemType = GameItemType.kBuffBoom
	self.level = 3
	self.isEmpty = false
	self.isBlock = false
end

function GameItemData:mimosaHasGrowup()
	return self.mimosaLevel > GamePlayConfig_Mimosa_Grow_Step
end

------------------- 鱿鱼大招的锁 -----------------------
-- 由于可能被多条线路上的鱿鱼锁住，所以需要计数
function GameItemData:addSquidLockValue()
	if not self.squidLockVal then
		self.squidLockVal = 0
	end
	self.squidLockVal = self.squidLockVal + 1
end

function GameItemData:reduceSquidLockValue()
	if self.squidLockVal then
		self.squidLockVal = math.max(0, self.squidLockVal - 1)
	end
end

-- 虽然按理说动画结束应该都会被清为0，但是还是再加个彻底清除的方法吧
function GameItemData:cleanSquidLock()
	if self.squidLockVal then
		self.squidLockVal = nil
	end
end

function GameItemData:hasSquidLock()
	if self.squidLockVal and self.squidLockVal > 0 then
		return true
	end
	return false
end
