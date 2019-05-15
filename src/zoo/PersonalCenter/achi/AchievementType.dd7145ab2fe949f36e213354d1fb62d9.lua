--[[
 * AchiDataType
 * @date    2018-04-02 15:04:00
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local cid = 1000
local function gnext()
	cid = cid + 1
	return tostring(cid)
end

AchiShareType = {
	kLink = 1,
	kImage = 2,
	kNotify = 3,
}

AchiLevelType = {
	kNewer = 1,
	kCopper = 2,
	kSilver = 3,
	kGold = 4,
	kPlatinum = 5,
	kDiamond = 6,
}

AchiId = {
	kUnlockNewObstacle = 50,
	kAreaFullStar = 300,
	kFiveTimesFourStar = 70,
	kTotalFourStarCount = 520,
	kNStarReward = 90,
	kScorePassThousand = 10,
	kContinuePassFiveLevel = 150,
	kFailTimeGFive = 160,
	kLastStepPass = 170,
	kLeftStepGETen = 180,
	kTotalEntryLevelTime = 310,
	kTotalLineEffectCount = 320,
	kTotalBombEffectCount = 330,
	kTotalMagicBirdCount = 340,
	kTotalChangeEffectCount = 350,
	kTotalUsePropCount = 360,
	kTotalSendPrimaryEnergyCount = 370,
	kTotalGetPrimaryEnergyCount = 380,
	kTotalUseEnergyCount = 390,
	kTotalHelpFriendUnlockCount = 400,
	kTotalHelpFriendPassCount = 410,
	kTotalUseWindmillCount = 420,
	kTotalUseCoinCount = 430,
	kTotalGetLikeCount = 200,
	kTotalSendLikeCount = 440,

	kTotalMarkCount = 450,
	kGetFinalMarkChest = 140,
	kTotalEntryWeeklyCount = 460,
	kTotalGetFruitCount = 240,
	kTotalRebirthFruitCount = 470,
	kTotalSpeedUpFruitCount = 480,

	kBindAnyAccount = 490,
	kUseCustomHeadOrNickname = 500,
	kFillUpPersonalInfo = 510,

	--only share
	kPassHighestLevel = 20,
	kFristRankFriend = 30,
	kAreaAllThreeStars = 40,
	kPassLevelFourStars = 80,
	kScoreOverFriend = 110,
	kLevelOverFriend = 120,
	kScoreOverNation = 250,
	kLevelOverNation = 260,
}

AchiDataType = {
	kLevelId = gnext(),
	kLevelType = gnext(),
	kOldScore = gnext(),
	kNewScore = gnext(),
	kOldStar = gnext(),
	kNewStar = gnext(),
	kOldIsJumpLevel = gnext(),
	kGetFinalMarkChest = gnext(),
	kBindAnyAccount = gnext(),
	kUseCustomHeadOrNickname = gnext(),
	kFillUpPersonalInfo = gnext(),
	kLeftStep = gnext(),
	kRankData = gnext(),
	kFriendRank = gnext(),
	kPassFriendNum = gnext(),
	kFriendRankList = gnext(),
	kPassFriendNum = gnext(),
	kScoreOverFriendTable = gnext(),
	kLevelOverFriendTable = gnext(),

	kNationScoreCofig = gnext(),
	kScoreOverNationResult = gnext(),

	kNationLevelCofig = gnext(),
	kLevelOverNationResult = gnext(),

	kUnlockHideLevel = gnext(),

	kOverSelfRank = gnext(),
	kAllScoreRank = gnext(),

	kQuitLevelMode = gnext(),

	kForbidShare = gnext(),

	kEntryLevelTimeAddCount = AchiId.kTotalEntryLevelTime,
	kLineEffectAddCount = AchiId.kTotalLineEffectCount,
	kBombEffectAddCount = AchiId.kTotalBombEffectCount,
	kMagicBirdAddCount = AchiId.kTotalMagicBirdCount,
	kChangeEffectAddCount = AchiId.kTotalChangeEffectCount,
	kUsePropAddCount = AchiId.kTotalUsePropCount,
	kSendPrimaryEnergyAddCount = AchiId.kTotalSendPrimaryEnergyCount,
	kGetPrimaryEnergyAddCount = AchiId.kTotalGetPrimaryEnergyCount,
	kUseEnergyAddCount = AchiId.kTotalUseEnergyCount,
	kHelpFriendUnlockAddCount = AchiId.kTotalHelpFriendUnlockCount,
	kHelpFriendPassAddCount = AchiId.kTotalHelpFriendPassCount,
	kUseWindmillAddCount = AchiId.kTotalUseWindmillCount,
	kUseCoinAddCount = AchiId.kTotalUseCoinCount,
	kGetLikeAddCount = AchiId.kTotalGetLikeCount,
	kSendLikeAddCount = AchiId.kTotalSendLikeCount,
	kMarkAddCount = AchiId.kTotalMarkCount,
	kEntryWeeklyAddCount = AchiId.kTotalEntryWeeklyCount,
	kGetFruitAddCount = AchiId.kTotalGetFruitCount,
	kRebirthFruitAddCount = AchiId.kTotalRebirthFruitCount,
	kSpeedUpFruitAddCount = AchiId.kTotalSpeedUpFruitCount,
}

if Achievement:isDebug() then
	AchiDataType.name = function ( tid )
		for key,id in pairs(AchiDataType) do
			if id == tid then
				return key
			end
		end
	end

	AchiId.name = function ( tid )
		for key,id in pairs(AchiId) do
			if id == tid then
				return key
			end
		end
	end
end