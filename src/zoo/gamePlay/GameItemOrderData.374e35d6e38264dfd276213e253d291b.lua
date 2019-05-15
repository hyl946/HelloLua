
require "zoo.util.MemClass"

local __encryptKeys = {
	f1 = true
}
GameItemOrderData = memory_class_simple(__encryptKeys)

GameItemOrderType = table.const
{
	kNone = 0,
	kAnimal = 1,                --收集小动物，后面的数字代表颜色 1~6 蓝绿棕紫红黄  例：1_4 紫色小动物
	kSpecialBomb = 2,           --收集特效
	kSpecialSwap = 3,           --收集特效交换
	kSpecialTarget = 4,         --特殊障碍（并没有啥道理的分类）
	kOthers = 5,                --其它障碍（并没有啥道理的分类）
	kSeaAnimal = 6,             --海洋生物
}

GameItemOrderType_SB = table.const -- Special Bomb  收集特效
{
	kLine = 1, --横线
	kWrap = 2, --竖线
	kColor = 3,--魔力鸟
}

GameItemOrderType_SS = table.const -- Special Swap  收集特效交换
{
	kLineLine = 1,   --直线&直线
	kWrapLine = 2,   --爆炸&直线
	kColorLine = 3,  --魔力鸟&直线
	kWrapWrap = 4,   --爆炸&爆炸
	kColorWrap = 5,  --魔力鸟&爆炸
	kColorColor = 6  --鸟鸟交换
}

GameItemOrderType_ST = table.const -- Special Target 特殊障碍（并没有啥道理的分类）
{
	kSnowFlower = 1,     --雪块
	kCoin = 2,           --银币
	kVenom = 3,          --毒液
	kSnail = 4,          --蜗牛
	kGreyCuteBall = 5,   --灰毛球
	kBrownCuteBall = 6,  --棕毛球
	kBottleBlocker = 7,  --精灵萌豆
	kChristmasBell = 8,  --圣诞铃铛
}

GameItemOrderType_Others = table.const --其它障碍（并没有啥道理的分类）
{
	kBalloon = 1,               --气球
	kBlackCuteBall = 2,         --黑毛球
	kHoney = 3,                 --蜂蜜
	kSand = 4,                  --流沙
	kMagicStone = 5,            --魔法石
	kBoomPuffer = 6,            --气鼓鱼
	kBlockerCoverMaterial = 7,  --小木桩
	kBlockerCover = 8,          --小叶堆
	kBlocker195 = 9,            --星星瓶子
	kChameleon = 10,			--变色龙
	kPacman = 11,				--吃豆人
	kGhost = 12,				--幽灵
    kJamSperad = 13,             --果酱
    kSquid = 14,             	--鱿鱼
    kBiscuit = 15, 				--夹心饼干
    kMilks = 16, 				--夹心饼干 奶油 【虚拟order 不显示 只有数据】
}

GameItemOrderTypeInvisible = {
	{key1 = GameItemOrderType.kOthers, key2 = GameItemOrderType_Others.kMilks},
}

GameItemOrderType_SeaAnimal = table.const   --海洋生物
{
	kPenguin = 1,    --企鹅
	kSeal 	 = 2,    --海豹
	kSeaBear = 3,    --熊
	kMistletoe = 4,
	kScarf = 5,--废弃 
	kElk = 6,
	kSea_3_3 = 7,
    kScaf_H = 8,
    kScaf_V = 9,
}

function GameItemOrderData:isInvisible( key1, key2 )

	local key1 = key1 or self.key1
	local key2 = key2 or self.key2

	for _, v in ipairs(GameItemOrderTypeInvisible) do
		if key1 == v.key1 and key2 == v.key2 then
			return true
		end
	end
	return false
end

--local currGameItemOrderDataClassID = 0
function GameItemOrderData:ctor()
--	currGameItemOrderDataClassID = currGameItemOrderDataClassID + 1
--	self.__class_id = currGameItemOrderDataClassID
--	self.encryptValueKey = "GameItemOrderData."..self.__class_id

	self.key1 = 0;
	self.key2 = 0;
	self.v1 = 0;
	self.f1 = 0;
end

function GameItemOrderData:getEncryptKey(key)
	return key .. "_" .. self.__class_id
end

function GameItemOrderData:encryptionFunc( key, value )
--	if key == "f1" then
	assert(__encryptKeys[key])
		encrypt_integer_f(self:getEncryptKey(key), value)
--		return true
--	end
--	return false
end
function GameItemOrderData:decryptionFunc( key )
--	if key == "f1" then
	assert(__encryptKeys[key])
		return decrypt_integer_f(self:getEncryptKey(key))
--	end
--	return nil
end

function GameItemOrderData:dispose()
	--HeMemDataHolder:deleteByKey(self.encryptValueKey)
	for key, value in pairs(__encryptKeys) do
		mem_deleteByKey(self:getEncryptKey(key))
	end
end

-- k1 = GameItemOrderType, k2 = GameItemOrderType_**, v1 = 目标数 , f1 = finished(完成的)
function GameItemOrderData:create(k1,k2,v1)
	local v = GameItemOrderData.new()
	v.key1 = k1
	v.key2 = k2
	v.v1 = v1;
	return v
end

function GameItemOrderData:copy()
	local r = GameItemOrderData.new()
	r.key1 = self.key1
	r.key2 = self.key2
	r.v1 = self.v1
	r.f1 = self.f1
	return r
end