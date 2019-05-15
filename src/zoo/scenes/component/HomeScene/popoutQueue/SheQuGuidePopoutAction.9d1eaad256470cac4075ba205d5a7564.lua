--[[
 * SheQuGuidePopoutAction
 * @date    2018-08-09 20:06:45
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

SheQuGuidePopoutAction = class(HomeScenePopoutAction)

function SheQuGuidePopoutAction:ctor()
	self.name = "SheQuGuidePopoutAction"
	self.guideFlag = false
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground, AutoPopoutSource.kSceneEnter)
end

function SheQuGuidePopoutAction:checkCanPop()
	local guide = GameGuideData:sharedInstance():getGuides()[20180612]
	local list = {
			{type = "scene", scene = "worldMap"},
            {type = "onceOnly"},
			{type = "hasNoOtherGuide"},
			{type = "userLevelGreatThan", para = 100},
            {type = "CheckCanShowFAQ"},
            {type = "CheckSettingBtnIsCreate"},
            {type = "checkGuideFlag", para = kGuideFlags.SheQuGuide},
		}

	if GameGuideCheck:checkFixedAppears(guide,list, nil, 20180612) then
		self.guideFlag = true
	end
	self:onCheckPopResult(self.guideFlag)
end

function SheQuGuidePopoutAction:popout(next_action)
    GameGuide:sharedInstance():tryStartGuide()
end