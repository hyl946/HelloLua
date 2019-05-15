LevelConfigGroupMgr = class()

local instance = nil
local GroupNumLimit = 5
local LevelIdPre = {
	kHide = "1",
	kMain = "2",
}
local FeatureNamePre = "LevelConfigGroup_"
function LevelConfigGroupMgr.getInstance()
	if not instance then
		instance = LevelConfigGroupMgr.new()
		instance:init()
	end
	return instance
end

function LevelConfigGroupMgr:init()
	self.groupConfig = {}
	self.levelIdMapping = {}

	self.oriLevelMap = {}
end

function LevelConfigGroupMgr:parseLevelRange(config, rangeStr)
	local rangeT1 = rangeStr:split(",")
	for i,v in ipairs(rangeT1) do
		if string.find(v, "-") then
			if not config.levelRanges then config.levelRanges = {} end
			local rangeT2 = v:split("-")
			local startLevel = tonumber(rangeT2[1])
			local endLevel = tonumber(rangeT2[2])
			local rangeT3 = {}
			if endLevel < startLevel then
				table.insert(rangeT3, endLevel)
				table.insert(rangeT3, startLevel)
			else
				table.insert(rangeT3, startLevel)
				table.insert(rangeT3, endLevel)
			end
			table.insert(config.levelRanges, rangeT3)
		else
			if not config.levelSaparate then config.levelSaparate = {} end
			-- insertIfNotExist
			table.insert(config.levelSaparate, tonumber(v))
		end
	end
end

function LevelConfigGroupMgr:parseTriggerVersion(config, childStr)
	local childT = childStr:split(";")
	local key = childT[1]
	local levelVersion = string.sub(key, 2) 
	if not config.groupTriggers then config.groupTriggers = {} end
	config.groupTriggers[key] = tonumber(levelVersion)
end

-- <maintenance id="1" child1="G1;1" child2="G0;1" child3="G2;1" extra = "950,1000-1050,1000" enable="true" mode="orthogonal_group" name="LevelTest" platform="default" version="default"/>  
-- {
--   1 = {
--     groupTriggers = {
--         G0 = 0,
--         G1 = 1,
--     },
--     featureName = "LevelConfigGroup_1",
--     levelSaparate = {
--         1 = 1,
--         2 = 7,
--     },
--     levelRanges = {
--         1 = {
--                 1 = 3,
--                 2 = 5,
--         },
--     },
--   },
-- }
function LevelConfigGroupMgr:initialize()
	for k,v in pairs(MetaManager.getInstance().level_config_group) do
		if v.enable == "true" then
			local isTimeEnable = true
			if v.endDate then 
				local endTime = os.time2(parseDate2Time(v.endDate))
				if Localhost:timeInSec() >= endTime then
					isTimeEnable = false
				end
			end
			local featureName = FeatureNamePre .. v.id
			if isTimeEnable then 
				local config = {}
				local maintenConfig = {}
				for i=1,GroupNumLimit do
					local key = "child" .. i
					local value = v[key]
					if value then
						maintenConfig[key] = value
						self:parseTriggerVersion(config, value)
					end
				end
				maintenConfig.enable = v.enable
				maintenConfig.name = featureName
				maintenConfig.mode = "orthogonal_group"
				config.featureName = featureName

				local maintenFeature = MaintenanceFeature.new()
				maintenFeature:fromLua(maintenConfig)
				MaintenanceManager:getInstance():addFeatureOutside(maintenFeature)
				
				self:parseLevelRange(config, v.extra)
				table.insert(self.groupConfig, config)
			else
				--clear local caches if exist
				MaintenanceManager:getInstance():clearSingleFeature(featureName)
			end
		end
	end
	-- printx(7, self:getRealLevelId(4), table.tostring(self.groupConfig))
end

function LevelConfigGroupMgr:setRealLevelIdToMapping(levelId, realLevelId)
	self.levelIdMapping[levelId] = realLevelId
end

function LevelConfigGroupMgr:getRealLevelIdFromMapping(levelId)
	return self.levelIdMapping[levelId]
end

--这里的clone会有警告 只在dev用 所以忽略
function LevelConfigGroupMgr:setOriLevelMapBeforeChange(singleLevelMap)
	if not singleLevelMap or self:isGroupLevel(singleLevelMap.id) or 
		self.oriLevelMap[singleLevelMap.id] then return end
	local data = table.clone(singleLevelMap)
	self.oriLevelMap[singleLevelMap.id] = data
end

function LevelConfigGroupMgr:getOriLevelMap(levelId)
	return self.oriLevelMap[levelId]
end

function LevelConfigGroupMgr:isGroupLevel(levelId)
	if (levelId > LevelConstans.MAIN_LEVEL_ID_GROUP_START and levelId <= LevelConstans.MAIN_LEVEL_ID_GROUP_END) or 
		(levelId > LevelConstans.HIDE_LEVEL_ID_GROUP_START and levelId <= LevelConstans.HIDE_LEVEL_ID_GROUP_END) then 
		return true
	else 
		return false 
	end
end

--level id with version
function LevelConfigGroupMgr:getRealLevelId(levelId)
	if _G.isCheckPlayModeActive or _G.isQAAutoPlayMode then
		return levelId
	end

	local realLevelId = self:getRealLevelIdFromMapping(levelId)
	if realLevelId then 
		return realLevelId 
	end

	if self:isGroupLevel(levelId) then
		return levelId 
	end

	local levelIdPre = nil
	if LevelType:isMainLevel(levelId) then
		levelIdPre = LevelIdPre.kMain
	elseif LevelType:isHideLevel(levelId) then
		levelIdPre = LevelIdPre.kHide
	end
	if not levelIdPre or not self.groupConfig then
		self:setRealLevelIdToMapping(levelId, levelId)
		return levelId 
	end

	for _,config in ipairs(self.groupConfig) do
		if not config.levelSaparate and not config.levelRanges or not config.groupTriggers then
			assert(false, 'wrong config!')
		end
		local hasLevelId = false
		if config.levelSaparate and table.includes(config.levelSaparate, levelId) then
			hasLevelId = true
		end
		if not hasLevelId and config.levelRanges then
			for _,levelRange in ipairs(config.levelRanges) do
				local levelRangeStart = tonumber(levelRange[1])
				local levelRangeEnd = tonumber(levelRange[2])
				if levelId >= levelRangeStart and levelId <= levelRangeEnd then
					hasLevelId = true 
				end 	
			end 
		end
		if hasLevelId then
			local uid = UserManager:getInstance().user.uid or '12345'
			for k,v in pairs(config.groupTriggers) do
				local key = tostring(k)
				if MaintenanceManager:getInstance():isEnabledInGroup(config.featureName, key, uid) then
					if key == "G0" then
						self:setRealLevelIdToMapping(levelId, levelId)
						return levelId
					else
						local levelIdTemp = levelId
						if levelIdPre == LevelIdPre.kHide then
							levelIdTemp = levelId - LevelConstans.HIDE_LEVEL_ID_START
						end
						realLevelId = tonumber(string.format("%s%04d%02d", levelIdPre, levelIdTemp, v))
						self:setRealLevelIdToMapping(levelId, realLevelId)
						return realLevelId
					end
				end
			end
			break 
		end
	end

	self:setRealLevelIdToMapping(levelId, levelId)
	return levelId
end