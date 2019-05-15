---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-07-11 10:54:11
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2016-08-05 14:53:56
---------------------------------------------------------------------------------------
OlympicBlockerState = class(BaseStableState)

function OlympicBlockerState:ctor()
	self.nextState = nil
	self.dropSpecialItemNum = 4
	self.explodeNum = 2
end

function OlympicBlockerState:dispose()
	BaseStableState.dispose(self)
end

function OlympicBlockerState:create(context)
	local v = OlympicBlockerState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function OlympicBlockerState:onEnter()
	BaseStableState.onEnter(self)
	self.nextState = nil
	self.actionCount = 0

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kOlympicBlocker]]) then
        printx(0, '!skip')
        self:onActionComplete()
        return self.actionCount
    end


	self:tryExplodeOlympicBlocker()

	if self.actionCount > 0 then
		self.mainLogic:setNeedCheckFalling()
	else
		self:onActionComplete()
	end
	return self.actionCount
end

function OlympicBlockerState:tryExplodeOlympicBlocker()

	local blockerCount = 0
	for r = 1, #self.mainLogic.gameItemMap do
		for c = 1, #self.mainLogic.gameItemMap[r] do
			local item = self.mainLogic.gameItemMap[r][c]

			if item.ItemType == GameItemType.kOlympicBlocker and item.olympicBlockerLevel == 0 then
				blockerCount = blockerCount + 1
			end
		end
	end

	if blockerCount == 0 then
		return
	end


	local waittingExplodeList = {} 
	local targetItemList = {}

	local allLevelList = {}
	for i = 1 , 5 do
		local list = {}
		list.minCol = 9
		list.arr = {}
		table.insert( allLevelList , list )
	end

	local function isAvailableGridByTargetLevelIndex(index , item , board)
		
		if index == 1 then
			if board.iceLevel > 0 then
				return true
			end
		elseif index == 2 then
			if item and (
							item.olympicLockLevel > 0 or
							item.cageLevel > 0 or
							item:hasAnyFurball() or
							item.ItemType == GameItemType.kCoin or
							item.ItemType == GameItemType.Blocker207 or
							item.ItemType == GameItemType.kVenom
						) then
				return true
			end
		elseif index == 3 then
			if item and (
							item.ItemType == GameItemType.kCrystal or
							item.ItemType == GameItemType.kRoost or
							item.ItemType == GameItemType.kMimosa or
							item.ItemType == GameItemType.kKindMimosa
							) then
				return true
			end
		elseif index == 4 then
			if item and item.ItemType == GameItemType.kAnimal and item.ItemSpecialType == 0 then
				return true
			end
		elseif index == 5 then
			if item and item.ItemType == GameItemType.kAnimal and item.ItemSpecialType ~= 0 then
				return true
			end
		end

		return false
	end

	for r = 1, #self.mainLogic.gameItemMap do
		for c = 1, #self.mainLogic.gameItemMap[r] do
			local item = self.mainLogic.gameItemMap[r][c]
			local board = self.mainLogic.boardmap[r][c]

			if item.ItemType == GameItemType.kOlympicBlocker and item.olympicBlockerLevel == 0 then
				item.olympicBlockerLevel = -1
				table.insert(waittingExplodeList, {r=r,c=c})
			else
				for i = 1 , #allLevelList do
					if isAvailableGridByTargetLevelIndex( i , item , board ) then
						table.insert( allLevelList[i].arr , {r=r,c=c} )
						if c < allLevelList[i].minCol then
							allLevelList[i].minCol = c
						end
					end
				end
			end
		end
	end

	local passedPosMap = {}

	local function conutAround(Row , Col , list)
		local conut = 0
		local colNum = 0
		local passNum = 0
		--printx( 1 , "   conutAround  " , Row , Col , list)

		for k,v in ipairs(list) do

			if v.r >= Row and v.r <= Row + 2 and v.c >= Col and v.c <= Col + 2 then

				if passedPosMap[tostring(v.r) .. "_" .. tostring(v.c)] then
					passNum = passNum + 1
				else
					conut = conut + 1

					if v.c == Col then
						--printx( 1 , "   conutAround  colNum ++  " , v.r , v.c , Col)
						colNum = colNum + 1
					end
				end
			end 
		end

		if colNum > 0 then
			return conut , passNum
		else
			return 0 , passNum
		end
	end

	local function __getTargetPoint(index , tarRow , tarCol , listDataArr)
		--printx( 1 , "   __getTargetPoint   index=",index , " row=" , tarRow , " col=" , tarCol )
		local maxAroundNum = 0
		local bestRow = 3
		local bestPosArr = {}

		local result = nil

		if not tarRow then
			tarRow = {2,3,4,5,6,7}
		end
		for k , row in ipairs(tarRow) do

			local col = tarCol
			local aroundNum , passedNum = conutAround(row , col , listDataArr)

			if aroundNum > 0 then
				if maxAroundNum < aroundNum then
					maxAroundNum = aroundNum
					bestRow = row
					bestPosArr = {}
					table.insert( bestPosArr , {r=row,c=col , passed=passedNum} )
				elseif maxAroundNum == aroundNum then
					table.insert( bestPosArr , {r=row,c=col , passed=passedNum} )
				end
			end
		end 

		--printx( 1 , "   bestPosArr = " , table.tostring(bestPosArr))
		return bestPosArr
	end

	local function getMinCol(arr)
		local minCol = 9
		for k,v in ipairs(arr) do
			if minCol > v.c and not passedPosMap[tostring(v.r) .. "_" .. tostring(v.c)] then
				minCol = v.c
			end
		end

		return minCol
	end
	
	----[[
	local function getTargetPoint()
		for i = 1 , 5 do
			local list = allLevelList[i]

			local arrLength = 0
			for k,v in ipairs(list.arr) do
				if not passedPosMap[tostring(v.r) .. "_" .. tostring(v.c)] then
					arrLength = arrLength + 1
				end
			end

			if arrLength > 0 then
				
				local tarRow = {2,3,4,5,6,7}
				--local tarCol = list.minCol
				local tarCol = getMinCol(list.arr)
				
				--if tarCol > 7 then tarCol = 7 end
				printx( 1 , "    getTargetPoint  minCol = " , tarCol , "  index = ",i)
				local resultArr = __getTargetPoint(i , tarRow , tarCol , list.arr)

				if #resultArr > 1 then 
					local datamap = {}
					for k,v in ipairs(resultArr) do
						if not datamap[v.passed] then
							datamap[v.passed] = {}
						end

						table.insert( datamap[v.passed] , v )
					end

					local min = 999
					local minV = nil
					for k,v in pairs(datamap) do
						if k < min then
							min = k
							minV = v
						end
					end

					resultArr = minV
				end

				if #resultArr == 1 then
					printx( 1 , "   只找到一个结果" , resultArr[1].r , resultArr[1].c)
					return resultArr[1]
				elseif #resultArr > 1 then
					printx( 1 , "   找到多个结果")
					tarRow = {}
					for k,v in ipairs(resultArr) do
						table.insert( tarRow , v.r )
					end
					
					if i ~= 5 then

						local nextArr = nil

						for j = i + 1 , 5 do
							local nextIndex = j

							local nextList = allLevelList[nextIndex]
							local arr = __getTargetPoint(nextIndex , tarRow , tarCol , nextList.arr)

							if #arr == 1 then
								nextArr = arr
								break
							elseif #arr > 1 then
								tarRow = {}
								for k,v in ipairs(arr) do
									table.insert( tarRow , v.r )
								end
								nextArr = arr
							else
								--do nothing
							end
						end

						if nextArr then
							return nextArr[1]
						else
							return resultArr[1]
						end

					else
						return resultArr[1]
					end
				else
					printx( 1 , "   没有结果")
					return nil
				end
			end
		end
	end
	--]]

	
	local function onActionComplete() 
		self.actionCount = self.actionCount - 1
		if self.actionCount <= 0 then
			self.context.needLoopCheck = true
			self:onActionComplete()
		end
	end

	for _, pos in ipairs(waittingExplodeList) do
		self.actionCount = self.actionCount + 1

		local targetPosList = {}
		for i = #targetPosList+1, self.explodeNum do

			local targetPoint = getTargetPoint()
			
			if targetPoint then
				if targetPoint.c > 7 then targetPoint.c = 7 end
				for j = 1 , 3 do
					for k = 1 , 3 do
						local tr = targetPoint.r + (j-1)
						local tc = targetPoint.c + (k-1)
						passedPosMap[tostring(tr) .. "_" .. tostring(tc)] = true
					end
				end
				table.insert(targetPosList, targetPoint)
			end
		end

		if #targetPosList > 0 then

		end

		--printx( 1 , "   OlympicBlockerState:tryExplodeOlympicBlocker  num = " , #targetPosList , "   at  " , pos.r, pos.c )
		local theAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItemMatchAt_OlympicBlockExplode,
			IntCoord:create(pos.r, pos.c),
			nil,
			GamePlayConfig_MaxAction_time)
		theAction.completeCallback = onActionComplete
		theAction.specialTargetPosList = targetPosList
		--theAction.addInt = 3 -- 加3步
		self.mainLogic:addDestructionPlanAction(theAction)
	end

end

function OlympicBlockerState:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil
end

function OlympicBlockerState:getClassName( ... )
	return "OlympicBlockerState"
end

function OlympicBlockerState:checkTransition()
	return self.nextState
end

function OlympicBlockerState:getNextState()
	return nil-- self.context.MoleWeeklyBossStateInLoop
end

function OlympicBlockerState:onActionComplete()
	self.nextState = self:getNextState()
end