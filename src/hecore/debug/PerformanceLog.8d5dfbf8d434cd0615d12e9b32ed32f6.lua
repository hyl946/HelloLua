
local PerformanceLog = {}
PerformanceLog.__index = PerformanceLog;

PerformanceLog.enabled = MaintenanceManager:getInstance():isEnabled("PerformanceLog", false)

function PerformanceLog:new(sceneName)
	assert(sceneName)

	local p = {}
	setmetatable(p, PerformanceLog)

	p.sceneName = sceneName
	p.fps = 0
	p.tick = 0
	p.fpsMinSet = {} --min - max
	p.maxRam = 0

	local onTimer = function(...)
		local elapsed = os.clock() - p._timestamp
		p._timestamp = os.clock()

		local fps = 60
		if(elapsed > 0) then
			fps = 1 / elapsed
		end
		p:addTrack(fps)
	end
	p._timestamp = os.clock()
	p._performanceLogHandle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTimer, 0, false)

	local function getMaxMem()
		if __IOS then
			local ram = AppController:getUsedMemory() / (1024)	-- MB
			p.maxRam = math.max(p.maxRam, ram)
		elseif __ANDROID then
			local disp = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")
			if(disp) then
				local ram = disp:getAppUsedMemory() / (1024)	-- MB
				p.maxRam = math.max(p.maxRam, ram)
			end
		else
		end
	end
	p._performanceMemLogHandle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(getMaxMem, 10, false)

	if __IOS then
	elseif __ANDROID then
		local disp = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")
		p._totalCpu = disp:getTotalCpu();
		p._pidCpu = disp:getPidCpu();
	else
	end

	return p;
end

function PerformanceLog:free()
	if(self._performanceLogHandle ~= nil) then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self._performanceLogHandle)
		self._performanceLogHandle = nil
	end
	if(self._performanceMemLogHandle ~= nil) then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self._performanceMemLogHandle)
		self._performanceMemLogHandle = nil
	end
end

function PerformanceLog:addTrack(fps)
	self.fps = self.fps + fps
	self.tick = self.tick + 1

	local insert = false
	for i = 1, #self.fpsMinSet do
		if(fps < self.fpsMinSet[i]) then
			insert = true
			table.insert(self.fpsMinSet, i, fps)
			break
		end
	end
	if(not insert) then
		self.fpsMinSet[#self.fpsMinSet + 1] = fps
	end
end

function PerformanceLog:log(  )
	local log = {}
	log.developingMode = isLocalDevelopMode

	if __IOS then
		log.cpuUsage = AppController:getCpuUsage()

    	local physicalMemory = NSProcessInfo:processInfo():physicalMemory() or 0
		physicalMemory = physicalMemory / (1024 * 1024)
		log.physicalMemory = physicalMemory

		log.appUsedRam = AppController:getUsedMemory() / (1024)	-- MB
		log.sysAvailableRam = AppController:getTotalMemory()

	elseif __ANDROID then
		local disp = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")
		if(disp) then
			local totalCpu = disp:getTotalCpu();
			local pidCpu = disp:getPidCpu();
			log.cpuUsage = (pidCpu - self._pidCpu) / (totalCpu - self._totalCpu)

	    	local physicalMemory = disp:getSysMemory()
	 		physicalMemory = physicalMemory / (1024 * 1024)
	 		log.physicalMemory = physicalMemory

			log.appUsedRam = disp:getAppUsedMemory() / (1024)	-- MB
			if(false)then
				print("app used memory: " .. disp:getAppUsedMemory() / (1024))
				print("sys used memory: " .. disp:getSysUsedMemory() / (1024 * 1024))
				print("sys free memory: " .. disp:getSysFreeMemory() / (1024 * 1024))
			end

			log.sysAvailableRam = physicalMemory
		end
	else
		log.cpuUsage = 0
		log.physicalMemory = 0
		log.appUsedRam = 0
		log.sysAvailableRam = 0
	end

	log.appUsedRamMax = self.maxRam;

	log.bundleVersion = MetaInfo:getInstance():getApkVersion()
	log.packageName = MetaInfo:getInstance():getPackageName()
	log.platform = StartupConfig:getInstance():getPlatformName()

    -- log.date = os.date("%Y-%m-%d %H:%M:%S")
    log.date = os.time()

	if(self.tick > 0) then
		log.fps = self.fps / self.tick;
	else
		log.fps = 0;
	end

	local n = math.min(#self.fpsMinSet, 100)
	if(n > 0) then
		local t = 0
		for i = 1, n do
			t = t + self.fpsMinSet[i]
		end
		log.fpsMin = t / n;
	else
		log.fpsMin = 0
	end

	log.model = MetaInfo:getInstance():getDeviceModel()
	log.point = self.sceneName

	function testSerialize()
		table.serialize(log)
	end

	if(pcall(testSerialize)) then
		local json = table.serialize(log)
		return json
	else
		return nil
	end

end

function PerformanceLog:parseDateStringToTimestamp(string)
    local p = '(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)'
    local month, day, year, hour, min, sec = string:match(p)
	year = "20" .. year
--	return year .. "-" .. month .. "-" .. day .. " " .. hour .. ":" .. min .. ":" .. sec
    local t = os.time({day=day,month=month,year=year,hour=hour,min=min,sec=sec})
    return t
end

function PerformanceLog:uploadLog()
--[[
	local md5_path = HeResPathUtils:getResCachePath()
	local f = io.open(md5_path .. "/static_config.md5", 'r')
	if f then
  		local md5 = f:read("*all")
  		str = "client md5:"..md5.."\n"..str
  	end
 ]]


	local function onRegisterFinished( response )
		--done
	end

	local str = self:log()
	if(str) then
		he_log_info("performance log: " .. str)

		local url = "http://10.130.136.203:8008/animaltest"

		local request = HttpRequest:createPost(url)
		request:setConnectionTimeoutMs(2 * 1000)
		request:setTimeoutMs(30 * 1000)
		request:addHeader("Content-Type: application/json")
	    request:setPostData(str, string.len(str))

	    HttpClient:getInstance():sendRequestImmediate(onRegisterFinished, request)
	end
end


return PerformanceLog
