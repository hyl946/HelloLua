---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-11-20 11:43:59
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2016-11-22 15:20:22
---------------------------------------------------------------------------------------
require 'zoo.panel.share.ShareBasePanel'

ShareWeeklyFinalRewardPanel = class(ShareBasePanel)

function ShareWeeklyFinalRewardPanel:ctor()

end

function ShareWeeklyFinalRewardPanel:getShareTitleName()
	local weeklyMatchData = SeasonWeeklyRaceManager:getInstance().matchData
	local achiValue = 0
	if weeklyMatchData then
		achiValue = weeklyMatchData.medals or 0
	end
	return localize(self.shareTitleKey,{num = achiValue})
end

function ShareWeeklyFinalRewardPanel:dispose()
	ShareBasePanel.dispose(self)
	-- ArmatureFactory:remove("skeleton", "share_290_animation")
    FrameLoader:unloadArmature('skeleton/share_290_animation', true)
end

function ShareWeeklyFinalRewardPanel:create(shareId)
	local panel = ShareWeeklyFinalRewardPanel.new()
	panel:loadRequiredResource("ui/NewSharePanelEx.json")
	panel:init(shareId)
	return panel
end

function ShareWeeklyFinalRewardPanel:init(shareId)
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

function ShareWeeklyFinalRewardPanel:buildAnim()
	FrameLoader:loadArmature("skeleton/share_290_animation")
    local anim = ArmatureNode:create("share_290/animation")
    anim:update(0.001)

    local function onAnim0Finish()
    	anim:playByIndex(1)
	end
    anim:addEventListener(ArmatureEvents.COMPLETE, onAnim0Finish)
    anim:playByIndex(0)
    return anim
end

function ShareWeeklyFinalRewardPanel:popout()
	PopoutManager.sharedInstance():add(self, false)
	self:popoutShowTransition()
end

-- function ShareWeeklyFinalRewardPanel:getVCenterInParentY()
-- 	return 50
-- end