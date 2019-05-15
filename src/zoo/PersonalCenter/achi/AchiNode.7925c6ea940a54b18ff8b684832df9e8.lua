--[[
 * AchiNode
 * @date    2018-03-30 15:41:31
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

AchiNode = class()

function AchiNode:ctor()
	self.id = 0
	self.scoreMap = {}
	self.defaultScore = 0
	self.ladder = nil
	self.level = 0
	self.levelType = nil
	self.reachCount = 0
	self.timeout = 0.5
	self.sharePriority = 0
	self.maxLevel = 1
	self.score = 0
	self.quitLevelMode = "success"
	self.reachedNotReceive = nil
end

function AchiNode:dump()
	local data = {
		id = self.id,
		score = self.score,
		level = self.level,
		reachCount = self.reachCount,
		maxLevel = self.maxLevel,
		nextTarCount = self:getNextTarCount(),
		reachedNotReceive = self.reachedNotReceive
	}

	Achievement:print(table.tostring(data))

	return data
end

function AchiNode:clean()
	self.level = 0
	self.reachedNotReceive = {level = 0, score = 0}
	self.reachCount = 0
	self.score = 0
end

function AchiNode:getNextTarCount()
	if type(self.ladder) ~= "table" then return 0 end

	local nextLevel = self.level + 1
	if nextLevel > self.maxLevel then nextLevel = self.maxLevel end

	return self.ladder[nextLevel]
end

function AchiNode:getCurTarCount(level)
	if type(self.ladder) ~= "table" then return 0 end
	level = level or self.level
	level = self:checkLevel(level)
	return self.ladder[level]
end

function AchiNode:getShareConfig()
	return {
		id = self.id,
		shareTitle = "show_off_desc_"..self.id,
		priority = self.priority,
		shareType = AchiShareType.kImage,
		keyName = "achievement.name."..self.id
	}
end

function AchiNode:canShared()
	return self.sharePanel ~= nil
end

function AchiNode:createSharePanel()
	if self.sharePanel then
		return self.sharePanel:create(self.id)
	end
	return nil
end

function AchiNode:isPassLevelCheck()
	return self.levelType ~= nil
end

function AchiNode:checkSupport(data)
	if self:isPassLevelCheck() then
		local isMatchQuitMode = (self.quitLevelMode == "all") or (data[AchiDataType.kQuitLevelMode] == self.quitLevelMode)
		local isMatchLevel = self:matchLevelType(data[AchiDataType.kLevelType])

		return  isMatchQuitMode and isMatchLevel
	end

	return true
end

function AchiNode:getCurReachedLevel()
	local level = self.level
	if self.reachedNotReceive then
		if self.reachedNotReceive.level and self.reachedNotReceive.level > level then
			level = self.reachedNotReceive.level
		end
	end
	return level
end

function AchiNode:isReachLadder( value, isEqual )
	local ladder = self.ladder or {}

	local level = self:getCurReachedLevel()
	local ntarget = ladder[level + 1] or ladder[level]

	if Achievement:isDebug() then
		Achievement:print(AchiId.name(self.id), level, ntarget, value, self.reachCount)
	end

	if not value or not ntarget then
		return false
	end

	local isReach = value >= ntarget
	if isEqual then
		isReach = value == ntarget
	end

	local isMaxLevel = level == self.maxLevel
	if ntarget and isReach and not isMaxLevel then
		return true
	end

	return false
end

function AchiNode:cancelTimeOut()
	if self.timeoutId then
		cancelTimeOut(self.timeoutId)
		self.timeoutId = nil
	end
end

function AchiNode:waitData()
	self.state = AchiNodeState.WAIT_DATA
	if not self.timeoutId then
		self.timeoutId = setTimeOut(function ()
			self.state = AchiNodeState.TIME_OUT
			if Achievement:isDebug() then
				Achievement:print("timeout:", AchiId.name(self.id))
			end
			self.timeoutId = nil
			Achievement:finished( self.id, false )
		end, self.timeout)
	end
end

function AchiNode:checkReach(data)
	if not self:checkSupport(data) then
		if Achievement:isDebug() then
			Achievement:print("this achi not support:", AchiId.name(self.id))
		end
		return
	end

	if self.state == AchiNodeState.TIME_OUT then
		return
	end

	local requiredDataIds = self.requiredDataIds or {}
	for _,id in ipairs(requiredDataIds) do
		if data[id] == nil then
			self:waitData()
			if Achievement:isDebug() then
				Achievement:print("require data is not ready:", AchiDataType.name(id))
			end
			return
		end
	end

	self:cancelTimeOut()

	self.state = AchiNodeState.CHECKING

	if self.type == AchiType.TRIGGER then
		local level = self:getCurReachedLevel()
		self.isNewReach = level > 0
	end

	local ret = false
	if self.onCheckReach then
		ret = self:onCheckReach(data)
	else
		Achievement:print("node no checkReach func!!!")
		return
	end

	self.state = AchiNodeState.FINISHED

	if Achievement:isDebug() then
		Achievement:print(AchiId.name(self.id), ", result:",ret)
	end

	if ret and Achievement:isEnabled() and not self:isMaxLevel() then
		local level = self:getCurReachedLevel()
		local score = 0
		if self.type == AchiType.PROGRES then
			level = level + 1
			score = self:getScore(level)
		elseif self.type == AchiType.TRIGGER then
			level = 1
			score = self:getScore(level)
		end

		if self.type ~= AchiType.SHARE then
			if Achievement:isDebug() then
				Achievement:print(AchiId.name(self.id), ", level:",level)
			end
			self:reached(level, score)
		end
	end

	Achievement:finished( self.id, ret )
end

function AchiNode:setup( config )
	if config.id ~= self.id then
		Achievement:print("config id, node id isnot match!")
		return
	end

	local points = config.points:split(",")
	for _,point in ipairs(points) do
		local r = point:split("-")
		if #r == 1 then
			self.defaultScore = tonumber(r[1])
		else
			for level=r[1],r[2] do
				self.scoreMap[level] = tonumber(r[3])
			end
		end
	end

	if config.ladder ~= "" then
		self.ladder = config.ladder:split(",") or {}
		for index=1,#self.ladder do
			local v = self.ladder[index]
			v = string.gsub(v, "(%w+)w", "%10000")
			v = string.gsub(v, "(%w+)y", "%100000000")
			self.ladder[index] = tonumber(v)
		end
	end
	--处理在高版本登录后，再去低版本登录的情况(删掉一些阶梯值)
	if self.calLadder then
		self:calLadder()
	end

	if config.extra then
		if self.calExtra then
			self:calExtra(config.extra)
		else
			self.extra = config.extra:split(",") or {}
			for index=1,#self.extra do
				self.extra[index] = tonumber(self.extra[index])
			end
		end
	end

	self.priority = tonumber(config.priority)
	self.type = config.type
	self.category = config.category

	if self.type == AchiType.PROGRES then
		if self.id == AchiId.kTotalEntryWeeklyCount then
			self.maxLevel = #self.extraLadder
		else
			self.maxLevel = #self.ladder
		end
	else
		self.maxLevel = 1
	end

	self.state = AchiNodeState.WAIT_DATA

	if self.requiredDataIds then
		for _,dataId in ipairs(self.requiredDataIds) do
			Achievement:addDataMap(dataId, self)
		end
	end

	--share
	local SharePriority = (require "zoo.PersonalCenter.achi.ShareConfig")
	self.sharePriority = SharePriority[self.id]
end

function AchiNode:getSingleLevelScore( level )
	if level and level > 0 then
		return self.scoreMap[level] or self.defaultScore
	elseif not level then
		return self.defaultScore
	else
		return 0
	end
end

function AchiNode:getScore(level)
	local score = 0
	if self.type == AchiType.PROGRES then
		for l=1,level do
			score = score + self:getSingleLevelScore(l)
		end
	else
		score = self:getSingleLevelScore(level)
	end
	return score
end

function AchiNode:cal()
	if self.type ~= AchiType.PROGRES then
		return
	end

	local ladder = self.ladder
	
	self.reachCount = self:getTargetValue()

	local level = 0
	for _,target in ipairs(ladder) do
		if target <= self.reachCount then
			level = level + 1
		end
	end

	local frontLevel = level
	local backCurLevel = self.level
	local backNextLevel = self.reachedNotReceive.level

	local isError = false

	if backCurLevel > frontLevel then
		self.level = level
		isError = true
	end

	if backCurLevel > backNextLevel then
		isError = true
		self.reachedNotReceive.level = self.level
	end

	if frontLevel < backNextLevel then
		isError = true
	end

	if Achievement:isDebug() and isError then
		local msg = string.format("id:%d数据合并错误：前端level:%d,后端生效level:%d,后端预领level:%d", self.id, frontLevel,backCurLevel, backNextLevel)
		CommonTip:showTip(msg)
		Achievement:print(msg)
	end
end

function AchiNode:mergeReceive(serverAchi)
	if self.type == AchiType.SHARE then
		return
	end

	self.level = serverAchi.level
	self.score = self:getScore(serverAchi.level)
end

function AchiNode:mergeReachedNotReceive(serverAchi)
	if self.type == AchiType.SHARE then
		return
	end
	self.reachedNotReceive = self.reachedNotReceive or {}
	local level = self.reachedNotReceive.level
	if not level or level < serverAchi.level then
		self.reachedNotReceive.level = serverAchi.level or 0
		self.reachedNotReceive.score = self:getScore(serverAchi.level)
	end
end

local function UpdateAchiData( id, level, achis )
	for _,achi in ipairs(achis) do
		if achi.id == id then
			achi.level = level
			return
		end
	end

	local achi = {id = id, level = level}
	table.insert(achis, achi)
end

--达成成就，还没领取
function AchiNode:reached( level, score )
	self:mergeReachedNotReceive({level = level, score = score})

	local achis = UserManager:getInstance().achievement.achievements
	local serviceAchis = UserService:getInstance().achievement.achievements

	UpdateAchiData(self.id, level, achis)
	UpdateAchiData(self.id, level, serviceAchis)
end

function AchiNode:receive(extra)
	local serverInfo = extra

	local info = {
		fromScore = self:getScore(self.level),
		fromLevel = self.level,
		toLevel = self.level,
		toScore = self:getScore(self.level),
		addScore = 0,
		addLevel = 0,
		id = self.id,
	}

	if serverInfo and serverInfo.effectiveLevel and serverInfo.level then
		self.level = serverInfo.effectiveLevel
		self:reached(serverInfo.level, self:getScore(serverInfo.level))

		if serverInfo.value then
			UserManager:getInstance().userExtend:setAchievementValue(self.id, tonumber(serverInfo.value) or 0)
			UserService:getInstance().userExtend:setAchievementValue(self.id, tonumber(serverInfo.value) or 0)
		end

		if self.id == AchiId.kTotalEntryWeeklyCount and serverInfo.weekMatchCounter then
			Achievement:print(table.tostring(UserManager:getInstance().achievement.weekMatch))

			local newWeekMatch = {}
			for k,v in pairs(serverInfo.weekMatchCounter) do
				local kv = {key = tonumber(k) or 0, value = tonumber(v) or 0}
				table.insert(newWeekMatch, kv)
			end
			
			UserManager:getInstance().achievement.weekMatch = newWeekMatch
			UserService:getInstance().achievement.weekMatch = table.clone(newWeekMatch)

			Achievement:print(table.tostring(newWeekMatch))
		end
	else
		self.level = self.level + 1
	end

	self.score = self:getScore(self.level)
	info.toLevel = self.level
	info.toScore = self.score

	info.addScore = info.toScore - info.fromScore
	info.addLevel = info.toLevel - info.fromLevel

	local receiveAchis = UserManager:getInstance().achievement.effectiveAchievements
	local serviceAchis = UserService:getInstance().achievement.effectiveAchievements
	UpdateAchiData(self.id, info.toLevel, receiveAchis)
	UpdateAchiData(self.id, info.toLevel, serviceAchis)

	Localhost.getInstance():flushCurrentUserData()

	return info
end

function AchiNode:getNotReceiveIndex()
	local achis = UserManager:getInstance().achievement.achievements
	for index,achi in ipairs(achis) do
		if achi.id == self.id then
			return index
		end
	end
	return nil
end

function AchiNode:canReceive()
	local index = self:getNotReceiveIndex()
	if index then
		local receiveData = UserManager:getInstance().achievement.achievements[index]
		return self.level < receiveData.level
	end
	return false
end

function AchiNode:matchLevelType(levelType)
	if self.levelType == 0 then return true end
	if levelType == nil then return false end
	local c = bit.lshift(1, levelType - 1)
	local ret = bit.band(self.levelType, c)
	return ret ~= 0
end

function AchiNode:isMaxLevel()
	return self.level == self.maxLevel
end

function AchiNode:checkLevel( level )
	return level > self.maxLevel and self.maxLevel or level
end

function AchiNode:getMaxScore()
	if self.maxScore then return self.maxScore end
	self.maxScore = self:getScore(self.maxLevel)
	return self.maxScore
end

function AchiNode:genLevelType( ... )
	local p = {...}
	local ret = 0
	for i,v in ipairs(p) do
		local tmp = bit.lshift(1, v - 1)
		ret = bit.bor(ret, tmp)
	end

	return ret
end

--common api
function AchiNode:isNotRepeatLevel( data, isJumpCheck )
	local score = data[AchiDataType.kOldScore]
	if score >= 0 then
		if isJumpCheck then
			if data[AchiDataType.kOldIsJumpLevel] then
				return true
			end
		end
		return false
	else
		return true
	end
end

function AchiNode:isGetNewStar( data )
	return data[AchiDataType.kOldStar] < data[AchiDataType.kNewStar]
end