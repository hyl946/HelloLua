
require "hecore.display.CocosObject"
require "hecore.display.Scene"
require "hecore.display.Director"
require "hecore.ui.LayoutBuilder"
require "hecore.ui.Button"
require "zoo.scenes.AnimationScene"
require "zoo.data.LevelMapManager"
require "zoo.data.MetaManager"
require "zoo.data.UserManager"
require "zoo.config.LevelConfig"
-- require "zoo.gamePlay.GameBoardLogic"
require "zoo.gamePlay.GameBoardView"
require "zoo.panel.StopGamePanel"
require "zoo.scenes.component.gameplayScene.MoveOrTimeCounter"
require "zoo.panelBusLogic.PassLevelLogic"
require "zoo.animation.PropListAnimation"
require "zoo.panel.QuitPanel"
require "zoo.gameGuide.GameGuide"
require "zoo.panelBusLogic.IngamePaymentLogic"
require "zoo.animation.UFOAnimation"
require "zoo.panel.PrePropRemindPanel"
require 'zoo.config.RabbitWeeklyConfig'
require "zoo.model.PropsModel"
require "zoo.animation.TileSquirrel"
require "zoo.util.FUUUManager"
require "zoo.payment.PaymentNetworkCheck"
require "zoo.panel.seasonWeekly.SeasonWeeklyRaceResultPanel"
require "zoo.gamePlay.GamePlaySceneSkinManager"
require "zoo.gamePlay.levelTarget.LevelTargetAnimationFactory"
require "zoo.scenes.component.gameplayScene.GamePlaySceneTopArea"
require "zoo.animation.SnowFlyAnimation"
require "zoo.PersonalCenter.AchievementManager"
require "zoo.replaykit.ReplayRecordController"
require 'zoo.animation.BossBee.GamePlaySceneDecorator'
require "zoo.animation.PropsAnimation"

require "zoo.panel.endGameProp.EndGamePropIosPanel_VerB"
require "zoo.panel.endGameProp.EndGamePropIosPanel_VerB_old"
require "zoo.panel.endGameProp.EndGamePropAndroidPanel_VerB"
require "zoo.panel.endGameProp.EndGamePropAndroidPanel_VerB_old"
require 'zoo.gameGuide.IngamePropGuideManager'
require "zoo.gamePlay.BoardLogic.GameInitBuffLogic"
require "zoo.gamePlay.BoardLogic.CertainPlayLogic.ScoreBuffBottleLogic"
require "zoo.gamePlay.BoardLogic.CertainPlayLogic.FirecrackerLogic"


--[[
if __WIN32 then
	require "zoo.test.LevelPlayDebugPanel"
end
]]


assert(not GamePlaySceneUI)
assert(Scene)
GamePlaySceneUI = class(Scene)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()

GamePlaySceneUIType = table.const{
	kNormal = 1,
	kDev    = 2, 
	kReplay = 3,
}

LevelSuccessPanelTpye = {
	
	kNomal = 1 ,
	kOlympic = 2 ,
}

_G.IS_PLAY_YUANXIAO2017_LEVEL = false




function GamePlaySceneUI:addDropStatDisplayLayer()
	local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()

	local dropStatLayer = LayerColor:create()
	dropStatLayer:setColor(ccc3(0, 0, 0))
	dropStatLayer:setOpacity(255 * 0.6)
	dropStatLayer:changeWidthAndHeight(visibleSize.width, 120)
	dropStatLayer:setPosition(ccp(visibleOrigin.x, self.gameBoardView:getPosition().y + 720))

	self.extandLayer:addChild(dropStatLayer)
	self.gameBoardLogic.dropBuffLogic:setDropStatDisplayLayer( dropStatLayer )
end

function GamePlaySceneUI:addReplayRecordButton()
	if not ReplayRecordController.isReplaykitSupport() then
		return
	end

	local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local winSize = CCDirector:sharedDirector():getVisibleSize()

	self.replayRecordController = ReplayRecordController:create(self)
	-- 根据屏幕比例调整位置
	if _G.__frame_ratio < 1.6 then
		self.replayRecordController:addRecordButton(ccp(visibleOrigin.x + visibleSize.width - 120, visibleOrigin.y + visibleSize.height - 155))
		if self.replayRecordController.recordButton then 
			self.replayRecordController.recordButton:setScale(0.6)
		end
	else
		self.replayRecordController:addRecordButton(ccp(visibleOrigin.x + visibleSize.width - 135, visibleOrigin.y + visibleSize.height - 160))
	end

	local function tryShowPreview()
		if self.gameBoardLogic.blockReplayReord <= 0 and self.replayRecordController:hasPreview() then
			self.replayRecordController:showPreview()
		end 
	end
	GlobalEventDispatcher:getInstance():removeEventListenerByName(kGlobalEvents.kShowReplayRecordPreview)
	GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kShowReplayRecordPreview, tryShowPreview)
end



function GamePlaySceneUI:addDropUsePropBtn()
	local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local lyBtn = LayerColor:createWithColor(ccc3(255, 0, 0), 160, 50)
	local label = TextField:create("DropUseProp", nil, 24)
	_G.kDevDropUseProp = false
	lyBtn:setColor(_G.kDevDropUseProp and ccc3(0, 255, 0) or ccc3(255, 0, 0))
	label:setPosition(ccp(80, 25))
	lyBtn:addChild(label)
	lyBtn:setTouchEnabled(true)
	lyBtn:setPosition(ccp(visibleOrigin.x+100, visibleOrigin.y+visibleSize.height - 160))
	lyBtn:ad(DisplayEvents.kTouchTap, function ()
			_G.kDevDropUseProp = not _G.kDevDropUseProp
			lyBtn:setColor(_G.kDevDropUseProp and ccc3(0, 255, 0) or ccc3(255, 0, 0))
		end)
	self:addChild(lyBtn)
end

function GamePlaySceneUI:addBonusBtn()
	local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local lyBtn = LayerColor:createWithColor(ccc3(255, 0, 0), 80, 50)
	local label = TextField:create("Bonus", nil, 24)
	label:setPosition(ccp(40, 25))
	lyBtn:addChild(label)
	lyBtn:setTouchEnabled(true)
	lyBtn:setPosition(ccp(visibleOrigin.x+100, visibleOrigin.y+visibleSize.height - 100))
	lyBtn:ad(DisplayEvents.kTouchTap, function ()
		self.gameBoardLogic:setGamePlayStatus(GamePlayStatus.kBonus)
		end)
	self:addChild(lyBtn)
end



function GamePlaySceneUI:revertItem( propId,expireTime,usePropType )
	StageInfoLocalLogic:revertUsedProp(UserManager:getInstance().uid, propId)
	
	self.propList:revertItem(propId,expireTime,usePropType)
end

function GamePlaySceneUI:revertGiftItem( propId,originalPos )
	StageInfoLocalLogic:revertUsedProp(UserManager:getInstance().uid, propId)
	-- self.propList:revertGiftItem(revertGiftInfo.itemId,revertGiftInfo.pos)
	self.propList:revertGiftItem(propId,originalPos)
end

function GamePlaySceneUI:getUsePropInfo( ... )
	if self.propId and self.usePropType then
		return { propId = self.propId, usePropType = self.usePropType,expireTime = self.expireTime }
	else
		return nil
	end
end

function GamePlaySceneUI:sendUsePropMessage(itemType, usePropType, sendMsgSuccessCallback, sendMsgFailCallback, revertPropInfo,...)
	assert(type(itemType) == "number")
	assert(type(usePropType) == "number")
	assert(sendMsgSuccessCallback == false or type(sendMsgSuccessCallback) == "function")
	assert(#{...} == 0)
	
	local function successCallback()
		if sendMsgSuccessCallback then
			sendMsgSuccessCallback()
		end
	end

	local logic = UsePropsLogic:create(usePropType, self.levelId, 0, {itemType}, revertPropInfo)
	logic:setSuccessCallback(successCallback)
	logic:setFailedCallback(sendMsgFailCallback)
	logic:start()
end

function GamePlaySceneUI:convertToLevelTargetAnimationOrderType(key1, ...)
	assert(key1)
	assert(#{...} == 0)

	local targetType = false

	if key1 == GameItemOrderType.kNone then
		assert(false)
	elseif key1 == GameItemOrderType.kAnimal then
		targetType = "order1"
	elseif key1 == GameItemOrderType.kSpecialBomb then
		targetType = "order2"
	elseif key1 == GameItemOrderType.kSpecialSwap then
		targetType = "order3"
	elseif key1 == GameItemOrderType.kSpecialTarget then
		targetType = "order4"
	elseif key1 == GameItemOrderType.kOthers then 
		targetType = "order5"
	elseif key1 == GameItemOrderType.kSeaAnimal then
		targetType = 'order6'
	else

		assert(false)
	end

	return targetType
end

function GamePlaySceneUI:setTargetNumber(key1, key2, number, worldPos, rotation, animate, percent,...)
	assert(type(key1) == "number")
	assert(type(key2) == "number")
	assert(type(number)	== "number")
	if not __PURE_LUA__ then 
		assert(type(worldPos)	== "userdata")
	end
	-- assert(#{...} == 0)
	local targetType = false
	local id = 1
	if animate ~= false then
		animate = true
	end

	if self.targetType == "order" then
		targetType = self:convertToLevelTargetAnimationOrderType(key1)
		id = key2
	elseif self.targetType == kLevelTargetType.dig_move_endless_mayday 
		or self.targetType == kLevelTargetType.summer_weekly
		or self.targetType == kLevelTargetType.hedgehog_endless
		or self.targetType == kLevelTargetType.wukong
		then
		targetType = self.targetType
		id = key2
	else
		targetType = self.targetType
	end

	if targetType == 'order6' then -- 海洋模式必须传入转动的角度
		self.levelTargetPanel:setTargetNumber(targetType, id, number, animate, worldPos, rotation)
	else
		self.levelTargetPanel:setTargetNumber(targetType, id, number, animate, worldPos, nil, percent)
	end

end

function GamePlaySceneUI:revertTargetNumber(key1, key2, number,...)
	assert(type(key1) == "number")
	assert(type(key2) == "number")
	assert(type(number)	== "number")
	assert(#{...} == 0)

	local targetType = false
	local id = 1

	if self.targetType == "order" then
		targetType = self:convertToLevelTargetAnimationOrderType(key1)
		id = key2
	elseif self.targetType == kLevelTargetType.dig_move_endless_mayday 
		or self.targetType == kLevelTargetType.summer_weekly
		or self.targetType == kLevelTargetType.hedgehog_endless then
		targetType = self.targetType
		id = key2
	else
		targetType = self.targetType
	end

	self.levelTargetPanel:revertTargetNumber(targetType, id, number)
end

function GamePlaySceneUI:buildBackground(...)
	assert(#{...} == 0)

	local background = LayerColor:create()
	background:changeWidthAndHeight(self.visibleSize.width, self.visibleSize.height)
	background:setColor(ccc3(255, 255, 255))

	background:setPosition(ccp(self.visibleOrigin.x, self.visibleOrigin.y))
	self:addChild(background)
end

function GamePlaySceneUI:onKeyBackClicked(...)
	assert(#{...} == 0)
	if __ANDROID and PaymentNetworkCheck.getInstance():getIsChecking() then return end
	if self.mask or (self.guideLayer and self.guideLayer:getChildrenList() and #self.guideLayer:getChildrenList() > 0) or not self.topArea:getPauseBtnEnable() then return end
	self:onPauseBtnTapped()
end

function GamePlaySceneUI:sendQuitLevelMessage(levelId, totalScore, starLevel, stageTime, destroyCoin, targetCount, opLog)
	local costMove = self.gameBoardLogic.realCostMove
	local passLevelLogic = PassLevelLogic:create(levelId, totalScore, starLevel, stageTime, destroyCoin, targetCount, opLog, self.levelType, costMove, nil, nil , nil , 
													self.gameBoardLogic.randomSeed , 
													LevelDifficultyAdjustManager:getCurrStrategyID())
	passLevelLogic:start()
end

function GamePlaySceneUI:addScore(score, globalPos)
	if globalPos then
		local ladyBugPos = self:getLadyBugPosition()
		if ladyBugPos then
			self:addScoreStar(globalPos, ladyBugPos)
		end
	end
	self.scoreProgressBar:addScore(score , globalPos)
end

function GamePlaySceneUI:getLadyBugPosition()
	local ladyBugAnimation = self.scoreProgressBar.ladyBugAnimation
	if ladyBugAnimation and ladyBugAnimation.animal then
		local targetPosition = ladyBugAnimation.animal:convertToWorldSpace(ccp(0,0))
		return targetPosition
	end
	return nil
end

function GamePlaySceneUI:addScoreStar(fromGlobalPos, toGlobalPos)
	local r = 16 + math.random() * 10
	for i = 1, 10 do	
		if math.random() > 0.6 then
			local angle = i * 36 * 3.1415926 / 180
			local x = fromGlobalPos.x + math.cos(angle) * r
			local y = fromGlobalPos.y + math.sin(angle) * r
			local sprite = Sprite:createWithSpriteFrameName("game_collect_small_star0000")
			sprite:setPosition(ccp(fromGlobalPos.x, fromGlobalPos.y))
			sprite:setScale(math.random()*0.6 + 0.7)
			sprite:setOpacity(0)
			local moveTime = 0.3 + math.random() * 0.64
			local moveTo = CCMoveTo:create(moveTime, ccp(toGlobalPos.x, toGlobalPos.y))
			local function onMoveFinished( ) sprite:removeFromParentAndCleanup(true) end
			local moveIn = CCEaseElasticOut:create(CCMoveTo:create(0.25, ccp(x, y)))
			local array = CCArray:create()
			array:addObject(CCSpawn:createWithTwoActions(moveIn, CCFadeIn:create(0.25)))
			array:addObject(CCEaseSineIn:create(moveTo))
			array:addObject(CCCallFunc:create(onMoveFinished))
			sprite:runAction(CCSequence:create(array))

			self.scoreStarsBatch:addChild(sprite)
		end
	end
end

function GamePlaySceneUI:getStarLevelFromScore(score, ...)
	assert(score)
	assert(#{...} == 0)

	local result = false

	if score < self.curLevelScoreTarget[1] then
		result = 0
	elseif score >= self.curLevelScoreTarget[1] and score < self.curLevelScoreTarget[2] then
		result = 1
	elseif score >= self.curLevelScoreTarget[2] and score < self.curLevelScoreTarget[3] then
		result = 2
	elseif score >= self.curLevelScoreTarget[3] then
		result = 3
	end

	return result
end


function GamePlaySceneUI:create(levelId, levelType, selectedItemsData, ...)
	assert(type(levelId)			== "number")
	assert(type(selectedItemsData)		== "table")
	assert(#{...} == 0)

	local scene = GamePlaySceneUI.new()
	scene:init(levelId, levelType, selectedItemsData)

	local function testCall()
		scene:passLevel(1, 99999999, 3, 0, 0)
		--scene:failLevel(1, 0, 0, 0, 0, false)
	end
	--setTimeOut(testCall, 3)
	return scene
end



function GamePlaySceneUI:checkHiddenAreaUnlockAchievement(levelId, levelType, newStar)
	local result = false
	local originLevelScore = UserManager:getInstance():getUserScore(levelId)
	if originLevelScore then
		UserManager:getInstance():removeUserScore(originLevelScore.levelId)
	end

	local newLevelScore = ScoreRef.new()
	newLevelScore.levelId = levelId
	newLevelScore.star = newStar
	UserManager:getInstance():addUserScore(newLevelScore)


	if not originLevelScore or originLevelScore.star < newStar then
		if levelType == GameLevelType.kMainLevel then
			local branchId = MetaModel:sharedInstance():getHiddenBranchIdByNormalLevelId(levelId)
			if branchId and not MetaModel:sharedInstance():isHiddenBranchUnlock(branchId) 
				and MetaModel:sharedInstance():isHiddenBranchCanOpen(branchId) then
				result = true
			end
		end
	end

	UserManager:getInstance():removeUserScore(levelId)
	if originLevelScore then
		UserManager:getInstance():addUserScore(originLevelScore)
	end

	return result
end

function GamePlaySceneUI:checkScoreAndCompleteAchievement(score)
	local oldScore = UserManager:getInstance():getUserScore(self.levelId)
	local maxTopLevel = MetaManager.getInstance():getMaxNormalLevelByLevelArea()
	local topLevelId = UserManager:getInstance():getUserRef():getTopLevelId()
	local function onCompleteSuccess(evt)
		if self.isDisposed then return end
		local num = 10000
		if evt.data and evt.data.passNum  then
			num = evt.data.passNum
		end
		setTimeOut(function()
				if not self.isDisposed then 
					--ShareManager:setShareData(ShareManager.ConditionType.PASS_NUM, num)
					--ShareManager:shareWithID(ShareManager.HIGHEST_LEVEL)

				 end
			end, 1 / 60)
	end
	local function onRankSuccess(evt)
		if self.isDisposed then return end

		local share = false

		if evt.data and evt.data.share then
			share = evt.data.share
		end

		setTimeOut(function()
				if not self.isDisposed then 
					Notify:dispatch("AchiEventDataUpdate", AchiDataType.kOverSelfRank, share)
				 end
			end, 1 / 60)
	end
	local completeRequest = self.levelId == maxTopLevel and self.levelId == topLevelId and (not oldScore or not oldScore.score)
	local rankRequest = not oldScore or not oldScore.score or oldScore.score < score
	if completeRequest and rankRequest then ConnectionManager:block() end
	if completeRequest then
		local completeHttp = GetPassNumHttp.new()
		completeHttp:addEventListener(Events.kComplete, onCompleteSuccess)
		completeHttp:load(self.levelId)
	else
		onCompleteSuccess({})
	end

	--服务端优化，在pass level之后获取之前的排名
	-- Notify:dispatch("AchiEventDataUpdate", AchiDataType.kOverSelfRank, share)

	-- ShareManager.preLevel = self.levelId
	-- if oldScore then
	-- 	ShareManager.preScore = oldScore.score
	-- end

	-- if rankRequest then
	-- 	local rankHttp = GetShareRankHttp.new()
	-- 	rankHttp:addEventListener(Events.kComplete, onRankSuccess)
	-- 	rankHttp:load(self.levelId, score)
	-- else
	-- 	onRankSuccess({})
	-- end
	if completeRequest and rankRequest then ConnectionManager:flush() end
end

function GamePlaySceneUI:onTimeModeStart(...)
	assert(#{...} == 0)
	-- self.gamePlayScene:setGameStart()
end

function GamePlaySceneUI:pause(...)
	assert(#{...} == 0)

	self.gamePlayScene:setGameStop()
end


function GamePlaySceneUI:continue(...)
	assert(#{...} == 0)

	self.gamePlayScene:setGameRemuse()
end

--@param onTop 是否在最上层
function GamePlaySceneUI:reorderTargetPanel(onTop)
	local parent = self.levelTargetPanel.layer:getParent()
	if not parent then return end 
	if onTop then 
		if parent ~= self then 
			setTimeOut(function ()
				if self.isDisposed then return end 
				self.levelTargetPanel.layer:removeFromParentAndCleanup(false)
				self:addChild(self.levelTargetPanel.layer)
				self.levelTargetPanel:shakeForFuuu()
			end, 0.5)
		end
	else
		if parent ~= self.levelTargetLayer then 
			self.levelTargetPanel.layer:removeFromParentAndCleanup(false)
			self.levelTargetLayer:addChild(self.levelTargetPanel.layer)
		end
	end
end

function GamePlaySceneUI:setItemTouchEnabled(enable)
	self.propList:setItemTouchEnabled(enable)
end

function GamePlaySceneUI:setPropState(itemId, reasonType, enable)
	-- type: 1. game init 2. has used in this round
	self.propList:setPropState(itemId, reasonType, enable)
	-- self.propList:setRevertPropDisable(GamePropsType.kBack_b, reasonType)
end

function GamePlaySceneUI:setPauseBtnEnable(enable, ...)
	assert(type(enable) == "boolean")
	assert(#{...} == 0)

	-- if enable then
	-- 	self.pauseBtn:setTouchEnabled(true)
	-- 	self.pauseBtn:setButtonMode(true)
	-- else
	-- 	-- Disable
	-- 	self.pauseBtn:setTouchEnabled(false)
	-- 	self.pauseBtn:setButtonMode(false)
	-- end
	if enable then
		self.topArea:setPauseBtnEnable(true)
	else
		self.topArea:setPauseBtnEnable(false)
	end
end

function GamePlaySceneUI:playPreGamePropAddStepAnim(itemData, animationCallback, ...)
	assert(itemData)
	assert(#{...} == 0)

	--这里的判断 用来加一些不在开始面板上显示的临时道具
	if not itemData.destXInWorldSpace then 
		self.gameBoardLogic:preGameProp(itemData.id) 
		local function delayCallback()
			if not self.isDisposed then
				animationCallback()
			end
		end
		setTimeOut(delayCallback, 0.1)
		return 
	end

	local anim = PropsAnimation:createAdd3Anim()
	anim:setPositionX(itemData.destXInWorldSpace)
	anim:setPositionY(itemData.destYInWorldSpace)
	self:addChild(anim)

	anim:addEventListener(Events.kComplete,function( ... )
		
		self.moveOrTimeCounter.addEffect = true
		self.gameBoardLogic:preGameProp(itemData.id)
		self.moveOrTimeCounter.addEffect = false

		self:runAction(CCSequence:createWithTwoActions(
			CCDelayTime:create(1),
			CCCallFunc:create(animationCallback)
		))
	end)

	anim:play()
end

function GamePlaySceneUI:playCommonAddPrePropEffect(buffType, itemData, lineData, wrapData, flyFinishedCallback, animFinishCallback, ...)
	local effectAmount = 1
	local linePos, wrapPos, assetName
	local useBlueTailFirst = false

	if buffType == InitBuffType.LINE_WRAP then
		effectAmount = 2
		linePos = lineData.pos
		wrapPos = wrapData.pos
		assetName = "wrap/anim"
		useBlueTailFirst = true
	elseif buffType == InitBuffType.LINE then
		linePos = lineData.pos
		assetName = "wrap/anim2"
		useBlueTailFirst = true
	else
		wrapPos = wrapData.pos
		if buffType == InitBuffType.WRAP then
			assetName = "wrap/anim1"
		elseif buffType == InitBuffType.RANDOM_BIRD then
			assetName = "wrap/anim_bird"
		elseif buffType == InitBuffType.BUFF_BOOM then
			assetName = "wrap/anim_boom"
		elseif buffType == InitBuffType.FIRECRACKER then
			assetName = "wrap/anim_firecracker"
		end
	end
	local anim = PropsAnimation:createPrePropsAnim(assetName, linePos, wrapPos, useBlueTailFirst)
	anim:setPositionX(itemData.destXInWorldSpace)
	anim:setPositionY(itemData.destYInWorldSpace)
	self:addChild(anim)

	anim:addEventListener(Events.kComplete,function( ... )
		flyFinishedCallback()

		local counter = 0
		local function effectFinish( ... )
			counter = counter + 1
			if counter >= effectAmount then
				animFinishCallback()
			end
		end

		if linePos then
			PropsAnimation:playLineEffect(lineData.type, lineData.r, lineData.c, self.gameBoardView, effectFinish)
		end
		if wrapPos then
			PropsAnimation:playWrapEffect(wrapData.r, wrapData.c, self.gameBoardView, effectFinish)
		end
	end)

	anim:play()
end

function GamePlaySceneUI:playGiveBackPreProp(itemData, callback)
	local realPropId = ItemType:getRealIdByTimePropId(itemData.id)
	local animName = nil
	if realPropId == GamePropsType.kBuffBoom_b then
		animName = "wrap/anim_boom"
	elseif realPropId == GamePropsType.kRandomBird_b then
		animName = "wrap/anim_bird"
	elseif realPropId == GamePropsType.kLineBomb_b then
		animName = "wrap/anim2"
	elseif realPropId == GamePropsType.kWrapBomb_b then
		animName = "wrap/anim1"
	elseif realPropId == GamePropsType.kWrap_b then
		animName = "wrap/anim"
	end
	if animName then
		local anim = PropsAnimation:createGiveBackAnim(animName, realPropId, callback)
		anim:setPositionX(itemData.destXInWorldSpace)
		anim:setPositionY(itemData.destYInWorldSpace)
		self:addChild(anim)
		anim:play()
	else
		if callback then callback() end
	end
end

function GamePlaySceneUI:playPreGamePropAddToBarAnim(itemData, animFinishCallback , fromGuide)
	local itemFound, itemIndex = self.propList:findItemByItemID(PropsModel.kTempPropMapping[tostring(itemData.id)])
	if not itemFound then
		local function delayCallback()
			if not self.isDisposed then
				animFinishCallback()
			end
		end
		setTimeOut(delayCallback, 0.1)
		return
	end
	local toPos = self.propList.leftPropList:ensureItemInSight(itemFound, 0.3)

	local anim = PropsAnimation:createAddToBarAnim(toPos)
	anim:setPositionX(itemData.destXInWorldSpace)
	anim:setPositionY(itemData.destYInWorldSpace)
	self:addChild(anim)

	anim:addEventListener(Events.kComplete,function( ... )
		if fromGuide then
			PropsModel:instance():addTemporary({itemId=itemData.id,itemNum=1})
		end
		self.propList:flushTemporaryProps(ccp(0,0), function( ... )end,true)
		self.propList:flushFakeProps()
		PropsAnimation:playAddToBarEffect(itemFound,animFinishCallback)
	end)

	anim:play()
end

function GamePlaySceneUI:onEnterHandler(event, ...)
end

function GamePlaySceneUI:onEnterBackground()
	if self.replayRecordController then
		self.replayRecordController:onEnterForeGround()
	end
end

function GamePlaySceneUI:onEnterForeGround()
	if _G.isLocalDevelopMode then printx(0, 'today debug GamePlaySceneUI:onEnterForeGround') end
	if self._isBuyPropPause == true then
		if _G.isLocalDevelopMode then printx(0, 'today debug _isBuyPropPause == true') end
		if self.androidPaymentLogic and self.androidPaymentLogic:hasPanelPopOutOnScene() then 
			--maybe do sth
			if _G.isLocalDevelopMode then printx(0, "GamePlaySceneUI:onEnterForeGround()====self.androidPaymentLogic:hasPanelPopOutOnScene()") end
		elseif self.buyPropPanel and self.buyPropPanel:getActiveIngamePayLogic() and self.buyPropPanel:getActiveIngamePayLogic():hasPanelPopOutOnScene() then
			if _G.isLocalDevelopMode then printx(0, "GamePlaySceneUI:onEnterForeGround()====self.buyPropPanel:getActiveIngamePayLogic():hasPanelPopOutOnScene()") end
		else
			self.gamePlayScene:setGameRemuse()
			self._isBuyPropPause = false
		end
	end
	if self.replayRecordController then
		self.replayRecordController:onEnterForeGround()
	end
end

function GamePlaySceneUI:useRemindPrepropCallback(itemIds, callback)
	local preItems = {}
	for k, v in ipairs(itemIds) do
		local tmpItem = {}
		tmpItem.id = tonumber(v.itemId)
		tmpItem.destXInWorldSpace = tonumber(v.destXInWorldSpace)
		tmpItem.destYInWorldSpace = tonumber(v.destYInWorldSpace)
		table.insert(self.selectedItemsData, tmpItem)
		table.insert(preItems, tmpItem)

		StageInfoLocalLogic:addPropsUsedInLevel(UserManager:getInstance().uid, tonumber(v.itemId)) -- 开始游戏提示使用道具记录
	end
	GameInitBuffLogic:useRemindPreItems(preItems, callback)

	--ReplayDataManager:updateSelectedItemsData(self.selectedItemsData)
end

local tipPanelHasPop = true--禁用该tip
function GamePlaySceneUI:playPrePropAnimation(completeCallback , fromGuide)
	-- Ensure Only Called Once
	if self.enterGameAnimPlayed then return end
	if not self.enterGameAnimPlayed then
		self.enterGameAnimPlayed = true
	end
	local hasPrePropAnim = false

	if GameInitBuffLogic:hasAnyInitBuffIncludedReplay() then
		GameInitBuffLogic:tryFindBuffPos()
	end

	for k,v in pairs(self.selectedItemsData) do
		local preGamePropType = ItemType:getPrePropType(v.id)
		if PrePropType.ADD_STEP == preGamePropType then
			StageInfoLocalLogic:addPropsUsedInLevel(UserManager:getInstance().uid, v.id)
			GainAndConsumeMgr.getInstance():consumeItem(DcFeatureType.kStagePlay, v.propId, 1, self.levelId, nil, DcSourceType.kPreProp)
		elseif PrePropType.TAKE_EFFECT_IN_BOARD == preGamePropType then
			self.useItem = true
			if table.find(self.selectedItemsData, function(v) 
				return v.id == ItemType.PRE_WRAP_BOMB 
				or v.id == ItemType.PRE_LINE_BOMB 
				or v.id == ItemType.TIMELIMIT_PRE_WRAP_BOMB 
				or v.id == ItemType.TIMELIMIT_PRE_LINE_BOMB
			end) then
				GameGuideData:sharedInstance():setNewPreProp(true)
			end
			StageInfoLocalLogic:addPropsUsedInLevel(UserManager:getInstance().uid, v.id)
			GainAndConsumeMgr.getInstance():consumeItem(DcFeatureType.kStagePlay, v.propId, 1, self.levelId, nil, DcSourceType.kPreProp)
		elseif PrePropType.ADD_TO_BAR == preGamePropType then
		else
			assert(false)
		end
	end
	GameInitBuffLogic:doUsePreProps(self.selectedItemsData, completeCallback)
end

function GamePlaySceneUI:playUFOHitAnimation()
	if self.ufo then 
		self.ufo:playHitByRocket()
	end
end

function GamePlaySceneUI:playUFORecoverAnimation()
	if self.ufo then
		self.ufo:playUFORecover()
	end
end

function GamePlaySceneUI:forceUpdateUFOStatus(status)
	if not self.ufo then return end
	if self.ufo.ufoStatus ~= status then
		self.ufo:forceUpdateUFOStatus(status)
	end
end

function GamePlaySceneUI:getUFOStayPositionInBoard()
	if not self.ufo then return nil end
	return self.ufo:getStayPositionInBoard()
end

function GamePlaySceneUI:playUFOReFlyInotAnimation( completeCallback)
	-- body
	if not self.ufo then return end
	local function callback( ... )
		-- body
		if completeCallback then completeCallback() end
	end
	local toPosition, posInBoard = GameExtandPlayLogic:getUFOPosition(self.gameBoardLogic)
	self.ufo:playAnimation_reFlyin(toPosition, callback)
	self.ufo:setStayPositionInBoard(posInBoard)
end

function GamePlaySceneUI:playUFOFlyIntoAnimation( completeCallback, ufotype )
	-- body
	local ufo_sprite = UFOAnimation:create(ufotype)
	self.effectLayer:addChild(ufo_sprite)
	local toPosition, posInBoard = GameExtandPlayLogic:getUFOPosition(self.gameBoardLogic)
	ufo_sprite:playAnimation_firstFlyin(toPosition , completeCallback)
	ufo_sprite:setStayPositionInBoard(posInBoard)
	self.ufo = ufo_sprite
end

function GamePlaySceneUI:playUFOPullAnimation(isPull)
	-- body
	if not self.ufo then return end
	local function callback( ... )
		if isPull then
			self.ufo:playAnimation_pull()
		end
	end

	local toPosition, posInBoard = GameExtandPlayLogic:getUFOPosition(self.gameBoardLogic)
	local action = CCMoveTo:create(0.1, toPosition)
	self.ufo:runAction(CCSequence:createWithTwoActions(action, CCCallFunc:create(callback)))
	self.ufo:setStayPositionInBoard(posInBoard)
end

function GamePlaySceneUI:playChangePeriodAnimation(periodNum, callback)
	assert(type(periodNum) == 'number')
	local txt = Sprite:createWithSpriteFrameName('rabbit_text'..periodNum..' instance 1')
	txt.dispose = function(_self) if _G.isLocalDevelopMode then printx(0, '*********** disposing txt') end Sprite.dispose(_self) end
	local function localCB()
		if txt and not txt.isDisposed then
			txt:removeFromParentAndCleanup(true)
		end
		callback()	
	end
	local a = CCArray:create()
	a:addObject(CCEaseExponentialOut:create(CCSpawn:createWithTwoActions(CCFadeIn:create(0.5), CCScaleTo:create(0.5, 1))))
	a:addObject(CCDelayTime:create(2))
	a:addObject(CCEaseExponentialOut:create(CCSpawn:createWithTwoActions(CCFadeOut:create(0.5), CCScaleTo:create(0.5, 1.3, 0.9))))
	a:addObject(CCCallFunc:create(localCB))
	local action = CCSequence:create(a)
	txt:runAction(action)
	Director:sharedDirector():getRunningScene():addChild(txt)
	local vo = Director:sharedDirector():getVisibleOrigin()
	local vs = Director:sharedDirector():getVisibleSize()
	txt:setPosition(ccp(vo.x + vs.width / 2, vo.y + vs.height / 2 + 70))

end

function GamePlaySceneUI:playUFOFlyawayAnimation( completeCallback )
	-- body
	if not self.ufo then return end
	self.ufo:playAnimation_flyOut(completeCallback)
end

function GamePlaySceneUI:getTopAreaHeight()
	local vSize = CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local topY = visibleOrigin.y + vSize.height
	
	local boardPos = self.gameBoardView:getPosition()
	local sizeHeight = self.gameBoardView.bgSizeHeight
	local boardY = self.gameBoardView:getParent():convertToWorldSpace(ccp(boardPos.x, boardPos.y + sizeHeight)).y

	local topAreaHeight = topY - boardY

	return topAreaHeight
end

function GamePlaySceneUI:getTargetScaleAndPosY(gamePlayType)
	local scale = 1
	local posY = 0
	if gamePlayType == GameModeTypeId.MAYDAY_ENDLESS_ID then 
		local oriSizeHeight = 240	--潜艇默认高度
		local topAreaHeight = self:getTopAreaHeight()
		local margin = 10
		local minFitHeight = oriSizeHeight + margin * 2
		if topAreaHeight < minFitHeight then 
			local scaleHeight = topAreaHeight - margin * 2
			scale = scaleHeight / oriSizeHeight
			posY = (topAreaHeight - scaleHeight) / 2
		else
			posY = (topAreaHeight - oriSizeHeight) / 2
		end
	end
	return scale, posY
end

function GamePlaySceneUI:playLevelTargetPanelAnim(completeCallback , noAnimation)
	local gamePlayType = self.gamePlayType

	local scale, posY = self:getTargetScaleAndPosY(gamePlayType)
	self.levelTargetPanel = LevelTargetAnimationFactory:createLevelTargetAnimation(gamePlayType, 200, posY, self.levelType)
	self.levelTargetPanel:setTargetScale(scale)

	local function onLevelTargetAnimationFinish()
		self:onGameAnimOver()
		completeCallback()
	end

	local function setDropDownMode(targetType)
		local levelMapManager = LevelMapManager.getInstance()
		local levelMeta		= levelMapManager:getMeta(self.levelId)
		assert(levelMeta)
		local gameData		= levelMeta.gameData
		assert(gameData)

		local ingredients	= gameData.ingredients
		assert(ingredients)
		local target = {{type=targetType, id=0, num=ingredients[1]}}
		self.targetType = targetType
		self.levelTargetPanel:setTargets(target, onLevelTargetAnimationFinish, onTimeModeStart , noAnimation)
	end
	-- Level Target Based On Level Type
	if gamePlayType == GameModeTypeId.NONE_ID then
		assert(false)
	elseif gamePlayType == GameModeTypeId.CLASSIC_MOVES_ID then
		local target = {{ type="move", id=0, num=self.curLevelScoreTarget[1]}}
		he_log_warning("move ?")
		self.targetType = "move"
		self.levelTargetPanel:setTargets(target, onLevelTargetAnimationFinish, onTimeModeStart , noAnimation)
	elseif gamePlayType == GameModeTypeId.CLASSIC_ID then
		local target = {{ type="time", id=0, num=self.curLevelScoreTarget[1]}}
		self.targetType = "time"
		self.levelTargetPanel:setTargets(target, onLevelTargetAnimationFinish, onTimeModeStart , noAnimation)

	elseif gamePlayType == GameModeTypeId.DROP_DOWN_ID then
		setDropDownMode("drop")
	elseif gamePlayType == GameModeTypeId.TASK_UNLOCK_DROP_DOWN_ID then
		setDropDownMode("acorn")
	elseif gamePlayType == GameModeTypeId.LIGHT_UP_ID then
		local iceNumber = self.gameBoardLogic.kLightUpTotal
		local target = {{type="ice", id=1, num=iceNumber}}
		self.targetType = "ice"
		self.levelTargetPanel:setTargets(target, onLevelTargetAnimationFinish, onTimeModeStart , noAnimation)
	elseif gamePlayType == GameModeTypeId.DIG_TIME_ID then
		assert(false, "not implemented !")
	elseif gamePlayType == GameModeTypeId.ORDER_ID
	    or gamePlayType == GameModeTypeId.SEA_ORDER_ID then
		self.targetType = "order"
		local targetTable = {}

		local orderList		= self.gameBoardLogic:getViewableOrderList()
		for index,orderData in ipairs(orderList) do

			local targetType	= false
			local id		= false
			local num		= false

			-- Get The Target Type
			targetType = self:convertToLevelTargetAnimationOrderType(orderData.key1)

			-- Get The Id
			id = orderData.key2

			-- Get The Number
			num = orderData.v1

			local target = {type = targetType, id = id, num = num}
			table.insert(targetTable, target)
		end

		self.levelTargetPanel:setTargets(targetTable, onLevelTargetAnimationFinish, onTimeModeStart , noAnimation)
	elseif gamePlayType == GameModeTypeId.DIG_MOVE_ENDLESS_ID then
		if _isQixiLevel then
			local jewelNum = math.pow(2, 32) - 1
			local target = {{type="dig_move_endless_qixi", id=1, num=0}}	
			self.targetType = "dig_move_endless_qixi"
			self.levelTargetPanel:setTargets(target, onLevelTargetAnimationFinish, onTimeModeStart , noAnimation)
		else
			local jewelNum = math.pow(2, 32) - 1
			local target = {{type="dig_move_endless", id=1, num=0}}	
			self.targetType = "dig_move_endless"
			self.levelTargetPanel:setTargets(target, onLevelTargetAnimationFinish, onTimeModeStart , noAnimation)
		end
	elseif gamePlayType == GameModeTypeId.DIG_MOVE_ID then
		local jewelNum = self.gameBoardLogic.digJewelLeftCount
		local target = {{type="dig_move", id=1, num=jewelNum}}	
		self.targetType = "dig_move"
		self.levelTargetPanel:setTargets(target, onLevelTargetAnimationFinish, onTimeModeStart , noAnimation)
		-- 感恩节和mayday一模一样，只是替换素材
	elseif gamePlayType == GameModeTypeId.MAYDAY_ENDLESS_ID 
		or gamePlayType == GameModeTypeId.HALLOWEEN_ID 
		or gamePlayType == GameModeTypeId.WUKONG_DIG_ENDLESS_ID 
		or gamePlayType == GameModeTypeId.MOLE_WEEKLY_RACE_ID 
		then
		local targetTypeName = nil
		if self.levelType == GameLevelType.kSummerWeekly then
			targetTypeName = "summer_weekly"
		elseif self.levelType == GameLevelType.kWukong then
			targetTypeName = kLevelTargetType.wukong
        elseif self.levelType == GameLevelType.kMoleWeekly then
			targetTypeName = kLevelTargetType.moleWeekly
		else
			targetTypeName = "dig_move_endless_mayday"
		end

		local jewelnum = math.pow(2, 32) - 1
		local target = 
		{
			{type= targetTypeName, id=1, num=0},
			--{type= targetTypeName, id=2, num =0},
		}	

		-- if GamePlaySceneSkinManager:isHalloweenLevel() then 
		-- 	table.insert(target, {type= targetTypeName, id=2, num=0})
		-- end

		self.targetType = targetTypeName
		self.levelTargetPanel:setTargets(target, onLevelTargetAnimationFinish, onTimeModeStart , noAnimation)
	elseif gamePlayType == GameModeTypeId.RABBIT_WEEKLY_ID then
		local target = {{type="rabbit_weekly", id=1, num=0}}	
		self.targetType = "rabbit_weekly"
		self.levelTargetPanel:setTargets(target, onLevelTargetAnimationFinish, onTimeModeStart , noAnimation)
	elseif gamePlayType == GameModeTypeId.HEDGEHOG_DIG_ENDLESS_ID then
		local targetTypeName = "hedgehog_endless"
		local target = {
			{type= targetTypeName, id=1, num=0},
		}
		self.targetType = targetTypeName
		self.levelTargetPanel:setTargets(target, onLevelTargetAnimationFinish, onTimeModeStart , noAnimation)
	elseif gamePlayType == GameModeTypeId.LOTUS_ID then
		local target = {{ type= kLevelTargetType.order_lotus , id=1, num=self.gameBoardLogic.currLotusNum }}
		self.targetType = kLevelTargetType.order_lotus
		self.levelTargetPanel:setTargets(target, onLevelTargetAnimationFinish, onTimeModeStart , noAnimation)
	elseif gamePlayType == GameModeTypeId.OLYMPIC_HORIZONTAL_ENDLESS_ID then
		local iceNumber = 0
		local target = {}
		self.targetType = kLevelTargetType.olympic_2016
		self.levelTargetPanel:setTargets(target, onLevelTargetAnimationFinish, onTimeModeStart , noAnimation)
	elseif gamePlayType == GameModeTypeId.SPRING_HORIZONTAL_ENDLESS_ID then
		local target = {}
		self.targetType = kLevelTargetType.spring_2017
		self.levelTargetPanel:setTargets(target, onLevelTargetAnimationFinish, onTimeModeStart , noAnimation)
    elseif gamePlayType == GameModeTypeId.JAMSPREAD_ID then
		local target = {}
--		self.targetType = kLevelTargetType.JamSperad
--		self.levelTargetPanel:setTargets(target, onLevelTargetAnimationFinish, onTimeModeStart , noAnimation)

        self.targetType = "order"
		local targetTable = {}

		local orderList		= self.gameBoardLogic.theOrderList
		for index,orderData in ipairs(orderList) do

			local targetType	= false
			local id		= false
			local num		= false

			-- Get The Target Type
			targetType = self:convertToLevelTargetAnimationOrderType(orderData.key1)

			-- Get The Id
			id = orderData.key2

			-- Get The Number
            num = orderData.v1
			
			local target = {type = targetType, id = id, num = num}
			table.insert(targetTable, target)
		end
        self.levelTargetPanel:setTargets(targetTable, onLevelTargetAnimationFinish, onTimeModeStart , noAnimation)
	else
		assert(false)
	end

	-- -----------------------
	-- Center The Target Panel
	-- -----------------------
	local alignLeftX	= 84
	local counterSize = self.moveOrTimeCounter:getGroupBounds().size
	local alignRightX	= self.moveOrTimeCounter:getPositionX() - counterSize.width/2
	local targetPanelSize	= self.levelTargetPanel:getTopContentSize()

	local deltaWidth	= alignRightX - alignLeftX - targetPanelSize.width
	local halfDeltaWidth	= deltaWidth / 2
	local centerPosX	= alignLeftX + halfDeltaWidth

    if gamePlayType == GameModeTypeId.MOLE_WEEKLY_RACE_ID  then

        local mainLogic = GameBoardLogic:getCurrentLogic()
        local bgScale = 1
        local offset = -130
        if mainLogic and mainLogic.PlayUIDelegate then
            local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
            if __isWildScreen then  
		        bgScale = visibleSize.width/960
                offset = -130-24/0.7
            end
        end
        self.levelTargetPanel:setPosX(centerPosX+offset)
    else
	    self.levelTargetPanel:setPosX(centerPosX)
    end
	self.levelTargetPanel.layer:setPositionY(self.levelTargetPanel.layer:getPositionY() + _G.__EDGE_INSETS.top / 3)
	self.levelTargetLayer:addChild(self.levelTargetPanel.layer)

	if gamePlayType == GameModeTypeId.MAYDAY_ENDLESS_ID then 
		self.levelTargetPanel:setTargetContainer(self.levelTargetLayer)
		self.levelTargetPanel:addTargets(false)

		local index = self:getChildIndex(self.topArea)
		self.levelTargetLayer:removeFromParentAndCleanup(false)
		self:addChildAt(self.levelTargetLayer, index)
	end
end

local goodsId = require('zoo.payment.buyProp.PropIdMapGoodsId'):getOldMap()

local function getGoodsId(propId)
	if propId == 10052 then
		local discountGoodsId = 148
		local goodsInfo = GoodsIdInfoObject:create(discountGoodsId)
		local discountOneYuanGoodsId = goodsInfo:getOneYuanGoodsId()
		local buyed = UserManager:getInstance():getDailyBoughtGoodsNumById(discountGoodsId)
		local buyedOneYuan = UserManager:getInstance():getDailyBoughtGoodsNumById(discountOneYuanGoodsId)
		if buyed > 0 or buyedOneYuan > 0 then
			return 147 
		else 
			return 148
		end
	else
		return goodsId[propId]
	end
end

function GamePlaySceneUI:buyPropCallback(propId, ...)
	assert(type(propId) == "number")
	assert(#{...} == 0)

	if _G.isLocalDevelopMode then printx(0, "GamePlaySceneUI:buyPropCallback Called !") end
	if _G.isLocalDevelopMode then printx(0, "propId: " .. propId) end

	if PublishActUtil:isGroundPublish() then
		CommonTip:showTip(Localization:getInstance():getText("本轮游戏只能使用该道具5次哦！"), "positive")
	else
		self.gamePlayScene:setGameStop()
		self._isBuyPropPause = true

		local function onBoughtCallback(propId, propNum, startPos)
			if _G.isLocalDevelopMode then printx(0, "onBoughtCallback", propId, propNum) end
			self:onBoughtCallback(propId, propNum)
			self.propList:setItemTouchEnabled(true)
			self.gamePlayScene:setGameRemuse()
			self._isBuyPropPause = false

			local function PropFlyAnimation()
				local endPos = self.propList:getItemCenterPositionById(propId)

				if not endPos then
					return
				end
				
				local runningScene = Director:sharedDirector():getRunningScene()
				local sprite = ResourceManager:sharedInstance():buildItemSprite(propId)
				runningScene:addChild(sprite)
				
				sprite:setAnchorPoint(ccp(0.5, 0.5))
				
				local startScale = 1.5
				local endScale = 0
				sprite:setPosition(startPos)
				sprite:setScale(startScale)


				local bezierConfig = ccBezierConfig:new() 
				local controlPoint = ccp((startPos.x + endPos.x)/2+(endPos.y-startPos.y)/4, (startPos.y + endPos.y)/2+(-endPos.x+startPos.x)/4)
				bezierConfig.controlPoint_1 = controlPoint
				bezierConfig.controlPoint_2 = controlPoint
				bezierConfig.endPosition = endPos
				local moveAction = CCEaseSineInOut:create(CCBezierTo:create(0.5, bezierConfig))

				local delayToScale = CCDelayTime:create(0.4)
				local scaleAction = CCScaleTo:create(0.5, endScale)
				local seqScale = CCSequence:createWithTwoActions(delayToScale, scaleAction)

				local finishAction = CCCallFunc:create(
					function ()
						sprite:removeFromParentAndCleanup(true)
					end
				)

				local spawn = CCSpawn:createWithTwoActions(moveAction, seqScale)
				local seq = CCSequence:createWithTwoActions(spawn, finishAction)
				sprite:runAction(seq)

				local shine = self.propList:findItemByItemID(propId).item:getChildByName("bg_selected")
				local oldOpacity = shine:getOpacity()
				local oldVisible = shine:isVisible()
				shine:setVisible(true)
				shine:setOpacity(0)
				local waitToFade = CCDelayTime:create(0.6)
				local fadeIn = CCFadeIn:create(0.3)
				local fadeOut = CCFadeOut:create(0.3)
				local finishShine = CCCallFunc:create(
					function()
						shine:setVisible(oldVisible)
						shine:setOpacity(oldOpacity)
					end
				)
				local arrayShine = CCArray:create()
				arrayShine:addObject(waitToFade)
				arrayShine:addObject(fadeIn)
				arrayShine:addObject(fadeOut)
				arrayShine:addObject(finishShine)
				local seqShine = CCSequence:create(arrayShine)
				shine:runAction(seqShine)

				--接收动画
				local spriteRecv = ResourceManager:sharedInstance():buildItemSprite(propId)
				runningScene:addChild(spriteRecv)
				spriteRecv:setAnchorPoint(ccp(0.5, 0.5))
				spriteRecv:setPositionXY(endPos.x, endPos.y)
				spriteRecv:setVisible(false)
				local actionArray = CCArray:create()
				actionArray:addObject(CCDelayTime:create(0.5))
				actionArray:addObject(CCCallFunc:create(
						function()
							spriteRecv:setVisible(true)
						end
					)
				)
				actionArray:addObject(CCScaleBy:create(3/24,1.3,1.3))
				actionArray:addObject(CCScaleBy:create(2/24,1/1.3,1/1.3))
				actionArray:addObject(CCCallFunc:create(
						function()
							spriteRecv:removeFromParentAndCleanup(true)
						end
					)
				)
				spriteRecv:runAction(CCSequence:create(actionArray))

			end

			if startPos ~= nil then
				local spawnArray = CCArray:create()
				for i=1, propNum do
					local seqArray = CCArray:create()
					seqArray:addObject(CCDelayTime:create((i-1)*0.2))
					seqArray:addObject(CCCallFunc:create(PropFlyAnimation))
					spawnArray:addObject(CCSequence:create(seqArray))
				end
				local spawn = CCSpawn:create(spawnArray)
				self:runAction(spawn)
			end

			self.buyPropPanel = nil
		end
		local function onExitCallbackFail(errCode, errMsg)
			if _G.isLocalDevelopMode then printx(0, "onExitCallback") end
			if __ANDROID then 
				if errCode == 730241 or errCode == 730247 or errCode == -1000061 then
					CommonTip:showTip(errMsg, "negative")
				else
					--TODO:這裡有可能多次彈出失敗面板
					CommonTip:showTip(Localization:getInstance():getText("buy.gold.panel.err.undefined"), "negative")
				end
			end
			self.propList:setItemTouchEnabled(true)
			self.gamePlayScene:setGameRemuse()
			self._isBuyPropPause = false
			self.androidPaymentLogic = nil
			self.buyPropPanel = nil
		end
		local function onExitCallbackCancel()
			if _G.isLocalDevelopMode then printx(0, "onExitCallback") end
			self.propList:setItemTouchEnabled(true)
			self.gamePlayScene:setGameRemuse()
			self._isBuyPropPause = false
			self.androidPaymentLogic = nil
			self.buyPropPanel = nil
		end


		local function iOSPayFun( ... )
			--on IOS and PC we use gold!
			if self.isDisposed then return end
			self.propList:setItemTouchEnabled(false)
			local function onSuccess(buyNum, startPos)
				buyNum = buyNum or 1
				onBoughtCallback(propId, buyNum, startPos)
			end
			local panel = PayPanelWindMill_VerB:create(getGoodsId(propId), onSuccess, onExitCallbackCancel)
			if panel then 
				panel:setFeatureAndSource(DcFeatureType.kStagePlay, DcSourceType.kIngamePropBuy)
				panel:popout() 
			end
		end 


		-- if __ANDROID then -- ANDROID
			
		-- 	if PlatformConfig:isQQPlatform() then
		-- 		--应用宝用户正交分组 50%的用户 直接使用风车币购买 
		-- 	    if MaintenanceManager:getInstance():isEnabledInGroup("YingYongBaoBuyType1" , "A1" , UserManager:getInstance().user.uid or '12345') then
		-- 	    	iOSPayFun()
		-- 	        return 
		-- 	    end
		-- 	end
			
		-- 	if _G.isLocalDevelopMode then printx(0, "android", propId) end
			-- self.androidPaymentLogic = IngamePaymentLogic:create(getGoodsId(propId), GoodsType.kItem, DcFeatureType.kStagePlay, DcSourceType.kIngamePropBuy)
			-- self.androidPaymentLogic:setSourceFlag("inLevelByProps")
			-- local function onSuccess(buyNum, startPos)
			-- 	self.androidPaymentLogic = nil
			-- 	buyNum = buyNum or 1
			-- 	onBoughtCallback(propId, buyNum, startPos)
			-- end
			-- self.propList:setItemTouchEnabled(false)
			-- self.androidPaymentLogic:setRepayPanelPopFunc(function ()
			-- 	self.gamePlayScene:setGameStop()
			-- 	self._isBuyPropPause = true	
			-- end)
			-- self.androidPaymentLogic:buy(onSuccess, onExitCallbackFail, onExitCallbackCancel)

		-- else -- else, on IOS and PC we use gold!
		-- 	iOSPayFun()
		-- end
		local buyPropPanel = require('zoo.payment.buyProp.BuyPropPanel'):create()
		buyPropPanel:setPropId(propId)
		buyPropPanel:setCallback(onBoughtCallback, onExitCallbackFail, onExitCallbackCancel)
		buyPropPanel:popout()

		self.buyPropPanel = buyPropPanel
	end
end

function GamePlaySceneUI:setMoveOrTimeCountCallback(count, playAnim, skipFiveAnim)
	self.moveOrTimeCounter:setCount(count, playAnim)
	self.moveOrTimeCount = count
	if self.replayMode == ReplayMode.kStrategy then return end 

	self.propList:onGameMoveChange(count, playAnim)
	if not skipFiveAnim then
		if count > 0 and count <= 5 then
			if self.moveOrTimeCounter.counterType == MoveOrTimeCounterType.TIME_COUNT then
				if count == 5 then -- 时间关只在时间为5秒时震动一次，少于5秒时不再执行，防止打断动画
					self.moveOrTimeCounter:stopShaking()
					self.moveOrTimeCounter:shake()
				end
			else
				self.moveOrTimeCounter:stopShaking()
				self.moveOrTimeCounter:shake()
			end

			local function anim() self.moveOrTimeCounter:updateView(true) end
			self.moveOrTimeCounter:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCCallFunc:create(anim), CCDelayTime:create(1))))
		else
			self.moveOrTimeCounter:stopShaking()
		end
	end
end

function GamePlaySceneUI:useStepPropComplete( theCurMoves,propItemPos, deltaSteps)


	local anim 

	if type(deltaSteps) == 'number' and deltaSteps == 15 then
		anim = PropsAnimation:createAdd15Anim()
	else	
		anim = PropsAnimation:createAdd5Anim()
	end

	if self.usePropItemPos then
		anim:setPositionX(self.usePropItemPos.x)
		anim:setPositionY(self.usePropItemPos.y)	
	else
		local size = CCDirector:sharedDirector():getVisibleSize()
		local origin = CCDirector:sharedDirector():getVisibleOrigin()
		anim:setPositionX(origin.x + size.width/2)
		anim:setPositionY(origin.y + size.height/2)
	end
	self:addChild(anim)

	anim:addEventListener(Events.kComplete,function( ... )
		self.moveOrTimeCounter.addEffect = true
		self:setMoveOrTimeCountCallback(theCurMoves, false)
		self.moveOrTimeCounter.addEffect = false
	end)
	anim:play()
end

function GamePlaySceneUI:setInfiniteMoveCallback()
	self.moveOrTimeCounter:setInfinite()
end


function GamePlaySceneUI:onBoughtCallback(propId, propNum, ...)
	assert(type(propId) == "number")
	assert(type(propNum) == "number")
	assert(#{...} == 0)

	if _G.isLocalDevelopMode then printx(0, "GamePlaySceneUI:onBoughtCallback Called !") end
	if _G.isLocalDevelopMode then printx(0, "propId: " .. propId) end
	if _G.isLocalDevelopMode then printx(0, "propNum: " .. propNum) end

	self.propList:addItemNumber(propId, propNum)
end

function GamePlaySceneUI:onScoreChangeCallback(newScore, ...)
	assert(type(newScore) == "number")
	assert(#{...} == 0)

	if _G.isLocalDevelopMode then printx(0, "-------------------- New Score: " .. newScore .. " ---------------------------") end
	self:setTargetNumber(0, 0, newScore, ccp(0,0))
end

--[[
function GamePlaySceneUI:onGameInit(levelId)
	printx( 1 , "GamePlaySceneUI:onInit  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" )
	if _G.isLocalDevelopMode then printx(0, "*****GamePlaySceneUI:onGameInit") end
	if GameGuide then
		return GameGuide:sharedInstance():onGameInit(levelId) or false
	else
		return false
	end
end
]]

function GamePlaySceneUI:runTopLevelHint(endCallBack)
	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	local vSize = Director:sharedDirector():getVisibleSize()
	local anim = CommonSkeletonAnimation:createTutorialMoveIn()
	local sprite = Sprite:createEmpty()
	sprite:setScaleX(-1)
	sprite:setPositionXY(180, vOrigin.y + 460)
	local function animPlay() sprite:addChild(anim) end
	sprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5), CCCallFunc:create(animPlay)))
	local panel = GameGuideUI:panelMini("")
	local pText = panel.ui:getChildByName("text")
	local dimension = pText:getPreferredSize()
	local text = TextField:create("", nil, 32, dimension, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	text:setString(Localization:getInstance():getText("recall_text_2"))
	text:setColor(ccc3(0, 0, 0))
	text:setAnchorPoint(ccp(0, 1))
	text:setPositionXY(pText:getPositionX(), pText:getPositionY())
	panel.ui:addChild(text)
	pText:removeFromParentAndCleanup(true)
	panel:setPosition(ccp(-600, self:getRowPosY(8)))
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(1))
	local function animStop() anim:pause() end
	array:addObject(CCEaseBackOut:create(CCMoveTo:create(0.2, ccp(180, self:getRowPosY(8)))))
	array:addObject(CCDelayTime:create(2.4))
	array:addObject(CCCallFunc:create(animStop))
	array:addObject(CCDelayTime:create(1.9))
	local function animContinue() anim:resume() end
	array:addObject(CCCallFunc:create(animContinue))
	array:addObject(CCDelayTime:create(0.2))

	local function panFadeOut()
		if panel and not panel.isDisposed then
			local childrenList = {}
			panel:getVisibleChildrenList(childrenList)
			for __, v in pairs(childrenList) do
				v:runAction(CCFadeOut:create(0.5))
			end
		end
	end
	array:addObject(CCCallFunc:create(panFadeOut))
	array:addObject(CCDelayTime:create(0.5))
	local function onComplete() 
		self.guideLayer:removeChildren(true)
		if endCallBack then 
			endCallBack()
		end 
	end
	array:addObject(CCCallFunc:create(onComplete))
	panel:runAction(CCSequence:create(array))

	self.guideLayer:addChild(sprite)
	self.guideLayer:addChild(panel)
end

function GamePlaySceneUI:onGameAnimOver()
	if _G.isLocalDevelopMode then printx(0, "*****GamePlaySceneUI:onGameAnimOver") end


	-- ==活动临时的动画 begin

	local actAnim = self.otherElementsLayer:getChildByName('FTWAddStarAnim') or self.otherElementsLayer:getChildByName('FTWAddLevelAnim')
	if actAnim then
		actAnim:playInitShow()
	end

	-- ==活动临时的动画 end


	local hasGuide = GameGuideData:sharedInstance():getRunningGuide() ~= nil
	
	if self.mask then
		self.mask:removeFromParentAndCleanup(true)
		self.mask = nil
	end

	if _G.isLocalDevelopMode then printx(0, "any guide is running?", hasGuide) end
	if not hasGuide and self.levelId < 10000 then	
		local gpt = self.gameBoardLogic.theGamePlayType
		if gpt == GameModeTypeId.CLASSIC_MOVES_ID 
			or gpt == GameModeTypeId.DROP_DOWN_ID 
			or gpt == GameModeTypeId.LIGHT_UP_ID 
			or gpt == GameModeTypeId.ORDER_ID then
				self:ingameBuyPropGuide()
		end
	end

	return hasGuide
end

function GamePlaySceneUI:gameGuideMask(opacity, array, allow, tileScale, violationCallback,useBrushProp)
	return self.gameBoardView:maskWithFewTouch(opacity, array, allow, tileScale, violationCallback, useBrushProp)
end

function GamePlaySceneUI:getPositionFromTo(from, to)
	return self.gameBoardView:getPositionFromTo(from, to)
end

function GamePlaySceneUI:getRowPosX(col)
	return self.gameBoardLogic:getGameItemPosInView(5, col).x
end

function GamePlaySceneUI:getRowPosY(row)
	return self.gameBoardLogic:getGameItemPosInView(row, 5).y
end

function GamePlaySceneUI:getMoveCountPos()
	return self.gameBoardView.moveCountPos
end

function GamePlaySceneUI:getPositionByIndex(index)
	return self.propList:getPositionByIndex(index)
end

function GamePlaySceneUI:getGlobalPositionUnit(r, c)
	return self.gameBoardLogic:getGameItemPosInView(r, c)
end

function GamePlaySceneUI:unloadResources()
	if type(self.fileList) == "table" then
		-- if __use_low_effect then 
			FrameLoader:unloadImageWithPlists( self.fileList, true )
		-- end

		if self.fileList.removeArmatureRes and type(self.fileList.removeArmatureRes) == "function" then
			self.fileList.removeArmatureRes()
			self.fileList.removeArmatureRes = nil
		end
	end
end

function GamePlaySceneUI:dispose()
	GlobalEventDispatcher:getInstance():removeEventListenerByName(kGlobalEvents.kShowReplayRecordPreview)
	if self.replayRecordController then
		self.replayRecordController:dispose()
		self.replayRecordController = nil
	end
	if self.disposResourceCache and self.fileList ~= nil then
		self:unloadResources()

		-- local function checkPngIsUnload( ... )
		-- 	-- body
		-- 	CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
		-- end
		-- CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(checkPngIsUnload, 10, false)
	end
	if _G.isLocalDevelopMode then printx(0, '*******************GamePlaySceneUI:dispose') end
	if _G.isLocalDevelopMode then printx(0, '_isQixiLevel = false') end
	if self.quitDcData then
		DcUtil:newLogUserStageQuit(self.quitDcData)
	end
	_isQixiLevel = false -- qixi
	self:onExitGame()

	Scene.dispose(self)

	if self.gamePlayType == GameModeTypeId.OLYMPIC_HORIZONTAL_ENDLESS_ID then
		OlympicResourceManager:unloadGameResources()
	end
	--StageInfoLocalLogic:clearStageInfo( UserManager.getInstance().user.uid )
	if _G.AutoCheckLeakInLevel and self.autoCheckLeakTag then
		stopObjectRefDebug(self.autoCheckLeakTag)
		dumpObjectRefDebugWithAlert(self.autoCheckLeakTag, true)
	end
end

function GamePlaySceneUI:onApplicationHandleOpenURL(launchURL)
	if _G.isLocalDevelopMode then printx(0, "*****************************************************") end
	if _G.isLocalDevelopMode then printx(0, "GamePlaySceneUI:onApplicationHandleOpenURL", launchURL) end
	if launchURL and string.len(launchURL) > 0 then
		local res = UrlParser:parseUrlScheme(launchURL)
		if not res.method or string.lower(res.method) ~= "addfriend" then return end
		if res.para and res.para.invitecode and res.para.uid and res.para.pid then
			local function onSuccess()
				local home = HomeScene:sharedInstance()
				if home and not home.isDisposed then
					home:checkDataChange()
					if home.coinButton and not home.coinButton.isDisposed then
					home.coinButton:updateView()
				end
				end
				CommonTip:showTip(Localization:getInstance():getText("url.scheme.add.friend"), "positive")
			end
			local function onUserHasLogin()
				local logic = InvitedAndRewardLogic:create(false)
				logic:start(res.para.invitecode, res.para.uid, res.para.pid, res.para.ext, onSuccess)
			end
			RequireNetworkAlert:callFuncWithLogged(onUserHasLogin, nil, kRequireNetworkAlertAnimation.kNoAnimation)
		end
	end
end

function GamePlaySceneUI:setMoveOrTimeStage(stageNumber)
	self.moveOrTimeCounter:setStageNumber(stageNumber)
end

function GamePlaySceneUI:promptBackProp()
	if _G.isLocalDevelopMode then printx(0, "start promptBackProp: ") end
	-- 把回退道具拖到屏幕中间，然后才去取坐标
	self.propList:moveBackPropToCenter()
	local backProp, index = self.propList:findItemByItemID(10002)
	if not backProp then return end
	if not backProp.prop then return end
	if backProp.prop.usedTimes >= backProp.prop.maxUsetime then return end
	if _G.isLocalDevelopMode then printx(0, index, backProp.item:getPositionX(), backProp.item:getPositionY()) end
	-- local pos = backProp.item:getParent():convertToWorldSpace(backProp.item:getPosition())
	local vs = Director:sharedDirector():getVisibleSize()
	local vo = Director:sharedDirector():getVisibleOrigin()
	local node = CommonSkeletonAnimation:createTutorialMoveIn()
	local scene = Director:sharedDirector():getRunningScene()
	posArmature = ccp(vs.width - 200, vo.y + 250)
	node:setPosition(posArmature)
	scene:addChild(node)
	node:setAnimationScale(0.3)
	backProp.animator:hint(1)
	-- CommonTip:showTip(Localization:getInstance():getText('no.venom.tips'), "positive", nil, 5)
	local builder = InterfaceBuilder:create("flash/scenes/homeScene/homeScene.json")
	local tip = GameGuideUI:panelMini('no.venom.tips')
	-- tip:getChildByName('txt'):setString(Localization:getInstance():getText('no.venom.tips'))
	-- tip:getChildByName('bg'):setScaleX(-1)
	-- tip:getChildByName('bg'):setAnchorPoint(ccp(1, 1))
	local posTip = ccp(vo.x + vs.width / 2 - tip:getGroupBounds().size.width / 2, posArmature.y + 110)
	local tipStartPos = ccp(vs.width + 300, posTip.y)
	tip:setPosition(tipStartPos)
	tip:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.3), CCEaseExponentialOut:create(CCMoveTo:create(0.3, posTip))))
	scene:addChild(tip)
	local function remove()
		if node and node.refCocosObj then node:runAction(
				CCSequence:createWithTwoActions(
					CCDelayTime:create(0.5),
					CCCallFunc:create(
						function () 
							if node and node.refCocosObj then 
								node:removeFromParentAndCleanup(true) 
							end 
						end)
				)
			)  
		end
		if tip and tip.refCocosObj then 
			tip:runAction(CCSequence:createWithTwoActions(
				CCEaseExponentialIn:create(CCMoveTo:create(0.3, tipStartPos)),
				CCCallFunc:create(
					function () 
						if tip and tip.refCocosObj then 
							tip:removeFromParentAndCleanup(true) 
						end
					end))
			)  
		end
	end
	setTimeOut(remove, 5)

end

function GamePlaySceneUI:setFireworkEnergy(energy)
	self.propList:setSpringItemEnergy(energy, self.gameBoardLogic.theCurMoves)
end

function GamePlaySceneUI:getFireworkEnergy()
	local item = self.propList:findSpringItem()
	if item then
		return item:getTotalEnergy()
	else
		if _G.isLocalDevelopMode then printx(0, "@@@@@@@@@@@@cannot find spring item!!!!!!!!!!!!!") end
		return 0
	end
end

function GamePlaySceneUI:setFireworkPercent(percent)
	self.propList:setSpringItemPercent(percent)
end

function GamePlaySceneUI:resetFireworkStatusForRevert(currEnergy)
	local item = self.propList:findSpringItem()
	if item then
		item:resetConfig()
		item:setEnergy(currEnergy, self.gameBoardLogic.theCurMoves)
	end
end

function GamePlaySceneUI:useSpringItemCallback(notUseEnergy, noReplayRecord)

    if self.levelType == GameLevelType.kMoleWeekly then

        local curt3 = 2
        if notUseEnergy == true then
            curt3 = 1
        end
        -- 关卡大招使用情况打点
        local boss = self.gameBoardLogic:getMoleWeeklyBossData()
        local bossHP = 0
        if boss then
            bossHP = boss.totalBlood - boss.hit
        end

        local dcData = {
	        game_type = "stage",
	        game_name = "",
	        category = "weeklyrace2018",
	        sub_category = "weeklyrace2018_use_skill",
	        t1 = self.gameBoardLogic.level,
	        t2 = bossHP,
            t3 = curt3,
        }
        DcUtil:activity(dcData)
    end

	self.gameBoardLogic:useMegaPropSkill(notUseEnergy, noReplayRecord)
end

function GamePlaySceneUI:playSpringCollectEffect(itemPosition)
	local targetPosition = self.propList:getSpringItemGlobalPosition()
	local r = 16 + math.random() * 10
	local batch = self
	local localPosition = batch:convertToNodeSpace(itemPosition)
	for i = 1, 20 do	
		if math.random() > 0.6 then
			local angle = i * 36 * 3.1415926 / 180
			local x = localPosition.x + math.cos(angle) * r
			local y = localPosition.y + math.sin(angle) * r
			local sprite = SpriteColorAdjust:createWithSpriteFrameName("game_collect_small_star0000")
			-- sprite:adjustColor(1, 1,-0.05,0.1)
   --      	sprite:applyAdjustColorShader()
			sprite:setPosition(ccp(localPosition.x, localPosition.y))
			sprite:setScale(math.random()*1.5 + 1)
			sprite:setOpacity(0)
			local moveTime = 0.3 + math.random() * 0.64
			local moveTo = CCMoveTo:create(moveTime, ccp(targetPosition.x + math.random(1, 10), targetPosition.y + math.random(1, 10)))
			local function onMoveFinished( ) sprite:removeFromParentAndCleanup(true) end
			local moveIn = CCEaseElasticOut:create(CCMoveTo:create(0.25, ccp(x, y)))
			local array = CCArray:create()
			array:addObject(CCSpawn:createWithTwoActions(moveIn, CCFadeIn:create(0.25)))
			array:addObject(CCEaseSineIn:create(moveTo))
			array:addObject(CCFadeOut:create(0.2))
			array:addObject(CCCallFunc:create(onMoveFinished))
			sprite:runAction(CCSequence:create(array))
			batch:addChild(sprite)
		end
	end
end

function GamePlaySceneUI:addSquirrelAnimation( ... )
	-- body
	local squirrel = TileSquirrel:create()
	self.otherElementsLayer:addChild(squirrel)
	local toPosition = self.gameBoardLogic:getGameItemPosInView(9, 5)
	squirrel:setPosition(toPosition)
	self.squirrel = squirrel
	self.squirrel.old_c = 5
end

function GamePlaySceneUI:playSquirrelGotAcronAnimation( pos_c )
	-- body
	if self.squirrelGettingAcorn then return end

	self.squirrelGettingAcorn = true
	local function callback( ... )
		-- body
		self.squirrelGettingAcorn = false
	end

	local function actionFunc( ... )
		-- body
		self.squirrel:playGetAnimation(callback)
	end
	self.squirrel:stopAllActions()
	local pos = self.gameBoardLogic:getGameItemPosInView(9, pos_c)
	local action_move = CCMoveTo:create(0.1, pos)
	local action_func = CCCallFunc:create(actionFunc)
	self.squirrel.old_c = pos_c
	self.squirrel:runAction(CCSequence:createWithTwoActions(action_move, action_func))	
end

function GamePlaySceneUI:playSquirrelMoveAnimation( isReachEndCondition )
	-- body
	if self.squirrelGettingAcorn then return end

	local x = self.squirrel:getPositionX()
	local now_c, isDangerous = GameExtandPlayLogic:getSquirrelPosYinBoard(self.gameBoardLogic, self.squirrel.old_c)
	local pos = self.gameBoardLogic:getGameItemPosInView(9, now_c)
	if now_c == self.squirrel.old_c then 
		self.squirrel:playExcitingAnimation(false)
	else
		local function callback( ... )
		-- body
			local random_count = math.random(10)
			if isDangerous or random_count <= 9 then
				self.squirrel:playNormalAnimation()
			else
				self.squirrel:playDozeAnimation()
			end
		end
		self.squirrel.old_c = now_c
		self.squirrel:stopAllActions()
		local time = math.floor(math.abs(x - pos.x) / 70) * 0.6
		local action_delay = CCDelayTime:create(0.2)
		local action_move = CCMoveTo:create(time, pos)
		local action_func = CCCallFunc:create(callback)
		local arr = CCArray:create()
		arr:addObject(action_delay)
		arr:addObject(action_move)
		arr:addObject(action_func)
		self.squirrel:runAction(CCSequence:create(arr))

		self.squirrel:playMoveAnimation()
	end
end

function GamePlaySceneUI:playSquirrelGiveKeyAnimation( callback )
	-- body
	local pos = self.gameBoardLogic:getGameItemPosInView(5, 5)
	local move_to = CCJumpTo:create(0.5, pos, 300, 1)
	local scale_to = CCScaleTo:create(0.5, 1)

	local move_action = CCSpawn:createWithTwoActions(move_to, scale_to)


	local function animationCallback( ... )
		-- body
		self.squirrel:runAction(CCDelayTime:create(0.5), CCCallFunc:create(callback))
		
	end
	local function playAnimation( ... )
		-- body
		self.squirrel:play(callback)
	end

	local pos = self.squirrel:getPosition()
	local x, y = pos.x, pos.y
	self.squirrel:removeFromParentAndCleanup(true)
	local squirrel_2 = TileSquirrelAndKey:create()
	squirrel_2:setPosition(ccp(x, y))
	self.otherElementsLayer:addChild(squirrel_2)
	squirrel_2:play(callback)

	self.squirrel = squirrel_2

	local call_func = CCCallFunc:create(playAnimation)
	self.squirrel:runAction(CCSequence:createWithTwoActions( move_action, call_func))
end

function GamePlaySceneUI:playSquirrelAnimation( ... )
	-- body
	if self.squirrel then 
		self.squirrel:playDozeAnimation()
	end
end

function GamePlaySceneUI:hasInGameProp(propId)
	if PropsModel.instance().addToBarProps and propId then
		for _, v in pairs(PropsModel.instance().addToBarProps) do
			if v.itemId == propId then
				return true
			end
		end
	end
	return false
end

function GamePlaySceneUI:ingameBuyPropGuide()
	local wSize = Director:sharedDirector():getWinSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()

	UserManager:getInstance():setIngameBuyGuide(0)

	if not __ANDROID then return false end
	local u = UserManager:getInstance().user
	if u.topLevelId < 40 then return false end
	local userDefault = CCUserDefault:sharedUserDefault()
	local key = "mm.buy.props.ingame.abc"
    local isGuideComplete = userDefault:getBoolForKey(key)
    if isGuideComplete then 
    	return false 
    else
    	userDefault:setBoolForKey(key, true)
    	userDefault:flush()
    end
    --check reg time
    local timestamp = os.time({year=2015, month=4, day=18, hour=0, min=0, sec=0})
    if UserManager:getInstance().mark.createTime / 1000 > timestamp then return false end
    --check props 
    if #PropsModel.instance().propItems > 5 then return false end

    local plist = {10001, 10010, 10002, 10003, 10005, }--this order shoud not modify
    local preList = {}
    local bagData = BagManager:getInstance():getUserBagData()
    local prePropData = PropsModel.instance().addToBarProps

    for _, v in ipairs(prePropData) do
		local tp = v.temporaryItemList
		if tp then
			for i, m in ipairs(tp) do
				local tpid = m.itemId
				if _G.isLocalDevelopMode then printx(0, "test1,", tpid) end
				if m.itemNum > 0 then
				
					tpid = PropsModel.kTempPropMapping[tostring(tpid)]
					if _G.isLocalDevelopMode then printx(0, "test12,", tpid) end
    				if tpid then
    					preList[tpid] = tpid
    				end
    			end
			end
		end
	end

    local function testProps(id)
    	if preList[id] then
			return true
		end

    	for _, v in ipairs(bagData) do
    		if _G.isLocalDevelopMode then printx(0, v.itemId, id) end
    		if v.itemId == id then
    			if _G.isLocalDevelopMode then printx(0, "sdfas:", preList[v.itemId], preList[tostring(v.itemId)]) end
    			if v.num > 0 then
    				return true
    			end
    		end
    	end

    	return false
    end

    local hasItemNum0 = false
    local itemIndex = -1
    for i, v in ipairs(plist) do
    	local exist = false
    	if not testProps(v) then
    		hasItemNum0 = true
			itemIndex = i
    		break
    	end
    end

    if not hasItemNum0 then return false end
    --check payment type
    local propsId = plist[itemIndex]
    do return end

    GameGuide:sharedInstance():forceStopGuide()
    
    local action = {type = "tempProp", opacity = 0xCC, index = itemIndex, 
		text = "tutorial.game.text2003000", multRadius = 1.3,
		panType = "down", panAlign = "viewY", panPosY = 450, 
		maskDelay = 0.3,maskFade = 0.4 ,panDelay = 0.5 , touchDelay = 1.1}

	local pos = self:getPositionByIndex(itemIndex)
	local trueMask = GameGuideUI:mask(0xCC, 1.1, ccp(pos.x, pos.y), 1.3)
	trueMask:stopAllActions()
	trueMask.setFadeIn(0.3, 0.4)
	local function onTimeOut()
		local function onTouch()
			self.guideLayer:removeChildren()
			CCUserDefault:sharedUserDefault():setBoolForKey(key, true)
			CCUserDefault:sharedUserDefault():flush()
		end
		trueMask:addEventListener(DisplayEvents.kTouchTap, onTouch)
	end
	trueMask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(touchDelay), CCCallFunc:create(onTimeOut)))
	local panel = GameGuideUI:panelS(nil, action, true)
	self.guideLayer:addChild(trueMask)
	self.guideLayer:addChild(panel)

	local hand = GameGuideAnims:handclickAnim()
	local pos = self:getPositionByIndex(action.index)

	hand:setAnchorPoint(ccp(0.5, 0.5))
	hand:setPosition(ccp(pos.x, pos.y))
	self.guideLayer:addChild(hand)
	
	local activeItem = self.propList:findItemByItemID(propsId)
	local touchLayer = LayerColor:create()
	local onTouch2 = function(evt)
		if activeItem and activeItem:hitTest(evt.globalPosition) then
			UserManager:getInstance():setIngameBuyGuide(1)
			self.guideLayer:removeChildren()
			touchLayer:removeFromParentAndCleanup(true)
			self:buyPropCallback(propsId)
		end
	end
	touchLayer:changeWidthAndHeight(wSize.width, wSize.height)
	
	touchLayer:setColor(ccc3(0, 0, 0))
	touchLayer:setOpacity(0)
	touchLayer:setPosition(ccp(0, 0))
	touchLayer:setTouchEnabled(true, 0, true)
	touchLayer:ad(DisplayEvents.kTouchTap, onTouch2)
	self.guideLayer:addChild(touchLayer)

	return true
end

function GamePlaySceneUI:playTargetReleaseEnergy( topos,callback )
	-- body
	local target = self.levelTargetPanel.c1
	if target then 
		target:releaseEnergy(topos, callback)
	else
		if callback then callback() end
	end
end

function GamePlaySceneUI:updateFillTarget( value )
	-- body
	local target = self.levelTargetPanel.c1
	if target then 
		target:releaseEnergyUpdate(value)
	end
end

function GamePlaySceneUI:playHandGuideAnimation( pos )
	-- body
	local hand = GameGuideAnims:handclickAnim(0.5, 0.3)
    hand:setAnchorPoint(ccp(0, 1))
    hand:setPosition(ccp(pos.x , pos.y))
    self:addChild(hand)
    self.handGuide = hand
end

function GamePlaySceneUI:stopHandGuideAnimation(  )
	-- body
	if self.handGuide then 
		self.handGuide:removeFromParentAndCleanup(true)
		self.handGuide = nil
	end
end

function GamePlaySceneUI:createTempUI(item, originalUI, propId )
	-- local node = CocosObject:create()

	local tempUI = ResourceManager:sharedInstance():buildGroup(originalUI.symbolName) 			
	local worldPos = originalUI:getParent():convertToWorldSpace(originalUI:getPosition())
	tempUI:setPosition(worldPos)

	tempUI:setCascadeOpacityEnabled(true)
	tempUI:setScale(self.propList.kPropListScaleFactor)

	local icon = PropListAnimation:createIcon(propId)
	icon:setCascadeOpacityEnabled(true)
	icon:setPositionX(item.icon:getPositionX())
	icon:setPositionY(item.icon:getPositionY())
	tempUI:addChildAt(icon,4)
	tempUI.icon = icon

	local function IsMagicPropItem()
		return propId == 10005 or propId == 10027
	end

	local function updateView( ui, useEffect )
		for k,v in pairs(originalUI:getChildrenList()) do
			local tempV = ui:getChildByName(v.name)
			if tempV then
				tempV:setCascadeOpacityEnabled(true)
				tempV:setVisible(v:isVisible())
				if v.getString and tempV.setString and v.name~="time_limit_label2" then
					tempV:setString(v:getString())
					tempV:setPositionX(v:getPositionX())
					tempV:setPositionY(v:getPositionY())
					tempV:setScaleX(v:getScaleX())
					tempV:setScaleY(v:getScaleY())

				elseif v.name=="time_limit_label2" then
					tempV:setAlignment(kCCTextAlignmentCenter)
					tempV:setPositionX(v:getPositionX())
					tempV:setPositionY(v:getPositionY())
					tempV:setScaleX(v:getScaleX())
					tempV:setScaleY(v:getScaleY())
				end



			end
		end

		if item and item.prop and item.prop.getRecentTimePropLeftTime then
			local lefttime = item.prop:getRecentTimePropLeftTime()
			local showLabelTime24 = 24 * 60 * 60
			local showLabelTime48 = 48 * 60 * 60
			--换背景 
			local timeLimitFlag = ui:getChildByName("time_limit_flag")
	        local cIdx = 100

	        if ui.timeLimitLabel == nil then
			    local timeLimitLabel = ui:getChildByName("time_limit_label")
			    if timeLimitLabel then
			    	ui.timeLimitLabel = BitmapText:create(' ', 'fnt/white_yahei.fnt')
				    ui.timeLimitLabel:setAnchorPoint(ccp(0,1))
				    ui.timeLimitLabel:setPositionX( timeLimitLabel:getPositionX() )
				    ui.timeLimitLabel:setPositionY( timeLimitLabel:getPositionY() )
				    ui:addChildAt( ui.timeLimitLabel , ui:getChildIndex( timeLimitLabel ) )
				    timeLimitLabel:removeFromParentAndCleanup( true )
				    ui.timeLimitLabel.name = 'time_limit_label2'
			    end
			end

	        if lefttime < showLabelTime24 or lefttime > showLabelTime48 then
	          cIdx = 101
	          if ui.timeLimitLabel then
	          	ui.timeLimitLabel:setColor(ccc3(255,255,0))
	          end
	        else
	          cIdx = 100
	          if ui.timeLimitLabel then
	          	ui.timeLimitLabel:setColor(ccc3(255,255,255))
	          end
	        end

	        if ui.timeLimitLabel then
	        	ui.timeLimitLabel:setText( item.timeLimitLabel:getString() )
	        end
	        
	        if timeLimitFlag then
	          timeLimitFlag:adjustColor  ( _G.LvlFlagColor[cIdx][1] ,_G.LvlFlagColor[cIdx][2] ,_G.LvlFlagColor[cIdx][3] ,_G.LvlFlagColor[cIdx][4] )
	          timeLimitFlag:applyAdjustColorShader()
	        end
		end

		ui:getChildByName("name_label"):setVisible(false)
		ui:getChildByName("bg_hint"):setVisible(false)
		ui:getChildByName("bg_selected"):setVisible(false)

		local bg_hint2 = ui:getChildByName("bg_hint2")
		local boundingBox = bg_hint2:boundingBox()
		bg_hint2:removeFromParentAndCleanup(true)

		local effectAnim = PropsAnimation:createSelectAnim()
		effectAnim.name = "bg_hint2"
		effectAnim:setPositionX(boundingBox:getMidX())
		effectAnim:setPositionY(boundingBox:getMidY())
		ui:addChildAt(effectAnim,0)

		if not useEffect then
			local guanp = effectAnim.animNode:getSlot("guanp")
			guanp:setDisplayImage(false)
		end

		effectAnim:setVisible(useEffect)
	end

	local isShowed = false
	local function showArrow( isUp )
		if tempUI.isDisposed then return end
		if isShowed then return end
		isShowed = true
		local node = ArmatureNode:create("export/animal_prop_direction")
		node:playByIndex(0, 0)
		node:update(0.001)
		tempUI:addChild(node)

		local iconx = item.icon:getPositionX()

		if not isUp then
			node:setPosition(ccp(iconx + 40, 88))
			node:setRotation(90)
		else
			node:setPosition(ccp(iconx - 33, 100))
		end

		tempUI:getChildByName("bg_hint2"):setVisible(true)
	end

	local function touchLeftUp( isUp )
		if tempUI.upProp then
			tempUI.upProp:runAction(CCMoveBy:create(0.2, ccp(0, -140)))
			tempUI.upProp:runAction(CCSequence:createWithTwoActions(CCFadeOut:create(0.2), CCCallFunc:create(function ()
				if not tempUI.upProp.isDisposed then
					tempUI.upProp:removeFromParentAndCleanup(true)
					tempUI.upProp = nil
				end
				showArrow( isUp )
			end)))
		end

		if tempUI.leftProp then
			tempUI.leftProp:runAction(CCMoveBy:create(0.2, ccp(140, 0)))
			tempUI.leftProp:runAction(CCSequence:createWithTwoActions(CCFadeOut:create(0.2), CCCallFunc:create(function ()
				if not tempUI.leftProp.isDisposed then
					tempUI.leftProp:removeFromParentAndCleanup(true)
					tempUI.leftProp = nil
				end
				showArrow( isUp )
			end)))
		end

		Notify:dispatch("GuideEventShowMagicItem", isUp)
		local animalType = isUp and AnimalTypeConfig.kColumn or AnimalTypeConfig.kLine
		self.gameBoardLogic:setBrushType(animalType)
	end

	if IsMagicPropItem() then
		local upProp = ResourceManager:sharedInstance():buildGroup(originalUI.symbolName)	
		upProp:setCascadeOpacityEnabled(true)
		upProp:setScale(self.propList.kPropListScaleFactor)

		local iconx = item.icon:getPositionX()
		local icon = PropListAnimation:createIcon(propId)
		icon:setCascadeOpacityEnabled(true)
		icon:setPositionX(iconx)
		icon:setPositionY(item.icon:getPositionY())
		upProp:addChildAt(icon,4)
		upProp.icon = icon

		updateView(upProp, IsMagicPropItem())
		tempUI:addChild(upProp)

		local upAnimNode = ArmatureNode:create("export/animal_prop_direction")
		upAnimNode:playByIndex(0, 0)
		upAnimNode:update(0.001)
		upAnimNode:setPosition(ccp(iconx - 33, 100))
		upProp:addChild(upAnimNode)

		local touchLayer = LayerColor:createWithColor(ccc3(255,0,0), 120, 120)
		touchLayer:setTouchEnabled(true, -1, true)
		touchLayer:setOpacity(0)
		touchLayer:setPosition(ccp(iconx-63, 0))
		touchLayer:addEventListener(DisplayEvents.kTouchTap, function ( ... )
			local m = upProp.refCocosObj:getActionManager()
			local count = m:numberOfRunningActionsInTarget(upProp.refCocosObj)
			local y = upProp:getPositionY()
			if count <= 0 and y ~= 0 then
				touchLeftUp(true)
			end
		end)
		upProp:addChild(touchLayer)
		upProp.touchLayer = touchLayer

		local leftProp = ResourceManager:sharedInstance():buildGroup(originalUI.symbolName)	

		leftProp:setCascadeOpacityEnabled(true)
		leftProp:setScale(self.propList.kPropListScaleFactor)

		local icon = PropListAnimation:createIcon(propId)
		icon:setCascadeOpacityEnabled(true)
		icon:setPositionX(item.icon:getPositionX())
		icon:setPositionY(item.icon:getPositionY())
		leftProp.icon = icon
		leftProp:addChildAt(icon,4)

		updateView(leftProp, IsMagicPropItem())
		tempUI:addChild(leftProp)

		local leftAnimNode = ArmatureNode:create("export/animal_prop_direction")
		leftAnimNode:playByIndex(0, 0)
		leftAnimNode:update(0.001)
		leftAnimNode:setRotation(90)
		leftAnimNode:setPosition(ccp(iconx+40, 90))
		leftProp:addChild(leftAnimNode)

		local touchLayer1 = LayerColor:createWithColor(ccc3(255,0,0), 120, 120)
		touchLayer1:setTouchEnabled(true, -1, true)
		touchLayer1:setOpacity(0)
		touchLayer1:setPosition(ccp(iconx-63, 0))
		touchLayer1:addEventListener(DisplayEvents.kTouchTap, function ( ... )
			local m = leftProp.refCocosObj:getActionManager()
			local count = m:numberOfRunningActionsInTarget(leftProp.refCocosObj)
			local x = leftProp:getPositionX()

			if count <= 0 and x ~= 0 then
				touchLeftUp(false)
			end
		end)

		leftProp:addChild(touchLayer1)
		leftProp.touchLayer = touchLayer1

		tempUI.upProp = upProp
		tempUI.leftProp = leftProp
	end

	updateView(tempUI, not IsMagicPropItem())
	tempUI.isMagicPropItem = IsMagicPropItem()

	return tempUI
end

function GamePlaySceneUI:showPropItemGuide( propId, delayShow)
	self:removePropItemGuide()

 	local item,itemIndex = self.propList.leftPropList:findItemByItemID(propId)
 	if not item then
 		return
 	end

 	local layer = CocosObject:create()

	local originalUI = self.propList.leftPropList.propsListView:getChildByName("i" .. itemIndex)
	local tempUI = self:createTempUI(item, originalUI, propId)			
	
	layer:addChild(tempUI)
	layer.ui = tempUI

	local _focus = false

	local function updateView( focus )
		_focus = focus
		for k,v in pairs(originalUI:getChildrenList()) do
			local tempV = tempUI:getChildByName(v.name)
			if tempV then
				tempV:setCascadeOpacityEnabled(true)
				tempV:setVisible(v:isVisible())
				if v.getString and tempV.setString and v.name~="time_limit_label2" then
					tempV:setString(v:getString())
					tempV:setPositionX(v:getPositionX())
					tempV:setPositionY(v:getPositionY())
					tempV:setScaleX(v:getScaleX())
					tempV:setScaleY(v:getScaleY())
				elseif v.name=="time_limit_label2" then
					tempV:setAlignment(kCCTextAlignmentCenter)
					tempV:setPositionX(v:getPositionX())
					tempV:setPositionY(v:getPositionY())
					tempV:setScaleX(v:getScaleX())
					tempV:setScaleY(v:getScaleY())
				end
			end
		end

		if item and item.prop and item.prop.getRecentTimePropLeftTime then
			local lefttime = item.prop:getRecentTimePropLeftTime()
			local showLabelTime24 = 24 * 60 * 60
			local showLabelTime48 = 48 * 60 * 60
			--换背景 
			local timeLimitFlag = tempUI:getChildByName("time_limit_flag")
			local timeLimitFlag_Left = nil
			if tempUI.leftProp and tempUI.leftProp:getChildByName("time_limit_flag") then
				timeLimitFlag_Left = tempUI.leftProp:getChildByName("time_limit_flag")
			end
			local timeLimitFlag_Up = nil
			if tempUI.upProp and tempUI.upProp:getChildByName("time_limit_flag") then
				timeLimitFlag_Up = tempUI.upProp:getChildByName("time_limit_flag")
			end

	        local cIdx = 100

	        if tempUI.timeLimitLabel == nil then
			    local timeLimitLabel = tempUI:getChildByName("time_limit_label")
			    if timeLimitLabel then
			    	tempUI.timeLimitLabel = BitmapText:create(' ', 'fnt/white_yahei.fnt')
				    tempUI.timeLimitLabel:setAnchorPoint(ccp(0,1))
				    tempUI.timeLimitLabel:setPositionX( timeLimitLabel:getPositionX() )
				    tempUI.timeLimitLabel:setPositionY( timeLimitLabel:getPositionY() )
				    tempUI:addChildAt( tempUI.timeLimitLabel , tempUI:getChildIndex( timeLimitLabel ) )
				    timeLimitLabel:removeFromParentAndCleanup( true )
				    tempUI.timeLimitLabel.name = 'time_limit_label2'
			    end
			end

	        if lefttime < showLabelTime24 or lefttime > showLabelTime48 then
	          cIdx = 101
	          if tempUI.timeLimitLabel then
	          	tempUI.timeLimitLabel:setColor(ccc3(255,255,0))
	          end
	          if tempUI.upProp and tempUI.upProp.timeLimitLabel then
	          	tempUI.upProp.timeLimitLabel:setColor(ccc3(255,255,0))
	          end
	          if tempUI.leftProp and tempUI.leftProp.timeLimitLabel then
	          	tempUI.leftProp.timeLimitLabel:setColor(ccc3(255,255,0))
	          end
	        else
	          cIdx = 100
	          if tempUI.timeLimitLabel then
	          	tempUI.timeLimitLabel:setColor(ccc3(255,255,255))
	          end
	          if tempUI.upProp and  tempUI.upProp.timeLimitLabel then
	          	tempUI.upProp.timeLimitLabel:setColor(ccc3(255,255,255))
	          end
	          if tempUI.leftProp and  tempUI.leftProp.timeLimitLabel then
	          	tempUI.leftProp.timeLimitLabel:setColor(ccc3(255,255,255))
	          end
	        end
	        
	        local timeLimitFlagVisible = false
	        if timeLimitFlag then
	        	timeLimitFlagVisible = timeLimitFlag:isVisible()
	         	timeLimitFlag:adjustColor  ( _G.LvlFlagColor[cIdx][1] ,_G.LvlFlagColor[cIdx][2] ,_G.LvlFlagColor[cIdx][3] ,_G.LvlFlagColor[cIdx][4] )
	         	timeLimitFlag:applyAdjustColorShader()
	        end
	        if timeLimitFlag_Left then
	        	timeLimitFlag_Left:setVisible(timeLimitFlagVisible)
	         	timeLimitFlag_Left:adjustColor  ( _G.LvlFlagColor[cIdx][1] ,_G.LvlFlagColor[cIdx][2] ,_G.LvlFlagColor[cIdx][3] ,_G.LvlFlagColor[cIdx][4] )
	         	timeLimitFlag_Left:applyAdjustColorShader()
	        end
	        if timeLimitFlag_Up then
	        	timeLimitFlag_Up:setVisible(timeLimitFlagVisible)
	         	timeLimitFlag_Up:adjustColor  ( _G.LvlFlagColor[cIdx][1] ,_G.LvlFlagColor[cIdx][2] ,_G.LvlFlagColor[cIdx][3] ,_G.LvlFlagColor[cIdx][4] )
	         	timeLimitFlag_Up:applyAdjustColorShader()
	        end

		end

		tempUI:getChildByName("name_label"):setVisible(focus)
		tempUI:getChildByName("bg_hint"):setVisible(false)
		tempUI:getChildByName("bg_selected"):setVisible(false)
		tempUI:getChildByName("bg_hint2"):setVisible(not tempUI.isMagicPropItem and focus)
		if tempUI.upProp then
			tempUI:getChildByName("name_label"):setVisible(false)
		end

		local freeFlagVisible = tempUI:getChildByName("free_flag"):isVisible()
		if tempUI.upProp then
			tempUI.upProp:getChildByName("free_flag"):setVisible(freeFlagVisible)
		end
		if tempUI.leftProp then
			tempUI.leftProp:getChildByName("free_flag"):setVisible(freeFlagVisible)
		end

		if tempUI.timeLimitLabel then
        	tempUI.timeLimitLabel:setText( item.timeLimitLabel:getString() )
        end
		if tempUI.upProp and tempUI.upProp.timeLimitLabel then
        	tempUI.upProp.timeLimitLabel:setText( item.timeLimitLabel:getString() )
        end
        if tempUI.leftProp and tempUI.leftProp.timeLimitLabel then
        	tempUI.leftProp.timeLimitLabel:setText( item.timeLimitLabel:getString() )
        end
	end

	updateView(true)

	function layer:hitTestPoint(worldPosition, useGroupTest)
		return item:hitTest(worldPosition)
	end

	function layer:getCenterPosition( ... )
		return item:getItemCenterPosition()
	end

	item:addEventListener(PropListItem.Events.kFocusChange,function( evt )
		updateView(evt.data)

		if evt.data and layer.selectCallback then
			layer.selectCallback()
		end
	end)

	item:addEventListener(PropListItem.Events.kUpdateView,function( evt )
		updateView(_focus)
	end)

	function layer:updateView( focus )
		updateView(focus)
	end

	local function showUpLeftProp( ... )
		if tempUI.upProp then
			tempUI.upProp.icon:setVisible(true)
			tempUI.upProp:setOpacity(0)
			tempUI.upProp:setPosition(ccp(0, 0))
			tempUI.upProp:runAction(CCFadeIn:create(0.2))
			tempUI.upProp:runAction(CCSequence:createWithTwoActions(CCMoveBy:create(0.2, ccp(0, 150)), CCMoveBy:create(0.1, ccp(0, -10))))
		end

		if tempUI.leftProp then
			tempUI.leftProp.icon:setVisible(true)
			tempUI.leftProp:setOpacity(0)
			tempUI.leftProp:setPosition(ccp(0, 0))
			tempUI.leftProp:runAction(CCFadeIn:create(0.2))
			tempUI.leftProp:runAction(CCSequence:createWithTwoActions(CCMoveBy:create(0.2, ccp(-150, 0)), CCMoveBy:create(0.1, ccp(10, 0))))
		end
	end

	if delayShow then
		tempUI:setVisible(false)
		tempUI.icon:setVisible(false)
		tempUI:runAction(CCSequence:createWithTwoActions(
			CCDelayTime:create(0.5),
			CCCallFunc:create(function( ... )
				showUpLeftProp()
				tempUI:setVisible(true)
				tempUI.icon:setVisible(true)
				originalUI:setVisible(false)
			end)
		))
	else
		showUpLeftProp()
	end

	layer.showUpLeftProp = showUpLeftProp

	function layer:removeFocusListener( ... )
		item:removeEventListenerByName(PropListItem.Events.kFocusChange)
		item:removeEventListenerByName(PropListItem.Events.kUpdateView)
	end

	function layer:showOriginalUI( ... )
		originalUI:setVisible(true)
	end

	self.propItemHighlightLayer = layer
	layer.item = item

	return layer
end

function GamePlaySceneUI:removePropItemGuide( ... )
	if self.propItemHighlightLayer then
		self.propItemHighlightLayer:removeFocusListener()
		self.propItemHighlightLayer:showOriginalUI()
		self.propItemHighlightLayer = nil
	end


end

function GamePlaySceneUI:showTopBoardView( ... )
 	local lastIndex = self.rootLayer:getChildrenList()[#self.rootLayer:getChildrenList()].index

 	self.gamePlaySceneOldIndex = self.rootLayer:getChildIndex(self.gamePlayScene)
 	self.rootLayer:setChildIndex(self.gamePlayScene,lastIndex + 1)

 	self.effectLayerOldIndex = self.rootLayer:getChildIndex(self.effectLayer)
 	self.rootLayer:setChildIndex(self.effectLayer,lastIndex + 2)

 	self.gameBoardView:showUsePropTipGuide(propId)
end

function GamePlaySceneUI:showNormalBoardView( ... )
	if self.effectLayerOldIndex then
		self.rootLayer:setChildIndex(self.effectLayer,self.effectLayerOldIndex)
		self.effectLayerOldIndex = nil
	end

	if self.gamePlaySceneOldIndex then
		self.rootLayer:setChildIndex(self.gamePlayScene,self.gamePlaySceneOldIndex)
		self.gamePlaySceneOldIndex = nil
	end

	-- 强制刷新下index
 	for i,v in ipairs(self.rootLayer:getChildrenList()) do
 		v.index = i - 1
 	end
 	self.rootLayer:refreshIndex()
end

function GamePlaySceneUI:showUsePropTipGuide( propId )
	self:reorderTargetPanel(false)
	self:removeUsePropTipGuide()

	local layer = self:showPropItemGuide(propId,false)
	if not layer then
		return
	end

 	-- local lastIndex = self.rootLayer:getChildrenList()[#self.rootLayer:getChildrenList()].index

 	-- self.gamePlaySceneOldIndex = self.rootLayer:getChildIndex(self.gamePlayScene)
 	-- self.rootLayer:setChildIndex(self.gamePlayScene,lastIndex + 1)

 	-- self.effectLayerOldIndex = self.rootLayer:getChildIndex(self.effectLayer)
 	-- self.rootLayer:setChildIndex(self.effectLayer,lastIndex + 2)
 	self:showTopBoardView()

 	self.gameBoardView:showUsePropTipGuide(propId)
 	
	-- 
	return layer
end

function GamePlaySceneUI:removeUsePropTipGuide( ... )
	-- if self.effectLayerOldIndex then
	-- 	self.rootLayer:setChildIndex(self.effectLayer,self.effectLayerOldIndex)
	-- 	self.effectLayerOldIndex = nil
	-- end

	-- if self.gamePlaySceneOldIndex then
	-- 	self.rootLayer:setChildIndex(self.gamePlayScene,self.gamePlaySceneOldIndex)
	-- 	self.gamePlaySceneOldIndex = nil
	-- end

	-- -- 强制刷新下index
 -- 	for i,v in ipairs(self.rootLayer:getChildrenList()) do
 -- 		v.index = i - 1
 -- 	end
 -- 	self.rootLayer:refreshIndex()
 	self:showNormalBoardView()

 	self.gameBoardView:removeUsePropTipGuide()

	self:removePropItemGuide()
end

function GamePlaySceneUI:playAnimalFallDown()
	local swoonRound = self.gameBoardLogic.gameMode:getFollowAnimalSwoonRound()
	self.olympicTopNode:updateFollowAnimalSwoonRound(swoonRound)
	self.olympicTopNode:playFollowAnimalFall()
	
	self.gameBoardLogic.boardView.scrollLeftStepNode:setNodeActived(false)
end

function GamePlaySceneUI:playOlympicBananaEffect(fromPos, onComplete)
	local sprite = TileOlympicBlocker:createFlySprite()
	local globalPos = fromPos
	local localPos = self.effectLayer:convertToNodeSpace(globalPos)
	local targetPos = self.olympicTopNode:getBananaPos()
	targetPos = self.effectLayer:convertToNodeSpace(targetPos)
	local actionArr1 = CCArray:create()
	actionArr1:addObject(CCScaleTo:create(3/24, 0.9))

	local scale = self.olympicTopNode:getAnimalScale()
	local actionArr2 = CCArray:create()
	actionArr2:addObject(CCRotateTo:create(7/24, 144))
	actionArr2:addObject(CCMoveTo:create(7/24, targetPos))
	actionArr2:addObject(CCScaleTo:create(7/24, 0.85 * scale))
	actionArr1:addObject(CCSpawn:create(actionArr2))

	local function playAnimalFallDown()
		sprite:removeFromParentAndCleanup(true)
		self:playAnimalFallDown()
		if onComplete then onComplete() end
	end

	actionArr1:addObject(CCCallFunc:create(playAnimalFallDown))

	sprite:runAction(CCSequence:create(actionArr1))
	sprite:setPosition(localPos)
	self.effectLayer:addChild(sprite)
end

function GamePlaySceneUI:playPassedFriendsTip(friendIds)
	if friendIds and #friendIds > 0 then
		local idx = 1
		if #friendIds > 1 then
			idx = math.random(1, #friendIds)
		end
		local friendId = friendIds[idx]

		local friendInfo = FriendManager.getInstance():getFriendInfo(friendId)
		if not friendInfo then return end

		local tipPos = nil
		local targetIcon = nil
		if self.levelTargetPanel and self.levelTargetPanel.c1 then
			targetIcon = self.levelTargetPanel.c1.icon
		end
		if targetIcon then
			local pos = targetIcon:getPosition()
			pos = targetIcon:getParent():convertToWorldSpace(pos)
			tipPos = self.extandLayer:convertToNodeSpace(pos)
		end
		if not tipPos then return end

		if self.extandLayer.weeklyPassFriendTip then
			self.extandLayer.weeklyPassFriendTip:removeFromParentAndCleanup(true)
			self.extandLayer.weeklyPassFriendTip = nil
		end

		local PassFriendTip = require("zoo.panel.seasonWeekly.components.PassFriendTip")
		local tip = PassFriendTip:create(friendId, friendInfo.name, friendInfo.headUrl)

		if not tip then return end

		self.extandLayer.weeklyPassFriendTip = tip
		self.extandLayer:addChild(tip)

		tip:setPosition(ccp(tipPos.x+15, tipPos.y-25))

		local function onDismiss()
			tip:removeFromParentAndCleanup(true)
			self.extandLayer.weeklyPassFriendTip = nil
		end
		tip:show(0, 4, onDismiss)
	end
end

--------- 通用点对点飞行示意动画 ---------
-- [param]
-- fromGridItemCoord/toGridItemCoord: 当没有传入 fromPos/toPos 时，通过格子坐标获取位置
--     GridItemCoord 支持用 r,c 或 x,y 系统表示坐标
function GamePlaySceneUI:playPointToPointFlyingEffect(fromPos, toPos, callback, fromGridItemCoord, toGridItemCoord, callbackParam)
	local animate = Layer:create()

	if not fromPos then fromPos = self:_getPositionFromGridCoord(fromGridItemCoord) end
	if not toPos then toPos = self:_getPositionFromGridCoord(toGridItemCoord) end

	if not fromPos or not toPos then return end

	local animation = Sprite:createWithSpriteFrameName("game_collect_small_star0000")
	animation:setScale(3)

	animation:setPosition(fromPos)
	-- local angle = -math.deg(math.atan2(toPos.y - fromPos.y, toPos.x - fromPos.x))
	-- animation:setRotation(angle)
	-- animation:setAnchorPoint(ccp(0.8, 0.46))

	local function finishCallback()
		animate:removeFromParentAndCleanup(true)
		if callback then callback(callbackParam) end
	end

	local actArr = CCArray:create()
	actArr:addObject(CCMoveTo:create(0.4, ccp(toPos.x , toPos.y)))
	actArr:addObject(CCCallFunc:create(finishCallback) )
	animation:runAction(CCSequence:create(actArr))

	animate:addChild(animation)
	self:addChild(animate)		--effectLayer?
end

--------- 通用流光飞行示意动画 ---------
-- [param]
-- fromGridItemCoord/toGridItemCoord: 当没有传入 fromPos/toPos 时，通过格子坐标获取位置
--     GridItemCoord 支持用 r,c 或 x,y 系统表示坐标
function GamePlaySceneUI:playLightFlyingEffect(fromPos, toPos, callback, callBackParam )

    callBackParam = callBackParam or nil

	local animate = Layer:create()

    local FlyLightLine = require 'zoo.animation.BossBee.FlyLightLine'
	FlyLightLine:createLine( animate, 0.3, fromPos, toPos, callback, callBackParam )

	self:addChild(animate)		--effectLayer?
end

function GamePlaySceneUI:_getPositionFromGridCoord(gridItemCoord)
	local position
	if gridItemCoord then
		local gridRow, gridCol
		if gridItemCoord.r and gridItemCoord.c then
			gridRow, gridCol = gridItemCoord.r, gridItemCoord.c
		elseif gridItemCoord.x and gridItemCoord.y then
			gridRow, gridCol = gridItemCoord.y, gridItemCoord.x
		end

		if gridRow and gridCol then
			local itemPosition = self.gameBoardLogic:getGameItemPosInView(gridRow, gridCol)
			position = self:convertToNodeSpace(itemPosition)
		end
	end
	return position
end


----------------------------------------------
--播放+1获取动画
function GamePlaySceneUI:flySpring2019AddNumAnimation( r,c, SkillID )
    
    local PicYearMeta = require "zoo.localActivity.PigYear.PicYearMeta"

    FrameLoader:loadImageWithPlist('flash/SpringFestival_2019/SpringFestivalRes_2019.plist')

    local itemPosition = self.gameBoardLogic:getGameItemPosInView(r, c)

    local headIndex =1
    if SkillID == PicYearMeta.ItemIDs.GEM_1 then
        headIndex = 1
    elseif SkillID == PicYearMeta.ItemIDs.GEM_3 then
        headIndex = 3
    elseif SkillID == PicYearMeta.ItemIDs.GEM_4 then
        headIndex = 4
    end

    local pigHeadSprite = Sprite:createWithSpriteFrameName("SpringFestival_2019res/pighead"..headIndex.."0000")
    pigHeadSprite:setScale(1.5)
    pigHeadSprite:setPosition( ccp(itemPosition.x,itemPosition.y) )
	self.effectLayer:addChild(pigHeadSprite)

    pigHeadSprite:setOpacity( 0 )

    local function callend()
        if pigHeadSprite.isDisposed then return end 

        pigHeadSprite:removeFromParentAndCleanup(true)
    end

    local array2 = CCArray:create()
    array2:addObject( CCDelayTime:create(0.5) )
    array2:addObject( CCFadeOut:create(1)  )

    local array1 = CCArray:create()
    array1:addObject(  CCSequence:create(array2)  )
    array1:addObject( CCMoveBy:create(1.1, ccp(0, 50 )) )

    local array = CCArray:create()
    array:addObject( CCDelayTime:create(0.2) )
    array:addObject( CCFadeIn:create(0.1) )
    array:addObject( CCSpawn:create(array1)  )
    array:addObject(CCCallFunc:create(callend))

    pigHeadSprite:runAction( CCSequence:create(array) )

    if not self.pigHeadBGSprite then
        local function MoveEndCall()
            self:flySpring2019PigBg( headIndex )
        end
        self:createSpring2019PigBg( MoveEndCall )
    else
        self:flySpring2019PigBg( headIndex )
    end
end

--播放春节左上角+1获取动画
function GamePlaySceneUI:flySpring2019PigBg( headIndex )
    
    local addOneSprite = Sprite:createWithSpriteFrameName("SpringFestival_2019res/addone0000")
    if headIndex == 1 then
        addOneSprite:setPosition(ccp(76,95))
    elseif headIndex==3 then
        addOneSprite:setPosition(ccp(76,60))
    elseif headIndex==4 then
        addOneSprite:setPosition(ccp(76,25))
    else
        addOneSprite:setPosition(ccp(76,25))
    end
	self.pigHeadBGSprite:addChild(addOneSprite)

    addOneSprite:setOpacity( 0 )

    local function callend()
        if addOneSprite.isDisposed then return end 
        addOneSprite:removeFromParentAndCleanup(true)

        local numLabel = self.pigHeadBGSprite.numLabel[headIndex]
        if numLabel then
            numLabel.ShowNum = numLabel.ShowNum + 1
            numLabel:setText( ""..numLabel.ShowNum )
        end

        if SpringFestival2019Manager.getInstance():getFlyPigLeftNum() == 0 then
            self:hideSpring2019PigBg()
        end
    end 

    local array1 = CCArray:create()
    array1:addObject( CCFadeOut:create(0.4)  )
    array1:addObject( CCMoveBy:create(0.5, ccp(0, 40 )) )

    local array = CCArray:create()
    array:addObject( CCDelayTime:create(0) )
    array:addObject( CCFadeIn:create(0.1) )
    array:addObject( CCSpawn:create(array1)  )
    array:addObject(CCCallFunc:create(callend))

    addOneSprite:runAction( CCSequence:create(array) )
end

--创建春节猪头底板
function GamePlaySceneUI:createSpring2019PigBg( MoveEndCall )
    local itemPosition = self.gameBoardLogic:getGameItemPosInView(1, 1)

    local posY = itemPosition.y+100
    local pigHeadBGSprite = Sprite:createWithSpriteFrameName("SpringFestival_2019res/pigNumBG0000")
    pigHeadBGSprite:setPosition( ccp(20 - 150,posY ) )
	self.effectLayer:addChild(pigHeadBGSprite)
    self.pigHeadBGSprite = pigHeadBGSprite
    self.pigHeadBGSprite.numLabel = {}
    local GemNumList = PigYearLogic:getGemNums()

    for i,v in ipairs(GemNumList) do
        if i~= 2 then
            local haveNum = GemNumList[i] or 0
            local numLabel = BitmapText:create(haveNum, 'fnt/piggybank.fnt', 0)
            numLabel:setAnchorPoint(ccp(0.5, 0.5))

            if i == 1 then
                numLabel:setPosition(ccp(76,95))
            elseif i==3 then
                numLabel:setPosition(ccp(76,60))
            elseif i==4 then
                numLabel:setPosition(ccp(76,25))
            end
            
            numLabel:setScale( 0.6 )
            numLabel.ShowNum = haveNum
            pigHeadBGSprite:addChild( numLabel )
            self.pigHeadBGSprite.numLabel[i] = numLabel
        end
    end

    local array = CCArray:create()
    array:addObject( CCMoveTo:create(0.2, ccp(60,posY)) )
    array:addObject(CCCallFunc:create(MoveEndCall))

    pigHeadBGSprite:runAction( CCSequence:create(array) )
end

function GamePlaySceneUI:hideSpring2019PigBg()
    local array = CCArray:create()
    array:addObject( CCDelayTime:create(1) )
    array:addObject( CCMoveBy:create(0.2, ccp(-150,0)) )
    array:addObject(CCCallFunc:create(MoveEndCall))

    self.pigHeadBGSprite:runAction( CCSequence:create(array) )
end

---------------------------------------------------------------------------------------------------
------------------------------------ 以下 已废弃 --------------------------------------------------
---------------------------------------------------------------------------------------------------

function GamePlaySceneUI:createGamePlayScene(levelId , gamePlaySceneUiType , levelType , forceUseDropBuff)
end

function GamePlaySceneUI:init(levelId, levelType, selectedItemsData, gamePlaySceneUiType,  ...)
end

function GamePlaySceneUI:initTopArea( ... )
end

function GamePlaySceneUI:checkPropEnough(usePropType, propId)
end

function GamePlaySceneUI:usePropCallback(propId, usePropType, expireTime, isRequireConfirm, ...)
end

function GamePlaySceneUI:cancelPropUseCallback(propId,confirm, ...)
end

function GamePlaySceneUI:onPauseBtnTapped(...)
end

function GamePlaySceneUI:passLevel(levelId, score, star, stageTime, coin, targetCount, opLog, bossCount,activityForceShareData, ...)
end

function GamePlaySceneUI:failLevel(levelId, score, star, stageTime, coin, targetCount, opLog, isTargetReached, failReason, ...)
end

-- This Function Is Called By Game Board Locig
function GamePlaySceneUI:addStep(levelId, score, star, isTargetReached, isAddStepCallback, panelType , panelTypeData ,...)
end

-------------------------
--显示加时间面板
-------------------------
function GamePlaySceneUI:showAddTimePanel(levelId, score, star, isTargetReached, addTimeCallback, ...)
end

-------------------------
--显示加兔兔导弹面板
-------------------------
function GamePlaySceneUI:showAddRabbitMissilePanel( levelId, score, star, isTargetReached, isAddPropCallback )
end

function GamePlaySceneUI:addTemporaryItem(itemId, itemNum, fromGlobalPosition, fromGuide ,...)
end

function GamePlaySceneUI:addTimeProp(propId, num, fromGlobalPosition, activityId, text)
end

-- -----------------------------------------------------------------
-- Used To Confirm The Property Is Used, For Hammer Like Property
-- ----------------------------------------------------------------

function GamePlaySceneUI:confirmPropUsed(pos, successCallback, failCallback)
end

function GamePlaySceneUI:onGameAnimOverByGuide()
end

function GamePlaySceneUI:onGameSwap(from, to)
end

function GamePlaySceneUI:onGetItem(itemType)
end

function GamePlaySceneUI:onGameStable(hasGift)
end

function GamePlaySceneUI:onExitGame()
end

function GamePlaySceneUI:onFullFirework()
end

function GamePlaySceneUI:onShowFullFireworkTip()
end

function GamePlaySceneUI:playFirstShowFireworkGuide()
end

function GamePlaySceneUI:tryFirstQuestionMark(mainLogic)
end