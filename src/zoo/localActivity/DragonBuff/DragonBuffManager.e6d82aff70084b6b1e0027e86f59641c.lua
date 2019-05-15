
DragonBuffManager = class()

local instance = nil
DragonBuffManager.UserState = {
	kNone = 0,
	kNormal = 202, 			--没满级满星
	kTopLevel = 203,		--满级没满星
	kTopStar = 204,       	--满级满星
}

local DragonBuffCfg = {
	[1] = {
		buff = {InitBuffType.RANDOM_BIRD},
		duration = 0,
		unlimit = true,
        AllCondition= 0,
		condition = 0, 
	},
	[2] = {
		buff = {InitBuffType.LINE, InitBuffType.WRAP},
		duration = 900*1000,
		unlimit = false,
        AllCondition= 50,
		condition = 50, 
	},
	[3] = {
		buff = {InitBuffType.LINE, InitBuffType.RANDOM_BIRD},
		duration = 900*1000,
		unlimit = false,
        AllCondition= 120,
		condition = 70, 
	},
	[4] = {
		buff = {InitBuffType.LINE, InitBuffType.WRAP, InitBuffType.RANDOM_BIRD},
		duration = 900*1000,
		unlimit = false,
        AllCondition= 190,
		condition = 70,
	},
	[5] = {
		buff = {InitBuffType.LINE, InitBuffType.RANDOM_BIRD, InitBuffType.RANDOM_BIRD},
		duration = 1200*1000,
		unlimit = false,
        AllCondition= 270,
		condition = 80, 
	},
}

local MAXLEVELSTATNEEDNUM = 100

local MAX_GRADE = 5

local VERSION = "1_"	--本地缓存标识 每次换皮应更改 
local ACT_SOURCE = 'DragonBuff/Config.lua'
local ACT_MAIN_END_TIME = "dragonbuff_main_end_time_"..VERSION
local ACT_ALL_END_TIME = "dragonbuff_all_end_time_"..VERSION
local kStorageFileName = "dragonbuff_"..VERSION
local kLocalDataExt = ".ds"

function DragonBuffManager.getInstance()
	if not instance then
		instance = DragonBuffManager.new()
		instance:init()
	end
	return instance
end

local function getUid()
	local uid = '12345'
	if UserManager and UserManager:getInstance().user then
		uid = UserManager:getInstance().user.uid or '12345'
	end
	uid = tostring(uid)
	return uid
end

function DragonBuffManager:init()
	self.curNum = 0
    self.bOpenActivity = false --是否打开过活动
    self.bLevelUp = false
	self.userState = nil
	self.normalEffectLv = nil 			

	self.uid = getUid()
	self.filePath = HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName .. self.uid .. kLocalDataExt

	self:readFromLocal()

	self:updateUserState()
end

local function isRightLevelMode(levelId)
	-- 排除时间关
	local levelModeTypeId = MetaModel:sharedInstance():getLevelModeTypeId(levelId)
	if levelModeTypeId == GameModeTypeId.CLASSIC_ID or levelModeTypeId == GameModeTypeId.DIG_TIME_ID then 
		return false
	end

	return true
end

function DragonBuffManager:updateUserState()
	local configTopLevel = MetaManager:getInstance():getMaxNormalLevelByLevelArea()
	local configFullStar = configTopLevel * 3
	local userTopLevel = UserManager:getInstance().user.topLevelId

	local userTopLevelPassed = false 
	local scoreOfLevel = UserManager:getInstance():getUserScore(userTopLevel)
	if scoreOfLevel then
		if scoreOfLevel.star ~= 0 or 
			JumpLevelManager:getLevelPawnNum(userTopLevel) > 0 or 
			UserManager:getInstance():hasAskForHelpInfo(userTopLevel) then 
			userTopLevelPassed = true	
		end
	end

	local tempLevelId 
	if userTopLevel%15==0 and userTopLevelPassed then 	--卡区域了
		tempLevelId = userTopLevel + 1
	else
		tempLevelId = userTopLevel
	end
	local find = false 
	for lvId=tempLevelId, configTopLevel do
		if isRightLevelMode(lvId) then 
			find = true
			self.normalEffectLv = lvId
			break
		end
	end

	if find then 
		self.userState = DragonBuffManager.UserState.kNormal
	else
		self.normalEffectLv = nil
		self.userState = DragonBuffManager.UserState.kTopLevel
	end


    --最高关失效
--    local topPassedLevelId = UserManager:getInstance():getTopPassedLevel()

--    if topPassedLevelId >= math.min(kMaxLevels, 1590) then
--        self.normalEffectLv = nil
--	    self.userState = DragonBuffManager.UserState.kTopLevel
--    end 
end

function DragonBuffManager:getUserState()
	return self.userState
end

function DragonBuffManager:getEffectLevelId()
	return self.normalEffectLv
end

function DragonBuffManager:shouldShowActCollection(levelId)
	if not levelId then return false end 
	if not self.normalEffectLv then return false end 
	if levelId ~= self.normalEffectLv then return false end 

    local senderUid = AskForHelpManager:getInstance():getDoneeUId()
    if senderUid then return false end 

    if LevelType:isMainLevel(levelId) and  LevelMapManager.getInstance():getLevelGameMode(levelId) ~=  GameModeTypeId.CLASSIC_ID then
    else
        return false
    end

	return self:isActivitySupport()
end

function DragonBuffManager:isActivitySupport()
	if self.bOpenActivity == false then 
		return false 
	end

	if __WIN32 then 
		return true
	end

	local endTime = CCUserDefault:sharedUserDefault():getIntegerForKey(ACT_MAIN_END_TIME..self.uid) or 0
	if Localhost:timeInSec() > endTime then 
		return false
	end

	return true
end

function DragonBuffManager:isActivitySupportAll()
	if self.bOpenActivity == false then 
		return false 
	end

    if not self.CurBuffLevel and not self.AnotherLevel then
        --not init
        return false
    end

	if __WIN32 then 
		return true
	end

	local endTime = CCUserDefault:sharedUserDefault():getIntegerForKey(ACT_ALL_END_TIME..self.uid) or 0
	if Localhost:timeInSec() > endTime then 
		return false
	end

	return true
end

function DragonBuffManager:readFromLocal()
	local file, err = io.open(self.filePath, "rb")

	if file and not err then
		local content = file:read("*a")
		io.close(file)

        local data = nil
        local function decodeContent()
            data = amf3.decode(content)
        end
        pcall(decodeContent)

		if data and type(data) == "table" then
			self.curNum = data.curNum or 0
            self.bOpenActivity = data.bOpenActivity == 1 and true or false
            self.buffStartTime = data.buffStartTime or 0
		end
	end
end

function DragonBuffManager:writeToLocal()
	local data = {}
	data.curNum = self.curNum
    data.bOpenActivity = self.bOpenActivity and 1 or 0
	data.buffStartTime = self.buffStartTime

	local content = amf3.encode(data)
    local file = io.open(self.filePath, "wb")
    -- assert(file, "DragonBuffManager persistent file failure " .. kStorageFileName)
    if not file then return end
	local success = file:write(content)
   
    if success then
        file:flush()
        file:close()
    else
        file:close()
    end
end

function DragonBuffManager:updateByActivity(mainEndTime, allEndTime, curTotalNum, buffStartTime)
	CCUserDefault:sharedUserDefault():setIntegerForKey(ACT_MAIN_END_TIME..self.uid, mainEndTime)
	CCUserDefault:sharedUserDefault():setIntegerForKey(ACT_ALL_END_TIME..self.uid, allEndTime)
	self.curNum = curTotalNum
	self.bOpenActivity = true
    self.buffStartTime = buffStartTime
	self:updateCollectInfo()

    self:writeToLocal()
end

function DragonBuffManager:getActivityIcon()
	for k,v in pairs(HomeScene:sharedInstance().activityIconButtons or {}) do
		if v.source == ACT_SOURCE then
			return v
		end
	end
end

function DragonBuffManager:updateActIconRewardFlag()
	local ret = table.find(ActivityUtil:getActivitys() or {},function(v)
		return v.source == ACT_SOURCE
	end)
	if ret then 
		ActivityUtil:setRewardMark(ACT_SOURCE, true)
	end
end

function DragonBuffManager:loadSkeletonAssert()
	FrameLoader:loadArmature('tempFunctionRes/CountdownParty/skeleton/countdown_party', 'countdown_party', 'countdown_party')
end

function DragonBuffManager:unloadSkeletonAssert()
    ArmatureFactory:remove('countdown_party', 'countdown_party')
end

function DragonBuffManager:updateCollectInfo()

    local CurLevel, CurAnotherLevel = self:getDragonBuffGradeInfo()

    if CurLevel  == 1 then
        return 
    end

    local UseTime = Localhost:time() - self.buffStartTime
    if UseTime > DragonBuffCfg[CurLevel].duration then
        self.curNum = 0
        self.buffStartTime = self.buffStartTime + DragonBuffCfg[CurLevel].duration

        self:writeToLocal()
    end
end

function DragonBuffManager:addCollectionNum(num)

    local CurLevel, CurAnotherLevel = self:getDragonBuffGradeInfo()
    local NextLevel, NextAnotherLevel = self:getDragonBuffGradeInfoByNum( self.curNum + num )

    if CurLevel + CurAnotherLevel == NextLevel + NextAnotherLevel then
        --没升级 检测使用时间是否到期 到期清0
        local UseTime = Localhost:time() - self.buffStartTime

        if CurLevel + CurAnotherLevel  == 1 then
            self.curNum = self.curNum + num
        else
            if UseTime > DragonBuffCfg[CurLevel].duration then
                self.curNum = num
                self.buffStartTime = Localhost:time()
            else
                self.curNum = self.curNum + num
            end
        end

        self.bLevelUp = false
    else
        self.buffStartTime = Localhost:time()
        self.curNum = self.curNum + num
        self.bLevelUp = true
    end

	self:writeToLocal()
end

function DragonBuffManager:getProgressShowNum()
	local totalCurNum = self.curNum
	return totalCurNum, self.limitNum
end

function DragonBuffManager:getLotteryNum()
	return self.lotteryNum 
end

function DragonBuffManager:getPasslevelExtraData(levelId, star, actCollectionNum)
	local extraData = {}
	extraData.userState = 206
    extraData.collectionNum = actCollectionNum

--	local userLevelState = self:getUserState()
--	if userLevelState then 
--		if userLevelState == DragonBuffManager.UserState.kNormal then 
--			local effLv = self:getEffectLevelId()
--			if effLv and levelId == effLv then 
--				extraData.userState = DragonBuffManager.UserState.kNormal
--				extraData.collectionNum = actCollectionNum
--			end
--		elseif userLevelState == DragonBuffManager.UserState.kTopLevel then 
--			if star and star > 0 then 
--				local levelScore = UserManager:getInstance():getUserScore(levelId)
--				local starIncrease = false 
--				if levelScore then
--					if levelScore.star > 0 then 
--						starIncrease = star - levelScore.star > 0
--					elseif JumpLevelManager:getLevelPawnNum(levelId) > 0 or 
--							UserManager:getInstance():hasAskForHelpInfo(levelId) then 
--						starIncrease = true
--					end
--					if starIncrease then 
--						extraData.userState = DragonBuffManager.UserState.kTopLevel
--					end
--				end
--			end
--		end
--	end

    --打点
    local curLevel, AnotherLevel =  self:getDragonBuffGradeInfo()
    local dcData = {
	    game_type = "stage",
	    game_name = "dragon2018",
	    category = "stage",
	    sub_category = "buff_end",
	    t1 = curLevel,
    }
    DcUtil:activity(dcData)

    local dcData = {
	    game_type = "stage",
	    game_name = "dragon2018",
	    category = "stage",
	    sub_category = "get_zongzi_num",
	    t1 = actCollectionNum,
        t2 = self.curNum,
    }
    DcUtil:activity(dcData)

	return extraData
end

--获取当前的等级
function DragonBuffManager:getDragonBuffGradeInfo( )
    return self:getDragonBuffGradeInfoByNum( self.curNum )
end

function DragonBuffManager:getDragonBuffGradeInfoByNum( num )
    
    local CurLevel = 0
    local AnotherLevel = 0

    for i=1, 5 do
        local LevelNeedNum = self:getNeedPointsAll(i)

        if num >= LevelNeedNum then
            CurLevel = i
        end
    end

    if CurLevel == 5 then

        local LevelNeedNum = self:getNeedPointsAll(5)

        local moreNum = num - LevelNeedNum
        local n = moreNum / MAXLEVELSTATNEEDNUM
        AnotherLevel = math.floor( tonumber(string.format("%.06f",n))  ) 
    end

    return CurLevel, AnotherLevel
end

--获取下一级所需的道具数
function DragonBuffManager:getNextPoints ( level ) --这里等级1-无限
    if level <= 0 then
        return 0
    end

    local nextNeedNum = 0
    if level < 5 then
        nextNeedNum = DragonBuffCfg[level+1].condition
    else
        nextNeedNum = MAXLEVELSTATNEEDNUM
    end

    return nextNeedNum
end

--获取下一级需要的总数
function DragonBuffManager:getNeedPointsAll ( level ) --这里等级1-无限
    
    if level <= 0 then  
        return 0
    end

    local nextNeedNum = 0
    for i=1, level do
        if i > 0 and i <= 5 then
            nextNeedNum = nextNeedNum + DragonBuffCfg[i].condition
        elseif i >5 then
            nextNeedNum = nextNeedNum + MAXLEVELSTATNEEDNUM
        end
    end

    return nextNeedNum
end

function DragonBuffManager:getDragonBuffInfo( point )

    local curLevel = 0
    local AnotherLevel = 0
    local CanUseTime = 0
    local havePoint = point

    if point then
        curLevel, AnotherLevel =  self:getDragonBuffGradeInfoByNum( point )
    else
        self:updateCollectInfo()

        curLevel, AnotherLevel =  self:getDragonBuffGradeInfo()

        if DragonBuffCfg[curLevel].unlimit == false then
            CanUseTime = self.buffStartTime + DragonBuffCfg[curLevel].duration
        else
            CanUseTime = -1
        end

        havePoint = self.curNum
    end

    local nextNeedNum = self:getNextPoints( curLevel+AnotherLevel ) 
    local nextNeedAllNum = self:getNeedPointsAll( curLevel+AnotherLevel+1 )

    return {
	        grade = curLevel, 
            gradeEx = AnotherLevel, 
	        points = havePoint,
	        nextPoints = nextNeedNum,
	        expireTimestamp = CanUseTime,
            nextAllPoints = nextNeedAllNum
	    }
end

function DragonBuffManager:InGame( levelId )
    self.CurBuffLevel = 0 --0代表没使用buff
    self.AnotherLevel = 0
    --判断是否是代打
    if self:shouldShowActCollection( levelId )  then
        self:updateCollectInfo()
        local curLevel, AnotherLevel =  self:getDragonBuffGradeInfo()
        self.CurBuffLevel = curLevel
        self.AnotherLevel = AnotherLevel

        --打点
        local dcData = {
	        game_type = "stage",
	        game_name = "dragon2018",
	        category = "stage",
	        sub_category = "buff_start",
	        t1 = self.CurBuffLevel,
        }
        DcUtil:activity(dcData)

        return true
    end

    return false
end

function DragonBuffManager:getCurBuffLevelInGame()

    if not self.CurBuffLevel and not self.AnotherLevel then
        --not init
        return nil
    end

    if self.CurBuffLevel == 0 then
        return nil
    else
        local CanUseTime = 0
        if DragonBuffCfg[self.CurBuffLevel].unlimit == false then
            CanUseTime = self.buffStartTime + DragonBuffCfg[self.CurBuffLevel].duration
        else
            CanUseTime = -1
        end

        local nextNeedNum = self:getNextPoints( self.CurBuffLevel + self.AnotherLevel ) 
        local nextNeedAllNum = self:getNeedPointsAll(  self.CurBuffLevel + self.AnotherLevel + 1 )

        return {
             self.CurBuffLevel,
             self.AnotherLevel,
             self.curNum,
             nextNeedNum,
             CanUseTime,
             nextNeedAllNum
        }
    end
end

function DragonBuffManager:getBuffConfigByLevel( level )
    if DragonBuffCfg[level] then
        return DragonBuffCfg[level]
    end

    return nil
end