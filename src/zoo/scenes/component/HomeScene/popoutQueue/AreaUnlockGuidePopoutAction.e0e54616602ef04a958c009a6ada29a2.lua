--[[
 * AreaUnlockGuidePopoutAction
 * @date    2018-08-20 10:19:10
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

AreaUnlockGuidePopoutAction = class(HomeScenePopoutAction)

function AreaUnlockGuidePopoutAction:ctor()
	self.name = "AreaUnlockGuidePopoutAction"
	self.recallUserNotPop = true
	self.guideFlag = false
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground, AutoPopoutSource.kSceneEnter)
end

function AreaUnlockGuidePopoutAction:checkCanPop()
	local topLevelId = UserManager:getInstance().user:getTopLevelId()

	local index = 151
	if topLevelId == 30 then
		index = 152
	end
	if topLevelId ~= 15 and topLevelId ~= 30 then
		return self:onCheckPopResult(false)
	end
	local guide = GameGuideData:sharedInstance():getGuides()[index]
	local list = {
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = topLevelId},
			{type = "noPopup"},
			{type = "topPassedLevel", para = topLevelId},
			{type = "onceOnly"},
		}
	if GameGuideCheck:checkFixedAppears(guide, list, nil, index) then
		self.guideFlag = true
	end

	self:onCheckPopResult(self.guideFlag)
end

function AreaUnlockGuidePopoutAction:popout(next_action)
	GameGuide:sharedInstance():tryStartGuide()
end