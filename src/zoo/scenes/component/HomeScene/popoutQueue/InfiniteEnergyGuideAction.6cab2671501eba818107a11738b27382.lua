--[[
 * InfiniteEnergyGuideAction
 * @date    2018-08-09 15:35:44
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

InfiniteEnergyGuideAction = class(HomeScenePopoutAction)

function InfiniteEnergyGuideAction:ctor()
	self.name = "InfiniteEnergyGuideAction"
	self.guideFlag = false
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground, AutoPopoutSource.kSceneEnter)
end

function InfiniteEnergyGuideAction:hasGuide()
	return not UserManager:getInstance():hasGuideFlag(kGuideFlags.InfiniteEnergy)
end

function InfiniteEnergyGuideAction:checkCanPop()
	local guide = GameGuideData:sharedInstance():getGuides()[20]
	local list = {
			{type = "noPopup"},
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = 2},
			{type = "onceOnly"} ,
			{type = "isNotNextLevelModel"} ,
			{type = "checkGuideFlag", para = kGuideFlags.InfiniteEnergy},
		}

	if GameGuideCheck:checkFixedAppears(guide,list, nil, 20) then
		self.guideFlag = true
	end

	self:onCheckPopResult(self.guideFlag)
end

function InfiniteEnergyGuideAction:popout(next_action)
    GameGuide:sharedInstance():tryStartGuide()
end