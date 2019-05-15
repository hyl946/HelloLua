LevelConstans = table.const{
	MAIN_LEVEL_ID_START = 0,
	MAIN_LEVEL_ID_END = 9999,
	MAIN_LEVEL_ID_GROUP_START = 2000000,
	MAIN_LEVEL_ID_GROUP_END = 2999999,
	HIDE_LEVEL_ID_START = 10000,
	HIDE_LEVEL_ID_END = 19999,
	HIDE_LEVEL_ID_GROUP_START = 1000000,
	HIDE_LEVEL_ID_GROUP_END = 1999999,
	DIGGER_MATCH_LEVEL_ID_START = 20000,
	DIGGER_MATCH_LEVEL_ID_END = 29999,
	-- RABBIT_MATCH_LEVEL_ID_START = 30000,
	-- RABBIT_MATCH_LEVEL_ID_END = 39999,
	RABBIT_MATCH_LEVEL_ID_START = 160000,
	RABBIT_MATCH_LEVEL_ID_END = 169999,
	MAYDAY_ENDLESS_LEVEL_ID_START = 150000,		--虽然叫MaydayEndless，但是在编辑器中已锁定为Halloween模式关卡
	MAYDAY_ENDLESS_LEVEL_ID_END = 151000,
	RECALL_TASK_LEVEL_ID_START = 170000,
	RECALL_TASK_LEVEL_ID_END = 179999,
	TASK_FOR_UNLOCK_AREA_START = 200000,
	TASK_FOR_UNLOCK_AREA_END = 209999,
	SUMMER_MATCH_LEVEL_ID_START = 230000,
	SUMMER_MATCH_LEVEL_ID_END = 239999,
	QIXI2015_LEVEL_ID_START = 250000,
	QIXI2015_LEVEL_ID_END = 259999,
	NATIONAL_DAY_LEVEL_ID_START = 260000,
	NATIONAL_DAY_LEVEL_ID_END = 269999,
	WUKONG_LEVEL_ID_START = 270000,
	WUKONG_LEVEL_ID_END = 279999,
	SPRING2017_LEVEL_ID_START = 280100,
	SPRING2017_LEVEL_ID_END = 280199,
	OLYMPIC_LEVEL_ID_START = 280200,
	OLYMPIC_LEVEL_ID_END = 280299,
	AUTUMN_2018_LEVEL_ID_START = 280401,
	AUTUMN_2018_LEVEL_ID_END = 280406,
	YUANXIAO2017_LEVEL_ID_START = 290301,
	YUANXIAO2017_LEVEL_ID_END = 290318,
	SPRING2018_LEVEL_ID_START = 290400,
	SPRING2018_LEVEL_ID_END = 290499,
	FOURYEARS_LEVEL_ID_START = 290501,
	FOURYEARS_LEVEL_ID_END = 290527,
	NATIONDAY2017_LEVEL_ID_START = 280301,
	NATIONDAY2017_LEVEL_ID_END = 280320,
	MOLE_WEEKLY_RACE_LEVEL_ID_START = 310000,
	MOLE_WEEKLY_RACE_LEVEL_ID_END = 319999,
--    SUMMER_FISH_LEVEL_ID_START = 290601,
--	SUMMER_FISH_LEVEL_ID_END = 290699,
    SUMMER_FISH_LEVEL_ID_START = 290701,
	SUMMER_FISH_LEVEL_ID_END = 290730,
    JAMSPERAD_LEVEL_ID_START = 320000,
	JAMSPERAD_LEVEL_ID_END = 329999,
    SPRINGFESTIVAL2019_LEVEL_ID_START = 330101,
	SPRINGFESTIVAL2019_LEVEL_ID_END = 330115,
    
}

StageModeConstans = table.const{
	STAGE_MODE_NORMAL = 0,
	STAGE_MODE_PVP = 1,
	STAGE_MODE_HIDE_AREA = 2,
	STAGE_MODE_DIGGER_MATCH = 3,
	STAGE_MODE_RABBIT_MATCH = 4
}

GameLevelType = {
	kQixi 			= 1,
	kMainLevel 		= 2,
	kHiddenLevel 	= 3,
	kDigWeekly		= 4,
	kMayDay			= 5,		--虽然叫Mayday，但是在编辑器中已锁定为Halloween模式关卡
	kRabbitWeekly	= 6,
	kTaskForRecall  = 8,
	kTaskForUnlockArea = 9,
	kSummerWeekly 	= 10,
	kWukong 	= 11,
	kOlympicEndless = 12,
	kWinter2016Weekly = 13,
	kYuanxiao2017 = 14,
	kSpring2017 = 15,
	kSpring2018 = 16,
	kFourYears 	= 17,
	kMoleWeekly = 18,
    kSummerFish = 19,
    kMidAutumn2018 = 20,
    kJamSperadLevel = 21,
    kSpring2019 = 22,
    kDailyTasks = 23,
}

LevelType = class()

function LevelType:isMainLevel( levelId )
	if (levelId > LevelConstans.MAIN_LEVEL_ID_START and levelId <= LevelConstans.MAIN_LEVEL_ID_END) or
		(levelId > LevelConstans.MAIN_LEVEL_ID_GROUP_START and levelId <= LevelConstans.MAIN_LEVEL_ID_GROUP_END) then 
		return true
	else return false end
end

function LevelType:isHideLevel( levelId )
	if (levelId > LevelConstans.HIDE_LEVEL_ID_START and levelId <= LevelConstans.HIDE_LEVEL_ID_END) or 
		(levelId > LevelConstans.HIDE_LEVEL_ID_GROUP_START and levelId <= LevelConstans.HIDE_LEVEL_ID_GROUP_END) then 
		return true
	else return false end
end

--关卡ABtest调整关卡
function LevelType:isGroupLevel(levelId)
	if (levelId > LevelConstans.MAIN_LEVEL_ID_GROUP_START and levelId <= LevelConstans.MAIN_LEVEL_ID_GROUP_END) or 
		(levelId > LevelConstans.HIDE_LEVEL_ID_GROUP_START and levelId <= LevelConstans.HIDE_LEVEL_ID_GROUP_END) then 
		return true
	else return false end
end

function LevelType:isDiggerMatchLevel( levelId )
	if levelId > LevelConstans.DIGGER_MATCH_LEVEL_ID_START and levelId <= LevelConstans.DIGGER_MATCH_LEVEL_ID_END then return true
	else return false end
end

function LevelType:isRabbtiMatchLevel( levelId )
	if levelId > LevelConstans.RABBIT_MATCH_LEVEL_ID_START and levelId <= LevelConstans.RABBIT_MATCH_LEVEL_ID_END then return true
	else return false end
end

function LevelType:isMaydayEndlessLevel( levelId )
	if levelId > LevelConstans.MAYDAY_ENDLESS_LEVEL_ID_START and levelId <= LevelConstans.MAYDAY_ENDLESS_LEVEL_ID_END then return true
	else return false end
end

function LevelType:isMoleWeeklyRaceLevel( levelId )
	if levelId > LevelConstans.MOLE_WEEKLY_RACE_LEVEL_ID_START and levelId <= LevelConstans.MOLE_WEEKLY_RACE_LEVEL_ID_END then return true
	else return false end
end

function LevelType:isWeeklyRaceLevel( levelId )
	local value = LevelType:isMoleWeeklyRaceLevel(levelId) or LevelType:isSummerMatchLevel(levelId)
	return value
end

function LevelType:isRecallTaskLevel( levelId )
	if levelId > LevelConstans.RECALL_TASK_LEVEL_ID_START and levelId <= LevelConstans.RECALL_TASK_LEVEL_ID_END then return true
	else return false end
end

function LevelType:isQixi2015Level( levelId )
	if levelId > LevelConstans.QIXI2015_LEVEL_ID_START and levelId <= LevelConstans.QIXI2015_LEVEL_ID_END then return true
	else return false end
end

function LevelType:isNationalDayLevel(levelId)
	if levelId > LevelConstans.NATIONAL_DAY_LEVEL_ID_START and levelId <= LevelConstans.NATIONAL_DAY_LEVEL_ID_END then
		return true
	end
	return false
end

function LevelType:isUnlockAreaTaskLevel( levelId )
	-- body
	if levelId > LevelConstans.TASK_FOR_UNLOCK_AREA_START and levelId <= LevelConstans.TASK_FOR_UNLOCK_AREA_END then
		return true
	else
		return false
	end
end

function LevelType:isOlympicLevel(levelId)
	if levelId >= LevelConstans.OLYMPIC_LEVEL_ID_START and levelId <= LevelConstans.OLYMPIC_LEVEL_ID_END then
		return true
	else
		return false
	end
end

function LevelType:isMidAutumn2018Level(levelId)
	if levelId >= LevelConstans.AUTUMN_2018_LEVEL_ID_START and levelId <= LevelConstans.AUTUMN_2018_LEVEL_ID_END then
		return true
	else
		return false
	end
end

function LevelType:isSummerMatchLevel( levelId )
	return levelId > LevelConstans.SUMMER_MATCH_LEVEL_ID_START and levelId <= LevelConstans.SUMMER_MATCH_LEVEL_ID_END 
end

function LevelType:isWukongLevel( levelId )
	return levelId > LevelConstans.WUKONG_LEVEL_ID_START and levelId <= LevelConstans.WUKONG_LEVEL_ID_END 
end

function LevelType:isSpring2017Level(levelId)
	return (levelId >= LevelConstans.SPRING2017_LEVEL_ID_START and levelId <= LevelConstans.SPRING2017_LEVEL_ID_END)
			or (levelId >= LevelConstans.NATIONDAY2017_LEVEL_ID_START and levelId <= LevelConstans.NATIONDAY2017_LEVEL_ID_END)
end

function LevelType:isSpring2018Level( levelId )
	return levelId >= LevelConstans.SPRING2018_LEVEL_ID_START and levelId <= LevelConstans.SPRING2018_LEVEL_ID_END 
end

function LevelType:isMoleWeekLevel( levelId )
	return levelId >= LevelConstans.MOLE_WEEKLY_RACE_LEVEL_ID_START and levelId <= LevelConstans.MOLE_WEEKLY_RACE_LEVEL_ID_END 
end

function LevelType:isSummerFishLevel( levelId )
	return levelId >= LevelConstans.SUMMER_FISH_LEVEL_ID_START and levelId <= LevelConstans.SUMMER_FISH_LEVEL_ID_END
end

function LevelType:isJamSperadLevel( levelId )
	return levelId >= LevelConstans.JAMSPERAD_LEVEL_ID_START and levelId <= LevelConstans.JAMSPERAD_LEVEL_ID_END
end

function LevelType:isSpringFestival2019Level( levelId )
	return levelId >= LevelConstans.SPRINGFESTIVAL2019_LEVEL_ID_START and levelId <= LevelConstans.SPRINGFESTIVAL2019_LEVEL_ID_END
end



function LevelType:isYuanxiao2017Level( levelId )
	--[[
	if __WIN32 and (levelId == 0 or levelId == 248 or levelId == 603) then
		return true
	end
	]]
	
	return levelId >= LevelConstans.YUANXIAO2017_LEVEL_ID_START and levelId <= LevelConstans.YUANXIAO2017_LEVEL_ID_END
end

function LevelType:isFourYearsLevel( levelId )
	return levelId >= LevelConstans.FOURYEARS_LEVEL_ID_START and levelId <= LevelConstans.FOURYEARS_LEVEL_ID_END
end

function LevelType:getLevelTypeByLevelId( levelId )
	if LevelType:isMainLevel(levelId) then
		return GameLevelType.kMainLevel
	elseif LevelType:isHideLevel(levelId) then
		return GameLevelType.kHiddenLevel
	elseif LevelType:isDiggerMatchLevel(levelId) then
		return GameLevelType.kDigWeekly
	elseif LevelType:isMaydayEndlessLevel(levelId) then 
		return GameLevelType.kMayDay
	elseif LevelType:isRabbtiMatchLevel(levelId) then
		return GameLevelType.kRabbitWeekly
	elseif LevelType:isRecallTaskLevel(levelId) then
		return GameLevelType.kTaskForRecall
	elseif LevelType:isUnlockAreaTaskLevel(levelId) then
		return GameLevelType.kTaskForUnlockArea
	elseif LevelType:isSummerMatchLevel(levelId) then
		return GameLevelType.kSummerWeekly
	elseif LevelType:isQixi2015Level(levelId) then
		return GameLevelType.kMayDay
	elseif LevelType:isNationalDayLevel(levelId) then
		return GameLevelType.kMayDay
	elseif LevelType:isWukongLevel(levelId) then
		return GameLevelType.kWukong
	elseif LevelType:isOlympicLevel(levelId) then
		return GameLevelType.kOlympicEndless
	elseif LevelType:isMidAutumn2018Level(levelId) then
		return GameLevelType.kMidAutumn2018 
	elseif LevelType:isYuanxiao2017Level(levelId) then
		return GameLevelType.kYuanxiao2017
	elseif LevelType:isSpring2017Level(levelId) then
		return GameLevelType.kSpring2017
	elseif LevelType:isSpring2018Level(levelId) then
		return GameLevelType.kSpring2018
	elseif LevelType:isFourYearsLevel(levelId) then
		return GameLevelType.kFourYears
	elseif LevelType:isMoleWeeklyRaceLevel(levelId) then
		return GameLevelType.kMoleWeekly
    elseif LevelType:isSummerFishLevel(levelId) then
		return GameLevelType.kSummerFish
    elseif LevelType:isJamSperadLevel(levelId) then
        return GameLevelType.kJamSperadLevel
    elseif LevelType:isSpringFestival2019Level(levelId) then
        return GameLevelType.kSpring2019
	else
		assert(false, 'unknown level type:levelId='..tostring(levelId))
		return GameLevelType.kMainLevel
	end
end

function LevelType.isShowRankList( levelType )
	if _isQixiLevel then return false end
	if LevelType.isActivityLevelType(levelType)
		or levelType == GameLevelType.kTaskForRecall
		or levelType == GameLevelType.kTaskForUnlockArea then
		return false
	end
	return true
end

function LevelType.isShareEnable( levelType )
	return levelType == GameLevelType.kMainLevel
		or levelType == GameLevelType.kHiddenLevel
end

function LevelType.isNeedUploadOpLog( levelType )
	return levelType == GameLevelType.kMainLevel
		or levelType == GameLevelType.kHiddenLevel
		or levelType == GameLevelType.kOlympicEndless
		or levelType == GameLevelType.kMidAutumn2018
		or levelType == GameLevelType.kYuanxiao2017
		or levelType == GameLevelType.kSpring2018
		or levelType == GameLevelType.kMoleWeekly
		or levelType == GameLevelType.kSummerFish
end

-- since ver 1.41
function LevelType.isActivityLevelType(levelType)
	if levelType == GameLevelType.kMayDay 
			or levelType == GameLevelType.kOlympicEndless 
			or levelType == GameLevelType.kMidAutumn2018
			or levelType == GameLevelType.kSpring2017
			or levelType == GameLevelType.kSpring2018
			or levelType == GameLevelType.kFourYears
			or levelType == GameLevelType.kWukong
            or levelType == GameLevelType.kSummerFish  then
		return true
	end
	return false
end