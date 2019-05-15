SunflowerLogic = class{}

function SunflowerLogic:breakSunFlask(mainLogic, r, c, times, scoreScale)
	scoreScale = scoreScale or 1
	local item = mainLogic.gameItemMap[r][c]
	local origLevel = item.sunFlaskLevel
	item.sunFlaskLevel = item.sunFlaskLevel - times
	if item.sunFlaskLevel < 0 then item.sunFlaskLevel = 0 end
	ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_SunFlask, ObstacleFootprintAction.k_Hit, origLevel - item.sunFlaskLevel)

	local itemView = mainLogic.boardView.baseMap[r][c]
	itemView:playSunFlaskBeingHit(item.sunFlaskLevel)

	if item.sunFlaskLevel == 0 then
		local action = GameBoardActionDataSet:createAs(
	        GameActionTargetType.kGameItemAction,
	        GameItemActionType.kItem_SunFlask_Blast, 
	        IntCoord:create(c, r),
	        nil,
	        GamePlayConfig_MaxAction_time
	        )
		action.targetFlask = item
		if SunflowerLogic:getSunflowerLackedEnergy(mainLogic) > 0 then
			local targetSunflower = SunflowerLogic:_getSunflowerOnBoard(mainLogic)
			action.targetSunflower = targetSunflower
			if targetSunflower then
				ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Sunflower, ObstacleFootprintAction.k_Charge, 1)
			end
		end
	    mainLogic:addDestroyAction(action)
		mainLogic:setNeedCheckFalling()
	end
	
end

function SunflowerLogic:onSunFlaskDestroyed(mainLogic, targetFlask)
	if targetFlask then
		targetFlask:cleanAnimalLikeData()
		-- targetFlask.isUsed = false
		targetFlask.isNeedUpdate = true
		mainLogic:checkItemBlock(targetFlask.y, targetFlask.x)
		mainLogic:addScoreToTotal(targetFlask.y, targetFlask.x, 100)

		SnailLogic:SpecialCoverSnailRoadAtPos(mainLogic, targetFlask.y, targetFlask.x)

		if mainLogic.sunflowerEnergy then
			mainLogic.sunflowerEnergy = mainLogic.sunflowerEnergy + 1
		end
	end
end

--------------------------- sunflower -----------------------------
function SunflowerLogic:getSunflowerLackedEnergy(mainLogic)
	local energyNeeded = 0
	if mainLogic and mainLogic.sunflowersAppetite and mainLogic.sunflowersAppetite > 0 then
		energyNeeded = mainLogic.sunflowersAppetite

		if mainLogic.sunflowerEnergy and mainLogic.sunflowerEnergy > 0 then
			energyNeeded = math.max(0, mainLogic.sunflowersAppetite - mainLogic.sunflowerEnergy)
		end
	end
	return energyNeeded
end

function SunflowerLogic:_getSunflowerOnBoard(mainLogic)
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
            if item.ItemType == GameItemType.kSunflower then
            	return item
            end
		end
	end
	return nil
end

function SunflowerLogic:getActiveSunflower(mainLogic)
	local sunflower = SunflowerLogic:_getSunflowerOnBoard(mainLogic)
	if sunflower and sunflower:isVisibleAndFree() then
		return sunflower
	end
	return nil
end

function SunflowerLogic:onSunFlowerDestroyed(mainLogic, targetFlower)
	if targetFlower then
		targetFlower:cleanAnimalLikeData()
		-- targetFlower.isUsed = false
		targetFlower.isNeedUpdate = true
		mainLogic:checkItemBlock(targetFlower.y, targetFlower.x)

		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Sunflower, ObstacleFootprintAction.k_Attack, 1)
	end
end
