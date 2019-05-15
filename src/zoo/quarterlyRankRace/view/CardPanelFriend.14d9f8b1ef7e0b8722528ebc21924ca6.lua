local CardPanelBase = require "zoo.quarterlyRankRace.view.CardPanelBase"
local UIHelper = require 'zoo.panel.UIHelper'
local CardPanelFriend = class(CardPanelBase)

function CardPanelFriend:ctor()
end

function CardPanelFriend:init(data)
	self.ui	= self:buildInterfaceGroup("rank_race_card/CardPanelFriend")
	self.data = data
	CardPanelBase.init(self, self.ui)

	UIHelper:addBitmapTextByIcon(self.partBottomUI:getChildByName("iconGroup"), self.data.rank.."/"..self.data.rankGroup, 'fnt/addfriend4.fnt', 'A14A0E', 1.2, {x = 6, y = -2})
end

function CardPanelFriend:create(data)
	local panel = CardPanelFriend.new()
	panel:loadRequiredResource("ui/RankRace/RankRaceCard.json")
	panel:init(data)
	return panel
end

return CardPanelFriend