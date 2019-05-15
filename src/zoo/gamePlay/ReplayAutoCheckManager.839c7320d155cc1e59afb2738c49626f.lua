ReplayAutoCheckManager = {}

function ReplayAutoCheckManager:checkByList( dataList , checkParameter , finCallback , errorCallback , checkListIndex , checkCount )
	self.checkList = {}
	self.checkByListFinCallback = finCallback
	self.checkByListErrorCallback = errorCallback
	self.checkByListParameter = checkParameter
	self.resultMap = {}

	if dataList and #dataList > 0 then
		for k,v in ipairs(dataList) do
			local dataV = {}
			dataV.levelId = v.levelId
			dataV.maxCounts = v.maxCounts
			dataV.finCallback = nil
			dataV.errorCallback = nil
			dataV.parameters = {}

			if self.checkByListParameter.preProp then
				if math.random(1,10000) < 3333 then
					dataV.parameters.preProps = {}
				end
			end

			if self.checkByListParameter.buffs then
				if math.random(1,10000) < 3333 then
					dataV.parameters.buffs = {}
				end
			end

			if self.checkByListParameter.dropColorAdjust then
				if math.random(1,10000) < 3333 then
					dataV.parameters.dropColorAdjust = {}
				end
			end

			if self.checkByListParameter.useProp then
				if math.random(1,10000) < 3333 then
					dataV.parameters.useProp = {}
				end
			end

			table.insert( self.checkList , dataV)
		end
	end

	self.checkListIndex = checkListIndex or 1
	if #self.checkList > 0 then
		local dataV = self.checkList[self.checkListIndex]

		self:check( dataV.levelId , dataV.maxCounts , dataV.finCallback , dataV.errorCallback , dataV.parameters , checkCount )
	end
end

function ReplayAutoCheckManager:check( levelId , maxCounts , finCallback , errorCallback , parameters , checkCount)
	self.levelId = levelId
	if checkCount then
		self.maxCounts = checkCount
	else
		self.maxCounts = maxCounts or 2000
	end
	
	self.finCallback = finCallback
	self.errorCallback = errorCallback
	self.parameters = parameters

	--printx( 1 , "ReplayAutoCheckManager:check  ===================================  " ,levelId , " count:" , self.maxCounts)

	self:doCheck( self.levelId )
end

function ReplayAutoCheckManager:doCheck( levelId )

	--printx( 1 ,  "ReplayAutoCheckManager:doCheck   1")

	if not PopoutManager:sharedInstance():haveWindowOnScreen()
			and not HomeScene:sharedInstance().ladyBugOnScreen then

			--printx( 1 ,  "ReplayAutoCheckManager:doCheck   2" , levelId)

			self.sectionData_step1 = nil
			self.sectionData_step2 = nil
			self.replayData_step1 = nil

		    local step = {randomSeed = 0, replaySteps = {}, level = levelId , selectedItemsData = {}}

		    if self.parameters then
		    	if self.parameters.preProps then

		    		table.insert(step.selectedItemsData , { id = 10087} )
		    		table.insert(step.selectedItemsData , { id = 10089} ) -- replace later
		    		table.insert(step.selectedItemsData , { id = 10018} )
		    		table.insert(step.selectedItemsData , { id = 10015} )
		    		table.insert(step.selectedItemsData , { id = 10007} )
		    		-- table.insert(step.selectedItemsData , { id = 10099} )
		    	end
		    end

		    --printx( 1 , "ReplayAutoCheckManager:doCheck     step = " , table.tostring(step))

			local newStartLevelLogic = NewStartLevelLogic:create( nil , step.level , step.selectedItemsData , false , {} )
			newStartLevelLogic:startWithReplay( ReplayMode.kConsistencyCheck_Step1 , step )
			--printx( 1 ,  "ReplayAutoCheckManager:doCheck   3")

			self.maxCounts = self.maxCounts - 1
	end

end

function ReplayAutoCheckManager:setSectionDataInStepOne( sectionData )
	self.sectionData_step1 = sectionData
end

function ReplayAutoCheckManager:setSectionDataInStepTwo( sectionData )
	self.sectionData_step2 = sectionData
end

function ReplayAutoCheckManager:setReplayDataInStepOne( replayData )
	self.replayData_step1 = replayData
end

function ReplayAutoCheckManager:encodeErrorData(rdata)
	local sectionData_step1 = rdata.s1
	local sectionData_step2 = rdata.s2

	local encodeList_1 = nil
	if sectionData_step1 then
		encodeList_1 = {}
		for i = 1 , #self.sectionData_step1 do
			local sectionData_s1 = self.sectionData_step1[i]
			table.insert( encodeList_1 , SectionResumeManager:encodeBySection( sectionData_s1 ) )
		end
	end

	local encodeList_2 = nil
	if sectionData_step2 then
		encodeList_2 = {}
		for i = 1 , #self.sectionData_step2 do
			local sectionData_s2 = self.sectionData_step2[i]
			table.insert( encodeList_2 , SectionResumeManager:encodeBySection( sectionData_s2 ) )
		end
	end

	return { s1 = encodeList_1 , s2 = encodeList_2 }
end

function ReplayAutoCheckManager:compareResult()

	--printx( 1 , "ReplayAutoCheckManager:compareResult  +++++++++++++++++++++++++++++++++++++++" , self.sectionData_step1 , self.sectionData_step2 )

	local rdata = {s1 = self.sectionData_step1 , s2 = self.sectionData_step2}

	if false then
		rdata = self:encodeErrorData(rdata)
		rdata.errorType = 5 --test
		return false , rdata
	end

	if self.sectionData_step1 and self.sectionData_step2 then

		if #self.sectionData_step1 ~= #self.sectionData_step2 then
			rdata = self:encodeErrorData(rdata)
			rdata.errorType = 1
			return false , rdata
		end

		for i = 1 , #self.sectionData_step1 do
			local sectionData_s1 = self.sectionData_step1[i]
			local sectionData_s2 = self.sectionData_step2[i]

			if not (sectionData_s1 and sectionData_s2) then
				rdata = self:encodeErrorData(rdata)
				rdata.errorType = 2
				rdata.stepIndex = i
				return false , rdata
			end

			if sectionData_s1.totalScore ~= sectionData_s2.totalScore then
				rdata = self:encodeErrorData(rdata)
				rdata.errorType = 3
				rdata.stepIndex = i
				rdata.totalScoreS1 = sectionData_s1.totalScore
				rdata.totalScoreS2 = sectionData_s2.totalScore
				return false , rdata
			end
		end

		return true
		
	else
		rdata = self:encodeErrorData(rdata)
		rdata.errorType = 4
		return false , rdata
	end
end

function ReplayAutoCheckManager:needContinueCheck()
	if self.maxCounts > 0 then
		return true
	end
	return false
end

function ReplayAutoCheckManager:outputResult( result , datas )

	--printx( 1 , "ReplayAutoCheckManager:outputResult  ~~~~~~~~~~~~~~~~~~~~~~~~~" , result  , "self.checkListIndex" , self.checkListIndex , debug.traceback() )

	

	if self.checkList and #self.checkList > 0 then

		local currData = self.checkList[self.checkListIndex]
		if not currData then return end

		if not self.resultMap[ currData.levelId ] then
			self.resultMap[ currData.levelId ] = {}
		end

		local levelResultData = self.resultMap[ currData.levelId ]

		if not levelResultData[ self.maxCounts + 1 ] then
			levelResultData[ self.maxCounts + 1 ] = {}
		end

		local levelResultCountData = levelResultData[ self.maxCounts + 1 ]

		levelResultCountData.result = result
		if not levelResultCountData.result then
			levelResultCountData.datas = datas
		end
		
		if not result then
			local testaaa = datas.s1[#datas.s1]

			--self:saveResult( currData.levelId , false , datas.s1[#datas.s1] , datas.s2[#datas.s2] )
			self:saveResult( currData.levelId , false , datas.s1 , datas.s2 )

			local fl = {}
			fl.levelId = currData.levelId
			fl.counts = self.maxCounts
			local list = {}
			table.insert(list , fl)

			if self.checkByListErrorCallback then self.checkByListErrorCallback( list ) end
			return
		else
			self:saveResult( currData.levelId , true ,nil , nil)

			self.checkListIndex = self.checkListIndex + 1
		
			local nextData = self.checkList[self.checkListIndex]

			if nextData then
				self:check( nextData.levelId , nextData.maxCounts , nextData.finCallback , nextData.errorCallback )
			else
				self:deleteLocalData()
				if self.checkByListFinCallback then self.checkByListFinCallback() end
			end
			return
		end


		--self:flush(2)
		
		self.checkListIndex = self.checkListIndex + 1
		
		local nextData = self.checkList[self.checkListIndex]
		
		if nextData then
			
			self:check( nextData.levelId , nextData.maxCounts , nextData.finCallback , nextData.errorCallback )
		else
			--checkList全部测试完毕，输出self.resultMap的结果


			local localData = self:readLocalData()

			if localData.list and #localData.list > 0 then
				for k,v in pairs(localData.list) do

					local fl = v
					--printx( 1 , "level  " .. tostring(fl.levelId) .. "  check failed at count " .. tostring(fl.counts) .. " errorType:" .. tostring(v1.datas.errorType) )
					printx( 1 , "level  " .. tostring(fl.levelId) .. "  check failed at count " .. tostring(fl.counts) )
					
				end

				if self.checkByListErrorCallback then self.checkByListErrorCallback( localData.list ) end
			else
				if self.checkByListFinCallback then self.checkByListFinCallback() end
			end

			

			--[[
			printx( 1 , "~~~~~~~~~~~~~~~~~~~~~~  ReplayAutoCheckManager:outputResult  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" )

			local failedLevels = {}
			for k,v in pairs(self.resultMap) do
				for k1,v1 in pairs(v) dol
					if not v1.result then
						local fl = {}
						fl.levelId = k
						fl.counts = k1
						fl.datas = v1.datas

						table.insert( failedLevels , fl )

						printx( 1 , "level  " .. tostring(fl.levelId) .. "  check failed at count " .. tostring(fl.counts) .. " errorType:" .. tostring(v1.datas.errorType) )
					end
				end
			end

			if #failedLevels == 0 then
				if self.checkByListFinCallback then self.checkByListFinCallback() end
			else
				if self.checkByListErrorCallback then self.checkByListErrorCallback( failedLevels ) end

				local dataText = table.serialize( failedLevels )
				Localhost:safeWriteStringToFile( dataText , HeResPathUtils:getUserDataPath() .. "/" .. "ReplayAutoCheckResult" .. ".ds")
			end
			]]
		end

	else
		--无checkList，测试完毕，直接输出结果
		printx( 1 , "~~~~~~~~~~~~~~~~~~~~~~  ReplayAutoCheckManager:outputResult  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" )
		printx( 1 , result )

		if result then
			if self.finCallback then self.finCallback() end
		else
			if self.errorCallback then self.errorCallback(datas) end
		end

	end

end

function ReplayAutoCheckManager:saveResult( levelId , result , sectionStep_1 , sectionStep_2)
	local localData = {}

	localData.checkList = self.checkList
	localData.checkByListParameter = self.checkByListParameter
	localData.checkListIndex = self.checkListIndex
	localData.currCount = self.maxCounts

	localData.LevelId = levelId
	localData.result = result
	
	--[[
	sectionStep_1.gameItemMap = nil
	sectionStep_1.boardmap = nil
	sectionStep_1.backItemMap = nil
	sectionStep_1.backBoardMap = nil

	sectionStep_1.theOrderList = nil
	sectionStep_1.allSeaAnimals = nil
	sectionStep_1.declare = nil
	sectionStep_1.blockProductRules = nil
	]]
	
	--[[
	for k,v in pairs(sectionStep_1.cachePool) do
		printx( 1 , "cachePool   K:" , k , "  V:" , v)

		
		for k1,v1 in pairs(v) do
			printx( 1 , "cachePool -----   K1:" , k1 , "  V1:" , v1)

			for k2,v2 in pairs(v1) do
				printx( 1 , "VVV -----   K2:" , k2 , "  V2:" , v2)
				
			end

		end

	end
	]]

	--sectionStep_1.cachePool = nil


	--sectionStep_1.sectionData = nil

	--[[
	for k,v in pairs(sectionStep_1) do
		printx( 1 , "testaaa   K:" , k , "  V:" , v)
	end
	]]

	--localData.datas = {}
	--table.insert( localData.datas , sectionStep_1 )
	localData.sectionStep_1 = sectionStep_1
	localData.sectionStep_2 = sectionStep_2

	local str1 = table.serialize( localData )
	--local str1 = amf3.encode( localData )
	--local str2 = mime.b64(str1)

	Localhost:safeWriteStringToFile( str1 , HeResPathUtils:getUserDataPath() .. "/" .. "ReplayAutoCheckResult" .. ".ds")
end

function ReplayAutoCheckManager:flush(flushType)

	local failedLevels = {}
	for k,v in pairs(self.resultMap) do
		for k1,v1 in pairs(v) do
			if not v1.result then
				local fl = {}
				fl.levelId = k
				fl.counts = k1
				--fl.datas = v1.datas

				table.insert( failedLevels , fl )

				--printx( 1 , "level  " .. tostring(fl.levelId) .. "  check failed at count " .. tostring(fl.counts) .. " errorType:" .. tostring(v1.datas.errorType) )
				printx( 1 , "level  " .. tostring(fl.levelId) .. "  check failed at count " .. tostring(fl.counts) )
			end
		end
	end

	if #failedLevels > 0 then

		local localData = self:readLocalData()
		for k,v in ipairs(failedLevels) do
			table.insert( localData.list , v )
		end

		localData.checkList = self.checkList
		localData.checkByListParameter = self.checkByListParameter
		localData.checkListIndex = self.checkListIndex
		localData.currCount = self.maxCounts

		local str1 = amf3.encode( localData )
		--local dataText = table.serialize( localData )
		Localhost:safeWriteStringToFile( str1 , HeResPathUtils:getUserDataPath() .. "/" .. "ReplayAutoCheckResult" .. ".ds")
	end
	self.resultMap = {}
end

function ReplayAutoCheckManager:readLocalData()
	local localDataText = nil
	
	local hFile, err = io.open( HeResPathUtils:getUserDataPath() .. "/" .. "ReplayAutoCheckResult" .. ".ds" , "r")
	if hFile and not err then
		localDataText = hFile:read("*a")
		io.close(hFile)
	end
	local localData = table.deserialize(localDataText)
	
	--[[
	local localData = nil
	if localDataText then
		localData = amf3.decode(localDataText) or {}
	end
	--]]
	 
	--[[
	if not localData then
		
		localData = {}
		localData.checkList = self.checkList
		localData.checkByListParameter = self.checkByListParameter
		localData.checkListIndex = self.checkListIndex
		localData.currCount = self.maxCounts

		localData.list = {}

	end
	]]
	return localData
end

function ReplayAutoCheckManager:deleteLocalData()
	os.remove( HeResPathUtils:getUserDataPath() .. "/" .. "ReplayAutoCheckResult" .. ".ds" )
end