local Processor = class(EventDispatcher)
local kStorageFileName = "levelUpdate.inf"
local kTestDecodeFilename = "testLevelUpdate.inf"
local kLevelUpdateVersionFileName = "levelUpdateVersion"
local mime = require("mime.core")

function Processor:hasStorageConfig()
	local path = HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName
	local file, err = io.open(path, "r")

	if file and not err then
		local content = file:read("*a")
		io.close(file)
		if content then
			return content
		end
	end
    return nil
end

function Processor:getStorageConfig()
	if self:hasStorageConfig() then
		local path = HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName
		local decodeContent = HeFileUtils:decodeCustomizeFile(path)
		if decodeContent and decodeContent ~= "" then
			return decodeContent
		end
	end
    return nil
end

function Processor:writeNewConfigVersion(version)
	version = version or ""

	local filePath = HeResPathUtils:getUserDataPath() .. "/" .. kLevelUpdateVersionFileName
	local file, err = io.open(filePath, "wb")
    if file and not err then
    	local content = tostring(version)..","..tostring(_G.bundleVersion)
    	local success = file:write(content)
    	if success then
            file:flush()
            file:close()
            return true
        end
    end

    assert(false, "writeNewLevelUpdateConfigVersion failed:"..tostring(version))

    return false
end

function Processor:readLocalConfigVersion()
	local filePath = HeResPathUtils:getUserDataPath() .. "/" .. kLevelUpdateVersionFileName
	local file = io.open(filePath, "rb")
	if file then
		local content = file:read("*a") 
		file:close()
		if content then
			local arr = string.split(content, ",")
			if arr and arr[2] == _G.bundleVersion then
				return arr[1]
			end
		end
	end
	return nil
end

function Processor:handleConfigFromServer(config, version)
	if not config or config == "" or version == "" then
		return
	end
	local tmpFile = HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName .. "." .. os.time()
	local fileSize = HeMathUtils:base64DecodeToFile(config, string.len(config), tmpFile)
	if fileSize > 0 then
		local jsonContent = HeFileUtils:decodeCustomizeFile(tmpFile)
		local mapDataContent = table.deserialize(jsonContent)
		if mapDataContent then
			-- local storageConfig = self:getStorageConfig()
			local oldVersion = self:readLocalConfigVersion()
			-- 内容或版本号不一样才需要更新
			if oldVersion ~= version then -- storageConfig ~= jsonContent or
	            local realFilePath = HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName
		        os.remove(realFilePath)
		        os.rename(tmpFile, realFilePath)

		        self:writeNewConfigVersion(version)
				return
			end
		end
	else
        he_log_error("persistent level_update config file failure. version = " .. tostring(version))
	end
	-- 无效或无需更新时，删除临时文件
	os.remove(tmpFile)
end

function Processor:start()
	local function onUpdateConfigError( evt )
	    if evt and evt.target then evt.target:removeAllEventListeners() end
	    if _G.isLocalDevelopMode then printx(0, "loadLevelConfigDynamicUpdate error") end
        self:dispatchEvent(Event.new(Events.kError, nil, self))
	end

	local function onUpdateConfigFinish( evt )
	    if evt and evt.target then evt.target:removeAllEventListeners() end
	    if _G.isLocalDevelopMode then printx(0, "loadLevelConfigDynamicUpdate finished") end
	    if evt.data and evt.data.config then
	        self:handleConfigFromServer(evt.data.config, evt.data.md5)
	    end
		self:dispatchEvent(Event.new(Events.kComplete, nil, self))
	end 

    local osName = nil
    if __ANDROID then 
    	osName = "android"
    elseif __IOS then 
    	osName = "ios"
    elseif __WIN32 then -- for test
	    osName = "android"
    end
    local version = _G.bundleVersion
    local curMd5 = self:readLocalConfigVersion()

    local http = LevelConfigUpdateHttp.new()
    http:addEventListener(Events.kComplete, onUpdateConfigFinish)
    http:addEventListener(Events.kError, onUpdateConfigError)
    http:load(osName, version, curMd5)
end

return Processor
