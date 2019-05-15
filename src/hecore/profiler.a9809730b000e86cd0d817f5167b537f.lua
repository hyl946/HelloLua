require "hecore.utils"
require "zoo.util.KeyChainUtil"
require("zoo.loader.LowDeviceDetectProcessor")

local ProFiEnabled = true --and isLocalDevelopMode and (_profiler and _profiler.enabled())
print("ProFiEnabled = " .. tostring(ProFiEnabled))
_G._ProFiEnabled = ProFiEnabled

local profiler = {}
profiler.enabled = false-- and ENABLED

require "hecore.performance"
require("hecore.debug.OnlinePerformanceLog")
local ProFi = require "hecore.ProFi"
-- require("hecore.debug.PerformanceLog")

--[[
function profiler:add(key, cost)
	if(self.enabled) then
		_profiler.add(key, cost)
	end
end

function profiler:save()
	_profiler.save()
end

function profiler:clearMap()
	_profiler.clear()
end
]]


profiler.functionRecordMap = {} --key, {cost, times}

function profiler:start()
	if(ProFiEnabled) then
		if printx then printx(0, "========		PROFILER START		========") end
		ProFi:start()
	end
end

function profiler:stop()
	if(ProFiEnabled) then
		if printx then printx(0, "========		PROFILER STOP		========") end
		ProFi:stop()
	end
end

function profiler:pause()
	if(ProFiEnabled) then
		if printx then printx(0, "========		PROFILER PAUSE		========") end
		ProFi:pauseMe()
	end
end

function profiler:resume()
	if(ProFiEnabled) then
		if printx then printx(0, "========		PROFILER RESUME		========") end
		ProFi:resumeMe()
	end
end


function profiler:add(key, cost)
	assert(self.enabled)

	local data = self.functionRecordMap[key]
	if(data == nil) then
		data = {0, 0}
		self.functionRecordMap[key] = data
	end

	local data = self.functionRecordMap[key]
	data[1] = data[1] + cost
	data[2] = data[2] + 1

	--[[
	assert(self.enabled)

	local data = self.functionRecordMap[key]
	if(data == nil) then
		data = {0, 0}
		self.functionRecordMap[key] = data
	end

	local data = self.functionRecordMap[key]
	data[1] = data[1] + cost
	data[2] = data[2] + 1
	]]
end

--[[
function profiler:dump()
	local map = self:getSortMap()

	printex("========		PROFILER dump		========", PRINT_CHANNEL.performance)
	local msg = ""
	for i = 1, #map do
		local f = map[i][1]
		local c = math.ceil(map[i][2] * 1000) / 1000
		local t = map[i][3]
		local each = (i .. ":\t" .. f .. ",\t" .. c .. "s,\t" .. t)
		msg = msg .. each .. "\n"
		print(each)
	end
	printex("========		PROFILER dump		========", PRINT_CHANNEL.performance)

	return msg
end
]]



--[[
function profiler:getSortMap()
	local map = {}

	for k, d in pairs(self.functionRecordMap) do
		local pack = {k, d[1], d[2]}

		if(#map == 0) then
			map[1] = pack
		else
			local find = false

			for i = 1, #map do
				if pack[2] > map[i][2] then
					table.insert(map, i, pack)
					find = true
					break
				end
			end

			if(not find) then
				map[#map + 1] = pack
			end
		end
	end

	return map
end

function profiler:save()
	if(not self.enabled) then return end


	local function doFlushCache()
		local date = tostring(os.date())
		date = string.gsub(date, ":", "_")
		date = string.gsub(date, "/", "_")
		date = string.gsub(date, " ", "_")
		local log = self:dump()
		local checkReplayCachePath = HeResPathUtils:getUserDataPath() .. "/_profiler_" .. date .. ".txt"

		Localhost:safeWriteStringToFile(log, checkReplayCachePath)
	end

	pcall(doFlushCache)
end
]]


function profiler:clearMap()
	if printx then printx(0, "========		PROFILER CLEAR		========") end

	self.functionRecordMap = {}

	if(_profiler) then
		_profiler.clear()
	end

	if(ProFiEnabled) then
		ProFi:stop()
		ProFi:reset()
		-- ProFi:start()
	end
end



local function getProfilerStorage()
	if __ANDROID then
		return luajava.bindClass("com.happyelements.android.utils.ScreenShotUtil"):getGamePictureExternalStorageDirectory()
	elseif __IOS then
 		return HeResPathUtils:getResCachePath()
 	else
 		return HeResPathUtils:getUserDataPath()
	end
end


function profiler:save()
	if printx then printx(0, "========		PROFILER SAVE		========") end

	if(_profiler) then
		_profiler.merge(self.functionRecordMap)
		_profiler.save()
	end

	if(ProFiEnabled) then
	    local date = tostring(os.date())
	    date = string.gsub(date, ":", "_")
	    date = string.gsub(date, "/", "_")
	    date = string.gsub(date, " ", "_")
	    local checkReplayCachePath = getProfilerStorage() .. "/_profiler_" .. date .. ".txt"

		print("write report @ " .. checkReplayCachePath)
		ProFi:writeReport( checkReplayCachePath )

	    if __ANDROID then
	        local disp = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")
	        disp:notifySystemToScanPicFolder(getProfilerStorage() .. "/")
	    end

	end
end

function _profiler_save(log, name)
	if(name == nil) then name = "_profiler_" end

  local function doFlushCache()
    local date = tostring(os.date())
    date = string.gsub(date, ":", "_")
    date = string.gsub(date, "/", "_")
    date = string.gsub(date, " ", "_")
    local checkReplayCachePath = getProfilerStorage() .. "/" .. name .. date .. "_c_.txt"

	print("write report @ " .. checkReplayCachePath)
    Localhost:safeWriteStringToFile(log, checkReplayCachePath)
  end

  pcall(doFlushCache)
end

--[[
function _profiler_add(key, cost)
	if(profiler.enabled) then
		profiler:add(key, cost)
	end
end
]]

return profiler
