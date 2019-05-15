local RankBoardTabBtnBase = require "zoo.quarterlyRankRace.component.RankBoardTabBtnBase"

RankBoardTabBtnFriend = class(RankBoardTabBtnBase)

function RankBoardTabBtnFriend:init(ui)
	RankBoardTabBtnBase.init(self, ui)

	local btnLabel = "好友排名"
	local labelSelect = BitmapText:create(btnLabel, 'fnt/newzhousai_rank5.fnt')
    labelSelect:setAnchorPoint(ccp(0.5, 0.5))
    self.selectUI:addChild(labelSelect)
    labelSelect:setPosition(ccp(86, -31))

    local labelNormal = BitmapText:create(btnLabel, 'fnt/newzhousai_rank4.fnt')
    labelNormal:setAnchorPoint(ccp(0.5, 0.5))
    self.normalUI:addChild(labelNormal)
    labelNormal:setPosition(ccp(85, -30))
end

function RankBoardTabBtnFriend:create(ui)
	local btn = RankBoardTabBtnFriend.new()
	btn:init(ui)
	return btn
end

return RankBoardTabBtnFriend