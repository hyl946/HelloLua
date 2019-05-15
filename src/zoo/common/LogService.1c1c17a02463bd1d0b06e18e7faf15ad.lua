

-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月27日 13:16:26
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

assert(not logServiceLoaded)
logServiceCond = true


local logDebugLevel = 3

local function getLogCallingFuncName()

	local info = debug.getinfo(3,"nS")
  local s = info.source or ""
  local n = info.name or ""
	return s .. ":" .. n
end

--------------------------------------------
---- Replace he_log_info
-------------------------------------------

local engine_he_log_info	= he_log_info

assert(not new_he_log_info)
function new_he_log_info(content, ...)
	if not __DEBUG then return end
	assert(content)
	assert(#{...} == 0)

	if logDebugLevel < 1 then
		return
	end

	local callingFuncName = getLogCallingFuncName()

	content = callingFuncName .. " | " .. content
	engine_he_log_info(content)
end

assert(engine_he_log_info ~= new_he_log_info)
he_log_info = new_he_log_info


---------------------------------------------
----- Replace he_log_warning
---------------------------------------

local engine_he_log_warning	= he_log_warning

assert(not new_he_log_warning)
function new_he_log_warning(content, ...)
	if not __DEBUG then return end
	assert(content)
	assert(#{...} == 0)

	if logDebugLevel < 2 then 
		return 
	end

	local callingFuncName = getLogCallingFuncName()

	content = "In Func " .. callingFuncName .. " | " .. content
	engine_he_log_warning(content)
end

assert(engine_he_log_warning ~= new_he_log_warning)
he_log_warning = new_he_log_warning
