local RealTimeUserFeatureBuilder = require 'zoo.heai.RealTimeUserFeatureBuilder'


local User = {}
function User:getTopLevelId()
	return 64
end
function User:getEnergy()
	return 10
end
function User:getCash()
	return 100
end
function User:getCoin()
	return 2000
end
function User:getStar()
	return 512
end
function User:getHideStar()
	return 128
end


ItemType = {}
ItemType.INGAME_REFRESH = 1
ItemType.INGAME_BACK = 2
ItemType.INGAME_SWAP = 3
ItemType.ADD_FIVE_STEP = 4
ItemType.INGAME_BRUSH = 5
ItemType.INGAME_HAMMER = 6
ItemType.SMALL_ENERGY_BOTTLE = 7
ItemType.MIDDLE_ENERGY_BOTTLE = 8
ItemType.LARGE_ENERGY_BOTTLE = 9


UserProfile = {}
UserProfile.gender = 1


UserMark = {}
UserMark.createTime = 123456789


UserManager = {}
UserManager.user = User
UserManager.profile = UserProfile
UserManager.mark = UserMark
function UserManager:getInstance()
	return UserManager
end
function UserManager:getUserScore(level)
	return {
	star=3,
}
end
function UserManager:getUserJumpLevelRef(level)
	return {
	pawnNum=10,
}
end
function UserManager:getUserPropNumberWithAllType(type)
	if type == ItemType.INGAME_REFRESH then
		return 1
	end
	if type == ItemType.INGAME_BACK then
		return 2
	end
	if type == ItemType.INGAME_SWAP then
		return 3
	end
	if type == ItemType.ADD_FIVE_STEP then
		return 4
	end
	if type == ItemType.INGAME_BRUSH then
		return 5
	end
	if type == ItemType.INGAME_HAMMER then
		return 6
	end
	if type == ItemType.SMALL_ENERGY_BOTTLE then
		return 7
	end
	if type == ItemType.MIDDLE_ENERGY_BOTTLE then
		return 8
	end
	if type == ItemType.LARGE_ENERGY_BOTTLE then
		return 9
	end
	return 0
end
function UserManager:getContinuousLogonDays()
	return 30
end
function UserManager:getUserLocation()
	return {country='country', province='province', city='city'}
end


UserTagManager = {}
function UserTagManager:getTopLevelFailCounts()
	return 10
end


UserEnergyState = {
	INFINITE = 0,
}


UserEnergyRecoverManager = {}
function UserEnergyRecoverManager:sharedInstance()
	return UserEnergyRecoverManager
end
function UserEnergyRecoverManager:getMaxEnergy()
	return 20
end
function UserEnergyRecoverManager:getEnergyState()
	return UserEnergyState.INFINITE
end


LevelMapManager = {}
function LevelMapManager:getInstance()
	return LevelMapManager
end
function LevelMapManager:getTotalStar(kMaxLevels)
	return 1024
end


MetaModel = {}
function MetaModel:sharedInstance()
	return MetaModel
end
function MetaModel:getFullStarInHiddenRegion()
	return 256
end


MetaInfo = {}
function MetaInfo:getInstance()
	return MetaInfo
end
function MetaInfo:getUdid()
	return 'ca7edbf091cc7b0f236d804d061192bb'
end
function MetaInfo:getDeviceModel()
	return 'x86'
end
function MetaInfo:getResolutionWidth()
	return 1
end
function MetaInfo:getResolutionHeight()
	return 1
end
function MetaInfo:getNetworkInfo()
	return 0
end


FriendManager = {}
FriendManager.friends = {}
function FriendManager:getInstance()
	return FriendManager
end
function FriendManager:getFriendCount()
	return 16
end


AskForHelpManager = {}
function AskForHelpManager:getInstance()
	return AskForHelpManager
end
function AskForHelpManager:getTotalHelpOtherCount()
	return 12
end
function AskForHelpManager:getTotalBeHelpedCount()
	return 24
end


PreBuffLogic = {}
function PreBuffLogic:getBuffGradeAndConfig()
	return {}
end


PlatformConfig = {}
PlatformConfig.name = "unittest"


local TopLevelState = {
	kNotPassed = 0,
	kPassedBySelf = 1,
	kPassedBySkip = 2,
	kPassedByFriend = 3,
}


---------------------------------------------------------------

caseHEAI = class(UnittestTask)

function caseHEAI:ctor()
	UnittestTask.ctor(self)

end

function caseHEAI:run(callback_success_message)
	local ret = RealTimeUserFeatureBuilder:build()
	-- local s = table.tostring(ret)
	-- print('\n')
	-- print(s)
	-- print('\n')
	-- debug.debug()
	self:validate(ret)


	callback_success_message(true, "")
end

function caseHEAI:validate(ret)
	local target =
{
  promotional_campaign_data = {
  },
  exchange_hold = 3,
  friend_num = 16,
  silvercoin_hold = 2000,
  current_time = 1535959767000,
  star_hid_level = 128,
  med_ebottle_hold = 8,
  login_days = 30,
  fivesteps_hold = 4,
  platform = "unittest",
  infinite_energy = true,
  carrier = 0,
  time_zone = "+08:00",
  stepback_hold = 2,
  udid = "ca7edbf091cc7b0f236d804d061192bb",
  levels_played_for_friends = 12,
  sml_ebottle_hold = 7,
  star_main_level = 512,
  brush_hold = 5,
  hammer_hold = 6,
  level_high_state = 2,
  star_ratio_hid_level = 0.5,
  goldcoin_hold = 100,
  gender = 1,
  network_type = 0,
  city = "city",
  promotional_campaign_ID = 0,
  province = "province",
  country = "country",
  reg_time = 123456789,
  levels_played_by_friends = 24,
  weekend = false,
  clientpixel = {
    1080,
    1920,
  },
  level_high_star = 3,
  clienttype = "x86",
  energy_level = 10,
  level_high_try = 10,
  big_ebottle_hold = 9,
  max_energy_level = 20,
  rank_in_friends = 1,
  keyt = "",
  level_high = 64,
  refresh_hold = 1,
  star_ratio_main_level = 0.5,
  cumulative_attempts = {},
  appid = 'animal_ioscn_prod', --'animal_androidcncm_prod','animal_androidqqzone_prod'
}

	ret.current_time = target.current_time
	ret.weekend = target.weekend
	ret.clientpixel = target.clientpixel
	ret.cumulative_attempts = target.cumulative_attempts
	ret.appid = target.appid
	
	table.compare(ret, target)

end

