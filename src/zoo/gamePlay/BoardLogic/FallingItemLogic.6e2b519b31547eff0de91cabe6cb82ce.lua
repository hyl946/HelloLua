-----进行全局的掉落检测----生成新Animal----
require "zoo.gamePlay.BoardAction.GameBoardActionDataSet"

FallingItemLogic = class{}

-----------------------------------------------------------
-- 掉落来源类型,来源按方向分为左上、上、右上三个方向
-- 其中上方向掉落有三种情况,即生成口、传送门出口和普通格子
-- 掉落来源类型标识了三种方向的所有组合的可能性
-- 
-- 1. Up为普通动物
-- 2. ==== 边界为生成口
-- 3. ==== 边界为传送门
--	         ^
--	         |
--	         v
--  |-----|-----|-----|
--  |Left |  Up |Right|
--  |-----|=====|-----|
--  |     | Tar |     |
--  |_____|_____|_____|
-- 
-----------------------------------------------------------
FallingSourceType = table.const
{
	kNone = 0,				--没有来源,地格为block或上/左上/右上方向都无法落入
	kUp = 1,				--仅上方可掉落
	kLeft = 2,				--仅左上方掉落
	kRight = 3,				--仅右上方掉落
	kDouble = 4,			--左上方或右上方可掉落
	kPortal = 5,			--仅传送门出口
	kProduct = 6, 			--仅生成口
	kUpLeft = 7,			--上方或左上方
	kUpRight = 8,			--上方或右上方
	kUpLR = 9,				--上方或左上方或右上方
	kPortalLeft = 10, 		--传送门出口或左上方
	kPortalRight = 11,		--传送门出口或右上方
	kPortalLR = 12,			--传送门出口或左上方或右上方
	kProductPortal = 13,	--生成口或传送门出口
}

local kLockedFC = {}
local kStopFallingColHelper = {}

------提前更新帮助地图--------
function FallingItemLogic:preUpdateHelpMap(mainLogic)

	if UseNewFallingLogic then
		return
	end
	
	mainLogic.FallingColumnList = nil
	mainLogic.FallingColumnList = {}
	self:buildFallingColumns(mainLogic)

	mainLogic.FallingHelpMap = nil
	mainLogic.FallingHelpMap = {}
	for r = 1, #mainLogic.gameItemMap do
		mainLogic.FallingHelpMap[r] = {}
		for c = 1,#mainLogic.gameItemMap[r] do
			mainLogic.FallingHelpMap[r][c] = FallingSourceType.kNone
		end
	end
	if mainLogic.gameItemMap then
		for c = 1, #mainLogic.gameItemMap[1] do 			----由左至右
			for r = #mainLogic.gameItemMap,1, -1 do			----由下至上
				mainLogic.FallingHelpMap[r][c] = FallingItemLogic:getPosFallingSourceType(mainLogic, r, c) ----判断来源
			end
		end
	end
end

function FallingItemLogic:buildFallingColumns(mainLogic)
	local function isAboveSeparated(r, c)
		local board = mainLogic.boardmap[r][c]
		return board:hasTopRope() or board:hasExitPortal() 
	end

	local function isBelowSeparated(r, c)
		local board = mainLogic.boardmap[r][c]
		return board:hasBottomRope() or board:hasEnterPortal() 
	end

	local function isPosStartOfColumn(r, c)
		local board = mainLogic.boardmap[r][c]
		local hasAbove = mainLogic:isPosValid(r - 1, c)
		if board.isUsed and not board.isBlock then
			if hasAbove then
				local boardAbove = mainLogic.boardmap[r - 1][c]
				if not boardAbove.isUsed or boardAbove.isBlock or isAboveSeparated(r, c) or isBelowSeparated(r - 1, c) then
					return true
				end
			else
				return true
			end
		end
		return false
	end

	local function getColumnLength(r, c)
		local result = 0
		for rowIndex = r, #mainLogic.boardmap do 
			if mainLogic:isPosValid(rowIndex, c) then
				local board = mainLogic.boardmap[rowIndex][c]
				if board.isUsed and not board.isBlock then
					if not isAboveSeparated(rowIndex, c) or rowIndex == r then
						result = result + 1
						if isBelowSeparated(rowIndex, c) then
							break
						end
					else
						break
					end
				else
					break
				end
			end
		end
		return result
	end

	for c = 1, #mainLogic.gameItemMap[1] do 
		for r = 1, #mainLogic.gameItemMap do
			if isPosStartOfColumn(r, c) then
				local len = getColumnLength(r, c)
				local fallingColumn = { start = { r = r, c = c }, len = len }
				table.insert(mainLogic.FallingColumnList, fallingColumn)
			end
		end
	end

	mainLogic.FallingColumnPosMap = nil
	mainLogic.FallingColumnPosMap = {}
	for i, fc in ipairs(mainLogic.FallingColumnList) do
		local col = fc.start.c
		local rowStart = fc.start.r
		local rowEnd = fc.start.r + fc.len - 1
		for r = rowStart, rowEnd do
			mainLogic.FallingColumnPosMap[r .. "_" .. col] = fc
		end		
	end	
end

function FallingItemLogic:getFallingColumnByPos(mainLogic, r, c)
	if mainLogic.FallingColumnPosMap then
		local fc = mainLogic.FallingColumnPosMap[r .. "_" .. c]
		if fc then
			return fc
		end
	end
	return nil
end

------提前更新帮助地图-------消除多个Block之后一次运行---
function FallingItemLogic:updateHelpMapByDeleteBlock(mainLogic)
	self:preUpdateHelpMap(mainLogic)
end

function FallingItemLogic:isEnterPortalBlock(mainLogic, exitBoard)
	local enterR = exitBoard.passEnterPoint_x
	local enterC = exitBoard.passEnterPoint_y
	local enterBoard = mainLogic.boardmap[enterR][enterC]
	return enterBoard.isBlock 
		or enterBoard:hasChainInDirection(ChainDirConfig.kDown) 
		or exitBoard:hasChainInDirection(ChainDirConfig.kUp)

		--or enterBoard:hasTopRope() 
		--or enterBoard:hasBottomRope() 
		--or exitBoard:hasTopRope() 
		--or exitBoard:hasBottomRope() 
end

----判断某一个点的来源
function FallingItemLogic:getPosFallingSourceType(mainLogic, r, c)
	local item = mainLogic.gameItemMap[r][c]
	local board = mainLogic.boardmap[r][c]

	if item.isBlock or not item.isUsed then
		return FallingSourceType.kNone
	end
	
	-- producer
	if board.isProducer and FallingItemLogic:isProducerValidInFC(mainLogic, r, c) then
		if board:hasExitPortal() and not self:isEnterPortalBlock(mainLogic, board) then
			return FallingSourceType.kProductPortal
		else
			return FallingSourceType.kProduct
		end
	-- portal exit tile, enter board must not be block
	elseif board:hasExitPortal() and not self:isEnterPortalBlock(mainLogic, board) then 
		local canFallingFromLeft = FallingItemLogic:canFallingFromLeft(mainLogic, r, c)
		local canFallingFromRight = FallingItemLogic:canFallingFromRight(mainLogic, r, c)
		if canFallingFromLeft and canFallingFromRight then
			return FallingSourceType.kPortalLR
		elseif canFallingFromLeft then
			return FallingSourceType.kPortalLeft
		elseif canFallingFromRight then
			return FallingSourceType.kPortalRight
		else
			return FallingSourceType.kPortal
		end
	-- normal item tile
	elseif FallingItemLogic:canFallingFromTop(mainLogic, r, c) then 
		local canFallingFromLeft = FallingItemLogic:canFallingFromLeft(mainLogic, r, c)
		local canFallingFromRight = FallingItemLogic:canFallingFromRight(mainLogic, r, c)
		if canFallingFromLeft and canFallingFromRight then
			return FallingSourceType.kUpLR
		elseif canFallingFromLeft then
			return FallingSourceType.kUpLeft
		elseif canFallingFromRight then
			return FallingSourceType.kUpRight
		else
			return FallingSourceType.kUp
		end
	-- get nothing from top
	else 
		local canFallingFromLeft = FallingItemLogic:canFallingFromLeft(mainLogic, r, c) 
		local canFallingFromRight = FallingItemLogic:canFallingFromRight(mainLogic, r, c)
		if canFallingFromLeft and canFallingFromRight then
			return FallingSourceType.kDouble
		elseif canFallingFromLeft then
			return FallingSourceType.kLeft
		elseif canFallingFromRight then
			return FallingSourceType.kRight
		else
			return FallingSourceType.kNone
		end
	end
end

-- 检测生成口是否生效，失效的生成口视为普通格子，生成口失效的状况有两种
-- 1. 两个生成口在同一个FallingColumn中，则下方的生成口失效
-- 2. 生成口所在的FallingColumn的起始点为传送门出口，并且传送门入口没有堵塞
function FallingItemLogic:isProducerValidInFC(mainLogic, r, c)
	local fc = FallingItemLogic:getFallingColumnByPos(mainLogic, r, c)
	local fcBeginR = fc.start.r
	if fcBeginR < r then
		local fcBeginBoard = mainLogic.boardmap[fcBeginR][c]
		if fcBeginBoard:hasExitPortal() and not self:isEnterPortalBlock(mainLogic, fcBeginBoard) then
			return false
		else
			for i = fcBeginR, r - 1 do
				local tempBoard = mainLogic.boardmap[i][c]
				if tempBoard.isProducer then
					return false
				end
			end
		end
	end
	return true
end

------上方是否可以往下掉落
function FallingItemLogic:canFallingFromTop(mainLogic, r, c)
	local r1 = r - 1
	if not mainLogic:isPosValid(r1, c) then return false end

	local topBoard = mainLogic.boardmap[r1][c]
	local board = mainLogic.boardmap[r][c]
	if topBoard.isUsed and not topBoard.isBlock then  			----上方可用 非Block
		---------1.绳子----------
		if not board:hasTopRope() and not topBoard:hasBottomRope() then  	----上方的下部无绳子、本地上部无绳子
			-------2.通道---------
			if topBoard:hasEnterPortal() then					----上方是通道入口 无法掉落，只能走左右
				return false 
			end
			if board:hasExitPortal() then						----下方是通道出口 无法掉落，只能走通道
				return false
			end

			return true
		end
	end
	return false
end

-------左上方是否可以向下掉落-------
function FallingItemLogic:canFallingFromLeft(mainLogic, r, c)
	local r1 = r-1
	local c1 = c-1
	if not mainLogic:isPosValid(r1, c1) then return false end

	local board = mainLogic.boardmap[r][c]
	local item = mainLogic.gameItemMap[r][c]

	local topLeftBoard = mainLogic.boardmap[r1][c1]
	local topLeftItem = mainLogic.gameItemMap[r1][c1]

	local r2 = r
	local c2 = c - 1

	local leftBoard = mainLogic.boardmap[r2][c2]
	local leftItem = mainLogic.gameItemMap[r2][c2]

	if topLeftItem.isUsed and not topLeftItem.isBlock then 			----非Block
		if not topLeftBoard:hasBottomRope()  				----下方无绳子
			and not leftBoard:hasTopRope()					----上方无绳子
			and not leftBoard:hasRightRope() 	 			----右边无绳子
			and not board:hasLeftRope() 					----左边无绳子
			then
			if not topLeftBoard:hasEnterPortal() and not leftBoard:hasExitPortal() then
				return true
			else
				return false
			end
		end
	end
	return false
end

-------右上方是否可以向下掉落-------
function FallingItemLogic:canFallingFromRight(mainLogic, r, c)
	local r1 = r - 1
	local c1 = c + 1
	if not mainLogic:isPosValid(r1, c1) then return false end

	local topRightBoard = mainLogic.boardmap[r1][c1]
	local topRightItem = mainLogic.gameItemMap[r1][c1]

	local board = mainLogic.boardmap[r][c]
	local item = mainLogic.gameItemMap[r][c]

	local r2 = r
	local c2 = c + 1

	local rightBoard = mainLogic.boardmap[r2][c2]
	local rightItem = mainLogic.gameItemMap[r2][c2]

	if topRightItem.isUsed and not topRightItem.isBlock then 			----非Block
		if not topRightBoard:hasBottomRope() 			----下方无绳子
			and not rightBoard:hasTopRope() 			----上方无绳子
			and not rightBoard:hasLeftRope() 			----左边无绳子
			and not board:hasRightRope() 				----右边无绳子
			then
			if not topRightBoard:hasEnterPortal() and not rightBoard:hasExitPortal() then
				return true
			else
				return false
			end
		end
	end
	return false
end

function FallingItemLogic:FallingGameItemCheck(mainLogic)----全局检测掉落-----to do-----------------------------------------------
	local isStillFalling = false

	--------1.直线掉落---------
	----传送门优先
	for c = 1, #mainLogic.gameItemMap[1] do 			----由左至右
		for r = #mainLogic.gameItemMap,1, -1 do			----由下至上
			local item = mainLogic.gameItemMap[r][c]
			if item.isUsed and item.isEmpty and item.comePos == nil then  			----使用中方块
				if FallingItemLogic:tryGetFallingFromPass(mainLogic, r, c) then 	----尝试掉落
					isStillFalling = true
				end
			end
		end
	end

	local productPortals = {}
	----生成口生成和直线下落随后
	for c = 1, #mainLogic.gameItemMap[1] do 			----由左至右
		for r = #mainLogic.gameItemMap,1, -1 do			----由下至上
			local item = mainLogic.gameItemMap[r][c]
			if item.isUsed and item.isEmpty and item.comePos == nil then  			----使用中方块
				if FallingItemLogic:tryGetFalling16(mainLogic, r, c, productPortals) then 	----尝试掉落
					isStillFalling = true
				end
			end
		end
	end

	-- 生成口实际执行
	if #productPortals > 0 then
		local sortedProductPortals = mainLogic:sortProductPortals(productPortals)
		for _, pos in ipairs(sortedProductPortals) do
			self:_tryGetFallingItemFromProduct(mainLogic, pos.x, pos.y)
		end
	end

	--------2.斜线掉落----------
	for c = 1,#mainLogic.gameItemMap[1] do 					----由左至右
		for r = #mainLogic.gameItemMap,1, -1 do				----由下至上
			local item = mainLogic.gameItemMap[r][c]
			if item.isUsed and item.isEmpty and item.comePos == nil then  			----使用中方块
				if FallingItemLogic:tryGetFalling234(mainLogic, r, c) then 			----尝试掉落
					isStillFalling = true
				end
			end
		end
	end

	------3.雪崩掉落 对于无法从上方获得item填充的格子从左上或右上位置进行填充
	local function positionSorter(pre, next)
		if pre.start.r == next.start.r then
			return pre.start.c < next.start.c
		else
			return pre.start.r < next.start.r
		end
	end

	local function getFCNeedCheckSnowSlide()
		local result = {}
		for i, fc in ipairs(mainLogic.FallingColumnList) do
			local topR = fc.start.r
			local topC = fc.start.c
			local item = mainLogic.gameItemMap[topR][topC]
			local isTopEmpty = item.isUsed and item.isEmpty and item.comePos == nil
			if isTopEmpty then
				table.insert(result, fc)
			end
		end
		table.sort(result, positionSorter)
		return result
	end

	----获取不再有填充的地格，这些地格没有item可以掉落填充它们
	local function getUnfillableTileMap()
		local result = {}

		local function isPosInvalidOrUnfillable(r, c)
			return not mainLogic:isPosValid(r, c) or result[r .. c]
		end

		for r = 1, #mainLogic.gameItemMap do
			for c = 1, #mainLogic.gameItemMap[r] do
				local item = mainLogic.gameItemMap[r][c]
				if item.isUsed and (item.isEmpty or item.isBlock) and item.comePos == nil then
					local st = mainLogic.FallingHelpMap[r][c]
					if st == FallingSourceType.kNone then
						result[r .. c] = true
					elseif st == FallingSourceType.kUp then
						local topR = r - 1
						if result[topR .. c] then
							result[r .. c] = true
						end
					elseif st == FallingSourceType.kUpLeft then
						local topLeftR = r - 1
						local topLeftC = c - 1
						local topR = r - 1
						if result[topR .. c] and result[topLeftR .. topLeftC] then
							result[r .. c] = true
						end
					elseif st == FallingSourceType.kUpRight then
						local topRightR = r - 1
						local topRightC = c + 1
						local topR = r - 1
						if result[topR .. c] and result[topRightR .. topRightC] then
							result[r .. c] = true
						end
					elseif st == FallingSourceType.kUpLR then
						local topLeftR = r - 1
						local topLeftC = c - 1
						local topRightR = r - 1
						local topRightC = c + 1
						local topR = r - 1
						if result[topR .. c] and result[topLeftR .. topLeftC] and result[topRightR .. topRightC] then
							result[r .. c] = true
						end
					elseif st == FallingSourceType.kPortal then
						if FallingItemLogic:isPortalExitNeedSlide(mainLogic, r, c) then
							result[r .. c] = true
						end
					elseif st == FallingSourceType.kPortalLeft then
						local topLeftR = r - 1
						local topLeftC = c - 1
						if FallingItemLogic:isPortalExitNeedSlide(mainLogic, r, c) 
							-- and result[topLeftR .. topLeftC] 
							then
							result[r .. c] = true
						end
					elseif st == FallingSourceType.kPortalRight then
						local topRightR = r - 1
						local topRightC = c + 1
						if FallingItemLogic:isPortalExitNeedSlide(mainLogic, r, c) 
							-- and result[topRightR .. topRightC] 
							then
							result[r .. c] = true
						end
					elseif st == FallingSourceType.kPortalLR then
						local topLeftR = r - 1
						local topLeftC = c - 1
						local topRightR = r - 1
						local topRightC = c + 1
						if FallingItemLogic:isPortalExitNeedSlide(mainLogic, r, c) 
							-- and result[topRightR .. topRightC] 
							-- and result[topLeftR .. topLeftC]
							then
							result[r .. c] = true
						end
					elseif st == FallingSourceType.kLeft then
						local topLeftR = r - 1
						local topLeftC = c - 1
						if result[topLeftR .. topLeftC] then
							result[r .. c] = true
						end 
					elseif st == FallingSourceType.kRight then
						local topRightR = r - 1
						local topRightC = c + 1
						if result[topRightR .. topRightC] then
							result[r .. c] = true
						end 
					elseif st == FallingSourceType.kDouble then
						local topLeftR = r - 1
						local topLeftC = c - 1
						local topRightR = r - 1
						local topRightC = c + 1
						if result[topLeftR .. topLeftC] and result[topRightR .. topRightC] then
							result[r .. c] = true
						end
					end
				end
			end
		end

		return result
	end

	local function getFCNeedSnowSlide()
		local needCheckList = getFCNeedCheckSnowSlide()	
		local unfillableTileMap = getUnfillableTileMap()
		local result = {}
		local resultTopItemPositionMap = {}

		for i, fc in ipairs(needCheckList) do
			local topR = fc.start.r
			local topC = fc.start.c
			if unfillableTileMap[topR .. topC] then
				table.insert(result, fc)
			end
		end
		return result
	end

	local needSnowSlideFCList = getFCNeedSnowSlide()

	for i, fc in ipairs(needSnowSlideFCList) do
		if FallingItemLogic:tryGetFallingSnowSlide(mainLogic, fc) then
			isStillFalling = true
		end
	end

	FallingItemLogic:clearFCLocks()

	return isStillFalling
end

function FallingItemLogic:isFCStable(mainLogic, fc)
	local startR = fc.start.r
	local endR = startR + fc.len - 1
	local c = fc.start.c
	local result = true
	
	for r = startR, endR do
		local item = mainLogic.gameItemMap[r][c]
		if item.isEmpty 
			or item.ItemStatus == GameItemStatusType.kNone
			or item.ItemStatus == GameItemStatusType.kJustStop
			or item.ItemStatus == GameItemStatusType.kItemHalfStable
			or item.ItemStatus == GameItemStatusType.kJustArrived
			then
		else
			result = false
			break
		end
	end
	return result
end

----有可以掉落的东西
function FallingItemLogic:isItemHasGameItemCanFalling(mainLogic, r, c)
	if not mainLogic:isPosValid(r, c) then return false end
	local item = mainLogic.gameItemMap[r][c]

	if item and item.isUsed and not item.isEmpty and not item.gotoPos 
		and item.ItemType ~= GameItemType.kNone and not item.isBlock 
		and (item.ItemStatus == GameItemStatusType.kNone 
			or item.ItemStatus == GameItemStatusType.kItemHalfStable 
			or item.ItemStatus == GameItemStatusType.kIsFalling
			or item.ItemStatus == GameItemStatusType.kJustArrived
			)
		then
		return true
	end
	return false
end

function FallingItemLogic:tryGetFallingFromPass(mainLogic, r, c)
	local ts = mainLogic.FallingHelpMap[r][c]
	if ts == FallingSourceType.kPortal 
		or ts == FallingSourceType.kPortalLeft 
		or ts == FallingSourceType.kPortalRight 
		or ts == FallingSourceType.kPortalLR 
		or ts == FallingSourceType.kProductPortal
		then
		local board = mainLogic.boardmap[r][c]
		if FallingItemLogic:isItemHasGameItemCanFalling(mainLogic, board.passEnterPoint_x, board.passEnterPoint_y) then 	----通道那边的东西可以掉落
			return FallingItemLogic:_tryGetFallingItemFromPass(mainLogic, r, c)
		end
	end
	return false
end

function FallingItemLogic:tryGetFalling16(mainLogic, r, c, productPos)
	local function isEnterPortalEmpty(r, c)
		local board = mainLogic.boardmap[r][c]
		return not FallingItemLogic:isItemHasGameItemCanFalling(mainLogic, board.passEnterPoint_x, board.passEnterPoint_y)
	end

	local ts = mainLogic.FallingHelpMap[r][c]
	if ts == FallingSourceType.kUp 
		or ts == FallingSourceType.kUpLeft 
		or ts == FallingSourceType.kUpRight 
		or ts == FallingSourceType.kUpLR 
		then
		if FallingItemLogic:isItemHasGameItemCanFalling(mainLogic, r-1, c) then 	----上方有可以掉落的东西
			return FallingItemLogic:_tryGetFallingItemFromUp(mainLogic, r, c)
		end
	elseif ts == FallingSourceType.kProduct 
		or (ts == FallingSourceType.kProductPortal and isEnterPortalEmpty(r, c) and not FallingItemLogic:isFCHeadLocked(r, c)) then

		-- 在生成口所在的FallingColumn中，生成口上方位置有item存在时，生成口不生效，此时视为由上方下落，掉落来源类型为FallingSourceType.kUp
		local fc = FallingItemLogic:getFallingColumnByPos(mainLogic, r, c)
		local fcStartRow = fc.start.r
		if fcStartRow < r then
			for i = fcStartRow, r - 1 do
				local tempItem = mainLogic.gameItemMap[i][c]
				if tempItem.isUsed and not tempItem.isEmpty then
					if FallingItemLogic:isItemHasGameItemCanFalling(mainLogic, r-1, c) then 	----上方有可以掉落的东西
						-- perform as FallingSourceType.kUp
						return FallingItemLogic:_tryGetFallingItemFromUp(mainLogic, r, c)
					else
						return false
					end
				end
			end
		end
		table.insert(productPos, IntCoord:create(r, c))
		return true
		-- return FallingItemLogic:_tryGetFallingItemFromProduct(mainLogic, r, c)
	end
	return false
end

function FallingItemLogic:tryGetFalling234(mainLogic, r, c)
	local ts = mainLogic.FallingHelpMap[r][c]
	if ts == FallingSourceType.kLeft then 
		if FallingItemLogic:isItemHasGameItemCanFalling(mainLogic, r-1, c-1) then 	----左上方有可以掉落的东西
			return FallingItemLogic:_tryGetFallingItemFromLeftUp(mainLogic, r, c)
		end
	elseif ts == FallingSourceType.kRight then
		if FallingItemLogic:isItemHasGameItemCanFalling(mainLogic, r-1, c+1) then 	----右上方有可以掉落的东西
			return FallingItemLogic:_tryGetFallingItemFromRightUp(mainLogic, r, c)
		end
	elseif ts == FallingSourceType.kDouble then 															----左右随机掉落
		return FallingItemLogic:_tryGetFallingItemFromLeftRightUp(mainLogic, r, c)
	end
end

function FallingItemLogic:isFallingColumnEmpty(mainLogic, fc)
	local startR = fc.start.r
	local c = fc.start.c
	local endR = startR + fc.len - 1
	for r = startR, endR do
		local item = mainLogic.gameItemMap[r][c]
		if not item.isEmpty or item.comePos ~= nil then
			return false
		end
	end
	return true
end

function FallingItemLogic:isFCHeadLocked(r, c)
	return kLockedFC and kLockedFC[r .. "_" .. c]
end

function FallingItemLogic:lockFCHead(r, c)
	kLockedFC = kLockedFC or {}
	kLockedFC[r .. "_" .. c] = true
end

function FallingItemLogic:clearFCLocks()
	kLockedFC = {}
end

function FallingItemLogic:isPortalExitNeedSlide(mainLogic, r, c)
	local ts = mainLogic.FallingHelpMap[r][c]
	if ts == FallingSourceType.kPortal 
		or ts == FallingSourceType.kPortalLeft 
		or ts == FallingSourceType.kPortalRight 
		or ts == FallingSourceType.kPortalLR 
		then
		if FallingItemLogic:isFCHeadLocked(r, c) then
			return false
		end
		local board = mainLogic.boardmap[r][c]
		local enterX = board.passEnterPoint_x
		local enterY = board.passEnterPoint_y
		local enterBoard = mainLogic.boardmap[enterX][enterY]
		local enterBoardFC = FallingItemLogic:getFallingColumnByPos(mainLogic, enterX, enterY)

		if enterBoardFC then
			local fcStartBoard = mainLogic.boardmap[enterBoardFC.start.r][enterBoardFC.start.c]
			if not fcStartBoard.isProducer and FallingItemLogic:isFallingColumnEmpty(mainLogic, enterBoardFC) then
				return true
			end
		end
	end
	return false
end

function FallingItemLogic:tryGetFallingSnowSlide(mainLogic, fc)
	local r = fc.start.r
	local c = fc.start.c
	local bottomR = fc.start.r + fc.len - 1
	for k = r, bottomR do
		local st = mainLogic.FallingHelpMap[k][c]
		local item = mainLogic.gameItemMap[k][c]
		if item.isEmpty and item.comePos == nil then
			local canSlideLeft = false
			local canSlideRight = false
			local fallsuccess = false

			if st == FallingSourceType.kUpLeft or st == FallingSourceType.kPortalLeft then
				canSlideLeft = true
			elseif st == FallingSourceType.kUpRight or st == FallingSourceType.kPortalRight then
				canSlideRight = true
			elseif st == FallingSourceType.kUpLR or st == FallingSourceType.kPortalLR then
				canSlideLeft = true
				canSlideRight = true
			else
				canSlideLeft = FallingItemLogic:canFallingFromLeft(mainLogic, k, c)
				canSlideRight = FallingItemLogic:canFallingFromRight(mainLogic, k, c)
			end

			if canSlideLeft and canSlideRight then
				fallsuccess = FallingItemLogic:_tryGetFallingItemFromLeftRightUp(mainLogic, k, c)
			elseif canSlideLeft then
				if FallingItemLogic:isItemHasGameItemCanFalling(mainLogic, k - 1, c - 1) then
					fallsuccess = FallingItemLogic:_tryGetFallingItemFromLeftUp(mainLogic, k, c)
				end
			elseif canSlideRight then
				if FallingItemLogic:isItemHasGameItemCanFalling(mainLogic, k - 1, c + 1) then
					fallsuccess = FallingItemLogic:_tryGetFallingItemFromRightUp(mainLogic, k, c)
				end
			end

			if fallsuccess then
				return fallsuccess
			end
		else
			return false
		end
	end
	return false
end

function FallingItemLogic:_tryGetFallingItemFromUp(mainLogic, r, c)
	-- body
	local item1 = mainLogic.gameItemMap[r-1][c] 	----上面那个
	local item2 = mainLogic.gameItemMap[r][c]		----下面空位

	item2.gotoPos = IntCoord:create(r, c)
	item2.comePos = IntCoord:create(r - 1, c)

	----直接放入----
	item2:getAnimalLikeDataFrom(item1)	----获取物品信息
	item2.dataReach = false 								----数据未到
	item2.ItemStatus = GameItemStatusType.kIsFalling		----正在下落
	item2.itemPosAdd.x = 0
	item2.itemPosAdd.y = GamePlayConfig_Tile_Height + item2.itemPosAdd.y		----从上方而来
	item2.isEmpty = false;

	item1:cleanAnimalLikeData()

	----开始动作----

	local FallingAction = GameBoardActionDataSet:createAs(		------下落动作
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemFalling_UpDown,
		IntCoord:create(r-1,c),
		IntCoord:create(r,c),
		GamePlayConfig_Falling_MaxTime)
	mainLogic:addFallingAction(FallingAction)
	FallingAction.addInfo = "Pass"

	return true
end

function FallingItemLogic:_tryGetFallingItemFromLeftUp(mainLogic, r, c)
	-- body
	local item1 = mainLogic.gameItemMap[r-1][c-1]	----上面那个
	local item2 = mainLogic.gameItemMap[r][c]		----下面空位

	item2.gotoPos = IntCoord:create(r, c)
	item2.comePos = IntCoord:create(r - 1, c - 1)
	
	----直接放入----
	item2:getAnimalLikeDataFrom(item1)	----获取物品信息
	item2.dataReach = false 								----数据未到
	item2.ItemStatus = GameItemStatusType.kIsFalling		----正在下落
	item2.itemPosAdd.x = -GamePlayConfig_Tile_Width
	item2.itemPosAdd.y = GamePlayConfig_Tile_Height		----从上方而来
	item2.isEmpty = false;
	item2.itemSpeed = 0;

	item1:cleanAnimalLikeData()

	----开始动作----
	local FallingAction = GameBoardActionDataSet:createAs(		------下落动作
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemFalling_LeftRight,
		IntCoord:create(r - 1, c - 1),
		IntCoord:create(r,c),
		GamePlayConfig_Falling_LeftRight_Time)
	mainLogic:addFallingAction(FallingAction)
	FallingAction.addInfo = "Pass"

	return true
end

function FallingItemLogic:_tryGetFallingItemFromRightUp(mainLogic, r, c)
	-- body
	local item1 = mainLogic.gameItemMap[r-1][c+1]	----上面那个
	local item2 = mainLogic.gameItemMap[r][c]		----下面空位
	item2.gotoPos = IntCoord:create(r, c)
	item2.comePos = IntCoord:create(r - 1, c + 1)

	----直接放入----
	item2:getAnimalLikeDataFrom(item1)	----获取物品信息
	item2.dataReach = false 									----数据未到
	item2.ItemStatus = GameItemStatusType.kIsFalling			----正在下落
	item2.itemPosAdd.x = GamePlayConfig_Tile_Width
	item2.itemPosAdd.y = GamePlayConfig_Tile_Height			----从上方而来
	item2.isEmpty = false;
	item2.itemSpeed = 0;

	item1:cleanAnimalLikeData()

	----开始动作----
	local FallingAction = GameBoardActionDataSet:createAs(		------下落动作
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemFalling_LeftRight,
		IntCoord:create(r - 1, c + 1),
		IntCoord:create(r,c),
		GamePlayConfig_Falling_LeftRight_Time)
	mainLogic:addFallingAction(FallingAction)
	FallingAction.addInfo = "Pass"

	return true
end

function FallingItemLogic:_tryGetFallingItemFromLeftRightUp(mainLogic, r, c)
	-- body
	local f_type = 0
	if FallingItemLogic:isItemHasGameItemCanFalling(mainLogic, r-1, c-1) then
		f_type = f_type + 1
	end
	if FallingItemLogic:isItemHasGameItemCanFalling(mainLogic, r-1, c+1) then
		f_type = f_type + 2
	end
	if f_type == 3 then ----随机
		f_type = mainLogic.randFactory:rand(1,2);
	end
		
	if f_type == 1 then -----左边
		return FallingItemLogic:_tryGetFallingItemFromLeftUp(mainLogic, r, c)
	elseif f_type == 2 then -----右边
		return FallingItemLogic:_tryGetFallingItemFromRightUp(mainLogic, r, c)
	end
	return false
end

function FallingItemLogic:_tryGetFallingItemFromPass(mainLogic, r, c)				----从通道的另一边获取物品

	local board2 = mainLogic.boardmap[r][c]		----下面空位
	local r1 = board2.passEnterPoint_x
	local c1 = board2.passEnterPoint_y

	local board1 = mainLogic.boardmap[r1][c1]		----掉落动物

	local item1 = mainLogic.gameItemMap[r1][c1]
	local item2 = mainLogic.gameItemMap[r][c]

	item2.gotoPos = IntCoord:create(r, c)
	item2.comePos = IntCoord:create(r1, c1)

	----直接放入----
	item2:getAnimalLikeDataFrom(item1)	----获取物品信息
	item2.dataReach = false 								----数据未到
	item2.ItemStatus = GameItemStatusType.kIsFalling		----正在下落
	item2.itemSpeed = GamePlayConfig_FallingSpeed_Pass_Start
	item2.itemPosAdd.x = 0
	item2.itemPosAdd.y = GamePlayConfig_Tile_Height			----从上方而来
	item2.ClippingPosAdd.y = GamePlayConfig_Tile_Height		----从上方而来
	item2.isEmpty = false

	item1:cleanAnimalLikeData()
	item1.EnterClippingPosAdd.y = 0

	----开始动作----
	local FallingAction = GameBoardActionDataSet:createAs(		------下落动作
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemFalling_Pass,
		IntCoord:create(r1,c1),	 		----上面那个
		IntCoord:create(r,c),			----
		GamePlayConfig_Falling_MaxTime)
	mainLogic:addFallingAction(FallingAction)
	FallingAction.addInfo = "Pass"

	return true
end

function FallingItemLogic:_tryGetFallingItemFromProduct(mainLogic, r, c) 			----从生产口创建
	local item1 = mainLogic.gameItemMap[r][c]		----生成位置
	item1.gotoPos = IntCoord:create(r,c)
	item1.comePos = IntCoord:create(0,0)

	----直接放入------随机生成-----
	local data1 = mainLogic:randomANewItemFallingData(r,c)		----随机一个数据
	item1:getAnimalLikeDataFrom(data1) 							----获取物品信息
	item1.dataReach = false 									----数据未到
	item1.ItemStatus = GameItemStatusType.kIsFalling			----正在下落
	item1.ClippingPosAdd.y = GamePlayConfig_Tile_Height
	if mainLogic:isPosValid(r + 1, c) then
		local item2 = mainLogic.gameItemMap[r + 1][c]
		if item2.itemPosAdd.y ~= 0 then
			item1.ClippingPosAdd.y = item2.itemPosAdd.y	
		end
	end
	item1.itemPosAdd.y = item1.ClippingPosAdd.y
	item1.isEmpty = false;

	item1.isProduct = true;
	----开始动作----
	local FallingAction = GameBoardActionDataSet:createAs(		------下落动作
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemFalling_Product,
		IntCoord:create(r,c),
		IntCoord:create(r+1,c),
		GamePlayConfig_Falling_MaxTime)

	mainLogic:addFallingAction(FallingAction)
	FallingAction.addInfo = "Pass"

	return true
end

function FallingItemLogic:isFallingColumnBelowFull(mainLogic, fc, startR)
	local rStart = startR
	local rEnd = fc.start.r + fc.len - 1
	local c = fc.start.c

	local fallingColumnBelowFull = true
	for row = rStart, rEnd do
		local tempItem = mainLogic.gameItemMap[row][c]
		if tempItem.isEmpty then
			fallingColumnBelowFull = false
		end
	end
	return fallingColumnBelowFull
end

function FallingItemLogic:getNumFallingColumnEmptyTile(mainLogic, fc)
	local rStart = fc.start.r
	local rEnd = fc.start.r + fc.len - 1
	local c = fc.start.c
	local result = 0
	for row = rStart, rEnd do
		local tempItem = mainLogic.gameItemMap[row][c]
		if tempItem.isEmpty then
			result = result + 1
		end
	end
	return result
end

function FallingItemLogic:getNumFallingColumnBelowItem(mainLogic, fc, startR)
	local rStart = startR + 1
	local rEnd = fc.start.r + fc.len - 1
	local c = fc.start.c
	local result = 0

	if startR == rEnd then
		return 0
	end

	for row = rStart, rEnd do
		local tempItem = mainLogic.gameItemMap[row][c]
		if not tempItem.isEmpty then
			result = result + 1
		end
	end
	return result
end

function FallingItemLogic:getNumFallingColumnBelowTile(mainLogic, fc, startR)
	local rEnd = fc.start.r + fc.len - 1
	return rEnd - startR
end

function FallingItemLogic:stopFCFallingColumnByPos(mainLogic, r, c)
	if kStopFallingColHelper[r.."_"..c] then -- 防止出现环链无限循环
		return
	end
	kStopFallingColHelper[r.."_"..c] = true
	local fc = FallingItemLogic:getFallingColumnByPos(mainLogic, r, c)
	if fc then
		local rStart = fc.start.r
		local rEnd = fc.start.r + fc.len - 1
		if r > rStart and r <= rEnd then
			for row = r, rStart, -1 do
				local item = mainLogic.gameItemMap[row][c]
				if item.dataReach and item.ItemStatus == GameItemStatusType.kIsFalling then
					item:AddItemStatus(GameItemStatusType.kItemHalfStable)
				else
					return
				end
			end
		end

		local headBoard = mainLogic.boardmap[rStart][c]
		if headBoard:hasExitPortal() then
			local enterX = headBoard.passEnterPoint_x
			local enterY = headBoard.passEnterPoint_y
			FallingItemLogic:stopFCFallingColumnByPos(mainLogic, enterX, enterY)
		end
	end
end

function FallingItemLogic:stopFCFallingByBlock(mainLogic, r, c)
	kStopFallingColHelper = {}
	local fc = FallingItemLogic:getFallingColumnByPos(mainLogic, r, c)
	if fc then
		local rStart = fc.start.r
		local rEnd = fc.start.r + fc.len - 1
		if r > rStart and r <= rEnd then
			FallingItemLogic:stopFCFallingColumnByPos(mainLogic, r-1, c)
		elseif r == rStart then
			local board = mainLogic.boardmap[r][c]
			if board:hasExitPortal() then
				local enterX = board.passEnterPoint_x
				local enterY = board.passEnterPoint_y
				FallingItemLogic:stopFCFallingColumnByPos(mainLogic, enterX, enterY)
			end
		end
	end
end

--------------------------------------------------------------
-- 检测是否停止直线掉落状态
-- return number 
-- 0: stop falling
-- 1: keep falling and keep speed 
-- 2: keep falling and reset speed
--------------------------------------------------------------
function FallingItemLogic:checkStopFallingDown(mainLogic, r, c)
	if r < #mainLogic.boardmap then 					----当没有到屏幕最下方时
		local board1 = mainLogic.boardmap[r][c]
		local board2 = mainLogic.boardmap[r+1][c]

		local item1 = mainLogic.gameItemMap[r][c]
		local item2 = mainLogic.gameItemMap[r+1][c]

		local fc = FallingItemLogic:getFallingColumnByPos(mainLogic, r, c)

		if fc then
			local fallingColumnBelowNotFull = not FallingItemLogic:isFallingColumnBelowFull(mainLogic, fc, r)
			if fallingColumnBelowNotFull then
				-- 可以向下掉落
				return 1
			else
				local fcBottomBoard = mainLogic.boardmap[fc.start.r + fc.len - 1][fc.start.c]
				-- falling column最下方有传送门
				if fcBottomBoard:hasEnterPortal() and not fcBottomBoard:hasChainInDirection(ChainDirConfig.kDown) then
					local exitX = fcBottomBoard.passExitPoint_x
					local exitY = fcBottomBoard.passExitPoint_y
					local exitBoard = mainLogic.boardmap[exitX][exitY]

					if exitBoard and exitBoard:hasExitPortal() then
						local exitFC = FallingItemLogic:getFallingColumnByPos(mainLogic, exitX, exitY)
						if exitFC and not exitBoard:hasChainInDirection(ChainDirConfig.kUp) then
							local numExitFCEmptyTile = FallingItemLogic:getNumFallingColumnEmptyTile(mainLogic, exitFC)
							local numFCBelowItem = FallingItemLogic:getNumFallingColumnBelowItem(mainLogic, fc, r)
							local numFCBelowTile = FallingItemLogic:getNumFallingColumnBelowTile(mainLogic, fc, r)

							if numFCBelowItem < numExitFCEmptyTile + numFCBelowTile then
								FallingItemLogic:lockFCHead(exitX, exitY)
								-- 等待fc下方传送门传送，此时被判定为掉落状态，item不进入稳定
								return 2
							end
						end
					end
				end	
			end
		end
	end

	return 0
end