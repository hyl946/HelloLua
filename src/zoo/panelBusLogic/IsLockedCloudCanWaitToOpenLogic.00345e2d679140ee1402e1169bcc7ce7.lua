
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年11月28日 16:43:12
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com


---------------------------------------------------
-------------- IsLockedCloudCanOpenLogic
---------------------------------------------------

IsLockedCloudCanWaitToOpenLogic = class()


function IsLockedCloudCanWaitToOpenLogic:init(lockedCloudId)
	assert(type(lockedCloudId) == "number")
	self.lockedCloudId = lockedCloudId
end

function IsLockedCloudCanWaitToOpenLogic:hasPassedLevel(levelId)
	if UserManager.getInstance():hasPassedLevel(levelId) or
		JumpLevelManager.getInstance():hasJumpedLevel(levelId) or
			UserManager:getInstance():hasAskForHelpInfo(levelId) then
				return true
	end
	return false
end

function IsLockedCloudCanWaitToOpenLogic:start()
	local topLevelId	= UserManager.getInstance().user:getTopLevelId()
	assert(topLevelId)
	local curLevelAreaData	= MetaModel:sharedInstance():getLevelAreaDataById(self.lockedCloudId)
	local curStartNodeId	= tonumber(curLevelAreaData.minLevel)
	assert(curStartNodeId)
	if topLevelId == curStartNodeId - 1 and self:hasPassedLevel(topLevelId) then
		return true
	end

	return false
end

function IsLockedCloudCanWaitToOpenLogic:create(lockedCloudId)
	assert(type(lockedCloudId) == "number")

	local newIsLockedCloudCanOpenLogic = IsLockedCloudCanWaitToOpenLogic.new()
	newIsLockedCloudCanOpenLogic:init(lockedCloudId)
	return newIsLockedCloudCanOpenLogic
end

