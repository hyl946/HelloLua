
Qixi2018CollectManager = class()

local instance = nil
Qixi2018CollectManager.UserState = {
	kNone = 0,
	kNormal = 202, 			--没满级满星
	kTopLevel = 203,		--满级没满星
	kTopStar = 204,       	--满级满星
}


local OneStarGiveNum = 90

--100兑换70个收集物
local WeekDiamondChangeNum = 100
local WeekDiamondGetNum = 70

local VERSION = "1_"	--本地缓存标识 每次换皮应更改 
local ACT_SOURCE = 'QiXi201807/Config.lua'
local ACT_OPPO_SOURCE = 'Act4021_OppoRank/Config.lua'

local ACT_MAIN_END_TIME = "QiXi201807_main_end_time_"..VERSION
local ACT_ALL_END_TIME = "QiXi201807_all_end_time_"..VERSION
local ACT_MAIN_END_OPPO_RANK_TIME = "QiXi201807_main_end_time_oppo_rank_"..VERSION
local kStorageFileName = "QiXi201807_"..VERSION
local kLocalDataExt = ".ds"

function Qixi2018CollectManager.getInstance()
	if not instance then
		instance = Qixi2018CollectManager.new()
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

function Qixi2018CollectManager:init()
	self.curNum = 0
	self.limitList = {}
    self.maxLevel = 0
    self.rewardList = {}
    self.bHeadFull = 0
    self.bTreeFull = 0
    self.UpdateActivityTime = 0
    self.maxOppoLevel = 0
    self.weekTargetCount = 0
    self.weekusedTargetCount = 0
    self.TreeReward = 0
    self.RewardDay = 0

	self.userState = nil
	self.normalEffectLv = nil 		
    
    self.bIsShowStartPanel = false
    self.SaveStartCanRewardAll = false

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
	-- local levelConfig = LevelDataManager.sharedLevelData():getLevelConfigByID(levelId, false)
	-- if levelConfig.hasDropDownUFO then 
	-- 	return false
	-- end

	return true
end


--根据活动开启时的最高关卡 算满级满星状态
function Qixi2018CollectManager:getUserStateByActivityMaxLevel( maxLevel )
    if not maxLevel or maxLevel == 0 then
        return 0
    end

    local userState = 0

    local configTopLevel = maxLevel
	local configFullStar = configTopLevel * 3

    local CurUserLevel = UserManager:getInstance().user.topLevelId
    if CurUserLevel > configTopLevel then
        CurUserLevel = configTopLevel
    end

	local userTopLevel = CurUserLevel
	local userFullStar = 0
	local scores = UserManager:getInstance():getScoreRef()
	for k, v in pairs(scores) do
		if v.levelId <= userTopLevel and LevelType:isMainLevel(v.levelId) then 
			local star = tonumber(v.star)
			if star > 3 then
				star = 3 
			end
			userFullStar = userFullStar + star
		end
    end

	local userTopLevelPassed = false 
	local scoreOfLevel = UserManager:getInstance():getUserScore(userTopLevel)
	if scoreOfLevel then
		if scoreOfLevel.star ~= 0 or 
			JumpLevelManager:getLevelPawnNum(userTopLevel) > 0 or 
			UserManager:getInstance():hasAskForHelpInfo(userTopLevel) then 
			userTopLevelPassed = true	
		end
	end

	if userTopLevel > configTopLevel or (userTopLevel == configTopLevel and userTopLevelPassed) then --满级
		if userFullStar >= configFullStar then 
			userState = Qixi2018CollectManager.UserState.kTopStar
		else
			userState = Qixi2018CollectManager.UserState.kTopLevel
		end
	else
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
				break
			end
		end
		if find then 
			userState = Qixi2018CollectManager.UserState.kNormal
		else
			userState = Qixi2018CollectManager.UserState.kTopLevel
		end
	end

    return userState
end

function Qixi2018CollectManager:updateUserState()
    local configTopLevel, topAdjustY = NewAreaOpenMgr.getInstance():getCanPlayTopLevel()
	local configFullStar = configTopLevel * 3
	local userTopLevel = UserManager:getInstance().user.topLevelId
	local userFullStar = 0
	local scores = UserManager:getInstance():getScoreRef()
	for k, v in pairs(scores) do
		if v.levelId <= userTopLevel and LevelType:isMainLevel(v.levelId) then 
			local star = tonumber(v.star)
			if star > 3 then
				star = 3 
			end
			userFullStar = userFullStar + star
		end
    end

	local userTopLevelPassed = false 
	local scoreOfLevel = UserManager:getInstance():getUserScore(userTopLevel)
	if scoreOfLevel then
		if scoreOfLevel.star ~= 0 or 
			JumpLevelManager:getLevelPawnNum(userTopLevel) > 0 or 
			UserManager:getInstance():hasAskForHelpInfo(userTopLevel) then 
			userTopLevelPassed = true	
		end
	end

	if userTopLevel > configTopLevel or (userTopLevel == configTopLevel and userTopLevelPassed) then --满级
		self.normalEffectLv = nil
		if userFullStar >= configFullStar then 
			self.userState = Qixi2018CollectManager.UserState.kTopStar
		else
			self.userState = Qixi2018CollectManager.UserState.kTopLevel
		end
	else
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
			self.userState = Qixi2018CollectManager.UserState.kNormal
		else
			self.normalEffectLv = nil
			self.userState = Qixi2018CollectManager.UserState.kTopLevel
		end
	end
end

function Qixi2018CollectManager:getUserState()
	return self.userState
end

function Qixi2018CollectManager:getEffectLevelId()
	return self.normalEffectLv
end

function Qixi2018CollectManager:shouldShowActCollection(levelId)
	if not levelId then return false end 
	if not self.normalEffectLv then return false end 
	if levelId ~= self.normalEffectLv then return false end 
	return self:isActivitySupport()
end

function Qixi2018CollectManager:isActivitySupport()
    self:PassDayReset()

--    if self.bTreeFull == 1 then
--        if #self.rewardList == 4 then 
--		    return false 
--	    end
--    else
	    if self.limitList and #self.limitList == 0 then 
		    return false 
	    end

        if #self.rewardList == 4 then 
		    return false 
	    end

        if self.curNum >= self.limitList[4] then 
		    return false 
	    end
--    end

--	if __WIN32 then 
--		return true
--	end

	local endTime = CCUserDefault:sharedUserDefault():getIntegerForKey(ACT_MAIN_END_TIME..self.uid) or 0
	if Localhost:timeInSec() > endTime then 
		return false
	end

	return true
end

function Qixi2018CollectManager:isActivitySupportAll()

--    if self.bTreeFull == 1 then
--        return false
--    else
	    if self.limitList and #self.limitList == 0 then 
		    return false 
	    end

        if #self.rewardList == 4 then 
		    return false 
	    end
--    end

--	if __WIN32 then 
--		return true
--	end

	local endTime = CCUserDefault:sharedUserDefault():getIntegerForKey(ACT_ALL_END_TIME..self.uid) or 0
	if Localhost:timeInSec() > endTime then 
		return false
	end

	return true
end

function Qixi2018CollectManager:shouldShowOppoActCollection(levelId)

	if not levelId then return false end 
	if not self.normalEffectLv then return false end 
	if levelId ~= self.normalEffectLv then return false end 
	return self:isActivityOppoRankSupport()
end

function Qixi2018CollectManager:isActivityOppoRankSupport()

--	if __WIN32 then 
--		return true
--	end

	local endTime = CCUserDefault:sharedUserDefault():getIntegerForKey(ACT_MAIN_END_OPPO_RANK_TIME..self.uid) or 0
	if Localhost:timeInSec() > endTime then 
		return false
	end

	return true
end

function Qixi2018CollectManager:isActivityOppoSupportAll()

--	if __WIN32 then 
--		return true
--	end

	local endTime = CCUserDefault:sharedUserDefault():getIntegerForKey(ACT_MAIN_END_OPPO_RANK_TIME..self.uid) or 0
	if Localhost:timeInSec() > endTime then 
		return false
	end

	return true
end

function Qixi2018CollectManager:getDayStartTimeByTS(ts) --传入毫秒
	local utc8TimeOffset = 57600*1000 -- (24 - 8) * 3600
	local oneDaySeconds = 86400*1000 -- 24 * 3600
	return ts - ((ts - utc8TimeOffset) % oneDaySeconds)
end


function Qixi2018CollectManager:readFromLocal()
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
			self.limitList = data.limitList or {}
            self.maxLevel = data.maxLevel or 0
            self.rewardList = data.rewardList or {}
            self.bHeadFull = data.bHeadFull or 0
            self.bTreeFull = data.bTreeFull or 0
            self.UpdateActivityTime = data.UpdateActivityTime or 0
		    self.maxOppoLevel = data.maxOppoLevel or 0
            self.weekTargetCount = data.weekTargetCount or 0
            self.weekusedTargetCount = data.weekusedTargetCount or 0
            self.TreeReward = data.TreeReward or 0
            self.RewardDay = data.RewardDay or 0
		end
	end

    self:PassDayReset()
end

function Qixi2018CollectManager:PassDayReset()

    if self.UpdateActivityTime == 0 then
        return
    end
    
    --第二天刷新数据
    local SaveStartTime = self:getDayStartTimeByTS( self.UpdateActivityTime )
    local TodayStartTime = self:getDayStartTimeByTS( Localhost:time() )

    if SaveStartTime ~= TodayStartTime then
        self.curNum = 0
        self.rewardList = {}
        self.UpdateActivityTime = Localhost:time()
        self.weekTargetCount = 0
        self.weekusedTargetCount = 0
        self:addCollectionNum( self.curNum )

        if self.bTreeFull and self.RewardDay > 0 then
            self.TreeReward = 0
            self.RewardDay = self.RewardDay - 1
            if self.RewardDay < -1 then
                self.RewardDay = -1
            end
        end

        self:writeToLocal()
    end

end

function Qixi2018CollectManager:writeToLocal()
	local data = {}
	data.curNum = self.curNum
	data.limitList = self.limitList
    data.rewardList = self.rewardList
    data.maxLevel = self.maxLevel
    data.bHeadFull = self.bHeadFull
    data.bTreeFull = self.bTreeFull
    data.UpdateActivityTime = self.UpdateActivityTime
    data.maxOppoLevel = self.maxOppoLevel
    data.weekTargetCount = self.weekTargetCount
    data.weekusedTargetCount = self.weekusedTargetCount
    data.TreeReward = self.TreeReward
    data.RewardDay = self.RewardDay

	local content = amf3.encode(data)
    local file = io.open(self.filePath, "wb")
    -- assert(file, "Qixi2018CollectManager persistent file failure " .. kStorageFileName)
    if not file then return end
	local success = file:write(content)
   
    if success then
        file:flush()
        file:close()
    else
        file:close()
    end
end

function Qixi2018CollectManager:updateByActivity(mainEndTime, allEndTime, curTotalNum, curLimitList,rewardList, maxLevel, bTreeFull, bHeadFull, weekTargetCount, weekusedTargetCount, TreeReward, RewardDay )
	CCUserDefault:sharedUserDefault():setIntegerForKey(ACT_MAIN_END_TIME..self.uid, mainEndTime)
	CCUserDefault:sharedUserDefault():setIntegerForKey(ACT_ALL_END_TIME..self.uid, allEndTime)
	self.curNum = 0 --当前拥有数量
	self.limitList = curLimitList --当前条件数量列表
    self.rewardList = rewardList
    self.maxLevel = maxLevel --活动开启时间内的最高关卡
    self.bTreeFull = bTreeFull
    self.bHeadFull = bHeadFull
    self.weekTargetCount = weekTargetCount
    self.weekusedTargetCount = weekusedTargetCount
    self.TreeReward = TreeReward
    self.RewardDay = RewardDay

    self:addCollectionNum(curTotalNum)
    self.UpdateActivityTime = Localhost:time()

	-- self:updateEffectFlowerNodeShow()
end

function Qixi2018CollectManager:updateByActivityOppoRank(mainEndTime,maxOppoLevel)
	CCUserDefault:sharedUserDefault():setIntegerForKey(ACT_MAIN_END_OPPO_RANK_TIME..self.uid, mainEndTime)
    self.maxOppoLevel = maxOppoLevel --活动开启时间内的最高关卡

end

function Qixi2018CollectManager:getActivityIcon()
	for k,v in pairs(HomeScene:sharedInstance().activityIconButtons or {}) do
		if v.source == ACT_SOURCE then
			return v
		end
	end
end

function Qixi2018CollectManager:getOppoActivityIcon()
	for k,v in pairs(HomeScene:sharedInstance().activityIconButtons or {}) do
		if v.source == ACT_OPPO_SOURCE then
			return v
		end
	end
end

function Qixi2018CollectManager:updateActIconRewardFlagShow()
    --更新奖字
    local function CanReward( index )
        for i,v in pairs( self.rewardList ) do
            if v == index then
                return false
            end
        end

        return true
    end

    local bIconShow = false

    local bActIsEnd = false
    local endTime = CCUserDefault:sharedUserDefault():getIntegerForKey(ACT_MAIN_END_TIME..self.uid) or 0
	if Localhost:timeInSec() > endTime then 
        bActIsEnd = true
    end

    local CanRewardIndex = self:getCurCanRewardIndex()
	if CanRewardIndex ~= 0 and CanReward( CanRewardIndex ) and not bActIsEnd then 
		bIconShow = true
	end

    if self.bTreeFull ==1 and self.TreeReward == 0 and self.RewardDay >= 0 and self.RewardDay < 7 then
        bIconShow = true
    end
 
    self:updateActIconRewardFlag( bIconShow )
end

function Qixi2018CollectManager:updateActIconRewardFlag( bShow )
	local ret = table.find(ActivityUtil:getActivitys() or {},function(v)
		return v.source == ACT_SOURCE
	end)
	if ret then 
		ActivityUtil:setRewardMark(ACT_SOURCE, bShow)
	end
end

--藤蔓飞到活动里
function Qixi2018CollectManager:handleStarIncrease(levelId, starIncreaseNum, startPos)

	self:addCollectionNum(starIncreaseNum * OneStarGiveNum)

	local endPos
	local icon = self:getActivityIcon()
    local oppoIcon = self:getOppoActivityIcon()


    --判断能不能往七夕活动上飞。不行就飞oppo
    local bCanFlyToQixi = true
    if self.bTreeFull == 1 then
        bCanFlyToQixi = false
    else
	    if self.limitList and #self.limitList == 0 then 
		    bCanFlyToQixi = false
        elseif self.rewardList and #self.rewardList == 4 then 
            bCanFlyToQixi = false
        elseif self.limitList[4] and self.curNum >= self.limitList[4] then 
            bCanFlyToQixi = false
	    end
    end

    local endTime = CCUserDefault:sharedUserDefault():getIntegerForKey(ACT_MAIN_END_TIME..self.uid) or 0
	if Localhost:timeInSec() > endTime then 
		bCanFlyToQixi = false
	end
    -----
    --判断能不能往七夕活动上飞。不行就飞oppo
    local bCanFlyToOppoQixi = true

    local endTime = CCUserDefault:sharedUserDefault():getIntegerForKey(ACT_MAIN_END_OPPO_RANK_TIME..self.uid) or 0
	if Localhost:timeInSec() > endTime then 
		bCanFlyToOppoQixi = false
	end

    if icon and bCanFlyToQixi then
        local bounds = icon:getGroupBounds()
		endPos = ccp(bounds:getMidX(), bounds:getMidY())
    elseif oppoIcon and bCanFlyToOppoQixi then
        local bounds = oppoIcon:getGroupBounds()
		endPos = ccp(bounds:getMidX(), bounds:getMidY())
    end


--	if icon then 
--		local bounds = icon:getGroupBounds()
--		endPos = ccp(bounds:getMidX(), bounds:getMidY())
--	end

	local scene = Director:sharedDirector():getRunningScene()
	local flyContainer = CocosObject:create()
	local whiteBg = Sprite:createWithSpriteFrameName("countdown_party_flower/countdown_party_fly_item0000")
	whiteBg:setScale(0.8)
	local itemIcon = Sprite:createWithSpriteFrameName("countdown_party_flower/countdown_party_fly_item0000")
	local itemIconSize = itemIcon:getContentSize()
	local num = Sprite:createWithSpriteFrameName("countdown_party_flower/countdown_party_fly_num_"..starIncreaseNum.."0000")
	local numSize = num:getContentSize()

	flyContainer:addChild(whiteBg)
	whiteBg:setPosition(ccp(-itemIconSize.width/2, 0))
	flyContainer:addChild(itemIcon)
	itemIcon:setPosition(ccp(-itemIconSize.width/2, 0))
	flyContainer:addChild(num)
	num:setPosition(ccp(numSize.width/2, 0))

	flyContainer:setPosition(ccp(startPos.x, startPos.y))
	scene:addChild(flyContainer)

	local flyTime = 0.4
	local arr = CCArray:create()
	arr:addObject(CCScaleTo:create(0.1, 1.2))
	arr:addObject(CCScaleTo:create(0.1, 1))
	arr:addObject(CCDelayTime:create(0.5))

	if endPos then 
		arr:addObject(CCCallFunc:create(function ()
			local arr1 = CCArray:create()
			arr1:addObject(CCDelayTime:create(flyTime*0.8))
			arr1:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(flyTime*0.2 + 0.1, 1.3), CCFadeTo:create(flyTime*0.2 + 0.1, 0)))
			whiteBg:runAction(CCSequence:create(arr1))

			local arr2 = CCArray:create()
			arr2:addObject(CCScaleTo:create(flyTime, 0.8))
			arr2:addObject(CCSequence:createWithTwoActions(CCDelayTime:create(flyTime*0.8), CCFadeTo:create(flyTime*0.2, 0)))
			itemIcon:runAction(CCSpawn:create(arr2))

			num:runAction(CCFadeTo:create(flyTime/3*2, 0))
		end))

		arr:addObject(HeBezierTo:create(flyTime, ccp(endPos.x + itemIconSize.width/2, endPos.y), true, ccpDistance(endPos, startPos) * 0.1))
		-- arr:addObject(CCEaseSineOut:create(CCMoveTo:create(flyTime, ccp(endPos.x + itemIconSize.width/2, endPos.y))))

		arr:addObject(CCDelayTime:create(0.1))
	end

	arr:addObject(CCCallFunc:create(function ()
		self:updateActIconRewardFlagShow()
		flyContainer:removeFromParentAndCleanup(true)
	end))
	flyContainer:runAction(CCSequence:create(arr))
end

function Qixi2018CollectManager:loadSkeletonAssert()
	FrameLoader:loadArmature('tempFunctionRes/CountdownParty/skeleton/countdown_party', 'countdown_party', 'countdown_party')
end

function Qixi2018CollectManager:unloadSkeletonAssert()
    ArmatureFactory:remove('countdown_party', 'countdown_party')
end

function Qixi2018CollectManager:addCollectionNum(num)
    self:PassDayReset()

    self.curNum = self.curNum + num

	self:writeToLocal()


    --更新奖字
    self:updateActIconRewardFlagShow()
end

function Qixi2018CollectManager:addWeekCollectionNum(num)

    self.weekTargetCount = self.weekTargetCount + num

    local MoreNum = self.weekTargetCount - self.weekusedTargetCount
    if MoreNum > WeekDiamondChangeNum then
        local CanChangeNum = math.floor( MoreNum/WeekDiamondChangeNum )

        self.weekusedTargetCount = self.weekusedTargetCount + CanChangeNum * WeekDiamondChangeNum
        self:addCollectionNum( CanChangeNum * WeekDiamondGetNum )
    end


	self:writeToLocal()
end

function Qixi2018CollectManager:getCurCanRewardIndex()
    local totalCurNum = self.curNum

    local canGerRewardMaxIndex = 0
    for i,v in ipairs(self.limitList) do
        if totalCurNum >= v  then
            canGerRewardMaxIndex = i
        end
    end

    return canGerRewardMaxIndex
end

function Qixi2018CollectManager:getIsAllReward()

    if self.limitList and #self.limitList > 0 then
        if #self.rewardList >= #self.limitList then
            return true
        end
    end

    return false
end

function Qixi2018CollectManager:GetIsReward( index)
    for i,v in pairs(self.rewardList) do
        if v == index then
            return true
        end
    end

    return false
end

function Qixi2018CollectManager:getProgressShowNum()
	local totalCurNum = self.curNum

    local limitNum = 0

    if self.limitList and #self.limitList > 0 then
        if #self.rewardList >= #self.limitList then
            limitNum = self.limitList[#self.limitList]
        else
            local noRewardIndex = 4
            for i=1, 4 do
                local bReward = self:GetIsReward(i)

                if bReward == false then
                    noRewardIndex = i
                    break
                end
            end
            
            limitNum = self.limitList[noRewardIndex]
        end
    end

	return totalCurNum, limitNum
end

function Qixi2018CollectManager:getPasslevelExtraData(levelId, star, actCollectionNum)
	local extraData = {}
	extraData.userState = 0
	local userLevelState = self:getUserStateByActivityMaxLevel( self.maxLevel )
--    self:updateUserState()

    extraData.userState = userLevelState
    local effLv = self:getEffectLevelId()
	if effLv and levelId == effLv then 
		extraData.collectionNum = actCollectionNum
	end

	return extraData
end

function Qixi2018CollectManager:getPasslevelOppoExtraData(levelId, star, actCollectionNum)
	local extraData = {}
	extraData.userState = 0
	local userLevelState = self:getUserStateByActivityMaxLevel( self.maxOppoLevel )
--    self:updateUserState()

    extraData.userState = userLevelState
    local effLv = self:getEffectLevelId()
	if effLv and levelId == effLv then 
		extraData.collectionNum = actCollectionNum
	end

	return extraData
end

function Qixi2018CollectManager:getCurIsAllRewardAll(  )
    return self:getIsAllRewardAll( self.curNum )
end

function Qixi2018CollectManager:getIsAllRewardAll( num )

    for i,v in ipairs(self.limitList) do
        if num < v then
            return false
        end
    end
    return true
end

function Qixi2018CollectManager:getCurIsShowStartPanel()
    return self.bIsShowStartPanel
end

function Qixi2018CollectManager:getSaveStartCanRewardAll()
    return self.SaveStartCanRewardAll
end

function Qixi2018CollectManager:setCurIsShowStartPanel( bIsShowStartPanel )
    self.bIsShowStartPanel = bIsShowStartPanel --记录显示过开始面板上的气泡 
    self.SaveStartCanRewardAll = self:getCurIsAllRewardAll()
end

function Qixi2018CollectManager:getRewardList()
    return self.rewardList
end

