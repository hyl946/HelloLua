require "zoo.gamePlay.ReplayDataManager"
local DisplayQualityManager = class()

function DisplayQualityManager:ctor( ... )
	-- body

	local key = self:getForcePopoutKey()
	local value = CCUserDefault:sharedUserDefault():getIntegerForKey(key, 0)
	CCUserDefault:sharedUserDefault():setIntegerForKey(key, value)
	CCUserDefault:sharedUserDefault():flush()

end

local instance 

function DisplayQualityManager:getInstance( ... )
	if not instance then
		instance = DisplayQualityManager.new()
	end
	return instance
end


function DisplayQualityManager:isEnable( ... )

	if(false) then
		return true
	end


	if __WIN32 and _G.isLocalDevelopMode then
		return true
	end

	if(not _G._scaleTexture) then
		return false
	end

	--[[if not __IOS then 
		return false
	end--]]

	if not MaintenanceManager:getInstance():isEnabled('customDisplayQuality') then
		return false
	end

	local topLevelId = 0
	pcall(function ( ... )
		topLevelId = tonumber(UserManager:getInstance().user:getTopLevelId()) or 0	
	end)
	if(topLevelId < 100) then
		return false
	end

	return _G.__isLowDevice

	-- local physicalMemory = 0
	-- pcall(function ( ... )
	-- 	physicalMemory = tonumber(NSProcessInfo:processInfo():physicalMemory()) or 0
	-- end)
	-- return physicalMemory < 1100*1024*1024
end

function DisplayQualityManager:showRedDot( ... )
	if(not self:isEnable()) then
		return false
	end

    local qualityHint = CCUserDefault:sharedUserDefault():getIntegerForKey("game.texture.quality.hint")
    if(qualityHint == 1) then
    	return false
    end

    return true
end

function DisplayQualityManager:markShowRedDot( ... )
    CCUserDefault:sharedUserDefault():setIntegerForKey("game.texture.quality.hint", 1)
    CCUserDefault:sharedUserDefault():flush()
end


--[[
DisplayQualityManager.Quality = {
	kLow = 1,
	kMiddle = 2,
	kHigh = 3
}
]]

function DisplayQualityManager:getQuality( ... )
	local quality = CCUserDefault:sharedUserDefault():getIntegerForKey("game.texture.quality")
	if (not quality) or quality == 0 then
		return 3
	else
		return quality
	end
end

function DisplayQualityManager:setQuality( quality )
	CCUserDefault:sharedUserDefault():setIntegerForKey("game.texture.quality", quality)
	CCUserDefault:sharedUserDefault():flush()
end

function DisplayQualityManager:getForcePopoutKey( ... )
--[[
	local uid = '12345'
    if UserManager and UserManager:getInstance().user then
    	uid = UserManager:getInstance().user.uid or '12345'
    end
    local key = 'not.force.popout.custom.display.quality.'..uid
    return key
]]
    local key = 'custom.display.quality.force.popout.'
    return key
end

function DisplayQualityManager:markHasForcePopout( ... )
    local key = self:getForcePopoutKey()
    CCUserDefault:sharedUserDefault():setIntegerForKey(key, 5)
	CCUserDefault:sharedUserDefault():flush()
end

local _has_sub_once = false
function DisplayQualityManager:canForcePopout( ... )

	if(not self:isEnable()) then
		return false
	end

	if(not ReplayDataManager:checkLastLaunchHasCrashedInLevel()) then
		return false
	end

	local key = self:getForcePopoutKey()
	local value = CCUserDefault:sharedUserDefault():getIntegerForKey(key, 0)
	if not _has_sub_once then
		_has_sub_once = true
		value = value - 1
	    CCUserDefault:sharedUserDefault():setIntegerForKey(key, value)
		CCUserDefault:sharedUserDefault():flush()
	end

	local quality = self:getQuality()
	if quality ~= 3 then
		return false
	end

	if(value > 0) then
		return false
	end

	return true

end


return DisplayQualityManager
