
CountdownPartyManager = class()

local instance = nil
CountdownPartyManager.UserState = {
	kNone = 0,
	kNormal = 202, 			--没满级满星
	kTopLevel = 203,		--满级没满星
	kTopStar = 204,       	--满级满星
}

local VERSION = "2_"	--本地缓存标识 每次换皮应更改 
local ACT_SOURCE = 'RotaryTable201805/Config.lua'
local ACT_MAIN_END_TIME = "countdown_party_main_end_time_"..VERSION
local ACT_ALL_END_TIME = "countdown_party_all_end_time_"..VERSION
local kStorageFileName = "countdown_party_"..VERSION
local kLocalDataExt = ".ds"

function CountdownPartyManager.getInstance()
	if not instance then
		instance = CountdownPartyManager.new()
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

function CountdownPartyManager:init()
	self.curNum = 0
	self.limitNum = 0
	self.lotteryNum = 0

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
	-- local levelConfig = LevelDataManager.sharedLevelData():getLevelConfigByID(levelId, false)
	-- if levelConfig.hasDropDownUFO then 
	-- 	return false
	-- end

	return true
end

function CountdownPartyManager:updateUserState()
	local configTopLevel = MetaManager:getInstance():getMaxNormalLevelByLevelArea()
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
			self.userState = CountdownPartyManager.UserState.kTopStar
		else
			self.userState = CountdownPartyManager.UserState.kTopLevel
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
			self.userState = CountdownPartyManager.UserState.kNormal
		else
			self.normalEffectLv = nil
			self.userState = CountdownPartyManager.UserState.kTopLevel
		end
	end
end

function CountdownPartyManager:getUserState()
	return self.userState
end

function CountdownPartyManager:getEffectLevelId()
	return self.normalEffectLv
end

function CountdownPartyManager:shouldShowActCollection(levelId)
	if not levelId then return false end 
	if not self.normalEffectLv then return false end 
	if levelId ~= self.normalEffectLv then return false end 
	return self:isActivitySupport()
end

function CountdownPartyManager:isActivitySupport()
	if self.limitNum <= 0 then 
		return false 
	end

	if __WIN32 then 
		return true
	end

	-- local ret = table.find(ActivityUtil:getActivitys() or {},function(v)
	-- 	return v.source == ACT_SOURCE
	-- end)
	-- if not ret then 
	-- 	return false 
	-- end

	local endTime = CCUserDefault:sharedUserDefault():getIntegerForKey(ACT_MAIN_END_TIME..self.uid) or 0
	if Localhost:timeInSec() > endTime then 
		return false
	end

	return true
end

function CountdownPartyManager:isActivitySupportAll()
	if self.limitNum <= 0 then 
		return false 
	end

	if __WIN32 then 
		return true
	end

	-- local ret = table.find(ActivityUtil:getActivitys() or {},function(v)
	-- 	return v.source == ACT_SOURCE
	-- end)
	-- if not ret then 
	-- 	return false 
	-- end

	local endTime = CCUserDefault:sharedUserDefault():getIntegerForKey(ACT_ALL_END_TIME..self.uid) or 0
	if Localhost:timeInSec() > endTime then 
		return false
	end

	return true
end

function CountdownPartyManager:readFromLocal()
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
			self.limitNum = data.limitNum or 0
			self.lotteryNum = data.lotteryNum or 0
		end
	end
end

function CountdownPartyManager:writeToLocal()
	local data = {}
	data.curNum = self.curNum
	data.limitNum = self.limitNum
	data.lotteryNum = self.lotteryNum

	local content = amf3.encode(data)
    local file = io.open(self.filePath, "wb")
    -- assert(file, "CountdownPartyManager persistent file failure " .. kStorageFileName)
    if not file then return end
	local success = file:write(content)
   
    if success then
        file:flush()
        file:close()
    else
        file:close()
    end
end

function CountdownPartyManager:updateByActivity(mainEndTime, allEndTime, curTotalNum, curLimitNum)
	CCUserDefault:sharedUserDefault():setIntegerForKey(ACT_MAIN_END_TIME..self.uid, mainEndTime)
	CCUserDefault:sharedUserDefault():setIntegerForKey(ACT_ALL_END_TIME..self.uid, allEndTime)
	self.curNum = 0
	self.lotteryNum = 0
	self.limitNum = curLimitNum
	self:addCollectionNum(curTotalNum)

	-- self:updateEffectFlowerNodeShow()
end

-- function CountdownPartyManager:updateEffectFlowerNodeShow()
-- 	local userTopLevel = UserManager:getInstance().user.topLevelId
-- 	local worldScene = HomeScene:sharedInstance().worldScene
-- 	if worldScene and worldScene.levelToNode then 
-- 		local effLv = CountdownPartyManager.getInstance():getEffectLevelId()
-- 		if effLv then 
-- 			local userTopNode = worldScene.levelToNode[effLv]
-- 			if userTopNode then
-- 				userTopNode:updateActCollectionShow()
-- 			end
-- 		end
-- 	end
-- end

function CountdownPartyManager:getActivityIcon()
	for k,v in pairs(HomeScene:sharedInstance().activityIconButtons or {}) do
		if v.source == ACT_SOURCE then
			return v
		end
	end
end

function CountdownPartyManager:updateActIconRewardFlag()
	local ret = table.find(ActivityUtil:getActivitys() or {},function(v)
		return v.source == ACT_SOURCE
	end)
	if ret then 
		ActivityUtil:setRewardMark(ACT_SOURCE, true)
	end
end

function CountdownPartyManager:handleStarIncrease(levelId, starIncreaseNum, startPos)
	local iconRewardFlag = false 
	local lotteryNum = self.lotteryNum
	self:addCollectionNum(starIncreaseNum * 60)
	if lotteryNum == 0 and self.lotteryNum > 0 then 
		iconRewardFlag = true
	end

	local endPos
	local icon = self:getActivityIcon()
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
		if iconRewardFlag then 
			self:updateActIconRewardFlag()
		end
		flyContainer:removeFromParentAndCleanup(true)
	end))
	flyContainer:runAction(CCSequence:create(arr))
end

function CountdownPartyManager:loadSkeletonAssert()
	FrameLoader:loadArmature('tempFunctionRes/CountdownParty/skeleton/countdown_party', 'countdown_party', 'countdown_party')
end

function CountdownPartyManager:unloadSkeletonAssert()
    ArmatureFactory:remove('countdown_party', 'countdown_party')
end

function CountdownPartyManager:addCollectionNum(num)
	local function add(_num)
		if _num >= self.limitNum then 
			local leftNum = _num - self.limitNum
			self.lotteryNum = self.lotteryNum + 1
			if leftNum > 0 then 
				add(leftNum)
			end
		else
			local tempNum = self.curNum + _num
			if tempNum < self.limitNum then 
				self.curNum = tempNum
			else
				self.curNum = tempNum - self.limitNum
				self.lotteryNum = self.lotteryNum + 1
			end
		end
	end
	add(num)

	self:writeToLocal()
end

function CountdownPartyManager:getProgressShowNum()
	local totalCurNum = self.lotteryNum * self.limitNum + self.curNum
	return totalCurNum, self.limitNum
end

function CountdownPartyManager:getLotteryNum()
	return self.lotteryNum 
end

function CountdownPartyManager:getPasslevelExtraData(levelId, star, actCollectionNum)
	local extraData = {}
	extraData.userState = 0
	local userLevelState = self:getUserState()
	if userLevelState then 
		if userLevelState == CountdownPartyManager.UserState.kNormal then 
			local effLv = self:getEffectLevelId()
			if effLv and levelId == effLv then 
				extraData.userState = CountdownPartyManager.UserState.kNormal
				extraData.collectionNum = actCollectionNum
			end
		elseif userLevelState == CountdownPartyManager.UserState.kTopLevel then 
			if star and star > 0 then 
				local levelScore = UserManager:getInstance():getUserScore(levelId)
				local starIncrease = false 
				if levelScore then
					if levelScore.star > 0 then 
						starIncrease = star - levelScore.star > 0
					elseif JumpLevelManager:getLevelPawnNum(levelId) > 0 or 
							UserManager:getInstance():hasAskForHelpInfo(levelId) then 
						starIncrease = true
					end
					if starIncrease then 
						extraData.userState = CountdownPartyManager.UserState.kTopLevel
					end
				end
			end
		end
	end

	return extraData
end