require "zoo.data.MetaManager"
require "zoo.net.UserLocalLogic"

AnimalStageInfo = class()
function AnimalStageInfo:ctor( uid, levelId )
	self.uid = uid
	self.levelId = levelId
	self.oldTotalStar = 0
	self.propIds = {}
	self.buyMove = 0
	self.dropProps = {}
	self.usePropLog = {}
	self.propsUsedInLevel = {}
	self.stageState = -1 --0（首次闯当前关）1（非首次闯当前关&未过关，包含跳关回来刷关的）2（已过关重刷）
	self.propLogForDc = {}
	self.stepProgressDataList = {}
	self.addFiveLogForDc = {}
	self.specialAnimalNum = {}
	self.targetsData = {}
	self.preProps = {}
	self.paymentOrderIds = {} 
end
function AnimalStageInfo:isEmpty()
	if not self.propIds then return true end
	if #self.propIds > 0 then return false end
	return true
end
function AnimalStageInfo:addProp( itemID )
	table.insert(self.propIds, itemID)
end

function AnimalStageInfo:addUsePropLog( itemID )
	table.insert(self.usePropLog, itemID)
end

function AnimalStageInfo:addPreProp(propId, expireTime)
	table.insert(self.preProps, {propId = propId, expireTime = expireTime})
end

function AnimalStageInfo:revertUsedProp(propId)
	if propId then
		-- if self.propsUsedInLevel[propId] and self.propsUsedInLevel[propId] > 0 then
		-- 	self.propsUsedInLevel[propId] = self.propsUsedInLevel[propId] - 1
		-- end
	end
end

function AnimalStageInfo:addStepProgressData()
	local boardLogic = GameBoardLogic:getCurrentLogic()
	if boardLogic then

		if self.stepProgressDataList and #self.stepProgressDataList > 0 then
			local lastData = self.stepProgressDataList[#self.stepProgressDataList]
			if lastData.idx == boardLogic.realCostMove then
				table.remove( self.stepProgressDataList )
			end
		end

		local result , fuuuLogID , progressData = FUUUManager:lastGameIsFUUU(false , false)

		if progressData then
			--printx( 1 , "AnimalStageInfo:addPropsUsedInLevel  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! propId" , propId )
			--printx( 1 , table.tostring(progressData) )

			local dcStr = ""
			local function getTarStr( targetId , k2 , cv , tv )
				local leftv = tv - cv
				if leftv < 0 then leftv = 0 end
				return tostring(targetId * 100 + k2) .. "_" .. tostring(leftv) .. "_" .. tostring( cv ) .. "_" .. tostring(tv)
			end

			for k,v in ipairs(progressData) do
				if v.orderTargetId then
					if v.cld then
						--printx(1 , "FUCK          v  = " , table.tostring(v))
						for k2,v2 in ipairs(v.cld) do
							local str = getTarStr( v.orderTargetId , v2.k2 or 0 , v2.cv or 0 , v2.tv or 0 )
							if dcStr == "" then
								dcStr = str
							else
								dcStr = dcStr .. "_" .. str
							end
						end
					else
						local str = getTarStr( v.orderTargetId , 0 , v.cv or 0 , v.tv or 0 )
						if dcStr == "" then
							dcStr = str
						else
							dcStr = dcStr .. "_" .. str
						end
					end
				end
				
			end
			--printx(  )
			local stepProgress = {}
			stepProgress.idx = boardLogic.realCostMove
			stepProgress.theCurMoves = boardLogic.theCurMoves
			stepProgress.progressStr = dcStr
			stepProgress.cv = progressData.cv
			stepProgress.tv = progressData.tv

			table.insert( self.stepProgressDataList , stepProgress )
		end
	end
end

function AnimalStageInfo:addPropsUsedInLevel( propId )
	if propId then
		if not self.propsUsedInLevel[propId] then
			self.propsUsedInLevel[propId] = 0
		end
		self.propsUsedInLevel[propId] = self.propsUsedInLevel[propId] + 1
		
		local boardLogic = GameBoardLogic:getCurrentLogic()
		if boardLogic then

			local propUseData = {}
			propUseData.idx = boardLogic.realCostMove
			propUseData.propId = propId
			propUseData.theCurMoves = boardLogic.theCurMoves

			table.insert( self.propLogForDc , propUseData )
		end
	end
end

function AnimalStageInfo:addFiveUseInLevel(isBuyAndUse)
	local num = #self.addFiveLogForDc + 1
	table.insert(self.addFiveLogForDc, string.format("%s_%s", num, isBuyAndUse and 1 or 0))
end

function AnimalStageInfo:getPropLogForDc()
	return self.propLogForDc
end

function AnimalStageInfo:getAddFiveLogForDc()
	return self.addFiveLogForDc
end

function AnimalStageInfo:removeProp( itemID )
	table.removeValue(self.propIds, itemID)
end
function AnimalStageInfo:incrBuyMove( buyMove )
	self.buyMove = self.buyMove + buyMove
end

function AnimalStageInfo:addSpecialAnimal(spType, addNum)
	if not spType then return end
	addNum = addNum or 1
	local num = self.specialAnimalNum[spType] or 0
	self.specialAnimalNum[spType] = num + addNum
end

function AnimalStageInfo:getSpecialAnimalNum(spType)
	if not spType then return 0 end
	return self.specialAnimalNum[spType] or 0
end

function AnimalStageInfo:initTargets(targets)
	self.targetsData = {}
	if targets then
		for i, v in ipairs(targets) do
			if v.num and v.num > 0 then
				table.insert(self.targetsData, {tType=v.type, tId = v.id, tNum = v.num})
			end
		end
	end
end

function AnimalStageInfo:addPaymentOrderId(orderId)
	table.insert(self.paymentOrderIds, orderId)
end

local stageInfoMap = {}

StageInfoLocalLogic = class()

function StageInfoLocalLogic:getStageInfoKey( uid )
	return tostring(uid)
end
function StageInfoLocalLogic:getStageInfo( uid )
	local key = StageInfoLocalLogic:getStageInfoKey( uid )
	return stageInfoMap[key]
end
function StageInfoLocalLogic:initStageInfo(uid, levelId, propIds)
	-- printx( 1 , "StageInfoLocalLogic:clearStageInfo  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" , debug.traceback())
	local stageInfo = AnimalStageInfo.new(uid, levelId)
	local key = StageInfoLocalLogic:getStageInfoKey( uid )
	stageInfo.propIds = propIds
	stageInfo.totalStar = UserManager:getInstance():getUserRef():getTotalStar()
	stageInfoMap[key] = stageInfo
	--todo: save stage info to local file.
end

function StageInfoLocalLogic:clearStageInfo( uid )
	-- printx( 1 , "StageInfoLocalLogic:clearStageInfo  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" , debug.traceback())
	local key = StageInfoLocalLogic:getStageInfoKey( uid )
	local result = stageInfoMap[key]
	--?should we remove data?
	stageInfoMap[key] = nil
	return result
end

function StageInfoLocalLogic:addTempProps( uid, propId )
	local stageInfo = StageInfoLocalLogic:getStageInfo( uid )
	if stageInfo then stageInfo:addProp(propId) end
end

function StageInfoLocalLogic:subTempProps( uid, propIds )
	local stageInfo = StageInfoLocalLogic:getStageInfo( uid )
	if stageInfo and not stageInfo:isEmpty() then
		for i,item in ipairs(propIds) do
			stageInfo:removeProp(item)
		end
	end
end

function StageInfoLocalLogic:revertUsedProp(uid, propId)
	local stageInfo = StageInfoLocalLogic:getStageInfo( uid )
	if stageInfo then
		stageInfo:revertUsedProp(propId)
	end
end

function StageInfoLocalLogic:addPreProp(uid, propId, expireTime)
	local stageInfo = StageInfoLocalLogic:getStageInfo( uid )
	if stageInfo then
		stageInfo:addPreProp(propId, expireTime)
	end
end

function StageInfoLocalLogic:addPropsUsedInLevel(uid, propId, isBuyAddFive)
	local stageInfo = StageInfoLocalLogic:getStageInfo( uid )
	if stageInfo then
		stageInfo:addPropsUsedInLevel(propId)
		
		if propId == ItemType.ADD_FIVE_STEP or 
			propId == ItemType.ADD_BOMB_FIVE_STEP then
			stageInfo:addFiveUseInLevel(isBuyAddFive)
		end
	end
end

function StageInfoLocalLogic:removeLastPropsUsedData(uid, propId)
	local stageInfo = StageInfoLocalLogic:getStageInfo( uid )
	if stageInfo then
		--stageInfo:addPropsUsedInLevel(propId)
		table.remove( stageInfo.propLogForDc )
		if propId == ItemType.ADD_FIVE_STEP or 
			propId == ItemType.ADD_BOMB_FIVE_STEP then
			--stageInfo:addFiveUseInLevel(isBuyAddFive)
			table.remove( stageInfo.addFiveLogForDc )
			--self.propLogForDc
		end
	end
end

function StageInfoLocalLogic:addStepProgressData(uid)
	local stageInfo = StageInfoLocalLogic:getStageInfo( uid )
	if stageInfo then
		stageInfo:addStepProgressData()
	end
end

function StageInfoLocalLogic:addBuyMove( uid, val )
	local stageInfo = StageInfoLocalLogic:getStageInfo( uid )
	if stageInfo then 
		stageInfo:incrBuyMove(val) 
		stageInfo:addUsePropLog(val)
	end
	return true
end

function StageInfoLocalLogic:openGiftBlocker( uid, levelId, propIds )
	local stageInfo = StageInfoLocalLogic:getStageInfo( uid )
	if stageInfo then
		for i,v in ipairs(propIds) do stageInfo:addProp(v) end
	end
end

function StageInfoLocalLogic:getPropsInGame(uid, levelId, itemIds)
	local stageInfo = StageInfoLocalLogic:getStageInfo( uid )
	if stageInfo and itemIds then
		for _, v in pairs(itemIds) do
			local originNum = stageInfo.dropProps[v] or 0
			stageInfo.dropProps[v] = originNum + 1
		end
		return true
	end
	return false
end

function StageInfoLocalLogic:getTotalDropPropCount(uid)
	local stageInfo = StageInfoLocalLogic:getStageInfo( uid )
	local total = 0
	if stageInfo then
		for _, v in pairs(stageInfo.dropProps) do
			total = total + v
		end
	end
	return total
end

function StageInfoLocalLogic:hasUsePropInLevel(uid)
	local stageInfo = StageInfoLocalLogic:getStageInfo( uid )
	local useProp = false
	if stageInfo and stageInfo.usePropLog and #stageInfo.usePropLog > 0 then 
		
		for k,v in ipairs(stageInfo.usePropLog) do
			if not PropsModel.kTempPropMapping[tostring(v)] then
				useProp = true 
				break
			end
		end
	end
	return useProp
end

function StageInfoLocalLogic:getPropInLevelUseState(uid)
	local usePre = false		--使用前置道具
	local useTemp = false 		--使用临时道具（当前关卡内获得的）
	local useBag = false 		--使用背包内的
	local stageInfo = StageInfoLocalLogic:getStageInfo(uid)
	local useProp = false
	if stageInfo and stageInfo.usePropLog and #stageInfo.usePropLog > 0 then 
		for k,v in ipairs(stageInfo.usePropLog) do
			if PropsModel.kTempPropMapping[tostring(v)] then
				useTemp = true
			else
				if v > 1000000 then 
					usePre = true
				else
					useBag = true
				end
			end
		end
	end

	return usePre, useTemp, useBag 
end

function StageInfoLocalLogic:setStageState(uid , state , levelId)
	-- printx( 1 , "   StageInfoLocalLogic:setStageState  ~~~~~~~~~~~~~~~~~^^^^|||||||||~~~~~~~~~~~~~~~  " , uid , state , debug.traceback())
	local stageInfo = StageInfoLocalLogic:getStageInfo( uid )
	-- printx( 1 , "   stageInfo = " , stageInfo , "levelId" , levelId)
	if stageInfo then

		if not levelId or levelId <= 0 then
			stageInfo.stageState = -1
			if math.random( 1 , 1000 ) <= 10 then
				-- he_log_error( "StageInfoLocalLogic:setStageState ERROR!!! levelId:" .. tostring(levelId) .. "  state:" .. tostring(state) )
			end
		elseif LevelType:isMainLevel( levelId ) then
			stageInfo.stageState = state
		elseif LevelType:isHideLevel( levelId ) then
			stageInfo.stageState = 3
		else
			stageInfo.stageState = 4
		end
		-- printx( 1 , "   stageInfo.stageState = " , stageInfo.stageState)
	end
end

function StageInfoLocalLogic:getStageState(uid)
	-- printx( 1 , "   StageInfoLocalLogic:getStageState  ~~~~~~~~~~~~~~~~~^^^^|||||||||~~~~~~~~~~~~~~~  " , uid)

	local stageInfo = StageInfoLocalLogic:getStageInfo( uid )
	if stageInfo then
		-- printx( 1 , "   stageInfo.stageState = " , stageInfo.stageState)
		return stageInfo.stageState
	end
	-- printx( 1 , "   stageInfo.stageState = -1" )
	if math.random( 1 , 1000 ) <= 10 then
		-- he_log_error( "StageInfoLocalLogic:getStageState ERROR!!! uid:" .. tostring(uid) )
	end
	return -1
end

function StageInfoLocalLogic:initTargets(uid, targets)
	local stageInfo = StageInfoLocalLogic:getStageInfo( uid )
	if stageInfo then
		stageInfo:initTargets(targets)
	end
end

function StageInfoLocalLogic:addPaymentOrderId(uid, orderId)
	local stageInfo = StageInfoLocalLogic:getStageInfo( uid )
	if stageInfo and orderId then
		stageInfo:addPaymentOrderId(orderId)
	end
end