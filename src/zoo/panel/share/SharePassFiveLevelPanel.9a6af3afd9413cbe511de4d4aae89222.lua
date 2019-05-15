require 'zoo.panel.share.ArmatureShareBasePanel'
SharePassFiveLevelPanel = class(ArmatureShareBasePanel)

function SharePassFiveLevelPanel:ctor()
	
end

function SharePassFiveLevelPanel:init(armatureSource, skeletonName, textureName, armatureName, playPaperGroup)
	--初始化文案内容
	ArmatureShareBasePanel.init(self, armatureSource, skeletonName, textureName, armatureName, playPaperGroup)

	self.shareMessage = Localization:getInstance():getText("show_off_wx_share_60")

end

function SharePassFiveLevelPanel:getShareTitleName()
	return Localization:getInstance():getText(self.shareTitleKey)
end

function SharePassFiveLevelPanel:create(shareId)
	local panel = SharePassFiveLevelPanel.new()
	panel:loadRequiredResource("ui/NewSharePanelEx.json")
	-- panel.ui = panel:buildInterfaceGroup('SharePassFiveLevelPanel')
	panel.shareId = shareId
	panel:init('skeleton/share_150_animation', 'share_150_animation', 'share_150_animation', 'ShareContinuePassLevel', false)
	return panel
end

