--[[
 * AchiLevelRights
 * @date    2018-04-10 14:19:11
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local AchiLevelRights = {}

local LevelConfig = {}

function AchiLevelRights:init(rightsConfig)
	self.level = AchiLevelType.kNewer
	self.score = 0
	self.maxScore = 0
	self.maxLevel = 0

	for k,v in pairs(AchiLevelType) do
		self.maxLevel = self.maxLevel + 1
	end

	local achis = Achievement:getAchis()
	for id,achi in pairs(achis) do
		if achi.type ~= AchiType.SHARE then
			self.maxScore = self.maxScore + achi:getMaxScore()
		end
	end
	table.sort(rightsConfig, function ( p, n )
			return p.id < n.id
	end)

	for level,c in ipairs(rightsConfig) do
		table.insert(LevelConfig, c.points)
	end

	self.rightsConfig = rightsConfig
end

function AchiLevelRights:getConfig()
	return self.rightsConfig
end

--for test
function AchiLevelRights:test__reduceLevel()
	LevelConfig = {}
	for level,c in ipairs(self.rightsConfig) do
		table.insert(LevelConfig, c.points)
	end
	local curLevel = self.level
	local tarlevel = curLevel - 1
	if tarlevel <= 0 then return end

	LevelConfig[tarlevel] = self.score - 1
	for i=tarlevel+1,#LevelConfig do
		LevelConfig[i] = self.score + i*200
	end
	self:check()
end

--for test
function AchiLevelRights:test__addLevel()
	LevelConfig = {}
	for level,c in ipairs(self.rightsConfig) do
		table.insert(LevelConfig, c.points)
	end

	local curLevel = self.level
	local tarlevel = curLevel + 1
	if tarlevel > self.maxLevel then return end

	LevelConfig[tarlevel] = self.score
	for i=tarlevel+1,#LevelConfig do
		LevelConfig[i] = self.score + i*200
	end

	self:check()
end

function AchiLevelRights:dump()
	local data = {
		level = self.level,
		score = self.score,
		maxScore = self.maxScore,
		maxLevel = self.maxLevel,
		nextLevelScore = self:getLevelScore(self.level+1)
	}
	Achievement:print(table.tostring(data))
	return data
end

function AchiLevelRights:getLevelScore(level)
	return LevelConfig[level] or LevelConfig[#LevelConfig]
end

function AchiLevelRights:getLevel(score)
	local tarlevel = 0
	for level=#LevelConfig, 1, -1 do
		local tarscore = LevelConfig[level]
		if score >= tarscore then
			tarlevel = level break
		end
	end
	return tarlevel
end

function AchiLevelRights:check()
	local achis = Achievement:getAchis()
	self.score = 0

	local oldLevel = self.level

	for id,achi in pairs(achis) do
		if achi.type ~= AchiType.SHARE then
			self.score = self.score + achi:getScore(achi.level)
		end
	end

	self.level = self:getLevel(self.score)

	if oldLevel < self.level then
		Notify:dispatch("AchiUpgradeEvent")
	end
end

function AchiLevelRights:getRights( name )
	if self.rightsConfig then
		return self.rightsConfig[self.level] and self.rightsConfig[self.level][name] or 0
	end
	return 0
end

function AchiLevelRights:getExtraCount( tname )
	if tname == "SendReceiveEnergyNum" then
		return self:getRights("freegift")
	elseif tname == "MarkCoinIncomeTimes" then
		return self:getRights("markCoin")
	elseif tname == "FriendLevelCount" then
		return self:getRights("friendSubstitute")
	elseif tname == "FruitGetCount" then
		return self:getRights("fruit")
	elseif tname == "EnergyRecoveryUpperLimit" then
		return self:getRights("energy")
	end
	return 0
end

return AchiLevelRights