require "zoo.mission.missionCreator.MissionBase"

TopLevelMission = class(MissionBase)

function TopLevelMission:create(type, index, special)
	local mission = TopLevelMission.new()
	mission:init(type, index, special)
	return mission
end

function TopLevelMission:init(type, index, special)
	MissionBase.init(self, type, index, special)
	if self.index == 1 then
		self.meta.priority = 10000
	end
end

function TopLevelMission:isSupport(runningTasks)
	if not self.meta then return false end

	if self.index ~= 1 then
		return false
	end

	if not self:checkSpecial() or
		not self:checkWeeklyAppear() or
		not self:checkDailyAppear() or
		not self:checkUserTopLevel() then
		return false
	end

	local user = UserManager:getInstance():getUserRef()
	if user:getTopLevelId() == MetaManager:getInstance():getMaxNormalLevelByLevelArea() then
		local score = UserManager:getInstance():getUserScore(user:getTopLevelId())
		if score and score.star >= 1 then
			return false
		end
	end

	self.legal = MetaManager:getInstance():getMissionIdMetaByType(self.type)

	return true
end

function TopLevelMission:createMission()
	local mission = MissionBase.createMission(self)
	mission.progress = tostring(MetaManager:getInstance():getMaxNormalLevelByLevelArea())
	return mission
end