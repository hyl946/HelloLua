FuuuDiffAdjustManager = class()

function FuuuDiffAdjustManager:create( levelDifficultyAdjustManager )
	local logic = FuuuDiffAdjustManager.new()
	logic:reset()
	logic.levelDifficultyAdjustManager = levelDifficultyAdjustManager
	return logic
end

function FuuuDiffAdjustManager:reset()
end

function FuuuDiffAdjustManager:buildLevelTargetProgressByRespData( datastr )
	if datastr then

		local levelTargetProgress = table.deserialize( datastr )

		--printx( 1 , "#levelTargetProgress = " , #levelTargetProgress)

		local levelTables = {}

		for i = 1 , #levelTargetProgress do

			local data = levelTargetProgress[i]
			local stepBean = {}

			local level = data[1]
			local step = data[2]

			stepBean.tagetId = data[3]
			stepBean.min = data[4]
			stepBean.low = data[7]
			stepBean.mid = data[6]
			stepBean.high = data[5]
			stepBean.max = data[8]
			stepBean.sampleCount = data[9]

			local levelconfig = LevelDataManager.sharedLevelData():getLevelConfigByID( level  , false )

			if levelconfig then
				local moveLimit = levelconfig.moveLimit or 9999
				if moveLimit == 0 then moveLimit = 9999 end

				if step <= moveLimit then
					if not levelTables[ tostring(level) ] then
						levelTables[ tostring(level) ] = { levelId = level , steps = {} , staticTotalSteps = moveLimit }
					end

					local steps = levelTables[ tostring(level) ].steps

					if not steps[ "s" .. tostring(step) ] then
						steps[ "s" .. tostring(step) ] = {}
					end
					
					local currStep = steps["s" .. tostring(step)]

					currStep[ tostring(stepBean.tagetId) ] = stepBean
				end
			end
			
		end

		return levelTables
	end

	return nil
end

function FuuuDiffAdjustManager:buildLevelTargetProgressDataByReplayDataStr( datastr , staticTotalSteps )

	local leveldata = {}
	leveldata.steps = {}
	leveldata.staticTotalSteps = staticTotalSteps

	local version = 1

	if string.starts(datastr, '@@@Version:2@@@') then
		version = 2
		datastr = string.sub(datastr, #'@@@Version:2@@@' + 1, -1)
	end

	for w in string.gmatch( datastr ,"([^';']+)") do
		
		local arr = {}
		for w1 in string.gmatch( w ,"([^'~']+)") do
			table.insert( arr , w1 )
		end

		local targetId = arr[1]
		local stepsStr = arr[2]

		local stepsArr = {}
		for w2 in string.gmatch( stepsStr ,"([^'^']+)") do
			table.insert( stepsArr , w2 )
		end

		for k,v in ipairs(stepsArr) do

			local realStep = k
			if version == 2 then
				realStep = k - 1
			end

			if not leveldata.steps[ "s" .. tostring(realStep) ] then
				leveldata.steps[ "s" .. tostring(realStep) ] = {}
			end
			
			local step = leveldata.steps[ "s" .. tostring(realStep) ]

			if not step[tostring(targetId)] then
				step[tostring(targetId)] = { tagetId = targetId }
			end

			local stepBean = step[tostring(targetId)]

			local vt = {}
			for w3 in string.gmatch( v ,"([^'_']+)") do
				table.insert( vt , w3 )
			end

			stepBean.min = tonumber( vt[1] )
			stepBean.low = tonumber( vt[2] )
			stepBean.mid = tonumber( vt[3] )
			stepBean.high = tonumber( vt[4] )
			stepBean.max = tonumber( vt[5] )

		end
		
	end

	return leveldata
end

function FuuuDiffAdjustManager:getLevelTargetProgressDataStrForReplay( localLevelData , levelId )
	if (not localLevelData) or (not localLevelData.levelTargetProgress) then
		return
	end

	local ldata = localLevelData.levelTargetProgress[ tostring(levelId) ]

	if ldata then
		local staticTotalSteps = ldata.staticTotalSteps
		local steps = ldata.steps

		local datastr = ""
		local targetIdMap = {}
		for i = 0 , tonumber(staticTotalSteps) do
			local step = steps["s" .. tostring(i)]

			if step then
				for k,v in pairs(step) do

					if not targetIdMap[k] then
						targetIdMap[k] = ""
					end
					local str = targetIdMap[k]

					if str == "" then
						targetIdMap[k] = tostring(v.min) .. "_" .. tostring(v.low) .. "_" .. tostring(v.mid) .. "_" .. tostring(v.high) .. "_" .. tostring(v.max)
					else
						targetIdMap[k] = str .. "^" .. tostring(v.min) .. "_" .. tostring(v.low) .. "_" .. tostring(v.mid) .. "_" .. tostring(v.high) .. "_" .. tostring(v.max)
					end
				end
			end
		end


		for k2,v2 in pairs(targetIdMap) do
			if datastr == "" then
				datastr = tostring(k2) .. "~" .. v2
			else
				datastr = datastr .. ";" .. tostring(k2) .. "~" .. v2
			end
		end

		local version = '@@@Version:2@@@'
		datastr = version .. datastr
		return datastr , staticTotalSteps
	end
end




function FuuuDiffAdjustManager:checkAdjustStrategyByFuuu( levelId , closeToMaxLevel )
	--[[
	-- RemoteDebug:uploadLogWithTag( "checkAdjustStrategyByFuuu" , "111  levelId" , levelId , "closeToMaxLevel" , closeToMaxLevel)

	local uid = getCurrUid()

	local addColorFuuuGroup = 0

	if MaintenanceManager:getInstance():isEnabledInGroup("LevelDifficultyAdjust" , "NewFuuu1" , uid) then
		addColorFuuuGroup = 1
	elseif MaintenanceManager:getInstance():isEnabledInGroup("LevelDifficultyAdjust" , "NewFuuu2" , uid) then
		addColorFuuuGroup = 2
	elseif MaintenanceManager:getInstance():isEnabledInGroup("LevelDifficultyAdjust" , "NewFuuu3" , uid) then
		addColorFuuuGroup = 3
	end

	-- RemoteDebug:uploadLogWithTag( "checkAdjustStrategyByFuuu" , "222  uid" , uid , "addColorFuuuGroup" , addColorFuuuGroup )

	if addColorFuuuGroup ~= 0 then

		if addColorFuuuGroup == 1 then

			if not closeToMaxLevel then

				local activationTag = UserTagManager:getUserTag( UserTagNameKeyFullMap.kActivation )
				local topLevelDiffTag = UserTagManager:getUserTag( UserTagNameKeyFullMap.kTopLevelDiff )

				local activationTagValue = UserTagValueMap[UserTagNameKeyFullMap.kActivation]
				local topLevelDiffTagValue = UserTagValueMap[UserTagNameKeyFullMap.kTopLevelDiff]

				-- RemoteDebug:uploadLogWithTag( "checkAdjustStrategyByFuuu" , "333  activationTag" , activationTag , 
				-- 	"topLevelDiffTag" , topLevelDiffTag , "activationTagValue" , activationTagValue , "topLevelDiffTagValue" , topLevelDiffTagValue )

				if activationTag == activationTagValue.kWillLose 
					or activationTag == activationTagValue.kReturnBack 
					or topLevelDiffTag == topLevelDiffTagValue.kHighDiff4 
					or topLevelDiffTag == topLevelDiffTagValue.kHighDiff5 
					then

					return false

				end

				local failCounts = UserTagManager:getTopLevelFailCounts() or 1

				-- RemoteDebug:uploadLogWithTag( "checkAdjustStrategyByFuuu" , "444  failCounts" , failCounts  )

				--failCounts = failCounts - 2

				if failCounts > 0 then
					if topLevelDiffTag == topLevelDiffTagValue.kHighDiff3 then

						if failCounts % 3 == 0 then
							return true
						end

					elseif topLevelDiffTag == topLevelDiffTagValue.kHighDiff2 then

						if failCounts % 2 == 0 then
							return true
						end

					else
						return true
					end
				end
			end

		elseif addColorFuuuGroup == 2 then

			-- RemoteDebug:uploadLogWithTag( "checkAdjustStrategyByFuuu" , "555  Group 2 closeToMaxLevel =" , closeToMaxLevel  )
			if closeToMaxLevel then

				local failCounts = UserTagManager:getTopLevelFailCounts() or 1
				failCounts = failCounts - 1

				-- RemoteDebug:uploadLogWithTag( "checkAdjustStrategyByFuuu" , "666  Group 2 failCounts =" , failCounts  )
				if failCounts > 0 then
					-- RemoteDebug:uploadLogWithTag( "checkAdjustStrategyByFuuu" , "777  Group 2 true"  )
					return true
				end
			else
				-- RemoteDebug:uploadLogWithTag( "checkAdjustStrategyByFuuu" , "888  Group 2 true"  )
				return true
			end

		elseif addColorFuuuGroup == 3 then

			if closeToMaxLevel then

				local failCounts = UserTagManager:getTopLevelFailCounts() or 1
				failCounts = failCounts - 3

				if failCounts > 0 then
					return true
				end

			else

				local failCounts = UserTagManager:getTopLevelFailCounts() or 1

				if failCounts == 1 then
					return true
				end
			end

		end

	end
	]]
	return false
end



function FuuuDiffAdjustManager:checkAdjustStrategyByFuuuV2( levelId , closeToMaxLevel , userGroup )

	DiffAdjustQAToolManager:print( 1 , "checkAdjustStrategyByFuuu" , "111  levelId" , levelId , "closeToMaxLevel" , closeToMaxLevel )
	-- RemoteDebug:uploadLogWithTag( "checkAdjustStrategyByFuuu" , "111  levelId" , levelId , "closeToMaxLevel" , closeToMaxLevel)

	local uid = LevelDifficultyAdjustManager:getContext().uid

	DiffAdjustQAToolManager:print( 1 , "checkAdjustStrategyByFuuu" , "222  uid" , uid , "userGroup" , userGroup )
	-- RemoteDebug:uploadLogWithTag( "checkAdjustStrategyByFuuu" , "222  uid" , uid , "userGroup" , userGroup )
	if userGroup == 0 then
		return false
	end
		
	local payUser = false

	if (userGroup >= 12 and userGroup <= 16) or (userGroup == 9 or userGroup == 17) or userGroup == 10 then
		--[[
		A9组
		回流用户、濒临流失、四阶过难、五阶过难：不触发fuuu，只会相应的触发难度自动调整 
		三阶过难：toplevel关每闯关2次后，第2n+1次触发fuuu，其他时候满足自动调关则触发自动调关，不满足则什么都不触发 
		二阶过难：toplevel关每闯关1次后，第n+1次触发fuuu，其他时候满足自动调关则触发自动调关，不满足则什么都不触发 
		非以上用户： toplevel关每次闯关都会触发fuuu
		]]

		local function checkEnableFuuu()
			local activationTag = LevelDifficultyAdjustManager:getContext().fixedActivationTag
			local topLevelDiffTag = LevelDifficultyAdjustManager:getContext().diffTag

			local activationTagValue = UserTagValueMap[UserTagNameKeyFullMap.kActivation]
			local topLevelDiffTagValue = UserTagValueMap[UserTagNameKeyFullMap.kTopLevelDiff]

			DiffAdjustQAToolManager:print( 1 , "checkAdjustStrategyByFuuu" , "333  activationTag" , activationTag , 
				"topLevelDiffTag" , topLevelDiffTag , "activationTagValue" , activationTagValue , "topLevelDiffTagValue" , topLevelDiffTagValue )
			-- RemoteDebug:uploadLogWithTag( "checkAdjustStrategyByFuuu" , "333  activationTag" , activationTag , 
			-- 	"topLevelDiffTag" , topLevelDiffTag , "activationTagValue" , activationTagValue , "topLevelDiffTagValue" , topLevelDiffTagValue )

			if activationTag == activationTagValue.kWillLose 
				or activationTag == activationTagValue.kReturnBack 
				or topLevelDiffTag == topLevelDiffTagValue.kHighDiff4 
				or topLevelDiffTag == topLevelDiffTagValue.kHighDiff5 
				then
				DiffAdjustQAToolManager:print( 1 , "checkAdjustStrategyByFuuu" , "333  return" )
				-- RemoteDebug:uploadLogWithTag( "checkAdjustStrategyByFuuu" , "333  return" )
				return false

			end

			local failCounts = LevelDifficultyAdjustManager:getContext().failCount + 1

			DiffAdjustQAToolManager:print( 1 , "checkAdjustStrategyByFuuu" , "444  failCounts" , failCounts )
			-- RemoteDebug:uploadLogWithTag( "checkAdjustStrategyByFuuu" , "444  failCounts" , failCounts  )

			--failCounts = failCounts - 2

			if failCounts > 0 then
				if topLevelDiffTag == topLevelDiffTagValue.kHighDiff3 then

					if failCounts % 3 == 0 then
						DiffAdjustQAToolManager:print( 1 , "checkAdjustStrategyByFuuu" , "555  return" )
						-- RemoteDebug:uploadLogWithTag( "checkAdjustStrategyByFuuu" , "555  return" )
						return true
					end

				elseif topLevelDiffTag == topLevelDiffTagValue.kHighDiff2 then

					if failCounts % 2 == 0 then
						DiffAdjustQAToolManager:print( 1 , "checkAdjustStrategyByFuuu" , "666  return" )
						-- RemoteDebug:uploadLogWithTag( "checkAdjustStrategyByFuuu" , "666  return" )
						return true
					end

				else
					DiffAdjustQAToolManager:print( 1 , "checkAdjustStrategyByFuuu" , "777  return" )
					-- RemoteDebug:uploadLogWithTag( "checkAdjustStrategyByFuuu" , "777  return" )
					return true
				end
			end

			return false
		end

		local function checkFailCount()
			local failCounts = LevelDifficultyAdjustManager:getContext().failCount + 1
			if failCounts > 0 then
				if failCounts % 3 == 0 then
					return true
				end
			end
			return false
		end
		-- printx( 1 , "FFFFFFFFFFFFFFFFFFFFFFF 1  closeToMaxLevel" , closeToMaxLevel )
		local function checkPayAmountAndPlayCount()
			-- printx( 1 , "FFFFFFFFFFFFFFFFFFFFFFF 2")
			local last60DayPayAmount = LevelDifficultyAdjustManager:getContext().last60DayPayAmount

			local playCount = LevelDifficultyAdjustManager:getContext().todayPlayCount
			playCount = playCount + 1

			if not LevelDifficultyAdjustManager:getContext().isMock then
				local totalPlayCountData = LevelDifficultyAdjustManager:getContext().totalPlayCountData

				local today = LevelDifficultyAdjustManager:getContext().today
				local todayData = totalPlayCountData[ tostring(today) ]
				todayData["l" .. tostring(LevelDifficultyAdjustManager:getContext().levelId)] = playCount

				LocalBox:setData( "totalPlayCount" , totalPlayCountData , "LB_diffadjust" )
			end

			

			if userGroup == 12 and last60DayPayAmount > 47 then
				if playCount <= 3 then
					return false
				else
					return true
				end
			elseif userGroup == 13 and last60DayPayAmount > 47 then	
				if playCount <= 3 then
					return false
				else
					if checkFailCount() then
						return true
					else
						return false
					end
				end
			elseif userGroup == 14 and last60DayPayAmount > 47 then	
				return false
			elseif userGroup == 15 and last60DayPayAmount > 240 then	
				return false
			elseif userGroup == 16 and last60DayPayAmount > 240 then	
				if playCount <= 3 then
					return false
				else
					if checkFailCount() then
						return true
					else
						return false
					end
				end
			else
				--非以上情况使用A9组逻辑，即“每把都会触发fuuu干预，不触发颜色干预 ”
				return true
			end
		end

		local isPayUser = LevelDifficultyAdjustManager:getContext().isPayUser
		if not closeToMaxLevel then
			--非头部玩家

			if (userGroup == 9 or userGroup == 17) or (userGroup >= 12 and userGroup <= 16) then
				-- printx( 1 , "FFFFFFFFFFFFFFFFFFFFFFF 1.1")
				if isPayUser then
					-- printx( 1 , "FFFFFFFFFFFFFFFFFFFFFFF 1.2")
					if (userGroup == 9 or userGroup == 17) then
						DiffAdjustQAToolManager:print( 1 , "checkAdjustStrategyByFuuu" , "N1  return true" )
						return true
					else
						local r = checkPayAmountAndPlayCount()
						DiffAdjustQAToolManager:print( 1 , "checkAdjustStrategyByFuuu" , "N2  return " , r )
						return r
					end
				else
					-- printx( 1 , "FFFFFFFFFFFFFFFFFFFFFFF 1.3")
					local fuuuResult = checkEnableFuuu()
					if fuuuResult then 
						DiffAdjustQAToolManager:print( 1 , "checkAdjustStrategyByFuuu" , "N3  return true" )
						return true 
					end
				end
			elseif userGroup == 10 then
				if isPayUser then
					local failCounts = LevelDifficultyAdjustManager:getContext().failCount + 1
					if failCounts > 0 then
						if failCounts % 3 == 0 then
							DiffAdjustQAToolManager:print( 1 , "checkAdjustStrategyByFuuu" , "N4  return true" )
							return true
						end
					end
					DiffAdjustQAToolManager:print( 1 , "checkAdjustStrategyByFuuu" , "N5  return false" )
					return false
				else
					local fuuuResult = checkEnableFuuu()
					if fuuuResult then
						DiffAdjustQAToolManager:print( 1 , "checkAdjustStrategyByFuuu" , "N6  return true" ) 
						return true 
					end
				end
			end
			
		else
			--头部玩家
			local maxLevelId = LevelDifficultyAdjustManager:getContext().maxLevelId
			if levelId <= maxLevelId - 15 then
				--非头部15关内的玩家
				if (userGroup == 9 or userGroup == 17) or (userGroup >= 12 and userGroup <= 16) then
					if (userGroup == 9 or userGroup == 17) then
						DiffAdjustQAToolManager:print( 1 , "checkAdjustStrategyByFuuu" , "N7  return true" ) 
						return true
					else
						local r = checkPayAmountAndPlayCount()
						DiffAdjustQAToolManager:print( 1 , "checkAdjustStrategyByFuuu" , "N8  return " , r ) 
						return r
					end
				elseif userGroup == 10 then
					local failCounts = LevelDifficultyAdjustManager:getContext().failCount + 1
					if failCounts > 0 then
						if failCounts % 3 == 0 then
							DiffAdjustQAToolManager:print( 1 , "checkAdjustStrategyByFuuu" , "N9  return true" ) 
							return true
						end
					end
					DiffAdjustQAToolManager:print( 1 , "checkAdjustStrategyByFuuu" , "N10  return true" ) 
					return false
				end
			end

		end
		DiffAdjustQAToolManager:print( 1 , "checkAdjustStrategyByFuuu" , "888  return" )
		-- RemoteDebug:uploadLogWithTag( "checkAdjustStrategyByFuuu" , "888  return" )
		return false

	end

	return false
end