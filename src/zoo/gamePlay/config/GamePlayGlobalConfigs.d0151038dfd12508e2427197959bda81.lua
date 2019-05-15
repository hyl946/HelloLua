GameItemType = table.const
{
	kNone = 0,				--空
	kAnimal = 1,			--动物--包括豆荚
	kSnow = 2,				--雪块
	kCoin = 4,				--银币
	kCrystal = 5,			--水晶--随机变化动物信息
	kGift = 6,				--礼盒	--TBD
	kIngredient = 7,		--豆荚
	kVenom = 8,				--毒液
	kRoost = 9, 			--鸡窝
	kBalloon = 10,          --气球
	kDigGround = 11,        --挖地地块
	kDigJewel = 12,         --挖地宝石块
	kAddMove = 13, 			--加步数的动物
	kPoisonBottle = 14,     --毒液瓶 -- ps.就是章鱼
	kBigMonster = 15,       --巨型怪物
	kBigMonsterFrosting = 16, --大怪物的雪块
	kBlackCuteBall = 17,        --黑色毛球
	kMimosa  = 18,          ---含羞草
	kSnail   = 19,          --蜗牛
	kBoss = 20,             --四格boss，无尽劳动节模式，可换皮
	kRabbit = 21,           --兔子
	kMagicLamp = 22,		-- 神灯
	kSuperBlocker = 23, 	-- 无敌障碍
	kHoneyBottle = 24,      --蜂蜜罐子
	kAddTime	= 25,		--加时间的动物
	kQuestionMark = 26,     --问号
	kMagicStone = 27, 		-- 魔法石
	kGoldZongZi = 28,       --金粽子，类似kDigJewel，自带一层云（已废弃）
	kBottleBlocker = 29,    --瓶子妖精障碍
	kHedgehogBox = 30,      --刺猬宝箱
	kRocket = 31, 			--火箭
	kKindMimosa = 32,       --新含羞草
	kCrystalStone = 33,		--染色宝宝
	kWukong = 34,  --悟空（春节关卡的猴子）
	kTotems = 35,		 	--无敌小金刚 闪电鸟
	kLotus = 36,		 	--草地（荷叶）
	kDrip = 37,		 	--水滴
	kPuffer = 38,		 	--河豚
	kNewGift = 39,		-- 新礼盒
	kOlympicBlocker = 40,	--奥运宝石障碍
	kMissile = 41,		-- 冰封导弹
	kChestSquare = 42,  -- 大宝箱
	kChestSquarePart = 43, -- 大宝箱的一部分
	kRandomProp = 44, -- 道具云块 ，1-4为4类道具云块
	
	kTangChicken = 45, --唐装鸡
	kWeeklyBoss = 46,   	 --周赛第二种四格boss
	kBlocker195 = 47, --星星瓶
	kBlocker199 = 48,	--水母
	kChameleon = 49,	--变色龙
	kBuffBoom = 50,	--Buff炸弹
	kBlocker207 = 51, --钥匙
	kPacman = 52, --吃豆人
	kPacmansDen = 53, --吃豆人小窝
	kBlocker211 = 54, --寄居蟹

	kMoleBossSeed = 55, --周赛boss技能释放的种子
	kMoleBossCloud = 56, --周赛boss技能释放的四格大云块
    kYellowDiamondGrass = 57, --周赛黄宝石
	kTurret = 58, --炮塔
	kScoreBuffBottle = 59, --刷星瓶子
	kSunFlask = 60,			--太阳砂瓶子
	kSunflower = 61,		--向日葵
	kFirecracker = 62,		--爆竹（前置道具 & buff活动用）
	kSquid = 63,			--鱿鱼,墨鱼宝宝
	kSquidEmpty = 64,		--鱿鱼占位

    kJamSperad = 65, --果酱
    kWanSheng = 66, --万生
}

GameItemStatusType = table.const
{
	kNone = 0,				--正常状态-无需处理
	kIsMatch = 1,			--被Match的状态-----》冰层减少，周围一些Match响应的物体进行响应
	kIsSpecialCover = 2,	--被特效扫描到了
	-- kIsMatchCover = 3,		--同时被Match以及被扫描到,已废弃
	kIsFalling = 4,			--开始掉落
	kJustStop = 5,
	kItemHalfStable = 6,	--半稳定状态
	kWaitBomb = 7,			--等待爆炸的状态，只能爆炸，不能掉落
	kDestroy = 8,			--销毁过程,从开始爆破到彻底消失
	kMatchMix = 9,
	kJustArrived = 10,      --新掉落算法使用。掉落过程中，掉落了完整的一格后的状态，此状态下将检测是否能够继续掉落，能则切换为kIsFalling，否则切换为kItemHalfStable
}


DirectionType = table.const
{
	kUp = 1 ,
	kDown = 2 ,
	kLeft = 3 ,
	kRight = 4 ,
}

------------------- 地鼠周赛SKILL  ------------------------
MoleWeeklyBossSkillType = table.const
{
    THICK_HONEY = "f",
    DEAVTIVATE_MAGIC_TILE = "s",
    FRAGILE_BLACK_CUTEBALL = "m",
    SEED = "t",
    BIG_CLOUD_BLOCK = "cC",
    SMALL_CLOUD_BLOCK_1 = "cA",
    SMALL_CLOUD_BLOCK_2 = "cB",
    SUB_ADD_SPECIAL = "AddSpecial",
    SUB_SEED_COUNT_DOWN = "SeedCountDown"
}

-- DIG_GENERATE_CIRCLE_START_ROW: 从digmap的第几行开始循环
MoleWeeklyRaceParam = table.const
{
    BOSS_REGENERATE_ROW_COUNT = 2,
    SCROLL_GROUND_MIN_LIMIT = 2,
    SCROLL_GROUND_MAX_LIMIT = 4,
    HEAL_SETTLE_ROUND = 2,
    PICK_TARGET_PRIORITY_ROW = 5,
    PICK_TARGET_PRIORITY_ROW_2 = 6,
    MAGIC_TILE_MAX_LIFE = 4,
    MAGIC_TILE_BLAST_SPLIT = 6,
    SKILL_CLOUD_HP = 4,
    SKILL_CLOUD_SPECIAL_HIT_EFFECT = 2,
    SKILL_CLOUD_DESTROY_JEWEL = 15,
    JEWEL_CLOUD_SCORE = 150,
    DIG_GENERATE_CIRCLE_START_ROW = 11,
}
--------------------------------------------------------------



GamePropsType = table.const
{
	kNone = 0,					--空
	kRefresh = 10001,			--游戏中 刷新
	kBack = 10002,				--游戏中 后退一步
	kSwap = 10003,				--游戏中 强制交换
	kAdd5 = 10004,				--游戏中 +5步
	kBombAdd5 = 10078,			--周赛游戏中 +5步 清全屏 
	kAdd15 = 10086,
	kAdd1 = 10115,
	kAdd2 = 10116,
	kLineBrush = 10005,			--游戏中 条纹刷子
	kColorBrush_b = 10006,		--游戏前置 球----魔力鸟	----随机
	kWrap_b = 10007,			--游戏前置 糖纸
	kColorBrush = 10008,		--游戏中 颜色刷子
	kTelescope = 10009,			--游戏中 望远镜
	kHammer = 10010,			--游戏中 锤子

	kRefresh_b = 10015,			--游戏前置 刷新
	kBack_b = 10016,			--游戏前置 后退一步
	kSwap_b = 10017,			--游戏前置 强制交换
	kAdd3_b = 10018,			--游戏前置 +3
	kLineBrush_b = 10019,		--游戏前置 条纹刷子
	kHammer_b = 10024,			--游戏前置 锤子
	kWrapBomb_b = 10081,		--游戏前置 爆炸
	kLineBomb_b = 10082, 		--游戏前置 直线

	kRefresh_l = 10025,			--临时刷新
	kHammer_l = 10026,			--临时锤子
	kLineBrush_l = 10027,		--临时条纹刷子
	kSwap_l	= 10028,			--临时强制交换

	kOctopusForbid = 10052,		--章鱼冰道具
	kOctopusForbid_l = 10053,	--章鱼冰道具 临时
	kRandomBird    =  10055, 	--随机魔力鸟
	kBroom			= 10056,	--女巫扫把
	kBroom_l		= 10057,    --女巫扫把 临时

	kBack_l          = 10065,    --后退 临时

	kBuffBoom_b     = 10089,    --开局导弹
	kRandomBird_b	= 10087,

	kFirecracker_b	= 10099,	-- 开局爆竹

	kMoleWeeklyRaceSPProp = 99995,  --鼹鼠周赛道具大招
	kSectionResumeBack = 99996,  --断面恢复虚拟道具，游戏业务逻辑不会使用
	kWukongJump = 99997,    --使蜗牛疯狂
	kHedgehogCrazy = 99998,    --使蜗牛疯狂
	kSpringFirework = 99999, 	--春节爆竹
	kNationDay2017Cast = 99996, 	--国庆技能

    kJamSpeardHummer = 10103, 		--果酱锤子

    kRowEffect = 10105,			--游戏中 横特效
    kRowEffect_l = 10108,		--游戏中 横特效(临时)
    kColumnEffect = 10109,		--游戏中 竖特效
    kColumnEffect_l = 10112,	--游戏中 竖特效(临时)

    kSpringSkill1 = 99991, --春节技能 
    kSpringSkill2 = 99992, --春节技能 
    kSpringSkill2 = 99993, --春节技能 
    kSpringSkill4 = 99994, --春节技能 
}

GamePlayStatus = table.const
{
	kPreStart = 0,			----游戏开始前（面板、前置道具等）
	kNormal = 1,			----正常游戏
	kEnd = 2,				----满足结束条件
	kBonus = 3,				----BonusTime
	kAferBonus = 4,    		----Bonus结束
	kWin = 5,				----赢了
	kFailed = 6,			----输了
}

-- 支持使用后 用回退道具返还的道具
SupportBackPropTypes = table.const
{
	GamePropsType.kRefresh,
	GamePropsType.kRefresh_b,
	GamePropsType.kRefresh_l,

	GamePropsType.kSwap,
	GamePropsType.kSwap_l,
	GamePropsType.kSwap_b,

	GamePropsType.kLineBrush,
	GamePropsType.kLineBrush_l, 
	GamePropsType.kLineBrush_b,

	GamePropsType.kHammer,
	GamePropsType.kHammer_l,
	GamePropsType.kHammer_b,

	GamePropsType.kOctopusForbid,
	GamePropsType.kOctopusForbid_l,

	GamePropsType.kRandomBird,

	GamePropsType.kBroom,
	GamePropsType.kBroom_l,

	GamePropsType.kRowEffect,
	GamePropsType.kRowEffect_l,
	GamePropsType.kColumnEffect,
	GamePropsType.kColumnEffect_l,

}