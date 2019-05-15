require "hecore.class"
require "hecore.utils"
require "zoo.model.LuaXml"
require "zoo.data.DataRef"
require "zoo.util.AlertDialogImpl"


local debugDataRef = false
--
-- LevelMapManager ---------------------------------------------------------
--
--LevelMapManager = class()

local instance = nil
LevelMapManager = {
}
-- private
local levelMap = nil
local originLevelMap = nil
local kStorageFileName = "levelUpdate.inf"
local kLevelUpdateVersionFileName = "levelUpdateVersion"
local maxLevelId = 1
local maxMainLevelId = 1
local maxHiddenLevelId = 0

function LevelMapManager.getInstance()
	if not instance then instance = LevelMapManager end
	return instance
end

function LevelMapManager:initialize(path)
	path = path or "meta/customize.inf"
	path = CCFileUtils:sharedFileUtils():fullPathForFilename(path)
	local customize = HeFileUtils:decodeCustomizeFile(path)
	local gameConfigData  = table.deserialize(customize)
	assert(gameConfigData)

	-- 配置解析出错处理
	if not gameConfigData then
		--[[
		local filemd5 = ""
		if not string.starts(path, "apk") then
			filemd5 = HeMathUtils:md5File(path)
		end
		local content = string.sub(tostring(customize), 1, 100)
		he_log_error(string.format("meta error: path:%s,md5:%s,content:%s", path, filemd5, content))
		]]

		if __ANDROID then
			local function onOK()
		        -- CCDirector:sharedDirector():endToLua()
				local applicationHelper =  luajava.bindClass("com.happyelements.android.ApplicationHelper")
				applicationHelper:restart(1000);
			end

			AlertDialogImpl:alert( "ERROR!", "检测到资源错误，请重启游戏", '确认', '取消', onOK, nil, nil)
		end
	end

	levelMap = {}
	if _G.isCheckPlayModeActive then originLevelMap = {} end
	

	-- local mem4 = collectgarbage("count")
	-- printx(10, "\nmemory is", mem4, "kb")

	customize = nil
	self.gameConfigData = gameConfigData
	-- collectgarbage("collect")

	-- local mem4 = collectgarbage("count")
	-- printx(10, "\nafter collect again memory is", mem4, "kb")

	------------------------
	-- Other Data About Level
	-- ---------------------
	self.hiddenNodeRange = 10000
end

function LevelMapManager:addToLoader( loader )
	for i,v in ipairs(self.gameConfigData) do
		loader:add(v, kFrameLoaderType.level)
	end

 	self.loader_count = 0
 	self.max_loader_count = #self.gameConfigData
 	self.gameConfigData = nil
end

function LevelMapManager:loadSingleLevel(source)
	local data = self:createLevelMeta(source)
	levelMap[data.id] = data
	
	if _G.isCheckPlayModeActive then 
		local data = self:createLevelMeta(source, false, true)
		originLevelMap[data2.id] = data
	end

	self.loader_count = self.loader_count + 1

	if self.loader_count >= self.max_loader_count then
		self:loadFinshed()
	end
end

function LevelMapManager:loadFinshed()
	self:updateMaxLevelIds()
	self:initMaxLevelConfig()
end

function LevelMapManager:createLevelMeta(src, isFromUpdate, isOld)
	local data = LevelMapMeta.new(true, isFromUpdate, isOld)
	local md5, _amf3
	pcall(function ()
		md5 = HeMathUtils:md5( table.serialize( src ) )
	end)
	pcall(function ()
		_amf3 = amf3.encode( src )
	end)
	data.contentTable = {md5, _amf3}
	data:fromLua(src)

	if not isOld then
		data.gameData = nil
	end

	return data
end

local MAX_CACHE_NUM = 10

function LevelMapManager:initGameData( v )
	local data = LevelGameData.new()
	data:fromLua(v)
	return data
end

function LevelMapManager:getLevelGameData( meta )
	self.gameDataCaches = self.gameDataCaches or {}

	local levelId = meta.id
	local isFromUpdate = meta.isFromUpdate

	if _G.isLocalDevelopMode then
		self.getLevelGameDataCount = self.getLevelGameDataCount or 0
		self.getLevelGameDataCount = self.getLevelGameDataCount + 1
		printx(10, 'getLevelGameData :', self.getLevelGameDataCount, levelId)
	end

	--cache
	local target = table.find(self.gameDataCaches, function ( v )
		return v.levelId == levelId
	end)

	local realLevelId = meta.metaLevelId or meta.id
	if target then
		local index = table.indexOf(self.gameDataCaches, target)
		if target.metaLevelId and target.metaLevelId ~= realLevelId then
			table.remove(self.gameDataCaches, index)
		else
			local max = #self.gameDataCaches
			if index ~= max then
				table.insert(self.gameDataCaches, target)
				table.remove(self.gameDataCaches, index)
			end
			return target
		end
	end

	--load data
	local data = LevelGameData.new()
	local ldata = self:loadLevelData(realLevelId, isFromUpdate)
	if not ldata then
		he_log_error(realLevelId..' faild to load level config!')
	end
	data:fromLua(ldata.gameData)
	data.levelId = levelId
	data.metaLevelId = realLevelId

	table.insert(self.gameDataCaches, data)
	
	if MAX_CACHE_NUM < #self.gameDataCaches then
		table.remove(self.gameDataCaches, 1)
	end

	return data
end

function LevelMapManager:loadLevelData(levelId, isFromUpdate)
	if _G.isLocalDevelopMode then
		self.__realLoadLevelCount = self.__realLoadLevelCount or 0
		self.__realLoadLevelCount = self.__realLoadLevelCount + 1
		printx(10, 'real loadLevelData :', self.__realLoadLevelCount, levelId)
		printx(10, '\n\n********************' .. tostring(levelId) .. '********************\n' .. debug.traceback() .. '\n\n')
	end

	local path = CCFileUtils:sharedFileUtils():fullPathForFilename("meta/customize.inf")
	if isFromUpdate then
		path = HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName
	end
	local str = HeFileUtils:decodeLevelMeta(path, levelId, isFromUpdate)

	return table.deserialize(str)
end

function LevelMapManager:initMaxLevelConfig()
	-- 排除过高的关卡
	kMaxLevels = MetaManager:getInstance():getMaxNormalLevelByLevelArea()
	if (_G.isPrePackage) then
		kMaxLevels = _G.prePackageMaxLevel
	end
	local validMaxMainLineLevelId = self:calcMaxMainLineLevelId()
	if kMaxLevels > validMaxMainLineLevelId then
		_G._MAIN_LEVEL_META_ERROR = {meta = kMaxLevels, config = validMaxMainLineLevelId}
		kMaxLevels = validMaxMainLineLevelId
	end
	-- 计算最高隐藏关
	kMaxHiddenLevel = 0
	if MetaManager:getInstance().hide_area then
		for k, v in pairs(MetaManager:getInstance().hide_area) do
			if (v.hideLevelRange) then 
				if ( kMaxHiddenLevel < v.hideLevelRange[#v.hideLevelRange]) then 
					kMaxHiddenLevel = v.hideLevelRange[#v.hideLevelRange]
				end
			end
		end
		kMaxHiddenLevel = 10000 + kMaxHiddenLevel
		local validMaxHiddenLevelId = self:calcMaxHiddenLevelId()
		if validMaxHiddenLevelId > 0 and kMaxHiddenLevel > validMaxHiddenLevelId then
			_G._HIDDEN_LEVEL_META_ERROR = {meta = kMaxHiddenLevel, config = validMaxHiddenLevelId}
			kMaxHiddenLevel = validMaxHiddenLevelId
		end
		if (_G.isPrePackage) then
			kMaxHiddenLevel = 10033
		end
	end
end

function LevelMapManager:updateMaxLevelIds()
	for k, v in pairs(levelMap) do 
		if maxLevelId < k then
			maxLevelId = k
		end
		if k < 9999 and maxMainLevelId < k then 
			maxMainLevelId = k
		elseif k >= 10000 and k < 19999 and maxHiddenLevelId < k then 
			maxHiddenLevelId = k
		end
	end
end

function LevelMapManager:isNormalNode(nodeId, ...)
	assert(type(nodeId) == "number")
	assert(#{...} == 0)

	return tonumber(nodeId) < self.hiddenNodeRange
end

-- 到toLevel的全部主线关最高星级，包含toLevel
function LevelMapManager:getTotalStar(toLevel)
	local ret = 0
	for i=1,toLevel do
		ret = ret + levelMap[i]:getTotalStarNumber()
	end
	return ret
end


function LevelMapManager:getLevelDisplayName(levelId)
	if LevelConfigGroupMgr.getInstance():isGroupLevel(levelId) then
		return levelId
	end

	if self:isNormalNode(levelId) then
		return levelId
	else
		return "+" .. (levelId - self.hiddenNodeRange)
	end
end

local function getStorageLevelUpdateConfig()
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

local function getStorageLevelUpdateConfigVersion()
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

local kTestLevelConfig = "level_test_update"
local function getTestLevelConfig()
	local filePath = HeResPathUtils:getUserDataPath() .. "/" .. kTestLevelConfig
	local file = io.open(filePath, "rb")
	if file then
		local content = file:read("*a") 
		file:close()
		if content then
			local levelConfigs = nil
			pcall(function() levelConfigs = table.deserialize(content) end)
			-- if _G.isLocalDevelopMode then printx(0, "test level config:", table.tostring(levelConfigs)) end
			return levelConfigs
		end
	end
	return nil
end

function LevelMapManager:invalidLevelUpdate( ... )
	self.hasLoadLevelUpdate = false
end

-- 获取原始关卡信息 类型为LevelMapMeta{id, gameData, score1, score2, score3, score4}
function LevelMapManager:getMeta( levelId )
	if _G.isCheckPlayModeActive then 
		local diffTable = CheckPlay:getCheckPlayDiffTable()
		if diffTable and type(diffTable) == "table" then
			levelMap = {}

			for i, v in pairs(originLevelMap) do
				levelMap[v.id] = v
			end

			for i, v in ipairs(diffTable) do
				levelMap[data.id] = self:createLevelMeta(v, true, true)
			end

			self.levelUpdateVersion = "12345"
		end
	else
		if not self.hasLoadLevelUpdate then
			self.hasLoadLevelUpdate = true
			local updateCfgVer = getStorageLevelUpdateConfigVersion()
			if updateCfgVer then
				local storageConfig = getStorageLevelUpdateConfig()
				if storageConfig then
					local path = HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName
					local decodeContent = HeFileUtils:decodeCustomizeFile(path)
					if decodeContent and decodeContent ~= "" then
						local jsonContent = table.deserialize(decodeContent)
						if jsonContent and type(jsonContent) == "table" then
							for i, v in ipairs(jsonContent) do
								local data = self:createLevelMeta(v, true)
								levelMap[data.id] = data
							end
							self:updateMaxLevelIds()
						end
					end
					self.levelUpdateVersion = updateCfgVer
				end
			end
		end
		if isLocalDevelopMode and not self.hasLoadTestLeveConfig then
			self.hasLoadTestLeveConfig = true
			local levelConfigs = getTestLevelConfig()
			if levelConfigs then
				local updateLevels = {}
				for _, v in pairs(levelConfigs) do
					local data = self:createLevelMeta(v, true, true)
					levelMap[data.id] = data
					table.insert(updateLevels, data.id)
				end
			end
		end
	end

	local realLevelId = LevelConfigGroupMgr.getInstance():getRealLevelId(levelId)
	self:changeMetaByLevelId(levelId, realLevelId)

	if _G.isLocalDevelopMode and _G.isQAAutoPlayMode then
		local levelMapCache = LevelConfigGroupMgr.getInstance():getOriLevelMap(levelId)
		if levelMapCache and (not levelMap[levelId] or (levelMap[levelId].levelSig ~= levelMapCache.levelSig)) then
			levelMap[levelId] = levelMapCache
		end
	end

	return levelMap[levelId]
end

function LevelMapManager:changeMetaByLevelId(levelId, realLevelId)
	if levelId ~= realLevelId then
		if not levelMap[realLevelId] then
			assert(false, 'level config is not exist '..realLevelId)
		end
		if not levelMap[levelId] or (levelMap[levelId].levelSig ~= levelMap[realLevelId].levelSig) then 
			if _G.isLocalDevelopMode then
				LevelConfigGroupMgr.getInstance():setOriLevelMapBeforeChange(levelMap[levelId])
			end
			levelMap[levelId] = levelMap[realLevelId]
			levelMap[levelId].id = levelId 
			levelMap[levelId].metaLevelId = realLevelId
			if levelMap[levelId].gameData then 					--old
				levelMap[levelId].gameData.levelId = levelId
			end 
			LevelDataManager.sharedLevelData():clearLevelConfigById(levelId)
		end
	end
end

function LevelMapManager:getMetaLevelId(levelId)
	return levelMap[levelId] and levelMap[levelId].metaLevelId or levelId
end

function LevelMapManager:getLevelUpdateVersion()
	return self.levelUpdateVersion
end

function LevelMapManager:getMaxLevelId( ... )
	return maxLevelId
end

function LevelMapManager:getMaxMainLineLevelId( ... )
	return maxMainLevelId
end

function LevelMapManager:getMaxHiddenLevelId( ... )
	if maxHiddenLevelId > kMaxHiddenLevel then
		return kMaxHiddenLevel
	else
		return maxHiddenLevelId
	end
end

function LevelMapManager:calcMaxLevelId( ... )
	-- body
	local result = 1
	for k, v in pairs(levelMap) do 
		if result < k then 
			result = k
		end
	end
	maxLevelId = result
	return result
end

function LevelMapManager:calcMaxMainLineLevelId( ... )
	-- body
	local result = 1
	for k, v in pairs(levelMap) do 
		if result < k and k < 9999 then 
			result = k
		end
	end
	maxMainLevelId = result
	return result
end

function LevelMapManager:calcMaxHiddenLevelId( ... )
	local result = 0
	for k, v in pairs(levelMap) do 
		if k >= 10000 and k < 19999 and result < k then 
			result = k
		end
	end
	maxHiddenLevelId = result
	return result
end

function LevelMapManager:addDevMeta( v )
	-- body
	local data = LevelMapMeta.new(true, false, true)
	data:fromLua(v)
	levelMap[data.id] = data
end

function LevelMapManager:getLevelGameMode( levelId )
	if levelId == 0 then return 0 end

	local levelMeta = self:getMeta(levelId)
	if levelMeta then
		local gameData = levelMeta.gameData
		if gameData then
			if LevelType:isSummerMatchLevel( levelId ) then
				return self:getLevelGameModeByName(  GameModeType.SUMMER_WEEKLY )
			else
				return self:getLevelGameModeByName(gameData.gameModeName)
			end
		end
	end
	return nil
end

function LevelMapManager:getLevelGameModeByName( gameModeName )
	local result = getGameModeTypeIdFromModeType(gameModeName)
	if result == nil then
		if _G.isLocalDevelopMode then printx(0, "getLevelGameMode", gameModeName, result) end
	end
	return result
end

function LevelMapManager:isDigMoveEndlessLevel(levelId)
	return self:getLevelGameMode(levelId) == GameModeTypeId.DIG_MOVE_ENDLESS_ID
end

function LevelMapManager:isMaydayEndlessLevel(levelId)
	return self:getLevelGameMode(levelId) == GameModeTypeId.MAYDAY_ENDLESS_ID
end

function LevelMapManager:isRabbitWeeklyLevel(levelId)
	return self:getLevelGameMode(levelId) == GameModeTypeId.RABBIT_WEEKLY_ID
end

function LevelMapManager:getAllLevelId()
	local result = {}
	for levelId, __ in pairs(levelMap) do
		table.insert(result, levelId)
	end
	return result
end

function LevelMapManager:getTotalStarNumberByAreaId( areaId )
	-- body
	local result = 0

	for k = (areaId - 1) * 15 + 1, areaId * 15 do 
		result = result + self:getMeta(k):getTotalStarNumber()
	end

	return result
end

--
-- LevelGameData ---------------------------------------------------------
--
LevelGameData = class(DataRef)
function LevelGameData:ctor()
	self.addMoveBase = GamePlayConfig_Add_Move_Base
	self.clearTargetLayers = 0
	self.confidence = 0
	self.digTileMap = {}
	self.digTileSpecialAnimalMap = {}
	self.dropRules = {}
	self.gameModeName = GameModeType.ORDER
	self.moveLimit = 0
	self.numberOfColours = 0
	self.portals = {}
	self.randomSeed = 0
	self.scoreTargets = {0,0,0}
	self.specialAnimalMap = {}
	self.tileMap = {}
	self.seaAnimalMap = {}
	self.seaFlagMap = {}
	self.dropBuff = {}
	self.levelId = 0
end

--
-- LevelMapMeta ---------------------------------------------------------
--
LevelMapMeta = class() 
function LevelMapMeta:ctor(isInit, isFromUpdate, isOld)
	self.isInit = isInit
	self.isFromUpdate = isFromUpdate
	self.id = 0
	self.score1 = 0
	self.score2 = 0
	self.score3 = 0
	self.score4 = 0
	self.scoreTargets = {}

	self.totalLevel = 0
	self.levelSig = nil
	self.isOld = isOld
	if isOld then
		self.gameData = LevelGameData.new()
	else
		local mt = getmetatable(self)
		local ori = mt.__index
		local data = {
			__index = function ( t, k )
				if k == "gameData" then
					return LevelMapManager:getLevelGameData(self)
				end
				return ori[k]
			end
		}
		setmetatable(data, data)
		mt.__index = data
	end
end
function LevelMapMeta:getStar( score )
	if self.score4 > self.score3 and score >= self.score4 then return 4
	elseif score >= self.score3 then return 3
	elseif score >= self.score2 then return 2
	elseif score >= self.score1 then return 1
	else return 0 end
end
function LevelMapMeta:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil") end
		return
	end

	for k,v in pairs(src) do
		if k == "gameData" then
			if not self.isOld then
				self.gameData = LevelMapManager.getInstance():initGameData( v )
			else
				self.gameData:fromLua(v)
			end
		else
			self[k] = v
			if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
		end		
	end

	assert(self.gameData, "gameData should be non nil")
	self.id = self.totalLevel

	assert(#self.gameData.scoreTargets>2, "scoreTargets should be more than 3")

	self:updateScoreTargets()
end

function LevelMapMeta:updateScoreTargets()
	self.scoreTargets = {}
	self.score1 = self.gameData.scoreTargets[1]
	self.scoreTargets[1] = self.score1

	self.score2 = self.gameData.scoreTargets[2]
	self.scoreTargets[2] = self.score2

	self.score3 = self.gameData.scoreTargets[3]
	self.scoreTargets[3] = self.score3

	if not self.isInit and NewAreaOpenMgr.getInstance():isOnlineCheckFourStar(self.id) then 
		self.score4 = 0
		self.scoreTargets[4] = nil
	else
		self.isInit = false
		if #self.gameData.scoreTargets == 4 then
			self.score4 = self.gameData.scoreTargets[4]
			self.scoreTargets[4] = self.score4
		else
			self.score4 = 0
		end
	end

	if debugDataRef then if _G.isLocalDevelopMode then printx(0, self.id, self.score1, self.score2, self.score3, self.score4) end end
end

function LevelMapMeta:getScoreTargets()
	return self.scoreTargets
end

function LevelMapMeta:getTotalStarNumber()
	return #self.scoreTargets
end

function LevelMapMeta:getMoveLimit()
	return self.gameData.moveLimit
end