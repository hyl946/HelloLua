--[[
 * NotificationGuidePopoutAction
 * @date    2018-08-17 15:19:45
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

NotificationGuidePopoutAction = class(HomeScenePopoutAction)

function NotificationGuidePopoutAction:ctor()
	self.name = "NotificationGuidePopoutAction"
    self:setSource(AutoPopoutSource.kTriggerPop)
end

function NotificationGuidePopoutAction:checkCache(cache)
	if self.debug then
		cache.para = {
			guideTriggerType = NotiGuideTriggerType.kPassAllLevel,
			extraData = kMaxLevels
		}
	end

	local _M = NotificationGuideManager.getInstance()
	if not _M:isEnable() then 
		return self:onCheckCacheResult(false)
	end

	local para = cache.para
	local guideTriggerType = para.guideTriggerType
	local extraData = para.extraData

	if not _M:check(guideTriggerType, extraData) then
		return self:onCheckCacheResult(false)
	end

	self.guideTriggerType = guideTriggerType
	self.extraData = extraData
	self:onCheckCacheResult(true)
end

function NotificationGuidePopoutAction:popout( next_action )
	local _M = NotificationGuideManager.getInstance()

	local extraData = self.extraData
	local guideTriggerType = self.guideTriggerType

	if guideTriggerType == NotiGuideTriggerType.kPassAllLevel then
		_M.maxLevel = extraData
		_M:writeMaxLevel(extraData)
	end
	
	_M:onNotified(guideTriggerType)
	
	require "zoo.panel.NotificationGuidePanel"
	NotificationGuidePanel:create(guideTriggerType):popout(next_action)
end