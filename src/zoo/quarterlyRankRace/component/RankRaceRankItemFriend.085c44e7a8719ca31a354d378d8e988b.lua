local RankRaceRankItemBase = require "zoo.quarterlyRankRace.component.RankRaceRankItemBase"
local CardPanelFriend = require "zoo.quarterlyRankRace.view.CardPanelFriend"
local RankRaceRankItemFriend = class(RankRaceRankItemBase)

function RankRaceRankItemFriend:init(itemData)
	RankRaceRankItemBase.init(self, itemData)

	local lvFlagUI = self.ui:getChildByName("lvFlag")
	local lvFlagLabel = lvFlagUI:getChildByName("label")
	local lvFlagBg = lvFlagUI:getChildByName("bg")
	local dan = math.clamp(itemData.data.extra or 1, 1, 10)
	for i=1,10 do
		local label = lvFlagLabel:getChildByName(i.."")
		label:setVisible(i == dan)
	end
	local bgIndex = math.floor((dan - 1) / 3) + 1
	for i=1,4 do
		local bg = lvFlagBg:getChildByName(i.."")
		bg:setVisible(i == bgIndex)
	end
end

function RankRaceRankItemFriend:showCardPanel()
    local data = self.itemData.data
	local uid = tostring(data.uid)

	local function showPanel(cardInfo)
		if self.isDisposed then return end
		if cardInfo.isSelf then 
			cardInfo.rankGroup = RankRaceMgr.getInstance():getRankTatalNum(1) or 100
	    	cardInfo.rank = RankRaceMgr.getInstance().rankIndexGroup or cardInfo.rankGroup
	    end
		local panel = CardPanelFriend:create(cardInfo)
	    panel:popout()
	end

	local function onQuerySuccess()
		if self.isDisposed then return end
		local cardInfo = RankRaceMgr.getInstance():getRankCardInfo(2, uid)
		showPanel(cardInfo)
	end

	local function onQueryFail(evt)
		if self.isDisposed then return end
		local errCode = evt.data
		if errCode then
			CommonTip:showTip(localize('error.tip.' .. errCode))
		end
	end
	local cardInfo = RankRaceMgr.getInstance():getRankCardInfo(2, uid)
	if cardInfo then
		showPanel(cardInfo)
	else
		RankRaceMgr.getInstance():queryRankCardInfo(2, uid, onQuerySuccess, onQueryFail)
	end
end

function RankRaceRankItemFriend:getItemGroupName()
	return "2018_s1_rank_race/rank_item/rankItemRenderFriend"
end

function RankRaceRankItemFriend:create(itemData)
	local item = RankRaceRankItemFriend.new()
	item:init(itemData)
	return item
end

return RankRaceRankItemFriend