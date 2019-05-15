require "zoo.mission.missionCreator.MissionBase"

EnterWeeklyRaceMission = class(MissionBase)

function EnterWeeklyRaceMission:create(type, index, special)
	local mission = EnterWeeklyRaceMission.new()
	mission:init(type, index, special)
	return mission
end

function EnterWeeklyRaceMission:isSupport(runningTasks)
	local baseCheck = MissionBase.isSupport(self, runningTasks)
	if not self:filterRunningMission(runningTasks) then
		return false
	end
	local now = Localhost:time()
	local enterCheck = SeasonWeeklyRaceManager:getInstance():getUpdateTime()
	if enterCheck and now - enterCheck > 172800000 then -- 两天
		self.meta.priority = 8000
	end
	return baseCheck
end