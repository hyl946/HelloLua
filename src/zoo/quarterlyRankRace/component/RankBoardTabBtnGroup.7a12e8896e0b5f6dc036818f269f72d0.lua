local RankBoardTabBtnBase = require "zoo.quarterlyRankRace.component.RankBoardTabBtnBase"

RankBoardTabBtnGroup = class(RankBoardTabBtnBase)

function RankBoardTabBtnGroup:init(ui)
	RankBoardTabBtnBase.init(self, ui)

	self.flagGroupUI = self.ui:getChildByName("flagGroup")
	for i=2,4 do
		self["flagGroup"..i] = self.flagGroupUI:getChildByName(i.."")
		if self["flagGroup"..i] then 
			self["flagGroup"..i]:setVisible(false)
		end
	end

    local dan = RankRaceMgr.getInstance():getData():getSafeDan()
    local danName = localize('rank.race.dan.panel.title.' .. dan)
    local danSuffix = "组排名"

    local labelSelect = BitmapText:create(danName, 'fnt/newzhousai_rank3.fnt')
    labelSelect:setAnchorPoint(ccp(1, 0.5))
    self.selectUI:addChild(labelSelect)

   	labelSelectSuffix = BitmapText:create(danSuffix, 'fnt/newzhousai_rank5.fnt')
   	labelSelectSuffix:setAnchorPoint(ccp(0, 0.5))
    self.selectUI:addChild(labelSelectSuffix)

    if dan == 10 then 
   		labelSelect:setPosition(ccp(102, -31))
   		labelSelectSuffix:setPosition(ccp(94, -31))
   	else
   		labelSelect:setPosition(ccp(127, -31))
   		labelSelectSuffix:setPosition(ccp(119, -31))
   	end

    local labelNormal = BitmapText:create(danName..danSuffix, 'fnt/newzhousai_rank4.fnt')
    labelNormal:setAnchorPoint(ccp(0.5, 0.5))
    self.normalUI:addChild(labelNormal)
    labelNormal:setPosition(ccp(108, -30))
end

function RankBoardTabBtnGroup:updateFlagShow()
	local rankIndexGroup = RankRaceMgr.getInstance().rankIndexGroup
	if rankIndexGroup and rankIndexGroup > 0 then 
		local danGroup = RankRaceMgr.getInstance():getDanGroup()
		for i=2,4 do
			if danGroup == i and self["flagGroup"..i] then 
				self["flagGroup"..i]:setVisible(true)
				break
			end
		end
	end
end

function RankBoardTabBtnGroup:create(ui)
	local btn = RankBoardTabBtnGroup.new()
	btn:init(ui)
	return btn
end

return RankBoardTabBtnGroup
