WanShengLogic = class{}


--------------------
--万生增加一层
--------------------
function WanShengLogic:increaseWanSheng( mainLogic, r, c, times, scoreScale )
	-- body
	scoreScale = scoreScale or 1
	local item = mainLogic.gameItemMap[r][c]
	if item.wanShengLevel + times > 4 then times = 4 - item.wanShengLevel end
    local oldLevel = item.wanShengLevel
	item.wanShengLevel = item.wanShengLevel + times

	ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_LotusBlocker, ObstacleFootprintAction.k_Hit, times)
	
	local incAction = GameBoardActionDataSet:createAs(
	 		GameActionTargetType.kGameItemAction,
	 		GameItemActionType.kItem_WanSheng_increase,
	 		IntCoord:create(r,c),
	 		nil,
	 		GamePlayConfig_MaxAction_time)
	incAction.addInt = times
    incAction.oldLevel = oldLevel
	mainLogic:addDestroyAction(incAction)
end

function WanShengLogic:checkSpecialHitWanSheng(mainLogic, r, c, scoreScale)

    local targetItem = mainLogic.gameItemMap[r][c]
	if targetItem then
		if targetItem.ItemType == GameItemType.kWanSheng then
			WanShengLogic:increaseWanSheng(mainLogic, r, c, 1, scoreScale)
        end
	end
end

function WanShengLogic:checkWanShengBroken( mainLogic, callback )
	-- body
	local gameItemMap = mainLogic.gameItemMap
	local boardMap = mainLogic.boardmap
	--select item to run
	local brokenWanSheng = {}
	local canBeInfectItemList = {}
    local canBeInfectItemList2 = {}
	local subCanBeInfectItemList = {}
	for r = 1, #gameItemMap do 
		for c = 1, #gameItemMap[r] do
			local item = gameItemMap[r][c]
            local board = boardMap[r][c]
			if item then 
				local intCoord = IntCoord:create(r, c)
				if item.wanShengLevel > 3 and item:isAvailable() then
					table.insert(brokenWanSheng, intCoord)
					ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_LotusBlocker, ObstacleFootprintAction.k_Attack, 1)
				elseif item:canInfectByWanSheng() and board:canInfectByWanSheng() then
					if boardMap[r][c].wanshengWrongSelect then 
						table.insert(subCanBeInfectItemList, intCoord)
                    elseif boardMap[r][c].wanshengRightSelect then 
						table.insert(canBeInfectItemList, intCoord)
					else
						table.insert(canBeInfectItemList2, intCoord)
					end
				end
			end 
		end
	end


    --对list进行animal排序 普通小动物 特效 魔力鸟
    local function getSortList( ItemList )

        local NewList = {}
        NewList[1] = {}
        NewList[2] = {}
        NewList[3] = {}

        if #ItemList == 0 then 
            NewList[1] = table.clone(ItemList)
            return NewList 
        end

        for i,v in ipairs(ItemList) do
            local item = gameItemMap[v.x][v.y]

            if item.ItemType == GameItemType.kAnimal then
                
                if item.ItemSpecialType == 0 then
                    table.insert( NewList[1], v )
                elseif item.ItemSpecialType~= AnimalTypeConfig.kColor then
                    table.insert( NewList[2], v )
                else
                    table.insert( NewList[3], v )
                end
            else
                table.insert( NewList[1], v )
            end
        end
        return NewList
    end

    local new_canBeInfectItemList = getSortList(canBeInfectItemList)
    local new_canBeInfectItemList2 = getSortList(canBeInfectItemList2)
    local new_subCanBeInfectItemList = getSortList(subCanBeInfectItemList)
    
    local ForList = { new_canBeInfectItemList[1],
        new_canBeInfectItemList[2], 
        new_canBeInfectItemList[3],
        new_canBeInfectItemList2[1],
        new_canBeInfectItemList2[2],
        new_canBeInfectItemList2[3],
        new_subCanBeInfectItemList[1],
        new_subCanBeInfectItemList[2],
        new_subCanBeInfectItemList[3] }

    --计算扔的位置
	for i, v in pairs(brokenWanSheng) do 
        local item = mainLogic.gameItemMap[v.x][v.y]
        local wanShengConfig = item.wanShengConfig
        local CanChangeNum = item.wanShengConfig.num or 1
        local itemType = wanShengConfig.mType+1

		local infectList = {}
		local createwanshengs = CanChangeNum
		if not createwanshengs then 
			printx( 1 , "   ===================create WanShengChild ===========================   " , CanChangeNum)
			createwanshengs = 1 
		end

		for k = 1, createwanshengs do 
			local item 

            for m,n in ipairs(ForList) do
                if itemType == TileConst.kLock and ( m%3 == 0 ) then 
                else
                    if #n > 0 then
				        item = table.remove(n, mainLogic.randFactory:rand(1, #n))

                        local ItemInfo = {}
                        ItemInfo.item = item
                        ItemInfo.wanShengConfig = table.clone( wanShengConfig )
				        table.insert(infectList, ItemInfo)
                        break
                    end
                end
            end
		end

		local addScore = GamePlayConfigScore.MatchAt_WanSheng
		mainLogic:addScoreToTotal(v.x, v.y, addScore)

		local infectAction = GameBoardActionDataSet:createAs(
	 		GameActionTargetType.kGameItemAction,
	 		GameItemActionType.kItem_WanSheng_Broken,
	 		v,
	 		nil,
	 		GamePlayConfig_MaxAction_time)
		infectAction.infectList = infectList
		infectAction.completeCallback = callback
		mainLogic:addGameAction(infectAction)

		--果酱兼容
		infectAction.SpecialID = mainLogic:addSrcSpecialCoverToList( ccp(v.x,v.y) )
	end

	return #brokenWanSheng
end


function WanShengLogic:getTurretLevel( attr )
    local attList = string.split(attr, '-')
    return tonumber(attList[2])
end

function WanShengLogic:getSunFlaskLevel( attr )
    return tonumber(attr)
end