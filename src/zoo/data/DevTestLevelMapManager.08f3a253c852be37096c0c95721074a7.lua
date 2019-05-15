local instance = nil
DevTestLevelMapManager = {}

function DevTestLevelMapManager.getInstance()
	if not instance then instance = DevTestLevelMapManager end
	return instance
end

function DevTestLevelMapManager:getConfig(fileName)
	local path = "meta/" .. fileName
	path = CCFileUtils:sharedFileUtils():fullPathForFilename(path)

	local ret = lua_read_file(path)
	--local ret = file:read("*a")
	--file:close()

	return ret
end

