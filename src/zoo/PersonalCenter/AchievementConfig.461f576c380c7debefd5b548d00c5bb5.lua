require "zoo.panel.share.ShareFinalPassLevelPanel"
require "zoo.panel.share.ShareFirstInFriendsPanel"
require "zoo.panel.share.ShareFourStarPanel"
require "zoo.panel.share.ShareHiddenLevelPanel"
require "zoo.panel.share.ShareLastStepPanel"
require "zoo.panel.share.ShareLeftTenStepPanel"
require "zoo.panel.share.SharePassFiveLevelPanel"
require "zoo.panel.share.SharePassFriendPanel"
require "zoo.panel.share.SharePyramidPanel"
require "zoo.panel.share.ShareThousandOnePanel"
require "zoo.panel.share.ShareTrophyPanel"
require "zoo.panel.share.ShareChestPanel"
require "zoo.panel.share.ShareEggsPanel"
require "zoo.panel.share.SharePopularityPanel"
require "zoo.panel.share.ShareUnlockNewObstaclePanel"
require "zoo.panel.share.Share5Time4StarPanel"
require "zoo.panel.share.ShareNStarRewardPanel"
require "zoo.panel.share.ShareAreaFullStar"
require "zoo.panel.share.ShareNWSliverConsumer"
require "zoo.panel.share.ShareCollectedNFruit"
require "zoo.panel.share.ShareExplorerPanel"
require "zoo.panel.share.ShareWeeklyFinalRewardPanel"

local manager = AchievementManager
local id = manager.shareId
local ShareType = manager.shareType
local Priority = manager.priority

local AchievementType = manager.achievementType

kShareConfig = {} 
kShareConfig[tostring(id.PASS_STEP_LESS_10)] = {id=1, gamecenter="happyelements_5steps"}--
kShareConfig[tostring(id.PASS_HIGHEST_LEVEL)] = {id=2, gamecenter="happyelements_before1000_high"}
kShareConfig[tostring(id.LAST_STEP_PASS)] = {id=3, gamecenter="happyelements_last_step_pass"}--
kShareConfig[tostring(id.N_TIME_PASS)] = {id=4, gamecenter="happyelements_finally_pass"}--
kShareConfig[tostring(id.OVER_SELF_RANK)] = {id=5, gamecenter="happyelements_before1000_friends"}
kShareConfig[tostring(id.CONTINUE_PASS_5_LEVEL)] = {id=6, gamecenter="happyelements_rocket"}--
-- kShareConfig[tostring(id.SCORE_OVER_FRIEND)] = {id=7, gamecenter="happyelements_beyond_friends"}
-- kShareConfig[tostring(id.LEVEL_OVER_FRIEND)] = {id=8, gamecenter="happyelements_beyond_friends_checkpoint"}
kShareConfig[tostring(id.HIDE_FULL_STAR)] = {id=9, gamecenter="happyelements_fourstar"}
kShareConfig[tostring(id.ALL_THREE_STARS)] = {id=10, gamecenter="happyelements_all_star"}--
--kShareConfig[tostring(id.UNLOCK_HIDEN_LEVEL)] = {id=11, gamecenter="happyelements_hidden_checkpoint"}
--kShareConfig[tostring(id.EIGHTY_PERCENT_PERSON)] = {id=12, gamecenter="happyelements_rocket"}
kShareConfig[tostring(id.FRIST_RANK_FRIEND)] = {id=15, gamecenter="happyelements_no.1_friends"}
--kShareConfig[tostring(id.HIGHEST_LEVEL_TWO)] = {id=16, gamecenter="happyelements_the_highest_level"}
kShareConfig[tostring(id.MARK_FINAL_CHEST)] = {id=18, gamecenter="happyelements_sign_get_treasure"}

local oriPrint = print
local print = function ( ... )
	oriPrint("[achievement] ",...)
end

--关卡数大于7
local function LevelGreater7()
	local top_level = UserManager.getInstance().user:getTopLevelId()
	return top_level > 7
end
--关卡数大于15
local function LevelGreater15()
	local top_level = UserManager.getInstance().user:getTopLevelId()
	return top_level > 15
end

--关卡数大于30
local function LevelGreater30()
	local top_level = UserManager.getInstance().user:getTopLevelId()
	local score = UserManager.getInstance():getUserScore(top_level)
	if score then
		top_level = top_level + 1
	end
	return top_level > 30
end

local function LevelGreater46()
	local top_level = UserManager.getInstance().user:getTopLevelId()
	return top_level > 45
end

--通关好友数大于4
local function PassFriNumG4()
	return manager:getData(manager.PASS_FRIEND_NUM) > 4
end

--好友数大于4
local function FriendNumG4()
	local friend_num = FriendManager:getInstance():getFriendCount()
	return friend_num > 4
end

--连续失败n次后过关
local function FailNumG5()
	local levelDataInfo = UserService.getInstance().levelDataInfo
	local levelInfo = levelDataInfo:getLevelInfo(manager:getData(manager.LEVEL))

	local playTimes = levelInfo.playTimes or 0
	local failTimes = levelInfo.failTimes or 0

	return playTimes > 5 and (playTimes - failTimes) == 1
end
--是否不是重复闯关
local function IsNotRepeatLevel( isPassHighestLevel )
	local score = manager:getData(manager.PRE_SCORE)
	if score then
		if isPassHighestLevel then
			if manager:getData(manager.PRE_ISJUMPEDLEVEL) then
				return true
			end
		end
		return false
	else
		return true
	end
end

--是否是当前版本最高关卡
local function IsCurHighestLevel()
	local version_highest_level =  MetaManager.getInstance():getMaxNormalLevelByLevelArea()
	return version_highest_level == manager:getData(manager.LEVEL)
end
--好友排行榜第一
local function IsFirstFriendRank()
	local rank = manager:getData(manager.FRIEND_RANK)
	return rank == 1
end

--分数进入该关卡前1000名
-- local function ScorePassThousand()
-- 	local score = manager:getData(manager.TOTAL_SCORE)
-- 	local minRankScore = manager:getData(manager.MIN_RANK_SCORE)
-- 	return score >= minRankScore
-- end

--是否超越自己的排名
local function IsOverSelfRank()
	return manager:getData(manager.OVER_SELF_RANK) == true
end


--全部区域3星
local function IsFullThreeStars()
	local maxStar = 15 * 3
	local userStar = 0

	local firstLevel = 1
	local lastLevel = 15
	local currentLevel = manager:getData(manager.LEVEL)
	if currentLevel then 
		if currentLevel%15 == 0 then
			firstLevel = currentLevel - 15
			lastLevel = currentLevel
		else
			firstLevel = currentLevel - (currentLevel%15)
			lastLevel = firstLevel + 15
		end
		if firstLevel<1 then 
			firstLevel = 1
		end
	end

	local preScore = manager:getData(manager.PRE_SCORE)
	local passLevelStar = manager:getData(manager.PASS_LEVEL_STAR)
	if preScore == nil then
		userStar = userStar + passLevelStar
		if passLevelStar <= 2 then return false end 
	else
		local score = UserManager:getInstance():getUserScore(currentLevel)
		if preScore.star >= 3 then return false end
		if score.star < 3 then return false end 
		userStar = userStar + score.star
	end

	firstLevel = firstLevel + 1
	if firstLevel == 2 then firstLevel = 1 end
	--TODO:current level star >= 3
	local scores = UserManager:getInstance().scores
	for k,v in pairs(scores) do
		if v.levelId >= firstLevel and v.levelId <= lastLevel and v.levelId ~= currentLevel then
			if v.star <= 2 then return false end 
			userStar = userStar + v.star
		end
	end

	return userStar >= maxStar
end

--是否获得隐藏的4颗星
local function IsFourStar()
	local level = manager:getData(manager.LEVEL)
	local totalScore = manager:getData(manager.TOTAL_SCORE)
	local scores = MetaModel:sharedInstance():getLevelTargetScores(level)
	local star = 0
	for k, v in ipairs(scores) do
		if totalScore > v then star = k end
	end

	return star == 4
end

--分数是否超越好友
local function IsScoreOverFriend()
	local friend_rank_list = manager:getData(manager.FRIEND_RANK_LIST)
	local self_score = manager:getData(manager.TOTAL_SCORE)
	local isOverFriend = false

	local over_friend_table = {}

	for i,v in ipairs(friend_rank_list) do
		if self_score > v.score then
			isOverFriend = true
			table.insert( over_friend_table, v )
		end
	end

	manager:setData(manager.SCORE_OVER_FRIEND_TABLE, over_friend_table)

	return isOverFriend
end

--进度是否超越好友
local function IsLevelOverFriend()
	local friend_rank_list = FriendManager:getInstance().friends

	if friend_rank_list == nil then
		return false
	end

	local isOverFriend = false

	local level_over_friend_table = {}
	local level = manager:getData(manager.LEVEL)

	for uid,friend in pairs(friend_rank_list) do
		local top_level = friend:getTopLevelId()
		if level == top_level then
			isOverFriend = true
			table.insert(level_over_friend_table, friend)
		end
	end

	manager:setData(manager.LEVEL_OVER_FRIEND_TABLE, level_over_friend_table)

	return isOverFriend
end

--是否签到领取最后一个宝箱
local function IsMarkFinalChest()
	local isFinal = manager:getData(manager.GET_MARK_FINAL_CHEST)
	return isFinal == true
end

-- 收集61儿童节所有的彩蛋
local function IsColletAll61Eggs()
	local isAll = manager:getData(manager.COLLECT_ALL_61_EGGS)
	return isAll == true
end

local function IsWeeklyExplorer()
	local value = manager:getData(manager.WEEKLY_EXPLORER)
	value = tonumber(value)
	return value and value >= 50
end

WeeklyMedalConfig = {3, 7, 12, 17, 22, 27, 32, 37}
local function IsCollectedNWeeklyMedal()
	local newCollectedNum = manager:getData(manager.COLLECTED_WEEKLY_MEDAL)
	local weeklyMatchData = SeasonWeeklyRaceManager:getInstance().matchData
	local totalCollected = weeklyMatchData and weeklyMatchData.medals or 0
	local oriTotalCollected = totalCollected - newCollectedNum
	if oriTotalCollected < 0 then oriTotalCollected = 0 end
	
	local targetNum = 0
	local achiLevel = 0

	for index = #WeeklyMedalConfig, 1, -1 do
		local targetIndex = 0

		if oriTotalCollected >= WeeklyMedalConfig[index] then
			targetIndex = index + 1
			if index == #WeeklyMedalConfig then
				--已经是最高成就了
				break
			end
		elseif index == 1 then
			targetIndex = 1
		end

		targetNum = WeeklyMedalConfig[targetIndex] or 0

		if targetNum > 0 then
			for l = #WeeklyMedalConfig, targetIndex, -1 do
				if totalCollected >= WeeklyMedalConfig[l] then
					achiLevel = l
					break
				end
			end
			break
		end
	end
	if _G.isLocalDevelopMode then printx(0, "totalCollected :", totalCollected, " TargetNum: ", targetNum) end

	if achiLevel > 0 then
		manager:setData(manager.TOTAL_COLLECTED_WEEKLY_MEDAL, totalCollected)
		return true
	end

	return false
end


--是否连续通过5关以上
local function IsPassFiveLevel()
	local levelDataInfo = UserService.getInstance().levelDataInfo

	local top_level = UserManager.getInstance().user:getTopLevelId()
	local maxConbo = levelDataInfo.maxConbo or 0

	local levels = {}
	for level,v in pairs(levelDataInfo.levels) do
		if LevelType:isMainLevel(tonumber(level)) then
			table.insert(levels, tonumber(level))
		end
	end

	table.sort(levels)

	if #levels < 5 then
		return false
	end

	--连续
	for i = #levels - 4, #levels-1 do
		if levels[i + 1] - levels[i] ~= 1 then
			return false
		end
	end

	return maxConbo >= 5
end

--是否是最后一步过关
local function IsLastStepPass()
	return manager:getData(manager.LEFT_STEP) == 0
end

--通关步数小等于10
local function PassStepLE10()
	return manager:getData(manager.PASS_STEP) <= 10
end

--解锁新障碍的关卡
local function UnlockNewObstacle()
	local firstNewObstacleLevels = MetaManager:getInstance().global.firstNewObstacleLevels
	local level = manager:getData(manager.LEVEL)

	table.sort(firstNewObstacleLevels)

	for _,o_level in ipairs(firstNewObstacleLevels) do
		if level == o_level then
			return true
		end

		if level < o_level then
			return false
		end
	end

	return false
end
--计算解锁新障碍的关卡的成就等级
local function CalUnLocalNewObstacleAchiLevel()
	local firstNewObstacleLevels = MetaManager:getInstance().global.firstNewObstacleLevels
	local level = manager:getData(manager.LEVEL)

	table.sort(firstNewObstacleLevels)

	local score = 0
	local achiLevel = 0

	for index, o_level in ipairs(firstNewObstacleLevels) do
		if level <= o_level then
			achiLevel = index
			if level > 400 then
				score = score + 50
			else
				score = score + 20
			end
		else
			break
		end
	end

	return achiLevel, score
end

--通过n个区域的全部隐藏关
local function PassAllAreaHideLevel()
	local level = manager:getData(manager.LEVEL)
	local isHideLevel = LevelType:isHideLevel(level)

	if isHideLevel then
		local hideAreaLevelIds = {}
		local HIDE_LEVEL_ID_START = 10000
		local hideArea = MetaManager.getInstance():getHideAreaByHideLevelId(level)

		if hideArea == nil then return false end

		local hideLevels = hideArea.hideLevelRange
		for i,v in ipairs(hideLevels) do
			table.insert(hideAreaLevelIds, HIDE_LEVEL_ID_START + v)
		end

		table.sort( hideAreaLevelIds )

		if hideAreaLevelIds[#hideAreaLevelIds] == level then
			return true
		end
	end

	return false
end

--计算通过n个区域的全部隐藏关的成就等级
local function CalPassAllAreaHideLevelAchiLevel()
	local hide_area = MetaManager.getInstance().hide_area
	local HIDE_LEVEL_ID_START = 10000

	local achiLevel = 0

	for k,hideArea in pairs(hide_area) do
		local hideLevels = hideArea.hideLevelRange

		local isPassAll = true

		for i,v in ipairs(hideLevels) do
			local level = HIDE_LEVEL_ID_START + v
			local score = UserManager.getInstance():getUserScore(level)
			if score == nil or score.star < 1 then 
				isPassAll = false
				break
			end
		end

		if isPassAll == true then
			achiLevel = achiLevel + 1
		end
	end

	return achiLevel
end

--有5*n关卡达到4星
local function Is5TimesLevelTo4star()
	local level = manager:getData(manager.LEVEL)
	local scores = UserManager.getInstance():getScoreRef()
	local levelCount = 0
	local thisFourStar = false
	for i,score in ipairs(scores) do
		if score.star == 4 then
			levelCount = levelCount + 1
		end

		if score.levelId == level and score.star == 4 then
			thisFourStar = true
		end
	end

	manager:setData(manager.FIVE_TIMES_4_STAR_COUNT, levelCount)

	return levelCount % 5 == 0 and thisFourStar
end

--计算有5*n关卡达到4星成就等级
local function Cal5TimesLevelTo4starAchiLevel()
	local level = manager:getData(manager.LEVEL)
	local scores = UserManager.getInstance():getScoreRef()
	local levelCount = 0

	for i,score in ipairs(scores) do
		if score.star == 4 then
			levelCount = levelCount + 1
		end
	end

	return math.floor(levelCount / 5)
end

--获得n星星（n=星星奖励可领取数值）
local function IsGetStarReward()
	local curTotalStar 	= UserManager:getInstance().user:getTotalStar()
	local starReward = MetaManager.getInstance().star_reward
	for _,reward in ipairs(starReward) do
		if curTotalStar == reward.starNum and curTotalStar > manager.preTotalStar then
			return true
		end
	end

	return false
end

--计算获得n星星（n=星星奖励可领取数值）成就等级
local function CalGetStarRewardAchiLevel()
	local curTotalStar 	= UserManager:getInstance().user:getTotalStar()
	local starReward = MetaManager.getInstance().star_reward
	local achiLevel = 0

	for _,reward in ipairs(starReward) do
		if curTotalStar <= reward.starNum then
			achiLevel = achiLevel + 1
		end
	end

	return achiLevel
end

--隐藏关区域满星
local function IsAreaFullStar()
	local curLevelId = manager:getData(manager.LEVEL)
	
	local preScore = manager:getData(manager.PRE_SCORE)
	local passLevelStar = manager:getData(manager.PASS_LEVEL_STAR)
	local maxStar = LevelMapManager:getInstance():getMeta(curLevelId):getTotalStarNumber()

	if (preScore and passLevelStar <= preScore.star) or passLevelStar < maxStar then
		return false
	end

	local isMainLevel = LevelType:isMainLevel(tonumber(curLevelId))
	local isHideLevel = LevelType:isHideLevel(tonumber(curLevelId))

	if not isMainLevel and not isHideLevel then
		return false
	end

	local HIDE_LEVEL_ID_START = 10000

	local hideAreaLevelIds, continueLevels

	local function getHideAreaLevelIds(mainLevelId)
		if mainLevelId < 16 then
			local continueLevels = {}
			for id=1,15 do
				table.insert(continueLevels, id)
			end
			return {}, continueLevels
		end

		local hideAreaLevelIds = {}

		local hide_area = MetaManager:getInstance().hide_area
		local continueLevels

		for k,hideArea in pairs(hide_area) do
			continueLevels = hideArea.continueLevels
			if mainLevelId >= continueLevels[1] and mainLevelId <= continueLevels[#continueLevels] then
				local hideLevels = hideArea.hideLevelRange
				for i,v in ipairs(hideLevels) do
					table.insert(hideAreaLevelIds, HIDE_LEVEL_ID_START + v)
				end
				break
			end
		end

		if mainLevelId >= 16 and mainLevelId < 31 then
			continueLevels = {}
			for id=16,30 do
				table.insert(continueLevels, id)
			end
		end

		return hideAreaLevelIds, continueLevels
	end

	if isHideLevel then
		hideAreaLevelIds = {}
		local hideArea = MetaManager:getInstance():getHideAreaByHideLevelId(curLevelId)
		for i,v in ipairs(hideArea.hideLevelRange) do
			table.insert(hideAreaLevelIds, HIDE_LEVEL_ID_START + v)
		end

		if curLevelId >= 1 and curLevelId < 4 then
			continueLevels = {}
			for id=16,30 do
				table.insert(continueLevels, id)
			end
		else
			continueLevels = hideArea.continueLevels
		end
	else
		hideAreaLevelIds, continueLevels = getHideAreaLevelIds(curLevelId)
	end
	
	for _,levelId in ipairs(hideAreaLevelIds) do
		local maxStar = LevelMapManager:getInstance():getMeta(levelId):getTotalStarNumber()
		local score = UserManager.getInstance():getUserScore(levelId)
		if score == nil or (score and score.star < maxStar) then
			return false
		end
	end

	for _,levelId in ipairs(continueLevels) do
		local maxStar = LevelMapManager:getInstance():getMeta(levelId):getTotalStarNumber()
		local score = UserManager.getInstance():getUserScore(levelId)
		if score == nil or (score and score.star < maxStar) then
			return false
		end
	end

	manager.fullStarHideAreaNum = manager.fullStarHideAreaNum + 1
	local count = manager.fullStarHideAreaNum

	if count == 5 or count == 10 or count == 15 or count == 20 or count == 25 then
		manager:setData(manager.FULL_STAR_HIED_AREA_NUM, count)
		return true
	end

	return false
end

AchiCostConfig = {1000000, 2000000, 3000000, 5000000, 7000000, 9000000}
local function IsCostNWSliver()
	local cost = manager:getData(manager.COIN_COST_NUM)
	local totalCost = UserManager:getInstance().achievement.spentCoins or 0
	local curTotalCost = cost + totalCost
	local costLevel = 0
	local targetCost = 0

	for index = #AchiCostConfig, 1, -1 do
		local targetIndex = 0

		if totalCost >= AchiCostConfig[index] then
			targetIndex = index + 1
			if index == #AchiCostConfig then
				--已经是最高成就了
				break
			end
		elseif index == 1 then
			targetIndex = 1
		end

		targetCost = AchiCostConfig[targetIndex] or 0

		if targetCost > 0 then
			for l = #AchiCostConfig, targetIndex, -1 do
				if curTotalCost >= AchiCostConfig[l] then
					costLevel = l
					break
				end
			end
			break
		end
	end

	if _G.isLocalDevelopMode then printx(0, "IsCostNWSliver cost :", cost, "oriTotalCost : ", totalCost) end
	if _G.isLocalDevelopMode then printx(0, "curTotalCost :", curTotalCost, " TargetCost: ", targetCost) end

	UserManager:getInstance().achievement.spentCoins = curTotalCost

	if costLevel > 0 then
		manager:setData(manager.TOTAL_COIN_COST_NUM, targetCost)
		return true
	end

	return false
end

AchiFruitCofig = {100,200,300,500,700,900,1200,1500,1800}
local function IsCollectedNFruit()
	local totalPickNum = UserManager:getInstance().achievement.pickedFruits or 0
	local pickNum = manager:getData(manager.PICK_FRUIT_NUM)
	local curTotalNum = pickNum + totalPickNum
	local costLevel = 0
	local targetNum = 0

	for index = #AchiFruitCofig, 1, -1 do
		local targetIndex = 0
		
		if totalPickNum >= AchiFruitCofig[index] then
			targetIndex = index + 1
			if index == #AchiFruitCofig then
				--已经是最高成就了
				break
			end
		elseif index == 1 then
			targetIndex = 1
		end

		targetNum = AchiFruitCofig[targetIndex] or 0

		if targetNum > 0 then
			for l = #AchiFruitCofig, targetIndex, -1 do
				if curTotalNum >= AchiFruitCofig[l] then
					costLevel = l
					break
				end
			end
			break
		end
	end

	if _G.isLocalDevelopMode then printx(0, "CollectedNFruit pick :", pickNum, "oriTotalPickNum : ", totalPickNum) end
	if _G.isLocalDevelopMode then printx(0, "curTotalNum :", curTotalNum, " targetNum: ", targetNum) end

	UserManager:getInstance().achievement.pickedFruits = curTotalNum

	if costLevel > 0 then
		manager:setData(manager.TOTAL_PICK_FRUIT_NUM, targetNum)
		return true
	end

	return false
end

local function HaveFriend()
	return FriendManager:getInstance():getFriendCount() > 0
end

local function supportPF(pf)
	return PlatformConfig:hasAuthConfig(pf)
end

local function HaveBindedAccount(authEnum)
	return UserManager:getInstance().profile:getSnsUsername(authEnum) ~= nil
end

local function ScoreOverNation()
	manager:setData(manager.SCORE_OVER_NATION_RESULT, nil)
	local score = manager:getData(manager.TOTAL_SCORE)
	local nation_score_config = manager:getData(manager.NATION_SCORE_CONFIG)
	local ret = false
	for k, v in pairs(nation_score_config) do
		if score >= v then
			ret = true
			manager:setData(manager.SCORE_OVER_NATION_RESULT, k)
		end		
	end
	-- if _G.isLocalDevelopMode then printx(0, manager:getData(manager.SCORE_OVER_NATION_RESULT)) debug.debug() end
	return ret 
end

local function LevelOverNation()
	manager:setData(manager.LEVEL_OVER_NATION_RESULT, nil)
	local level = manager:getData(manager.LEVEL)
	local nation_level_config = manager:getData(manager.NATION_LEVEL_CONFIG)
	local ret = false
	for k, v in pairs(nation_level_config) do
		if level >= v then
			ret = true
			manager:setData(manager.LEVEL_OVER_NATION_RESULT, k)
		end		
	end
	--if _G.isLocalDevelopMode then printx(0, manager:getData(manager.LEVEL_OVER_NATION_RESULT)) debug.debug() end
	return ret
end

local function GetImgUrl(shareId)
	local timer = os.time()
	local datetime = tostring(os.date("%y%m%d", timer))
	local imageURL = string.format("http://static.manimal.happyelements.cn/feed/week_first.jpg?v="..datetime)	
	return imageURL
end

local function GetKeyName( id )
	return "achievement_name_"..id
end

local function GetKeyDesc( id )
	return "achievement_desc_"..id
end

local function GetShareTitle( id )
	return "show_off_desc_"..id
end

local function GenLevelType( ... )
	local p = {...}
	local ret = 0
	for i,v in ipairs(p) do
		local tmp = bit.lshift(1, v - 1)
		ret = bit.bor(ret, tmp)
	end

	return ret
end

local configs = {}

local index = 0
local function nextIndex()
	index = index + 1
	return index
end

local function BuildUnifiedPara( shareId )
	local c = configs[shareId]
	c.priority = table.indexOf(Priority, shareId)
	c.keyName = c.keyName or GetKeyName(shareId)
	c.keyDesc = c.keyDesc or GetKeyDesc(shareId)
	c.shareTitle = c.shareTitle or GetShareTitle(shareId)
	c.shareImage = c.shareImage or GetImgUrl(shareId)

	
end

local function BuildConfig(c )
	configs[c.id] = c
	BuildUnifiedPara(c.id)
end

BuildConfig({
		id = id.SCORE_PASS_THOUSAND, 
		judge = function ()
			return LevelGreater7() and IsOverSelfRank()
		end,
		unlockCondition = LevelGreater7,
		achievementType = AchievementType.TRIGGER,
		autoCalScore = false,
		score = 100,
		levelType = GenLevelType(GameLevelType.kMainLevel, GameLevelType.kHiddenLevel),
		shareType = ShareType.IMAGE,
		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
			manager.LEVEL,
			manager.TOTAL_SCORE,
			manager.OVER_SELF_RANK,
			manager.ALL_SCORE_RANK
		},
		sharePanel = ShareThousandOnePanel,
	})

BuildConfig({
		id = id.PASS_HIGHEST_LEVEL, 
		judge = function ()
			return IsCurHighestLevel() and IsNotRepeatLevel(true)
		end,
		achievementType = AchievementType.SHARE,
		autoCalScore = false,
		score = 0,
		levelType = GenLevelType(GameLevelType.kMainLevel),
		shareType = ShareType.IMAGE,
		shareTitle = GetShareTitle(id.PASS_HIGHEST_LEVEL).."_1", --特殊的shareTitle
		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
			manager.LEVEL,
			manager.RANKDATA,
		},
		sharePanel = SharePyramidPanel,
	})

BuildConfig({
		id = id.FRIST_RANK_FRIEND, 
		judge = function ()
			return IsFirstFriendRank() and PassFriNumG4()
		end,
		achievementType = AchievementType.SHARE,
		autoCalScore = false,
		score = 0,
		levelType = GenLevelType(GameLevelType.kMainLevel, GameLevelType.kHiddenLevel),
		shareType = ShareType.IMAGE,
		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
			manager.FRIEND_RANK,
			manager.PASS_FRIEND_NUM,
		},
		sharePanel = ShareFirstInFriendsPanel,
	})


BuildConfig({
		id = id.ALL_THREE_STARS, 
		judge = function ()
			return IsFullThreeStars()
		end,
		achievementType = AchievementType.SHARE,
		autoCalScore = false,
		score = 0,
		levelType = GenLevelType(GameLevelType.kMainLevel),
		shareType = ShareType.IMAGE,
		shareTitle1 = "show_off_desc_40_1",
		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
			manager.LEVEL,
			manager.UNLOCK_HIDEN_LEVEL,
		},
		sharePanel = ShareTrophyPanel,
	})

BuildConfig({
		id = id.UNLOCK_NEW_OBSTACLE, 
		judge = function ()
			return UnlockNewObstacle() and IsNotRepeatLevel()
		end,
		achievementType = AchievementType.PROGRESS,
		autoCalScore = true,
		score = 20,
		scoreAndAchiLevel = CalUnLocalNewObstacleAchiLevel,
		levelType = GenLevelType(GameLevelType.kMainLevel),
		shareType = ShareType.IMAGE,
		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
			manager.LEVEL,
		},
		sharePanel = ShareUnlockNewObstaclePanel,
	})

BuildConfig({
		id = id.PASS_N_HIDEN_LEVEL, 
		judge = function ()
			return PassAllAreaHideLevel() and IsNotRepeatLevel()
		end,
		unlockCondition = LevelGreater30,
		keyDesc1 = GetKeyDesc(id.PASS_N_HIDEN_LEVEL).."_2",--进度型列表显示字符串
		achievementType = AchievementType.PROGRESS,
		autoCalScore = true,
		score = 20,
		achiLevel = CalPassAllAreaHideLevelAchiLevel,
		levelType = GenLevelType(GameLevelType.kHiddenLevel),
		shareType = ShareType.IMAGE,
		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
			manager.LEVEL,
		},
		sharePanel = ShareHiddenLevelPanel,
	})

BuildConfig({
		id = id.FIVE_TIMES_FOUR_STAR, 
		judge = function ()
			return Is5TimesLevelTo4star()
		end,
		achievementType = AchievementType.PROGRESS,
		autoCalScore = true,
		score = 20,
		achiLevel = Cal5TimesLevelTo4starAchiLevel,
		levelType = GenLevelType(GameLevelType.kMainLevel, GameLevelType.kHiddenLevel),
		shareType = ShareType.IMAGE,
		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
			manager.LEVEL,
		},
		sharePanel = Share5Time4StarPanel,
	})

BuildConfig({
		id = id.HIDE_FULL_STAR, 
		judge = function ()
			return IsFourStar()
		end,
		achievementType = AchievementType.SHARE,
		autoCalScore = false,
		score = 0,
		levelType = GenLevelType(GameLevelType.kMainLevel, GameLevelType.kHiddenLevel),
		shareType = ShareType.IMAGE,
		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
			manager.LEVEL,
			manager.TOTAL_SCORE,
		},
		sharePanel = ShareFourStarPanel,
	})

BuildConfig({
		id = id.N_STAR_REWARD, 
		judge = function ()
			return IsGetStarReward()
		end,
		achievementType = AchievementType.PROGRESS,
		autoCalScore = true,
		score = 20,
		levelType = GenLevelType(GameLevelType.kMainLevel, GameLevelType.kHiddenLevel),
		achiLevel = CalGetStarRewardAchiLevel,
		shareType = ShareType.IMAGE,
		sharePanel = ShareNStarRewardPanel,
	})

BuildConfig({
		id = id.WEEKLY_FIRST_FRI_RANK, 
		judge = function ()
			--周赛的成就不在这里判断
			return false
		end,
		achievementType = AchievementType.TRIGGER,
		achievementImage = true,
		autoCalScore = false,
		score = 100,
		levelType = GenLevelType(GameLevelType.kSummerWeekly, GameLevelType.kMoleWeekly),
		shareType = ShareType.IMAGE,
	})

BuildConfig({
		id = id.WILDAID_ACT_COMPLETE, 
		judge = function ()
			return false
		end,
		achievementType = AchievementType.TRIGGER,
		achievementImage = true,
		autoCalScore = false,
		score = 100,
		levelType = nil,
		shareType = ShareType.IMAGE,
	})

-- BuildConfig({
-- 		id = id.SCORE_OVER_FRIEND, 
-- 		judge = function ()
-- 			return false
-- 			-- return LevelGreater7() and PassFriNumG4() and IsScoreOverFriend() and (HaveFriend() or HaveBindedAccount(PlatformAuthEnum.kQQ)) 
-- 		end,
-- 		achievementType = AchievementType.SHARE,
-- 		autoCalScore = false,
-- 		score = 0,
-- 		levelType = GenLevelType(GameLevelType.kMainLevel, GameLevelType.kHiddenLevel),
-- 		shareType = ShareType.NOTIFY,
-- 		notifyMessage = "show_off_to_friend_point",
-- 		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
-- 			manager.LEVEL,
-- 			manager.PASS_FRIEND_NUM,
-- 			manager.FRIEND_RANK_LIST,
-- 			manager.TOTAL_SCORE,
-- 		},
-- 		sharePanel = SharePassFriendPanel,
-- 	})

-- BuildConfig({
-- 		id = id.LEVEL_OVER_FRIEND, 
-- 		judge = function ()
-- 			-- if __WIN32 then return true end
-- 			-- return FriendNumG4() and LevelGreater30() and IsLevelOverFriend() and (HaveFriend() or HaveBindedAccount(PlatformAuthEnum.kQQ))
-- 			return false
-- 		end,
-- 		achievementType = AchievementType.SHARE,
-- 		autoCalScore = false,
-- 		score = 0,
-- 		levelType = GenLevelType(GameLevelType.kMainLevel),
-- 		shareType = ShareType.NOTIFY,
-- 		notifyMessage = "show_off_to_friend_rank",
-- 		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
-- 			manager.LEVEL,
-- 		},
-- 		sharePanel = SharePassFriendPanel,
-- 	})

BuildConfig({
		id = id.WEEKLY_GEM_OVER_FRIEND, 
		judge = function ()
			--周赛相关不在这判断
			return false
		end,
		achievementType = AchievementType.SHARE,
		autoCalScore = false,
		score = 0,
		levelType = GenLevelType(GameLevelType.kSummerWeekly,  GameLevelType.kMoleWeekly),
		shareType = ShareType.NOTIFY,
	})
-- test wenkan
BuildConfig({
		id = id.SCORE_OVER_NATION, 
		judge = function ()
			-- if __WIN32 then 
			-- 	ScoreOverNation()
			-- 	return true 
			-- end
			-- if _G.isLocalDevelopMode then 
			-- 	ScoreOverNation()
			-- 	return true 
			-- end
			return not HaveFriend() and supportPF(PlatformAuthEnum.kQQ) and not HaveBindedAccount(PlatformAuthEnum.kQQ) and LevelGreater46() and ScoreOverNation()
		end,
		achievementType = AchievementType.SHARE,
		autoCalScore = false,
		score = 0,
		levelType = GenLevelType(GameLevelType.kMainLevel, GameLevelType.kHiddenLevel),
		shareType = ShareType.NOTIFY,
		notifyMessage = "show_off_score_over_nation", 
		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
			manager.LEVEL,
			manager.PASS_FRIEND_NUM,
			manager.FRIEND_RANK_LIST,
			manager.TOTAL_SCORE,
		},
		sharePanel = SharePassFriendPanel,
	})

BuildConfig({
		id = id.LEVEL_OVER_NATION, 
		judge = function ()
			if __WIN32 then
				LevelOverNation()
				return true
			end

			return not HaveFriend() and supportPF(PlatformAuthEnum.kQQ) and not HaveBindedAccount(PlatformAuthEnum.kQQ) and LevelGreater46() and LevelOverNation()
		end,
		achievementType = AchievementType.SHARE,
		autoCalScore = false,
		score = 0,
		levelType = GenLevelType(GameLevelType.kMainLevel),
		shareType = ShareType.NOTIFY,
		notifyMessage = "show_off_level_over_nation",
		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
			manager.LEVEL,
		},
		sharePanel = SharePassFriendPanel,
	})

BuildConfig({
		id = id.WEEKLY_GEM_OVER_NATION, 
		judge = function ()
			--周赛相关不在这判断
			return false
		end,
		achievementType = AchievementType.SHARE,
		autoCalScore = false,
		score = 0,
		levelType = GenLevelType(GameLevelType.kSummerWeekly, GameLevelType.kMoleWeekly),
		shareType = ShareType.NOTIFY,
	})
-- end test
BuildConfig({
		id = id.MARK_FINAL_CHEST, 
		judge = function ()
			return IsMarkFinalChest()
		end,
		achievementType = AchievementType.TRIGGER,
		autoCalScore = false,
		score = 100,
		levelType = nil, --不是过关炫耀
		shareType = ShareType.IMAGE,
		outLevelJudge = true,
		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
			manager.GET_MARK_FINAL_CHEST,
		},
		sharePanel = ShareChestPanel,
	})

BuildConfig({
		id = id.CONTINUE_PASS_5_LEVEL, 
		judge = function ()
			return LevelGreater7() and IsNotRepeatLevel() and IsPassFiveLevel()
		end,
		unlockCondition = LevelGreater7,
		achievementType = AchievementType.TRIGGER,
		autoCalScore = false,
		score = 50,
		levelType = GenLevelType(GameLevelType.kMainLevel),
		shareType = ShareType.IMAGE,
		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
			manager.LEVEL,
		},
		sharePanel = SharePassFiveLevelPanel,
	})

BuildConfig({
		id = id.N_TIME_PASS, 
		judge = function ()
			return FailNumG5()
		end,
		achievementType = AchievementType.TRIGGER,
		autoCalScore = false,
		score = 50,
		levelType = GenLevelType(GameLevelType.kMainLevel, GameLevelType.kHiddenLevel),
		shareType = ShareType.IMAGE,
		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
			manager.LEVEL,
		},
		sharePanel = ShareFinalPassLevelPanel,
	})

BuildConfig({
		id = id.LAST_STEP_PASS, 
		judge = function ()
			return IsNotRepeatLevel() and IsLastStepPass()
		end,
		achievementType = AchievementType.TRIGGER,
		autoCalScore = false,
		score = 50,
		levelType = GenLevelType(GameLevelType.kMainLevel, GameLevelType.kHiddenLevel),
		shareType = ShareType.IMAGE,
		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
			manager.LEVEL,
			manager.LEFT_STEP,
		},
		sharePanel = ShareLastStepPanel,
	})

BuildConfig({
		id = id.PASS_STEP_LESS_10, 
		judge = function ()
			return LevelGreater7() and PassStepLE10()
		end,
		unlockCondition = LevelGreater7,
		achievementType = AchievementType.TRIGGER,
		autoCalScore = false,
		score = 50,
		levelType = GenLevelType(GameLevelType.kMainLevel, GameLevelType.kHiddenLevel),
		shareType = ShareType.IMAGE,
		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
			manager.LEVEL,
			manager.PASS_STEP,
		},
		sharePanel = ShareLeftTenStepPanel,
	})

BuildConfig({
		id = id.COLLECT_ALL_61_EGGS, 
		judge = function ()
			return IsColletAll61Eggs()
		end,
		achievementType = AchievementType.TRIGGER,
		autoCalScore = false,
		score = 100,
		levelType = nil, --不是过关炫耀
		shareType = ShareType.IMAGE,
		outLevelJudge = true,
		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
			manager.COLLECT_ALL_61_EGGS,
		},
		sharePanel = ShareEggsPanel,
	})

BuildConfig({
		id = id.GET_POPULARITY, 
		judge = function ()
			local lastNum = Cookie:getInstance():read(CookieKey.kLastPopularityNum) or 0
			local lastLevel = math.min(math.floor(lastNum / 100),4)
			local num = manager:getData(manager.GET_POPULARITY)
			local level = math.min(math.floor(num / 100),4)
			return level > lastLevel
		end,
		achievementType = AchievementType.PROGRESS,--TRIGGER,
		autoCalScore = true,
		score = 20,
		levelType = nil, --不是过关炫耀
		achiLevel = function( ... )
			local num = tonumber(manager:getData(manager.GET_POPULARITY)) or 0
			local achiLevel = math.min(math.floor(num / 100),4)
			local score = achiLevel * 20
			return achiLevel, score
		end,
		shareType = ShareType.IMAGE,
		outLevelJudge = true,
		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
			manager.GET_POPULARITY,
		},
		sharePanel = { 
			create=function( self,shareId )
				Cookie:getInstance():write(
					CookieKey.kLastPopularityNum,
					manager:getData(manager.GET_POPULARITY)
				)
				return SharePopularityPanel:create(shareId)
			end
		},
	})

BuildConfig({
		id = id.AREA_FULL_STAR, 
		judge = function ()
			return IsAreaFullStar()
		end,
		achievementType = AchievementType.PROGRESS,
		autoCalScore = false,
		score = 10,
		keyDesc1 = "achievement_desc_220_1",
		levelType = GenLevelType(GameLevelType.kMainLevel, GameLevelType.kHiddenLevel),
		shareType = ShareType.IMAGE,
		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
			
		},
		sharePanel = ShareAreaFullStar,
	})

BuildConfig({
		id = id.NW_SILVER_CONSUMER, 
		judge = function ()
			return IsCostNWSliver()
		end,
		achievementType = AchievementType.PROGRESS,
		autoCalScore = false,
		score = 10,
		keyDesc1 = "achievement_desc_230_1",
		-- levelType = GenLevelType(GameLevelType.kMainLevel, GameLevelType.kHiddenLevel),
		outLevelJudge = true,
		shareType = ShareType.IMAGE,
		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
			manager.COIN_COST_NUM,
		},
		sharePanel = ShareNWSliverConsumer,
	})

BuildConfig({
		id = id.COLLECTED_N_FRUIT, 
		judge = function ()
			return IsCollectedNFruit()
		end,
		achievementType = AchievementType.PROGRESS,
		autoCalScore = false,
		score = 10,
		keyDesc1 = "achievement_desc_240_1",
		levelType = nil, --不是过关炫耀
		shareType = ShareType.IMAGE,
		outLevelJudge = true,
		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
			manager.PICK_FRUIT_NUM,
		},
		sharePanel = ShareCollectedNFruit,
	})

BuildConfig({
		id = id.WEEKLY_EXPLORER, 
		judge = function ()
			return IsWeeklyExplorer()
		end,
		achievementType = AchievementType.TRIGGER,
		autoCalScore = false,
		score = 20,
		levelType = nil, --GenLevelType(GameLevelType.kSummerWeekly),
		shareType = ShareType.IMAGE,
		outLevelJudge = true,
		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
			manager.WEEKLY_EXPLORER,
		},
		sharePanel = ShareExplorerPanel,
	})

BuildConfig({
		id = id.COLLECTED_N_WEEKLY_MEDAL, 
		judge = function ()
			return IsCollectedNWeeklyMedal()
		end,
		achievementType = AchievementType.PROGRESS,
		autoCalScore = true,
		score = 10,
		levelType = nil, --不是过关炫耀
		shareType = ShareType.IMAGE,
		outLevelJudge = true,
		dataKeyTable = { --使用到的网络数据，或必须在另外地方取到的本地数据
			manager.COLLECTED_WEEKLY_MEDAL,
		},
		sharePanel = ShareWeeklyFinalRewardPanel,
	})
	
	if PlatformConfig:isPlayDemo() then
		configs = {}
	end
	
return configs