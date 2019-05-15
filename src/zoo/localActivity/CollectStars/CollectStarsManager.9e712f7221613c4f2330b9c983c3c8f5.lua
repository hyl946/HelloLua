

local function jsmaLog( ... )
	if _G.isLocalDevelopMode  then printx(105 ,...) end
end 



local collectStarsActid = 5006

CollectStarsManager = class()
local function defineHttp( name )
	local http = class(HttpBase)
	function http:load( params )
		if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
		local context = self
		local loadCallback = function(endpoint, data, err)
			if err then
				he_log_info(name .. " error: " .. err)
				context:onLoadingError(err)
			else
				he_log_info(name .. " success !")
				
				context:onLoadingComplete(data)
			end
		end

		self.transponder:call(name, params or {}, loadCallback, rpc.SendingPriority.kHigh, false)
	end
	return http
end


local GetInfoHttp = defineHttp("getActivityInfo")

local instance = nil
CollectStarsManager.UserState = {
	kNone = 0,
	kNormal = 202, 			--没满级满星
	kTopLevel = 203,		--满级没满星
	kTopStar = 204,       	--满级满星
}
local HIDE_LEVEL_ID_START = 10000
local VERSION = "3"	--本地缓存标识 每次换皮应更改 
local ACT_SOURCE = "CollectStars2019V3/Config.lua"
local BEGIN_TIME = "collectstars_begin_time_"..VERSION
local END_TIME = "collectstars_end_time_"..VERSION

-- local fullLevelJudge = 1980

local kStorageFileName = "collectstars_"..VERSION
local kLocalDataExt = ".ds"

local MAX_PROGRESS = 5
local function getDayStartTimeByTS(ts)
	local utc8TimeOffset = 57600 -- (24 - 8) * 3600
	local oneDaySeconds = 86400 -- 24 * 3600
	return ts - ((ts - utc8TimeOffset) % oneDaySeconds)
end
-- 原A1组 组别id1 （难度≤5 并且关卡难度/三星率”数值<10）
-- 原A2组 组别id2 （难度≤5 并且关卡难度/三星率”数值>=10）
-- 原B组 组别id3 （难度 5到10）
-- 原C组 组别id4 （难度大于10）
-- 原隐藏关组 组别id5 
-- 原四星关组 组别id6 ( 关卡难度/四星率 )
local function table_Insert( tableNode , dataNode )
	if not table then
		return
	end
	if not dataNode then
		return
	end
	local hasIt = table.find( tableNode ,function ( levelIdNode )
		return levelIdNode.id == dataNode.id
	end)
	if not hasIt then
		table.insert( tableNode , dataNode )
	end
end 
local function time2day(ts)
	ts = ts or Localhost:timeInSec()
	local utc8TimeOffset = 57600 -- (24 - 8) * 3600
	local oneDaySeconds = 86400 -- 24 * 3600
	local dayStart = ts - ((ts - utc8TimeOffset) % oneDaySeconds)
	return (dayStart + 8*3600)/24/3600
end


function CollectStarsManager.getInstance()
	if not instance then
		instance = CollectStarsManager.new()
		instance:init()
	end
	return instance
end


function CollectStarsManager:getCollectStarsActid()
	return tostring( collectStarsActid )
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


local function getFilePath(  )
	return HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName .. getUid() .. kLocalDataExt
end 

function CollectStarsManager:init()
	self.data = {}
	self.data_3 = {}
	self.oldStarForStageEnd = 0 
	self.stars = 0
	self.uid = getUid()
	self.notFinishTable = {}
	-- self.hasBuff = false
	self.filePath2 = HeResPathUtils:getUserDataPath() .. "/level_difficulty_v2.ds"

	self.userStartTime = 0
	self.userEndTime = 0
	self.fullStarId = 0
	self.willShowTitle = false
	self.fullLevelJudge = 0
	self:readFromLocal()

	self:readFromStorage()

	self:startPassDayCountDown()
	self.buffLeftNum = 0 
	self.needUpdateAllLevel = true
	self.__passDayListener = function ( ... )
        self:onPassDay()
    end

    self.observers = {}
    self.failNumTable = 0
    self.popToday = false
    self.popToday1 = false
    self.fullSpecialShow_Full = false
    self.fullSpecialShow = false
    
    --开始面板激活buff
    self.isActivationBuff = true
    self.autoAddBuff = false
    self.rewardConfig = {}
    self.autoAddBuffNum = 0
    self.sendStageStartLevelId = 0
    if self.conditionsTable ==nil then
    	self.conditionsTable = {}
    end
    local conditions = self.conditionsTable[ 4 ] or 0
	if self.stars >= conditions and self.stars > 0 and conditions> 0  then
		self.canShowTitleStar = false
	else
		self.canShowTitleStar = true
	end
    GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kPassDay, self.__passDayListener)
    self.topPassLevelOldId = UserManager:getInstance():getTopPassedMainLevelId()


    local function onActInfoChange(evt)
		self:onActInfoChange()
	end
	self:onActInfoChange()
	GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kUserDataInit, onActInfoChange)
	Notify:register('ActInfoChange', CollectStarsManager.onActInfoChange, CollectStarsManager:getInstance() )
	
    self:setTimer()

end

function CollectStarsManager:clearTimer()
	if self.updateSchedId then 
        Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateSchedId)
        self.updateSchedId = nil
	end
end

function CollectStarsManager:setTimer()
	if not self:isActivitySupport() then
		return
	end

	local function __update()
        self:checkActivityEnd()
    end
    if not self.updateSchedId then
        self.updateSchedId = Director:sharedDirector():getScheduler():scheduleScriptFunc(__update, 1.0, false)
    end

end

function CollectStarsManager:getRewardIndexWithBoxIndex( boxIndexTable )
	local rewardIds = {}
	for i=1,#boxIndexTable do
		local boxIndex = boxIndexTable[i]
		table.insert( rewardIds , self:getRewardConfigWithIndex( boxIndex ) )
	end
	return rewardIds
end




function CollectStarsManager:doActivityIsEnd( endCallback )

	-- local function onGetRequestNumSuccess(evt)
	-- 	if not evt then
	-- 		return
	-- 	end
	-- 	if not evt.data then
	-- 		return
	-- 	end
	-- 	if not evt.data.actInfos then
	-- 		return
	-- 	end 

	-- 	local actInfos = evt.data.actInfos
	-- 	local extraJson = {}
	-- 	local collectStarCctInfos = nil

	-- 	for k,v in pairs(actInfos) do
	-- 		if v.actId == collectStarsActid  then
	-- 			collectStarCctInfos = table.clone(v)
	-- 		end
	-- 	end
	-- 	if not collectStarCctInfos then
	-- 		return
	-- 	end

	-- 	for k,v in pairs( UserManager:getInstance().actInfos or {} ) do
	-- 		if v.actId == collectStarsActid  then
	-- 			local collectStarCctInfos_extra = table.deserialize( collectStarCctInfos.extra or {} ) or {}
	-- 			local data = table.deserialize( UserManager:getInstance().actInfos[k].extra ) or {}
	-- 			data.lastReward = table.clone( collectStarCctInfos_extra.lastReward or {} )
	-- 			UserManager:getInstance().actInfos[k].extra =table.serialize( data )
	-- 		end
	-- 	end
	-- 	config.readUserData()

	-- 	if endCallback ~= nil then endCallback() end

	-- end



 --    local http = GetRequestNumHttp.new(false)
 --    http:ad(Events.kComplete, onGetRequestNumSuccess)
 --    local function onFail(evt)
 --    	if endCallback ~= nil then endCallback() end
	-- end

	-- local function onCancel( ... )
	-- 	if endCallback ~= nil then endCallback() end
	-- end


	-- http:ad(Events.kError, onFail)
	-- http:ad(Events.kCancel, onCancel)
 --    http:load()

	
	self:checkLocalData()

end





function CollectStarsManager:checkActivityEnd()

	-- local endTime = self:getUserEndTime()
	-- local secondLeft =  endTime - Localhost:timeInSec() 

	-- if secondLeft > 0 then
	-- 	return
	-- end
	-- if self.updateSchedId then 
 --        Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateSchedId)
 --        self.updateSchedId = nil
	-- end

end





function CollectStarsManager:getFullLevelJudge()
	local actInfos = UserManager:getInstance().actInfos
	if actInfos then 
		local num = nil
		local extraJson = {}
		for k,v in pairs(actInfos) do
			if v.actId == collectStarsActid then
				num = tonumber(v.msgNum )
				extraJson = v.extra
			end
		end
		local data = table.deserialize( extraJson ) or {}
		if data.fullLevelId  then
			self.fullLevelJudge = data.fullLevelId 
		end
	end
	return self.fullLevelJudge
end

function CollectStarsManager:onPassDay()

	
	if self.day == time2day() then
		return
	end
	self.day = time2day()
	self.buffLeftNum = 0
	if not self:isActivitySupport() then
		self:doActivityIsEnd()
		return false
	end
	local topPassedLevelId = UserManager:getInstance():getTopPassedLevel()
	if topPassedLevelId >= self:getFullLevelJudge() then
		self.buffLeftNum = 6
	else
		self.buffLeftNum = 3
	end
	self:setLeftBuffNum( self.buffLeftNum  )

	self:updatehandleNotification()
	self:updateIcon()



end


function CollectStarsManager:canPopout()
	if not self:isActivitySupport() then
		return false
	end

end

function CollectStarsManager:getStarWithLevelId(levelId)
	if levelId ==nil or levelId <= 0 then
		return false
	end
	return getStarWithLevelId( levelId )
end

function CollectStarsManager:getLevelConfigData(levelId, ...)
	assert(levelId)
	assert(type(levelId) == "number")
	assert(#{...} == 0)

	local levelMeta = LevelMapManager.getInstance():getMeta(levelId)
	if levelMeta then return levelMeta end
	return nil
end
function CollectStarsManager:getLevelTargetScores(levelId, ...)
	assert(levelId)
	assert(type(levelId) == "number")
	assert(#{...} == 0)

	local levelConfigData = self:getLevelConfigData(levelId)
	assert(levelConfigData)
	if levelConfigData ==nil then
		
		return nil
	end
	local targetScores = levelConfigData:getScoreTargets()
	assert(targetScores)

	return targetScores
end

function CollectStarsManager:shouldShouStar4(levelId)
	if levelId ==nil or levelId <= 0 then
		return false
	end

	-- if _G.isLocalDevelopMode  then printx(1 , "changeLevelWithLevelId shouldShouStar4 levelId " , levelId ) end

	local star = getStarWithLevelId( levelId )
	local isStar4Level = false
	local targetScores =  self:getLevelTargetScores( levelId )
	if targetScores and #targetScores > 3 and targetScores[4] > 0 then
		isStar4Level = true
	end
	if isStar4Level and star == 3 then
		return true
	end
	return false
end
function CollectStarsManager:shouldShowStar4(levelId)
	return self:shouldShouStar4(levelId)
end

function CollectStarsManager:_updateByActivity( beginTime, endTime )
	CCUserDefault:sharedUserDefault():setIntegerForKey(BEGIN_TIME..getUid(), beginTime)
	CCUserDefault:sharedUserDefault():setIntegerForKey(END_TIME..getUid(), endTime)
	CCUserDefault:sharedUserDefault():flush()
end



function CollectStarsManager:updateByActivity()
	
	local actInfos = UserManager:getInstance().actInfos
	if not actInfos then 
		return 
	end
	local num = nil
	local extraJson = {}
	for k,v in pairs(actInfos) do
		if v.actId == collectStarsActid then
			num = tonumber(v.msgNum )
			extraJson = v.extra
		end
	end

	local data = table.deserialize( extraJson ) or {}
	local userEndTime = data.endTime or 0
	local userStartTime = data.startTime  or 0
	self:_updateByActivity( userStartTime /1000 , userEndTime /1000)

end


function CollectStarsManager:isInMyArea( branchIdNode )
	-- if not self:isActivitySupportForIsMyArea() then
	-- 	return false
	-- end
	-- if _G.isLocalDevelopMode  then printx(100 , "CollectStarsManager isInMyArea " ,branchIdNode   ) end
	

	-- local currentLevel = self:getFirstLevelWhenClickIcon()
	-- local kMaxLevelsNode = NewAreaOpenMgr.getInstance():getCanPlayTopLevel()
 --    for k = 1 , kMaxLevelsNode/15  do 
 --        local endLevelId = k * 15
 --        local branchId = MetaModel:sharedInstance():getHiddenBranchIdByNormalLevelId(endLevelId)
 --        if branchId and not MetaModel:sharedInstance():isHiddenBranchDesign(branchId) then --已上线隐藏关
 --        	if branchId == branchIdNode then
 --        		local branchData = MetaModel:sharedInstance():getHiddenBranchDataByBranchId(branchId)
 --        		if currentLevel >= branchData.startNormalLevel and currentLevel<=branchData.endNormalLevel then
 --        			return true
 --        		end
 --        	end
 --        end
 --    end
 --    if _G.isLocalDevelopMode  then printx(100 , "CollectStarsManager isInMyArea return false"    ) end
    return false
end

function CollectStarsManager:updatehandleNotification()

	local ret = table.find(ActivityUtil:getActivitys() or {},function(v)
		return v.source == ACT_SOURCE
	end)
	if ret then 
		local config = require("activity/CollectStars2019V3/Config.lua")
		if config and config.isSupport  and config.handleNotification and config.isSupport() then
			 config.handleNotification( self:getFullLevelJudge() )
		end
	end

end

function CollectStarsManager:isActivityAwardTime()
	local ret = table.find(ActivityUtil:getActivitys() or {},function(v)
		return v.source == ACT_SOURCE
	end)
	if ret then 
		local config = require("activity/CollectStars2019V3/Config.lua")
		if config and config.isSupport  and config.isAwardTime then
			return  config.isAwardTime()
		end
	end
	return false
end

function CollectStarsManager:getActivityTime()
	local ret = table.find(ActivityUtil:getActivitys() or {},function(v)
		return v.source == ACT_SOURCE
	end)
	if ret then 
		local config = require("activity/CollectStars2019V3/Config.lua")
		if config and config.isSupport  and config.getEndTime then
			return  config.getEndTime()
		end
	end
	return  nil
end


function CollectStarsManager:isActivitySupportForIsMyArea()

	-- local endTime = self:getActivityTime()

	-- if _G.isLocalDevelopMode  then printx(100 , "CollectStarsManager:isActivitySupport() endTime = " , endTime ) end

	-- if not endTime then
	-- 	endTime = CCUserDefault:sharedUserDefault():getIntegerForKey(END_TIME..getUid()) or 0
	-- end
	-- if not endTime then
	-- 	return false
	-- end
	-- if Localhost:timeInSec() > endTime then 
	-- 	return false
	-- end
	return false

end




function CollectStarsManager:isActivitySupport()

	local endTime = CCUserDefault:sharedUserDefault():getIntegerForKey(END_TIME..getUid()) or 0
	local beginTime = CCUserDefault:sharedUserDefault():getIntegerForKey(BEGIN_TIME..getUid()) or 0
	if beginTime == 0 and endTime ==0 then
		return false
	end
	local now = Localhost:timeInSec() 
	if now > beginTime and now < endTime then 
		return true
	end 
	return false

end




function CollectStarsManager:getActSource()
	return ACT_SOURCE
end

function CollectStarsManager:loadProp10113()
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile('tempFunctionRes/CollectStars/yellowEnergy/yellowEnergy.plist')
end

function CollectStarsManager:unloadProp10113()
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile('tempFunctionRes/CollectStars/yellowEnergy/yellowEnergy.plist')
end


function CollectStarsManager:loadSkeletonAssert()
	FrameLoader:loadArmature('tempFunctionRes/CountdownParty/skeleton/countdown_party', 'countdown_party', 'countdown_party')
	FrameLoader:loadArmature('tempFunctionRes/CollectStars2018/startPanelNPC', 'levelInfoNPCAnimation', 'levelInfoNPCAnimation')
end

function CollectStarsManager:unloadSkeletonAssert()
    ArmatureFactory:remove('countdown_party', 'countdown_party')
    ArmatureFactory:remove('levelInfoNPCAnimation', 'levelInfoNPCAnimation')
    self.oldLevel = nil 
end

function CollectStarsManager:loadLevelInfoSkeletonAssert()
	-- if _G.isLocalDevelopMode  then printx(1 , "CollectStarsManager:loadLevelInfoSkeletonAssert()") end
	FrameLoader:loadArmature('tempFunctionRes/CollectStars2018/startPanelNPC', 'levelInfoNPCAnimation', 'levelInfoNPCAnimation')
end
function CollectStarsManager:unloadLevelInfoSkeletonAssert()
	-- if _G.isLocalDevelopMode  then printx(1 , "CollectStarsManager:unloadLevelInfoSkeletonAssert()") end
    ArmatureFactory:remove('levelInfoNPCAnimation', 'levelInfoNPCAnimation')
    self.oldLevel = nil 
end

function CollectStarsManager:loadLevelSuccessSkeletonAssert()

	-- printx(11, "loadLevelSuccessSkeletonAssert + + + + + + + + + + + + +")
	FrameLoader:loadArmature('tempFunctionRes/CollectStars2018/levelSuccessAnim', 'ScoreBuffBottleLevelSuccess', 'ScoreBuffBottleLevelSuccess')
	FrameLoader:loadArmature('tempFunctionRes/CollectStars2018/skeleton/bottle5', 'bottle5', 'bottle5')
end
function CollectStarsManager:unloadLevelSuccessSkeletonAssert()
	-- printx(11, "- - - - - - - - - - - -  loadLevelSuccessSkeletonAssert")
    ArmatureFactory:remove('ScoreBuffBottleLevelSuccess', 'ScoreBuffBottleLevelSuccess')
    ArmatureFactory:remove('bottle5', 'bottle5')
    self.oldLevel = nil 
end

function CollectStarsManager:loadLevelSuccessFullSkeletonAssert()
	FrameLoader:loadArmature('tempFunctionRes/CollectStars2018/levelSuccessFullAnim', 'ScoreBuffBottleLevelSuccessFull', 'ScoreBuffBottleLevelSuccessFull')
end
function CollectStarsManager:unloadLevelSuccessFullSkeletonAssert()
    ArmatureFactory:remove('ScoreBuffBottleLevelSuccessFull', 'ScoreBuffBottleLevelSuccessFull')
    self.oldLevel = nil 
end

-- 从配置中获取每个瓶子的分数加成比例，小数形式
function CollectStarsManager:getScoreBuffBottleEffectPercent()
	local effectPercent = MetaManager.getInstance():getScoreBuffBottleEffectPercent()
	if not effectPercent then effectPercent = 0 end
	effectPercent = math.max(effectPercent, 0)
	effectPercent = math.min(effectPercent, 1)

	return effectPercent
end

function CollectStarsManager:isActivitySupportAll()
	return self:isActivitySupport()
end

--根据这个关的levelid 得到 点亮的星星数
function CollectStarsManager:getProgressNun( levelId )
	if 1 then
		return 0
	end
end



function CollectStarsManager:getLevelWithIndex( index , levelInit , changeLevel )

	--马俊松添加
	self:getAllLevelsData()
	return {id = self.currentLevel }

end


function CollectStarsManager:getUserStartTime()

	local endTime = CCUserDefault:sharedUserDefault():getIntegerForKey(END_TIME..getUid()) or 0
	local beginTime = CCUserDefault:sharedUserDefault():getIntegerForKey(BEGIN_TIME..getUid()) or 0

	self.userStartTime  = beginTime

	local actInfos = UserManager:getInstance().actInfos
	if not actInfos then 
		return self.userStartTime
	end
	local extraJson = nil
	for k,v in pairs(actInfos) do
		if v.actId == collectStarsActid then
			extraJson = v.extra
		end
	end

	if not extraJson then
		return self.userStartTime
	end
	local data = table.deserialize( extraJson ) or {}
	local userEndTime = data.endTime or 0
	local userStartTime = data.startTime  or 0
	self.userStartTime  = userStartTime / 1000
	

    if _G.isLocalDevelopMode  then 

	end
	return self.userStartTime 
end
function CollectStarsManager:getUserEndTime()

	local endTime = CCUserDefault:sharedUserDefault():getIntegerForKey(END_TIME..getUid()) or 0
	local beginTime = CCUserDefault:sharedUserDefault():getIntegerForKey(BEGIN_TIME..getUid()) or 0

	self.userEndTime = endTime

	local actInfos = UserManager:getInstance().actInfos
	if not actInfos then 
		return self.userEndTime
	end
	local extraJson = nil
	for k,v in pairs(actInfos) do
		if v.actId == collectStarsActid then
			extraJson = v.extra
		end
	end

	if not extraJson then
		return self.userEndTime
	end
	local data = table.deserialize( extraJson ) or {}
	local userEndTime = data.endTime or 0
	local userStartTime = data.startTime  or 0
	self.userEndTime  = userEndTime / 1000
	

    if _G.isLocalDevelopMode  then 
        -- local t = os.date("*t", tonumber(self.userEndTime ))
        -- if t then
        --     printx(104 , "userEndTime = " , string.format("%d年%d月%d日%d时",t.year,t.month,t.day,t.hour))
        -- end
    end

	return self.userEndTime 
end


function CollectStarsManager:checkLocalData()

	local function clearData( ... )
		local data = {}
		local content = amf3.encode(data)
		local file = io.open( getFilePath() , "wb")
	    if not file then return end
		local success = file:write(content)
	    if success then
	        file:flush()
	        file:close()
	    else
	        file:close()
	    end
	    self:_updateByActivity( 0, 0 )
	    self:readFromLocal()
	    jsmaLog("CollectStarsManager:checkLocalData() clearData")
	end 
	local endTime = CCUserDefault:sharedUserDefault():getIntegerForKey(END_TIME..getUid()) or 0

	local actInfos = UserManager:getInstance().actInfos
	if not actInfos then 
		return 
	end

	local extraJson = nil
	local num = nil
	for k,v in pairs(actInfos) do
		if v.actId == collectStarsActid then
			num = tonumber(v.msgNum )
			extraJson = v.extra
		end
	end
	if not num then
		return
	end
	if not extraJson then
		return
	end
	local data = table.deserialize( extraJson ) or {}

	local userEndTime = data.endTime or 0
	local userStartTime = data.startTime  or 0
	userEndTime = userEndTime / 1000
	userStartTime = userStartTime / 1000

	if endTime >0 and userEndTime > 0 and userEndTime ~= endTime then
		clearData()
	end
	if Localhost:timeInSec() > endTime and endTime >0 then 
		--活动结束了 
		clearData()
	end
	local data = table.deserialize( extraJson ) or {}
	local now = Localhost:timeInSec() 
	self.userStartTime = userStartTime
	self.userEndTime = userEndTime
	self:setLeftBuffNum( num )
end


function CollectStarsManager:getRewardConfigWithIndex( index )

	if self.rewardConfig ==nil then
		self.rewardConfig = {}
	end
	if #self.rewardConfig ~=4 then
		self.rewardConfig = {1,2,3,4}
	end

	local rewardId = self.rewardConfig[index] or 0
	return rewardId
end


function CollectStarsManager:onActInfoChange()
	self:readUserData()

end


function CollectStarsManager:readUserData(  )
	
	local actInfos = UserManager:getInstance().actInfos
	if not actInfos then 
		return 
	end
	local num = nil
	local extraJson = {}
	for k,v in pairs(actInfos) do
		if v.actId == collectStarsActid then
			num = tonumber(v.msgNum )
			extraJson = v.extra
		end
	end
	if not num then
		return
	end
	self.buffLeftNum = num
	local data = table.deserialize( extraJson ) or {}
	-- startTime number	当期活动开始的时间戳，活动关闭时为0
	-- endTime number	当期活动结束的时间戳，活动关闭时为0
	-- lastReward List<number>	待发的奖励，活动开启时为上一期奖励 ，活动关闭期间为已关闭的当期奖励，列表内为rewardId
	-- fullLevelId number	改期活动的满级关卡ID，活动未开启或者缺少配置时为99999
	-- fullStarId number	改期活动的满星关卡ID，活动未开启或者缺少配置时为99999
	-- rewardConfig List<number>	当期活动的奖励id，活动未开启时为空
	-- if _G.isLocalDevelopMode  then printx(104 , " data = " , table.tostring(data) ) end
	local userEndTime = data.endTime or 0
	local userStartTime = data.startTime  or 0
	-- if _G.isLocalDevelopMode  then printx(104 , " userEndTime = " , userEndTime ) end
	local lastReward = data.lastReward  or {}
	local fullLevelId = data.fullLevelId  or 0
	local fullStarId = data.fullStarId  or 0
	self.fullStarId = fullStarId or 0
	self.rewardConfig = data.rewardConfig or {1,2,3,4}
	self.fullLevelJudge = fullLevelId
	fullLevelJudge = fullLevelId
	-- {"startTime":1553079600000,"endTime":1553511600000,"fullLevelId":2010,"fullStarId":2025,"rewardConfig":[1,2,3,4],"autoAddBuff":true}
	self.autoAddBuff = data.autoAddBuff or false
	-- self:_updateByActivity( userStartTime /1000 , userEndTime /1000)
	self:writeToLocal()
end

function CollectStarsManager:getNextLevelWhenPassLevel( notAdd )

	self.nextLevelIndex = self.nextLevelIndex or 1
	local levelData = self:getLevelWithIndex( self.nextLevelIndex ,nil , true)
	local newLevelId = 0
	if levelData ~= nil and levelData.id ~=nil then
		newLevelId = levelData.id
	end
	self.currentLevel = newLevelId
	self:writeToLocal()
	self:updateActIconNum()
	return newLevelId
end

function CollectStarsManager:setCurrentLevel2( currentLevel )
	self.currentLevel = currentLevel

	-- if _G.isLocalDevelopMode  then jsmaLog( "CollectStarsManager setCurrentLevel2 self.currentLevel  " , self.currentLevel  ) end
	-- self.oldLevel = nil 
	self:writeToLocal()
end

function CollectStarsManager:setCurrentLevel( currentLevel )
	-- self.currentLevel = currentLevel
	-- -- self.oldLevel = nil 
	-- self:writeToLocal()
end

function CollectStarsManager:getCurrentLevel(  )

	-- if _G.isLocalDevelopMode  then jsmaLog( "CollectStarsManager getCurrentLevel self.currentLevel  " , self.currentLevel  ) end
	return self.currentLevel or 0
end


function CollectStarsManager:passDayInit()
	-- if _G.isLocalDevelopMode  then printx(1 , " CollectStarsManager passDayInit  " ) end
	if not self:isActivitySupport() then
		return 
	end
	-- self.leftTimes = 5
	-- self.nextLevelIndex = 1		--下一关索引重置为1
	-- self.changed = false --今天没有换过关
	-- self:writeToLocal()


end




function CollectStarsManager:passDayCheck()

	if not self:isActivitySupport() then
		return false
	end

	return false
end




function CollectStarsManager:clearSuccessWhenFinish(  )
	self.willClearSuccessNum = true

end

function CollectStarsManager:setFailReason( failReason ,levelId )

	-- if not CollectStarsManager.getInstance():shouldShowActCollection(levelId , true) then
	-- 	self.willClearSuccessNum = false
	-- 	return 
	-- end
	-- if not self.willSendStageEnd then
	-- 	return
	-- end

	-- self.failReason = failReason
	-- local t1Node = self.oldProgress or 1
	-- if t1Node <= 0 then
	-- 	t1Node = 0
	-- end
	-- if t1Node >= 5 then
	-- 	t1Node = 5
	-- end
	-- local playId = GamePlayContext:getInstance():getIdStr() 

	-- if self.t4_newStar ==0 then
	-- 	--失败了传老星星数
	-- 	self.t4_newStar = self.t3_oldStar
	-- end
	-- self:log("star_stage_end", t1Node , playId , self.t3_oldStar , self.t4_newStar , self.failReason , self.successNum ,levelId)
	-- self.willSendStageEnd = false

	-- if self.willClearSuccessNum then
	-- 	self.successNum = 0 
	-- 	self.willClearSuccessNum = false
	-- end
	-- self:writeToLocal()
	-- if _G.isLocalDevelopMode  then printx(100 , "CollectStarsManager setFailReason self.successNum = " ,self.successNum ) end

end

function CollectStarsManager:passLevel( levelId  ,newStar  )

	-- if _G.isLocalDevelopMode  then jsmaLog( " CollectStarsManager passLevel 11111111111111 levelId = newStar = " , levelId ,newStar) end

	self.finishTarget3 = false
	self.finishTarget4 = false
	self.oldProgress = self.progress
	
	self.oldProgressForLevelSuccess = -1

	local finishTarget = false

	local oldStar = 0
	local score = UserManager.getInstance():getUserScore( levelId )
	if score and score.star  then
		oldStar = score.star
	end

	-- if self.willSendStageEnd then
	-- 	self.successNum = self.successNum + 1
	-- end

	self:starStageEnd( oldStar , newStar )
	if not self:isActivitySupport() then
		-- if _G.isLocalDevelopMode  then printx(1 , " CollectStarsManager passLevel isActivitySupport false ") end
		return finishTarget
	end
	if self.currentLevel ~= levelId then
		-- if _G.isLocalDevelopMode  then printx(1 , " CollectStarsManager passLevel notThisLevelId false ") end
		return finishTarget
	end



	--闯关失败 那么 分数障碍清零 
	if newStar == 0 then
		self.progress = 1 
		self.progress_See = 0
		-- if _G.isLocalDevelopMode  then printx(1 , " CollectStarsManager passLevel fail false ") end
		return finishTarget
	end

	--判断是否完成了目标
	local isStar4Level = false
	local targetScores =  self:getLevelTargetScores( levelId )
	if targetScores and #targetScores > 3 and targetScores[4] > 0 then
		isStar4Level = true
	end

	if isStar4Level then

		if newStar>=4 and oldStar< 3 then
			finishTarget = true
			self.finishTarget3 = true
			self.finishTarget4 = true
			self.autoChangeLevel = true
			self.oldProgressForLevelSuccess = 101	--满4星
			return finishTarget
		end

		if oldStar == 3 and newStar == 4 then
			finishTarget = true
			self.finishTarget4 = true
			self.autoChangeLevel = true
			self.oldProgressForLevelSuccess = 101	--满4星

			return finishTarget
		end

		if newStar == 3 and oldStar < 3 then
			finishTarget = true
			self.finishTarget3 = true
			self.autoChangeLevel = true
			self.oldProgressForLevelSuccess = 100	--满3星

			return finishTarget
		end

	else
		if newStar >= 3 then
			finishTarget = true
			self.finishTarget3 = true
			self.autoChangeLevel = true
			self.oldProgressForLevelSuccess = 100	--满3星

			return finishTarget
		end
	end

	self.oldProgressForLevelSuccess = self.progress 

	-- if _G.isLocalDevelopMode  then printx(100 , " self.oldProgressForLevelSuccess =  " , self.oldProgressForLevelSuccess ) end


	
	-- self.progress = self.progress + 1 
	-- self.progress = self.progress > MAX_PROGRESS and MAX_PROGRESS or self.progress
	-- self.oldProgress = self.progress
	-- if _G.isLocalDevelopMode  then printx(1 , "CollectStarsManager shouldShowActCollection progress =" ,self.progress  ) end
		
	self:writeToLocal()

	-- if finishTarget then	-- 这个分支走不进来了吧，finishTarget = true的话前面都return了
	-- 	self.autoChangeLevel = true
	-- 	self.oldProgressForLevelSuccess = -1
	-- 	if self.finishTarget4 then
	-- 		self.oldProgressForLevelSuccess = 101
	-- 	elseif self.finishTarget3 then
	-- 		self.oldProgressForLevelSuccess = 100
	-- 	end
	-- end

	return finishTarget

end


function CollectStarsManager:geBuytLeftTimes()
--	504 - 508
	local leftTimes = 5
	for i=504,508 do
		local bought = UserManager:getInstance():getDailyBoughtGoodsNumById( i )
		leftTimes = leftTimes - bought
		-- if _G.isLocalDevelopMode  then printx(1 , "CollectStarsManager geBuytLeftTimes bought =" , bought  ) end
	end

--	local goods1 =  MetaManager:getInstance():getGoodMeta(goodsId1)

	return leftTimes
end


function CollectStarsManager:getGoodsID()
--	504 - 508
	local leftTimes = self:geBuytLeftTimes()
	if leftTimes > 0 then
		return 508 - leftTimes + 1
	end
	return nil
end


function CollectStarsManager:getCash()
	local goodsID = self:getGoodsID()
	if goodsID == nil then
		return 0
	end
	local goodsItem =  MetaManager:getInstance():getGoodMeta( goodsID )
	return goodsItem.qCash
end



function CollectStarsManager:empty(  )
	-- self.currentLevel = 0
	-- self.leftTimes = 10
	-- self.progress = 1
	-- self.progress_See = 0 --上次打开活动面板时 显示的进度
	-- -- self.changedLevels = {}
	-- -- self.nextLevelIndex = 0
	-- self:writeToLocal()

end



function CollectStarsManager:readFromLocal()

	if not self:isActivitySupport() then
		return
	end

	local file, err = io.open(getFilePath(), "rb")

	if file and not err then
		local content = file:read("*a")
		io.close(file)
        local data = nil
        local function decodeContent()
            data = amf3.decode(content)
        end
        pcall(decodeContent)
		if data and type(data) == "table" then
			
			-- self.changed = data.changed or false
			self.currentLevel = data.currentLevel or 0
			self.buffLeftNum = data.buffLeftNum or 0
			self.infinitelevelId = data.infinitelevelId or 0
			self.willShowTitle = data.willShowTitle or false
			self.stars = data.stars or 0		
			self.lastLevel = data.lastLevel or 0
			self.rewards = data.rewards or {}
			self.usableProp = data.usableProp or 0
			self.conditionsTable = data.conditionsTable or {}
			self.beginStar = data.beginStar or 0
			self.failNumTable = data.failNumTable or 0
			self.popToday = data.popToday or false
			self.popToday1 = data.popToday1 or false
			self.dayIndex = data.dayIndex or 0
			self.oldStarForStageEnd = data.oldStarForStageEnd or 0	
			self.starStageStartT1 = data.starStageStartT1 or 0	
			self.notFinishTable = data.notFinishTable or {}
			self.fullLevelJudge = data.fullLevelJudge or 0	
			self.fullStarId = data.fullStarId or 0	
			self.sendStageStartLevelId = data.sendStageStartLevelId or 0
			self.isActivationBuff = data.isActivationBuff 	
			self.rewardConfig = data.rewardConfig or {1,2,3,4}
			self.autoAddBuff = data.autoAddBuff or false		
			if #self.rewardConfig ~=4 then
				self.rewardConfig  = {1,2,3,4}
			end
			if self.dayIndex ~= time2day() then
				self.dayIndex = time2day() 
				self.failNumTable = 0
				self.popToday = false
				self.popToday1 = false
			end
			
		end
	end
	self:getFullLevelJudge()

end

function CollectStarsManager:setIsActivationBuff( isActivationBuff )
	self.isActivationBuff = isActivationBuff
	self:writeToLocal()
end

function CollectStarsManager:getIsActivationBuff()
	return self.isActivationBuff
end
	
function CollectStarsManager:writeToLocal()

	local data = {}
	-- data.changed = self.changed or false
	data.currentLevel = self.currentLevel or 0
	data.buffLeftNum = self.buffLeftNum or 0
	data.infinitelevelId = self.infinitelevelId or 0

	data.stars = self.stars or 0
	data.lastLevel = self.lastLevel or 0
	data.rewards = self.rewards or {}
	data.usableProp = self.usableProp or 0
	data.conditionsTable = self.conditionsTable or {}
	data.beginStar = self.beginStar or 0
	data.failNumTable = self.failNumTable or 0
	data.popToday = self.popToday or false
	data.popToday1 = self.popToday1 or false
	data.oldStarForStageEnd = self.oldStarForStageEnd or 0
	data.starStageStartT1 = self.starStageStartT1 or 0
	data.willShowTitle = self.willShowTitle or false
	data.notFinishTable = self.notFinishTable or {}
	data.fullLevelJudge = self.fullLevelJudge or 0
	data.fullStarId = self.fullStarId or 0

	data.isActivationBuff = self.isActivationBuff 
	data.autoAddBuff = self.autoAddBuff or false
	data.sendStageStartLevelId = self.sendStageStartLevelId or 0

	if #self.rewardConfig == 4 then
		data.rewardConfig = self.rewardConfig or {1,2,3,4}
	end
	

	-- jsmaLog( "writeToLocal notFinishTable= " , table.tostring(self.notFinishTable) )
	data.dayIndex = time2day() 

	local content = amf3.encode(data)

    local file = io.open(getFilePath(), "wb")
    -- assert(file, "CollectStarsManager persistent file failure " .. kStorageFileName)
    if not file then return end
	local success = file:write(content)
   
    if success then
        file:flush()
        file:close()
    else
        file:close()
    end

end


function CollectStarsManager:getActivityIcon()
	for k,v in pairs(HomeScene:sharedInstance().activityIconButtons or {}) do
		if v.source == ACT_SOURCE then
			return v
		end
	end
	return nil
end

function CollectStarsManager:updateActIconNum()
	-- self:updateIcon()
end

function CollectStarsManager:updateActIconRewardFlag()
	local ret = table.find(ActivityUtil:getActivitys() or {},function(v)
		return v.source == ACT_SOURCE
	end)
	if ret then 
		-- ActivityUtil:setRewardMark(ACT_SOURCE, true)
	end
	
end

function CollectStarsManager:isReplayModel(  )
	return self.isReplayModel or false
end

function CollectStarsManager:closeReplayModel()
	self.isReplayModel = nil
end

function CollectStarsManager:tryOpenReplayModel( levelId )

	if not self:isActivitySupport() then
		-- if _G.isLocalDevelopMode  then printx(1 , " CollectStarsManager tryOpenReplayModel isActivitySupport false ") end
		return 
	end

	if self.currentLevel ~= levelId then
		-- if _G.isLocalDevelopMode  then printx(1 , " CollectStarsManager tryOpenReplayModel notThisLevelId false ") end
		return 
	end
	self.isReplayModel = true

end



function CollectStarsManager:passLevelFail( levelId )

	-- if _G.isLocalDevelopMode  then printx(1 , " CollectStarsManager passLevelFail self.currentLevel =" , self.currentLevel ) end
	if not self:isActivitySupport() then
		-- if _G.isLocalDevelopMode  then printx(1 , " CollectStarsManager passLevel isActivitySupport false ") end
		return 
	end

	if self.currentLevel ~= levelId then
		-- if _G.isLocalDevelopMode  then printx(1 , " CollectStarsManager passLevel notThisLevelId false ") end
		return 
	end


	-- self.successNum = self.successNum + 1
	-- self.oldProgressForLevelSuccess = -1

	local oldStar = 0
	local score = UserManager.getInstance():getUserScore( levelId )
	if score and score.star  then
		oldStar = score.star
	end
	self:starStageEnd( oldStar , 0 )
	
	-- self.progress_See = 0
	-- self.oldProgress = self.progress 
	-- self.progress = 1 
	if self:passDayCheck() then
		self:passDayInit()
	else
		self:writeToLocal()
	end

	

end

function CollectStarsManager:startPassDayCountDown()
	GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kPassDay, function (evt) 
			-- if _G.isLocalDevelopMode  then printx(1 , "CollectStarsManager startPassDayCountDown " ) end
			-- local scene = Director:sharedDirector():getRunningSceneLua()
			-- if not self:isActivitySupport() then
			-- 	return 
			-- end
			-- self.timeLeft = 5
			-- self:writeToLocal()
			-- self:updateActIconNum()
	end)
end



function CollectStarsManager:setPopoutActionCloseCallBack( popoutActionCloseCallBack )
	self.popoutActionCloseCallBack = popoutActionCloseCallBack
end

function CollectStarsManager:doPopoutActionCloseCallBack(  )
	if self.popoutActionCloseCallBack then
		self.popoutActionCloseCallBack()
		self.popoutActionCloseCallBack = nil
	end
end



--用了一个buff 
function CollectStarsManager:useBuff(  )

	self.buffLeftNum = self.buffLeftNum -1 
	if self.buffLeftNum <0 then
		self.buffLeftNum = 0
	end
	self:setLeftBuffNum( self.buffLeftNum )
	self:updatehandleNotification()
	self:updateIcon()

end

function CollectStarsManager:setLeftBuffNum( leftNum )
	self.buffLeftNum = leftNum
	for k,v in pairs( UserManager:getInstance().actInfos or {} ) do
		if v.actId == collectStarsActid then
			UserManager:getInstance().actInfos[k].msgNum = tonumber(self.buffLeftNum)
		end
	end
	self:writeToLocal()
end

function CollectStarsManager:willShowAddStep( levelId )
	local isBuffEffective = self:_isBuffEffective(levelId)
	local mainLogic = GameBoardLogic:getCurrentLogic()
	local nowstar = 0 
	if mainLogic then
		nowstar = mainLogic.gameMode:getScoreStarLevel()
	end
	if isBuffEffective and nowstar > self.oldStarForStageEnd then
		return true
	end
	return false
end

function CollectStarsManager:getOldStarForStageEnd(  )
	return self.oldStarForStageEnd or 0
end
function CollectStarsManager:clearStarStageStart(  )
	self.starStageStartT1 = 0
	self.sendStageStartLevelId = 0
	self:writeToLocal()
end

--开始关卡前打点（仅当前任务关打）
function CollectStarsManager:starStageStart( levelId )
	-- self:useBuff()

	self.buffLeftNum = self.buffLeftNum or 0 
	self.autoAddBuffNum = 0
	--有buff 并且 选择带着buff进去
	local t1 = self.buffLeftNum > 0 and self.isActivationBuff == true
	if t1 then
		t1 = 1
	else
		t1 = 0
	end
	self.starStageStartT1 = t1
	
	setTimeOut(function ( ... )
		local playId = GamePlayContext:getInstance():getIdStr() 
		self:log("star_stage_start",t1,playId ,levelId , self.buffLeftNum )
    end, 1)

	self.oldStarForStageEnd = self:getStarWithLevelId( levelId )
	-- if _G.isLocalDevelopMode  then jsmaLog( "CollectStarsManager starStageStart levelId  = " , levelId  ) end
	-- if _G.isLocalDevelopMode  then jsmaLog( "CollectStarsManager starStageStart levelId  = " , levelId  ) end
	self.infinitelevelId = levelId
	self.willSendStageEnd = true

	self.sendStageStartLevelId = levelId
	self:isFullStar()
	self:writeToLocal()
end


-- 结束关卡时打点（仅当前任务关打）
function CollectStarsManager:starStageEnd( t3_oldStar ,t4_newStar   )

	self.t3_oldStar = t3_oldStar
	self.t4_newStar = t4_newStar
	-- self:log("star_stage_end", t1Node , playId , self.t3_oldStar , self.t4_newStar , t5_fail_reason , self.successNum )
end


function CollectStarsManager:isBuffEffectiveForLevelSuccessTopLevel( levelId  )
	local isBuffEffective , buffLeftNum = self:isBuffEffectiveForPassLevel( levelId , nil , nil )
	if self.canShowTitleStar == false then
		return false
	end

	self.infinitelevelId  = 0 
	return isBuffEffective
end


function CollectStarsManager:getTodayFailNum()
	self:readFromLocal()
	return self.failNumTable or 0
end



function CollectStarsManager:isFinishTargetWithLevelIDAndNewStar( levelId ,starNumNew)
	local targetIsFour = self:shouldShouStar4( levelId )
	if not starNumNew then
		starNumNew = 0
	end
	starNumNew = tonumber(starNumNew)
	if targetIsFour then
    	-- if _G.isLocalDevelopMode  then jsmaLog( "isFinishTargetWithLevelIDAndNewStar 1 levelId = starNum = " , levelId ,starNum ) end
    	return starNumNew >= 4
    else
    	-- if _G.isLocalDevelopMode  then jsmaLog( "isFinishTargetWithLevelIDAndNewStar 2 levelId = starNumNew =" , levelId ,starNumNew ) end
    	return starNumNew >= 3
    end
end

--判断是否满星了
function CollectStarsManager:isFinishTarget( levelId )

	local starNum = self:getStarWithLevelId( levelId )
    local targetIsFour = self:shouldShouStar4( levelId )
    -- local finish = false

    if targetIsFour then
    	-- if _G.isLocalDevelopMode  then jsmaLog( "isFinishTarget 1 levelId = starNum = " , levelId ,starNum ) end
    	return starNum >= 4
    else
    	-- if _G.isLocalDevelopMode  then jsmaLog( "isFinishTarget 2 levelId = starNum =" , levelId ,starNum ) end
    	return starNum >= 3
    end
end

function CollectStarsManager:canShowTitle( levelId ,levelType , isStartlevel)

	-- if _G.isLocalDevelopMode  then jsmaLog( "canShowTitle self.willShowTitle =  " , self.willShowTitle ) end

	local isBuffEffective = self:_isBuffEffective(levelId , levelType)
	if  isStartlevel then
		isBuffEffective = self:_isBuffEffective(levelId , levelType)
	else
		isBuffEffective = self:isBuffEffectiveForPassLevel(levelId )
	end
	if isStartlevel == true  then
		self.canShowTitleStar = false
	end
	
	if not isBuffEffective then
		-- if _G.isLocalDevelopMode  then jsmaLog( "canShowTitle 1 " ) end
		return false
	end
	if self.willShowTitle == true and not isStartlevel then
		self.willShowTitle = false
		-- if _G.isLocalDevelopMode  then jsmaLog( "canShowTitle 2 " ) end
		self:writeToLocal()
		return true
	end
	local conditions = self.conditionsTable[ 4 ] or 0
	if self.stars >= conditions and isStartlevel == true then
		-- if _G.isLocalDevelopMode  then jsmaLog( "canShowTitle 4 " ) end
		return false
	end

	if isStartlevel == true then
		self.willShowTitle = true
		self:writeToLocal()
	end
	if isStartlevel == true  then
		self.canShowTitleStar = true
	end
	-- if _G.isLocalDevelopMode  then jsmaLog( "canShowTitle 5 " ) end

	return true
end


--结算界面 瓶子的缩放
function CollectStarsManager:getLadyBugScaleInSuccessTopPanel()
	return 1.15
end



function CollectStarsManager:isBuffEffective( levelId ,levelType  )
	-- if self.isActivationBuff== false then
	-- 	return false
	-- end
	return self:_isBuffEffective( levelId ,levelType)
end

--buff是否生效 还剩几个buff 志坚:  这个里面不要做耗时的处理哈~我几个地方都在用~
function CollectStarsManager:_isBuffEffective( levelId ,levelType  )
	self:readFromLocal()

	if  levelType == StartLevelType.kAskForHelp then
		-- if _G.isLocalDevelopMode  then jsmaLog( "isBuffEffective false  000 = "  ) end
		return false , 0 
	end

	local isActivitySupport = self:isActivitySupport()
	if not isActivitySupport then
		-- if _G.isLocalDevelopMode  then jsmaLog( "isBuffEffective false  111"  ) end
		return false , 0
	end
	if AskForHelpManager:getInstance():isInMode() then
		-- if _G.isLocalDevelopMode  then jsmaLog( "isBuffEffective false  222"  ) end
		return false , 0
	end
	if not levelId then 
		-- if _G.isLocalDevelopMode  then jsmaLog( "isBuffEffective false  333"  ) end
		return false , 0
	end 

	local levelIdLevelType = LevelType:getLevelTypeByLevelId( levelId )
	if GameLevelType.kMainLevel ~= levelIdLevelType and GameLevelType.kHiddenLevel ~= levelIdLevelType then
		-- if _G.isLocalDevelopMode  then jsmaLog( "isBuffEffective false  888"  ) end
		return false , 0
	end

	if self:isFullStar(false , true) then
		-- if _G.isLocalDevelopMode  then jsmaLog( "isBuffEffective false  444"  ) end
		return true , self.buffLeftNum or 0
	end

	if levelIsPassed( levelId )   then
		-- if _G.isLocalDevelopMode  then jsmaLog( "isBuffEffective false  555 self.buffLeftNum = " , self.buffLeftNum  ) end
		if not self:isFinishTarget(levelId) then
			-- if _G.isLocalDevelopMode  then jsmaLog( "isBuffEffective true  666 self.buffLeftNum = " ,self.buffLeftNum ) end
			return true , self.buffLeftNum or 0
		end
	end



	-- if _G.isLocalDevelopMode  then jsmaLog( "isBuffEffective false  777"  ) end
	return false , 0
end

--志坚你先用着
function CollectStarsManager:getLeftBuffNum(  )

	return self.buffLeftNum or 0
end



-- 1=star_buff 是否带分数buff闯关（0=不带，-1=带1级，2=带2级，3=带3级，4=带4级，5=带5级）  
-- t2=playId 全局唯一标识点  
-- t3=old_star 当前关卡开始前星星数
-- t4=new_star 当前关卡结束星星数 
-- t5=fail_reason：  
--      0（成功过关）  
--      6（步数不够）  
--     14（时间不够）  
--     19 （分数不够）  
--     99(荷塘关失败了） 
-- t6=满星前闯关累积次数（没满星时每次闯关结束都会累积打点）

function CollectStarsManager:log( subCategory,t1,t2,t3,t4 , t5 ,t6 , t7  )
	local params = {
		game_type = "stage",
		game_name = "farmstar_new_v3",
		category = "canyu",
		sub_category = subCategory,
		t1 = t1,
		t2 = t2,
		t3 = t3,
		t4 = t4,
		t5 = t5,
		t6 = t6,
		t7 = t7,
	}

	if _G.isLocalDevelopMode  then printx(105 , "CollectStarsManager:log = \n " , table.tostring(params) ) end
	DcUtil:activity(params)
end


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


local CollectStarFeature = class()

MaintenanceModeType = {
	kDefault = "default",
	kGroup = "group",
	kOrthogonalGroup = "orthogonal_group"
}

MaintenanceFilterListType = {
	
	kWhite = "white",
	kBlack = "black",
}

function CollectStarFeature:ctor()
	-- self.id = false
end
function CollectStarFeature:fromXML( src )
	self:fromLua(src)
end

function CollectStarFeature:encode()
	local ret = {}
	ret.id = self.id
	ret.d = self.d
	ret.d3 = self.d3
	ret.d4 = self.d4
	return ret
end

function CollectStarFeature:isInWhitelist()
	return false
end

function CollectStarFeature:isInFilterlist()
	return false
end

function CollectStarFeature:fromLua(src)
	if not src then return end

	self.id = tonumber(src.id)
	self.d = tonumber(src.d)

	self.d3 = tonumber(src.d3)
	self.d4 = tonumber(src.d4)

end

function CollectStarsManager:fromLua(src)

	if not src then return end
	self.data = {}
	for k,config in pairs(src) do
		if type(config) == "table" then
			local feature = CollectStarFeature.new()
			feature:fromLua(config)
			if feature ~= nil and feature.id ~= nil then
				self.data[feature.id] = feature
			end
		end		
	end

	self.getCanPlayTopLevel = NewAreaOpenMgr.getInstance():getCanPlayTopLevel()
	for levelId=1,self.getCanPlayTopLevel do
		local feature = self.data[ levelId ]
		if feature == nil then
			local feature = CollectStarFeature.new()
			local random = math.random(0, 1)
			random = 0
			feature.id = levelId
			feature.d = random
			feature.d3 = random
			feature.d4 = random
			self.data[feature.id] = feature
		end
	end
	self.data_3 = {}
	for k,config in pairs( self.data ) do
		self.data_3 [k] = config
	end
	table.sort( self.data_3 , function ( a , b )
		if a.d3 + a.d4 == b.d3 + b.d4  then
			return a.id < b.id
		end
		return a.d3 + a.d4 > b.d3 + b.d4
	end)

	-- table.sort( self.data_3 , function ( a , b )
	-- 	if a.d  == b.d   then
	-- 		return a.id < b.id
	-- 	end
	-- 	return a.d < b.d 
	-- end)

end

function CollectStarsManager:saveVersion()
	CCUserDefault:sharedUserDefault():setIntegerForKey("level_difficulty_v2"..getUid() ,  self.version )
	CCUserDefault:sharedUserDefault():flush()
end

function CollectStarsManager:getVersion()
	local version = CCUserDefault:sharedUserDefault():getIntegerForKey("level_difficulty_v2"..getUid()) or 0
	return version
end

function CollectStarsManager:hasDSFile()
	local file, err = io.open(self.filePath2, "rb")
	if file and not err then
		io.close(file)
		return true
	end
	return false
end





function CollectStarsManager:readFromStorage()
	-- local data = Localhost:readFromStorage("level_difficulty_v2.ds")
	-- self:fromLua(data)
	
	if self.readOnlyOnce then
		return
	end
	self.readOnlyOnce = true
	local data = MetaManager.getInstance():getLevelDifficultyAll()
	self:fromLua(data)

end

function CollectStarsManager:writeToStorage()
	local data = {}
	for k,v in pairs(self.data) do
		table.insert(data, v:encode())
	end
	Localhost:writeToStorage(data, "level_difficulty_v2.ds")
	self:saveVersion()
end

function CollectStarsManager:getLevelDifficultyV2Data(key)
	return self.data and self.data[key] or nil
end

function CollectStarsManager:fromXML( src )
	
	if src then self.version = src.version end
	-- if _G.isLocalDevelopMode then jsmaLog( "CollectStarsManager:fromXML self.version = " , self.version ) end
	self:fromLua(src)

end


function CollectStarsManager:needLoadXMLFile( version_S )
	--马俊松修改 v2表修改为 v1表了 所以直接给成功
	if true then
		return false
	end

	-- if _G.isLocalDevelopMode then jsmaLog( "CollectStarsManager:needLoadXMLFile version_Mine = version_S = " ,version_Mine, version_S) end
	if not self:hasDSFile() then
		return true
	end
	local version_Mine = self:getVersion()
	if version_Mine and version_S and tonumber( version_Mine ) == tonumber( version_S ) then
		return false
	end
	return true
end


function CollectStarsManager:onlineLoad( onFinish )
	--马俊松修改 v2表修改为 v1表了 所以直接给成功 
	if onFinish then onFinish() return end

	local url = NetworkConfig.maintenanceURL
	local uid = UserManager.getInstance().uid or "12345"
	local params = string.format("?name=level_difficulty_v2&uid=%s&_v=%s", uid, majorBundleVersion)
	if __IOS_FB then
  		params = string.format("?name=level_difficulty_v2_mobile&uid=%s&_v=%s", uid, majorBundleVersion)
  	end
	url = url .. params

	local request = HttpRequest:createGet(url)

  	local connection_timeout = 2
	if __WP8 then 
	   	connection_timeout = 5
	end
    request:setConnectionTimeoutMs(connection_timeout * 1000)
    request:setTimeoutMs(30 * 1000)
   
    local function onRegisterFinished( response )
    	if response.httpCode ~= 200 then 
    	else
    		local message = response.body
    		local metaXML = xml.eval(message)
    		local confList = xml.find(metaXML, "level_difficulty_v2")
    		if confList then
	    		self.data = {}
	    		self:fromXML(confList)
	    		self:writeToStorage()
	    	end
    	end
    	if onFinish then onFinish() end
    end
    self.needUpdateAllLevel = true
    HttpClient:getInstance():sendRequest(onRegisterFinished, request)
end
function CollectStarsManager:getAutoAddBuff(  )
	return self.autoAddBuff or false
end
function CollectStarsManager:getAutoAddBuffNum()
	if self.autoAddBuff == false then
		self.autoAddBuffNum  = 0
		return 0 
	end
	return tonumber( self.autoAddBuffNum )

end


function CollectStarsManager:doClearAutoAddBuff(  )
	self.autoAddBuffNum = 0
end
function CollectStarsManager:doAutoAddBuff(  oldStar , newStar )
	if self.autoAddBuff == false then
		return
	end
	if newStar <= oldStar then
		return 
	end
	self.autoAddBuffNum = newStar - oldStar
	self.buffLeftNum = self.buffLeftNum + newStar - oldStar
	self:setLeftBuffNum( self.buffLeftNum  )
	self:updateIcon()


end

function CollectStarsManager:isBuffEffectiveForPassLevel( levelId , oldStar , star )
	self:readFromLocal()
	local isActivitySupport = self:isActivitySupport()
	if not isActivitySupport then
		return false , 0
	end
	if AskForHelpManager:getInstance():isInMode() then

		return false , 0
	end
	if not levelId then 

		return false , 0
	end 
	local levelIdLevelType = LevelType:getLevelTypeByLevelId( levelId )
	if GameLevelType.kMainLevel ~= levelIdLevelType and GameLevelType.kHiddenLevel ~= levelIdLevelType then

		return false , 0
	end

	local isFinishTarget = self:isFinishTargetWithLevelIDAndNewStar( levelId ,star )
	levelId = tostring(levelId)
	if not isFinishTarget then
		if self.notFinishTable[ levelId ] == nil then
			self.notFinishTable[ levelId ] = 0
		else
			self.notFinishTable[ levelId ]  = tonumber(self.notFinishTable[ levelId ] ) 

		end
		self.notFinishTable[ levelId ] = self.notFinishTable[ levelId ] + 1
	end
	local t6 = self.notFinishTable[ levelId ] 
	levelId = tonumber(levelId)
	local isSendStageEnd = self.sendStageStartLevelId == levelId 
	self.sendStageStartLevelId  = 0
	if oldStar and star then
		self.openNewBox = false
		local playId = GamePlayContext:getInstance():getIdStr() 
		if isSendStageEnd then
			if isFinishTarget then
				self:log("star_stage_end", self.starStageStartT1 , playId , self.oldStarForStageEnd, star , levelId  )
			else
				self:log("star_stage_end", self.starStageStartT1 , playId , self.oldStarForStageEnd, star , levelId , t6 or 0 )
			end
		end
	end

	local isBuffEffective = self.infinitelevelId == levelId 
	if star then
		if isBuffEffective and star > oldStar then

			local stars1 , conditions1 =self:getWinNumString( self.stars )
			self.stars = tonumber(self.stars or 0 )+ tonumber(star) - tonumber(oldStar)  
			local stars2 , conditions2 =self:getWinNumString( self.stars )
			conditions2 = conditions2 or 0 
			conditions1 = conditions1 or 0
			if conditions2 > conditions1 then
				self.openNewBox = true
			end
		end
	end 

	if star == 0 then
		self.infinitelevelId  = 0 
	end

	local userTopLevel = UserManager:getInstance().user.topLevelId
	local topPassLevelOldId = UserManager:getInstance():getTopPassedMainLevelId()

	if star == 0 and userTopLevel == levelId and topPassLevelOldId < userTopLevel then
		if self.userTopLevelPlay ~= levelId then
			self.userTopLevelPlay = levelId
			self.failNumTable = 0
		end
		self.failNumTable = self.failNumTable + 1 

	end
	local todayIndex =  tonumber( time2day() )	


	if self.isfullStar == false and self:isFullStar(false , true) then
		self.fullSpecialShow_Full = true
	end


    self:notify("UpdateStarNum")
	self:writeToLocal()

	return isBuffEffective , self.buffLeftNum or 0

end


function CollectStarsManager:isFullStarWithLevelID( levelId_Full )

	for levelId=1,levelId_Full do
		if not self:isFinishTarget(levelId) then
			jsmaLog( "isFullStarWithLevelID levelId = " , levelId )
			return false
		end
	end

	for k = 1 , levelId_Full/15  do 
        local endLevelId = k * 15
        local branchId = MetaModel:sharedInstance():getHiddenBranchIdByNormalLevelId(endLevelId)
        if branchId and not MetaModel:sharedInstance():isHiddenBranchDesign(branchId) then --已上线隐藏关
            local branchData = MetaModel:sharedInstance():getHiddenBranchDataByBranchId(branchId)
            if branchData and branchData.endNormalLevel == endLevelId then
                for levelId=branchData.startHiddenLevel,branchData.endHiddenLevel do
                	local scoreOfLevel = UserManager:getInstance():getUserScore(levelId)
                	if scoreOfLevel then
                		if scoreOfLevel.star > 0 and scoreOfLevel.star <3 then
                			if not self:isFinishTarget(levelId) then
                				jsmaLog( "isFullStarWithLevelID levelId = " , levelId )
								return false
							end
                		end
                	end
                end
            end
        end
    end
	-- local fullStar1 = LevelMapManager.getInstance():getTotalStar( self.getCanPlayTopLevel )
	jsmaLog( "isFullStarWithLevelID return true  "  )
	return true
end

--满星的判定  forceUpdate 强制更新  isFarmStar 是否是刷分模式的满星判定
function CollectStarsManager:isFullStar( forceUpdate ,isFarmStar)
	--满星的判定
	if not isFarmStar then
		--刷星模式的满星判定 不看 self.fullStarId
		isFarmStar = false
	end
	if not forceUpdate then
		forceUpdate = false
	end
    if  self.getCanPlayTopLevel ==nil then
        self.getCanPlayTopLevel = NewAreaOpenMgr.getInstance():getCanPlayTopLevel()
    end

    if self.getCanPlayTopLevel < NewAreaOpenMgr.getInstance():getCanPlayTopLevel() then
        self.getCanPlayTopLevel = NewAreaOpenMgr.getInstance():getCanPlayTopLevel()
        self.myStarNum  = nil
    end

    if self.getCanPlayTopLevel < self.fullStarId and isFarmStar == false then

    	-- jsmaLog( "11 isFullStarWithLevelID self.getCanPlayTopLevel = " , self.getCanPlayTopLevel )
    	-- jsmaLog( "11 isFullStarWithLevelID self.fullStarId = " , self.fullStarId )
    	return false
    end
    local userRef    = UserManager.getInstance().user
    local userStar = userRef:getStar()
    local userStar_Hide = userRef:getHideStar()

    if self.myStarNum == ( userStar + userStar_Hide) then
        if not self.isfullStar then
            self.isfullStar = false
        end
        if not forceUpdate then
        	-- jsmaLog( "22 isFullStarWithLevelID isfullStar 0 = " , self.isfullStar )
        	return self.isfullStar
        end
    else
        self.myStarNum = userStar + userStar_Hide
    end
    -- jsmaLog("33 self.getCanPlayTopLevel = " , self.getCanPlayTopLevel)
    -- jsmaLog("33 self.fullStarId = " , self.fullStarId)

    if self.getCanPlayTopLevel > self.fullStarId then
    	self.isfullStar =self:isFullStarWithLevelID( self.fullStarId  )
    	self.needUpdateAllLevel = true

    	-- jsmaLog( "44 isFullStarWithLevelID  111 self.isfullStar = " , self.isfullStar )

    	return self.isfullStar  
    end
    local fullStar1 = LevelMapManager.getInstance():getTotalStar( self.getCanPlayTopLevel )
    -- local fullStar2 = MetaModel.sharedInstance():getFullStarInHiddenRegion( true )
    local fullStar2 = MetaModel.sharedInstance():getFullStarInOpenedHiddenRegion()
    local fullStar =  fullStar1 + fullStar2
    local isfullStar = fullStar <= (userStar + userStar_Hide )
    self.isfullStar = isfullStar
    self.needUpdateAllLevel = true

    -- jsmaLog( "55 isFullStarWithLevelID self.getCanPlayTopLevel  = " , self.getCanPlayTopLevel  )
    -- jsmaLog( "55 isFullStarWithLevelID fullStar1 + fullStar2 = " , fullStar1 + fullStar2  )
    -- jsmaLog( "55 isFullStarWithLevelID userStar + userStar_Hide = " , userStar + userStar_Hide )
    -- jsmaLog( "55 isFullStarWithLevelID isfullStar = " , isfullStar )
    return isfullStar
  
end

-- function CollectStarsManager:starIsNotEnough(levelId)

-- 	local maxStar = 3
-- 	local targetScores =  self:getLevelTargetScores( levelId )
-- 	if targetScores and #targetScores > 3 and targetScores[4] > 0 then
-- 		maxStar = 4
-- 	end
-- 	local star = self:getStarWithLevelId( levelId )
-- 	return maxStar > star

-- end

function CollectStarsManager:isActEnabled( ... )
	local config
    for _,v in pairs(ActivityUtil:getActivitys()) do
        if v.source == ACT_SOURCE then
        	pcall(function ( ... )
	            config = require ('activity/'..v.source)
        	end)
            break
        end
    end
    local actEnabled = config and config.isSupport()
    return actEnabled
end

function CollectStarsManager:getNextLevelInFullStarModel( lastLevel )

	if _G.isLocalDevelopMode  then jsmaLog( "CollectStarsManager getNextLevelInFullStarModel  lastLevel " , lastLevel ) end

	local allLevelsDataNum = #self.data
	local index = 1
	for i=1,allLevelsDataNum do
		local dataNode = self.data_3[ i ]
		index = i 
		if dataNode.id == lastLevel then
			break
		end
	end

	-- if index == allLevelsDataNum then
	-- 	index = 1
	-- else
	-- 	index = index + 1
	-- end
	if self.data_3[ index + 1 ] == nil then
		index =1
	else
		index = index + 1
	end 

	if self.data_3[ index ] and self.data_3[ index ].id then
		return self.data_3[ index ].id
	end
	return 1
end



function CollectStarsManager:getAllLevelsData( forceUpdate )
	if not forceUpdate then
		forceUpdate = false
	end
	if not self.needUpdateAllLevel and not forceUpdate then
		-- if _G.isLocalDevelopMode  then jsmaLog( "CollectStarsManager getAllLevelsData  needUpdateAllLevel " , self.needUpdateAllLevel ) end
		-- if _G.isLocalDevelopMode  then jsmaLog( "CollectStarsManager getAllLevelsData 1  " , table.tostring( self.level_3 ) ) end
		return self.level_3 , self.level_4 , self.level_Hide , self.jumpLevels , self.askForHelpLevels 
	end

	if  self.getCanPlayTopLevel ==nil then
        self.getCanPlayTopLevel = NewAreaOpenMgr.getInstance():getCanPlayTopLevel()
    end

	local level_3 = {}
	local level_4 = {}
	local level_Hide = {}
	local jumpLevels = {}
	local askForHelpLevels = {}
	

	for k,config in pairs( self.data_3 ) do
		local levelId = config.id
		-- if HIDE_LEVEL_ID_START > levelId then
			local isHideLevel = levelId>HIDE_LEVEL_ID_START

			local scoreOfLevel = UserManager:getInstance():getUserScore(levelId)
			local isStar4Level = false
			local targetScores =  self:getLevelTargetScores( levelId )
			if targetScores and #targetScores > 3 and targetScores[4] > 0 then
				isStar4Level = true
			end
			-- local levelIsPassed = levelIsPassed( levelId )
			local shouldShowStar4 = 1

			local scoreOfLevel_star = 0
			if scoreOfLevel then
				scoreOfLevel_star = scoreOfLevel.star
			end
			if JumpLevelManager:getLevelPawnNum( levelId ) > 0 then
				if scoreOfLevel_star == 0 then
					table.insert( jumpLevels , levelId )
				end
			elseif UserManager:getInstance():hasAskForHelpInfo( levelId ) then 
				if scoreOfLevel_star == 0 then
					table.insert( askForHelpLevels , levelId )
				end
			elseif isStar4Level and scoreOfLevel_star == 3 and not isHideLevel then
				table.insert( level_4 , levelId )
			elseif scoreOfLevel_star > 0 and scoreOfLevel_star <3 and not isHideLevel then
				table.insert( level_3 , levelId )
			end
	end

	table.sort( level_4 , function ( levelId_1, levelId_2 )
		local config_1 = self:getLevelDifficultyV2Data(levelId_1)
		local config_2 = self:getLevelDifficultyV2Data(levelId_2)
		if config_1 and config_2 then
			if config_1.d4 ~= config_2.d4 then
				return config_1.d4 > config_2.d4
			end
		end
		return levelId_1 < levelId_2
	end )
	-- table.sort( level_4 , function ( levelId_1, levelId_2 )
	-- 	local config_1 = self:getLevelDifficultyV2Data(levelId_1)
	-- 	local config_2 = self:getLevelDifficultyV2Data(levelId_2)
	-- 	if config_1 and config_2 then
	-- 		if config_1.d ~= config_2.d then
	-- 			return config_1.d < config_2.d
	-- 		end
	-- 	end
	-- 	return levelId_1 < levelId_2
	-- end )

	for k = 1 , self.getCanPlayTopLevel/15  do 
        local endLevelId = k * 15
        local branchId = MetaModel:sharedInstance():getHiddenBranchIdByNormalLevelId(endLevelId)
        if branchId and not MetaModel:sharedInstance():isHiddenBranchDesign(branchId) then --已上线隐藏关
            local branchData = MetaModel:sharedInstance():getHiddenBranchDataByBranchId(branchId)
            if branchData and branchData.endNormalLevel == endLevelId then
                for levelId=branchData.startHiddenLevel,branchData.endHiddenLevel do
                	local scoreOfLevel = UserManager:getInstance():getUserScore(levelId)
                	if scoreOfLevel then
                		if scoreOfLevel.star > 0 and scoreOfLevel.star <3 then
                			table.insert( level_Hide , levelId )
                		end
                	end
                end
            end
        end
    end

    table.sort( level_Hide , function ( levelId_1, levelId_2 )
		local config_1 = self:getLevelDifficultyV2Data(levelId_1)
		local config_2 = self:getLevelDifficultyV2Data(levelId_2)
		if config_1 and config_2 then
			if config_1.d3 ~= config_2.d3 then
				return config_1.d3 > config_2.d3
			end
		end
		return levelId_1 < levelId_2
	end )
	--  table.sort( level_Hide , function ( levelId_1, levelId_2 )
	-- 	local config_1 = self:getLevelDifficultyV2Data(levelId_1)
	-- 	local config_2 = self:getLevelDifficultyV2Data(levelId_2)
	-- 	if config_1 and config_2 then
	-- 		if config_1.d ~= config_2.d then
	-- 			return config_1.d < config_2.d
	-- 		end
	-- 	end
	-- 	return levelId_1 < levelId_2
	-- end )

    self.level_3 = level_3
    self.level_4 = level_4
    self.level_Hide = level_Hide
    self.jumpLevels = jumpLevels
    self.askForHelpLevels = askForHelpLevels
    self.needUpdateAllLevel = false 
	-- self.currentLevel = level_3[1] or level_Hide[1] or level_4[1] or askForHelpLevels[1] or jumpLevels[1]
	-- self.currentLevel = self.currentLevel or 0
	-- self:setCurrentLevel( self.currentLevel )

	-- for i=1,#self.jumpLevels do
	-- 	local levelId = jumpLevels[i]
	-- 	table.insert( self.level_3 , levelId )
	-- end
	-- for i=1,#self.askForHelpLevels do
	-- 	local levelId = askForHelpLevels[i]
	-- 	table.insert( self.level_3 , levelId )
	-- end

	self.level_3 = self:removalTable( self.level_3  )
	self.level_4 = self:removalTable( self.level_4  )
	self.level_Hide = self:removalTable( self.level_Hide  )
	self.jumpLevels = self:removalTable( self.jumpLevels  )
	self.askForHelpLevels = self:removalTable( self.askForHelpLevels  )

	-- if _G.isLocalDevelopMode  then jsmaLog( "CollectStarsManager getAllLevelsData 2  " , table.tostring( self.level_3 ) ) end
	-- if _G.isLocalDevelopMode  then jsmaLog( "CollectStarsManager setData  " , table.tostring( self.level_4 ) ) end
	-- if _G.isLocalDevelopMode  then jsmaLog( "CollectStarsManager setData  " , table.tostring( self.level_Hide ) ) end
	-- if _G.isLocalDevelopMode  then jsmaLog( "CollectStarsManager setData  " , table.tostring( self.jumpLevels ) ) end
	-- if _G.isLocalDevelopMode  then jsmaLog( "CollectStarsManager setData  " , table.tostring( self.askForHelpLevels ) ) end

    return self.level_3 , self.level_4 , self.level_Hide , self.jumpLevels , self.askForHelpLevels
end

function CollectStarsManager:removalTable( data )
	local ret = {}
	for k, v in ipairs( data ) do
		local hasIt = table.find( ret , function ( value )
			return value == v 
		end )
		if not hasIt then
			table.insert( ret , v )
		end
	end
	return ret

end


function CollectStarsManager:setData( data ,conditionsTable)

	-- jsmaLog("CollectStarsManager setData data = " , table.tostring(data))
	-- jsmaLog("CollectStarsManager setData conditionsTable = " , table.tostring(conditionsTable))

	self.stars = tonumber (data.stars )or 0 
	self.lastLevel = data.lastLevel or 0 
	self.rewards = table.clone( data.rewards or {} )
	self.usableProp = data.usableProp or 0 
	self.conditionsTable = table.clone( conditionsTable or {} )

	-- self.fullLevelJudge = data.fullLevelId or 0
	-- self.fullStarId = data.fullStarId or 0
	
	local userRef    = UserManager.getInstance().user
    local userStar = userRef:getStar()
    local userStar_Hide = userRef:getHideStar()
    local nowTotalStar = userStar + userStar_Hide
    --我第一次打开活动时的总星星数量
    self.beginStar  = nowTotalStar - self.stars 

    self.buffLeftNum = self.usableProp 
    self:setLeftBuffNum( self.buffLeftNum  )
   
end

function CollectStarsManager:getFullSpecialShow(  )
	return self.fullSpecialShow or false
end
function CollectStarsManager:getFullSpecialShowFull(  )
	return self.fullSpecialShow_Full or false
end

function CollectStarsManager:clearFullSpecialShow(  )
		
	self.fullSpecialShow_Full = false
	self.fullSpecialShow = false
end



--获取当前的收集星星数量 和满星数量
function CollectStarsManager:getWinNumString( forEnd )
	local index = 1
	if self.conditionsTable then
		for i=1,#self.conditionsTable do
			local conditionNode = self.conditionsTable[i] or 0
			if self.stars >= conditionNode then
				index = index + 1
			end
		end
	end
	local maxconditionNode = self.conditionsTable[4] or 0
	local maxconditionNode3 = self.conditionsTable[3] or 0
	local endRet = self.conditionsTable[index-1] or self.conditionsTable[index]
	if self.openNewBox then
		self.openNewBox = false
		return math.min( self.stars , self.conditionsTable[index-1] or self.conditionsTable[index] ) , self.conditionsTable[index-1] or self.conditionsTable[index] ,false
	end
	return math.min( self.stars , maxconditionNode) , self.conditionsTable[index] or self.conditionsTable[index-1] ,self.stars >= maxconditionNode3
end


function CollectStarsManager:getBoxCanOpenIndex()
	if not self:hasRewards() then
		return {}
	end

	local function isGetRewards( boxID )
    	local hasIt = table.find( self.rewards , function ( a  )
			return a == self:getRewardConfigWithIndex( boxID )
		end )
		return hasIt~=nil
    end 
    local stars = self.stars or 0
    if self:isFullStar() then
    	stars = self.conditionsTable[4] or 20
    end
    local canGetBoxIndex = {}
	for i=1,4 do
		local isGet = isGetRewards( i )
		local conditions = self.conditionsTable[i] or 0
		if not isGet and stars >= conditions then
			table.insert( canGetBoxIndex , i )
		end
	end
	return canGetBoxIndex
end


function CollectStarsManager:hasRewards()
	if not self.beginStar then
		return false
	end
	local userRef    = UserManager.getInstance().user
    local userStar = userRef:getStar()
    local userStar_Hide = userRef:getHideStar()
    local nowTotalStar = userStar + userStar_Hide
    local function isGetRewards( boxID )
    	local hasIt = table.find( self.rewards , function ( a  )
			return a == self:getRewardConfigWithIndex( boxID )
		end )
		return hasIt~=nil
    end 
    local stars = self.stars or 0
    if self:isFullStar() then
    	stars = self.conditionsTable[4] or 20
    end

	local totalStar = 0	
	local hasNotGetBox = false

	for i=1,4 do
		local isGet = isGetRewards( i )
		local conditions = self.conditionsTable[i] or 0
		if not isGet and stars >= conditions then
			return true
		end
		if not isGet then
			hasNotGetBox = true
		end
	end

	if hasNotGetBox and self:isActivityAwardTime() and  self:isFullStar()  then
		local canPlayTopLevel = NewAreaOpenMgr.getInstance():getCanPlayTopLevel()
		if canPlayTopLevel == self.fullStarId then
			return true
		end
	end

	return false

end

function CollectStarsManager:onPassLevelMsgSuccess( levelId )
	if not self:isActivitySupport() then
		return 
	end
	

	local topPassLevelOldId = UserManager:getInstance():getTopPassedMainLevelId()

	if levelId - topPassLevelOldId ~= 1  then
		return
	end

	if levelId == self.fullLevelJudge then
		self.fullSpecialShow = true
		self.buffLeftNum = self.buffLeftNum or 0
		self.buffLeftNum = self.buffLeftNum + 3
		self:setLeftBuffNum( self.buffLeftNum )
	end
	
end

function CollectStarsManager:doOpenActivity(  )


	if not self:isActivitySupport() then
		return
	end

    local actSource = CollectStarsManager:getInstance():getActSource()
    local source = actSource
    local version = nil
    for k,v in pairs(ActivityUtil:getActivitys() or {}) do
        if v.source == source then
            version = v.version
            break
        end
    end

    if version then
        ActivityData.new({source=source,version=version}):start(true, true, nil, nil, closeCallBack)
        PushActivity:sharedInstance():setActivityPopNumWithActId( collectStarsActid ,1 )
    end

end

function CollectStarsManager:doPopToday(  )
	if not self.popToday then
		self.popToday = true
		self:writeToLocal()
	end
end

function CollectStarsManager:checkPopop(  )

	if UserManager:getInstance():getTopPassedMainLevelId() >= self.fullLevelJudge then
		--满级玩家进游戏加载到活动立即强弹
	else
	    local todatFailTImes = CollectStarsManager.getInstance():getTodayFailNum()
	    local energy = UserManager:getInstance().user:getEnergy()
	    if energy < 5 or todatFailTImes>=4 and UserManager:getInstance():getTopPassedMainLevelId() <= self.fullLevelJudge then
	    	if not self.popToday then
	    		self:doOpenActivity()
		        self.popToday = true
		        self:writeToLocal()
		        return
	    	end
	    end
	end
	
	if self.fullSpecialShow or self.fullSpecialShow_Full then
		self:doOpenActivity()
	end

end



function CollectStarsManager:backToHomeScene( isInitedHomeScene )

	self:readUserData()
	-- self:checkLocalData()
	if isInitedHomeScene then
		self:updateIcon()
	end

end





function CollectStarsManager:addObserver(ob)

	self.observers[ob] = ob
end

function CollectStarsManager:removeObserver(ob)

	if self.observers[ob] then
		self.observers[ob] = nil
	end
end


function CollectStarsManager:notify(eventName, ...)
	for _, ob in pairs(self.observers) do
		if ob['on' .. eventName] then
			ob['on' .. eventName](ob, ...)
		end
	end
end


function CollectStarsManager:updateIconNumOnly( iconNum )

	if not self:isActivitySupport() then
		return
	end
	if not self:isActEnabled() then
		return
	end	
	
	jsmaLog( "updateIconNumOnly  iconNum = " , iconNum)

	local activityIcon = self:getActivityIcon()
	if activityIcon ==nil then
		return
	end
	if activityIcon.numTip ==nil then
		return
	end
	if activityIcon.numTip.setNum ==nil then
		return
	end
	if activityIcon.rewardIcon ==nil then
		return
	end


	if not iconNum then
		activityIcon.numTip:setNum( self.buffLeftNum  - self.autoAddBuffNum )
		activityIcon.rewardIcon:setVisible(true)
	else
		activityIcon.numTip:setNum( iconNum )
		activityIcon.rewardIcon:setVisible(false)
	end
end



function CollectStarsManager:updateIcon( inHomeScene ,iconNum )

	-- self:checkLocalData()

	if not self:isActivitySupport() then

	end
	if not self:isActEnabled() then
		return
	end	

	local hasRewards = self:hasRewards()	
	if ActivityUtil and ActivityUtil.setMsgNum then
		if self:isActivityAwardTime() then
			ActivityUtil:setMsgNum( ACT_SOURCE , 0  )
		else
			ActivityUtil:setMsgNum( ACT_SOURCE , self.buffLeftNum  )
		end
	end

	if ActivityUtil and ActivityUtil.setRewardMark and hasRewards then
		ActivityUtil:setRewardMark(ACT_SOURCE, hasRewards)
	end
	if self.autoAddBuffNum > 0 then
		self:updateIconNumOnly()
	end
end
function CollectStarsManager:playAddNumberAni( callback )

	local activityIcon = self:getActivityIcon()
	if activityIcon ==nil or activityIcon.icon ==nil  then
		return
	end
	local numLabel = BitmapText:create("+"..self:getAutoAddBuffNum(), "fnt/star_entrance.fnt")
	numLabel:setAnchorPoint(ccp(0.5, 0.5))
	activityIcon.icon:addChild( numLabel )
	numLabel:setPositionXY(-8 , 40)
	local kAnimationTime = 1/30
	local arr = CCArray:create()
	arr:addObject(CCMoveBy:create(kAnimationTime*10,ccp(0,20)))
	arr:addObject(CCCallFunc:create(function ()
		-- local leftBuffCount = math.max(context.leftBuffCount - 1, 0)
		-- leftTimeLabel:setText("x".. leftBuffCount)
	end))
	arr:addObject(CCSpawn:createWithTwoActions(
		 CCFadeOut:create(kAnimationTime*8),
		 CCMoveBy:create(kAnimationTime*8, ccp(0,10))
	))
	arr:addObject(CCCallFunc:create(function()
		numLabel:removeFromParentAndCleanup(true)
		numLabel = nil
		self.autoAddBuffNum = 0 
		self:updateIcon()
		if callback then callback() end
	end))
	numLabel:runAction(CCSequence:create(arr))

end

