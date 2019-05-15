require "zoo.mission.missionCreator.MissionBase"
require "zoo.mission.missionCreator.TopLevelMission"
require "zoo.mission.missionCreator.GetStarMission"
require "zoo.mission.missionCreator.FourStarMission"
require "zoo.mission.missionCreator.RemainStepMission"
require "zoo.mission.missionCreator.EnterWeeklyRaceMission"
require "zoo.mission.missionCreator.GainStarMission"
require "zoo.mission.missionCreator.PickFruitMission"
require "zoo.mission.missionCreator.MarkMission"

local MissionTypeClasses = {
	[1] = TopLevelMission,
	[2] = GetStarMission,
	[3] = GetStarMission,
	[4] = GetStarMission,
	[5] = GetStarMission,
	[6] = GetStarMission,
	[7] = GetStarMission,
	[8] = GetStarMission,
	[9] = GetStarMission,
	[10] = GetStarMission,
	[11] = FourStarMission,
	[12] = FourStarMission,
	[13] = RemainStepMission,
	[14] = RemainStepMission,
	[15] = EnterWeeklyRaceMission,
	[16] = PickFruitMission,
	[17] = GainStarMission,
	[18] = GainStarMission,
	[19] = GainStarMission,
	[23] = MarkMission,
}

MissionCreator = class()

local instance = nil
function MissionCreator:getInstance()
	if not instance then
		instance = MissionCreator.new()
		instance:init()
	end
	return instance
end

function MissionCreator:ctor()
	self.weeklyAppear = {}
	self.dailyAppear = {}
	self.appearedMission = {}
	self.weeklyAppearAtCreation = {}
	self.dailyAppearAtCreation = {}
end

function MissionCreator:init()
	local meta = MetaManager:getInstance():getMissionMeta()
	self.missionType = {}
	for i,v in pairs(meta) do
		for j,w in ipairs(v.cType) do
			if not self.missionType[w] then
				self.missionType[w] = v.mType
			end
		end
	end
	self.createType = {}
	for i,v in ipairs(meta) do
		for j,w in ipairs(v.cType) do
			if not self.createType[w] then
				self.createType[w] = v.rType
			end
		end
	end
end

function MissionCreator:setCreateInfo(data)
	if data.weeklyAppear then
		self.weeklyAppear = {}
		for i, v in ipairs(data.weeklyAppear) do
			self.weeklyAppear[tonumber(v.key)] = tonumber(v.value)
		end
	end
	if data.dailyAppear then
		self.dailyAppear = {}
		for i, v in ipairs(data.dailyAppear) do
			self.dailyAppear[tonumber(v.key)] = tonumber(v.value)
		end
	end
	if data.appeardMission then
		self.appearedMission = {}
		for i,v in ipairs(data.appeardMission) do
			if tonumber(v) ~= nil then
				table.insert(self.appearedMission, tonumber(v))
			end
		end
	end
	if data.lastReturnTime then self.lastReturnTime = data.lastReturnTime end
	if data.loginCountInPassedSevenDays then
		self.loginCountInPassedSevenDays = data.loginCountInPassedSevenDays
		if self.loginCountInPassedSevenDays <= 1 then
			self.loginCountInPassedSevenDays = 1
		end
	end
end

function MissionCreator:addCreateAppearType(missionType)
	self.dailyAppearAtCreation[missionType] = (self.dailyAppearAtCreation[missionType] or 0) + 1
	self.weeklyAppearAtCreation[missionType] = (self.weeklyAppearAtCreation[missionType] or 0) + 1
end

function MissionCreator:addAppearType(missionType)
	self.dailyAppear[missionType] = (self.dailyAppear[missionType] or 0) + 1
	self.weeklyAppear[missionType] = (self.weeklyAppear[missionType] or 0) + 1
end

function MissionCreator:addAppearMission(missionId)
	for i,v in ipairs(self.appearedMission) do
		if v == missionId then
			return
		end
	end
	table.insert(self.appearedMission, missionId)
end

function MissionCreator:setRunningMissions(tasks)
	self.runningTasks = self.runningTasks or {}
	for i,v in ipairs(tasks) do
		table.insert(self.runningTasks, v)
	end
end

function MissionCreator:clearRunningMissions()
	self.runningTasks = {}
end

function MissionCreator:clearCreation()
	self.weeklyAppearAtCreation = {}
	self.dailyAppearAtCreation = {}
end

function MissionCreator:createMission(index, special)
	local ready = {}

	-- get supported mission types
	local meta = MetaManager:getInstance():getMissionTypeData()
	local benchList = {}
	for i,v in ipairs(meta) do
		local elem = nil
		if MissionTypeClasses[v.id] then
			elem = MissionTypeClasses[v.id]:create(v.id, index, special)
		else
			elem = MissionBase:create(v.id, index, special)
		end
		self.runningTasks = self.runningTasks or {}
		if elem:isSupport(self.runningTasks) then
			table.insert(ready, elem)
		else
			table.insert(benchList, elem)
		end
	end
	if #ready <= 0 then
		for i,v in ipairs(benchList) do
			if v:isBenchSupport(self.runningTasks) then
				table.insert(ready, elem)
			end
		end
	end
	if #ready <= 0 then return nil end

	-- kill running mission types (canceled while no mission type will survive)
	local runningTypes = MissionLogic:getInstance():getAppearingTypes()
	for i,v in ipairs(self.runningTasks) do
		local meta = MetaManager:getInstance():getMissionIdMeta(v)
		if meta then
			if not table.indexOf(runningTypes, meta.mType) then
				table.insert(runningTypes, meta.mType)
			end
		end
	end
	local tmp = {}
	for i,v in ipairs(ready) do
		if self.missionType[v.type] == 1 or not table.indexOf(runningTypes, self.missionType[v.type]) then
			table.insert(tmp, v)
		end
	end
	if #tmp > 0 then
		ready = tmp
	end

	-- sort by priority and kill items with same mission type
	table.sort(ready, function(a, b) return a.meta.priority > b.meta.priority end)
	local tmp, set = {}, {}
	for i, v in ipairs(ready) do
		local idx = table.indexOf(set, self.createType[v.type])
		if #tmp <= 0 or not idx then
			table.insert(tmp, v)
			table.insert(set, self.createType[v.type])
		else
			if math.random(100) <= 50 then
				tmp[idx] = v
			end
		end
	end
	ready = tmp

	-- pick items with highest priority
	local priority = ready[1].meta.priority
	for i,v in ipairs(ready) do
		if priority ~= v.meta.priority then
			while (#ready >= i) do
				table.remove(ready)
			end
			break
		end
	end

	-- randomly return a mission
	if #ready == 1 then
		return ready[1]:createMission()
	else
		local random = math.random(#ready)
		return ready[random]:createMission()
	end
end

function MissionCreator:getMissionType(type)
	return self.missionType[type]
end

function MissionCreator:getWeeklyAppear(createType)
	local missionType = self.missionType[createType]
	return (self.weeklyAppear[missionType] or 0) + (self.weeklyAppearAtCreation[missionType] or 0)
end

function MissionCreator:getDailyAppear(createType)
	local missionType = self.missionType[createType]
	return (self.dailyAppear[missionType] or 0) + (self.dailyAppearAtCreation[missionType] or 0)
end

function MissionCreator:getUserType()
	if self:getSignInDay() <= 7 then
		return MissionUserType.kNewUser
	elseif self:getLoginAfterLose() ~= 0 and self:getLoginAfterLose() <= 2 then
		return MissionUserType.kReturnUser
	else
		return MissionUserType.kDefault
	end
end

function MissionCreator:getPassedMissions()
	return self.appearedMission
end

function MissionCreator:getLoginDay()
	return self.loginCountInPassedSevenDays
end

function MissionCreator:getLoginAfterLose()
	if self.lastReturnTime == 0 then
		return 0
	end
	return math.ceil((Localhost:time() - self.lastReturnTime) / 86400000)
end

function MissionCreator:getSignInDay()
	local mark = UserManager:getInstance().mark
	return math.ceil((Localhost:time() - mark.createTime) / 86400000)
end

function MissionCreator:createMissionByConfig(config)
	local meta = MetaManager:getInstance():getMissionIdMeta(config.taskId) or {}
	local ret = {}
	ret.id = meta.id or 0
	ret.type = meta.mType or 0
	ret.state = config.state or ((meta.id and meta.id ~= 0) and 1) or 0
	ret.rewards = config.rewards or {}
	ret.extraRewards = config.extraRewards or {}
	ret.createTime = tonumber(config.createTime) or Localhost:time()
	ret.lastUpdateTime = tonumber(config.lastUpdateTime) or Localhost:time()
	ret.finishTime = tonumber(config.finishTime) or 0
	ret.condition = meta.condition or {}

	if config.progress then
		ret.progress = {}
		local sections = string.split(config.progress, ",")
		for i,v in ipairs(sections) do
			local values = string.split(v, '/')
			table.insert(ret.progress, {current = tonumber(values[1]), total = tonumber(values[2])})
		end
	end

	return ret
end

function MissionCreator:getRunningTypes()
	return MissionLogic:getInstance():getRunningTypes()
end

function MissionCreator:getMissionSubType(id)
	local meta = MetaManager:getInstance():getMissionIdMeta(id) or {}
	return meta.rType
end