require "zoo.mission.missionCreator.MissionBase"
require "zoo.panel.FruitTreePanel"

PickFruitMission = class(MissionBase)

function PickFruitMission:create(type, index, special)
	local mission = PickFruitMission.new()
	mission:init(type, index, special)
	return mission
end

function PickFruitMission:isSupport(runningTasks)
	if not MissionBase.isSupport(self, runningTasks) then
		return false
	end
	
	local model = FruitTreePanelModel:sharedInstance()
	local temp = {}
	for i,v in ipairs(self.legal) do
		if type(v.condition[1]) == "table" and type((v.condition[1])[1]) == "number" and
			(model:getPickCount() - model:getPicked()) >= (v.condition[1])[1] then
			table.insert(temp, v)
		end
	end
	self.legal = temp
	return #self.legal > 0
end