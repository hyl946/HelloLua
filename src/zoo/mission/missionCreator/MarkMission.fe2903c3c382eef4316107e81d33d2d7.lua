require "zoo.mission.missionCreator.MissionBase"

MarkMission = class(MissionBase)

function MarkMission:create(type, index, special)
	local mission = MarkMission.new()
	mission:init(type, index, special)
	return mission
end

function MarkMission:isSupport(runningTasks)
	if not MissionBase.isSupport(self, runningTasks) then
		return false
	end

	local mark = UserManager:getInstance().mark
	if not mark then return false end
	local now = Localhost:time()
	local dayTime = 86400000
	local dayStart = math.floor((now - mark.createTime) / dayTime) * dayTime + mark.createTime
	if tonumber(dayStart) <= tonumber(mark.markTime) then return false end

	return true
end