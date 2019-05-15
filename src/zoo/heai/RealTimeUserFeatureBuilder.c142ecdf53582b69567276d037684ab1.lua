---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2018-05-24 10:46:17
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   dan.liang
-- @Last Modified time: 2018-12-16 09:51:53
---------------------------------------------------------------------------------------
--[[
Real-time user features:
level_high					The highest level	
level_high_state			Whether the highest stage has passed	
level_high_star				The number of stars at the highest stage	
level_high_try				Challenged times on the highest stage	
energy_level				how much energy user has (?/30)	
pay_all						Accumulative total payment since registration	
goldcoin_hold				Happycoins holding	
silvercoin_hold				Gamecoins holding	
refresh_hold				Refresh holding	
stepback_hold				Step back holding	
exchange_hold				Exchange holding	
5steps_hold					Add 5 steps holding	
brush_hold					Brush holding	
hammer_hold					Hammer holding	
sml_ebottle_hold			Small Energy bottle holding	
med_ebottle_hold			Mid Energy bottle holding	
big_ebottle_hold			Big Energy bottle holding	
login_days					Cumulative login days	
star						Total number of stars users obtained	
ratio_of_stars				Total number of stars users obtained / Total number of potential stars	
friend_num					Friend num	
rank_in_friends				relative ranking of positions on the level tree	
levels_played_for_friends	# of levels that this player has played for his/her friends	
levels_played_by_friends	# of levels that this player's friends has played for him/her	
game_ranking	
game_score	
promotional_campaign		what type of promotional campaign the user is in,such as collecting Birds/line elimination after passing several levels
promotional_stage			what stage in the promotional campaign the user is	
user_id						User id	
udid						device id	
keyt						mobile number	
carrier						Mobile Carrier	
clienttype					Device type	
clientpixel					resolution ratio	
platform					Platform (360/vivo/baidu/app store)
gameversion					Game software version
level_version				level version	
gender						gender	
reg_time					register time	
country	
province	
city	
Wifi or data connection		boolean	
current_time				UTC	
time_zone	
weekend (or holidays)		boolean
cumulative_attempts 		cumulative # of failed attempts  for current to current + 4 levels
]]
local TopLevelState = {
	kNotPassed = 0,
	kPassedBySelf = 1,
	kPassedBySkip = 2,
	kPassedByFriend = 3,
}

local function formatNumber(format, number)
	return tonumber(string.format(format, number))
end

local function getPromotionalCampaign()
	local prebuffGrade, prebuffConfig = PreBuffLogic:getBuffGradeAndConfig()
	if prebuffConfig and #prebuffConfig > 0 then
		local buffs = {}
		for _, v in ipairs(prebuffConfig) do
			table.insert(buffs, v.buffType)
		end
		return 1, buffs
	end
	return 0, {}
end

local friendsData = nil
local friendsDataUpdateTime = nil
local myData = nil
local function getSelfRankInFriends()
	local user = UserManager.getInstance().user
	if not friendsDataUpdateTime or friendsDataUpdateTime ~= FriendManager.getInstance().friendListUpdateTime then
		friendsData = {}
		myData = nil
		for fid, fuser in pairs(FriendManager.getInstance().friends) do
			if fuser and tonumber(fid) ~= user.uid then
				local data = {
					uid = tonumber(fid),
					topLevelId = fuser:getTopLevelId(),
					stars = fuser:getStar(),
				}
				table.insert(friendsData, data)
			end
		end
		table.sort( friendsData, function(a, b)
				if a.topLevelId > b.topLevelId then 
					return true 
				elseif a.topLevelId == b.topLevelId then
					if a.stars > b.stars then 
						return true 
					elseif a.stars == b.stars then
						return a.uid < b.uid
					end
				end
				return false
			end)
		friendsDataUpdateTime = FriendManager.getInstance().friendListUpdateTime
	end
	local topLevelId = user:getTopLevelId()
	local mainLevelStars = user:getStar()
	if not myData or topLevelId ~= myData.topLevelId or mainLevelStars ~= myData.stars then
		myData = {}
		myData.topLevelId = topLevelId
		myData.stars = mainLevelStars
		local friendNum = #friendsData
		local rank = friendNum + 1
		for idx = 1, friendNum do
			local fdata = friendsData[idx]
			if myData.topLevelId > fdata.topLevelId then
				rank = idx
				break
			elseif myData.topLevelId == fdata.topLevelId then
				if myData.stars > fdata.stars then
					rank = idx
					break
				end
			end
		end
		myData.rank = rank
	end
	return myData.rank
end

local RealTimeUserFeatureBuilder = {}

function RealTimeUserFeatureBuilder:build(levelIds)
	local userMgr = UserManager:getInstance()
	local user = userMgr.user
	local ret = {}
	-- level datas
	local topLevelId = user:getTopLevelId()
	local topLevelScore = userMgr:getUserScore(topLevelId)
	
	local topLevelState = TopLevelState.kNotPassed
	local ref = userMgr:getUserJumpLevelRef(topLevelId)
	if ref and ref.pawnNum > 0 then
		topLevelState = TopLevelState.kPassedBySkip
	elseif userMgr:hasAskForHelpInfo(topLevelId) then
		topLevelState = TopLevelState.kPassedByFriend
	elseif topLevelScore and topLevelScore.star > 0 then
		topLevelState = TopLevelState.kPassedBySelf
	end
	ret.level_high = topLevelId
	ret.level_high_state = topLevelState
	ret.level_high_star = topLevelScore and topLevelScore.star or 0
	ret.level_high_try = UserTagManager:getTopLevelFailCounts()
	
	ret.energy_level = user:getEnergy()
	ret.max_energy_level = UserEnergyRecoverManager:sharedInstance():getMaxEnergy()
	ret.infinite_energy = (UserEnergyRecoverManager:sharedInstance():getEnergyState() == UserEnergyState.INFINITE)
	-- accessed from the back-end
	-- ret.pay_all = UserTagManager:getUserTagBySeries(UserTagNameKeyFullMap.kHistoryPay) or 0
	-- props datas
	ret.goldcoin_hold = user:getCash()
	ret.silvercoin_hold = user:getCoin()
	ret.refresh_hold = userMgr:getUserPropNumberWithAllType(ItemType.INGAME_REFRESH) -- sum of normal-item and time-limit-item
	ret.stepback_hold = userMgr:getUserPropNumberWithAllType(ItemType.INGAME_BACK)
	ret.exchange_hold = userMgr:getUserPropNumberWithAllType(ItemType.INGAME_SWAP)
	ret.fivesteps_hold = userMgr:getUserPropNumberWithAllType(ItemType.ADD_FIVE_STEP) -- 5steps_hold
	ret.brush_hold = userMgr:getUserPropNumberWithAllType(ItemType.INGAME_BRUSH)
	ret.hammer_hold = userMgr:getUserPropNumberWithAllType(ItemType.INGAME_HAMMER)
	ret.sml_ebottle_hold = userMgr:getUserPropNumberWithAllType(ItemType.SMALL_ENERGY_BOTTLE)
	ret.med_ebottle_hold = userMgr:getUserPropNumberWithAllType(ItemType.MIDDLE_ENERGY_BOTTLE)
	ret.big_ebottle_hold = userMgr:getUserPropNumberWithAllType(ItemType.LARGE_ENERGY_BOTTLE)

	ret.login_days = userMgr:getContinuousLogonDays() -- continus login days, not Cumulative login days
    local totalStar = LevelMapManager.getInstance():getTotalStar(kMaxLevels)
	ret.star_main_level = user:getStar()
	ret.star_ratio_main_level = formatNumber("%0.2f", ret.star_main_level * 1.0 / totalStar)
	ret.star_hid_level = user:getHideStar()
	local hideStar = MetaModel:sharedInstance():getFullStarInHiddenRegion()
	if hideStar and hideStar > 0 then
		ret.star_ratio_hid_level = formatNumber("%0.2f", ret.star_hid_level * 1.0 / hideStar)
	else
		ret.star_ratio_hid_level = 0
	end
	-- friends datas
	ret.friend_num = FriendManager.getInstance():getFriendCount()
	ret.rank_in_friends = getSelfRankInFriends()
	ret.levels_played_for_friends = AskForHelpManager:getInstance():getTotalHelpOtherCount()
	ret.levels_played_by_friends = AskForHelpManager:getInstance():getTotalBeHelpedCount()

	-- accessed from the back-end
	-- ret.game_ranking = 0 -- ?
	-- ret.game_score = 0 -- ?

	local pcId, pcData = getPromotionalCampaign()
	ret.promotional_campaign_ID = pcId
	ret.promotional_campaign_data = pcData

	local metaInfo = MetaInfo:getInstance()
	-- ret.user_id = user.uid -- duplicate,remove
	-- ret.gameversion = _G.bundleVersion -- duplicate,remove
	-- ret.level_version = "" -- duplicate,remove
	ret.udid = metaInfo:getUdid()
	ret.keyt = "" -- ? account connected phone no. or device phone no.?
	local carrier = 0
	if __ANDROID then
		local metaInfo = luajava.bindClass("com.happyelements.android.MetaInfo")
		carrier = metaInfo:getNetOperatorType():getValue()
	elseif __IOS then
		carrier = AppController:getNetOperatorType()
	end
	ret.carrier = carrier --metaInfo:getNetOperatorName() -- no standard value, maybe "ChinaMobile" or "中国移动" etc.
	ret.clienttype = metaInfo:getDeviceModel()
	ret.clientpixel = {metaInfo:getResolutionWidth(), metaInfo:getResolutionHeight()}
	ret.platform = PlatformConfig.name
	ret.gender = userMgr.profile.gender or 0 -- return 0: unknown, 1: male, 2: female
	ret.reg_time = tonumber(userMgr.mark.createTime) or 0 -- milliseconds

	local location = userMgr:getUserLocation()
	if location then
		ret.country = location.country or ""
		ret.province = location.province or ""
		ret.city = location.city or ""
	else
		ret.country = ""
		ret.province = ""
		ret.city = ""
	end
	-- Wifi or data connection, return network type -1: none, 0: mobile, 1: wifi
	ret.network_type = metaInfo:getNetworkInfo()
	-- time datas
	local timestamp = os.time()
	ret.current_time = timestamp * 1000
	local minuteOffset = math.modf((timestamp - os.time(os.date("!*t", timestamp))) / 60)
	local hourPart = math.modf(math.abs(minuteOffset) / 60)
	local minutePart = math.abs(minuteOffset) % 60
	-- timezone "+08:00"
	ret.time_zone = string.format("%s%02d:%02d", minuteOffset>=0 and "+" or "-", hourPart, minutePart)
	local wday = os.date("*t", timestamp).wday
	ret.weekend = (wday == 1 or wday == 6) -- Sunday/Saturday
	ret.cumulative_attempts = {}
	if levelIds then 
		for i, levelId in ipairs(levelIds) do
			ret.cumulative_attempts[tostring(levelId)] = FUUUManager:getLevelContinuousFailNum(levelId) 
		end
	end
	ret.appid = StartupConfig:getInstance():getDcUniqueKey()

	return ret
end

return RealTimeUserFeatureBuilder