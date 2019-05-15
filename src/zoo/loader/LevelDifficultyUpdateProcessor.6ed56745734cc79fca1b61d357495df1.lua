local Processor = class(EventDispatcher)
local LOCAL_FILE_NAME = "levelDifficulty.inf"
local LOCAL_FILE_VERSION_NAME = "levelDifficultyVersion"

function Processor:getLocalCofig()
	if self:getLocalVersion() ~= nil then--是否是当前客户端版本对应的配置
		local path = HeResPathUtils:getUserDataPath() .. "/" .. LOCAL_FILE_NAME
		local file, err = io.open(path, "r")
		if file and not err then
			local content = file:read("*a")
			io.close(file)
			if content then
				return content
			end
		end
	end
	return nil
end

function Processor:writeLocalVersion(version)
	version = version or ""
	local path = HeResPathUtils:getUserDataPath() .. "/" .. LOCAL_FILE_VERSION_NAME
	local file, err = io.open(path, "wb")
	if file and not err then
		local content = version .. "," .. _G.bundleVersion
		local success = file:write(content)
		if success then
			file:flush()
			file:close()
			return true
		end
	end
	return false
end

function Processor:getLocalVersion()
	local path = HeResPathUtils:getUserDataPath() .. "/" .. LOCAL_FILE_VERSION_NAME
	local file = io.open(path, "rb")
	if file then
		local content = file:read("*a")
		file:close()
		if content then
			local infoAry = string.split(content, ",")
			if infoAry ~= nil and infoAry[2] == _G.bundleVersion then
				return infoAry[1]
			end
		end
	end

	return nil
end

function Processor:writeLocalConfig(config)
	local path = HeResPathUtils:getUserDataPath() .. "/" .. LOCAL_FILE_VERSION_NAME .. os.time()
	local file, err = io.open(path, "wb")
	if file and not err then
		local success = file:write(config)
		if success then
			file:flush()
			file:close()
			local oldFilePath = HeResPathUtils:getUserDataPath() .. "/" .. LOCAL_FILE_NAME
			os.remove(oldFilePath)
			os.rename(path, oldFilePath)
			return true
		else
			file:close()
			os.remove(path)
			he_log_error("write file failure " .. path)
		end
	else
		he_log_error("persistent file failure " .. LOCAL_FILE_VERSION_NAME .. ", error: " .. err)
	end
	return false
end

function Processor:getServerConfig(config, version)
	local localConfig = self:getLocalCofig()
	local localVersion = self:getLocalVersion()
	if localConfig ~= config or localVersion ~= version then
		local writeSuccess = self:writeLocalConfig(config)
		if writeSuccess then
			if self:writeLocalVersion(version) then
				MetaManager:getInstance().level_difficulty = table.deserialize(config) or {}
			end
		end
	end
end

function Processor:start()
	local function onError(evt)
		if evt and evt.target then evt.target:removeAllEventListeners() end
		if _G.isLocalDevelopMode then printx(0, "loadLevelDifficultyConfigDynamicUpdate error") end
	end

	local function onSucess(evt)
		if evt and evt.target then evt.target:removeAllEventListeners() end
		if _G.isLocalDevelopMode then printx(0, "loadLevelDifficultyConfigDynamicUpdate finished") end
		if evt.data and evt.data.config then
			self:getServerConfig(evt.data.config, evt.data.md5)
		end
	end

	local clientVersion = _G.bundleVersion
	local localCfgVersion = self:getLocalVersion() or ""
	local http = LevelDifficultyUpdate.new()
	http:addEventListener(Events.kComplete, onSucess)
	http:addEventListener(Events.kError, onError)
	http:load(clientVersion, localCfgVersion)
end

return Processor