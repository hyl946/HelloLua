local function _openStartLevelPanel( levelId,  levelType)
	-- body

	if not PopoutManager:sharedInstance():haveWindowOnScreen() and not HomeScene:sharedInstance().ladyBugOnScreen then
        local panel = StartGamePanel:create(levelId, levelType)
        panel:popout(false)
    end
end

local function startLevel( levelId, levelType )
	-- body
	if levelType == GameLevelType.kMainLevel then
		HomeScene:sharedInstance().worldScene:moveNodeToCenter(levelId, function ( ... )
	        _openStartLevelPanel(levelId, levelType)
	    end)
	    return true
	end

	if levelType == GameLevelType.kHiddenLevel then
		local branchId = MetaModel.sharedInstance():getHiddenBranchIdByHiddenLevelId(levelId)
	    HomeScene:sharedInstance().worldScene:scrollToBranch(branchId, function ( ... )
	        _openStartLevelPanel(levelId, levelType)
		end)
	    return true
	end

	return false
end





local PlayLevelAction = {}



function PlayLevelAction:playUnpassedMainLevel( allowUnlockArea )
	local myTopLevel = UserManager:getInstance().user:getTopLevelId()
    if myTopLevel <= 0 then
        return true
    end
	if not UserManager:getInstance():hasPassedLevelEx(myTopLevel) then
        return startLevel(myTopLevel, GameLevelType.kMainLevel)
    else
    	local localMaxLevel = kMaxLevels
		if NewAreaOpenMgr then
			localMaxLevel = NewAreaOpenMgr.getInstance():getLocalTopLevel()
		end
		if myTopLevel >= localMaxLevel then
			return false
		else
			if allowUnlockArea then
		        HomeScene:sharedInstance().worldScene:moveNodeToCenter(myTopLevel, function ( ... )
		            setTimeOut(function ( ... )
		                if not PopoutManager:sharedInstance():haveWindowOnScreen() then
		                    if HomeScene:sharedInstance().worldScene then 
		                        local lockedCloudsTable = HomeScene:sharedInstance().worldScene.lockedClouds
		                        if lockedCloudsTable then 
		                            for i,v in ipairs(lockedCloudsTable) do
		                                if v.state == LockedCloudState.WAIT_TO_OPEN and not v.isCachedInPool then 
		                                    v:handleWaitToOpen()
		                                    break
		                                end
		                            end
		                        end
		                    end
		                end
		            end, 0.2)
		        end)
		        return true
		    else
		    	return false
		    end
	    end
    end
end

local branchDataList 
function PlayLevelAction:playUnpassedHiddenLevel( ... )
	if not branchDataList then
		branchDataList = MetaModel:sharedInstance():getHiddenBranchDataList()
	end
	for index, v in ipairs(branchDataList) do
		if MetaModel:sharedInstance():isHiddenBranchCanOpen(index) then
			for levelId = branchDataList[index].startHiddenLevel, branchDataList[index].endHiddenLevel do
				if not UserManager:getInstance():hasPassedLevelEx(levelId) then
					return startLevel(levelId, GameLevelType.kHiddenLevel)
				end
			end
		end
	end
	return false
end

function PlayLevelAction:playRandomHiddenLevel( ... )
	if not branchDataList then
		branchDataList = MetaModel:sharedInstance():getHiddenBranchDataList()
	end
	for index, v in ipairs(branchDataList) do
		if MetaModel:sharedInstance():isHiddenBranchCanOpen(index) then
			for levelId = branchDataList[index].startHiddenLevel, branchDataList[index].endHiddenLevel do
				if math.random() < 0.5 then
					return startLevel(levelId, GameLevelType.kHiddenLevel)
				end
			end
		end
	end
	return false
end


local function getTimer( ... )
	local _ts = HeTimeUtil:getCurrentTimeMillis()
	return function ( ... )
		local tmp = HeTimeUtil:getCurrentTimeMillis()
		local ret = tmp - _ts
		_ts = tmp
		return ret
	end
end

function PlayLevelAction:playUnFullStarMainLevel( ... )
	local myTopLevel = UserManager:getInstance().user:getTopLevelId()
    if myTopLevel <= 0 then
        return true
    end


    local sectionSum = 0
    local total = 0
    local timerB = getTimer()


	for levelId = myTopLevel, 1, -1 do



		local scoreRef = UserManager:getInstance():getUserScore(levelId)

		local timerA = getTimer()

		local levelMeta = LevelMapManager.getInstance():getMeta(levelId)

		sectionSum = sectionSum + timerA()

		local star = 0
		if scoreRef then
			star = scoreRef.star or 0
		end

		local totalStar = 3
		if levelMeta and levelMeta.scoreTargets and levelMeta.scoreTargets[4] and levelMeta.scoreTargets[4] > 0 then
			totalStar = 4
		end
		if totalStar > star then
        	return startLevel(levelId, GameLevelType.kMainLevel)
		end
	end

	total = timerB()

	return false
end

function PlayLevelAction:playUnFullStarHiddenLevel( ... )
	if not branchDataList then
		branchDataList = MetaModel:sharedInstance():getHiddenBranchDataList()
	end
	for index, v in ipairs(branchDataList) do
		if MetaModel:sharedInstance():isHiddenBranchCanOpen(index) then
			for levelId = branchDataList[index].startHiddenLevel, branchDataList[index].endHiddenLevel do
				
				local scoreRef = UserManager:getInstance():getUserScore(levelId)
				local levelMeta = LevelMapManager.getInstance():getMeta(levelId)

				local star = 0
				if scoreRef and scoreRef.star then
					star = scoreRef.star
				end
				local totalStar = 3
				if levelMeta and levelMeta.scoreTargets and levelMeta.scoreTargets[4] and levelMeta.scoreTargets[4] > 0 then
					totalStar = 4
				end
				if totalStar > star then
					return startLevel(levelId, GameLevelType.kHiddenLevel)
				end
			end
		end
	end
	return false
end

function PlayLevelAction:doAction( levelTypes, allowUnlockArea)

	if allowUnlockArea == nil then
		allowUnlockArea = false
	end

	if table.indexOf(levelTypes, GameLevelType.kMainLevel) ~= nil then
		if self:playUnpassedMainLevel(allowUnlockArea) then
			return true
		end
	end

	if table.indexOf(levelTypes, GameLevelType.kHiddenLevel) ~= nil then
		if self:playUnpassedHiddenLevel() then
			return true
		end
	end

	if table.indexOf(levelTypes, GameLevelType.kMainLevel) ~= nil then
		if self:playUnFullStarMainLevel() then
			return true
		end
	end

	if table.indexOf(levelTypes, GameLevelType.kHiddenLevel) ~= nil then
		if self:playUnFullStarHiddenLevel() then
			return true
		end
	end

	if table.indexOf(levelTypes, GameLevelType.kMainLevel) ~= nil then
		local myTopLevel = UserManager:getInstance().user:getTopLevelId()
        return startLevel(myTopLevel, GameLevelType.kMainLevel)
	end

	if table.indexOf(levelTypes, GameLevelType.kHiddenLevel) ~= nil then
        if self:playRandomHiddenLevel() then
        	return true
        end
	end

	return false
end

return PlayLevelAction