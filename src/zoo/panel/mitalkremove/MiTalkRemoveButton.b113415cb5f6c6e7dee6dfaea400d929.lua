local MiTalkRemoveButton = class(IconButtonBase)

function MiTalkRemoveButton:ctor()
    self.idPre = "MiTalkRemoveButton"
    self.playTipPriority = 30

end

function MiTalkRemoveButton:playHasNotificationAnim()
end

function MiTalkRemoveButton:playOnlyTipAnim()
end

function MiTalkRemoveButton:stopHasNotificationAnim()
end

function MiTalkRemoveButton:updateIconTipShow(tipState)
end

function MiTalkRemoveButton:init(inHomeScene)

	local ver = tonumber(string.split(_G.bundleVersion, ".")[2])
	if ver >= 47 then
		self:initShowHideConfig(ManagedIconBtns.MITALK_REMOVE)
	end

	self.tipState = IconTipState.kNormal
	self.id = self.idPre .. self.tipState

	self.inHomeScene = inHomeScene

	self.panelConfigFile = 'ui/wdj_remove.json'
	self.builder = InterfaceBuilder:createWithContentsOfFile(self.panelConfigFile)

	self.ui = self.builder:buildGroup("wdj_remove/WDJRemoveButton")
	IconButtonBase.init(self, self.ui)


	self.wrapper:setTouchEnabled(true)
	self.wrapper:setButtonMode(true)

	self:setTipPosition(IconButtonBasePos.RIGHT)

	self.wrapper:addEventListener(DisplayEvents.kTouchTap, function()
		if PopoutManager:sharedInstance():haveWindowOnScreen() then return end
		self:runAction(CCCallFunc:create(function()
			local MiTalkRemoveManager = require 'zoo.panel.mitalkremove.MiTalkRemoveManager'
			MiTalkRemoveManager:popout(1, true)
		end))
	end)

    self:playOnlyIconAnim()
end

function MiTalkRemoveButton:refresh( ... )
	
end

function MiTalkRemoveButton:create(inHomeScene)
	local newMiTalkRemoveButton = MiTalkRemoveButton.new()
	newMiTalkRemoveButton:init(inHomeScene)
	return newMiTalkRemoveButton
end


function MiTalkRemoveButton:dispose( ... )
	IconButtonBase.dispose(self)
	if self.panelConfigFile then
		InterfaceBuilder:unloadAsset(self.panelConfigFile)
	end
end


return MiTalkRemoveButton