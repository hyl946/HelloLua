SalesButton = class(GroupButtonBase)

function SalesButton:ctor()
	
end

function SalesButton:buildUI()
	GroupButtonBase.buildUI(self)

	local label1 = self.groupNode:getChildByName("label1")
	local labelSize1 = self.groupNode:getChildByName("labelSize1")
	local size = labelSize1:getContentSize() 
	local position = labelSize1:getPosition()
	local scaleX = labelSize1:getScaleX()
	local scaleY = labelSize1:getScaleY()
	self.labelRect1 = {x=position.x, y=position.y, width=size.width*scaleX, height=size.height*scaleY}
	self.label1 = label1
	labelSize1:removeFromParentAndCleanup(true)

	self.oriPrice = self.groupNode:getChildByName("oriLabel")
end

function SalesButton:setOtherString(str)
	if self.label1 and self.label1.refCocosObj then
		self.label1:setText(str)
		InterfaceBuilder:centerInterfaceInbox(self.label1, self.labelRect1)
	end
end

function SalesButton:setOriPrice(price)
	self.oriPrice:setString(price)
end

function SalesButton:create(groupNode)
	local button = SalesButton.new(groupNode)
	button:buildUI()
	return button
end