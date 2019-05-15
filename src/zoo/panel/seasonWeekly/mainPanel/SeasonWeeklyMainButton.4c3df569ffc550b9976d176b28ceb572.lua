SeasonWeeklyMainButton = class(GroupButtonBase)

function SeasonWeeklyMainButton:ctor(groupNode)
	self.groupNode = groupNode
end
function SeasonWeeklyMainButton:create(buttonGroup)
	local button = SeasonWeeklyMainButton.new(buttonGroup)
	button:buildUI()
	return button
end

function SeasonWeeklyMainButton:buildUI()
	GroupButtonBase.buildUI(self)

	self.numTip = getRedNumTip()
	self.numTip:setPositionXY(110, 35)
    self.numTip:setScale(1.3)
	self.groupNode:addChild(self.numTip)
	self.boundsHighLight = self.groupNode:getChildByName("shadow")
end

function SeasonWeeklyMainButton:setNumberVisible(isVisible)
	self.numTip:setVisible(isVisible)
end
function SeasonWeeklyMainButton:setNumber( n )
	self.numTip:setNum(n)
end
function SeasonWeeklyMainButton:setShadowVisible(isVisible)
	self.boundsHighLight:setVisible(isVisible)
end