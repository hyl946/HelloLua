---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-11-20 10:37:51
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2016-11-30 16:53:36
---------------------------------------------------------------------------------------
require 'zoo.panel.share.ShareBasePanel'

local _instancePanel = nil

ShareExplorerPanel = class(ShareBasePanel)

function ShareExplorerPanel:ctor()

end

function ShareExplorerPanel:getShareTitleName()
	return localize(self.shareTitleKey)
end

function ShareExplorerPanel:dispose()
	ShareBasePanel.dispose(self)
	-- ArmatureFactory:remove("skeleton", "share_280_animation")
	FrameLoader:unloadArmature("skeleton/share_280_animation", true)
end

function ShareExplorerPanel:create(shareId)
	local panel = ShareExplorerPanel.new()
	panel:loadRequiredResource("ui/NewSharePanelEx.json")
	panel:init(shareId)
	return panel
end

function ShareExplorerPanel:init(shareId)
	self.ui = self:buildInterfaceGroup('ShareExplorerPanel')
	self.shareId = shareId

	ShareBasePanel.init(self)

	local anim = self:buildAnim()
	local animPh = self.ui:getChildByName("anim")
	local pos = animPh:getPosition()
	local zOrder = animPh:getZOrder()
	anim:setScale(0.95)
	anim:setPosition(ccp(pos.x+55, pos.y-100))
	self.ui:addChildAt(anim, zOrder)

	animPh:removeFromParentAndCleanup(true)
end

function ShareExplorerPanel:buildAnim()
	FrameLoader:loadArmature("skeleton/share_280_animation")
    local anim = ArmatureNode:create("share_280/animation")
    anim:update(0.001)

    local function onAnim0Finish()
    	anim:playByIndex(1)
	end
    anim:addEventListener(ArmatureEvents.COMPLETE, onAnim0Finish)
    anim:playByIndex(0)
    return anim
end

function ShareExplorerPanel:popout(closeCallback)
	self.closeCallback = closeCallback
	PopoutManager.sharedInstance():add(self, false)
	self:popoutShowTransition()
	_instancePanel = self
end

function ShareExplorerPanel:removePopout()
	_instancePanel = nil
	ShareBasePanel.removePopout(self)

	if self.closeCallback then
		self.closeCallback()
	end
end

function ShareExplorerPanel:hasInstancePanel()
	return _instancePanel ~= nil
end

function ShareExplorerPanel:getVCenterInScreenY(...)
	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local selfHeight	= self.ui:getChildByName("bg"):getGroupBounds().size.height

	local deltaHeight	= visibleSize.height - selfHeight
	local halfDeltaHeight	= deltaHeight / 2

	return visibleOrigin.y + halfDeltaHeight + selfHeight - 15
end