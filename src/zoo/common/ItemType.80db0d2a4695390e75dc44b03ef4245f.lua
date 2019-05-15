
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年10月23日 13:53:49
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com
--

-- assert(not ItemType)

ItemType = {
	INGAME_REFRESH 			= 10001, 
	INGAME_BACK    			= 10002,
	INGAME_SWAP    			= 10003,
	-- Add Step
	ADD_FIVE_STEP	        = 10004,
	ADD_BOMB_FIVE_STEP 		= 10078, --周赛清全屏加五步
	ADD_15_STEP				= 10086, --加十五步

	INGAME_BRUSH 			=  10005,
	INITIAL_2_SPECIAL_EFFECT	= 10007,
	INGAME_HAMMER 			= 10010,
	INGREDIENT 			= 10011,
	-- Energy Bottle
	SMALL_ENERGY_BOTTLE	= 10012,
	MIDDLE_ENERGY_BOTTLE	= 10013,
	LARGE_ENERGY_BOTTLE	= 10014,
	INGAME_PRE_REFRESH	= 10015,
	ADD_THREE_STEP	= 10018,
	INFINITE_ENERGY_BOTTLE	= 10039,
	--兔兔导弹
	RABBIT_MISSILE = 10040,

	ACT_PLACY_CARD_29 = 10049,
	ACT_PLACY_CARD_59 = 10050,
	ACT_PLACY_CARD_99 = 10051,

	OCTOPUS_FORBID = 10052,
	RANDOM_BIRD    = 10055,
	BROOM 		   = 10056,
	RABBIT_WEEKLY_PLAY_CARD = 10054,
	WEEKLY_DAZHAO = 10080,

	DIAMONDS		= 10085, --钻石，用于在加五步面板抽奖

	TIMELIMIT_BACK 	= 10058,
	TIMELIMIT_REFRESH 	= 10059,
	TIMELIMIT_HAMMER 	= 10060,
	TIMELIMIT_BRUSH 	= 10061,
	TIMELIMIT_ADD_FIVE_STEP = 10062,
	TIMELIMIT_SWAP 	= 10063,
	TIMELIMIT_BROOM 	= 10064,
	TIMELIMIT_RANDOM_BIRD = 10066,
	TIMELIMIT_OCTOPUS_FORBID = 10067,
	TIMELIMIT_ADD_BOMB_FIVE_STEP = 10079, --周赛清全屏加五步

	TIMELIMIT_INITIAL_2_SPECIAL_EFFECT = 10069,
	TIMELIMIT_INGAME_PRE_REFRESH = 10070,
	TIMELIMIT_ADD_THREE_STEP = 10071,

	OLYMPIC_ADD_FIVE = 10068,
	THIRD_ANNIVERSARY_ADD_FIVE = 10077,
	NATIONDAY2017_ADD_FIVE = 10077,

	PRE_WRAP_BOMB = 10081,
	PRE_LINE_BOMB = 10082,
	TIMELIMIT_PRE_WRAP_BOMB = 10083,
	TIMELIMIT_PRE_LINE_BOMB = 10084,

	PRE_RANDOM_BIRD = 10087,
	TIMELIMIT_PRE_RANDOM_BIRD = 10088,
	PRE_BUFF_BOOM = 10089,
	TIMELIMIT_PRE_BUFF_BOOM = 10090,

	TIMELIMIT_48_HAMMER 	= 10092,
	TIMELIMIT_48_BRUSH 	= 10093,
	TIMELIMIT_48_ADD_BOMB_FIVE_STEP = 10091, --周赛清全屏加五步

	ADD_FIVE_STEP_BY_BALLOON = 10094, --加五步（气球专用）
	ADD_FIVE_STEP_BY_ANIMAL = 10095, --加N步（加步数动物专用）

	TIMELIMIT_48_BACK = 10096,
	TIMELIMIT_48_INITIAL_2_SPECIAL_EFFECT = 10097,

	INFINITE_ENERGY_BOTTLE_ONE_MINUTE = 10098, --无限精力一分钟、获得多个会合并在背包显示

	PRE_FIRECRACKER = 10099, 			-- 前置爆竹（产品名：前置导弹）
	TIMELIMIT_PRE_FIRECRACKER = 10100, 	-- 限时前置爆竹（产品名：限时前置导弹）

    DOUBLEEGGPLAYTIME = 10101, --双蛋打折次数
    DOUBLEEGGPLAYTIME2 = 10102, --双蛋次数
    JAMSPEARD_HUMMER = 10103, --果酱锤子
    JAMSPEARD_ADD_FIVE = 10104, --果酱加5步

    INGAME_ROW_EFFECT = 10105,					--游戏内 横特效
    TIMELIMIT_INGAME_ROW_EFFECT = 10106,		--游戏内 横特效（24H）
    TIMELIMIT_48_INGAME_ROW_EFFECT = 10107,		--游戏内 横特效（48H）
    INGAME_COLUMN_EFFECT = 10109,				--游戏内 竖特效
    TIMELIMIT_INGAME_COLUMN_EFFECT = 10110,		--游戏内 竖特效（24H）
    TIMELIMIT_48_INGAME_COLUMN_EFFECT = 10111,	--游戏内 竖特效（48H）

    ADD_1_STEP = 10115,
    ADD_2_STEP = 10116,
    VOUCHER = 10117,

	-- Energy Lightning
	ENERGY_LIGHTNING	= 4,
	COIN			= 2,
	REOPEN_LADYBUG_TASK	= 8,
	GOLD			= 14,
	HOURGLASS 				= 10029,
	GEM 					= 10, -- dig gems
	MOONCAKE				= 11,
	MAYDAY_BOSS				= 12,
	HOLYCUP					= 11, -- 感恩节模式（活动不会同时存在，不存在冲突）
	THANKSGIVING_BOSS			= 12,
	WEEKLY_RABBIT     = 13,
	XMAS_BELL				= 10,
	XMAS_BOSS				= 12,
	-- 6  最终加5步
	-- 15 世界杯足球
	ADD_TIME			= 16, -- 最终加15秒

	KEY_GOLD            = 17,  ---解锁钥匙，临时展示用
	KWATER_MELON        = 18,
	KELEPHANT           = 19,
	WUKONG           = 20,
	CLOTHES_PIECE 		= 21, ---周赛碎片

	RACE_PLAY_CARD = 50101, 	--鼹鼠周赛次数
	RACE_TARGET_0 = 50103,		--鼹鼠周赛红宝石
	RACE_TARGET_1 = 50102,		--鼹鼠周赛黄宝石
    RACE_TARGET_2 = 50104,		--鼹鼠周赛黄宝石2 没有这个道具。占位换图用

	STAR_BANK_GOLD = 50015,

	ACT_RECALL_POINT = 50017,	--召回活动 兑换特权消耗的道具 point是zhou.ding起的名

	FULL_STAR_SCORE = 50299,
	COLLECT_STAR_2019 = 10113,  --2019刷星活动买次数 id错配成了1开头 加白名单 不进背包

	UNKNOW_1 = 10072, 			--不知道干啥的  

    MARK2019BUQIANITEM = 10114, 			--签到补签道具
}

-- Pre Game Property Type, 
-- Each Type Go To Different Location When Game Start
PrePropType = {
	ADD_STEP		= 1,
	REDUCE_TARGET		= 2,
	TAKE_EFFECT_IN_BOARD	= 3,
	ADD_TO_BAR		= 4
}

ItemNotInBag = {
	[ItemType.RABBIT_WEEKLY_PLAY_CARD] = true,
	[ItemType.WEEKLY_DAZHAO] = true,
	[ItemType.RACE_PLAY_CARD] = true,
	-- 1.37开始，前置道具可以进背包
	-- [ItemType.INGAME_PRE_REFRESH] = true,
	-- [ItemType.INITIAL_2_SPECIAL_EFFECT] = true,
	-- [ItemType.ADD_THREE_STEP] = true,
	--[ItemType.OLYMPIC_ADD_FIVE] = true,
	--[ItemType.THIRD_ANNIVERSARY_ADD_FIVE] = true,
	[ItemType.ACT_PLACY_CARD_29] = true,
	[ItemType.ACT_PLACY_CARD_59] = true,
	[ItemType.ACT_PLACY_CARD_99] = true,
	[ItemType.ACT_RECALL_POINT] = true,
    [ItemType.DOUBLEEGGPLAYTIME] = true,
    [ItemType.DOUBLEEGGPLAYTIME2] = true,
    [ItemType.MARK2019BUQIANITEM] = true,
    [ItemType.COLLECT_STAR_2019] = true, 
}

TimePropMap = {
	[ItemType.TIMELIMIT_BACK] = ItemType.INGAME_BACK,
	[ItemType.TIMELIMIT_48_BACK] = ItemType.INGAME_BACK,
	[ItemType.TIMELIMIT_REFRESH] = ItemType.INGAME_REFRESH,
	[ItemType.TIMELIMIT_HAMMER] = ItemType.INGAME_HAMMER,
	[ItemType.TIMELIMIT_BRUSH] = ItemType.INGAME_BRUSH,
	[ItemType.TIMELIMIT_ADD_FIVE_STEP] = ItemType.ADD_FIVE_STEP,
	[ItemType.TIMELIMIT_SWAP] = ItemType.INGAME_SWAP,
	[ItemType.TIMELIMIT_BROOM] = ItemType.BROOM,
	[ItemType.TIMELIMIT_RANDOM_BIRD] = ItemType.RANDOM_BIRD,
	[ItemType.TIMELIMIT_OCTOPUS_FORBID] = ItemType.OCTOPUS_FORBID,

	[ItemType.TIMELIMIT_INITIAL_2_SPECIAL_EFFECT] = ItemType.INITIAL_2_SPECIAL_EFFECT,
	[ItemType.TIMELIMIT_48_INITIAL_2_SPECIAL_EFFECT] = ItemType.INITIAL_2_SPECIAL_EFFECT,
	[ItemType.TIMELIMIT_INGAME_PRE_REFRESH] = ItemType.INGAME_PRE_REFRESH,
	[ItemType.TIMELIMIT_ADD_THREE_STEP] = ItemType.ADD_THREE_STEP,
	[ItemType.TIMELIMIT_PRE_WRAP_BOMB] = ItemType.PRE_WRAP_BOMB,
	[ItemType.TIMELIMIT_PRE_LINE_BOMB] = ItemType.PRE_LINE_BOMB,
	[ItemType.TIMELIMIT_ADD_BOMB_FIVE_STEP] = ItemType.ADD_BOMB_FIVE_STEP,

	[ItemType.TIMELIMIT_PRE_RANDOM_BIRD] = ItemType.PRE_RANDOM_BIRD,
	[ItemType.TIMELIMIT_PRE_BUFF_BOOM] = ItemType.PRE_BUFF_BOOM,

	[ItemType.TIMELIMIT_48_HAMMER] = ItemType.INGAME_HAMMER,
	[ItemType.TIMELIMIT_48_BRUSH] = ItemType.INGAME_BRUSH,
	[ItemType.TIMELIMIT_48_ADD_BOMB_FIVE_STEP] = ItemType.ADD_BOMB_FIVE_STEP,

	[ItemType.TIMELIMIT_PRE_FIRECRACKER] = ItemType.PRE_FIRECRACKER,

	[ItemType.TIMELIMIT_INGAME_ROW_EFFECT] = ItemType.INGAME_ROW_EFFECT,
	[ItemType.TIMELIMIT_48_INGAME_ROW_EFFECT] = ItemType.INGAME_ROW_EFFECT,
	[ItemType.TIMELIMIT_INGAME_COLUMN_EFFECT] = ItemType.INGAME_COLUMN_EFFECT,
	[ItemType.TIMELIMIT_48_INGAME_COLUMN_EFFECT] = ItemType.INGAME_COLUMN_EFFECT,
}

TimeLimitPropType = {
	k24Hour = 1,
	k48Hour = 2,
}

local TimeProp48HourMap = {
	ItemType.TIMELIMIT_48_HAMMER,
	ItemType.TIMELIMIT_48_BRUSH,
	ItemType.TIMELIMIT_48_ADD_BOMB_FIVE_STEP,
	ItemType.TIMELIMIT_48_BACK,
	ItemType.TIMELIMIT_48_INITIAL_2_SPECIAL_EFFECT,
	ItemType.TIMELIMIT_48_INGAME_ROW_EFFECT,
	ItemType.TIMELIMIT_48_INGAME_COLUMN_EFFECT,
}

PropToTimePropMap = {}
for k, v in pairs(TimePropMap) do
	PropToTimePropMap[v] = k
end

function ItemType:isHappyCoinPreProps(propId)
	assert(type(propId) == "number")
	if propId == ItemType.PRE_RANDOM_BIRD or propId == ItemType.PRE_FIRECRACKER then
		return true
	else
		return false
	end
end

function ItemType:getTimePropItemListByRealId( realItemId  )
	--保证得到的是 realItemId
	realItemId = ItemType:getRealIdByTimePropId( realItemId )
	local propIdList = {}
	for k, v_ReadItemID in pairs(TimePropMap) do
		if v_ReadItemID == realItemId then
			table.insert( propIdList , k )
		end
	end 
	return propIdList
end

function ItemType:getTimePropItemByRealId( propId )
	assert(type(propId) == "number")
	--准备废弃这个接口了 以后用上面的  ItemType:getTimePropItemListByRealId( realItemId  )
	assert( false )
	if PropToTimePropMap[propId] then
		return PropToTimePropMap[propId]
	else
		return propId
	end
end

function ItemType:getRealIdByTimePropId( propId )
	assert(type(propId) == "number")

	if TimePropMap[propId] then
		return TimePropMap[propId]
	else
		return propId
	end
end

function ItemType:isTimeProp(propId)
	local isTimeProp = TimePropMap[propId] ~= nil
	local limitType = nil
	if isTimeProp then
		if table.includes(TimeProp48HourMap, propId) then
			limitType = TimeLimitPropType.k48Hour
		else
			limitType = TimeLimitPropType.k24Hour
		end
	end
	return isTimeProp, limitType
end

function ItemType:inPreProp(propId)
	return propId == ItemType.INITIAL_2_SPECIAL_EFFECT 
	or propId == ItemType.INGAME_PRE_REFRESH 
	or propId == ItemType.ADD_THREE_STEP
	or propId == ItemType.PRE_WRAP_BOMB 
	or propId == ItemType.PRE_LINE_BOMB
	or propId == ItemType.PRE_RANDOM_BIRD
	or propId == ItemType.PRE_BUFF_BOOM
	or propId == ItemType.PRE_FIRECRACKER
end

--是不是限时前置道具
function ItemType:inTimePreProp( propId )
	if ItemType:isTimeProp( propId) then
		return ItemType:inPreProp( ItemType:getRealIdByTimePropId(propId) )
	end
	return false
	or propId == ItemType.TIMELIMIT_PRE_FIRECRACKER
end

function ItemType:isPrePropAddStep(itemType)

	if itemType == ItemType.ADD_FIVE_STEP or
		itemType == ItemType.ADD_THREE_STEP then

			return true
	end

	return false
end

function ItemType:isPrePropReduceTarget(itemType)

	return false
end

function ItemType:isPrePropTakeEffectInBoard(itemType)

	if itemType == ItemType.INITIAL_2_SPECIAL_EFFECT
		or itemType == ItemType.PRE_BUFF_BOOM
		or itemType == ItemType.PRE_RANDOM_BIRD 
		or itemType == ItemType.PRE_WRAP_BOMB 
		or itemType == ItemType.PRE_LINE_BOMB 
		or itemType == ItemType.PRE_FIRECRACKER
		then
		return true
	end

	return false
end

function ItemType:isPrePropAddToBar(itemType)
	-- Note The Check Order In Function ItemType:getPrePropType
	return true
end

function ItemType:getPrePropType(itemType)

	if ItemType:isTimeProp(itemType) then
		itemType = ItemType:getRealIdByTimePropId(itemType)
	end

	if ItemType:isPrePropAddStep(itemType) then
		return PrePropType.ADD_STEP

	elseif ItemType:isPrePropReduceTarget(itemType) then
		return PrePropType.REDUCE_TARGET

	elseif ItemType:isPrePropTakeEffectInBoard(itemType) then
		return PrePropType.TAKE_EFFECT_IN_BOARD
	else

		return PrePropType.ADD_TO_BAR
	end
end

function ItemType:isItemNeedToBeAdd(itemId)
	local itemType = math.floor(itemId / 10000)
	-- if _G.isLocalDevelopMode then printx(0, "itemType = ", itemType) end
	if itemType ~= 1 then return false end -- 非道具
	if ItemNotInBag and ItemNotInBag[itemId] then -- 不需要加入背包
		return false
	end
	return true
end

function ItemType:isEnergyBottle(itemId)
	if itemId ~= nil then
		if itemId == ItemType.SMALL_ENERGY_BOTTLE or
		   itemId == ItemType.MIDDLE_ENERGY_BOTTLE or
		   itemId == ItemType.LARGE_ENERGY_BOTTLE then
		   return true
		end
	end
	
	return false
end

function ItemType:isMergableItem( itemId )
	return table.indexOf({
		ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE
	}, itemId) ~= nil
end

local HeadFrameRange = {60000, 69999}

function ItemType:isHeadFrame( itemId )
	return itemId >= HeadFrameRange[1] and itemId <= HeadFrameRange[2]
end

function ItemType:convertToHeadFrameId( itemId )
	if ItemType:isHeadFrame(itemId) then
		return itemId - HeadFrameRange[1]
	end
end


local HonorRange = {50300, 50499}

function ItemType:isHonor( itemId )
	return itemId >= HonorRange[1] and itemId <= HonorRange[2]
end

-- 因为道具ID可能会对应多个Goods配置，所以锁定代表前置道具的那一条
PrePropsIDToGoodsID = {
  [10087] = 511,
  [10099] = 641,
}

function ItemType:getGoodsIDOfPreProps(propID)
	if PrePropsIDToGoodsID and PrePropsIDToGoodsID[propID] then
		return PrePropsIDToGoodsID[propID]
	end
	return nil
end