local kUdidConfig = HeResPathUtils:getUserDataPath().."/lkN90pqEZh.du"

UdidUtil = {}
function UdidUtil:getUdid()
	if kIsMockLoginMode and type(kMockLoginData) == "table" then
		return kMockLoginData.sk
	end
	local result = nil
	if not PlatformConfig:isAuthConfig(PlatformAuthEnum.kGuest) then
		local data = UdidUtil:readFromStorage()
		if data and data.udid ~= nil then result = data.udid end
		if _G.isLocalDevelopMode then printx(0, "OAuth user udid:"..tostring(result)) end
	end
	if result == nil then result = MetaInfo:getInstance():getUdid() end
	if _G.isLocalDevelopMode then printx(0, "MetaInfo:getInstance():getUdid() udid:"..tostring(result)) end
	return result
end

function UdidUtil:clearUdid()
	os.remove(kUdidConfig)
end

function UdidUtil:readFromStorage()
	local filePath = kUdidConfig
	local file = io.open(filePath, "rb")
	if file then
		local data = file:read("*a") 
		file:close()

		if data then
			local result = nil 
			local function decodeAmf3() result = amf3.decode(data) end
			pcall(decodeAmf3)
			if _G.isLocalDevelopMode then printx(0, "udid file found:"..tostring(table.tostring(result))) end
			return result
		end
	end
	if _G.isLocalDevelopMode then printx(0, "udid file not found"..filePath) end
	return nil
end
function UdidUtil:saveUdid(newUdid)
	local data = amf3.encode({udid=newUdid})
	local filePath = kUdidConfig
	
	local tmpName = filePath .. "." .. os.time()
    local file = io.open(tmpName, "wb")

    assert(file, "persistent udid file failure " .. tmpName)
    if not file then return end

    local success = file:write(data)

    if success then
        file:flush()
        file:close()
        os.remove(filePath)
        os.rename(tmpName, filePath)
        if _G.isLocalDevelopMode then printx(0, "write udid file success " .. filePath) end
    else
        file:close()
        os.remove(tmpName)
        if _G.isLocalDevelopMode then printx(0, "write udid file failure " .. tmpName) end
    end 
end

function UdidUtil:revertUdid()
	local defaultUDID = MetaInfo:getInstance():getUdid()
	UdidUtil:saveUdid(defaultUDID)
	if _G.isLocalDevelopMode then printx(0, "revertUdid") end
	return defaultUDID
end