--实名制homescene图标
require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"
local RealNameButton = class(IconButtonBase)

function RealNameButton:ctor()
    self.idPre = "RealNameButton"
    self.playTipPriority = 30
end

function RealNameButton:playHasNotificationAnim()
end

function RealNameButton:playOnlyTipAnim( ... )
	-- body
end

function RealNameButton:stopHasNotificationAnim()
end

function RealNameButton:updateIconTipShow(tipState)
end

function RealNameButton:init(inHomeScene)
	self:initShowHideConfig(ManagedIconBtns.REAL_NAME)

	self.tipState = IconTipState.kNormal
	self.id = self.idPre .. self.tipState

	self.inHomeScene = inHomeScene
	self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_authentication')

	IconButtonBase.init(self, self.ui)

	self:setTipPosition(IconButtonBasePos.RIGHT)

	self.wrapper:addEventListener(DisplayEvents.kTouchTap, function()
		if PopoutManager:sharedInstance():haveWindowOnScreen() then return end
		self:runAction(CCCallFunc:create(function( ... )
			RealNameManager:popoutEntryPanel(RealNameEntryType.homeScene)
		end))
	end)

	if self.inHomeScene then
		self.tipState = IconTipState.kReward
		self.id = self.idPre .. self.tipState

		self:playHasNotificationAnim()
	end
end

function RealNameButton:create(inHomeScene)
	local button = RealNameButton.new()
	button:init(inHomeScene)
	return button
end


function RealNameButton:dispose( ... )
	IconButtonBase.dispose(self)
	if self.panelConfigFile then
		InterfaceBuilder:unloadAsset(self.panelConfigFile)
	end
end

return RealNameButton