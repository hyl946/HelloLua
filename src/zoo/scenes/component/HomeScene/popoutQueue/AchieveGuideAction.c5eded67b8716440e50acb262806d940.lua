--[[
 * AchieveGuideAction
 * @date    2018-08-06 16:49:02
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

AchieveGuideAction = class(HomeScenePopoutAction)

function AchieveGuideAction:ctor()
	self.name = "AchieveGuideAction"
	self.guideFlag = false
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground, AutoPopoutSource.kSceneEnter)
end

function AchieveGuideAction:checkCanPop()
	local hasGuide = AchiUIManager:hasGuide()
	if hasGuide then
		self.guideFlag = true
	end
	
	self:onCheckPopResult(hasGuide)
end

function AchieveGuideAction:popout(next_action)
    if AchiUIManager:hasGuide() then
    	GameGuide:sharedInstance():tryStartGuide()
    else
    	next_action()
    end
end