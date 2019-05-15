---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-06-21 15:10:26
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   dan.liang
-- @Last Modified time: 2018-09-11 11:25:33
---------------------------------------------------------------------------------------
require "zoo.gamePlay.mode.HorizontalEndlessMode"

OlympicHorizontalEndlessMode = class(HorizontalEndlessMode)

--local classIndex = 0
local __encryptKeys = {
	olympicWaitSteps = true,
	followAnimalSwoonRound = true,
	frontAnimalColId = true,
	failedByLightPassed = true,
	currIceNum = true,
}
local EncryptData = memory_class_simple(__encryptKeys)

function EncryptData:ctor()
--	classIndex = classIndex + 1
--	self.__class_id = classIndex

	self.olympicWaitSteps = 0
	self.followAnimalSwoonRound = 0
	self.frontAnimalColId = 0
	self.failedByLightPassed = 0
	self.currIceNum = 0
end

function EncryptData:encryptionFunc( key, value )
--	if __encryptKeys[key] then
	assert(__encryptKeys[key])
		if value == nil then value = 0 end
		HeMemDataHolder:setInteger(self:getEncryptKey(key), value)
--		return true
--	end
--	return false
end

function EncryptData:decryptionFunc( key )
--	if __encryptKeys[key] then
	assert(__encryptKeys[key])
		return HeMemDataHolder:getInteger(self:getEncryptKey(key))
--	end
--	return nil
end

function EncryptData:getEncryptKey(key)
	return key .. "_" .. self.__class_id
end

---------------------------------------------------------------------------------------
local kCheckLightStartCol = 2
local kCheckLightEndCol = 3

function OlympicHorizontalEndlessMode:getPlayerGroup()
	local uid = tonumber(UserManager.getInstance().uid) or 12345
	return math.floor( uid / 10 ) % 6 + 1
end

function OlympicHorizontalEndlessMode:initModeSpecial(config)
	HorizontalEndlessMode.initModeSpecial(self, config)

	self.mainLogic.olympicScore = 0

	self.mainLogic.frontAnimalId = self:getPlayerGroup()

	local _tileMap = config.tileMap
	for r = 1, #_tileMap do
		if self.mainLogic.boardmap[r] == nil then self.mainLogic.boardmap[r] = {} end        --地形
		for c = 1, #_tileMap[r] do
		  local tileDef = _tileMap[r][c]
		  self.mainLogic.boardmap[r][c]:initLightUp(tileDef)              
		end
	end

	_tileMap = config.digTileMap
	for r = 1, #_tileMap do
		if self.mainLogic.digBoardMap[r] == nil then self.mainLogic.digBoardMap[r] = {} end        --地形
		for c = 1, #_tileMap[r] do
			local tileDef = _tileMap[r][c]
			self.mainLogic.digBoardMap[r][c]:initLightUp(tileDef)              
		end
	end
	self.encryptData = EncryptData.new()
	self.encryptData.olympicWaitSteps = 0
	self.encryptData.followAnimalSwoonRound = 0
	self.encryptData.frontAnimalColId = 0
	self.encryptData.failedByLightPassed = 0
	self.encryptData.currIceNum = 0
end

function OlympicHorizontalEndlessMode:reachEndCondition()
  return self.encryptData.failedByLightPassed and self.encryptData.failedByLightPassed > 0
end

function OlympicHorizontalEndlessMode:canChangeMoveToStripe()
	return false
end

function OlympicHorizontalEndlessMode:reachTarget()
	return false
end

function OlympicHorizontalEndlessMode:failByRefresh( ... )
	return self:getScoreStarLevel() < 1
end

function OlympicHorizontalEndlessMode:afterFail()
    local function goOn()
    	local mainLogic = self.mainLogic
	    self.encryptData.failedByLightPassed = 0
	    mainLogic:setGamePlayStatus(GamePlayStatus.kNormal)
	    mainLogic.fsm:changeState(mainLogic.fsm.fallingMatchState)
	    
		-- 为了展现效果，将5步加到等待步数上
		-- self:addFollowAnimalSwoonRound(5)
		self:playAddFiveEffect()
		self:updateWaitSteps(self.encryptData.olympicWaitSteps + 5)

		mainLogic.PlayUIDelegate:playAnimalFallDown()

		local action = GameBoardActionDataSet:createAs(
	            GameActionTargetType.kGameItemAction,
	            GameItemActionType.kBombAll_OlympicMode,
	            IntCoord:create(1, 1),
	            IntCoord:create(9, 4),
	            GamePlayConfig_MaxAction_time
	        )
	    mainLogic:addDestructionPlanAction(action)
	    mainLogic:setNeedCheckFalling()

	    mainLogic.PlayUIDelegate:setPauseBtnEnable(true)
	end
	local function giveUp()
		self.mainLogic:setGamePlayStatus(GamePlayStatus.kAferBonus)
	end

	local mainLogic = self.mainLogic
    if mainLogic.PlayUIDelegate then

    	local function popPanel()
    		if not mainLogic or mainLogic.isDisposed then return end

    		require "zoo.panel.endGameProp.EndGamePropOlympicPanel"
    		local lifetimeFlag = true

    		local activityModel = mainLogic.PlayUIDelegate and mainLogic.PlayUIDelegate.activityStageData
    		if activityModel and activityModel.getUsedFreePropFlag then
    			lifetimeFlag = activityModel:getUsedFreePropFlag()
    		end
    		--printx( 1 , "  111 lifetimeFlag = " , lifetimeFlag)

    		if mainLogic.PlayUIDelegate:is(DevTestGamePlayScene) then
	    		--[[
				require "zoo.panel.TwoChoicePanel"
				local panel = TwoChoicePanel:create("使用复活道具继续游戏？", "继续", "放弃")
				panel:setButton1TappedCallback(goOn)
				panel:setButton2TappedCallback(giveUp)
				panel:setCloseButtonTappedCallback(giveUp)
				panel:popout()
				--]]

				--EndGamePropAndroidPanel:create(mainLogic.level, mainLogic.levelType, ItemType.THIRD_ANNIVERSARY_ADD_FIVE, goOn, giveUp, nil)

				----[[
				local panel = EndGamePropOlympicPanel:create(
    					mainLogic.level, mainLogic.levelType, ItemType.THIRD_ANNIVERSARY_ADD_FIVE, goOn, giveUp, nil)
				panel:setCloseBtnEnable()
    			panel:popout()

    			if activityModel and activityModel.setUsedFreePropFlag then
	    			activityModel:setUsedFreePropFlag(true)
	    			--printx( 1 , "  333333333333 model:setLifetimeFlag(true)" , lifetimeFlag)
	    		end
	    		--]]

	    	elseif not lifetimeFlag then

	    		local panel = EndGamePropOlympicPanel:create(
    					mainLogic.level, mainLogic.levelType, ItemType.THIRD_ANNIVERSARY_ADD_FIVE, goOn, giveUp, nil)

    			panel:popout()

    			if activityModel and activityModel.setUsedFreePropFlag then
	    			activityModel:setUsedFreePropFlag(true)
	    		end
	    	else
	    		EndGamePropManager:create(false, mainLogic.level, mainLogic.levelType, ItemType.THIRD_ANNIVERSARY_ADD_FIVE, goOn, giveUp, nil, nil)
	    	end
    	end
    	
    	setTimeOut( popPanel , 2 )
    end
end

function OlympicHorizontalEndlessMode:onGameStart()
	-- self:doCheckHasLightItemToWarnning()
	HorizontalEndlessMode.onGameStart(self)
	self:updateRoadHoles()
	self:addBoardViewEffect()
end

function OlympicHorizontalEndlessMode:addBoardViewEffect()
	local boardView = self.mainLogic.boardView
	if not boardView.olympicBoardEffectBatch then
		local olympicBoardEffectBatch = CocosObject:create()
		olympicBoardEffectBatch:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/autumn2018/mid_autumn_ani_res.png"),9))
		boardView.olympicBoardEffectBatch = olympicBoardEffectBatch
		boardView:addChild(olympicBoardEffectBatch)

		local startRowIndex = boardView.startRowIndex
		local startColIndex = boardView.startColIndex
		local colCount = boardView.colCount
		local rowCount = boardView.rowCount
		for i = 1, rowCount do
			local effect, animate2 = SpriteUtil:buildAnimatedSprite(1/24, "ZQ_move_arrow_%04d", 0, 39)
			effect:play(animate2, 0, 0)
			-- effect:setPosition(ccp(GamePlayConfig_Tile_Width*(startColIndex+colCount-1), GamePlayConfig_Tile_Height*(10-startRowIndex-i+0.5)))
			effect:setPosition(ccp(25, GamePlayConfig_Tile_Height*(10-startRowIndex-i+0.5) + 10))
			olympicBoardEffectBatch:addChild(effect)
		end
	end
end

function OlympicHorizontalEndlessMode:onGameInit()
	HorizontalEndlessMode.onGameInit(self)
	-- if self.mainLogic.PlayUIDelegate then
		-- self.mainLogic.PlayUIDelegate.moveOrTimeCounter:setVisible(true)
		-- self.mainLogic.PlayUIDelegate.moveOrTimeCounter:setCount(self.mainLogic.passedCol)
		-- self.mainLogic.PlayUIDelegate.moveOrTimeCounter:setStageNumber("前进距离")
	-- end
	self.encryptData.frontAnimalColId = self.mainLogic.boardView.startColIndex
	self:updateWaitSteps(self:getNextScrollWaitSteps())
end

function OlympicHorizontalEndlessMode:getNextScrollWaitSteps()
	local passedCol = self.mainLogic.passedCol or 0
	local waitSteps = 0
	if self.totalAdditionColCount and self.totalAdditionColCount > 0 then
		
		local realPassedCol = passedCol - self.totalAdditionColCount

		if realPassedCol >= 0 then
			local loopStart = 26
			local loopEnd = 40
			local loopCount = loopEnd - loopStart + 1
			local realCol = ( realPassedCol % loopCount ) + (loopStart - 9)
			local loopTimes = math.floor( realPassedCol / loopCount ) + 1

			printx( 1 , "   OlympicHorizontalEndlessMode:getNextScrollWaitSteps  realCol = " , realCol , " realPassedCol = " , realPassedCol)
			waitSteps = self:getWaitStepsByCol(realCol)
		 	
		 	printx( 1 , "   OlympicHorizontalEndlessMode:getNextScrollWaitSteps  passedCol = " , passedCol , "  self.totalAdditionColCount = " , self.totalAdditionColCount , "  waitSteps = " , waitSteps)
		 	if passedCol >= self.totalAdditionColCount and waitSteps > 1 then

				if waitSteps - loopTimes > 1 then
					waitSteps = waitSteps - loopTimes
				else
					waitSteps = 1
				end
			end
		else
			local nextColIdx = 10 + passedCol % self.totalAdditionColCount
			waitSteps = self:getWaitStepsByCol(nextColIdx)
		end
		
	end
	return waitSteps
end

function OlympicHorizontalEndlessMode:checkHasIceInBoard()
	local mainLogic = self.mainLogic
	for r = 1, #mainLogic.boardmap do
		for c = mainLogic.boardView.startColIndex, #mainLogic.boardmap[r] do
			local board = mainLogic.boardmap[r][c]
			if board.iceLevel > 0 then
				return true
			end
		end
	end
	return false
end

function OlympicHorizontalEndlessMode:checkNeedDoScroll()
	local mainLogic = self.mainLogic
	if not self:checkHasIceInBoard() then
		return 3
	end
	if self.encryptData.olympicWaitSteps < 1 and self.encryptData.followAnimalSwoonRound < 1 then
		return 1
	end
	return 0
end

function OlympicHorizontalEndlessMode:checkScrollDigGround(scrollComplete)
	local needDoScroll = self:checkNeedDoScroll()
	if needDoScroll > 0 then
		self:doScrollDigGround(needDoScroll, scrollComplete)
		self:updateWaitSteps(self:getNextScrollWaitSteps())
		return true
	end
	return false
end

function OlympicHorizontalEndlessMode:hasLightInCol(col)
	return GameExtandPlayLogic:checkHasLightsInCol(self.mainLogic, col)
end

function OlympicHorizontalEndlessMode:doScrollDigGround(moveUpCol, stableScrollCallback)
	local hasLightInFirstCol = self:hasLightInCol(2)
	if hasLightInFirstCol then
		self.encryptData.failedByLightPassed = 1
	end

	local function onScrollFinish()
		-- self:doCheckHasLightItemToWarnning()
		self:onBoardScrollFinish()
		if stableScrollCallback and type(stableScrollCallback) == "function" then
			stableScrollCallback()
		end
	end
	HorizontalEndlessMode.doScrollDigGround(self, moveUpCol, onScrollFinish)
end

function OlympicHorizontalEndlessMode:onBoardScrollFinish()
	self:updateRoadHoles()
	local olympicTopNode = self.mainLogic.PlayUIDelegate.olympicTopNode
	if olympicTopNode then
		olympicTopNode:playAnimalWaitAnimate()
	end
end

function OlympicHorizontalEndlessMode:onScrollBoardView(time, extraCol)
	local mainLogic = self.mainLogic
	if mainLogic.PlayUIDelegate and extraCol then
		local gameBg = mainLogic.PlayUIDelegate.gameBgNode
		local boardView = mainLogic.boardView
		if gameBg and gameBg.doScroll then
			local moveDistanceX = boardView:convertToWorldSpace(ccp(0 ,0)).x - boardView:convertToWorldSpace(ccp(GamePlayConfig_Tile_Width*extraCol ,0)).x
			gameBg:doScroll(time, moveDistanceX)
		end
		local olympicTopNode = mainLogic.PlayUIDelegate.olympicTopNode
		if olympicTopNode then
			local boardView = mainLogic.boardView

			olympicTopNode:playFollowAnimalRun()
			self:updateFrontAnimalPosition(time, extraCol)

			local function getMoveTargetPosition(colId)
				local targetCol = colId - mainLogic.passedCol
				local needRemove = false
				if targetCol < boardView.startColIndex then
					needRemove = true
				end
				local posX = self:calcColumnGlobalPosX(targetCol, -5)
				return ccp(posX, 0), needRemove
			end
			olympicTopNode:moveHoles(time, getMoveTargetPosition)
		end
	end
end

function OlympicHorizontalEndlessMode:doCheckHasLightItemToWarnning()
	local hasAlert = self:addIceAlertEffect(kCheckLightStartCol, kCheckLightEndCol)

	local olympicTopNode = self.mainLogic.PlayUIDelegate.olympicTopNode
	if olympicTopNode then
		if hasAlert then
			olympicTopNode:playFrontAnimalHappyToAfraid()
		else
			olympicTopNode:playFrontAnimalAfraidToHappy()
		end
	end
end

-- function OlympicHorizontalEndlessMode:checkHasLightItemToWarnning(colStart, colEnd)
-- 	colEnd = colEnd or colStart
-- 	local mainLogic = self.mainLogic
-- 	for r = 1, #mainLogic.boardmap do
-- 		for c = colStart, colEnd do
-- 			local board = mainLogic.boardmap[r][c]
-- 			if board then
-- 				local itemView = mainLogic.boardView.baseMap[r][c]
-- 				if board.iceLevel > 0 then
-- 					itemView:playTopLevelHightLightEffect(TileHighlightType.kRedAlert)
-- 				else
-- 					itemView:stopTopLevelHightLightEffect()
-- 				end
-- 				itemView.isNeedUpdate = true
-- 			end
-- 		end
-- 	end
-- end

function OlympicHorizontalEndlessMode:removeIceAlertEffect(startCol, endCol, doMarkOnly)
	local mainLogic = self.mainLogic
	local startRowIndex = mainLogic.boardView.startRowIndex
	for col = startCol, endCol do
		local itemView = mainLogic.boardView.baseMap[startRowIndex][col]
		if itemView then
			local effect = itemView.itemSprite[ItemSpriteType.kTopLevelHighLightEffect]
			if effect and not effect.isDisposed then
				if doMarkOnly then
					effect._needToBeRemoved = true
				elseif effect._needToBeRemoved then
					effect:removeFromParentAndCleanup(true)
					itemView.itemSprite[ItemSpriteType.kTopLevelHighLightEffect] = nil
				end
			end
		end
	end
end

function OlympicHorizontalEndlessMode:buildAlertEffect(colCount, rowCount)
	local effect = CocosObject.new(CCNode:create())
	local frameTime = 1.5/24
	if colCount and colCount > 0 and rowCount and rowCount > 0 then
		local borderSprite = Scale9Sprite:createWithSpriteFrameName("ZQ_alert_light_scale9")
		local array = CCArray:create()
		array:addObject(CCFadeOut:create(10 * frameTime))
		array:addObject(CCFadeIn:create(10 * frameTime))
		-- array:addObject(CCDelayTime:create(0.1))
		borderSprite:runAction(CCRepeatForever:create(CCSequence:create(array)))
		borderSprite:setPreferredSize(CCSizeMake(colCount * GamePlayConfig_Tile_Width+18, rowCount * GamePlayConfig_Tile_Height+20))
		borderSprite:setAnchorPoint(ccp(0, 1))
		borderSprite:ignoreAnchorPointForPosition(false)
		borderSprite:setPosition(ccp(-GamePlayConfig_Tile_Width/2-10, GamePlayConfig_Tile_Height/2+10))
		effect:addChild(borderSprite)
	end
	-- local arrowSprite, animate = SpriteUtil:buildAnimatedSprite(frameTime, "ZQ_hole_alert_%04d", 0, 12)
	-- arrowSprite:setScale(0.9)
	-- animate = CCSequence:createWithTwoActions(CCDelayTime:create(8 * frameTime), animate)
	-- arrowSprite:setPosition(ccp(-3, 70))
	-- arrowSprite:play(animate, 0, 0)
	-- effect:addChild(arrowSprite)
	return effect
end

function OlympicHorizontalEndlessMode:addIceAlertEffect(colStart, colEnd)
	local mainLogic = self.mainLogic
	local alertAreas = {}
	local startRowIndex = mainLogic.boardView.startRowIndex
	local rowCount = mainLogic.boardView.rowCount
	local tmpArea = nil
	for col = colStart, colEnd do
		if self:hasLightInCol(col) then
			if not tmpArea then
				tmpArea = {col=col, len=1}
				table.insert(alertAreas, tmpArea)
			else
				tmpArea.len = tmpArea.len + 1
			end
		else
			tmpArea = nil
		end
	end
	self:removeIceAlertEffect(colStart, colEnd, true)
	tmpArea = nil
	if #alertAreas > 0 then
		for _, area in pairs(alertAreas) do
			for i = 1, area.len do
				local col = area.col+i-1
				local itemView = mainLogic.boardView.baseMap[startRowIndex][col]
				if itemView then
					local existEffect = itemView.itemSprite[ItemSpriteType.kTopLevelHighLightEffect]
					if existEffect and existEffect._olympic_flag == i*100+area.len then
						existEffect._needToBeRemoved = false
					else
						if existEffect then
							existEffect:removeFromParentAndCleanup(true)
							itemView.itemSprite[ItemSpriteType.kTopLevelHighLightEffect] = true
						end
						local effect = nil
						if i == 1 then
							effect = self:buildAlertEffect(area.len, rowCount)
						else
							effect = self:buildAlertEffect()
						end
						effect:setPosition(itemView:getBasePosition(col, startRowIndex))
						local effectLayer = itemView.getContainer(ItemSpriteType.kTopLevelHighLightEffect)
						effectLayer:addChild(effect)
						itemView.itemSprite[ItemSpriteType.kTopLevelHighLightEffect] = effect
						effect._olympic_flag = i*100+area.len
					end
				end
			end
		end
	end
	self:removeIceAlertEffect(colStart, colEnd)

	return #alertAreas > 0
end

function OlympicHorizontalEndlessMode:useMove()
	HorizontalEndlessMode.useMove(self)
	if self.encryptData.followAnimalSwoonRound > 0 then
		self:updateSwoonRound(self.encryptData.followAnimalSwoonRound - 1)
	elseif self.encryptData.olympicWaitSteps > 0 then
		self:updateWaitSteps(self.encryptData.olympicWaitSteps - 1)
	end
end

function OlympicHorizontalEndlessMode:updateSwoonRound(round)
	self.encryptData.followAnimalSwoonRound = round
	if self.mainLogic.PlayUIDelegate then
		local olympicTopNode = self.mainLogic.PlayUIDelegate.olympicTopNode
		if olympicTopNode then
			olympicTopNode:updateFollowAnimalSwoonRound(round)
		end
	end
end

function OlympicHorizontalEndlessMode:updateWaitSteps(step)

	--printx( 1 , "   OlympicHorizontalEndlessMode:updateWaitSteps    " , step)
	--printx( 1 , "   " , debug.traceback())
	self.encryptData.olympicWaitSteps = step
	if not self.mainLogic.boardView.scrollLeftStepNode then
		self:initLeftStepNode()
	end
	self.mainLogic.boardView.scrollLeftStepNode:setLeftStep(self.encryptData.olympicWaitSteps)	
end

function OlympicHorizontalEndlessMode:playAddFiveEffect()
	self.mainLogic.boardView.scrollLeftStepNode:playAddFiveEffect()
end

function OlympicHorizontalEndlessMode:initLeftStepNode()
	local LeftStepNode = require("zoo.modules.autumn2018.ZQLeftStepNode")
	local scrollLeftStepNode = LeftStepNode:create()
	local posY = 600 - (self.mainLogic.boardView.startRowIndex - 1) * 70
	scrollLeftStepNode:setPosition(ccp(35, posY))
	scrollLeftStepNode:playMoveAnimation1()
	self.mainLogic.boardView.scrollLeftStepNode = scrollLeftStepNode
	self.mainLogic.boardView:addChild(scrollLeftStepNode)
end

function OlympicHorizontalEndlessMode:saveDataForRevert(saveRevertData)
	local mainLogic = self.mainLogic
	saveRevertData.olympicWaitSteps = self.encryptData.olympicWaitSteps
	HorizontalEndlessMode.saveDataForRevert(self, saveRevertData)
end

function OlympicHorizontalEndlessMode:revertDataFromBackProp()
	local mainLogic = self.mainLogic
	self.encryptData.olympicWaitSteps = mainLogic.saveRevertData.olympicWaitSteps
	HorizontalEndlessMode.revertDataFromBackProp(self)
end

function OlympicHorizontalEndlessMode:revertUIFromBackProp()
	local mainLogic = self.mainLogic
	self:updateWaitSteps(self.encryptData.olympicWaitSteps)
	HorizontalEndlessMode.revertUIFromBackProp(self)
end

function OlympicHorizontalEndlessMode:updateScoreBoard()
	if self.mainLogic.PlayUIDelegate then
		local topArea = self.mainLogic.PlayUIDelegate.topArea
		if topArea and topArea.zqScoreBoard then
			local runCols = self.encryptData.frontAnimalColId - self.mainLogic.boardView.startColIndex
			self.mainLogic.olympicScore = runCols * 100
			local score = self.encryptData.currIceNum
			setTimeOut(function () 
				if topArea and topArea.zqScoreBoard and not topArea.zqScoreBoard.isDisposed then
					ZQManager.getInstance():updateScore(score, true)
				end
			end , 1)
		end
	end
end

function OlympicHorizontalEndlessMode:getColId(col)
	return col + self.mainLogic.passedCol
end

function OlympicHorizontalEndlessMode:updateRoadHoles()
	if self.mainLogic.PlayUIDelegate then
		local olympicTopNode = self.mainLogic.PlayUIDelegate.olympicTopNode
		if olympicTopNode then
			local boardView = self.mainLogic.boardView
			for col = boardView.startColIndex, 9 do
				if self:hasLightInCol(col) then
					local globalPosX = self:calcColumnGlobalPosX(col, -5)
					olympicTopNode:addRoadHoles(globalPosX, self:getColId(col))
				end
			end
		end
	end
end

function OlympicHorizontalEndlessMode:calcFrontAnimalStayCol()
	local boardView = self.mainLogic.boardView
	local targetCol = boardView.startColIndex
	for col = boardView.startColIndex, 9 do
		if self:hasLightInCol(col) then
			break
		end
		targetCol = col
	end
	return targetCol
end

function OlympicHorizontalEndlessMode:checkFrontAnimalCanRun()
	if self.mainLogic.PlayUIDelegate then
		local boardView = self.mainLogic.boardView

		local targetCol = self:calcFrontAnimalStayCol()
		local targetColId = self:getColId(targetCol)
		local posOffsetX = 0
		if targetCol == 2 then
			posOffsetX = -20
		end
		if targetColId > self.encryptData.frontAnimalColId then
			local olympicTopNode = self.mainLogic.PlayUIDelegate.olympicTopNode
			local time = (targetColId - self.encryptData.frontAnimalColId) * 0.4
			if time > 1.5 then time = 1.5 end

			olympicTopNode:playFrontAnimalRunTo( self:calcColumnGlobalPosX(targetCol, 20 + posOffsetX) , time)
			self.encryptData.frontAnimalColId = targetColId

			--self:updateScoreBoard()
		else
			--printx( 1 , "  WTFFFFFFFFFFFFFFFFFFFFFFFFFFF?????????????????????" , targetCol , targetColId)
			if targetCol == 2 then
				local olympicTopNode = self.mainLogic.PlayUIDelegate.olympicTopNode
				if olympicTopNode.roadHoles[targetColId] then
					olympicTopNode:playFrontAnimalMoveTo( self:calcColumnGlobalPosX(targetCol, -15 + posOffsetX) , 0.3)
				else
					olympicTopNode:playFrontAnimalMoveTo( self:calcColumnGlobalPosX(targetCol, 20 + posOffsetX) , 0.3)
				end
			end
		end
	end
end

function OlympicHorizontalEndlessMode:updateFrontAnimalPosition(time, extraCol)
	extraCol = extraCol or 0
	local mainLogic = self.mainLogic
	local boardView = mainLogic.boardView

	local frontAnimalCol = self.encryptData.frontAnimalColId - mainLogic.passedCol
	if frontAnimalCol < boardView.startColIndex then
		frontAnimalCol = boardView.startColIndex
	end
	local hasLightInCol = self:hasLightInCol(extraCol + frontAnimalCol) -- 滚动完成前的位置

	local frontAnimalColId = self:getColId(frontAnimalCol)
	local needRun = false
	if frontAnimalColId > self.encryptData.frontAnimalColId then
		needRun = true
		self.encryptData.frontAnimalColId = frontAnimalColId
	end
	local olympicTopNode = mainLogic.PlayUIDelegate.olympicTopNode

	local frontAnimalTargetPos = 0
	local posOffsetX = 0
	if frontAnimalCol == 2 then
		posOffsetX = -20
	end
	--printx( 1 , "   OlympicHorizontalEndlessMode:updateFrontAnimalPosition   `111  " , frontAnimalColId , self.encryptData.frontAnimalColId)
	if needRun then
		olympicTopNode:playFrontAnimalRunTo( self:calcColumnGlobalPosX(frontAnimalCol, -15 + posOffsetX) , time)
		--self:updateScoreBoard()
	else
		olympicTopNode:playFrontAnimalMoveTo( self:calcColumnGlobalPosX(frontAnimalCol, 20 + posOffsetX) , time)
	end
end

function OlympicHorizontalEndlessMode:checkFollowAnimalCanGetUp()
	local mainLogic = self.mainLogic
	if self.followAnimalFallDown and self.encryptData.followAnimalSwoonRound <= 0 then
		if mainLogic.PlayUIDelegate then
			local olympicTopNode = mainLogic.PlayUIDelegate.olympicTopNode
			olympicTopNode:playFollowAnimalJump()
			olympicTopNode:setSwoonRoundLabelVisible(false)
		end
		local scrollLeftStepNode = mainLogic.boardView.scrollLeftStepNode
		scrollLeftStepNode:setNodeActived(true)
		scrollLeftStepNode:playMoveAnimation1()

		self.followAnimalFallDown = false
	end
end

function OlympicHorizontalEndlessMode:calcColumnGlobalPosX(col, offsetX)
	offsetX = offsetX or 15 
	local boardView = self.mainLogic.boardView
	return boardView:convertToWorldSpace(ccp((col - 0.5) * 70 + offsetX, 0)).x
end

function OlympicHorizontalEndlessMode:onEnterWaitingState()
	self:doCheckHasLightItemToWarnning()
	self:checkFrontAnimalCanRun()
	self:checkFollowAnimalCanGetUp()
end

function OlympicHorizontalEndlessMode:addFollowAnimalSwoonRound(num)
	self:updateSwoonRound(self.encryptData.followAnimalSwoonRound + num)
	self.followAnimalFallDown = true
end

function OlympicHorizontalEndlessMode:getFollowAnimalSwoonRound()
	return self.encryptData.followAnimalSwoonRound or 0
end