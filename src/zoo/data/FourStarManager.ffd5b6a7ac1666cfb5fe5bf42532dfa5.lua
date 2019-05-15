FourStarManager = class()
local instance
function FourStarManager:getInstance( ... )
	-- body
	if not instance then
		instance = FourStarManager.new()
		instance:init()
	end
	return instance
end

function FourStarManager:init( ... )
	-- body
	self:readConfig()
end

function FourStarManager:getMyMainStar( ... )
	-- body
	return UserManager.getInstance().user:getStar()
end

function FourStarManager:getMaxMainStar( ... )
	-- body
	return UserManager:getInstance():getFullStarInOpenedRegion()
end

function FourStarManager:getMaxHideStar( ... )
	-- body
	return MetaModel.sharedInstance():getFullStarInOpenedHiddenRegion()
end

function FourStarManager:getMyHideStar( ... )
	-- body
	return  UserManager.getInstance().user:getHideStar()
end

--获取全部的四星关
function FourStarManager:getAllFourStarLevels( ... )
	-- body
	local list = {}
	for level = 1, kMaxLevels do 
		local targetScores =  MetaModel.sharedInstance():getLevelTargetScores(level)
		if targetScores and #targetScores > 3 and targetScores[4] > 0 then
			local data = {}
			data.level = level
			table.insert(list, data)
		end
	end

	return list
end

--用户能看见的所有主线四星关 已经三星的四星关和四星的四星关
function FourStarManager:getAllCompleteStar4LevelsIncludeStar3()
	local list = {}
	for level = 1, kMaxLevels do 
		local targetScores =  MetaModel.sharedInstance():getLevelTargetScores(level)
		if targetScores and #targetScores >= 4 and targetScores[4] > 0  then
			local star = 0
			local score = UserManager.getInstance():getUserScore(level)
			if score then
				star = score.star
			end

			local data = {}
			data.level = level
			data.star = star
			if star >= 3 then
				table.insert(list, data)
			end
		end
	end
	return list
end

--是否已经发现了所有的四星关
function FourStarManager:isFindAllStar4Levels()

	local isFindAll = true
	for level = 1, kMaxLevels do 
		local targetScores =  MetaModel.sharedInstance():getLevelTargetScores(level)
		if targetScores and #targetScores > 3 and targetScores[4] > 0  then
			local star = 0
			local score = UserManager.getInstance():getUserScore(level)
			if score then
				star = score.star
			end
			local data = {}
			data.level = level
			data.star = star
			if star < 3 then
				isFindAll = false
				return isFindAll
			end
		end
	end
	return isFindAll
end

--获取 4星关卡中大于三星的关
function FourStarManager:getAllCompleteStar4IncludeStar3()

	local list = {}
	for level = 1, kMaxLevels do 
		local targetScores =  MetaModel.sharedInstance():getLevelTargetScores(level)
		if targetScores and #targetScores > 3 and targetScores[4] > 0  then
			local star = 0
			local score = UserManager.getInstance():getUserScore(level)
			if score then
				star = score.star
			end

			local data = {}
			data.level = level
			data.star = star
			if star >= 3 then
				table.insert(list, data)
			end
		end
	end
	return list
end

function FourStarManager:getAllUnlockStar3LevelsNum()
	local dataList_3 ,dataList_4 = FourStarManager:getInstance():getAllUnlockStar4Levels()
	return #dataList_3
end

function FourStarManager:getAllUnlockStar4Levels()
	local list_3 = {}
	local list_4 = {}
	
	for level = 1, kMaxLevels do 
		local targetScores =  MetaModel.sharedInstance():getLevelTargetScores(level)
		if targetScores and #targetScores > 3 and targetScores[4] > 0  then
			local star = 0
			local score = UserManager.getInstance():getUserScore(level)
			if score then
				star = score.star
			end

			local data = {}
			data.level = level
			data.star = star
			if star == 4 then
				table.insert(list_4, data)
			elseif star == 3 then
				table.insert(list_3, data)
			end
		end
	end

	return list_3 , list_4
	
end


function FourStarManager:getAllCompleteFourStarLevels()

	local list = {}
	for level = 1, kMaxLevels do 
		local targetScores =  MetaModel.sharedInstance():getLevelTargetScores(level)
		if targetScores and #targetScores > 3 and targetScores[4] > 0  then
			local star = 0
			local score = UserManager.getInstance():getUserScore(level)
			if score then
				star = score.star
			end

			local data = {}
			data.level = level
			data.star = star
			if star == 4 then
				table.insert(list, data)
			end

		end
	end

	return list
	
end

--	已3星，尚未达到4星
function FourStarManager:getAllNotToFourStarLevels( ... )
	-- body
	local list = {}
	for level = 1, kMaxLevels do 
		local targetScores =  MetaModel.sharedInstance():getLevelTargetScores(level)
		if targetScores and #targetScores > 3 and targetScores[4] > 0  then
			local star = 0
			local score = UserManager.getInstance():getUserScore(level)
			if score then
				star = score.star
			end

			local data = {}
			data.level = level
			data.star = star
			if star < 4 then
				table.insert(list, data)
			end
		end
	end
	return list
end




--获取所有的4星关
function FourStarManager:getFourStarLevels( ... )
	-- body
	local list = {}
	for level = 1, kMaxLevels do 
		local targetScores =  MetaModel.sharedInstance():getLevelTargetScores(level)
		if targetScores and #targetScores > 3 and targetScores[4] > 0  then
			local star = 0
			local score = UserManager.getInstance():getUserScore(level)
			if score then
				star = score.star
			end
			local data = {}
			data.level = level
			data.star = star
			table.insert(list, data)
		end
	end
	return list
end


-- 所有未满级的隐藏关
function FourStarManager:getAllNotPerfectHiddenLevels(...)
	local hiddenNodeStart = 10001
	local hiddenNodeEnd = 19999

	local list = {}
	for level = hiddenNodeStart, kMaxHiddenLevel do 
		-- if _G.isLocalDevelopMode then printx(0, "===========> prepare to get ",level) end
		local branchId = MetaModel.sharedInstance():getHiddenBranchIdByHiddenLevelId(level)
		if not MetaModel.sharedInstance():isHiddenBranchDesign(branchId) then
			local targetScores =  MetaModel.sharedInstance():getLevelTargetScores(level)
			if targetScores then
				local star = 0
				local score = UserManager.getInstance():getUserScore(level)
				if score then
					star = score.star
				end
				local data = {}
				data.level = level
				data.star = star
				if star < 3 then
					table.insert(list, data)
				end
			end
		end
	end
	return list
end

function FourStarManager:getAllHiddenLevels(...)
	local hiddenNodeStart = 10001
	local hiddenNodeEnd = 19999

	local list = {}
	for level = hiddenNodeStart, kMaxHiddenLevel do 
		-- if _G.isLocalDevelopMode then printx(0, "===========> prepare to get ",level) end
		local branchId = MetaModel.sharedInstance():getHiddenBranchIdByHiddenLevelId(level)
		if not MetaModel.sharedInstance():isHiddenBranchDesign(branchId) then
			local targetScores =  MetaModel.sharedInstance():getLevelTargetScores(level)
			if targetScores then
				local star = 0
				local score = UserManager.getInstance():getUserScore(level)
				if score then
					star = score.star
				end
				local data = {}
				data.level = level
				data.star = star
				table.insert(list, data)
			end
		end
	end
	return list
end

--是否应该显示为4星 （四星展示需求）
function FourStarManager:shouldShouStar4(levelId)
	if levelId ==nil or levelId <= 0 then
		return false
	end
	local star = self:getStarWithLevelId( levelId )
	local isStar4Level = false
	local targetScores =  MetaModel.sharedInstance():getLevelTargetScores(levelId)
	if targetScores and #targetScores > 3 and targetScores[4] > 0 then
		isStar4Level = true
	end
	if isStar4Level and star == 3 then
		return true
	end
	return false
end
--根据关卡id得到这关的分数（好友代打和跳过都是0星算过关） 
function FourStarManager:getStarWithLevelId( level )
	if level==nil or level == 0 then
		return 0
	end

	local scoreOfLevel = UserManager:getInstance():getUserScore(level)
	if scoreOfLevel then
		if scoreOfLevel.star ~= 0 or 
			JumpLevelManager:getLevelPawnNum(level) > 0 or 
			UserManager:getInstance():hasAskForHelpInfo(level) then 
			if scoreOfLevel.star ==nil then
				return 0
			else
				return scoreOfLevel.star or 0
			end
		end
	else
		return 0 
	end
	return scoreOfLevel.star or 0

end
--判断这关过没过 （好友代打和跳过都是0星算过关） 
function FourStarManager:levelIsPassed( level )
	if level==nil or level == 0 then
		return false
	end
	local scoreOfLevel = UserManager:getInstance():getUserScore(level)
	if scoreOfLevel then
		if scoreOfLevel.star ~= 0 or 
			JumpLevelManager:getLevelPawnNum(level) > 0 or 
			UserManager:getInstance():hasAskForHelpInfo(level) then 
			return true
		end
	end
	return false
end

--判断这个玩家是否已经满星
function FourStarManager:playerIsFullStar()
	local userRef    = UserManager.getInstance().user
    local userStar = userRef:getStar()
    local userStar_Hide = userRef:getHideStar()
    local fullStar1 = UserManager:getInstance():getFullStarInOpenedRegionInclude4star() 
    local fullStar2 = MetaModel.sharedInstance():getFullStarInOpenedHiddenRegion()
    local fullStar =  fullStar1 + fullStar2
    local isFullStar = fullStar <= (userStar + userStar_Hide )
    return isFullStar
end

--这个关是四星关
function FourStarManager:isFourStarLevel( level )
	-- body
	local targetScores = MetaModel.sharedInstance():getLevelTargetScores(level)
	if targetScores and #targetScores > 3 and targetScores[4] > 0 then
		return true
	end
	return false
end

function FourStarManager:isGetFourStarInLevel( level )
	-- body
	local score = UserManager.getInstance():getUserScore(level)
	if score and score.star > 3 then
		return true
	end
	return false
end

function FourStarManager:writeConfig( ... )
	-- body
	local filePath = HeResPathUtils:getUserDataPath().."/four_star_guide"
	local file = io.open(filePath, "w")
	if file then
		file:write(table.serialize(self.config or {}))
		file:close()
	end
end

function FourStarManager:readConfig( ... )
	-- body
	local filePath = HeResPathUtils:getUserDataPath().."/four_star_guide"
	if not self.config then
		local file = io.open(filePath, "r")
		if file then
			local data = file:read("*a")
			file:close()
			if data then
				self.config = table.deserialize(data) or {}
			else
				self.config = {}
			end
		else
			self.config = {}
		end
	end
end

function FourStarManager:isTimeToShowGuide( level )
	-- body
	local time_now = os.time()
	local time_last
	for k, v in ipairs(self.config) do
		if v.level == level then
			if time_now - v.time >= 60 * 60 * 24 then
				v.time = time_now
				self:writeConfig()
				return true
			else
				return false
			end
		end

	end

	local data = {level = level, time = time_now}
	table.insert(self.config, data)
	self:writeConfig()
	return true
end

function FourStarManager:getLadyBugAnimationType( level, star )
	-- body
	local function randomFourstarLevel( minLevel, maxLevel )
		-- body
		local list = {}
		for k = minLevel, maxLevel do 
			if self:isFourStarLevel(k) and not self:isGetFourStarInLevel(k) then
				table.insert(list, k)
			end
		end

		if #list > 0 then
			return LadyBugFourStarAnimationType.kWithBtn, list[math.random(1, #list)]
		end
	end

	if self:isFourStarLevel(level) then
		if star and star == 4 then
			local topLevel = UserManager.getInstance().user:getTopLevelId()
			local _type, _level
			if level < topLevel then
				 _type, _level = randomFourstarLevel(level + 1, topLevel)
				if _type then 
					return _type, _level
				end
			end

			_type, _level = randomFourstarLevel(1, level - 1)
			if _type then 
				return _type, _level
			end

			for k = topLevel, kMaxLevels do 
				if self:isFourStarLevel(k) then
					return LadyBugFourStarAnimationType.kWithoutBtn, k
				end
			end
		elseif self:isGetFourStarInLevel(level) then
			return nil
		elseif self:isTimeToShowGuide(level) then
			return LadyBugFourStarAnimationType.kWithoutBtn
		end
	else
		return nil
	end
end