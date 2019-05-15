local LadybugABTestManager = {}

function LadybugABTestManager:__isNew( ... )
	local uid = UserManager.getInstance().user.uid or '12345'
	uid = tonumber(uid) or 0
	local percent = uid % 100
	local threshold = 50
	if MaintenanceManager:getInstance():isEnabled('ladybug') then
		threshold = MaintenanceManager:getInstance():getValue('ladybug') or 50
		threshold = tonumber(threshold) or 50
		return percent < threshold and (self:hadTriggerNewTask() or self:isInValidLevelRange())
	else
		return false
	end
end

function LadybugABTestManager:__isHardCodeNew( ... )


	if (not PlatformConfig:isPlatform(PlatformNameEnum.k360)) and (not PlatformConfig:isPlatform(PlatformNameEnum.kQQ)) then 
		return false 
	end

	local threshold = 50

	local uid = UserManager.getInstance().user.uid or '12345'
	uid = tonumber(uid) or 0
	local percent = uid % 100

	return percent < threshold and (self:hadTriggerNewTask() or self:isInValidLevelRange())
end

function LadybugABTestManager:isNew( ... )
	return true
end

function LadybugABTestManager:hadTriggerNewTask( ... )
	local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
	return LadybugDataManager:getInstance():hadTrigger()
end

function LadybugABTestManager:isInValidLevelRange( ... )
	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	return topLevelId <= 62
end

function LadybugABTestManager:isOld( ... )
	return not self:isNew()
end

return LadybugABTestManager