--[[
 * @Author  zhou.ding 
 * @Date    2017-02-22 10:47:28
 * @Email 	zhou.ding@happyelements.com
--]]

local next_event = 0

local function getNext()
	next_event = next_event + 1
	return next_event
end

local events = {
	APP_ENTER_BACKGROUND		= getNext(),
	APP_ENTER_FOREGROUND 		= getNext(),
	APP_OPEN_URL				= getNext(),
	FB_OPEN_URL					= getNext(),
	APP_RESUMED					= getNext(),
	APP_PAUSE					= getNext(),
}

return {events = events, getNext = getNext}