require "zoo.gameGuide.GameGuideData"
require 'zoo.gameGuide.IngamePropGuideManager'

GameGuideCheck = class()

function GameGuideCheck:verifyGuideConditions(guides)
	local checkList = {}
	for k, v in pairs(guides) do
		checkList = {}
		if type(v.appear) ~= "table" then
			assert(false, "Illegal appear list! index: "..tostring(k))
			debug.debug()
			return
		end
		if #v.appear <= 0 then
			assert(false, "Empty appear list! index: "..tostring(k))
			debug.debug()
			return
		end
		for i, v in ipairs(v.appear) do
			if not v.type then
				assert(false, "Appear condition without type! index: "..tostring(k))
				debug.debug()
				return
			end
			if checkList[v.type] == true then
				assert(false, "Repeat appear condition in Guides! index: "..tostring(k))
				debug.debug()
				return
			end
			if type(self[v.type]) ~= "function" then
				assert(false, "Unsupported appear type by GameGuide! index/type: "..
					tostring(index)..'/'..tostring(v.type))
				debug.debug()
				return
			end

			checkList[v.type] = true
		end
		checkList = {}
		if type(v.disappear) ~= "table" then
			assert(false, "Illegal disappear list! index: "..tostring(k))
			debug.debug()
			return
		end
		for i, v in ipairs(v.disappear) do
			if not v.type then
				assert(false, "Disappear condition without type! index: "..tostring(k))
				debug.debug()
				return
			end
			if checkList[v.type] == true then
				assert(false, "Repeat disappear condition in Guides! index: "..tostring(k))
				debug.debug()
				return
			end
			if type(self[v.type]) ~= "function" then
				assert(false, "Unsupported disappear type by GameGuide! index/type: "..
					tostring(index)..'/'..tostring(v.type))
				debug.debug()
				return
			end
			checkList[v.type] = true
		end
	end
end

function GameGuideCheck:checkAppear(guide, paras, index)
	if not guide then return false end
	if type(guide.appear) ~= "table" then return false end
	for i, v in ipairs(guide.appear) do
		if type(self[v.type]) == "function" then
			if not self[v.type](self, index, v, paras) and (not GameGuideCheck:isCheckNeedIgnore(index, v.type)) then
				return false
			end
		else
			assert(false, "Unsupported appear type by GameGuide! index/type: "..
				tostring(index)..'/'..tostring(v.type))
		end
	end
	return true
end

function GameGuideCheck:checkDisappear(guide, paras, index)
	if not guide then return false end
	if type(guide.disappear) ~= "table" then return false end
	for i, v in ipairs(guide.disappear) do
		if type(self[v.type]) == "function" then
			if self[v.type](self, index, v, paras) then
				return true
			end
		else
			assert(false, "Unsupported disappear type by GameGuide! index/type: "..
				tostring(index)..'/'..tostring(v.type))
		end
	end
	return false
end

function GameGuideCheck:checkFixedAppears(guide, list, paras, index)
	if not guide then return false end
	
	local checkList = {}
	for i, v in ipairs(list) do
		checkList[v.type] = {condition = v.condition, force = v.force, check = false}
	end

	for i, v in ipairs(guide.appear) do
		if checkList[v.type] then
			checkList[v.type].check = true

			if v.type == "scene" and v.scene == "game" and not v.para then
				return false
			end

			if type(self[v.type]) == "function" then
				if not self[v.type](self, index, v, paras) then
					return false
				end
			else
				assert(false, "Unsupported disappear type by GameGuide! index/type: "..
					tostring(index)..'/'..v.type)
			end
		end
	end

	for k, v in pairs(checkList) do
		if not v.check and v.force then
			return false
		end
	end

	return true
end

function GameGuideCheck:noNewPreProp(index, condition, paras)
	return not GameGuideData:sharedInstance():getNewPreProp()
end

function GameGuideCheck:noPopup(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:noPopup======================++++++++++++++++++++ " , GameGuideData:sharedInstance():getPopups())
	return GameGuideData:sharedInstance():getPopups() <= 0
end

function GameGuideCheck:scene(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:scene======================++++++++++++++++++++ " ,index , condition.para)
	local data = GameGuideData:sharedInstance()
	if condition.scene ~= data:getScene() then return false end
	if condition.scene == "game" then
		if paras and paras.forceLevel and not condition.para then return false end
		if type(condition.para) == "number" and condition.para ~= data:getLevelId() then return false end
		if type(condition.para) == "table" and not table.exist(condition.para, data:getLevelId()) then return false end
	end
	--printx( 1 , "  GameGuideCheck:scene  true")
	return true
end

function GameGuideCheck:minCoin(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:minCoin======================++++++++++++++++++++")
	local coin = UserManager:getInstance().user:getCoin()
	return coin >= condition.para
end

function GameGuideCheck:maxCoin(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:maxCoin======================++++++++++++++++++++")
	local coin = UserManager:getInstance().user:getCoin()
	return coin <= condition.para
end

function GameGuideCheck:userLevelGreatThan(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:userLevelGreatThan======================++++++++++++++++++++")
	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	return topLevelId > condition.para
end

function GameGuideCheck:userLevelLessThan(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:userLevelLessThan======================++++++++++++++++++++")
	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	return topLevelId < condition.para
end

function GameGuideCheck:userLevelEqual(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:userLevelLessThan======================++++++++++++++++++++")
	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	return topLevelId == condition.para
end

function GameGuideCheck:minCurrLevel(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:minCurrLevel======================++++++++++++++++++++")
	local mainLogic = GameBoardLogic:getCurrentLogic()

	if not mainLogic or not mainLogic.level then
		return false
	end
	--printx( 1 , "   mainLogic.level = " , mainLogic.level , "  condition.para = " , condition.para )
	return mainLogic.level >= condition.para
end

function GameGuideCheck:maxCurrLevel(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:maxTopLevel======================++++++++++++++++++++")
	local mainLogic = GameBoardLogic:getCurrentLogic()

	if not mainLogic or not mainLogic.level then
		return false
	end
	return mainLogic.level <= condition.para
end

function GameGuideCheck:continuousFailed(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:continuousFailed======================++++++++++++++++++++")
	local levelId = GameGuideData:sharedInstance():getLevelId()
	if levelId then
		local continuousFailNum = GameGuideData:sharedInstance():getContinuousFailedNum() or 0
		--printx( 1 , "   continuousFailNum = " , continuousFailNum)
		return continuousFailNum >= condition.para
	end
	return false
end

function GameGuideCheck:checkAutoPopout( index, condition, paras )
	local actionCls = _G[condition.para]
	return AutoPopout:checkGuideFlag(actionCls)
end

function GameGuideCheck:usePrePropNum(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:usePrePropNum======================++++++++++++++++++++ " ,index)
	if not GameBoardLogic:getCurrentLogic() then
		return false
	end
	local gameplaysceneui = GameBoardLogic:getCurrentLogic().PlayUIDelegate
	local num = nil
	if gameplaysceneui and gameplaysceneui.selectedItemsData then
		num = #gameplaysceneui.selectedItemsData
	end
	--printx( 1 , "  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	--printx( 1 , "  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	--printx( 1 , "  GameGuideCheck:usePrePropNum " , num)
	local topLevelId = UserManager:getInstance().user:getTopLevelId()

	if condition.para == 1 then
		--printx( 1 , "   GameGuideCheck:usePrePropNum 1" , num > 0)
		return num > 0
	else
		--printx( 1 , "   GameGuideCheck:usePrePropNum 2" , num == 0)
		return num == 0
	end
	--printx( 1 , "   GameGuideCheck:usePrePropNum 3" , false)
	return false
end

function GameGuideCheck:hasPropNum(index, condition, paras)
	
	--[[
	condition.para = { 
				groupType = 2 , group = {
											[1] = {propId = 10071 , num = 0 , op = 2} ,
											[2] = {propId = 10018 , num = 0 , op = 2} ,
											[1] = {propId = 10069 , num = 0 , op = 2} ,
											[2] = {propId = 10007 , num = 0 , op = 2} ,
										} 
			}
	]]
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:hasPropNum======================++++++++++++++++++++" , index)
	if condition.para then
		local groupType = condition.para.groupType
		local group = condition.para.group

		local function check(v)
			local num = UserManager:getInstance():getUserPropNumber(v.propId)
			printx( 1 , "   check  " , v.propId , num , v.op)
			local targetNum = v.num
			if v.op == 1 then
				if num == targetNum then
					return true
				end
			elseif v.op == 2 then
				if num >= targetNum then
					return true
				end
			elseif v.op == 3 then
				if num <= targetNum then
					return true
				end
			end
			return false
		end

		local result = false

		if groupType == 1 then
			result = true

			for k,v in ipairs(group) do
				if not check(v) then
					result = false
					break
				end
			end
		else
			result = false

			for k,v in ipairs(group) do
				if check(v) then
					result = true
					break
				end
			end
		end
		--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:hasPropNum======================++++++++++++++++++++" , result)
		return result
	end
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:hasPropNum======================++++++++++++++++++++" , false)
	return false
end

function GameGuideCheck:firstGuideOnLevel(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:firstGuideOnLevel======================++++++++++++++++++++" , index)
	local mainLogic = GameBoardLogic:getCurrentLogic()
	if mainLogic and mainLogic.level then
		local data = GameGuideData:sharedInstance()
		if data:containInGuideLevelFlag(mainLogic.level) then
			--printx( 1 , "   mainLogic.level = " , mainLogic.level , "  false ")
			return false
		else
			--printx( 1 , "   mainLogic.level = " , mainLogic.level , "  true ")
			return true
		end
	end

	--printx( 1 , "     false ")
	return false
end

function GameGuideCheck:notTimeLevel(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:notTimeLevel======================++++++++++++++++++++")
	local mainLogic = GameBoardLogic:getCurrentLogic()

	if not mainLogic then
		return false
	end
	--printx( 1 , "   mainLogic.theGamePlayType = " , mainLogic.theGamePlayType , "   GameModeTypeId.CLASSIC_ID = " , GameModeTypeId.CLASSIC_ID)
	if mainLogic.theGamePlayType ~= GameModeTypeId.CLASSIC_ID then --GameModeTypeId
		return true
	end

	return false
end

function GameGuideCheck:notUseProp(index, condition, paras)
	
	local data = GameGuideData:sharedInstance()

	local list = condition.para
	local result = true
	for k,v in pairs(list) do
		if data:containInUsePropLog(v) then
			result = false
		end
	end
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:notUseProp======================++++++++++++++++++++" , result)
	return result
end

function GameGuideCheck:hasPropInBar(index, condition, paras)
	local mainLogic = GameBoardLogic:getCurrentLogic()

	if mainLogic and mainLogic.PlayUIDelegate and mainLogic.PlayUIDelegate.propList and mainLogic.PlayUIDelegate.propList.leftPropList then
		local leftPropList = GameBoardLogic:getCurrentLogic().PlayUIDelegate.propList.leftPropList
		local itemFound, itemIndex = leftPropList:findItemByItemID( condition.para )
		if itemFound then
			return true
		end
	end
	return false
end

function GameGuideCheck:hasAvailableEneryBottleToStartLevel(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:hasAvailableEneryBottleToStartLevel======================++++++++++++++++++++ " , index)
	if UserManager:getInstance():getUserPropNumber( ItemType.MIDDLE_ENERGY_BOTTLE ) >= 1 then
		return true
	elseif UserManager:getInstance():getUserPropNumber( ItemType.SMALL_ENERGY_BOTTLE ) >= 5 then
		return true
	end	
	return false
end

function GameGuideCheck:energyConut(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:energyConut======================++++++++++++++++++++ " , index)
	local currEnery = UserManager:getInstance().user:getEnergy()
	if tonumber(condition.para.op) == 1 then
		return currEnery <= tonumber(condition.para.conut)
	else
		return currEnery >= tonumber(condition.para.conut)
	end

	return false
end

function GameGuideCheck:checkMaintenanceEnabled(index, condition, paras)
	return MaintenanceManager:getInstance():isEnabled(condition.para)
end

function GameGuideCheck:checkMaintenanceEnabledInGroup(index, condition, paras)
	return MaintenanceManager:getInstance():isEnabledInGroup(condition.para.mname , condition.para.key , UserManager:getInstance().uid )
end

function GameGuideCheck:hasNoOperation(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:hasNoOperation======================++++++++++++++++++++")
	local data = GameGuideData:sharedInstance()
	local time1 = tonumber(data:getLastSwapTime())
	local time2 = Localhost:timeInSec()
	--printx( 1 , "   time1 = " , time1 , "  time2 = " , time2)
	return tonumber(time2 - time1) >= 8
end


function GameGuideCheck:hasNoSpecialAnimal(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:hasNoSpecialAnimal======================++++++++++++++++++++")
	local mainLogic = GameBoardLogic:getCurrentLogic()

	if not mainLogic then
		return false
	end

	local checkItem = nil
	local specialAnimalNum = 0
	for r = 1, #mainLogic.gameItemMap do
 		for c = 1, #mainLogic.gameItemMap[r] do
 			checkItem = mainLogic.gameItemMap[r][c]
 			if checkItem and checkItem.ItemType == GameItemType.kAnimal and checkItem.ItemSpecialType ~= 0 then
 				specialAnimalNum = specialAnimalNum + 1
 			end
 		end
 	end

 	return specialAnimalNum <= 0
end

function GameGuideCheck:tagetLeft(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:tagetLeft======================++++++++++++++++++++")
	local mainLogic = GameBoardLogic:getCurrentLogic()
	if not mainLogic then
		return false
	end

	local totalTargetLeft = 0
	
	if mainLogic.theOrderList and #mainLogic.theOrderList > 0 then
		for i,v in ipairs(mainLogic.theOrderList) do
	        totalTargetLeft = totalTargetLeft + (v.v1 - v.f1)
	    end
	    --printx( 1 , "   totalTargetLeft = " , totalTargetLeft , "   condition.para = " , condition.para)
	    return totalTargetLeft <= condition.para

	elseif mainLogic.theGamePlayType == GameModeTypeId.LIGHT_UP_ID and mainLogic.kLightUpLeftCount then
		--printx( 1 , "   kLightUpLeftCount = " , mainLogic.kLightUpLeftCount , "   condition.para = " , condition.para)
		return mainLogic.kLightUpLeftCount <= condition.para

	elseif mainLogic.theGamePlayType == GameModeTypeId.DIG_MOVE_ID and mainLogic.digJewelLeftCount then
		--printx( 1 , "   digJewelLeftCount = " , mainLogic.digJewelLeftCount , "   condition.para = " , condition.para)
		return mainLogic.digJewelLeftCount <= condition.para

	elseif mainLogic.theGamePlayType == GameModeTypeId.DROP_DOWN_ID and mainLogic.ingredientsTotal and mainLogic.ingredientsCount then
		local leftIngredients = mainLogic.ingredientsTotal - mainLogic.ingredientsCount
		--printx( 1 , "   leftIngredients = " , leftIngredients , "   condition.para = " , condition.para)
		return leftIngredients <= condition.para
	else

	end
	--printx( 1 , "   false    condition.para = " , condition.para)
    return false
end

function GameGuideCheck:numMoveLeft(index, condition, paras)
	
	local mainLogic = GameBoardLogic:getCurrentLogic()
	if not mainLogic or not condition.para or type(condition.para) ~= "table" or #condition.para ~= 2 then
		--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:numMoveLeft======================++++++++++++++++++++" , "not mainLogic" , false , table.tostring(condition) )
		return false
	end

	local tar = condition.para[1]
	local op = condition.para[2]
	--printx( 1 , "   tar = " , tar , "  op = " , op , "   mainLogic.theCurMoves = " , mainLogic.theCurMoves)
	if op == 1 then
		--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:numMoveLeft======================++++++++++++++++++++" , mainLogic.theCurMoves <= tar)
		return mainLogic.theCurMoves <= tar
	else
		--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:numMoveLeft======================++++++++++++++++++++" , mainLogic.theCurMoves >= tar)
		return mainLogic.theCurMoves >= tar
	end
end

function GameGuideCheck:gameLevelType(index, condition, paras)
	local mainLogic = GameBoardLogic:getCurrentLogic()
	if not mainLogic then
		--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:gameLevelType======================++++++++++++++++++++" , false)
		return false
	end
	
	local list = condition.para
	local result = false
	for k,v in pairs(list) do
		if mainLogic.levelType == v then --GameLevelType
			--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:gameLevelType======================++++++++++++++++++++  true " , mainLogic.theGamePlayType)
			result = true
		end
	end

	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:gameLevelType======================++++++++++++++++++++ false " , mainLogic.theGamePlayType)
	return result
end

function GameGuideCheck:notGameLevelType(index, condition, paras)
	local mainLogic = GameBoardLogic:getCurrentLogic()
	if not mainLogic then
		--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:notGameLevelType======================++++++++++++++++++++" , false)
		return false
	end
	
	local list = condition.para
	local result = true
	for k,v in pairs(list) do
		if mainLogic.levelType == v then --GameLevelType
			--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:notGameLevelType======================++++++++++++++++++++  true " , mainLogic.levelType , v)
			result = false
		end
	end

	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:notGameLevelType======================++++++++++++++++++++ false " , mainLogic.levelType)
	return result
end

function GameGuideCheck:gameModeType(index, condition, paras)
	local mainLogic = GameBoardLogic:getCurrentLogic()
	if not mainLogic then
		--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:gameModeType======================++++++++++++++++++++" ,index, false)
		return false
	end
	
	local list = condition.para
	local result = false
	for k,v in pairs(list) do
		if mainLogic.theGamePlayType == v then --GameModeTypeId
			--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:gameModeType======================++++++++++++++++++++  true " ,index, mainLogic.theGamePlayType)
			result = true
		end
	end

	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:gameModeType======================++++++++++++++++++++ " ,index, mainLogic.theGamePlayType)
	return result
end

function GameGuideCheck:levelOrder(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:levelOrder======================++++++++++++++++++++")
	local mainLogic = GameBoardLogic:getCurrentLogic()

	if not mainLogic then
		return false
	end	
	local totalTargetLeft = 0
	if mainLogic.theOrderList and #mainLogic.theOrderList then
		--printx( 1 , "  mainLogic.theOrderList = " , table.tostring(mainLogic.theOrderList) )
		for i,v in ipairs(mainLogic.theOrderList) do
			--printx( 1 , "  v = " , v.key1 ,v.key2 , v.v1 , v.v2)
	        --totalTargetLeft = totalTargetLeft + (v.v1 - v.f1)
	        if condition and condition.para then
	        	for k1,v1 in pairs(condition.para) do
	        		if v.key1 == v1.key1 and v.key2 == v1.key2 then
	        			return true
	        		end
	        	end
	        end
	        --[[
	        if v.key1 == GameItemOrderType.kSpecialTarget and v.key2 == GameItemOrderType_ST.kVenom then

	        end
	        ]]
	    end
	end

	return false
end

function GameGuideCheck:notLevelOrder(index, condition, paras)
	local mainLogic = GameBoardLogic:getCurrentLogic()

	if not mainLogic then
		return true
	end	
	local totalTargetLeft = 0
	if mainLogic.theOrderList and #mainLogic.theOrderList then
		for i,v in ipairs(mainLogic.theOrderList) do
	        if condition and condition.para then
	        	for k1,v1 in pairs(condition.para) do
	        		if v.key1 == v1.key1 and v.key2 == v1.key2 then
	        			return false
	        		end
	        	end
	        end
	    end
	end

	return true
end

function GameGuideCheck:hasBrid(index, condition, paras)
	local mainLogic = GameBoardLogic:getCurrentLogic()
	
	if not mainLogic then
		--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:hasBrid======================++++++++++++++++++++" , false)
		return false
	end

	local function checkNearby( r , c , checkType)
		local checkItem = nil
		local rlt = true

		if mainLogic.gameItemMap[r] and mainLogic.gameItemMap[r][c] then
			checkItem = mainLogic.gameItemMap[r][c]
		end

		if checkType == 1 then
			if checkItem and checkItem.ItemType == GameItemType.kAnimal and checkItem.ItemSpecialType ~= 0 then
				rlt = false
			end
		else
			if not checkItem or  not mainLogic:canUseLineBrush(r,c) or not mainLogic:isItemCanMoved(r,c) then
				rlt = false
			end
		end

		return rlt
	end

 	if condition.para and type(condition.para) == "table" and #condition.para >= 2 then

 		local compareType = condition.para[2] or 1
	 	local tar = condition.para[1] or 0
	 	local hasNoSpecialNearby = condition.para[3] or 0
	 	local canUseLineBrushNearby = condition.para[4] or 0

	 	local checkItem = nil
		local specialAnimalNum = 0
		local falseNum = 0
		for r = 1, #mainLogic.gameItemMap do
	 		for c = 1, #mainLogic.gameItemMap[r] do
	 			checkItem = mainLogic.gameItemMap[r][c]
	 			if checkItem and checkItem.ItemType == GameItemType.kAnimal and checkItem.ItemSpecialType == AnimalTypeConfig.kColor then

	 				local canadd = true

	 				if hasNoSpecialNearby == 1 then
	 					if not checkNearby( r , c + 1 , 1) 
		 					or not checkNearby( r , c - 1 , 1) 
		 					or not checkNearby( r + 1, c , 1) 
		 					or not checkNearby( r - 1 , c , 1) then
	 						canadd = false
	 					end
	 				end

	 				if canadd and canUseLineBrushNearby == 1 then
	 					if not checkNearby( r , c + 1 , 2) 
		 					and not checkNearby( r , c - 1 , 2) 
		 					and not checkNearby( r + 1, c , 2) 
		 					and not checkNearby( r - 1 , c , 2) then
		 					canadd = false
	 					end
	 				end

	 				if canadd then
	 					specialAnimalNum = specialAnimalNum + 1
	 				else
	 					falseNum = falseNum + 1
	 				end
	 			end
	 		end
	 	end

 		if compareType == 1 then
 			--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:hasBrid======================++++++++++++++++++++  111  " , specialAnimalNum , condition.para[1] , specialAnimalNum <= condition.para[1])
 			return specialAnimalNum <= tar and falseNum == 0
 		else
 			--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:hasBrid======================++++++++++++++++++++  222  " , specialAnimalNum , condition.para[1] , specialAnimalNum >= condition.para[1])
 			return specialAnimalNum >= tar and falseNum == 0
 		end
 	end
 	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:hasBrid======================++++++++++++++++++++" , false)
 	return false
end

function GameGuideCheck:hasVenom(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:hasVenom======================++++++++++++++++++++")
	local mainLogic = GameBoardLogic:getCurrentLogic()

	if not mainLogic then
		return false
	end

	local checkItem = nil
	local specialAnimalNum = 0
	for r = 1, #mainLogic.gameItemMap do
 		for c = 1, #mainLogic.gameItemMap[r] do
 			checkItem = mainLogic.gameItemMap[r][c]
 			if checkItem and checkItem.ItemType == GameItemType.kVenom then
 				specialAnimalNum = specialAnimalNum + 1
 			end
 		end
 	end

 	return specialAnimalNum >= condition.para
end

function GameGuideCheck:venomTooLess(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:venomTooLess======================++++++++++++++++++++")

	local mainLogic = GameBoardLogic:getCurrentLogic()

	if not mainLogic then
		return false
	end

	local checkItem = nil
	local venomNum = 0
	for r = 1, #mainLogic.gameItemMap do
 		for c = 1, #mainLogic.gameItemMap[r] do
 			checkItem = mainLogic.gameItemMap[r][c]
 			if checkItem and checkItem.ItemType == GameItemType.kVenom then
 				venomNum = venomNum + 1
 			end
 		end
 	end
 	local tarnum = 0
 	if mainLogic.theOrderList and #mainLogic.theOrderList then
		for i,v in ipairs(mainLogic.theOrderList) do
	        if v.key1 == GameItemOrderType.kSpecialTarget and v.key2 == GameItemOrderType_ST.kVenom then
	        	tarnum = v.v1 - v.f1
	        	--printx( 1 , "   tttttt    v.f1 = " , v.f1 , "  v.v1 = " , v.v1 , "  v.v2 = " , v.v2)
	        end
	    end
	end
	--printx( 1 , "  venomNum = " , venomNum , "  mainLogic.theCurMoves = " , mainLogic.theCurMoves , "  tarnum = " , tarnum)
 	return venomNum + mainLogic.theCurMoves < tarnum
end

function GameGuideCheck:hasExpiringTimeProp(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:hasExpiringTimeProp======================++++++++++++++++++++ "  ,index)
	local mainLogic = GameBoardLogic:getCurrentLogic()
	if mainLogic and mainLogic.PlayUIDelegate and mainLogic.PlayUIDelegate.propList and mainLogic.PlayUIDelegate.propList.leftPropList then
		local leftPropList = mainLogic.PlayUIDelegate.propList.leftPropList
		local timeProp , propIndex = leftPropList:findOneTimeProp()

		if timeProp and timeProp.prop:getRecentTimePropLeftTime() < 3600*4 then
			if timeProp.prop.itemId == ItemType.OCTOPUS_FORBID and self:levelOrder(1, { para={ [1] = {key1=4,key2=3} } }, nil) then
				--printx( 1 , "   111")
				return false
			else
				--printx( 1 , "   222")
				return true
			end
		end
	end
	--printx( 1 , "   333")
	return false
end



function GameGuideCheck:bossBlood(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:bossBlood======================++++++++++++++++++++" , index)
	local mainLogic = GameBoardLogic:getCurrentLogic()

	if not mainLogic then
		--printx( 1 , "   false")
		return false
	end

	local checkItem = nil
	local bossList = {}
	for r = 1, #mainLogic.gameItemMap do
 		for c = 1, #mainLogic.gameItemMap[r] do
 			checkItem = mainLogic.gameItemMap[r][c]
 			if checkItem and checkItem.ItemType == GameItemType.kBoss and checkItem.blood then
 				--printx( 1 , "   WTF !!!!!!!!!!!!!!!!!!    " , r , c)
 				table.insert( bossList , checkItem )
 			end
 		end
 	end

 	if condition.para and type(condition.para) == "table" and #condition.para == 2 then
 		local minBlood = condition.para[1]
	 	local maxBlood = condition.para[2]
	 	if #bossList > 0 then
	 		for k,v in ipairs(bossList) do
	 			--printx( 1 , " ------------------ BOSS BLOOD ------------------------- " , v.blood , minBlood , maxBlood)
	 			if v.blood and v.blood >= minBlood and v.blood <= maxBlood then
	 				--printx( 1 , "   true")
	 				return true
	 			end
	 		end
	 	end
 	end
 	--printx( 1 , "   false")
 	return false
end

function GameGuideCheck:scrollRowCloud(index, condition, paras)
	local mainLogic = GameBoardLogic:getCurrentLogic()
	if not mainLogic then return false end
	if mainLogic.passedRow and mainLogic.passedRow > 0 then 
		local digItemMap = mainLogic.digItemMap
		local minRow = condition.para[1]
 		local maxRow = condition.para[2]
        for r = 1, #digItemMap do
            for c = 1, 9 do
                local item = digItemMap[r][c]
                if item.randomPropGuide then
                    local rowDelta = r - mainLogic.passedRow
                    if rowDelta >= minRow and rowDelta <= maxRow then 
                    	local guideInfo = Guides[index]
                    	if guideInfo then 
                    		local action = guideInfo.action[1]
                    		if action then 
                    			action.rowDelta = rowDelta
								action.itemId = item.randomPropDropId
								return true
                    		end
                    	end             
                    end
                end
            end
        end
	end
	return false
end

function GameGuideCheck:hasNoOtherGuide(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:hasNoOtherGuide======================++++++++++++++++++++" , index)
	
	local mainLogic = GameBoardLogic:getCurrentLogic()

	if mainLogic and mainLogic.level then
		local level = mainLogic.level
		local guideIndex = index
		--printx( 1 , "    GameGuideCheck:hasNoOtherGuide   index = " , index)

		for k,v in pairs(Guides) do
			if v.appear then
				for k1,v1 in pairs(v.appear) do
					if v1.type == "scene" and v1.scene == "game" and v1.para and v1.para == level then
						if k ~= guideIndex then
							--printx( 1 , "   GameGuideCheck:hasNoOtherGuide  false " , k)
							return false
						end
					end
				end
			end
		end
	end
	
	--printx( 1 , "   GameGuideCheck:hasNoOtherGuide  true")
	return true
end

function GameGuideCheck:canSwapArea(index, condition, paras)
	local mainLogic = GameBoardLogic:getCurrentLogic()

	if not mainLogic then
		return false
	end

	local checkItem = nil
	local animalNum = 0
	for r = 1, #mainLogic.gameItemMap do
 		for c = 1, #mainLogic.gameItemMap[r] do
 			checkItem = mainLogic.gameItemMap[r][c]
 			-- if checkItem and checkItem.ItemType == GameItemType.kAnimal and checkItem.ItemSpecialType ~= AnimalTypeConfig.kColor then
 			-- 	animalNum = animalNum + 1
 			-- end
 			if checkItem and RefreshItemLogic.isItemRefreshable(checkItem) then
 				animalNum = animalNum + 1
 			end
 		end
 	end

 	return animalNum >= 10
end

function GameGuideCheck:notSpringItemGuide(index, condition, paras)

	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:notSpringItemGuide======================++++++++++++++++++++" , index)
	local playUI = Director:sharedDirector():getRunningScene()
	if playUI and playUI.propList then
		local springItem = playUI.propList:findSpringItem()
		if springItem and springItem.animPlaying then
			--printx( 1 , "    false " , springItem.animPlaying)
			return false
		end
	end
	--printx( 1 , "    true ")
	return true
end

function GameGuideCheck:gamePlayStatus(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:gamePlayStatus======================++++++++++++++++++++" , index)
	local mainLogic = GameBoardLogic:getCurrentLogic()

	if not mainLogic then
		--printx( 1 , "    fasle ")
		return false
	end

	if condition and condition.para and type(condition.para) == "table" then
		for k,v in pairs(condition.para) do
			--printx( 1 , "   v = " , v , "  mainLogic.theGamePlayStatus = " , mainLogic.theGamePlayStatus)
			if v and v == mainLogic.theGamePlayStatus then
				--printx( 1 , "    true " , mainLogic.theGamePlayStatus)
				return true
			end 
		end
	end
	--printx( 1 , "    false " , mainLogic.theGamePlayStatus)
	return false
end

function GameGuideCheck:notGamePlayStatus(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:notGamePlayStatus======================++++++++++++++++++++" , index)
	local mainLogic = GameBoardLogic:getCurrentLogic()

	if not mainLogic then
		--printx( 1 , "    fasle ")
		return false
	end

	if condition and condition.para and type(condition.para) == "table" then
		for k,v in pairs(condition.para) do
			if v and v == mainLogic.theGamePlayStatus then
				--printx( 1 , "    fasle " , v , mainLogic.theGamePlayStatus)
				return false
			end 
		end
	end
	--printx( 1 , "    true " , mainLogic.theGamePlayStatus)
	return true
end



function GameGuideCheck:topLevel(index, condition, paras)
	-- if isLocalDevelopMode then
	-- 	return true
	-- end
	if GameGuide:sharedInstance():isRepeatGuide() then
		return true
	end
	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	return topLevelId == condition.para
end

-- actWin.para is now used as levelId@startGamePanel only.
function GameGuideCheck:popup(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:popup======================++++++++++++++++++++ " , index)
	local data = GameGuideData:sharedInstance()
	if not paras then paras = {} end
	if not paras.actWin and data.currPopPanel then
		paras.actWin = data.currPopPanel
	end

	if condition.strictMode then
		if not data.currPopPanel then
			return false
		end
	end
	
	if (data:getPopups() <= 0 and not data.currPopPanel ) or not paras or not paras.actWin then return false end
	if condition.popup and condition.popup ~= paras.actWin.panelName then return false end
	local op = '=='
	if condition.op then
		op = condition.op
	end
	local levelId
	if condition.para then
		levelId = condition.para
	end
	-- op可以不用管<>因为可以把levelId多配1或者少配1实现
	if levelId then
		if op == '==' then
			return paras.actWin.levelId == levelId 
		elseif op == '~=' then
			return paras.actWin.levelId ~= levelId 
		elseif op == '>=' then
			return paras.actWin.levelId >= levelId 
		elseif op == '<=' then 
			return paras.actWin.levelId <= levelId 
		end
	end

	return true
end

function GameGuideCheck:popdown(index, condition, paras)
	return paras and paras.actWin and paras.actWin.panelName == condition.popdown
end

function GameGuideCheck:numMoves(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:numMoves======================++++++++++++++++++++ " , index)
	return GameGuideData:sharedInstance():getNumMoves() == condition.para
end

function GameGuideCheck:minNumMoves(index, condition, paras)
	return GameGuideData:sharedInstance():getNumMoves() >= condition.para
end

function GameGuideCheck:maxNumMoves(index, condition, paras)
	return GameGuideData:sharedInstance():getNumMoves() <= condition.para
end


function GameGuideCheck:startCheckFromServer(index, condition, paras)
	
	local shouldShow = not UserManager.getInstance():hasGuideFlag( index )
	print("function GameGuideCheck:startCheckFromServer index =" , index , shouldShow )
	shouldShow = shouldShow and ( not AutoPopout:isInNextLevelMode() )
	return shouldShow
end

function GameGuideCheck:staticBoard(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:staticBoard======================++++++++++++++++++++ " ,index, GameGuideData:sharedInstance():getGameStable())
	return GameGuideData:sharedInstance():getGameStable()
end

function GameGuideCheck:onceOnly(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:onceOnly======================++++++++++++++++++++ " ,index)
	-- if isLocalDevelopMode then
	-- 	return true
	-- end
	if GameGuide:sharedInstance():isRepeatGuide() then
		return true
	end
	return not GameGuideData:sharedInstance():containInGuidedIndex(index)
end

function GameGuideCheck:customCheck( index, condition, paras )
	-- body
	-- RemoteDebug:uploadLogWithTag('customCheck', 'sssssssss', table.tostring({...}))	
	if condition and type(condition.func) == 'function' then
		return condition.func()
	end
	return false
end

function GameGuideCheck:onceLevel(index, condition, paras)
	--printx( 1 , "    ++++++++++++++++++=============GameGuideCheck:onceLevel======================++++++++++++++++++++ " ,index, GameGuideData:sharedInstance():containInGuideInLevel(index))
	return not GameGuideData:sharedInstance():containInGuideInLevel(index)
end

function GameGuideCheck:onceOnToday(index, condition, paras)

	local guidedOnToday = GameGuideData:sharedInstance():getGuidedOnToday()
	if guidedOnToday and not guidedOnToday["k_" .. tostring(index)] then
		return true
	end
	return false
end

function GameGuideCheck:getItem(index, condition, paras)
	return paras and condition.item == paras.item
end

function GameGuideCheck:curLevelGuided(index, condition, paras)
	for k, v in ipairs(condition.guide) do
		if not GameGuideData:sharedInstance():containInCurLevelGuide(v) then return false end
	end
	return true
end

function GameGuideCheck:button(index, condition, paras)
	return GameGuideData:sharedInstance():containInHomeSceneButton(condition.button)
end

function GameGuideCheck:halloweenBoss(index, condition, paras)
	return GameGuideData:sharedInstance():containInGameFlags("halloweenBossFirstComeout")
end

function GameGuideCheck:goldZongzi(index, condition, paras)
	return GameGuideData:sharedInstance():containInGameFlags("goldZongziAppear")
end

function GameGuideCheck:waitSignal(index, condition, paras)
	return GameGuideData:sharedInstance():containInGameFlags(condition.name) == condition.value
end

function GameGuideCheck:swap(index, condition, paras)
	if type(paras) ~= "table" or table.size(paras) < 2 then return false end
	
	local para1, para2 = paras[1], paras[2]
	if not condition.from or not condition.to then return true end
	if type(para1) ~= "table" or type(para1.x) ~= "number" or type(para1.y) ~= "number" or
		type(para2) ~= "table" or type(para2.x) ~= "number" or type(para2.y) ~= "number" then
		return false
	end
	return (para1.x == condition.from.x and para1.y == condition.from.y and
		para2.x == condition.to.x and para2.y == condition.to.y) or
		(para2.x == condition.from.x and para2.y == condition.from.y and
		para1.x == condition.to.x and para1.y == condition.to.y)
end

function GameGuideCheck:click( index, condition, paras )
	-- body
	if paras and paras.value == "click" then
		return true
	end
	return false
end

function GameGuideCheck:topPassedLevel(index, condition, paras)
	if GameGuide:sharedInstance():isRepeatGuide() then
		return true
	end
	local level = 0
	for k, v in ipairs(UserManager:getInstance():getScoreRef()) do
		if (v.star > 0 or UserManager.getInstance():hasPassedByTrick(v.levelId)) and v.levelId < 10000 and level < v.levelId then level = v.levelId end
	end
	return condition.para == level
end

function GameGuideCheck:passedLevel(index, condition, paras)
	local checkLevel = condition.para
	local result = GameGuideData:sharedInstance():containInPassedLevelIds(tostring(checkLevel)) or false
	return result
end

function GameGuideCheck:notPassedLevel(index, condition, paras)
	local checkLevel = condition.para
	local result = GameGuideData:sharedInstance():containInPassedLevelIds(tostring(checkLevel)) or false
	return not result
end



function GameGuideCheck:usePropId(index, condition, paras)
	for k,v in pairs(condition.para or {}) do
		if GameGuideData:sharedInstance():getUsePropId() == v then
			return true
		end
	end
	return false
end

function GameGuideCheck:notUsePropId(index, condition, paras)
	return not self:usePropId(index, condition, paras)
end

function GameGuideCheck:usePropComplete(index, condition,paras)
	return paras and condition.propId == paras.propId
end

function GameGuideCheck:hasGuide(index, condition, paras)
	for i, v in ipairs(condition.guideArray) do
		if not GameGuideData:sharedInstance():containInGuidedIndex(v) then
			return false
		end
	end
	return true
end

-- index=引导index
-- condition=
--[[[LUA-print] {
  type = "IngamePropGuideManager",
  para = {
    propId = 10001,
    type = "strong",
  },
}]]
-- paras=nil
local STRONG_TYPE = 'strong'
local WEAK_TYPE = 'weak'
local EXTRA_TYPE = 'extra'

function GameGuideCheck:IngamePropGuideManager(index, condition, paras)
	local propId = condition.para.propId
	local type = condition.para.type
	if not propId or (type ~= WEAK_TYPE and type ~= STRONG_TYPE and type ~= EXTRA_TYPE) then
		return false
	end
	local data = GameGuideData:sharedInstance()
	local levelId = data:getLevelId()
	return IngamePropGuideManager:getInstance():checkCondition(propId, type, levelId)
end

function GameGuideCheck:triggerForceSwapSpecial(index, condition, paras)
	return IngamePropGuideManager:getInstance():tryTriggerForceSwapSpecial()
end

function GameGuideCheck:triggerForceSwapIngredient(index, condition, paras)
	return IngamePropGuideManager:getInstance():tryTriggerForceSwapIngredient()
end

function GameGuideCheck:triggerHammer(index, condition, paras)
	return IngamePropGuideManager:getInstance():tryTriggerHammer()
end

function GameGuideCheck:triggerBrush(index, condition, paras)
	return IngamePropGuideManager:getInstance():tryTriggerBrush()
end


-- 为什么是1呢？因为GameGuideCheck不允许同一个引导配两个相同的type
function GameGuideCheck:prePropImproveLogic1(index, condition, paras)
	local func = condition.func or "isNewGuideLogic"
	local expect = condition.expect or false
	if func == "isNewGuideLogic" then
		return PrePropImproveLogic:isNewGuideLogic() == expect
	elseif func == "isNewItemLogic" then
		return PrePropImproveLogic:isNewItemLogic() == expect
	end
	return false
end

-- 为什么是2呢？因为GameGuideCheck不允许同一个引导配两个相同的type
function GameGuideCheck:prePropImproveLogic2(index, condition, paras)
	local func = condition.func or "isNewGuideLogic"
	local expect = condition.expect or false
	if func == "isNewGuideLogic" then
		return PrePropImproveLogic:isNewGuideLogic() == expect
	elseif func == "isNewItemLogic" then
		return PrePropImproveLogic:isNewItemLogic() == expect
	end
	return false
end


function GameGuideCheck:hasItemOnBoard(index, condition, paras)
	local mainLogic = GameBoardLogic:getCurrentLogic()

	if not mainLogic then
		return false
	end

	local itemtype = condition.para

	local checkItem = nil
	local count = 0
	for r = 1, #mainLogic.gameItemMap do
 		for c = 1, #mainLogic.gameItemMap[r] do
 			checkItem = mainLogic.gameItemMap[r][c]
 			if checkItem and checkItem.ItemType == itemtype then
 				count = count + 1
 			end
 		end
 	end

 	return count > 0
end


function GameGuideCheck:isNotNextLevelModel(index, condition, paras)
	return not AutoPopout:isInNextLevelMode()
end

function GameGuideCheck:checkGuideFlag(index, condition, paras)
	local guideFlag = tonumber(condition.para)
	if guideFlag and UserManager:getInstance():hasGuideFlag(guideFlag) then
		return false
	end
	return true
end

function GameGuideCheck:checkGuideFlag1(index, condition, paras)
	local guideFlag = tonumber(condition.para)
	if guideFlag and UserManager:getInstance():hasGuideFlag(guideFlag) then
		return false
	end
	return true
end

function GameGuideCheck:checkSpeedBtn(index, condition, paras)
	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	if topLevelId < 47 then return false end

	local guideFlag1 = kGuideFlags.SpeedBtn_1
	local guideFlag2 = kGuideFlags.SpeedBtn_2

	if not guideFlag1 or not guideFlag2 then return false end

	local hasFirst = UserManager:getInstance():hasGuideFlag(guideFlag1)
	local hasSecond = UserManager:getInstance():hasGuideFlag(guideFlag2)
	if hasFirst and hasSecond then
		return false
	end

	local scene = Director:sharedDirector():getRunningScene()
	if not scene or not scene.gameBoardLogic or scene.gameBoardLogic.theGamePlayType == GameModeTypeId.CLASSIC_ID then
		return false
	end 

	local speedSwitch = GameSpeedManager:getGameSpeedSwitch()
	if speedSwitch ~= 0 then
		return false
	end

	if hasFirst then
		local preTime = CCUserDefault:sharedUserDefault():getStringForKey("speed.btn.guide.time")
		preTime = tonumber(preTime or '0') or 0
		local now = Localhost:timeInSec()
		if (now-preTime)/3600/24 < 7 then
			return false
		end

		local energyState = UserEnergyRecoverManager:sharedInstance():getEnergyState()
		if energyState ~= UserEnergyState.INFINITE then
			return false
		end
	end

	return true
end

function GameGuideCheck:CheckIsHaveMoleWeekWaterBox()
	local mainLogic = GameBoardLogic:getCurrentLogic()

    local result = MoleWeeklyRaceLogic:getVisibleMagicTileLocation(mainLogic)

    if result == nil then
        return false
    end

	return true
end

function GameGuideCheck:CheckIsBossNotAlive()
	local mainLogic = GameBoardLogic:getCurrentLogic()

    if not mainLogic:getMoleWeeklyBossData() and mainLogic:getBossCount() == 1 then
        return true
    else
        return false
    end
end

function GameGuideCheck:CheckIsNotHaveMoleWeekWaterBox()
	local mainLogic = GameBoardLogic:getCurrentLogic()

    local result = MoleWeeklyRaceLogic:getVisibleMagicTileLocation(mainLogic)

    if result == nil then
        return true
    end

	return false
end

function GameGuideCheck:CheckIsBossLifeReinit()
	local mainLogic = GameBoardLogic:getCurrentLogic()

    if mainLogic:getMoleWeeklyBossData() and mainLogic:getBossCount() >= 1 then
        return true
    else
        return false
    end
end

function GameGuideCheck:CheckIsBigSkillFull()
	local playUI = Director:sharedDirector():getRunningScene()
	if playUI and playUI.propList then
		local springItem = playUI.propList:findSpringItem()
		if springItem and springItem.percent >= 1 then
			--printx( 1 , "    false " , springItem.animPlaying)
			return true
		end
	end

    return false
end


function GameGuideCheck:CheckIsBigSkillNotFull()
	local playUI = Director:sharedDirector():getRunningScene()
	if playUI and playUI.propList then
		local springItem = playUI.propList:findSpringItem()
		if springItem and springItem.percent >= 1 then
			--printx( 1 , "    false " , springItem.animPlaying)
			return false
		end
	end

    return true
end

function GameGuideCheck:CheckBossEnergy( percent )
	local playUI = Director:sharedDirector():getRunningScene()
	if playUI and playUI.propList then
		local springItem = playUI.propList:findSpringItem()
		if springItem and springItem.percent >= 1 then
			--printx( 1 , "    false " , springItem.animPlaying)
			return false
		end
	end

    return true
end

function GameGuideCheck:CheckIsSkillShow( index, condition, paras )
    local SkillType = condition.para

    local mainLogic = GameBoardLogic:getCurrentLogic()
	local result = MoleWeeklyRaceLogic:getTargetLocationForGuide( mainLogic, SkillType )

    if result == nil then
        return false
    end

	return true
end

function GameGuideCheck:CheckIsNotTestScene()
    
    local mainLogic = GameBoardLogic:getCurrentLogic()
    if mainLogic.PlayUIDelegate:is(DevTestGamePlayScene) then
        return false
    end

	return true
end
    
function GameGuideCheck:CheckSceneIsHaveBoardView()
    
    local playUI = Director:sharedDirector():getRunningScene()

    if playUI and playUI.gameBoardView then
        return true
    end

	return false
end
    
function GameGuideCheck:CheckSceneIsHaveBoss()
    
    local mainLogic = GameBoardLogic:getCurrentLogic()
    if mainLogic and not mainLogic:getMoleWeeklyBossData() then
        return false
    end

    return true
end
    
function GameGuideCheck:CheckSceneIsInMoleWeekAddFilePanel()
    
    if PopoutManager:sharedInstance():haveWindowOnScreen() then
        local popoutPanel = PopoutManager:sharedInstance():getLastPopoutPanel()

        if popoutPanel.panelName == "MoleWeekAddFivePanel" then
            return true
        end
    end

    return false
end
    
function GameGuideCheck:CheckCanShowFAQ()
    return FAQ:useNewFAQ()
end

function GameGuideCheck:CheckSettingBtnIsCreate()
    local playUI = Director:sharedDirector():getRunningScene()
    if playUI and playUI.settingButton then
        return true
    end

    return false
end

function GameGuideCheck:CheckIsYYB()
    local __isQQ = PlatformConfig:isQQPlatform()
    return __isQQ
end

function GameGuideCheck:CheckIsNotYYB()

    local __isQQ = PlatformConfig:isQQPlatform()

    if __isQQ then
        return false
    else
        return true
    end
end

function GameGuideCheck:addIgnoreCheckTypes(index, checkTypes)
	if not (checkTypes and index) then
		return
	end
	if not GameGuideCheck.ignoreCheckData then
		GameGuideCheck.ignoreCheckData = {}
	end
	if not GameGuideCheck.ignoreCheckData[index] then
		GameGuideCheck.ignoreCheckData[index] = {}
	end
	for _, v in pairs(checkTypes) do
		GameGuideCheck.ignoreCheckData[index][v] = true
	end
	printx(0, "addIgnoreCheckTypes", index, table.tostring(checkTypes))
end

function GameGuideCheck:isCheckNeedIgnore(index, checkType)
	if not GameGuideCheck.ignoreCheckData then
		return false
	end
	if not (checkType and index) then
		return false
	end
	if GameGuideCheck.ignoreCheckData[index] then
		if GameGuideCheck.ignoreCheckData[index]["__all"] or GameGuideCheck.ignoreCheckData[index][checkType] then
			return true
		end
	end
	return false
end

function GameGuideCheck:cleanIgnoreCheckOnGuideComplete(index)
	if not (GameGuideCheck.ignoreCheckData and index) then
		return
	end
	local inIgnore = GameGuideCheck.ignoreCheckData[index] ~= nil
	GameGuideCheck.ignoreCheckData[index] = nil
	if inIgnore then
		printx(0, "cleanIgnoreCheckOnGuideComplete", index)
		printx(0, "left ignoreChecks", table.tostring(GameGuideCheck.ignoreCheckData))
	end
end

function GameGuideCheck:CheckIsSpringFestival2019OpenAndSkillShow()

    local CurCreateRightPropList = SpringFestival2019Manager.getInstance():getCurLevelCreateRightPropList()
    local RightPropListOpen = SpringFestival2019Manager.getInstance():getRightPropListOpen()

    if CurCreateRightPropList and RightPropListOpen then
        return true
    end

    return false
end