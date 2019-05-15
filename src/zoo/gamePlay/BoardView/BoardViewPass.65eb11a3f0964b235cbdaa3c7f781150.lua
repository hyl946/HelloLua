-------显示界面的传送优化------

BoardViewPass = class{}



-----执行动作---将某个sprite传给另一个数据结构进行管理----
function BoardViewPass:runAllAction(boardView)
	if boardView and boardView.gameBoardLogic and boardView.gameBoardLogic.fallingActionList then
		--[[
		local actionList = boardView.gameBoardLogic.fallingActionList
		--printx( 1 , "   BoardViewPass:runAllAction  ++++++++++++++++++++++++++++++++++++++++++++++++")
		for k,v in pairs(actionList) do
			--printx( 1 , "    BoardViewPass:runAllAction   " , k , v.actionType)
			if v.actionTarget == GameActionTargetType.kGameItemAction then 				----判断Item的变化，进行物体的传递
				BoardViewPass:runGameItemActionPass(boardView, v)
			end
		end
		--printx( 1 , "   BoardViewPass:runAllAction  ---------------------------------------------------")
		]]


		local actionList = boardView.gameBoardLogic.fallingActionList
		local maxIndex = table.maxn(actionList)
		for i = 1 , maxIndex do
			local atc = actionList[i]
			if atc then
				if atc.actionTarget == GameActionTargetType.kGameItemAction then 				----判断Item的变化，进行物体的传递
					BoardViewPass:runGameItemActionPass(boardView, atc)
				end
			end
		end
	end
end

----Item动作的传球计算<从一个item把Sprite传给另外一个>
function BoardViewPass:runGameItemActionPass(boardView, theAction)
	if theAction.actionType == GameItemActionType.kItemFalling_UpDown then					----上方掉落
		if theAction.addInfo == "Pass" then
			BoardViewPass:runGameItemActionPassFallingUpDown(boardView, theAction)			
		end
	elseif theAction.actionType == GameItemActionType.kItemFalling_LeftRight then			----斜向掉落
		if theAction.addInfo == "Pass" then
			BoardViewPass:runGameItemActionPassFallingLeftRight(boardView, theAction)			
		end
	elseif theAction.actionType == GameItemActionType.kItemFalling_Product then				----生成物品
		if theAction.addInfo == "Pass" then
			BoardViewPass:runGameItemActionPassFallingProductItem(boardView, theAction)
		end			
		-- if theAction.addInfo == "over" and GamePlayConfig_Product_As_Clipping then
			-- BoardViewPass:runGameItemActionPassFallingProductItemOver(boardView, theAction)			
		-- end
	elseif theAction.actionType == GameItemActionType.kItemFalling_Pass then				----穿越通道
		if theAction.addInfo == "Pass" then
			BoardViewPass:runGameItemActionPassFallingPass(boardView, theAction)		
		end
		-- if theAction.addInfo == "over" then
			-- BoardViewPass:runGameItemActionPassFallingPassOver(boardView, theAction);
		-- end
	elseif theAction.actionType == GameItemActionType.kItemSpecial_Color then				----鸟和其他交换
		if theAction.addInfo == "Pass" then
			BoardViewPass:runGameItemActionPassBirdColorSwap(boardView, theAction)			
		end
	elseif theAction.actionType == GameItemActionType.kItemSpecial_ColorLine then			----鸟和其他交换
		if theAction.addInfo == "Pass" then
			BoardViewPass:runGameItemActionPassBirdColorSwap(boardView, theAction)			
		end	
	elseif theAction.actionType == GameItemActionType.kItemSpecial_ColorWrap then
		if theAction.addInfo == "Pass" then
			BoardViewPass:runGameItemActionPassBirdColorSwap(boardView, theAction)			
		end	
	elseif theAction.actionType == GameItemActionType.kItemSpecial_ColorColor_part1 then			----鸟鸟交换
		if theAction.addInfo == "Pass" then
			BoardViewPass:runGameItemActionPassBirdBirdSwap(boardView, theAction)			
		end	
	end
end

function BoardViewPass:runGameItemActionPassFallingUpDown(boardView, theAction)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y

	local item1 = boardView.baseMap[r1][c1] 		----掉出方块
	local item2 = boardView.baseMap[r2][c2]			----掉入方块

	local data1 = boardView.gameBoardLogic.gameItemMap[r1][c1] 		----掉出方块
	local data2 = boardView.gameBoardLogic.gameItemMap[r2][c2]		----掉入方块

	for i = 1, #ItemSpriteCanFallingDownLayers do
		local layerType = ItemSpriteCanFallingDownLayers[i]

		if item1.itemSprite[layerType] then
			item2:removeItemSpriteGameItem()
			item2.itemSprite[layerType] = item1.itemSprite[layerType]
			item1.itemSprite[layerType] = nil
			break
		end
	end

	if item1.itemSprite[ItemSpriteType.kFurBall] then
		item2.itemSprite[ItemSpriteType.kFurBall] = item1.itemSprite[ItemSpriteType.kFurBall]
		item1.itemSprite[ItemSpriteType.kFurBall] = nil
		item2.oldData.furballLevel = data2.furballLevel
		item2.oldData.furballType = data2.furballType
	end

	----修改显示数据不会重新再生成
	item2.oldData.ItemType = data2.ItemType
	item2.oldData._encrypt.ItemColorType = data2._encrypt.ItemColorType
	item2.oldData.ItemSpecialType = data2.ItemSpecialType
	item2.itemShowType = item1.itemShowType
end

function BoardViewPass:runGameItemActionPassFallingLeftRight(boardView, theAction)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y

	local item1 = boardView.baseMap[r1][c1] 		----掉出方块
	local item2 = boardView.baseMap[r2][c2]			----掉入方块
	local data1 = boardView.gameBoardLogic.gameItemMap[r1][c1] 		----掉出方块
	local data2 = boardView.gameBoardLogic.gameItemMap[r2][c2]		----掉入方块

	for i = 1, #ItemSpriteCanFallingDownLayers do
		local layerType = ItemSpriteCanFallingDownLayers[i]

		if item1.itemSprite[layerType] then
			item2:removeItemSpriteGameItem()
			item2.itemSprite[layerType] = item1.itemSprite[layerType]
			item1.itemSprite[layerType] = nil
			
			item2.oldData.ItemType = data2.ItemType
			item2.oldData._encrypt.ItemColorType = data2._encrypt.ItemColorType
			item2.oldData.ItemSpecialType = data2.ItemSpecialType
			item2.itemShowType = item1.itemShowType
			break
		end
	end

	if item1.itemSprite[ItemSpriteType.kFurBall] then
		item2.itemSprite[ItemSpriteType.kFurBall] = item1.itemSprite[ItemSpriteType.kFurBall]
		item1.itemSprite[ItemSpriteType.kFurBall] = nil

		item2.oldData.furballLevel = data2.furballLevel
		item2.oldData.furballType = data2.furballType
	end
end

------生成一个新的东西
function BoardViewPass:runGameItemActionPassFallingProductItem(boardView, theAction)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y

	local item1 = boardView.baseMap[r1][c1] 		----生成位置
	local data1 = boardView.gameBoardLogic.gameItemMap[r1][c1] 		----生成位置

	--------开始生成---------
	item1:FallingDataIntoClipping(data1) 			----生成对应的Item

	if item1.itemSprite[ItemSpriteType.kItem] then
		item1.itemSprite[ItemSpriteType.kItemShow] = nil
	elseif item1.itemSprite[ItemSpriteType.kItemShow] then
		item1.itemSprite[ItemSpriteType.kItem] = nil
	end

	----这时候数据已经加载过去了，这里内部传递一下，就不会再重新生成animal的sprite了
	item1.oldData.ItemType = data1.ItemType
	item1.oldData._encrypt.ItemColorType = data1._encrypt.ItemColorType
	item1.oldData.ItemSpecialType = data1.ItemSpecialType

    --add by zhigang.niu 掉落之后olddata等级属性要继承 要不clipping不好使
    item1.oldData.wanShengLevel = data1.wanShengLevel
    item1.oldData.missileLevel = data1.missileLevel
    item1.oldData.honeyBottleLevel = data1.honeyBottleLevel
end

function BoardViewPass:runGameItemActionPassFallingProductItemOver(boardView, theAction)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y

	local item1 = boardView.baseMap[r1][c1] 		----生成位置
	local item2 = boardView.baseMap[r2][c2]			----下面方块
	local data1 = boardView.gameBoardLogic.gameItemMap[r1][c1] 		----生成位置
	local data2 = boardView.gameBoardLogic.gameItemMap[r2][c2]		----下面方块
	
	if (data1.dataReach) then
		item1:takeClippingNodeToSprite(data1)
	end
end

function BoardViewPass:runGameItemActionPassFallingPass(boardView, theAction)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y

	local item1 = boardView.baseMap[r1][c1] 		----掉出方块
	local item2 = boardView.baseMap[r2][c2]			----掉入方块
	local data1 = boardView.gameBoardLogic.gameItemMap[r1][c1] 		----掉出方块
	local data2 = boardView.gameBoardLogic.gameItemMap[r2][c2]		----掉入方块

	item2:FallingDataIntoClipping(data2)
	item2.isNeedUpdate = true

	item1:FallingDataOutOfClipping(data2)
	item1.isNeedUpdate = true

	----这时候数据已经加载过去了，这里内部传递一下，就不会再重新生成animal的sprite了
	item2.oldData.ItemType = data2.ItemType
	item2.oldData._encrypt.ItemColorType = data2._encrypt.ItemColorType
	item2.oldData.ItemSpecialType = data2.ItemSpecialType
	item2.itemShowType = item1.itemShowType
end

function BoardViewPass:runGameItemActionPassFallingPassOver(boardView, theAction)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y

	local item1 = boardView.baseMap[r1][c1] 		----生成位置
	local item2 = boardView.baseMap[r2][c2]			----下面方块
	local data1 = boardView.gameBoardLogic.gameItemMap[r1][c1] 		----生成位置
	local data2 = boardView.gameBoardLogic.gameItemMap[r2][c2]		----下面方块

	if (data2.dataReach) then
		item2:takeClippingNodeToSprite(data2)
		-- item1:cleanClippingSpriteOfItem()
		item1:cleanEnterClippingSpriteOfItem()
	end

	item1.isNeedUpdate = true;
	item2.isNeedUpdate = true;
end

function BoardViewPass:runGameItemActionPassBirdColorSwap(boardView, theAction)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y

	local item1 = boardView.baseMap[r1][c1] 		----鸟
	local item2 = boardView.baseMap[r2][c2]			----颜色

	local sprite11 = item1.itemSprite[ItemSpriteType.kItem];
	local sprite12 = item1.itemSprite[ItemSpriteType.kItemShow];
	local sprite21 = item2.itemSprite[ItemSpriteType.kItem];
	local sprite22 = item2.itemSprite[ItemSpriteType.kItemShow];
	-------交换sprite------
	if sprite11 then
		item2.itemSprite[ItemSpriteType.kItem] = sprite11;
		item2.itemSprite[ItemSpriteType.kItemShow] = nil;
	elseif sprite12 then
		item2.itemSprite[ItemSpriteType.kItem] = nil;
		item2.itemSprite[ItemSpriteType.kItemShow] = sprite12;
	else
		item2.itemSprite[ItemSpriteType.kItem] = nil;
		item2.itemSprite[ItemSpriteType.kItemShow] = nil;
	end

	if sprite21 then
		item1.itemSprite[ItemSpriteType.kItem] = sprite21;
		item1.itemSprite[ItemSpriteType.kItemShow] = nil;
	elseif sprite22 then
		item1.itemSprite[ItemSpriteType.kItem] = nil;
		item1.itemSprite[ItemSpriteType.kItemShow] = sprite22;
	else
		item1.itemSprite[ItemSpriteType.kItem] = nil;
		item1.itemSprite[ItemSpriteType.kItemShow] = nil;
	end

	----修改显示数据不会重新再生成
	local data1 = boardView.gameBoardLogic.gameItemMap[r1][c1] 		----掉出方块
	local data2 = boardView.gameBoardLogic.gameItemMap[r2][c2]		----掉入方块

	----这时候数据已经加载过去了，这里内部传递一下，就不会再重新生成animal的sprite了
	item2.oldData._encrypt.ItemColorType = data2._encrypt.ItemColorType
	item2.oldData.ItemSpecialType = data2.ItemSpecialType
	item2.itemShowType = ItemSpriteItemShowType.kCharacter

	item1.oldData._encrypt.ItemColorType = data1._encrypt.ItemColorType
	item1.oldData.ItemSpecialType = data1.ItemSpecialType
	item1.itemShowType = ItemSpriteItemShowType.kBird
end

function BoardViewPass:runGameItemActionPassBirdBirdSwap(boardView, theAction)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y

	local item1 = boardView.baseMap[r1][c1] 		----鸟
	local item2 = boardView.baseMap[r2][c2]			----颜色

	local sprite11 = item1.itemSprite[ItemSpriteType.kItem];
	local sprite12 = item1.itemSprite[ItemSpriteType.kItemShow];
	local sprite21 = item2.itemSprite[ItemSpriteType.kItem];
	local sprite22 = item2.itemSprite[ItemSpriteType.kItemShow];
	-------交换sprite------
	if sprite11 then
		item2.itemSprite[ItemSpriteType.kItem] = sprite11;
		item2.itemSprite[ItemSpriteType.kItemShow] = nil;
	elseif sprite12 then
		item2.itemSprite[ItemSpriteType.kItem] = nil;
		item2.itemSprite[ItemSpriteType.kItemShow] = sprite12;
	else
		item2.itemSprite[ItemSpriteType.kItem] = nil;
		item2.itemSprite[ItemSpriteType.kItemShow] = nil;
	end

	if sprite21 then
		item1.itemSprite[ItemSpriteType.kItem] = sprite21;
		item1.itemSprite[ItemSpriteType.kItemShow] = nil;
	elseif sprite22 then
		item1.itemSprite[ItemSpriteType.kItem] = nil;
		item1.itemSprite[ItemSpriteType.kItemShow] = sprite22;
	else
		item1.itemSprite[ItemSpriteType.kItem] = nil;
		item1.itemSprite[ItemSpriteType.kItemShow] = nil;
	end

	----修改显示数据不会重新再生成
	local data1 = boardView.gameBoardLogic.gameItemMap[r1][c1] 		----掉出方块
	local data2 = boardView.gameBoardLogic.gameItemMap[r2][c2]		----掉入方块

	----这时候数据已经加载过去了，这里内部传递一下，就不会再重新生成animal的sprite了
	item2.oldData._encrypt.ItemColorType = data2._encrypt.ItemColorType
	item2.oldData.ItemSpecialType = data2.ItemSpecialType
	item2.itemShowType = ItemSpriteItemShowType.kBird

	item1.oldData._encrypt.ItemColorType = data1._encrypt.ItemColorType
	item1.oldData.ItemSpecialType = data1.ItemSpecialType
	item1.itemShowType = ItemSpriteItemShowType.kBird
end
