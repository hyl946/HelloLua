require "zoo.gamePlay.GameBoardData"
require "zoo.gamePlay.GameItemData"
require "zoo.animation.LinkedItemAnimation"
require "zoo.animation.TileCuteBall"
require "zoo.itemView.ItemViewUtils"
require "zoo.gamePlay.GamePlayConfig"
require "zoo.animation.TileCharacter"
require "zoo.animation.TileBird"
require "zoo.animation.TileVenom"
require "zoo.animation.TileCoin"
require "zoo.animation.TileRoost"
require "zoo.animation.TileBalloon"
require "zoo.animation.TileDigJewel"
require "zoo.animation.TileDigGround"
require "zoo.animation.TileAddMove"
require "zoo.animation.TilePoisonBottle"
require "zoo.animation.TileBlocker"
require "zoo.animation.TileMonster"
require "zoo.animation.TileChestSquare"
require "zoo.animation.TileMonsterFrosting"
require "zoo.animation.TileBlackCuteBall"
require "zoo.animation.TileMimosa"
require "zoo.animation.TileSnailRoad"
require "zoo.animation.TileSnail"
require "zoo.animation.TileBoss"
require "zoo.animation.TileBossGaf"
require "zoo.modules.weekly2017s1.TileWeeklyBoss"
require "zoo.modules.weekly2017s1.TileRandomProp"
require "zoo.animation.TileRabbit"
require "zoo.animation.TileTransDoor"
require "zoo.animation.TileMagicLamp"
require "zoo.animation.TileWukong"
require "zoo.animation.TileWukongTarget"
require "zoo.animation.TileWukongEff"
require "zoo.animation.TileSuperBlocker"
require "zoo.animation.TileHoneyBottle"
require "zoo.animation.TileHoney"
require "zoo.animation.TileAddTime"
require "zoo.animation.TileMagicTile"
require "zoo.animation.TileSand"
require "zoo.animation.TileQuestionMark"
require "zoo.animation.TileChain"
require "zoo.animation.TileMagicStone"
require "zoo.animation.TileMove"
require "zoo.animation.TileBottleBlocker"
require "zoo.animation.Halloween2015.TileHalloweenNewBoss"
require "zoo.animation.TileHedgehogRoad"
require "zoo.animation.TileHedgehog"
require "zoo.animation.TileHedgehogBox"
require "zoo.animation.TileRocket"
require "zoo.animation.TileBeanpod"
require "zoo.animation.TileCrystalStone"
require "zoo.animation.TileTotems"
require "zoo.animation.TileLotus"
require "zoo.animation.TileDrip"
require "zoo.animation.TileSuperCuteBall"
require "zoo.animation.TilePuffer"
require "zoo.animation.TileDoubleSideBlocker"
require "zoo.modules.olympic.TileOlympicBlocker"
require "zoo.modules.olympic.TileOlympicLock"
require "zoo.animation.TileMissile"
require "zoo.animation.TileBlockerCoverMaterial"
require "zoo.animation.TileBlockerCover"
require "zoo.animation.TileLantern"
require "zoo.animation.TileBlocker195"
require "zoo.animation.TileBlocker199"
require "zoo.animation.TileColorFilterA"
require "zoo.animation.TileColorFilterB"
require "zoo.animation.TileChameleon"
require "zoo.modules.nation2017.TileNationDayStar"
require "zoo.animation.TileLockBox"
require "zoo.animation.TileLockBoxKey"
require "zoo.animation.TileBuffBoom"
require "zoo.animation.TilePacman"
require "zoo.animation.TilePacmansDen"
require "zoo.animation.TileBlocker211"
require "zoo.animation.TileTurret"
require "zoo.animation.TileYellowDiamond"
require "zoo.animation.Mole.TileMoleBossSeed"
require "zoo.animation.Mole.TileMoleMagicTileCover"
require "zoo.animation.Mole.TileMoleBossCloud"
require "zoo.animation.TileGhost"
require "zoo.animation.TileGhostDoor"
require "zoo.animation.TileScoreBuffBottle"
require "zoo.animation.TileSunFlask"
require "zoo.animation.TileSunflower"
require "zoo.animation.TileFirecracker"
require "zoo.animation.TileJamSperad"
require "zoo.animation.TileSquid"
require "zoo.animation.TileWanSheng"
require "zoo.animation.TileBiscuit"

ItemView = class{}

--用来显示地图上物品的基础
--包括地格--包括动物

ItemSpriteTypeNames = table.const
{
	"kNone",
	"kBackground",		-- 地格--------添加层次时请保持这个在最后
	"kScrollBackground",   --周赛可滚动地格背景 
	"kMoveTileBackground", -- 移动地格背景
	"kGravitySkinBottom", -- 重力皮肤（底部）有的皮肤在格子底下，有的在顶上，有的上下都有
	"kTileBlocker",       -- 翻转地格, 传送带
	"kColorFilterA", 	  -- 色彩过滤器状态A层
	"kJamSperad",       -- 果酱
	"kSuperCuteLowLevel", -- 超级毛球静默
	"kSeaAnimal",         -- 海洋生物
	"kBiscuit",
	"kSnailRoad",         --蜗牛轨迹
	"kHedgehogRoad",      --刺猬轨迹
	"kPropsEffect", 	  --使用道具后的特效
	"kTileHighLightEffect", -- 地格特效
	"kTileHighLightEffectWithoutTexture", --地格特效，无texture版
	"kHedgehogRoadEffect", --刺猬轨迹播放动画
	"kRabbitCaveDown",    --兔子洞穴, 问号爆炸背景光
	"kSand",			    -- 流沙动画
	"kSandMove",			-- 流沙动画
	"kLight",				-- 冰层, 流沙
	"kQuestionMarkDestoryBg", --问号消除背景光 
	"kItemBack",			-- 鸟的特效
	"kLotus_bottom",		-- 草地底层（荷叶）
	"kItemLowLevel",		-- 物品&物品特效--专门用来放置需要出现在顶层的物品及物品特效（例如草地）
	"kBlockerCoverMaterial",			    --木桩
	"kItem",				-- 物品--动物
	"kItemShow",			-- 物品特效--某个动物的动画，或者是消除特效qq
	"kMoleWeeklyItemShow",	-- 鼹鼠周赛相关Item for Batch
	"kPacmanShow",			-- 吃豆人 for Batch
	"kSquidShow",			-- 鱿鱼 for Batch
	"kMagicTileWater",
    "kMoleBossCloud",		-- 新周赛 4格草地
	"kDigBlocker",		-- 地块和宝石
	"kRandomProp",      -- 道具云块
	"kItemDestroy",		-- 物品消除特效层---一个雪花	
	"kClipping",			-- 生成口、传送门出口遮罩
	"kEnterClipping",	    -- 传送门入口遮罩
	"kRabbitCaveUp",    --兔子洞穴上层
	"kRope",				-- 绳子
	"kOlympicLock",	
	"kLock",				-- 笼子
	"kFurBall",			-- 毛球
	"kSnail",               --蜗牛，刺猬
	"kHoney",			-- 蜂蜜
	"kWeeklyBoss",     -- 周赛第二种boss
	"kBigMonster",       -- 雪怪
	"kLockShow",			-- 笼子消除
	"kSnowShow",			-- 雪花消除
	"kBigMonsterIce",			-- 雪花消除
	"kChestSquarePart",	-- 大宝箱四个角
	"kChestSquare",		-- 大宝箱
	"kChestSquarePartFront", -- 大宝箱四个角的前景
	"kNormalEffect",     -- 毛球消除，毒液扩散, 雪怪的冰层等
	"kGhostDoor",			--幽灵出入口
	"kTransClipping",    -- 传送带遮罩
	"kPass",	            -- 通道
	"kTransmissionDoor",   -- 传送带出入口
	"kTransmissionDoorIn", -- 传送带出入口
	"kItemHighLevel",	  -- 物品&物品特效--专门用来放置需要出现在顶层的物品及物品特效（例如猴子,草地）
	"kLotus_top",		-- 草地顶层（荷叶）
	"kGhost",			--幽灵
	"kSuperCuteHighLevel",	-- 超级毛球活跃
	"kTopLevelHighLightEffect",
	"kChain",			-- 冰柱
	"kBlockerCover",    --小叶堆
	"kColorFilterB", 	  -- 色彩过滤器状态B层
	"kLock206Show",--配对锁显示层
	"kSpecial",			-- 鸟飞行,刷新飞行
	"kSpecialHigh",			-- 魔力鸟新特效要盖住动物
	"kRoostFly",			-- 鸡窝飞行,与刷新飞行冲突
	"kSnailMove",       	-- 蜗牛移动，问号爆炸前景光
	"kQuestionMarkDestoryFg", --问号消除前景光 
	"kMagicStoneFire", --魔法石发动动画
    "kTurretEffect",	 --炮塔动画
	"kDigBlockerBomb",
	"kTileMoveEffect",
	"kBigMonsterFoot",  --雪怪作用时的脚印
	"kMissileEffect",	-- 冰封导弹特效层
	"kBlockerCoverEffect",--小叶堆特效
	"kCrystalStoneEffect", -- 染色宝宝特效层 for batch
	"kBlocker195Effect", --星星瓶特效层
	"kBlocker199Effect", --水母宝宝特效层
	"kBlocker211Effect", --寄居蟹特效层
	"kBlockerCommonEffect",	 --障碍通用特效层
	"kSuperTotemsLight",
	"kSuperTotemsEffect",
	"kGravitySkinTop", -- 各位大神，请让我在最前面，谢谢！我很乖，保证不乱来~     重力皮肤（底部）有的皮肤在格子底下，有的在顶上，有的上下都有
	"kTopLevelEffect", -- 要放到最上层的动画，又需要低于gameguide
	"kLast",			-- 最上层--------添加层次时请保持这个在最前
	"kGameGuideEffect",
}

TileHighlightType = table.const {
	kTotems = 1,
	kRedAlert = 2,
}

ItemSpriteType = {}
local itemSpriteIndex = 0
for _,v in ipairs(ItemSpriteTypeNames) do
	ItemSpriteType[v] = itemSpriteIndex
	itemSpriteIndex = itemSpriteIndex + 1
end

-- ItemSpriteType = table.const
-- {
-- 	kNone = 0,
-- 	kBackground = 1,		-- 地格--------添加层次时请保持这个在最后
-- 	kMoveTileBackground = 2, -- 移动地格背景
-- 	kTileBlocker = 3,       -- 翻转地格, 传送带, 海洋生物
-- 	kSnailRoad = 4,         --蜗牛轨迹
-- 	kRabbitCaveDown = 5,    --兔子洞穴, 问号爆炸背景光
-- 	kSand = 6,			    -- 流沙动画
-- 	kSandMove = 7,			-- 流沙动画
-- 	kLight = 8,				-- 冰层, 流沙
-- 	kQuestionMarkDestoryBg = 9, --问号消除背景光 
-- 	kItemBack = 10,			-- 鸟的特效
-- 	kItem = 11,				-- 物品--动物
-- 	kItemShow = 12,			-- 物品特效--某个动物的动画，或者是消除特效qq
-- 	kDigBlocker = 13,		-- 地块和宝石
-- 	kItemDestroy = 14,		-- 物品消除特效层---一个雪花	
-- 	kClipping = 15,			-- 生成口、传送门出口遮罩
-- 	kEnterClipping = 16,	    -- 传送门入口遮罩
-- 	kRabbitCaveUp = 17,    --兔子洞穴上层
-- 	kRope = 18,				-- 绳子
-- 	kChain = 19,			-- 冰柱
-- 	kLock = 20,				-- 笼子
-- 	kFurBall = 21,			-- 毛球, 蜂蜜
-- 	kBigMonster = 22,       -- 雪怪
-- 	kLockShow = 23,			-- 笼子消除
-- 	kSnowShow = 24,			-- 雪花消除
-- 	kNormalEffect = 25,     -- 毛球消除，毒液扩散, 雪怪的冰层等
-- 	kTransClipping = 26,    -- 传送带遮罩
-- 	kPass = 27,	            -- 通道
-- 	kTransmissionDoor = 28,  -- 传送带出入口
-- 	kSpecial = 29,			-- 鸟飞行,刷新飞行
-- 	kRoostFly = 30,			-- 鸡窝飞行,与刷新飞行冲突
-- 	kSnailMove = 31,       	-- 蜗牛移动，问号爆炸前景光
-- 	kQuestionMarkDestoryFg = 32, --问号消除前景光 
-- 	kMagicStoneFire = 33, --魔法石发动动画
-- 	kDigBlockerBomb = 34,
-- 	kTileMoveEffect	= 35,
-- 	kLast = 36,			-- 最上层--------添加层次时请保持这个在最前
-- }

local Max_Item_Y = GamePlayConfig_Max_Item_Y

ItemSpriteItemShowType = table.const
{
	kNone = 0,
	kCharacter = 1,			-- 普通，有颜色
	kBird = 2,				-- 魔力鸟
	kCoin = 3,				-- 银币
	kRabbit = 4,            -- 兔子
	kBlocker207 = 5,          -- 钥匙
}

--可参与交换的item层
ItemSpriteCanSwapLayers = table.const{
	ItemSpriteType.kItem, 
	ItemSpriteType.kItemShow,
	ItemSpriteType.kPacmanShow,
	ItemSpriteType.kMoleWeeklyItemShow,
	-- ItemSpriteType.kGhost
}

--可掉落的item层（不考虑生成口生成）
ItemSpriteCanFallingDownLayers = table.const{
	ItemSpriteType.kItem, 
	ItemSpriteType.kItemShow,
	ItemSpriteType.kMoleWeeklyItemShow
}

local boardViewLayers = {

	ItemSpriteType.kMoveTileBackground, 
	ItemSpriteType.kGravitySkinBottom,
	ItemSpriteType.kTileBlocker, 
	ItemSpriteType.kJamSperad,
	ItemSpriteType.kColorFilterA,
	ItemSpriteType.kSuperCuteLowLevel,
	ItemSpriteType.kSeaAnimal,
	ItemSpriteType.kMagicTileWater,
	ItemSpriteType.kSnailRoad,
	ItemSpriteType.kHedgehogRoad, 
	ItemSpriteType.kTileHighLightEffect,
	ItemSpriteType.kTileHighLightEffectWithoutTexture,
	ItemSpriteType.kHedgehogRoadEffect,
	ItemSpriteType.kRabbitCaveDown, 
	ItemSpriteType.kClipping, 
	ItemSpriteType.kEnterClipping, 
	ItemSpriteType.kRope, 
	ItemSpriteType.kBigMonster, 
	ItemSpriteType.kBigMonsterIce,
	ItemSpriteType.kWeeklyBoss,
	ItemSpriteType.kSand,
	ItemSpriteType.kLight,
	ItemSpriteType.kLotus_bottom,
	ItemSpriteType.kItemLowLevel,
	ItemSpriteType.kBlockerCoverMaterial,
	ItemSpriteType.kItem, 
	ItemSpriteType.kItemShow,
	ItemSpriteType.kPacmanShow,
	ItemSpriteType.kSquidShow,
	ItemSpriteType.kMoleWeeklyItemShow,
	ItemSpriteType.kDigBlocker,
	ItemSpriteType.kOlympicLock,
	ItemSpriteType.kLock,
	ItemSpriteType.kFurBall,
	ItemSpriteType.kSnail,
	ItemSpriteType.kHoney,
	ItemSpriteType.kGhostDoor,
	ItemSpriteType.kPass,
	ItemSpriteType.kItemHighLevel,
	ItemSpriteType.kLotus_top,
	ItemSpriteType.kGhost,
	ItemSpriteType.kSuperCuteHighLevel,
	ItemSpriteType.kBlockerCover,
	ItemSpriteType.kColorFilterB,
	ItemSpriteType.kTopLevelHighLightEffect,
	ItemSpriteType.kChain, 
	ItemSpriteType.kMoleBossCloud,
	ItemSpriteType.kGravitySkinTop, --各位大神，请让我在最前面，谢谢！我很乖，保证不乱来~
	-- ItemSpriteType.kNormalEffect,
}

local needUpdateLayers = {
	ItemSpriteType.kGravitySkinBottom,
	ItemSpriteType.kLotus_bottom,
	ItemSpriteType.kItemLowLevel,
	ItemSpriteType.kBlockerCoverMaterial,
	ItemSpriteType.kItem, 
	ItemSpriteType.kLight,
	ItemSpriteType.kItemShow,
	ItemSpriteType.kPacmanShow,
	ItemSpriteType.kSquidShow,
	ItemSpriteType.kMoleWeeklyItemShow,
	ItemSpriteType.kDigBlocker,
	ItemSpriteType.kOlympicLock,
	ItemSpriteType.kLock,
	ItemSpriteType.kFurBall, 
	ItemSpriteType.kHoney,
	ItemSpriteType.kClipping, 
	ItemSpriteType.kEnterClipping,
	ItemSpriteType.kRope,
	ItemSpriteType.kTransClipping,
	ItemSpriteType.kBigMonster,
	ItemSpriteType.kBigMonsterIce,
	ItemSpriteType.kWeeklyBoss,
	ItemSpriteType.kItemHighLevel,
	ItemSpriteType.kLotus_top,
	ItemSpriteType.kGhost,
	ItemSpriteType.kBlockerCover,
	ItemSpriteType.kColorFilterA,
	ItemSpriteType.kColorFilterB,
    ItemSpriteType.kMoleBossCloud,
    ItemSpriteType.kGravitySkinTop,
}

local needTransLayer = table.const{
	-- ItemSpriteType.kTileBlocker,
	ItemSpriteType.kJamSperad,
	ItemSpriteType.kMoveTileBackground,
	ItemSpriteType.kColorFilterA,
	ItemSpriteType.kSuperCuteLowLevel,
	ItemSpriteType.kLotus_bottom,
	ItemSpriteType.kItemLowLevel,
	ItemSpriteType.kSand,
	ItemSpriteType.kLight,
	ItemSpriteType.kBlockerCoverMaterial,
	ItemSpriteType.kItem, 
	ItemSpriteType.kItemShow,
	ItemSpriteType.kPacmanShow,
	ItemSpriteType.kSquidShow,
	ItemSpriteType.kMoleWeeklyItemShow,
	ItemSpriteType.kDigBlocker,
	ItemSpriteType.kLock,
	ItemSpriteType.kFurBall,
	ItemSpriteType.kHoney,
	ItemSpriteType.kItemHighLevel,
	ItemSpriteType.kLotus_top,
	ItemSpriteType.kGhost,
	ItemSpriteType.kSuperCuteHighLevel,
	ItemSpriteType.kBlockerCover,
	ItemSpriteType.kColorFilterB,
}

local ColorFilterBHideLayers = {
	ItemSpriteType.kColorFilterA,
	ItemSpriteType.kSuperCuteLowLevel,
	ItemSpriteType.kSeaAnimal,
	ItemSpriteType.kMagicTileWater,
	ItemSpriteType.kSnailRoad,
	ItemSpriteType.kHedgehogRoad, 
	ItemSpriteType.kTileHighLightEffect,
	ItemSpriteType.kTileHighLightEffectWithoutTexture,
	ItemSpriteType.kHedgehogRoadEffect,
	ItemSpriteType.kRabbitCaveDown, 
	ItemSpriteType.kClipping, 
	ItemSpriteType.kEnterClipping, 
	ItemSpriteType.kRope, 
	ItemSpriteType.kBigMonster, 
	ItemSpriteType.kBigMonsterIce,
	ItemSpriteType.kWeeklyBoss,
	ItemSpriteType.kSand,
	ItemSpriteType.kLight,
	ItemSpriteType.kLotus_bottom,
	ItemSpriteType.kItemLowLevel,
	ItemSpriteType.kBlockerCoverMaterial,
	ItemSpriteType.kItem, 
	ItemSpriteType.kItemShow,
	ItemSpriteType.kPacmanShow,
	-- ItemSpriteType.kSquidShow,
	ItemSpriteType.kMoleWeeklyItemShow,
	ItemSpriteType.kDigBlocker,
	ItemSpriteType.kOlympicLock,
	ItemSpriteType.kLock,
	ItemSpriteType.kFurBall,
	ItemSpriteType.kSnail,
	ItemSpriteType.kHoney,
	-- ItemSpriteType.kPass,
	ItemSpriteType.kItemHighLevel,
	ItemSpriteType.kLotus_top,
	ItemSpriteType.kGhost,
	ItemSpriteType.kSuperCuteHighLevel,
	ItemSpriteType.kBlockerCover,
    ItemSpriteType.kMoleBossCloud,
	-- ItemSpriteType.kColorFilterB,
	-- ItemSpriteType.kTopLevelHighLightEffect,
	-- ItemSpriteType.kChain, 
	
	-- ItemSpriteType.kNormalEffect,
}

local itemsName = { 
	[AnimalTypeConfig.kBlue] = "horse", 
	[AnimalTypeConfig.kGreen] = "frog", 
	[AnimalTypeConfig.kOrange] = "bear", 
	[AnimalTypeConfig.kPurple] = "cat", 
	[AnimalTypeConfig.kRed] = "fox", 
	[AnimalTypeConfig.kYellow] = "chicken"
}
local kCharacterAnimationTime = 1/30

local function getColorIndexByAnimalName(name)
	if name then
		for colortype, v in pairs(itemsName) do
			if v == name then 
				return AnimalTypeConfig.convertColorTypeToIndex(colortype) 
			end
		end
	end
	return 0
end

function ItemView:ctor()
	self.itemSprite = nil		-- 真正的显示对象
	self.itemPosAdd = nil		-- 普通物品的偏移量存储
	self.RopePosAdd = nil		-- 绳子的偏移量存储
	self.x = 0
	self.y = 0
	self.w = 0
	self.h = 0

	self.clippingnode = nil						-- 
	self.enterClippingNode = nil
	self.cl_hoff = 0;
	self.cl_h = 0;

	self.pos_x = 0;		--实际位置
	self.pos_y = 0;

	self.oldData = nil;
	self.oldBoard = nil;
	self.itemShowType = 0;
	self.isNeedUpdate = false;

	self.flyingfromtype = ItemSpriteType.kNone;

	--colorfilter的boarddata对itemdata的影响标识
	self.colorFiterEffect = false
end

function ItemView:cleanAllViews( ... )
	self.RopePosAdd = nil		-- 绳子的偏移量存储

	self.clippingnode = nil						-- 
	self.enterClippingNode = nil
	self.cl_hoff = 0;
	self.cl_h = 0;

	self.oldData = nil;
	self.oldBoard = nil;
	self.itemShowType = 0;
	self.isNeedUpdate = false;

	self.flyingfromtype = ItemSpriteType.kNone;

	for k, v in pairs(self.itemSprite) do
		if k ~= ItemSpriteType.kMoveTile and v and v:getParent() then
			v:removeFromParentAndCleanup(true)
		end
	end
	self.itemSprite = {}
	self.itemPosAdd = {}		-- 普通物品的偏移量存储
end

function ItemView.copyDatasFrom(toData, fromData)
	if type(fromData) ~= "table" then return end
	
	toData.w = fromData.w
	toData.h = fromData.h

	toData.itemShowType = fromData.itemShowType
	toData.cl_hoff = fromData.cl_hoff
	toData.cl_h = fromData.cl_h
	toData.flyingfromtype = fromData.flyingfromtype
	toData.itemPosAdd = {}
	for k, v in pairs(fromData.itemPosAdd) do
		toData.itemPosAdd[k] = ccp(v.x, v.y)
	end
	if fromData.oldData then toData.oldData = fromData.oldData:copy() end
	if fromData.oldBoard then toData.oldBoard = fromData.oldBoard:copy() end
end

function ItemView:dispose()
	self.itemSprite = nil
	self.itemPosAdd = nil
	self.RopePosAdd = nil

	self.clippingnode = nil
	self.enterClippingNode = nil
	self.oldData = nil;
	self.oldBoard = nil;
end

function ItemView:create(context)
	local s = ItemView.new()
	s:initView(context)
	return s
end

function ItemView:initView(context)
	self.itemSprite = {}
	self.itemPosAdd = {}
	self.context = context

	-- self:watchOnItemSprites()
end

function ItemView:watchOnItemSprites()
	local __vt = {}
	local mt = {
		__index = function(t, k)
			return __vt[k]
		end,
		__newindex = function(t, k, v)
			if k == ItemSpriteType.kSnowShow and __vt[k] and __vt[k]:getParent() == nil then
				log_file("watchOnItemSprites", tostring(v)..debug.traceback())
			end
			__vt[k] = v
		end,
	}
	setmetatable(self.itemSprite, mt)
end

function ItemView:initByBoardData(data, boderInfo)
	if data.isUsed == false then return end -- 不可用，跳过，什么都不显示

	self.oldBoard = data:copy();

	self.x = data.x;
	self.y = data.y;
	self.w = data.w;
	self.h = data.h;

	if data.isProducer then needClipping = true self.cl_hoff = 0 self.cl_h = self.h - 6  end				--生成口，需要裁减
	if data:hasPortal() then needClipping = true self.cl_hoff = 0 self.cl_h = self.h end						--通道，需要裁减

	-- if needClipping then
		--将ClippingNode添加为界面的子节点，当某个物体掉落将要进（出）范围时，添加至ClippingNode，静止时添加至节点
		-- self:buildClippingNode()
	-- end
	local function isBoardWithoutBg()
		return not data.isUsed or data.isMoveTile or data.isTangChickenBoard
	end

	if self.context.levelType == GameLevelType.kSummerWeekly or self.context.levelType == GameLevelType.kSpring2017 
		or self.context.levelType == GameLevelType.kMoleWeekly then
		if not isBoardWithoutBg() then 
			self.itemSprite[ItemSpriteType.kScrollBackground] = ItemViewUtils:buildScrollBackGround(boderInfo)
		end
	end

	if data:isRotationTileBlock() then 
		self.itemSprite[ItemSpriteType.kTileBlocker] = ItemViewUtils:buildTileBlocker(data.reverseCount, data.isReverseSide)
	end

	if data:isDoubleSideTileBlock() then
		self.itemSprite[ItemSpriteType.kTileBlocker] = ItemViewUtils:buildDoubleSideTileBlocker(data.reverseCount, data.side == 2)
	end

	if data.isRabbitProducer then 
		self:buildRabbitCave()
	end

	if data.colorFilterState == ColorFilterState.kStateA or data.colorFilterState == ColorFilterState.kStateB then 
		self.itemSprite[ItemSpriteType.kColorFilterA] = TileColorFilterA:create(data.colorFilterColor)
	end

	if data.colorFilterBLevel > 0 then 
		self.itemSprite[ItemSpriteType.kColorFilterB] = TileColorFilterB:create(self.getContainer(ItemSpriteType.kColorFilterB).refCocosObj:getTexture(),
																				 data.colorFilterColor, data.colorFilterBLevel)
	end

	if data.sandLevel > 0 then
		self.itemSprite[ItemSpriteType.kSand] = ItemViewUtils:buildSand(data.sandLevel)
	end
	
	if data.iceLevel > 0 then		 --冰
		self.itemSprite[ItemSpriteType.kLight] = ItemViewUtils:buildLight(data.iceLevel, data.gameModeId)
	end

	if data.transType > 0 then
		self:buildTransmisson(data)
	end

	if data.seaAnimalType then
		self.itemSprite[ItemSpriteType.kSeaAnimal] = {}
		self:buildSeaAnimal(data.seaAnimalType)
	end

	if data.biscuitData then
		self.itemPosAdd[ItemSpriteType.kBiscuit] = ccp(
			-self.w/2 + self.w * data.biscuitData.nCol / 2, 
			self.h/2 - self.h * data.biscuitData.nRow / 2
		)
		self.itemSprite[ItemSpriteType.kBiscuit] = {}
		self:buildBiscuit(data.biscuitData)
	end

	if data.isMagicTileAnchor then
		self:buildMagicTile(data)
	end

	if data.magicTileDisabledRound > 0 then
		self:buildMoleMagicTileCover()	--untested
	end

	if data.isWukongTarget then
		self:buildWukongTarget(data)
	end

	if data.lotusLevel > 0 then
		self:buildLotus(data.lotusLevel)
	end

	if data:hasSuperCuteBall() then
		self:addSuperCuteBall(data.superCuteState)
	end

    if data.isJamSperad then
		self:buildJamSperad()
    end

	if data:hasPortal() then		--通道
		local possImage = nil;
		if data.passType == 1 then
			possImage = LinkedItemAnimation:buildPortalExit(data.passExitColorId , data:getGravity());
			if data:getGravity() == BoardGravityDirection.kDown then
				self.itemPosAdd[ItemSpriteType.kPass] = ccp(0, self.h * 0.32)
			elseif data:getGravity() == BoardGravityDirection.kUp then
				self.itemPosAdd[ItemSpriteType.kPass] = ccp(0, -self.h * 0.32)
			elseif data:getGravity() == BoardGravityDirection.kLeft then
				self.itemPosAdd[ItemSpriteType.kPass] = ccp( self.h * 0.32 , 0)
			else
				self.itemPosAdd[ItemSpriteType.kPass] = ccp( -self.h * 0.32 , 0)
			end
		elseif data.passType == 2 then
			possImage = LinkedItemAnimation:buildPortalEnter(data.passEnterColorId , data:getGravity());
			if data:getGravity() == BoardGravityDirection.kDown then
				self.itemPosAdd[ItemSpriteType.kPass] = ccp(0, -self.h * 0.4)
			elseif data:getGravity() == BoardGravityDirection.kUp then
				self.itemPosAdd[ItemSpriteType.kPass] = ccp(0, self.h * 0.4)
			elseif data:getGravity() == BoardGravityDirection.kLeft then
				self.itemPosAdd[ItemSpriteType.kPass] = ccp( -self.h * 0.4 , 0)
			else
				self.itemPosAdd[ItemSpriteType.kPass] = ccp( self.h * 0.4 , 0 )
			end
	    elseif data.passType == 3 then
			possImage = LinkedItemAnimation:buildPortalBoth(data.passEnterColorId, data.passExitColorId , data:getGravity());
			if data:getGravity() == BoardGravityDirection.kDown then
				self.itemPosAdd[ItemSpriteType.kPass] = ccp(0, self.h * 0.33)
			elseif data:getGravity() == BoardGravityDirection.kUp then
				self.itemPosAdd[ItemSpriteType.kPass] = ccp(0, -self.h * 0.33)
			elseif data:getGravity() == BoardGravityDirection.kLeft then
				self.itemPosAdd[ItemSpriteType.kPass] = ccp(self.h * 0.33 , 0)
			else
				self.itemPosAdd[ItemSpriteType.kPass] = ccp(-self.h * 0.33 , 0)
			end
		end
		if possImage~=nil then
			self.itemSprite[ItemSpriteType.kPass] = possImage
		end
	end

	self:refreshRopeView(data)

	if data.isMoveTile then
		local bgTexture = nil
		if self.getContainer(ItemSpriteType.kMoveTileBackground) then 
			bgTexture = self.getContainer(ItemSpriteType.kMoveTileBackground).refCocosObj:getTexture()
		end
		self.itemSprite[ItemSpriteType.kMoveTileBackground] =TileMove:createTile(bgTexture, data.isCollector)
	end

	-- chain todo
	if data.y >= self.context.startRowIndex then 
	-- 挖地滚动到地格外面后冰柱不再显示，绳子是做了遮罩，但冰柱为了做batch无法再做遮罩
	-- 由于魔法地格的存在导致上一行的数据可能仍然存在
		self:addChainsView(data)
	end

	self:initSnailRoad(data)
	if data.blockerCoverMaterialLevel > 0 then
		self:buildBlockerCoverMaterial(data.blockerCoverMaterialLevel)
	end

	self:addGhostDoor(data)
end

function ItemView:refreshRopeView(data)
	local oldRopeSprite = self.itemSprite[ItemSpriteType.kRope]
	if oldRopeSprite then
		oldRopeSprite:removeFromParentAndCleanup(true)
		oldRopeSprite = nil
	end

	if data:hasRope() then		
		local str_H = "WallH.png"
		local str_V = "WallV.png"
		local st_sprite = Sprite:createWithSpriteFrameName(str_H);
		st_sprite:setOpacity(0)
		if data:hasTopRopeProperty() then --上
			local RopeUP = Sprite:createWithSpriteFrameName(str_H);
			RopeUP:setPositionXY(self.w / 2.0 + 5, self.h / 2.0 + 5)
			st_sprite:addChild(RopeUP)
		end
		if data:hasBottomRopeProperty() then --下
			local RopeDown = Sprite:createWithSpriteFrameName(str_H);
			RopeDown:setPositionXY(self.w / 2.0 + 5, -self.h / 2.0 + 7)
			st_sprite:addChild(RopeDown)
		end
		if data:hasLeftRopeProperty() then --左
			local RopeLeft = Sprite:createWithSpriteFrameName(str_V);
			RopeLeft:setPositionXY(5, 5)
			st_sprite:addChild(RopeLeft)
		end
		if data:hasRightRopeProperty() then --右
			local RopeRight = Sprite:createWithSpriteFrameName(str_V);
			RopeRight:setPositionXY(self.w + 4, 5)
			st_sprite:addChild(RopeRight)
		end

		if st_sprite then 
			self.itemSprite[ItemSpriteType.kRope] = st_sprite
		end
	end
end

function ItemView:buildBlockerCoverMaterial(level)
	local blockerCoverSprite = TileBlockerCoverMaterial:create(level)
	self.itemSprite[ItemSpriteType.kBlockerCoverMaterial] = blockerCoverSprite

	if blockerCoverSprite then
		local pos = self:getBasePosition(self.x, self.y)
		self.itemSprite[ItemSpriteType.kBlockerCoverMaterial]:setPosition(pos)
	end
	
	if self.oldBoard then
		self.oldBoard.blockerCoverMaterialLevel = level
	end
end

function ItemView:playBlockerCoverMaterialDecEffect(level)
	local item = self.itemSprite[ItemSpriteType.kBlockerCoverMaterial]
	if item then
		item:playDecreaseAnimation(level , function () 
				if level == 0 then
					self.itemSprite[ItemSpriteType.kBlockerCoverMaterial] = nil
				end
			end)
	end

	if self.oldBoard then
		self.oldBoard.blockerCoverMaterialLevel = level
	end
end

function ItemView:playBlockerCoverMaterialWait()
	local item = self.itemSprite[ItemSpriteType.kBlockerCoverMaterial]
	if item then
		item:playWaitAnimation()
	end

	if self.oldBoard then
		self.oldBoard.blockerCoverMaterialLevel = -1
	end
end

function ItemView:buildLotus(lotusLevel)
	self:playLotusAnimation(lotusLevel , "in" , true)
end

function ItemView:setLotusHoldItemVisible(isvisible)

	if self.itemSprite[ItemSpriteType.kItem] then
		self.itemSprite[ItemSpriteType.kItem]:setVisible(isvisible)
	end

	if self.itemSprite[ItemSpriteType.kItemShow] then
		self.itemSprite[ItemSpriteType.kItemShow]:setVisible(isvisible)
	end

	if self.itemSprite[ItemSpriteType.kPacmanShow] then
		self.itemSprite[ItemSpriteType.kPacmanShow]:setVisible(isvisible)
	end

end

function ItemView:playLotusAnimation(currLotusLevel , animationType , initMode)
	--printx( 1 , "    ItemView:playLotusAnimation   " , currLotusLevel , animationType )
	if currLotusLevel <= 0 or currLotusLevel > 3 then return end

	--构建荷叶底层
	local isNewLotusBottom = false
	local isNewLotusTop = false
	if not self.itemSprite[ItemSpriteType.kLotus_bottom] then
		isNewLotusBottom = true
		self.itemSprite[ItemSpriteType.kLotus_bottom] = TileLotus:create(currLotusLevel , animationType , "bottom")
		self.itemSprite[ItemSpriteType.kLotus_bottom]:setPosition( ccp( (self.x - 0.5 ) * self.w , (Max_Item_Y - self.y - 0.5 ) * self.h ) )
	else
		self.itemSprite[ItemSpriteType.kLotus_bottom]:playAnimation(currLotusLevel , animationType , "bottom")
	end

	--构建荷叶顶层
	if not self.itemSprite[ItemSpriteType.kLotus_top] then
		isNewLotusTop = true
		self.itemSprite[ItemSpriteType.kLotus_top] = TileLotus:create(currLotusLevel , animationType , "top")
		self.itemSprite[ItemSpriteType.kLotus_top]:setPosition( ccp( (self.x - 0.5 ) * self.w , (Max_Item_Y - self.y - 0.5 ) * self.h ) )
	else
		self.itemSprite[ItemSpriteType.kLotus_top]:playAnimation(currLotusLevel , animationType , "top")
	end

	--setLotusHoldItemVisible方法已修改为由Action调用
	if initMode then
		if currLotusLevel == 3 and animationType == "in" then
			
			setTimeOut( function () 
					if self.oldData and self.oldData.lotusLevel == 3 then
						self:setLotusHoldItemVisible(false)
					end
					
				end , 22 / 24 )

		elseif currLotusLevel == 3 and animationType == "out" then
			self:setLotusHoldItemVisible(true)
		end
	end

	if currLotusLevel == 1 and animationType == "out" then
		local lotusbottom = self.itemSprite[ItemSpriteType.kLotus_bottom]
		local lotustop = self.itemSprite[ItemSpriteType.kLotus_top]

		if lotusbottom and (isNewLotusBottom or lotusbottom:getParent() == nil) then
			local container = self.getContainer(ItemSpriteType.kLotus_bottom)
			container:addChild(lotusbottom)
		end
		if lotustop and (isNewLotusTop or lotustop:getParent() == nil) then
			local container = self.getContainer(ItemSpriteType.kLotus_top)
			container:addChild(lotustop)
		end

		self.itemSprite[ItemSpriteType.kLotus_bottom] = nil
		self.itemSprite[ItemSpriteType.kLotus_top] = nil

		local function clearLotus()
			if lotusbottom and not lotusbottom.isDisposed then
				lotusbottom:removeFromParentAndCleanup(true)
			end
			if lotustop and not lotustop.isDisposed then
				lotustop:removeFromParentAndCleanup(true)
			end
		end
		setTimeOut(clearLotus , 10 / 24 )
		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayLotusClear1 )

	elseif currLotusLevel == 2 and animationType == "out" then
		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayLotusClear2 )
	elseif currLotusLevel == 3 and animationType == "out" then
		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayLotusClear2 )
	end
	self.isNeedUpdate = true
end

--处理蜗牛轨迹
function ItemView:initSnailRoad( data )
	-- body
	if self.itemSprite[ItemSpriteType.kSnailRoad] and not self.itemSprite[ItemSpriteType.kSnailRoad].isDisposed then
		self.itemSprite[ItemSpriteType.kSnailRoad]:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kSnailRoad] = nil
	end

	if data:getSnailRoadViewType() then
		local snailRoad
		if data.roadType == TileRoadShowType.kSnail then
			snailRoad = TileSnailRoad:create(data:getSnailRoadViewType(), data:getSnailRoadRotation())
			self.itemSprite[ItemSpriteType.kSnailRoad] = snailRoad
		else
			snailRoad = TileHedgehogRoad:create(data:getSnailRoadViewType(), data:getSnailRoadRotation(), data.hedgeRoadState)
			self.itemSprite[ItemSpriteType.kHedgehogRoad] = snailRoad
		end
		-- snailRoad:setPosition(self:getBasePosition())
	end
end

function ItemView:getBasePosition(x, y)
	local tempX = (x - 0.5 ) * self.w 
	local tempY = (Max_Item_Y - y - 0.5 ) * self.h
	return ccp(tempX, tempY)
end

function ItemView:getBasePositionWeek(x, y)
	local tempX = (x - 0.5 ) * GamePlayConfig_Tile_Width
	local tempY = (Max_Item_Y - y - 0.5 ) * GamePlayConfig_Tile_Width
	return ccp(tempX, tempY)
end

function ItemView:getBoardViewTransContainer()
	if not self.boardViewTransContainer then
		self.boardViewTransContainer = self:copyBoardTransData()
	end
	return self.boardViewTransContainer
end

function ItemView:removeBoardViewTranscontainer()
	if self.boardViewTransContainer and not self.boardViewTransContainer.isDisposed then
		self.boardViewTransContainer:removeFromParentAndCleanup(false)
		self.boardViewTransContainer:dispose()
	end
	self.boardViewTransContainer = nil
end

function ItemView:copyBoardTransData()
	local container = Sprite:createEmpty()
	container.items = {}
	container.datas = {}
	ItemView.copyDatasFrom(container.datas, self)
	for v = ItemSpriteType.kNone, ItemSpriteType.kLast do
		if table.exist(boardViewLayers, v) then
			local item = self.itemSprite[v]
			if item then
				container.items[v] = item
				item:removeFromParentAndCleanup(false)
				self.itemSprite[v] = nil
				container:addChild(item)
			end 
		end
	end

	for index, i in ipairs(needUpdateLayers) do
		if container.items[i] ~= nil then
			if self.itemPosAdd[i] ~= nil then	--itemPosAdd，是某些特殊原件的显示偏移量
				if i == ItemSpriteType.kClipping 
					or i == ItemSpriteType.kEnterClipping 
					then
					container.items[i]:setPositionXY(self.itemPosAdd[i].x + self.w / 2, self.h / 2 + self.itemPosAdd[i].y)
				else
					container.items[i]:setPositionXY(self.itemPosAdd[i].x, self.itemPosAdd[i].y)
				end
			else
				if i == ItemSpriteType.kClipping 
					or i == ItemSpriteType.kEnterClipping 
					then
					container.items[i]:setPositionXY(self.w / 2, self.h / 2)
				elseif i == ItemSpriteType.kBigMonster or i == ItemSpriteType.kWeeklyBoss or i == ItemSpriteType.kMoleBossCloud  then
					container.items[i]:setPositionXY(0.5 * self.w, - 0.5 * self.h)
				end
			end
		end
	end
	return container
end

--通过面板数据更新Item的位置信息
--forcePos 强制刷新
function ItemView:upDatePosBoardDataPos(data, forcePos)
	if data.isUsed == false then return end -- 不可用，跳过，什么都不显示
	self.x = data.x;
	self.y = data.y;
	self.w = data.w;
	self.h = data.h;

	if self.itemSprite[ItemSpriteType.kColorFilterB] then 
		self:hideFilterBHideLayers()
	end

	local tempX = (self.x - 0.5 ) * self.w 
	local tempY = (Max_Item_Y - self.y - 0.5 ) * self.h
	if self.pos_x ~= tempX or self.pos_y ~=tempY or forcePos then
		self.pos_x = tempX;
		self.pos_y = tempY;
		for index, i in ipairs(needUpdateLayers) do
			if self.itemSprite[i] ~= nil then
				if not self.itemSprite[i].refCocosObj then
					he_log_error("refCocosObj is null:" .. tostring(i))
				else
					-- if i == ItemSpriteType.kBigMonster or i == ItemSpriteType.kWeeklyBoss or i == ItemSpriteType.kMoleBossCloud then 
					-- 	if _G.isLocalDevelopMode then printx(0, tempX + 0.5 * self.w, tempY - 0.5 * self.h) end
					-- 	if _G.isLocalDevelopMode then printx(0, data.x, data.y, data.w, data.h) end
					-- 	-- debug.debug()
					-- end

					if self.itemPosAdd[i] ~= nil then	--itemPosAdd，是某些特殊原件的显示偏移量
						if i == ItemSpriteType.kClipping 
							or i == ItemSpriteType.kEnterClipping 
							then
							self.itemSprite[i]:setPositionXY(self.itemPosAdd[i].x + self.w / 2, self.h / 2 + self.itemPosAdd[i].y)
						else
							self.itemSprite[i]:setPositionXY(tempX + self.itemPosAdd[i].x, tempY + self.itemPosAdd[i].y)
						end
					else
						if i == ItemSpriteType.kClipping 
							or i == ItemSpriteType.kEnterClipping 
							then
							self.itemSprite[i]:setPositionXY(self.w / 2, self.h / 2)
						elseif i == ItemSpriteType.kBigMonster or i == ItemSpriteType.kWeeklyBoss  or i == ItemSpriteType.kMoleBossCloud then
							self.itemSprite[i]:setPositionXY(tempX + 0.5 * self.w, tempY - 0.5 * self.h)
						elseif i == ItemSpriteType.kLotus_bottom then
							self.itemSprite[i]:setPositionXY(tempX, tempY)
						else
							self.itemSprite[i]:setPositionXY(tempX, tempY)
						end
					end
				end
			end
		end
	end
end

function ItemView:initPosBoardDataPos(data, forcePos)
	if data.isUsed == false then return end -- 不可用，跳过，什么都不显示
	self.x = data.x;
	self.y = data.y;
	self.w = data.w;
	self.h = data.h;

	if self.itemSprite[ItemSpriteType.kColorFilterB] then 
		self:hideFilterBHideLayers()
	end

	local tempX = (self.x - 0.5 ) * self.w 
	local tempY = (Max_Item_Y - self.y - 0.5 ) * self.h
	if self.pos_x ~= tempX or self.pos_y ~=tempY or forcePos then
		self.pos_x = tempX;
		self.pos_y = tempY;
		for i = ItemSpriteType.kBackground, ItemSpriteType.kLast do
			if self.itemSprite[i] ~= nil then
				local shouldHandle = true
				if not self.itemSprite[i].refCocosObj then
					shouldHandle = false
					assert(false, "initPosBoardDataPos - refCocosObj is nil on layer:"..tostring(i)..",itemType:"..tostring(data.ItemType))
				end
				if shouldHandle then 
					if self.itemPosAdd[i] ~= nil then	--itemPosAdd，是某些特殊原件的显示偏移量
						if i == ItemSpriteType.kClipping 
							or i == ItemSpriteType.kEnterClipping 
							then
							self.itemSprite[i]:setPositionXY(self.itemPosAdd[i].x + self.w / 2, self.h / 2 + self.itemPosAdd[i].y)
						else
							self.itemSprite[i]:setPositionXY(tempX + self.itemPosAdd[i].x, tempY + self.itemPosAdd[i].y)
						end
					else
						if i == ItemSpriteType.kClipping 
							or i == ItemSpriteType.kEnterClipping 
							then
							self.itemSprite[i]:setPositionXY(self.w / 2, self.h / 2)
						elseif i == ItemSpriteType.kBigMonster or i == ItemSpriteType.kWeeklyBoss  or i == ItemSpriteType.kMoleBossCloud then  
							self.itemSprite[i]:setPositionXY(tempX + 0.5 * self.w, tempY - 0.5 * self.h)
						else
							self.itemSprite[i]:setPositionXY(tempX, tempY)
						end
					end
				end
			end
		end
	end
end

function ItemView:showFilterBHideLayers()
	for i,v in ipairs(ColorFilterBHideLayers) do
		if self.itemSprite[v] then
			self.itemSprite[v]:setVisible(true)
		end
	end
end

function ItemView:hideFilterBHideLayers()
	for i,v in ipairs(ColorFilterBHideLayers) do
		if self.itemSprite[v] then
			self.itemSprite[v]:setVisible(false)
		end
	end
end

function ItemView:initByItemData(data, doNotCleanFormerView)	--通过GameItem的数据进行初始化
	if data.isUsed == false then return end -- 不可用，跳过，什么都不显示

	if (not doNotCleanFormerView) then 
		self:cleanGameItemView()
	end
	self.oldData = data:copy()
	self.x = data.x;
	self.y = data.y;
	self.w = data.w;
	self.h = data.h;

	--基本属性
	if data.ItemType == GameItemType.kAnimal then
		self:buildNewAnimalItem(data._encrypt.ItemColorType, data.ItemSpecialType, true, true, data.hasActCollection)
	elseif data.ItemType == GameItemType.kSnow then	--雪
		local snowsprite = ItemViewUtils:buildSnow(data.snowLevel)
		self.itemSprite[ItemSpriteType.kItem] = snowsprite
	elseif data.ItemType == GameItemType.kCrystal then	--由系统统一计算
		self.itemShowType = ItemSpriteItemShowType.kCharacter
		self.itemSprite[ItemSpriteType.kItem] = ItemViewUtils:buildCrystal(data._encrypt.ItemColorType, data.hasActCollection)          ------水晶
	elseif data.ItemType == GameItemType.kGift or data.ItemType == GameItemType.kNewGift then		--由系统统一计算
		self.itemShowType = ItemSpriteItemShowType.kCharacter
		self.itemSprite[ItemSpriteType.kItem] = ItemViewUtils:buildGift(data._encrypt.ItemColorType)
	elseif data.ItemType == GameItemType.kIngredient then
		local beanpod = ItemViewUtils:buildBeanpod(data.showType)
		self.itemSprite[ItemSpriteType.kItem] = beanpod
	elseif data.ItemType == GameItemType.kVenom then
		self:buildVenom()
	elseif data.ItemType == GameItemType.kCoin then
		self:buildCoin()
	elseif data.ItemType == GameItemType.kRoost then
		self:buildRoost(data.roostLevel)
	elseif data.ItemType == GameItemType.kBalloon then
		self:buildBalloon(data)
	elseif data.ItemType == GameItemType.kDigGround then        ----------挖地障碍 地块 宝石块
		self:buildDigGround(data.digGroundLevel)
	elseif data.ItemType == GameItemType.kDigJewel then 
		self:buildDigJewel(data.digJewelLevel, self.context.levelType)
	elseif data.ItemType == GameItemType.kAddMove then
		self:buildAddMove(data._encrypt.ItemColorType, data.numAddMove)
	elseif data.ItemType == GameItemType.kPoisonBottle then 
		self:buildPoisonBottle(data.forbiddenLevel)
	elseif data.ItemType == GameItemType.kBigMonster then 
		self:buildMonster()
	elseif data.ItemType == GameItemType.kChestSquare then
		self:buildChestSquare()
	elseif data.ItemType == GameItemType.kBlackCuteBall then 
		self:buildBlackCuteBall(data.blackCuteStrength, data.blackCuteMaxStrength)
	elseif data.ItemType == GameItemType.kMimosa or data.ItemType == GameItemType.kKindMimosa then
		self:buildMimosa(data)
	elseif data.isSnail then
		self:buildSnail(data.snailRoadType)
	elseif data.bossLevel and data.bossLevel > 0 then 
		self:buildBoss(data)
	elseif data.weeklyBossLevel and data.weeklyBossLevel > 0 then 
		self:buildWeeklyBoss(data)
	elseif data.moleBossCloudLevel and data.moleBossCloudLevel > 0 then 
		self:buildMoleBossCloud(data)
	elseif data.ItemType == GameItemType.kRabbit then
		self:buildRabbit(data._encrypt.ItemColorType, data.rabbitLevel, GameItemRabbitState.kSpawn == data.rabbitState)
	elseif data.ItemType == GameItemType.kMagicLamp then
		self:buildMagicLamp(data._encrypt.ItemColorType, data.lampLevel)
	elseif data.ItemType == GameItemType.kWukong then
		self:buildWukong(data)
	elseif data.ItemType == GameItemType.kSuperBlocker then
		self:buildSuperBlocker()
	elseif data.ItemType == GameItemType.kHoneyBottle then
		self:buildHoneyBottle(data.honeyBottleLevel)
	elseif data.ItemType == GameItemType.kAddTime then
		self:buildAddTime(data._encrypt.ItemColorType, data.addTime)
	elseif data.ItemType == GameItemType.kQuestionMark then
		self:buildQuestionMark(data._encrypt.ItemColorType)
	elseif data.ItemType == GameItemType.kMagicStone then
		self:buildMagicStone(data.magicStoneDir, data.magicStoneLevel)
	elseif data.ItemType == GameItemType.kBottleBlocker then
		self:buildBottleBlocker(data.bottleLevel , data._encrypt.ItemColorType)
	elseif data:isHedgehog() then
		self:buildHedgehog(data.snailRoadType, data.hedgehogLevel, data.hedge_before)
	elseif data.ItemType == GameItemType.kHedgehogBox then
		self:buildHedgehogBox()
	elseif data.ItemType == GameItemType.kRocket then
		self:buildRocket(data._encrypt.ItemColorType)	
	elseif data.ItemType == GameItemType.kCrystalStone then
		self:buildCrystalStone(data._encrypt.ItemColorType, data.crystalStoneEnergy, data.crystalStoneBombType)
	elseif data.ItemType == GameItemType.kTotems then
		self:buildTotems(data._encrypt.ItemColorType, data:isActiveTotems())
	elseif data.ItemType == GameItemType.kDrip then
		self:buildDrip()
	elseif data.ItemType == GameItemType.kPuffer then
		self:buildPuffer( false , data.pufferState)
	elseif data.ItemType == GameItemType.kOlympicBlocker then
		self:buildOlympicBlocker(data)
	elseif data.ItemType == GameItemType.kMissile then
		self:buildMissile(data)
	elseif data.ItemType == GameItemType.kRandomProp then
		self:buildRandomProp(data)
	elseif data.ItemType == GameItemType.kTangChicken then
		self:buildTangChicken(data)
	elseif data.ItemType == GameItemType.kBlocker195 then
		self:buildBlocker195(data)
	elseif data.ItemType == GameItemType.kBlocker199 then
		self:buildBlocker199(data)
	elseif data.ItemType == GameItemType.kChameleon then
		self:buildChameleon(data)
	elseif data.ItemType == GameItemType.kBuffBoom then
		self:buildBuffBoom( data )
	elseif data.ItemType == GameItemType.kBlocker207 then
		self:buildBlocker207()
	elseif data.ItemType == GameItemType.kPacman then 
		self:buildPacman(data)
	elseif data.ItemType == GameItemType.kPacmansDen then 
		self:buildPacmansDen()
	elseif data.ItemType == GameItemType.kBlocker211 then
		self:buildBlocker211(data)
    elseif data.ItemType == GameItemType.kTurret then
		self:buildTurret(data.turretDir, data.turretIsTypeRandom, data.turretLevel, data.turretIsSuper)
	elseif data.ItemType == GameItemType.kMoleBossSeed then
		self:buildMoleBossSeed(data.moleBossSeedCountDown)
    elseif data.ItemType == GameItemType.kYellowDiamondGrass then
		self:buildYellowDiamond( data.yellowDiamondLevel )
	elseif data.ItemType == GameItemType.kScoreBuffBottle then
		self:buildScoreBuffBottle(data)
	elseif data.ItemType == GameItemType.kSunFlask then
		self:buildSunFlask(data.sunFlaskLevel)
	elseif data.ItemType == GameItemType.kSunflower then
		self:buildSunflower()
	elseif data.ItemType == GameItemType.kFirecracker then
		self:buildFirecracker(data)
	elseif data.ItemType == GameItemType.kSquid then 
		self:buildSquid(data)
    elseif data.ItemType == GameItemType.kWanSheng then
        self:buildWanSheng(data)
	end

	-- if self.oldBoard and self.oldBoard.magicTileId ~= nil then
	-- 	self:addMagicTileWater(data)
	-- end

	--附加属性
	if data:hasFurball() then
		self:cleanFurballView()
		self.itemSprite[ItemSpriteType.kFurBall] = ItemViewUtils:buildFurball(data.furballType)
		if data.furballType == GameItemFurballType.kBrown and data.isBrownFurballUnstable then
			self:playFurballUnstableEffect()
		end
	end

	if data.olympicLockLevel > 0 then
		self:buildOlympicLockBlocker(data)
	end

	if data.cageLevel > 0 then
		self.itemSprite[ItemSpriteType.kLock] = ItemViewUtils:buildLocker(data.cageLevel)	
	end

	if data.honeyLevel > 0 then
		self:buildHoney(data.honeyLevel)
	end

	if data.blockerCoverLevel > 0 then
		self:growupBlockerCover(data.blockerCoverLevel)
	end

	if data:seizedByGhost() then
		self:addGhost()
	end

	-- 你这家伙事儿最多，要不要放在最后？ =____,=
	if data.isReverseSide then 
		self:setTileBlockCoverSpriteVisible(false)
	end

	if data.bigMonsterFrostingType> 0 and data.bigMonsterFrostingStrength > 0 then --雪怪的冰块
		self.itemSprite[ItemSpriteType.kBigMonsterIce] = ItemViewUtils:buildMonsterFrosting(data.bigMonsterFrostingType)
	end

	if data.chestSquarePartType > 0 and data.chestSquarePartStrength > 0 then --大宝箱的冰块
		self.itemSprite[ItemSpriteType.kChestSquarePart] = TileChestSquarePart:create(data.chestSquarePartType)
		self.itemSprite[ItemSpriteType.kChestSquarePartFront] = TileChestSquarePart:createFront(data.chestSquarePartType)
	end

	if data.beEffectByMimosa > 0 then
		self:addMimosaEffect(data.beEffectByMimosa ,data.mimosaDirection)
	end

	if data:hasBlocker206() then
		self:buildBlocker206( false , data )
	end
end

function ItemView:buildBuffBoom( datas , isOnlyGetSprite)
	local sprite = TileBuffBoom:create( datas.level , TileBuffBoomState.kNormal )

	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
	end
	return sprite
end

function ItemView:decBuffBoom()
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]

	if sprite then
		sprite:changeBuffBoomState( TileBuffBoomState.kOnHit )
	end
end

function ItemView:decBuffBoomToLevel(level)
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]

	if sprite then
		local count = sprite.level - level
		if count > 0 then
			for i = 1 , count do
				sprite:changeBuffBoomState( TileBuffBoomState.kOnHit )
			end
		end
	end
end

function ItemView:explodeBuffBoom()

	local sprite = self.itemSprite[ItemSpriteType.kItemShow]

	if sprite then
		sprite:changeBuffBoomState( TileBuffBoomState.kExplode )
	end
end

function ItemView:hideBuffBoom()

	local sprite = self.itemSprite[ItemSpriteType.kItemShow]

	if sprite then
		sprite:hideBody()
	end
end

function ItemView:playBoomByBuffBoomFromPos( animType, fromCCP, callback)
	local animation = nil

	
	--local boom , boomAnimate = SpriteUtil:buildAnimatedSprite(1/12, "buff_boom_ball_%04d", 1, 3 , true)
	local boom = Sprite:createWithSpriteFrameName( "buff_boom_ball_0001" )

	--[[
	local ball, animate = SpriteUtil:buildAnimatedSprite(1/24, "buff_boom_ball_eff/buff_boom_ball_eff_%04d", 1, 24 , false)
	local oriScale = 0.65
	ball:play(animate, 0, 0)
	]]
	local oriScale = 0.9

	--boom:play( boomAnimate , 0 , 0 )

	local toCCP = self:getBasePosition(self.x, self.y)

	local fromPos = {x = fromCCP.x, y = fromCCP.y}
	local toPos = {x = toCCP.x + 3, y = toCCP.y - 2}

	if animType == 1 then
		boom:setPositionXY( fromPos.x , fromPos.y + 11 )
		boom:setScale( 1 * oriScale )
		--boom:setRotation(0)
	elseif animType == 2 then
		boom:setPositionXY( fromPos.x - 11 , fromPos.y )
		boom:setScale( 1 * oriScale )
		boom:setRotation(-15)
	elseif animType == 3 then
		boom:setPositionXY( fromPos.x + 11 , fromPos.y )
		boom:setScale( 1 * oriScale )
		boom:setRotation(15)
	end

	local function onBoomAnimComplete()
		if self.itemSprite[ItemSpriteType.kRoostFly] then
			self.itemSprite[ItemSpriteType.kRoostFly]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kRoostFly] = nil
		end
	end

	local function onRemoveBall()
		
		if self.itemSprite[ItemSpriteType.kSpecial] then
			self.itemSprite[ItemSpriteType.kSpecial]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kSpecial] = nil
		end
		--[[
		if boom and boom:getParent() and not boom.isDisposed then
			boom:stopAllActions()
			boom:removeFromParentAndCleanup(true)
		end
		]]
		if callback then callback() end
	end

	local function bezierCompleteCallback()
	end

	local function showBoomEff()

		local boomEff , boomEffAnimate = SpriteUtil:buildAnimatedSprite(1/24, "buff_boom_ball_eff_%04d", 1, 16 , false)
		boomEff:play(boomEffAnimate, 0, 1, onBoomAnimComplete, false)
		boomEff:setPositionXY( toPos.x , toPos.y )
		self.itemSprite[ItemSpriteType.kRoostFly] = boomEff
		self.isNeedUpdate = true
	end

	local function runAct1()

		local controlPoint = nil
		controlPoint = ccp(toPos.x - (toPos.x - fromPos.x) / 5, toPos.y + 600)

		local bezierConfig = ccBezierConfig:new()
		bezierConfig.controlPoint_1 = ccp(fromPos.x, fromPos.y)
		bezierConfig.controlPoint_2 = controlPoint
		bezierConfig.endPosition = ccp(toPos.x, toPos.y)
		local bezierAction = CCBezierTo:create(0.5, bezierConfig)
		local callbackAction = CCCallFunc:create( bezierCompleteCallback )
		local delayAction = CCDelayTime:create(0.01)

		local actionList = CCArray:create()
		actionList:addObject(bezierAction)
		actionList:addObject(callbackAction)
		actionList:addObject(delayAction)
		actionList:addObject(CCCallFunc:create(onRemoveBall))
		local sequenceAction = CCSequence:create(actionList)

		boom:runAction(sequenceAction)

		local actionList2 = CCArray:create()
		actionList2:addObject(CCDelayTime:create(0.45))
		actionList2:addObject(CCCallFunc:create(showBoomEff))

		boom:runAction(CCSequence:create(actionList2))
	end

	local function runAct2()

		local actArr = CCArray:create()
		actArr:addObject(CCRotateTo:create(0.1, 90))
		actArr:addObject(CCRotateTo:create(0.1, 180))
		actArr:addObject(CCRotateTo:create(0.1, 270))
		actArr:addObject(CCRotateTo:create(0.1, 360))

		boom:runAction( CCRepeatForever:create( CCSequence:create(actArr) ) )
	end

	local t1 = 0.1

	local actArr2 = CCArray:create()
	actArr2:addObject( CCEaseSineOut:create( CCScaleTo:create(t1, oriScale , 0.5*oriScale) ) )
	actArr2:addObject( CCEaseSineIn:create( CCScaleTo:create(t1, oriScale , 1*oriScale) ) )
	actArr2:addObject( CCCallFunc:create( function () 
			runAct1()
			runAct2()
		end) )

	boom:runAction( CCSequence:create(actArr2) )

	local actArr3 = CCArray:create()

	if animType == 1 then
		actArr3:addObject( CCEaseSineOut:create( CCMoveTo:create(t1, ccp(fromPos.x , fromPos.y - 15) ) ) )
		actArr3:addObject( CCEaseSineIn:create( CCMoveTo:create(t1, ccp(fromPos.x , fromPos.y) ) ) )
	elseif animType == 2 then
		actArr3:addObject( CCEaseSineOut:create( CCMoveTo:create(t1, ccp(fromPos.x - 11 , fromPos.y - 15) ) ) )
		actArr3:addObject( CCEaseSineIn:create( CCMoveTo:create(t1, ccp(fromPos.x - 11 , fromPos.y) ) ) )
	elseif animType == 3 then
		actArr3:addObject( CCEaseSineOut:create( CCMoveTo:create(t1, ccp(fromPos.x + 11 , fromPos.y - 15) ) ) )
		actArr3:addObject( CCEaseSineIn:create( CCMoveTo:create(t1, ccp(fromPos.x + 11 , fromPos.y) ) ) )
	end

	boom:runAction( CCSequence:create(actArr3) )

	self.itemSprite[ItemSpriteType.kSpecial] = boom

	local function forceRemoveBoom()
		if boom and boom:getParent() and not boom.isDisposed then
			boom:stopAllActions()
			boom:removeFromParentAndCleanup(true)
		end
		if self.itemSprite[ItemSpriteType.kSpecial] == boom then
			self.itemSprite[ItemSpriteType.kSpecial] = nil
		end
	end

	setTimeOut( forceRemoveBoom , 1 )

	self.isNeedUpdate = true	
end


function ItemView:buildTangChicken(data)
	self.itemSprite[ItemSpriteType.kItemShow] = TileNationDayStarBox:create(data.tangChickenNum or 1)
end

function ItemView:playTangChickenDisappear(playCollectAnimFunc, toPos, chickenNum)
	local tangChicken = self.itemSprite[ItemSpriteType.kItemShow]
	if tangChicken then
		local callback = function( ... )
			tangChicken:removeFromParentAndCleanup(true)
		end
		tangChicken:removeFromParentAndCleanup(false)
		self.itemSprite[ItemSpriteType.kItemShow] = nil
		self.isNeedUpdate = true

		self.getContainer(ItemSpriteType.kTopLevelEffect):addChild(tangChicken)
		tangChicken:playDisappearAnim(playCollectAnimFunc, callback, toPos, chickenNum)
	end
end

function ItemView:buildOlympicLockBlocker(data, isOnlyGetSprite)
	local sprite = TileOlympicLock:create(data.olympicLockLevel)
	if not isOnlyGetSprite then
		local oldSprite = self.itemSprite[ItemSpriteType.kOlympicLock]
		if oldSprite and not oldSprite.isDisposed then
			oldSprite:removeFromParentAndCleanup(true)
		end
		self.itemSprite[ItemSpriteType.kOlympicLock] = sprite
	end
	return sprite
end

function ItemView:buildMissile(data,isOnlyGetSprite)
	local sprite = TileMissile:create(data.missileLevel)
	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
	end
	return sprite
end

function ItemView:buildChameleon(data,isOnlyGetSprite)
	local sprite = TileChameleon:create()
	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
	end
	return sprite
end

function ItemView:buildPacman(data, isOnlyGetSprite)
	local mainLogic = GameBoardLogic:getCurrentLogic()

	if data.pacmanColour == 0 then
		local index = mainLogic.randFactory:rand(1, #mainLogic.mapColorList)
		data.pacmanColour = AnimalTypeConfig.convertColorTypeToIndex(mainLogic.mapColorList[index])
	end

	local maxDevourAmount = (mainLogic.pacmanConfig and mainLogic.pacmanConfig.devourCount) or 1

	local texture
	if self.getContainer(ItemSpriteType.kPacmanShow) then 
		texture = self.getContainer(ItemSpriteType.kPacmanShow).refCocosObj:getTexture()
	end
	local sprite = TilePacman:create(texture, data.pacmanColour, data.pacmanDevourAmount, maxDevourAmount, data.pacmanIsSuper)
	-- printx(11, "buildPacman, pacmanIsSuper:", data.pacmanIsSuper)
	if data.pacmanIsSuper and data.pacmanIsSuper == 2 then
		-- printx(11, "change pacmanIsSuper to 1")
		data.pacmanIsSuper = 1	--动画更新完，恢复原状
	end

	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kPacmanShow] = sprite
	end
	return sprite
end

function ItemView:buildPacmansDen(isOnlyGetSprite)
	local texture
	if self.getContainer(ItemSpriteType.kPacmanShow) then 
		texture = self.getContainer(ItemSpriteType.kPacmanShow).refCocosObj:getTexture()
	end
	local sprite = TilePacmansDen:create(texture)

	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kPacmanShow] = sprite
	end
	return sprite
end

function ItemView:buildRandomProp(data,isOnlyGetSprite)
	local sprite = TileRandomProp:create(data.randomPropDropId)
	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kRandomProp] = sprite
	end
	return sprite
end


function ItemView:buildOlympicBlocker(data, isOnlyGetSprite)
	local sprite = TileOlympicBlocker:create(data.olympicBlockerLevel)
	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
	end
	return sprite
end

function ItemView:buildPuffer(isOnlyGetSprite , pufferState)
	local sprite = TilePuffer:create(self , pufferState)

	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
	end
	return sprite
end

function ItemView:changePufferState(newData)
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	local newState = newData.pufferState

	local function finishCallback()
		if newState == PufferState.kExplode then
			self.itemSprite[ItemSpriteType.kSpecial] = nil
			-- if sprite and not sprite.isDisposed then
			-- 	sprite:removeFromParentAndCleanup(false)
			-- end
		end 
	end

	if sprite then
		sprite:changePufferState(newState , finishCallback)

		if newState == PufferState.kExplode then
			sprite:removeFromParentAndCleanup(false)
			self.itemSprite[ItemSpriteType.kItemShow] = nil
			---------- 在某些现在还未知的条件下，special层的视图会被莫名移除，导致不会走入finishCallback，
			---------- 因而ItemSpriteType.kSpecial的引用就不会被移除，由此会产生bug，故先不进行引用
			------------------------ 不清除有可能疑似内存泄露(?)，不引用清除后看不见视图……
			------------------------ 总之先不改了，至少之前的某特定bug通过修复别的相关模块也能规避……
			------------------------ 不过这个问题还是需要修复的，源头就是special被莫名移除
			self.itemSprite[ItemSpriteType.kSpecial] = sprite
			self.isNeedUpdate = true
		end
	end
end

function ItemView:buildDrip(isOnlyGetSprite)
	
	local sprite = TileDrip:create(self)
	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
	end
	return sprite
end

function ItemView:changeDripState(newData)
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	local newState = newData.dripState
	local newMovePos = self:getBasePosition( newData.dripLeaderPos.x , newData.dripLeaderPos.y )

	if sprite and sprite.changeDripState then
		sprite:changeDripState(newState , newMovePos)

		if newState == DripState.kCasting then
			self.itemSprite[ItemSpriteType.kItemShow] = nil
			self.itemSprite[ItemSpriteType.kItemHighLevel] = sprite
			self.isNeedUpdate = true
		elseif newState == DripState.kMove then
			--self.itemSprite[ItemSpriteType.kItemShow] = nil
			--self.itemSprite[ItemSpriteType.kItemHighLevel] = sprite
			--self.isNeedUpdate = true
		end
	end
end

function ItemView:buildCrystalStone(colortype, energy, bombType, isOnlyGetSprite)
	local sprite = TileCrystalStone:create(colortype, energy/GamePlayConfig_CrystalStone_Energy, bombType)
	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
	end
	return sprite
end

function ItemView:buildRocket(colortype, isOnlyGetSprite)
	local rocket = TileRocket:create(colortype)
	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kItemShow] = rocket
		self.itemShowType = ItemSpriteItemShowType.kCharacter
	end
	return rocket
end

function ItemView:buildBottleBlocker( bottleLevel , itemColorType , texture , isOnlyGetSprite )
	local sprite = TileBottleBlocker:create(bottleLevel, itemColorType)
	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
	end
	return sprite
end

function ItemView:buildMagicStone(magicStoneDir, magicStoneLevel)
	local sprite = TileMagicStone:create(magicStoneLevel, magicStoneDir)
	self.itemSprite[ItemSpriteType.kItemShow] = sprite
	return sprite
end

function ItemView:buildDigGround( digLevel, isOnlyGetSprite )
	-- body
	local texture
	if self.getContainer(ItemSpriteType.kDigBlocker) then 
		texture = self.getContainer(ItemSpriteType.kDigBlocker).refCocosObj:getTexture()
	end

	-- if self.context.levelType == GameLevelType.kSummerWeekly then
	-- 	local digJewelCls = require "zoo.modules.weekly2017s1.TileDigGroundWeekly"
	-- 	view = digJewelCls:create(digLevel, texture)
	-- else
		view = TileDigGround:create(digLevel, texture, self.context.levelType )
	-- end

	if isOnlyGetSprite then
		return view
	else
		self.itemSprite[ItemSpriteType.kDigBlocker] = view
		if self.context.levelType == GameLevelType.kSummerWeekly then
			self.itemPosAdd[ItemSpriteType.kDigBlocker] = ccp(0, -5)
		end
	end
end

function ItemView:buildDigJewel( digLevel, levelType, isOnlyGetSprite)
	-- body
	local texture
	if self.getContainer(ItemSpriteType.kDigBlocker) then 
		texture = self.getContainer(ItemSpriteType.kDigBlocker).refCocosObj:getTexture()
	end
	local view = nil

	-- if levelType == GameLevelType.kSummerWeekly then
	-- 	local digJewelCls = require "zoo.modules.weekly2017s1.TileDigJewelWeekly"
	-- 	view = digJewelCls:create(digLevel, texture)
	-- else
		view = TileDigJewel:create(digLevel, texture, levelType)
	-- end

	if isOnlyGetSprite then
		return view
	else
		self.itemSprite[ItemSpriteType.kDigBlocker] = view
		if self.context.levelType == GameLevelType.kSummerWeekly then
			self.itemPosAdd[ItemSpriteType.kDigBlocker] = ccp(0, -5)
		end
	end
end

function ItemView:buildYellowDiamond( digLevel, isOnlyGetSprite)
	-- body
	local texture
	if self.getContainer(ItemSpriteType.kDigBlocker) then 
		texture = self.getContainer(ItemSpriteType.kDigBlocker).refCocosObj:getTexture()
	end
	local view = nil

	view = TileYellowDiamond:create(digLevel, texture)

	if isOnlyGetSprite then
		return view
	else
		self.itemSprite[ItemSpriteType.kDigBlocker] = view
		if self.context.levelType == GameLevelType.kSummerWeekly then
			self.itemPosAdd[ItemSpriteType.kDigBlocker] = ccp(0, -5)
		end
	end
end

function ItemView:buildJamSperad(isOnlyGetSprite, bAnim )
	-- body
	local texture
	if self.getContainer(ItemSpriteType.kJamSperad) then 
		texture = self.getContainer(ItemSpriteType.kJamSperad).refCocosObj:getTexture()
	end
	local view = nil
    if bAnim == nil then bAnim = false end

	view = TileJamSperad:create( texture, bAnim )

	if isOnlyGetSprite then
		return view
	else
		self.itemSprite[ItemSpriteType.kJamSperad] = view
	end
end

function ItemView:getItemSprite(theType)
	if theType == ItemSpriteType.kClipping then
		return self.clippingnode
	end 		----裁减节点特殊处理

	if theType == ItemSpriteType.kEnterClipping then
		return self.enterClippingNode
	end

	return self.itemSprite[theType];
end

function ItemView:cleanGameItemView()
	if self.itemSprite[ItemSpriteType.kItem] then self.itemSprite[ItemSpriteType.kItem]:removeFromParentAndCleanup(true); self.itemSprite[ItemSpriteType.kItem] = nil; end;
	if self.itemSprite[ItemSpriteType.kItemShow] then self.itemSprite[ItemSpriteType.kItemShow]:removeFromParentAndCleanup(true); self.itemSprite[ItemSpriteType.kItemShow] = nil; end;
	if self.itemSprite[ItemSpriteType.kItemHighLevel] then self.itemSprite[ItemSpriteType.kItemHighLevel]:removeFromParentAndCleanup(true); self.itemSprite[ItemSpriteType.kItemHighLevel] = nil; end;
	if self.itemSprite[ItemSpriteType.kItemLowLevel] then self.itemSprite[ItemSpriteType.kItemLowLevel]:removeFromParentAndCleanup(true); self.itemSprite[ItemSpriteType.kItemLowLevel] = nil; end;
	if self.itemSprite[ItemSpriteType.kFurBall] then self.itemSprite[ItemSpriteType.kFurBall]:removeFromParentAndCleanup(true); self.itemSprite[ItemSpriteType.kFurBall] = nil; end;
	if self.itemSprite[ItemSpriteType.kHoney] then self.itemSprite[ItemSpriteType.kHoney]:removeFromParentAndCleanup(true); self.itemSprite[ItemSpriteType.kHoney] = nil; end;
	if self.itemSprite[ItemSpriteType.kPacmanShow] then self.itemSprite[ItemSpriteType.kPacmanShow]:removeFromParentAndCleanup(true); self.itemSprite[ItemSpriteType.kPacmanShow] = nil; end;
	if self.itemSprite[ItemSpriteType.kSquidShow] then self.itemSprite[ItemSpriteType.kSquidShow]:removeFromParentAndCleanup(true); self.itemSprite[ItemSpriteType.kSquidShow] = nil; end;
	if self.itemSprite[ItemSpriteType.kMoleWeeklyItemShow] then self.itemSprite[ItemSpriteType.kMoleWeeklyItemShow]:removeFromParentAndCleanup(true); self.itemSprite[ItemSpriteType.kMoleWeeklyItemShow] = nil; end;
	if self.itemSprite[ItemSpriteType.kGhost] then self:cleanGhostView() end
end

function ItemView:cleanFurballView()
	if self.itemSprite[ItemSpriteType.kFurBall] then
		self.itemSprite[ItemSpriteType.kFurBall]:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kFurBall] = nil
	end
end

function ItemView:cleanFurballEffectView()
	if self.itemSprite[ItemSpriteType.kNormalEffect] then
		self.itemSprite[ItemSpriteType.kNormalEffect]:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kNormalEffect] = nil
	end
end

function ItemView:getGameItemSprite()
	local baseSprite
	local coverSprite

	local layersCollection = {ItemSpriteType.kItemShow, ItemSpriteType.kItem, ItemSpriteType.kItemHighLevel}
	for i = 3, #ItemSpriteCanSwapLayers do
		table.insert(layersCollection, ItemSpriteCanSwapLayers[i])
	end
	for i = 1, #layersCollection do
		local layerType = layersCollection[i]
		if self.itemSprite[layerType] then
			baseSprite = self.itemSprite[layerType]
			break
		end
	end

	ghostSprite = self.itemSprite[ItemSpriteType.kGhost]
	if ghostSprite then coverSprite = ghostSprite end

	return baseSprite, coverSprite
end

function ItemView:playWrapItemBombEffect()
	local thingToRemove = self.itemSprite[ItemSpriteType.kItemShow]
	if thingToRemove then
		local function onAnimComplete()
			thingToRemove:removeFromParentAndCleanup(true)
		end

		local actionSeq = CCArray:create()
		actionSeq:addObject(CCDelayTime:create(BoardViewAction:getActionTime(5)))
		actionSeq:addObject(CCScaleTo:create(BoardViewAction:getActionTime(3), 1))
		actionSeq:addObject(CCScaleTo:create(BoardViewAction:getActionTime(1), 1.5))
		actionSeq:addObject(CCFadeOut:create(BoardViewAction:getActionTime(3)))
		actionSeq:addObject(CCCallFunc:create(onAnimComplete))

		local destroySprite = thingToRemove.mainSprite
		if destroySprite and destroySprite.refCocosObj then 
			destroySprite:setScale(0.82)
			destroySprite:runAction(CCSequence:create(actionSeq))
		end
	end

	local t3 = self.itemSprite[ItemSpriteType.kClipping]
	if t3 then
		if t3:getParent() then t3:removeFromParentAndCleanup(true) end
		self.itemSprite[ItemSpriteType.kClipping] = nil
	end

	local t4 = self.itemSprite[ItemSpriteType.kEnterClipping]
	if t4 then
		if t4:getParent() then t4:removeFromParentAndCleanup(true) end
		self.itemSprite[ItemSpriteType.kEnterClipping] = nil
	end
end

function ItemView:playAnimalSpriteZoomIn()
	local t1 = self.itemSprite[ItemSpriteType.kItemShow]
	local t2 = self.itemSprite[ItemSpriteType.kItem]

	if self.itemShowType == ItemSpriteItemShowType.kCharacter then 		----清除动物，然后删除效果
		local sprite = nil;
		if t1 ~= nil then 			----动物特效
			sprite = self.itemSprite[ItemSpriteType.kItemShow].mainSprite;
		else 					 	----普通动物
			sprite = self.itemSprite[ItemSpriteType.kItem];
		end

		if sprite and sprite.refCocosObj then
			sprite:setScale(1)

			local actionSeq = CCArray:create()
			actionSeq:addObject(CCScaleTo:create(3*kCharacterAnimationTime, 1.14))
			actionSeq:addObject(CCScaleTo:create(2*kCharacterAnimationTime, 1))

			sprite:runAction(CCSequence:create(actionSeq))
		end
	end
end

------小动物和鸟的消除动画--------
function ItemView:playAnimationAnimalDestroy()
	local t1 = self.itemSprite[ItemSpriteType.kItemShow]
	local t2 = self.itemSprite[ItemSpriteType.kItem]
	self.isNeedUpdate = true 		----提示界面进行更新
	----1.选择消失动画类型
	if self.itemShowType == ItemSpriteItemShowType.kBird then
		if t1 then self:playBirdNormal_BirdDestroyEffect() end
		-- if t1 then t1:play(kTileBirdAnimation.kDestroy) end
	elseif self.itemShowType == ItemSpriteItemShowType.kCharacter then 		----清除动物，然后删除效果
		local destroySprite = nil;
		local thingToRemove = nil;
		local colorIndex = nil
		if t1 ~= nil then 			----动物特效
			destroySprite = self.itemSprite[ItemSpriteType.kItemShow].mainSprite;
			thingToRemove = self.itemSprite[ItemSpriteType.kItemShow];
			local animalName = self.itemSprite[ItemSpriteType.kItemShow].name
			colorIndex = animalName and getColorIndexByAnimalName(animalName) or nil
		else 					 	----普通动物
			destroySprite = self.itemSprite[ItemSpriteType.kItem];
			thingToRemove = self.itemSprite[ItemSpriteType.kItem];
			colorIndex = destroySprite and destroySprite.colorIndex or nil
		end

		local actionarray = CCArray:create()
		actionarray:addObject(CCScaleTo:create(BoardViewAction:getActionTime(GamePlayConfig_GameItemAnimalDeleteAction_CD_View), 0.3));
		actionarray:addObject(CCFadeTo:create(BoardViewAction:getActionTime(GamePlayConfig_GameItemAnimalDeleteAction_CD_View), 168));
		actionarray:addObject(CCTintTo:create(BoardViewAction:getActionTime(GamePlayConfig_GameItemAnimalDeleteAction_CD_View), 0, 170, 229));
		local spawnAction = CCSpawn:create(actionarray);
		local function removeCharacterAction()
			thingToRemove:removeFromParentAndCleanup(true);
		end 
		local callAction = CCCallFunc:create(removeCharacterAction)
		local sequenceAction = CCSequence:createWithTwoActions(spawnAction, callAction)
		if destroySprite and destroySprite.refCocosObj then 	
			destroySprite:runAction(sequenceAction);
			self:playAnimationAnimalDestroy_DestroyEffect(colorIndex);		----播放动物删除的雪花爆炸特效	
		end
	elseif self.itemShowType == ItemSpriteItemShowType.kCoin then
		if t1 then t1:playDestroyAnimation() end
	elseif self.oldData.ItemType == GameItemType.kBlocker207 and self.itemShowType == ItemSpriteItemShowType.kBlocker207 then
		--[[
		local destroySprite = nil;
		local thingToRemove = nil;
		local colorIndex = nil
		if t1 ~= nil then 			----动物特效
			destroySprite = self.itemSprite[ItemSpriteType.kItemShow].mainSprite;
			thingToRemove = self.itemSprite[ItemSpriteType.kItemShow];
			colorIndex = 6
		else 					 	----普通动物
			destroySprite = self.itemSprite[ItemSpriteType.kItem];
			thingToRemove = self.itemSprite[ItemSpriteType.kItem];
			colorIndex = 6
		end

		local actionarray = CCArray:create()
		actionarray:addObject(CCScaleTo:create(BoardViewAction:getActionTime(GamePlayConfig_GameItemAnimalDeleteAction_CD_View), 0.3));
		actionarray:addObject(CCFadeTo:create(BoardViewAction:getActionTime(GamePlayConfig_GameItemAnimalDeleteAction_CD_View), 168));
		actionarray:addObject(CCTintTo:create(BoardViewAction:getActionTime(GamePlayConfig_GameItemAnimalDeleteAction_CD_View), 0, 170, 229));
		local spawnAction = CCSpawn:create(actionarray);
		local function removeCharacterAction()
			thingToRemove:removeFromParentAndCleanup(true);
		end 
		local callAction = CCCallFunc:create(removeCharacterAction)
		local sequenceAction = CCSequence:createWithTwoActions(spawnAction, callAction)
		if destroySprite and destroySprite.refCocosObj then 	
			destroySprite:runAction(sequenceAction);
			self:playAnimationAnimalDestroy_DestroyEffect(colorIndex);		----播放动物删除的雪花爆炸特效	
		end
		]]

		self:playBlocker207DestroyAnimation()

	elseif self.itemShowType == ItemSpriteItemShowType.kRabbit then
		self:playRabbitDestroyAnimation()
	else
		if _G.isLocalDevelopMode then printx(0, "don't konw what kind destroy animation to show!!!", self.y, self.x) end;
	end

	local t3 = self.itemSprite[ItemSpriteType.kClipping]
	if t3 then
		if t3:getParent() then t3:removeFromParentAndCleanup(true) end
		self.itemSprite[ItemSpriteType.kClipping] = nil
	end

	local t4 = self.itemSprite[ItemSpriteType.kEnterClipping]
	if t4 then
		if t4:getParent() then t4:removeFromParentAndCleanup(true) end
		self.itemSprite[ItemSpriteType.kEnterClipping] = nil
	end
end

local function createElasticEffect(viewSprite)
	local array = CCArray:create()
	array:addObject(CCEaseSineOut:create(CCMoveBy:create(0.05, ccp(0, -4))))
	array:addObject(CCEaseSineInOut:create(CCMoveBy:create(0.08, ccp(0, 6))))
	array:addObject(CCEaseSineIn:create(CCMoveBy:create(0.025, ccp(0, -2))))

	local targetAction = CCSequence:create(array)
	if viewSprite then viewSprite:runAction(targetAction) end
end

function ItemView:playElasticEffect()
	local viewSprite, animSprite = self.itemSprite[ItemSpriteType.kItem], self.itemSprite[ItemSpriteType.kItemShow]
	if viewSprite and viewSprite.refCocosObj then
		createElasticEffect(viewSprite)
	end
	if animSprite and animSprite.refCocosObj then
		createElasticEffect(animSprite)
	end
end

----播放动物删除的雪花爆炸特效
function ItemView:playAnimationAnimalDestroy_DestroyEffect(colorIndex)
	--self.isNeedUpdate = true;
	local destroyItem = self;
	local function onRepeatFinishCallback_DestroyEffect()
		destroyItem.itemSprite[ItemSpriteType.kItemDestroy] = nil;
	end 
	local destroySprite = ItemViewUtils:buildAnimalDestroyEffect(colorIndex, onRepeatFinishCallback_DestroyEffect)
	self.itemSprite[ItemSpriteType.kItemDestroy] = destroySprite;
	local pos = self:getBasePosition(self.x,self.y);
	destroySprite:setPosition(pos);
	if self.getContainer(ItemSpriteType.kItemDestroy) ~= nil then 
		self.getContainer(ItemSpriteType.kItemDestroy):addChild(destroySprite);
	else
		self.isNeedUpdate = true;
	end
end

function ItemView:playBonusTimeEffcet()
	local container = self.getContainer(ItemSpriteType.kTileHighLightEffect)
	if container then
		local sprite = Sprite:createWithSpriteFrameName("tile_light_special")
		sprite:setOpacity(0)
		sprite:setPosition(self:getBasePosition(self.x, self.y))
		container:addChild(sprite)

		local lightActSeq = CCArray:create()
		lightActSeq:addObject(CCFadeTo:create(5 * kCharacterAnimationTime, 204))
		lightActSeq:addObject(CCFadeTo:create(5 * kCharacterAnimationTime, 0))
		lightActSeq:addObject(CCCallFunc:create(function() sprite:removeFromParentAndCleanup(true) end))
		sprite:runAction(CCSequence:create(lightActSeq))
	end

	-- local function playItemEffect(sprite)
	-- 	local originScaleX = sprite:getScaleX()
	-- 	local originScaleY = sprite:getScaleY()
	-- 	local actSeq = CCArray:create()
	-- 	actSeq:addObject(CCScaleTo:create(5*kCharacterAnimationTime, originScaleX*1.2, originScaleY*1.2))
	-- 	actSeq:addObject(CCScaleTo:create(3*kCharacterAnimationTime, originScaleX*0.86, originScaleY*0.86))
	-- 	actSeq:addObject(CCScaleTo:create(3*kCharacterAnimationTime, originScaleX, originScaleY))
	-- 	sprite:runAction(CCSequence:create(actSeq))
	-- end

	-- local itemSprite = self.itemSprite[ItemSpriteType.kItem]
	-- if itemSprite then
	-- 	playItemEffect(itemSprite)
	-- end
	-- local itemShowSprite = self.itemSprite[ItemSpriteType.kItemShow]
	-- if itemShowSprite then
	-- 	playItemEffect(itemShowSprite)
	-- end
end

function ItemView:playMixAnimation(specialType, relativePosList, callback)
	local itemSprite = self.itemSprite[ItemSpriteType.kItemShow]
	-- if itemSprite then
	-- 	local actSeq = CCArray:create()
	-- 	actSeq:addObject(CCDelayTime:create(6/60))
	-- 	actSeq:addObject(CCScaleTo:create(4/60, 1.17))
	-- 	actSeq:addObject(CCScaleTo:create(2/60, 1))
	-- 	itemSprite:runAction(CCSequence:create(actSeq))
	-- end

	local function onRepeatFinishCallback_DestroyEffect()
		self.itemSprite[ItemSpriteType.kItemDestroy] = nil;
		if callback then callback() end
	end 
	local destroySprite = CommonEffect:buildMixSpecialAnim(specialType, {x=0,y=0}, relativePosList, onRepeatFinishCallback_DestroyEffect)
	self.itemSprite[ItemSpriteType.kItemDestroy] = destroySprite;
	local pos = self:getBasePosition(self.x,self.y);
	destroySprite:setPosition(pos)
	if self.getContainer(ItemSpriteType.kItemDestroy) ~= nil then 
		self.getContainer(ItemSpriteType.kItemDestroy):addChild(destroySprite);
	else
		self.isNeedUpdate = true;
	end
end

function ItemView:playBridBackEffect(isShow, scaleTo)
	if (isShow) then
		if self.itemSprite[ItemSpriteType.kItemBack] ~= nil then
			self.itemSprite[ItemSpriteType.kItemBack]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kItemBack] = nil
		end
		self.itemSprite[ItemSpriteType.kItemBack] = TileBird:createBirdDestroyEffectForever(scaleTo)
		local pos = self:getBasePosition(self.x, self.y)
		self.itemSprite[ItemSpriteType.kItemBack]:setPosition(pos)

		self.isNeedUpdate = true;
	else
		if (self.itemSprite[ItemSpriteType.kItemBack]~= nil) then
			TileBird:deleteBirdDestroyEffect(self.itemSprite[ItemSpriteType.kItemBack])
			self.itemSprite[ItemSpriteType.kItemBack] = nil
		end
	end
end

function ItemView:playBirdBirdBackEffect(isShow, pos)
	if isShow then
		local bird = TileBird:createBirdBirdDestroyBackEffectForever()

		pos = pos or self:getBasePosition(self.x, self.y)
		self.itemSprite[ItemSpriteType.kItemBack] = bird
		self.itemSprite[ItemSpriteType.kItemBack]:setPosition(pos)

		self.isNeedUpdate = true;
	else
		if self.itemSprite[ItemSpriteType.kItemBack] ~= nil then
			local bird = self.itemSprite[ItemSpriteType.kItemBack]
			if bird.playDisappear then
				bird.playDisappear()
			end
			self.itemSprite[ItemSpriteType.kItemBack] = nil
		end
	end
end

function ItemView:playBirdBirdExplodeEffect(isShow, specialPosList)
	local pos = self:getBasePosition(self.x, self.y)
	local birdExplode = TileBird:play2BirdExplodeAnimation(specialPosList)
	self.itemSprite[ItemSpriteType.kSpecial] = birdExplode
	self.itemSprite[ItemSpriteType.kSpecial]:setPosition(pos)
	self.isNeedUpdate = true
end

function ItemView:finishBirdBirdExplodeEffect()
	-- 动画移除靠动画自己~
	self.itemSprite[ItemSpriteType.kSpecial] = nil
end

function ItemView:playFlyingBirdEffect(r, c, delaytime, flyingtime, specialType)
	local item = self
	local function onAnimComplete()
		if item then
			item.itemSprite[ItemSpriteType.kSpecial] = nil
		end
	end

	local selfPos = self:getBasePosition(self.x, self.y)
	local fromPos = self:getBasePosition(c, r)
	local animation = CommonEffect:buildBirdEffectFlyAnim(specialType, fromPos, selfPos, flyingtime, arriveCallback, onAnimComplete)
	-- Firebolt:createLightOnly(fromPos, selfPos, flyingtime, onAnimComplete)
	self.itemSprite[ItemSpriteType.kSpecial] = animation 

	self.isNeedUpdate = true
end

function ItemView:playBirdSpecial_BirdDestroyEffect()
	if self.itemShowType == ItemSpriteItemShowType.kBird then
		local birdNode = self.itemSprite[ItemSpriteType.kItemShow]
		if birdNode then
			birdNode:playDestroyAnimation()
		end
		local function onAnimComplete()
			-- self.itemSprite[ItemSpriteType.kSpecialHigh] = nil
		end
		local animate = TileBird:buildBirdSpecialDestroyAnimation(false, onAnimComplete)
		animate:setPosition(self:getBasePosition(self.x, self.y))
		-- self.itemSprite[ItemSpriteType.kSpecialHigh] = animate

		self.getContainer(ItemSpriteType.kSpecialHigh):addChild(animate)

		self.isNeedUpdate = true
	end
end

function ItemView:playBirdBird_BirdDestroyEffect(toRC, isMasterBird)
	if self.itemShowType == ItemSpriteItemShowType.kBird then
		local birdNode = self.itemSprite[ItemSpriteType.kItemShow]

		if birdNode then
			self.itemSprite[ItemSpriteType.kItemShow] = nil
			
			local toPos = self:getBasePosition(toRC.y, toRC.x)
			birdNode:removeFromParentAndCleanup(false)
			local effect = TileBird:buildBirdBirdDestroyEffect(birdNode, toPos, isMasterBird)
			self.getContainer(ItemSpriteType.kSpecialHigh):addChild(effect)
		end
	end
end

function ItemView:playBirdNormal_BirdDestroyEffect()
	local birdNode = self.itemSprite[ItemSpriteType.kItemShow]
	if birdNode then
		birdNode:playDestroyAnimation()
	end
	local function onAnimComplete()
		-- self.itemSprite[ItemSpriteType.kSpecialHigh] = nil
	end
	local animate = TileBird:buildBirdNormalDestroyAnimation(false, onAnimComplete)
	animate:setPosition(self:getBasePosition(self.x, self.y))
	-- self.itemSprite[ItemSpriteType.kSpecialHigh] = animate
	self.getContainer(ItemSpriteType.kSpecialHigh):addChild(animate)

	self.isNeedUpdate = true
end

----播放冰层消除特效----
function ItemView:playIceDecEffect(oldIceLevel, callback)
	local pos = self:getBasePosition(self.x,self.y);
	pos.x = pos.x + GamePlayConfig_IceDeleted_Pos_Add_X[oldIceLevel] or 0
	pos.y = pos.y + GamePlayConfig_IceDeleted_Pos_Add_Y[oldIceLevel] or 0
	local sprite = ItemViewUtils:buildLighttAction(oldIceLevel, callback);
	if oldIceLevel == 1 then -- 一级冰碎裂微调
		pos.y = pos.y-0.5
	end
	sprite:setPosition(pos);

	----播放消除特效----
	if self.itemSprite[ItemSpriteType.kLight] ~= nil then
		if self.itemSprite[ItemSpriteType.kLight]:getParent() ~= nil then
			self.itemSprite[ItemSpriteType.kLight]:getParent():addChild(sprite);
		else
			if callback then callback() end
		end
	elseif self.getContainer(ItemSpriteType.kLight) ~= nil then ----最后一层冰被干掉了，要靠辅助记录的Panel来添加特效
		self.getContainer(ItemSpriteType.kLight):addChild(sprite);
	end
end

function ItemView:playOlympicIceDecEffect(iceLevel, onComplete)
	local pos = self:getBasePosition(self.x,self.y);
	local sprite = ItemViewUtils:buildOlympicIceDecAction(iceLevel, onComplete);
	sprite:setPosition(pos);
	----播放消除特效----
	if self.itemSprite[ItemSpriteType.kLight] ~= nil then
		if self.itemSprite[ItemSpriteType.kLight]:getParent() ~= nil then
			self.itemSprite[ItemSpriteType.kLight]:getParent():addChild(sprite);
		else
			if onComplete then onComplete() end
		end
	elseif self.getContainer(ItemSpriteType.kLight) ~= nil then ----最后一层冰被干掉了，要靠辅助记录的Panel来添加特效
		self.getContainer(ItemSpriteType.kLight):addChild(sprite);
	end
end

function ItemView:playOlympicBlockerDecEffect(blockLevel, onComplete)
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite and sprite.playDecAnimation then
		sprite:playDecAnimation(blockLevel)
	end
	-- if blockLevel <= 1 then
	-- 	if self.itemSprite[ItemSpriteType.kItemShow] then
	-- 		self.itemSprite[ItemSpriteType.kItemShow]:removeFromParentAndCleanup(true) 
	-- 		self.itemSprite[ItemSpriteType.kItemShow] = nil
	-- 		self.isNeedUpdate = true
	-- 	end
	-- end
end

function ItemView:playBoomByOlympicBlockerEffectFromPos( animType, fromCCP, callback)
	local animation = nil

	local ball, animate = SpriteUtil:buildAnimatedSprite(1/24, "ZQ_bomb_%04d", 0, 6 , false)
	local oriScale = 0.65
	ball:play(animate, 0, 0)

	local toCCP = self:getBasePosition(self.x, self.y)

	local fromPos = {x = fromCCP.x, y = fromCCP.y}
	local toPos = {x = toCCP.x, y = toCCP.y}

	if animType == 2 then
		ball:setPositionXY( fromPos.x - 11 , fromPos.y)
		ball:setScale( 0.9 * oriScale )
		ball:setRotation(-15)
	else
		ball:setPositionXY( fromPos.x + 11 , fromPos.y)
		ball:setScale( 0.9 * oriScale )
		ball:setRotation(15)
	end

	local function onBoomAnimComplete()
		if self.itemSprite[ItemSpriteType.kRoostFly] then
			self.itemSprite[ItemSpriteType.kRoostFly]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kRoostFly] = nil
		end
	end

	local function onRemoveBall()
		if self.itemSprite[ItemSpriteType.kSpecial] then
			self.itemSprite[ItemSpriteType.kSpecial]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kSpecial] = nil
		end
		if callback then callback() end
	end

	local function bezierCompleteCallback()
	end

	local function showBoomEff()
		local sprite, animate = SpriteUtil:buildAnimatedSprite(1/24, "ZQ_bomb_light_%04d", 0, 15 , false)
		sprite:play(animate, 0, 1, onBoomAnimComplete, false)
		sprite:setPositionXY( toPos.x, toPos.y - 5 )
		self.itemSprite[ItemSpriteType.kRoostFly] = sprite
		self.isNeedUpdate = true
	end

	local function runAct1()

		local controlPoint = nil
		controlPoint = ccp(toPos.x - (toPos.x - fromPos.x) / 5, toPos.y + 600)

		local bezierConfig = ccBezierConfig:new()
		bezierConfig.controlPoint_1 = ccp(fromPos.x, fromPos.y)
		bezierConfig.controlPoint_2 = controlPoint
		bezierConfig.endPosition = ccp(toPos.x, toPos.y)
		local bezierAction = CCBezierTo:create(0.9, bezierConfig)
		local callbackAction = CCCallFunc:create( bezierCompleteCallback )
		local delayAction = CCDelayTime:create(0.1)

		local actionList = CCArray:create()
		actionList:addObject(bezierAction)
		actionList:addObject(callbackAction)
		actionList:addObject(delayAction)
		actionList:addObject(CCCallFunc:create(onRemoveBall))
		local sequenceAction = CCSequence:create(actionList)

		ball:runAction(sequenceAction)

		local actionList2 = CCArray:create()
		actionList2:addObject(CCDelayTime:create(0.85))
		actionList2:addObject(CCCallFunc:create(showBoomEff))

		ball:runAction(CCSequence:create(actionList2))
	end

	local function runAct2()

		local actArr = CCArray:create()
		actArr:addObject(CCRotateTo:create(0.1, 90))
		actArr:addObject(CCRotateTo:create(0.1, 180))
		actArr:addObject(CCRotateTo:create(0.1, 270))
		actArr:addObject(CCRotateTo:create(0.1, 360))

		ball:runAction( CCRepeatForever:create( CCSequence:create(actArr) ) )
	end

	local t1 = 0.1

	local actArr2 = CCArray:create()
	actArr2:addObject( CCEaseSineOut:create( CCScaleTo:create(t1, oriScale , 0.5*oriScale) ) )
	actArr2:addObject( CCEaseSineIn:create( CCScaleTo:create(t1, oriScale , 1*oriScale) ) )
	actArr2:addObject( CCCallFunc:create( function () 
			runAct1()
			runAct2()
		end) )

	ball:runAction( CCSequence:create(actArr2) )

	local actArr3 = CCArray:create()

	if animType == 2 then
		actArr3:addObject( CCEaseSineOut:create( CCMoveTo:create(t1, ccp(fromPos.x - 11 , fromPos.y - 15) ) ) )
		actArr3:addObject( CCEaseSineIn:create( CCMoveTo:create(t1, ccp(fromPos.x - 11 , fromPos.y) ) ) )
	else
		actArr3:addObject( CCEaseSineOut:create( CCMoveTo:create(t1, ccp(fromPos.x + 11 , fromPos.y - 15) ) ) )
		actArr3:addObject( CCEaseSineIn:create( CCMoveTo:create(t1, ccp(fromPos.x + 11 , fromPos.y) ) ) )
	end

	ball:runAction( CCSequence:create(actArr3) )

	self.itemSprite[ItemSpriteType.kSpecial] = ball

	self.isNeedUpdate = true	
end

function ItemView:playBoomByOlympicBlockerEffect( animType , fromItem , callback)
	local animation = nil

	local fromCCP = self:getBasePosition(fromItem.x, fromItem.y)

	self:playBoomByOlympicBlockerEffectFromPos(animType, fromCCP, callback)	
end

function ItemView:playOlympicLockDecEffect(lockLevel, onComplete)
	local sprite = self.itemSprite[ItemSpriteType.kOlympicLock]
	if not sprite then
		sprite = TileOlympicLock:create(lockLevel)
		self.itemSprite[ItemSpriteType.kOlympicLock] = sprite
		self.isNeedUpdate = true
		sprite:setPosition(self:getBasePosition(self.x,self.y))
	end
	local function onAnimFinish()
		if lockLevel <= 1 then 
			sprite:removeFromParentAndCleanup(true) 
			self.itemSprite[ItemSpriteType.kOlympicLock] = nil
		else
			sprite:updateLevel(lockLevel - 1)
		end
		if onComplete then onComplete() end
	end
	sprite:playDecAnimation( lockLevel, onAnimFinish )
end                                                                                          

function ItemView:playLockDecEffect()
	local context = self
	local function onAnimComplete(evt)
		if context.itemSprite[kLockShow] then
			context.itemSprite[kLockShow] = nil
		end
	end

	local pos = self:getBasePosition(self.x,self.y)
	local sprite = ItemViewUtils:buildLockAction()
	sprite:ad(Events.kComplete, onAnimComplete)
	sprite:setPosition(pos)
	self.itemSprite[ItemSpriteType.kLockShow] = sprite
	if self.itemSprite[ItemSpriteType.kLock] then
		self.itemSprite[ItemSpriteType.kLock]:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kLock] = nil
	end
	
	self.isNeedUpdate = true

	GamePlayMusicPlayer:playEffect( GameMusicType.kPlayLockBreak )
end

function ItemView:playSnowDecEffect(snowLevel)
	local pos = self:getBasePosition(self.x,self.y);
	local sprite = ItemViewUtils:buildSnowAction(snowLevel)
	local offsetX = {0, 0, 3, 4.5, 2.8}
	local offsetY = {0, -22, -10.5, -17.5, -14.4}

	pos.x = pos.x + offsetX[snowLevel]
	pos.y = pos.y + offsetY[snowLevel]
	sprite:setPosition(pos)

	local oldSprite = self.itemSprite[ItemSpriteType.kSnowShow]
	if oldSprite and oldSprite:getParent() == nil then
		oldSprite:dispose()
	end

	self.itemSprite[ItemSpriteType.kSnowShow] = sprite;
	if snowLevel <= 1 then 
		self.itemSprite[ItemSpriteType.kItem]:removeFromParentAndCleanup(true) 
		self.itemSprite[ItemSpriteType.kItem] = nil
	end
	self.isNeedUpdate = true;
end

function ItemView:playVenomDestroyEffect()
	local s = self.itemSprite[ItemSpriteType.kItemShow]
	self.itemSprite[ItemSpriteType.kItemShow] = nil
	local function onAnimComplete(evt)
		if s then
			s:removeFromParentAndCleanup(true)
		end
	end
	s.isNeedUpdate = true
	s:ad(Events.kComplete, onAnimComplete)
	s:playDestroyAnimation()
end

function ItemView:playForbiddenLevelAnimation(level, playAnim, callback)
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	sprite:playForbiddenLevelAnimation(level, playAnim, callback)
end

function ItemView:playRabbitUpstarirsAnimation(r, c, boardView, isShowDangerous ,callback )
	local time = 1
	local scale_fix = boardView:getScale()
	
	local s = self.itemSprite[ItemSpriteType.kItemShow]
	s:stopAllActions()
	s:setPosition(self:getBasePosition(c,r)) 
	local sprite = s
	s:removeFromParentAndCleanup(false)
	self.itemSprite[ItemSpriteType.kItemShow] = nil
	sprite:setScale(scale_fix)
	s:playUpAnimation()
	local function completeCallback( ... )
		-- body
		if s then
			s:removeFromParentAndCleanup(false)
			self.getContainer(ItemSpriteType.kItemShow):addChild(s)
			self.itemSprite[ItemSpriteType.kItemShow] = s
			s:setScale(1)
			s:setPosition(self:getBasePosition(c, r))
			-- if isShowDangerous then 
			-- 	s:playHappyAnimation(true)
			-- end
		end
		if callback then callback() end
	end
	
	s:setPosition(boardView.gameBoardLogic:getGameItemPosInView(self.y, self.x) )
	local position =  boardView.gameBoardLogic:getGameItemPosInView(r, c)
	local array_action_list = CCArray:create()
	array_action_list:addObject(CCRotateTo:create(0.1, 0))
	array_action_list:addObject(CCEaseExponentialInOut:create(CCMoveTo:create(4 * time/5, position)))
	array_action_list:addObject(CCCallFunc:create(completeCallback))
	s:runAction(CCSequence:create(array_action_list))

	if boardView and boardView.PlayUIDelegate then 
		boardView.PlayUIDelegate.effectLayer:addChild(s)
	end
end

function ItemView:updateDangerousStatus(isDangerous)
	if self.itemShowType == ItemSpriteItemShowType.kRabbit then
		local s = self.itemSprite[ItemSpriteType.kItemShow]
		if s then
			if isDangerous then 
				s:playInDangerAnimation()
			else
				s:stopInDangerAnimation()
			end
		end
	else
		local s = self.itemSprite[ItemSpriteType.kItem]
		if s then
			if isDangerous then 
				if s.playInDangerAnimation then
					s:playInDangerAnimation()
				end
			else
				if s.stopInDangerAnimation then
					s:stopInDangerAnimation()
				end
			end
		end
	end
end

function ItemView:playUpstairsAnimation(r, c, boardView, isShowDangerous ,callback )
	-- body
	if self.itemShowType == ItemSpriteItemShowType.kRabbit then 
		self:playRabbitUpstarirsAnimation(r, c, boardView, isShowDangerous ,callback)
		return 
	end

	local time = 1
	local scale_fix = boardView:getScale()
	local sprite = ItemViewUtils:buildBeanpod()
	sprite:setScale(scale_fix)
	local sprite_fg = Sprite:createWithSpriteFrameName("light_bg")
	local anchorPointY = self.y - r == 1 and 1/4 or 1/6
	sprite_fg:setAnchorPoint(ccp(0.5, anchorPointY))
	sprite_fg:setScaleY((1+ self.y - r)/3)
	sprite_fg:setScale(scale_fix)
	local s = self.itemSprite[ItemSpriteType.kItem]
	s:stopAllActions()
	s:setVisible(false)
	s:setPosition(self:getBasePosition(c,r)) 

	local function completeCallback( ... )
		-- body
		if s then
			s:setVisible(true)
			-- if isShowDangerous then 
			-- 	local action_zoom = CCScaleTo:create(0.4, 1.1)
			-- 	local action_narrow = CCScaleTo:create(0.2, 0.9)
			-- 	s:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(action_zoom, action_narrow)))
			-- end
		end
		if sprite then sprite:removeFromParentAndCleanup(true) end
		if sprite_fg then sprite_fg:removeFromParentAndCleanup(true) end
		if callback then callback() end
	end
	
	sprite:setPosition(boardView.gameBoardLogic:getGameItemPosInView(self.y, self.x) )
	sprite_fg:setPosition(boardView.gameBoardLogic:getGameItemPosInView(self.y, self.x))
	local position =  boardView.gameBoardLogic:getGameItemPosInView(r, c)
	local array_action_list = CCArray:create()
	-- array_action_list:addObject(CCDelayTime:create(0.1))
	array_action_list:addObject(CCRotateTo:create(0.1, -10))
	array_action_list:addObject(CCEaseExponentialInOut:create(CCMoveTo:create(4 * time/5, position)))
	array_action_list:addObject(CCCallFunc:create(completeCallback))
	sprite:runAction(CCSequence:create(array_action_list))

	local fg_action_list = CCArray:create()
	fg_action_list:addObject(CCDelayTime:create(0.1))
	fg_action_list:addObject(CCFadeIn:create(time/4))
	fg_action_list:addObject(CCFadeOut:create(time/4))
	local action_fg = CCSequence:create(fg_action_list )
	sprite_fg:runAction(action_fg)
	if boardView and boardView.PlayUIDelegate then 
		boardView.PlayUIDelegate.effectLayer:addChild(sprite)
		boardView.PlayUIDelegate.effectLayer:addChild(sprite_fg)
	end
end

function ItemView:playChangeToIngredientAnimation( boardView, fromPosition , callback )
	-- body
	if boardView.PlayUIDelegate and boardView.PlayUIDelegate.effectLayer then
		local sprite = ItemViewUtils:buildBeanpod()
		local function completeCallback( ... )
			-- body
			if sprite then sprite:removeFromParentAndCleanup(true) end
			if callback then callback() end
		end

		boardView.PlayUIDelegate.effectLayer:addChild(sprite, 0)
		local fromPosition = fromPosition or ccp(0,0)
		local toPosition = boardView.gameBoardLogic:getGameItemPosInView(self.y, self.x)
		sprite:setPosition(fromPosition)
		sprite:runAction(CCSequence:createWithTwoActions(CCEaseSineIn:create(CCMoveTo:create(0.6,toPosition)) , CCCallFunc:create(completeCallback)))
	else
		if callback() then callback() end
	end
end

function ItemView:playChangeToDigGround( boardView, callback )
	-- body
	local preItemView = self:getGameItemSprite()
	local animation
	
	local function animationCallback( ... )
		-- body
		self.isNeedUpdate = true
		if callback then callback() end
	end

	local function midCallback( ... )
		-- body
		if preItemView then preItemView:setVisible(false) end
	end
	self.isNeedUpdate = true
	animation = TileDigGround:createDigGroundAnimation(midCallback, animationCallback)
	self.itemSprite[ItemSpriteType.kNormalEffect] = animation
	animation:setPosition(self:getBasePosition(self.x, self.y))
end

function ItemView:playVenomSpreadEffect(direction, callback, itemType)
	local s = self.itemSprite[ItemSpriteType.kItemShow]
	if not s then
		return
	end

	s.isNeedUpdate = true
	s:playTempInvisibleAnimation()

	local function completeHandler(evt)
		s:playRevertVisibleAnimation()
		if callback and type(callback) == "function" then callback() end
	end

	local sprite
	if itemType == GameItemType.kVenom then 
		sprite = TileVenom:create()
	elseif itemType == GameItemType.kPoisonBottle then
		sprite = TilePoisonBottle:create()
	end
	
	local pos = self:getBasePosition(self.x, self.y)
	sprite:setPosition(pos)
	sprite:ad(Events.kComplete, completeHandler)
	sprite:playDirectionAnimation(direction)
	self.itemSprite[ItemSpriteType.kNormalEffect] = sprite
	self.isNeedUpdate = true
end

function ItemView:playFurballTransferEffect(direction, callback)
	local s = self.itemSprite[ItemSpriteType.kFurBall]
	local furballName = nil
	if s then
		furballName = s.name
		s:stopAllActions()
		self.itemSprite[ItemSpriteType.kFurBall]:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kFurBall] = nil
	else
		local boardLogic = GameBoardLogic:getCurrentLogic()
		local replayData = boardLogic and boardLogic:getReplayRecordsData() or {}
		
		--assert(false, "furball origin view not exist. replayData="..table.serialize(replayData))

		self.isNeedUpdate = true
		if callback and type(callback) == "function" then callback() end
		return
	end

	local newSprite = TileCuteBall:create(furballName)
	newSprite:setPosition(self:getBasePosition(self.x, self.y))

	self.itemSprite[ItemSpriteType.kSpecial] = newSprite
	self.isNeedUpdate = true

	local animationType = nil
	if direction.x > 0 then
		animationType = kTileCuteBallAnimation.kRight
	elseif direction.x < 0 then
		animationType = kTileCuteBallAnimation.kLeft
	else
		if direction.y > 0 then
			animationType = kTileCuteBallAnimation.kDown
		else
			animationType = kTileCuteBallAnimation.kUp
		end
	end

	local context = self
	local function onAnimComplete(evt)
		if newSprite and not newSprite.isDisposed then
			newSprite:removeFromParentAndCleanup(true)
		end

		if self.itemSprite[ItemSpriteType.kSpecial] == newSprite then
			self.itemSprite[ItemSpriteType.kSpecial] = nil
		end

		if callback and type(callback) == "function" then callback() end
	end

	if animationType then
		newSprite:playDirectionAnimation(animationType)
		newSprite:ad(Events.kComplete, onAnimComplete)
	end

	GamePlayMusicPlayer:playEffect( GameMusicType.kPlayCuteJump )
end

function ItemView:playFurballUnstableEffect()
	local s = self.itemSprite[ItemSpriteType.kFurBall]
	if s then
		s:playFurballUnstableAnimation()
	end
end

function ItemView:playFurballShieldEffect()
	local s = self.itemSprite[ItemSpriteType.kFurBall]
	if s then
		s:playFurballShieldAnimation()
	end
end

function ItemView:playFurballSplitEffect(dir, callback)
	local s = self.itemSprite[ItemSpriteType.kFurBall]
	self.itemSprite[ItemSpriteType.kNormalEffect] = s
	self.itemSprite[ItemSpriteType.kFurBall] = nil
	if s then
		s:playFurballSplitAnimation(dir, callback)
		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayBrowncuteSplit )
	else
		callback()
	end
end

function ItemView:playGreyFurballDestroyEffect()
	local s = self.itemSprite[ItemSpriteType.kFurBall]
	if not s then
		if _G.isLocalDevelopMode then printx(0, "item view no furball play destroy " .. self.x .. ", " ..self.y) end
		return
	end
	s.isNeedUpdate = true
	self.itemSprite[ItemSpriteType.kNormalEffect] = s
	self.itemSprite[ItemSpriteType.kFurBall] = nil

	local context = self	
	local function onAnimComplete(evt)
		if s and s:getParent() then
			s:removeFromParentAndCleanup(true)
		end
	end

	s:ad(Events.kComplete, onAnimComplete)
	s:playDestroyAnimation()
	GamePlayMusicPlayer:playEffect( GameMusicType.kPlayGraycuteDead )
end

function ItemView:addFurballView(furballType)
	local sprite = ItemViewUtils:buildFurball(furballType)
	local pos = self:getBasePosition(self.x, self.y)
	sprite:setPosition(pos)
	self.itemSprite[ItemSpriteType.kFurBall] = sprite
	self.isNeedUpdate = true
end

----依据地图地面信息更新数据
function ItemView:updateByNewBoardData(data)
	local resultInfo = nil
	--修改树桩状态
	if (self.oldBoard == nil or self.oldBoard.blockerCoverMaterialLevel ~= data.blockerCoverMaterialLevel) then
		if (self.itemSprite[ItemSpriteType.kBlockerCoverMaterial] ~= nil) then
			if self.itemSprite[ItemSpriteType.kBlockerCoverMaterial]:getParent() then
				self.itemSprite[ItemSpriteType.kBlockerCoverMaterial]:removeFromParentAndCleanup(true);
				self.itemSprite[ItemSpriteType.kBlockerCoverMaterial] = nil;
			end
		end

		self:buildBlockerCoverMaterial(data.blockerCoverMaterialLevel)
	end

	--修改冰层状态
	if (self.oldBoard == nil or self.oldBoard.iceLevel ~= data.iceLevel) then
		if (self.itemSprite[ItemSpriteType.kLight] ~= nil) then
			if self.itemSprite[ItemSpriteType.kLight]:getParent() then
				self.itemSprite[ItemSpriteType.kLight]:removeFromParentAndCleanup(true);
				self.itemSprite[ItemSpriteType.kLight] = nil;
			end
		end
		self.itemSprite[ItemSpriteType.kLight] = ItemViewUtils:buildLight(data.iceLevel, data.gameModeId)
	end

	if self.oldBoard then
		
		if self.oldBoard:getGravity() ~= data:getGravity() or self.oldBoard:getGravitySkinType() ~= data:getGravitySkinType() then
			
			if not resultInfo then resultInfo = {} end
			resultInfo.gravityInfo = {}
			if self.oldBoard:getGravity() ~= data:getGravity() then
				resultInfo.gravityInfo.gravityChanged = true
			end
			if self.oldBoard:getGravitySkinType() ~= data:getGravitySkinType() then
				resultInfo.gravityInfo.gravitySkinChanged = true
			end
		end
		
	else
		if not resultInfo then resultInfo = {} end
		resultInfo.gravityInfo = {}
		resultInfo.gravityInfo.gravityChanged = true
		resultInfo.gravityInfo.gravitySkinChanged = true
	end
	
	if self.oldBoard and self.oldBoard:isDoubleSideTileBlock() and data.forceUpdate then
		data.forceUpdate = false
		if (self.oldBoard and not self.oldBoard:getSnailRoadViewType() and data:getSnailRoadViewType() ) then
			--self:initSnailRoad()
			if self.itemSprite[ItemSpriteType.kSnailRoad] and not self.itemSprite[ItemSpriteType.kSnailRoad].isDisposed then
				self.itemSprite[ItemSpriteType.kSnailRoad]:setVisible(true)
			end
		end

		if (self.oldBoard and self.oldBoard:getSnailRoadViewType() and not data:getSnailRoadViewType() ) then
			if self.itemSprite[ItemSpriteType.kSnailRoad] and not self.itemSprite[ItemSpriteType.kSnailRoad].isDisposed then
				self.itemSprite[ItemSpriteType.kSnailRoad]:setVisible(false)
			end
		end

		
		if self.oldBoard and not self.oldBoard.seaAnimalType and data.seaAnimalType then
			self.itemSprite[ItemSpriteType.kSeaAnimal] = nil
			self:buildSeaAnimal(data.seaAnimalType)
		elseif self.oldBoard and self.oldBoard.seaAnimalType and not data.seaAnimalType then
			self:clearSeaAnimal()
		elseif self.oldBoard and self.oldBoard.seaAnimalType and data.seaAnimalType then
			self:clearSeaAnimal()
			self:buildSeaAnimal(data.seaAnimalType)
		end
		--[[
		local oldSand = 0
		if self.oldBoard and self.oldBoard.sandLevel then
			oldSand = self.oldBoard.sandLevel
		end
		]]

		if self.itemSprite[ItemSpriteType.kSand] then
			self.itemSprite[ItemSpriteType.kSand]:stopAllActions()
			self.itemSprite[ItemSpriteType.kSand]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kSand] = nil
		end

		if data.sandLevel and data.sandLevel > 0 then
			self:addSandView(data.sandLevel)
		end
		
		if self.oldBoard and self.oldBoard.iceLevel ~= data.iceLevel then
			if (self.itemSprite[ItemSpriteType.kLight] ~= nil) then
				if self.itemSprite[ItemSpriteType.kLight]:getParent() then
					self.itemSprite[ItemSpriteType.kLight]:removeFromParentAndCleanup(true);
					self.itemSprite[ItemSpriteType.kLight] = nil;
				end
			end
			self.itemSprite[ItemSpriteType.kLight] = ItemViewUtils:buildLight(data.iceLevel, data.gameModeId)
		end
		
		if self.oldBoard and self.oldBoard.lotusLevel ~= data.lotusLevel then

			if self.itemSprite[ItemSpriteType.kLotus_bottom] then
				self.itemSprite[ItemSpriteType.kLotus_bottom]:removeFromParentAndCleanup(true)
				self.itemSprite[ItemSpriteType.kLotus_bottom] = nil
			end

			if self.itemSprite[ItemSpriteType.kLotus_top] then
				self.itemSprite[ItemSpriteType.kLotus_top]:removeFromParentAndCleanup(true)
				self.itemSprite[ItemSpriteType.kLotus_top] = nil
			end

			self:buildLotus(data.lotusLevel)
		end

		if self.itemSprite[ItemSpriteType.kColorFilterA] then
			self.itemSprite[ItemSpriteType.kColorFilterA]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kColorFilterA] = nil
		end
		if self.itemSprite[ItemSpriteType.kColorFilterB] then
			self.itemSprite[ItemSpriteType.kColorFilterB]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kColorFilterB] = nil
		end

		if data.colorFilterState == ColorFilterState.kStateA or data.colorFilterState == ColorFilterState.kStateB then 
			local pos = self:getBasePosition(self.x, self.y)
			local colorFilterA = TileColorFilterA:create(data.colorFilterColor)
			self.itemSprite[ItemSpriteType.kColorFilterA] = colorFilterA
			colorFilterA:setPosition(pos)

			if data.colorFilterBLevel > 0 then 
				local colorFilterB = TileColorFilterB:create(self.getContainer(ItemSpriteType.kColorFilterB).refCocosObj:getTexture(), 
																data.colorFilterColor, data.colorFilterBLevel)
				self.itemSprite[ItemSpriteType.kColorFilterB] = colorFilterB
				colorFilterB:setPosition(pos)
				self.colorFiterEffect = true
			end
		end

		self:cleanGhostDoorView()
		self:addGhostDoor(data)
		--forceUpdate--
	end

    --修改果酱状态
    if self.oldBoard then
	    if not self.oldBoard.isJamSperad and data.isJamSperad then
            local view = TileJamSperad:create( self.getContainer(ItemSpriteType.kJamSperad).refCocosObj:getTexture(), true )
            self.itemSprite[ItemSpriteType.kJamSperad] = view
            local pos = self:getBasePosition(self.x, self.y)
            view:setPosition(pos)
        end
    end

	data.isNeedUpdate = false;
	self.oldBoard = data:copy();
	return resultInfo
end
----依据地图信息更新数据
function ItemView:updateByNewItemData(data)
	----[[
	if data.forceUpdate then
		data.forceUpdate = false
		data.isNeedUpdate = false

		if self.colorFiterEffect then 
			data.isBlock = true
			data:setColorFilterBLock(true)
			self.colorFiterEffect = false
		end

		if self.itemSprite[ItemSpriteType.kLock] then
			self.itemSprite[ItemSpriteType.kLock]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kLock] = nil
		end

		if self.itemSprite[ItemSpriteType.kBigMonster] then
			self.itemSprite[ItemSpriteType.kBigMonster]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kBigMonster] = nil
		end
		if self.itemSprite[ItemSpriteType.kBigMonsterIce] then
			self.itemSprite[ItemSpriteType.kBigMonsterIce]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kBigMonsterIce] = nil
		end
		if self.itemSprite[ItemSpriteType.kWeeklyBoss] then
			self.itemSprite[ItemSpriteType.kWeeklyBoss]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kWeeklyBoss] = nil
		end
		if self.itemSprite[ItemSpriteType.kBlockerCover] then
			self.itemSprite[ItemSpriteType.kBlockerCover]:removeFromParentAndCleanup(true)
		end

        if self.itemSprite[ItemSpriteType.kMoleBossCloud] then
			self.itemSprite[ItemSpriteType.kMoleBossCloud]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kMoleBossCloud] = nil
		end

		if self.itemSprite[ItemSpriteType.kGhost] then
			self:cleanGhostView()
		end

		self:removeItemSpriteGameItem()
		self:initByItemData(data)
		self:upDatePosBoardDataPos(data)

		return
	end
	--]]
	----==========1.修改动物状态--------------
	------全空--------
	if data.ItemType == GameItemType.kNone and not (data.isSnail or data:isHedgehog()) then 				----空了---进行更新，并且修改标志
		data.isNeedUpdate = false
		self:cleanGameItemView()
	end

	-- 一劳永逸="=
	if self.oldData and (self.oldData:seizedByGhost() ~= data:seizedByGhost()) then
		if self.itemSprite[ItemSpriteType.kGhost] then
			self:cleanGhostView()
		end
	end

	--------豆荚------
	if data.ItemType == GameItemType.kIngredient then
		if self.oldData and self.oldData.ItemType ~= data.ItemType then
			self:removeItemSpriteGameItem();
			self.itemSprite[ItemSpriteType.kItem] = ItemViewUtils:buildBeanpod(data.showType);
		end
	end

	--------银币------
	if data.ItemType == GameItemType.kCoin then
		self.itemShowType = ItemSpriteItemShowType.kCoin
		if self.oldData and self.oldData.ItemType ~= data.ItemType then
			self:removeItemSpriteGameItem()
			self:buildCoin()
		end
	elseif self.itemShowType == ItemSpriteItemShowType.kCoin then
		self.itemShowType = ItemSpriteItemShowType.kNone
	end

	--------冰封导弹------
	if data.ItemType == GameItemType.kMissile then
		-- if _G.isLocalDevelopMode then printx(0, "111111111111111111",self.oldData.x,self.oldData.y,self.oldData.ItemType,"New Data ",data.x,data.y,data.ItemType) end
		-- debug.debug()
		if self.oldData and self.oldData.ItemType ~= data.ItemType then
			self:removeItemSpriteGameItem()
			self:buildMissile(data)
		end
	end

	--------变色龙------
	if data.ItemType == GameItemType.kChameleon then
		if self.oldData and self.oldData.ItemType ~= data.ItemType then
			self:removeItemSpriteGameItem()
			self:buildChameleon(data)
		end
	end

	--吃豆人
	if data.ItemType == GameItemType.kPacman then
		if self.oldData and 
			(self.oldData.ItemType ~= data.ItemType 
				or self.pacmanIsSuper ~= data.pacmanIsSuper
				or self.pacmanDevourAmount ~= data.pacmanDevourAmount
				) then
			self:removeItemSpriteGameItem()
			self:buildPacman(data)
		end
	end
	if data.ItemType == GameItemType.kPacmansDen then
		if self.oldData and self.oldData.ItemType ~= data.ItemType then
			self:removeItemSpriteGameItem()
			self:buildPacmansDen()
		end
	end

	--鱿鱼
	if data.ItemType == GameItemType.kSquid then
		if self.oldData and 
			(self.oldData.ItemType ~= data.ItemType 
				or self.squidTargetCount ~= data.squidTargetCount
				) then
			self:removeItemSpriteGameItem()
			self:buildSquid(data)
		end
	end

    --万生
	if data.ItemType == GameItemType.kWanSheng then
		if self.oldData and self.oldData.ItemType ~= data.ItemType then
			self:removeItemSpriteGameItem()
			self:buildWanSheng(data)
		end
	end

	-------- 道具云块 ------
	if data.ItemType == GameItemType.kRandomProp then
		-- if _G.isLocalDevelopMode then printx(0, "111111111111111111",self.oldData.x,self.oldData.y,self.oldData.ItemType,"New Data ",data.x,data.y,data.ItemType) end
		-- debug.debug()
		if self.oldData and self.oldData.ItemType ~= data.ItemType then
			self:removeItemSpriteGameItem()
			self:buildRandomProp(data)
		end
	end
	

	------水晶-------
	if data.ItemType == GameItemType.kCrystal then
		if self.oldData then
			if self.oldData.ItemType ~= data.ItemType
				or self.oldData._encrypt.ItemColorType ~= data._encrypt.ItemColorType
				then
				self:removeItemSpriteGameItem();
				self.itemShowType = ItemSpriteItemShowType.kCharacter
				self.itemSprite[ItemSpriteType.kItem] = ItemViewUtils:buildCrystal(data._encrypt.ItemColorType, data.hasActCollection)               ------水晶
			end
		end
	end

	---------------礼物-----------
	if data.ItemType == GameItemType.kGift or data.ItemType == GameItemType.kNewGift then
		if self.oldData and (self.oldData.ItemType ~= data.ItemType or self.oldData._encrypt.ItemColorType ~= data._encrypt.ItemColorType) then
			self:removeItemSpriteGameItem();
			self.itemShowType = ItemSpriteItemShowType.kCharacter
			self.itemSprite[ItemSpriteType.kItem] = ItemViewUtils:buildGift(data._encrypt.ItemColorType)
		end
	end

	---------------气球----------------
	if data.ItemType == GameItemType.kBalloon then
		if self.oldData and (self.oldData.ItemType ~= data.ItemType or self.oldData._encrypt.ItemColorType ~= data._encrypt.ItemColorType) then
			self:removeItemSpriteGameItem();
			self:buildBalloon(data)
		end
	end 

	if data.ItemType == GameItemType.kMagicLamp then
		if self.oldData and (self.oldData.ItemType ~= data.ItemType or self.oldData._encrypt.ItemColorType ~= data._encrypt.ItemColorType) then
			self:removeItemSpriteGameItem();
			self:buildMagicLamp(data._encrypt.ItemColorType, data.lampLevel)
		end
	end 

	if data.ItemType == GameItemType.kWukong then
		if self.oldData and (self.oldData.ItemType ~= data.ItemType or self.oldData._encrypt.ItemColorType ~= data._encrypt.ItemColorType) then
			self:removeItemSpriteGameItem();
			self:buildWukong(data)
		end
	end 

	if data.ItemType == GameItemType.kDrip then
		if self.oldData then
			if self.oldData.ItemType ~= data.ItemType then
				self:removeItemSpriteGameItem();
				self:buildDrip()
			elseif self.oldData.ItemType == data.ItemType and self.oldData.dripState ~= data.dripState then
				self:changeDripState(data)
			end
		end
	end

	if data.ItemType == GameItemType.kRoost then
		if self.oldData then
			if self.oldData.ItemType ~= data.ItemType then
				self:removeItemSpriteGameItem();
				self:buildRoost(data.roostLevel)
			end
		end
	end

	if data.ItemType == GameItemType.kPoisonBottle then
		if self.oldData then
			if self.oldData.ItemType ~= data.ItemType then
				self:removeItemSpriteGameItem();
				self:buildPoisonBottle(data.forbiddenLevel)
			end
		end
	end

	if data.ItemType == GameItemType.kPuffer then
		if self.oldData then
			if self.oldData.ItemType ~= data.ItemType then
				self:removeItemSpriteGameItem();
				self:buildPuffer(false , data.pufferState)
			elseif self.oldData.ItemType == data.ItemType and self.oldData.pufferState ~= data.pufferState then
				self:changePufferState(data)
			end
		end
	end

	if data.ItemType == GameItemType.kAddMove then
		if self.oldData and (self.oldData.ItemType ~= data.ItemType or self.oldData._encrypt.ItemColorType ~= data._encrypt.ItemColorType) then
			self:removeItemSpriteGameItem()
			self:buildAddMove(data._encrypt.ItemColorType, data.numAddMove)
		end
	end

	if data.ItemType == GameItemType.kAddTime then
		if self.oldData and (self.oldData.ItemType ~= data.ItemType or self.oldData._encrypt.ItemColorType ~= data._encrypt.ItemColorType) then
			self:removeItemSpriteGameItem()
			self:buildAddTime(data._encrypt.ItemColorType, data.addTime)
		end
	end

	if data.ItemType == GameItemType.kMagicStone then
		if self.oldData then
			if self.oldData.ItemType ~= data.ItemType then
				self:removeItemSpriteGameItem();
				self:buildMagicStone(data.magicStoneDir, data.magicStoneLevel)
			end
		end
	end

    if data.ItemType == GameItemType.kTurret then
		if self.oldData then
			if self.oldData.ItemType ~= data.ItemType then
				self:removeItemSpriteGameItem()
				self:buildTurret(data.turretDir, data.turretIsTypeRandom, data.turretLevel, data.turretIsSuper)
			end
		end
	end

	--------刷星瓶子------
	if data.ItemType == GameItemType.kScoreBuffBottle then
		if self.oldData and (self.oldData.ItemType ~= data.ItemType or self.oldData._encrypt.ItemColorType ~= data._encrypt.ItemColorType) then
			self:removeItemSpriteGameItem()
			self:buildScoreBuffBottle(data)
		end
	end
	
	--------太阳瓶子------
	if data.ItemType == GameItemType.kSunFlask then
		if self.oldData and (self.oldData.ItemType ~= data.ItemType or self.oldData.sunFlaskLevel ~= data.sunFlaskLevel) then
			self:removeItemSpriteGameItem()
			self:buildSunFlask(data.sunFlaskLevel)
		end
	end

	if data.ItemType == GameItemType.kSunflower then
		if self.oldData and (self.oldData.ItemType ~= data.ItemType) then
			self:removeItemSpriteGameItem()
			self:buildSunflower()
		end
	end

	-------- 爆竹 --------
	if data.ItemType == GameItemType.kFirecracker then
		if self.oldData and (self.oldData.ItemType ~= data.ItemType or self.oldData._encrypt.ItemColorType ~= data._encrypt.ItemColorType) then
			self:removeItemSpriteGameItem()
			self:buildFirecracker(data)
		end
	end

	----------------------修改黑色毛球状态------------------------
	if data.ItemType == GameItemType.kBlackCuteBall then 
		if self.oldData and (self.oldData.ItemType ~= data.ItemType) then
			self:removeItemSpriteGameItem();
			self:buildBlackCuteBall(data.blackCuteStrength, data.blackCuteMaxStrength)
		end
	end

	----------------------修改兔子状态------------------------
	if data.ItemType == GameItemType.kRabbit then 
		self.itemShowType = ItemSpriteItemShowType.kRabbit
		if self.oldData and (self.oldData.ItemType ~= data.ItemType or self.oldData._encrypt.ItemColorType ~= data._encrypt.ItemColorType) then
			self:removeItemSpriteGameItem();
			self:buildRabbit(data._encrypt.ItemColorType, data.rabbitLevel)
		end
	end

	------------------蜂蜜罐状态----------------------
	if data.ItemType == GameItemType.kHoneyBottle then 
		if ( self.oldData and self.oldData.ItemType ~= data.ItemType) then
			self:removeItemSpriteGameItem()
			self:buildHoneyBottle(data.honeyBottleLevel)
		end
	end
	
	--------------------动物--变化----------------
	if data.ItemType == GameItemType.kAnimal then 				----动物类型
		if self.oldData then
			if data.ItemType ~= self.oldData.ItemType 
				or data._encrypt.ItemColorType ~= self.oldData._encrypt.ItemColorType 	----检测是否需要更新
				or data.ItemSpecialType ~= self.oldData.ItemSpecialType
				or (self.oldData.ItemCheckColorType and data._encrypt.ItemColorType ~= self.oldData.ItemCheckColorType)
				or data.forceUpdate
				then
				data.forceUpdate = false
				----显示上有一些不一样
				----1.删除原来的
				self:removeItemSpriteGameItem()

				----2.创建新的Item
				self:buildNewAnimalItem(data._encrypt.ItemColorType, data.ItemSpecialType, true, true, data.hasActCollection)
			end

			if data._encrypt.ItemColorType == 0 and (data.ItemSpecialType == nil or data.ItemSpecialType == 0) then ----被消除之后，数据啥都不剩了
				data.isNeedUpdate = false
			end
		end
	end

	if data.ItemType == GameItemType.kQuestionMark then
		if self.oldData
		and (self.oldData.ItemType ~= data.ItemType or self.oldData._encrypt.ItemColorType ~= data._encrypt.ItemColorType) then
			self:removeItemSpriteGameItem()
			self:buildQuestionMark(data._encrypt.ItemColorType)
		end
	end
	
	if data.ItemType == GameItemType.kRocket then
		if self.oldData and (self.oldData.ItemType ~= data.ItemType or self.oldData._encrypt.ItemColorType ~= data._encrypt.ItemColorType) then
			self:removeItemSpriteGameItem()
			self:buildRocket(data._encrypt.ItemColorType)
		end
	end

	if data.ItemType == GameItemType.kTotems then
		if self.oldData and (self.oldData.ItemType ~= data.ItemType or self.oldData._encrypt.ItemColorType ~= data._encrypt.ItemColorType) then
			self:removeItemSpriteGameItem()
			self:buildTotems(data._encrypt.ItemColorType, data:isActiveTotems())
		end
	end

	------掉落-------
	if data.ItemStatus == GameItemStatusType.kIsFalling 
		or data.ItemStatus == GameItemStatusType.kNone
		or data.ItemStatus == GameItemStatusType.kJustStop
		or data.ItemStatus == GameItemStatusType.kItemHalfStable then
		if data.ItemType == GameItemType.kNone 
			or data.ItemType == GameItemType.kAnimal
			or data.ItemType == GameItemType.kCoin
			or data.ItemType == GameItemType.kCrystal
			or data.ItemType == GameItemType.kGift
			or data.ItemType == GameItemType.kNewGift
			or data.ItemType == GameItemType.kIngredient
			or data.ItemType == GameItemType.kBalloon
			or data.ItemType == GameItemType.kAddMove
			or data.ItemType == GameItemType.kBlackCuteBall
			or data.ItemType == GameItemType.kRabbit
			or data.ItemType == GameItemType.kHoneyBottle
			or data.ItemType == GameItemType.kAddTime
			or data.ItemType == GameItemType.kQuestionMark
			or data.ItemType == GameItemType.kRocket
			or data.ItemType == GameItemType.kCrystalStone
			or data.ItemType == GameItemType.kTotems
			or data.ItemType == GameItemType.kDrip
			or data.ItemType == GameItemType.kPuffer
			or data.ItemType == GameItemType.kMissile
			or data.ItemType == GameItemType.kBlocker195
			or data.ItemType == GameItemType.kChameleon
			or data.ItemType == GameItemType.kBuffBoom
			or data.ItemType == GameItemType.kBlocker207
			or data.ItemType == GameItemType.kMoleBossSeed
			or data.ItemType == GameItemType.kScoreBuffBottle
			or data.ItemType == GameItemType.kFirecracker
            or data.ItemType == GameItemType.kWanSheng
			then
			self.itemPosAdd[ItemSpriteType.kItem] = data.itemPosAdd 			----掉落一个物品
			self.itemPosAdd[ItemSpriteType.kItemShow] = data.itemPosAdd 		----掉落一个特效
			self.itemPosAdd[ItemSpriteType.kItemHighLevel] = data.itemPosAdd 		----掉落一个特效
			self.itemPosAdd[ItemSpriteType.kItemLowLevel] = data.itemPosAdd 		----掉落一个特效
			self.itemPosAdd[ItemSpriteType.kFurBall] = data.itemPosAdd
			self.itemPosAdd[ItemSpriteType.kMoleWeeklyItemShow] = data.itemPosAdd
			self.itemPosAdd[ItemSpriteType.kClipping] = data.ClippingPosAdd 	----生成口的某些掉落物品
			self.itemPosAdd[ItemSpriteType.kEnterClipping] = data.EnterClippingPosAdd
			data.isNeedUpdate = false
		end
	end

	----------------------------------蜗牛------------------------------
	if data.isSnail then 
		if self.oldData and (self.oldData.isSnail ~= data.isSnail) then
			self:removeItemSpriteGameItem();
			if self.itemSprite[ItemSpriteType.kSnailMove] ~= nil then
				self.itemSprite[ItemSpriteType.kSnailMove]:removeFromParentAndCleanup(true)
				self.itemSprite[ItemSpriteType.kSnailMove] = nil
			end
			self:buildSnail(data.snailRoadType)
		end
	end

	if data:isHedgehog() then 
		if self.oldData and (self.oldData.hedgehogLevel ~= data.hedgehogLevel) then
			self:removeItemSpriteGameItem();
			if self.itemSprite[ItemSpriteType.kSnailMove] ~= nil then
				self.itemSprite[ItemSpriteType.kSnailMove]:removeFromParentAndCleanup(true)
				self.itemSprite[ItemSpriteType.kSnailMove] = nil
			end
			self:buildHedgehog(data.snailRoadType, data.hedgehogLevel)
		end
	end

	-----================2.修改牢笼状态------
	if (self.oldData) then
		if (self.oldData.cageLevel ~= data.cageLevel) then
			if self.itemSprite[ItemSpriteType.kLock] ~= nil then
				if self.itemSprite[ItemSpriteType.kLock]:getParent() then
					self.itemSprite[ItemSpriteType.kLock]:removeFromParentAndCleanup(true);
					self.itemSprite[ItemSpriteType.kLock] = nil
				end
			end
			if data.cageLevel > 0 then
				self.itemSprite[ItemSpriteType.kLock] = ItemViewUtils:buildLocker(data.cageLevel)
			end
		end
	end

	-----================3.修改雪花状态------
	if (self.oldData) then
		if (self.oldData.snowLevel ~= data.snowLevel and data.snowLevel > 0) then
			if (self.itemSprite[ItemSpriteType.kItem] ~= nil) then
				if self.itemSprite[ItemSpriteType.kItem]:getParent() then
					self.itemSprite[ItemSpriteType.kItem]:removeFromParentAndCleanup(true);
				end
			end
			self.itemSprite[ItemSpriteType.kItem] = ItemViewUtils:buildSnow(data.snowLevel)
		end
	end

	-----================4.修改毒液状态------
	if self.oldData then
		if self.oldData.venomLevel ~= data.venomLevel and data.venomLevel > 0 then
			self:removeItemSpriteGameItem()
			self:buildVenom()
		end
	end

	--------------------5.修改地块状态-----------------
	if self.oldData then 
		if self.oldData.digGroundLevel ~= data.digGroundLevel and data.digGroundLevel > 0 then
			self:removeItemSpriteGameItem()
			self:buildDigGround(data.digGroundLevel)
		end
	end


	if self.oldData then 
		if self.oldData.digJewelLevel ~= data.digJewelLevel and data.digJewelLevel > 0 then
			self:removeItemSpriteGameItem()
			self:buildDigJewel(data.digJewelLevel, self.context.levelType)
		end
	end

	-------------------------妖精瓶子-------------------------

	if data.ItemType == GameItemType.kBottleBlocker then
		if self.oldData and self.oldData.ItemType ~= data.ItemType then
			
			self:removeItemSpriteGameItem()
			self:buildBottleBlocker(data.bottleLevel , data._encrypt.ItemColorType)

		elseif self.oldData and self.oldData.ItemType == data.ItemType then
			if data.bottleLevel > 0 and 
				(self.oldData.bottleLevel ~= data.bottleLevel or self.oldData._encrypt.ItemColorType ~= data._encrypt.ItemColorType) then

				self:removeItemSpriteGameItem()
				self:buildBottleBlocker(data.bottleLevel , data._encrypt.ItemColorType)

			end
		end
	end

	--------------------6.修改boss状态-------------------
	if self.oldData then 
		if self.oldData.ItemType ~= data.ItemType and data.ItemType == GameItemType.kBoss then
			self:removeItemSpriteGameItem()
			if data.bossLevel > 0 then 
				self:buildBoss(data)
			end
		end

		if self.oldData.ItemType ~= data.ItemType and data.ItemType == GameItemType.kWeeklyBoss then
			self:removeItemSpriteGameItem()
			if data.weeklyBossLevel > 0 then 
				self:buildWeeklyBoss(data)
			end
		end

		if self.oldData.ItemType ~= data.ItemType and data.ItemType == GameItemType.kMoleBossCloud then
			self:removeItemSpriteGameItem()
			if data.moleBossCloudLevel > 0 then 
				self:buildMoleBossCloud(data)
	end
		end
	end
	--------------------7.修改蜂蜜状态-------------------
	if (self.oldData) then
		if (self.oldData.honeyLevel ~= data.honeyLevel) then
			if self.itemSprite[ItemSpriteType.kHoney] ~= nil then
				if self.itemSprite[ItemSpriteType.kHoney]:getParent() then
					self.itemSprite[ItemSpriteType.kHoney]:removeFromParentAndCleanup(true);
					self.itemSprite[ItemSpriteType.kHoney] = nil
				end
			end
			if data.honeyLevel > 0 then
				self:buildHoney(data.honeyLevel)
			end
		end
	end

	-- if data.ItemType == GameItemType.kOlympicBlocker then
	-- 	if self.oldData and (self.oldData.ItemType ~= data.ItemType or self.oldData.olympicBlockerLevel ~= data.olympicBlockerLevel) then
	-- 		self:removeItemSpriteGameItem()
	-- 		if data.olympicBlockerLevel >= 0 then
	-- 			self:buildOlympicBlocker(data)
	-- 		end
	-- 	end
	-- end

	if data.ItemType == GameItemType.kBuffBoom then
		if self.oldData and ( self.oldData.ItemType ~= data.ItemType --[[or self.oldData.olympicBlockerLevel ~= data.olympicBlockerLevel]] ) then
			self:removeItemSpriteGameItem()
			--if data.olympicBlockerLevel >= 0 then
				self:buildBuffBoom( data )
			--end
		end
	end

	if data.ItemType == GameItemType.kCrystalStone then
		if self.oldData and (self.oldData.ItemType ~= data.ItemType
			or self.oldData._encrypt.ItemColorType ~= data._encrypt.ItemColorType or self.oldData.crystalStoneEnergy ~= data.crystalStoneEnergy) then
			self:removeItemSpriteGameItem()
			self:buildCrystalStone(data._encrypt.ItemColorType, data.crystalStoneEnergy, data.crystalStoneBombType)
		end
	end

	if data.ItemType == GameItemType.kBlocker195 then
		if self.oldData and (self.oldData.ItemType ~= data.ItemType or self.oldData.subtype ~= data.subtype or
	 		self.oldData.level ~= data.level) then
			self:removeItemSpriteGameItem()
			self:buildBlocker195(data)
		end
	end

	if data.ItemType == GameItemType.kBlocker199 then
		if self.oldData and (self.oldData.ItemType ~= data.ItemType or self.oldData.subtype ~= data.subtype or 
			self.oldData._encrypt.ItemColorType ~= data._encrypt.ItemColorType) then--用于强制交换
			self:removeItemSpriteGameItem()
			self:buildBlocker199(data)
		end
	end

	if (self.oldData and self.oldData.lockLevel ~= data.lockLevel) then
		if self.itemSprite[ItemSpriteType.kLock206Show] ~= nil then
			if self.itemSprite[ItemSpriteType.kLock206Show]:getParent() then
				self.itemSprite[ItemSpriteType.kLock206Show]:removeFromParentAndCleanup(true);
				self.itemSprite[ItemSpriteType.kLock206Show] = nil
			end
		end
		if data:hasBlocker206() then
			self:buildBlocker206( false , data )
		end
	end

	if data.ItemType == GameItemType.kBlocker207 then
		self.itemShowType = ItemSpriteItemShowType.kBlocker207
		if self.oldData and (self.oldData.ItemType ~= data.ItemType) then--用于强制交换
			self:removeItemSpriteGameItem()
			self:buildBlocker207()
		end
	elseif self.itemShowType == ItemSpriteItemShowType.kBlocker207 then
		self.itemShowType = ItemSpriteItemShowType.kNone
	end

	if data.ItemType == GameItemType.kBlocker211 then
		self.itemShowType = ItemSpriteItemShowType.kBlocker211
		if self.oldData and (self.oldData.ItemType ~= data.ItemType or self.oldData.level ~= data.level or self.oldData._encrypt.ItemColorType ~= data._encrypt.ItemColorType)then 
			self:removeItemSpriteGameItem()
			self:buildBlocker211(data)
		end
	end

    if data.ItemType == GameItemType.kMoleBossSeed then 
		if ( self.oldData and self.oldData.ItemType ~= data.ItemType) then
			self:removeItemSpriteGameItem()
			self:buildMoleBossSeed(data.moleBossSeedCountDown)
		end
	end

    if data.ItemType == GameItemType.kYellowDiamondGrass then 
		if self.oldData.yellowDiamondLevel ~= data.yellowDiamondLevel and data.yellowDiamondLevel > 0 then
			self:removeItemSpriteGameItem()
			self:buildYellowDiamond(data.yellowDiamondLevel)
		end
	end

    if data:seizedByGhost() then
		self:addGhost()
	end

	if data:isTopCover( GameItemDataTopCoverName.k_TileBlocker ) and data.isReverseSide then -- 更新翻转地格上的视图状态
		self:setTileBlockCoverSpriteVisible(false)
	end

	----不论如何都赋值data
	self.oldData = data:copy()
	data.isNeedUpdate = false
end

function ItemView:growupBlockerCover(level)
	local sprite = TileBlockerCover:create(level)
	--local sprite = TileMissile:create(level)
	if self.oldData then 
		self.oldData.blockerCoverLevel = level 
	end
	
	if self.itemSprite[ItemSpriteType.kBlockerCover] then
		self.itemSprite[ItemSpriteType.kBlockerCover]:removeFromParentAndCleanup(true)
	end
	self.itemSprite[ItemSpriteType.kBlockerCover] = sprite
end

function ItemView:decreaseBlockerCover(level)
	local sprite = self.itemSprite[ItemSpriteType.kBlockerCover]
	if sprite then
		sprite:playDecreaseAnimation(level)
	end

	if self.oldData then 
		self.oldData.blockerCoverLevel = level 
	end
end

function ItemView:addBlockerCoverGenerateEff( eff )
	local sprite = self.itemSprite[ItemSpriteType.kBlockerCoverEffect]
end

function ItemView:removeBlockerCoverGenerateEff()
	self.itemSprite[ItemSpriteType.kBlockerCoverEffect] = nil
end

-----删除gameItem的sprite
function ItemView:removeItemSpriteGameItem()
	if self.itemSprite then
		if self.itemSprite[ItemSpriteType.kItem] ~= nil then
			self.itemSprite[ItemSpriteType.kItem]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kItem] = nil
		end
		if self.itemSprite[ItemSpriteType.kItemShow] ~= nil then
			self.itemSprite[ItemSpriteType.kItemShow]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kItemShow] = nil
		end

		if self.itemSprite[ItemSpriteType.kSnail] ~= nil then
			self.itemSprite[ItemSpriteType.kSnail]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kSnail] = nil
		end

		if self.itemSprite[ItemSpriteType.kDigBlocker] ~= nil then
			self.itemSprite[ItemSpriteType.kDigBlocker]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kDigBlocker] = nil
		end

		if self.itemSprite[ItemSpriteType.kBigMonster] ~= nil then
			self.itemSprite[ItemSpriteType.kBigMonster]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kBigMonster] = nil
		end

		if self.itemSprite[ItemSpriteType.kWeeklyBoss] ~= nil then
			self.itemSprite[ItemSpriteType.kWeeklyBoss]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kWeeklyBoss] = nil
		end

        if self.itemSprite[ItemSpriteType.kMoleBossCloud] ~= nil then
			self.itemSprite[ItemSpriteType.kMoleBossCloud]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kMoleBossCloud] = nil
		end

		if self.itemSprite[ItemSpriteType.kItemHighLevel] ~= nil then
			self.itemSprite[ItemSpriteType.kItemHighLevel]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kItemHighLevel] = nil
		end

		if self.itemSprite[ItemSpriteType.kItemLowLevel] ~= nil then
			self.itemSprite[ItemSpriteType.kItemLowLevel]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kItemLowLevel] = nil
		end
		
		if self.itemSprite[ItemSpriteType.kPacmanShow] ~= nil then
			self.itemSprite[ItemSpriteType.kPacmanShow]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kPacmanShow] = nil
		end

		if self.itemSprite[ItemSpriteType.kSquidShow] ~= nil then
			self.itemSprite[ItemSpriteType.kSquidShow]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kSquidShow] = nil
		end

		if self.itemSprite[ItemSpriteType.kMoleWeeklyItemShow] ~= nil then
			self.itemSprite[ItemSpriteType.kMoleWeeklyItemShow]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kMoleWeeklyItemShow] = nil
		end

		if self.itemSprite[ItemSpriteType.kGhost] then
			self:cleanGhostView()
		end
	end
end

----创建AnimalItem
----autoset 自动设置为物品， autotype 自动设置创建类型
----返回1，物品对象，返回2，物品对象的类型
function ItemView:buildNewAnimalItem(colortype, specialtype, autoset, autotype, hasActCollection)
	if AnimalTypeConfig.isSpecialTypeValid(specialtype)
		and specialtype ~= AnimalTypeConfig.kColor
		then
		if AnimalTypeConfig.isColorTypeValid(colortype) and colortype ~= AnimalTypeConfig.kDrip then 
			---特殊动画
			local sprite = TileCharacter:create(table.getMapValue(itemsName, colortype))
			if specialtype == AnimalTypeConfig.kLine then
	  			sprite:play(kTileCharacterAnimation.kLineRow)
	  		elseif specialtype == AnimalTypeConfig.kColumn then
	  			sprite:play(kTileCharacterAnimation.kLineColumn)
	  		elseif specialtype == AnimalTypeConfig.kWrap then
	  			sprite:play(kTileCharacterAnimation.kWrap)
	  		end
			local pos = self:getBasePosition(self.x, self.y)
			sprite:setPosition(pos)

			if hasActCollection then 
				self:addActCollectionIcon(sprite, 17, -17)
			end

	  		if (autoset) then 
	  			self.itemSprite[ItemSpriteType.kItemShow] = sprite 
	  		end
	  		if (autotype) then self.itemShowType = ItemSpriteItemShowType.kCharacter end;
	  		return sprite
		end
  	elseif specialtype == AnimalTypeConfig.kColor then 		----颜色鸟
		local bird = TileBird:create()
		bird:play(1)
		local pos = self:getBasePosition(self.x, self.y)
		bird:setPosition(pos)

		if hasActCollection then 
			self:addActCollectionIcon(sprite, 17, -17)
		end

		if (autoset) then self.itemSprite[ItemSpriteType.kItemShow] = bird end;
		if (autotype) then self.itemShowType = ItemSpriteItemShowType.kBird end;
		return bird
	elseif AnimalTypeConfig.isColorTypeValid(colortype) and colortype ~= AnimalTypeConfig.kDrip then
		--------静态图片
		local sprite = ItemViewUtils:buildAnimalStatic(colortype);
		local pos = self:getBasePosition(self.x, self.y)
		sprite:setPosition(pos)

		if hasActCollection then 
			self:addActCollectionIcon(sprite, 52, 18)
		end

		if (autoset) then
			if (self.itemSprite[ItemSpriteType.kItem]) then
				if (self.itemSprite[ItemSpriteType.kItem]:getParent()) then
					self.itemSprite[ItemSpriteType.kItem]:removeFromParentAndCleanup(true);
				end;
				self.itemSprite[ItemSpriteType.kItem] = nil;
			end
			self.itemSprite[ItemSpriteType.kItem] = sprite 
		end; 
		if (autotype) then self.itemShowType = ItemSpriteItemShowType.kCharacter end;

		return sprite
	end
end

function ItemView:buildQuestionMark( colortype )
	-- body
	local sprite = ItemViewUtils:createQuestionMark(colortype)
	self.itemSprite[ItemSpriteType.kItemShow] = sprite
	self.itemShowType = ItemSpriteItemShowType.kCharacter
end

function ItemView:buildAddTime(colortype, addTime, isOnlyGetSprite)
	local sprite = TileAddTime:create(colortype, addTime)
	local pos = self:getBasePosition(self.x, self.y)
	sprite:setPosition(pos)
	if isOnlyGetSprite then 
		return sprite
	else
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
		self.itemShowType = ItemSpriteItemShowType.kCharacter
	end
end

function ItemView:buildAddMove(colortype, numAddMove, isOnlyGetSprite)
	local sprite = TileAddMove:create(colortype, numAddMove)
	local pos = self:getBasePosition(self.x, self.y)
	sprite:setPosition(pos)
	if isOnlyGetSprite then 
		return sprite
	else
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
		self.itemShowType = ItemSpriteItemShowType.kCharacter
	end
end

function ItemView:buildVenom()
	local sprite = TileVenom:create()
	local pos = self:getBasePosition(self.x, self.y)
	sprite:setPosition(pos)
	sprite:playNormalAnimation()
	self.itemSprite[ItemSpriteType.kItemShow] = sprite
end

function ItemView:buildPoisonBottle(forbiddenLevel, isOnlyGetSprite)
	if not forbiddenLevel then forbiddenLevel = 0 end
	local sprite = TilePoisonBottle:create()
	if forbiddenLevel == 0 then
		sprite:playNormalAnimation()
	else
		sprite:playForbiddenLevelAnimation(forbiddenLevel, false, nil)
	end
	if isOnlyGetSprite then 
		return sprite
	else
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
	end

end

function ItemView:buildCoin(isOnlyGetSprite)
	--2017元宵节
	local sprite 
	if _G.IS_PLAY_NATIONDAY2017_LEVEL then
		sprite = TileCoinLikeA:create(_G.SPRING2018_COLLECTION_TYPE)
	else
		sprite = TileCoin:create()
	end
	if isOnlyGetSprite then
		return sprite
	else
		local pos = self:getBasePosition(self.x, self.y)
		sprite:setPosition(pos)
		self.itemShowType = ItemSpriteItemShowType.kCoin
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
	end
end

function ItemView:buildMagicLamp(color, level)
	local sprite = TileMagicLamp:create(color, level)
	local pos = self:getBasePosition(self.x, self.y)
	sprite:setPosition(pos)
	self.itemSprite[ItemSpriteType.kItemShow] = sprite
end

function ItemView:buildWukong(data)
	local sprite = TileWukong:create(data)
	local pos = self:getBasePosition(self.x, self.y)
	sprite:setPosition(pos)
	self.itemSprite[ItemSpriteType.kItemShow] = sprite
end

function ItemView:changeWukongState(state , callback)
	local sprite = self:getWukongSprite()
	if sprite then
		
		if sprite.state ~= state then
			if state == TileWukongState.kReadyToJump then
				self.itemSprite[ItemSpriteType.kItemShow] = nil
				sprite:getParent():removeChild(sprite , false)
				self.itemSprite[ItemSpriteType.kSnailMove] = sprite
				self.isNeedUpdate = true
			elseif sprite.state == TileWukongState.kReadyToJump and state == TileWukongState.kOnActive then
				self.itemSprite[ItemSpriteType.kSnailMove] = nil
				sprite:getParent():removeChild(sprite , false)

				self.itemSprite[ItemSpriteType.kItemShow] = sprite
				self.isNeedUpdate = true
			end
		end

		sprite:changeState(state , callback)
	end
end

function ItemView:changeWukongColor(color , callback)
	local sprite = self:getWukongSprite()
	if sprite then
		sprite:setColor(color , callback)
	end
end

function ItemView:getWukongSprite()
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if not sprite then
		sprite = self.itemSprite[ItemSpriteType.kSnailMove]
	end
	return sprite
end

function ItemView:onWukongJumpFin()
	local sprite = self.itemSprite[ItemSpriteType.kSnailMove]
	
	if sprite then
		sprite:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kSnailMove] = nil
	end

	--[[
	sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite then
		sprite:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kItemShow] = nil
	end
	]]

	sprite = self.itemSprite[ItemSpriteType.kRoostFly]
	
	if sprite then
		sprite:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kRoostFly] = nil
	end
end

function ItemView:playWukongJumpAnimation(toPos, completeCallback , nojump)
	local sprite = nil
	local context = self
	local function onAnimComplete()
		--[[
		if sprite and sprite:getParent() then
			sprite:removeFromParentAndCleanup(true)
			context.itemSprite[ItemSpriteType.kRoostFly] = nil
			context.isNeedUpdate = true
		end
		--]]
	end

	if nojump then
		setTimeOut( function ()

			local locksprite = self.itemSprite[ItemSpriteType.kRoostFly]
	
			if locksprite then
				locksprite:removeFromParentAndCleanup(true)
				self.itemSprite[ItemSpriteType.kRoostFly] = nil
			end

			local sprite = self.itemSprite[ItemSpriteType.kSnailMove]
	
			if sprite then
				sprite:removeFromParentAndCleanup(false)
				self.itemSprite[ItemSpriteType.kSnailMove] = nil
			end

			self.itemSprite[ItemSpriteType.kItemShow] = sprite
			self.isNeedUpdate = true

		end , 1.8 )

		setTimeOut( function ()
			if completeCallback then completeCallback() end
		end , 2 )

		local monkey = self.itemSprite[ItemSpriteType.kItemShow]
		self.itemSprite[ItemSpriteType.kItemShow] = nil
		monkey:getParent():removeChild(monkey , false)
		

		sprite = monkey

		local lockrect = TileWukongEff:create()
		--local pos = self:getBasePosition(self.x, self.y)
		local pos = self:getBasePosition( 1,1 )
		lockrect:setPosition(pos)
		self.itemSprite[ItemSpriteType.kRoostFly] = lockrect

		self.itemSprite[ItemSpriteType.kSnailMove] = sprite
		self.isNeedUpdate = true

	else
		--[[
		local monkey = self.itemSprite[ItemSpriteType.kItemShow]
		if monkey then
			self.itemSprite[ItemSpriteType.kItemShow] = nil
			monkey:getParent():removeChild(monkey , false)
		end
		]]
		
		sprite = self:getWukongSprite()

		local fromCCP = self:getBasePosition(self.x, self.y)
		local toCCP = self:getBasePosition(toPos.x, toPos.y)

		local controlPoint = nil
		if fromCCP.y < toCCP.y then
			controlPoint = ccp(toCCP.x - (toCCP.x - fromCCP.x) / 5, toCCP.y + 350)
		elseif fromCCP.y > toCCP.y then
			if fromCCP.x == toCCP.x then
				controlPoint = ccp(fromCCP.x, fromCCP.y)
			else
				controlPoint = ccp(fromCCP.x - (fromCCP.x - toCCP.x) / 5, fromCCP.y + 240)
			end
		elseif fromCCP.y == toCCP.y then
			controlPoint = ccp(fromCCP.x - (fromCCP.x - toCCP.x) / 2, fromCCP.y + 360)
		end

		local bezierConfig = ccBezierConfig:new()
		bezierConfig.controlPoint_1 = fromCCP
		bezierConfig.controlPoint_2 = controlPoint
		bezierConfig.endPosition = toCCP
		local bezierAction = CCBezierTo:create(2, bezierConfig)
		local callbackAction = CCCallFunc:create(completeCallback)
		local delayAction = CCDelayTime:create(0.3)

		local actionList = CCArray:create()
		actionList:addObject(bezierAction)
		actionList:addObject(callbackAction)
		actionList:addObject(delayAction)
		actionList:addObject(CCCallFunc:create(onAnimComplete))
		-- local sequenceAction = CCSequence:createWithTwoActions(bezierAction, callbackAction)
		local sequenceAction = CCSequence:create(actionList)

		
		--sprite = TileWukong:createByAnimation()

		sprite:setPosition(fromCCP)

		sprite:runAction(sequenceAction)

		local scaleArr = CCArray:create()
		scaleArr:addObject( CCEaseSineIn:create( CCScaleTo:create( 1.3 , 1.8 , 1.8) ) )
		scaleArr:addObject( CCEaseSineOut:create( CCScaleTo:create( 0.7 , 1 , 1) ) )
		sprite:runAction(CCSequence:create(scaleArr))

		----[[
		self.itemSprite[ItemSpriteType.kSnailMove] = sprite
		self.isNeedUpdate = true
		--]]

		local lockrect = TileWukongEff:create()
		--local pos = self:getBasePosition(self.x, self.y)
		local pos = self:getBasePosition( 1,1 )
		lockrect:setPosition(pos)
		self.itemSprite[ItemSpriteType.kRoostFly] = lockrect
	end
	

end

function ItemView:buildRabbitCave()
	local bg = Sprite:createWithSpriteFrameName("rabbit_cave_0000")
	self.itemSprite[ItemSpriteType.kRabbitCaveDown] = bg

	local fg = Sprite:createWithSpriteFrameName("rabbit_cave_0001")
	self.itemSprite[ItemSpriteType.kRabbitCaveUp] = fg

end

function ItemView:buildRabbit(color, level, isPlayAnimation, isOnlyGetSprite)
	local sprite = TileRabbit:create(color, level)
	if isOnlyGetSprite then
		return sprite
	else
		local pos = self:getBasePosition(self.x, self.y)
		self.itemShowType = ItemSpriteItemShowType.kRabbit
		sprite:setPosition(pos)
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
		if isPlayAnimation then 
			sprite:playUpAnimation(nil, true)
		end
	end
end

function ItemView:buildRoost(roostLevel)
	local sprite = TileRoost:create(roostLevel)
	local pos = self:getBasePosition(self.x, self.y)
	sprite:setPosition(pos)
	self.itemSprite[ItemSpriteType.kItemShow] = sprite
end

function ItemView:playRoostUpgradeAnimation(times)
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	sprite:playUpgradeAnimation(times)
end

function ItemView:playRoostReplaceAnimation(completeCallback)
	local function onAnimComplete(evt)
		if completeCallback ~= nil and type(completeCallback) == "function" then
			completeCallback()
		end
	end
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	sprite:ad(Events.kComplete, onAnimComplete)
	sprite:playReplaceAnimation()
end

function ItemView:playRoostReplaceFlyAnimation(fromPos, completeCallback)
	local sprite = nil
	local context = self
	local function onAnimComplete()
		if sprite and sprite:getParent() then
			sprite:removeFromParentAndCleanup(true)
			if sprite == context.itemSprite[ItemSpriteType.kRoostFly] then
				context.itemSprite[ItemSpriteType.kRoostFly] = nil
				context.isNeedUpdate = true
			end
		end
	end

	local fromCCP = self:getBasePosition(fromPos.y, fromPos.x)
	local toCCP = self:getBasePosition(self.x, self.y)

	local controlPoint = nil
	if fromCCP.y < toCCP.y then
		controlPoint = ccp(toCCP.x - (toCCP.x - fromCCP.x) / 5, toCCP.y + 350)
	elseif fromCCP.y > toCCP.y then
		if fromCCP.x == toCCP.x then
			controlPoint = ccp(fromCCP.x, fromCCP.y)
		else
			controlPoint = ccp(fromCCP.x - (fromCCP.x - toCCP.x) / 5, fromCCP.y + 240)
		end
	elseif fromCCP.y == toCCP.y then
		controlPoint = ccp(fromCCP.x - (fromCCP.x - toCCP.x) / 2, fromCCP.y + 360)
	end

	local bezierConfig = ccBezierConfig:new()
	bezierConfig.controlPoint_1 = fromCCP
	bezierConfig.controlPoint_2 = controlPoint
	bezierConfig.endPosition = toCCP
	local bezierAction = CCBezierTo:create(0.4, bezierConfig)	--0.6
	local callbackAction = CCCallFunc:create(completeCallback)
	local delayAction = CCDelayTime:create(0.3)

	local actionList = CCArray:create()
	actionList:addObject(bezierAction)
	actionList:addObject(callbackAction)
	actionList:addObject(delayAction)
	actionList:addObject(CCCallFunc:create(onAnimComplete))
	-- local sequenceAction = CCSequence:createWithTwoActions(bezierAction, callbackAction)
	local sequenceAction = CCSequence:create(actionList)

	sprite = TileRoost:createFlyEffect()
	sprite:setPosition(fromCCP)
	-- sprite:ad(Events.kComplete, onAnimComplete)
	sprite:runAction(sequenceAction)
	self.itemSprite[ItemSpriteType.kRoostFly] = sprite
	self.isNeedUpdate = true
end

function ItemView:playDigGroundDecAnimation( boardView )
	-- body
	local sprite = self.itemSprite[ItemSpriteType.kDigBlocker]
	
	local function callback( ... )
		-- body
		sprite:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kDigBlockerBomb] = nil
	end

	if sprite then 
		if sprite.level == 1 then
			self.itemSprite[ItemSpriteType.kDigBlocker] = nil
			if boardView and container then
				sprite:removeFromParentAndCleanup(false)
				self.itemSprite[ItemSpriteType.kDigBlockerBomb] = sprite
			end
			sprite:changeLevel(sprite.level -1, callback)
		else 
			sprite:changeLevel(sprite.level - 1)
		end

		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayCloudClear )
	end
end

function ItemView:playDigJewelDecAnimation( boardView )
	-- body
	local sprite = self.itemSprite[ItemSpriteType.kDigBlocker]
	local function callback( ... )
		-- body
		sprite:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kDigBlockerBomb] = nil
		
	end

	if sprite then 
		if sprite.level == 1 then
			self.itemSprite[ItemSpriteType.kDigBlocker] = nil
			if boardView and container then 
				sprite:removeFromParentAndCleanup(false)
				self.itemSprite[ItemSpriteType.kDigBlockerBomb] = sprite
			end
			sprite:changeLevel(sprite.level -1, callback)
			GamePlayMusicPlayer:playEffect( GameMusicType.kPlayCloudCollect )
		else
			sprite:changeLevel(sprite.level - 1, true)
			GamePlayMusicPlayer:playEffect( GameMusicType.kPlayCloudClear )
		end
	end
end

function ItemView:playRandomPropDie(boardView )
	local layer = ItemSpriteType.kRandomProp

	local sprite = self.itemSprite[layer]  -- ===========================
	local function callback( ... )
		sprite:removeFromParentAndCleanup(true)
		self.itemSprite[layer] = nil
	end

	if sprite then 
		self.itemSprite[layer] = nil
		if boardView and container then 
			sprite:removeFromParentAndCleanup(false)
			self.itemSprite[layer] = sprite
		end
		sprite:playDie(callback)
	end
end

function ItemView:playDigGoldZongZiDecAnimation( boardView )
	-- body
	local sprite = self.itemSprite[ItemSpriteType.kDigBlocker]
	local function callback( ... )
		-- body
		--sprite:removeFromParentAndCleanup(true)
		--self.itemSprite[ItemSpriteType.kDigBlockerBomb] = nil
		
	end

	if sprite then 
		if sprite.level == 1 then
			sprite:changeLevel(sprite.level - 1, true)
		else
			sprite:changeLevel(sprite.level - 1, true)
		end
		
	end
end

function ItemView:playBottleBlockerHitAnimation(boardView , newLevel , newColor)
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite then

		local onAnimationDone = function()

		end

		sprite:playBottleHitAnimation(newLevel + 1 , newColor , onAnimationDone)
		if newLevel == 0 then
			local function onAnimComplete()
				self.itemSprite[ItemSpriteType.kSpecial] = nil
			end
			local anime = sprite:buildTotalBreakEffect(nil , onAnimComplete)
			local pos = sprite:getPosition()
			anime:setPosition(ccp(pos.x , pos.y))
			self.itemSprite[ItemSpriteType.kSpecial] = anime
			self.isNeedUpdate = true
			GamePlayMusicPlayer:playEffect( GameMusicType.kPlayBottleCasting )
		else
			GamePlayMusicPlayer:playEffect( GameMusicType.kPlayBottleMatch )
		end
	end
end

function ItemView:buildMonster()
	local monster = TileMonster:create()
	self.itemSprite[ItemSpriteType.kBigMonster] = monster
	
end

function ItemView:buildChestSquare()
	local sp = TileChestSquare:create()
	self.itemSprite[ItemSpriteType.kChestSquare] = sp
end

function ItemView:buildBoss(data)
	local boss = TileBossGaf:create(BossTypeGaf.kJingyu)
	self.itemSprite[ItemSpriteType.kBigMonster] = boss
	self:updateBossBlood(data.blood/data.maxBlood, false, tostring(data.blood)..'/'..tostring(data.maxBlood))
	self:upDatePosBoardDataPos(data)
end

function ItemView:buildWeeklyBoss(data)
	local boss = TileWeeklyBoss:create(WeeklyBossType.kRadish)
	self.itemSprite[ItemSpriteType.kWeeklyBoss] = boss
	-- self:updateBossBlood(data.blood/data.maxBlood, false, tostring(data.blood)..'/'..tostring(data.maxBlood))
	self:upDatePosBoardDataPos(data)
end

function ItemView:buildMoleBossCloud(data)
	local cloud = TileMoleBossCloud:create()
	self.itemSprite[ItemSpriteType.kMoleBossCloud] = cloud 		--借用下位置无妨吧~
	self:upDatePosBoardDataPos(data)
end

function ItemView:updateBossBlood(value, playAnim, debug_string)
	local s = self.itemSprite[ItemSpriteType.kBigMonster]
	if s then
		s:setBloodPercent(value, playAnim, debug_string)
	end
end

function ItemView:buildBlackCuteBall( strength, maxStrength, isOnlyGetSprite )
	-- body
	local blackcute = TileBlackCuteBall:create(strength, maxStrength)
	if isOnlyGetSprite then 
		return blackcute
	else
		self.itemSprite[ItemSpriteType.kItemShow] = blackcute
	end
end

function ItemView:playBlackCuteBallDecAnimation( strength , callback)
	-- body
	local item = self:getGameItemSprite()
	if item then 
		if strength == 2 then 
			item:playLife2(callback)
		elseif strength == 1 then 
			item:playLife1(callback)
		elseif strength == 0 then
			item:playLife0(callback)
		end
		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayBlackcuteDizziness )
	end
end

function ItemView:playMissileDecAnimation( strength )

	local item = self:getGameItemSprite()
	if item then 
		if strength == 2 then 
			item:playDecAnimation()
			item:playLife2()
		elseif strength == 1 then 
			item:playDecAnimation()
			item:playLife1()
		elseif strength == 0 then
			item:playDecAnimation()
			item:playLife0()
		end
	end
end


function ItemView:playMissileFlyAnimation(fromPos, completeCallback)
	local sprite = nil
	local context = self
	local function onAnimComplete()
		if sprite and sprite:getParent() then
			sprite:removeFromParentAndCleanup(true)
			context.itemSprite[ItemSpriteType.kSuperTotemsEffect] = nil
			context.isNeedUpdate = true
		end
	end

	local xOffset,yOffset = 0,7
	local fromCCP = self:getBasePosition(fromPos.x, fromPos.y)
	local toCCP = self:getBasePosition(self.x, self.y)
	fromCCP = ccp(fromCCP.x + xOffset,fromCCP.y + yOffset)
	toCCP = ccp(toCCP.x + xOffset  , toCCP.y + yOffset )

	local initRotation = 0
	local rotateAngle = 0
	local controlPoint = nil

	controlPoint = ccp((fromCCP.x + toCCP.x) / 2, (fromCCP.y + toCCP.y )/2)
	initRotation = 0
	rotateAngle = 0

	-- 余弦定理求转向夹角
	local offsetAngle = 0 -- 顺时针偏移一定的角度
	local vec1 = {0,1.0}
	local vec2 = {toCCP.x - fromCCP.x , toCCP.y - fromCCP.y}
	local x1,y1,x2,y2 = vec1[1],vec1[2],vec2[1],vec2[2]
	local costheta = (x1*x2 + y1*y2) / (math.sqrt(x1*x1+y1*y1) * math.sqrt(x2*x2 + y2*y2))
	initRotation = math.deg(math.acos(costheta))
	-- 逆时针方向的
	if (toCCP.x < fromCCP.x) then initRotation = 0 - initRotation end
	-- -- 求发射点和目标点的中垂线
	-- -- 将导弹位置平移到坐标原点
	vec1 = {0,0}
	vec2 = {0,math.abs(fromCCP.y - toCCP.y)}
	local zhong_chui_xian_px = math.tan(math.rad(offsetAngle)) * (math.abs(fromCCP.y - toCCP.y)/2)
	-- bezier点位置
	local ptBezier1 = {zhong_chui_xian_px,(math.abs(fromCCP.y - toCCP.y)/2)}
	-- 旋转到对应位置
	ptBezier1 = {ptBezier1[1]*math.cos(math.rad(initRotation)) + ptBezier1[2]*math.sin(math.rad(initRotation)),-ptBezier1[1]*math.sin(math.rad(initRotation)) + ptBezier1[2]*math.cos(math.rad(initRotation))}
	-- 平移回原坐标
	ptBezier1 = {ptBezier1[1] + fromCCP.x,ptBezier1[2] + fromCCP.y}
	controlPoint  = ccp(ptBezier1[1],ptBezier1[2])

	-- rotateAngle = 0-offsetAngle*2
	initRotation = initRotation + offsetAngle

	-- if _G.isLocalDevelopMode then printx(0, "aaaaa ",x1,y1,x2,y2," initRotation ",initRotation,ptBezier1[1],ptBezier1[2]) end
	local adjust = 1
	if CrashResumeGamePlaySpeedUp and GamePlayConfig_replayAdjustValue then
		--adjust = GamePlayConfig_replayAdjustValue
	end

	local bezierConfig = ccBezierConfig:new()
	bezierConfig.controlPoint_1 = fromCCP
	bezierConfig.controlPoint_2 = controlPoint
	bezierConfig.endPosition = toCCP
	local bezierAction = CCBezierTo:create(0.42 / adjust, bezierConfig)
	local callbackAction = CCCallFunc:create(completeCallback)
	local delayAction = CCDelayTime:create(0.07 / adjust)

	local rotateList = CCArray:create()
	rotateList:addObject(CCDelayTime:create(0.21 / adjust))
	rotateList:addObject(CCRotateBy:create(0.21 / adjust, rotateAngle))
	local rotateAction = CCSequence:create(rotateList)

	local scaleList = CCArray:create()
	scaleList:addObject(CCScaleTo:create(0.07 / adjust, 1,0.8))
	scaleList:addObject(CCDelayTime:create(0.28 / adjust))
	scaleList:addObject(CCScaleTo:create(0.07 / adjust, 1,0.35))
	local scaleAction = CCSequence:create(scaleList)

	local spawnArray = CCArray:create()
	spawnArray:addObject(bezierAction)
	spawnArray:addObject(rotateAction)
	-- spawnArray:addObject(scaleAction)
	local spawnActions = CCSpawn:create(spawnArray)

	local seqList = CCArray:create()
	seqList:addObject(spawnActions)
	seqList:addObject(callbackAction)
	seqList:addObject(delayAction)
	seqList:addObject(CCCallFunc:create(onAnimComplete))
	local sequenceAction = CCSequence:create(seqList)

	-- IMPL 飞直线，别搞那么复杂
	-- local initRotation = 0
	-- if toCCP.y - fromCCP.y > 0 then
	-- 	initRotation = math.deg(math.atan((toCCP.x - fromCCP.x)/(toCCP.y - fromCCP.y)))
	-- elseif toCCP.y -fromCCP.y < 0 then
	-- 	initRotation = 180 + math.deg(math.atan((toCCP.x - fromCCP.x) / (toCCP.y - fromCCP.y)))
	-- else
	-- 	if toCCP.x - fromCCP.x > 0 then initRotation = 90
	-- 	else
	-- 		initRotation = -90
	-- 	end
	-- end

	-- 	local seqList = CCArray:create()
	-- seqList:addObject(CCMoveTo:create(0.6, toCCP))
	-- seqList:addObject(CCCallFunc:create(callback))
	-- seqList:addObject(CCCallFunc:create(completeCallback))
	-- seqList:addObject( CCDelayTime:create(0.1))
	-- seqList:addObject(CCCallFunc:create(onAnimComplete))
	-- local sequenceAction = CCSequence:create(seqList)
	-- IMPL END --------------------------------------------------------------------------



	sprite = TileMissile:createFlyEffect()
	sprite:setPosition(ccp(fromCCP.x-5 , fromCCP.y-8))
	sprite:setRotation(initRotation)
	-- sprite:setScaleY(0.25)
	sprite:runAction(sequenceAction)
	self.itemSprite[ItemSpriteType.kSuperTotemsEffect] = sprite

	self.isNeedUpdate = true
end

function ItemView:playBlackCuteBallJumpToAnimation( r, c, midcallback, callback )
	-- body
	local sprite = self:getGameItemSprite()
	local toPos = self:getBasePosition(c, r)
	local function animationCallback( ... )
		-- body
		sprite:removeFromParentAndCleanup(false)
		self.itemSprite[ItemSpriteType.kSpecial] = nil
		self.itemSprite[ItemSpriteType.kItemShow] = sprite

		if callback then callback() end
	end

	-- 黑毛球跳跃的时候不要被别的障碍视图压到
	sprite:removeFromParentAndCleanup(false)
	self.itemSprite[ItemSpriteType.kItemShow] = nil
	self.itemSprite[ItemSpriteType.kSpecial] = sprite

	if sprite then 
		sprite:playJumpToAnimation(toPos, midcallback, animationCallback)
		GamePlayMusicPlayer:playEffect(GameMusicType.kPlayBlackcuteJump)
	else
	end

	self.isNeedUpdate = true
end

function ItemView:buildMimosa(data, isOnlyGetSprite)
	-- body
	local mimosa = TileMimosa:create(data.mimosaDirection)

	if isOnlyGetSprite then
		return mimosa
	else
		self.itemSprite[ItemSpriteType.kItemShow] = mimosa
		if self.oldData and self.oldData.mimosaLevel == GamePlayConfig_Mimosa_Grow_Step then
			mimosa:playActivieAnimation()
		else
			mimosa:playIdleAnimation()
		end
	end
end

function ItemView:addMimosaEffect( itemType, direction )
	-- body
	local container = Sprite:createEmpty()
	local mask = Sprite:createWithSpriteFrameName("mimosa_mask")
	container:addChild(mask)
	if itemType == GameItemType.kKindMimosa then
		mask:setAlpha(0)
	else
		mask:setAlpha(0.8)
	end
	container.mask = mask

	local sprite = Sprite:createWithSpriteFrameName("mimosa.grow.up_0026")
	container:addChild(sprite)
	container.mimosaLefa = sprite

	if direction == 1 then
		container:setRotation(-90)
	elseif direction == 2 then
		container:setRotation(90)
	elseif direction == 3 then
		container:setRotation(0)
	else
		container:setRotation(180)
	end
	container:setPosition(self:getBasePosition(self.x, self.y))
	self.itemSprite[ItemSpriteType.kNormalEffect] = container
end

function ItemView:playMimosaBackAnimation(delaytime,callback)
	-- body
	if self.isPlayBackAnimation then 
		if callback then callback() end
		return
	end

	local sprite = self:getGameItemSprite()
	self.isPlayBackAnimation = true
	if sprite then
		local function play( ... )
			-- body
			sprite:playBackAnimation(callback)
			self.isPlayBackAnimation = nil
		end 
		sprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delaytime), CCCallFunc:create(play)))
	end
end

function ItemView:playMimosaGrowAnimation( callback )
	-- body
	local sprite = self:getGameItemSprite()
	if sprite then
		sprite:playGrowAnimation(callback)
	end
end

function ItemView:playMimosaEffectGrow( itemType, direction, delay, callback)
	-- body
	local container = Sprite:createEmpty()
	local mask = Sprite:createWithSpriteFrameName("mimosa_mask")
	container:addChild(mask)
	mask:setAlpha(0)
	container.mask = mask
	if not self.itemSprite[ItemSpriteType.kNormalEffect] and itemType == GameItemType.kMimosa then 
		mask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay + 0.4), CCFadeTo:create(0.3, 255 * 0.8)))
	end

	self.isNeedUpdate = true
	local sprite = Sprite:createWithSpriteFrameName("mimosa.grow.up_0000")
	delay = delay or 0
	local frames = SpriteUtil:buildFrames("mimosa.grow.up_%04d", 0, 27)
	local animate = SpriteUtil:buildAnimate(frames, 1/60)
	local function animationCallback( ... )
		-- body
		if self.itemSprite[ItemSpriteType.kNormalEffect] then
			container:removeFromParentAndCleanup(true)
		else
			if itemType == GameItemType.kMimosa then
				mask:setAlpha(0.8)
			else
				mask:setAlpha(0)
			end
			self.itemSprite[ItemSpriteType.kNormalEffect] = container
			container:removeFromParentAndCleanup(false)
			self.getContainer(ItemSpriteType.kNormalEffect):addChild(container)
		end
		self.itemSprite[ItemSpriteType.kSpecial] = nil
		self.isNeedUpdate = true
		if callback then callback() end
	end
	sprite:play(animate, delay, 1, animationCallback )

	container:addChild(sprite)
	container.mimosaLefa = sprite

	if direction == 1 then
		container:setRotation(-90)
	elseif direction == 2 then
		container:setRotation(90)
	elseif direction == 3 then
		container:setRotation(0)
	else
		container:setRotation(180)
	end
	self.itemSprite[ItemSpriteType.kSpecial] = container
	container:setPosition(self:getBasePosition(self.x, self.y))

	GamePlayMusicPlayer:playEffect( GameMusicType.kPlayMimosaGrow )
end

function ItemView:playMimosaEffectBack( itemType, direction, delay, callback )
	-- body
	delay = delay or 0
	-- delay = 0
	local sprite = self.itemSprite[ItemSpriteType.kNormalEffect]
	if sprite then
		local mimosaLefa = sprite.mimosaLefa
		local mask = sprite.mask
		if mask and itemType == GameItemType.kMimosa then 
			mask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay), CCFadeOut:create(0.3)) )
		end

		local function animationCallback( ... )
		-- body
			sprite:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kNormalEffect] = nil	
			if callback then callback() end
		end
		local function startAnimation( ... )
			-- body
			local frames = SpriteUtil:buildFrames("mimosa.grow.up_%04d", 0, 27, true)
			local animate = SpriteUtil:buildAnimate(frames, 1/48)
			mimosaLefa:play(animate, 0, 1, animationCallback )
		end
		mimosaLefa:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay), CCCallFunc:create(startAnimation) ))

		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayMimosaOnhit )
	end

end

function ItemView:playMimosaEffectAnimation( itemType, direction, delay, callback, isGrow )
	-- body
	if isGrow then
		self:playMimosaEffectGrow( itemType, direction, delay, callback)
	else
		self:playMimosaEffectBack( itemType, direction, delay, callback )
	end
end

function ItemView:playMimosaReadyAnimation( ... )
	-- body
	local sprite = self:getGameItemSprite()
	if sprite then
		sprite:playActivieAnimation()
	end
end


function ItemView:buildSnail( snailRoadType )
	-- body
	local sprite = TileSnail:create()
	sprite:setPosition(self:getBasePosition(self.x, self.y))
	self.itemSprite[ItemSpriteType.kSnail] = sprite
	if snailRoadType == RouteConst.kLeft then 
		sprite:setScaleX(-1)
	end
	sprite:updateArrow(snailRoadType)
end

function ItemView:playHedgehogOut( callback )
	-- body
	local function _callback( ... )
		-- body
		if callback then callback() end
	end
	local sp = self.itemSprite[ItemSpriteType.kSnail]
	if sp then
		sp:playHedgehogOutAnimation(_callback)
	else
		_callback()
	end

end
function ItemView:buildHedgehog( roadType, hedgehogLevel, isbefore )
	-- body
	local sprite = TileHedgehog:create(hedgehogLevel,isbefore)
	sprite:setPosition(self:getBasePosition(self.x, self.y))
	self.itemSprite[ItemSpriteType.kSnail] = sprite
	if roadType == RouteConst.kLeft then 
		sprite:setScaleX(-1)
	end
	sprite:updateArrow(roadType)
end

-----创建掉落中被裁减的物品的sprite
function ItemView:CreateFallingClippingSprite(data, autotype)
	local tempsprite = nil;
	-------毒液，雪花不参与裁减掉落的计算-----
	if data.ItemType == GameItemType.kAnimal then 				----动物
		tempsprite = self:buildNewAnimalItem(data._encrypt.ItemColorType, data.ItemSpecialType, false, autotype, data.hasActCollection)
	elseif data.ItemType == GameItemType.kCrystal then  		--由系统统一计算
		tempsprite = ItemViewUtils:buildCrystal(data._encrypt.ItemColorType, data.hasActCollection)
	elseif data.ItemType == GameItemType.kGift then				--由系统统一计算
		tempsprite = ItemViewUtils:buildGift(data._encrypt.ItemColorType)
	elseif data.ItemType == GameItemType.kNewGift then				--由系统统一计算
		tempsprite = ItemViewUtils:buildGift(data._encrypt.ItemColorType)
	elseif data.ItemType == GameItemType.kIngredient then 		--添加一个豆荚
		local beanpod = ItemViewUtils:buildBeanpod(data.showType) 			--创建豆荚
		tempsprite = beanpod; 		--添加
	elseif data.ItemType == GameItemType.kCoin then
		tempsprite = self:buildCoin(true)
	elseif data.ItemType == GameItemType.kBalloon then
		tempsprite = TileBalloon:create(data._encrypt.ItemColorType, data.balloonFrom, data.balloonConstantPlayAlert)
	elseif data.ItemType == GameItemType.kBlackCuteBall then
		tempsprite = TileBlackCuteBall:create(data.blackCuteStrength, data.blackCuteMaxStrength)
	elseif data.ItemType == GameItemType.kRabbit then
		tempsprite = TileRabbit:create(data._encrypt.ItemColorType)
	elseif data.ItemType == GameItemType.kHoneyBottle then
		tempsprite = TileHoneyBottle:create(data.honeyBottleLevel)
	elseif data.ItemType == GameItemType.kAddTime then
		tempsprite = TileAddTime:create(data._encrypt.ItemColorType, data.addTime)
	elseif data.ItemType == GameItemType.kQuestionMark then
		tempsprite = ItemViewUtils:createQuestionMark(data._encrypt.ItemColorType)
	elseif data.ItemType == GameItemType.kAddMove then
		tempsprite = self:buildAddMove(data._encrypt.ItemColorType, data.numAddMove, true)
	elseif data.ItemType == GameItemType.kRocket then
		tempsprite = self:buildRocket(data._encrypt.ItemColorType, true)
	elseif data.ItemType == GameItemType.kCrystalStone then
		tempsprite = self:buildCrystalStone(data._encrypt.ItemColorType, data.crystalStoneEnergy, data.crystalStoneBombType, true)
	elseif data.ItemType == GameItemType.kTotems then
		tempsprite = self:buildTotems(data._encrypt.ItemColorType, data:isActiveTotems(), true)
	elseif data.ItemType == GameItemType.kDrip then
		tempsprite = self:buildDrip(true)
	elseif data.ItemType == GameItemType.kPuffer then
		tempsprite = self:buildPuffer(true , data.pufferState)
	elseif data.ItemType == GameItemType.kBuffBoom then
		tempsprite = self:buildBuffBoom( data , true )
	elseif data.ItemType == GameItemType.kMissile then
		tempsprite = self:buildMissile(data,true)
	elseif data.ItemType == GameItemType.kRandomProp then
		tempsprite = self:buildRandomProp(data,true)
	elseif data.ItemType == GameItemType.kBlocker195 then
		tempsprite = self:buildBlocker195(data, true)
	elseif data.ItemType == GameItemType.kBlocker199 then
		tempsprite = self:buildBlocker199(data, true)
	elseif data.ItemType == GameItemType.kChameleon then
		tempsprite = self:buildChameleon(data,true)
	elseif data.ItemType == GameItemType.kBlocker207 then
		tempsprite = self:buildBlocker207(true)
	elseif data.ItemType == GameItemType.kBlocker211 then
		tempsprite = self:buildBlocker211(data, true)
	elseif data.ItemType == GameItemType.kMoleBossSeed then
		tempsprite = self:buildMoleBossSeed(itemData.moleBossSeedCountDown, true)
	elseif data.ItemType == GameItemType.kScoreBuffBottle then
		tempsprite = self:buildScoreBuffBottle(data, true)
	elseif data.ItemType == GameItemType.kSunFlask then
		tempsprite = self:buildSunFlask(data.sunFlaskLevel, true)
	elseif data.ItemType == GameItemType.kSunflower then
		tempsprite = self:buildSunflower(true)
	elseif data.ItemType == GameItemType.kFirecracker then
		tempsprite = self:buildFirecracker(data, true)
    elseif data.ItemType == GameItemType.kWanSheng then
		tempsprite = self:buildWanSheng(data, true)
	else
		he_log_error("!!!!!!!!!!!!!!!!!!!!!!!!   unexcepted item type:"..tostring(data.ItemType))
	end 

	if not tempsprite then
		local logMsg = string.format("failed to create item.ItemType=%s,ColorType=%s,SpecialType=%s", 
			tostring(data.ItemType), 
			tostring(AnimalTypeConfig.convertColorTypeToIndex(data._encrypt.ItemColorType)), 
			tostring(AnimalTypeConfig.convertSpecialTypeToIndex(data.ItemSpecialType)))
		he_log_error(logMsg)
	end
	
	local container = Sprite:createEmpty()
	tempsprite:setPosition(ccp(0, 0))
	container:addChild(tempsprite)

	--附加属性
	if data.furballLevel > 0 then
		local furballsprite = ItemViewUtils:buildFurball(data.furballType)
		container:addChild(furballsprite)
	end

	return container
end

----为裁减区域添加一个节点
function ItemView:buildClippingNode()
	if self.clippingnode == nil then
		local pos = self:getBasePosition(self.x,self.y)-------回头还得加上从外面传来的偏移量
		--self.clippingnode = ClippingNode:create(CCRectMake(0, 0, self.w, self.cl_h))
		local clippingnode = SimpleClippingNode:create()
		clippingnode:setContentSize(CCSizeMake(self.w, self.cl_h))
		clippingnode:setPosition(ccp(pos.x - self.w / 2, pos.y - self.h / 2))
		self.clippingnode = clippingnode
	end
end

function ItemView:buildEnterClippingNode()
	if self.enterClippingNode == nil then
		local pos = self:getBasePosition(self.x, self.y)
		--self.enterClippingNode = ClippingNode:create(CCRectMake(0, 0, self.w, self.cl_h))
		local clippingnode = SimpleClippingNode:create()
		clippingnode:setContentSize(CCSizeMake(self.w, self.cl_h))
		clippingnode:setPosition(ccp(pos.x - self.w / 2, pos.y - self.h / 2))
		self.enterClippingNode = clippingnode
	end
end



----删除裁减节点的所有子节点
function ItemView:removeAllChildOfClippingNode()
	if self.clippingnode == nil then return false end
	if self.itemSprite[ItemSpriteType.kClipping] then
		self.itemSprite[ItemSpriteType.kClipping]:removeFromParentAndCleanup(true)
	end
	self.clippingnode:removeChildren() 			----删除所有子节点
	return true
end

function ItemView:removeAllChildOfEnterClippingNode()
	if self.enterClippingNode == nil then return false end
	if self.itemSprite[ItemSpriteType.kEnterClipping] then
		self.itemSprite[ItemSpriteType.kEnterClipping]:removeFromParentAndCleanup(true)
	end
	self.enterClippingNode:removeChildren()
	return true
end

function ItemView:addSpriteToClippingNode(theSprite)
	self:buildClippingNode()
	self.itemSprite[ItemSpriteType.kClipping] = theSprite
	if theSprite ~= nil then
		if theSprite:getParent() then theSprite:removeFromParentAndCleanup(false) end
		self.clippingnode:addChild(theSprite)
	end
end

function ItemView:addSpriteToEnterClippingNode(theSprite)
	self:buildEnterClippingNode()
	self.itemSprite[ItemSpriteType.kEnterClipping] = theSprite
	if theSprite ~= nil then
		if theSprite:getParent() then theSprite:removeFromParentAndCleanup(false) end
		self.enterClippingNode:addChild(theSprite)
	end
end

----将一个数据里面的东西添加到ClippingNode
function ItemView:FallingDataIntoClipping(data)
	local tempsprite = nil
	tempsprite = self:CreateFallingClippingSprite(data, true)
	tempsprite:setPositionXY(self.w / 2, self.h * 1.5)

	self:removeAllChildOfClippingNode() 			----删除原有Clipping的子节点
	self:addSpriteToClippingNode(tempsprite)		----将新的进行添加

	self:cleanGameItemView()
	self.isNeedUpdate = true
end

-----将裁减点里面的东西放入正常的Sprite
function ItemView:takeClippingNodeToSprite(data)
	self:cleanClippingSpriteOfItem()
	self:initByItemData(data)
end

----将一个东西通过Clipping掉出格子
function ItemView:FallingDataOutOfClipping(data)
	local tempsprite = nil
	tempsprite = self:CreateFallingClippingSprite(data, false)
	tempsprite:setPositionXY(self.w / 2, self.h / 2)

	self:removeAllChildOfEnterClippingNode()
	self:addSpriteToEnterClippingNode(tempsprite)
	self:cleanGameItemView()
	self.isNeedUpdate = true
end

----
function ItemView:cleanClippingSpriteOfItem()
	if self.itemSprite[ItemSpriteType.kClipping] then 
		self.itemSprite[ItemSpriteType.kClipping]:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kClipping] = nil
		self.isNeedUpdate = true
	end
end

function ItemView:cleanEnterClippingSpriteOfItem()
	if self.itemSprite[ItemSpriteType.kEnterClipping] then 
		self.itemSprite[ItemSpriteType.kEnterClipping]:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kEnterClipping] = nil
		self.isNeedUpdate = true
	end
end

----播放获取分数的特效动作
----num为分数
----posEnd为最后消失的位置 (注：已被架空)
----posType用来设置不同的位置类型,以便在屏幕上错开位置
function ItemView:playGetScoreAction(boardView, num, posEnd, posType, labelBatch, isBuffScore)
	--[[
	local color = nil
	if self.oldData then
		if type(self.oldData._encrypt.ItemColorType) == "table" then
			color = AnimalTypeConfig.convertColorTypeToIndex( self.oldData._encrypt.ItemColorType )
		else
			color = 0
		end
	end

	if not color then color = 0 end
	if _G.isLocalDevelopMode then printx(0,  "RRR   TTTTTTTTTTTTTTTTTTTTT  " , color ) end
	]]
	
	

	local str = string.format("%d", num);
	local ScoreLabel = labelBatch:createLabel(str);

	local pos = self:getBasePosition(self.x, self.y);
	-- local pos = boardView.gameBoardLogic:getGameItemPosInView(self.y, self.x)

	--local pos_start = ccp(pos.x - self.w / 2, pos.y - self.h /2+50)
	local pos_start = ccp(pos.x, pos.y - self.h /2+50)
	--local pos_2 = ccp(pos.x - self.w / 2, pos.y + self.h /2)
	local pos_2 = ccp(pos.x, pos.y + self.h /2)
	if posEnd == nil then
		posEnd = ccp(0, 800)
	end

	ScoreLabel:setPosition(pos_start);
	local startMoveAction = CCMoveTo:create(BoardViewAction:getActionTime(GamePlayConfig_Score_MatchDeleted_UP_Time), pos_2);
	--local stopMoveAction = CCDelayTime:create(BoardViewAction:getActionTime(GamePlayConfig_Score_MatchDeleted_Stop_Time));
	local stopMoveAction = CCDelayTime:create(BoardViewAction:getActionTime(0.1));
	local flyOutAction = CCFadeOut:create(BoardViewAction:getActionTime(GamePlayConfig_Score_MatchDeleted_Fly_Time))			----渐隐效果
	
	local scoreShowScale = 1

	if isBuffScore then
		scoreShowScale = GamePlayConfig_Score_MatchDeleted_Scale_SCORE_BUFF_BOTTLE
	elseif tonumber(num) <= 100 then
		scoreShowScale = GamePlayConfig_Score_MatchDeleted_Scale_SMALL
	elseif tonumber(num) < 1000 then
		scoreShowScale = GamePlayConfig_Score_MatchDeleted_Scale_NORMAL
	else
		scoreShowScale = GamePlayConfig_Score_MatchDeleted_Scale_BIG
	end

	ScoreLabel:setScale(scoreShowScale)

	local function onRepeatFinishCallback_GetScore()
		if ScoreLabel and ScoreLabel:getParent() then
			ScoreLabel:removeFromParentAndCleanup(true);
		end
	end

	local callAction = CCCallFunc:create(onRepeatFinishCallback_GetScore);
	local array = CCArray:create()
    array:addObject(startMoveAction)
    array:addObject(stopMoveAction)
    array:addObject(flyOutAction)
    array:addObject(callAction)
	local sequenceAction = CCSequence:create(array)

	ScoreLabel:runAction(sequenceAction);
	return ScoreLabel;
end

----刷新特效，某个sprite放入kSpecial层，飞向目标位置
----item2为来源，即，由item2的位置飞向self
function ItemView:flyingSpriteIntoItem(item2)
	if self.x == item2.x and self.y == item2.y then return end;		----自己和自己不交换

	if item2.itemSprite[ItemSpriteType.kItem] ~= nil then
		self.flyingfromtype = ItemSpriteType.kItem 												----记录来源
		self.itemSprite[ItemSpriteType.kSpecial] = item2.itemSprite[ItemSpriteType.kItem]; 		----传输
		self.itemSprite[ItemSpriteType.kSpecial]:removeFromParentAndCleanup(false);				----离开原有面板
		item2.itemSprite[ItemSpriteType.kItem] = nil;											----删除值
	elseif item2.itemSprite[ItemSpriteType.kItemShow] ~= nil then
		self.flyingfromtype = ItemSpriteType.kItemShow 											----记录来源
		self.itemSprite[ItemSpriteType.kSpecial] = item2.itemSprite[ItemSpriteType.kItemShow]; 	----传输
		self.itemSprite[ItemSpriteType.kSpecial]:removeFromParentAndCleanup(false);				----离开原有面板
		item2.itemSprite[ItemSpriteType.kItemShow] = nil;										----删除值
	end
end

----刷新特效结束，kSpecial层的物品进入普通层
function ItemView:flyingSpriteIntoItemEnd()
	if self.itemSprite[ItemSpriteType.kSpecial] then
		if (self.itemSprite[self.flyingfromtype] ~= nil ) then
			self.itemSprite[self.flyingfromtype]:removeFromParentAndCleanup(true)
			self.itemSprite[self.flyingfromtype] = nil
		end
		self.itemSprite[self.flyingfromtype] = self.itemSprite[ItemSpriteType.kSpecial]
		self.itemSprite[self.flyingfromtype]:removeFromParentAndCleanup(false)
		self.itemSprite[ItemSpriteType.kSpecial] = nil
		self.flyingfromtype = ItemSpriteType.kNone	--飞完了清除本次来源的标记
		self.isNeedUpdate = true
	end
end

----播放收集豆荚的动画
function ItemView:playCollectIngredientAction(itemShowType, boardView, posEnd)
	if self.itemSprite[ItemSpriteType.kItem] then
		local item = self.itemSprite[ItemSpriteType.kItem]
		local sprite = ItemViewUtils:buildBeanpod(itemShowType)
		if boardView.PlayUIDelegate and boardView.PlayUIDelegate.effectLayer then
			boardView.PlayUIDelegate.effectLayer:addChild(sprite, 0)
			sprite:setPosition(boardView.gameBoardLogic:getGameItemPosInView(self.y, self.x))
		end
		item:runAction(CCScaleTo:create(BoardViewAction:getActionTime(GamePlayConfig_DropDown_Ingredient_ScaleTime), 0))
		local position = boardView.gameBoardLogic:getGameItemPosInView(self.y, self.x)
		if itemShowType and itemShowType == IngredientShowType.kAcorn then 
			position.y = position.y - GamePlayConfig_DropDown_Acorn_CollectPos * GamePlayConfig_Tile_Height
		else
			position.y = position.y - GamePlayConfig_DropDown_Ingredient_CollectPos * GamePlayConfig_Tile_Height
		end

		local function onRepeatFinishCallback_MoveIngredient()
			sprite:removeFromParentAndCleanup(true)
			if boardView.PlayUIDelegate then
				local ingred_Left = boardView.gameBoardLogic.ingredientsTotal - boardView.gameBoardLogic.ingredientsCount
				boardView.PlayUIDelegate:setTargetNumber(0, 0, ingred_Left, position)
				--GamePlayMusicPlayer:playEffect( GameMusicType.kPlayUfoCollect_jdj )
			end
		end

		local collect = CCSpawn:createWithTwoActions(CCMoveTo:create(BoardViewAction:getActionTime(GamePlayConfig_DropDown_Ingredient_CollectTime),
			position), CCScaleTo:create(BoardViewAction:getActionTime(GamePlayConfig_DropDown_Ingredient_CollectTime), GamePlayConfig_DropDown_Ingredient_CollectScale))
		sprite:runAction(CCSequence:createWithTwoActions(collect, CCCallFunc:create(onRepeatFinishCallback_MoveIngredient)))
		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayJdjCollect )
	end
end

function ItemView:playChangeCrystalColor(color)
	local spritenew = ItemViewUtils:buildCrystal(color, false);
	local spriteold = self.itemSprite[ItemSpriteType.kItem];
	local changeLight = Sprite:createWithSpriteFrameName("crystal_anim0000")
	local changeFrame = SpriteUtil:buildFrames("crystal_anim%04d", 0, 20)
	local changeAnim = SpriteUtil:buildAnimate(changeFrame, kCharacterAnimationTime)
	if spriteold then
		local actCollectIcon = spriteold.actCollectIcon
		if actCollectIcon then 
			actCollectIcon:removeFromParentAndCleanup(false)
		end
		if spriteold:getParent() then
			spriteold:getParent():addChild(spritenew)
			spritenew:setPosition(self:getBasePosition(self.x,self.y));
			spritenew:setAlpha(0)

			if actCollectIcon then 
				spritenew:addChild(actCollectIcon)
				actCollectIcon:setAlpha(0)
				spritenew.actCollectIcon = actCollectIcon
			end
		end

		self.itemSprite[ItemSpriteType.kSpecial] = changeLight
		changeLight:setPosition(self:getBasePosition(self.x, self.y))
		self.isNeedUpdate = true
		changeLight:play(changeAnim)

		local Fade_Action1 = CCFadeOut:create(BoardViewAction:getActionTime(GamePlayConfig_CrystalChange_time));
		local Fade_Action2 = CCFadeIn:create(BoardViewAction:getActionTime(GamePlayConfig_CrystalChange_time));

		local context = self
		local function onCrystalColorChangeFinish()
			if spriteold then
				if spriteold:getParent() then
					spriteold:removeFromParentAndCleanup(true)
				end
				if changeLight:getParent() then
					changeLight:removeFromParentAndCleanup(true)
					context.itemSprite[ItemSpriteType.kSpecial] = nil
				end
			end
		end 
		local ccCallbackAction = CCCallFunc:create(onCrystalColorChangeFinish);
		local ccs1 = CCSequence:createWithTwoActions(Fade_Action1,ccCallbackAction);

		self.itemSprite[ItemSpriteType.kItem] = spritenew;

		spriteold:runAction(ccs1);
		
		spritenew:runAction(Fade_Action2);
		if actCollectIcon then 
			actCollectIcon:runAction(CCFadeTo:create(BoardViewAction:getActionTime(GamePlayConfig_CrystalChange_time), 255))
		end
	end
end

function ItemView:playAnimationAnimalDestroyByBird(itemPosition, birdPosition)
	local sprite1 = self.itemSprite[ItemSpriteType.kItem]------如果是kItemShow，肯定被直接炸掉了

	local item = self
	local function onAnimationFinished()
		if (sprite1) then
			sprite1:removeFromParentAndCleanup(true)
		end
		if item then
			item.itemSprite[ItemSpriteType.kSpecial] = nil 
		end
	end

	if sprite1 == nil then 			----如果是未能完全穿越通道的，则直接将其取出
		self:takeClippingNodeToSprite(self.oldData)
		sprite1 = self.itemSprite[ItemSpriteType.kItem];
	end
	self.itemSprite[ItemSpriteType.kItem] = nil;
	self.itemSprite[ItemSpriteType.kSpecial] = sprite1;

	local length = math.sqrt(math.pow(birdPosition.y - itemPosition.y, 2) + math.pow(birdPosition.x - itemPosition.x, 2))
	local thetime = 0.25 + 0.45 * length / (11 * GamePlayConfig_Tile_Width)
	local delayTime = 0.1
	local moveToAction = HeBezierTo:create(thetime, birdPosition, true, length * 0.618)
	local delayMoveAction = CCEaseSineIn:create(moveToAction)
	local scaleAction = CCEaseSineIn:create(CCScaleTo:create(thetime, 0.4))
	-- local delayScaleAction = CCSequence:createWithTwoActions(CCDelayTime:create(0.01), scaleAction)
	local rotateAction = CCRotateBy:create(thetime + delayTime, 90 + 270 * length / (11 * GamePlayConfig_Tile_Width))
	local callAction = CCCallFunc:create(onAnimationFinished)
	local deleteAction = CCSequence:createWithTwoActions(CCDelayTime:create(thetime + delayTime), callAction)
	local alphaAction = CCSequence:createWithTwoActions(CCDelayTime:create(thetime - 0.1), CCFadeOut:create(delayTime+0.1))

	local actionList = CCArray:create()
	actionList:addObject(delayMoveAction)
	actionList:addObject(scaleAction)
	actionList:addObject(rotateAction)
	actionList:addObject(deleteAction)
	actionList:addObject(alphaAction)
  	local spawnAction = CCSpawn:create(actionList)
  	local sequenceAction = CCSequence:createWithTwoActions(CCDelayTime:create(0.4 * math.random()), spawnAction)

  	if sprite1 == nil or not sprite1.refCocosObj then
  		if _G.isLocalDevelopMode then printx(0, "sprite1 == nil", r1,c1) end
  	else
  		sprite1:runAction(sequenceAction)
  	end
end

function ItemView:playShakeBySpecialColorEffect()
	local itemView, itemBackView, itemShowView = self.itemSprite[ItemSpriteType.kItem], self.itemSprite[ItemSpriteType.kItemBack], self.itemSprite[ItemSpriteType.kItemShow]
	--动画效果，不使用随机种子
	local firstDir = 0
	if math.random() > 0.5 then 
		firstDir = 1
	else
		firstDir = -1
	end
	local rotateAngel = 6 + 3 * math.random()
	local rotateAction1 = CCRotateTo:create(0.08, firstDir * rotateAngel)
	local rotateAction2 = CCRotateTo:create(0.08, -firstDir * rotateAngel * 2)
	local actionList = CCArray:create()
	actionList:addObject(rotateAction1)
	actionList:addObject(rotateAction2)
	local sequenceAction = CCSequence:create(actionList)
	if itemView and itemView.refCocosObj then
		itemView:runAction(CCRepeatForever:create(sequenceAction))
	end
end

function ItemView:playAnimalChangeToSpecialEffect(color, specialType, delay)
	if specialType == AnimalTypeConfig.kWrap
			or specialType == AnimalTypeConfig.kLine
			or specialType == AnimalTypeConfig.kColumn then
		local sprite = self.itemSprite[ItemSpriteType.kItemShow]
		if sprite then
			local actSeq = CCArray:create()
			if delay and delay > 0 then
				actSeq:addObject(CCDelayTime:create(delay))
			end
			actSeq:addObject(CCScaleTo:create(0.2, 1.2))
			actSeq:addObject(CCScaleTo:create(0.1, 1))
			sprite:runAction(CCSequence:create(actSeq))
		end
	end
end

function ItemView:stopShakeBySpecialColorEffect()
	local itemView, itemBackView, itemShowView = self.itemSprite[ItemSpriteType.kItem], self.itemSprite[ItemSpriteType.kItemBack], self.itemSprite[ItemSpriteType.kItemShow]
	if itemView and itemView.refCocosObj then
		itemView:stopAllActions()
		itemView:setRotation(0)
	end
end

function ItemView:showMoveTileEffect(dir)
	local effect = TileMove:createArrowAnimation(dir)
	effect:setPosition(self:getBasePosition(self.x, self.y))
	self.itemSprite[ItemSpriteType.kTileMoveEffect] = effect
	self.isNeedUpdate = true
end

function ItemView:hideMoveTileEffect()
	local effect = self.itemSprite[ItemSpriteType.kTileMoveEffect]
	if effect and not effect.isDisposed then
		effect:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kTileMoveEffect] = nil
	end
end

function ItemView:showAdviseEffect(dir)
	local itemView, itemBackView, itemShowView = self.itemSprite[ItemSpriteType.kItem], self.itemSprite[ItemSpriteType.kItemBack], self.itemSprite[ItemSpriteType.kItemShow]
	local toX = 0
	local toY = 0
	if dir.r < 0 then 
		toY = 1
	elseif dir.r > 0 then
		toY = -1
	elseif dir.c > 0 then
		toX = 1
	elseif dir.c < 0 then
		toX = -1
	end

	local moveDistance = 2 
	local moveDistance2 = 4
	local moveAction1 = CCMoveBy:create(0.15, ccp(-toX * moveDistance, -toY * moveDistance))
	local moveAction2 = CCMoveBy:create(0.03, ccp(toX * moveDistance, toY * moveDistance))
	local moveAction3 = CCMoveBy:create(0.01, ccp(toX * moveDistance2, toY * moveDistance2))
	local moveAction4 = CCMoveBy:create(0.30, ccp(-toX * moveDistance2, -toY * moveDistance2))
	local actionList = CCArray:create()
	actionList:addObject(moveAction1)
	actionList:addObject(moveAction2)
	actionList:addObject(moveAction3)
	actionList:addObject(moveAction4)
	local sequenceAction = CCSequence:create(actionList)
	local repeatTimes = 3
	if itemView then
		itemView:runAction(CCRepeat:create(sequenceAction, repeatTimes))
	end
	if itemBackView then
		itemBackView:runAction(CCRepeat:create(sequenceAction, repeatTimes))
	end
	if itemShowView then
		itemShowView:runAction(CCRepeat:create(sequenceAction, repeatTimes))
	end
end

function ItemView:stopAdviseEffect()
	local itemView, itemBackView, itemShowView = self.itemSprite[ItemSpriteType.kItem], self.itemSprite[ItemSpriteType.kItemBack], self.itemSprite[ItemSpriteType.kItemShow]
	if itemView then
		itemView:stopAllActions()
	end
	if itemBackView then
		itemBackView:stopAllActions()
	end
	if itemShowView then
		itemShowView:stopAllActions()
	end
end

function ItemView:playSelectEffect(data)
	if data.ItemType == GameItemType.kAnimal then
		if not AnimalTypeConfig.isSpecialTypeValid(data.ItemSpecialType) then
			local itemView = self.itemSprite[ItemSpriteType.kItem]
			if itemView and itemView.refCocosObj then
				itemView:setVisible(false)
				local sprite = TileCharacter:create(table.getMapValue(itemsName, data._encrypt.ItemColorType))
				sprite:playSelectAnimation()
				local pos = self:getBasePosition(self.x, self.y)
				sprite:setPosition(pos)

				if data.hasActCollection then 
					self:addActCollectionIcon(sprite, 17, -17)
				end

				self.itemSprite[ItemSpriteType.kItemShow] = sprite
				self.isNeedUpdate = true
			end
		elseif data.ItemSpecialType == AnimalTypeConfig.kColor then
			local itemView = self.itemSprite[ItemSpriteType.kItemShow]
			if itemView then
				itemView:playSelectedAnimation()
			end

		end
	elseif table.exist({GameItemType.kRabbit, GameItemType.kCrystalStone, GameItemType.kTotems}, data.ItemType) then
		local itemView = self.itemSprite[ItemSpriteType.kItemShow]
		if itemView and itemView.refCocosObj then 
			itemView:playSelectedAnimate()
		end
	end

	if self.itemSprite[ItemSpriteType.kSpecial] == nil then
		local selectBorderEffect = ItemViewUtils:buildSelectBorder()
		local pos = self:getBasePosition(self.x,self.y);
		selectBorderEffect:setPosition(pos)
		self.itemSprite[ItemSpriteType.kSpecial] = selectBorderEffect
		self.isNeedUpdate = true
	end
end

function ItemView:stopSelectEffect(data)
	if data.ItemType == GameItemType.kAnimal then
		if not AnimalTypeConfig.isSpecialTypeValid(data.ItemSpecialType) then
			local itemView, itemShowView = self.itemSprite[ItemSpriteType.kItem], self.itemSprite[ItemSpriteType.kItemShow]
			if itemView then
				itemView:setVisible(true)
			end
			if itemShowView then
				itemShowView:stopSelectAnimation()
				itemShowView:removeFromParentAndCleanup(true)
				self.itemSprite[ItemSpriteType.kItemShow] = nil
				self.isNeedUpdate = true
			end
		elseif data.ItemSpecialType == AnimalTypeConfig.kColor then
			local itemView = self.itemSprite[ItemSpriteType.kItemShow]
			if itemView then
				itemView:playNormalAnimation()
			end
		end
	elseif table.exist({GameItemType.kCrystalStone, GameItemType.kTotems}, data.ItemType) then
		local itemView = self.itemSprite[ItemSpriteType.kItemShow]
		if itemView then
			itemView:stopSelectedAnimate()
		end
	end

	local borderEffect = self.itemSprite[ItemSpriteType.kSpecial]
	if borderEffect then
		if not borderEffect.isDisposed then
			borderEffect:stopAllActions()
		end
		borderEffect:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kSpecial] = nil
		self.isNeedUpdate = true
	end
end

function ItemView:showBoardHighlightEffect()
	self:removeBoardHighlightEffect()

	local bottomView = Sprite:createWithSpriteFrameName("tile_high_light_effect_bottom_0000")
	if bottomView then
		local frames = SpriteUtil:buildFrames("tile_high_light_effect_bottom_%04d", 0, 30)
		local anim = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		bottomView:play(anim)

		bottomView:setPosition(self:getBasePosition(self.x, self.y))
		self.itemSprite[ItemSpriteType.kTileHighLightEffectWithoutTexture] = bottomView
	end

	local topView = Sprite:createWithSpriteFrameName("tile_high_light_effect_top_0000")
	if topView then
		local frames = SpriteUtil:buildFrames("tile_high_light_effect_top_%04d", 0, 30)
		local anim = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		topView:play(anim)

		topView:setPosition(self:getBasePosition(self.x, self.y))
		self.itemSprite[ItemSpriteType.kSpecialHigh] = topView
	end

	self.isNeedUpdate = true
end

function ItemView:removeBoardHighlightEffect()
	if self.itemSprite[ItemSpriteType.kTileHighLightEffectWithoutTexture] then
		local bottomView = self.itemSprite[ItemSpriteType.kTileHighLightEffectWithoutTexture]
		bottomView:stopAllActions()
		bottomView:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kTileHighLightEffectWithoutTexture] = nil
	end

	if self.itemSprite[ItemSpriteType.kSpecialHigh] then
		local topView = self.itemSprite[ItemSpriteType.kSpecialHigh]
		topView:stopAllActions()
		topView:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kSpecialHigh] = nil
	end

	self.isNeedUpdate = true
end

------------------------balloon------------------
function ItemView:buildBalloon( data )
	local balloon =  TileBalloon:create(data._encrypt.ItemColorType, data.balloonFrom, data.balloonConstantPlayAlert)
	local pos = self:getBasePosition(self.x, self.y)
	balloon:setPosition(pos)
	self.itemShowType = ItemSpriteItemShowType.kCharacter
	self.itemSprite[ItemSpriteType.kItemShow] = balloon
end

function ItemView:updateBalloonStep( value )
	-- body
	local balloon = self:getItemSprite(ItemSpriteType.kItemShow)
	if balloon then balloon:updateShowNumber(value) end
end

function ItemView:playBalloonActionRunaway( boardView )


	local balloon = self:getItemSprite(ItemSpriteType.kItemShow)
	self.itemSprite[ItemSpriteType.kItemShow] = nil
	-- body
	local function callback( ... )
		-- body
		if balloon then
			balloon:removeFromParentAndCleanup(true)
		end
	end
	local scale = 1;
	if boardView and boardView.PlayUIDelegate and boardView.PlayUIDelegate.effectLayer then
		balloon:removeFromParentAndCleanup(false)
		boardView.PlayUIDelegate.effectLayer:addChild(balloon)
		scale = boardView.PlayUIDelegate.effectLayer:getScale();
		balloon:setPosition(boardView.gameBoardLogic:getGameItemPosInView(self.y, self.x))
		
	end
	if balloon then balloon:playRunawayAnimation(scale, callback) end
end

function ItemView:playBalloonBombEffect( ... )
	-- body
	local s = self.itemSprite[ItemSpriteType.kItemShow]
	-- s:removeFromParentAndCleanup(true)
	if s then 
		self.itemSprite[ItemSpriteType.kItemShow] = nil
		GamePlayMusicPlayer:playEffect(GameMusicType.kBalloonBreak)
		local function onAnimComplete( evt )
			-- body
			if s then 
				s:removeFromParentAndCleanup(true)
			end
			GamePlayMusicPlayer:playEffect(GameMusicType.kPlayAdd5stepStart)
			setTimeOut( function () GamePlayMusicPlayer:playEffect(GameMusicType.kPlayAdd5stepFlyon) end , 0.4 )
			setTimeOut( function () GamePlayMusicPlayer:playEffect(GameMusicType.kPlayAdd5stepEnd) end , 1 )
		end
		s.isNeedUpdate = true
		s:ad(Events.kComplete, onAnimComplete)
		s:playDestroyAnimation()

		local t3 = self.itemSprite[ItemSpriteType.kClipping];----正在穿越通道的物品，直接移除，因为已经有特效在播放了
		if (t3) then
			if t3:getParent() then t3:removeFromParentAndCleanup(true) end;
			self.itemSprite[ItemSpriteType.kClipping] = nil;
		end
	end
end

function ItemView:playRabbitDestroyAnimation()
	local s = self.itemSprite[ItemSpriteType.kItemShow]
	if s then
		s:removeFromParentAndCleanup(false)
		
		self.itemSprite[ItemSpriteType.kItemShow] = nil

		local function onAnimComplete()
			if s then s:removeFromParentAndCleanup(true) end
			self.itemSprite[ItemSpriteType.kNormalEffect] = nil
		end

		s:playDestroyAnimation(onAnimComplete)

		if self.getContainer(ItemSpriteType.kNormalEffect) and self.itemSprite[ItemSpriteType.kNormalEffect] == nil then
			self.getContainer(ItemSpriteType.kNormalEffect):addChild(s);
		else
			self.isNeedUpdate = true
		end
		self.itemSprite[ItemSpriteType.kNormalEffect] = s
	end
end


function ItemView:setTileBlockCoverSpriteVisible( value )
	for i = ItemSpriteType.kColorFilterA, ItemSpriteType.kLast do
		if self.itemSprite[i] ~= nil then
			if i == ItemSpriteType.kRope or i == ItemSpriteType.kPass or i == ItemSpriteType.kChain then 
			else
				if value then 
					if self.itemSprite[ItemSpriteType.kColorFilterB] then 
						if table.includes(ColorFilterBHideLayers, i) then 
							self.itemSprite[i]:setVisible(false)
						else
							self.itemSprite[i]:setVisible(true)
						end
					else
						self.itemSprite[i]:setVisible(true)
					end
				else
					self.itemSprite[i]:setVisible(false)
				end
			end
		end
	end
end


function ItemView:playTileBoardUpdate( countDown, isReverseSide, callback, boardView)
	-- body
	local s = self.itemSprite[ItemSpriteType.kTileBlocker]
	if s then
		s:updateState(countDown)
	end

	local function animateCallback( ... )
		-- body
		if isReverseSide then 
			self:setTileBlockCoverSpriteVisible(true)
			if boardView.PlayUIDelegate and boardView.PlayUIDelegate.effectLayer then 
				stars = s:createStarSprite()
				stars:setPosition(boardView.gameBoardLogic:getGameItemPosInView(self.y, self.x))
				boardView.PlayUIDelegate.effectLayer:addChild(stars)
			end
		end

		if s then
			s:updateState(3)
		end
		if callback then callback() end
	end

	if countDown == 0 then 
		self.isNeedUpdate = true
		self:setTileBlockCoverSpriteVisible(false)
		s:playTurnAnimation(isReverseSide, animateCallback)
		
	else
		if callback then  callback() end
	end
end

function ItemView:playDoubleSideTileBoardUpdate( countDown, side , callback, boardView)
	-- body
	local s = self.itemSprite[ItemSpriteType.kTileBlocker]
	if s then
		s:updateState(countDown)
	end

	local function animateCallback( ... )
		-- body
		----[[

		--self:setTileBlockCoverSpriteVisible(true)

		if side == 2 then 
			self.isNeedUpdate = true
			--
			if boardView.PlayUIDelegate and boardView.PlayUIDelegate.effectLayer then 
				stars = s:createStarSprite()
				stars:setPosition(boardView.gameBoardLogic:getGameItemPosInView(self.y, self.x))
				boardView.PlayUIDelegate.effectLayer:addChild(stars)
			end
		end
		--]]

		if s then
			s:updateState(3)
		end
		--self:removeItemSpriteGameItem()
		if callback then callback() end
	end

	if countDown == 0 then 
		local isReverseSide = side == 2
		self.isNeedUpdate = true
		--self:removeItemSpriteGameItem()
		--self:setTileBlockCoverSpriteVisible(false)
		s:playTurnAnimation( isReverseSide , animateCallback)

		local function removeSelf()
			if self.itemSprite[ItemSpriteType.kTileMoveEffect] then
				self.itemSprite[ItemSpriteType.kTileMoveEffect]:removeFromParentAndCleanup(true)
				self.itemSprite[ItemSpriteType.kTileMoveEffect] = nil
			end
		end

		local eff = TileDoubleSideBlocker:createFrameAnimations( TileDoubleSideBlockerAnimeType.kChangeTop , isReverseSide , removeSelf )
		local effPos = self:getBasePosition(self.x, self.y)
		eff:setPositionXY( effPos.x - 2 , effPos.y )
		self.itemSprite[ItemSpriteType.kTileMoveEffect] = eff
		
	else
		if callback then  callback() end
	end
end

function ItemView:playMonsterFrostingDec( callback )
	-- body
	local monster_frosting = self.itemSprite[ItemSpriteType.kBigMonsterIce]
	local function animationCallback( ... )
		-- body
		if monster_frosting then monster_frosting:removeFromParentAndCleanup(true) end
		self.itemSprite[ItemSpriteType.kBigMonsterIce] = nil
		if callback and type(callback) == "function" then callback() end
	end
	
	if monster_frosting then
		monster_frosting:playDestroyAnimation(animationCallback)
		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayMonsterBreakice )
	end
end

function ItemView:playChestSquarePartDec(callback)
	local part = self.itemSprite[ItemSpriteType.kChestSquarePart]
	local partFront = self.itemSprite[ItemSpriteType.kChestSquarePartFront]

	local function animationCallback( ... )
		if part then part:removeFromParentAndCleanup(true) end
		self.itemSprite[ItemSpriteType.kChestSquarePart] = nil
		if callback and type(callback) == "function" then callback() end
	end
	
	local function animationCallback2( ... )
		if part then part:removeFromParentAndCleanup(true) end
		self.itemSprite[ItemSpriteType.kChestSquarePartFront] = nil
		if callback and type(callback) == "function" then callback() end
	end

	if part then
		part:playDestroyAnimation(animationCallback)
	end

	if partFront then
		partFront:playFrontDestroyAnimation(animationCallback2)
	end

end

function ItemView:playChesteSquareJumpAnimation(finishCallback)
	local monster = self.itemSprite[ItemSpriteType.kChestSquare]

	local function animationCallback( ... )
		if monster then monster:removeFromParentAndCleanup(true) end
		self.itemSprite[ItemSpriteType.kChestSquare] = nil
		self.isNeedUpdate = true
		if finishCallback then finishCallback() end
	end
	
	if monster then 
		monster:playJumpAnimation(animationCallback)
	else
		if finishCallback then finishCallback() end
	end

end


function ItemView:playChesteSquareHit()
	local monster = self.itemSprite[ItemSpriteType.kChestSquare]

	local function animationCallback( ... )
		-- if monster then monster:removeFromParentAndCleanup(true) end
		-- self.itemSprite[ItemSpriteType.kChestSquare] = nil
		-- self.isNeedUpdate = true
	end
	
	if monster then 
		monster:playHit(animationCallback)
	end
end


function ItemView:playMonsterEncourageAnimation( ... )
	-- body
	local monster = self.itemSprite[ItemSpriteType.kBigMonster]
	if monster then monster:playEncourageAnimation() end
end



function ItemView:playMonsterJumpAnimation( jumpCallback, finishCallback )
	local monster = self.itemSprite[ItemSpriteType.kBigMonster]
	self.itemSprite[ItemSpriteType.kBigMonster] = nil
	local function animationCallback()
		if monster then monster:removeFromParentAndCleanup(true) end
		self.isNeedUpdate = true
		if finishCallback then finishCallback() end
	end
	
	if monster then 
		monster:playJumpAnimation(jumpCallback, animationCallback)
	else
		if finishCallback then finishCallback() end
	end
end

function ItemView:playMaydayBossChangeToAddMove(boardView, fromItem, callback, isHalloween)
	local animation = nil
	local function onAnimComplete()
		if self.itemSprite[ItemSpriteType.kSpecial] then
			self.itemSprite[ItemSpriteType.kSpecial]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kSpecial] = nil
		end

		callback()
	end

	local fromPos = self:getBasePosition(fromItem.x, fromItem.y)
	local toPos = self:getBasePosition(self.x, self.y)
	animation = FallingStar:create(fromPos, toPos, flyingtime, onAnimComplete, nil, isHalloween)
	self.itemSprite[ItemSpriteType.kSpecial] = animation 
	self.isNeedUpdate = true

end

function ItemView:playChangeToLineSpecial(boardView, fromItem, direction, callback)
	local animation = nil
	local function onAnimComplete()
		if self.itemSprite[ItemSpriteType.kSpecial] then
			self.itemSprite[ItemSpriteType.kSpecial]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kSpecial] = nil
		end

		callback()
	end

	local fromPos = self:getBasePosition(fromItem.x, fromItem.y)
	local toPos = self:getBasePosition(self.x, self.y)
	animation = FallingStar:create(fromPos, toPos, flyingtime, onAnimComplete)
	self.itemSprite[ItemSpriteType.kSpecial] = animation 
	self.isNeedUpdate = true	
end

function ItemView:playMaydayBossDie(boardView, callback)
	local boss = self.itemSprite[ItemSpriteType.kBigMonster]
	-- self.itemSprite[ItemSpriteType.kBigMonster] = nil 			--动画视图的消失和逻辑分开来 避免boss动画播不完就被remove掉了。
	local function animationCallback( ... )
		if boss then 
			boss:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kBigMonster] = nil
		end
		if callback then callback() end
		
	end
	if boss then
		boss:destroy(animationCallback)
	else
		if callback then callback() end
	end
end

function ItemView:playWeeklyBoosDie(boardView, callback)
	local boss = self.itemSprite[ItemSpriteType.kWeeklyBoss]
	self.itemSprite[ItemSpriteType.kWeeklyBoss] = nil 			--动画视图的消失和逻辑分开来 避免boss动画播不完就被remove掉了。
	local function animationCallback()
		if boss then 
			boss:removeFromParentAndCleanup(true)
			-- self.itemSprite[ItemSpriteType.kBigMonster] = nil
		end
		if callback then callback() end
	end
	if boss then
		boss:destroy(animationCallback)
	else
		if callback then callback() end
	end
end

function ItemView:playMoleWeeklyBossCloudDie(callback)
	local cloud = self.itemSprite[ItemSpriteType.kMoleBossCloud]
	self.itemSprite[ItemSpriteType.kMoleBossCloud] = nil 			--动画视图的消失和逻辑分开来 避免cloud动画播不完就被remove掉了。
	local function animationCallback()
		if cloud then 
			cloud:removeFromParentAndCleanup(true)
		end
		if callback then callback() end
	end
	if cloud then
		cloud:destroy(animationCallback)
	else
		if callback then callback() end
	end
end

function ItemView:playMaydayBossDisappear(boardView, callback)
	local boss = self.itemSprite[ItemSpriteType.kBigMonster]
	local function animationCallback( ... )
		if boss and not boss.isDisposed then 
			boss:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kBigMonster] = nil
		end
		if callback then callback() end

	end
	boss:disappear(animationCallback)
end

function ItemView:playMaydayBossCast(boardView, callback)
	local boss = self.itemSprite[ItemSpriteType.kBigMonster]
	local function animationCallback( ... )
		if callback then callback() end
	end
	boss:cast(animationCallback)
end

function ItemView:buildBossAnim(data)
	local boss = TileBossGaf:create(BossTypeGaf.kJingyu)
	self.itemSprite[ItemSpriteType.kBigMonster] = boss
	self:updateBossBlood(data.blood/data.maxBlood, false)
	self:upDatePosBoardDataPos(data)
end

function ItemView:playMaydayBossComeout(boardView, data, callback)
	self:buildBossAnim(data)
	local boss = self.itemSprite[ItemSpriteType.kBigMonster]
	local tempX = (self.x - 0.5 ) * self.w 
	local tempY = (Max_Item_Y - self.y - 0.5 ) * self.h
	boss:setPositionXY(tempX + 0.5 * self.w, tempY - 0.5 * self.h)

	local function animationCallback()
		if callback then callback() end
	end

	boss:comeout(animationCallback)
	self.isNeedUpdate = true
end

function ItemView:playBossHit(boardView, callback)
	local boss = self.itemSprite[ItemSpriteType.kBigMonster]

	local function animCallback()
		if callback then callback() end
	end
	boss:hit(animationCallback)
end

function ItemView:playWeeklyBossHit(boardView, bossBlood, callback)
	local boss = self.itemSprite[ItemSpriteType.kWeeklyBoss]

	local function animCallback()
		if callback then callback() end
	end
	boss:hit(bossBlood, animationCallback)
end

function ItemView:playMoleBossCloudHit(boardView, bossBlood, callback)
	local cloud = self.itemSprite[ItemSpriteType.kMoleBossCloud]

	local function animCallback()
		if callback then callback() end
	end
	cloud:hit(bossBlood, animationCallback)
end

function ItemView:playMonsterDestroyItem(r_min, r_max, c_min, c_max, delayIndex, animationCallback )
	-- body
	local sprite
	local function localCallback( ... )
		-- body

		if sprite then sprite:removeFromParentAndCleanup(true) end
		self.itemSprite[ItemSpriteType.kBigMonsterFoot] = nil

	end

	local function getItemPosition( x,y )
		-- body
		local tempX = (x - 0.5 ) * GamePlayConfig_Tile_Width
		local tempY = (Max_Item_Y - y - 0.5 ) * GamePlayConfig_Tile_Width
		return ccp(tempX, tempY)

	end

	if r_max - r_min > 5 then 
		sprite = BigMonsterFoot:create( localCallback, animationCallback )
		local basePos = getItemPosition(5, 5)
		sprite:setPosition(ccp(basePos.x, basePos.y))
		sprite:setScale(1.2)
	else
		sprite = MonsterFoot:create( localCallback,animationCallback, delayIndex )
		local basePos = getItemPosition(c_min, r_min)
		sprite:setPosition(ccp(basePos.x + GamePlayConfig_Tile_Width, basePos.y - GamePlayConfig_Tile_Height/2))
	end
	self.itemSprite[ItemSpriteType.kBigMonsterFoot] = sprite
	self.isNeedUpdate = true
	
end

function ItemView:playMissleBombAnimation( ... )
	local sprite
	local function localCallback( ... )
		if sprite then sprite:removeFromParentAndCleanup(true) end
		self.itemSprite[ItemSpriteType.kMissileEffect] = nil
	end

	local function getItemPosition( x,y )
		local tempX = (x - 0.5 ) * GamePlayConfig_Tile_Width
		local tempY = (Max_Item_Y - y - 0.5 ) * GamePlayConfig_Tile_Width
		return ccp(tempX, tempY)
	end

	sprite = MissileBomb:create( localCallback )
	local basePos = getItemPosition(self.x, self.y)
	sprite:setPosition(ccp(basePos.x-32, basePos.y+33))

	self.itemSprite[ItemSpriteType.kMissileEffect] = sprite
	self.isNeedUpdate = true
end

function ItemView:playSnailRoadChangeState( changeToBright )
	-- body
	local snailRoad = self.itemSprite[ItemSpriteType.kSnailRoad]
	if snailRoad then
		snailRoad:changeState(changeToBright)
	end
end

function ItemView:playHedgehogRoadChangeState( state )
	-- body
	local road = self.itemSprite[ItemSpriteType.kHedgehogRoad]
	local function callback( ... )
		-- body
		road:setVisible(true)
		local s = self.itemSprite[ItemSpriteType.kHedgehogRoadEffect]
		if s then
			s:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kHedgehogRoadEffect] = nil
		end
	end

	if road then 
		road:changeState(state)
		--[[
		if state == HedgeRoadState.kPass then
			road:setVisible(false)
			local tmpRoad = road:copy()
			local size = tmpRoad:getGroupBounds().size
			local pos = self:getBasePosition(self.x, self.y)
			local roadAni = TileHedgehogRoad:createChangeBrightAnimation(tmpRoad, pos, callback)
			self.itemSprite[ItemSpriteType.kHedgehogRoadEffect] = roadAni
			-- roadAni:setPosition(ccp(pos.x - size.width/2, pos.y - size.height/2))
			self.isNeedUpdate = true
		end
		]]
		
	end
end

function ItemView:playSnailInShellAnimation(direction,callback )
	-- body
	local item = self.itemSprite[ItemSpriteType.kSnail]
	if item then
		if item then item:removeFromParentAndCleanup(true) end
		self.itemSprite[ItemSpriteType.kSnail] = nil
	end
	local tempSnail = TileSnail:create()
	local function animationCallback( ... )
		-- body
		self.isNeedUpdate = true
		if callback then callback() end
		tempSnail:playMoveAnimation()
	end

	
	tempSnail:setPosition(self:getBasePosition(self.x, self.y))
	tempSnail:playToShellAnimation(animationCallback)
	self.itemSprite[ItemSpriteType.kSnailMove] = tempSnail
	if direction == RouteConst.kLeft then
		tempSnail:setScaleX(-1)
	end

	self.isNeedUpdate = true
end

function ItemView:playHedgehogInShellAnimation(direction,callback, hedgehogLevel, isCrazy )
	-- body
	local item = self.itemSprite[ItemSpriteType.kSnail]
	if item then
		if item then item:removeFromParentAndCleanup(true) end
		self.itemSprite[ItemSpriteType.kSnail] = nil
	end
	local tempSnail = TileHedgehog:create(hedgehogLevel)
	local function animationCallback( ... )
		-- body
		self.isNeedUpdate = true
		if callback then callback() end
		tempSnail:playMoveAnimation(nil, isCrazy)
	end

	
	tempSnail:setPosition(self:getBasePosition(self.x, self.y))
	tempSnail:playToShellAnimation(animationCallback)
	self.itemSprite[ItemSpriteType.kSnailMove] = tempSnail
	if direction == RouteConst.kLeft then
		tempSnail:setScaleX(-1)
	end

	self.isNeedUpdate = true
end

function ItemView:playSnailOutShellAnimation(direction, callback)
	local item = self.itemSprite[ItemSpriteType.kSnailMove]
	local function animationCallback( ... )
		-- body
		item:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kSnailMove] = nil
		self:cleanGameItemView()
		self:buildSnail(direction)
		if self.getContainer(ItemSpriteType.kSnail) ~= nil then 
			self.getContainer(ItemSpriteType.kSnail):addChild(self.itemSprite[ItemSpriteType.kSnail]);
		else
			self.isNeedUpdate = true;
		end

		-- self.isNeedUpdate = true
		if callback then callback() end
	end
	if item then
		item:setRotation(0)
		if direction == RouteConst.kLeft then
			item:setScaleX(-1)
		else
			item:setScaleX(1)
		end
		item:updateArrow(direction)
		item:playOutShellAnimation(animationCallback) 
	end
end

function ItemView:playHedgehogOutShellAnimation(direction, callback, hedgehogLevel)
	local item = self.itemSprite[ItemSpriteType.kSnailMove]
	local function animationCallback( ... )
		-- body
		item:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kSnailMove] = nil
		self:cleanGameItemView()
		self:buildHedgehog(direction, hedgehogLevel)
		if self.getContainer(ItemSpriteType.kSnail) ~= nil then 
			self.getContainer(ItemSpriteType.kSnail):addChild(self.itemSprite[ItemSpriteType.kSnail]);
		else
			self.isNeedUpdate = true;
		end
		if callback then callback() end
	end
	if item then
		item:setRotation(0)
		if direction == RouteConst.kLeft then
			item:setScaleX(-1)
		else
			item:setScaleX(1)
		end
		item:updateArrow(direction)
		item:playOutShellAnimation(animationCallback) 
	end
end

function ItemView:playHedgehogChangeAnimation( level, callback )
	-- body
	local item = self.itemSprite[ItemSpriteType.kSnail]
	local function animationCallback( ... )
		-- body
		if callback then callback() end
	end 
	item:playChangeAnimation(level, animationCallback)
end



function ItemView:playSnailMovingAnimation(rotation , callback)
	-- body
	-- debug.debug()
	local item = self.itemSprite[ItemSpriteType.kSnailMove]
	local function animationCallback( ... )
		-- body
		if callback then callback() end
		self.isNeedUpdate = true
		GamePlayMusicPlayer:playEffect( GameMusicType.kPlaySnailStop )
	end
	--[[
	item:setScaleX(1)
	item:setRotation(0)
	item:setMainSpriteRotation(0)
	if rotation == 180 then 
		item:setScaleX(-1)
	else
		item:setRotation(rotation)
		item:setMainSpriteRotation(rotation)
	end
	]]

	if rotation == 180 then 
		item:setScaleX(-1)
		item:setRotation(0)
		item:setMainSpriteRotation(0)
	else
		item:setScaleX(1)
		item:setRotation(rotation)
		item:setMainSpriteRotation(rotation)
	end

	local action_move = CCMoveTo:create(0.15, self:getBasePosition(self.x, self.y))	--0.3
	local action_callback = CCCallFunc:create(animationCallback)
	item:runAction(CCSequence:createWithTwoActions(action_move, action_callback))
	GamePlayMusicPlayer:playEffect( GameMusicType.kPlaySnailMove )
end

function ItemView:playSnailDisappearAnimation( callback )
	-- body
	local item = self.itemSprite[ItemSpriteType.kSnailMove]
	self.itemSprite[ItemSpriteType.kSnailMove] = nil
	local function animationCallback( ... )
		-- body
		if item then item:removeFromParentAndCleanup(true) end
		if callback then callback() end
	end
	if item then 
		item:playDestroyAnimation(animationCallback)
		item:setScaleX(1)
		item:setRotation(0)
		GamePlayMusicPlayer:playEffect( GameMusicType.kPlaySnailOut )
	else
		if callback then callback() end
	end
end

function ItemView:changToSnail( direction, callback )
	-- body
	self:cleanGameItemView()
	self:buildSnail(direction)
	local item = self.itemSprite[ItemSpriteType.kSnail]
	self.isNeedUpdate = true
	if item then item:playOutShellAnimation(callback) end
end

function ItemView:changeToRabbit(color,level,callback)
	
	self:cleanGameItemView()
	self:buildRabbit(color, level)
	local item = self.itemSprite[ItemSpriteType.kItemShow]
		self.isNeedUpdate = true
	local function localCallback()
		callback()
	end
	if item then if _G.isLocalDevelopMode then printx(0, '***** changeToRabbit') end item:playUpAnimation(localCallback, true) end
end

function ItemView:playBirdShiftToAnim(destPos, callback)
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	local toPos = self:getBasePosition(destPos.c, destPos.r)
	local moveTo = CCSequence:createWithTwoActions(CCMoveTo:create(0.1, ccp(toPos.x, toPos.y)), CCCallFunc:create(callback))
	sprite:runAction(moveTo)
end

function ItemView:getTransItemCopy()
	local container = Sprite:createEmpty()
	container.items = {}
	for k, v in pairs(needTransLayer) do
		local item = self.itemSprite[v]
		if item then
			container.items[v] = item
			item:removeFromParentAndCleanup(false)
			self.itemSprite[v] = nil
			item:setPosition(ccp(0,0))
			container:addChild(item)
		end 
	end
	return container
end

function ItemView:getTransContainer()
	if self.transContainer:getParent() then
		self.transContainer:removeFromParentAndCleanup(false)
	end
	return self.transContainer
end

--头部直接从自己的transClipping里面去取sprite
function ItemView:reinitTransHeadByLogic(gameItemData, boardData)
	-- transContainer留给下一个Item用。。。
	if self.itemSprite[ItemSpriteType.kItemShow] then
		if self.transContainer then self.transContainer:removeFromParentAndCleanup(false) end 
		self.itemSprite[ItemSpriteType.kItemShow] = nil -- 删除引用
	end
	-- 留下container，其他的删除
	self.transClippingContainer:removeFromParentAndCleanup(false)
	self.itemSprite[ItemSpriteType.kTransClipping]:removeFromParentAndCleanup(true)
	self.itemSprite[ItemSpriteType.kTransClipping] = nil
	self.transClippingNode = nil
	-- 重建sprite
	for k, v in pairs(self.transClippingContainer.items) do
		v:removeFromParentAndCleanup(false)
		self.itemSprite[k] = v
	end
	self.transClippingContainer:dispose()
	self.transClippingContainer = nil

	self:initPosBoardDataPos(gameItemData, true)
	self.isNeedUpdate = true
end

-- function ItemView:addTileMoveAnimation(animation)
-- 	self.getContainer(ItemSpriteType.kTileMove):addChild(animation)
-- end

function ItemView:playTileMoveAnimation(transContainer, moveDataList, onMoveFinishCallback)
	if not self.boardViewTransContainer then
		-- 保存已有的视图
		self.boardViewTransContainer = self:copyBoardTransData()
	end

	if transContainer then
		if transContainer and transContainer.datas then
			self:copyDatasFrom(transContainer.datas)
		end
		if moveDataList and #moveDataList > 0 then
			local startPos = moveDataList[1].pos

			local actionsCount = 0
			for k, v in pairs(transContainer.items) do
				v:removeFromParentAndCleanup(false)
				local container = self.getContainer(k)
				if container then
					local offsetX, offsetY = 0, 0
					if k == ItemSpriteType.kPass or table.exist(needUpdateLayers, k) then
						local itemPosOffset = self.itemPosAdd[k]
						if itemPosOffset then
							offsetX = itemPosOffset.x
							offsetY = itemPosOffset.y
						else
							if k == ItemSpriteType.kBigMonster or k == ItemSpriteType.kWeeklyBoss or k == ItemSpriteType.kMoleBossCloud then
								offsetX = 0.5 * self.w
								offsetY = -0.5 * self.h
							end
						end
					end
					v:setPosition(ccp(startPos.x + offsetX, startPos.y + offsetY))
					container:addChild(v)
				end
				self.itemSprite[k] = v
				-- 移动
				local seq = CCArray:create()
				local prePos = nil
				for _, move in ipairs(moveDataList) do
					if prePos then 

						local adjust = 1
						if CrashResumeGamePlaySpeedUp and GamePlayConfig_replayAdjustValue then
							--adjust = GamePlayConfig_replayAdjustValue
						end
						--seq:addObject(CCMoveBy:create(move.time, ccp(move.pos.x - prePos.x, move.pos.y - prePos.y)))
						seq:addObject(CCMoveBy:create( move.time / adjust , ccp(move.pos.x - prePos.x, move.pos.y - prePos.y)))
					end
					prePos = move.pos
				end
				local moveEnded = false
				local function onMoveEnd()
					if not moveEnded then
						moveEnded = true
						if onMoveFinishCallback then onMoveFinishCallback() end
					end
					-- actionsCount = actionsCount - 1
					-- if actionsCount == 0 then
					-- 	if onMoveFinishCallback then onMoveFinishCallback() end
					-- end
				end
				seq:addObject(CCCallFunc:create(onMoveEnd))

				actionsCount = actionsCount + 1
				v:runAction(CCSequence:create(seq))
			end
		end
		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayMovetileMove )
	else
		if onMoveFinishCallback then onMoveFinishCallback() end
	end
end

function ItemView:reinitBoardViews(gameItemData, boardData, transContainer)
	if not self.boardViewTransContainer then
		-- 保存已有的视图
		self.boardViewTransContainer = self:copyBoardTransData()
	end

	for k, v in pairs(transContainer.items) do
		v:removeFromParentAndCleanup(false)
		local container = self.getContainer(k)
		if container then
			v:setPosition(self:getBasePosition(self.x, self.y))
			container:addChild(v)
		end
		self.itemSprite[k] = v
	end

	self:initPosBoardDataPos(gameItemData, true)

	self.isNeedUpdate = true
end

-- 其他的item要从上一个itemView的transContainer去拿sprite
function ItemView:reinitTransRoadByLogic(gameItemData, boardData, transContainer)
	-- transContainer原本是放在ItemShow的，摘下来保留
	if self.itemSprite[ItemSpriteType.kItemShow] then
		self.transContainer:removeFromParentAndCleanup(false)
		self.itemSprite[ItemSpriteType.kItemShow] = nil
	end

	-- 在这个函数中，只有kEnd才会有transClippingContainer
	if self.transClippingContainer1 then
		self.transClippingNode:removeFromParentAndCleanup(true)
		self.transClippingContainer1 = nil
		self.transClippingNode = nil
		self.itemSprite[ItemSpriteType.kTransClipping] = nil
	end

	-- 重建sprite

	for k, v in pairs(transContainer.items) do
		v:removeFromParentAndCleanup(false)
		self.itemSprite[k] = v
	end

	transContainer:dispose()

	self:initPosBoardDataPos(gameItemData, true)
	self.isNeedUpdate = true
end

function ItemView:buildTransmisson(boardData)
	local image, rotation, scale
	local transType = boardData.transType

	if transType == TransmissionType.kRoad
	or transType == TransmissionType.kStart
	or transType == TransmissionType.kEnd 
	or transType == TransmissionType.kSingleTile then
		image = 'trans_road_0000'
		rotation = (boardData.transDirect - 1) * 90
		scale = 1
	else
		image = 'trans_corner_0000'
		if transType == TransmissionType.kCorner_UR then
			rotation = 0
			scale = 1
		elseif transType == TransmissionType.kCorner_RD then
			rotation = 90
			scale = 1
		elseif transType == TransmissionType.kCorner_DL then
			rotation = 180
			scale = 1
		elseif transType == TransmissionType.kCorner_LU then
			rotation = 270
			scale = 1
		elseif transType == TransmissionType.kCorner_LD then
			rotation = 270
			scale = -1
		elseif transType == TransmissionType.kCorner_DR then
			rotation = 180
			scale = -1
		elseif transType == TransmissionType.kCorner_RU then
			rotation = 90
			scale = -1
		elseif transType == TransmissionType.kCorner_UL then
			rotation = 0
			scale = -1
		end
	end


	local board = Sprite:createWithSpriteFrameName(image)
	board:setRotation(rotation)
	board:setScaleX(scale)
	self.itemSprite[ItemSpriteType.kTileBlocker] = board

	if boardData.transType >= TransmissionType.kStart then
		if type(boardData.transColor) == "table" then 
			if boardData.transType == TransmissionType.kSingleTile then 
				self.itemSprite[ItemSpriteType.kTransmissionDoorIn] = TileTransDoor:create(boardData.transColor.startColor, TransmissionType.kStart, boardData.transDirect)
				self.itemSprite[ItemSpriteType.kTransmissionDoor] = TileTransDoor:create(boardData.transColor.endColor, TransmissionType.kEnd, boardData.transDirect)
			else
				self.itemSprite[ItemSpriteType.kTransmissionDoorIn] = TileTransDoor:create(boardData.transColor.startColor, TransmissionType.kStart, boardData.transDirect)
			end
		else
			self.itemSprite[ItemSpriteType.kTransmissionDoor] = TileTransDoor:create(boardData.transColor, boardData.transType, boardData.transDirect)
		end 
	end

end

function ItemView:createTransClippingSprite(itemData, boardData)
	local container = Sprite:createEmpty()
	container.items = {}

	if boardData.colorFilterState == ColorFilterState.kStateA or boardData.colorFilterState == ColorFilterState.kStateB then 
		local colorFilterA = TileColorFilterA:create(boardData.colorFilterColor)
		if colorFilterA then
			container:addChild(colorFilterA)
			container.items[ItemSpriteType.kColorFilterA] = colorFilterA
		end
	end

	if boardData.superCuteState == GameItemSuperCuteBallState.kInactive then
		local cuteBall = TileSuperCuteBall:create(boardData.superCuteState)
		container:addChild(cuteBall)
		container.items[ItemSpriteType.kSuperCuteLowLevel] = cuteBall
	end

	if boardData.sandLevel > 0 then
		local sprite = ItemViewUtils:buildSand(boardData.sandLevel)
		container:addChild(sprite)
		container.items[ItemSpriteType.kSand] = sprite
	end

	if boardData.iceLevel > 0 then		 --冰
		local ice = ItemViewUtils:buildLight(boardData.iceLevel, boardData.gameModeId)
		container:addChild(ice)
		container.items[ItemSpriteType.kLight] = ice
	end

	if boardData.lotusLevel > 0 then		 --草地（荷叶）底层
		--local bottom = self:createLotusAnimation(boardData.lotusLevel , "in" , "bottom" , true)
		local bottom = TileLotus:create(boardData.lotusLevel , "in" , "bottom" , true)
		container:addChild(bottom)
		container.items[ItemSpriteType.kLotus_bottom] = bottom
	end

	if boardData.blockerCoverMaterialLevel > 0 or  boardData.blockerCoverMaterialLevel == -1 then	
		local tileBlockerCoverMaterial = TileBlockerCoverMaterial:create(boardData.blockerCoverMaterialLevel)
		if tileBlockerCoverMaterial then
			container:addChild(tileBlockerCoverMaterial)
			container.items[ItemSpriteType.kBlockerCoverMaterial] = tileBlockerCoverMaterial
		end
	end

	--果酱传送带开始结束的创建
	if boardData.isJamSperad then	
		local JamSperad = self:buildJamSperad( true )
		if JamSperad then
			container:addChild(JamSperad)
			container.items[ItemSpriteType.kJamSperad] = JamSperad
		end
	end

	local itemSprite = nil
	local layer = nil
	local isOnlyGetSprite = true
	if itemData.ItemType == GameItemType.kAnimal then
		itemSprite = self:buildNewAnimalItem(itemData._encrypt.ItemColorType, itemData.ItemSpecialType, false, false, itemData.hasActCollection)
		if AnimalTypeConfig.isSpecialTypeValid(itemData.ItemSpecialType) then
			layer = ItemSpriteType.kItemShow
		else			
			layer = ItemSpriteType.kItem
		end
	elseif itemData.ItemType == GameItemType.kSnow then	--雪
		itemSprite = ItemViewUtils:buildSnow(itemData.snowLevel)
		layer = ItemSpriteType.kItem
	elseif itemData.ItemType == GameItemType.kCrystal then	--由系统统一计算
		itemSprite = ItemViewUtils:buildCrystal(itemData._encrypt.ItemColorType, itemData.hasActCollection)               ------水晶
		layer = ItemSpriteType.kItem
	elseif itemData.ItemType == GameItemType.kGift then		--由系统统一计算
		itemSprite = ItemViewUtils:buildGift(itemData._encrypt.ItemColorType)
		layer = ItemSpriteType.kItem
	elseif itemData.ItemType == GameItemType.kNewGift then		--由系统统一计算
		itemSprite = ItemViewUtils:buildGift(itemData._encrypt.ItemColorType)
		layer = ItemSpriteType.kItem
	elseif itemData.ItemType == GameItemType.kIngredient then
		itemSprite = ItemViewUtils:buildBeanpod(itemData.showType)
		layer = ItemSpriteType.kItem
	elseif itemData.ItemType == GameItemType.kVenom then
		itemSprite = TileVenom:create()
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kCoin then
		itemSprite = self:buildCoin(true)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kRoost then
		itemSprite =TileRoost:create(itemData.roostLevel)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kBalloon then
		itemSprite = TileBalloon:create(itemData._encrypt.ItemColorType, itemData.balloonFrom, itemData.balloonConstantPlayAlert)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kDigGround then        ----------挖地障碍 地块 宝石块
		itemSprite = self:buildDigGround(itemData.digGroundLevel, isOnlyGetSprite)
		layer = ItemSpriteType.kDigBlocker
	elseif itemData.ItemType == GameItemType.kDigJewel then 
		itemSprite = self:buildDigJewel(itemData.digJewelLevel, self.context.levelType, isOnlyGetSprite)
		layer = ItemSpriteType.kDigBlocker
	elseif itemData.ItemType == GameItemType.kBottleBlocker then
		itemSprite = self:buildBottleBlocker(itemData.bottleLevel , itemData._encrypt.ItemColorType , nil , true)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kAddMove then
		itemSprite = self:buildAddMove(itemData._encrypt.ItemColorType, itemData.numAddMove, isOnlyGetSprite)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kPoisonBottle then 
		itemSprite = self:buildPoisonBottle(itemData.forbiddenLevel, isOnlyGetSprite)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kBigMonster then 
		-- self:buildMonster()                                        --not support
	elseif itemData.ItemType == GameItemType.kBlackCuteBall then 
		itemSprite = self:buildBlackCuteBall(itemData.blackCuteStrength, itemData.blackCuteMaxStrength, isOnlyGetSprite)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kMimosa then
		itemSprite = self:buildMimosa(itemData, isOnlyGetSprite)
		layer = ItemSpriteType.kItemShow
	elseif itemData.isSnail then
		-- self:buildSnail(itemData.snailRoadType)                    --not support
	elseif itemData.bossLevel and itemData.bossLevel > 0 then 
		-- self:buildBoss(itemData)                                    --not support
	elseif itemData.ItemType == GameItemType.kRabbit then
		itemSprite = self:buildRabbit(itemData._encrypt.ItemColorType, itemData.rabbitLevel, false, isOnlyGetSprite)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kHoneyBottle then
		itemSprite = TileHoneyBottle:create(itemData.honeyBottleLevel)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kAddTime then
		itemSprite = self:buildAddTime(itemData._encrypt.ItemColorType, itemData.addTime, isOnlyGetSprite)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kQuestionMark then
		itemSprite = ItemViewUtils:createQuestionMark(itemData._encrypt.ItemColorType)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kMagicLamp then
		itemSprite = TileMagicLamp:create(itemData._encrypt.ItemColorType, itemData.lampLevel)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kWukong then
		itemSprite = TileWukong:create(itemData._encrypt.ItemColorType, itemData.wukongProgressCurr)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kDrip then
		itemSprite = self:buildDrip(true)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kPuffer then
		itemSprite = self:buildPuffer(true , itemData.pufferState)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kBuffBoom then
		itemSprite = self:buildBuffBoom( itemData , true )
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kSuperBlocker then
		itemSprite = TileSuperBlocker:create(self.context.theGamePlayType)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kMagicStone then
		itemSprite = TileMagicStone:create(itemData.magicStoneLevel, itemData.magicStoneDir)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kRocket then
		itemSprite = self:buildRocket(itemData._encrypt.ItemColorType, true)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kCrystalStone then
		itemSprite = self:buildCrystalStone(itemData._encrypt.ItemColorType, itemData.crystalStoneEnergy, itemData.crystalStoneBombType, true)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kTotems then
		itemSprite = self:buildTotems(itemData._encrypt.ItemColorType, itemData:isActiveTotems(), true)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kMissile then
		itemSprite = self:buildMissile(itemData,true)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kRandomProp then
		itemSprite = self:buildRandomProp(itemData,true)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kBlocker195 then
		itemSprite = self:buildBlocker195(itemData, true)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kBlocker199 then
		itemSprite = self:buildBlocker199(itemData, true)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kChameleon then
		itemSprite = self:buildChameleon(itemData, true)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kBlocker207 then
		itemSprite = self:buildBlocker207(true)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kPacman then
		itemSprite = self:buildPacman(itemData, true)
		layer = ItemSpriteType.kPacmanShow
	elseif itemData.ItemType == GameItemType.kPacmansDen then 
		itemSprite = self:buildPacmansDen(true)
		layer = ItemSpriteType.kPacmanShow
	elseif itemData.ItemType == GameItemType.kBlocker211 then
		itemSprite = self:buildBlocker211(itemData, true)
		layer = ItemSpriteType.kItemShow
    elseif itemData.ItemType == GameItemType.kTurret then
		itemSprite = self:buildTurret(itemData.turretDir, itemData.turretIsTypeRandom, itemData.turretLevel, itemData.turretIsSuper, true)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kMoleBossSeed then
		itemSprite = self:buildMoleBossSeed(itemData.moleBossSeedCountDown, true)
		layer = ItemSpriteType.kMoleWeeklyItemShow
    elseif itemData.ItemType == GameItemType.kYellowDiamondGrass then 
		itemSprite = self:buildYellowDiamond(itemData.yellowDiamondLevel, isOnlyGetSprite)
		layer = ItemSpriteType.kDigBlocker
	elseif itemData.ItemType == GameItemType.kScoreBuffBottle then
		itemSprite = self:buildScoreBuffBottle(itemData, true)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kSunFlask then
		itemSprite = self:buildSunFlask(itemData.sunFlaskLevel, true)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kSunflower then
		itemSprite = self:buildSunflower(true)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kFirecracker then
		itemSprite = self:buildFirecracker(itemData, true)
		layer = ItemSpriteType.kItemShow
	elseif itemData.ItemType == GameItemType.kSquid then
		itemSprite = self:buildSquid(itemData, true)
		layer = ItemSpriteType.kSquidShow
    elseif itemData.ItemType == GameItemType.kWanSheng then
		itemSprite = self:buildWanSheng(itemData, true)
		layer = ItemSpriteType.kItemShow
	end

	if itemSprite then
		itemSprite:setPositionXY(0,0)
		container:addChild(itemSprite)
		container.items[layer] = itemSprite
	end

	--附加属性
	if itemData:hasFurball() then
		local sprite = ItemViewUtils:buildFurball(itemData.furballType)
		container:addChild(sprite)
		container.items[ItemSpriteType.kFurBall] = sprite
	end

	if itemData.cageLevel > 0 then
		local sprite = ItemViewUtils:buildLocker(itemData.cageLevel)
		container:addChild(sprite)	
		container.items[ItemSpriteType.kLock] = sprite
	end

	if itemData.honeyLevel > 0 then
		local honey = TileHoney:create(itemData.honeyLevel)
		honey:normal()
		container:addChild(honey)
		container.items[ItemSpriteType.kHoney] = honey
	end

	if boardData.lotusLevel > 0 then		 --草地（荷叶）顶层
		--local top = self:createLotusAnimation(boardData.lotusLevel , "in" , "top" , true)
		local top = TileLotus:create(boardData.lotusLevel , "in" , "top" , true)
		if top then
			container:addChild(top)
			container.items[ItemSpriteType.kLotus_top] = top
		else
			printx( 1 , "   createLotusAnimation ERROR !!!!!!!!!!!!!!!!!!!!!!!!!!!!    " , boardData.lotusLevel , "in" , "top")
		end
	end

	if itemData.blockerCoverLevel > 0 then
		local blockerCover = TileBlockerCover:create(itemData.blockerCoverLevel , true)
		if blockerCover then
			container:addChild(blockerCover)
			container.items[ItemSpriteType.kBlockerCover] = blockerCover
		end
	end

	if boardData.superCuteState == GameItemSuperCuteBallState.kActive then
		local cuteBall = TileSuperCuteBall:create(boardData.superCuteState)
		container:addChild(cuteBall)
		container.items[ItemSpriteType.kSuperCuteHighLevel] = cuteBall
	end

	if boardData.colorFilterBLevel > 0 then
		local texture
		if self.getContainer(ItemSpriteType.kColorFilterB) then 
			texture = self.getContainer(ItemSpriteType.kColorFilterB).refCocosObj:getTexture()
		end
		local colorFilterB = TileColorFilterB:create(texture, boardData.colorFilterColor, boardData.colorFilterBLevel)
		if colorFilterB then
			container:addChild(colorFilterB)
			container.items[ItemSpriteType.kColorFilterB] = colorFilterB
		end
	end

	if itemData:hasBlocker206() then
		local sprite = self:buildBlocker206( true , itemData )
		container:addChild(sprite)	
		container.items[ItemSpriteType.kLock206Show] = sprite
	end

	if itemData:seizedByGhost() then
		local isActiveGhost = itemData.ghostPaceLength > 0
		local ghost = TileGhost:create(isActiveGhost)
		container:addChild(ghost)
		container.items[ItemSpriteType.kGhost] = ghost
	end

	return container
end

function ItemView:removeAllChildOfTransClippingSprite()
	if self.itemSprite[ItemSpriteType.kTransClipping] then
		self.itemSprite[ItemSpriteType.kTransClipping]:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kTransClipping] = nil
		self.transClippingNode = nil
	end
end

function ItemView:buildTransmissonClippingNode()
	local pos = self:getBasePosition(self.x, self.y)
	local clippingnode = SimpleClippingNode:create()
	clippingnode:setContentSize(CCSizeMake(self.w, self.h))
	clippingnode:setPosition(ccp(pos.x - self.w/2, pos.y - self.h/2))
	self.transClippingNode = clippingnode
end

function ItemView:addSpriteToTransClippingNode(theSprite, transType)
	if transType and transType == TransmissionType.kSingleTile then 
		if not self.transClippingNode then
			self:buildTransmissonClippingNode()
		end
	else
		self:buildTransmissonClippingNode()
	end
	self.itemSprite[ItemSpriteType.kTransClipping] = self.transClippingNode
	if theSprite ~= nil then
		if theSprite:getParent() then theSprite:removeFromParentAndCleanup(false) end
		theSprite:setPositionXY(self.w/2, self.h/2)
		self.transClippingNode:addChild(theSprite)
	end
end

function ItemView:roadTransToNext(dp, isCorner, callback)
	local container = self:getTransItemCopy()
	self.transContainer = container
	local function moveCallback()
		if callback then callback() end
	end
	self.itemSprite[ItemSpriteType.kItemShow] = container
	container:setPosition(self:getBasePosition(self.x, self.y))
	local action = CCSequence:createWithTwoActions(CCMoveBy:create(GamePlayConfig_Transmission_Time, dp), CCCallFunc:create(moveCallback))
	container:runAction(action)
	local bg = self.itemSprite[ItemSpriteType.kTileBlocker]
	if bg then 
		local image
		if isCorner then
			image = 'trans_corner_%04d'
		else
			image = 'trans_road_%04d'
		end
		local anim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames(image, 0, 24), 1/30)
		bg:play(anim, 0, 1)
	end
	self.isNeedUpdate = true
end

function ItemView:tailTransToOut(itemData, boardData, dp, transType, callback)
	local function moveCallback()
		if callback then callback() end
	end
	local tempSprite = self:getTransItemCopy()
	self.transClippingContainer1 = tempSprite
	self:addSpriteToTransClippingNode(tempSprite, transType)
	tempSprite:runAction(CCSequence:createWithTwoActions(CCMoveBy:create(GamePlayConfig_Transmission_Time,dp), CCCallFunc:create(moveCallback)))
	self.isNeedUpdate = true

	local bg = self.itemSprite[ItemSpriteType.kTileBlocker]
	if bg then 
		local image = 'trans_road_%04d'
		local anim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames(image, 0, 24), 1/30)
		bg:play(anim, 0, 1)
	end

	local transDoor = self.itemSprite[ItemSpriteType.kTransmissionDoor]
	if transDoor then
		transDoor:playTransAnimation()
	end
end

function ItemView:headTransToIn(itemData, boardData, dp, toTransType, callback)
	local function moveCallback()
		if callback then callback() end
	end
	local tempSprite = self:createTransClippingSprite(itemData, boardData)
	self.transClippingContainer = tempSprite
	self:addSpriteToTransClippingNode(tempSprite, toTransType)
	local pos = tempSprite:getPosition()

	tempSprite:setPosition(ccp(pos.x - dp.x, pos.y - dp.y))
	tempSprite:runAction(CCSequence:createWithTwoActions(CCMoveBy:create(GamePlayConfig_Transmission_Time,dp), CCCallFunc:create(moveCallback)))
	self.isNeedUpdate = true
end

-- 开局时动物从小放大的时间
local startScaleTime = 0.2
-- 在游戏开局时动物从小到大变化
function ItemView:animalStartTimeScale()
	local item, itemBack, itemShow = self.itemSprite[ItemSpriteType.kItem], self.itemSprite[ItemSpriteType.kItemBack], self.itemSprite[ItemSpriteType.kItemShow]
	if item then
		item:setScale(0)
		item:runAction(CCScaleTo:create(startScaleTime, 1))
	end
	if itemBack then
		itemBack:setScale(0)
		item:runAction(CCScaleTo:create(startScaleTime, 1))
	end
	if itemShow then
		itemShow:setScale(0)
		itemShow:runAction(CCScaleTo:create(startScaleTime, 1))
	end
end

function ItemView:gainFocus()
end

function ItemView:lostFocus()
end

function ItemView:buildBiscuit( biscuitData )
	self.itemSprite[ItemSpriteType.kBiscuit] = TileBiscuit:create(biscuitData, self.w, self.h)
	local pos = self:getBasePosition(self.x, self.y)
	self.itemSprite[ItemSpriteType.kBiscuit]:setPositionXY(
		pos.x + self.itemPosAdd[ItemSpriteType.kBiscuit].x, 
		pos.y + self.itemPosAdd[ItemSpriteType.kBiscuit].y
	)
	self.isNeedUpdate = true
end

function ItemView:playBicsuitCollectAnim( callback )
	if self.itemSprite[ItemSpriteType.kBiscuit] then

		self.itemSprite[ItemSpriteType.kBiscuit]:runAction(CCSequence:createWithTwoActions(
			CCScaleTo:create(4 / 30, 0.362, 0.362),
			CCCallFunc:create(function ( ... )
				self:clearBiscuit()
				if callback then callback() end
			end)
		))
	end
end

function ItemView:clearBiscuit( ... )
	-- body
	if self.itemSprite[ItemSpriteType.kBiscuit] then
		self.itemSprite[ItemSpriteType.kBiscuit]:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kBiscuit] = nil
		self.isNeedUpdate = true
	end
end

function ItemView:playUpgradeBiscuitAnim(biscuitData, newLevel )
	if self.itemSprite[ItemSpriteType.kBiscuit] then
		self.itemSprite[ItemSpriteType.kBiscuit]:playUpgradeBiscuitAnim(
			biscuitData, 
			newLevel, 
			self.getContainer(ItemSpriteType.kBlockerCommonEffect)
		)
	end
end

-- function ItemView:updateBiscuit(biscuitData)
-- 	-- body
-- 	if self.itemSprite[ItemSpriteType.kBiscuit] then
-- 		self.itemSprite[ItemSpriteType.kBiscuit]:removeFromParentAndCleanup(true)
-- 		self.itemSprite[ItemSpriteType.kBiscuit] = nil
-- 	end
-- 	self:buildBiscuit(biscuitData)
-- end

function ItemView:playAppkyMilkAnim(biscuitData, milkRow, milkCol )
	self.itemSprite[ItemSpriteType.kBiscuit]:playAppkyMilkAnim(biscuitData, milkRow, milkCol)
end

function ItemView:buildSeaAnimal(seaAnimalType)
	local rotation = 0
	local anchorPoint = ccp(0, 0)
	local image = 'sea_animal_penguin_0000'
	local pos = self:getBasePosition(self.x, self.y)
    local NumberLayer = nil

    --根据关卡类型不同创建不用更多海洋生物
    local CurLevelType = 0
    local mainLogic = GameBoardLogic:getCurrentLogic()
	if mainLogic then
        local levelID = mainLogic.level
        CurLevelType = LevelType:getLevelTypeByLevelId( levelID )
    end

	if seaAnimalType == SeaAnimalType.kPenguin then
		rotation = 0
		anchorPoint = ccp(1/2, 3/4)
		image = 'sea_animal_penguin_0000'
	elseif seaAnimalType == SeaAnimalType.kPenguin_H then
		rotation = -90
		anchorPoint = ccp(1/2, 3/4)
		image = 'sea_animal_penguin_0000'
	elseif seaAnimalType == SeaAnimalType.kSeal then
		rotation = 0
		anchorPoint = ccp(1/6, 3/4)
		image = 'sea_animal_seal_0000'
	elseif seaAnimalType == SeaAnimalType.kSeal_V then
		rotation = 90
		anchorPoint = ccp(1/6, 1/4)
		image = 'sea_animal_seal_0000'
	elseif seaAnimalType == SeaAnimalType.kSeaBear then
		rotation = 0
		anchorPoint = ccp(1/6, 5/6)
		image = 'sea_animal_bear_0000'
	elseif seaAnimalType == SeaAnimalType.kSea_3_3 then
		rotation = 0
		anchorPoint = ccp(1/6, 5/6)
		image = "sea_animal_fish33_0000"

        --3*3可获得鱼的数量
        NumberLayer = Sprite:createEmpty()

        local num1 = 0
        local num2 = 0

        local label1Pos = ccp(41+30/0.7,39+12/0.7)
        local label2Pos = ccp(80+30/0.7,39+12/0.7)

        local label1 = Sprite:createWithSpriteFrameName("sea_animal_wenhao")
        label1:setPosition( label1Pos )
        label1:setAnchorPoint(ccp(0.5, 0.5))
        NumberLayer:addChildAt( label1, 1)

        local label2 = Sprite:createWithSpriteFrameName("sea_animal_wenhao")
        label2:setPosition( label2Pos )
        label2:setAnchorPoint(ccp(0.5, 0.5))
        NumberLayer:addChildAt( label2, 2 )

	elseif seaAnimalType == SeaAnimalType.kMistletoe then

         if CurLevelType == GameLevelType.kSummerFish then
            rotation = 0
            anchorPoint = ccp(1/2,1/2)
		    image = "sea_animal_fish_0000"
        else
		    anchorPoint = ccp(1/2,1/2)
		    image = "sea_animal_4_0000"
        end
	elseif seaAnimalType == SeaAnimalType.kElk then

         if CurLevelType == GameLevelType.kSummerFish then
            rotation = 0
            anchorPoint = ccp(1/4,3/4)
		    image = "sea_animal_fish22_0000"
        else
		    anchorPoint = ccp(1/4,3/4)
		    image = "sea_animal_6_0000"
        end
	elseif seaAnimalType == SeaAnimalType.kScarf_H then

         if CurLevelType == GameLevelType.kSummerFish then
            rotation = 0
            anchorPoint = ccp(1/4,1/2)
		    image = "sea_animal_fish12_0000"
        else
		    rotation = -90
		    anchorPoint = ccp(1/2,3/4)
		    image = "sea_animal_5_0000"
        end
	elseif seaAnimalType == SeaAnimalType.kScarf_V then

         if CurLevelType == GameLevelType.kSummerFish then
            rotation = 0
            anchorPoint = ccp(1/2,3/4)
		    image = "sea_animal_fish21_0000"
        else
		    anchorPoint = ccp(1/2,3/4)
		    image = "sea_animal_5_0000"
        end
	end


	local sprite = Sprite:createWithSpriteFrameName(image)
	sprite:setAnchorPoint(anchorPoint)
	sprite:setRotation(rotation)
	sprite:setPosition(pos)
	self.itemSprite[ItemSpriteType.kSeaAnimal] = sprite

    if NumberLayer then
        NumberLayer:setTexture(sprite.refCocosObj:getTexture())
        sprite:addChild( NumberLayer )
    end
end

function ItemView:clearSeaAnimal()
	local sprite = self.itemSprite[ItemSpriteType.kSeaAnimal]
	if sprite then
		sprite:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kSeaAnimal] = nil
	end
end

function ItemView:setMagicLampLevel(level, color, callback)
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if level == 0 then
		sprite:playReinit(color, callback)
	elseif level >= 1 and level <= 4 then
		sprite:playLevel(level, 0)
		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayLampMatch )
	elseif level == 5 then
		sprite:playBeforeCast()
		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayLampCasting )
	elseif level == 6 then
		sprite:playCasting()
	end
end

function ItemView:explodeGoldZongZi(callback)
	local sprite = self.itemSprite[ItemSpriteType.kDigBlocker]
	if sprite then
		sprite:explodeGoldZongZi(callback)
	end
end


function ItemView:buildSuperBlocker()
	local sprite = TileSuperBlocker:create(self.context.theGamePlayType)
	local pos = self:getBasePosition(self.x, self.y)
	sprite:setPosition(pos)
	self.itemSprite[ItemSpriteType.kItemShow] = sprite
end

function ItemView:buildHoneyBottle( level )
	-- body
	local sprite = TileHoneyBottle:create(level)
	self.itemSprite[ItemSpriteType.kItemShow] = sprite
end

function ItemView:playHoneyBottleDec( times )
	-- body
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite then
		sprite:playIncreaseAnimation(times)
		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayHoneybottleMatch )
	end
end

function ItemView:playHoneyBottleBroken( callback )
	-- body
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	local function animationCallback()
		if sprite then sprite:removeFromParentAndCleanup(true) end
		self.itemSprite[ItemSpriteType.kItemShow] = nil
		if callback then callback() end
	end

	if sprite then
		sprite:playBrokenAnimation(animationCallback)
		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayHoneybottleCasting )
	end
end

function ItemView:playBeInfectAnimation( fromPos, callback, honeyLevel)
	-- body
	local flyAnimation = nil

	local function finishCallback( ... )
		-- body
		local honey = self.itemSprite[ItemSpriteType.kHoney]
		self.isNeedUpdate = true
		if honey then honey:normal() end
	end

	local function flyCallback()
		-- body
		if flyAnimation then flyAnimation:removeFromParentAndCleanup(true) end
		self.itemSprite[ItemSpriteType.kSpecial] = nil
		local honey = TileHoney:create(honeyLevel)
		honey:setPosition(self:getBasePosition(self.x, self.y))
		honey:add(finishCallback)
		self.itemSprite[ItemSpriteType.kHoney] = honey
		if callback then callback() end
		self.isNeedUpdate = true
	end
	
	flyAnimation= TileHoney:createFlyAnimation(fromPos, self:getBasePosition(self.x, self.y),  flyCallback)
	self.itemSprite[ItemSpriteType.kSpecial] = flyAnimation
	self.isNeedUpdate = true
end

function ItemView:addHoneyWithAnimation(honeyLevel, callback)
	local honeyEffect = TileHoney:create(honeyLevel)
	local function animationCallback( ... )
		if honeyEffect then honeyEffect:removeFromParentAndCleanup(true) end
		self.itemSprite[ItemSpriteType.kNormalEffect] = nil
		if callback then callback() end
	end
	honeyEffect:setPosition(self:getBasePosition(self.x, self.y))
	honeyEffect:add(animationCallback)
	self.itemSprite[ItemSpriteType.kNormalEffect] = honeyEffect

	self.isNeedUpdate = true
end

function ItemView:buildHoney( honeyLevel )
	-- body
	local honey = TileHoney:create(honeyLevel)
	honey:normal()
	self.itemSprite[ItemSpriteType.kHoney] = honey
end

function ItemView:playHoneyDec(honeyLevel, callback)
	-- body
	local honeyEffect = TileHoney:create(honeyLevel)
	local function animationCallback( ... )
		-- body
		if honeyEffect then honeyEffect:removeFromParentAndCleanup(true) end
		self.itemSprite[ItemSpriteType.kNormalEffect] = nil
		if callback then callback() end
	end
	honeyEffect:setPosition(self:getBasePosition(self.x, self.y))
	honeyEffect:disappear(animationCallback)
	GamePlayMusicPlayer:playEffect( GameMusicType.kPlayPoisonClear )
	--setTimeOut( function () GamePlayMusicPlayer:playEffect( GameMusicType.kPlayHoneyClear ) end , 1 )
	self.itemSprite[ItemSpriteType.kNormalEffect] = honeyEffect

	local sprite = self.itemSprite[ItemSpriteType.kHoney]
	if sprite then sprite:removeFromParentAndCleanup(true) end
	self.itemSprite[ItemSpriteType.kHoney] = nil
	self.isNeedUpdate = true
end

function ItemView:buildWukongTarget(data)
	local sprite = TileWukongTarget:create()
	if self.itemSprite[ItemSpriteType.kTileBlocker] and self.itemSprite[ItemSpriteType.kTileBlocker]:getParent() then
		self.itemSprite[ItemSpriteType.kTileBlocker]:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kTileBlocker] = nil
	end
	self.itemSprite[ItemSpriteType.kTileBlocker] = sprite
end

function ItemView:setWukongTargetLightVisible(direction , visible)
	local sprite = self.itemSprite[ItemSpriteType.kTileBlocker]
	if sprite then
		sprite:setLightVisible(direction , visible)
	end
end

function ItemView:playWukongTargetLoopAnimation(animationType)
	local sprite = self.itemSprite[ItemSpriteType.kTileBlocker]
	if sprite then
		sprite:playLoopAnimation(animationType)
	end
end



function ItemView:deleteWukongTarget()
	local sprite = self.itemSprite[ItemSpriteType.kTileBlocker]
	if sprite and sprite:getParent() then
		sprite:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kTileBlocker] = nil
	end
end


function ItemView:buildMagicTile(data)
	local level = data.remainingHit or 1
	local sprite = TileMagicTile:create(level)
	if self.itemSprite[ItemSpriteType.kTileBlocker] and self.itemSprite[ItemSpriteType.kTileBlocker]:getParent() then
		self.itemSprite[ItemSpriteType.kTileBlocker]:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kTileBlocker] = nil
	end
	self.itemSprite[ItemSpriteType.kTileBlocker] = sprite
end

function ItemView:deleteMagicTile()
	if self.itemSprite[ItemSpriteType.kTileBlocker] and self.itemSprite[ItemSpriteType.kTileBlocker]:getParent() then
		local tile = self.itemSprite[ItemSpriteType.kTileBlocker]
		local function onHide()
			self.itemSprite[ItemSpriteType.kTileBlocker]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kTileBlocker] = nil
		end
		tile:playDisappearAnimation(onHide)
	end
end

function ItemView:playMagicTileVanishCountDownAlert()
	if self.itemSprite[ItemSpriteType.kTileBlocker] and self.itemSprite[ItemSpriteType.kTileBlocker]:getParent() then
		local tile = self.itemSprite[ItemSpriteType.kTileBlocker]
		tile:playVanishCountDownAlert()
	end
end

-- function ItemView:addMagicTileWater(data)
-- 	if self.itemSprite[ItemSpriteType.kMagicTileWater] == nil then
-- 		local waterLayer = TileMagicTile:createWaterAnim()
-- 		self.itemSprite[ItemSpriteType.kMagicTileWater] = waterLayer
-- 		self.itemPosAdd[ItemSpriteType.kMagicTileWater] = ccp(0, -24)
-- 	end
-- end

-- function ItemView:removeMagicTileWater()
-- 	if self.itemSprite[ItemSpriteType.kMagicTileWater] and self.itemSprite[ItemSpriteType.kMagicTileWater]:getParent() then
-- 		self.itemSprite[ItemSpriteType.kMagicTileWater]:removeFromParentAndCleanup(true)
-- 		self.itemSprite[ItemSpriteType.kMagicTileWater] = nil
-- 	end
-- end

function ItemView:changeMagicTileColor(color)
	if color == 'red' then
		local sprite = self.itemSprite[ItemSpriteType.kTileBlocker]
		if sprite and sprite.refCocosObj then
			sprite:changeColor('red')
		end
	end
end

function ItemView:clearHalloweenBoss()
	if self.itemSprite[ItemSpriteType.kNormalEffect] and self.itemSprite[ItemSpriteType.kNormalEffect]:getParent() then
		self.itemSprite[ItemSpriteType.kNormalEffect]:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kNormalEffect] = nil
	end
end

function ItemView:addSandView(sandLevel)
	local sprite = ItemViewUtils:buildSand(sandLevel)
	local pos = self:getBasePosition(self.x, self.y)
	sprite:setPosition(pos)
	self.itemSprite[ItemSpriteType.kSand] = sprite
	self.isNeedUpdate = true
end

function ItemView:playSandClean(callback)
	local sprite = self.itemSprite[ItemSpriteType.kSand]
	if sprite then 
		sprite:stopAllActions()
		sprite:removeFromParentAndCleanup(true) 
	end

	local function onAnimationFinished()
		if self.itemSprite[ItemSpriteType.kSand] then
			-- self.itemSprite[ItemSpriteType.kSand]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kSand] = nil
		end
		if callback then callback() end
	end

	local texture
	if self.getContainer(ItemSpriteType.kSand) then 
		texture = self.getContainer(ItemSpriteType.kSand).refCocosObj:getTexture()
	end

	local anim, posOffset = TileSand:buildCleanAnim(onAnimationFinished, texture)
	if not anim then
		if _G.isLocalDevelopMode then printx(0, "build sand clean animation failed~") end
		return
	end
	posOffset = posOffset or {x=0, y=0}
	local basePos = self:getBasePosition(self.x, self.y)
	anim:setPosition(ccp(basePos.x + posOffset.x, basePos.y + posOffset.y))

	self.itemSprite[ItemSpriteType.kSand] = anim
	self.isNeedUpdate = true
end

function ItemView:playSandMoveAnim(callback, direction)
	assert(direction)
	local function onAnimationFinished()
		if callback and type(callback)=="function" then callback() end
	end

	local sprite = self.itemSprite[ItemSpriteType.kSand]
	if sprite then
		sprite:stopAllActions()
		sprite:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kSand] = nil
	else
		if _G.isLocalDevelopMode then printx(0, "itemSprite[ItemSpriteType.kSand] not exist") end
		onAnimationFinished()
		return
	end

	local anim, posOffset = TileSand:buildMoveAnim(direction, onAnimationFinished)
	if not anim then
		if _G.isLocalDevelopMode then printx(0, "build sand move animation failed~") end
		onAnimationFinished()
		return
	end
	posOffset = posOffset or {x=0, y=0}
	local basePos = self:getBasePosition(self.x, self.y)
	anim:setPosition(ccp(basePos.x + posOffset.x, basePos.y + posOffset.y))

	self.itemSprite[ItemSpriteType.kSandMove] = anim
	self.isNeedUpdate = true
	GamePlayMusicPlayer:playEffect( GameMusicType.kPlaySandMove )
end


function ItemView:setQuestionMarkChangeItemVisible( value )
	-- body
	for k, v in pairs(needUpdateLayers) do 
		local s = self.itemSprite[v]
		if s then
			s:setVisible(value)
		end
	end
end

function ItemView:playQuestionMarkDestroy( callback )
	-- body
	local s = self.itemSprite[ItemSpriteType.kItemShow]
	if s then 
		s:removeFromParentAndCleanup(true)
	end

	local isBgCallback = false
	local isFgCallback = false
	local function finishCallback()
		if isBgCallback and isFgCallback then
			if callback then callback() end
		end
	end

	local function bg_callback( ... )
		isBgCallback = true
			-- body
		local s = self.itemSprite[ItemSpriteType.kQuestionMarkDestoryBg]
		if s then 
			s:removeFromParentAndCleanup(true)
		end
		self.itemSprite[ItemSpriteType.kQuestionMarkDestoryBg] = nil
		finishCallback()
	end
	local bg = TileQuestionMark:getBgLight(bg_callback)
	bg:setPosition(self:getBasePosition(self.x, self.y))
	self.itemSprite[ItemSpriteType.kQuestionMarkDestoryBg] = bg

	local function fg_callback( ... )
		isFgCallback = true
		-- body
		local s = self.itemSprite[ItemSpriteType.kQuestionMarkDestoryFg]
		if s then 
			s:removeFromParentAndCleanup(true)
		end
		self.itemSprite[ItemSpriteType.kQuestionMarkDestoryFg] = nil
		finishCallback()
	end 
	local fg = TileQuestionMark:getFgLight(fg_callback)
	fg:setPosition(self:getBasePosition(self.x, self.y))
	self.itemSprite[ItemSpriteType.kQuestionMarkDestoryFg] = fg
	self.isNeedUpdate = true
end

function ItemView:addChainsView(data)
	if data:hasChains() then
		local texture = nil
		if self.getContainer(ItemSpriteType.kChain) then 
			texture = self.getContainer(ItemSpriteType.kChain).refCocosObj:getTexture()
		end
		local chainSprite = TileChain:createWithChains(data.chains, texture)
		self.itemSprite[ItemSpriteType.kChain] = chainSprite
	end
end

-- breakLevels = {dir : level}
function ItemView:playChainBreakAnim(breakLevels, callback, isRemove)
	if type(breakLevels) == "table" and table.size(breakLevels) > 0 then
		local chainSprite = self.itemSprite[ItemSpriteType.kChain]
		if chainSprite and not chainSprite.isDisposed then
			chainSprite:playBreakAnimation(breakLevels, callback, isRemove)
			GamePlayMusicPlayer:playEffect( GameMusicType.kPlayIceblockBreak )
		else
			if callback then callback() end
		end
	else
		if callback then callback() end
	end
end

function ItemView:playStoneActiveAnim(stoneLevel, targetPos, callback)
	local stoneSprite = self.itemSprite[ItemSpriteType.kItemShow]
	if stoneSprite then
		-- stoneSprite:active(stoneLevel, targetPos)
		-- remove old anim
		local fireSprite = self.itemSprite[ItemSpriteType.kMagicStoneFire]
		if fireSprite and not fireSprite.isDisposed then
			fireSprite:removeFromParentAndCleanup(true)
			if fireSprite.onAnimFinish then fireSprite.onAnimFinish() end
			self.itemSprite[ItemSpriteType.kMagicStoneFire] = nil
		end
		-- add new anim
		local function onAnimFinish()
			if stoneSprite and not stoneSprite.isDisposed then
				stoneSprite:updateStoneSprite()
				stoneSprite:idle()
			end
			if callback then callback() end
		end

		local texture = nil
		if self.getContainer(ItemSpriteType.kMagicStoneFire)  then 
			texture = self.getContainer(ItemSpriteType.kMagicStoneFire).refCocosObj:getTexture()
		end

		local anim = TileMagicStone:createActiveAnim(texture, stoneLevel, stoneSprite.direction, onAnimFinish, targetPos)
		anim:setPosition(self:getBasePosition(self.x, self.y))
		anim.onAnimFinish = callback
		self.itemSprite[ItemSpriteType.kMagicStoneFire] = anim

		stoneSprite:removeStoneSprite()
		stoneSprite.level = stoneLevel + 1
		if stoneSprite.level > 2 then stoneSprite.level = 2 end

		self.isNeedUpdate = true
	else
		if callback then callback() end
	end
end

function ItemView:buildHedgehogBox( ... )
	-- body
	local sp = TileHedgehogBox:create()
	self.itemSprite[ItemSpriteType.kItemShow] = sp
end

function ItemView:playHedgehogBoxOpen(callback, targetPos)
	-- body
	local sp = self.itemSprite[ItemSpriteType.kItemShow]
	if sp then
		sp:playOpenAnimation(targetPos, callback)
	else
		if callback then callback() end
	end
end

local kRocketSpeed = 500
function ItemView:playRocketFlyAnimation(boardView, colortype, startPos, finalPos, callback)
	local rocket = TileRocket:create(colortype)
	if rocket and startPos and finalPos then
		colortype = colortype or rocket.color
		if rocket:getParent() then
			rocket:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kItemShow] = nil
		end

		local startPosInView, ufoPosInView = boardView:getPositionFromTo(startPos, finalPos)
		local effectLayer = boardView.PlayUIDelegate.effectLayer
		local function onAnimFinish()
			local explode = TileRocket:buildRocketExplodeAnimation()
			local offsetPos = ccp(0, 0)
			if finalPos.y > startPos.y then offsetPos = ccp(-50, 0) -- UFO在导弹右边
			elseif finalPos.y < startPos.y then offsetPos = ccp(50, 0) -- UFO在导弹左边
			end
			explode:setPosition(ccp(ufoPosInView.x + offsetPos.x, ufoPosInView.y + offsetPos.y))
			effectLayer:addChild(explode)

			if callback then callback() end
		end

		local finalPosInView = ccp(ufoPosInView.x, ufoPosInView.y + 15) -- 向上偏移一定距离
		local movePosList = {}
		table.insert(movePosList, startPosInView)
		if finalPos.y ~= startPos.y then -- 转弯点
			table.insert(movePosList, ccp(startPosInView.x, finalPosInView.y))
		end
		table.insert(movePosList, finalPosInView)
		local ani = TileRocket:buildRocketAnimation(colortype, movePosList, onAnimFinish)
		if ani then
			ani:setPosition(startPosInView)
			effectLayer:addChild(ani)
		else
			if callback then callback() end
		end
		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayPokectLaunch )
	else
		if callback then callback() end
	end
end

--------------------------------------------------
-- 染色宝宝动画
--------------------------------------------------
-- 染色宝宝外发光动画
function ItemView:playCrystalStoneChargeEffect()
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite and type(sprite.playChargeEffect) == "function" then
		sprite:playChargeEffect()
	end
end

-- 充能动画
function ItemView:playCrystalStoneCharge(fromItemPos, color)
	local function onAnimFinish( ... )
		self:playCrystalStoneChargeEffect()
	end
	local layer = self.getContainer(ItemSpriteType.kCrystalStoneEffect)
	if layer then
		local startPos = self:getBasePosition(fromItemPos.y, fromItemPos.x)
		local endPos = self:getBasePosition(self.x, self.y)
		local finalPos = ccp(endPos.x, endPos.y+28)

		local animate = TileCrystalStoneAnimate:buildAddEnergyAnimate(color, ccp(finalPos.x-startPos.x, finalPos.y-startPos.y), onAnimFinish)
		animate:setPosition(startPos)

		layer:addChild(animate)
	end
end

-- 更新能量进度
function ItemView:updateCrystalStoneEnergy(energyPercent, withAnimate)
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite and type(sprite.updateEnergyPercent) == "function" then
		sprite:updateEnergyPercent(energyPercent, withAnimate)
	end
end

-- 激活状态
function ItemView:playCrystalStoneFullAnimate()
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite and type(sprite.updateState) == "function" then
		sprite:updateState(CrystalStongAnimateStates.kFull)
	end
end

-- 消失动画
function ItemView:playCrystalStoneDisappear(isSpecial, callback)
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite and type(sprite.playDisappearAnimate) == "function" then
		sprite:playDisappearAnimate(callback)

		if isSpecial then
			if self.itemSprite[ItemSpriteType.kCrystalStoneEffect] then 
				self.itemSprite[ItemSpriteType.kCrystalStoneEffect]:removeFromParentAndCleanup(true) 
			end

			local effect = TileCrystalStoneAnimate:buildExplodeEffect()
			local pos = self:getBasePosition(self.x, self.y)
			effect:setPosition(ccp(pos.x, pos.y-2))

			self.itemSprite[ItemSpriteType.kCrystalStoneEffect] = effect
			self.isNeedUpdate = true
		end
	else
		if callback then callback() end
	end
end

-- 转换为等待消失
function ItemView:playCrystalStoneChangeToWaiting()
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite and type(sprite.playChangeToWaitingBomb) == "function" then
		sprite:playChangeToWaitingBomb()
	end
end

-- 染色宝宝发出改变颜色的特效
function ItemView:playChangeColorByCrystalStone(fromItem, color, callback)
	local fromPos = self:getBasePosition(fromItem.y, fromItem.x)
	local finalPos = self:getBasePosition(self.x, self.y)
	local function onAnimationFinished()
		if callback then callback() end
	end

	local startPos = ccp(fromPos.x, fromPos.y+28)
	local animate = TileCrystalStoneAnimate:buildChangeColorAnimate(color, ccp(finalPos.x - startPos.x, finalPos.y - startPos.y), onAnimationFinished)
	animate:setPosition(startPos)
	self.itemSprite[ItemSpriteType.kCrystalStoneEffect] = animate
	self.isNeedUpdate = true
	GamePlayMusicPlayer:playEffect( GameMusicType.kPlayCrystalCasting )
end

--------------------------------------------------
-- 星星瓶动画
--------------------------------------------------
function ItemView:buildBlocker195(data, isOnlyGetSprite)--创建
	local boardLogic = GameBoardLogic:getCurrentLogic()
	local percent = 0
	if data.isActive then
		percent = 1
	else
		percent = data.level / boardLogic.blocker195Nums[data.subtype]
	end

	local sprite = TileBlocker195:create(data.subtype, percent, data.isActive)
	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
	end
	return sprite
end

function ItemView:playBlocker195CollectAnimation(count, percent)--收集动画
	if self.oldData then 
		self.oldData.level = count
	end
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite then
		sprite:playCollectAnimation(percent)
	end
end

function ItemView:playBlocker195Light1Animation(fromPos)--收集光动画
	local function finishCallback()
		self:playBlocker195Light2Animation()
	end
	local layer = self.getContainer(ItemSpriteType.kBlocker195Effect)
	if layer then
		local startPos = self:getBasePosition(fromPos.y, fromPos.x)
		local endPos = self:getBasePosition(self.x, self.y)
		local finalPos = ccp(endPos.x, endPos.y)

		local animate = TileBlocker195:playCollectLight1Animation(ccp(finalPos.x-startPos.x, finalPos.y-startPos.y), finishCallback)
		animate:setPosition(startPos)
		layer:addChild(animate)
	end
end

function ItemView:playBlocker195Light2Animation()
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite and type(sprite.playCollectLight2Animation) == "function" then
		sprite:playCollectLight2Animation()
	end
end

function ItemView:playBlocker195FlyAnimation(fromPos, toPos)
	local layer = self.getContainer(ItemSpriteType.kBlocker195Effect)
	if layer then
		local animate = TileBlocker195:playJoinAnimation(fromPos, toPos)
		layer:addChild(animate)
	end
end

function ItemView:playBlocker195DestroyAnimation()--消除动画
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite then
		sprite:playDestroyAnimation()
	end
end
--------------------------------------------------
-- 水母宝宝
--------------------------------------------------
function ItemView:buildBlocker199(data, isOnlyGetSprite)
	local sprite = TileBlocker199:create(data.subtype, data.level, data._encrypt.ItemColorType, data.isActive)
	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
	end
	return sprite
end

function ItemView:playBlocker199GrowupAnimation(level)
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite then
		sprite:playGrowupAnimation(level)
	end
end

function ItemView:playBlocker199ExplodeAnimation()
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite then
		sprite:playExplodeAnimation()
	end
end

function ItemView:playBlocker199ReinitAnimation(type, color, isRotation)
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite then
		sprite:playReinitAnimation(type, color, isRotation)
		if self.oldData then 
			self.oldData.subtype = type
			self.oldData._encrypt.ItemColorType = color
		end
	end
end

function ItemView:playBlocker199EffectAnimation(len, angle)
	local layer = self.getContainer(ItemSpriteType.kBlocker199Effect)
	local effect = TileBlocker199:playEffectAnimation(len)
	effect:setPosition(self:getBasePosition(self.x, self.y))
	effect:setRotation(angle)
	if layer then layer:addChild(effect) end
end

function ItemView:removeBlocker199View()
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite then
		sprite:removeWholeView()
		sprite:removeFromParentAndCleanup(true)
	end
	self.itemSprite[ItemSpriteType.kItemShow] = nil
end

--------------------------------------------------
-- 配对锁和钥匙
--------------------------------------------------
function ItemView:buildBlocker206(isOnlyGetSprite , data)

	local sprite = TileLockBox:create(
		data.needKeys , 
		data.lockBoxRopeUp , 
		data.lockBoxRopeDown , 
		data.lockBoxRopeLeft , 
		data.lockBoxRopeRight , 
		data.lockBoxActive)

	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kLock206Show] = sprite
	end
	return sprite
end

function ItemView:playBlocker206ActiveAnimation()
	local sprite = self.itemSprite[ItemSpriteType.kLock206Show]
	if sprite then
		sprite:playActive()
	end
end


function ItemView:playBlocker206DestroyAnimation()
	local sprite = self.itemSprite[ItemSpriteType.kLock206Show]
	if sprite then
		local function onAnimFinish()
			sprite:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kLock206Show] = nil
		
			self.isNeedUpdate = true
		end

		sprite:playBreak(onAnimFinish)
	end
end


function ItemView:playBlocker206ChargeAnimation(fromItemPos)
	local function onAnimFinish( ... )
		local sprite = self.itemSprite[ItemSpriteType.kLock206Show]
		if sprite then
			sprite:decreaseLockHeadNum()
		end
	end
	local layer = self.getContainer(ItemSpriteType.kCrystalStoneEffect)
	if layer then
		local startPos = self:getBasePosition(fromItemPos.y, fromItemPos.x)
		local endPos = self:getBasePosition(self.x, self.y)
		local finalPos = ccp(endPos.x, endPos.y+0)

		local animate = TileCrystalStoneAnimate:buildAddEnergyAnimate( AnimalTypeConfig.kOrange , ccp(finalPos.x-startPos.x, finalPos.y-startPos.y), onAnimFinish)
		animate:setPosition(startPos)

		layer:addChild(animate)
	end
end


function ItemView:buildBlocker207(isOnlyGetSprite)
	self.itemShowType = ItemSpriteItemShowType.kBlocker207
	local sprite = TileLockBoxKey:create()
	--local sprite = TileNationDayStar:create()
	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
	end
	return sprite
end

function ItemView:playBlocker207DestroyAnimation()
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite then
		local function onAnimFinish()
			sprite:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kItemShow] = nil
		
			self.isNeedUpdate = true
		end

		if sprite.playBreak then
			sprite:playBreak(onAnimFinish)
		else
			assert(false, 'playBlocker207DestroyAnimation')
		end
	end
end
--------------------------------------------------
-- 寄居蟹
--------------------------------------------------
function ItemView:buildBlocker211(data, isOnlyGetSprite)--创建
	local sprite = TileBlocker211:create(data)
	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
	end
	return sprite
end

function ItemView:playBlocker211CollectAnimation(data)--收集动画
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite then
		sprite:playCollectAnimation(data)
	end
end

function ItemView:renewBlocker211IdleAnimation(data)--恢复等待动画
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite then
		sprite:renewIdleAnimation(data)
	end
end

function ItemView:playBlocker211ExplodeAnimation()--收集状态
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite then
		sprite:playExplodeAnimation(function()
			self:playBlocker211EmptyAnimation()
		end)
	end
end

function ItemView:playBlocker211EmptyAnimation()--不能收集状态
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite then
		sprite:playEmptyAnimation()
	end
end

function ItemView:playBlocker211ReinitAnimation()--重置
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite then
		sprite:playReinitAnimation()
	end
end

function ItemView:playBlocker211Effect1Animation(fromPos, toPos)--特效飞线
	local layer = self.getContainer(ItemSpriteType.kBlocker211Effect)
	if layer then
		local animate = TileBlocker211:playEffect1Animation(fromPos, toPos, function()
			self:playBlocker211Effect2Animation(toPos)
		end)
		layer:addChild(animate)
	end
end

function ItemView:playBlocker211Effect2Animation(pos)--特效爆炸
	local layer = self.getContainer(ItemSpriteType.kBlocker211Effect)
	if layer then
		local animate = TileBlocker211:playEffect2Animation(pos)
		layer:addChild(animate)
	end
end
--------------------------------------------------
function ItemView:buildTotems(colortype, isActived, isOnlyGetSprite)
	local sprite = TileTotems:create(colortype, isActived)
	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
	end
	return sprite
end

function ItemView:playTotemsChangeToActive(callback)
	local totems = self.itemSprite[ItemSpriteType.kItemShow]
	if totems and type(totems.playChangeAnimate) == "function" then
		totems:playChangeAnimate(callback)
		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayTotemsActive )
	end
end

function ItemView:playSuperTotemsWaittingExplode(linkToPos)
	local totems = self.itemSprite[ItemSpriteType.kItemShow]
	if totems and type(totems.hideTotems) == "function" then
		totems:hideTotems()
	end

	local selfPos = self:getBasePosition(self.x, self.y)
	local waittingAnimate = TileTotemsAnimation:buildTotemsWattingExplodeAnimate()
	waittingAnimate:setPosition(selfPos)
	self.itemSprite[ItemSpriteType.kSuperTotemsEffect] = waittingAnimate

	if linkToPos then
		local targetPos = self:getBasePosition(linkToPos.y, linkToPos.x)
		local lightningAnimate = TileTotemsAnimation:buildTotemsExplodeLightning(selfPos, targetPos)
		lightningAnimate:setPosition(selfPos)
		self.itemSprite[ItemSpriteType.kSuperTotemsLight] = lightningAnimate
	end
	GamePlayMusicPlayer:playEffect( GameMusicType.kPlayTotemsCasting )
end

function ItemView:playSuperTotemsDestoryAnimate()
	if self.itemSprite[ItemSpriteType.kSuperTotemsLight] then
		self.itemSprite[ItemSpriteType.kSuperTotemsLight]:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kSuperTotemsLight] = nil
	end
	if self.itemSprite[ItemSpriteType.kSuperTotemsEffect] then
		self.itemSprite[ItemSpriteType.kSuperTotemsEffect]:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kSuperTotemsEffect] = nil
	end
	if self.itemSprite[ItemSpriteType.kItemShow] then
		self.itemSprite[ItemSpriteType.kItemShow]:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kItemShow] = nil
	end
end

function ItemView:playTopLevelHightLightEffect(highlightType)
	if self.highlightType == highlightType then return end
	self.highlightType = highlightType

	self:stopTopLevelHightLightEffect()

	local effect = nil
	if highlightType == TileHighlightType.kRedAlert then
		effect = ItemViewUtils:buildWarnningTileHighLight()
	end
	if effect then
		effect:setPosition(self:getBasePosition(self.x, self.y))
		self.itemSprite[ItemSpriteType.kTopLevelHighLightEffect] = effect
	end
	self.isNeedUpdate = true
end

function ItemView:stopTopLevelHightLightEffect()
	self.highlightType = nil
	if self.itemSprite[ItemSpriteType.kTopLevelHighLightEffect] then
		self.itemSprite[ItemSpriteType.kTopLevelHighLightEffect]:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kTopLevelHighLightEffect] = nil

		self.isNeedUpdate = true
	end
end

function ItemView:playMixTileHighlightEffect()
	local container = self.getContainer(ItemSpriteType.kTileHighLightEffect)
	if container then
		local effect = ItemViewUtils:buildMixTileHighLight()
		effect:setPosition(self:getBasePosition(self.x, self.y))
		container:addChild(effect)
	end
end

function ItemView:playTileHighlightEffect(highlightType)
	if self.highlightType == highlightType then return end

	self.highlightType = highlightType

	self:stopTileHighlightEffect()

	local effect = nil
	if highlightType == TileHighlightType.kTotems then
		-- local effect = TileTotemsAnimation:createTileLight()
		effect = ItemViewUtils:buildTotemsTileHighLight()
	end
	if effect then
		effect:setPosition(self:getBasePosition(self.x, self.y))
		self.itemSprite[ItemSpriteType.kTileHighLightEffect] = effect
	end
	self.isNeedUpdate = true
end

function ItemView:stopTileHighlightEffect()
	self.highlightType = nil
	if self.itemSprite[ItemSpriteType.kTileHighLightEffect] then
		self.itemSprite[ItemSpriteType.kTileHighLightEffect]:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kTileHighLightEffect] = nil

		self.isNeedUpdate = true
	end
end
function ItemView:addWukongProgress(add)
	if self.oldData and self.oldData.ItemType == GameItemType.kWukong then
		local tileWukong = self:getWukongSprite()
		self.oldData.wukongProgressCurr = self.oldData.wukongProgressCurr + add
		if self.oldData.wukongProgressCurr > self.oldData.wukongProgressTotal then
			self.oldData.wukongProgressCurr = self.oldData.wukongProgressTotal
		end
		if tileWukong then
			tileWukong:setProgress(self.oldData.wukongProgressCurr , self.oldData.wukongProgressTotal)
		end
	end
end

function ItemView:setWukongProgress(curr , total)
	local tileWukong = self:getWukongSprite()
	if tileWukong then

		tileWukong:setProgress(curr , total)
	end
end

function ItemView:cleanSuperCuteBallView()
	if self.itemSprite[ItemSpriteType.kSuperCuteHighLevel] then
		if self.itemSprite[ItemSpriteType.kSuperCuteHighLevel]:getParent() then
			self.itemSprite[ItemSpriteType.kSuperCuteHighLevel]:removeFromParentAndCleanup(true)
		end
		self.itemSprite[ItemSpriteType.kSuperCuteHighLevel] = nil
	end
	if self.itemSprite[ItemSpriteType.kSuperCuteLowLevel] then
		if self.itemSprite[ItemSpriteType.kSuperCuteLowLevel]:getParent() then
			self.itemSprite[ItemSpriteType.kSuperCuteLowLevel]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kSuperCuteLowLevel] = nil
		end
	end
	self.isNeedUpdate = true
end

function ItemView:addSuperCuteBall(ballState)
	self:cleanSuperCuteBallView()

	local sprite = TileSuperCuteBall:create(ballState)
	sprite:setPosition(self:getBasePosition(self.x, self.y))

	if ballState == GameItemSuperCuteBallState.kInactive then
		self.itemSprite[ItemSpriteType.kSuperCuteLowLevel] = sprite
	else
		self.itemSprite[ItemSpriteType.kSuperCuteHighLevel] = sprite
	end
	self.isNeedUpdate = true
end

function ItemView:playSuperCuteMove(direction, callback)
	local superCute = self.itemSprite[ItemSpriteType.kSuperCuteHighLevel]

	if superCute then
		local function onAnimFinish()
			if type(callback) == "function" then callback() end 
		end	

		superCute:removeFromParentAndCleanup(false)
		self.itemSprite[ItemSpriteType.kSuperCuteHighLevel] = nil

		if self.itemSprite[ItemSpriteType.kSpecial] then
			self.itemSprite[ItemSpriteType.kSpecial]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kSpecial] = nil
		end

		self.itemSprite[ItemSpriteType.kSpecial] = superCute
		self.isNeedUpdate = true

		local jumDir = nil
		if direction.x == 0 and direction.y == 1 then
			jumDir = SuperCuteBallJumpDirection.kRight
		elseif direction.x == 0 and direction.y == -1 then
			jumDir = SuperCuteBallJumpDirection.kLeft
		elseif direction.x == 1 and direction.y == 0 then
			jumDir = SuperCuteBallJumpDirection.kDown
		elseif direction.x == -1 and direction.y == 0 then
			jumDir = SuperCuteBallJumpDirection.kUp
		end
		if jumDir then
			superCute:playJump(jumDir, onAnimFinish)
		else
			onAnimFinish()
		end
		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayCuteJump )
	else
		if type(callback) == "function" then callback() end 
	end
end

function ItemView:playSuperCuteInactive(callback)
	local superCute = self.itemSprite[ItemSpriteType.kSuperCuteHighLevel]
	if superCute then
		local function onAnimFinish()
			superCute:removeFromParentAndCleanup(false)
			self.itemSprite[ItemSpriteType.kSuperCuteHighLevel] = nil
			superCute:playInactive()
			self.itemSprite[ItemSpriteType.kSuperCuteLowLevel] = superCute
		
			self.isNeedUpdate = true
			if type(callback) == "function" then callback() end 
		end
		superCute:playHide(onAnimFinish)
		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayWhitecuteHide )
	else
		if type(callback) == "function" then callback() end 
	end
end

function ItemView:playSuperCuteRecover(callback)
	local superCute = self.itemSprite[ItemSpriteType.kSuperCuteLowLevel]
	if superCute then
		local function jumpToHighLevel()
			superCute:removeFromParentAndCleanup(false)
			self.itemSprite[ItemSpriteType.kSuperCuteLowLevel] = nil

			self.itemSprite[ItemSpriteType.kSuperCuteHighLevel] = superCute
			self.isNeedUpdate = true
		end
		local function onAnimFinish()
			superCute:playIdle(true)
			if type(callback) == "function" then callback() end
		end
		superCute:playShow(onAnimFinish, jumpToHighLevel)
		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayWhitecuteShow )
	else
		if type(callback) == "function" then callback() end 
	end
end

--色彩过滤器
function ItemView:playColorFilterAFilter()
	local sprite = self.itemSprite[ItemSpriteType.kColorFilterA]
	if sprite then
		sprite:playFilter()
	end
end

function ItemView:playColorFilterBDec(oldLevel, callback)
	local sprite = self.itemSprite[ItemSpriteType.kColorFilterB]
	if sprite then 
		sprite:playDec(oldLevel, callback)
	end
end

function ItemView:playColorFilterBDisappear()
	local sprite = self.itemSprite[ItemSpriteType.kColorFilterB]
	self.itemSprite[ItemSpriteType.kColorFilterB] = nil
	if sprite then 
		sprite:playDisappear(function ()
			sprite:removeFromParentAndCleanup(true)
		end)
	end
end

function ItemView:playActCollectionShow(callback)
	local deltaX 
	local deltaY 
	local destDeltaX = 52
	local destDeltaY = 18
	local sp = self.itemSprite[ItemSpriteType.kItem]
	if sp then 
		deltaX = 52
		deltaY = 18
	else
		sp = self.itemSprite[ItemSpriteType.kItemShow]
		deltaX = 17
		deltaY = -17
	end
	if sp then
		ActCollectionLogic:playGenFlyAni(self.getContainer(ItemSpriteType.kTopLevelEffect), self.pos_x + destDeltaX, self.pos_y + destDeltaY, function ()
			self:addActCollectionIcon(sp, deltaX, deltaY)
			if callback then callback() end
		end)
	else
		if callback then callback() end
	end
end

function ItemView:addActCollectionIcon(pSprite, posX, posY)
	if not pSprite then return end
  	local actCollectIcon = Sprite:createWithSpriteFrameName("item_act_collection.png")
	actCollectIcon:setPosition(ccp(posX, posY))
	pSprite:addChild(actCollectIcon)
	pSprite.actCollectIcon = actCollectIcon
end

function ItemView:playChameleonBlast()
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]	--变色龙放此层

	local function finishCallback()
		if sprite then 
			sprite:removeFromParentAndCleanup(true) 
		end
		self.itemSprite[ItemSpriteType.kSpecial] = nil
	end

	if sprite then
		sprite:playChameleonBlastAnimation(finishCallback)

		self.itemSprite[ItemSpriteType.kItemShow] = nil
		self.itemSprite[ItemSpriteType.kSpecial] = sprite	--因为变换目标是特效的话，也在kItemShow这层，所以转换变色龙动画的层级
	end

end

--------------------------------------------------------------------------
--								Pacman
--------------------------------------------------------------------------
--- Pacman's Den
function ItemView:updatePacmansDenProgressDisplay()
	local sprite = self.itemSprite[ItemSpriteType.kPacmanShow]
	if sprite then
		sprite:updateProgressDisplay()
	end
end

function ItemView:playPacmansDenGenerate()
	local sprite = self.itemSprite[ItemSpriteType.kPacmanShow]

	local function finishCallback()
		self.itemSprite[ItemSpriteType.kSpecial] = nil
		self.itemSprite[ItemSpriteType.kPacmanShow] = sprite
	end

	if sprite then
		self.itemSprite[ItemSpriteType.kPacmanShow] = nil
		self.itemSprite[ItemSpriteType.kSpecial] = sprite
		sprite:playGeneratePacmanAnimation(finishCallback)
	end
end

--- 动画层级依托于上面的PacmansDenGenerate，所以需保证上面的动画时间长于这个
function ItemView:playPacmansDenGeneratePacman(direction, colour, callback)
	local sprite = self.itemSprite[ItemSpriteType.kPacmanShow]
	local jumDir = PacmanLogic:getJumpDirectionIndex(direction)
	if jumDir and sprite then
		sprite:playOnePacmanGenerate(jumDir, colour, callback)
	end
end

--- Pacman
function ItemView:playPacmanMove(direction, callback)
	local sprite = self.itemSprite[ItemSpriteType.kPacmanShow]

	if sprite then
		local function onAnimFinish()
			if self.itemSprite[ItemSpriteType.kSpecial] then
				self.itemSprite[ItemSpriteType.kSpecial]:removeFromParentAndCleanup(true)
				self.itemSprite[ItemSpriteType.kSpecial] = nil
			end
			if type(callback) == "function" then callback() end 
		end	

		sprite:removeFromParentAndCleanup(false)
		self.itemSprite[ItemSpriteType.kPacmanShow] = nil

		if self.itemSprite[ItemSpriteType.kSpecial] then
			self.itemSprite[ItemSpriteType.kSpecial]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kSpecial] = nil
		end

		self.itemSprite[ItemSpriteType.kSpecial] = sprite
		self.isNeedUpdate = true

		local jumDir = PacmanLogic:getJumpDirectionIndex(direction)
		if jumDir then
			sprite:playPacmanJump(jumDir, onAnimFinish)
		else
			onAnimFinish()
		end
	else
		if type(callback) == "function" then callback() end 
	end
end

function ItemView:changePacmanToSuper()
	local sprite = self.itemSprite[ItemSpriteType.kPacmanShow]
	-- printx(11, "ItemView:changePacmanToSuper", sprite)
	if sprite then
		-- printx(11, "sprite:changeToSuper()")
		sprite:changeToSuper()
	end
end

function ItemView:playPacmanBlastAnimation()
	local sprite = self.itemSprite[ItemSpriteType.kPacmanShow]

	local function finishCallback()
		if sprite then 
			sprite:removeFromParentAndCleanup(true) 
		end
		self.itemSprite[ItemSpriteType.kPacmanShow] = nil
	end

	if sprite then
		sprite:playPacmanBlastAnimation(finishCallback)
	end
end

function ItemView:playPacmansBlowHitAnimation(fromPos, toPos)
	local layer = self.getContainer(ItemSpriteType.kBlocker195Effect)	--借用一下这层没问题吧？反正不会同时出现
	if layer then
		local animate = TilePacman:playHitEffectAnimation(fromPos, toPos)
		layer:addChild(animate)
	end
end

----------- Turret Demo ---------------
function ItemView:buildTurret(turretDir, turretIsTypeRandom, turretLevel, turretIsSuper, isOnlyGetSprite)
	local sprite = TileTurret:create(turretDir, turretIsTypeRandom, turretLevel, turretIsSuper)
	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
	end
	return sprite
end

function ItemView:playTurretPreUpgradeAnimation(toSuper, done )
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite then
		sprite:playPreUpgradeAnimation(done)
	end
end

function ItemView:playTurretUpgradeAnimation(toSuper, fromPos )
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
    local layer = self.getContainer(ItemSpriteType.kTurretEffect)
	if sprite then
		sprite:playUpgradeAnimation(toSuper, layer, fromPos)
	end
end

function ItemView:playTurretFireFlyAnimation(fromPos, toPos)
	local layer = self.getContainer(ItemSpriteType.kTurretEffect)
	if layer then
		local animate = TileTurret:playHitEffectAnimation(fromPos, toPos)
		layer:addChild(animate)
	end
end

function ItemView:playTurretPieceFlyAnimation(fromPos, toPos, delayTime, PieceInedx, done, isSuper)
	local layer = self.getContainer(ItemSpriteType.kTurretEffect)
	if layer then
		local animate = TileTurret:playPiectFly(fromPos, toPos, delayTime, PieceInedx, done, isSuper)
		layer:addChild(animate)
	end
end

function ItemView:setTurretViewBackToActive()
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite then
		sprite:setViewBackToActive()
	end
end

function ItemView:playTurretMainBoomAnimation(toPos)
	local layer = self.getContainer(ItemSpriteType.kTurretEffect)
    local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if layer then
		local animate = sprite:playMainBoomAnimation(toPos)
		layer:addChild(animate)
	end
end
----------- Turret Demo End---------------

---------------------------------------------------------------------------------------------
--									Mole Weekly Race
---------------------------------------------------------------------------------------------
------------- Seed --------------
function ItemView:buildMoleBossSeed(level, isOnlyGetSprite)
	local texture
	if self.getContainer(ItemSpriteType.kMoleWeeklyItemShow) then 
		texture = self.getContainer(ItemSpriteType.kMoleWeeklyItemShow).refCocosObj:getTexture()
	end
	local sprite = TileMoleBossSeed:create(texture, level)

	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kMoleWeeklyItemShow] = sprite
	end
	return sprite
end

function ItemView:replaceWithMoleBossSeed(level)
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite then sprite:removeFromParentAndCleanup(true) end

	self:buildMoleBossSeed(level)
end

function ItemView:playMoleBossSeedBeingHit()
	-- printx(11, " =+ + + + + + + Play seed Dec + + + + + + +=")
	local sprite = self.itemSprite[ItemSpriteType.kMoleWeeklyItemShow]
	if sprite then
		sprite:playBeingHitAnimation()
	end
end

function ItemView:playMoleBossSeedDemolish(callback)
	-- printx(11, " =+ + + + + + + Play seed Demolish + + + + + + +=")
	local sprite = self.itemSprite[ItemSpriteType.kMoleWeeklyItemShow]
	if sprite then
		sprite:playBreakAnimation(callback)
	end
end

function ItemView:playMoleBossSeedCountDown(callback)
	local sprite = self.itemSprite[ItemSpriteType.kMoleWeeklyItemShow]
	if sprite then
		sprite:playCountDownAnimation(callback)
	end
end

function ItemView:playMoleBossSeedHitAnimation(fromPos, toPos)
	-- printx(11, " =+ + + + + + + playMoleBossSeedHitAnimation + + + + + + +=")
	local layer = self.getContainer(ItemSpriteType.kBlocker195Effect)	--借用一下这层没问题吧？反正不会同时出现
	if layer then
		local animate = TileMoleBossSeed:playHitEffectAnimation(fromPos, toPos)
		layer:addChild(animate)
	end
end

------------- Magic tile cover --------------
function ItemView:buildMoleMagicTileCover(isOnlyGetSprite)
	local sprite = TileMoleMagicTileCover:create()

	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kBlockerCoverMaterial] = sprite
	end
	return sprite
end

function ItemView:addMoleMagicTileCoverAnimation()
	-- printx(11, "Grid Add Disable Effect!!!")
	-- local sprite = Sprite:createWithSpriteFrameName("magic_tile_mole_cover_disappear_0000")

	local sprite = TileMoleMagicTileCover:create()
	self.itemSprite[ItemSpriteType.kBlockerCoverMaterial] = sprite

	if self.itemSprite[ItemSpriteType.kBlockerCoverMaterial]:getParent() ~= nil then
		self.itemSprite[ItemSpriteType.kBlockerCoverMaterial]:getParent():addChild(sprite)
	end

	sprite:playAppearAnimation()
	sprite:setPosition(self:getBasePosition(self.x, self.y))
end

function ItemView:removeMoleMagicTileCover()
	local sprite = self.itemSprite[ItemSpriteType.kBlockerCoverMaterial]

	local function animationCallback()
		if sprite then sprite:removeFromParentAndCleanup(true) end
		self.itemSprite[ItemSpriteType.kBlockerCoverMaterial] = nil
		-- if callback then callback() end
	end

	if sprite then
		sprite:playDisappearAnimation(animationCallback)
	end
end

------------- others tmp --------------
function ItemView:playHalloweenBossSkillFlyTo(fromPos, toPos, callback)
	local layer = self.getContainer(ItemSpriteType.kBlocker195Effect)	--依然借用一下这层
	if layer then
		local animate = Layer:create()

		local animation = Sprite:createWithSpriteFrameName("blocker_pacman_effect_hit_0000")
		local frames = SpriteUtil:buildFrames("blocker_pacman_effect_hit_%04d", 0, 22)
		local anim = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		animation:play(anim, 0, 1, onAnimationFinished, true)

		local angle = -math.deg(math.atan2(toPos.y - fromPos.y, toPos.x - fromPos.x))
		animation:setPosition(fromPos)
		animation:setRotation(angle)
		animation:setAnchorPoint(ccp(0.8, 0.46))

		local function finishCallback()
			animate:removeFromParentAndCleanup(true)
			if callback then callback() end
		end

		local actArr = CCArray:create()
		actArr:addObject(CCMoveTo:create(0.4, ccp(toPos.x , toPos.y)))
		actArr:addObject(CCCallFunc:create(finishCallback) )
		animation:runAction(CCSequence:create(actArr))

		animate:addChild(animation)
		layer:addChild(animate)
	end
end

function ItemView:playYellowDiamondDecAnimation( boardView )
	-- body
	local sprite = self.itemSprite[ItemSpriteType.kDigBlocker]
	local function callback( ... )
		-- body
		sprite:removeFromParentAndCleanup(true)
		self.itemSprite[ItemSpriteType.kDigBlockerBomb] = nil
	end

	if sprite then 
		if sprite.level == 1 then
			self.itemSprite[ItemSpriteType.kDigBlocker] = nil
			if boardView and container then 
				sprite:removeFromParentAndCleanup(false)
				self.itemSprite[ItemSpriteType.kDigBlockerBomb] = sprite
			end
			sprite:changeLevel(sprite.level -1, callback)
			GamePlayMusicPlayer:playEffect( GameMusicType.kPlayCloudCollect )
		else
			sprite:changeLevel(sprite.level - 1, true)
			GamePlayMusicPlayer:playEffect( GameMusicType.kPlayCloudClear )
		end
	end
end

--------------------------------------------- Ghost --------------------------------------------------------
function ItemView:cleanGhostDoorView()
	-- printx(11, " ItemView:cleanGhostDoorView.", debug.traceback())
	if self.itemSprite[ItemSpriteType.kGhostDoor] then
		if self.itemSprite[ItemSpriteType.kGhostDoor]:getParent() then
			self.itemSprite[ItemSpriteType.kGhostDoor]:removeFromParentAndCleanup(true)
		end
		self.itemSprite[ItemSpriteType.kGhostDoor] = nil
	end
end

function ItemView:addGhostDoor(data)
	if data.isGhostAppear then
		self:_addGhostDoor(GhostDoorType.k_appear)
	end
	if data.isGhostCollect then
		self:_addGhostDoor(GhostDoorType.k_vanish)
	end
end

function ItemView:_addGhostDoor(doorType)
	local sprite = TileGhostDoor:create(doorType)
	sprite:setPosition(self:getBasePosition(self.x, self.y))
	self.itemSprite[ItemSpriteType.kGhostDoor] = sprite
	-- self.isNeedUpdate = true
end

--------------------------------------------
function ItemView:cleanGhostView()
	-- printx(11, " ItemView:cleanGhostView.", debug.traceback())
	if self.itemSprite[ItemSpriteType.kGhost] then
		if self.itemSprite[ItemSpriteType.kGhost]:getParent() then
			self.itemSprite[ItemSpriteType.kGhost]:removeFromParentAndCleanup(true)
		end
		self.itemSprite[ItemSpriteType.kGhost] = nil
	end
end

function ItemView:addGhost()
	self:cleanGhostView()

	local sprite = TileGhost:create()
	sprite:setPosition(self:getBasePosition(self.x, self.y))
	self.itemSprite[ItemSpriteType.kGhost] = sprite
	self.isNeedUpdate = true

	return sprite
end

function ItemView:playGhostAppear(callback)
	-- local function onAnimFinish()
	-- 	ghost:playIdleAnimation()
	-- 	if type(callback) == "function" then callback() end
	-- end

	local ghost = self:addGhost()
	ghost:playGhostAppear()
	-- ghost:playGhostAppear(onAnimFinish)
end

function ItemView:playGhostActive(callback)
	local ghost = self.itemSprite[ItemSpriteType.kGhost]
	if ghost then
		ghost:switchToActiveView()
	end
end

function ItemView:playGhostFly(pace)
	-- printx(11, "pace, moveSpeed:", pace, moveSpeed)
	local ghost = self.itemSprite[ItemSpriteType.kGhost]
	if ghost then
		ghost:playFlyAnimation(pace)
	end
end

function ItemView:playGhostNormal(callback)
	local ghost = self.itemSprite[ItemSpriteType.kGhost]
	if ghost then
		ghost:playIdleAnimation()
	end
end

function ItemView:playGhostDisappear(pace)
	local ghost = self.itemSprite[ItemSpriteType.kGhost]
	if ghost then
		ghost:playDisappearAnimation(pace)
	end
end

------------------------------------------------------------------------
function ItemView:buildScoreBuffBottle(data, isOnlyGetSprite)
	local targetColour = data._encrypt.ItemColorType
	local colourIndex = AnimalTypeConfig.convertColorTypeToIndex(targetColour)

	local sprite = TileScoreBuffBottle:create(colourIndex)
	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
	end
	return sprite
end

function ItemView:playScoreBuffBottleBeingHit()
	-- printx(11, " =+ + + + + + + playScoreBuffBottleBeingHit + + + + + + +=")
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite then
		sprite:playBeingHitAnimation()
	end
end

function ItemView:playScoreBuffBottleBlast(bottleColour)
	self:cleanScoreBuffBottleView()

	local layer = self.getContainer(ItemSpriteType.kBlocker195Effect)	--借用一下这层没问题吧？反正不会同时出现
	if layer then
		local function onBlastFinished()
			-- printx(11, "=========== Back 1 ================")
			-- if animation then
			-- 	printx(11, "=========== Back 2 ================")
			-- 	animation:removeFromParentAndCleanup(true)
			-- end
		end

		local startPos = self:getBasePosition(self.x, self.y)
		startPos.y = startPos.y + 1
		local animation = TileScoreBuffBottle:playScoreBuffBottleBlastAnimation(bottleColour, onBlastFinished)
		animation:setPosition(startPos)
		layer:addChild(animation)
	end
end

function ItemView:cleanScoreBuffBottleView()
	-- printx(11, " ItemView:cleanScoreBuffBottleView.", debug.traceback())
	if self.itemSprite[ItemSpriteType.kItemShow] then
		if self.itemSprite[ItemSpriteType.kItemShow]:getParent() then
			self.itemSprite[ItemSpriteType.kItemShow]:removeFromParentAndCleanup(true)
		end
		self.itemSprite[ItemSpriteType.kItemShow] = nil
	end
end

---------------------------------------------------------------------------------------------
--								..*.* Sunflower *.*..
---------------------------------------------------------------------------------------------
function ItemView:buildSunFlask(level, isOnlyGetSprite)
	-- printx(11, "buildSunFlask", level, debug.traceback())
	local sprite = TileSunFlask:create(level)

	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
	end
	return sprite
end

function ItemView:playSunFlaskBeingHit(currLevel)
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite then
		sprite:playDecreaseAnimation(currLevel)
	end
end

-----------------------------------
function ItemView:buildSunflower(isOnlyGetSprite)
	local mainLogic = GameBoardLogic:getCurrentLogic()
	local countDownVal = SunflowerLogic:getSunflowerLackedEnergy(mainLogic)

	local sprite = TileSunflower:create(countDownVal)

	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
	end
	return sprite
end

function ItemView:playSunflowerAbsorbSun(fromPos, toPos, newNumVal)
	-- local layer = self.getContainer(ItemSpriteType.kBlocker195Effect)
	local layer = self.getContainer(ItemSpriteType.kBlockerCommonEffect)
	if layer then
		local sunflowerSprite = self.itemSprite[ItemSpriteType.kItemShow]
		if sunflowerSprite then
			if newNumVal then
				sunflowerSprite:playSunflowerAbsorbSunSelfPart(newNumVal)
			else
				local animate = sunflowerSprite:playSunflowerAbsorbSun(fromPos, toPos)
				layer:addChild(animate)
			end
		end
	end
end

function ItemView:decreaseSunflowerNumViewRespectively()
	local sunflowerSprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sunflowerSprite then
		sunflowerSprite:decreaseSunflowerNumView()
	end
end

function ItemView:removeSunflowerView()
	local sunflowerSprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sunflowerSprite then
		sunflowerSprite:removeSunflowerView()
	end
end

---------------------------------------------------------------------------------------------
--								..+.+* Firecracker *+.+..
---------------------------------------------------------------------------------------------
function ItemView:buildFirecracker(data, isOnlyGetSprite)
	local targetColour = data._encrypt.ItemColorType
	local colourIndex = AnimalTypeConfig.convertColorTypeToIndex(targetColour)

	local sprite = TileFirecracker:create(colourIndex)
	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
	end
	return sprite
end

function ItemView:cleanFirecrackerView()
	-- printx(11, " ItemView:cleanFirecrackerView.", debug.traceback())
	if self.itemSprite[ItemSpriteType.kItemShow] then
		if self.itemSprite[ItemSpriteType.kItemShow]:getParent() then
			self.itemSprite[ItemSpriteType.kItemShow]:removeFromParentAndCleanup(true)
		end
		self.itemSprite[ItemSpriteType.kItemShow] = nil
	end
end

function ItemView:playFirecrackerBeingHit()
	-- printx(11, " =+ + + + + + + playFirecrackerBeingHit + + + + + + +=")
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite then
		sprite:playBeingHitAnimation()
	end
end

function ItemView:explodeFirecracker()
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite then
		sprite:switchToFirecrackerBlastAnimation()
	end
end

function ItemView:playBoomByFirecrackerFromPos(colourIndex, directionGap, animType, fromCCP, callback)
	local boom = Sprite:createWithSpriteFrameName("blocker_firecracker_single_"..colourIndex.."_0000")

	local oriScale = 0.87
	local wholeYShift = 33
	local perRotateAngle = 9
	local preXShift = 11

	local toCCP = self:getBasePosition(self.x, self.y)

	local fromPos = {x = fromCCP.x, y = fromCCP.y - wholeYShift}
	local toPos = {x = toCCP.x, y = toCCP.y - 2}

	if animType == 1 then
		boom:setPositionXY( fromPos.x - preXShift , fromPos.y )
		boom:setScale( 1 * oriScale )
		boom:setRotation(-perRotateAngle)
	elseif animType == 2 then
		boom:setPositionXY( fromPos.x + preXShift , fromPos.y )
		boom:setScale( 1 * oriScale )
		boom:setRotation(perRotateAngle)
	elseif animType == 3 then
		boom:setPositionXY( fromPos.x , fromPos.y - 3 )
		boom:setScale( 1 * oriScale )
	end

	local function onBoomAnimComplete()
		if self.itemSprite[ItemSpriteType.kTopLevelEffect] then
			self.itemSprite[ItemSpriteType.kTopLevelEffect]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kTopLevelEffect] = nil
		end
	end

	local function onRemoveBoom()
		if self.itemSprite[ItemSpriteType.kSpecial] then
			self.itemSprite[ItemSpriteType.kSpecial]:removeFromParentAndCleanup(true)
			self.itemSprite[ItemSpriteType.kSpecial] = nil
		end
		if callback then callback() end
	end

	local function bezierCompleteCallback()
	end

	local function showBoomEff()
		local boomEff, boomEffAnimate = SpriteUtil:buildAnimatedSprite(1/24, "blocker_firecracker_effect_blast_%04d", 1, 24, false)
		boomEff:play(boomEffAnimate, 0, 1, onBoomAnimComplete, false)
		boomEff:setPositionXY( toPos.x , toPos.y )
		self.itemSprite[ItemSpriteType.kTopLevelEffect] = boomEff
		self.isNeedUpdate = true
	end

	local flyDuration = 0.5
	local function runAct1()
		local controlPoint = nil
		controlPoint = ccp(toPos.x - (toPos.x - fromPos.x) / 5, toPos.y + 600 + wholeYShift)

		local bezierConfig = ccBezierConfig:new()
		bezierConfig.controlPoint_1 = ccp(fromPos.x, fromPos.y)
		bezierConfig.controlPoint_2 = controlPoint
		bezierConfig.endPosition = ccp(toPos.x, toPos.y + wholeYShift)
		local bezierAction = CCBezierTo:create(flyDuration, bezierConfig)
		local callbackAction = CCCallFunc:create( bezierCompleteCallback )
		-- local delayAction = CCDelayTime:create(0.1)
		local fadeAction = CCFadeOut:create(0.1)

		local actionList = CCArray:create()
		actionList:addObject(bezierAction)
		actionList:addObject(callbackAction)
		-- actionList:addObject(delayAction)
		actionList:addObject(fadeAction)
		actionList:addObject(CCCallFunc:create(onRemoveBoom))
		local sequenceAction = CCSequence:create(actionList)

		boom:runAction(sequenceAction)

		local actionList2 = CCArray:create()
		actionList2:addObject(CCDelayTime:create(flyDuration))
		actionList2:addObject(CCCallFunc:create(showBoomEff))

		boom:runAction(CCSequence:create(actionList2))
	end

	local function runAct2()
		local actArr = CCArray:create()
		-- 尝试模拟一下近似于Beziel曲线的旋转………就决定是你了！小旋转！
		local directionFlag = 1
		if directionGap < 0 then directionFlag = -1 end
		local midSplitPercent = 0.7
		local splitPercent = 0.5 + (0.95 - 0.5) / 8 * (8 - math.abs(directionGap))

		local rotateTime1 = flyDuration * midSplitPercent * splitPercent
		local rotateTime2 = flyDuration * midSplitPercent * (1 - splitPercent)
		local rotateTime3 = flyDuration * (1 - midSplitPercent) * (1 - splitPercent)
		local rotateTime4 = flyDuration * (1 - midSplitPercent) * splitPercent
		local angle1 = 90 * (1 - splitPercent)
		local angle2 = 90
		local angle3 = 180 - 90 * (1 - splitPercent)
		local angle4 = 180

		actArr:addObject(CCRotateTo:create(rotateTime1, angle1 * directionFlag))
		actArr:addObject(CCRotateTo:create(rotateTime2, angle2 * directionFlag))
		actArr:addObject(CCRotateTo:create(rotateTime3, angle3 * directionFlag))
		actArr:addObject(CCRotateTo:create(rotateTime4, angle4 * directionFlag))

		boom:runAction( CCSequence:create(actArr) )
	end

	local t1 = 0.1
	local actArr2 = CCArray:create()

	local pressAnim = CCScaleTo:create(t1, oriScale , 0.5*oriScale)
	local pressMoveAnim = CCMoveBy:create(t1, ccp(0, 13))
	local press = CCSpawn:createWithTwoActions(pressAnim, pressMoveAnim)
	actArr2:addObject(press)
	local bounceAnim = CCScaleTo:create(t1, oriScale , 1*oriScale)
	local bounceMoveAnim = CCMoveBy:create(t1, ccp(0, 0))
	local bounce = CCSpawn:createWithTwoActions(bounceAnim, bounceMoveAnim)
	actArr2:addObject(bounce)

	actArr2:addObject( CCCallFunc:create( function () 
			runAct1()
			runAct2()
		end) )

	boom:runAction( CCSequence:create(actArr2) )

	local actArr3 = CCArray:create()

	if animType == 1 then
		actArr3:addObject( CCEaseSineOut:create( CCMoveTo:create(t1, ccp(fromPos.x - 11 , fromPos.y - 15) ) ) )
		actArr3:addObject( CCEaseSineIn:create( CCMoveTo:create(t1, ccp(fromPos.x - 11 , fromPos.y) ) ) )
	elseif animType == 2 then
		actArr3:addObject( CCEaseSineOut:create( CCMoveTo:create(t1, ccp(fromPos.x + 11 , fromPos.y - 15) ) ) )
		actArr3:addObject( CCEaseSineIn:create( CCMoveTo:create(t1, ccp(fromPos.x + 11 , fromPos.y) ) ) )
	elseif animType == 3 then
		actArr3:addObject( CCEaseSineOut:create( CCMoveTo:create(t1, ccp(fromPos.x , fromPos.y - 15) ) ) )
		actArr3:addObject( CCEaseSineIn:create( CCMoveTo:create(t1, ccp(fromPos.x , fromPos.y) ) ) )
	end

	boom:runAction( CCSequence:create(actArr3) )

	self.itemSprite[ItemSpriteType.kSpecial] = boom

	local function forceRemoveBoom()
		if boom and boom:getParent() and not boom.isDisposed then
			boom:stopAllActions()
			boom:removeFromParentAndCleanup(true)
		end
		if self.itemSprite[ItemSpriteType.kSpecial] == boom then
			self.itemSprite[ItemSpriteType.kSpecial] = nil
		end
	end

	setTimeOut(forceRemoveBoom, 1)

	self.isNeedUpdate = true	
end

--------------------------------------------------------------------------
--								Squid
--------------------------------------------------------------------------
function ItemView:buildSquid(data, isOnlyGetSprite)
	local mainLogic = GameBoardLogic:getCurrentLogic()

	local texture
	if self.getContainer(ItemSpriteType.kSquidShow) then 
		texture = self.getContainer(ItemSpriteType.kSquidShow).refCocosObj:getTexture()
	end
	local sprite = TileSquid:create(texture, data.squidDirection, data.squidTargetType, data.squidTargetNeeded, data.squidTargetCount)
	-- printx(11, "= = = buildSquid = = =", data.squidDirection, data.squidTargetType, data.squidTargetNeeded, data.squidTargetCount)

	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kSquidShow] = sprite
	end
	return sprite
end

function ItemView:playSquidTargetFly(fromPos, toPos, newTargetAmount)
	local layer = self.getContainer(ItemSpriteType.kBlockerCommonEffect)
	if layer then
		local sprite = self.itemSprite[ItemSpriteType.kSquidShow]
		if sprite then
			local animate = sprite:playSquidAbsorbTarget(fromPos, toPos, newTargetAmount)
			if animate then
				layer:addChild(animate)
			end
		end
	end
end

function ItemView:playSquidRun(gridLength, startPos)
	local layer = self.getContainer(ItemSpriteType.kBlockerCommonEffect)
	if layer then
		local sprite = self.itemSprite[ItemSpriteType.kSquidShow]
		if sprite then
			local animate = sprite:playSquidRun(gridLength, startPos)
			layer:addChild(animate)
		end
	end
end

function ItemView:squidCommonDestroyItemAnimation(layerType)
	-- printx(11, "==== === squidCommonDestroyItemAnimation", layerType)
	if not layerType then
		layerType = ItemSpriteType.kItemShow
	end
	local sprite = self.itemSprite[layerType]
	if sprite and not sprite.isDisposed then
		-- printx(11, "has sprite", sprite)
		-- printx(11, "sprite.sprite", sprite.sprite)
		-- printx(11, "sprite.itemSprite", sprite.itemSprite)
		-- printx(11, "sprite.mainSprite", sprite.mainSprite)
		-- printx(11, "sprite.stoneSprite", sprite.stoneSprite)
		local targetSprite = sprite.sprite
		if not targetSprite then targetSprite = sprite.itemSprite end
		if not targetSprite then targetSprite = sprite.mainSprite end 	-- 毛球叫这个……
		-- if not targetSprite then targetSprite = sprite.stoneSprite end  -- 魔法石除了影子 & 炮塔，但是他们都能用下面的sprite
		if not targetSprite then targetSprite = sprite end 				-- 寄居蟹…………保险起见这个放在最后吧
		if targetSprite and not targetSprite.isDisposed then
			-- printx(11, "deal with animation")
			local function onWholeAnimFinished()
				-- printx(11, "!!!!!!  !!!!!! onWholeAnimFinished")
				sprite:removeFromParentAndCleanup(true)
			
				self.isNeedUpdate = true
			end

			self.itemSprite[layerType] = nil 	--切断关联

			targetSprite:stopAllActions()

			local function onRepeatFinishCallback_DestroyEffect()
				if sprite.destroySprite and sprite.destroySprite:getParent() then
					sprite:removeChild(sprite.destroySprite)
				end
			end 

			local destroySprite = ItemViewUtils:buildAnimalDestroyEffect(6, onRepeatFinishCallback_DestroyEffect)
			sprite.destroySprite = destroySprite
			sprite:addChildAt( destroySprite , 1 )

			local removeAct = CCSequence:createWithTwoActions(CCScaleTo:create(0.3, 0.01), CCFadeOut:create(0.3))
			local wholeAct = CCSequence:createWithTwoActions(removeAct, CCCallFunc:create(onWholeAnimFinished))
			targetSprite:runAction(wholeAct)
		end
	end
end

function ItemView:squidDestroyPacmansDenAnimation()
	local sprite = self.itemSprite[ItemSpriteType.kPacmanShow]

	local function finishCallback()
		if sprite then
			sprite:removeViewPack()
			sprite:removeFromParentAndCleanup(true)
		end
		self.itemSprite[ItemSpriteType.kSpecial] = nil
		self.isNeedUpdate = true
	end

	if sprite then
		self.itemSprite[ItemSpriteType.kPacmanShow] = nil
		self.itemSprite[ItemSpriteType.kSpecial] = sprite

		local removeAct = CCSequence:createWithTwoActions(CCScaleTo:create(0.3, 0.01), CCFadeOut:create(0.3))
		local wholeAct = CCSequence:createWithTwoActions(removeAct, CCCallFunc:create(finishCallback))
		sprite:runAction(wholeAct)
	end
end


--------------------------------------------------------------------------
--								WanSheng
--------------------------------------------------------------------------
function ItemView:buildWanSheng(data, isOnlyGetSprite)
    
    if not data.wanShengConfig then
        --如果没有配置信息 说明从生成口生成的 现读配置
        local Config
        local mainLogic = GameBoardLogic:getCurrentLogic()
	    if mainLogic then
            local levelID = mainLogic.level
            local levelConfig = LevelDataManager.sharedLevelData():getLevelConfigByID(levelID)

            if levelConfig.wanShengDropConfig then
                for i,v in pairs( levelConfig.wanShengDropConfig ) do
                    local key = (data.y-1).."_"..(data.x-1)
                    if i == key and  v.mType ~= 0 and v.num ~= 0 then
                        Config = table.clone( v )
                    end
                end
            end

            if not Config then
                Config = table.clone( levelConfig.wanShengNormalConfig )
            end
        end

        data.wanShengConfig = Config
    end

    local sprite = TileWanSheng:create(data.wanShengLevel, data.wanShengConfig)
	if not isOnlyGetSprite then
		self.itemSprite[ItemSpriteType.kItemShow] = sprite
	end
	return sprite
end

function ItemView:playWanShengDec( times )
	-- body
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	if sprite then
		sprite:playIncreaseAnimation(times)
--		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayHoneybottleMatch )
	end
end

function ItemView:playWanShengBroken( callback )
	-- body
	local sprite = self.itemSprite[ItemSpriteType.kItemShow]
	local function animationCallback()
		if sprite then sprite:removeFromParentAndCleanup(true) end
		self.itemSprite[ItemSpriteType.kItemShow] = nil
		if callback then callback() end
	end

	if sprite then
		sprite:playBrokenAnimation(animationCallback)
--		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayHoneybottleCasting )
	end
end

function ItemView:playWanShengEndFlyAnimation( config, fromPos, callback, honeyLevel)

	-- body
	local flyAnimation = nil

--	local function finishCallback( ... )
--		-- body
--		local honey = self.itemSprite[ItemSpriteType.kItemShow] --对应障碍的层
--		self.isNeedUpdate = true
--		if honey then honey:normal() end
--	end

	local function flyCallback()
		-- body
		if flyAnimation then flyAnimation:removeFromParentAndCleanup(true) end
		self.itemSprite[ItemSpriteType.kSpecial] = nil

--        local targetId = config.mType 
--        if targetId then
--            --飞的障碍

----            CreateFallingClippingSprite

----            if targetId == then

--		    local honey = TileHoney:create(honeyLevel)
--		    honey:setPosition(self:getBasePosition(self.x, self.y))
--		    honey:add(finishCallback)
--		    self.itemSprite[ItemSpriteType.kItemShow] = honey --对应障碍的层
--        end

		if callback then callback() end
		self.isNeedUpdate = true
	end

	flyAnimation= TileWanSheng:createFlyAnimation(fromPos, self:getBasePosition(self.x, self.y),  flyCallback)
	self.itemSprite[ItemSpriteType.kSpecial] = flyAnimation
	self.isNeedUpdate = true
end

--------------------------------------------------------------------------