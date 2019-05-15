local WDJRemoveButton = class(IconButtonBase)

function WDJRemoveButton:ctor()
    self.idPre = "WDJRemoveButton"
    self.playTipPriority = 30

end

function WDJRemoveButton:playHasNotificationAnim()
end

function WDJRemoveButton:playOnlyTipAnim()
end

function WDJRemoveButton:stopHasNotificationAnim()
end

function WDJRemoveButton:updateIconTipShow(tipState)
end

function WDJRemoveButton:init(inHomeScene)

	local ver = tonumber(string.split(_G.bundleVersion, ".")[2])
	if ver >= 47 then
		self:initShowHideConfig(ManagedIconBtns.WDJ_REMOVE)
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
			local WDJRemoveManager = require 'zoo.panel.wdjremove.WDJRemoveManager'
			WDJRemoveManager:popout(1, true)
		end))
	end)

    self:playOnlyIconAnim()
end

function WDJRemoveButton:refresh( ... )
	
end

function WDJRemoveButton:create(inHomeScene)
	local newWDJRemoveButton = WDJRemoveButton.new()
	newWDJRemoveButton:init(inHomeScene)
	return newWDJRemoveButton
end


function WDJRemoveButton:dispose( ... )
	IconButtonBase.dispose(self)
	if self.panelConfigFile then
		InterfaceBuilder:unloadAsset(self.panelConfigFile)
	end
end


return WDJRemoveButton