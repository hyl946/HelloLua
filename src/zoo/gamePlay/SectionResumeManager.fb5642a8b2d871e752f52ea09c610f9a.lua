--断面恢复  用于AI学习和瞬时闪退恢复功能
SectionResumeManager = {}

SectionType = {
	
	kInit = 1 ,
	kSwap = 2 ,
	kSwapAndTryEndGame = 3 ,
	kUseProp = 4 ,
}

function SectionResumeManager:startLevel(mainlogic , logicVer)
	self.mainlogic = mainlogic
	self.sectionList = {}
	self.isReverting = false
	self:initToolbar()
	self.logicVer = logicVer or 1
end

function SectionResumeManager:endLevel()
	self.mainlogic = nil
	self.sectionList = nil
	self.logicVer = nil
end

function SectionResumeManager:getCurrSectionIndex()
	return self.currSectionIndex or 0
end

function SectionResumeManager:getLastSectionIndex()
	if self.sectionList then return #self.sectionList end
	return 0
end

function SectionResumeManager:addSection()
	--printx( 1 , "SectionResumeManager:addSection  000 ----- self.mainlogic.replayMode" , self.mainlogic.replayMode, self.isReverting )
	if not __WIN32 then
		--return nil
	end

	local useSection = false
	local saveFullStep = false
	local maxSectionCount = nil

	if _G.useSectionWhenCrash 
		or MaintenanceManager:getInstance():isEnabledInGroup( "CrashResumeNew" , "useSection" , UserManager:getInstance():getUID() or "12345" )
		or _G.autoShowSectionToolBar 
		or self.mainlogic.replayMode == ReplayMode.kMcts 
		or self.mainlogic.replayMode == ReplayMode.kConsistencyCheck_Step1 
		or self.mainlogic.replayMode == ReplayMode.kConsistencyCheck_Step2 then
		
		useSection = true

		if _G.autoShowSectionToolBar 
			or self.mainlogic.replayMode == ReplayMode.kConsistencyCheck_Step1 
			or self.mainlogic.replayMode == ReplayMode.kConsistencyCheck_Step2 then
			
			saveFullStep = true
			
			if not _G.autoShowSectionToolBar then
				maxSectionCount = 45
			end
		end

	end

	if self.isReverting then
		self.isReverting = false

		--[[
		local section = SaveRevertData:create( self.mainlogic )

		section.currRandomSeed = self.mainlogic.randFactory:getCurrHoldrand()
		section.currPrePropRandomSeed = self.mainlogic.prePropRandFactory:getCurrHoldrand()

		self:addSectionByData( section , self:getCurrSectionIndex() )
		]]

		if self.revertCallbackForAI then
			local callback = self.revertCallbackForAI
			callback()
			self.revertCallbackForAI = nil
		end
		return
	end

	if not useSection then
		return nil
	end

	if not saveFullStep then
		self.sectionList = {}
		self.currSectionIndex = 0
		--每次储存前先清空，只存一步
	elseif maxSectionCount then
		if #self.sectionList == maxSectionCount then
			table.remove( self.sectionList , 1 )
			self.currSectionIndex = self.currSectionIndex - 1
		end
	end

	if self.mainlogic then
		local section = SaveRevertData:create( self.mainlogic )

		--[[
		if self.mainlogic.PlayUIDelegate and self.mainlogic.PlayUIDelegate.getUsePropInfo then
			section:setUsePropInfo(self.mainlogic.PlayUIDelegate:getUsePropInfo())
		end
		]]

		if self.mainlogic.PlayUIDelegate 
			and self.mainlogic.PlayUIDelegate.propList
			and self.mainlogic.PlayUIDelegate.propList.leftPropList
			and self.mainlogic.PlayUIDelegate.propList.leftPropList.getSectionRevertData
			then

			local propListData = self.mainlogic.PlayUIDelegate.propList.leftPropList:getSectionRevertData()
			if propListData then
				section.propListData = propListData
			end
		end

		section.productItemAdjustContext = ProductItemDiffChangeLogic:getContext()
		--printx( 1, "SectionResumeManager:addSection ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  section.productItemAdjustContext =" , table.tostring(section.productItemAdjustContext) )

		section.realCostMove = self.mainlogic.realCostMove

		--printx( 1 , "SectionResumeManager:addSection  111  section =" , section , debug.traceback() )
		self:addSectionByData( section , self:getCurrSectionIndex() + 1 )
		self.currSectionIndex = self:getCurrSectionIndex() + 1
		self.currSectionShowIndex = self.currSectionIndex

		GlobalEventDispatcher:getInstance():dispatchEvent(
			Event.new(kGlobalEvents.kSectionResume, { currSectionIndex = self.currSectionIndex })
			)

		return section
	end

	return nil
end

function SectionResumeManager:addSectionByData( sectionData , sectionIndex )

	if not sectionIndex then sectionIndex = self:getCurrSectionIndex() + 1 end

	local section = sectionData

	if sectionIndex == self:getCurrSectionIndex() + 1 and self.nextSectionData then
		section.sectionData = self.nextSectionData
		section.sectionType = self.nextSectionData.sectionType

		self.nextSectionData = nil
	end

	--printx( 1 , "SectionResumeManager:addSectionByData  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ sectionIndex =" , sectionIndex , "section =" , section , debug.traceback() )

	self.sectionList[sectionIndex] = section
	--printx( 1 , "SectionResumeManager:addSectionByData   sectionData" , sectionData , "sectionIndex" , sectionIndex)
end

function SectionResumeManager:setCurrSectionInfo( sectionData )
	local section = self:getSectionByIndex( self:getCurrSectionIndex() )
	if section and not section.sectionType then
		section.sectionData = sectionData
		section.sectionType = sectionData.sectionType
	end
end

function SectionResumeManager:setNextSectionInfo( sectionData )
	self.nextSectionData = sectionData
	if self.sectionList[ self:getCurrSectionIndex() ] then
		local currData = self.sectionList[ self:getCurrSectionIndex() ]
		currData.nextSectionData = self.nextSectionData

		ReplayDataManager:updateCurrSectionDataToReplay()
	end
end

function SectionResumeManager:changeSectionType( sectionType , sectionIndex )
	if not sectionIndex then sectionIndex = self:getCurrSectionIndex() end
	local currSection = self:getSectionByIndex( sectionIndex )
	if currSection and currSection.sectionData then
		currSection.sectionData.sectionType = sectionType
		currSection.sectionType = sectionType
	end
end

function SectionResumeManager:getSectionByIndex(sectionIndex)
	if self.sectionList then 
		return self.sectionList[sectionIndex]
	end
	return nil
end

function SectionResumeManager:getCurrSectionData()
	if self.sectionList then 
		return self.sectionList[self:getCurrSectionIndex()]
	end
	return nil
end

function SectionResumeManager:recodeProductItemDiffContextTable( dataTable , opr )

	--[[
	local function docheck( tab )
		local recodeTab = {}
		for k,v in pairs( tab ) do
			if type(v) == "table" and k ~= "class" then

			elseif type(v) ~= "userdata" and type(v) ~= "function" then
				if k
				recodeTab[k]
			end
		end
	end
	]]

	local datas = {}


	local function docheck( tab )
		local recodeTab = {}
		for k,v in pairs( tab ) do
			if opr == 1 then
				recodeTab[tostring(k)] = v
			elseif opr == 2 then
				recodeTab[tonumber(k)] = v
			end
		end
		return recodeTab
	end

	if dataTable then

		for k1,v1 in pairs(dataTable) do

			if k1 == "defaultColorList" then
				datas.defaultColorList = docheck( dataTable.defaultColorList )
			elseif k1 == "singleDropConfig" then
				datas.singleDropConfig = docheck( dataTable.singleDropConfig )
			elseif k1 == "singleColorList" then
				datas.singleColorList = docheck( dataTable.singleColorList )
			elseif k1 == "falsifyMap" then
				datas.falsifyMap = docheck( dataTable.falsifyMap )
			elseif k1 == "availableColorList" then
				datas.availableColorList = docheck( dataTable.availableColorList )
			else
				datas[k1] = v1
			end
		end
	end
	return datas
end

function SectionResumeManager:encodeBySection( section )

	local dataTable = {}
	local mainlogic = self.mainlogic

	local cloneGameItemMapForRevert = {}
	local cloneBoardMapForRevert = {}
	local cloneGameBackItemMapForRevert = {}
	local cloneBackBoardMapForRevert = {}
	local cloneCachePoolForRevert = {}
	local cloneOrderList = {}
	local cloneSectionData = {}
	local cloneNextSectionData = {}

	local function cloneTable(oringinTable , targetTable)

		local function checkCanCopy(k , v)
			if k ~= "class" and type(v) ~= "function" and type(v) ~= "userdata" then
				return true
			end
			return false
		end

		for k,v in pairs(oringinTable) do

			if k == "_encrypt" then
				if oringinTable._encrypt.ItemColorType == 0 then
					targetTable["_encrypt_ItemColorType"] = 0
				else
					targetTable["_encrypt_ItemColorType"] = AnimalTypeConfig.convertColorTypeToIndex( oringinTable._encrypt.ItemColorType )
				end
			elseif k == "ItemSpecialType" then
				if oringinTable.ItemSpecialType == 0 then
					targetTable["ItemSpecialType"] = 0
				else
					targetTable["ItemSpecialType"] = AnimalTypeConfig.convertSpecialTypeToIndex( oringinTable.ItemSpecialType )
				end
			elseif k == "tileMoveMeta" then
				--[[
				local tileMoveMeta = {}
				for k1 , v1 in pairs(v) do
					if checkCanCopy( k , v ) then

						if type(v1) == "table" then
							tileMoveMeta[k1] = {}

							for k2 , v2 in pairs(v1) do
								if checkCanCopy( k2 , v2 ) then
									table.insert( tileMoveMeta[k1] , v2 )
								end
							end
							
						else
							tileMoveMeta[k1] = v1
						end
					end
				end

				targetTable[k] = tileMoveMeta
				]]
				targetTable[k] = v:encodeForSectionData()

			elseif k == "chains" then

				local chains = {}
				for k2,v2 in pairs(v) do
					chains[tostring(k2)] = v2
				end
				targetTable[k] = chains

			elseif k == "blocker199Colors" or k == "blocker83Colors" then
				local colorIndexList = {}

				for k1 , v1 in ipairs(v) do
					table.insert( colorIndexList , AnimalTypeConfig.convertColorTypeToIndex( v1 ) )
				end
				targetTable[k] = colorIndexList
			elseif k == "blocker199Dirs" then
				local fixedList = {}
				for k1 , v1 in ipairs(v) do
					table.insert( fixedList , "k_" .. tostring(v1) )
				end
				targetTable[k] = fixedList
			elseif k ~= "class" and type(v) ~= "function" and type(v) ~= "userdata" then
				targetTable[k] = v
			end
		end
	end

	for r = 1, 9 do
		cloneGameItemMapForRevert[r] = {}
		for c = 1, 9 do
			
			local cloneData = {}
			local oringinData = section.gameItemMap[r][c]
			cloneTable( oringinData , cloneData )

			cloneGameItemMapForRevert[r][c] = cloneData
		end
	end

	for r = 1, 9 do
		cloneBoardMapForRevert[r] = {}
		for c = 1, 9 do

			local cloneData = {}
			local oringinData = section.boardmap[r][c]
			cloneTable( oringinData , cloneData )

			cloneBoardMapForRevert[r][c] = cloneData
		end
	end
	
	if section.backItemMap then
		for r = 1, 9 do
			if section.backItemMap[r] then
				cloneGameBackItemMapForRevert[r] = {}
				for c = 1, 9 do
					if section.backItemMap[r][c] then

						local cloneData = {}
						local oringinData = section.backItemMap[r][c]
						cloneTable( oringinData , cloneData )

						cloneGameBackItemMapForRevert[r][c] = cloneData
					end
				end
			end
		end
	end
	
	if section.backBoardMap then
		for r = 1, 9 do
			if section.backBoardMap[r] then
				cloneBackBoardMapForRevert[r] = {}
				for c = 1, 9 do
					if section.backBoardMap[r][c] then

						local cloneData = {}
						local oringinData = section.backBoardMap[r][c]
						cloneTable( oringinData , cloneData )

						cloneBackBoardMapForRevert[r][c] = cloneData
					end
				end
			end
		end
	end

	if section.cachePoolV2 then

		if self.logicVer == 2 then
			-- printx( 1 , "WTFFFFFFFFFFFFFFFF???????????????????????????  section.cachePoolV2 =" , table.tostring(section.cachePoolV2) )
			for k2,v2 in ipairs(section.cachePoolV2) do
				cloneCachePoolForRevert[k2] = {}
				for k,v in pairs(v2) do

					local nk = "k" .. tostring(k)

					-- local fchar = string.sub( nk , 1 , 1 )
					-- local test111 = string.sub( nk , 2 )
					-- printx( 1 , "fchar = " , fchar , "test111 =" , test111)

					cloneCachePoolForRevert[k2][nk] = {}

					for k1,v1 in ipairs(v) do
						local cloneData = {}
						cloneTable( v1 ,  cloneData )
						table.insert( cloneCachePoolForRevert[k2][nk], cloneData )
					end
				end
			end
		else
			for k2,v2 in ipairs(section.cachePoolV2) do
				cloneCachePoolForRevert[k2] = {}
				for k,v in pairs(v2) do
					local obj = {}
					obj.itemType = k
					obj.list = {}
					for k1,v1 in pairs(v) do
						local cloneData = {}
						cloneTable( v1 , cloneData )
						table.insert( obj.list , cloneData )
					end

					table.insert( cloneCachePoolForRevert[k2] , obj )
				end
			end
		end
	end

	if section.theOrderList then

		for k,v in ipairs(section.theOrderList) do
			local cloneData = {}
			cloneData.key1 = v.key1
			cloneData.key2 = v.key2
			cloneData.v1 = tostring(v.v1)
			cloneData.f1 = tostring(v.f1)
			table.insert( cloneOrderList , cloneData )
		end
	end


	if section.sectionData then
		cloneTable( section.sectionData , cloneSectionData )
	end

	if section.nextSectionData then
		cloneTable( section.nextSectionData , cloneNextSectionData )
	end

	dataTable.gameItemMap = cloneGameItemMapForRevert
	dataTable.boardmap = cloneBoardMapForRevert
	dataTable.backItemMap = cloneGameBackItemMapForRevert
	dataTable.backBoardMap = cloneBackBoardMapForRevert
	dataTable.cachePoolV2 = cloneCachePoolForRevert
	
	dataTable.theOrderList = cloneOrderList
	dataTable.sectionData = cloneSectionData
	dataTable.nextSectionData = cloneNextSectionData

	-- printx( 1 , "WTFFFFFFFFFFFFFFFFFFFFFFFFFF ?????????????????????????  dataTable.cachePool =" , table.tostring(dataTable.cachePool) )

	if section.blocker206Cfg then
		dataTable.blocker206Cfg = {}

		for k,v in pairs(section.blocker206Cfg) do
			dataTable.blocker206Cfg[ tostring(k) ] = tostring(v) 
		end
	end

	if section.productItemAdjustContext then
		dataTable.productItemAdjustContext = self:recodeProductItemDiffContextTable( section.productItemAdjustContext , 1 )
	end
	

	for k,v in pairs(section) do
		if type(v) ~= "function" and type(v) ~= "userdata" 
			and k ~= "gameItemMap"
			and k ~= "boardmap"
			and k ~= "backItemMap"
			and k ~= "backBoardMap"
			and k ~= "cachePool"
			and k ~= "cachePoolV2"
			and k ~= "theOrderList"
			and k ~= "sectionData"
			and k ~= "nextSectionData"
			and k ~= "blocker206Cfg"
			and k ~= "productItemAdjustContext"
			and k ~= "class"
			then

			if k == "totalScore"
				or k == "currRandomSeed"
				or k == "currPrePropRandomSeed"
			then
				dataTable[k] = tostring(v)
			else
				dataTable[k] = v
			end
		end
	end

	--ActCollectionLogic:revertOneStep()

	return dataTable

end


function SectionResumeManager:decodeByTable( dataTable )
	--local section = SaveRevertData:create( self.mainlogic )
	local section = SaveRevertData.new()
	

	local mainlogic = self.mainlogic



	local cloneGameItemMapForRevert = {}
	local cloneBoardMapForRevert = {}
	local cloneGameBackItemMapForRevert = {}
	local cloneBackBoardMapForRevert = {}
	local cloneCachePoolForRevert = {}
	local cloneOrderList = {}
	local cloneSectionData = nil
	local cloneNextSectionData = nil

	local function cloneTable(oringinTable , targetTable)
		for k,v in pairs(oringinTable) do
			if k == "_encrypt_ItemColorType" then
				if tonumber(oringinTable._encrypt_ItemColorType) == 0 then
					targetTable._encrypt.ItemColorType = 0
				else
					targetTable._encrypt.ItemColorType = AnimalTypeConfig.convertIndexToColorType( tonumber(oringinTable._encrypt_ItemColorType) )
				end
			elseif k == "ItemSpecialType" then
				if tonumber(oringinTable.ItemSpecialType) == 0 then
					targetTable["ItemSpecialType"] = 0
				else
					targetTable["ItemSpecialType"] = AnimalTypeConfig.specialTypeList[ tonumber(oringinTable.ItemSpecialType) ]
				end
			elseif k == "tileMoveMeta" then
				--[[
				targetTable.tileMoveMeta = TileMoveMeta:create()
				local tileMoveMeta = targetTable.tileMoveMeta

				for k1 , v1 in pairs(v) do

					if type(v1) == "table" then

						if not tileMoveMeta[k1] then
							tileMoveMeta[k1] = {}
						end

						for k2 , v2 in pairs(v1) do
							tileMoveMeta[k1][k2] = TileMoveRouteMeta.new()
							local tileMoveRouteMeta = tileMoveMeta[k1][k2]
							for k3 , v3 in pairs(v2) do
								tileMoveRouteMeta[k3] = v3
							end
						end
					else
						tileMoveMeta[k1] = v1
					end
				end
				]]
				targetTable.tileMoveMeta = TileMoveMeta:create( v.meta , v.gameMode )
			elseif k == "chains" then

				local chains = {}
				for k2,v2 in pairs(v) do
					chains[tonumber(k2)] = v2
				end
				targetTable[k] = chains
			elseif k == "blocker199Colors" or k == "blocker83Colors" then
				
				local colorList = {}

				for k1 , v1 in ipairs(v) do
					table.insert( colorList ,  AnimalTypeConfig.convertIndexToColorType( tonumber(v1) ) )
				end
				targetTable[k] = colorList
			elseif k == "blocker199Dirs" then
				local fixedList = {}
				for k1 , v1 in ipairs(v) do
					if type(v1) == "string" then
						local nn = tonumber( string.sub( v1 , 3 ) )
						if nn then
							table.insert( fixedList , nn )
						end
					end
				end
				targetTable[k] = fixedList
			elseif k ~= "class" and type(v) ~= "function" and type(v) ~= "userdata" then
				targetTable[k] = v
			end
		end
	end

	for r = 1, 9 do
		cloneGameItemMapForRevert[r] = {}
		for c = 1, 9 do
			
			local cloneData = GameItemData:create()
			local oringinData = dataTable.gameItemMap[r][c]
			cloneTable( oringinData , cloneData )

			cloneGameItemMapForRevert[r][c] = cloneData
		end
	end

	for r = 1, 9 do
		cloneBoardMapForRevert[r] = {}
		for c = 1, 9 do

			local cloneData = GameBoardData:create()
			local oringinData = dataTable.boardmap[r][c]
			cloneTable( oringinData , cloneData )

			cloneBoardMapForRevert[r][c] = cloneData
		end
	end

	if dataTable.backItemMap then
		for r = 1, 9 do
			if dataTable.backItemMap[r] then
				cloneGameBackItemMapForRevert[r] = {}
				for c = 1, 9 do
					if dataTable.backItemMap[r][tostring(c)] then

						local cloneData = GameItemData:create()
						local oringinData = dataTable.backItemMap[r][tostring(c)]
						cloneTable( oringinData , cloneData )
						cloneGameBackItemMapForRevert[r][c] = cloneData
					end
				end
			end
		end
	end
	
	if dataTable.backBoardMap then
		for r = 1, 9 do
			if dataTable.backBoardMap[r] then
				cloneBackBoardMapForRevert[r] = {}
				for c = 1, 9 do
					if dataTable.backBoardMap[r][tostring(c)] then

						local cloneData = GameBoardData:create()
						local oringinData = dataTable.backBoardMap[r][tostring(c)]
						cloneTable( oringinData , cloneData )

						cloneBackBoardMapForRevert[r][c] = cloneData
					end
				end
			end
		end
	end

	if dataTable.cachePoolV2 then

		if self.logicVer == 2 then
			for k2,v2 in ipairs(dataTable.cachePoolV2) do
				cloneCachePoolForRevert[k2] = {}
				for k,v in pairs(v2) do

					local fchar = string.sub( tostring(k) , 1 , 1 )
					if fchar ~= "k" then
						break
					end

					local str = string.sub( tostring(k) , 2 )
					local arr = string.split( str , "_" )

					local ruleId = nil
					if #arr == 1 then
						ruleId = tonumber( str )
					else
						ruleId = str
					end

					cloneCachePoolForRevert[k2][ ruleId ] = {}
					for k1,v1 in ipairs(v) do
						local cloneData = {}
						cloneTable( v1 ,  cloneData )
						table.insert( cloneCachePoolForRevert[k2][ ruleId ] , cloneData )
					end
				end
			end
		else
			for k2,v2 in ipairs(dataTable.cachePoolV2) do
				cloneCachePoolForRevert[k2] = {}
				for k,v in pairs(v2) do

					cloneCachePoolForRevert[k2][ v.itemType ] = {}
					for k1,v1 in pairs(v.list) do
						local cloneData = GameItemData:create()
						cloneTable( v1 , cloneData )
						table.insert( cloneCachePoolForRevert[k2][ v.itemType ] , cloneData )
					end
				end
			end
		end
	end

	if dataTable.theOrderList then

		for k,v in ipairs(dataTable.theOrderList) do
			local cloneData = GameItemOrderData:create( v.key1 , v.key2 , tonumber(v.v1) , true )
			cloneData.f1 = tonumber(v.f1)
			table.insert( cloneOrderList , cloneData )
		end
	end

	if dataTable.sectionData then
		cloneSectionData = SectionData:create()
		cloneTable( dataTable.sectionData , cloneSectionData )
	end

	if dataTable.nextSectionData then

		cloneNextSectionData = SectionData:create()
		cloneTable( dataTable.nextSectionData , cloneNextSectionData )
	end

	section.gameItemMap = cloneGameItemMapForRevert
	section.boardmap = cloneBoardMapForRevert
	section.backItemMap = cloneGameBackItemMapForRevert
	section.backBoardMap = cloneBackBoardMapForRevert
	section.cachePoolV2 = cloneCachePoolForRevert
	section.theOrderList = cloneOrderList
	section.sectionData = cloneSectionData
	section.nextSectionData = cloneNextSectionData

	-- printx( 1 , "WTFFFFFFFFFFFFFFFFFFFFFFFFFF !!!!!!!!!!!!!!!!!!!!!!  section.cachePool =" , table.tostring(section.cachePool) )

	if dataTable.blocker206Cfg then
		section.blocker206Cfg = {}

		for k,v in pairs(dataTable.blocker206Cfg) do
			section.blocker206Cfg[ tonumber(k) ] = tonumber(v) 
		end
	end

	if dataTable.productItemAdjustContext then
		section.productItemAdjustContext = self:recodeProductItemDiffContextTable( dataTable.productItemAdjustContext , 2 )
	end

	for k,v in pairs(dataTable) do
		if type(v) ~= "function" and type(v) ~= "userdata" 
			and k ~= "gameItemMap"
			and k ~= "boardmap"
			and k ~= "backItemMap"
			and k ~= "backBoardMap"
			and k ~= "cachePool"
			and k ~= "cachePoolV2"
			and k ~= "theOrderList"
			and k ~= "sectionData"
			and k ~= "blocker206Cfg"
			and k ~= "productItemAdjustContext"
			and k ~= "nextSectionData"
			then

			if k == "totalScore"
				or k == "currRandomSeed"
				or k == "currPrePropRandomSeed"
			then
				section[k] = tonumber(v)
			else
				section[k] = v
			end
		end
	end
	--ActCollectionLogic:revertOneStep()
	return section

end

function SectionResumeManager:doRevert( section , passOperationPlayback , swapCallback )
	if not section then return end

	if section.realCostMove then
		self.mainlogic.realCostMove = section.realCostMove
	end

	self.mainlogic.hasAddMoveStep = nil
	self.mainlogic.saveRevertData = section
	self.mainlogic.gameMode:revertDataFromBackProp()

	--[[
	local propAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kPropsAction, 
		GamePropsActionType.kBack, 
		nil, 
		nil, 
		GamePlayConfig_Back_Animation_CD)

	self.mainlogic:addPropAction(propAction)
	self.mainlogic.fsm:changeState(self.mainlogic.fsm.usePropState)
	]]

	self.mainlogic.boardView:reInitByGameBoardLogic()
	self.mainlogic.gameMode:revertUIFromBackProp(mainLogic)

	self.mainlogic.randFactory:randSeed( section.currRandomSeed )
	self.mainlogic.prePropRandFactory:randSeed( section.currPrePropRandomSeed )

	if section.propListData then
		if self.mainlogic.PlayUIDelegate 
			and self.mainlogic.PlayUIDelegate.propList
			and self.mainlogic.PlayUIDelegate.propList.leftPropList
			and self.mainlogic.PlayUIDelegate.propList.leftPropList.revertBySectionData
			then

			local fixPropId = nil
			if section.nextSectionData and section.nextSectionData.sectionType == SectionType.kUseProp then
				fixPropId = section.nextSectionData.propId
			end

			self.mainlogic.PlayUIDelegate.propList.leftPropList:revertBySectionData( section.propListData )

			if fixPropId then

				local itemFound, itemIndex = self.mainlogic.PlayUIDelegate.propList.leftPropList:findItemByItemID( fixPropId )
				if not itemFound then
					local mappingItemId = PropsModel.kTempPropMapping[tostring( fixPropId )]
				    if mappingItemId then 
				    	itemFound, itemIndex = self.mainlogic.PlayUIDelegate.propList.leftPropList:findItemByItemID(mappingItemId) 
				    end
				end

				if itemFound then
					itemFound:confirm( fixPropId , ccp(0,0) )
				end
			end
		end
	end

	ProductItemDiffChangeLogic:setContext( section.productItemAdjustContext )

	self.mainlogic:updateFieldLogicPossibility_activeAll()
	self.mainlogic:startWaitingOperation()
	ProductItemDiffChangeLogic:onBoardStableHandler( self.mainlogic )


	local result = 0

	if section.nextSectionData and not passOperationPlayback then
		--printx( 1 , "SectionResumeManager:doRevert   section.nextSectionData =" , table.tostring(section.nextSectionData))

		if section.nextSectionData.sectionType == SectionType.kSwapAndTryEndGame then
			self.mainlogic:refreshComplete()
			result = 1
		elseif section.nextSectionData.sectionType == SectionType.kSwap then
			self.mainlogic:startTrySwapedItem(
				section.nextSectionData.pos1.r, 
				section.nextSectionData.pos1.c, 
				section.nextSectionData.pos2.r, 
				section.nextSectionData.pos2.c,
				swapCallback
				)
			result = 2
		elseif section.nextSectionData.sectionType == SectionType.kUseProp then

			if section.nextSectionData.propId ~= GamePropsType.kMoleWeeklyRaceSPProp then
				self.mainlogic:useProps( 
					section.nextSectionData.propId, 
					section.nextSectionData.pos1.r, 
					section.nextSectionData.pos1.c, 
					section.nextSectionData.pos2.r, 
					section.nextSectionData.pos2.c
					)
			end
			
			result = 3
		end
	end

	LevelDifficultyAdjustManager:checkAdjustStrategyInLevelByLastLocalData()

	--self.mainlogic.fsm:changeState(self.mainlogic.fsm.waitingState)

	return result
end

function SectionResumeManager:doRevertByIndex( tarIndex , mode )
	--printx( 1 , "SectionResumeManager:doRevertByIndex  tarIndex =" , tarIndex , "mode =" , mode )
	if self.mainlogic and self.sectionList then
		local section = self.sectionList[ tarIndex ]
		--printx( 1 , "SectionResumeManager:doRevertByIndex   tarIndex =" , tarIndex , "section =" , section)

		if section then

			self.isReverting = true

			if not mode then mode = 1 end

			if mode == 1 then
				self.currSectionIndex = tarIndex
			elseif mode == 2 then
				self.currSectionShowIndex = tarIndex
			end

			self:doRevert(section , true)
		end
	end
end

function SectionResumeManager:doRevertByNextIndex( mode )
	local tarIndex = 0

	if mode == 1 then
		tarIndex = self:getCurrSectionIndex() + 1
	elseif mode == 2 then
		tarIndex = self.currSectionShowIndex + 1
	end

	self:doRevertByIndex( tarIndex , mode )
end

function SectionResumeManager:doRevertByPrevIndex( mode )
	local tarIndex = 0

	if mode == 1 then
		tarIndex = self:getCurrSectionIndex() - 1
	elseif mode == 2 then
		tarIndex = self.currSectionShowIndex - 1
	end

	self:doRevertByIndex( tarIndex , mode )
end


function SectionResumeManager:getCurrSectionDatas()
	return self.sectionList
end


function SectionResumeManager:initToolbar()
	self.currSectionIndex = 0
	self.currSectionShowIndex = 0
end


function SectionResumeManager:deleteDatasOverCurrSectionIndex()
	local ci = self:getCurrSectionIndex()
	local li = self:getLastSectionIndex()

	for i = ci + 1 , li do
		self.sectionList[i] = nil
	end
end


function SectionResumeManager:getCurrSerializedSectionData()
	local sectionData = self:getCurrSectionData()
	-- he_log_error("save move" .. sectionData.theCurMoves)
	local dataTable = self:encodeBySection( sectionData )
	--local dataText = table.serialize( dataTable )
	local dataText = amf3.encode( dataTable )
	return dataText
end

function SectionResumeManager:revertBySerializedSectionData( dataText , callback )
	--local dataTable = table.deserialize( dataText )
	assert( dataText , "SectionResumeManager:revertBySerializedSectionData   dataText can not be nil !!!!!!!!!!!!" )
	local dataTable = amf3.decode( dataText )
	local sectionData = self:decodeByTable( dataTable )
	-- he_log_error("revert move" .. sectionData.theCurMoves)
	self.isReverting = true
	self.currSectionIndex = 1
	self.sectionList = {}
	self:doRevert( sectionData )
	self.revertCallbackForAI = callbacksectionData
end

function SectionResumeManager:testDemoForAI()
	self.AIStartStep = 2
	self.AIEndStep = 6
	self.testDemoForAIEnable = true
	self.testCount = 0

	--printx()
end

function SectionResumeManager:isTestDemoForAIEnable()
	return self.testDemoForAIEnable
end

function SectionResumeManager:getTestDemoForAIStartStep()
	return self.AIStartStep
end

function SectionResumeManager:getTestDemoForAIEndStep()
	return self.AIEndStep
end

function SectionResumeManager:addTestDemoForAICount()
	self.testCount = self.testCount + 1
end

function SectionResumeManager:getTestDemoForAICount()
	return self.testCount
end

function SectionResumeManager:getIsReverting()
	return self.isReverting
end

----------------------------------------------------------
