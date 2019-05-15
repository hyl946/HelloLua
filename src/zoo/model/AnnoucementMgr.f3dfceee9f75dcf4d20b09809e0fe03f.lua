
AnnoucementMgr = class()

AnnouncementPosType = {
	kHome = "home",
	kLoading = "loading",	
}

local instance = nil
local configPath = HeResPathUtils:getUserDataPath() .. "/AnnouncementConfig" 
local AnnouncementCD = {
	[AnnouncementPosType.kHome] = 24 * 3600,
	[AnnouncementPosType.kLoading] = 0	
}

function AnnoucementMgr.getInstance()
	if not instance then
        instance = AnnoucementMgr.new()
        instance:init()
    end
    return instance
end

function AnnoucementMgr:init()
	self.config = self:readConfig()
end

function AnnoucementMgr:refreshLocalData(posType, announcements)
	local config = self:getConfig()
	for k,v in pairs(announcements) do
		if type(v) == "table" and v.id then 
			if not config[v.id] then 
				config[v.id] = { times = 0 }
			end
			config[v.id].times = config[v.id].times + 1
		end
	end
	if posType == AnnouncementPosType.kHome then 
		config.lastPopout = os.time()
	end
	self:writeConfig(config)
end

function AnnoucementMgr:readConfig()
	local file = io.open(configPath, "r")
	if file then
		local data = file:read("*a") 
		file:close()
		if data then
			return table.deserialize(data) or {}
		end
	end
	return {}
end

function AnnoucementMgr:writeConfig(data)
	self.config = data
	local file = io.open(configPath,"w")
	if file then 
		file:write(table.serialize(data or {}))
		file:close()
	end
end

function AnnoucementMgr:getConfig()
	return self.config
end

function AnnoucementMgr:loadAnnouncement(posType, callback)
	local config = self.config

	local cd = AnnouncementCD[posType] or AnnouncementCD[AnnouncementPosType.kHome]
	if os.time() - (config.lastPopout or 0) < cd then 
		callback(nil)
		return
	end

	local function onCallback(response)
		if response.httpCode ~= 200 then 
			callback(nil)
		else
			callback(response.body)
		end
	end

	local url = NetworkConfig.maintenanceURL
	local uid = UserManager.getInstance().uid

	local params 
	if uid then
		params = string.format("?name=announcement&_v=%s&scene=%s&uid=%s", _G.bundleVersion, posType, tostring(uid))
	else
		params = string.format("?name=announcement&_v=%s&scene=%s", _G.bundleVersion, posType)
	end
	url = url .. params
	if _G.isLocalDevelopMode then printx(0, url) end

	local request = HttpRequest:createGet(url)

	local timeout = 3
  	local connection_timeout = 2

  	if __WP8 then 
    	timeout = 30
    	connection_timeout = 5
  	end

    request:setConnectionTimeoutMs(connection_timeout * 1000)
    request:setTimeoutMs(timeout * 1000)

    if not PrepackageUtil:isPreNoNetWork() then 
   		HttpClient:getInstance():sendRequest(onCallback, request)
   	else
	    if _G.isLocalDevelopMode then printx(0, "AnnouncementPanel================no network prepackage") end
   	end
end

function AnnoucementMgr:parseAnnouncement(content)
	local announcementXML = xml.eval(content)
	local announcements = xml.find(announcementXML, "announcement")

	if not announcements then
		return {}
	end

	local platformName = StartupConfig:getInstance():getPlatformName()
	local config = self.config

	local function filter( group )
		-- do 
		-- 	return group[1]
		-- end
		local v = table.find(group,function(a) 
			if a.enable == "false" then 
				if not a.version then
					he_log_error("invalid announcement:" .. table.tostring(a))
					return false
				end
				return (a.version == "default" or table.exist(a.version:split(","),_G.bundleVersion)) and 
			   			(a.platform == "default" or table.exist(a.platform:split(","),platformName)) 
			end
			return false
		end)
		if v then
			return nil
		end

		local g = table.filter(group,function(a) return a.enable ~= "false"  end)
		local v = table.find(g,function(a) 
			local versionStr = _G.bundleVersion
			if _G.isLocalDevelopMode then
				local array = versionStr:split(".")
				versionStr = array[1].."."..array[2]
			end
			return table.exist(a.version:split(","),versionStr) and table.exist(a.platform:split(","),platformName)
		end)
		if v then 
			return v
		end

		local v = table.find(g,function(a) 
			return a.version == "default" and table.exist(a.platform:split(","),platformName)
		end)
		if v then 
			return v
		end

		local v = table.find(g,function(a) 
			return table.exist(a.version:split(","),_G.bundleVersion) and a.platform == "default"
		end)
		if v then
			return v
		end

		local v = table.find(g,function(a)
			return a.version == "default" and a.platform == "default" 
		end)
		if v then 
			return v
		end

		-- for k,v in pairs(group) do
		-- 	if v.enable ~= "false" then

		-- 		if (v.version == "default" or table.exist(v.version:split(","),_G.bundleVersion)) and 
		-- 		   (v.platform == "default" or table.exist(v.platform:split(","),platformName)) then 
		-- 			return v
		-- 		end	
		-- 	end
		-- end
		return nil
	end

	local ret = {}
	local announcements = table.filter(announcements,function(v) return type(v) == "table" end)
	for _,v in pairs(table.groupBy(announcements,function(a) return a.key or "" end)) do
		local v2 = filter(v)
		if v2 then 
			ret[v2.id] = v2
		end
	end

	ret = table.filter(ret,function(v)  
		local times = tonumber(v.times) or -1
		if times > 0 and config[v.id] then 
			if config[v.id].times >= times then
				return false
			end
		end
		return true
	end)

	table.sort(ret,function(a,b) return tonumber(a.id) < tonumber(b.id) end)
	return ret
end