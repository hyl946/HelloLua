--[[
 * PersonalInfoGuideAction
 * @date    2018-08-09 16:27:20
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

PersonalInfoGuideAction = class(HomeScenePopoutAction)

function PersonalInfoGuideAction:ctor()
	self.name = "PersonalInfoGuideAction"
	self.guideFlag = false
    self:setSource(AutoPopoutSource.kGamePlayQuit)
end

function PersonalInfoGuideAction:checkCanPop()
	local PersonalInfoReward = require('zoo.PersonalCenter.PersonalInfoReward')
	if HomeSceneButtonsManager:getInstance().hasGuideOnScreen or GameGuideData:sharedInstance():getRunningGuide() then
		return self:onCheckPopResult(false)
	end

	local canTrigger = PersonalInfoReward:canTrigger()
	if canTrigger then
		self.guideFlag = true
	end

	if self.debug then
		canTrigger = true
	end
	
	self:onCheckPopResult(canTrigger)
end

function PersonalInfoGuideAction:popout(next_action)
    local PersonalInfoGuide = require "zoo.PersonalCenter.PersonalInfoGuide"
	PersonalInfoGuide:popGuide()
end