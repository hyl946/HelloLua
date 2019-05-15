require 'zoo.panel.share.ArmatureShareBasePanel'

ShareFirstInFriendsPanel = class(ArmatureShareBasePanel)

function ShareFirstInFriendsPanel:ctor()
	
end

function ShareFirstInFriendsPanel:init(armatureSource, skeletonName, textureName, armatureName, playPaperGroup)

	ArmatureShareBasePanel.init(self, armatureSource, skeletonName, textureName, armatureName, playPaperGroup)

	self.level = self.achiManager:get(AchiDataType.kLevelId)

end

function ShareFirstInFriendsPanel:getShareLinkTitleMessage( ... )	
	local title = Localization:getInstance():getText("show_new_title30")
	local levelId = tonumber(self.level) or 0
	local message = ""
	if LevelType:isHideLevel(levelId) then
		message = Localization:getInstance():getText("show_new_text30_1",{num = levelId - LevelConstans.HIDE_LEVEL_ID_START})
	else
		message = Localization:getInstance():getText("show_new_text30",{num = self.level})
	end

	return title,message
end

function ShareFirstInFriendsPanel:getShareTitleName()
	local level = self.achiManager:get(AchiDataType.kLevelId)
	local levelText = tostring(LevelMapManager.getInstance():getLevelDisplayName(level))
	return Localization:getInstance():getText(self.shareTitleKey,{num = levelText})
end



function ShareFirstInFriendsPanel:create(shareId)
	local panel = ShareFirstInFriendsPanel.new()
	panel:loadRequiredResource("ui/NewSharePanelEx.json")
	-- panel.ui = panel:buildInterfaceGroup('ArmatureAnimSharePanel')
	panel.shareId = shareId
	panel:init('skeleton/share_30_animation', 'share_30_animation', 'share_30_animation', 'ShareFirstRankFriend', true)
	return panel
end

