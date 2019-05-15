--[[
 * IconCollectGuidePopoutAction
 * @date    2018-08-09 11:45:14
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

IconCollectGuidePopoutAction = class(HomeScenePopoutAction)

function IconCollectGuidePopoutAction:ctor()
	self.name = "IconCollectGuidePopoutAction"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground, AutoPopoutSource.kSceneEnter)
end

function IconCollectGuidePopoutAction:checkCache(cache)
	self:onCheckCacheResult(HomeSceneButtonsManager.getInstance():canForcePop())
end

function IconCollectGuidePopoutAction:popout(next_action)
    HomeSceneButtonsManager.getInstance():showButtonHideTutor(next_action)
end