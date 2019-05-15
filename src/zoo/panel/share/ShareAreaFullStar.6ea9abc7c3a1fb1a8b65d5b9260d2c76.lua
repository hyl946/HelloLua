require 'zoo.panel.share.ShareBasePanel'

ShareAreaFullStar = class(ShareBasePanel)

function ShareAreaFullStar:ctor()

end


function ShareAreaFullStar:init()
	--初始化文案内容
	ShareBasePanel.init(self)

	local function skeletonAnimation()
		self:runSkeletonAnimation()
	end

	self.ui:runAction(CCCallFunc:create(skeletonAnimation))

	self:runLightAction()
end

function ShareAreaFullStar:runLightAction()
	local light = self.ui:getChildByName("light")
	light:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
	light:setPosition(ccp(350, -450))
	light:setScale(0)
	local light_arr = CCArray:create()
	light_arr:addObject(CCFadeIn:create(0.6))
	light_arr:addObject(CCScaleTo:create(0.3, 2.0))
	light:runAction(CCRepeatForever:create(CCRotateBy:create(0.5, 40)))
	light:runAction(CCSequence:create(light_arr))
end

function ShareAreaFullStar:runSkeletonAnimation()
	FrameLoader:loadArmature('skeleton/share_220_animation')
    self.animNode = ArmatureNode:create("share_220_animation")
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

function ShareAreaFullStar:getShareTitleName()
	local num = self.achiManager:getData(self.achiManager.FULL_STAR_HIED_AREA_NUM)
	return Localization:getInstance():getText(self.shareTitleKey,{num = num})
end

function ShareAreaFullStar:initShareTitle(titleName)
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

function ShareAreaFullStar:dispose()
	ShareBasePanel.dispose(self)
	-- ArmatureFactory:remove("skeleton", "share_220_animation")
    FrameLoader:unloadArmature("skeleton/share_220_animation", true)
end

function ShareAreaFullStar:create(shareId)
	local panel = ShareAreaFullStar.new()
	panel:loadRequiredResource("ui/NewSharePanelEx.json")
	panel.ui = panel:buildInterfaceGroup('Share5Time4StarPanel')
	panel.shareId = shareId
	panel:init()
	return panel
end