
local whitelist = {
--[[
	--515815787
	"DFB41B7E-7FEE-4DCD-9CC8-F6A3EE4776DB",
	"638D39E9-886C-4409-825B-2EECA4137CD8",
	--wanqing
	"3339BE04-7028-41B6-82FF-64AE68964DE7",
]]
}

local function isInPerformanceLogWhitelist()
	if _G.isLocalDevelopMode then
		return true
	end

    local metaInfo = MetaInfo:getInstance()
    if(metaInfo) then
        local code = metaInfo:getUdid()
        for i = 1, #whitelist do
            if code == whitelist[i] then
                return true
            end
        end
    end
    return false
end

local function getUdid()
    local metaInfo = MetaInfo:getInstance()
    if(metaInfo) then
        local code = metaInfo:getUdid()
        return code
    end
    return ""
end



local OnlinePerformanceLog = {}
OnlinePerformanceLog.__index = OnlinePerformanceLog;
_G._performanceLogChannel = ""
_G._performanceLogInterval = 600

function OnlinePerformanceLog:enabled()
	return isInPerformanceLogWhitelist()
end

function OnlinePerformanceLog:new(scenario)
	assert(scenario)

	local p = {}
	setmetatable(p, OnlinePerformanceLog)

	p.udid = getUdid()
	p.scenario = scenario
	p.fpsMin = 60
	p.avarageFps = 0
	p.tick = 0
	p:start()

	return p
end

function OnlinePerformanceLog:addTrack()
	self.tick = self.tick + 1
	if self.tick % 30 == 30 then
		local timestamp = os.clock()
		local elapsed = timestamp - self._blockTimestamp
		self._blockTimestamp = timestamp

		local fps = 60
		if elapsed ~= 0 then
			fps = 30 / elapsed
		end
		self.fpsMin = math.min(self.fpsMin, fps)
	end
end

function OnlinePerformanceLog:start()
	local context = self
	local onTimer = function(...)
		context:addTrack()
	end

	self._startTimestamp = os.clock()
	self._blockTimestamp = self._startTimestamp
	self._fpsLogHandle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTimer, 0, false)
end

function OnlinePerformanceLog:free()
	if(self._fpsLogHandle ~= nil) then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self._fpsLogHandle)
		self._fpsLogHandle = nil
	end

	local timestamp = os.clock()
	local elapsed = timestamp - self._startTimestamp

	if elapsed ~= 0 then
		local fps = self.tick / elapsed
		self.avarageFps = fps
		self.fpsMin = math.min(self.fpsMin, fps)
	end

	self:log()
end

function OnlinePerformanceLog:log()
	local msg = self.scenario
	msg = msg .. ', udid=' .. tostring(self.udid)
	msg = msg .. ', fps=' .. tostring(self.avarageFps)
	msg = msg .. ', min=' .. tostring(self.fpsMin)
	msg = msg .. ', tick=' .. tostring(self.tick)

   	msg = msg .. self:getCpuInfo()

	he_log_error(msg)
end

function OnlinePerformanceLog:getCpuInfo()
	local msg = ''

	local function _getCpiInfo()
	    if(__ANDROID) then
	        local disp = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")
	        if(disp) then
	        	msg = msg .. ", cpu_usage:"
	        	msg = msg .. ", max:" .. disp:getMaxCpuFreq()
	        	msg = msg .. ", min:" .. disp:getMinCpuFreq() 
	        	msg = msg .. ", cur:" .. disp:getCurCpuFreq()
	        end
		elseif __IOS then
			local cpuUsage = AppController:getCpuUsage()
	        msg = msg .. ", cpu_usage:" .. tostring(cpuUsage)
	    end
	end

	pcall(_getCpiInfo)
    return msg
end


return OnlinePerformanceLog
