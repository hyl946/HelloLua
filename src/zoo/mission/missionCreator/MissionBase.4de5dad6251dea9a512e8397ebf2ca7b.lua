MissionBase = class()

MissionUserType = {
	kDefault = 0,
	kNewUser = 1,
	kReturnUser = 2,
}

MissionTypes = {
	kTopLevel = 1,
	kGetStarMission = 2,
	kFourStarMission = 3,
	kRemainStep = 4,
	kEnterWeeklyRace = 5,
	kPickFruit = 6,
	kGetStar = 7,
	kLogin = 8,
}

function MissionBase:create(type, index, special)
	local mission = MissionBase.new()
	mission:init(type, index, special)
	return mission
end

function MissionBase:init(type, index, special)
	local meta = MetaManager:getInstance():getMissionTypeData(type)
	self.meta = {}
	for k, v in pairs(meta) do
		if _G.type(v) ~= "function" then
			self.meta[k] = v
		end
	end
	self.type = type
	self.index = index
	self.special = special
end

function MissionBase:isSupport(runningTasks)
	if not self.meta then return false end

	if not self:checkSpecial() or
		not self:checkWeeklyAppear() or
		not self:checkDailyAppear() or
		not self:checkUserTopLevel() or
		not self:checkConditionByUserType() or
		not self:filterRunningMission(runningTasks) then
		return false
	end
	return true
end

function MissionBase:isBenchSupport(runningTasks)
	return false
end

function MissionBase:checkSpecial()
	return not (self.special and not self.meta.special)
end
function MissionBase:checkWeeklyAppear()
	return self.meta.weekly > MissionCreator:getInstance():getWeeklyAppear(self.type)
end
function MissionBase:checkDailyAppear()
	return self.meta.daily > MissionCreator:getInstance():getDailyAppear(self.type)
end
function MissionBase:checkUserTopLevel()
	local userLevel = UserManager:getInstance():getUserRef():getTopLevelId()
	return not (userLevel < self.meta.minLevel or userLevel > self.meta.maxLevel)
end
function MissionBase:checkConditionByUserType()
	local userType = MissionCreator:getInstance():getUserType()
	if userType == MissionUserType.kNewUser then
		return self:checkSignInDay()
	elseif userType == MissionUserType.kReturnUser then
		return self:checkReturnDay()
	else
		return self:checkLoginDay()
	end
end
function MissionBase:checkLoginDay()
	local loginDay = MissionCreator:getInstance():getLoginDay()
	return self.meta.minLogin ~= 0 and self.meta.maxLogin ~= 0 and
		loginDay >= self.meta.minLogin and loginDay <= self.meta.maxLogin
end
function MissionBase:checkReturnDay()
	local loginAfterLose = MissionCreator:getInstance():getLoginAfterLose()
	return self.meta.maxReturn ~= 0 and loginAfterLose <= self.meta.maxReturn
end
function MissionBase:checkSignInDay()
	local signInDay = MissionCreator:getInstance():getSignInDay()
	return self.meta.maxSignIn ~= 0 and signInDay <= self.meta.maxSignIn
end
function MissionBase:filterRunningMission(runningTasks)
	if type(self.legal) == "table" then
		return #self.legal > 0
	end
	
	local metas = MetaManager:getInstance():getMissionIdMetaByType(self.type)
	self.legal = {}
	for i,v in ipairs(metas) do
		if not table.indexOf(runningTasks, v.id) then
			table.insert(self.legal, v)
		end
	end
	if #self.legal <= 0 then
		return false
	end
	return true
end

function MissionBase:createMission()
	local random = math.random(#self.legal)
	local meta = self.legal[random]
	return MissionCreator:createMissionByConfig({taskId = meta.id})
end