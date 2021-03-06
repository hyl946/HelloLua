require 'zoo.panel.share.ShareBasePanel'

ShareNStarRewardPanel = class(ShareBasePanel)

function ShareNStarRewardPanel:ctor()

end


function ShareNStarRewardPanel:init()
	--初始化文案内容
	ShareBasePanel.init(self)

	local function skeletonAnimation()
		self:runSkeletonAnimation()
	end

	self.ui:runAction(CCCallFunc:create(skeletonAnimation))

	self:runLightAction()
end

function ShareNStarRewardPanel:runLightAction()
	local light = self.ui:getChildByName("light")
	light:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
	light:setPosition(ccp(450, -380))
	light:setScale(0)
	local light_arr = CCArray:create()
	light_arr:addObject(CCFadeIn:create(0.6))
	light_arr:addObject(CCScaleTo:create(0.3, 2.0))
	light:runAction(CCRepeatForever:create(CCRotateBy:create(0.5, 40)))
	light:runAction(CCSequence:create(light_arr))
end

function ShareNStarRewardPanel:runSkeletonAnimation()
	FrameLoader:loadArmature('skeleton/share_90_animation')
    self.animNode = ArmatureNode:create("ShareNStarReward")
    self.animNode:setAnchorPoint(ccp(0.5, 0.5))
    self.animNode:setPosition(ccp(40, - 60))

    local function finishCallback()
    	self.animNode:rma()
        self.animNode:playByIndex(1, 0)
    end
    self.animNode:addEventListener(ArmatureEvents.COMPLETE, finishCallback)

    self.animNode:playByIndex(0, 1)
    self.ui:addChildAt(self.animNode, 3)
end

function ShareNStarRewardPanel:getShareTitleName()
	local curTotalStar 	= UserManager:getInstance().user:getTotalStar()
	return Localization:getInstance():getText(self.shareTitleKey,{num = curTotalStar})
end

function ShareNStarRewardPanel:dispose()
	ShareBasePanel.dispose(self)
	-- ArmatureFactory:remove("skeleton", "share_90_animation")
    FrameLoader:unloadArmature("skeleton/share_90_animation", true)
end

function ShareNStarRewardPanel:create(shareId)
	local panel = ShareNStarRewardPanel.new()
	panel:loadRequiredResource("ui/NewSharePanelEx.json")
	panel.ui = panel:buildInterfaceGroup('Share5Time4StarPanel')
	panel.shareId = shareId
	panel:init()
	return panel
end