DropDownMode = class(MoveMode)

function DropDownMode:initModeSpecial(config)
  local mainLogic = self.mainLogic
  local tempingredients = config.ingredients
  mainLogic.ingredientsTotal = tempingredients[1]					----豆荚总数
  local ingredientsScreen = config.numIngredientsOnScreen			----屏幕上数量
  mainLogic.ingredientSpawnDensity = config.ingredientSpawnDensity;	----间隔步数
  if (mainLogic.ingredientSpawnDensity == nil )then
    mainLogic.ingredientSpawnDensity = 5
  end
  if mainLogic.ingredientsProductDropList then
    --if _G.isLocalDevelopMode then printx(0, "mainLogic.ingredientsProductDropList", #mainLogic.ingredientsProductDropList) end
    if #mainLogic.ingredientsProductDropList > 0 then
      local count = mainLogic:getIngredientsOnScreen()
      if count >= config.numIngredientsOnScreen then 
        config.numIngredientsOnScreen = count
        return 
      end
      
      for i = 1, 300 do				
        local rand1 = mainLogic.randFactory:rand(1, #mainLogic.ingredientsProductDropList)
        local board1 = mainLogic.ingredientsProductDropList[rand1]
        local c = board1.x
        local r = board1.y
        --if _G.isLocalDevelopMode then printx(0, "initGameSpecial kDropDown ",r,c) end
        local item = mainLogic.gameItemMap[r][c]
        if item.ItemType ~= GameItemType.kIngredient then
          if item.ItemType == GameItemType.kAnimal and item.ItemSpecialType == 0 then
            count = count + 1
            item.ItemType = GameItemType.kIngredient;
            item._encrypt.ItemColorType = 0
            --item.ItemSpecialType = 0;
          end
        end
        if count >= ingredientsScreen then
          break;
        end
      end
    end
  end
end

function DropDownMode:reachEndCondition()
  return  MoveMode.reachEndCondition(self) or self.mainLogic.ingredientsCount >= self.mainLogic.ingredientsTotal
end

function DropDownMode:reachTarget()
  return self.mainLogic.ingredientsCount >= self.mainLogic.ingredientsTotal;
end

function DropDownMode:saveDataForRevert(saveRevertData)
  local mainLogic = self.mainLogic
  saveRevertData.ingredientsCount = mainLogic.ingredientsCount
  saveRevertData.ingredientsMoveCount = mainLogic.ingredientsMoveCount
  saveRevertData.ingredientsTotalCount = mainLogic.ingredientsTotalCount
  saveRevertData.dropNumCached = mainLogic.dropNumCached
  MoveMode.saveDataForRevert(self,saveRevertData)
end

function DropDownMode:revertDataFromBackProp()
  local mainLogic = self.mainLogic
  mainLogic.ingredientsCount = mainLogic.saveRevertData.ingredientsCount
  mainLogic.ingredientsMoveCount = mainLogic.saveRevertData.ingredientsMoveCount
  mainLogic.ingredientsTotalCount = mainLogic.saveRevertData.ingredientsTotalCount
  mainLogic.dropNumCached = mainLogic.saveRevertData.dropNumCached
  MoveMode.revertDataFromBackProp(self)
end

function DropDownMode:revertUIFromBackProp()
  local mainLogic = self.mainLogic
  local ingred_Left = mainLogic.ingredientsTotal - mainLogic.ingredientsCount
  if mainLogic.PlayUIDelegate then
    mainLogic.PlayUIDelegate:revertTargetNumber(0, 0, ingred_Left)
  end
  MoveMode.revertUIFromBackProp(self)
end

function DropDownMode:checkAllIngredientCount()
  local mainLogic = self.mainLogic
	local countsum = 0
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
			if item.isUsed == true 
				and item.ItemType == GameItemType.kIngredient then
				countsum = countsum + 1
			end
		end
	end
	--if _G.isLocalDevelopMode then printx(0, "checkAllIngredientCount", countsum) end
	--debug.debug()
	return countsum;
end

-- function DropDownMode:afterSwap(r, c)
--   self:tryCollectIngredient(r, c)
-- end

-- function DropDownMode:afterStable(r, c)
--   return self:tryCollectIngredient(r, c)
-- end

-- function DropDownMode:afterChainBreaked(r, c)
--   return self:tryCollectIngredient(r, c)
-- end

-- function DropDownMode:afterColorFilterBBreaked(r, c)
--   return self:tryCollectIngredient(r, c)
-- end

function DropDownMode:checkDropDownCollect(r, c)
  return self:tryCollectIngredient(r, c)
end

function DropDownMode:tryCollectIngredient(r,c)
  local mainLogic = self.mainLogic
	local board1 = mainLogic.boardmap[r][c]
  local result = false
	if board1.isCollector == true and not board1:hasChainInDirection(ChainDirConfig.kDown) and board1.colorFilterBLevel == 0 then
		local item1 = mainLogic.gameItemMap[r][c]
		if item1.ItemType == GameItemType.kIngredient and item1:isVisibleAndFree() then	
      result = true
			-----1.得分				
      item1:AddItemStatus(GameItemStatusType.kDestroy)
      item1.isCollectIngredient = true --爆炸会到导致重复收集
			local addScore = GamePlayConfigScore.DropDownIngredient
      mainLogic:addScoreToTotal(r, c, addScore)

			-----2.收集动画
			local CollectAction = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItem_CollectIngredient,
				IntCoord:create(r,c),
				nil,
      GamePlayConfig_DropDown_Ingredient_DroppingCD)
			CollectAction.addInfo = "Pass"
      CollectAction.itemShowType = item1.showType
			mainLogic:addDestroyAction(CollectAction)
      mainLogic.toBeCollected = mainLogic.toBeCollected + 1

      mainLogic.ingredientsCount = mainLogic.ingredientsCount + 1;
      if mainLogic:getIngredientsOnScreen() < 1 then 
  			ProductItemLogic:shoundCome(mainLogic, GameItemType.kIngredient)
  			ProductItemLogic:resetStep(mainLogic, GameItemType.kIngredient)
      end
		end
	end
  return result
end