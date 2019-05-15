require "zoo.gamePlay.CheckPlay"
local simplejson = require("cjson")

QACheckPlayManager = class()

local instance = nil
function QACheckPlayManager.getInstance()
	if not instance then
		instance = QACheckPlayManager.new()
		instance:init()
	end
	return instance
end

local kResultFileName = "qa_check_result"
local kResultFileExt = ".lua"
local kSourceFileName = "qa_check_source"
local kSourceFileExt = ".txt"
function QACheckPlayManager:init()
	self.checkIndex = 0
	self.results = {}
	self.results.sucLevels = {}
	self.results.startTime = os.date('%Y-%m-%d %H:%M:%S', os.time())
	--获取本地replay关卡数据
	self.checkDatas = {}
	self.pathPre = _G.launchCmds.path or HeResPathUtils:getUserDataPath() 
	local path = self.pathPre .. "/" .. kSourceFileName .. kSourceFileExt
	local file, err = io.open(path, "r")
	if file and not err then
		-- --读取整个文件
		-- local content = file:read("*a")
		-- self.checkDatas = simplejson.decode(content)

		--读取每一条
		local lineNum = 1
		local content = file:read("*l")
		while(content) do
			local ct = simplejson.decode(content)
			ct.lineNum = lineNum
			table.insert(self.checkDatas, ct)
			content = file:read("*l")
			lineNum = lineNum + 1
		end
		io.close(file)
	else
		self:catchException("open "..kSourceFileName.." failed when init called")
	end
end

function QACheckPlayManager:flush(results)
	local filePath = self.pathPre .. "/" .. kResultFileName .. kResultFileExt
    local file = io.open(filePath, "w")
    
    if not file then 
    	self:catchException("open "..kResultFileName.." failed when flush called 1")
    	return 
    end

	local success = file:write(table.tostring(results))
   
    if success then
        file:flush()
        file:close()
    else
        file:close()
        self:catchException("open "..kResultFileName.." failed when flush called 2")
    end
end

function QACheckPlayManager:updateLastResult(errCode)
	local playData = self.checkDatas[self.checkIndex]
	if errCode == 200 or errCode == 4 or errCode == 5 then
		table.insert(self.results.sucLevels, playData.level)
	else 
		if not self.results["failLevels_"..errCode] then 
			self.results["failLevels_"..errCode] = {}
		end
		local result = {}
		result.levelId = playData.level
		result.lineNum = playData.lineNum
		result.randomSeed = playData.randomSeed
		table.insert(self.results["failLevels_"..errCode], result)
	end
end

function QACheckPlayManager:catchException(str)
	self.results.errorLog = str
end

function QACheckPlayManager:check()
	self.checkIndex = self.checkIndex + 1
	local playData = self.checkDatas[self.checkIndex]
	if playData then
		HeGameDefault:setFpsValue(6000)
		CheckPlay:resetCheckId()
		CheckPlay:setQACheckData(playData.score)
		CheckPlay:check(self.checkIndex, nil, playData, nil, ReplayMode.kQACheck)
	else
		self.results.endTime = os.date('%Y-%m-%d %H:%M:%S', os.time())
		QACheckPlayManager.getInstance():flush(self.results)
		CCDirector:sharedDirector():endToLua()
	end
end