--[[
 * ActivityCenterGuidePopoutAction
 * @date    2018-08-21 15:27:59
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

ActivityCenterGuidePopoutAction = class(HomeScenePopoutAction)

function ActivityCenterGuidePopoutAction:ctor()
	self.name = "ActivityCenterGuidePopoutAction"
	self.waitNextFrame = true
    self:setSource(AutoPopoutSource.kTriggerPop)
end

function ActivityCenterGuidePopoutAction:checkCache(cache)
	if not cache.para then
		return self:onCheckCacheResult(false)
	end

	self.config = {actId = cache.para}
	self:onCheckPopResult(ActivityCenter:canShowGuide(self.config))
end

function ActivityCenterGuidePopoutAction:popout(next_action)
	ActivityCenter:showGuide(self.config, next_action)
end