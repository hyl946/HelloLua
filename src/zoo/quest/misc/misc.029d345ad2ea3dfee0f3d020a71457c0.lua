local nilKey = '___nil___key'

local function memorize( func )
    local cache = {}
    return function ( ... )
        local params = {...}
        local paramsNum = #params
        local result = cache
        for index = 1, paramsNum - 1 do
            local param = params[index]
            if param == nil then
                param = nilKey
            end
            if result[param] == nil then
                result[param] = {}
            end
            result = result[param]
        end
        local lastParam = params[paramsNum]

        if lastParam == nil then
            lastParam = nilKey
        end

        if result[lastParam] == nil then
            result[lastParam] = func(...)
        end
        return result[lastParam] 
    end
end

local function _getTotalStarByLevelId( levelId )
	local levelMeta = LevelMapManager.getInstance():getMeta(levelId)
	local totalStar = 3
	if levelMeta and levelMeta.scoreTargets and levelMeta.scoreTargets[4] and levelMeta.scoreTargets[4] > 0 then
		totalStar = 4
	end
	return totalStar
end

local function isUserFullStar( ... )
	-- body
	local localTotalStar = 0
    pcall(function ( ... )
	    local maxLevel = NewAreaOpenMgr.getInstance():getLocalTopLevel()
	    local totalStar = LevelMapManager.getInstance():getTotalStar(maxLevel)
	    local totalHiddenStar = MetaModel.sharedInstance():getFullStarInHiddenRegion(true)
	    localTotalStar = totalStar + totalHiddenStar
    end)

	local userTotalStar = UserManager.getInstance().user:getHideStar() + UserManager.getInstance().user:getStar()
    local isFullStar = userTotalStar >= localTotalStar

    return isFullStar
end


return {
	memorize = memorize,
	getTotalStarByLevelId = memorize(_getTotalStarByLevelId),
	isUserFullStar = isUserFullStar,
}