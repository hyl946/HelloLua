require "zoo.mission.missionCreator.MissionBase"

GainStarMission = class(MissionBase)

function GainStarMission:create(type, index, special)
	local mission = GainStarMission.new()
	mission:init(type, index, special)
	return mission
end

function GainStarMission:isSupport(runningTasks)
	if not MissionBase.isSupport(self, runningTasks) then
		return false
	end
	local hiddenStar = MetaModel:sharedInstance():getFullStarInHiddenRegion()
	local maxMainLevel = MetaManager:getInstance():getMaxNormalLevelByLevelArea()
	local userStar = UserManager:getInstance():getUserRef():getStar()
	local mainStar = 0
	for i = 1, maxMainLevel do
		local scores = MetaModel:sharedInstance():getLevelTargetScores(i)
		if type(scores) then mainStar = mainStar + #scores end
	end

	local temp = {}
	for i,v in ipairs(self.legal) do
		if type(v.condition[1]) == "table" and type((v.condition[1])[1]) == "number" and
			hiddenStar + mainStar - userStar >= (v.condition[1])[1] then
			table.insert(temp, v)
		end
	end
	self.legal = temp
	return #self.legal > 0
end