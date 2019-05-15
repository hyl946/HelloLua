CCUserDefault = class()
local instance = nil 
function CCUserDefault:sharedUserDefault()
	if instance == nil then
		instance = CCUserDefault.new()
	end
	return instance
end

function CCUserDefault:setIntegerForKey(k, v) self[k] = v end
function CCUserDefault:setBoolForKey(k, v) self[k] = v end
function CCUserDefault:setFloatForKey(k, v) self[k] = v end
function CCUserDefault:setDoubleForKey(k, v) self[k] = v end
function CCUserDefault:setStringForKey(k, v) 
	self[k] = v 
end


function CCUserDefault:getBoolForKey(k, v) return self[k] end
function CCUserDefault:getIntegerForKey(k, v) return self[k] end
function CCUserDefault:getFloatForKey(k, v) return self[k] end
function CCUserDefault:getDoubleForKey(k, v) return self[k] end
function CCUserDefault:getStringForKey(k, v) 
	return self[k] 
end

function CCUserDefault:flush()
	
end

