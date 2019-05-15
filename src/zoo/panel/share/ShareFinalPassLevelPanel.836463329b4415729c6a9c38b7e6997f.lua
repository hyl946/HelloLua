require 'zoo.panel.share.ArmatureShareBasePanel'
ShareFinalPassLevelPanel = class(ArmatureShareBasePanel)

function ShareFinalPassLevelPanel:ctor()

end

function ShareFinalPassLevelPanel:init(armatureSource, skeletonName, textureName, armatureName, playPaperGroup)
	ArmatureShareBasePanel.init(self, armatureSource, skeletonName, textureName, armatureName, playPaperGroup)

	self.shareMessage = Localization:getInstance():getText("show_off_wx_share_70")

end

function ShareFinalPassLevelPanel:getShareTitleName()
	return Localization:getInstance():getText(self.shareTitleKey)
end

function ShareFinalPassLevelPanel:dispose()
	ArmatureShareBasePanel.dispose(self)

end

function ShareFinalPassLevelPanel:create(shareId)
	local panel = ShareFinalPassLevelPanel.new()
	panel:loadRequiredResource("ui/NewSharePanelEx.json")
	-- panel.ui = panel:buildInterfaceGroup('ShareFinalPassLevelPanel')
	panel.shareId = shareId
	panel:init('skeleton/share_160_animation', 'share_160_animation', 'share_160_animation', 'ShareNTimePass', false)
	return panel
end