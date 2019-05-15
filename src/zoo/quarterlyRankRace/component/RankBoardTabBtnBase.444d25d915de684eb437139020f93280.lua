
local RankBoardTabBtnBase = class()

function RankBoardTabBtnBase:ctor()
end

function RankBoardTabBtnBase:init(ui)
	self.ui = ui
	self.normalUI = self.ui:getChildByName("normal")
	self.selectUI = self.ui:getChildByName("select")
end

function RankBoardTabBtnBase:ad(eventName, listener, context)
	self.ui:addEventListener(eventName, listener, context)
end

function RankBoardTabBtnBase:setTouchEnabled(isEnable)
	self.ui:setTouchEnabled(isEnable)
end

function RankBoardTabBtnBase:setButtonMode(isButtonMode)
	self.ui:setButtonMode(isEnable)
end

function RankBoardTabBtnBase:setSelect(isSelected)
	self.normalUI:setVisible(not isSelected)
	self.selectUI:setVisible(isSelected)
end

function RankBoardTabBtnBase:setTabBtnIndex(tabIndex)
	self.tabIndex = tabIndex
end

function RankBoardTabBtnBase:getTabBtnIndex()
	return self.tabIndex
end

function RankBoardTabBtnBase:updateFlagShow()
end

return RankBoardTabBtnBase