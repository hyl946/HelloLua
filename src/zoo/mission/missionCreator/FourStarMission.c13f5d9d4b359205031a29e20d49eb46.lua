require "zoo.mission.missionCreator.MissionBase"

FourStarMission = class(MissionBase)

function FourStarMission:create(type, index, special)
	local mission = FourStarMission.new()
	mission:init(type, index, special)
	return mission
end

function FourStarMission:isSupport(runningTasks)
	if not MissionBase.isSupport(self, runningTasks) then
		return false
	end
	local runningTypes = MissionCreator:getInstance():getRunningTypes()
	for i,v in ipairs(runningTypes) do
		if v == MissionTypes.kLogin then
			return false
		end
	end
	local user = UserManager:getInstance():getUserRef()
	local legal = {}
	for i,v in ipairs(self.legal) do
		if type(v.condition[1]) == "table" and type((v.condition[1])[1]) == "number" and
			type((v.condition[1])[2]) == "number" and (v.condition[1])[1] <= user:getTopLevelId() then
			local hasJumpedLevel = UserManager.getInstance():hasPassedByTrick( (v.condition[1])[1] )
			if hasJumpedLevel then return false end
			local score = UserManager:getInstance():getUserScore((v.condition[1])[1])
			if score and score.star < (v.condition[1])[2] then
				table.insert(legal, v)
			end
		end
	end
	self.legal = legal
	return #legal > 0
end