local OOMENABLE = false


--[[
local __request_log_debug = false and isLocalDevelopMode
local __request_log_localtime = HeResPathUtils:getUserDataPath() .. "newoommanagertime.str"

local function __log(s)
    print('oommanager: ' .. s)
end
local function __call(f)
  if __request_log_debug then
    f()
  else
    pcall(f)
  end
end

local function __check_time(intervalSec)
  local lastSaveSec = 0
  local function readLocalTime()
    local lastTimeStr = _nativeUtil.read(__request_log_localtime)
    lastSaveSec = tonumber(lastTimeStr) 
    if lastSaveSec == nil then
      lastSaveSec = 0
      _nativeUtil.write(__request_log_localtime, tostring(lastSaveSec))
    end
  end
  pcall(readLocalTime)
  __log('saved process time = ' .. tostring(lastSaveSec))

  local currentSec = os.time()
  local nextSec = lastSaveSec + intervalSec
  if not __request_log_debug and currentSec < nextSec then
    __log('ignore process, left = ' .. tostring(nextSec - currentSec))
    return false
  end
  return true
end

local function active()
  __log('update process time')
	_nativeUtil.write(__request_log_localtime, tostring(os.time()))

  __log('active')
  -- to do
end

local initialized = false
local function main()
  	if initialized then
  		return
  	end
  	initialized = true

    if not __IOS then
      return
    end

    local maintenance = MaintenanceManager:getInstance():getMaintenanceByKey("oomtrace")
    if maintenance == nil or not maintenance.enable then
      __log('no config')
      return
    end

    local config = tostring(maintenance.extra) or ""
    local param = config:split(",")
    if #param < 2 then
    	__log('wrong config parameters: ' .. config)
  		return
    end
  	local interval = tonumber(param[1])
  	local dimi = tonumber(param[2])
  	if interval == nil or dimi == nil then
      	__log('wrong config parameters: ' .. config)
  		return
  	end

  	if not __check_time(interval) then
      	__log('not the time')
  		return
  	end

    local uid = tonumber(UserManager:getInstance().uid) or 0
    __log('uid = ' .. tostring(uid))
    if uid == 0 then
      __log('no uid')
      return
    end
    uid = uid % 10000
    if not __request_log_debug and uid >= dimi then
    	__log('not in the range')
    	return
    end

	__call(active)
end

function try2StartTencentoom()
	if __IOS then
		__call(main)
	end
end

]]

