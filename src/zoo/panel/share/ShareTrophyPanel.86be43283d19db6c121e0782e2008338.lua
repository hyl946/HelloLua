require 'zoo.panel.share.ArmatureShareBasePanel'
ShareTrophyPanel = class(ArmatureShareBasePanel)

local function getFirstAndLastLevel(currentLevel)
	local firstLevel = 1
	local lastLevel = 15
	if currentLevel then 
		if currentLevel%15 == 0 then
			firstLevel = currentLevel - 15
			lastLevel = currentLevel
		else
			firstLevel = currentLevel - (currentLevel%15)
			lastLevel = firstLevel + 15
		end
		firstLevel = firstLevel + 1
	end
	return firstLevel, lastLevel
end

function ShareTrophyPanel:getShareTitleName()
	local level = self.achiManager:get(AchiDataType.kLevelId)
	local firstLevel, lastLevel = getFirstAndLastLevel(level)
	local isNewBranchUnlock = self.achiManager:get(AchiDataType.kUnlockHideLevel)

	if isNewBranchUnlock then
		self.shareTitleKey = self.config.shareTitle1
	end

	return Localization:getInstance():getText(self.shareTitleKey,{num = firstLevel, num1= lastLevel})
end

function ShareTrophyPanel:create(shareId)
	local panel = ShareTrophyPanel.new()
	panel:loadRequiredResource("ui/NewSharePanelEx.json")
	panel.shareId = shareId
	panel:init('skeleton/share_' .. shareId .. '_animation', 
			   'share_' .. shareId .. '_animation', 
			   'share_' .. shareId .. '_animation', 
			   'share_' .. shareId .. '_animation/mainanimation')
	return panel
end

function ShareTrophyPanel:initShareTitle(titleName)
    local slot = self.node:getSlot('title')
    local text = BitmapText:create(titleName, 'fnt/share.fnt', 0)
    text:setAnchorPoint(ccp(0.5, 0.5))
    local sprite = Sprite:createEmpty()
    sprite:addChild(text)
    slot:setDisplayImage(sprite.refCocosObj)
end