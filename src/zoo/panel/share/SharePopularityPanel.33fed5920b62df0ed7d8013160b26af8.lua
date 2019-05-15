require 'zoo.panel.share.ShareBasePanel'
SharePopularityPanel = class(ShareBasePanel)

function SharePopularityPanel:ctor()

end

function SharePopularityPanel:init()
	--初始化文案内容
	ShareBasePanel.init(self)

	local function skeletonAnimation()
		self:runSkeletonAnimation()
	end

	self.ui:runAction(CCCallFunc:create(skeletonAnimation))

	self:runLightAction()

end


function SharePopularityPanel:initShareTitle(titleName)
	assert(titleName)
	local shareTitleUI = self.ui:getChildByName("shareTitle")
	self.shareTitle = self:addToLayerColor(shareTitleUI,ccp(0.5,0)) 

	self.shareTitleString = TextField:createWithUIAdjustment(shareTitleUI:getChildByName("shareTitleSize"), shareTitleUI:getChildByName("shareTitle"))
	shareTitleUI:addChild(self.shareTitleString)
	self.shareTitleString:setString(titleName)

	local size = self.shareTitleString:boundingBox().size
	self.shareTitleString:setScale(self.shareTitleString:getScale() * 0.8)
	local newSize = self.shareTitleString:boundingBox().size

	self.shareTitleString:setPositionX(self.shareTitleString:getPositionX() + size.width/2 - newSize.width/2)
end


function SharePopularityPanel:runSkeletonAnimation( ... )
	FrameLoader:loadArmature('skeleton/share_200_animation')
    self.animNode = ArmatureNode:create("share_200/200")
    self.animNode:setAnchorPoint(ccp(0.5, 0.5))
    self.animNode:setPosition(ccp(40, - 60))

	self.animNode:playByIndex(0)
	self.animNode:update(0.001) 
	self.animNode:stop()
	self.animNode:playByIndex(0)

    self.ui:addChildAt(self.animNode, 3)

end

function SharePopularityPanel:runLightAction()
	local light = self.ui:getChildByName("light")
	light:setVisible(false)
end

function SharePopularityPanel:getShareTitleName()
	local achiValue = self.achi:getTargetValue()
	return Localization:getInstance():getText(self.shareTitleKey,{num = achiValue})
end

function SharePopularityPanel:dispose()
	ShareBasePanel.dispose(self)
	-- ArmatureFactory:remove("skeleton", 'share_200_animation')
	FrameLoader:unloadArmature("skeleton/share_200_animation", true)
end

function SharePopularityPanel:create(shareId)
	local panel = SharePopularityPanel.new()
	panel:loadRequiredResource("ui/NewSharePanelEx2.json")
	panel.ui = panel:buildInterfaceGroup('NewSharePanelEx2')
	panel.shareId = shareId
	panel:init()
	return panel
end