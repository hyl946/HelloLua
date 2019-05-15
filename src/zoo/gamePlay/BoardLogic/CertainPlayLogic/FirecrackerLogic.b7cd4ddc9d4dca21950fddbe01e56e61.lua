FirecrackerLogic = {}

function FirecrackerLogic:hasGeneratedFirecracker()
	local mainLogic = GameBoardLogic:getCurrentLogic()
	if mainLogic.generateFirecrackerTimes > 0 then
		return true
	end

	if mainLogic.generateFirecrackerTimesForPreBuff > 0 then
		return true
	end
	
	return false
end

---------------------------------------------------- Destroy ---------------------------------------------------
function FirecrackerLogic:onFirecrackerSimulated(targetBottle)
	-- printx(11, "--------------- onFirecrackerSimulated -----------------------")
	targetBottle.isToBlastFirecracker = true

	local mainLogic = GameBoardLogic:getCurrentLogic()
	local itemView = mainLogic.boardView.baseMap[targetBottle.y][targetBottle.x]
	if itemView then
		itemView:playFirecrackerBeingHit()
	end
end

function FirecrackerLogic:getAllToBlastFirecrackerOnBoard(mainLogic)
	local allTarget = {}
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
            if item and item.isToBlastFirecracker and item.ItemType == GameItemType.kFirecracker and item:isVisibleAndFree() then
            	table.insert(allTarget, item)
            end
		end
	end
	return allTarget
end

function FirecrackerLogic:onDestroyFirecracker(mainLogic, targetItem)
	-- printx(11, "--------------- onDestroyFirecracker -----------------------")
	if targetItem then
		targetItem.isToBlastFirecracker = false
		local r, c = targetItem.y, targetItem.x

		GameExtandPlayLogic:chargeCrystalStone(mainLogic, r, c, targetItem._encrypt.ItemColorType)
		GameExtandPlayLogic:doAllBlocker211Collect(mainLogic, r, c, targetItem._encrypt.ItemColorType, false, 1)

		targetItem:cleanAnimalLikeData()
		targetItem.isNeedUpdate = true
		mainLogic:checkItemBlock(r, c)

		local addScore = GamePlayConfigScore.MatchBySnow
		mainLogic:addScoreToTotal(r, c, addScore)
	end
end
