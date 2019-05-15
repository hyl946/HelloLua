--[[
 * AreaUnlockPanelPopoutAction
 * @date    2018-09-05 11:21:51
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

AreaUnlockPanelPopoutAction = class(HomeScenePopoutAction)

function AreaUnlockPanelPopoutAction:ctor()
    self.name = "AreaUnlockPanelPopoutAction"
    self.ignorePopCount = true
    self:setSource(AutoPopoutSource.kTriggerPop)
end

function AreaUnlockPanelPopoutAction:checkCache(cache)
    local para = cache.para

    self.para = para
    self:onCheckCacheResult(self.para ~= nil)
end

function AreaUnlockPanelPopoutAction:popout( next_action )
	local para = self.para

	if not para then
		next_action()
		return
	end

	local function close_cb()
		if para.closeCb then
			para.closeCb()
		end
		if self.close_cb then
			next_action()
			self.close_cb = nil
		end
	end
	self.close_cb = close_cb
	
    AreaUnlockPanel:create(para.cloudId, para.star, para.neededStar, para.onSuccess, self.close_cb, self.close_cb)
end