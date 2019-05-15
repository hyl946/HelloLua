------------------------------------------------------------------------------------
-- 地格类型
------------------------------------------------------------------------------------
local bit = require("bit")

NewFallingItemLogicBoundaryLevel = 1711
NewFallingItemLogicBoundaryHiddenLevel = 10142

TileConst = table.const
{
	kEmpty = 1,
	kAnimal = 2,
	kLight1 = 3,
	kLight2 = 4,	--两层冰
	kCannon = 5,	--生成口
	kBlocker = 6,	--障碍
	kFrosting = 7,	--冰霜
	kLock = 8,		--牢笼
	kFudge = 9,		--豆荚
	kCollector = 10,--收集口
	kPortal = 11,
	kPortalEnter = 12,--入口
	kPortalExit = 13,--出口
	kCoin = 14,
	kChamelleon = 15,--
	
	kLicoriceSquare = 17,
	kPepper = 18,
	kFrosting1 =  19,
	kFrosting2 =  20,
	kFrosting3 =  21,
	kFrosting4 =  22,
	kFrosting5 =  23,
	
	kWall = 25,		--墙
	kWallUp = 26,
	kWallDown = 27,
	kWallLeft = 28,
	kWallRight = 29,
	kLight3 = 30,
	kDigGround = 31,	--
	kGreyCute = 32,		--毛球
	kBrownCute = 33,	--
	kBlackCute = 34,	--黑色毛球
	kCrystal = 35,		--水晶
	kGift = 36,			--礼物

	kPoison = 37,		--毒液
	kNone = 38,			--空格子
	kCannonAnimal = 39,	--动物生成掉落口
	kCannonIngredient = 40,--原料掉落口
	kCannonBlock= 41,	--障碍生成掉落口
	kAddMove = 42, 		--增加步数的动物
	kDigGround_1 = 43,   ---挖地地块--多层
	kDigGround_2 = 44,
	kDigGround_3 = 45,
	kDigJewel_1 = 46,    --挖地-宝石块--多层
	kDigJewel_2 = 47,
	kDigJewel_3 = 48,

	kRoost = 49, 		--鸡窝
	kBalloon = 50, --气球
	kRabbitProducer = 51, --兔子生成口

	kPoisonBottle = 52, --毒液瓶
	kTileBlocker = 53,  --翻转地格
	kTileBlocker2 = 54, --2号翻转地格

	kBigMonster = 58,   --占四格的雪怪
	kBigMonsterFrosting1 = 59,
	kBigMonsterFrosting2 = 60,
	kBigMonsterFrosting3 = 61,
	kBigMonsterFrosting4 = 62,
					
	kMimosaLeft = 63,        -----含羞草
	kMimosaRight = 64,
	kMimosaUp = 65,
	kMimosaDown = 66,
	kMimosaLeaf = 67,

	--活动相关 四格boss 无尽劳动节模式
	kMayDayBlocker1 = 68,
	kMayDayBlocker2 = 69,
	kMayDayBlocker3 = 70,
	kMayDayBlocker4 = 71,
	--活动相关 无尽劳动模式 类似宝石
	kDigJewel_1_blue = 72,
	kDigJewel_2_blue = 73,
	kDigJewel_3_blue = 74,

	kMaydayBlockerEmpty = 75,

	kSnailSpawn = 76, 	--蜗牛生成口
	kSnail = 77,      	--蜗牛
	kSnailCollect = 78, --蜗牛收集口
	
	kTransmission = 80,  ---传送带
	kMagicLamp = 84, -- 神灯（别名：独眼、增益性障碍）
	kSuperBlocker = 87,	-- 无敌障碍
	kHoneyBottle = 88,  --蜂蜜罐子
	kHoney = 89,        --蜂蜜
	kAddTime	= 90, 	--增加时间的动物
	kMagicTile = 91,	-- 万圣节魔法地格
	kSand = 92, 	-- 流沙
	-----------------------------------------------这里开始地图使用新的数据结构
	kQuestionMark = 93,  --问号
	-- 冰柱 94~118
	kChain1 = 94,
	kChain1_Up = 95,
	kChain1_Right = 96,
	kChain1_Down = 97,
	kChain1_Left = 98,
	kChain2 = 99,
	kChain2_Up = 100,
	kChain2_Right = 101,
	kChain2_Down = 102,
	kChain2_Left = 103,
	kChain3 = 104,
	kChain3_Up = 105,
	kChain3_Right = 106,
	kChain3_Down = 107,
	kChain3_Left = 108,
	kChain4 = 109,
	kChain4_Up = 110,
	kChain4_Right = 111,
	kChain4_Down = 112,
	kChain4_Left = 113,
	kChain5 = 114,
	kChain5_Up = 115,
	kChain5_Right = 116,
	kChain5_Down = 117,
	kChain5_Left = 118,
	-- 魔法石 PC:firefly
	kMagicStone_Up = 119,
	kMagicStone_Right = 120,
	kMagicStone_Down = 121,
	kMagicStone_Left = 122,
	kHoney_Sub_Select = 123,   ---蜂蜜优先级的第二选择
	kCannonCoin = 124,
	kCannonCrystallBall = 125,
	kCannonBalloon = 126,
	kCannonHoneyBottle = 127,
	kCannonGreyCuteBall = 128,
	kCannonBrownCuteBall = 129,
	kCannonBlackCuteBall = 130,
	kMoveTile = 131, -- 移动地块
	kGoldZongZi = 135, --金粽子（已废弃）
	kBottleBlocker = 136, --妖精瓶子
	kCrystalStone = 142, --水晶石
	kRocket = 143, --火箭
	kCannonCrystalStone = 144,
	kHedgehog = 145,  --刺猬
	kHedgehogBox = 146, --刺猬宝箱
	kCannonRocket = 147,

	kKindMimosaLeft = 148,        ----新含羞草
	kKindMimosaRight = 149,
	kKindMimosaUp = 150,
	kKindMimosaDown = 151,

	kTotems = 154, -- 无敌小金刚（PC图腾）
	kCannonTotems = 156, -- 无敌小金刚生成口

	kWukong = 157,  --悟空（春节关卡的猴子）
	kWukongTarget = 158,  --悟空目标地块

	kLotusLevel1 = 159,  --草地（荷叶）一级
	kLotusLevel2 = 160,  --草地（荷叶）二级
	kLotusLevel3 = 161,  --草地（荷叶）三级
	kSuperCute = 162,	-- 无敌毛球
	kDrip = 163,  --水滴
	kCannonDrip = 164,  --水滴生成口

	kCannonCandyColouredAnimal = 165,  --指定颜色动物生成口
	kCannonCandyLineEffectColumn = 166,  --竖直线特效生成口
	kCannonCandyLineEffectRow = 167,  --横直线特效生成口
	kCannonCandyWrapEffect = 168,  --炸弹特效生成口
	kCannonCandyMagicBird = 169,  --魔力鸟生成口

	kPuffer = 170,  --河豚
	kPufferActivated = 171,  --被激活的河豚
	kCannonPuffer = 172,  --河豚生成口
	kCannonPufferActivated = 173,  --被激活的河豚生成口

	kDoubleSideTurnTile = 174,  --双面翻转地格
	kNewGift = 175, -- 新礼盒
	kOlympicBlocker = 176,
	kOlympicLockBlocker = 177,
	kPoisonPassSelect = 178,

	kMissile = 179,		-- 冰封导弹
	kCannonCandyMissile = 180, -- 冰封导弹生成口

	kChestSquare = 181, -- 大宝箱
	kChestSquare1 = 182, -- 大宝箱左上
	kChestSquare2 = 183, -- 大宝箱右上
	kChestSquare3 = 184, -- 大宝箱左下
	kChestSquare4 = 185, -- 大宝箱右下

	kRandomProp1 = 186, -- 道具云块1
	kRandomProp2 = 187,-- 道具云块2
	kRandomProp3 = 188,-- 道具云块3
	kRandomProp4 = 189,-- 道具云块4
	
	kBlockerCoverMaterial = 190,-- 木桩（用来生成小叶堆）
	kBlockerCover = 191,-- 小叶堆
	kBlockerCoverGenerateFixedFlag = 192,-- 小叶堆固定生成位置的Flag
	kBlockerCoverGenerateFlag = 193,-- 小叶堆随机生成位置的Flag

	kTangChicken = 194, -- 唐装鸡
	kBlocker195 = 195, --星星瓶
	kCannonBlocker195 = 196, --星星瓶生成口
	kWeeklyBoss = 197,  --周赛第二种boss
	kWeeklyBossEmpty = 198,	 --周赛第二种boss站位
	kBlocker199 = 199, --水母宝宝
	kBlocker200 = 200, --199障碍pc端站位
	kColorFilter = 201, --色彩过滤器
	kChameleon = 202,	--变色龙 / 谜之蛋
	kCannonChameleon = 203,		--变色龙生成口
	kPacman = 204,		--吃豆人
	kPacmansDen = 205,	--吃豆人小窝
	kBlocker206 = 206,--配对锁
	kBlocker207 = 207,--配对钥匙
	kCannonBlocker207 = 208,--配对钥匙生成口
	kBuffBoomPassSelect = 209,--BuffBoom放招目标过滤(包括buff和前置：无色炸弹和魔力鸟)(历史遗迹，新关卡应当用下面的PreAndBuffPassSelect系列)
	kBlocker211 = 211,--寄居蟹
    kTurret = 212,	--炮塔
	kMoleBossSeed = 213,	--周赛boss技能释放的种子
	kMoleBossCloud = 214,	--周赛boss技能释放的四格大云块
	kMoleBossCloudPossess = 215,	--周赛boss技能释放的四格大云块占位
    kYellowDiamondGrass1 = 216, --黄色钻石草地1级
    kYellowDiamondGrass2 = 217, --黄色钻石草地2级

    kGravityUp = 218,  --重力方向（上）
    kGravityDown = 219,  --重力方向（下）
    kGravityLeft = 220,  --重力方向（左）
    kGravityRight = 221,  --重力方向（右）

    kNewObject = 222,--已废弃。可以任意更改

    kGhost = 223,		--幽灵
    kGhostAppear = 224,	--幽灵生成位
    kGhostVanish = 225,	--幽灵收集位

	kGravitySkin = 226, --重力方向的显示效果

	kSunFlask = 227,		--太阳瓶子
    kSunflower = 228,		--向日葵

    kPreAndBuffFirecrackerPassSelect = 229,		--前置orBuff炸弹 屏蔽投掷点
    kPreAndBuffLineWrapPassSelect = 230,		--前置orBuff特效 屏蔽投掷点
    kPreAndBuffMagicBirdPassSelect = 231,		--前置orBuff魔力鸟 屏蔽投掷点

    kSquid = 232,			--鱿鱼
    kSquidEmpty = 233,		--鱿鱼占位
    kJamSperad = 234, --果酱模式

    kWanSheng = 235, --万能生成器
    kWanShengWrong = 236, --万能生成器 ×
    kWanShengRight = 237, --万能生成器 √
    kWanShengDrop = 238, --万能生成器 生成口

    kBiscuit = 239, -- 饼干

    -- 主线关新障碍添加后需要在SnapshotManager中添加相应逻辑，上传给AI学习
	kMaxTile = 240, -- 到250要注意了，看SnapshotManager的ItemProps, 有惊喜
	kInvalid = -1,
}

TileConstVirtual = {
	kSeaAnimalProduct = 20001,
}

TileConstName = table.const
{
	[TileConst.kLight1] = { name = "ice" , chsName = "冰块" , datas = 1 } ,
	[TileConst.kLight2] = { name = "ice" , chsName = "冰块" , datas = 2 } ,	--两层冰
	[TileConst.kLight3] = { name = "ice" , chsName = "冰块" , datas = 3 },
	[TileConst.kFrosting] = { name = "snow" , chsName = "雪块" } ,	--冰霜
	[TileConst.kLock] = { name = "cage" , chsName = "牢笼" },		--牢笼
	[TileConst.kFudge] = { name = "goldenPod" , chsName = "金豆荚" } ,		--豆荚
	[TileConst.kCoin] = { name = "coin" , chsName = "银币" } ,
	[TileConst.kFrosting1] =  { name = "snow" , chsName = "雪块" , datas = 1 } ,
	[TileConst.kFrosting2] =  { name = "snow" , chsName = "雪块" , datas = 2 } ,
	[TileConst.kFrosting3] =  { name = "snow" , chsName = "雪块" , datas = 3 } ,
	[TileConst.kFrosting4] =  { name = "snow" , chsName = "雪块" , datas = 4 } ,
	[TileConst.kFrosting5] =  { name = "snow" , chsName = "雪块" , datas = 5 } ,
	
	[TileConst.kWall] = { name = "rope" , chsName = "绳子" },		--墙
	[TileConst.kWallUp] = { name = "rope" , chsName = "绳子" , datas = 1 },
	[TileConst.kWallDown] = { name = "rope" , chsName = "绳子" , datas = 2 },
	[TileConst.kWallLeft] = { name = "rope" , chsName = "绳子" , datas = 3 },
	[TileConst.kWallRight] = { name = "rope" , chsName = "绳子" , datas = 4 },
	
	[TileConst.kDigGround] = { name = "cloud" , chsName = "云块" },	--
	[TileConst.kGreyCute] = { name = "greyFurball" , chsName = "灰色毛球" },		--毛球
	[TileConst.kBrownCute] = { name = "brownFurball" , chsName = "棕色毛球" } ,	--
	[TileConst.kBlackCute] = { name = "blackFurball" , chsName = "黑色毛球" },	--黑色毛球
	[TileConst.kCrystal] = { name = "crystalBall" , chsName = "水晶球" },		--水晶
	[TileConst.kGift] = { name = "gift" , chsName = "礼盒" , datas = "old" },			--礼物
	[TileConst.kNewGift] = { name = "gift" , chsName = "礼盒" , datas = "new" }, -- 新礼盒

	[TileConst.kPoison] = { name = "poison" , chsName = "毒液" },		--毒液

	[TileConst.kDigGround_1] = { name = "cloud" , chsName = "云块" , datas = 1 },   ---挖地地块--多层
	[TileConst.kDigGround_2] = { name = "cloud" , chsName = "云块" , datas = 2 },
	[TileConst.kDigGround_3] = { name = "cloud" , chsName = "云块" , datas = 3 },
	[TileConst.kDigJewel_1] = { name = "diamondCloud" , chsName = "宝石云块" , datas = 1 },    --挖地-宝石块--多层
	[TileConst.kDigJewel_2] = { name = "diamondCloud" , chsName = "宝石云块" , datas = 2 },
	[TileConst.kDigJewel_3] = { name = "diamondCloud" , chsName = "宝石云块" , datas = 3 },

	[TileConst.kRoost] = { name = "roost" , chsName = "鸡窝" }, 		--鸡窝
	[TileConst.kBalloon] = { name = "balloon" , chsName = "气球" }, --气球

	[TileConst.kPoisonBottle] = { name = "octopus" , chsName = "毒液章鱼" }, --毒液瓶
	[TileConst.kTileBlocker] = { name = "trapdoor" , chsName = "翻转地格" , datas = 1 },  --翻转地格
	[TileConst.kTileBlocker2] = { name = "trapdoor" , chsName = "翻转地格", datas = 2 }, --2号翻转地格

	[TileConst.kBigMonster] = { name = "yeti" , chsName = "雪怪" },   --占四格的雪怪
	[TileConst.kBigMonsterFrosting1] = { name = "yeti" , chsName = "雪怪" , datas = 1 },
	[TileConst.kBigMonsterFrosting2] = { name = "yeti" , chsName = "雪怪" , datas = 2 },
	[TileConst.kBigMonsterFrosting3] = { name = "yeti" , chsName = "雪怪" , datas = 3 },
	[TileConst.kBigMonsterFrosting4] = { name = "yeti" , chsName = "雪怪" , datas = 4 },
					
	[TileConst.kMimosaLeft] = { name = "mimosa" , chsName = "含羞草" , datas = 1 },        -----含羞草
	[TileConst.kMimosaRight] = { name = "mimosa" , chsName = "含羞草" , datas = 2 },
	[TileConst.kMimosaUp] = { name = "mimosa" , chsName = "含羞草" , datas = 3 },
	[TileConst.kMimosaDown] = { name = "mimosa" , chsName = "含羞草" , datas = 4 },
	[TileConst.kMimosaLeaf] = { name = "mimosa" , chsName = "含羞草" },

	[TileConst.kSnailSpawn] = { name = "snail" , chsName = "蜗牛" , datas = 2 }, 	--蜗牛生成口
	[TileConst.kSnail] = { name = "snail" , chsName = "蜗牛" , datas = 1 },      	--蜗牛
	[TileConst.kSnailCollect] = { name = "snail" , chsName = "蜗牛" , datas = 3 }, --蜗牛收集口
	
	[TileConst.kTransmission] = { name = "conveyor" , chsName = "传送带" },  ---传送带
	[TileConst.kMagicLamp] = { name = "genie" , chsName = "大眼仔" }, -- 神灯（别名：独眼、增益性障碍）
	[TileConst.kHoneyBottle] = { name = "honeyBottle" , chsName = "蜂蜜罐子" },  --蜂蜜罐子
	[TileConst.kHoney] = { name = "honey" , chsName = "蜂蜜" },        --蜂蜜
	[TileConst.kSand] = { name = "sand" , chsName = "流沙" }, 	-- 流沙
	-----------------------------------------------这里开始地图使用新的数据结构
	-- 冰柱 94~118
	[TileConst.kChain1] = { name = "icicle" , chsName = "魔法冰柱" , datas = 1 },
	[TileConst.kChain1_Up] = { name = "icicle" , chsName = "魔法冰柱" , datas = 11 },
	[TileConst.kChain1_Right] = { name = "icicle" , chsName = "魔法冰柱" , datas = 12 },
	[TileConst.kChain1_Down] = { name = "icicle" , chsName = "魔法冰柱" , datas = 13 },
	[TileConst.kChain1_Left] = { name = "icicle" , chsName = "魔法冰柱" , datas = 14 },
	[TileConst.kChain2] = { name = "icicle" , chsName = "魔法冰柱" , datas = 2 },
	[TileConst.kChain2_Up] = { name = "icicle" , chsName = "魔法冰柱" , datas = 21 },
	[TileConst.kChain2_Right] = { name = "icicle" , chsName = "魔法冰柱" , datas = 22 },
	[TileConst.kChain2_Down] = { name = "icicle" , chsName = "魔法冰柱" , datas = 23 },
	[TileConst.kChain2_Left] = { name = "icicle" , chsName = "魔法冰柱" , datas = 24 },
	[TileConst.kChain3] = { name = "icicle" , chsName = "魔法冰柱" , datas = 3 },
	[TileConst.kChain3_Up] = { name = "icicle" , chsName = "魔法冰柱" , datas = 31 },
	[TileConst.kChain3_Right] = { name = "icicle" , chsName = "魔法冰柱" , datas = 32 },
	[TileConst.kChain3_Down] = { name = "icicle" , chsName = "魔法冰柱" , datas = 33 },
	[TileConst.kChain3_Left] = { name = "icicle" , chsName = "魔法冰柱" , datas = 34 },
	[TileConst.kChain4] = { name = "icicle" , chsName = "魔法冰柱" , datas = 4 },
	[TileConst.kChain4_Up] = { name = "icicle" , chsName = "魔法冰柱" , datas = 41 },
	[TileConst.kChain4_Right] = { name = "icicle" , chsName = "魔法冰柱" , datas = 42 },
	[TileConst.kChain4_Down] = { name = "icicle" , chsName = "魔法冰柱" , datas = 43 },
	[TileConst.kChain4_Left] = { name = "icicle" , chsName = "魔法冰柱" , datas = 44 },
	[TileConst.kChain5] = { name = "icicle" , chsName = "魔法冰柱" , datas = 5 },
	[TileConst.kChain5_Up] = { name = "icicle" , chsName = "魔法冰柱" , datas = 51 },
	[TileConst.kChain5_Right] = { name = "icicle" , chsName = "魔法冰柱" , datas = 52 },
	[TileConst.kChain5_Down] = { name = "icicle" , chsName = "魔法冰柱" , datas = 53 },
	[TileConst.kChain5_Left] = { name = "icicle" , chsName = "魔法冰柱" , datas = 54 },
	-- 魔法石 PC:firefly
	[TileConst.kMagicStone_Up] = { name = "magicStone" , chsName = "魔法石" , datas = 1 },
	[TileConst.kMagicStone_Right] = { name = "magicStone" , chsName = "魔法石" , datas = 2 },
	[TileConst.kMagicStone_Down] = { name = "magicStone" , chsName = "魔法石" , datas = 3 },
	[TileConst.kMagicStone_Left] = { name = "magicStone" , chsName = "魔法石" , datas = 4 },

	[TileConst.kBottleBlocker] = { name = "explosiveBottle" , chsName = "魔法萌豆" }, --妖精瓶子
	[TileConst.kCrystalStone] = { name = "colorRobot" , chsName = "染色宝宝" }, --水晶石
	[TileConst.kRocket] = { name = "rocket" , chsName = "小火箭" }, --火箭

	[TileConst.kKindMimosaLeft] = { name = "mimosa" , chsName = "含羞草" , datas = 1 },        ----新含羞草
	[TileConst.kKindMimosaRight] = { name = "mimosa" , chsName = "含羞草" , datas = 2 },
	[TileConst.kKindMimosaUp] = { name = "mimosa" , chsName = "含羞草" , datas = 3 },
	[TileConst.kKindMimosaDown] = { name = "mimosa" , chsName = "含羞草" , datas = 4 },

	[TileConst.kTotems] = { name = "thunderBird" , chsName = "闪电鸟" }, -- 无敌小金刚（PC图腾）

	[TileConst.kLotusLevel1] = { name = "lotusPond" , chsName = "荷塘" , datas = 1 },  --草地（荷叶）一级
	[TileConst.kLotusLevel2] = { name = "lotusPond" , chsName = "荷塘" , datas = 2 },  --草地（荷叶）二级
	[TileConst.kLotusLevel3] = { name = "lotusPond" , chsName = "荷塘" , datas = 3 },  --草地（荷叶）三级
	[TileConst.kSuperCute] = { name = "whiteFurball" , chsName = "超级白毛球" },	-- 无敌毛球

	[TileConst.kPuffer] = { name = "pufferfish" , chsName = "气鼓鱼" , datas = 1 },  --河豚
	[TileConst.kPufferActivated] = { name = "pufferfish" , chsName = "气鼓鱼" , datas = 2 },  --被激活的河豚

	[TileConst.kMissile] = { name = "frozenMissile" , chsName = "冰封导弹" },		-- 冰封导弹
	
	[TileConst.kBlockerCoverMaterial] = { name = "stump" , chsName = "小树桩" },-- 木桩（用来生成小叶堆）
	[TileConst.kBlockerCover] = { name = "leafPile" , chsName = "小叶堆" , datas = 1 },-- 小叶堆
	[TileConst.kBlockerCoverGenerateFixedFlag] = { name = "leafPile" , chsName = "小叶堆" , datas = 2 },-- 小叶堆固定生成位置的Flag
	[TileConst.kBlockerCoverGenerateFlag] = { name = "leafPile" , chsName = "小叶堆" , datas = 3 },-- 小叶堆随机生成位置的Flag

	[TileConst.kBlocker195] = { name = "starBottle" , chsName = "星星瓶" }, --星星瓶
	[TileConst.kBlocker199] = { name = "jellyfish" , chsName = "小贝壳 水母宝宝" }, --水母宝宝
	[TileConst.kColorFilter] = { name = "colorFilter" , chsName = "过滤器" }, --色彩过滤器
	[TileConst.kChameleon] = { name = "chameleonEgg" , chsName = "染色蛋" },	--变色龙 / 谜之蛋
	[TileConst.kPacman] = { name = "pacman" , chsName = "蓄电精灵" , datas = 1 },		--吃豆人
	[TileConst.kPacmansDen] = { name = "pacman" , chsName = "蓄电精灵" , datas = 2 },	--吃豆人小窝
	[TileConst.kBlocker206] = { name = "padlock" , chsName = "钥匙和锁" , datas = 1 },--配对锁
	[TileConst.kBlocker207] = { name = "padlock" , chsName = "钥匙和锁" , datas = 2 },--配对钥匙
	[TileConst.kBlocker211] = { name = "hermitCrab" , chsName = "寄居蟹" },--寄居蟹
    [TileConst.kTurret] = { name = "turret" , chsName = "炮塔" },	--炮塔

    [TileConst.kAddTime]	= { name = "addTimeAnimal" , chsName = "加5秒动物" }, 	--增加时间的动物
	[TileConst.kGhost] = { name = "ghost" , chsName = "幽灵", datas = 1},	-- 幽灵
	[TileConst.kGhostAppear] = { name = "ghost" , chsName = "幽灵", datas = 2},
	[TileConst.kSunFlask] = { name = "sunFlask" , chsName = "太阳瓶子"},
	[TileConst.kSunflower] = { name = "sunflower" , chsName = "向日葵"},
	[TileConst.kSquid] = { name = "squid" , chsName = "鱿鱼"},

    [TileConst.kJamSperad] = { name = "JamSperad" , chsName = "果酱"}, --果酱

    [TileConst.kWanSheng] = { name = "lotus" , chsName = "万生"}, --万生
    [TileConst.kWanShengRight] = { name = "WanShengRight" , chsName = "万生×"}, --万生×
    [TileConst.kWanShengWrong] = { name = "WanShengWrong" , chsName = "万生√"}, --万生√
    [TileConst.kWanShengDrop] = { name = "WanShengDrop" , chsName = "万生生成口"}, --万生生成口

    [TileConst.kBiscuit] = { name = "biscuit" , chsName = "饼干"},
}

-------------------------------
-- 通用方向定义
-------------------------------
DefaultDirConfig = table.const {
	kUp = 1,
	kRight = 2,
	kDown = 3,
	kLeft = 4,
}

------------------------------------------------------------------------------------
-- 墙的方向定义
------------------------------------------------------------------------------------
DirConfig = table.const
{
	kUp = 1,
	kDown = 2,
	kLeft = 3,
	kRight = 4
}

---------------------------------
-- 冰柱方向定义
---------------------------------
ChainDirConfig = table.const {
	kUp = 1,
	kRight = 2,
	kDown = 3,
	kLeft = 4,
}

-------------------------------
-- 魔法石方向定义
-------------------------------
MagicStoneDirConfig = table.const {
	kUp = 1,
	kRight = 2,
	kDown = 3,
	kLeft = 4,
}

GameItemSuperCuteBallState = table.const {
	kNone = 0,
	kActive = 1,
	kInactive = 2,
}

local recordInt = nil
local randFactory = nil
local function genRandomInteger()
	if not recordInt then
		randFactory = HERandomObject()
		randFactory:randSeed(os.time())
		recordInt = randFactory:rand(1, 100)
	end
	recordInt = recordInt + randFactory:rand(1, 100)
	return recordInt
end

local _colorTypeMt = {
	__eq = function(op1, op2)
		return op1.a == op2.a and op1.b == op2.b
	end
}

local function _createColorTypeObj(originObj)
	setmetatable(originObj, _colorTypeMt)
	return originObj
end

------------------------------------------------------------------------------------
-- 动物类型
------------------------------------------------------------------------------------
AnimalTypeConfig =
{
    kNone = 30,
	kRandom = 0, 
	
	kLine = genRandomInteger(), 
	kColumn = genRandomInteger(), 
	kWrap = genRandomInteger(), 
	kColor = genRandomInteger(), 
	kDrip = genRandomInteger(), 

	-- 随便写的数字, a/b不完全一致就行了
	kBlue = _createColorTypeObj({a = 1, b = 1}),
	kGreen = _createColorTypeObj({a = 1, b = 2}),
	kOrange = _createColorTypeObj({a = 1, b = 3}), 
	kPurple = _createColorTypeObj({a = 2, b = 1}), 
	kRed = _createColorTypeObj({a = 2, b = 2}), 
	kYellow = _createColorTypeObj({a = 2, b = 3}), 
	
	fRandom = 0x0,		
	fBlue = 0x2, 		
	fGreen = 0x4, 		
	fOrange = 0x8, 		
	fPurple = 0x10, 
	fRed = 0x20, 
	fYellow = 0x40,

	fLine = 0x80,
	fColumn = 0x100,
	fWrap = 0x200,
	fColor = 0x400,
}

local colorTypeList = {
	AnimalTypeConfig.kBlue, --蓝色
	AnimalTypeConfig.kGreen, --绿色
	AnimalTypeConfig.kOrange, --棕色
	AnimalTypeConfig.kPurple,--紫色 
	AnimalTypeConfig.kRed, --红色
	AnimalTypeConfig.kYellow,--黄色
	--AnimalTypeConfig.kDrip,
}
AnimalTypeConfig.colorTypeList = colorTypeList

---颜色table与颜色ID的对照，这个ID只是为了更直观地识别颜色，没什么别的用
-- local colorTableToIndex = { 
-- 	[AnimalTypeConfig.kBlue] = 1, 
-- 	[AnimalTypeConfig.kGreen] = 2, 
-- 	[AnimalTypeConfig.kOrange] = 3, 
-- 	[AnimalTypeConfig.kPurple] = 4, 
-- 	[AnimalTypeConfig.kRed] = 5, 
-- 	[AnimalTypeConfig.kYellow] = 6,
-- 	[AnimalTypeConfig.kDrip] = 99
-- }
-- AnimalTypeConfig.colorTableToIndex = colorTableToIndex

local specialTypeList = {
	AnimalTypeConfig.kLine,
	AnimalTypeConfig.kColumn,
	AnimalTypeConfig.kWrap,
	AnimalTypeConfig.kColor,
	AnimalTypeConfig.kDrip,
}
AnimalTypeConfig.specialTypeList = specialTypeList

AnimalTypeConfig.reinit = function ()
	colorTypeList = {
		AnimalTypeConfig.kBlue, --蓝色
		AnimalTypeConfig.kGreen, --绿色
		AnimalTypeConfig.kOrange, --棕色
		AnimalTypeConfig.kPurple,--紫色 
		AnimalTypeConfig.kRed, --红色
		AnimalTypeConfig.kYellow,--黄色
		--AnimalTypeConfig.kDrip,
	}
	AnimalTypeConfig.colorTypeList = colorTypeList

	specialTypeList = {
		AnimalTypeConfig.kLine,
		AnimalTypeConfig.kColumn,
		AnimalTypeConfig.kWrap,
		AnimalTypeConfig.kColor,
		AnimalTypeConfig.kDrip,
	}
	AnimalTypeConfig.specialTypeList = specialTypeList
end

RouteConst = table.const{
	kUp = 1, 
	kDown = 2, 
	kLeft = 3,
	kRight = 4,

	kSimple = 5, 
	kOverLap = 6,
	kCross = 7,

	kMaxTile = 8,		--
	kInvalid = -1,		--
}

---问号障碍可以生成的类型
UncertainCfgConst = table.const{
	kCanFalling = 1,      ------可以掉落的
	kCannotFalling = 2,   ------不能掉落
	kSpecial = 3,         ------特效
	kProps = 4,         	  ------道具
}

function AnimalTypeConfig.getType(value)
	if value == 0 then return 0 end

	local color = 0

	if bit.band(value, AnimalTypeConfig.fBlue) ~= 0 then color = AnimalTypeConfig.kBlue
	elseif bit.band(value, AnimalTypeConfig.fGreen) ~= 0 then color = AnimalTypeConfig.kGreen
	elseif bit.band(value, AnimalTypeConfig.fOrange) ~= 0 then color = AnimalTypeConfig.kOrange
	elseif bit.band(value, AnimalTypeConfig.fPurple) ~= 0 then color = AnimalTypeConfig.kPurple
	elseif bit.band(value, AnimalTypeConfig.fRed) ~= 0 then color = AnimalTypeConfig.kRed
	elseif bit.band(value, AnimalTypeConfig.fYellow) ~= 0 then color = AnimalTypeConfig.kYellow
	else color = AnimalTypeConfig.kRandom end

	return color
end

function AnimalTypeConfig.getSpecial(value)
	if value == 0 then return 0 end

	local special = 0
	if bit.band(value, AnimalTypeConfig.fLine) ~= 0 then special = AnimalTypeConfig.kLine
	elseif bit.band(value, AnimalTypeConfig.fColumn) ~= 0 then special = AnimalTypeConfig.kColumn
	elseif bit.band(value, AnimalTypeConfig.fWrap) ~= 0 then special = AnimalTypeConfig.kWrap
	elseif bit.band(value, AnimalTypeConfig.fColor) ~= 0 then special = AnimalTypeConfig.kColor end
	
	return special
end

function AnimalTypeConfig.isSpecialAnimal(itemSpecialType, excludeColour)
	if itemSpecialType == AnimalTypeConfig.kLine or itemSpecialType == AnimalTypeConfig.kColumn 
		or itemSpecialType == AnimalTypeConfig.kWrap then
		return true
	end
	if not excludeColour and itemSpecialType == AnimalTypeConfig.kColor then
		return true
	end

	return false
end

function AnimalTypeConfig.isColorTypeValid(color)
	return table.includes(colorTypeList, color)
end

function AnimalTypeConfig.isSpecialTypeValid(specialType)
	return table.includes(specialTypeList, specialType)	
end

function AnimalTypeConfig.convertColorTypeToIndex(color)
	if color == 0 then return 0 end
	return table.indexOf(colorTypeList, color)
end

function AnimalTypeConfig.convertSpecialTypeToIndex(specialType)
	if specialType == 0 then return 0 end
	return table.indexOf(specialTypeList, specialType)
end

function AnimalTypeConfig.convertIndexToColorType(index)
	if type(index) == "number" then
		return colorTypeList[index]
	end
	return nil
end

function AnimalTypeConfig.generateColorType(copyColor)
	if type(copyColor) == 'number' then
		return copyColor
	elseif type(copyColor) == 'table' then
		return table.clone(copyColor)
	end
end

function AnimalTypeConfig.getOriginColorValue(color)
	if type(color) == 'number' then
		return color
	elseif type(color) == 'table' then
		for _, c in ipairs(colorTypeList) do
			if c == color then
				return c
			end
		end
	end
end

------------------------------------------------------------------------------------
-- 动物特殊类型定义
------------------------------------------------------------------------------------
-- SpecialType = table.const 
-- {
-- 	kNone = 0x0,
-- 	kCoin = 0x2,
-- 	kWrap = 0x4,
-- 	kLine = 0x8,
-- 	kColor = 0x10,
-- 	kColumn = 0x20,
-- 	kDropDownIngredient = 0x40,
-- 	kLicoriceSquare = 0x80,
-- 	kChamelleon = 0x100,
-- 	kCrystalBall = 0x200,
-- 	kGift = 0x400
-- }

-- function SpecialType.isWrap(value) return value == SpecialType.kWrap end
-- function SpecialType.isColor(value) return value == SpecialType.kColor end
-- function SpecialType.isLine(value) return value == SpecialType.kLine end
-- function SpecialType.isColumn(value) return value == SpecialType.kColumn end
-- function SpecialType.isStripe(value) return SpecialType.isLine(value) or SpecialType.isColumn(value) end
-- function SpecialType.isDropDownIngredient(value) return value == SpecialType.kDropDownIngredient end
-- function SpecialType.isLicoriceSquare(value) return value == SpecialType.kLicoriceSquare end
-- function SpecialType.isCoin(value) return value == SpecialType.kCoin end
-- function SpecialType.isChameleon(value) return value == SpecialType.kChamelleon end
-- function SpecialType.isLicoriceSquareOrDropDown(value) return SpecialType.isDropDownIngredient(value) or SpecialType.isLicoriceSquare(value) end
-- function SpecialType.isCrystalBall(value) return value == SpecialType.kCrystalBall end
-- function SpecialType.isGift(value) return value == SpecialType.kGift end
-- function SpecialType.isNormalCandy(value) return value == SpecialType.kNone end
-- function SpecialType.translateToTileFlag(value)
-- 	if table.indexOf({SpecialType.kNone, SpecialType.kWrap, SpecialType.kLine, SpecialType.kColor, SpecialType.kColumn}, value) then
-- 		return TileConst.kAnimal
-- 	elseif value == SpecialType.kCoin then
-- 		return TileConst.kCoin
-- 	elseif value == SpecialType.kLicoriceSquare then
-- 		return TileConst.kLicoriceSquare
-- 	elseif value ==  SpecialType.kChamelleon then
-- 		return TileConst.kChamelleon
-- 	elseif value == SpecialType.kCrystalBall then
-- 		return TileConst.kCrystal
-- 	elseif value == SpecialType.kGift then
-- 		return TileConst.kGift
-- 	end
	
-- 	return TileConst.kEmpty
-- end

------------------------------------------------------------------------------------
-- 深度
------------------------------------------------------------------------------------
ItemViewDepth = table.const {kBackground = 0, kLightUp = 1, kAnimal = 2, kCuteBall = 3, kBlock = 4, kLock = 5, kWall = 6, kEffect = 7}

------------------------------------------------------------------------------------
-- 动物图像映射配置
------------------------------------------------------------------------------------

ItemViewBridge = table.const
{
	kYellow = 0,
	kYellowH = 1,
	kYellowV = 2,
	kYellowW = 3,
	kGreen = 4,
	kGreenH = 5,
	kGreenV = 6,
	kGreenW = 7,
	kOrange = 8,
	kOrangeH = 9,

	kOrangeV = 10,
	kOrangeW = 11,
	kPurple = 12,
	kPurpleH = 13,
	kPurpleV = 14,
	kPurpleW = 15,
	kBlue = 16,
	kBlueH = 17,
	kBlueV = 18,
	kBlueW = 19,
	kRed = 20,
	kRedH = 21,
	kRedV = 22,
	kRedW = 23,
	kColor = 24,
	kHazelnut = 25,
	kCherry = 26,
	kBackground = 27,
	kLight1 = 28,
	kLight2 = 29,
	kLight3 = 30,
	kLock = 31,
	kFrosting = 39,
	kCoin = 40
}

function ItemViewBridge:getGiftItemViewByColor(color)
	local value = 0

	if color == AnimalTypeConfig.kBlue then value = 46
	elseif color == AnimalTypeConfig.kGreen then value = 49
	elseif color == AnimalTypeConfig.kOrange then value = 47
	elseif color == AnimalTypeConfig.kPurple then value = 45
	elseif color == AnimalTypeConfig.kRed then value = 44
	elseif color == AnimalTypeConfig.kYellow then value = 48
	end

	return value
end

function ItemViewBridge:getBlockerViewByStrength(value)
	return 31 + value
end

function ItemViewBridge:getWallViewByDir(dir)
	return 39 - math.ceil(dir / 2)
end

function ItemViewBridge:getCuteBallViewByType(value)
	if value == CuteBallType.kGrey then return 41
	elseif value == CuteBallType.kBrown then return 43
	elseif value == CuteBallType.kBlack then return 42
	end
end

function ItemViewBridge:getCrystalBall(color)
	if color == AnimalTypeConfig.kBlue then value = 50
	elseif color == AnimalTypeConfig.kGreen then value = 53
	elseif color == AnimalTypeConfig.kOrange then value = 52
	elseif color == AnimalTypeConfig.kPurple then value = 55
	elseif color == AnimalTypeConfig.kRed then value = 51
	elseif color == AnimalTypeConfig.kYellow then value = 54
	end
	return value
end

function ItemViewBridge:getFrameName(value)
	return string.format("animal_item_1%04d", value)
end

------------------------------------------------------------------------------------
-- 毛球定义
------------------------------------------------------------------------------------
CuteBallType = {kNone = -1, kGrey = 1, kBrown = 2, kBlack = 3}
		
function CuteBallType.tileToCuteBallType(tile)
	if tile:hasProperty(TileConst.kGreyCute) then
		return CuteBallType.kGrey
	elseif tile:hasProperty(TileConst.kBrownCute) then
		return CuteBallType.kBrown
	elseif tile:hasProperty(TileConst.kBlackCute) then
		return CuteBallType.kBlack
	else
		return CuteBallType.kNone
	end
end

------------------------------------------------------------------------------------
-- 星星瓶收集类型定义
------------------------------------------------------------------------------------
Blocker195CollectType = table.const{
	kLine = "1-7^1-8",		--直线或竖线特效
	kWrap = "1-9",			--范围特效
	kLock = "7",			--牢笼
	kCoin = "13",			--银币
	kSnow = "18",   		--雪块
	kGreyCute = "31",		--灰毛球
	kBrownCute = "32",		--褐毛球
	kBlackCute = "33",		--黑毛球
	kPoison = "36",     	--毒液
	kDigGround = "42",  	--云块
	kHoneyBottle = "87",	--蜂蜜罐子
	kHoney = "88",      	--蜂蜜
	kSand = "91", 			-- 流沙
	kBottleBlocker = "135", --妖精瓶子
	kSuperCute = "161",     --白毛球
	kPuffer = "170", 		--气鼓鱼
	kMissile = "178", 		--冰封导弹
	kColorFilter = "200",  	--色彩过滤器
	kChameleon = "201", 	--变色龙
	kGhost = "222", 		--幽灵
}

Blocker195CollectTypeInOrder = {
	Blocker195CollectType.kLine,			--1
	Blocker195CollectType.kWrap,			--2
	Blocker195CollectType.kLock,			--3
	Blocker195CollectType.kCoin,			--4
	Blocker195CollectType.kSnow,			--5
	Blocker195CollectType.kGreyCute,		--6
	Blocker195CollectType.kBrownCute,		--7
	Blocker195CollectType.kBlackCute,		--8
	Blocker195CollectType.kPoison,			--9
	Blocker195CollectType.kDigGround,		--10
	Blocker195CollectType.kHoneyBottle,		--11
	Blocker195CollectType.kHoney,			--12
	Blocker195CollectType.kSand,			--13
	Blocker195CollectType.kBottleBlocker,	--14
	Blocker195CollectType.kSuperCute,		--15
	Blocker195CollectType.kPuffer,			--16
	Blocker195CollectType.kMissile,			--17
	Blocker195CollectType.kColorFilter,		--18
	Blocker195CollectType.kChameleon,		--19
	Blocker195CollectType.kGhost,			--20
}

------------------------------------------------------------------------------------
-- 鱿鱼收集物，虽初始与星星瓶相同，但难保以后，故写为两份
------------------------------------------------------------------------------------
SquidCollectType = table.const{
	100001,		--直线或竖线特效
	100002,		--范围特效
	TileConst.kLock,		--牢笼  8
	TileConst.kCoin,		--银币  14
	TileConst.kFrosting1,   --雪块  19
	TileConst.kGreyCute,	--灰毛球  32
	TileConst.kBrownCute,	--褐毛球  33
	TileConst.kBlackCute,	--黑毛球  34
	TileConst.kPoison,     	--毒液  37
	TileConst.kDigGround_1, --云块  43
	TileConst.kHoneyBottle,	--蜂蜜罐子  88
	TileConst.kHoney,      	--蜂蜜  89
	TileConst.kSand, 		-- 流沙  92
	TileConst.kBottleBlocker, 	--妖精瓶子  136
	TileConst.kSuperCute,     	--白毛球  162
	TileConst.kPufferActivated, --气鼓鱼  171
	TileConst.kMissile, 		--冰封导弹  179
	TileConst.kColorFilter, --色彩过滤器  201
	TileConst.kChameleon, 	--变色龙  202
	TileConst.kGhost, 		--幽灵  223
}
