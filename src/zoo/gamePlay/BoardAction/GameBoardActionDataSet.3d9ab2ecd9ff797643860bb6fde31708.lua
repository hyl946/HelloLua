require "zoo.gamePlay.GamePlayConfig"

--存储游戏Item的动画效果对应数据列表

GameBoardActionDataSet = class{}

GameActionTargetType = table.const	--总体动作分类
{
	kNone = 0,					--空
	kGameBoardAction = 1,		--游戏面板操作动画类型
	kGameItemAction = 2,		--游戏Item自动动画类型
	kPropsAction = 3,			--游戏道具动画类型
	kTopPartAction = 4, 		--关卡内顶部部分动画类型（包括进度掉 关卡目标 分数等）
}

GameBoardActionType = table.const	--关卡正常操作动画细节
{
	kNone = 0,						--无动画
	kStartTrySwapItem = 1,			--尝试交换两个物体
	kStartTrySwapItemFailed = 2,	--交换两个物体失败的回弹动画
	kStartTrySwapItem_fun = 3,		--搞笑式交换（被墙挡住了）
	kStartBonusTime = 4,			--开始奖励时间
	kStartBonusTime_ItemFlying = 5,	--奖励时间的飞行特效
	kTileMove = 6,					--移动地块移动
	kStartTrySwapItemSuccess = 7,   --交换成功
	kItem_Special_Mix = 8, -- 合成特效
}

GameItemActionType = table.const	--Item自动播放动画细节
{
	kNone = 0,
	kItemDeletedByMatch = 2,		--因为match消除-----播放消除动画，同时进行相应计算
	kItemCoverBySpecial = 3,		--已废弃

	kItemSpecial_Line = 4,			--Item处发起直线特效_横排
	kItemSpecial_Column = 5,		--Item处发起直线特效_竖排
	kItemSpecial_Wrap = 6,			--区域特效爆炸
	kItemSpecial_Color = 7,			--鸟特效
	kItemSpecial_Color_ItemDeleted = 8, 	 --鸟和animal交换之后，同颜色的引起爆炸或者被吸走
	kItemSpecial_ColorLine = 9,		--鸟和直线特效交换
	kItemSpecial_ColorLine_flying = 10, 		--鸟和直线特效交换之后，飞出多个直线特效
	kItemSpecial_ColorWrap = 11,	--鸟和区域特效交换
	kItemSpecial_ColorWrap_flying = 12,			--鸟和区域特效交换,飞出多个区域特效
	kItemCoverBySpecial_Color = 13,				--鸟消除自己

	-- kItemSpecial_ColorColor = 14,				--鸟鸟消除
	kItemSpecial_ColorColor_part1 = 14,					--鸟鸟消除第一部分：鸟自身消除
	kItemSpecial_ColorColor_part2 = 215,				--鸟鸟消除第二部分：棋盘特效消除
	kItemSpecial_ColorColor_part3 = 216,				--鸟鸟消除第三部分：全屏消除

	kItemSpecial_ColorColor_ItemDeleted = 15, 	--鸟和鸟交换之后，全屏的动物被吸走
	kItemSpecial_WrapWrap = 16,		--区域+区域

	kItemShakeBySpecialColor = 17,	--鸟相关的特效中禽兽摇头晃脑
	kItemSpecial_WrapLine = 18,		--区域+区域

	kItemFalling_UpDown = 20,		--Item向下掉落
	kItemFalling_LeftRight = 21,		--左右掉落
	kItemFalling_Product = 22,		--生成新的Item
	kItemFalling_Pass = 23,			--穿过通道

	kItemMatchAt_IceDec = 30,		--MatchAt--> 冰层消除一层
	kItemMatchAt_LockDec = 31,		--MatchAt--> 牢笼消除一层
	kItemMatchAt_SnowDec = 32,		--MatchAt--> 雪花消除一层
	kItemMatchAt_VenowDec = 33,		--MatchAt--> 毒液消除一层

	kItemScore_Get = 40,			--获取分数特效
	kItemOrderList_Get = 41,		--完成某个Order

	kItemRefresh_Item_Flying = 50, 		 --刷新效果

	kItem_CollectIngredient = 60,	----收集食材（豆荚）

	kItem_Crystal_Change = 70, 		----水晶换色
	kItem_Venom_Spread = 71,		----毒液蔓延
	kItem_Furball_Transfer = 72, 	----毛球转移跳动
	kItem_Furball_Grey_Destroy = 73,----灰色毛球完蛋大吉
	kItem_Furball_Brown_Unstable = 74, --褐色毛球被特效打中 变为不稳定状态(颤抖)
	kItem_Furball_Split = 75,		----褐色毛球分裂
	kItem_Furball_Brown_Shield = 76,----褐色毛球护盾
	kItem_Roost_Upgrade = 77,		----鸡窝升级
	kItem_Roost_Replace = 78,		----鸡窝将原有动物替换为小鸡

	kItem_Balloon_update = 79,      --气球更新数据
	kItem_balloon_runAway = 80,     --气球飞走

	kItem_DigGroundDec = 81, --挖地地块消除一层
	kItem_DigJewleDec = 82,  --挖地宝石块消除一层

	kItem_ItemChangeToIngredient = 83, ---item变成豌豆荚
	kItem_ItemForceToMove = 84,    --强制移动到别的坐标

	kItem_TileBlocker_Update = 85,   --翻转地块更新
	kItem_Monster_frosting_dec = 86, --雪怪上的雪消除
	kItem_Monster_Jump         = 87, --雪怪消失
	kItem_Monster_Destroy_Item = 88, --因雪怪消失导致的消除
	kItem_PM25_Update          = 89, --pm2.5作用

	kItem_Black_Cute_Ball_Dec = 90,  --黑色毛球消除一层
	kItem_Black_Cute_Ball_Update = 91, --黑色毛球更新
	kItem_Mimosa_Grow = 92,            --含羞草生长
	kItem_Mimosa_back = 93,            --含羞草收回
	kItem_Mimosa_Ready = 94,           --含羞草准备生长

	kItem_Snail_Road_Bright = 95,      --蜗牛轨迹点亮
	kItem_Snail_Move = 96,             --蜗牛移动
	kItem_Snail_Product = 97,          --产生蜗牛
	kItem_Mayday_Boss_Die = 98,        -- 劳动节Boss死亡
	kItem_Mayday_Boss_Loss_Blood = 99,

	kItem_Rabbit_Product = 100,       --产生兔子
	kItem_Transmission = 101,         --传送带
	kOctopus_Change_Forbidden_Level = 102, 		-- 章鱼冰
	kItem_Area_Destruction = 103,		-- 消除一个矩形区域 用于海洋生物模式
	kItem_Magic_Lamp_Casting = 104, 	-- 神灯释放 大眼仔
	kItem_Magic_Lamp_Charging = 105,	-- 神灯充能
	kItem_Magic_Lamp_Reinit = 106,	-- 神灯充能
	kItem_WitchBomb = 107,
	kItem_Honey_Bottle_increase = 108,   -- 蜂蜜罐子被打
	kItem_Honey_Bottle_Broken = 109,     -- 蜂蜜罐子破碎
	kItemDestroy_HoneyDec = 110 ,        -- 蜂蜜消除
	kItem_Magic_Tile_Hit = 111,
	kItem_MoleWeekly_Boss_Die = 112,
	kItem_MoleWeekly_Boss_Create = 113,
	kItem_Magic_Tile_Change = 114,
	-- kItem_Halloween_Boss_Casting = 115,
	kItem_Sand_Clean	= 116,			-- 流沙消除
	kItem_Sand_Transfer	= 117,			-- 流沙流动
	kItem_mayday_boss_casting = 118,    -- 活动boss发大招
	kItem_QuestionMark_Protect = 119,   -- 问号障碍变成其他障碍时保护
	kItem_Magic_Stone_Active = 120, 	-- 魔法石被激活

	-- kItem_Gold_ZongZi_Active = 121, 	-- 金粽子被挖出
	-- kItem_Gold_ZongZi_Explode = 122, 	-- 金粽子生成特效

	kItem_Bottle_Blocker_Explode = 123, 	-- 妖精瓶子被消除一层
	kItem_Bottle_Destroy_Around = 124, 	-- 妖精瓶子释放特效炸掉周围四格

	kItem_Hedgehog_Road_bright = 125,   --刺猬轨迹点亮
	kItem_Hedgehog_Move = 126,          --刺猬移动
	kItem_Hedgehog_Crazy_Move = 127,    --刺猬疯狂移动
	kItem_Hedgehog_Clean_Dig_Groud = 128, --清除刺猬以上的云层
	kItem_Hedgehog_Box_Change = 129,      --刺猬礼盒打开
	kItem_Hedgehog_Road_State = 130,      --刺猬路径变化
	kItem_Hedgehog_Release_Energy = 131,  --刺猬变大
	kItem_Rocket_Active = 132, 			  --火箭发射，消除动物，击中UFO
	-- kItem_Halloween_Boss_Ready_Casting = 133,
	kItem_KindMimosa_back = 134,          --新的含羞草，匹配退回
	kItemSpecial_CrystalStone_Animal = 135,		--水晶石+动物
	-- kItemSpecial_CrystalStone_Bird = 136,		--水晶石+魔力鸟
	kItemSpecial_CrystalStone_Bird_part1 = 136,		--水晶石+魔力鸟 part1
	kItemSpecial_CrystalStone_Bird_part2 = 218,		--水晶石+魔力鸟 part2
	kItemSpecial_CrystalStone_Bird_part3 = 219,		--水晶石+魔力鸟 part3
	kItemSpecial_CrystalStone_CrystalStone = 137,		--水晶石+水晶石
	kItemSpecial_CrystalStone_Charge = 138,		--给水晶石充能
	kItemSpecial_CrystalStone_Destroy = 139,		--水晶石消失
	kItemSpecial_CrystalStone_Flying = 140,		--改变目标动物颜色

	kItem_Wukong_Casting = 141, 	-- 悟空释放大招
	kItem_Wukong_Charging = 142,	-- 悟空金箍棒充能
	kItem_Wukong_Reinit = 143,	-- 悟空重置颜色
	kItem_Wukong_CheckAndChangeState = 144,	-- 悟空刷新自身状态
	kItem_Wukong_JumpToTarget = 145,	-- 悟空直接飞到某个目标地格
	kItem_Wukong_FallToClearItem = 146,	-- 悟空落到目标地格，消除该地格上的item并触发特效
	kItem_Wukong_MonkeyBar = 147,	-- 悟空释放金箍棒，消除三排
	kItem_Wukong_Gift = 148,	-- 悟空扔出道具和特效

	-- kItem_SuperTotems_Explode = 149, -- 小金刚爆炸
	kItem_SuperTotems_Explode_part1 = 149,		-- 小金刚爆炸 part1
	kItem_SuperTotems_Explode_part2 = 217,		-- 小金刚爆炸 part2
	kItem_SuperTotems_Bomb_By_Match = 150, -- 匹配生成的小金刚一次性爆炸
	kItem_Decrease_Lotus = 151, -- 草地（荷叶）消除一层
	kItem_Update_Lotus = 152, -- 草地（荷叶）升级或增生
	-- kItem_Halloween_Boss_ClearLine = 153,
	kItem_Drip_Casting = 160,
	kItem_Check_Has_Drip = 161,
	kItem_SuperCute_Recover = 154,
	kItem_SuperCute_Inactive = 155,
	kItem_SuperCute_Transfer = 156,
	kItem_Puffer_Active = 157,
	kItem_Puffer_Explode = 158,

	kItem_DoubleSideTileBlocker_Update = 159,

	kItemMatchAt_OlympicLockDec = 160,
	kItemMatchAt_OlympicBlockDec = 161,
	kItemMatchAt_OlympicBlockExplode = 162,

	kBombAll_OlympicMode = 163,
	kItemMatchAt_Olympic_IceDec = 164,

	kMissileHit = 165,			-- 冰封导弹被消除一层
	kMissileFire = 166, 	-- 地图上全部可以发射的冰封导弹发射
	kMissileHitSingle = 167, -- 冰封导弹小弹头击中每一个小地格
	kItem_chestSquare_part_dec = 168, --大宝箱上的冰块消除
	kItem_ChestSquare_Jump = 169,     -- 大宝箱爆炸

	kItem_randomPropDec = 170,  -- 道具云块被消除

	kItem_ChickenMonther_Cast = 171,
	kItem_TangChicken_Destroy = 173,--获得唐装鸡
	
	kBonus_Step_To_Line = 174,
	kItemMatchAt_BlockerCoverMaterialDec = 175, --木桩消除一层
	kItem_Generate_Blocker_Cover = 176,--生成小叶堆
	kItem_Blocker_Cover_Dec = 177,--小叶堆消除一层

	kEliminateMusic = 178, -- 特效消除音效

	kItem_Weekly_Boss_Loss_Blood = 179,	--周赛第二种boss掉血
	kItem_Weekly_Boss_Die = 180,        --周赛第二种boss掉血死亡
	kItem_Blocker195_Collect = 181,--星星瓶收集
	kItem_Blocker195_Dec = 182,--星星瓶消除
	kItemSpecial_Blocker195_Color = 183,--消除所有同色无特效元素
	kItemSpecial_Blocker195_Kind_Color = 184,--消除所有同色同类元素
	kItemSpecial_Blocker195_Coin = 185,--消除所有的银币
	kItemSpecial_Blocker195_HoneyBottle = 186,--所有蜂蜜罐子减一层
	kItemSpecial_Blocker195_Missile = 187,--所有冰封导弹减一层
	kItemSpecial_Blocker195_Puffer = 188,--所有气鼓鱼减一层
	kItem_Blocker199_Dec = 189,--水母宝宝消除一层
	kItem_Blocker199_Explode = 190,--水母宝宝释放一次
	kItem_Blocker199_Reinit = 191,--水母宝宝变色
	kItem_Totems_Change = 192,--后补的，原来一直没有定义

	kItem_ColorFilter_Filter = 193,		--色彩过滤器A状态过滤
	kItem_ColorFilterB_Dec = 194,		--色彩过滤器B状态减层

	kNationDay2017_Cast = 195,			--十一技能
	kNationDay2017_Bomb_All = 196,
	
	kItem_Chameleon_transform = 197,	--变色龙变成动物

	kAddBuffItemToBoard = 198,	--增加buff到棋盘
	kBuffBoom_Dec = 199,	--BuffBoom被旁消
	kBuffBoom_Explode = 200,	--BuffBoom爆炸并放招
	kItem_Blocker206_Dec = 201,--配对锁被销毁
	kItem_Blocker207_Dec = 202,--钥匙被销毁
	kItemSpecial_Blocker195_Blocker207 = 203,--所有钥匙被销毁

	kAct_Collection_Turn = 204, 		--活动收集物转换
	kAddBuffAdd3Step = 205,
	kAddBuffRefresh = 206,
	kAddBuffSpecialAnimal = 207,
	kItemGiveBack = 208,

	kItem_pacman_eatTarget = 209,		--吃豆人吃目标
	kItem_pacman_blow = 210,			--吃豆人发大招
	kItem_pacmansDen_generate = 211,	--吃豆人小窝释放吃豆人

	kItemSpecial_rectangle = 212,		--通用长方形特效区域，传入左上&右下坐标 (x-col, y-row)
	kItemSpecial_diagonalSquare = 213,	--通用斜正方形特效区域（形如wrap爆炸），传入半径（如：wrap爆炸半径为2）
	kItem_Blocker211_Collect = 214,--寄居蟹收集
	-- ！！现在排到 219 了，下面的请从 220 开始 ！！---

	kItem_MoleWeekly_Boss_Skill = 220,  			--周赛boss技能
	kItem_MoleWeekly_Magic_Tile_Blast = 221,		--周赛的超级地格爆炸了
	kItem_MoleWeekly_Boss_Cloud_Die = 222,			--周赛boss施放的大云块消散

    kItem_YellowDiamondDec = 223,  --黄宝石块消除一层
	kItem_Turret_upgrade = 224,			--炮塔被触发

    kMoleWeekly_Bomb_All = 225, --地鼠消全屏

    kSummerFish_33_FlyObject = 226, --暑期活动3*3宝箱的飞行动画

	kItem_ghost_generate = 227,		--幽灵出现
	kItem_ghost_move = 228,			--幽灵移动
	kItem_ghost_collect = 229,		--幽灵被收集
	kItemSpecial_Blocker195_Ghost = 230, --所有幽灵被攻击

	kItem_ScoreBuffBottle_Add = 231,	 --生成刷星瓶
	kItem_ScoreBuffBottle_Blast = 232,	 --刷星瓶被消除

	kItem_SunFlask_Blast = 233,		--太阳瓶被消除
	kItem_SunFlower_Blast = 234,	--向日葵开大

	kItem_Firecracker_Blast = 235,		-- 新前置爆竹爆炸，击打目标

	kItem_Squid_Collect = 236,		--鱿鱼收集
	kItem_Squid_Run = 237,			--鱿鱼退场
	kItem_Squid_BombGrid = 238,		--鱿鱼大招影响格子

	kItem_Line_Prop_Effect = 239,	--横竖特效道具，usePropState居然不掉落，真是麻烦

    kItem_WanSheng_increase = 240,   -- 万生被打
	kItem_WanSheng_Broken = 241,     -- 万生破碎
    kItemSpecial_Blocker195_WanSheng = 242, --星星瓶造成 所有万生消除1层

    kItem_SpringFestival2019_Skill1 = 243, --春节技能1
    kItem_SpringFestival2019_Skill2 = 244, --春节技能2
    kItem_SpringFestival2019_Skill3 = 245, --春节技能3
    kItem_SpringFestival2019_Skill4 = 246, --春节技能4

	kItemMatchAt_ApplyMilk = 247,	--MatchAt--> 涂奶油
	kItem_AddNewBiscuit = 248,
	kItem_CollectBiscuit = 249,
}

GamePropsActionType = table.const 	--游戏道具播放动画细节
{
	kNone = 0,
	kHammer = 1,					-- 锤子
	kSwap = 2,						-- 强制交换
	kLineBrush = 3,					-- 条纹刷子
	kBack = 4, 						-- 回退
	kOctopusForbid = 5, 			-- 章鱼冰
	kRandomBird = 6, 				-- 随机魔力鸟
	kBroom = 7,						-- 扫把
	kHedgehogCrazy = 8,             -- 刺猬疯狂
	kWukongJump = 9,	            -- 点击悟空触发跳跃
	kNationDay2017Cast = 10,	    -- 十一技能
	kMoleWeeklyRaceSPProp = 11,	    -- 鼹鼠周赛道具大招
    kJamSpeardHammer = 12,			-- 果酱锤子
    kLineEffectProp = 13,			-- 横竖特效
    kSpringFestival2019_Skill1 = 14, --春节技能1
    kSpringFestival2019_Skill2 = 15, --春节技能2
    kSpringFestival2019_Skill3 = 16, --春节技能3
    kSpringFestival2019_Skill4 = 17, --春节技能4
}

GameBoardTopPartActionType = table.const
{
	kNone = 0,
	kBranchProgress = 1, 			--branch进度条（http://wiki.happyelements.net/pages/viewpage.action?pageId=31460095 刷新活动需求）
}

GameActionStatus = table.const
{
	kNone = 0,
	kWaitingForStart = 1,			--游戏模式下，将等待view--->logic的启动，保证数据和view的同步，数据验证模式下，直接开始计算
	kRunning = 2,					--动作执行中
	kWaitingForDeath = 3,			--即将结束--view-->logic侦查到此状态将走下一步，该动作自动变为下个动作或者结束
}

function GameBoardActionDataSet:ctor()
	self.actionTarget = 0;
	self.actionType = 0;		----GameBoardActionType/GameItemActionType/
	self.ItemPos1 = nil;		----动画Item参数1
	self.ItemPos2 = nil;		----动画Item参数2
	self.actid = 0;

	self.actionStatus = 0;		----动作状态
	self.actionDuring = 0;		----执行时间
	self.addInfo = "";			----辅助字符串
	self.addInt = 0;			----辅助数值
	self.addInt2 = 0;			----辅助数2
end

function GameBoardActionDataSet:dispose()
	self.ItemPos1 = nil;		----动画Item参数1
	self.ItemPos2 = nil;		----动画Item参数2
end

function GameBoardActionDataSet:create()
	local data = GameBoardActionDataSet.new()
	data:initDataSet()
	return data
end

function GameBoardActionDataSet:initDataSet()
end

function GameBoardActionDataSet:createAs(actionTarget, actionType, ItemPos1, ItemPos2, CDTime)
	local data = GameBoardActionDataSet:create()
	data.actionTarget = actionTarget
	data.actionType = actionType
	data.ItemPos1 = ItemPos1
	data.ItemPos2 = ItemPos2

	data.actionStatus = GameActionStatus.kWaitingForStart
	data.actionDuring = CDTime

	if actionType ==  GameItemActionType.kItemScore_Get then
		assert(ItemPos1)
	end
	return data
end