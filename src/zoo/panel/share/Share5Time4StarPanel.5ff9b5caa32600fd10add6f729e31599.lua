require 'zoo.panel.share.ShareBasePanel'

Share5Time4StarPanel = class(ShareBasePanel)

function Share5Time4StarPanel:ctor()

end


function Share5Time4StarPanel:init()
	--初始化文案内容
	ShareBasePanel.init(self)

	local function skeletonAnimation()
		self:runSkeletonAnimation()
	end

	self.ui:runAction(CCCallFunc:create(skeletonAnimation))

	self:runLightAction()
end

function Share5Time4StarPanel:runSkeletonAnimation()
	FrameLoader:loadArmature('skeleton/share_70_animation')
    self.animNode = ArmatureNode:create("Share5Time4Star")
    self.animNode:setAnchorPoint(ccp(0.5, 0.5))
    self.animNode:setPosition(ccp(40, -60))

    local function finishCallback()
    	self.animNode:rma()
        self.animNode:playByIndex(1, 0)
    end
    self.animNode:addEventListener(ArmatureEvents.COMPLETE, finishCallback)

    self.animNode:playByIndex(0, 1)
    self.ui:addChildAt(self.animNode, 3)
end

function Share5Time4StarPanel:runLightAction()
	local light = self.ui:getChildByName("light")
	light:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
	light:setPosition(ccp(250, -300))
	light:setScale(0)
	local light_arr = CCArray:create()
	light_arr:addObject(CCFadeIn:create(0.9))
	light_arr:addObject(CCScaleTo:create(0.4, 2.0))
	light:runAction(CCRepeatForever:create(CCRotateBy:create(0.5, 40)))
	light:runAction(CCSequence:create(light_arr))
end

function Share5Time4StarPanel:dispose()
	ShareBasePanel.dispose(self)
	-- ArmatureFactory:remove("skeleton", "share_70_animation")
    FrameLoader:unloadArmature("skeleton/share_70_animation", true)
end

function Share5Time4StarPanel:getShareTitleName()
	local count = self.achi.reachCount or 0
	return Localization:getInstance():getText(self.shareTitleKey,{num = count})
end

function Share5Time4StarPanel:create(shareId)
	local panel = Share5Time4StarPanel.new()
	panel:loadRequiredResource("ui/NewSharePanelEx.json")
	panel.ui = panel:buildInterfaceGroup('Share5Time4StarPanel')
	panel.shareId = shareId
	panel:init()
	return panel
end