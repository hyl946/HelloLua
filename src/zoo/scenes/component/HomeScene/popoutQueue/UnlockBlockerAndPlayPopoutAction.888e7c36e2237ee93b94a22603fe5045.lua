--[[
 * UnlockBlockerAndPlayPopoutAction
 * @date    2018-08-17 17:50:33
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

UnlockBlockerAndPlayPopoutAction = class(HomeScenePopoutAction)

function UnlockBlockerAndPlayPopoutAction:ctor(url)
	self.name = "UnlockBlockerAndPlayPopoutAction"
    self:setSource(AutoPopoutSource.kTriggerPop)
end

function UnlockBlockerAndPlayPopoutAction:checkCache(cache)
	if self.debug then
		cache.para = 40001
	end

	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	if topLevelId % 15 ~= 1 then
		return self:onCheckCacheResult(false)
	end
	self.areaId = cache.para
    self:onCheckCacheResult(self.areaId ~= nil)
end

function UnlockBlockerAndPlayPopoutAction:popout( next_action )
	UnlockBlockerAndPlayPanel:create(self.areaId):popout()
end
