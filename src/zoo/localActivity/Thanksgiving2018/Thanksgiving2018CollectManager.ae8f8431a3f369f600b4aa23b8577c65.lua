
Thanksgiving2018CollectManager = class()

local instance = nil
Thanksgiving2018CollectManager.UserState = {
	kNone = 0,
	kNormal = 202, 			--没满级满星
	kTopLevel = 203,		--满级没满星
	kTopStar = 204,       	--满级满星
}

local OneStarGiveNum = 90

local VERSION = "1_"	--本地缓存标识 每次换皮应更改 
local ACT_SOURCE = 'Thanksgiving2018/Config.lua'
local ACT_ID = 4023

local ACT_MAIN_END_TIME = "Thanksgiving2018_main_end_time_"..VERSION
local ACT_ALL_END_TIME = "Thanksgiving2018_all_end_time_"..VERSION
local kStorageFileName = "Thanksgiving2018_"..VERSION
local kLocalDataExt = ".ds"

function Thanksgiving2018CollectManager.getInstance()
	if not instance then
		instance = Thanksgiving2018CollectManager.new()
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

function Thanksgiving2018CollectManager:init()
	self.curNum = 0
    self.UpdateActivityTime = 0

    self.MainEndTime = 0
    self.AllEndTime = 0

	self.userState = nil
	self.normalEffectLv = nil 	
    self.HaveData = false

	self.uid = getUid()
	self.filePath = HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName .. self.uid .. kLocalDataExt

	self:readFromLocal()
    if self.HaveData then
        self.MainEndTime = CCUserDefault:sharedUserDefault():getIntegerForKey(ACT_MAIN_END_TIME..self.uid) or 0
        self.AllEndTime = CCUserDefault:sharedUserDefault():getIntegerForKey(ACT_ALL_END_TIME..self.uid) or 0
    end

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

function Thanksgiving2018CollectManager:updateUserState()

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
			self.userState = Thanksgiving2018CollectManager.UserState.kTopStar
		else
			self.userState = Thanksgiving2018CollectManager.UserState.kTopLevel
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
			self.userState = Thanksgiving2018CollectManager.UserState.kNormal
		else
			self.normalEffectLv = nil
			self.userState = Thanksgiving2018CollectManager.UserState.kTopLevel
		end
	end
end

function Thanksgiving2018CollectManager:getUserState()
	return self.userState
end

function Thanksgiving2018CollectManager:getEffectLevelId()
	return self.normalEffectLv
end

function Thanksgiving2018CollectManager:setNextPlayShouldShowActCollectionForReplay( value )
	self.replayFlag = value
end

function Thanksgiving2018CollectManager:shouldShowActCollection(levelId)

	if self.replayFlag then 
		return true 
	end
	if not levelId then return false end 

    if self:bMaxLevel() then
        local bCanCollect1 = true
        local bCanCollect2 = true
        --满级玩家打指定关
        if levelId ~= self.levelId then 
            bCanCollect1 = false 
        end

        if not self.normalEffectLv then 
            bCanCollect2 = false 
        elseif levelId ~= self.normalEffectLv then
            bCanCollect2 = false
        end 

        if bCanCollect1 == false and bCanCollect2 == false  then
            return false
        end
    else
        --非满级打最高关
	    if not self.normalEffectLv then return false end 
	    if levelId ~= self.normalEffectLv then return false end 
    end

	return self:isActivitySupport()
end

function Thanksgiving2018CollectManager:getActCollectionSupport( levelId )

    if self.SaveSupport == nil then
        return self:shouldShowActCollection( levelId )
    end

    return self.SaveSupport
end

function Thanksgiving2018CollectManager:SaveActCollectionSupport( bSupport )
    self.SaveSupport = bSupport
end

function Thanksgiving2018CollectManager:isActivitySupport()
    self:PassDayReset()

	local endTime = self.MainEndTime or 0
	if Localhost:timeInSec() > endTime then 
		return false
	end

	return true
end

function Thanksgiving2018CollectManager:isActivitySupportAll()

	local endTime = self.AllEndTime or 0
	if Localhost:timeInSec() > endTime then 
		return false
	end

	return true
end

function Thanksgiving2018CollectManager:getDayStartTimeByTS(ts) --传入毫秒
	local utc8TimeOffset = 57600*1000 -- (24 - 8) * 3600
	local oneDaySeconds = 86400*1000 -- 24 * 3600
	return ts - ((ts - utc8TimeOffset) % oneDaySeconds)
end

function Thanksgiving2018CollectManager:readFromLocal()
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
            self.UpdateActivityTime = data.UpdateActivityTime or 0

            self.playedLevelIds = data.playedLevelIds or {}
            self.playedLevelIds1 = data.playedLevelIds1 or {}
            self.levelId = data.levelId or 1
            self.turntableLv = data.turntableLv or 1
            self.itemIds = data.itemIds or {}
            self.contactInfo = data.contactInfo or {}
            self.LotteryConfig = data.LotteryConfig or {}
            self.objectId_0 = data.objectId_0 or 0
            self.objectId_5 = data.objectId_5 or 0

            self.greyRewardIndexes = data.greyRewardIndexes or {}
            self.doubleRewardIndexes = data.doubleRewardIndexes or {}
            self.strengthenStartTime = data.strengthenStartTime or 0
            self.HeadFrameID = data.HeadFrameID or 66013
            self.SpecialCDTime = data.SpecialCDTime or 900000
            self.fullLevel = data.fullLevel or false

            self.HaveData = true
        else
            self.HaveData = false
		end
	end

    self:PassDayReset()
end

function Thanksgiving2018CollectManager:PassDayReset()

    if self.UpdateActivityTime == 0 then
        return
    end
    
    --第二天刷新数据
    local SaveStartTime = self:getDayStartTimeByTS( self.UpdateActivityTime )
    local TodayStartTime = self:getDayStartTimeByTS( Localhost:time() )

    if SaveStartTime ~= TodayStartTime then
        self.curNum = 0
        self.UpdateActivityTime = Localhost:time()
        self:addCollectionNum( self.curNum )

        self:writeToLocal()
    end

end

function Thanksgiving2018CollectManager:writeToLocal()
	local data = {}
	data.curNum = self.curNum
    data.UpdateActivityTime = self.UpdateActivityTime

    data.playedLevelIds = self.playedLevelIds
    data.playedLevelIds1 = self.playedLevelIds1
    data.levelId = self.levelId
    data.turntableLv = self.turntableLv
    data.itemIds = self.itemIds
    data.contactInfo = self.contactInfo
    data.LotteryConfig = self.LotteryConfig
    data.objectId_0 = self.objectId_0
    data.objectId_5 = self.objectId_5

    data.greyRewardIndexes = self.greyRewardIndexes
    data.doubleRewardIndexes = self.doubleRewardIndexes
    data.strengthenStartTime = self.strengthenStartTime
    data.HeadFrameID = self.HeadFrameID
    data.SpecialCDTime = self.SpecialCDTime

    data.fullLevel = self.fullLevel
    

	local content = amf3.encode(data)
    local file = io.open(self.filePath, "wb")
    -- assert(file, "Thanksgiving2018CollectManager persistent file failure " .. kStorageFileName)
    if not file then return end
	local success = file:write(content)
   
    if success then
        file:flush()
        file:close()
    else
        file:close()
    end
end

function Thanksgiving2018CollectManager:updateByActivity(mainEndTime, allEndTime, model, Meta )
	CCUserDefault:sharedUserDefault():setIntegerForKey(ACT_MAIN_END_TIME..self.uid, mainEndTime)
	CCUserDefault:sharedUserDefault():setIntegerForKey(ACT_ALL_END_TIME..self.uid, allEndTime)

    self.MainEndTime = mainEndTime or 0
    self.AllEndTime = allEndTime or 0

	self.curNum = 0 --当前拥有数量
    self.playedLevelIds = model.playedLevelIds or {}
    self.playedLevelIds1 = model.playedLevelIds1 or {}
    self.levelId = model.levelId or 1 --满级玩家打的关卡
    self.turntableLv = model.turntableLv or 1
    self.itemIds = model.itemIds or {}
    self.contactInfo = model.contactInfo or {}
    self.greyRewardIndexes = model.greyRewardIndexes or {}
    self.doubleRewardIndexes = model.doubleRewardIndexes or {}
    self.strengthenStartTime = model.strengthenStartTime or 0
    self.fullLevel = model.fullLevel or false

    self.LotteryConfig = Meta.LotteryConfig
    self.objectId_0 = Meta.objectId_0
    self.objectId_5 = Meta.objectId_5
    self.HeadFrameID = Meta.HeadFrameId
    self.SpecialCDTime = Meta.SpecialCDTime
    

    self:addCollectionNum( model.gemNum )
    self.UpdateActivityTime = Localhost:time()

	-- self:updateEffectFlowerNodeShow()
end

function Thanksgiving2018CollectManager:getActivityIcon()
	for k,v in pairs(HomeScene:sharedInstance().activityIconButtons or {}) do
		if v.source == ACT_SOURCE then
			return v
		end
	end
end

function Thanksgiving2018CollectManager:getLotteryConfigInfoByTurnLevel( )

    for i,v in pairs( self.LotteryConfig ) do
        if self.turntableLv == v.level then
            return v
        end
    end

    return nil
end

function Thanksgiving2018CollectManager:bHaveObjectReward( )

    for i,v in ipairs(self.itemIds) do
        if v >= self.objectId_0 and v <= self.objectId_5 then
            return true
        end
    end
   
    return false 
end

function Thanksgiving2018CollectManager:updateActIconRewardFlagShow()
    --更新奖字
--    local bIconShow = false

--    local LotteryConfigInfo = self:getLotteryConfigInfoByTurnLevel()
--    if self.curNum >= LotteryConfigInfo.cost then
--        bIconShow = true
--    end

--    if self:bHaveObjectReward() then
--        local bHaveContactInfo = table.size(self.contactInfo or {}) > 0

--        if not bHaveContactInfo then
--            bIconShow = true
--        end
--    end

    local bCanZhuanpan = self.curNum >= 100
    if bCanZhuanpan then
        self:updateActIconRewardFlag( bCanZhuanpan )
    end
end

function Thanksgiving2018CollectManager:updateActIconRewardFlag( bShow )
	local ret = table.find(ActivityUtil:getActivitys() or {},function(v)
		return v.source == ACT_SOURCE
	end)
	if ret then 
		ActivityUtil:setRewardMark(ACT_SOURCE, bShow)
	end
end

--藤蔓飞到活动里
function Thanksgiving2018CollectManager:handleStarIncrease(levelId, starIncreaseNum, startPos)

	self:addCollectionNum(starIncreaseNum * OneStarGiveNum)

	local endPos
	local icon = self:getActivityIcon()

    --判断能不能往活动上飞
    if icon then
        local bounds = icon:getGroupBounds()
		endPos = ccp(bounds:getMidX(), bounds:getMidY())
    end

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

function Thanksgiving2018CollectManager:loadSkeletonAssert()
	FrameLoader:loadArmature('tempFunctionRes/CountdownParty/skeleton/countdown_party', 'countdown_party', 'countdown_party')
end

function Thanksgiving2018CollectManager:unloadSkeletonAssert()
    ArmatureFactory:remove('countdown_party', 'countdown_party')
end

function Thanksgiving2018CollectManager:addCollectionNum(num)
    self:PassDayReset()

    self.curNum = self.curNum + num

	self:writeToLocal()


    --更新奖字
    self:updateActIconRewardFlagShow()

    --推送
    if self.curNum > 100 then
        local config = self:getActConfigSync( ACT_ID )
        if config then
            config:handleNotification2()
        end
    end
end

function Thanksgiving2018CollectManager:getActConfigSync(actId)
	local activitys = ActivityUtil:getAllActivitysSync()
	local activity = table.find(activitys,function( v )
        local c = require("activity/" .. v.source)
        return tostring(c.actId) == tostring(actId)
    end)
    
    if activity  then
    	return (require("activity/" .. activity.source))
    end
end

function Thanksgiving2018CollectManager:getProgressShowNum()
	local totalCurNum = self.curNum

    local limitNum = 0

    local LotteryConfigInfo = self:getLotteryConfigInfoByTurnLevel()
    local CostNum = LotteryConfigInfo.cost

	return totalCurNum, CostNum
end

function Thanksgiving2018CollectManager:getPasslevelExtraData(levelId, star, actCollectionNum)
	local extraData = {}
	extraData.userState = 0
--	local userLevelState = self:getUserStateByActivityMaxLevel( self.maxLevel )
    self:updateUserState()

    extraData.userState = self.userState
   
    if self:bMaxLevel() then
        if levelId == self.levelId then 
		    extraData.collectionNum = actCollectionNum
        else
            local effLv = self:getEffectLevelId()
	        if effLv and levelId == effLv then 
		        extraData.collectionNum = actCollectionNum
	        end
	    end
    else
         local effLv = self:getEffectLevelId()
	    if effLv and levelId == effLv then 
		    extraData.collectionNum = actCollectionNum
	    end
    end
	return extraData
end

function Thanksgiving2018CollectManager:setPassLevel( levelId )

    local configTopLevel, topAdjustY = NewAreaOpenMgr.getInstance():getCanPlayTopLevel()
    if configTopLevel == levelId and not self.fullLevel then
        self.fullLevel = true

        local function onGetRequestNumSuccess(evt)
            ActivityUtil:setActInfos(evt.data.actInfos)
        end

        if not PrepackageUtil:isPreNoNetWork() then
		    local function getRequestNum( ... )
			    local http = GetRequestNumHttp.new(false)
			    http:ad(Events.kComplete, onGetRequestNumSuccess)
			    -- http:load()
			    http:syncLoad("Thanksgiving2018CollectManager")
		    end
		    RequireNetworkAlert:callFuncWithLogged(getRequestNum, nil, kRequireNetworkAlertAnimation.kNoAnimation)
	    end
    end

    self:writeToLocal()
end

function Thanksgiving2018CollectManager:setLevelPass( levelId )

    local LevelList = {}

	if self.fullLevel then
		LevelList = self.playedLevelIds
	else
		LevelList = self.playedLevelIds1
	end

    local bFind = false
    if LevelList then
        if #LevelList > 0 then

            local bFind = false
            for i,v in ipairs(LevelList) do
                if v == levelId then
                    bFind = true
                end
            end
        end
    end

    if bFind == false then
        table.insert( LevelList, levelId )
    end

    self:writeToLocal()
end

--置空推荐关卡
function Thanksgiving2018CollectManager:ClearLevelID( )
    --推荐关卡关闭 需要点开活动再次获得
    self.levelId = 0
    self:writeToLocal()
end

--当前关卡是否双倍
function Thanksgiving2018CollectManager:RewardIsDouble( levelId )

    local LevelList = {}

	if self.fullLevel then
		LevelList = self.playedLevelIds
	else
		LevelList = self.playedLevelIds1
	end

    if LevelList then

        if #LevelList > 0 then
            for i,v in ipairs(LevelList) do
                if v == levelId then
                    return false
                end
            end
        else
            return true
        end
    else
        return false
    end

    return true
end

--获取当前收集到的数量
function Thanksgiving2018CollectManager:getCurCollectNum( ... )
    local mainLogic = GameBoardLogic:getCurrentLogic()
    if mainLogic and mainLogic.actCollectionNum then 
        return mainLogic.actCollectionNum
    end
    return 0
end

--加五步面板展示的第一个数字
function Thanksgiving2018CollectManager:getNum1( ... )
	-- body
    return self:getCurCollectNum()
end

--加五步面板展示的第二个数字(如果有额外收益，那么包含额外收益)
function Thanksgiving2018CollectManager:getNum2( levelId )
	-- body
    local bCanDouble = self:RewardIsDouble( levelId )

    local curCollectNum = self:getCurCollectNum()

    local normalNum = curCollectNum*10
    local doubleNum = 0

    if bCanDouble then
        normalNum = normalNum*2
    end

    local num1 = self:getNum1()

    return normalNum - num1
end

--查询某一关是不是首次在玩
function Thanksgiving2018CollectManager:isFirstTime( levelId )
    return self:RewardIsDouble(levelId)
end

--首次玩的额外收益
function Thanksgiving2018CollectManager:getFirstTimeExtraNum( levelId )
	-- body
    local bCanDouble = self:RewardIsDouble( levelId )
    if not bCanDouble then
         return 0
    end

    local curCollectNum = self:getCurCollectNum()

    local normalNum = curCollectNum*10
    local doubleNum = normalNum*2

    return doubleNum - normalNum
end

--当前关是否可收集
function Thanksgiving2018CollectManager:getCurLevelIsCanCollect( levelId )
	return self:shouldShowActCollection( levelId )
end


function Thanksgiving2018CollectManager:bInSpecialTime( )

	local CurTime = Localhost:time()
	if self.strengthenStartTime ~=0 and CurTime <= self.strengthenStartTime + self.SpecialCDTime then
		return true
	end

	return false
end

function Thanksgiving2018CollectManager:bMaxLevel()
	return self.fullLevel or false
end

--开始关卡打点
function Thanksgiving2018CollectManager:StartLevelDC( )

    local bInSpecialTime = self:bInSpecialTime()

    local t1 = 2
    local t2

    if bInSpecialTime then
        t1 = 1

        local HideNum =  #self.greyRewardIndexes
        local doubleNum = #self.doubleRewardIndexes

        if HideNum == 2 then
            t2 = 1
        elseif HideNum == 4 then
            t2 =2
        elseif doubleNum == 1 then
            t2 =3
        elseif doubleNum == 2 then
            t2 =4
         elseif doubleNum == 3 then
            t2 =5
        elseif doubleNum == 4 then
            t2 =6
        elseif doubleNum == 5 then
            t2 =7
        elseif doubleNum == 6 then
            t2 =8
        elseif doubleNum == 7 then
            t2 =9
        elseif doubleNum == 8 then
            t2 =10
        end
    end

	local params = {
		    game_type = "share",
		    game_name = "thanksgiving2018",
		    category = "canyu",
		    sub_category = "thanksgiving2018_buff",
		    t1 = t1,
		    t2 = t2,
	    }

	DcUtil:activity(params)
end

--关卡收集打点
function Thanksgiving2018CollectManager:CollectDC( num )

	local params = {
		    game_type = "share",
		    game_name = "thanksgiving2018",
		    category = "canyu",
		    sub_category = "thanksgiving2018_amount",
		    t = num,
	    }

	DcUtil:activity(params)
end

--replay标记
function Thanksgiving2018CollectManager:getReplayFlag(  )
    return "Thanksgiving2018_Config.lua"
end