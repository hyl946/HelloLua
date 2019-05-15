local CardPanelBase = require "zoo.quarterlyRankRace.view.CardPanelBase"

local CardPanelGroup = class(CardPanelBase)

function CardPanelGroup:ctor()
	
end

function CardPanelGroup:init(data)
	self.ui	= self:buildInterfaceGroup("rank_race_card/CardPanelGroup")
	self.data = data
	CardPanelBase.init(self, self.ui)
end

function CardPanelGroup:create(data)
	local panel = CardPanelGroup.new()
	panel:loadRequiredResource("ui/RankRace/RankRaceCard.json")
	panel:init(data)
	return panel
end

return CardPanelGroup