require "zoo.model.LuaXml"
require "zoo.data.MetaRef"

MetaClientTest = class(UnittestTask)

local function parseItemDict(metaXML, childName, cls )
	local result = {}
	
	local xmlList = xml.find(metaXML, childName)
	for i,v in ipairs(xmlList) do
		local p = cls.new()
		p:fromLua(v)
		result[p.id] = p
	end
	return result
end 

function MetaClientTest:ctor()
end

function MetaClientTest:run(callback_success_message)
	self:validate()

	callback_success_message(true, "")
end

function MetaClientTest:getNewestRet()
	local ret = {}

	-- --win32 test
	-- local path = "meta/meta_client.xml"
	-- path = CCFileUtils:sharedFileUtils():fullPathForFilename(path)
	-- local metaXML = xml.load(path)

	local path = CCFileUtils:sharedFileUtils():fullPathForFilename("meta/meta_client.inf")
	local meta_client = HeFileUtils:decodeFile(path)
	local metaXML = xml.eval(meta_client)

	-- 配置解析出错处理
	if not metaXML then
		callback_success_message(false, "parse metaXML failed")
	end

	local level_area = parseItemDict(metaXML, "level_area", LevelAreaMetaRef)
	for i,v in pairs(level_area) do
		if v.maxLevel == 9999 then 
			ret.has9999Level = true 
			break
		end
	end

	return ret
end

function MetaClientTest:getTargetRet()
	local ret = {}
	ret.has9999Level = true 			--是否有9999关标识max level

	return ret
end

function MetaClientTest:validate()
	local newestRet = self:getNewestRet()
	local targetRet = self:getTargetRet()

	table.compare(newestRet, targetRet)
end