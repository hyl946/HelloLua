

local function jsmaLog( ... )
	if _G.isLocalDevelopMode  then printx(105 ,...) end
end 

DailyTasksManager = class()

local dailyTasksLeftNum_MAX = 15
local actID = 5004
local instance = nil



local HIDE_LEVEL_ID_START = 10000
local VERSION = "2"	--本地缓存标识 每次换皮应更改 
local ACT_SOURCE = "DailyTasks2019/Config.lua"
local END_TIME = "dailytasks_end_time_"..VERSION
local BEGIN_TIME = "dailytasks_begin_time_"..VERSION
local fullLevelJudge = 1980
local kStorageFileName = "dailytasks_"..VERSION
local kLocalDataExt = ".ds"
local MAX_PROGRESS = 5

local function getDayStartTimeByTS(ts)
	local utc8TimeOffset = 57600 -- (24 - 8) * 3600
	local oneDaySeconds = 86400 -- 24 * 3600
	return ts - ((ts - utc8TimeOffset) % oneDaySeconds)
end

local function time2day(ts)
	ts = ts or Localhost:timeInSec()
	local utc8TimeOffset = 57600 -- (24 - 8) * 3600
	local oneDaySeconds = 86400 -- 24 * 3600
	local dayStart = ts - ((ts - utc8TimeOffset) % oneDaySeconds)
	return (dayStart + 8*3600)/24/3600
end

local function getUid()
	local uid = '12345'
	if UserManager and UserManager:getInstance().user then
		uid = UserManager:getInstance().user.uid or '12345'
	end
	uid = tostring(uid)
	return uid
end

local function levelIsPassed( levelIdNode )
	if levelIdNode==nil or levelIdNode == 0 then
		return false
	end
	local scoreOfLevel = UserManager:getInstance():getUserScore(levelIdNode)

	local scoreOfLevel_star = 0
	if scoreOfLevel then
		scoreOfLevel_star = scoreOfLevel.star
	end

	if scoreOfLevel_star > 0 or 
		JumpLevelManager:getLevelPawnNum(levelIdNode) > 0 or 
		UserManager:getInstance():hasAskForHelpInfo(levelIdNode) then 
		return true
	end

	return false
end

local function getStarWithLevelId( levelIdNode )
	if levelIdNode==nil or levelIdNode == 0 then
		return 0
	end

	local scoreOfLevel = UserManager:getInstance():getUserScore(levelIdNode)

	local scoreOfLevel_star = 0
	if scoreOfLevel then
		scoreOfLevel_star = scoreOfLevel.star
	end

	if scoreOfLevel_star ~= 0 or 
		JumpLevelManager:getLevelPawnNum(levelIdNode) > 0 or 
		UserManager:getInstance():hasAskForHelpInfo(levelIdNode) then 
		if scoreOfLevel_star ==nil then
			return 0
		else
			return scoreOfLevel_star or 0
		end
	end

	return scoreOfLevel_star or 0
end 


function DailyTasksManager.getInstance()
	if not instance then
		instance = DailyTasksManager.new()
		instance:init()
	end
	return instance
end


function DailyTasksManager:init()
	
    self.filePath = HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName .. getUid() .. kLocalDataExt
    self.dailyTasksLeftNum = 0
    self.observers = {}
	self.passCount = 0
	self.starCount = 0
	self.dailyGiftStep = {0,0}
    
    local function onActInfoChange(evt)
		self:onActInfoChange()
	end
	GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kUserDataInit, onActInfoChange)
	Notify:register('ActInfoChange', DailyTasksManager.onActInfoChange, DailyTasksManager)
	self:readFromLocal()
	onActInfoChange()


	self.__passDayListener = function ( ... )
		if _G.isLocalDevelopMode  then jsmaLog( "DailyTasksManager:onPassDay() 0  self.dailyTasksLeftNum = " , self.dailyTasksLeftNum ) end
        self:onPassDay()
    end
     GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kPassDay, self.__passDayListener)


     Notify:register('ActivityPanelIsOpen', self.onActivityPanelIsOpen, self )
end


function DailyTasksManager:onActInfoChange()
	self:readUserData()

	self:updateIcon()
end

function DailyTasksManager:canPopout()
	if not self:isActivitySupport() then
		return false
	end

end
function DailyTasksManager:hasActivitysConfig()
	local ret = table.find(ActivityUtil:getActivitys() or {},function(v)
		return v.source == ACT_SOURCE
	end)
	return ret~=nil
end

function DailyTasksManager:updatehandleNotification()

	local ret = table.find(ActivityUtil:getActivitys() or {},function(v)
		return v.source == ACT_SOURCE
	end)
	if ret then 
		local config = require("activity/DailyTasks2019/Config.lua")
		if config and config.isSupport  and config.handleNotification then
			 config.handleNotification()
		end
	end

end

function DailyTasksManager:isActivityAwardTime()
	local ret = table.find(ActivityUtil:getActivitys() or {},function(v)
		return v.source == ACT_SOURCE
	end)
	if ret then 
		local config = require("activity/DailyTasks2019/Config.lua")
		if config and config.isSupport  and config.isAwardTime then
			return  config.isAwardTime()
		end
	end
	return false
end



function DailyTasksManager:getActivityTime()
	local ret = table.find(ActivityUtil:getActivitys() or {},function(v)
		return v.source == ACT_SOURCE
	end)
	if ret then 
		local config = require("activity/DailyTasks2019/Config.lua")
		if config and config.isSupport  and config.getEndTime then
			return  config.getEndTime()
		end
	end
	return  nil
end

function DailyTasksManager:isActivitySupport()
	local endTime = CCUserDefault:sharedUserDefault():getIntegerForKey(END_TIME..getUid()) or 0
	local beginTime = CCUserDefault:sharedUserDefault():getIntegerForKey(BEGIN_TIME..getUid()) or 0
	-- jsmaLog("beginTime = " , beginTime )
	-- jsmaLog("endTime = " , endTime )
	-- jsmaLog("Localhost:timeInSec() = " , Localhost:timeInSec() )
	if Localhost:timeInSec() > beginTime and Localhost:timeInSec() < endTime then 
		return true
	end 
	return false
end




function DailyTasksManager:getActSource()
	return ACT_SOURCE
end


--登录时 从actinfo中同步次数
function DailyTasksManager:readUserData(  )

	if self.isRead then
		return
	end
	self.isRead = true

	local actInfos = UserManager:getInstance().actInfos
	-- if _G.isLocalDevelopMode  then jsmaLog( " DailyTasksManager readUserData  actInfos =" , table.tostring(actInfos) ) end
	if not actInfos then 
		return 
	end
	local num = nil
	for k,v in pairs(actInfos) do
		if v.actId == actID then
			-- num = v.msgNum
			num = tonumber( v.extra )
		end
	end
	if not num then
		return
	end
	self.dailyTasksLeftNum = num
	self:writeToLocal()
	
end




function DailyTasksManager:getActivityIcon()
	for k,v in pairs(HomeScene:sharedInstance().activityIconButtons or {}) do
		if v.source == ACT_SOURCE then
			return v
		end
	end
end



function DailyTasksManager:log( category,subCategory,t1,t2,t3,t4, t5 )
	local params = {
		game_type = "share",
		game_name = "missions5",
		category = category,
		sub_category = subCategory,
		t1 = t1,
		t2 = t2,
		t3 = t3,
		t4 = t4,
		t5 = t5,
	}
	if _G.isLocalDevelopMode  then printx(105 , "Dc:log params= ",table.tostring(params)) end
	DcUtil:activity(params)
end





-- DailyTasksManager.getInstance():afterStartLevel( levelId )
function DailyTasksManager:canStartLevel( levelId )



end



function DailyTasksManager:readFromLocal()

	if not self:isActivitySupport() then
		return
	end

	self.filePath = HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName .. getUid() .. kLocalDataExt
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
			-- self.dailyTasksLeftNum = tonumber (data.dailyTasksLeftNum or 0 )
			self.passCount = tonumber(data.passCount or 0)
			self.starCount = tonumber(data.starCount or 0)
			self.dailyGiftStep = data.dailyGiftStep or {0,0}
			self.dailyTasksLeftNum = dailyTasksLeftNum_MAX -( self.passCount or 0 ) 
			self.bioscope = data.bioscope or false
		end
	end

end


function DailyTasksManager:writeToLocal()

	self.filePath = HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName .. getUid() .. kLocalDataExt

	local data = {}
	data.dailyTasksLeftNum = self.dailyTasksLeftNum or 0
	data.passCount = self.passCount or 0
	data.starCount = self.starCount or 0
	data.bioscope = self.bioscope or false

	data.dailyGiftStep = self.dailyGiftStep or {0,0}
	local content = amf3.encode(data)

    local file = io.open(self.filePath, "wb")
    if not file then return end
	local success = file:write(content)
    if success then
        file:flush()
        file:close()
    else
        file:close()
    end
    
end


function DailyTasksManager:hasGetRewardWithRewardID( reward )
	local hasIt = table.find( self.dailyGiftStep , function ( value )
		return reward ==value
	end)
	return hasIt~=nil
end

function DailyTasksManager:hasRewards()
	if not self.passCount then
		self.passCount = 0
	end
	local t1 = self.passCount >=2 and not self:hasGetRewardWithRewardID(1)
	local t2 = self.passCount >=dailyTasksLeftNum_MAX and not self:hasGetRewardWithRewardID(2)
	return t1 or t2 
end

--打开活动时 同步活动数据
function DailyTasksManager:setData( data )
--	self.stars = data.stars or 0 
	self.dailyTasksLeftNum = dailyTasksLeftNum_MAX -( data.passCount or 0 ) 
	
	self.passCount = tonumber(data.passCount or 0)
	self.starCount = tonumber(data.starCount or 0)
	self.dailyGiftStep = data.dailyGiftStep or {0,0}
	self.bioscope = data.bioscope or false
    self:writeToLocal()
    
end


function DailyTasksManager:updateIcon( inHomeScene )


	if not self:isActivitySupport() then
		if _G.isLocalDevelopMode  then jsmaLog( " DailyTasksManager updateIcon 111" ) end
		return
	end

	if not self:hasActivitysConfig() then
		if _G.isLocalDevelopMode  then jsmaLog( " DailyTasksManager updateIcon 222" ) end
		return
	end

	
	local hasRewards = self:hasRewards()	
	if ActivityUtil and ActivityUtil.setMsgNum then
		-- ActivityUtil:setMsgNum( ACT_SOURCE , self.dailyTasksLeftNum  )
		ActivityUtil:setMsgNum( ACT_SOURCE , 0  )
	end

	if ActivityUtil and ActivityUtil.setRewardMark and hasRewards then
		ActivityUtil:setRewardMark(ACT_SOURCE, hasRewards)
	end


end


--关卡是否支持活动 
function DailyTasksManager:isActivitySupportWithLevelID( levelID, replayMode )
    if replayMode == nil then replayMode = false end 

    if replayMode then 
        return true 
    end 
    return false

end

--跨天处理
function DailyTasksManager:onPassDay()
		
	--活动是否结束 重置次数为0 或者 15
	if not self:isActivitySupport()	then
		self.dailyTasksLeftNum  = 0
	else
		self.dailyTasksLeftNum = dailyTasksLeftNum_MAX
	end

	--更新本地缓存
	self:writeToLocal()
	--更新相关活动icon
	self:updateIcon()


end

--扣除闯关次数
function DailyTasksManager:deductionNum(  )
	--次数-1
	jsmaLog("DailyTasksManager deductionNum" )

	self.dailyTasksLeftNum = math.max(0 ,self.dailyTasksLeftNum - 1 )
	self.passCount = self.passCount + 1 
	self.passCount = math.min(dailyTasksLeftNum_MAX,self.passCount )
	--更新本地缓存
	jsmaLog("DailyTasksManager deductionNum self.passCount = " ,self.passCount )
	--UserManager中的 actinfos同步修改
	local actInfos = UserManager:getInstance().actInfos
	if actInfos then 
		local num = nil
		for k,v in pairs(actInfos) do
			if v.actId == actID then
				UserManager:getInstance().actInfos[k].extra = tostring( self.dailyTasksLeftNum )
			end
		end 
	end
	
	if self.passCount == 2 then
		jsmaLog("DailyTasksManager deductionNum self.passCount = " ,self.passCount )
		self:log("other","mission_finish",1)
	elseif self.passCount == dailyTasksLeftNum_MAX then
		jsmaLog("DailyTasksManager deductionNum self.passCount = " ,self.passCount )
		self:log("other","mission_finish",2)
	end

	self:log("other","mission_finish_debug",self.passCount ,self.dailyTasksLeftNum ,self.missions5LevelId )
	
	--更新相关活动icon
	self:updateIcon()
	self:writeToLocal()
end


--是否需要带上任务关过关成功消息
function DailyTasksManager:canPassLevel( levelId ,isGiveUp )
	jsmaLog(" DailyTasksManager:canPassLevel = 0 ")
	--判断活动是否激活
	if not self:isActivitySupport() then
		jsmaLog(" DailyTasksManager:canPassLevel = 1 ")
		return false
	end
	--主动放弃的关不算过了任务关
	if not levelId or isGiveUp then
		jsmaLog(" DailyTasksManager:canPassLevel = 2 ")
		return false
	end
	--	打主线关、隐藏关、活动关都算次数
	local levelIdLevelType = LevelType:getLevelTypeByLevelId( levelId )
	if GameLevelType.kMainLevel ~= levelIdLevelType and GameLevelType.kHiddenLevel ~= levelIdLevelType and GameLevelType.kDailyTasks ~= levelIdLevelType and GameLevelType.kSpring2019 ~= levelIdLevelType then
		jsmaLog(" DailyTasksManager:canPassLevel = 3 ")
		return false 
	end

	self.missions5LevelId = levelId
	
	local userTopLevel = UserManager:getInstance().user.topLevelId

	if userTopLevel < 20 then
		return false
	end

    local topPassedLevel = UserManager:getInstance():getTopPassedLevel()
    local canPlayTopLevel = NewAreaOpenMgr.getInstance():getCanPlayTopLevel()
    
    jsmaLog(" DailyTasksManager:canPassLevel userTopLevel =  " , levelIdLevelType )
    jsmaLog(" DailyTasksManager:canPassLevel userTopLevel =  " , userTopLevel )
    jsmaLog(" DailyTasksManager:canPassLevel topPassedLevel =  " , topPassedLevel )
    jsmaLog(" DailyTasksManager:canPassLevel canPlayTopLevel =  " , canPlayTopLevel )
    jsmaLog(" DailyTasksManager:canPassLevel levelId =  " , levelId )
    jsmaLog(" DailyTasksManager:canPassLevel self.dailyTasksLeftNum =  " , self.dailyTasksLeftNum )
    --没有满级
	if canPlayTopLevel > topPassedLevel then
		--最高关 并且 没有卡区域
		if levelId ==userTopLevel and topPassedLevel < userTopLevel then
			jsmaLog(" DailyTasksManager:canPassLevel 111" )
			return self.dailyTasksLeftNum > 0
		else
			jsmaLog(" DailyTasksManager:canPassLevel 222" )
			return false
		end
	end
	
	if canPlayTopLevel == topPassedLevel then
		if GameLevelType.kSpring2019 == levelIdLevelType then
			jsmaLog(" DailyTasksManager:canPassLevel 333..." )
			return self.dailyTasksLeftNum > 0
		end

		if not CollectStarsManager.getInstance():isFinishTarget( levelId ) then
			jsmaLog(" DailyTasksManager:canPassLevel 333" )
			return self.dailyTasksLeftNum > 0
		end
		jsmaLog(" DailyTasksManager:canPassLevel 444" )
		return false
	end
	jsmaLog(" DailyTasksManager:canPassLevel 555" )
	return self.dailyTasksLeftNum > 0
end


function DailyTasksManager:addObserver(ob)

	self.observers[ob] = ob
end



function DailyTasksManager:removeObserver(ob)

	if self.observers[ob] then
		self.observers[ob] = nil
	end
end


function DailyTasksManager:notify(eventName, ...)
	for _, ob in pairs(self.observers) do
		if ob['on' .. eventName] then
			ob['on' .. eventName](ob, ...)
		end
	end
end


function DailyTasksManager:afterStartLevel( levelId )
    local count = self.datas.levelPlayedCount[tostring(levelId)] or 0
	count = count + 1
	self.datas.levelPlayedCount[tostring(levelId)] = count

    self:write()
end


function DailyTasksManager:updateByActivity( beginTime, endTime )

	CCUserDefault:sharedUserDefault():setIntegerForKey(END_TIME..getUid(), endTime)
	CCUserDefault:sharedUserDefault():setIntegerForKey(BEGIN_TIME..getUid(), beginTime)
	CCUserDefault:sharedUserDefault():flush()

end

function DailyTasksManager:doOpenActivity( successCallback )

	if not self:isActivitySupport() then
		return
	end
    local actSource = DailyTasksManager:getInstance():getActSource()
    local source = actSource
    local version = nil
    for k,v in pairs(ActivityUtil:getActivitys() or {}) do
        if v.source == source then
            version = v.version
            break
        end
    end

    -- if _G.isLocalDevelopMode  then jsmaLog( " DailyTasksManager doOpenActivity version =  "  , version) end

    if version then
    	local function _successCallback( ... )
  			jsmaLog(" DailyTasksManager:doOpenActivity _successCallback ")
    		PushActivity:sharedInstance():setActivityPopNumWithActId( actID ,1 )
    		if successCallback then successCallback() end
    	end 

        ActivityData.new({source=source,version=version}):start(false,false,nil,errorCallback,endCallback, needPopCb, DuanMianData, extra , _successCallback)
    end

end

function DailyTasksManager:getWillSetGuideFlag()
	return self.willSetGuideFlag 
end


function DailyTasksManager:onActivityPanelIsOpen( actID_Config )
	jsmaLog(" DailyTasksManager:onActivityPanelIsOpen actID_Config = " , actID_Config )
	if self.wiiSendGuideFlag and actID == actID_Config then
		jsmaLog(" DailyTasksManager:onActivityPanelIsOpen 2" )
		if not UserManager:getInstance():hasGuideFlag(kGuideFlags.DailyTasks2019DoPopout) then
			UserLocalLogic:setGuideFlag( kGuideFlags.DailyTasks2019DoPopout )
			jsmaLog(" DailyTasksManager:onActivityPanelIsOpen 3" )
		end
	end
end

function DailyTasksManager:backToHomeScene( isInitedHomeScene , nextCallBack )
	self:readUserData()

	self.wiiSendGuideFlag = false

	if not isInitedHomeScene then
		if nextCallBack then nextCallBack() end
		jsmaLog(" DailyTasksManager:backToHomeScene false 1" )
		return
	end


	if not self:isActivitySupport() then
		if nextCallBack then nextCallBack() end
		jsmaLog(" DailyTasksManager:backToHomeScene false 1.5" )
		return
	end

	if UserManager:getInstance():hasGuideFlag(kGuideFlags.DailyTasks2019DoPopout) then
		if nextCallBack then nextCallBack() end
		jsmaLog(" DailyTasksManager:backToHomeScene false 2" )
		return
	end

	if self.bioscope == false then
		if nextCallBack then nextCallBack() end
		jsmaLog(" DailyTasksManager:backToHomeScene false 3" )
		return
	end
	if self.starCount > 0 then
		if nextCallBack then nextCallBack() end
		jsmaLog(" DailyTasksManager:backToHomeScene false 4" )
		return
	end

	if self.dailyTasksLeftNum > 13 then
		if nextCallBack then nextCallBack() end
		jsmaLog(" DailyTasksManager:backToHomeScene false 5" )
		return 
	end

	self.wiiSendGuideFlag = true
	-- jsmaLog(" DailyTasksManager:backToHomeScene doOpenActivity" )
	self:doOpenActivity(  )
	
end