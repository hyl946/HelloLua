require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"

TempActivityButton = class(IconButtonBase)

function TempActivityButton:create(...)
	local newCDKeyButton = TempActivityButton.new()
	newCDKeyButton:init()
	return newCDKeyButton
end

function TempActivityButton:init(...)
	self.ui	= ResourceManager:sharedInstance():buildGroup("activityButtonIcon")
	local text1 = self.ui:getChildByName("text1")
	text1:setVisible(false)
	local text2 = self.ui:getChildByName("text2")
	text2:setVisible(false)
	local rewardIcon = self.ui:getChildByName("rewardIcon")
	rewardIcon:setVisible(false)
	local msgNum = self.ui:getChildByName("msgNum")
	msgNum:setVisible(false)
	local msgBg = self.ui:getChildByName("msgBg")
	msgBg:setVisible(false)
	local guang = self.ui:getChildByName("guang")
	guang:setVisible(false)
	
	IconButtonBase.init(self, self.ui)

end




