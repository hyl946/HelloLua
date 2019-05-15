require "zoo.mission.missionCreator.MissionBase"

RemainStepMission = class(MissionBase)

function RemainStepMission:create(type, index, special)
	local mission = RemainStepMission.new()
	mission:init(type, index, special)
	return mission
end

function RemainStepMission:isSupport(runningTasks)
	if not MissionBase.isSupport(self, runningTasks) then
		return false
	end
	local completed = MissionCreator:getInstance():getPassedMissions()
	local user = UserManager:getInstance():getUserRef()
	local legal = {}
	for i,v in ipairs(self.legal) do
		if type(v.condition[1]) == "table" and type((v.condition[1])[1]) == "number" and
			type((v.condition[1])[2]) == "number" and (v.condition[1])[1] <= user:getTopLevelId() and
			not table.indexOf(completed, v.id) then
			table.insert(legal, v)
		end
	end
	self.legal = legal
	return #legal > 0
end