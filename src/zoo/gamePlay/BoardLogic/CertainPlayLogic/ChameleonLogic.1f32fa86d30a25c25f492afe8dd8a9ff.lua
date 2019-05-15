ChameleonLogic = class{}

--------检测处理影响变色龙的匹配-------
function ChameleonLogic:checkTransformByEffectMap(mainLogic)
	if not mainLogic.EffectChameleonHelpMap then
		-- printx(11, " = = = = = = NO ChameleonEffect = = = = = = ");
		return
	end

    local gameItemMap = mainLogic.gameItemMap

    -- printx(11, "ChameleonEffectMap:", table.tostring(mainLogic.EffectChameleonHelpMap))
	for r=1, table.maxn(mainLogic.EffectChameleonHelpMap) do
		if mainLogic.EffectChameleonHelpMap[r] and table.maxn(mainLogic.EffectChameleonHelpMap[r]) > 0 then
			for c=1, table.maxn(mainLogic.EffectChameleonHelpMap[r]) do
				-- printx(11, r, c)
				local effectRecord = mainLogic.EffectChameleonHelpMap[r][c];
				-- printx(11, "effectRecord:", effectRecord)
				if effectRecord and #effectRecord > 0 then
					local item = gameItemMap[r][c]

					-- printx(11, "=== Item status ===")
					-- printx(11, r, c, item.ItemType)
					-- printx(11, item:isAvailable())
					-- printx(11, item:hasLock())
					-- printx(11, item:chameleonFreeToTransform() )
					-- printx(11, item.ItemStatus)
					-- printx(11, "===================")
					-- printx(11, not item:hasLock())
					-- printx(11, item.ItemStatus == GameItemStatusType.kItemHalfStable or item.ItemStatus == GameItemStatusType.kNone)

		            if item and item.ItemType == GameItemType.kChameleon 
		            	and item:isAvailable() and not item:hasLock() and item:chameleonFreeToTransform() 
		            	and (item.ItemStatus == GameItemStatusType.kItemHalfStable or item.ItemStatus == GameItemStatusType.kNone)
		            	then

						-- printx(11, "=== Enter pick ===")
		                local colour, special = ChameleonLogic:_pickTransformTargetForChameleon(mainLogic, effectRecord)
		                if special >= 0 then		--可以设定变色啦！
		                	item.nextColour = colour
		                	item.nextSpecial = special

							--mainLogic:checkItemBlock(r,c)
		                	item.isBlock = true
							item.isNeedUpdate = true
							
							local chameleonTransformAction = GameBoardActionDataSet:createAs(
							 		GameActionTargetType.kGameItemAction,
							 		GameItemActionType.kItem_Chameleon_transform,
							 		IntCoord:create(r,c),
							 		nil,
							 		GamePlayConfig_MaxAction_time)
							-- printx(11, "Chameleon add to transform", r, c)
							mainLogic:addDestroyAction(chameleonTransformAction)

							--moved to actionRunner
							--mainLogic:tryDoOrderList(r, c, GameItemOrderType.kOthers, GameItemOrderType_Others.kChameleon, 1)
		                end
		            end
				end
			end
		end
	end

end

--决定变色目标
function ChameleonLogic:_pickTransformTargetForChameleon(mainLogic, candidates)
	--candidates: 列表形式，被几个影响到则记录几次，每个记录为"colour,itemSpecialType"的字符串

	local pickedColour = 0
	local pickedSpecial = -1

	local specialSets = {}
	local normalSets = {}

	for i=1, #candidates do
		local record = candidates[i]
		local special = tonumber(string.split(record, ",")[2])
		if special and special > 1 then
			table.insert(specialSets, record)
		else
			table.insert(normalSets, record)
		end
	end

	local pickedRecord
	if #specialSets > 0 then
		pickedRecord = specialSets[mainLogic.randFactory:rand(1, #specialSets)]
	else
		pickedRecord = normalSets[mainLogic.randFactory:rand(1, #normalSets)]
	end

	pickedSpecial = tonumber(string.split(pickedRecord, ",")[2])
	local pickedColourID = tonumber(string.split(pickedRecord, ",")[1])

	if pickedColourID == 99	then	--水滴的颜色设定序号
		pickedColour = AnimalTypeConfig.kDrip
	else
		pickedColour = AnimalTypeConfig.colorTypeList[pickedColourID]
	end

	-- printx(11, "Picked colourID: ", pickedColourID)
	--printx(11, "Picked colour: ", table.tostring(pickedColour))
	-- printx(11, "Picked special: ", pickedSpecial)
	return pickedColour, pickedSpecial
end

-- 为了动画，需要提前更新转化物视图，同时，顺便更新转化物数据
function ChameleonLogic:initNewItemView(mainLogic, chameleon)
	local r, c = chameleon.y, chameleon.x
	local newItemColour = chameleon.nextColour
	local newItemSpecial = chameleon.nextSpecial

	local newItem = chameleon
	newItem.ItemType = GameItemType.kAnimal
	if newItemColour == AnimalTypeConfig.kDrip then
		newItem.ItemType = GameItemType.kDrip
		newItem.dripState = DripState.kNormal
	end
	newItem.ItemSpecialType = newItemSpecial
	newItem._encrypt.ItemColorType = newItemColour

	local newItemView = mainLogic.boardView.baseMap[r][c]
	newItemView:initByItemData(newItem, true)
	newItemView:upDatePosBoardDataPos(newItem)

	mainLogic.gameItemMap[r][c].isNeedUpdate = true
end

--变色龙销毁动画播放完毕，正式全面转化数据
function ChameleonLogic:onChameleonDemolished(mainLogic, item)

	local r, c = item.y, item.x

	mainLogic:tryDoOrderList(r, c, GameItemOrderType.kOthers, GameItemOrderType_Others.kChameleon, 1)
	GameExtandPlayLogic:doAllBlocker195Collect(mainLogic, r, c, Blocker195CollectType.kChameleon)
	SquidLogic:checkSquidCollectItem(mainLogic, r, c, TileConst.kChameleon)
	-- item:cleanAnimalLikeData()

	--刷新一下视图
	-- ChameleonLogic:initNewItemView(mainLogic, item, false)
	--[[
	local newItemColour = item.nextColour
	local newItemSpecial = item.nextSpecial
	local newItem = item
	newItem.ItemType = GameItemType.kAnimal
	newItem.ItemSpecialType = newItemSpecial
	newItem._encrypt.ItemColorType = newItemColour
	local newItemView = mainLogic.boardView.baseMap[r][c]
	newItemView:initByItemData(newItem)
	newItemView:upDatePosBoardDataPos(newItem)
	-- newItemView:updateByNewItemData(newItem)
	--]]

	item.nextColour = nil
	item.nextSpecial = nil
	if item.ItemType == GameItemType.kDrip then
		item.dripState = DripState.kNormal
	end

	-- mainLogic.gameItemMap[r][c].isNeedUpdate = true
	mainLogic:checkItemBlock(r, c)
	mainLogic:addNeedCheckMatchPoint(r, c)
	mainLogic:setNeedCheckFalling()
	ColorFilterLogic:handleFilter(r, c) 	--即时检测过滤器过滤

	-- printx(11, "+ + + + + + + + + + + + Chameleon transfrom END + + + + + + + + + + + + ")
end