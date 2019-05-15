-- @Author: dan.liang
-- @Date:   2016-05-31 11:22:16
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2017-01-04 17:11:48

DcDataStageMode = {
	kNotDefined = -2,
	kNotInLevel = -1,
	kMainLevel = 0,
	kHideLevel = 1,
	kWeeklyLevel = 2,
	kActivityLevel = 3,
	kRecallLevel = 4,
	kUnlockAreaLevel = 5,
}

DcDataCurrencyType = {
	kCoin = 1,
	kGold = 2,
	kRmb = 3,
}

DcPayType = {
	kCoin = 1,
	kGold = 2,
	kRmb = 3,
	kFree = 4,
}

DcFeatureType = {
	kServer = "server",
	kActivity = "activity",
	kActivityInner = "activity_inner",
	kTrunk = "trunk",
	kRecall = "recall",
	kStore = "store",
	kFruitTree = "fruit_tree",
	kStarBank = "star_bank",
	kMessageCenter = "message_center",
	kShow = "show", 					--分享炫耀？
	kStageStart = "stage_start",
	kStagePlay = "stage_play",
	kStageEnd = "stage_end",
	kRankRace = "rank_race",
	kWeeklyRace = "weekly_race",
	kLadyBug = "lady_bug",
	kGuide = "guide",
	kIncentiveVideo = "incentive_video",
	kFriend = "friend",
	kSignIn = "sign_in",
	kStarAndLevel = "star_and_level",
	kAddFiveSteps = "add_five_steps",
	kLevelArea = "level_area",
	kCompensation = "compensation",
	kAccountLogin = "account_login",
	kBag = "bag",
	kPaymentPack = "payment_Pack",
	kNewStore = 'new_store',
}

DcSourceType = {
	kActPre = "act_",
	kPreProp = "prep_prop",
	kPrePropCoin = "prep_coin",
	kIngamePropBuy = "ingame_prop_buy",
	kIngamePropConsume = "ingame_prop_consume",
	kEnergySupply = "energy_supply",
	kEnergyBuy = "energy_buy",
	kEnergyUse = "energy_use",
	KIosReapir = "ios_repair",
	kIosPayCode = "ios_pay_code",
	kFreeGift = "free_gift",
	kAskFreeGift = "ask_free_gift",
	kReturnPreProp = "return_pre_prop", 
	kDrop = "drop",
	kLevelReward = "level_reward",
	kLevelRewardAFH = "level_reward_afh",
	kNewUserReward = "new_user_reward",
	kStarBoardReward = "star_board_reward",
	kStarRankReward = "star_rank_reward",
	kFullLevelGift = "full_level_gift",
	kAdverPre = "adver_pre",
	kAdverTurn = "adver_turn",
	kSignReward = "sign_reward",
	kSignBuyReward = "sign_buy_reward",
	kSignSupply = "sign_supply",
	kLoginRewardQQ = "login_reward_qq",
	kLoginRewardPhone = "login_reward_phone",
	kLoginReward360 = "login_reward_360",
	kPushEnergy = "push_energy_reward",
	kActFreeGift = "activity_freegift",
	kFullLevelReward = "full_level_reward",
	kWXTurntableReward = "wx_turntable_reward",
	kRecallTurntableReward = "recall_turntable_reward",
	kRecallPush = "recall_push",
	kUpdate = "update_reward",
	kNormalAreaReward = "normal_area_reward",
	kHideAreaReward = "hide_area_reward",
	kShareFreeGift = "share_free_gift",
	kShareCommon = "share_commom",
	kAuthentication = "authentication",
	kPersonalInfoReward = "personal_info_reward",
	kRankRaceLastWeek = "rank_race_last_week",
	kRankRaceLottery = "rank_race_lottery",
	kRankRaceBox = "rank_race_box",
	kRankRaceLink = "rank_race_link",
	kRankRaceDan = "rank_race_dan",
	kRankRaceOld = "rank_race_old",
	kRankRaceDaZhao = "rank_race_dazhao",
	kRankRacePlayCount = "rank_race_play_count",
	kWeeklyPlayCount = "weekly_race_play_count",
	kOppoLaunch = "oppo_launch",
	kVivoLaunch = "vivo_launch",
	kSvipBindPhone = "svip_bind_phone",
	kLadybugReward = "ladybug_reward",
	kLadybugReopen = "ladybug_task_reopen",
	kExchangeCode = "exchange_code",
	kGuideFlagReward = "guide_flag_reward_",
	kGuideBuyProp = "guide_buy_prop",
	kInviteReward = "invite_reward",
	kInviteRewardA = "invite_reward_a",
	kInviteRewardWdj = "invite_reward_wdj",
	kRecommendFriendAccept = "recommend_friend_accept",
	kFSBuy = "fs_buy",
	kFSBuyDiamonds = "fs_buy_diamonds",
	kFSNewLottery = 'fs_new_lottery',
	kFSLotteryTutorial = "fs_lottery_tutorial",
	kFSLottery = "fs_lottery",
	kCompenReward = "compen",
	kIosPayGuide = "ios_pay_guide_reward",
	kFruitTreeReward = "fruit_tree_reward",
	kFruitTreeUpdate = "fruit_tree_update",
	kFruitSpeedUp = "fruit_tree_speed_up",
	kAliQuickPayPro = "ali_quick_pay_pro",
	kStarBankBuy = "star_bank_buy",
	kWechatFriPay = "wechat_friend_pay",
	kStoreBuyGold = "store_buy_gold",
	kStoreBuyProp = "store_buy_prop",
	kStoreBuySales = "store_buy_sales",
	kJumpLevel = "jump_level",
	kQQWallReward = "qq_wall_reward",
	kUnlockArea = "unlock_area",
	kIosOneYuanShop = "ios_one_yuan_shop",
	kBagUse = "bag_use",
	kPaymentPackID = "payment_Pack_",
	kAdd2Step = "add_two_steps",
    kLuckyBagDouble = "LuckyBagDouble",
    kNewStore = 'new_store',
    kMiLaunch = 'mi_launch'
}

local iOS_ProductName = {
	[1] = "60个风车币",
	[2] = "188个风车币",
	[3] = "318个风车币",
	[4] = "1388个风车币",
	[5] = "62个风车币",
	[6] = "340个风车币",
	[7] = "1568个风车币",
	[8] = "10个风车币",
	[9] = "30个风车币",
	[13] = "1元限购100风车币（老版）",
}

DcDataHelper = {}

function DcDataHelper:getStageModeByLevelId(levelId)
	local levelType = LevelType:getLevelTypeByLevelId( levelId )
	if levelType == GameLevelType.kMainLevel then
		return DcDataStageMode.kMainLevel
	elseif levelType == GameLevelType.kHiddenLevel then
		return DcDataStageMode.kHideLevel
	elseif levelType == GameLevelType.kSummerWeekly
			or levelType == GameLevelType.kRabbitWeekly
			or levelType == GameLevelType.kMoleWeekly then
		return DcDataStageMode.kWeeklyLevel
	elseif LevelType.isActivityLevelType(levelType) then
		return DcDataStageMode.kActivityLevel
	elseif levelType == GameLevelType.kTaskForRecall then
		return DcDataStageMode.kRecallLevel
	elseif levelType == GameLevelType.kTaskForUnlockArea then
		return DcDataStageMode.kUnlockAreaLevel
	else
		return DcDataStageMode.kNotDefined
	end
end

function DcDataHelper:getPropNameById(itemId)
	local propName = nil
	local key = "prop.name."..tostring(itemId)
	if itemId == 9 then
		propName = "飞碟关复活"
	elseif itemId == 16 then
		propName = "时间关+15秒"
	elseif itemId > 40000 and itemId < 49999 then
		propName = "解锁区域"..tostring(itemId - 40000)
	else
		propName = Localization.getInstance():getText(key)
	end
	if key == propName then
		propName = "itemId_"..tostring(itemId)
	end
	return propName
end

function DcDataHelper:getGoodsNameById(goodsId)
	local goodsIdStr = tostring(goodsId)
	local wmDelta = 10000
	if goodsId > wmDelta and( __IOS or __WIN32) then 							--风车币android和ios不一样
		local id = goodsId - wmDelta
		local goodsName = iOS_ProductName[id]
		if not goodsName then 
			goodsName = string.format("product_%d", id) 
		end
	else
		local key = "goods.name.text"..goodsIdStr
		local goodsName = Localization.getInstance():getText(key)
		if key == goodsName then
			goodsName = "goodsId_"..goodsIdStr
		end
	end
	return goodsName
end