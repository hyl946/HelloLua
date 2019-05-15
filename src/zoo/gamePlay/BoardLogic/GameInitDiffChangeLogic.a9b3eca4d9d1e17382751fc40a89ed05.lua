require "zoo.gamePlay.config.GameInitDiffChangeLogicPatternConfig"

local function getCurrUid()
	return UserManager:getInstance():getUID() or "12345"
end

GameInitDiffChangeLogic = {}

local modeCount = 9

local patternConfig = GameInitDiffChangeLogicPatternConfig


LevelDiffAdjustTestPanel = class(BasePanel)

function LevelDiffAdjustTestPanel:create()
	local panel = LevelDiffAdjustTestPanel.new()
	panel:loadRequiredResource("ui/CrashResumePanel.json")
	panel:init()
	return panel
end

function LevelDiffAdjustTestPanel:init()
	self.ui = self:buildInterfaceGroup("CrashResumePanel/LevelDiffAdjustTestPanel")
	BasePanel.init(self, self.ui)

	self.label_title = self.ui:getChildByName("label_title")
	self.label_desc = self.ui:getChildByName("label_desc")

	self.label_title:setString( "不要动！！" ) 
	self.label_desc:setString( "正在分析第1关 ... 0%" ) 
	self.maxLevelId = LevelMapManager:getMaxMainLineLevelId()
end

function LevelDiffAdjustTestPanel:updateProgress( levelId )
	--printx( 1 , "LevelDiffAdjustTestPanel:updateProgress  " , levelId , self.maxLevelId)
	local jd = math.floor( (levelId / self.maxLevelId) * 100 )
	self.label_desc:setString( "正在分析第" .. tostring(levelId) .. "/" .. tostring(self.maxLevelId) .. "关 ... " .. tostring(jd) .. "%" ) 
end

function LevelDiffAdjustTestPanel:popout()

	local scene = Director.sharedDirector():getRunningScene()
	if scene == nil then 
		self:dispose()
		return 
	end

	self:setPositionForPopoutManager()
	PopoutManager:sharedInstance():add(self, true, false)
end

function LevelDiffAdjustTestPanel:onCloseBtnTapped()
	PopoutManager:sharedInstance():remove(self, true)
end
-----------------------------------------------------------------------


function GameInitDiffChangeLogic:startLevel( mainLogic )
	self.mainLogic = mainLogic
end

function GameInitDiffChangeLogic:endLevel()
	self.mode = nil
end

function GameInitDiffChangeLogic:changeMode( mode , ds )
	self.mode = mode
end

function GameInitDiffChangeLogic:testChangeMode()

	if not self.mode then self.mode = 0 end

	self.mode = self.mode + 1

	if self.mode > modeCount then self.mode = nil end

	if self.mode then
		local str = "nil"
		if self.mode == 1 then
			str = " mode" .. tostring(self.mode) .. "(直线)"
		elseif self.mode == 2 then
			str = " mode" .. tostring(self.mode) .. "(爆炸)"
		elseif self.mode == 3 then
			str = " mode" .. tostring(self.mode) .. "(直线+直线)"
		elseif self.mode == 4 then
			str = " mode" .. tostring(self.mode) .. "(直线+爆炸)"
		elseif self.mode == 5 then
			str = " mode" .. tostring(self.mode) .. "(魔力鸟)"
		elseif self.mode == 6 then
			str = " mode" .. tostring(self.mode) .. "(爆炸+爆炸)"
		elseif self.mode == 7 then
			str = " mode" .. tostring(self.mode) .. "(魔力鸟+直线)"
		elseif self.mode == 8 then
			str = " mode" .. tostring(self.mode) .. "(魔力鸟+爆炸)"
		elseif self.mode == 9 then
			str = " mode" .. tostring(self.mode) .. "(魔力鸟+魔力鸟)"
		end
		CommonTip:showTip( "激活虚拟种子\n" .. str , "negative", nil, 3)
	else
		CommonTip:showTip( "关闭虚拟种子" , "negative", nil, 3)
	end
	
end

function GameInitDiffChangeLogic:checkAllLevel()

	self.checkAllLevelIndex = 1
	self.checkNumOnCurrFrame = 0
	self.progressPanel = LevelDiffAdjustTestPanel:create()

	local checkDatas = {}
	local maxLevelId = LevelMapManager:getMaxMainLineLevelId()

	--maxLevelId = 1

	local function onUpdate()

		for levelId = self.checkAllLevelIndex , maxLevelId do

			self.checkNumOnCurrFrame = self.checkNumOnCurrFrame + 1
			if self.checkNumOnCurrFrame > 1 then
				self.checkAllLevelIndex = levelId
				self.checkNumOnCurrFrame = 0
				return
			end
			self.progressPanel:updateProgress(levelId)
			--printx( 1 , "GameInitDiffChangeLogic:checkAllLevel  Level   ------------------" , levelId )
			--printx( 1 , "WTF!!! !!!!!!!!!!!!!!!!!")
			local levelConfig = LevelDataManager.sharedLevelData():getLevelConfigByID( levelId , true )
			--printx( 1 , table.tostring(levelConfig))
			
			--if true then return end

			local itemMap = {}
			local boardMap = {}

			for i= 1,9 do
				boardMap[i] = {}
				for j=1,9 do
					boardMap[i][j] = GameBoardData:create();
				end
			end

			for i=1,9 do
				itemMap[i] = {}
				for j=1,9 do
					itemMap[i][j] = GameItemData:create();
				end
			end


			local tileMap = levelConfig.tileMap
			local animalMap = levelConfig.animalMap
			--printx( 1 , "WTF!!! 111")
			for r = 1, #tileMap do
				--printx( 1 , "WTF!!!  222")
				if boardMap[r] == nil then boardMap[r] = {} end
				if itemMap[r] == nil then itemMap[r] = {} end

				for c = 1, #tileMap[r] do
					--printx( 1 , "WTF!!!  333")
					local tileDef = tileMap[r][c]
					local gameMode = levelConfig.gameMode
					local tileMoveCfg = levelConfig.tileMoveCfg

					local itemData = itemMap[r][c]
					local boardData = boardMap[r][c]
					local theGamePlayType = LevelMapManager:getLevelGameModeByName(gameMode)

					if boardData then
						boardData:initByConfig(tileDef)
						boardData:setGameModeId(theGamePlayType)
						if boardData.isMoveTile then
							boardData:initTileMoveByConfig(tileMoveCfg)
						end
					end
					
					if itemData then
						itemData:initByConfig(tileDef)

						local balloonFrom = levelConfig.balloonFrom or 0
						local addMoveBase = GamePlayConfig_Add_Move_Base
						local addTime = 0

						if levelConfig.addMoveBase and levelConfig.addMoveBase > 0 then
							addMoveBase = tonumber(levelConfig.addMoveBase)
							if addMoveBase > 9 then
								addMoveBase = 9
							end
						end

						if levelConfig.addTime then
							addTime = tonumber(levelConfig.addTime)
							if addTime > 9 then
								addTime = 9
							end
						end

						itemData:initBalloonConfig(balloonFrom)
						itemData:initAddMoveConfig(addMoveBase)
						itemData:initAddTimeConfig(addTime)
					end

					if gameMode == GameModeType.TASK_UNLOCK_DROP_DOWN then 
						if itemData then
							itemData:initUnlockAreaDropDownModeInfo()
						end

						if boardData then
							boardData:initUnlockAreaDropDownModeInfo()
						end
					end

					if itemData then
						local animalDef = animalMap[r][c]
						itemData:initByAnimalDef(animalDef)
					end
					

				end
			end
			--printx( 1 , "WTF!!!  444")
			local resultdata = {}

			for i = 1 , modeCount do
				local result , selectData , allResultList = GameInitDiffChangeLogic:tryChangeBoardByVirtualSeed( 
					{mode = i , lockMode = true , onlyCheck = true , itemMap = itemMap , boardMap = boardMap} )

				resultdata[i] = {}
				resultdata[i].result = result
				resultdata[i].selectData = selectData
				resultdata[i].allResultList = allResultList
				resultdata[i].possbileNum = #allResultList
			end

			checkDatas[levelId] = resultdata

			--[[
			for i = 1 , #allResultList do
				printx( 1 , "GameInitDiffChangeLogic:checkAllLevel result:" , i , allResultList[i].pos , allResultList[i].config )
			end
			]]
			--printx( 1 , "----------------------------------------------------\n" )
		end

		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerTimerId)
		self.schedulerTimerId = nil

		self:exportCheckAllLevelData(checkDatas)

		self.progressPanel:onCloseBtnTapped()
		self.progressPanel = nil
	end

	local scheduler = CCDirector:sharedDirector():getScheduler()
	self.schedulerTimerId = scheduler:scheduleScriptFunc(onUpdate, 1/60 , false)

	self.progressPanel:popout()
end


function GameInitDiffChangeLogic:exportCheckAllLevelData(checkDatas)

	local datastr = "levelId,num1,num2,num3,num4,num5,num6,num7,num8,num9,pos1,pos2,pos3,pos4,pos5,pos6,pos7,pos8,pos9\n"

	for k,v in ipairs(checkDatas) do
		--printx( 1 , "Check Result ----------------------   levelId" ,k )	

		local numstr = tostring(k) .. ","
		local posstr = ""

		for i = 1 , modeCount do
			local rd = v[i]
			--printx( 1 , "mode" .. tostring(i) , "result" , rd.result , " num" , rd.possbileNum)	
			numstr = numstr .. tostring(rd.possbileNum) .. ","

			local str = ""
			for k1,v1 in pairs(rd.allResultList) do
				str = str .. tostring(v1.centerR) .. "_" .. tostring(v1.centerC) .. "-" .. tostring(v1.patternIndex) .. "|"
			end
			posstr = posstr .. str .. ","
		end

		datastr = datastr .. tostring(numstr) .. tostring(posstr)

		--printx( 1 , "---------------------------------------------" )	
		datastr = datastr .. "\n"
	end

	Localhost:safeWriteStringToFile( datastr , HeResPathUtils:getUserDataPath() .. "/GameInitDiffChangeLogicLevelDatas" .. ".csv" )
end

function GameInitDiffChangeLogic:rand(v1 , v2)
	return math.random( v1 , v2 )
end

function GameInitDiffChangeLogic:doChangeBoardByVirtualSeed(resultData)
	local r = resultData.centerR
	local c = resultData.centerC

	local configList = patternConfig["mode" .. tostring(resultData.typeIndex)]
	local config = configList[resultData.patternIndex]

	local resultPosList = {}

	local itemMap = self.mainLogic.gameItemMap
	local boardMap = self.mainLogic.boardmap

	--[[
	printx( 1 , "\nGameInitDiffChangeLogic  resultData " , r,c , 
		"mod" .. tostring(resultData.typeIndex) .. "_" .. tostring(resultData.patternIndex) .. 
		"  in " .. tostring(#resultPosList) .. " pattern")

	local function showTestTip()
		CommonTip:showTip( "VSEED mode" .. tostring(resultData.typeIndex) .. "_" .. tostring(resultData.patternIndex) ..
			" at[" .. tostring(resultData.centerR) .. "," .. tostring(resultData.centerC) .. "]" .. "  total:" .. tostring(#resultPosList)
			, "negative", nil, 30)
	end

	setTimeOut( showTestTip , 3 )
	]]


	if itemMap[r] and itemMap[r][c] then

		local color = self.mainLogic:randomColor()

		local cIndex1 = self.mainLogic.randFactory:rand(1,#self.mainLogic.mapColorList)
		local cIndex2 = nil

		if cIndex1 == #self.mainLogic.mapColorList then
			cIndex2 = self.mainLogic.randFactory:rand(1,#self.mainLogic.mapColorList - 1)
		else
			cIndex2 = self.mainLogic.randFactory:rand(cIndex1 + 1,#self.mainLogic.mapColorList)
		end

		local color1 =  self.mainLogic.mapColorList[cIndex1]
		local color2 =  self.mainLogic.mapColorList[cIndex2]

		local item = itemMap[r][c]
		item._encrypt.ItemColorType = color1
		item.isLockColorOnInit = true

		--printx( 1 , "GameInitDiffChangeLogic  resultData 111")

		for k,v in ipairs(config) do

			local fixr = v.dr
			local fixc = v.dc

			local ra = r + fixr - 4
			local ca = c + fixc - 4

			--printx( 1 , "GameInitDiffChangeLogic  aroundItem 222" , ra , ca)
			if itemMap[ra] and itemMap[ra][ca] then
				local aroundItem = itemMap[ra][ca]

				--printx( 1 , "GameInitDiffChangeLogic  aroundItem 333" , ra , ca)

				if v.ct == 1 then
					aroundItem._encrypt.ItemColorType = color1
				else
					aroundItem._encrypt.ItemColorType = color2
				end
				
				aroundItem.isLockColorOnInit = true
			end
		end
	end
end

function GameInitDiffChangeLogic:tryChangeBoardByVirtualSeed(datas)

	--printx( 1 ,"GameInitDiffChangeLogic:tryChangeBoardByVirtualSeed !!!")

	local mode = self.mode
	local lockMode = false --是否锁定到某一级mode，即不会自动降级
	local onlyCheck = false --只检测并返回结果，并不真正干预

	local itemMap = nil
	local boardMap = nil

	local usedLogMap = nil

	if datas then
		if datas.mode then
			mode = datas.mode
		end

		if datas.lockMode then
			lockMode = datas.lockMode
		end

		if datas.onlyCheck then
			onlyCheck = datas.onlyCheck
		end

		if datas.itemMap then
			itemMap = datas.itemMap
		end

		if datas.boardMap then
			boardMap = datas.boardMap
		end

		if datas.usedLogMap then
			usedLogMap = datas.usedLogMap
		end
	end

	if not mode or mode < 1 or mode > modeCount then 
		--RemoteDebug:uploadLog( "tryChangeBoardByVirtualSeed return 1  mode = nil" , mode  )
		return 
	end

	--RemoteDebug:uploadLog( "tryChangeBoardByVirtualSeed mode" , mode  )

	local levelId = 0 
	if self.mainLogic then
		levelId = self.mainLogic.level
	end

	local usedLog = LevelDifficultyAdjustManager:getVirtualSeedUsedLog(levelId)
	if usedLog and #usedLog > 0 then
		usedLogMap = {}
		for i = 1 , #usedLog do
			usedLogMap[ usedLog[i] ] = true
		end
	end

	--printx( 1 , "=====================================================================================================")
	--printx( 1 , "=====================================================================================================")
	--printx( 1 , "=====================================================================================================")
	--printx( 1 , "=======================GameInitDiffChangeLogic:tryChangeBoardByVirtualSeed===========================")
	--printx( 1 , "=====================================================================================================")
	--printx( 1 , "=====================================================================================================")
	--printx( 1 , "=====================================================================================================")



	if not itemMap then
		itemMap = self.mainLogic.gameItemMap
	end

	if not boardMap then
		boardMap = self.mainLogic.boardmap
	end

	local canRandomColorfulList = {}
	local canRandomColorfulMap = {}

	local itemAroundMap = {}

	for r = 1, #itemMap do 
		for c = 1, #itemMap[r] do

			local item = itemMap[r][c]

			if item then
				if item:canBeCoverByMatch() 
					and item._encrypt.ItemColorType == AnimalTypeConfig.kRandom 
					and item.ItemSpecialType ~= AnimalTypeConfig.kColor
					then
					table.insert(canRandomColorfulList , item)
					canRandomColorfulMap[tostring(item.y) .. "_" .. tostring(item.x)] = item
				end
			end
		end
	end

	--printx( 1 , "#canRandomColorfulList " , #canRandomColorfulList )
	if #canRandomColorfulList > 0 then

		for ia = 1 , #canRandomColorfulList do

			local item = canRandomColorfulList[ia] --交换对象A

			if item and item:canBeSwap() then
				local posKey = tostring(item.y) .. "_" .. tostring(item.x)

				--[[
				if not itemAroundMap[posKey] then
					itemAroundMap[posKey] = {}
				end
				]]

				local mapTable = {}
				mapTable.r = item.y
				mapTable.c = item.x
				mapTable.posKey = posKey
				mapTable.aroundMap = {}

				table.insert( itemAroundMap , mapTable )

				--local mapTable = itemAroundMap[posKey]

				local function buildMapTable(rf , cf)

					local aroundPosKey = tostring(mapTable.r + rf - 4) .. "_" .. tostring(mapTable.c + cf - 4)

					if canRandomColorfulMap[aroundPosKey] then
						mapTable.aroundMap[ tostring(rf) .. "_" .. tostring(cf) ] = true
					end
				end

				for ib = 1 , 7 do
					for ic = 1 , 7 do
						if (ib ~= 4 or ic ~= 4) and math.abs(ib - 4) + math.abs(ic - 4) <= 3 then --曼哈顿距离小于等于3，菱形
							buildMapTable( ib , ic )
						end
					end
				end
			end
		end

	end

	if not onlyCheck then --检测模式无需随机，因为它将遍历所有组合，不会中途跳出
		----[[
		local randomItemAroundMapIndex = {}
		local randomItemAroundMap = {}

		for i = 1 , #itemAroundMap do
			table.insert( randomItemAroundMapIndex , i )
		end

		for i = 1 , #itemAroundMap do
			local ridx = self:rand(1 , #randomItemAroundMapIndex)
			--printx(1 , "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR   "  ,randomItemAroundMapIndex[ridx] ,itemAroundMap[randomItemAroundMapIndex[ridx]].r , itemAroundMap[randomItemAroundMapIndex[ridx]].c)
			table.insert( randomItemAroundMap , itemAroundMap[randomItemAroundMapIndex[ridx]] )
			table.remove( randomItemAroundMapIndex , ridx )
		end

		itemAroundMap = randomItemAroundMap
		--]]
	end

	local resultPosList = {}
	local selectMode = mode

	local function tryFind(modeIndex)

		local configList = patternConfig["mode" .. tostring(modeIndex)]

		if not configList then 
			return false
		end

		if not onlyCheck then --检测模式无需随机，因为它将遍历所有组合，不会中途跳出
			----[[
			local randomConfigListIndex = {}
			local randomConfigList = {}

			for i = 1 , #configList do
				table.insert( randomConfigListIndex , i )
			end

			for i = 1 , #configList do
				local ridx = self:rand(1 , #randomConfigListIndex)
				local rconfig = {}
				rconfig.realIndex = randomConfigListIndex[ridx]
				rconfig.datas = configList[rconfig.realIndex]
				table.insert( randomConfigList , rconfig )
				table.remove( randomConfigListIndex , ridx )
			end

			configList = randomConfigList
			--]]
		end

		
		
		for k,v in ipairs(itemAroundMap) do

			--printx( 1 , "GameInitDiffChangeLogic  tryFind  modeIndex" , modeIndex , k)
			--local centerPos = string.split( k , "_")
			local centerR = v.r
			local centerC = v.c
			
			local aroundItemList = v.aroundMap

			for i = 1 , #configList do
				local result = true
				local config = nil
				local realIndex = i

				if onlyCheck then
					config = configList[i]
					realIndex = i
				else
					config = configList[i].datas
					realIndex = configList[i].realIndex
				end
				--printx( 1 , "GameInitDiffChangeLogic  tryFind   index -------" , i)
				for k1,v1 in ipairs(config) do
					

					local poskey = tostring(v1.dr) .. "_" .. tostring(v1.dc) --相对坐标，4,4点为起点
					--printx( 1 , "GameInitDiffChangeLogic  tryFind aroud  poskey:" , poskey)

					if not aroundItemList[poskey] then
						--printx( 1 , "tryFind  break 1")
						result = false
						break
					end

					if v1.itemB then --是否为交换对象B
						

						--local pos = string.split( k1 , "_")
						local r = centerR + v1.dr - 4
						local c = centerC + v1.dc - 4

						--printx( 1 , "GameInitDiffChangeLogic  tryFind 交换对象B ---------  " , r , c)

						if itemMap[r] and itemMap[r][c] and itemMap[centerR] and itemMap[centerR][centerC] then
							--local itemA = itemMap[centerR][centerC]
							local itemB = itemMap[r][c]

							if itemB:canBeSwap() then

								local boardA = boardMap[centerR][centerC]
								local boardB = boardMap[r][c]

								if centerR > r and centerC == c then
									if boardA:hasTopRope() or boardB:hasBottomRope() then
										--printx( 1 , "tryFind  break 2")
										result = false
										break
									end
								elseif centerR < r and centerC == c then
									if boardA:hasBottomRope() or boardB:hasTopRope() then
										--printx( 1 , "tryFind  break 3")
										result = false
										break
									end
								elseif centerR == r and centerC > c then
									if boardA:hasLeftRope() or boardB:hasRightRope() then
										--printx( 1 , "tryFind  break 4")
										result = false
										break
									end
								elseif centerR == r and centerC < c then
									if boardA:hasRightRope() or boardB:hasLeftRope() then
										--printx( 1 , "tryFind  break 5")
										result = false
										break
									end
								else
									--printx( 1 , "tryFind  break 6")
									if onlyCheck then
										CommonTip:showTip( "GameInitDiffChangeLogicPatternConfig ERROR !!!" , "negative", nil, 300)
									end
									assert(false, "GameInitDiffChangeLogic  patternConfig config Error ! modeIndex:" .. tostring(modeIndex) .. " " .. tostring(i) )
									result = false
									break
								end
							else
								--printx( 1 , "tryFind  break 7")
								result = false
								break
							end
						else
							--printx( 1 , "tryFind  break 8")
							result = false
							break
						end
					end
				end

				if result then
					--printx( 1 , "GameInitDiffChangeLogic:tryChangeBoardByVirtualSeed result :" , k , "mode" .. tostring(modeIndex) .. "_" .. tostring(i) )
					table.insert( resultPosList , { centerR = centerR , centerC = centerC , oringinTypeIndex = mode , typeIndex = modeIndex , patternIndex = realIndex })

					if not onlyCheck then
						-- 非检测模式无需找到所有pattern，找到任意一个就返回
						-- 检测模式则遍历所有可能的结果，并统计
						return 
					end
				end
			end
		end
	end

	tryFind(selectMode)
	--usedLogMap

	if not lockMode then

		for i = 1 , modeCount do

			if #resultPosList > 0 then
				break
			end

			selectMode = selectMode - 1

			if selectMode < 1 then
				printx( 1 , "GameInitDiffChangeLogic  mode" .. tostring(selectMode + 1) .. " PASS !")
				break
			end

			printx( 1 , "GameInitDiffChangeLogic  mode" .. tostring(selectMode + 1) .. " PASS !")

			if not usedLogMap or not usedLogMap[selectMode] then
				tryFind(selectMode)
			end
		end

		if #resultPosList == 0 then
			selectMode = mode

			for i = 1 , modeCount do

				if #resultPosList > 0 then
					break
				end

				selectMode = selectMode + 1

				if selectMode > modeCount then
					printx( 1 , "GameInitDiffChangeLogic  mode" .. tostring(selectMode - 1) .. " PASS !")
					break
				end

				printx( 1 , "GameInitDiffChangeLogic  mode" .. tostring(selectMode - 1) .. " PASS !")

				if not usedLogMap or not usedLogMap[selectMode] then
					tryFind(selectMode)
				end
			end
		end
	end

	local resultData = nil

	if not onlyCheck then

		if #resultPosList > 0 then

			resultData = resultPosList[ self:rand(1 , #resultPosList) ]

			if resultData then
				self:doChangeBoardByVirtualSeed(resultData)
				--RemoteDebug:uploadLog( "tryChangeBoardByVirtualSeed select " , mode , resultData.typeIndex , resultData.patternIndex , resultData.centerR , resultData.centerC  )
				DcUtil:VirtualSeedEnabled( levelId , mode , resultData.typeIndex , resultData.patternIndex , resultData.centerR , resultData.centerC )

				if resultData.oringinTypeIndex ~= resultData.typeIndex then
					LevelDifficultyAdjustManager:addVirtualSeedUsedLog( levelId , resultData.oringinTypeIndex )
				end
				LevelDifficultyAdjustManager:addVirtualSeedUsedLog( levelId , resultData.typeIndex )
			else
				--RemoteDebug:uploadLog( "tryChangeBoardByVirtualSeed select failed " , mode , 0  )
				DcUtil:VirtualSeedEnabled( levelId , mode , 0 , 0 , 0 , 0 )
				LevelDifficultyAdjustManager:addVirtualSeedUsedLog(levelId , mode)
			end
		else
			--RemoteDebug:uploadLog( "tryChangeBoardByVirtualSeed select faild"  , mode , 0 )
			DcUtil:VirtualSeedEnabled( levelId , mode , 0 , 0 , 0 , 0 )
			LevelDifficultyAdjustManager:addVirtualSeedUsedLog(levelId , mode)
		end
	end
	
	return #resultPosList > 0 , resultData ,  resultPosList
end

function GameInitDiffChangeLogic:checkEnableAdjust(levelId)

	local uid = getCurrUid()

	if not LevelType:isMainLevel( levelId ) then --不是主线关
		--RemoteDebug:uploadLog( "GameInitDiffChangeLogic break 5"  )
		DcUtil:VirtualSeedEnabled( levelId , nil , nil , nil , nil , nil , 5)
		return nil
	end

	local maxLevelId = MetaManager.getInstance():getMaxNormalLevelByLevelArea()
	local topLevel = UserManager:getInstance():getUserRef():getTopLevelId()

	if levelId > maxLevelId - 300 then
		--RemoteDebug:uploadLog( "GameInitDiffChangeLogic break 6" , levelId , maxLevelId , topLevel  )
		DcUtil:VirtualSeedEnabled( levelId , nil , nil , nil , nil , nil , 6)
		return nil
	end

	if levelId < topLevel then
		--RemoteDebug:uploadLog( "GameInitDiffChangeLogic break 7"  )
		DcUtil:VirtualSeedEnabled( levelId , nil , nil , nil , nil , nil , 7)
		return nil
	end

	local levelScore = UserManager:getInstance():getUserScore(levelId)
	if levelScore and levelScore.star and levelScore.star > 0 then
		--RemoteDebug:uploadLog( "GameInitDiffChangeLogic break 8"  )
		DcUtil:VirtualSeedEnabled( levelId , nil , nil , nil , nil , nil , 8)
		return nil
	end

	local userTestGroup = 0

	if MaintenanceManager:getInstance():isEnabledInGroup("VirtualSeed" , "G1" , uid) then
		userTestGroup = 1
	elseif MaintenanceManager:getInstance():isEnabledInGroup("VirtualSeed" , "G2" , uid) then
		userTestGroup = 2
	elseif MaintenanceManager:getInstance():isEnabledInGroup("VirtualSeed" , "G3" , uid) then
		userTestGroup = 3
	elseif MaintenanceManager:getInstance():isEnabledInGroup("VirtualSeed" , "G4" , uid) then
		userTestGroup = 4
	elseif MaintenanceManager:getInstance():isEnabledInGroup("VirtualSeed" , "G5" , uid) then
		userTestGroup = 5
	elseif MaintenanceManager:getInstance():isEnabledInGroup("VirtualSeed" , "G0" , uid) then
		userTestGroup = 0
	end

	local failCounts = UserTagManager:getTopLevelLogicalFailCounts() or 1
	failCounts = failCounts - 1

	local canEnableByFailCounts = false


	if userTestGroup == 0 or userTestGroup == 2 or userTestGroup == 3 then
		--RemoteDebug:uploadLog( "GameInitDiffChangeLogic break 1  userTestGroup" , userTestGroup  )
		DcUtil:VirtualSeedEnabled( levelId , nil , nil , nil , nil , nil , 1)
		return nil
	elseif userTestGroup == 1 then
		if failCounts % 4 == 3 then
			canEnableByFailCounts = true
		end
	elseif userTestGroup == 4 then

		local tag1 = false
		local tag2 = false
		
		local activationTag = UserTagManager:getUserTag( UserTagNameKeyFullMap.kActivation )
		if activationTag == UserTagValueMap[UserTagNameKeyFullMap.kActivation].kNormalActive 
			or activationTag == UserTagValueMap[UserTagNameKeyFullMap.kActivation].kHighlyActive then
			tag1 = true
		end

		local diffTag = UserTagManager:getUserTag( UserTagNameKeyFullMap.kTopLevelDiff )
		if not (diffTag == UserTagValueMap[UserTagNameKeyFullMap.kTopLevelDiff].kHighDiff4)
			and not (diffTag == UserTagValueMap[UserTagNameKeyFullMap.kTopLevelDiff].kNone) then
			tag2 = true
		end


		if tag1 and tag2 then
			if levelId >= 1 and levelId <= 200 then
				if failCounts % 2 == 1 then
					canEnableByFailCounts = true
				end
			elseif levelId > 200 and levelId <= 800 then
				if failCounts % 3 == 2 then
					canEnableByFailCounts = true
				end
			elseif levelId > 800 and levelId <= 1500 then
				if failCounts % 4 == 3 then
					canEnableByFailCounts = true
				end
			else
				DcUtil:VirtualSeedEnabled( levelId , nil , nil , nil , nil , nil , 10)
				return 
			end
		else
			DcUtil:VirtualSeedEnabled( levelId , nil , nil , nil , nil , nil , 9)
			RemoteDebug:uploadLogWithTag( "VirtualSeed" , "Group4 tag1" , tostring(tag1) , "tag2" , tostring(tag2) , "tag3" , tostring(tag3) )
			return 
		end

	elseif userTestGroup == 5 then

		local tag1 = false
		local tag2 = false
		local tag3 = false
		
		local activationTag = UserTagManager:getUserTag( UserTagNameKeyFullMap.kActivation )
		if activationTag == UserTagValueMap[UserTagNameKeyFullMap.kActivation].kNormalActive 
			or activationTag == UserTagValueMap[UserTagNameKeyFullMap.kActivation].kHighlyActive then
			tag1 = true
		end

		local diffTag = UserTagManager:getUserTag( UserTagNameKeyFullMap.kTopLevelDiff )
		if not (diffTag == UserTagValueMap[UserTagNameKeyFullMap.kTopLevelDiff].kHighDiff4)
			and not (diffTag == UserTagValueMap[UserTagNameKeyFullMap.kTopLevelDiff].kNone) then
			tag2 = true
		end

		local payTag = UserTagManager:getUserTag( UserTagNameKeyFullMap.kLastWeekPay )
		if not (payTag == UserTagValueMap[UserTagNameKeyFullMap.kLastWeekPay].kHigh)
			and not (payTag == UserTagValueMap[UserTagNameKeyFullMap.kLastWeekPay].kNone) then
			tag3 = true
		end

		if tag1 and tag2 and tag3 then
			if levelId >= 1 and levelId <= 200 then
				if failCounts % 2 == 1 then
					canEnableByFailCounts = true
				end
			elseif levelId > 200 and levelId <= 800 then
				if failCounts % 3 == 2 then
					canEnableByFailCounts = true
				end
			elseif levelId > 800 and levelId <= 1500 then
				if failCounts % 4 == 3 then
					canEnableByFailCounts = true
				end
			else
				DcUtil:VirtualSeedEnabled( levelId , nil , nil , nil , nil , nil , 10)
				return 
			end
		else
			DcUtil:VirtualSeedEnabled( levelId , nil , nil , nil , nil , nil , 9)
			RemoteDebug:uploadLogWithTag( "VirtualSeed" , "Group5 tag1" , tostring(tag1) , "tag2" , tostring(tag2) , "tag3" , tostring(tag3) )
			return 
		end

	end

	local usedLog = LevelDifficultyAdjustManager:getVirtualSeedUsedLog(levelId)

	if not usedLog then usedLog = {} end

	--printx( 1 , "WTF???????????????????????????????  usedLog " , table.tostring(usedLog))
	--RemoteDebug:uploadLog( "GameInitDiffChangeLogic failCounts = " , failCounts , "failCounts % 4 =" , failCounts % 4 , "#usedLog=" , #usedLog )

	--[[
	setTimeOut( function () 
		CommonTip:showTip( "failCounts:" .. tostring(failCounts) .. " " .. tostring(failCounts % 4) .. " " .. tostring(failCounts % 4 == 3) , "negative" , nil , 20 )
		end , 3 )
	]]

	if canEnableByFailCounts then

		local leftlist = {}
		local usedLogMap = {}

		for i = 1 , modeCount do
			usedLogMap[i] = false
		end

		local strForLog = ""
		for i = 1 , #usedLog do
			strForLog = strForLog .. tostring(usedLog[i]) .. "_"
			usedLogMap[ usedLog[i] ] = true
		end

		for i = 3 , modeCount do 
			if not usedLogMap[i] then
				table.insert( leftlist , i )
			end
		end

		--RemoteDebug:uploadLog( "usedLog =" , strForLog , "#leftlist =" , #leftlist  )

		if #leftlist == 0 then
			--RemoteDebug:uploadLog( "GameInitDiffChangeLogic break 2"  )
			DcUtil:VirtualSeedEnabled( levelId , nil , nil , nil , nil , nil , 2)
			return nil
		end
		--printx( 1 , "WTF???????????????????????????????  leftlist " , table.tostring(leftlist))

		local ranIndex = math.random( 1 , #leftlist )
		local modeIndex = leftlist[ranIndex]

		local d = {
					mode = nil , 
					lockMode = false , 
					onlyCheck = false , 
					itemMap = nil , 
					boardMap = nil ,
					usedLogMap = usedLogMap
				}

		GameInitDiffChangeLogic:changeMode( modeIndex )
		--RemoteDebug:uploadLog( "GameInitDiffChangeLogic:changeMode " , modeIndex  )

	else
		--RemoteDebug:uploadLog( "GameInitDiffChangeLogic break 3 failCounts " , failCounts  )
		DcUtil:VirtualSeedEnabled( levelId , nil , nil , nil , nil , nil , 3)
	end

end


function GameInitDiffChangeLogic:createVirtualSeedDataStr( datas )
	
	local initAdjustStr = nil
	if datas then
		initAdjustStr = datas.oringinTypeIndex .. "_" 
		.. datas.typeIndex .. "_"
		.. datas.patternIndex .. "_"
		.. datas.centerR .. "_"
		.. datas.centerC
	end

	return initAdjustStr
end