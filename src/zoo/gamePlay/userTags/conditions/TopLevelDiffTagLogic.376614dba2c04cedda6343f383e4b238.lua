TopLevelDiffTagLogic = class()

function TopLevelDiffTagLogic:create()
	return TopLevelDiffTagLogic.new()
end

function TopLevelDiffTagLogic:updateContext()
	-- printx( 1 , "TopLevelDiffTagLogic:updateContext !!!!!!!!!!!!!!!!!!!!!!!!!! " )
	-- debug.debug()
	self.context = {}

	self.context.uid = UserManager:getInstance():getUID() or "12345"
	self.context.topLevelId = UserManager:getInstance():getUserRef():getTopLevelId()
	self.context.topLevelFailCounts = UserTagManager:getTopLevelLogicalFailCounts()
	self.context.diff = LevelDifficultyAdjustManager:getLevelStaticDifficulty( self.context.topLevelId ) or 0 --平均失败次数 
	self.context.maxLevelId = MetaManager.getInstance():getMaxNormalLevelByLevelArea()

	if MaintenanceManager:getInstance():isEnabledInGroup( "LevelDifficultyAdjustV2" , "A17" , self.context.uid ) then
		self.context.logicVer = 4
	else
		self.context.logicVer = 3
	end
end

function TopLevelDiffTagLogic:setContext( datas )
	self.context = datas
	self.context.isMock = true
end

function TopLevelDiffTagLogic.unitTestByContext( mockDatas , result )

	local logic = TopLevelDiffTagLogic:create()

	logic:setContext( mockDatas )

	local topLevelFailCounts = logic.context.topLevelFailCounts
	local topLevelId = logic.context.topLevelId
	-- RemoteDebug:uploadLogWithTag( "TTT" , "TopLevelDiffTagLogic:checkChange  oldValue" , oldValue , "topLevelFailCounts" , topLevelFailCounts , debug.traceback() )
	local currDiff = logic:__check( topLevelId , topLevelFailCounts )

	if not result then result = {} end

	if result.diffTag == currDiff then
		return true
	end

	local _result = { diffTag = currDiff }

	return false , table.tostring(_result)
end

function TopLevelDiffTagLogic:checkChange( oldValue )

	self:updateContext()

	local topLevelFailCounts = self.context.topLevelFailCounts
	local topLevelId = self.context.topLevelId
	-- RemoteDebug:uploadLogWithTag( "TTT" , "TopLevelDiffTagLogic:checkChange  oldValue" , oldValue , "topLevelFailCounts" , topLevelFailCounts , debug.traceback() )
	local currDiff = self:__check( topLevelId , topLevelFailCounts )
	--printx( 1 , "TopLevelDiffTagCondition:checkChange ===========================  currDiff" , currDiff , "oldValue" , oldValue )
	if currDiff ~= oldValue then

		local bean = {}

		bean[UserTagNameKeyFullMap.kTopLevelDiff] = currDiff
		bean[UserTagNameKeyFullMap.kTopLevelDiff .. UserTagModel:getTopLevelIdSuffix()] = topLevelId
		bean.onlyUpdateThisTag = UserTagNameKeyFullMap.kTopLevelDiff
		-- RemoteDebug:uploadLogWithTag( "TAG" , "diff tag changed  [" .. tostring(oldValue) .. "] -- > [" .. tostring(currDiff) .. "]" )
		-- printx(1 , "====================  TAG =============================")
		-- printx(1 , "diff tag changed    [" .. tostring(oldValue) .. "] -- > [" .. tostring(currDiff) .. "]" )
		-- printx(1 , "=======================================================")
		return true , bean
	end

	return false
end

function TopLevelDiffTagLogic:getDiffTagV3( levelId , failTimes , valueMap , diff )

	if diff >= 3 and diff <= 5 then
		if failTimes < 1 then
			return valueMap.kLowDiff1
		end
	elseif diff > 5 and diff <= 10 then
		if failTimes <= 2 then
			return valueMap.kLowDiff1
		end
	elseif diff > 10 then
		if failTimes <= 3 then
			return valueMap.kLowDiff1
		end
	end

	if levelId < 400 then
		if failTimes > 15 then
			return valueMap.kHighDiff5
		end

		local fixDiff = math.floor( diff * 0.6 )

		if diff <= 5 then

			if failTimes > fixDiff + 6 then
				return valueMap.kHighDiff4
			elseif failTimes > fixDiff + 5 then
				return valueMap.kHighDiff3
			elseif failTimes > fixDiff + 4 then
				return valueMap.kHighDiff2
			elseif failTimes > fixDiff + 3 then
				return valueMap.kHighDiff1
			end

		elseif diff > 5 and diff < 10 then

			if failTimes > fixDiff + 5 then
				return valueMap.kHighDiff4
			elseif failTimes > fixDiff + 4 then
				return valueMap.kHighDiff3
			elseif failTimes > fixDiff + 3 then
				return valueMap.kHighDiff2
			elseif failTimes > fixDiff + 2 then
				return valueMap.kHighDiff1
			end

		elseif diff >= 10 then

			if failTimes > fixDiff + 4 then
				return valueMap.kHighDiff4
			elseif failTimes > fixDiff + 3 then
				return valueMap.kHighDiff3
			elseif failTimes > fixDiff + 2 then
				return valueMap.kHighDiff2
			elseif failTimes > fixDiff + 1 then
				return valueMap.kHighDiff1
			end

		end
	else

		local fixDiff = diff
		local num1 = 25
		local num2 = 20
		local num3 = 25
		local maxLevelId = MetaManager.getInstance():getMaxNormalLevelByLevelArea()
		local closeToMaxLevel = false

		if levelId >= 400 and levelId < 800 then
			fixDiff = math.floor( diff * 0.7 )
			num1 = 25
			num2 = 20
			num3 = 25
		elseif levelId >= 800 and levelId < 1200 then
			fixDiff = math.floor( diff * 0.8 )
			num1 = 30
			num2 = 25
			num3 = 30
		elseif levelId < maxLevelId - 60 then
			fixDiff = math.floor( diff * 0.9 )
			num1 = 30
			num2 = 30
			num3 = 35
		else
			fixDiff = math.floor( diff * 1 )
			closeToMaxLevel = true
		end

		--printx( 1 , "TopLevelDiffTagLogic  Check  Level400+  diff =" , diff , "fixDiff =" , fixDiff , "failTimes =" , failTimes)

		local function check3to1()
			if diff <= 5 then
				if failTimes > fixDiff + 10 then
					return valueMap.kHighDiff3
				elseif failTimes > fixDiff + 8 then
					return valueMap.kHighDiff2
				elseif failTimes > fixDiff + 5 then
					return valueMap.kHighDiff1
				end
			elseif diff > 5 and diff <= 10 then
				if failTimes > fixDiff + 8 then
					return valueMap.kHighDiff3
				elseif failTimes > fixDiff + 6 then
					return valueMap.kHighDiff2
				elseif failTimes > fixDiff + 4 then
					return valueMap.kHighDiff1
				end
			elseif diff > 10 and diff <= 15 then
				if failTimes > fixDiff + 5 then
					return valueMap.kHighDiff3
				elseif failTimes > fixDiff + 4 then
					return valueMap.kHighDiff2
				elseif failTimes > fixDiff + 3 then
					return valueMap.kHighDiff1
				end
			elseif diff > 15 then
				if failTimes > fixDiff + 5 then
					return valueMap.kHighDiff3
				elseif failTimes > fixDiff + 4 then
					return valueMap.kHighDiff2
				elseif failTimes > fixDiff + 3 then
					return valueMap.kHighDiff1
				end
			end

			return nil
		end

		if closeToMaxLevel then
			if diff <= 5 then
				if failTimes >= 30 then
					return valueMap.kHighDiff5
				elseif failTimes >= 20 then
					return valueMap.kHighDiff4
				else
					local r = check3to1()
					if r then
						return r
					end
				end
			elseif diff > 5 and diff <= 10 then
				if failTimes >= 30 then
					return valueMap.kHighDiff5
				elseif failTimes >= 20 then
					return valueMap.kHighDiff4
				else
					local r = check3to1()
					if r then
						return r
					end
				end
			elseif diff > 10 and diff <= 15 then
				if failTimes >= 35 then
					return valueMap.kHighDiff5
				elseif failTimes >= 30 then
					return valueMap.kHighDiff4
				else
					local r = check3to1()
					if r then
						return r
					end
				end
			elseif diff > 15 then
				if failTimes >= 35 then
					return valueMap.kHighDiff5
				elseif failTimes >= 30 then
					return valueMap.kHighDiff4
				else
					local r = check3to1()
					if r then
						return r
					end
				end
			end
		else
			if diff <= 5 then
				if failTimes >= fixDiff*6 then
					return valueMap.kHighDiff5
				elseif failTimes >= fixDiff*4 then
					return valueMap.kHighDiff4
				else
					local r = check3to1()
					if r then
						return r
					end
				end
			elseif diff > 5 and diff <= 10 then
				if failTimes >= fixDiff*3 then
					return valueMap.kHighDiff5
				elseif failTimes >= fixDiff*2 then
					return valueMap.kHighDiff4
				else
					local r = check3to1()
					if r then
						return r
					end
				end
			elseif diff > 10 and diff <= 15 then
				if failTimes >= fixDiff*num1/15 then
					return valueMap.kHighDiff5
				elseif failTimes >= fixDiff*20/15 then
					return valueMap.kHighDiff4
				else
					local r = check3to1()
					if r then
						return r
					end
				end
			elseif diff > 15 then
				if failTimes >= num3 then
					return valueMap.kHighDiff5
				elseif failTimes >= num2 then
					return valueMap.kHighDiff4
				else
					local r = check3to1()
					if r then
						return r
					end
				end
			end
		end
	end

	return valueMap.kNormalDiff
end

function TopLevelDiffTagLogic:getDiffTagV4( levelId , failTimes , valueMap , diff )
	
	--[[
	if diff >= 3 and diff <= 5 then
		if failTimes < 1 then
			return valueMap.kLowDiff1
		end
	elseif diff > 5 and diff <= 10 then
		if failTimes <= 2 then
			return valueMap.kLowDiff1
		end
	elseif diff > 10 then
		if failTimes <= 3 then
			return valueMap.kLowDiff1
		end
	end
	]]
	local maxLevelId = self.context.maxLevelId

	DiffAdjustQAToolManager:print( 1 , "RRR" , "TopLevelDiffTagLogic:getDiffTagV4 p1" , levelId , failTimes , diff , maxLevelId )

	local logicConfig = {
		[1] = {
			minLevel = 0 ,
			maxLevel = 400 ,
			list = {
				[1] = {
					mixDiff = 0 ,
					maxDiff = 3 ,
					diff_1_type = "diff_plus_count" ,
					diff_1_value = 1 ,
					diff_2_type = "diff_plus_count" ,
					diff_2_value = 2 ,
					diff_3_type = "diff_plus_count" ,
					diff_3_value = 3 ,
					diff_4_type = "diff_plus_count" ,
					diff_4_value = 5 ,
					diff_5_type = "diff_plus_count" ,
					diff_5_value = 7 ,
				} ,
				[2] = {
					mixDiff = 4 ,
					maxDiff = 9999 ,
					diff_1_type = "count" ,
					diff_1_value = 4 ,
					diff_2_type = "count" ,
					diff_2_value = 5 ,
					diff_3_type = "count" ,
					diff_3_value = 6 ,
					diff_4_type = "count" ,
					diff_4_value = 8 ,
					diff_5_type = "count" ,
					diff_5_value = 10 ,
				} ,
				
			} ,
		} ,

		[2] = {
			minLevel = 401 ,
			maxLevel = 800 ,
			list = {
				[1] = {
					mixDiff = 0 ,
					maxDiff = 4 ,
					diff_1_type = "diff_plus_count" ,
					diff_1_value = 1 ,
					diff_2_type = "diff_plus_count" ,
					diff_2_value = 2 ,
					diff_3_type = "diff_plus_count" ,
					diff_3_value = 3 ,
					diff_4_type = "diff_plus_count" ,
					diff_4_value = 4 ,
					diff_5_type = "diff_plus_count" ,
					diff_5_value = 5 ,
				} ,
				[2] = {
					mixDiff = 5 ,
					maxDiff = 9999 ,
					diff_1_type = "count" ,
					diff_1_value = 5 ,
					diff_2_type = "count" ,
					diff_2_value = 6 ,
					diff_3_type = "count" ,
					diff_3_value = 8 ,
					diff_4_type = "count" ,
					diff_4_value = 10 ,
					diff_5_type = "count" ,
					diff_5_value = 12 ,
				} ,
				
			} ,
		} ,

		[3] = {
			minLevel = 801 ,
			maxLevel = 1200 ,
			list = {
				[1] = {
					mixDiff = 0 ,
					maxDiff = 5 ,
					diff_1_type = "diff_plus_count" ,
					diff_1_value = 1 ,
					diff_2_type = "diff_plus_count" ,
					diff_2_value = 2 ,
					diff_3_type = "diff_plus_count" ,
					diff_3_value = 4 ,
					diff_4_type = "diff_plus_count" ,
					diff_4_value = 7 ,
					diff_5_type = "diff_plus_count" ,
					diff_5_value = 10 ,
				} ,
				[2] = {
					mixDiff = 6 ,
					maxDiff = 9999 ,
					diff_1_type = "count" ,
					diff_1_value = 6 ,
					diff_2_type = "count" ,
					diff_2_value = 7 ,
					diff_3_type = "count" ,
					diff_3_value = 9 ,
					diff_4_type = "count" ,
					diff_4_value = 12 ,
					diff_5_type = "count" ,
					diff_5_value = 15 ,
				} ,
				
			} ,
		} ,

		[4] = {
			minLevel = 1201 ,
			maxLevel = 1600 ,
			list = {
				[1] = {
					mixDiff = 0 ,
					maxDiff = 6 ,
					diff_1_type = "diff_plus_count" ,
					diff_1_value = 1 ,
					diff_2_type = "diff_plus_count" ,
					diff_2_value = 2 ,
					diff_3_type = "diff_plus_count" ,
					diff_3_value = 4 ,
					diff_4_type = "diff_plus_count" ,
					diff_4_value = 7 ,
					diff_5_type = "diff_plus_count" ,
					diff_5_value = 10 ,
				} ,
				[2] = {
					mixDiff = 7 ,
					maxDiff = 9999 ,
					diff_1_type = "count" ,
					diff_1_value = 7 ,
					diff_2_type = "count" ,
					diff_2_value = 8 ,
					diff_3_type = "count" ,
					diff_3_value = 10 ,
					diff_4_type = "count" ,
					diff_4_value = 13 ,
					diff_5_type = "count" ,
					diff_5_value = 16 ,
				} ,
				
			} ,
		} ,

		[5] = {
			minLevel = 1601 ,
			maxLevel = tonumber(maxLevelId - 60) ,
			list = {
				[1] = {
					mixDiff = 0 ,
					maxDiff = 8 ,
					diff_1_type = "diff_plus_count" ,
					diff_1_value = 1 ,
					diff_2_type = "diff_plus_count" ,
					diff_2_value = 2 ,
					diff_3_type = "diff_plus_count" ,
					diff_3_value = 4 ,
					diff_4_type = "diff_plus_count" ,
					diff_4_value = 7 ,
					diff_5_type = "diff_plus_count" ,
					diff_5_value = 10 ,
				} ,
				[2] = {
					mixDiff = 9 ,
					maxDiff = 9999 ,
					diff_1_type = "count" ,
					diff_1_value = 9 ,
					diff_2_type = "count" ,
					diff_2_value = 10 ,
					diff_3_type = "count" ,
					diff_3_value = 12 ,
					diff_4_type = "count" ,
					diff_4_value = 15 ,
					diff_5_type = "count" ,
					diff_5_value = 18 ,
				} ,
				
			} ,
		} ,

		[6] = {
			minLevel = tonumber(maxLevelId - 60 + 1) ,
			maxLevel = maxLevelId ,
			list = {
				[1] = {
					mixDiff = 0 ,
					maxDiff = 10 ,
					diff_1_type = "diff_plus_count" ,
					diff_1_value = 3 ,
					diff_2_type = "diff_plus_count" ,
					diff_2_value = 4 ,
					diff_3_type = "diff_plus_count" ,
					diff_3_value = 6 ,
					diff_4_type = "diff_plus_count" ,
					diff_4_value = 10 ,
					diff_5_type = "diff_plus_count" ,
					diff_5_value = 15 ,
				} ,
				[2] = {
					mixDiff = 11 ,
					maxDiff = 9999 ,
					diff_1_type = "count" ,
					diff_1_value = 13 ,
					diff_2_type = "count" ,
					diff_2_value = 14 ,
					diff_3_type = "count" ,
					diff_3_value = 16 ,
					diff_4_type = "count" ,
					diff_4_value = 20 ,
					diff_5_type = "count" ,
					diff_5_value = 25 ,
				} ,
				
			} ,
		} ,
	}

	local function checkUnit(checkType , checkValue , failCounts , diff)
		
		if checkType == "diff_plus_count" then
			if failCounts > diff + checkValue then
				return true
			end
		elseif checkType == "count" then
			if failCounts > checkValue then
				return true
			end
		end
		return false
	end

	for k , v in ipairs( logicConfig ) do

		if levelId >= v.minLevel and levelId <= v.maxLevel then

			for k2 , v2 in ipairs( v.list ) do

				if diff >= v2.mixDiff and diff <= v2.maxDiff then

					for i = 5 , 1 , -1 do

						local _result = checkUnit( 
							v2["diff_" .. tostring(i) .. "_type"] , v2["diff_" .. tostring(i) .. "_value"] , failTimes , diff )
						
						if _result then
							return valueMap["kHighDiff" .. tostring(i)]
						end
					end

					break
				end
			end

			break
		end
	end

	return valueMap.kNormalDiff
end

function TopLevelDiffTagLogic:__check( levelId , failTimes )

	local valueMap = UserTagValueMap[UserTagNameKeyFullMap.kTopLevelDiff]
	local diff = self.context.diff --平均失败次数 

	if self.context.logicVer == 3 then
		return self:getDiffTagV3( levelId , failTimes , valueMap , diff )
	elseif self.context.logicVer == 4 then
		return self:getDiffTagV4( levelId , failTimes , valueMap , diff )
	else
		return valueMap.kNormalDiff
	end
end

function TopLevelDiffTagLogic:__check_old( levelId , failTimes )

	--local diff = math.floor( LevelDifficultyAdjustManager:getLevelStaticDifficulty( levelId ) or 0 ) --平均失败次数
	local diff = LevelDifficultyAdjustManager:getLevelStaticDifficulty( levelId ) or 0 --平均失败次数

	local valueMap = UserTagValueMap[UserTagNameKeyFullMap.kTopLevelDiff]
	
	if diff >= 0 then

		local m1 = 15
		local m2 = 30

		if levelId >= 400 then
			m1 = 30
			m2 = 50
		end

		if failTimes >= m2 then
			return valueMap.kHighDiff5
		end

		if failTimes >= m1 then
			--四阶过难
			--RemoteDebug:uploadLog( "DiffAdjust getLevelDifficultyTag --> T4" .. " diff:" .. tostring(diff) .. " failTimes:" .. tostring(failTimes)  )
			return valueMap.kHighDiff4
		end

		if diff == 0 then
			return valueMap.kNone
		end

		if diff >= 3 and diff <= 5 then
			if failTimes < 1 then
				return valueMap.kLowDiff1
			end
		elseif diff > 5 and diff <= 10 then
			if failTimes <= 2 then
				return valueMap.kLowDiff1
			end
		elseif diff > 10 then
			if failTimes <= 3 then
				return valueMap.kLowDiff1
			end
		end

		if levelId < 400 then
			if diff <= 5 then
				if failTimes >= math.floor( diff * 1.1 ) then
					return valueMap.kHighDiff1
				end
			elseif diff > 5 and diff <= 10 then
				if failTimes >= 7 then
					return valueMap.kHighDiff2
				end
			elseif diff > 10 then
				if failTimes >= 10 then
					return valueMap.kHighDiff3
				end
			end
		else
			if diff < 10 then
				if failTimes >= math.floor( diff * 1.3 ) then
					return valueMap.kHighDiff1
				end
			elseif diff >= 10 and diff <= 15 then
				if failTimes >= math.floor( diff * 1.3 ) then
					return valueMap.kHighDiff2
				end
			elseif diff > 15 then
				if failTimes >= 20 then
					return valueMap.kHighDiff3
				end
			end			
		end
	end
	return valueMap.kNormalDiff
end

return TopLevelDiffTagLogic