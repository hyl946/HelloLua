require 'zoo.panel.share.ArmatureShareBasePanel'
ShareLastStepPanel = class(ArmatureShareBasePanel)

function ShareLastStepPanel:create(shareId)
	local panel = ShareLastStepPanel.new()
	panel:loadRequiredResource("ui/NewSharePanelEx.json")
	panel.shareId = shareId
	panel:init('skeleton/share_' .. shareId .. '_animation', 
			   'share_' .. shareId .. '_animation', 
			   'share_' .. shareId .. '_animation', 
			   'share_' .. shareId .. '_animation/LastStepPass')
	return panel
end

function ShareLastStepPanel:initShareTitle(titleName)
    local slot = self.node:getSlot('title')
    local text = BitmapText:create(titleName, 'fnt/share.fnt', 0)
    text:setAnchorPoint(ccp(0.5, 0.5))
    local sprite = Sprite:createEmpty()
    sprite:addChild(text)
    slot:setDisplayImage(sprite.refCocosObj)
end

function ShareLastStepPanel:getShareTitleName()
	return Localization:getInstance():getText(self.shareTitleKey)
end
