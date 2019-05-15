DcVersionManager = class()

AcType = table.const {
  kInstall = 11,
  kDnu = 1,
  kDau = 2,
  kOnline = 104,
  kUp = 5,
  kReg = 6,
  kActive = 7,
  kPromotion = 13,
  kTutorialStep = 15,
  kTutorialFinish = 3,
  kVirtualGoods = 71,
  kCreateCoin = 72,
  kUseItem = 103,
  kRewardItem = 102,
  kLevelUp = 4,
  kFirstLevel = 98,
  kBeforeWin = 99,
  kIngame = 9,
  kUserTrack = 101,
  kViralSend = 87,
  kViralArrival = 88,
  kViralActivate = 89,
  kFuuu = 100,
  kActivity = 109,
  kUserInfo = 900, --用户画像基础数据点
  kAppInfo = 907, --应用信息
  kQQUserFri = 909, --用户画像腾讯好友关系链
  kOPLog = 1003, -- oplog打点，改为8030
  kExposure = 1002, --曝光点
  kAdsIOSClick = 201, --ios ads
  kAdsIOSReward = 202,
  kAdsIOSLoad = 203,
  kCancelDnu = 401,
  kCancelReg = 406,
  kUserTag = 199,
  kExpire7Days = 8007,
  kExpire30Days = 8030,
  kExpire90Days = 8090,
  kSnapshotPassLevel = 945,
}

local Config = {
	{actType = AcType.kVirtualGoods, 	category = "coin", 				subCategory = "consume", 				version = 1},
	{actType = AcType.kVirtualGoods, 	category = "happy coin", 		subCategory = "consume", 				version = 1},
	{actType = AcType.kVirtualGoods, 	category = "rmb", 				subCategory = "consume", 				version = 1},
	{actType = AcType.kVirtualGoods, 	category = "unknown_currency", 	subCategory = "consume", 				version = 1},

	{actType = AcType.kCreateCoin, 		category = "currency", 			subCategory = "create", 				version = 1},

	{actType = AcType.kUseItem, 		category = "item", 				subCategory = "use", 					version = 1},

	{actType = AcType.kRewardItem, 		category = "item", 				subCategory = "origin", 				version = 1},

	{actType = AcType.kUserTrack, 		category = "payment", 			subCategory = "end_wm", 				version = 1},
	{actType = AcType.kUserTrack, 		category = "payment", 			subCategory = "check_fail", 			version = 7},
	{actType = AcType.kUserTrack, 		category = "payment", 			subCategory = "end", 					version = 7},
	{actType = AcType.kUserTrack, 		category = "payment", 			subCategory = "start_ios", 				version = 4},
	{actType = AcType.kUserTrack, 		category = "payment", 			subCategory = "end_ios", 				version = 4},
	{actType = AcType.kUserTrack, 		category = "payment", 			subCategory = "ios_product_change", 	version = 4},
}

local instance = nil
function DcVersionManager.getInstance()
	if not instance then
		instance = DcVersionManager.new()
		instance:init()
	end
	return instance
end

function DcVersionManager:init()
end

function DcVersionManager:getVersion(actType, category, subCategory)
	if not actType or not category or not subCategory then return 0 end
	for i,v in ipairs(Config) do
		if actType == v.actType and category == v.category and subCategory == v.subCategory then
			return v.version 
		end
	end
	return 0
end