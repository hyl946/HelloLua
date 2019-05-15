local CompStarNum = class()

function CompStarNum:create(parentPanel, ui, totalStar, needStar)
	local comp = CompStarNum.new()
	comp:init(parentPanel, ui, totalStar, needStar)
	return comp
end

function CompStarNum:init(parentPanel, ui, totalStar, needStar)
	self.ui = ui
	self.parentPanel = parentPanel
	self.totalStar = totalStar
	self.needStar = needStar
	self.starNumLabel = BitmapText:create('', "fnt/unlock.fnt")
    self.starNumLabel:setAnchorPoint(ccp(0.5, 0.5))
    self.starNumLabel:setPositionXY(190, -41)
	self.ui:addChild(self.starNumLabel)
	self.starNumProgressBar		= HomeSceneItemProgressBar:create(self.ui:getChildByName("starNumProgressBar"), self.totalStar, needStar)
	self.starBtn = GroupButtonBase:create(self.ui:getChildByName('btn_star'))
	self.starBtn:setString(Localization:getInstance():getText('more.star.btn.txt'))
	self.starBtn:ad(DisplayEvents.kTouchTap, function () self:onMoreStarBtnTapped() end)

	if UnlockLevelAreaLogic:isNew() then
		self.starNumLabel:setText('当前区域 ' .. self.totalStar .. "/" .. self.needStar)
		local width = self.starNumLabel:getContentSize().width
		self.starNumLabel:setPositionXY(95 + 21 + width/2, -41)
	else
		self.starNumLabel:setText(self.totalStar .. "/" .. self.needStar)
	end

end

function CompStarNum:onMoreStarBtnTapped()
	self.parentPanel:onCloseBtnTapped()
	local mode = nil
	if UnlockLevelAreaLogic:isNew() then
		mode = NewMoreStarPanel.Mode.kOnlyTopAreaLevels
	end
	local panel = NewMoreStarPanel:create(mode)
	panel:popout()
end

return CompStarNum