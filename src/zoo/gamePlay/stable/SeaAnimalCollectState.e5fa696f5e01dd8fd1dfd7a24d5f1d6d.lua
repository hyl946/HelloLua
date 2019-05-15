SeaAnimalCollectState = class(BaseStableState)


function SeaAnimalCollectState:create( context )
    -- body
    local v = SeaAnimalCollectState.new()
    v.context = context
    v.mainLogic = context.mainLogic  --gameboardlogic
    v.boardView = v.mainLogic.boardView
    return v
end

function SeaAnimalCollectState:update( ... )
    -- body
end

function SeaAnimalCollectState:onEnter()
    printx( -1 , "---->>>> SeaAnimalCollectState enter")
    if not self.mainLogic.gameMode:is(SeaOrderMode) then
    	return 0
    end

    return self:tryCollect()

end


function SeaAnimalCollectState:handleComplete()
    self.mainLogic:setNeedCheckFalling();
end

function SeaAnimalCollectState:onExit()
    printx( -1 , "----<<<< SeaAnimalCollectState exit")
    self.nextState = nil
    self.hasItemToHandle = false
end

function SeaAnimalCollectState:checkTransition()
    printx( -1 , "-------------------------SeaAnimalCollectState checkTransition")
    return self.nextState
end

function SeaAnimalCollectState:getCurrSeaAnimalStaticData()
	local boardMap = self.mainLogic.boardmap
	local datas = {}

	if boardMap then
		for r = 1, #boardMap do
			if boardMap[r] then
				for c = 1, #boardMap[r] do
					if boardMap[r][c] then

						local board = boardMap[r][c]
						if board.seaAnimalType and board.seaAnimalType ~= 0 then
							local animalData = SeaOrderMode:creatSeaAnimalStaticData( board.seaAnimalType , r , c )
							table.insert( datas , animalData )
						end
					end	
				end
			end
		end
	end
	return datas
end

function SeaAnimalCollectState:__tryCollect(seaAnimals , gameItemMap , boardMap , callback)

	local count = 0

	for k, v in pairs(seaAnimals) do
		-- 判断动物上的冰是否都消除了，并且都在反转地格的正面
		if v.isFreed ~= true then

			local isFreed = true
			--printx( 1 , "   SeaAnimalCollectState:__tryCollect  " , v.y , v.x , v.yEnd , v.xEnd)
			for r = v.y, v.yEnd do 
				for c = v.x, v.xEnd do
					if boardMap[r][c].iceLevel and boardMap[r][c].iceLevel > 0 or
						(boardMap[r][c].tileBlockType == 1 and boardMap[r][c].isReverseSide) then
						isFreed = false
						break
					end

					--[[
					if boardMap[r][c].iceLevel and boardMap[r][c].iceLevel > 0 or
						(boardMap[r][c].tileBlockType == 1 and boardMap[r][c].isReverseSide and boardMap[r][c].side ~= 1)
						or (boardMap[r][c].tileBlockType == 2 and boardMap[r][c].side == 2) then
						isFreed = false
						break
					end
					]]
				end
				if not isFreed then break end
			end

			-- isFreed = false -- test

			-- if _G.isLocalDevelopMode then printx(0, v.x, v.y, v.xEnd, v.yEnd, 'isFreed', isFreed) end

			if isFreed then
				--printx( 1 , "R     SeaAnimalCollectState:__tryCollect  isFreed  " , v.y , v.x , v.yEnd , v.xEnd)
				count = count + 1
				v.isFreed = true
				local destruction = GameBoardActionDataSet:createAs(
					GameActionTargetType.kGameItemAction,
					GameItemActionType.kItem_Area_Destruction,
					IntCoord:create(v.x, v.y),
					IntCoord:create(v.xEnd, v.yEnd),
					GamePlayConfig_MaxAction_time)
				destruction.completeCallback = callback
				self.mainLogic:addGameAction(destruction)

				local key1 = GameItemOrderType.kSeaAnimal
				local key2
				local rotation = 0
				local addScore = 0
				local footprintSubType
                local getNum = 1
				if v.type == SeaAnimalType.kPenguin then
					key2 = GameItemOrderType_SeaAnimal.kPenguin
					rotation = 0
					addScore = GamePlayConfigScore.SeaAnimalPenguin
					setTimeOut( function () GamePlayMusicPlayer:playEffect( GameMusicType.kPlayPenguinSave ) end , 0.7 )
					footprintSubType = ObstacleFootprintSubType.k_Arctic_Penguin
				elseif v.type == SeaAnimalType.kPenguin_H then
					key2 = GameItemOrderType_SeaAnimal.kPenguin
					rotation = 90
					addScore = GamePlayConfigScore.SeaAnimalPenguin
					setTimeOut( function () GamePlayMusicPlayer:playEffect( GameMusicType.kPlayPenguinSave ) end , 0.7 )
					footprintSubType = ObstacleFootprintSubType.k_Arctic_Penguin
				elseif v.type == SeaAnimalType.kSeaBear then
					key2 = GameItemOrderType_SeaAnimal.kSeaBear
					rotation = 0
					addScore = GamePlayConfigScore.SeaAnimalBear
					setTimeOut( function () GamePlayMusicPlayer:playEffect( GameMusicType.kPlayBearSave ) end , 0.7 )
					footprintSubType = ObstacleFootprintSubType.k_Arctic_PolarBear
				elseif v.type == SeaAnimalType.kSeal then
					key2 = GameItemOrderType_SeaAnimal.kSeal
					rotation = 0
					addScore = GamePlayConfigScore.SeaAnimalSeal
					setTimeOut( function () GamePlayMusicPlayer:playEffect( GameMusicType.kPlayPosterSave ) end , 0.7 )
					footprintSubType = ObstacleFootprintSubType.k_Arctic_Seal
				elseif v.type == SeaAnimalType.kSeal_V then 
					key2 = GameItemOrderType_SeaAnimal.kSeal
					rotation = -90
					addScore = GamePlayConfigScore.SeaAnimalSeal
					setTimeOut( function () GamePlayMusicPlayer:playEffect( GameMusicType.kPlayPosterSave ) end , 0.7 )
					footprintSubType = ObstacleFootprintSubType.k_Arctic_Seal
				--下边是圣诞关卡的音效 不再需要了
				elseif v.type == SeaAnimalType.kMistletoe then
					key2 = GameItemOrderType_SeaAnimal.kMistletoe
					rotation = 0
					addScore = 1000
					-- setTimeOut( function () GamePlayMusicPlayer:playEffect( GameMusicType.kPlayPosterSave ) end , 0.7 )
				elseif v.type == SeaAnimalType.kElk then
					key2 = GameItemOrderType_SeaAnimal.kElk
					rotation = 0
					addScore = 1000
					-- setTimeOut( function () GamePlayMusicPlayer:playEffect( GameMusicType.kPlayElkSave ) end , 0.7 )
				elseif v.type == SeaAnimalType.kScarf_H then					
					key2 = GameItemOrderType_SeaAnimal.kScaf_H
					rotation = 90
					addScore = 1000
					-- setTimeOut( function () GamePlayMusicPlayer:playEffect( GameMusicType.kPlayPosterSave ) end , 0.7 )
				elseif v.type == SeaAnimalType.kScarf_V then
					key2 = GameItemOrderType_SeaAnimal.kScaf_V
					rotation = 0
					addScore = 1000
					-- setTimeOut( function () GamePlayMusicPlayer:playEffect( GameMusicType.kPlayPosterSave ) end , 0.7 )		
				elseif v.type == SeaAnimalType.kSea_3_3 then
					key2 = GameItemOrderType_SeaAnimal.kSea_3_3
					rotation = 0
					addScore = 1000			
                    
                    getNum = self.mainLogic.SunmerFish3x3GetNum										
				end
				self.mainLogic:tryDoOrderList(v.y,v.x,key1,key2,getNum, rotation)
				ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_SeaAnimal, ObstacleFootprintAction.k_List, 1, footprintSubType)

				self.mainLogic:addScoreToTotal(v.x, v.y, addScore, nil, 2)
			end
		end
	end

	return count
end

function SeaAnimalCollectState:tryCollect()

	local count = 0
	local callbackCount = 0
	local function callback()
		callbackCount = callbackCount + 1
		if callbackCount == count then
			self:handleComplete()
		end
	end
 
	local gameItemMap = self.mainLogic.gameItemMap
	local boardMap = self.mainLogic.boardmap
	local seaAnimals = nil

	if self.mainLogic.needUpdateSeaAnimalStaticData then
		self.mainLogic.needUpdateSeaAnimalStaticData = false
		self.mainLogic.gameMode.allSeaAnimals = self:getCurrSeaAnimalStaticData()
	end

	seaAnimals = self.mainLogic.gameMode.allSeaAnimals

	if not seaAnimals then seaAnimals = {} end
	count = self:__tryCollect( seaAnimals , gameItemMap , boardMap , callback)
	--[[
	local backItemMap = self.mainLogic.backItemMap
	local backBoardMap = self.mainLogic.backBoardMap
	local allSeaAnimals_back = self.mainLogic.gameMode.allSeaAnimals_back
	if not allSeaAnimals_back then allSeaAnimals_back = {} end
	count = self:__tryCollect( allSeaAnimals_back , backItemMap , backBoardMap , callback)
	]]
	return count
end

