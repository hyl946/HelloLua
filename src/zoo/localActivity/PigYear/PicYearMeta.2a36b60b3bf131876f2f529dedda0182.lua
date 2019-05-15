local PicYearMeta = {}

PicYearMeta.SLOT_NUM = 8
PicYearMeta.INIT_UNLOCKED_SLOT_NUM = 3

local function minute2ms( m )
	return m * 60 * 1000
end

PicYearMeta.SLOT_CD = {
	minute2ms(30),
	minute2ms(25),
	minute2ms(20),
	minute2ms(15),
}

PicYearMeta.GoodsId = {
	kSpeedUp = 582,

	kUpgradeSlot1 = 627,
	kUpgradeSlot2 = 628,
	kUpgradeSlot3 = 629,

	kSlot1 = 0,
	kSlot2 = 0,
	kSlot3 = 0,

	kSlot4 = 630,
	kSlot5 = 631,
	kSlot6 = 632,
	kSlot7 = 633,
	kSlot8 = 634,
}

PicYearMeta.speedUpGoodsId = function(index)
	return 618+index
end

PicYearMeta.SPEED_UP_UNIT = minute2ms(5)
PicYearMeta.MAX_SLOT_LEVEL = 4
PicYearMeta.MAX_BAG_LEVEL = 4
PicYearMeta.MAX_BAG_MULTIPLE = 4

PicYearMeta.ACT_LEVEL_NUM = 15
PicYearMeta.ACT_LEVEL_RANGE = {
	330101, 330115
}

PicYearMeta.SkillCost = { 60,60,60,60 }
PicYearMeta.SkillStepNeed = { 5,0,5,5 }

PicYearMeta.ItemIDs = {
	GEM_1 = 50071,
	GEM_2 = 50070,
	GEM_3 = 50072,
	GEM_4 = 50073,

	SPEEDUP_CARD = 50040 ,

	BAG_LEVELUP = 50039,

	LUCKY_BAG_M_1 = -30001 + 1,
	LUCKY_BAG_M_2 = -30001 + 2,
	LUCKY_BAG_M_3 = -30001 + 3,
	LUCKY_BAG_M_4 = -30001 + 4,

	GOLD = 50045,
--	SILVER = 50046,
}

PicYearMeta.FULL_LEVEL = 2055

PicYearMeta.LEVEL_TYPE = GameLevelType.kSpring2019

PicYearMeta.BonsTimeMaxNum = 5 --步数结算
PicYearMeta.ADDFIVE_ADD_GETNUM = 10 --购买加5步送宝石数量

return PicYearMeta