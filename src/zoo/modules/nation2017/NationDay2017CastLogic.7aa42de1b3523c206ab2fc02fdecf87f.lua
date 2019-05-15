---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2017-09-01 17:16:55
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2017-09-14 19:04:56
---------------------------------------------------------------------------------------
NationDay2017CastLogic = class()

local kCoinWeightByCol = {}
for col = 1, 9 do
	kCoinWeightByCol[col] = math.pow(4, 9 - col) * 10000
end

function NationDay2017CastLogic:runCastAction(mainLogic, times)
	times = times or 1

	local function getItemWeight(r, c)
		if mainLogic.gameItemMap[r] then
			local item = mainLogic.gameItemMap[r][c]
			local board = mainLogic.boardmap[r][c]
			if item and item.isUsed then
				if item.ItemType == GameItemType.kCoin then
					return kCoinWeightByCol[c]
				elseif item.olympicLockLevel > 0 or
						item.cageLevel > 0 or
						item:hasAnyFurball() or
						item.ItemType == GameItemType.kVenom then
					return 1000
				elseif item.ItemType == GameItemType.kCrystal or
						item.ItemType == GameItemType.kRoost or
						item.ItemType == GameItemType.kMimosa or
						item.ItemType == GameItemType.kKindMimosa then
					return 100
				elseif item.ItemType == GameItemType.kAnimal and item.ItemSpecialType == 0 then
					return 10

				elseif item.ItemType == GameItemType.kAnimal then
					return 1
				end	
			end
		end
		return 0
	end

	local helpMap = {}
	for r = 1, 9 do
		if not helpMap[r] then helpMap[r] = {} end
		for c = 1, 9 do
			local weight = getItemWeight(r, c)
			helpMap[r][c] = {weight = weight, used = false}
		end
	end

	local function getTotalWeightByPos(r, c)
		local totalWeight = 0
		if helpMap[r] and helpMap[r][c] and helpMap[r][c].weight > 0 then
			for i = r-1, r+1 do
				for j = c - 1, c + 1 do
					if i >= 1 and i <= 9 and j >= 1 and j <= 9 and not helpMap[i][j].used then
						totalWeight = totalWeight + helpMap[i][j].weight
					end
				end
			end
		end
		return totalWeight
	end

	local function findBiggestWeightPos()
		local biggest = 0
		local posList = {}
		for r = 1, 9 do
			for c = 1, 9 do
				local weight = getTotalWeightByPos(r, c)
				if _G.isLocalDevelopMode then printx(0, "findBiggestWeightPos", r, c, weight) end
				if weight > 0 and weight >= biggest then
					if weight > biggest then posList = {} end
					table.insert(posList, {r=r, c=c})
					biggest = weight
				end
			end
		end
		if _G.isLocalDevelopMode then printx(0, "findBiggestWeightPos", table.tostring(posList)) end
		if #posList > 1 then
			return posList[mainLogic.randFactory:rand(1, #posList)]
		end
		return posList[1] -- maybe nil
	end

	local function findRandomPos()
		local posList = {}
		for r = 1, 9 do
			for c = 1, 9 do
				local item = mainLogic.gameItemMap[r] and mainLogic.gameItemMap[r][c] or nil
				if item and item.isUsed then
					table.insert(posList, {r=r,c=c})
				end
			end
		end
		if #posList > 1 then
			return posList[mainLogic.randFactory:rand(1, #posList)]
		end
		return posList[1] -- maybe nil
	end

	local function markPosAroundBeUsed(r, c)
		for i = r-1, r+1 do
			for j = c - 1, c + 1 do
				if i >= 1 and i <= 9 and j >= 1 and j <= 9 then
					helpMap[i][j].used = true
				end
			end
		end
	end

	local actionNum = 0
	local targetPosList = {}
	for i = 1, 2*times do
		local pos = findBiggestWeightPos()
		if not pos then pos = findRandomPos() end
		if pos then
			table.insert(targetPosList, pos)
			markPosAroundBeUsed(pos.r, pos.c)
		end
	end
	if _G.isLocalDevelopMode then printx(0, "targetPosList", table.tostring(targetPosList)) end
	if #targetPosList > 0 then
		actionNum = actionNum + 1
		local theAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kNationDay2017_Cast,
			nil,
			nil,
			GamePlayConfig_MaxAction_time)
		local castFromPos = mainLogic.gameMode.getCastFromPos and mainLogic.gameMode:getCastFromPos()
		if _G.isLocalDevelopMode then printx(0, "castFromPos:", table.tostring(castFromPos)) end
		theAction.castFromPos = castFromPos or {x = 0, y = 0}
		theAction.specialTargetPosList = targetPosList
		theAction.debugBombNum = actionNum
		mainLogic:addDestructionPlanAction(theAction)
	end
	return actionNum
end