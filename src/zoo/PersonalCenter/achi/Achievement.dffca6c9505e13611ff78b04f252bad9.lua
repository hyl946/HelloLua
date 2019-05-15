--[[
 * Achievement
 * @date    2018-03-30 11:34:44
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

Achievement = {}

AchiNodeState = {
	INVALID = 0,	--无效
	WAIT_DATA = 1,	--等待数据
	TIME_OUT = 2,	--超时
	FINISHED = 3,	--完成判断
	CHECKING = 4,   --判断中
}

function Achievement:isDebug()
	return _G.isLocalDevelopMode
end

require "zoo.PersonalCenter.achi.AchievementType"

function Achievement:init()
	if self.isInited then return end

	self.data = {}
	self.nodes = {}
	self.dataIdmap = {}
	self.isInited = true
	self.achis = {}

	local config,rightsConfig = unpack(require "zoo.PersonalCenter.achi.Config")
	require "zoo.PersonalCenter.achi.AchiNode"
	require "zoo.PersonalCenter.achi.node.NodeRequire"
	
	for _,c in ipairs(config) do
		local id = c.id
		local node = self.achis[id]
		if node then
			node:setup(c)
			self.nodes[id] = node
		else
			if self:isDebug() then
				self:print("not support this id:", AchiId.name(id))
			end
		end
	end

	self.achis = nil

	local AchiLevelRights = (require "zoo.PersonalCenter.achi.AchiLevelRights")
	AchiLevelRights:init(rightsConfig)

	self.levelRights = AchiLevelRights

	self:calAchi()

	self.state = "NORMAL_CHECKING"

	Notify:register("AchiEventDataUpdate", self.onDataUpdate, self)
	Notify:register("AchiEventPassLevel", self.onPassLevel, self)
	Notify:register("AchiEventFailLevel", self.onFailLevel, self)
	Notify:register("AchiEventSetData", self.set, self)
	Notify:register("AchiEventStartLevel", self.onStartLevel, self)
	Notify:register("AchiEventQuitGame", self.onQuitGame, self)
	Notify:register("AchiEventUserDataUpdate", self.calAchi, self)
	Notify:register("AchiEventCleanData", self.cleanData, self)

	local function onSuccessEvent(evt)
		self:print("onSuccessEvent", table.tostring(evt))
		local achiData = evt.data
		local achiId = achiData.id
		local value = achiData.value

		local oldValue = UserManager:getInstance().userExtend:getAchievementValue(achiId) or 0
		local addcount = value - oldValue
		if addcount > 0 then
			Notify:dispatch("AchiEventDataUpdate", achiId, addcount)
		end
	end
	EmergencySystem:getInstance():addEventListener(kEmergencyEvents.kAchievementEvent, onSuccessEvent)

	self.isNeedNetTrigger = not self:isEnabled()
end

function Achievement:checkInit()
	if self.isInited then
		self.isNeedNetTrigger = not self:isEnabled()
		self:calAchi()
		return
	end
	self:init()
end

function Achievement:addDataMap( dataId, node )
	self.dataIdmap[dataId] = self.dataIdmap[dataId] or {}
	table.insertIfNotExist(self.dataIdmap[dataId], node)
end

function Achievement:isNetworkTrigger()
	local hasAchi = UserManager:getInstance().achievement.newAchi

	if self.isNeedNetTrigger then
		return hasAchi and self.isNetTrigger
	else
		return hasAchi
	end
end

function Achievement:calAchi()
	for id,node in pairs(self:getAchis()) do
		node:clean()
	end

	--已领取
	local receiveAchis = UserManager:getInstance().achievement.effectiveAchievements
	for _,achi in ipairs(receiveAchis) do
		local node = self:getAchi(achi.id)
		if node then
			node:mergeReceive(achi)
		end
	end
	--已达成未领取
	local reachedAchis = UserManager:getInstance().achievement.achievements
	for _,achi in ipairs(reachedAchis) do
		local node = self:getAchi(achi.id)
		if node then
			node:mergeReachedNotReceive(achi)
		end
	end

	--reached count
	local achievementValue = UserManager:getInstance().userExtend.achievementValue
	for k,v in pairs(achievementValue) do
		if type(v) == "table" then
			local node = self:getAchi(v.key)
			if node then
				node.reachCount = v.value
			end
		end
	end

	for id,node in pairs(self.nodes) do
		if node.type == AchiType.PROGRES then
			node:cal()
		end
	end

	self.levelRights:check()
end

function Achievement:registerNode( node )
	self.achis[node.id] = node
end

function Achievement:print( ... )
	printx(10,"[Achievement]", ...)
	-- require "hecore.debug.remote"
	-- RemoteDebug:uploadLog(...)
end

function Achievement:set( id, value )
	self:init()
	self.data[id] = value
end

function Achievement:get( id )
	self:init()
	return self.data[id]
end

function Achievement:getAchi( id )
	self:init()
	return self.nodes[id]
end

function Achievement:getAchisByCategory(category)
	self:init()
	local achis = {}
	for k, v in pairs(self.nodes) do
		if v.category == category then
			table.insert(achis, v) 
		end
	end
	return achis
end

function Achievement:getAchis()
	self:init()
	return self.nodes
end

function Achievement:getState()
	self:init()
	return self.levelRights:dump()
end

function Achievement:getFriendScore( friend )
	if friend then
		local achievements = friend.achievement and friend.achievement.achievements or {}
		achievements = achievements or {}
		local score = 0
		for k, v in pairs(achievements) do
			local id = v.id
			local level = v.level
			local achi = self:getAchi(id)
			if achi then
				score = score + achi:getScore(level)
			end
		end
		return score
	else
		local state = self:getState()
		return state.score
	end
end

function Achievement:getLevelByScore( score )
	return self.levelRights:getLevel(score)
end

function Achievement:getRightsExtra( tname )
	self:init()
	return self.levelRights:getExtraCount( tname )
end

function Achievement:getRightsConfig()
	self:init()
	return self.levelRights:getConfig()
end

-- 默认返回当前显示的成就等级
function Achievement:getProgressString(reachedProgress)
	self:checkInit()

	local progress = ""
	local achis = {}
	for id,node in pairs(self.nodes) do
		if node.type ~= AchiType.SHARE then
			if reachedProgress then
				table.insert(achis, {node.id, node:getCurReachedLevel(), node.priority})
			else
				table.insert(achis, {node.id, node.level, node.priority})
			end
		end
	end

	table.sort(achis, function ( p, n )
		return p[3] < n[3]
	end)

	for i,achi in ipairs(achis) do
		if i == 1 then
			progress = string.format("%d_%d", achi[1], achi[2])
		else
			progress = string.format("%s;%d_%d",progress, achi[1], achi[2])
		end
	end

	return progress
end

--input
function Achievement:onDataUpdate(dataId, value)
	self:init()

	if not dataId then return end

	local nodes = self.dataIdmap[dataId] or {}
	self:set(dataId, value)

	if self:isDebug() then
		self:print("onDataUpdate:", AchiDataType.name(dataId), value)
	end

	for _,node in ipairs(nodes) do
		if node.state == AchiNodeState.WAIT_DATA then
			if not (self.state == "NORMAL_CHECKING" and node:isPassLevelCheck()) then
				node:checkReach(self.data)
			end
		end
	end
end

function Achievement:requireData()
	if self.data[AchiDataType.kQuitLevelMode] == "success" then
		local achi = self:getAchi(AchiId.kScorePassThousand)
		achi:requireData()

		local achi = self:getAchi(AchiId.kPassHighestLevel)
		achi:requireData(self.data)
	end
end

function Achievement:cleanData()
	self.data = {}
end

function Achievement:onStartLevel(levelId, levelType)
	self:cleanData()
	
	self:set(AchiDataType.kOldIsJumpLevel, UserManager.getInstance():hasPassedByTrick(levelId))

	if LevelType:isMainLevel(levelId) or LevelType:isHideLevel( levelId ) then
		self:set(AchiDataType.kEntryLevelTimeAddCount, 1)
	elseif LevelType:isSummerMatchLevel( levelId ) then
		self:set(AchiDataType.kEntryWeeklyAddCount, 1)
	elseif LevelType:isMoleWeekLevel( levelId ) then
		self:set(AchiDataType.kEntryWeeklyAddCount, 1)
	end

	self:set(AchiDataType.kLevelId, levelId)
	self:set(AchiDataType.kLevelType, levelType)
end

function Achievement:onQuitGame(isAH)
	self:set(AchiDataType.kQuitLevelMode, "quit")
	self:onQuitLevelCheckReach()
end

function Achievement:onFailLevel(levelId, totalScore)
	self:set(AchiDataType.kQuitLevelMode, "fail")
	self:onQuitLevelCheckReach()
end

function Achievement:onPassLevel(levelId, levelType, nation_level_config, nation_score_config)
	local function check()
		self:set(AchiDataType.kQuitLevelMode, "success")
		self:set(AchiDataType.kNationScoreCofig, nation_score_config)
		self:set(AchiDataType.kNationLevelCofig, nation_level_config)
		self:set(AchiDataType.kLevelId, levelId)
		self:set(AchiDataType.kLevelType, levelType)
		self:onQuitLevelCheckReach()
	end

	if levelId == 59 and not UserManager:getInstance():getOldUserScore(levelId) then
		local function onUseLocalFunc(errCode)
			check()
		end
		local function onUseServerFunc(data)
			self.isNetTrigger = true
			UserManager.getInstance():updateUserData(data)
			UserService.getInstance():updateUserData(data)
			UserService:getInstance():clearCachedHttp()

			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
			check()
		end

		RequireNetworkAlert:callFuncWithLogged(function( ... )
       		local logic = SyncExceptionLogic:create()
			logic:syncData(onUseServerFunc, onUseLocalFunc, kRequireNetworkAlertAnimation.kNoAnimation)
	    end,check,kRequireNetworkAlertAnimation.kSync)
	    
	else
		check()
	end
end

function Achievement:onQuitLevelCheckReach()
	local levelId = self.data[AchiDataType.kLevelId] or 0
	local levelType = self.data[AchiDataType.kLevelType] or 0

	local curRef	= UserManager:getInstance():getUserScore(levelId)
	local oldRef	= UserManager:getInstance():getOldUserScore(levelId)

	if oldRef then
		self:set(AchiDataType.kOldScore, oldRef.score)
		self:set(AchiDataType.kOldStar, oldRef.star)
	else
		self:set(AchiDataType.kOldScore, -1)
		self:set(AchiDataType.kOldStar, -1)
	end

	if curRef then
		self:set(AchiDataType.kNewScore, curRef.score)
		self:set(AchiDataType.kNewStar, curRef.star)
	else
		self:set(AchiDataType.kNewScore, 0)
		self:set(AchiDataType.kNewStar, 0)
	end

	if levelType == GameLevelType.kMainLevel or 
		levelType == GameLevelType.kHiddenLevel
	then 
		self:requireData()
	end

	self.state = "QUIT_LEVEL_CHECKING"

	self:print("QUIT_LEVEL_CHECKING ... ")

	for id,node in pairs(self.nodes) do
		if node:isPassLevelCheck() then
			node:checkReach(self.data)
		end
	end

	Localhost.getInstance():flushCurrentUserData()
end

function Achievement:isEnabled()
	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	return topLevelId >= 60
end

function Achievement:receive(achiId, onSuccess, onFail, onCancel)
	local http = OpNotifyHttp.new(true)

	local function opFail(evt)
		if evt and evt.data then 
			CommonTip:showTip(localize("error.tip."..evt.data))
		end
		if onFail then onFail({id = achiId, errCode = (evt.data or 0) }) end
	end

	local function opCancel(evt)
		if onCancel then onCancel({id = achiId}) end
	end

	local function opSuccess(evt)
		local achi = self:getAchi(achiId)

		if achi then
			if achi:isMaxLevel() then
				opFail({data = 7318001})
				return
			end

			local extra = nil
			if evt.data.extra then
				extra = table.deserialize(evt.data.extra)
			end
			local info = achi:receive(extra)

			if info.addScore <= 0 then
				CommonTip:showTip(localize("error.tip.7318002"))
			end

			self.levelRights:check()
			if onSuccess then onSuccess(info) end
		else
			opFail({data = -1})
		end
	end

	http:ad(Events.kComplete, opSuccess)
    http:ad(Events.kError, opFail)
    http:ad(Events.kCancel, opCancel)
    http:syncLoad(OpNotifyType.kAchi, achiId)
end

function Achievement:finished( achiId, isReached )
	local node = self.nodes[achiId]
	if node:isPassLevelCheck() then
	--过关成就
		if isReached then
			self.reachedAchis = self.reachedAchis or {}
			table.insert(self.reachedAchis, achiId)
		end

		local isFinished = true
		for id,node in pairs(self.nodes) do
			if node:isPassLevelCheck() and node:checkSupport(self.data) and node.state == AchiNodeState.WAIT_DATA then
				isFinished = false
				break
			end
		end

		if isFinished then
			local sharedIds = {}
			self.reachedAchis = self.reachedAchis or {}

			for _,id in ipairs(self.reachedAchis) do
				local n = self.nodes[id]
				if n:canShared() then
					table.insert(sharedIds, id)
				end
			end

			if self:isDebug() then
				local dataInfo = {}
				for dataId,v in pairs(self.data) do
					dataInfo[AchiDataType.name(dataId)] = v
				end
				self:print(table.tostring(dataInfo))

				local idInfo = {}
				for _,aid in ipairs(self.reachedAchis) do
					idInfo[AchiId.name(aid)] = true
				end

				self:print("pass level reached achis:", table.tostring(idInfo))
			end

			if #sharedIds > 0 and not self:get(AchiDataType.kForbidShare) then
				table.sort( sharedIds, function ( pid, nid )
					local pnode = self.nodes[pid]
					local nnode = self.nodes[nid]
					return pnode.sharePriority < nnode.sharePriority
				end )

				Notify:dispatch("AchiEventShowShare", sharedIds)
			end

			self.levelRights:check()

			self:notifyServer(self.reachedAchis)
			self.reachedAchis = {}

			for id,node in pairs(self.nodes) do
				if node:isPassLevelCheck() then
					node.state = AchiNodeState.WAIT_DATA
				end
			end
			self.state = "NORMAL_CHECKING"
		end
	else
	--关外成就
		if isReached then
			self:notifyServer( {achiId} )

			local achi = self:getAchi(achiId)
			if achi and achi:canShared() then
				Notify:dispatch("AchiEventShowShare", {achiId})
			end
			
			self.levelRights:check()
			Localhost.getInstance():flushCurrentUserData()
		end
		node.state = AchiNodeState.WAIT_DATA
	end
end

function Achievement:notifyServer( achiTable )
	if not self:isEnabled() or not self:isNetworkTrigger() then return end
	local newAchis = {}
	for _, id in pairs(achiTable) do
		local node = self:getAchi(id)
		if node.type ~= AchiType.SHARE then
			local has = node.type == AchiType.TRIGGER and node.isNewReach
			if not has then
				table.insert(newAchis, id)
			end
		end
		if node.type == AchiType.TRIGGER then
			local http = TriggerAchievement.new()
            local function onRequestFinish( evt )
            	SyncManager.getInstance():sync(nil, nil, kRequireNetworkAlertAnimation.kNoAnimation)
            end
            http:addEventListener(Events.kComplete, onRequestFinish)
			http:load(id)
		end
	end

	if #newAchis > 0 then
		table.sort( newAchis, function ( pid, nid )
			local pnode = self:getAchi(pid)
			local nnode = self:getAchi(nid)
			return pnode.priority < nnode.priority
		end )
		Notify:dispatch("AchiEventReachedNewAchi", newAchis)
	end
end

Notify:register("AchiEventInit", Achievement.checkInit, Achievement)