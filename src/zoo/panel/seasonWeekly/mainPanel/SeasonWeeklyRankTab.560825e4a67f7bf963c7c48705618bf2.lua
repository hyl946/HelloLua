local TabBtn = class()
function TabBtn:ctor( selectedUI, normalUI )
	self.selectedUI = selectedUI
	self.normalUI = normalUI
end

function TabBtn:select(bSelect)
	if self.selectedUI and (not self.selectedUI.isDisposed) then
		self.selectedUI:setVisible(bSelect)
	end
	if self.normalUI and (not self.normalUI.isDisposed) then
		self.normalUI:setVisible(not bSelect)
	end
end

local SeasonWeeklyRankTab = class(EventDispatcher)
SeasonWeeklyRankTab.STATE = {
	kLeft = 1,
	kRight = 2
}

SeasonWeeklyRankTab.EVENT = {
	kTurnLeft = 'kTurnLeft',	
	kTurnRight = 'kTurnRight',	
}

function SeasonWeeklyRankTab:ctor( ui )
	self.ui = ui

	self.tabSelected = self.ui:getChildByName('tabSelected')
	self.tabNormal = self.ui:getChildByName('tabNormal')

	self.btnLeft = TabBtn.new(
		self.tabSelected:getChildByName('tabLeft'), 
		self.tabNormal:getChildByName('tabLeft')
	)

	self.btnRight = TabBtn.new(
		self.tabSelected:getChildByName('tabRight'), 
		self.tabNormal:getChildByName('tabRight')
	)

	self:setState(SeasonWeeklyRankTab.STATE.kLeft)


	self.inputLeft = self.tabNormal:getChildByName('tabLeft')
	self.inputRight = self.tabNormal:getChildByName('tabRight')

	self.inputLeft:setTouchEnabled(true)
	self.inputLeft:ad(DisplayEvents.kTouchTap, function ( ... )
		self:setState(SeasonWeeklyRankTab.STATE.kLeft)
	end)

	self.inputRight:setTouchEnabled(true)
	self.inputRight:ad(DisplayEvents.kTouchTap, function ( ... )
		self:setState(SeasonWeeklyRankTab.STATE.kRight)
	end)
end

function SeasonWeeklyRankTab:setState( newState )
	if self.curState ~= newState then
		self.curState = newState

		if self.curState == SeasonWeeklyRankTab.STATE.kLeft then
			self.btnLeft:select(true)
			self.btnRight:select(false)
			self:dispatchEvent(Event.new(SeasonWeeklyRankTab.EVENT.kTurnLeft))
		elseif self.curState == SeasonWeeklyRankTab.STATE.kRight then
			self.btnLeft:select(false)
			self.btnRight:select(true)
			self:dispatchEvent(Event.new(SeasonWeeklyRankTab.EVENT.kTurnRight))
		end
	end
end

return SeasonWeeklyRankTab