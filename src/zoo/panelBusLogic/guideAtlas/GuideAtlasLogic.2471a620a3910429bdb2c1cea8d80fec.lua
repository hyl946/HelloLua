AnimalGuideAtlas = class()

AnimalGuideAtlasType = {
    kSpecial = 0,
    kLight = 1,
    kFrosting = 2,
    kGreyCuteBall = 3,
    kGift = 4,
    kCoin = 5,
    kBrownCuteBall = 6,
    kRoost = 7,
    kDigGround = 8,
    kBalloon = 9,
    kPoisonBottle = 10,
    kBigMonster = 11,
    kBlackCuteBall = 12,
    kMimosa = 13,
    kSnail = 14,
    kTransmission = 15,
    kSeaAnimal = 16,
    kMagicLamp = 17,
    kHoney = 18,
    kSand = 19,
    kChain = 20,
    kMagicStone = 21,
    kMoveTile = 22,
    kBottleBlocker = 23,
    kCrystalStone = 24,
    kTotem = 25,
    kRocket = 26,
    kIngredient = 27,
    kCage = 28,
    kSuperCute = 29,
    kRope = 30,
    kTileBlocker = 31,
    kCrystal = 32,
    kPortal = 33,
    kLotus = 34,
    kPuffer = 35,
    kDoubleSideTurnTile = 36,
    kMissile = 37,
    kBoss = 38,
    kChestSquare = 39,
    kQuestionMark = 40,
    kDrip = 41,
    kCloud = 42,
    kBlockerCover = 43,
    kBlocker195 = 44,
    kBlocker199 = 45,
    kColorFilter = 46,
    kChameleon = 47,
    kBlocker206 = 48,
    kPacman = 49,
    kBlocker211 = 50,
    kTurret = 51,
    kMoleWeekly1 = 52, --地鼠周赛52-59
    kMoleWeekly2 = 53,
    kMoleWeekly3 = 54,
    kMoleWeekly4 = 55,
    kMoleWeekly5 = 56,
    kMoleWeekly6 = 57,
    kMoleWeekly7 = 58,
    kMoleWeekly8 = 59,
    kGhost = 60,
    kSunFlask = 61,
    kSunflower = 62,
    kSquid = 63,
    kJamSpeard = 64,
    kWanSheng = 65,
    kWater = 66,
    kBiscuit = 67,
}

local AnimalGuideAtlasWeight = {
    [AnimalGuideAtlasType.kSpecial] = 0,
    [AnimalGuideAtlasType.kPortal] = 1,
    [AnimalGuideAtlasType.kLight] = 2,
    [AnimalGuideAtlasType.kIngredient] = 3,
    [AnimalGuideAtlasType.kFrosting] = 4,
    [AnimalGuideAtlasType.kGift] = 6,
    [AnimalGuideAtlasType.kRope] = 7,
    [AnimalGuideAtlasType.kGreyCuteBall] = 8,
    [AnimalGuideAtlasType.kCrystal] = 11,
    [AnimalGuideAtlasType.kCage] = 12,
    [AnimalGuideAtlasType.kCoin] = 14,
    [AnimalGuideAtlasType.kBrownCuteBall] = 15,
    [AnimalGuideAtlasType.kRoost] = 16,
    [AnimalGuideAtlasType.kDigGround] = 17,
    [AnimalGuideAtlasType.kBalloon] = 19,
    [AnimalGuideAtlasType.kRocket] = 21,
    [AnimalGuideAtlasType.kPoisonBottle] = 22,
    [AnimalGuideAtlasType.kTileBlocker] = 23,
    [AnimalGuideAtlasType.kBigMonster] = 24,
    [AnimalGuideAtlasType.kBlackCuteBall] = 25,
    [AnimalGuideAtlasType.kMimosa] = 99,
    [AnimalGuideAtlasType.kSnail] = 99,
    [AnimalGuideAtlasType.kTransmission] = 29,
    [AnimalGuideAtlasType.kSeaAnimal] = 30,
    [AnimalGuideAtlasType.kMagicLamp] = 31,
    [AnimalGuideAtlasType.kHoney] = 32,
    [AnimalGuideAtlasType.kSand] = 33,
    [AnimalGuideAtlasType.kChain] = 34,
    [AnimalGuideAtlasType.kMagicStone] = 36,
    [AnimalGuideAtlasType.kMoveTile] = 37,
    [AnimalGuideAtlasType.kBottleBlocker] = 38,
    [AnimalGuideAtlasType.kCrystalStone] = 99,
    [AnimalGuideAtlasType.kTotem] = 99,
    [AnimalGuideAtlasType.kLotus] = 99,
    [AnimalGuideAtlasType.kSuperCute] = 99,
    [AnimalGuideAtlasType.kPuffer] = 99,
    [AnimalGuideAtlasType.kDoubleSideTurnTile] = 99,
    [AnimalGuideAtlasType.kMissile] = 99,

    [AnimalGuideAtlasType.kBoss] = 35,
    [AnimalGuideAtlasType.kChestSquare] = 33,
    [AnimalGuideAtlasType.kQuestionMark] = 32,
    [AnimalGuideAtlasType.kDrip] = 31,
    [AnimalGuideAtlasType.kCloud] = 30,

    [AnimalGuideAtlasType.kBlockerCover] = 100,
    [AnimalGuideAtlasType.kBlocker195] = 100,
    [AnimalGuideAtlasType.kBlocker199] = 100,
    [AnimalGuideAtlasType.kColorFilter] = 100,
    [AnimalGuideAtlasType.kChameleon] = 100,
    [AnimalGuideAtlasType.kBlocker206] = 100,
    [AnimalGuideAtlasType.kPacman] = 100,
    [AnimalGuideAtlasType.kBlocker211] = 100,
    [AnimalGuideAtlasType.kTurret] = 100,
    [AnimalGuideAtlasType.kGhost] = 100,
    [AnimalGuideAtlasType.kSunFlask] = 100,
    [AnimalGuideAtlasType.kSunflower] = 100,
    [AnimalGuideAtlasType.kSquid] = 100,
    [AnimalGuideAtlasType.kJamSpeard] = 100,
    [AnimalGuideAtlasType.kWanSheng] = 100,
    [AnimalGuideAtlasType.kWater] = 100,
    [AnimalGuideAtlasType.kBiscuit] = 100,
}

local TileToAtlasTypeMapping = {

    [TileConst.kMayDayBlocker1] = AnimalGuideAtlasType.kBoss,
    [TileConst.kMayDayBlocker2] = AnimalGuideAtlasType.kBoss,
    [TileConst.kMayDayBlocker3] = AnimalGuideAtlasType.kBoss,
    [TileConst.kMayDayBlocker4] = AnimalGuideAtlasType.kBoss,
    [TileConst.kChestSquare] = AnimalGuideAtlasType.kChestSquare,
    [TileConst.kQuestionMark] = AnimalGuideAtlasType.kQuestionMark,
    [TileConst.kDrip] = AnimalGuideAtlasType.kDrip,
    [TileConst.kDigJewel_1] = AnimalGuideAtlasType.kCloud,
    [TileConst.kDigJewel_2] = AnimalGuideAtlasType.kCloud,
    [TileConst.kDigJewel_3] = AnimalGuideAtlasType.kCloud,
    [TileConst.kDigJewel_1_blue] = AnimalGuideAtlasType.kCloud,
    [TileConst.kDigJewel_2_blue] = AnimalGuideAtlasType.kCloud,
    [TileConst.kDigJewel_3_blue] = AnimalGuideAtlasType.kCloud,

    -- [TileConst.kAnimal] = 2,
    [TileConst.kLight1] = AnimalGuideAtlasType.kLight,
    [TileConst.kLight2] = AnimalGuideAtlasType.kLight,
    [TileConst.kLight3] = AnimalGuideAtlasType.kLight,
    -- [TileConst.kCannon] = 5,    --生成口
    -- [TileConst.kBlocker] = 6,   --障碍
    [TileConst.kFrosting] = AnimalGuideAtlasType.kFrosting,
    [TileConst.kLock] = AnimalGuideAtlasType.kCage,      --牢笼
    [TileConst.kFudge] = AnimalGuideAtlasType.kIngredient,     --
    [TileConst.kCollector] = AnimalGuideAtlasType.kIngredient,--收集口
    [TileConst.kPortal] = AnimalGuideAtlasType.kPortal,
    [TileConst.kPortalEnter] = AnimalGuideAtlasType.kPortal,--入口
    [TileConst.kPortalExit] = AnimalGuideAtlasType.kPortal,--出口
    [TileConst.kCoin] = AnimalGuideAtlasType.kCoin,
    -- [TileConst.kChamelleon] = 15,--
    
    -- [TileConst.kLicoriceSquare] = 17,
    -- [TileConst.kPepper] = 18,
    [TileConst.kFrosting1] =  AnimalGuideAtlasType.kFrosting,
    [TileConst.kFrosting2] =  AnimalGuideAtlasType.kFrosting,
    [TileConst.kFrosting3] =  AnimalGuideAtlasType.kFrosting,
    [TileConst.kFrosting4] =  AnimalGuideAtlasType.kFrosting,
    [TileConst.kFrosting5] =  AnimalGuideAtlasType.kFrosting,
    
    [TileConst.kWall] = AnimalGuideAtlasType.kRope,     --墙
    [TileConst.kWallUp] = AnimalGuideAtlasType.kRope,
    [TileConst.kWallDown] = AnimalGuideAtlasType.kRope,
    [TileConst.kWallLeft] = AnimalGuideAtlasType.kRope,
    [TileConst.kWallRight] = AnimalGuideAtlasType.kRope,
    -- [TileConst.kDigGround] = AnimalGuideAtlasType.kDigGround,
    [TileConst.kGreyCute] = AnimalGuideAtlasType.kGreyCuteBall,
    [TileConst.kBrownCute] = AnimalGuideAtlasType.kBrownCuteBall, 
    [TileConst.kBlackCute] = AnimalGuideAtlasType.kBlackCuteBall, 
    [TileConst.kCrystal] = AnimalGuideAtlasType.kCrystal,      --水晶
    [TileConst.kGift] = AnimalGuideAtlasType.kGift,

    [TileConst.kPoison] = AnimalGuideAtlasType.kPoisonBottle,       --毒液
    -- [TileConst.kNone] = 38,         --空格子
    -- [TileConst.kCannonAnimal] = 39, --动物生成掉落口
    -- [TileConst.kCannonIngredient] = 40,--原料掉落口
    -- [TileConst.kCannonBlock]= 41,   --障碍生成掉落口
    -- [TileConst.kAddMove] = 42,      --增加步数的动物
    -- [TileConst.kDigGround_1] = AnimalGuideAtlasType.kDigGround,   ---挖地地块--多层
    -- [TileConst.kDigGround_2] = AnimalGuideAtlasType.kDigGround,
    -- [TileConst.kDigGround_3] = AnimalGuideAtlasType.kDigGround,
    [TileConst.kDigJewel_1] = AnimalGuideAtlasType.kDigGround,    --挖地-宝石块--多层
    [TileConst.kDigJewel_2] = AnimalGuideAtlasType.kDigGround,
    [TileConst.kDigJewel_3] = AnimalGuideAtlasType.kDigGround,

    [TileConst.kRoost] = AnimalGuideAtlasType.kRoost,
    [TileConst.kBalloon] = AnimalGuideAtlasType.kBalloon,
    -- [TileConst.kRabbitProducer] = 51, --兔子生成口

    [TileConst.kPoisonBottle] = AnimalGuideAtlasType.kPoisonBottle,
    [TileConst.kTileBlocker] = AnimalGuideAtlasType.kTileBlocker,  --翻转地格
    [TileConst.kTileBlocker2] = AnimalGuideAtlasType.kTileBlocker, --2号翻转地格

    [TileConst.kBigMonster] = AnimalGuideAtlasType.kBigMonster,   --占四格的巨型怪物
    [TileConst.kBigMonsterFrosting1] = AnimalGuideAtlasType.kBigMonster,
    [TileConst.kBigMonsterFrosting2] = AnimalGuideAtlasType.kBigMonster,
    [TileConst.kBigMonsterFrosting3] = AnimalGuideAtlasType.kBigMonster,
    [TileConst.kBigMonsterFrosting4] = AnimalGuideAtlasType.kBigMonster,

    [TileConst.kWeeklyBoss] = AnimalGuideAtlasType.kChestSquare,   --占四格的巨型怪物2 周赛第二种boss
                    
    -- [TileConst.kMimosaLeft] = AnimalGuideAtlasType.kMimosa,        -----含羞草
    -- [TileConst.kMimosaRight] = AnimalGuideAtlasType.kMimosa,
    -- [TileConst.kMimosaUp] = AnimalGuideAtlasType.kMimosa,
    -- [TileConst.kMimosaDown] = AnimalGuideAtlasType.kMimosa,
    -- [TileConst.kMimosaLeaf] = AnimalGuideAtlasType.kMimosa,

    -- --活动相关 四格boss 无尽劳动节模式
    -- [TileConst.kMayDayBlocker1] = 68,
    -- [TileConst.kMayDayBlocker2] = 69,
    -- [TileConst.kMayDayBlocker3] = 70,
    -- [TileConst.kMayDayBlocker4] = 71,
    --活动相关 无尽劳动模式 类似宝石
    -- [TileConst.kDigJewel_1_blue] = 72,
    -- [TileConst.kDigJewel_2_blue] = 73,
    -- [TileConst.kDigJewel_3_blue] = 74,

    -- [TileConst.kMaydayBlockerEmpty] = 75,

    [TileConst.kSnailSpawn] = AnimalGuideAtlasType.kSnail,   --蜗牛生成口
    [TileConst.kSnail] = AnimalGuideAtlasType.kSnail,
    [TileConst.kSnailCollect] = AnimalGuideAtlasType.kSnail, --蜗牛收集口
    
    -- [TileConst.kTransmission] = AnimalGuideAtlasType.kTransmission, -- 无用了
    [TileConst.kMagicLamp] = AnimalGuideAtlasType.kMagicLamp, -- 神灯（别名：独眼、增益性障碍）
    -- [TileConst.kSuperBlocker] = 87, -- 无敌障碍
    [TileConst.kHoneyBottle] = AnimalGuideAtlasType.kHoney,  --蜂蜜罐子
    [TileConst.kHoney] = AnimalGuideAtlasType.kHoney,
    -- [TileConst.kAddTime]    = 90,   --增加时间的动物
    -- [TileConst.kMagicTile] = 91,    -- 万圣节魔法地格
    [TileConst.kSand] = AnimalGuideAtlasType.kSand,
    -----------------------------------------------这里开始地图使用新的数据结构
    -- [TileConst.kQuestionMark] = 93,  --问号
    -- 冰柱 94~118
    [TileConst.kChain1] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain1_Up] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain1_Right] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain1_Down] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain1_Left] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain2] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain2_Up] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain2_Right] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain2_Down] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain2_Left] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain3] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain3_Up] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain3_Right] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain3_Down] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain3_Left] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain4] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain4_Up] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain4_Right] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain4_Down] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain4_Left] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain5] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain5_Up] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain5_Right] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain5_Down] = AnimalGuideAtlasType.kChain,
    [TileConst.kChain5_Left] = AnimalGuideAtlasType.kChain,
    -- 魔法石 PC:firefly
    [TileConst.kMagicStone_Up] = AnimalGuideAtlasType.kMagicStone,
    [TileConst.kMagicStone_Right] = AnimalGuideAtlasType.kMagicStone,
    [TileConst.kMagicStone_Down] = AnimalGuideAtlasType.kMagicStone,
    [TileConst.kMagicStone_Left] = AnimalGuideAtlasType.kMagicStone,

    -- [TileConst.kHoney_Sub_Select] = 123,   ---蜂蜜优先级的第二选择
    [TileConst.kCannonCoin] = AnimalGuideAtlasType.kCoin,
    -- [TileConst.kCannonCrystallBall] = 125,
    [TileConst.kCannonBalloon] = AnimalGuideAtlasType.kBalloon,
    [TileConst.kCannonHoneyBottle] = AnimalGuideAtlasType.kHoney,
    [TileConst.kCannonGreyCuteBall] = AnimalGuideAtlasType.kGreyCuteBall,
    [TileConst.kCannonBrownCuteBall] = AnimalGuideAtlasType.kBrownCuteBall,
    [TileConst.kCannonBlackCuteBall] = AnimalGuideAtlasType.kBlackCuteBall,

    [TileConst.kMoveTile] = AnimalGuideAtlasType.kMoveTile,
    -- [TileConst.kGoldZongZi] = 135, --金粽子

    [TileConst.kBottleBlocker] = AnimalGuideAtlasType.kBottleBlocker,
    [TileConst.kCrystalStone] = AnimalGuideAtlasType.kCrystalStone,
    [TileConst.kRocket] = AnimalGuideAtlasType.kRocket, --火箭
    [TileConst.kCannonCrystalStone] = AnimalGuideAtlasType.kCrystalStone,
    -- [TileConst.kHedgehog] = 145,  --刺猬
    -- [TileConst.kHedgehogBox] = 146, --刺猬宝箱
    -- [TileConst.kCannonRocket] = 147,

    [TileConst.kKindMimosaLeft] = AnimalGuideAtlasType.kMimosa,
    [TileConst.kKindMimosaRight] = AnimalGuideAtlasType.kMimosa,
    [TileConst.kKindMimosaUp] = AnimalGuideAtlasType.kMimosa,
    [TileConst.kKindMimosaDown] = AnimalGuideAtlasType.kMimosa,

    [TileConst.kTotems] = AnimalGuideAtlasType.kTotem, -- 无敌小金刚（PC图腾）
    [TileConst.kCannonTotems] = AnimalGuideAtlasType.kTotem, -- 无敌小金刚生成口

    -- [TileConst.kWukong] = 157,  --悟空（春节关卡的猴子）
    -- [TileConst.kWukongTarget] = 158,  --悟空目标地块

    [TileConst.kLotusLevel1] = AnimalGuideAtlasType.kLotus,  --草地（荷叶）一级
    [TileConst.kLotusLevel2] = AnimalGuideAtlasType.kLotus,  --草地（荷叶）二级
    [TileConst.kLotusLevel3] = AnimalGuideAtlasType.kLotus,  --草地（荷叶）三级
    [TileConst.kSuperCute] = AnimalGuideAtlasType.kSuperCute,   -- 无敌毛球
    -- [TileConst.kDrip] = 163,  --水滴
    -- [TileConst.kCannonDrip] = 164,  --水滴生成口


    -- [TileConst.kCannonCandyColouredAnimal] = 165,  --指定颜色动物生成口
    -- [TileConst.kCannonCandyLineEffectColumn] = 166,  --竖直线特效生成口
    -- [TileConst.kCannonCandyLineEffectRow] = 167,  --横直线特效生成口
    -- [TileConst.kCannonCandyWrapEffect] = 168,  --炸弹特效生成口
    -- [TileConst.kCannonCandyMagicBird] = 169,  --魔力鸟生成口

    [TileConst.kPuffer] = AnimalGuideAtlasType.kPuffer,  --河豚
    [TileConst.kPufferActivated] = AnimalGuideAtlasType.kPuffer,  --被激活的河豚
    [TileConst.kCannonPuffer] = AnimalGuideAtlasType.kPuffer,  --河豚生成口
    [TileConst.kCannonPufferActivated] = AnimalGuideAtlasType.kPuffer,  --被激活的河豚生成口

    [TileConst.kDoubleSideTurnTile] = AnimalGuideAtlasType.kDoubleSideTurnTile,  --双面翻转地格
    [TileConst.kNewGift] = AnimalGuideAtlasType.kGift, -- 新礼盒
    [TileConst.kMissile] = AnimalGuideAtlasType.kMissile,
    [TileConst.kCannonCandyMissile] = AnimalGuideAtlasType.kMissile,

    [TileConst.kBlockerCoverMaterial] = AnimalGuideAtlasType.kBlockerCover,
	[TileConst.kBlockerCover] = AnimalGuideAtlasType.kBlockerCover,
	[TileConst.kBlockerCoverGenerateFixedFlag] = AnimalGuideAtlasType.kBlockerCover,
	[TileConst.kBlockerCoverGenerateFlag] = AnimalGuideAtlasType.kBlockerCover,

    [TileConst.kBlocker195] = AnimalGuideAtlasType.kBlocker195,
    [TileConst.kBlocker199] = AnimalGuideAtlasType.kBlocker199,
    [TileConst.kColorFilter] = AnimalGuideAtlasType.kColorFilter,
    [TileConst.kChameleon] = AnimalGuideAtlasType.kChameleon,
    [TileConst.kCannonChameleon] = AnimalGuideAtlasType.kChameleon,
    [TileConst.kBlocker206] = AnimalGuideAtlasType.kBlocker206,
    [TileConst.kPacman] = AnimalGuideAtlasType.kPacman,
    [TileConst.kPacmansDen] = AnimalGuideAtlasType.kPacman,
    [TileConst.kBlocker211] = AnimalGuideAtlasType.kBlocker211,
    [TileConst.kTurret] = AnimalGuideAtlasType.kTurret,
    [TileConst.kGhost] = AnimalGuideAtlasType.kGhost,
    [TileConst.kGhostAppear] = AnimalGuideAtlasType.kGhost,
    [TileConst.kSunFlask] = AnimalGuideAtlasType.kSunFlask,
    [TileConst.kSunflower] = AnimalGuideAtlasType.kSunflower,
    [TileConst.kSquid] = AnimalGuideAtlasType.kSquid,
    [TileConst.kJamSperad] = AnimalGuideAtlasType.kJamSpeard,
    [TileConst.kWanSheng] = AnimalGuideAtlasType.kWanSheng,
    [TileConst.kWanShengDrop] = AnimalGuideAtlasType.kWanSheng,
    [TileConst.kGravitySkin] = AnimalGuideAtlasType.kWater, --第一个用的水 这里只用key value 下面自由判断
    [TileConst.kBiscuit] = AnimalGuideAtlasType.kBiscuit, 
}

local PermanentAtlasTypes = {
    AnimalGuideAtlasType.kSpecial,
}

-- if __WIN32 then
--     table.insert(PermanentAtlasTypes, AnimalGuideAtlasType.kPuffer)
--     table.insert(PermanentAtlasTypes, AnimalGuideAtlasType.kDoubleSideTurnTile)
-- end

local __config = nil

local function readConfig()
    local config
    local filePath = HeResPathUtils:getUserDataPath().."/guide_atlas"
    local file = io.open(filePath, "r")
    if file then
        local data = file:read("*a")
        file:close()
        if data then
            config = table.deserialize(data) or {}
        end
    end
    return config
end

local function writeConfig(config)
    local filePath = HeResPathUtils:getUserDataPath().."/guide_atlas"
    local file = io.open(filePath, "w")
    if file then
        file:write(table.serialize(config or {}))
        file:close()
    end
end

local function getConfigDataByLevelId(levelId)
    if __config and __config[levelId] then
        return __config[levelId]
    else
        __config = readConfig() or {}
        return __config[levelId]
    end
end


local function setConfigDataByLevelId(levelId, config)
    if not __config then
        __config = readConfig() or {}
    end
    __config[levelId] = config
    writeConfig(__config)    
end

local instance = nil
function AnimalGuideAtlas:create(levelConfig)    
    local instance = AnimalGuideAtlas.new()
    instance:init(levelConfig)
    return instance
end

function AnimalGuideAtlas:init(levelConfig)
    -- if true then
    --     self.tileCollection = {}
    --     for k, v in pairs(AnimalGuideAtlasType) do
    --         self.tileCollection[v] = true
    --     end
    --     self.config = {}
    --     for k, v in pairs(self.tileCollection) do
    --         if v == true then
    --             table.insert(self.config, k)
    --         end
    --     end


    --     -- if _G.isLocalDevelopMode then printx(0, 'self.config') end
    --     -- if _G.isLocalDevelopMode then printx(0, table.tostring(self.config)) end


    --     table.sort(self.config, 
    --         function (v1, v2)
    --             if _G.isLocalDevelopMode then printx(0, v1, v2) end
    --             if AnimalGuideAtlasWeight[v1] == AnimalGuideAtlasWeight[v2] then
    --                 return v1 < v2
    --             else
    --                 return AnimalGuideAtlasWeight[v1] > AnimalGuideAtlasWeight[v2] 
    --             end
    --         end)
    --     return
    -- end

    -- if __WIN32 then
    --     local _t = os.clock()
    --     self:processConfig(levelConfig)
    --     setConfigDataByLevelId(tostring(levelConfig.level), self.config)
    --     if _G.isLocalDevelopMode then printx(0, 'xxxxxxxxxxxxxxxxxxxxxxxxxatlasLogic'..(os.clock() - _t)) end
    --     return
    -- end

    local config = getConfigDataByLevelId(tostring(levelConfig.level))
    if config then
        self.config = config
    else
        self:processConfig(levelConfig)
        setConfigDataByLevelId(tostring(levelConfig.level), self.config)
    end
end

function AnimalGuideAtlas:mainLevelProcessConfig(levelConfig)
    if levelConfig.trans and #levelConfig.trans > 0 then
        self.tileCollection[AnimalGuideAtlasType.kTransmission] = true
    end

    if levelConfig.hasDropDownUFO then
        self.tileCollection[AnimalGuideAtlasType.kRocket] = true
    end

    if levelConfig.dropRules then
        for k, v in pairs(levelConfig.dropRules) do
            local realTileConst
            if type(v.itemID) == 'number' then
                realTileConst = v.itemID + 1
            else
                realTileConst = string.split(v.itemID, '_')[1] + 1
            end
            if TileToAtlasTypeMapping[realTileConst] then
                self.tileCollection[TileToAtlasTypeMapping[realTileConst]] = true
            end
        end
    end

    if levelConfig.routeRawData and #levelConfig.routeRawData > 0 then
        for r = 1, #levelConfig.routeRawData do
            for c = 1, #levelConfig.routeRawData[r] do
                local tileData = levelConfig.routeRawData[r][c]
                if tileData 
                and (tileData:hasProperty(RouteConst.kUp)
                    or tileData:hasProperty(RouteConst.kDown)
                    or tileData:hasProperty(RouteConst.kLeft)
                    or tileData:hasProperty(RouteConst.kRight)) then
                    self.tileCollection[AnimalGuideAtlasType.kSnail] = true
                    break
                end
            end
        end        
    end

    if (levelConfig.seaAnimalMap and #levelConfig.seaAnimalMap > 0) or (levelConfig.seaFlagMap and #levelConfig.seaFlagMap > 0) then
        self.tileCollection[AnimalGuideAtlasType.kSeaAnimal] = true
    end

    local count = 0
    for r = 1, #levelConfig.tileMap do
        for c = 1, #levelConfig.tileMap[r] do
            local tileConfig = levelConfig.tileMap[r][c]
            for tileConstKey, tileConstReference in pairs(TileToAtlasTypeMapping) do
                count = count + 1
                if tileConfig:hasProperty(tileConstKey) then
                    
                    if tileConstKey == TileConst.kGravitySkin then
                        --重力皮肤
                        if tonumber( tileConfig:getAttrOfProperty(TileConst.kGravitySkin) ) == BoardGravitySkinType.kWater then
                            self.tileCollection[AnimalGuideAtlasType.kWater] = true
                        end
                    else
                        self.tileCollection[tileConstReference] = true
                    end
                end
            end
        end
    end

    if levelConfig.digTileMap and #levelConfig.digTileMap then
        for r = 1, #levelConfig.digTileMap do
            for c = 1, #levelConfig.digTileMap[r] do
                local tileConfig = levelConfig.digTileMap[r][c]
                for tileConstKey, tileConstReference in pairs(TileToAtlasTypeMapping) do
                    count = count + 1
                    if tileConfig:hasProperty(tileConstKey) then
                        if tileConstKey == TileConst.kGravitySkin then
                            --重力皮肤
                            if tileConfig:getAttrOfProperty(TileConst.kGravitySkin) == BoardGravitySkinType.kWater then
                                self.tileCollection[AnimalGuideAtlasType.kWater] = true
                            end
                        else
                            self.tileCollection[tileConstReference] = true
                        end
                    end
                end
            end
        end
    end
end

function AnimalGuideAtlas:processConfig(levelConfig)
    self.tileCollection = {}
    for k, v in pairs(AnimalGuideAtlasType) do
        self.tileCollection[v] = false
    end

    local levelId = tonumber(levelConfig.level)
    if LevelType:isMainLevel(levelId) 
        or LevelType:isHideLevel(levelId) 
        or LevelType:isSummerMatchLevel(levelId) 
        or LevelType:isYuanxiao2017Level(levelId)
        or LevelType:isMoleWeeklyRaceLevel(levelId)
        or LevelType:isJamSperadLevel(levelId) 
        or LevelType:isSpringFestival2019Level(levelId) then
        
        self:mainLevelProcessConfig(levelConfig)
    end
    for k, v in pairs(PermanentAtlasTypes) do
        self.tileCollection[v] = true
    end

    -- if _G.isLocalDevelopMode then printx(0, 'count', count) end

    -- if _G.isLocalDevelopMode then printx(0, 'self.tileCollection') end
    -- if _G.isLocalDevelopMode then printx(0, table.tostring(self.tileCollection)) end

    -- sort
    self.config = {}
    for k, v in pairs(self.tileCollection) do
        if v == true then
            table.insert(self.config, k)
        end
    end


    -- if _G.isLocalDevelopMode then printx(0, 'self.config') end
    -- if _G.isLocalDevelopMode then printx(0, table.tostring(self.config)) end


    table.sort(self.config, 
        function (v1, v2)
            if _G.isLocalDevelopMode then printx(0, v1, v2) end
            if AnimalGuideAtlasWeight[v1] == AnimalGuideAtlasWeight[v2] then
                return v1 < v2
            else
                return AnimalGuideAtlasWeight[v1] > AnimalGuideAtlasWeight[v2] 
            end
        end)


end

function AnimalGuideAtlas:getConfig()
    return self.config
end