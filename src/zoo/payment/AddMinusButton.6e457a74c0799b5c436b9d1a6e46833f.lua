
AddMinusButton = class(GroupButtonBase)
function AddMinusButton:create(group)
	local button = AddMinusButton.new(group)
	button:buildUI()
	return button
end
local kButtonType = {
	kAdd = 0,
	kMinus = 1,
}
function AddMinusButton:setButtonType(buttonType)
	self.add = self.groupNode:getChildByName("add")
	self.addd = self.groupNode:getChildByName("addd")
	self.minus = self.groupNode:getChildByName("minus")
	self.minusd = self.groupNode:getChildByName("minusd")
	self.buttonType = buttonType
	if buttonType == kButtonType.kAdd then
		self.minus:setVisible(false)
		self.minusd:setVisible(false)
		self.addd:setVisible(false)
	elseif buttonType == kButtonType.kMinus then
		self.add:setVisible(false)
		self.addd:setVisible(false)
		self.minusd:setVisible(false)
	end
end
function AddMinusButton:setEnabled(isEnabled)
	GroupButtonBase.setEnabled(self, isEnabled)
	if self.buttonType == kButtonType.kAdd then
		self.add:setVisible(isEnabled)
		self.addd:setVisible(not isEnabled)
	elseif self.buttonType == kButtonType.kMinus then
		self.minus:setVisible(isEnabled)
		self.minusd:setVisible(not isEnabled)
	end
end
