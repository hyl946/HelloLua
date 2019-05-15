local ACT_SOURCE = 'FindingTheWay/Config.lua'
local actId = 5001

local CacheIO = require 'zoo.localActivity.FindingTheWay.CacheIO'

local funny_levels = {}
local funny_levels_props = {}
local lastLevelIndex = 0
local propNum = 0
local star2PropNum = 0

local FTWLocalLogic = {}

FTWLocalLogic.MODE = {
	kAddStarMode = 'AddStarMode',
	kFullStarMode = 'FullStarMode',
}

function FTWLocalLogic:getActId( ... )
	return actId
end

function FTWLocalLogic:isActEnabled( ... )
	local config
    for _,v in pairs(ActivityUtil:getActivitys()) do
        if v.source == ACT_SOURCE then
        	pcall(function ( ... )
	            config = require ('activity/'..v.source)
        	end)
            break
        end
    end
    local actEnabled = config and config.isSupport()

    if config and config.actId then
    	actId = config.actId
    end

    self:read()
    return actEnabled and star2PropNum > 0
end


--一次打关期间维护数据
function FTWLocalLogic:stashData( data )
	self._cache_data = data
end

function FTWLocalLogic:clearStashData( ... )
	self._cache_data = nil
end

function FTWLocalLogic:onStartLevelInfoPanel( levelId )

	self:clearStashData()

	if self:isActEnabled() then

		local levelType = LevelType:getLevelTypeByLevelId( levelId )
		if (GameLevelType.kMainLevel ~= levelType and GameLevelType.kHiddenLevel ~= levelType) then
			return 
		end

		local context_data = {
			levelId = levelId,
			deltaPropNum = 0,
			oldStar = 0,
		}

		local score = UserManager.getInstance():getUserScore(levelId)
		if score and score.star then
			context_data.oldStar = score.star
		end

		if self:isAddStarMode(levelId) then

			if UserManager:getInstance():hasPassedLevelEx(levelId) then 

				local thisLevelMaxStar = 3

				local levelMeta = LevelMapManager:getMeta(context_data.levelId)
				if levelMeta then
					thisLevelMaxStar = levelMeta:getTotalStarNumber()
				end

				if context_data.oldStar < thisLevelMaxStar then
					context_data.mode = FTWLocalLogic.MODE.kAddStarMode
				end
			end

		elseif self:isFullStarMode(levelId) then
			context_data.mode = FTWLocalLogic.MODE.kFullStarMode
		end

		self:stashData(context_data)
	end
end


local Dc = {}
function Dc:log( category,subCategory,t1,t2,t3,t4 )
	local params = {
		game_type = "stage",
		game_name = "starEvent_winter",
		category = category,
		sub_category = subCategory,
		t1 = t1,
		t2 = t2,
		t3 = t3,
		t4 = t4,
	}
	DcUtil:activity(params)
end


function FTWLocalLogic:onLevelSuccessPanel( ... )
	if self:isFTWEnabled() then


		if self._cache_data.mode == FTWLocalLogic.MODE.kAddStarMode then
		elseif self._cache_data.mode == FTWLocalLogic.MODE.kFullStarMode then

			

			local levelId = self._cache_data.levelId
			Dc:log('stage', 'pass_specialLevel', levelId)

			self._cache_data.deltaPropNum = 0
			local levelIndex = table.indexOf(funny_levels, levelId)
			if levelIndex then
				self._cache_data.deltaPropNum = funny_levels_props[levelIndex] or 0
			end
			lastLevelIndex = lastLevelIndex + 1
		end

		-- printx(61, self._cache_data.mode, self._cache_data.deltaPropNum)

		self:updatePropNum(propNum + (self._cache_data.deltaPropNum or 0), true)
		self:tryUpdateMsgNum(propNum)
		self:write()

	end
end

function FTWLocalLogic:onLevelEnd( ... )
	self._cache_data = nil
end

function FTWLocalLogic:getFunnyPropNum( levelId )
	local funny_prop = 0
	local levelIndex = table.indexOf(funny_levels or {}, levelId)
	if levelIndex then
		funny_prop = funny_levels_props[levelIndex] or 0
	end
	return funny_prop
end

function FTWLocalLogic:tryUpdateMsgNum( n )
	ActivityUtil:setMsgNum(ACT_SOURCE, n )
end

function FTWLocalLogic:isFullStar( ... )

    local ret = false

    pcall(function ( ... )
	    local maxLevel = NewAreaOpenMgr.getInstance():getLocalTopLevel()
	    local totalStar = LevelMapManager.getInstance():getTotalStar(maxLevel)
	    local totalHiddenStar = MetaModel.sharedInstance():getFullStarInHiddenRegion(true)
	    local curStar = UserManager:getInstance().user:getStar()
	    local curHiddenStar = UserManager:getInstance().user:getHideStar()
	    ret = curStar + curHiddenStar >= totalStar + totalHiddenStar
    end)

    return ret
end

function FTWLocalLogic:getDeltaPropNum( ... )
	if self._cache_data then
		return self._cache_data.deltaPropNum or 0
	end
	return 0
end

function FTWLocalLogic:getMode( ... )
	if self:isFTWEnabled() then
		return self._cache_data.mode
	end
end

--非满星状态 补星模式
function FTWLocalLogic:isAddStarMode( levelId )
	-- body
	if not self:isFullStar() then
		return true
	end
	return false
end

--满星状态 闯关模式
function FTWLocalLogic:isFullStarMode( levelId )
	if self:isFullStar() then
		-- if table.indexOf(funny_levels, levelId) ~= nil then
		if levelId == self:selectOneLevel() then
			return true
		end
	end
	return false
end

function FTWLocalLogic:updateFunnyLevels( _funny_levels, noIO )
	funny_levels = table.clone(_funny_levels or {}) or {}
	-- table.sort(funny_levels)
	if not noIO then
		self:write()
	end
end

function FTWLocalLogic:updatePropNum( _propNum, noIO  )
	propNum = _propNum

	if not noIO then
		self:write()
	end
end

function FTWLocalLogic:write( ... )
	-- body
	local cacheIO = CacheIO.new('FTWLocalLogic')
	cacheIO:set('funny_levels', funny_levels, true)
	cacheIO:set('propNum', propNum, true)
	cacheIO:set('star2PropNum', star2PropNum, true)
	cacheIO:set('lastLevelIndex', lastLevelIndex, true)
	cacheIO:set('funny_levels_props', funny_levels_props)
end

function FTWLocalLogic:read( ... )
	-- body
	if not self._had_read then
		self._had_read = true
		local cacheIO = CacheIO.new('FTWLocalLogic')
		funny_levels = cacheIO:get('funny_levels') or funny_levels
		propNum = cacheIO:get('propNum') or propNum
		star2PropNum = cacheIO:get('star2PropNum') or star2PropNum
		lastLevelIndex = cacheIO:get('lastLevelIndex') or lastLevelIndex
		funny_levels_props = cacheIO:get('funny_levels_props') or funny_levels_props
	end
end

function FTWLocalLogic:updateFunnyLevelsStars( _funny_levels_props, noIO  )
	funny_levels_props = _funny_levels_props

	if not noIO then
		self:write()
	end
end

function FTWLocalLogic:updateLastLevelIndex( _last_level_index , noIO )
	lastLevelIndex = _last_level_index + 1

	if not noIO then
		self:write()
	end
end

function FTWLocalLogic:updateStar2PropNum( _n, noIO  )
	star2PropNum = _n

	if not noIO then
		self:write()
	end
end

--在一次打关上下文中 用于判断本次打关 是否应该处理 ftw相关的逻辑
function FTWLocalLogic:isFTWEnabled( ... )
	if self._cache_data and self._cache_data.mode then
		return true
	end
end

function FTWLocalLogic:getDataForRevert( ... )
	return table.clone(self._cache_data or {}, true)
end

function FTWLocalLogic:setDataForRevert( data )
	if self:isActEnabled() then
		if not self:isFTWEnabled() then
			self._cache_data = data
		end
	end
end
--
function FTWLocalLogic:onStarChange( newStar )	
	if self:isFTWEnabled() then
		if self._cache_data.mode == FTWLocalLogic.MODE.kAddStarMode then
			local oldDelta = self._cache_data.deltaPropNum or 0
			local oldStar = self._cache_data.oldStar
			self._cache_data.deltaPropNum = self:calcPropNum(oldStar, newStar)
			return self._cache_data.deltaPropNum - oldDelta
		end
	end
end


function FTWLocalLogic:calcPropNum(oldStar, newStar )
	return math.clamp( (newStar - oldStar) * star2PropNum, 0, 1000)
end

function FTWLocalLogic:selectOneLevel( ... )
	if lastLevelIndex > #funny_levels and #funny_levels > 0 then
		lastLevelIndex = (lastLevelIndex-1) % (#funny_levels) + 1
	end
	return funny_levels[lastLevelIndex] or 14
end

function FTWLocalLogic:getLevelIndex( levelId )
	return table.indexOf(funny_levels, levelId) or 1
end


return FTWLocalLogic