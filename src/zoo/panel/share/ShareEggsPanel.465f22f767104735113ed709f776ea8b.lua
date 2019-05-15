require 'zoo.panel.share.ShareBasePanel'

ShareEggsPanel = class(ShareBasePanel)

function ShareEggsPanel:ctor()

end


function ShareEggsPanel:init()
	--初始化文案内容
	ShareBasePanel.init(self)

	local function skeletonAnimation()
		self:runSkeletonAnimation()
	end

	self.ui:runAction(CCCallFunc:create(skeletonAnimation))

	self:runLightAction()
end

function ShareEggsPanel:runLightAction()
	local light = self.ui:getChildByName("light")
	light:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
	light:setPosition(ccp(380, -380))
	light:setScale(0)
	local light_arr = CCArray:create()
	light_arr:addObject(CCFadeIn:create(0.6))
	light_arr:addObject(CCScaleTo:create(0.3, 2.0))
	light:runAction(CCRepeatForever:create(CCRotateBy:create(0.5, 40)))
	light:runAction(CCSequence:create(light_arr))
end

function ShareEggsPanel:runSkeletonAnimation()
	FrameLoader:loadArmature('skeleton/eggs_share_animation')
    self.animNode = ArmatureNode:create("eggs_share_animation/ShareEggsPanel")
    self.animNode:setAnchorPoint(ccp(0.5, 0.5))
    self.animNode:setPosition(ccp(40, - 60))

    -- local function finishCallback()
    -- 	self.animNode:rma()
    --     self.animNode:playByIndex(1, 0)
    -- end
    -- self.animNode:addEventListener(ArmatureEvents.COMPLETE, finishCallback)

    self.animNode:playByIndex(0)
    self.ui:addChildAt(self.animNode, 3)
end

function ShareEggsPanel:getShareTitleName()
	return "火眼金睛！找到了所有小动物"
end

function ShareEggsPanel:dispose()
	ShareBasePanel.dispose(self)
	-- ArmatureFactory:remove("skeleton", "eggs_share_animation")
    FrameLoader:unloadArmature("skeleton/eggs_share_animation", true)
end

function ShareEggsPanel:create(shareId)
	local panel = ShareEggsPanel.new()
	panel:loadRequiredResource("ui/NewSharePanelEx.json")
	panel.ui = panel:buildInterfaceGroup('ShareEggsPanel')
	panel.shareId = shareId
	panel:init()
	return panel
end


function ShareEggsPanel:popout()
	PopoutManager.sharedInstance():add(self, false)
	self:popoutShowTransition()
end