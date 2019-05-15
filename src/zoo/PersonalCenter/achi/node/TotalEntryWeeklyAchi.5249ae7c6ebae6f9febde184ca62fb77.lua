--[[
 * TotalEntryWeeklyAchi
 * @date    2018-04-09 14:22:07
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local TotalEntryWeeklyAchi = class(AchiNode)

function TotalEntryWeeklyAchi:ctor()
	self.id = AchiId.kTotalEntryWeeklyCount
	self.levelType = self:genLevelType(GameLevelType.kSummerWeekly, GameLevelType.kMoleWeekly)
	self.requiredDataIds = {self.id}
	self.quitLevelMode = "all"
end

function TotalEntryWeeklyAchi:calExtra( extra )
	local ex = extra:split(",") or {}
	local extraLadder = {}
	
	for _,l in ipairs(ex) do
		local ladder = l:split(":")
		table.insert(extraLadder, {date = tonumber(ladder[1]), target = tonumber(ladder[2])})
	end

	self.extraLadder = extraLadder
end

function TotalEntryWeeklyAchi:getCurTarCount(level)
	if type(self.extraLadder) ~= "table" then return 0 end
	level = level or self.level
	level = self:checkLevel(level)
	return self.extraLadder[level].target
end

function TotalEntryWeeklyAchi:addCount()
	self:checkExpireData()

	local today = self:getTodayStart()
	local weekMatch = UserManager:getInstance().achievement.weekMatch or {}
	local serviceWeek = UserService:getInstance().achievement.weekMatch or {}
	
	local has = false
	local tarIndex = nil

	for index,time_count in ipairs(weekMatch) do
		local time = time_count.key
		if time == today then
			time_count.value = time_count.value + 1
			has = true
			tarIndex = index
			break
		end
	end

	if tarIndex then
		serviceWeek[tarIndex].value = serviceWeek[tarIndex].value + 1
	end

	if not has then
		table.insert(UserManager:getInstance().achievement.weekMatch, {key = today, value = 1})
		table.insert(UserService:getInstance().achievement.weekMatch, {key = today, value = 1})
	end
end

function TotalEntryWeeklyAchi:getTodayStart()
	local t =	Localhost:getTodayStart()
	local utc8TimeOffset = 57600
	local dayInSec = 86400
	return (t - utc8TimeOffset) / dayInSec + 1
end

function TotalEntryWeeklyAchi:checkExpireData()
	local maxDate = self.extraLadder[#self.extraLadder].date
	local weekMatch = UserManager:getInstance().achievement.weekMatch or {}
	local lastday = self:getTodayStart() - maxDate + 1
	local newWeekMatch = {}
	for index,time_count in ipairs(weekMatch) do
		local time = time_count.key
		local count = time_count.value
		if lastday <= time then
			table.insert(newWeekMatch, time_count)
		end
	end
	UserManager:getInstance().achievement.weekMatch = newWeekMatch
	UserService:getInstance().achievement.weekMatch = table.clone(newWeekMatch)
end

function TotalEntryWeeklyAchi:getCurCount()
	local ladder = self.extraLadder or {}

	local level = self:getCurReachedLevel()
	local extraTar = ladder[level + 1] or ladder[level]
	local date = extraTar.date

	local weekMatch = UserManager:getInstance().achievement.weekMatch or {}
	local lastday = self:getTodayStart() - date + 1

	local count  = 0
	for index,time_count in ipairs(weekMatch) do
		local time = time_count.key
		if lastday <= time then
			count = count + time_count.value
		end
	end
	return count
end

function TotalEntryWeeklyAchi:receive(extra)
	local info = AchiNode.receive(self, extra)
	self:cal()
	return info
end

function TotalEntryWeeklyAchi:cal()
	self:checkExpireData()

	local ladder = self.ladder
	
	local curCount = self:getCurCount()


	local backCurLevel = self.level
	local backNextLevel = self.reachedNotReceive.level

	if backNextLevel > backCurLevel then
	--可领
		self.reachCount = self:getCurTarCount(backNextLevel)
	else
	--不可领
		self.reachCount = curCount
	end
end

function TotalEntryWeeklyAchi:getNextTarCount()
	if type(self.extraLadder) ~= "table" then return 0 end

	local nextLevel = self.level + 1
	if nextLevel > self.maxLevel then nextLevel = self.maxLevel end

	local tar = self.extraLadder[nextLevel]
	return tar.target
end

function TotalEntryWeeklyAchi:getNextTarDate()
	if type(self.extraLadder) ~= "table" then return 0 end

	local nextLevel = self.level + 1
	if nextLevel > self.maxLevel then nextLevel = self.maxLevel end

	local tar = self.extraLadder[nextLevel]
	return tar.date
end

function TotalEntryWeeklyAchi:getCurTarDate(level)
	if type(self.extraLadder) ~= "table" then return 0 end
	if type(level) ~= "number" then level = 1 end
	if level > self.maxLevel then level = self.maxLevel end

	local tar = self.extraLadder[level]
	return tar.date
end

function TotalEntryWeeklyAchi:isReachLadder( value, isEqual )
	local ladder = self.extraLadder or {}

	local level = self:getCurReachedLevel()
	local extraTar = ladder[level + 1] or ladder[level]
	local ntarget = extraTar.target

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

function TotalEntryWeeklyAchi:onCheckReach(data)
	self:addCount()

	local curCount = self:getCurCount()

	local isReach = self:isReachLadder(curCount, true)

	self:cal()

	return isReach
end

function TotalEntryWeeklyAchi:getTargetValue()
	return UserManager:getInstance().userExtend:getAchievementValue(self.id) or 0
end

Achievement:registerNode(TotalEntryWeeklyAchi.new())