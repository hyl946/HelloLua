SeasonWeeklyRaceConfig = class()

local _instance = nil
function SeasonWeeklyRaceConfig:ctor()
	self.dailyShare = 1
	self.freePlayByShare = 1
	self.dailyMainLevelPlay = 6 --每天累计最多有效的主线闯关次数，超过则不会增加周赛次数
	self.addWeeklyPlayCountPerMainLevelPlay = 2 --主线每闯过多少关会触发加周赛次数的逻辑
	self.freePlayByMainLevel = 1 --因为主线闯关每次触发增加周赛逻辑时，加几次周赛次数
	self.playCardGoodId = 150
	self.dazhaoGoodId = 474
	self.minLevel = 31
	self.levelIds = {
			230400,230401,230402,230403,230404,230405,230406,230407,230408,230409,230410,230411,230412,230413,230414,230415,230416,230417
			} -- default
	self.levelRewards = {}
	self.weeklyRewards = MetaRef.parseConditionRewardList(
		"200=10013:1,2:3000;700=10058:1,10059:1,2:6000;1200=10069:1,10071:1,2:10000;1600=10058:1,10071:1,10061:1,2:15000;2000=10079:1,10059:1,10064:1,10069:1,2:20000;2400=10013:1,10071:1,10064:1,10058:1,10059:1,10060:1,2:25000"
		)
	--self.winterWeeklyRewards = {}
	
	self.weeklyDropProp = 7
	self.specialPercentPlays = {14,16,20}
	self.specialPercent = 10
	self.maxDailyDropPropsCount = 1               -- 普通道具的数量
	self.maxDailyDropPropsCountJingLiPing = 5     -- 初级精力瓶的数量
	self.startTime = os.time({year=2015, month=9, day=1, hour=0, min=0, sec=0})
	self.firstLevelOffset = 7
	self.surpassLimit = 200
	self.weeklyRaceType = 6 -- 分享二维码相关，1 为秋季周赛，新开发时需要递增并和后端确定数字


	self.rankRewardWeight = 10
	self.rankMinNum = 0
	self.surpassRewards = MetaRef.parseConditionRewardList(
		"10064:1"
	)

	self.totalRankRewardWeight = 10
	self.totalRankMinNum = 0
	self.totalSurpassRewards = MetaRef.parseConditionRewardList(
		"10059:1"
	)

end

function SeasonWeeklyRaceConfig:getSurpassRewardItemId( ... )
	return 10064
end

function SeasonWeeklyRaceConfig:getTotalSurpassRewardItemId( ... )
	return 10059
end

function SeasonWeeklyRaceConfig:isSurpassReward( rewardItem )
	return rewardItem.itemId == self:getSurpassRewardItemId()
end

function SeasonWeeklyRaceConfig:isTotalSurpassReward( rewardItem )
	return rewardItem.itemId == self:getTotalSurpassRewardItemId()
end

function SeasonWeeklyRaceConfig:getInstance()
	if not _instance then
		_instance = SeasonWeeklyRaceConfig.new()
		_instance:init()
	end
	return _instance
end

function SeasonWeeklyRaceConfig:getSpecialPercent(playCount)
	if self.specialPercentPlays then
		if table.exist(self.specialPercentPlays, playCount) then
			return self.specialPercent
		end
	end
	return nil
end

function SeasonWeeklyRaceConfig:init()
	if MetaManager:getInstance().autumnWeeklyLevelRewards then
		for _, v in pairs(MetaManager:getInstance().autumnWeeklyLevelRewards) do
			self.levelRewards[tonumber(v.day)] = v
		end
	end

	--[[
	if MetaManager:getInstance().global.summer_week_match_levels_2016 then
		self.levelIds = MetaManager:getInstance().global.summer_week_match_levels_2016
	end
	]]

	if _G.isLocalDevelopMode then printx(0, "self.levelIds", table.tostring(self.levelIds)) end
	self.maxDailyDropPropsCount = MetaManager:getInstance().global.summer_week_max_prop_daily or 1
	self.maxDailyDropPropsCountJingLiPing = MetaManager:getInstance().global.winter_2016_energy_drop_limit or 5

	-- if _G.isLocalDevelopMode then printx(0, MetaManager:getInstance().global.summer_week_max_prop_daily,MetaManager:getInstance().global.winter_2016_energy_drop_limit) end
	-- debug.debug()
	self.weeklyDropProp = MetaManager:getInstance().global.summer_week_max_prop or 7
	--self.surpassRewards = MetaManager:getInstance().global.winter_2016_surpass_rewards
	self.surpassLimit = MetaManager:getInstance().global.weekSurpassLimit
	--self.weeklyRewards = MetaManager:getInstance().global.weekWeeklyReward



	self.rankMinNum = MetaManager:getInstance().global.weekRankMinNum
	--self.winterWeeklyRewards = MetaManager:getInstance().global.winter_2016_weekly_rewards
	self.rankRewardWeight = MetaManager:getInstance().global.winter_2016_surpass_num



	self.totalRankMinNum = MetaManager:getInstance().global.weekTotalRankMinNum
	--self.winterWeeklyRewards = MetaManager:getInstance().global.winter_2016_weekly_rewards
	self.totalRankRewardWeight = MetaManager:getInstance().global.winter_2016_total_surpass_num

end

function SeasonWeeklyRaceConfig:getDailyRewardsByDay(day)
	if day then
		local levelRewards = self.levelRewards[day]
		if levelRewards then return levelRewards.dailyRewards end
	end
	return nil
end

function SeasonWeeklyRaceConfig:getWeeklyRewards()
	--之前是weeklyRewards  1.30冬季周赛后用winterWeeklyRewards （为兼容老版本） 
	return self.weeklyRewards
end

function SeasonWeeklyRaceConfig:getRankMinScore()
	return self.rankMinNum
end

function SeasonWeeklyRaceConfig:getSurpassRewards()
	return self.surpassRewards
end

function SeasonWeeklyRaceConfig:getSurpassLimit()
	return self.surpassLimit
end


function SeasonWeeklyRaceConfig:getTotalRankMinScore()
	return self.totalRankMinNum
end

function SeasonWeeklyRaceConfig:getTotalSurpassRewards()
	return self.totalSurpassRewards
end
