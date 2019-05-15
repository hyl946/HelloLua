require "zoo.gamePlay.mode.HorizontalEndlessMode"
require "zoo.modules.spring2017.Spring2017Config"
-- 
SpringHorizontalEndlessMode = class(HorizontalEndlessMode)

--local classIndex = 0
local __encryptKeys = {
	scrollWaitSteps = true,
	collectChickenNum = true,
	totalCollectChickenNum = true,
	playCastChickenNum = true,
	bossCastTimes = true,
	useMoves = true,
	castAddMove3Num = true,
	totalAddMove3Num = true,
	totalAdd3 = true,
	totalAdd5 = true,
	bombNum = true,
	targetAddNum = true,
	targetAddition = true,
}
local EncryptData = memory_class_simple(__encryptKeys)

function EncryptData:ctor()
--	classIndex = classIndex + 1
--	self.__class_id = classIndex
	self.scrollWaitSteps = 0
	self.collectChickenNum = 0
	self.totalCollectChickenNum = 0
	self.playCastChickenNum = 10
	self.bossCastTimes = 0
	
	-- 每15步最多扔1次+步
	self.useMoves = 0
	self.castAddMove3Num = 0
	self.totalAddMove3Num = 0

	-- for check
	self.totalAdd3 = 0
	self.totalAdd5 = 0
	-- 无需加密
	self.chickenInBag = 0
	self.chickenOnBoard = 0

	self.bombNum = 0
	self.totalBombNum = 0
	self.targetAddNum = 0
	self.targetAddition = 100
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

----------------------------------------------------
local kMapLoopBeginCol = 16

function SpringHorizontalEndlessMode:getChickenMother( ... )
	if self.mainLogic.PlayUIDelegate then
		local topAnimationsNode = self.mainLogic.PlayUIDelegate.topAnimationsNode
		if not topAnimationsNode then
			return
		end
		return topAnimationsNode.chickenMother
	end
end

function SpringHorizontalEndlessMode:updateShowChickenNum( onlyCollectPercent )
	local chickenMother = self:getChickenMother()
	if chickenMother then 
		chickenMother:updateTargetNum(self.encryptData.totalCollectChickenNum)
		-- chickenMother:setCollectPercent(math.max(0,self.encryptData.collectChickenNum / self.encryptData.playCastChickenNum),1)
		-- if not onlyCollectPercent then
		-- 	chickenMother:setTotalNum(self.encryptData.totalCollectChickenNum)
		-- end
	end
end

function SpringHorizontalEndlessMode:getCollectPosition()
	local chickenMother = self:getChickenMother()
	if chickenMother then 
		return chickenMother:getCollectPosition()
	end
	return nil
end

function SpringHorizontalEndlessMode:playCollectEffect()
	local chickenMother = self:getChickenMother()
	if chickenMother then 
		return chickenMother:playCollectEffect()
	end
end

function SpringHorizontalEndlessMode:playCollectAnim(fromPos, playEffect,callback, time)
	if self.mainLogic.PlayUIDelegate then
		local effectLayer = self.mainLogic.PlayUIDelegate.effectLayer
		if not effectLayer.chickenBatchNode then
			effectLayer.chickenBatchNode = CocosObject:create()
			effectLayer.chickenBatchNode:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/nationday2017/nationday2017_in_game.png"), 80));
			effectLayer:addChild(effectLayer.chickenBatchNode)
		end
		local chickenBatchNode = effectLayer.chickenBatchNode

		local sprite = Sprite:createWithSpriteFrameName("nationday_star_0000") --ItemViewUtils:buildAnimalStatic(AnimalTypeConfig.kYellow)
		sprite:setPosition(fromPos)
		local toPosCCP = self:getChickenMother():getCollectPosition()
		local toPos = {x = toPosCCP.x - 5, y = toPosCCP.y - 5}
		local time = time or 0.8
		local spawnActs = CCArray:create()
		local fadeAct = CCSequence:createWithTwoActions(CCDelayTime:create(time*2/3), CCFadeTo:create(time/3, 255 * 0.5))
		-- local moveAct = CCMoveTo:create(time, ccp(toPos.x, toPos.y))
		local scaleAct = CCScaleTo:create(time, 0.5)
		spawnActs:addObject(fadeAct)
		-- spawnActs:addObject(moveAct)
		spawnActs:addObject(scaleAct)

		local controlPoint = ccp(fromPos.x + (toPos.x - fromPos.x) * 0.3, toPos.y + 50)
		local bezierConfig = ccBezierConfig:new()
		bezierConfig.controlPoint_1 = fromPos
		bezierConfig.controlPoint_2 = controlPoint
		bezierConfig.endPosition = ccp(toPos.x, toPos.y)
		local bezierAction = CCBezierTo:create(time, bezierConfig)
		spawnActs:addObject(bezierAction)

		local actSeq = CCArray:create()
		actSeq:addObject(CCSpawn:create(spawnActs))
		local function onFinish()
			if playEffect then
				local effect = SpringAnimations:createEffectExplore()
				effect:setPosition(ccp(toPos.x, toPos.y))
				-- effect:playByIndex(0,1,1)
				effect:setScale(1.5)
				-- effect:addEventListener(ArmatureEvents.COMPLETE, function( ... )
				-- 	effect:removeFromParentAndCleanup(true)
				-- end)
				effectLayer:addChild(effect)
			end

			sprite:removeFromParentAndCleanup(true)
			if callback then callback() end
		end
		actSeq:addObject(CCCallFunc:create(onFinish))
		sprite:runAction(CCSequence:create(actSeq))

		chickenBatchNode:addChild(sprite)
	else
		if callback then callback() end
	end
end

function SpringHorizontalEndlessMode:collectChicken( num, r, c )
	self.encryptData.collectChickenNum = self.encryptData.collectChickenNum + num
	self.encryptData.totalCollectChickenNum = self.encryptData.totalCollectChickenNum + num

	if r and c then
		self.encryptData.chickenOnBoard = self.encryptData.chickenOnBoard + num
	else
		self.encryptData.chickenInBag = self.encryptData.chickenInBag + num
	end

	local chickenMother = self:getChickenMother()
	if chickenMother then 
		chickenMother:playHit(function( ... )
			-- chickenMother:playIdle()
		end)
		if r and c then
			local function updateShowChickenNum()
				self:updateShowChickenNum()
			end
			local fromPos = self.mainLogic:getGameItemPosInView(r, c)
			self:playCollectAnim(fromPos,false, updateShowChickenNum)
			-- self:updateShowChickenNum(true)
		else
			self:updateShowChickenNum()
		end
	end
end

function SpringHorizontalEndlessMode:playChickenMotherCastIfNeed( onCast )
	-- if self.encryptData.collectChickenNum >= self.encryptData.playCastChickenNum then
	-- 	self.encryptData.collectChickenNum = 0--self.encryptData.collectChickenNum - self.encryptData.playCastChickenNum
	-- 	self.encryptData.bossCastTimes = self.encryptData.bossCastTimes + 1
	-- 	self:updatePlayCastChickenNum()

	-- 	local addChickenId = nil
	-- 	if self.encryptData.bossCastTimes <= 3 then
	-- 		local chickenIds = {1, 3, 2}
	-- 		addChickenId = chickenIds[self.encryptData.bossCastTimes]
	-- 	end

	-- 	local chickenMother = self:getChickenMother()
	-- 	if chickenMother then
	-- 		local function onCompleteCallback()
	-- 			chickenMother:playIdle()
	-- 		end
	-- 		local function onCastCallback()
	-- 			-- GamePlayMusicPlayer:getInstance():playEffect(GameMusicType.kSpring2017Cast)
	-- 			self:updateShowChickenNum()
	-- 			if onCast then onCast() end
	-- 		end
	-- 		local function addChickenCallback()
	-- 			local playScene = self.mainLogic.PlayUIDelegate
	-- 			if addChickenId and playScene and type(playScene.addSpringChickenById) == "function" then
	-- 				playScene:addSpringChickenById(addChickenId)
	-- 				-- GamePlayMusicPlayer:getInstance():playEffect(GameMusicType.kSpring2017Appear)
	-- 			end
	-- 		end
	-- 		chickenMother:playCast(onCompleteCallback, onCastCallback, addChickenCallback)
	-- 		-- local function playMusicEffect()
	-- 		-- 	GamePlayMusicPlayer:getInstance():playEffect(GameMusicType.kSpring2017Cast)
	-- 		-- end
	-- 		-- setTimeOut(playMusicEffect, 1.5)
	-- 		return true
	-- 	end
	-- end
	return false
end


function SpringHorizontalEndlessMode:initModeSpecial(config)
	HorizontalEndlessMode.initModeSpecial(self,config)
	self.encryptData = EncryptData.new()
	self.encryptData.scrollWaitSteps = 0
	self.encryptData.collectChickenNum = 0
	self.encryptData.generateCols = 0
	self.encryptData.bossCastTimes = 0
	self.isInFinalBombTime = false
	-- self:updatePlayCastChickenNum()
end

function SpringHorizontalEndlessMode:updatePlayCastChickenNum()
	local nextIndex = self.encryptData.bossCastTimes + 1
	if nextIndex > #Spring2017Config.CastConfig then
		nextIndex = #Spring2017Config.CastConfig
	end
	self.encryptData.playCastChickenNum = Spring2017Config.CastConfig[nextIndex]
end

function SpringHorizontalEndlessMode:updateUFOAnimation()
	local chickenMother = self:getChickenMother()
	if chickenMother then
		if self.encryptData.bombNum > 0 then
			local function onFinish()
				self.nationdayBombOnReady = true
				chickenMother:playReadyAnimation()
			end
			chickenMother:playLoadAnimation(onFinish)
		else
			chickenMother:playIdleAniamtion()
		end
	end
end

function SpringHorizontalEndlessMode:updateUFOBombNum()
	local chickenMother = self:getChickenMother()
	if chickenMother then
		chickenMother:updateBombNum(self.encryptData.bombNum)
	end
end

function SpringHorizontalEndlessMode:initBombAnimation()
	self:updateUFOAnimation()
	local chickenMother = self:getChickenMother()
	local function onClick()
		if self.nationdayBombOnReady then
			self:useBomb()
		end
	end
	chickenMother:setOnTouchLitener(onClick)
end

function SpringHorizontalEndlessMode:useBomb()
	local mainLogic = self.mainLogic
	if mainLogic.isWaitingOperation 
			and mainLogic.theGamePlayStatus == GamePlayStatus.kNormal
			and not mainLogic.isPaused then
		local interactionCtr = mainLogic.boardView.interactionController
		-- 不在使用其他道具(小木槌)的状态中才能使用
		if interactionCtr:getCurrentInteraction() == interactionCtr.normalSwapInteraction then
			self.nationdayBombOnReady = false
			mainLogic:useNationDay2017Cast()
		end
	end
end

function SpringHorizontalEndlessMode:runUseBombAnimation(onFire)
	local chickenMother = self:getChickenMother()
	local function onFireCallback()
		self:updateUFOBombNum()
		if onFire then onFire() end
	end
	local function onFinishCallback()
		if self.encryptData.bombNum > 0 then
			local function onFinish()
				self.nationdayBombOnReady = true
				chickenMother:playReadyAnimation()
			end
			chickenMother:playLoadAnimation(onFinish)
		else
			chickenMother:playIdleAniamtion()
		end
	end
	chickenMother:playFireAnimation(onFireCallback, onFinishCallback)
end

function SpringHorizontalEndlessMode:updateWaitSteps(step)
	self.encryptData.scrollWaitSteps = step
	if not self.mainLogic.boardView.scrollLeftStepNode then
		self:initLeftStepNode()
	end
	self.mainLogic.boardView.scrollLeftStepNode:setLeftStep(self.encryptData.scrollWaitSteps)	
end

function SpringHorizontalEndlessMode:getNextScrollWaitSteps()
	local passedCol = self.mainLogic.passedCol or 0
	local nextColIdx = self:calcNextColIndex(passedCol)
 	local waitSteps = self:getWaitStepsByCol(nextColIdx)
	return waitSteps
end

function SpringHorizontalEndlessMode:reachEndCondition()
	return	self.mainLogic.theCurMoves <= 0
end

function SpringHorizontalEndlessMode:afterFail()
	local mainLogic = self.mainLogic;

	if self.isInFinalBombTime then
		self.mainLogic:setGamePlayStatus(GamePlayStatus.kAferBonus)
		return
	end
	if mainLogic.PlayUIDelegate then
	    local function goOn()
	    	self:getAddSteps(5)
		    mainLogic:setGamePlayStatus(GamePlayStatus.kNormal)
		    mainLogic.fsm:changeState(mainLogic.fsm.fallingMatchState)
		    
			local action = GameBoardActionDataSet:createAs(
		            GameActionTargetType.kGameItemAction,
		            GameItemActionType.kNationDay2017_Bomb_All,
		            IntCoord:create(2, 2),
		            IntCoord:create(9, 9),
		            GamePlayConfig_MaxAction_time
		        )
		    mainLogic:addDestructionPlanAction(action)
		    mainLogic:setNeedCheckFalling()

		    mainLogic.PlayUIDelegate:setPauseBtnEnable(true)
		end
		local function giveUp()
			-- 关卡大招使用情况打点
			local usedBombNum = self.encryptData.totalBombNum - self.encryptData.bombNum
			local dcData = {
				game_type = "stage",
				game_name = "national_day2017",
				category = "stage",
				sub_category = "national_day2017_skill",
				t1 = self.encryptData.totalBombNum,
				t2 = usedBombNum,
			}
			DcUtil:activity(dcData)

			if self.encryptData.bombNum > 0 then
				self.isInFinalBombTime = true
				
				mainLogic:setGamePlayStatus(GamePlayStatus.kNormal)
				NationDay2017CastLogic:runCastAction(mainLogic, self.encryptData.bombNum)
		    	self.encryptData.bombNum = 0

		    	mainLogic.fsm:changeState(mainLogic.fsm.fallingMatchState)
		    	mainLogic:setNeedCheckFalling()
			else
				mainLogic:setGamePlayStatus(GamePlayStatus.kAferBonus)
			end
		end

		if self.isFailByRefresh then
			setTimeOut(giveUp, 0.1)
		elseif self.guideLevelFlag and not self.hadGiveFreeAddFive then
			self.hadGiveFreeAddFive = true
    		local panel = EndGamePropOlympicPanel:create(
					mainLogic.level, mainLogic.levelType, ItemType.NATIONDAY2017_ADD_FIVE, goOn, giveUp, nil)
			panel:popout()
		else
			local function copyLabel(label, text)
				text = text or ""
				local copy = TextField:create(text, label:getFontName(), label:getFontSize(), 
						nil, kCCVerticalTextAlignmentCenter, kCCTextAlignmentLeft)
			  	copy:setAnchorPoint(ccp(0, 0.5))
  				copy:setColor(ccc3(label:getColor().r, label:getColor().g, label:getColor().b))
  				copy:setOpacity(label:getOpacity())
  				return copy
			end
			local hasTangChicken = self:hasTangChickenInNextCols(2)
			local function onPanelWillPopout(panel)
				if panel and hasTangChicken then
					local pos = panel.msgLabel:getPosition()
					local replaceNode = CocosObject.new(CCNode:create())

					local label1 = copyLabel(panel.msgLabel, "下一列有")
					replaceNode:addChild(label1)

					local label2 = copyLabel(panel.msgLabel, "哦，立即复活继续玩好不？")
					replaceNode:addChild(label2)

					local sprite = Sprite:createWithSpriteFrameName("nationday_starbox")
					sprite:setAnchorPoint(ccp(0, 0.5))
					replaceNode:addChild(sprite)

					local lSize1 = label1:getContentSize()
					local spriteSize = sprite:getContentSize()
					sprite:setPositionX(lSize1.width)
					label2:setPositionX(lSize1.width+spriteSize.width)

					replaceNode:setPosition(ccp(pos.x, pos.y - lSize1.height/2))
					panel.msgLabel:setString("")
					panel.msgLabel:getParent():addChild(replaceNode)
				end
			end
			if mainLogic.replayMode ~= ReplayMode.kNone then
				if mainLogic.replayStep and mainLogic.replayStep < #mainLogic.replaySteps then
					setTimeOut(goOn, 0.1)
					return
				elseif mainLogic.replayMode ~= ReplayMode.kResume and mainLogic.replayMode ~= ReplayMode.kReview then
					setTimeOut(giveUp, 0.1)
					return
				end
			end
			-- if __ANDROID then 
			-- 	EndGamePropAndroidPanel_VerB:create(mainLogic.level, mainLogic.levelType, ItemType.NATIONDAY2017_ADD_FIVE, goOn, giveUp, nil, onPanelWillPopout)
			-- else
			-- 	EndGamePropIosPanel_VerB:create(mainLogic.level, mainLogic.levelType, ItemType.NATIONDAY2017_ADD_FIVE, goOn, giveUp, nil, onPanelWillPopout)
			-- end

			EndGamePropManager:create(false, mainLogic.level, mainLogic.levelType, ItemType.NATIONDAY2017_ADD_FIVE, goOn, giveUp, nil, onPanelWillPopout)
		end
	end
end

function SpringHorizontalEndlessMode:hasTangChickenInNextCols(cols)
	cols = cols or 1
	local passedCol = self.mainLogic.passedCol
	local digItemMap = self.mainLogic.digItemMap
	local totalNum = 0
	for i = 1, cols do
		local colIdx = self:calcNextColIndex(passedCol + i - 1)
		for r = 1, 9 do
			local c = colIdx - 9
			local item = digItemMap[r] and digItemMap[r][c] or nil
			if item and item.ItemType == GameItemType.kTangChicken then
				return true
			end
		end
	end
	return false
end

function SpringHorizontalEndlessMode:getNextColsTangChickenNum(cols)
	cols = cols or 1
	local passedCol = self.mainLogic.passedCol
	local digItemMap = self.mainLogic.digItemMap
	local totalNum = 0
	for i = 1, cols do
		local colIdx = self:calcNextColIndex(passedCol + i - 1)
		for r = 1, 9 do
			local c = colIdx - 9
			local item = digItemMap[r] and digItemMap[r][c] or nil
			if item and item.ItemType == GameItemType.kTangChicken then
				totalNum = totalNum + 1
			end
		end
	end
	return totalNum
end

function SpringHorizontalEndlessMode:getAddSteps(count)
	local mainLogic = self.mainLogic;
	mainLogic.hasAddMoveStep = { source = "tryAgainWhenFailed" , steps = count }
	mainLogic.theCurMoves = mainLogic.theCurMoves + count
	if mainLogic.PlayUIDelegate then
		mainLogic.PlayUIDelegate:setMoveOrTimeCountCallback(mainLogic.theCurMoves, false)
	end
	setTimeOut( function () GamePlayMusicPlayer:playEffect( GameMusicType.kPropAdd5stepFlyon ) end , 0.15 )

	self:logAddStep(count)
end

function SpringHorizontalEndlessMode:checkScrollDigGround(scrollComplete)
	if self.encryptData.scrollWaitSteps < 1 then
		local num = self:getNextColsTangChickenNum(2)
		self:doScrollDigGround(2,scrollComplete)
		self:updateWaitSteps(self:getNextScrollWaitSteps())
		return true
	end
	return false
end

function SpringHorizontalEndlessMode:doScrollDigGround(moveUpCol, stableScrollCallback)
	HorizontalEndlessMode.doScrollDigGround(self,moveUpCol,stableScrollCallback)
end

function SpringHorizontalEndlessMode:onScrollBoardView(time, moveDistance)
	-- TODO:game bg
end

function SpringHorizontalEndlessMode:onGameStart()
	if not self.mainLogic.isDisposed then -- quit level at begining
		-- self:doCheckHasLightItemToWarnning()
		HorizontalEndlessMode.onGameStart(self)
		self:addBoardViewEffect()

		-- self:resetGuideDengLongPosition()

		self:initBombAnimation()
	end
end

function SpringHorizontalEndlessMode:onGameInit()
	local context = self

	if self.mainLogic.replayMode == ReplayMode.kNone then
		-- 判断是否是引导关
		local levelPassed = GameGuideData:sharedInstance():containInPassedLevelIds(tostring(self.mainLogic.level))
		self.guideLevelFlag = not levelPassed and GameGuide:checkHaveGuide(self.mainLogic.level)
		if self.mainLogic.nationDayData then 
			-- 记录replay用数据
			GamePlayContext:getInstance().nationDayData = {}
		    GamePlayContext:getInstance().nationDayData.buffList = self.mainLogic.nationDayData
		    GamePlayContext:getInstance().nationDayData.isGuideLevel = self.guideLevelFlag
	    	ReplayDataManager:updateNationDayCtxData()
		end
	else
		if GamePlayContext:getInstance().nationDayData then
			self.guideLevelFlag = GamePlayContext:getInstance().nationDayData.isGuideLevel
		end
	end

	local function setGameStart()
		self:onGameStart()
	end

	local function playPrePropAnimation()
		local nationDayData = GamePlayContext:getInstance().nationDayData
		if nationDayData and nationDayData.buffList then
			local animCount = 0
			for i, v in ipairs(nationDayData.buffList) do
				if v.buffType == 1 or v.buffType == 2 then
					animCount = animCount + 1
				end
			end
			local animWaitCount = 0
			local function onFinish()
				animWaitCount = animWaitCount - 1
				if animWaitCount == 0 then
					setGameStart()
				end
			end
			local animIndex = 0
			local vSize 	= CCDirector:sharedDirector():getVisibleSize()
			for i, v in ipairs(nationDayData.buffList) do
				if v.buffType == 1 then
					animIndex = animIndex + 1
					animWaitCount = animWaitCount + 1
					local function onAddStep()
						self.mainLogic.theCurMoves = self.mainLogic.theCurMoves + v.value
						if self.mainLogic.PlayUIDelegate then
							self.mainLogic.PlayUIDelegate:setMoveOrTimeCountCallback(self.mainLogic.theCurMoves, false)
						end
						onFinish()
					end
					local moveOrTimeCounter = self.mainLogic.PlayUIDelegate.moveOrTimeCounter
					local flyToPos = moveOrTimeCounter.label:getPositionInWorldSpace()
					local anim = NationDay2017Animations:createBuffAnimation(v.buffType, v.value, v.frameType, v.headUrl, flyToPos, onAddStep)
					anim:setPosition(ccp(vSize.width/2 + (animIndex - (animCount+1)/2) * 240 + 10, vSize.height / 2 + 100))
					self.mainLogic.PlayUIDelegate.effectLayer:addChild(anim)
				elseif v.buffType == 2 then
					animIndex = animIndex + 1
					animWaitCount = animWaitCount + 1
					local function onAddBomb()
						self.encryptData.totalBombNum = self.encryptData.totalBombNum + v.value
						self.encryptData.bombNum = v.value + self.encryptData.bombNum
						self:updateUFOBombNum()
						onFinish()
					end
					local chickenMother = self:getChickenMother()
					local flyToPos = chickenMother:getBombPosition()
					local anim = NationDay2017Animations:createBuffAnimation(v.buffType, v.value, v.frameType, v.headUrl, flyToPos, onAddBomb)
					anim:setPosition(ccp(vSize.width/2 + (animIndex - (animCount+1)/2) * 200 + 10, vSize.height / 2 + 100))
					self.mainLogic.PlayUIDelegate.effectLayer:addChild(anim)
				elseif v.buffType == 0 then
					self.encryptData.targetAddition = v.value
				elseif v.buffType == 3 then
					self.encryptData.targetAddNum = v.value
				end
			end
			if animWaitCount == 0 then
				setGameStart()
			end
		else
			setGameStart()
		end
	end

	local function playDigScrollAnimation()
		context.mainLogic.boardView:startHorizontalScrollInitView(playPrePropAnimation)
	end
	local col = GameExtandPlayLogic:clacBoardColCount(context.mainLogic.digBoardMap)
	if col > 17 then col = 17 end
	local extraItemMap, extraBoardMap = context:getExtraMap(0, col)
	self.mainLogic.boardView:initHorizontalScrollView(extraItemMap, extraBoardMap)
	self.mainLogic.boardView:hideItemViewLayer()
	self.mainLogic.passedCol = 0

	if self.mainLogic.PlayUIDelegate then
		-- self.mainLogic.PlayUIDelegate.moveOrTimeCounter:setVisible(false)
		self.mainLogic.PlayUIDelegate:playLevelTargetPanelAnim(playDigScrollAnimation)
	else
		playDigScrollAnimation()
	end
	self.mainLogic:stopWaitingOperation()

	self:updateWaitSteps(self:getNextScrollWaitSteps())
end

function SpringHorizontalEndlessMode:getCastFromPos()
	local chickenMother = self:getChickenMother()
	if chickenMother then
		local pos = chickenMother:getFireBombPosition()
		if pos then
			pos = self.mainLogic.boardView:convertToNodeSpace(pos)
			return {x = pos.x, y = pos.y}
		end
	end
	return nil
end

function SpringHorizontalEndlessMode:resetGuideDengLongPosition()
	local chickenMother = self:getChickenMother()
	if chickenMother and chickenMother.denglongNode then
		local gb = chickenMother.denglongNode:getGroupBounds()
		local data = GameGuideData:sharedInstance()
		local action = data:getGuideActionById(2801013, 1)
		action.position = ccp(gb.origin.x, gb.origin.y)
		action.width = gb.size.width
		action.height = gb.size.height
	end
end

function SpringHorizontalEndlessMode:onAfterRefreshStable()
	if self.guideLevelFlag and self.mainLogic.realCostMove == 3 and not self.hadGiveFreeBomb then
		self.hadGiveFreeBomb = true
		self.encryptData.totalBombNum = self.encryptData.totalBombNum + 1
		self.encryptData.bombNum = self.encryptData.bombNum + 1
		self:updateUFOBombNum()
		self:updateUFOAnimation()
	end
end

function SpringHorizontalEndlessMode:useMove()
	HorizontalEndlessMode.useMove(self)
	-- TODO:
	self:updateWaitSteps(self.encryptData.scrollWaitSteps - 1)

	self.mainLogic.theCurMoves = self.mainLogic.theCurMoves - 1
	if self.mainLogic.PlayUIDelegate then --------调用UI界面函数显示移动步数
		self.mainLogic.PlayUIDelegate:setMoveOrTimeCountCallback(self.mainLogic.theCurMoves, false)
	end


	self.encryptData.useMoves = self.encryptData.useMoves + 1
	if self.encryptData.useMoves % 15 == 0 then
		self.encryptData.castAddMove3Num = 0
	end

	self:removeAlertEffect()
end

function SpringHorizontalEndlessMode:initLeftStepNode()
	local LeftStepNode = require("zoo.modules.spring2017.SpringLeftStepNode")
	local scrollLeftStepNode = LeftStepNode:create()
	local posY = 630 - (self.mainLogic.boardView.startRowIndex - 1) * 70 - 70
	scrollLeftStepNode:setPosition(ccp(60, posY))
	scrollLeftStepNode:playMoveAnimation1()
	self.mainLogic.boardView.scrollLeftStepNode = scrollLeftStepNode
	self.mainLogic.boardView:addChild(scrollLeftStepNode)
end

function SpringHorizontalEndlessMode:addBoardViewBg()
	-- local boardView = self.mainLogic.boardView
	-- local bg = Sprite:createWithSpriteFrameName("spring_board_bg")
	-- bg:setPosition(ccp(351, 247))
	-- boardView:addChildAt(bg, -1)
end

function SpringHorizontalEndlessMode:addBoardViewEffect()
	local boardView = self.mainLogic.boardView
	if not boardView.olympicBoardEffectBatch then
		local olympicBoardEffectBatch = CocosObject:create()
		olympicBoardEffectBatch:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/nationday2017/board_view_effects.png"),9))
		boardView.olympicBoardEffectBatch = olympicBoardEffectBatch
		boardView:addChild(olympicBoardEffectBatch)

		local startRowIndex = boardView.startRowIndex + 1
		local startColIndex = boardView.startColIndex
		local colCount = boardView.colCount
		local rowCount = boardView.rowCount - 1
		for i = 1, rowCount do
			local effect, animate2 = SpriteUtil:buildAnimatedSprite(1/24, "board_move_effect_%04d", 0, 20)
			effect:play(animate2, 0, 0)
			effect:setPosition(ccp(GamePlayConfig_Tile_Width*(startColIndex+colCount-1), GamePlayConfig_Tile_Height*(10-startRowIndex-i+0.5)))
			olympicBoardEffectBatch:addChild(effect)
		end
	end
end

function SpringHorizontalEndlessMode:onEnterWaitingState()
	if self.encryptData.scrollWaitSteps == 1 then
		self:addAlertEffect()
	end
end

function SpringHorizontalEndlessMode:addAlertEffect()
	self:removeAlertEffect()

	local alertEffect = CocosObject:create()
	alertEffect:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/nationday2017/nationday2017_in_game.png"), 9));
	local colCount, rowCount = 2,7
	local frameTime = 1/24

	for r = 3, 9 do
		local effect = Sprite:createWithSpriteFrameName("nd2017_alert_arrow")
		local poxY = (3 - r) * 70
		effect:setOpacity(0)
		effect:setPosition(ccp(0, poxY))

		local actSeq = CCArray:create()
		actSeq:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(frameTime, ccp(0, poxY)), CCFadeTo:create(6*frameTime, 255*0.07)))
		actSeq:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(6*frameTime, ccp(45, 0)), CCFadeTo:create(6*frameTime, 255*0.51)))
		actSeq:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(11*frameTime, ccp(79, 0)), CCFadeTo:create(11*frameTime, 255*0.4)))
		actSeq:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(6*frameTime, ccp(32.5, 0)), CCFadeTo:create(11*frameTime, 0)))
		actSeq:addObject(CCDelayTime:create(28*frameTime))

		effect:runAction(CCRepeatForever:create(CCSequence:create(actSeq)))

		alertEffect:addChild(effect)
	end

	alertEffect:setPosition(ccp(20, 450))

	-- local borderSprite = Scale9Sprite:createWithSpriteFrameName("spring2017_ingame/alert_light_scale90000")
	-- local array = CCArray:create()
	-- array:addObject(CCFadeOut:create(10 * frameTime))
	-- array:addObject(CCFadeIn:create(10 * frameTime))
	-- -- array:addObject(CCDelayTime:create(0.1))
	-- borderSprite:runAction(CCRepeatForever:create(CCSequence:create(array)))
	-- borderSprite:setPreferredSize(CCSizeMake(
	-- 	colCount * GamePlayConfig_Tile_Width+20, 
	-- 	rowCount * GamePlayConfig_Tile_Height+20
	-- ))
	-- borderSprite:setAnchorPoint(ccp(0.5, 0.5))
	-- borderSprite:ignoreAnchorPointForPosition(false)

	-- borderSprite:setPositionX(351 - 74*3 + 10)
	-- borderSprite:setPositionY(247)

	local boardView = self.mainLogic.boardView
	boardView:addChild(alertEffect)

	self.alertEffect = alertEffect
end

function SpringHorizontalEndlessMode:removeAlertEffect()
	if self.alertEffect and not self.alertEffect.isDisposed then
		self.alertEffect:removeFromParentAndCleanup(true)
		self.alertEffect = nil
	end
end

function SpringHorizontalEndlessMode:calcNextColIndex(passedCol)
	passedCol = passedCol or 0
	if passedCol > self.totalAdditionColCount then
		-- 已循环过的总列数
		local loopColNum = passedCol - self.totalAdditionColCount
		-- 循环列数
		local loopAddColNum = self.totalAdditionColCount - kMapLoopBeginCol + 10
		return loopColNum % loopAddColNum + kMapLoopBeginCol
	else
		return passedCol + 10
	end
end

function SpringHorizontalEndlessMode:generateAdditionMap(passedCol, addCol)
	local mainLogic = self.mainLogic
	local animalMap = self.levelConfig.animalMap

	local newItemMap, newBoardMap = {}, {}
	local beginAddCol = kMapLoopBeginCol - 9
	local loopAddColNum = self.totalAdditionColCount - beginAddCol + 1
	for i = 1, addCol do
		-- 轨迹循环：超过30列之后，从第beginAddCol列轨迹继续循环。
		local realCol = self.encryptData.generateCols % loopAddColNum + beginAddCol
		if _G.isLocalDevelopMode then printx(0, realCol) end

		self.encryptData.generateCols = self.encryptData.generateCols + 1
		-- local loopCount = math.ceil(self.encryptData.generateCols / loopAddColNum)

	 	for r = 1, #self.mainLogic.digItemMap do
	 		newItemMap[r] = newItemMap[r] or {}
	 		newBoardMap[r] = newBoardMap[r] or {}
	 		local itemData = self.mainLogic.digItemMap[r][realCol]:copy()
	 		newItemMap[r][i] = itemData
	 		
	 		local animalDef = animalMap[r][realCol+9]
	 		if animalDef then
		 		itemData:initByAnimalDef(animalDef)
		 	end

			if itemData:isColorful() then 			--可以随机颜色的物体
				if itemData._encrypt.ItemColorType == AnimalTypeConfig.kRandom 			--随机类型
					and itemData.ItemSpecialType ~= AnimalTypeConfig.kColor then	
						itemData._encrypt.ItemColorType = mainLogic:randomColor()
				end
			end
	 		newBoardMap[r][i] = self.mainLogic.digBoardMap[r][realCol]:copy()

			--每循环1次，唐装鸡在之前个数的基础上+5
			-- if itemData.ItemType == GameItemType.kTangChicken then
			-- 	local addLoopCount = math.min(loopCount,Spring2017Config.LoopAddCount)
			-- 	itemData.tangChickenNum = itemData.tangChickenNum + addLoopCount * Spring2017Config.LoopAddChickenNum
			-- end

	 	end
	 end
	 return newItemMap, newBoardMap
end

function SpringHorizontalEndlessMode:getCastAddMove3Num( ... )
	return self.encryptData.castAddMove3Num
end

function SpringHorizontalEndlessMode:getTotalAddMove3Num()
	return self.encryptData.totalAddMove3Num
end

function SpringHorizontalEndlessMode:incCastAddMove3Num( ... )
	self.encryptData.castAddMove3Num = self.encryptData.castAddMove3Num + 1
	self.encryptData.totalAddMove3Num = self.encryptData.totalAddMove3Num + 1
end

function SpringHorizontalEndlessMode:logAddStep( count )
	if count == 3 then
		self.encryptData.totalAdd3 = self.encryptData.totalAdd3 + 1
	elseif count == 5 then
		self.encryptData.totalAdd5 = self.encryptData.totalAdd5 + 1
	end
end

function SpringHorizontalEndlessMode:reachTarget()
	return false
end

-- for check
function SpringHorizontalEndlessMode:getGameExtraData()
	local ret = {}
	ret.cols = self.mainLogic.passedCol -- 滚动列数
	if self.mainLogic.usePropLog then -- 道具使用统计
		local prop = {}
		for propId, num in pairs(self.mainLogic.usePropLog) do
			prop[tostring(propId)] = num
		end
		ret.prop = prop
	end

	ret.add5 = self.encryptData.totalAdd5 -- 加5步次数
	ret.move = self.encryptData.useMoves	-- 总的移动步数
	ret.inbg = self.encryptData.chickenInBag -- 福袋鸡掉落的唐装鸡
	ret.onbd = self.encryptData.chickenOnBoard -- 棋盘上消除的小黄鸡
	ret.bomb = self.encryptData.totalBombNum
	-- ret.cast = self.encryptData.bossCastTimes -- 大招次数
	return ret
end