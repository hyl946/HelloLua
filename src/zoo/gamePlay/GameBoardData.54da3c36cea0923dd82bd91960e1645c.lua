require "zoo.config.TileMetaData"
require "zoo.config.TileConfig"

require "zoo.gamePlay.GamePlayConfig"

GameBoardData = class()

gCopyDataMode = {
	
	kNormal = 0 ,
	kDoubleSideBlockerTurn = 1 ,	
}

-- GameBoardDataConfig = {
-- 	magicTileMaxLife = 4,
-- }

TileRoadType = table.const{
	kLine = 1,
	kCorner = 2,
	kStartPoint = 3, 
	kEndPoint = 4,
}

TileRoadShowType = table.const{
	kSnail = 0,  --默认 蜗牛路径
	kHedgehog = 1, --刺猬路径
}

BoardGravityDirection = table.const{
	kUp = 1 ,
	kDown = 2 , 
	kLeft = 3 ,
	kRight = 4 ,
}

BoardGravitySkinType = {
	
	kNone = 0 ,
	kWater = 1 ,
	kWind = 2 ,
	kElectromagnetic = 3 ,
}



TransmissionType = table.const{
	kNone = 0,
	kRoad = 1,-- 转角分顺、逆时针8个方向
	kCorner_UR = 2, -- up right
	kCorner_RD = 3, -- right down
	kCorner_DL = 4, -- down left
	kCorner_LU = 5, -- left up
	kCorner_LD = 6,
	kCorner_DR = 7,
	kCorner_RU = 8,
	kCorner_UL = 9,
	kStart = 10,
	kEnd = 11,
	kSingleTile = 12,
}

TransmissionDirection = table.const{
	kNone = 0,
	kRight = 1, 
	kDown = 2, 
	kLeft = 3,
	kUp = 4
}

TransmissionColor = table.const{
	kNone = 0,
	kRed = 1,
	kGreen = 2,
	kBlue = 3
}

HedgeRoadState = table.const{
	kStop = 0, 
	kPass = 1,
	kDestroy = 2,
}

ColorFilterState = table.const{
	kStateNone = 0,
	kStateA = 1,
	kStateB = 2,
}

BiscuitType = {
	k1x2 = 1,
	k2x1 = 2,
	k2x2 = 3,
	k2x3 = 4,
	k3x2 = 5,
	k3x3 = 6,
}

gTileBlockDefaultCount = 3

function GameBoardData:ctor()

	self.gravity = BoardGravityDirection.kDown
	self.gravitySkin = BoardGravitySkinType.kNone
	self.isUsed = false; 	--是否可用
	self.isMoveTile = false; -- 是否是移动地块
	self.isProducer = false;	--是否可以掉落出东西（生产）
	self.iceLevel = 0;		--冰层厚度
	self.passType = 0;		--没有通道，1=上方有[出口]，2=下方有[入口]，3=上方有[出口]且下方有[入口]
	self.passExitPoint_x = 0;
	self.passExitPoint_y = 0;	--连接的通道出口位置
	self.passEnterPoint_x = 0;
	self.passEnterPoint_y = 0;	--连接的通道入口位置
	self.passEnterColorId = 1
	self.passExitColorId = 1
	self.isCollector = false; --能否掉出豆荚--收集口
	self.ropetype = 0;		--按位表示有什么方向的绳子，从右至左，第1位-4位分别表示：上下左右
	self.isBlock = false;	--是block类型<毒液、雪花、牢笼>
	self.tileBlockType = 0;   --特殊地格类型 0=普通地格 1 = 翻转地格
	self.isReverseSide = false    --所在地块是否被翻转
	self.reverseCount = nil
	self.sandLevel = 0 	-- 流沙等级
	self.blockerCoverMaterialLevel = 0 -- 木桩等级

	self.snailRoadType = 0   --蜗牛轨迹
	self.isSnailProducer = false --蜗牛生成口
	self.isSnailCollect  = false --蜗牛收集口
	self.nextSnailRoad = nil
	self.isSnailRoadBright = false
	self.snailTargetCount = 0
	self.snailRoadViewRotation = nil
	self.snailRoadViewType = nil
	self.roadType = 0
	self.hedgeRoadState = 0  --刺猬路径状态

	self.isRabbitProducer = false -- 兔子生成口

	self.transType = TransmissionType.kNone
	self.transColor =TransmissionColor.kNone
	self.transDirect  = TransmissionDirection.kNone
	self.transLink = nil


	self.x = 0;
	self.y = 0;
	self.w = GamePlayConfig_Tile_Width;
	self.h = GamePlayConfig_Tile_Height;

	self.gameModeId = nil
	self.seaAnimalType = nil

	self.biscuitData = nil

	self.isNeedUpdate = false
	self.theGameBoardFallType = {}
	self.isMagicTileAnchor = false
	self.magicTileId = nil
	self.magicTileIndex = nil
	self.remainingHit = nil
	self.magicTileDisabledRound = 0		--demo用：超级地格无效回合，Boss技能用
	self.chains = {}
	self.showType = 0
	self.honeySubSelect = false

	self.isWukongTarget = false    -- 是否为悟空的目标地格

	self.lotusLevel = 0

	self.superCuteState = GameItemSuperCuteBallState.kNone
	self.superCuteAddInt = 0
	self.side = 0

	self.poisonPassSelect = false

	self.blockerCoverFlag = 0

	self.colorFilterState = ColorFilterState.kStateNone
	self.colorFilterColor = 0
	self.colorFilterBLevel = 0 --色彩过滤器B状态等级
	self.isJustEffectByFilter = false

	self.fallTypeLimits = nil -- {123=10} 银币掉落10个后不再从该口掉落
	self.fallTypeCounter = nil -- 已经掉落个数

	self.isTangChickenBoard = nil
	self.buffBoomPassSelect = false

	self.isGhostAppear = false --幽灵生成位
	self.isGhostCollect  = false --幽灵收集位

	self.preAndBuffFirecrackerPassSelect = false			--前置&Buff炸弹 屏蔽投掷点
    self.preAndBuffLineWrapPassSelect = false		--前置&Buff特效 屏蔽投掷点
    self.preAndBuffMagicBirdPassSelect = false		--前置&Buff魔力鸟 屏蔽投掷点

    self.isJamSperad = false

    self.wanshengRightSelect = false
    self.wanshengWrongSelect = false
end

function GameBoardData:resetDatas( mode )

	if not mode then mode = gCopyDataMode.kNormal end

	if mode == gCopyDataMode.kNormal then

		self.ropetype		= 0 --按位表示有什么方向的绳子，从右至左，第1位-4位分别表示：上下左右
		self.chains = {}

		self.snailRoadType = 0   --蜗牛轨迹
		self.isSnailProducer = false --蜗牛生成口
		self.isSnailCollect  = false --蜗牛收集口
		self.nextSnailRoad = nil
		self.isSnailRoadBright = false
		self.snailTargetCount = 0
		self.snailRoadViewRotation = nil
		self.snailRoadViewType = nil
		self.roadType = 0
		self.hedgeRoadState = 0

		self.passType = 0;		--没有通道，1=上方有[出口]，2=下方有[入口]，3=上方有[出口]且下方有[入口]
		self.passExitPoint_x = 0;
		self.passExitPoint_y = 0;	--连接的通道出口位置
		self.passEnterPoint_x = 0;
		self.passEnterPoint_y = 0;	--连接的通道入口位置
		self.passEnterColorId = 1
		self.passExitColorId = 1
		self.isCollector = false; --能否掉出豆荚--收集口

	elseif mode == gCopyDataMode.kDoubleSideBlockerTurn then
		self.snailTargetCount = 0
	end

	self.gravity = BoardGravityDirection.kDown
	self.gravitySkin = BoardGravitySkinType.kNone
	self.isUsed = false; 	--是否可用
	self.isMoveTile = false; -- 是否是移动地块
	self.isProducer = false;	--是否可以掉落出东西（生产）
	self.iceLevel = 0;		--冰层厚度
	
	
	self.isBlock = false;	--是block类型<毒液、雪花、牢笼>
	self.tileBlockType = 0;   --特殊地格类型 0=普通地格 1 = 翻转地格
	self.isReverseSide = false    --所在地块是否被翻转
	self.reverseCount = nil
	self.sandLevel = 0 	-- 流沙等级
	self.blockerCoverMaterialLevel = 0

	self.isRabbitProducer = false -- 兔子生成口

	self.transType = TransmissionType.kNone
	self.transColor =TransmissionColor.kNone
	self.transDirect  = TransmissionDirection.kNone
	self.transLink = nil

	self.gameModeId = nil
	self.seaAnimalType = nil

	self.biscuitData = nil 

	self.isNeedUpdate = false
	self.theGameBoardFallType = {}
	self.isMagicTileAnchor = false
	self.magicTileId = nil
	self.magicTileIndex = nil
	self.remainingHit = nil
	self.magicTileDisabledRound = 0
	self.showType = 0
	self.honeySubSelect = false
	self.tileMoveCountDown = 0
	self.tileMoveReverse = false
	self.tileMoveMeta = nil

	self.isWukongTarget = false
	self.lotusLevel = 0

	self.superCuteState = GameItemSuperCuteBallState.kNone
	self.superCuteAddInt = 0
	self.side = 0

	self.poisonPassSelect = false

	self.blockerCoverFlag = 0

	self.colorFilterState = ColorFilterState.kStateNone
	self.colorFilterColor = 0
	self.colorFilterBLevel = 0

	self.fallTypeLimits = nil
	self.fallTypeCounter = nil
	self.isTangChickenBoard = nil
	self.buffBoomPassSelect = false

	self.isGhostAppear = false
	self.isGhostCollect  = false

	self.preAndBuffFirecrackerPassSelect = false
    self.preAndBuffLineWrapPassSelect = false
    self.preAndBuffMagicBirdPassSelect = false

    self.isJamSperad = false
    self.wanshengRightSelect = false
    self.wanshengWrongSelect = false
end

function GameBoardData:tryProductFallType(cannonType)
	if not self.fallTypeLimits or not self.fallTypeLimits[cannonType] then
		return true
	end
	self.fallTypeCounter = self.fallTypeCounter or {}
	if not self.fallTypeCounter[cannonType] then
		self.fallTypeCounter[cannonType] = 0
	end
	if self.fallTypeCounter[cannonType] >= self.fallTypeLimits[cannonType] then
		return false
	end
	return true
end

function GameBoardData:addProductFallType(cannonType, num)
	if self.fallTypeCounter then
		num = num or 1
		self.fallTypeCounter[cannonType] = self.fallTypeCounter[cannonType] + num
	end
end

function GameBoardData.copyDatasFrom(toData, fromData , mode)
	if type(fromData) ~= "table" then return end

	if not mode then mode = gCopyDataMode.kNormal end

	if mode == gCopyDataMode.kNormal then
		toData.ropetype		= fromData.ropetype
		if fromData.chains and type(fromData.chains) == "table" then
			toData.chains = {}

			for dir, chain in pairs(fromData.chains) do
				toData.chains[dir] = {direction = dir, level = chain.level}
			end
		end

		toData.snailRoadType = fromData.snailRoadType   --蜗牛轨迹
		toData.isSnailProducer = fromData.isSnailProducer
		toData.isSnailCollect = fromData.isSnailCollect
		toData.snailTargetCount = fromData.snailTargetCount
		toData.snailRoadViewRotation = fromData.snailRoadViewRotation
		toData.snailRoadViewType = fromData.snailRoadViewType
		toData.roadType = fromData.roadType

		toData.passType		= fromData.passType
		toData.passEnterPoint_x	= fromData.passEnterPoint_x
		toData.passEnterPoint_y	= fromData.passEnterPoint_y
		toData.passExitPoint_x	= fromData.passExitPoint_x
		toData.passExitPoint_y	= fromData.passExitPoint_y
		toData.passEnterColorId	= fromData.passEnterColorId
		toData.passExitColorId	= fromData.passExitColorId

		toData.isCollector	= fromData.isCollector

	elseif mode == gCopyDataMode.kDoubleSideBlockerTurn then
		toData.snailTargetCount 		= fromData.snailTargetCount
	end
	
	toData.gravity 		= fromData.gravity
	toData.gravitySkin 		= fromData.gravitySkin
	toData.isUsed 		= fromData.isUsed
	toData.isMoveTile 	= fromData.isMoveTile
	toData.isProducer		= fromData.isProducer
	toData.iceLevel		= fromData.iceLevel
	
	toData.isBlock		= fromData.isBlock
	toData.tileBlockType = fromData.tileBlockType
	toData.isReverseSide = fromData.isReverseSide
	toData.reverseCount  = fromData.reverseCount
	toData.sandLevel		= fromData.sandLevel
	toData.blockerCoverMaterialLevel = fromData.blockerCoverMaterialLevel

	toData.isNeedUpdate = fromData.isNeedUpdate

	toData.isRabbitProducer = fromData.isRabbitProducer -- 兔子生成口
	toData.transType = fromData.transType
	toData.transDirect = fromData.transDirect
	toData.transLink = fromData.transLink
	toData.transColor = fromData.transColor
	
	if fromData.theGameBoardFallType and type(fromData.theGameBoardFallType) == "table" then
		toData.theGameBoardFallType = {}
		for k, fallType in pairs(fromData.theGameBoardFallType) do
			toData.theGameBoardFallType[k] = fallType
		end
	end
	
	toData.gameModeId = fromData.gameModeId
	toData.seaAnimalType = fromData.seaAnimalType
	if fromData.biscuitData then
		toData.biscuitData = table.clone(fromData.biscuitData, true)
	else
		toData.biscuitData = nil
	end
	toData.isMagicTileAnchor = fromData.isMagicTileAnchor
	toData.magicTileId = fromData.magicTileId
	toData.magicTileIndex = fromData.magicTileIndex
	toData.remainingHit = fromData.remainingHit
	toData.magicTileDisabledRound = fromData.magicTileDisabledRound
	toData.isHitThisRound = fromData.isHitThisRound


	toData.showType = fromData.showType
	toData.honeySubSelect = fromData.honeySubSelect
	toData.tileMoveCountDown = fromData.tileMoveCountDown
	toData.tileMoveReverse = fromData.tileMoveReverse
	toData.tileMoveMeta = fromData.tileMoveMeta
	toData.hedgeRoadState = fromData.hedgeRoadState

	toData.isWukongTarget = fromData.isWukongTarget
	toData.lotusLevel = fromData.lotusLevel

	toData.superCuteState = fromData.superCuteState
	toData.superCuteAddInt = fromData.superCuteAddInt
	toData.side = fromData.side
	toData.poisonPassSelect = fromData.poisonPassSelect

	toData.blockerCoverFlag = fromData.blockerCoverFlag

	toData.colorFilterState = fromData.colorFilterState
	toData.colorFilterColor = fromData.colorFilterColor
	toData.colorFilterBLevel = fromData.colorFilterBLevel

	toData.fallTypeLimits = table.copyValues(fromData.fallTypeLimits)
	toData.fallTypeCounter = table.copyValues(fromData.fallTypeCounter)

	toData.isTangChickenBoard = fromData.isTangChickenBoard
	toData.buffBoomPassSelect = fromData.buffBoomPassSelect

	toData.isGhostAppear = fromData.isGhostAppear
	toData.isGhostCollect  = fromData.isGhostCollect

	toData.preAndBuffFirecrackerPassSelect = fromData.preAndBuffFirecrackerPassSelect
    toData.preAndBuffLineWrapPassSelect = fromData.preAndBuffLineWrapPassSelect
    toData.preAndBuffMagicBirdPassSelect = fromData.preAndBuffMagicBirdPassSelect

    toData.isJamSperad = fromData.isJamSperad
    toData.wanshengRightSelect = fromData.wanshengRightSelect
    toData.wanshengWrongSelect = fromData.wanshengWrongSelect
end

function GameBoardData:copy()
	local v = GameBoardData.new()
	v:initData()

	v.x = self.x
	v.y = self.y
	v.w = self.w
	v.h = self.h

	v:copyDatasFrom(self)
	return v
end

function GameBoardData:dispose()
end

function GameBoardData:create()
	local v = GameBoardData.new()
	v:initData()
	return v
end

function GameBoardData:initData()

end

function GameBoardData:initByConfig(tileDef)
	self.x = tileDef.x;
	self.y = tileDef.y;

	if tileDef:hasProperty(TileConst.kEmpty) then self.isUsed = false else self.isUsed = true end	--是否可用		--1
	-- 生成口类型判断
	self.theGameBoardFallType = ProductItemLogic:getTileFallTypes(tileDef)
	if #self.theGameBoardFallType > 0 then self.isProducer = true end
	if self.isProducer then
		local addInfo = tonumber(tileDef:getAddInfoOfProperty(TileConst.kCannon))
		if addInfo then 
			self.fallTypeLimits = self.fallTypeLimits or {}
			self.fallTypeLimits[TileConst.kCannonCoin] = addInfo
		end
	end

	self.gravity = BoardGravityDirection.kDown
	
	if tileDef:hasProperty(TileConst.kGravityUp) then
		self.gravity = BoardGravityDirection.kUp
	end

	if tileDef:hasProperty(TileConst.kGravityLeft) then
		self.gravity = BoardGravityDirection.kLeft
	end

	if tileDef:hasProperty(TileConst.kGravityRight) then
		self.gravity = BoardGravityDirection.kRight
	end

	self.gravitySkin = BoardGravitySkinType.kNone
	if tileDef:hasProperty(TileConst.kGravitySkin) then
		self.gravitySkin = tonumber(tileDef:getAttrOfProperty(TileConst.kGravitySkin)) or BoardGravitySkinType.kWater
	end
	
	if tileDef:hasProperty(TileConst.kBlocker) then self.isBlock = true end							--是否为阻挡物	--6
	if tileDef:hasProperty(TileConst.kLock) then self.isBlock = true end							--牢笼也是阻挡物--8
	if tileDef:hasProperty(TileConst.kCollector) then self.isCollector = true end					--豆荚掉落出口	--10

	if tileDef:hasProperty(TileConst.kPortalEnter) then self.passType = self.passType + 2 end						--通道入口		--11
	if tileDef:hasProperty(TileConst.kPortalExit) then self.passType = self.passType + 1 end						--通道出口		--12

	if tileDef:hasProperty(TileConst.kWallUp) then self.ropetype = bit.bor(self.ropetype, 0x01) end			--绳子类型		--25\26\27\28\29
	if tileDef:hasProperty(TileConst.kWallDown) then self.ropetype = bit.bor(self.ropetype, 0x02) end		
	if tileDef:hasProperty(TileConst.kWallLeft) then self.ropetype = bit.bor(self.ropetype, 0x04) end		
	if tileDef:hasProperty(TileConst.kWallRight) then self.ropetype = bit.bor(self.ropetype, 0x08) end		

	if tileDef:hasProperty(TileConst.kSnailSpawn) then
		self.isSnailProducer = true self.snailRoadViewType = TileRoadType.kStartPoint self.snailRoadViewRotation = 0
	elseif tileDef:hasProperty(TileConst.kSnailCollect) then
		self.isSnailCollect  = true self.snailRoadViewType = TileRoadType.kEndPoint self.snailRoadViewRotation = 0
	end

	if tileDef:hasProperty(TileConst.kGhostAppear) then
		self.isGhostAppear = true
	elseif tileDef:hasProperty(TileConst.kGhostVanish) then
		self.isGhostCollect  = true
	end

	if tileDef:hasProperty(TileConst.kRabbitProducer) then 
		self.isRabbitProducer = true
	end

	if tileDef:hasProperty(TileConst.kMagicLamp) then
		self.isBlock = true
	end

	if tileDef:hasProperty(TileConst.kMagicTile) then
		self.isMagicTileAnchor = true
		self.isHitThisRound = false
		self.remainingHit = MoleWeeklyRaceParam.MAGIC_TILE_MAX_LIFE --GameBoardDataConfig.magicTileMaxLife
		self.magicTileDisabledRound = 0
	end

	if tileDef:hasProperty(TileConst.kWukongTarget) then
		self.isWukongTarget = true
	end

	if tileDef:hasProperty(TileConst.kSand) then -- 流沙
  		self.sandLevel = 1 
  	end

  	if tileDef:hasProperty(TileConst.kHoney_Sub_Select) then 
  		self.honeySubSelect = true
  	end

    if tileDef:hasProperty(TileConst.kWanShengRight) then 
  		self.wanshengRightSelect = true
  	end

    if tileDef:hasProperty(TileConst.kWanShengWrong) then 
  		self.wanshengWrongSelect = true
  	end
    
  	-- chains
  	local chainsMeta = tileDef:getChainsMeta()
  	self.chains = {}
  	if chainsMeta then
  		for _, v in pairs(chainsMeta) do
	  		self.chains[v.direction] = v
	  	end
  	end
  	
  	if tileDef:hasProperty(TileConst.kMoveTile) then self.isMoveTile = true end

	if tileDef:hasProperty(TileConst.kTileBlocker) then 
		self.tileBlockType = 1 self.reverseCount = gTileBlockDefaultCount 
	elseif tileDef:hasProperty(TileConst.kTileBlocker2) then
		self.tileBlockType = 1 self.reverseCount = gTileBlockDefaultCount self.isReverseSide = true
	end  --翻转地格

	if tileDef:hasProperty(TileConst.kDoubleSideTurnTile) then 
		self.tileBlockType = 2
		self.reverseCount = gTileBlockDefaultCount
		self.side = 1
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

	if tileDef:hasProperty(TileConst.kTangChicken) then
		self.isTangChickenBoard = true
	end

	if tileDef:hasProperty(TileConst.kSuperCute) then 
		self.superCuteState = GameItemSuperCuteBallState.kActive
		self.isBlock = true
	end

	if tileDef:hasProperty(TileConst.kPoisonPassSelect) then 
		self.poisonPassSelect = true
	end

	if tileDef:hasProperty(TileConst.kBuffBoomPassSelect) then 
		self.buffBoomPassSelect = true
		self.preAndBuffFirecrackerPassSelect = true
		self.preAndBuffLineWrapPassSelect = true
		self.preAndBuffMagicBirdPassSelect = true
	end

	if tileDef:hasProperty(TileConst.kBlockerCoverMaterial) then 
		self.blockerCoverMaterialLevel = tonumber(tileDef:getAttrOfProperty(TileConst.kBlockerCoverMaterial))
	end

	if tileDef:hasProperty(TileConst.kColorFilter) then 
		local addInfo = tileDef:getAddInfoOfProperty(TileConst.kColorFilter)
		local filterLv = tonumber(addInfo) or 3
		if filterLv > 0 then
			self.colorFilterState = ColorFilterState.kStateB 
			self.isBlock = true
		else
			self.colorFilterState = ColorFilterState.kStateA 
		end
		self.colorFilterBLevel = filterLv
		self.colorFilterColor = tonumber(tileDef:getAttrOfProperty(TileConst.kColorFilter))
	elseif tileDef:hasProperty(TileConst.kBlockerCoverGenerateFlag) then
		self.blockerCoverFlag = tonumber( tileDef:getAttrOfProperty( TileConst.kBlockerCoverGenerateFlag ) ) + 3
	elseif tileDef:hasProperty(TileConst.kBlockerCoverGenerateFixedFlag) then
		self.blockerCoverFlag = tonumber( tileDef:getAttrOfProperty( TileConst.kBlockerCoverGenerateFixedFlag ) )
	end

	if tileDef:hasProperty(TileConst.kBlocker199) then self.isBlock = true end
	if tileDef:hasProperty(TileConst.kPacman) then self.isBlock = true end
	if tileDef:hasProperty(TileConst.kPacmansDen) then self.isBlock = true end

	if tileDef:hasProperty(TileConst.kGhost) then self.isBlock = true end

	if tileDef:hasProperty(TileConst.kPreAndBuffFirecrackerPassSelect) then self.preAndBuffFirecrackerPassSelect = true end
	if tileDef:hasProperty(TileConst.kPreAndBuffLineWrapPassSelect) then self.preAndBuffLineWrapPassSelect = true end
	if tileDef:hasProperty(TileConst.kPreAndBuffMagicBirdPassSelect) then self.preAndBuffMagicBirdPassSelect = true end

    if tileDef:hasProperty(TileConst.kJamSperad) then  self.isJamSperad = true  end

    if tileDef:hasProperty(TileConst.kBiscuit) then
    	local attrBiscuitType = tileDef:getAttrOfProperty(TileConst.kBiscuit)
    	local biscuitType = math.clamp(tonumber(attrBiscuitType) or 0, table.min(BiscuitType), table.max(BiscuitType))
    	-- 因为 biscuitType 已经 clamp过了 所以
    	-- 一定执行成功 没有意外 begin
    	local _, szBiscuitType = table.find(BiscuitType, function ( v )
    		return v == biscuitType
    	end)
    	local nRow, nCol = string.match(szBiscuitType, "(%d+)x(%d+)")
    	nRow = tonumber(nRow)
    	nCol = tonumber(nCol)
    	-- 一定执行成功 没有意外 end
    	self.biscuitData = {
    		type = biscuitType,
    		nRow = nRow, 
    		nCol = nCol,
    		milks = {},
    		level = 1,
    	}

    	for milkRow = 1, nRow do
			self.biscuitData.milks[milkRow] = {}
    		for milkCol = 1, nCol do
				self.biscuitData.milks[milkRow][milkCol] = 0
    		end
    	end
    end
end

function GameBoardData:upgradeBiscuit( newLevel )
	if self.biscuitData then
		local upgradeLevelCount = math.max(newLevel - self.biscuitData.level, 0)
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Biscuit, ObstacleFootprintAction.k_Upgrade, upgradeLevelCount)

		self.biscuitData.level = newLevel
	end
end

function GameBoardData:calcBiscuitLevels( biscuitData )
	return table.min(table.map(table.min, biscuitData.milks)) + 1
end

function GameBoardData:isBiscuitAndCover( r, c )
	if self.biscuitData then
		if r >= self.y and r <= self.y + self.biscuitData.nRow - 1 then
			if c >= self.x and c <= self.x + self.biscuitData.nCol - 1 then
				return true
			end
		end
	end
end

function GameBoardData:canApplyMilkAt( milkRow, milkCol )
	if self.biscuitData then
		local curMilkValue = self.biscuitData.milks[milkRow][milkCol]
		if curMilkValue < self.biscuitData.level then
			return true
		end
	end
	return false
end

function GameBoardData:getMilksCountAndTarget( ... )
	if self.biscuitData then
		local count = 0
		local target = self.biscuitData.nRow * self.biscuitData.nCol * 3
		for milkRow, v in ipairs(self.biscuitData.milks) do
			for milkCol, vv in ipairs(v) do
				count = count + vv
			end
		end
		return count, target
	end
	return 0, 0
end

function GameBoardData:convertToMilkRC( r, c )
	if self.biscuitData then
		return r - self.y + 1, c - self.x + 1
	end
end

function GameBoardData:getGravity()
	return self.gravity
end

function GameBoardData:setGravity(value)
	self.gravity = value
end

function GameBoardData:getGravitySkinType()
	return self.gravitySkin
end

function GameBoardData:setGravitySkinType(value)
	self.gravitySkin = value
end

function GameBoardData:isGravityUp()
	return self.gravity == BoardGravityDirection.kUp
end
function GameBoardData:isGravityDown()
	return self.gravity == BoardGravityDirection.kDown
end
function GameBoardData:isGravityLeft()
	return self.gravity == BoardGravityDirection.kLeft
end
function GameBoardData:isGravityRight()
	return self.gravity == BoardGravityDirection.kRight
end

function GameBoardData:onUseMoves()
	self.tileMoveCountDown = self.tileMoveCountDown - 1
end

function GameBoardData:resetMoveTileData()
	self.tileMoveCountDown = self.tileMoveMeta.moveCountDown or 1
end

function GameBoardData:checkTileCanMove()
	return self.isMoveTile and self.tileMoveCountDown <= 0
end

function GameBoardData:setTransmissionConfig(transType, transDirection, transColor, link)
	self.transType = transType
	self.transDirect = transDirection
	self.transColor = transColor or 0
	self.transLink = link
end

function GameBoardData:reinitTransmissionLinkByScroll(moveUpRow)
	if self.transLink then 
		self.transLink.x = self.y
	end
end

function GameBoardData:changeDataAfterTrans(gameBoardData)
	self.iceLevel = gameBoardData.iceLevel
	self.sandLevel = gameBoardData.sandLevel
	self.lotusLevel = gameBoardData.lotusLevel
	self.superCuteState = gameBoardData.superCuteState
	self.superCuteAddInt = gameBoardData.superCuteAddInt
	self.blockerCoverMaterialLevel = gameBoardData.blockerCoverMaterialLevel

	self.colorFilterState = gameBoardData.colorFilterState
	self.colorFilterColor = gameBoardData.colorFilterColor
	self.colorFilterBLevel = gameBoardData.colorFilterBLevel
	
	self.isJamSperad = gameBoardData.isJamSperad

	self.isNeedUpdate = true
end

function GameBoardData:initTileMoveByConfig(tileMoveConfig)
	if tileMoveConfig then
		-- local tileMoveMeta = tileMoveConfig:findTileMoveMetaByPos(self.y, self.x)
		local tileMoveMeta = tileMoveConfig:findCopiedTileMoveMetaByPos(self.y, self.x)
		-- if _G.isLocalDevelopMode then printx(0, "initTileMoveByConfig:", self.y, self.x, table.tostring(tileMoveMeta)) end
		self.tileMoveMeta = tileMoveMeta
		self:resetMoveTileData()
	end
end

function GameBoardData:initScrollTileMoveByConfig(tileMoveConfig, normalRowNum)
	if tileMoveConfig then
		-- local tileMoveMeta = tileMoveConfig:findTileMoveMetaByPos(self.y + normalRowNum, self.x)
		local tileMoveMeta = tileMoveConfig:findCopiedTileMoveMetaByPos(self.y + normalRowNum, self.x)
		-- if _G.isLocalDevelopMode then printx(0, "initTileMoveByConfig:", self.y, self.x, table.tostring(tileMoveMeta)) end
		self.tileMoveMeta = tileMoveMeta
		self:resetMoveTileData()
	end
end

function GameBoardData:reinitTileMoveByScroll(moveUpRow)
	if self.tileMoveMeta and self.tileMoveMeta.routes[1] then 
		self.tileMoveMeta.routes[1].startPos.x = self.y
		self.tileMoveMeta.routes[1].endPos.x = self.y
		self:resetMoveTileData()
	end
end

function GameBoardData:initSnailRoadDataByConfig( tileDef, roadType )
	-- body
	if tileDef then 
		if tileDef:hasProperty(RouteConst.kUp) then
			self.snailRoadType = RouteConst.kUp
		elseif tileDef:hasProperty(RouteConst.kDown) then
			self.snailRoadType = RouteConst.kDown
		elseif tileDef:hasProperty(RouteConst.kLeft) then
			self.snailRoadType = RouteConst.kLeft
		elseif tileDef:hasProperty(RouteConst.kRight) then
			self.snailRoadType = RouteConst.kRight
		end

		self.roadType = roadType

	end

end

function GameBoardData:setPreSnailRoad( preSnailRoadType)
	-- body
	if self.snailRoadViewType and self.snailRoadViewType == TileRoadType.kEndPoint then ----collect point
	elseif self.snailRoadViewType and self.snailRoadViewType == TileRoadType.kStartPoint then  --product point
	elseif not preSnailRoadType or self.snailRoadType == preSnailRoadType then   --line
		if self.snailRoadType == RouteConst.kRight or self.snailRoadType == RouteConst.kLeft then
			self.snailRoadViewRotation = 0 self.snailRoadViewType = TileRoadType.kLine
		elseif self.snailRoadType == RouteConst.kUp or self.snailRoadType == RouteConst.kDown then
			self.snailRoadViewRotation = 90 self.snailRoadViewType = TileRoadType.kLine
		end
	else                                                            --corner
		self.snailRoadViewType = TileRoadType.kCorner
		if preSnailRoadType == RouteConst.kDown then
			self.snailRoadViewRotation = self.snailRoadType == RouteConst.kLeft and 0 or 90
		elseif preSnailRoadType == RouteConst.kUp then
			self.snailRoadViewRotation = self.snailRoadType == RouteConst.kLeft and 270 or 180
		elseif preSnailRoadType == RouteConst.kLeft then
			self.snailRoadViewRotation = self.snailRoadType == RouteConst.kUp and 90 or 180
		elseif preSnailRoadType == RouteConst.kRight then
			self.snailRoadViewRotation = self.snailRoadType == RouteConst.kUp and 0 or 270
		end
	end
end

function GameBoardData:getSnailRoadViewType( ... )
	-- body
	return self.snailRoadViewType
end

function GameBoardData:getSnailRoadRotation( ... )
	-- body
	return self.snailRoadViewRotation
end

function GameBoardData:getNextSnailRoad( ... )
	-- body
	if not self.nextSnailRoad then
		if self.snailRoadType == RouteConst.kUp then
			self.nextSnailRoad = IntCoord:create(self.y -1, self.x)
		elseif self.snailRoadType == RouteConst.kDown then
			self.nextSnailRoad = IntCoord:create(self.y + 1, self.x)
		elseif self.snailRoadType == RouteConst.kLeft then
			self.nextSnailRoad = IntCoord:create(self.y, self.x - 1)
		elseif self.snailRoadType == RouteConst.kRight then
			self.nextSnailRoad = IntCoord:create(self.y, self.x + 1 )
		end
	end
	return self.nextSnailRoad
end

function GameBoardData:isHasPreSnailRoad( ... )
	-- body
	if self.snailRoadType > 0 or self.isSnailCollect then 
		return true
	else
		return false
	end
end

function GameBoardData:hasSameChains(otherBoard)
	if not otherBoard then return false end
	return self:chainsInNumber() == otherBoard:chainsInNumber()
end

function GameBoardData:chainsInNumber()
	local ret = 0
	for _,v in pairs(self.chains) do
		ret = ret + v.level * (math.pow(10, v.direction - 1))
	end
	return ret
end

function GameBoardData:hasChains()
	for _,v in pairs(self.chains) do
		if v.level > 0 then
			return true
		end
	end
	return false
end

function GameBoardData:decChainsInDirections(dirs, isRemove)
	local breakLevels = {}
	if dirs then
		for _, dir in pairs(dirs) do
			local breakLevel = self:_decChainInDirection(dir, isRemove)
			breakLevels[dir] = breakLevel
		end
	end
	return breakLevels
end

function GameBoardData:_decChainInDirection(dir, isRemove)
	local originLevel = 0
	local chain = self:getChainInDirection(dir)
	if chain and chain.level > 0 then
		originLevel = chain.level 
		local decLevel = 1
		if isRemove then decLevel = originLevel end
		chain.level = chain.level - decLevel
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Icicle, ObstacleFootprintAction.k_Hit, decLevel)
		if chain.level <= 0 then
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Icicle, ObstacleFootprintAction.k_Eliminate, 1)
		end
	end
	return originLevel
end

function GameBoardData:getChainInDirection(dir)
	return self.chains[dir]
end

-- dir in ChainDirConfig
function GameBoardData:hasChainInDirection(dir)
	local chain = self:getChainInDirection(dir)
	if chain and chain.level > 0 then
		return true
	else
		return false
	end
end

function GameBoardData:initLightUp(tileDef)
	if tileDef:hasProperty(TileConst.kLight1)then self.iceLevel = 1									--冰层厚度		--3\4\30
	elseif tileDef:hasProperty(TileConst.kLight2)then self.iceLevel = 2
	elseif tileDef:hasProperty(TileConst.kLight3)then self.iceLevel = 3
	end
end

function GameBoardData:addPassEnterInfo(x, y)
	self.passExitPoint_x = x;
	self.passExitPoint_y = y;
end

function GameBoardData:setPassEnterColor(colorId)
	self.passEnterColorId = colorId
end

function GameBoardData:addPassExitInfo(x, y)
	self.passEnterPoint_x = x;
	self.passEnterPoint_y = y;
end

function GameBoardData:setPassExitColor(colorId)
	self.passExitColorId = colorId
end

function GameBoardData:hasRope()
	return self.ropetype ~= 0
end

function GameBoardData:hasLeftRopeProperty()
	return bit.band(self.ropetype, 0x04) ~= 0
end

function GameBoardData:hasRightRopeProperty()
	return bit.band(self.ropetype, 0x08) ~= 0
end

function GameBoardData:hasTopRopeProperty()
	return bit.band(self.ropetype, 0x01) ~= 0
end

function GameBoardData:hasBottomRopeProperty()
	return bit.band(self.ropetype, 0x02) ~= 0
end

function GameBoardData:removeRopeOfDirection(direction)
	if self:hasRope() then
		-- direction1-4: 上右下左
		-- 绳子位数1-4：  上下左右
		-- printx(11, "ropetype:", self.ropetype)
		if direction == 1 then
			self.ropetype = bit.band(self.ropetype, 0xE)	--1110 绳子上
		end
		if direction == 2 then
			self.ropetype = bit.band(self.ropetype, 0x7)	--0111 绳子右
		end
		if direction == 3 then
			self.ropetype = bit.band(self.ropetype, 0xD)	--1101 绳子下
		end
		if direction == 4 then
			self.ropetype = bit.band(self.ropetype, 0xB)	--1011 绳子左
		end
		-- printx(11, "ropetype after:", self.ropetype)
	end
end

function GameBoardData:hasLeftRope()
	return self:hasLeftRopeProperty() or self:hasChainInDirection(ChainDirConfig.kLeft)
end

function GameBoardData:hasRightRope()
	return self:hasRightRopeProperty() or self:hasChainInDirection(ChainDirConfig.kRight)
end

function GameBoardData:hasTopRope()
	return self:hasTopRopeProperty() or self:hasChainInDirection(ChainDirConfig.kUp)
end

function GameBoardData:hasBottomRope()
	return self:hasBottomRopeProperty() or self:hasChainInDirection(ChainDirConfig.kDown)
end

function GameBoardData:hasPortal()
	return self.passType > 0
end

--是否是翻转地格
function GameBoardData:isRotationTileBlock( ... )
	-- body
	return self.tileBlockType == 1
end

function GameBoardData:isDoubleSideTileBlock( ... )
	-- body
	return self.tileBlockType == 2
end

-- 含有传送门入口，即格子下边缘的传送门视图
function GameBoardData:hasEnterPortal()
	return self.passType == 2 or self.passType == 3
end

-- 含有传送门出口，即格子上边缘的传送门视图
function GameBoardData:hasExitPortal()
	return self.passType == 1 or self.passType == 3
end

function GameBoardData:initSeaAnimal(seaAnimalType)
	self.seaAnimalType = seaAnimalType
end

function GameBoardData:setGameModeId(gameModeId)
	self.gameModeId = gameModeId
end

function GameBoardData:initUnlockAreaDropDownModeInfo( ... )
	-- body
	if self.isCollector then 
		self.showType = IngredientShowType.kAcorn
	end
end

function GameBoardData:hasSuperCuteBall()
	return self.superCuteState ~= GameItemSuperCuteBallState.kNone
end

------- 以下已转移至 CommonMultipleHittingPriorityLogic
-- function GameBoardData:isMissileTargetPrior1( ... )

-- 	-- if 	(self.iceLevel > 0  and self.seaAnimalType ~= nil)
-- 	-- 	then
-- 	-- 	return true
-- 	-- end
-- 	return false
-- end

-- function GameBoardData:isMissileTargetPrior2( itemData)
-- 	if 	(self.iceLevel > 0  and itemData.ItemType ~= GameItemType.kNone)
-- 		or (self.lotusLevel > 1 and itemData.ItemType ~= GameItemType.kNone)
-- 		or self.colorFilterBLevel > 0 
-- 		or (self.blockerCoverMaterialLevel > 0 and itemData.ItemType ~= GameItemType.kNone)
-- 		then
-- 		return true
-- 	end
-- 	return false
-- end
-- function GameBoardData:isMissileTargetPrior3( itemData)
-- 	if (self.sandLevel > 0 and itemData.ItemType ~= GameItemType.kNone
-- 		or (self.lotusLevel == 1 and itemData.ItemType ~= GameItemType.kNone)
-- 		) then
-- 		return true
-- 	end
	
-- 	return false
-- end
-- function GameBoardData:isMissileTargetPrior4( ... )
-- 	return false
-- end
-- function GameBoardData:isMissileTargetPrior5( ... )
-- 	return false
-- end
-- function GameBoardData:isMissileTargetPrior6()
-- 	return false
-- end

-- function GameBoardData:isMissileTargetInvalid()
-- 	return false
-- end 

function GameBoardData:isBigMonsterEffectPrior1()
	if 	self.iceLevel > 0  
		or self.sandLevel > 0 
		or self.lotusLevel > 0 
		or self.blockerCoverMaterialLevel > 0 
		then 
		return true
	else
		return false
	end
end

function GameBoardData:isBigMonsterEffectPrior2()
	if self:hasChains() 
		or self.snailRoadType > 0 
		or self.colorFilterBLevel > 0 
		then
		return true
	else
		return false
	end
end

function GameBoardData:isBigMonsterEffectPrior3()
	return false
end

function GameBoardData:changeHedgehogRoadState( state )
	if state > self.hedgeRoadState then 
		self.hedgeRoadState = state
	end
end


--转换为过滤器
function GameBoardData:changeToColorFilter( attr, addInfo )
--    local addInfo = tileDef:getAddInfoOfProperty(TileConst.kColorFilter)
    local filterLv = tonumber(addInfo) or 3
	if filterLv > 0 then
		self.colorFilterState = ColorFilterState.kStateB 
		self.isBlock = true
	else
		self.colorFilterState = ColorFilterState.kStateA 
	end
	self.colorFilterBLevel = filterLv
	self.colorFilterColor = tonumber(attr) --tonumber(tileDef:getAttrOfProperty(TileConst.kColorFilter))
end

--是否能被万生破裂后飞出的障碍替换
function GameBoardData:canInfectByWanSheng( ... )

    if self.isUsed == false then return false end

	if self.iceLevel > 0                        --冰
        or self.sandLevel > 0                   --沙子
        or self.blockerCoverMaterialLevel > 0  --木桩
--        or self.snailRoadType > 0              --蜗牛轨迹
--        or self.isSnailProducer            --蜗牛生成口3
--        or self.isSnailCollect             --蜗牛生成口
        or self.lotusLevel > 0              --荷塘
        then
	    return false
	end
	return true
end