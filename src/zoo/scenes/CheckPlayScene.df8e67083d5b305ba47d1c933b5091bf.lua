require "zoo.config.LevelDropPropConfig"

CheckPlayScene = class(GamePlaySceneUI)

CheckPlaySceneEvents = {
	kSwapFail = "CheckPlaySceneEvents.kSwapFail",
}

local CheckPlayCrashListener = nil
local hasRedefine = nil

CheckPlayScenePLayMode = {
	
	kNormal = 1 ,
	kSnapshot = 2 ,
	kResume = 3 ,

}

function CheckPlayScene:ctor()
	self.isCheckReplayScene = true
	self.isCheckReplay = false
	self.onReplayEndHandler = nil
end

function CheckPlayScene:create(levelId, replayRecords)
	local s = CheckPlayScene.new()
	-- body
	local levelMeta = LevelMapManager.getInstance():getMeta(levelId)
	if not levelMeta then 
		local testConfStr = DevTestLevelMapManager.getInstance():getConfig("test1.json")
		local testConf = table.deserialize(testConfStr)
		testConf.totalLevel = levelId
		LevelMapManager:getInstance():addDevMeta(testConf)
	end
	local levelConfig = LevelDataManager.sharedLevelData():getLevelConfigByID(levelId)

	s:init(levelConfig, replayRecords)

	return s
end

function CheckPlayScene:createWithLevelConfig(levelConfig, replayRecords , version)
	local s = CheckPlayScene.new()
	s.currVersion = version
	s:init(levelConfig, replayRecords)
	return s
end

local function doInjectCode()
	--if jit and jit.on then jit.on() end

	ClassicMode.reachEndCondition = function ()
		return false
	end

	--[[
	RandomFactory.rand = function (self,a,b)
		local r = 0 
		if self.CCPObject then
			if a and b then
				self.randomIndex = self.randomIndex + 1
				r = self.CCPObject:rand(a,b)
			else
				self.randomIndex = self.randomIndex + 1
				r = self.CCPObject:rand()
			end
		end

		--if _G.isCheckPlayModeActive then
			--printx( 1 , "  ===== rand   randomIndex = " , self.randomIndex , "  a = " , a , "  b = " , b , " r = " , r )
			--printx( 1 , "  " , debug.traceback())
		--end

		return r
	end
	]]

	
	--[[
	GameBoardLogic.addActionToList = function (self, theAction, theList , type)
		if not self.actionCountIndex then self.actionCountIndex = 0 end
		self.actionCountIndex = self.actionCountIndex + 1
		local actCount = self.actionCountIndex
		
		theAction.creatId = totalActIndex
		theList[actCount] = theAction
		theAction.actid = actCount	
	end
	]]


	UFOAnimation.playUFOWakeUpOnRecover = function( self , callback)
		self:stopUFOAnimations()

		if self.stun then self.stun:setOpacity(0) end
		local function onFinished()
			if self.stun then self.stun:removeFromParentAndCleanup(true) end
			self.ufoStatus = UFOStatus.kNormal
			self:setUFONormal()
			if callback then callback() end
		end
		self.body:runAction(CCSequence:createWithTwoActions(self:createUFOWakeAnimation(), CCCallFunc:create(onFinished)))
	end


	OlympicHorizontalEndlessMode.afterFail = function (self)
	    local function goOn()
	    	local mainLogic = self.mainLogic
		    self.encryptData.failedByLightPassed = 0
		    mainLogic:setGamePlayStatus(GamePlayStatus.kNormal)
		    mainLogic.fsm:changeState(mainLogic.fsm.fallingMatchState)
		    
			self:addFollowAnimalSwoonRound(5)
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

	    		if mainLogic.replayStep <= #mainLogic.replaySteps then 
	    			goOn()
				else
					mainLogic.PlayUIDelegate:passLevel( 
						mainLogic.level, mainLogic.totalScore , mainLogic.gameMode:getScoreStarLevel() ,
						math.floor(mainLogic.timeTotalUsed), mainLogic.coinDestroyNum, mainLogic:getTargetCount()
						 )
				end
	    	end
	    	
	    	setTimeOut( popPanel , 2 )
	    end
	end

	GameBoardLogic.Replay = function (self)
		if self.replayError then -- 发生了错误
			self.replaying = false
			if self.PlayUIDelegate and type(self.PlayUIDelegate.onReplayErrorOccurred) == "function" then
				self.PlayUIDelegate:onReplayErrorOccurred(self.replayError)
			end
		else
			if self.replayStep <= #self.replaySteps then
				if not self.replaySteps[self.replayStep].prop then
					self:startTrySwapedItem(self.replaySteps[self.replayStep].x1, self.replaySteps[self.replayStep].y1,
						self.replaySteps[self.replayStep].x2, self.replaySteps[self.replayStep].y2)
					self.replayStep = self.replayStep + 1
				else

					local r1 = self.replaySteps[self.replayStep].x1
					local c1 = self.replaySteps[self.replayStep].y1
					local r2 = self.replaySteps[self.replayStep].x2
					local c2 = self.replaySteps[self.replayStep].y2
					local propId = self.replaySteps[self.replayStep].prop

					local usePropResult = self:useProps(propId, r1,c1,r2,c2)

					if not usePropResult then
						local runningScene = Director.sharedDirector():getRunningSceneLua()
						if runningScene and runningScene.isCheckReplayScene then
							runningScene:dp(Event.new("replay_error", {msg="use_prop_error"}))
						end
						return
					end

					self.replayStep = self.replayStep + 1
				end
			else
				if self.gameMode:is(ClassicMode) then
					self:setGamePlayStatus(GamePlayStatus.kEnd)
				else
					--self:checkCanMoveItem(0)
					self.replaying = false
					if self.PlayUIDelegate and type(self.PlayUIDelegate.onReplayEnd) == "function" then
						self.PlayUIDelegate:onReplayEnd()
					end
				end
			end
		end
	end
end

function CheckPlayScene:init( levelConfig, replayRecords )
	-- body
	assert(levelConfig)
	assert(replayRecords)

	self.replayRecords = replayRecords
	levelConfig.randomSeed = self.replayRecords.randomSeed

	local levelId = levelConfig.level
	self.levelId = levelId
	local levelType =  LevelType:getLevelTypeByLevelId(levelId) or GameLevelType.kMainLevel

	local propIds = {}
	if replayRecords.selectedItemsData then
		for _, v in pairs(replayRecords.selectedItemsData) do
			table.insert(propIds, tonumber(v.id))
		end
	end
	StageInfoLocalLogic:clearStageInfo( UserManager.getInstance().user.uid )
	StageInfoLocalLogic:initStageInfo(UserManager:getInstance().user.uid, levelId, propIds)

	if self.currVersion and type(self.currVersion) == "string" then
		local arr = self.currVersion:split(".")
		for k,v in pairs(arr) do
		end
		if #arr > 0 and tonumber(arr[#arr]) >= 41 then
			require "zoo.gamePlay.GamePlayContext"
			GamePlayContext:getInstance():decodeContextDataForReplay( self.replayRecords.ctx )
		end 
	end

	local function callback( ... )
		-- body
		GamePlaySceneUI.init(self, levelId, levelType, replayRecords.selectedItemsData or {}, GamePlaySceneUIType.kReplay)
		self.propList:addFakeAllProp(999)
		self.replayResourceIsReady = true
		self:__startReplay()
	end 
	self:loadExtraResource(levelConfig, callback)

	local function onReplayErrorOccurred(evt)
		local errorData = evt and evt.data or nil
		if errorData and errorData.msg == "use_prop_error" then
			self:onReplayErrorOccurred(CheckPlay.RESULT_ID.kUsePropError, errorData)
		else
			self:onReplayErrorOccurred(CheckPlay.RESULT_ID.kSwapFail, errorData)
		end
		
	end
	self:ad("replay_error", onReplayErrorOccurred)

	if CheckPlayCrashListener then
		GlobalEventDispatcher:getInstance():removeEventListener("lua_crash", CheckPlayCrashListener)
		CheckPlayCrashListener = nil
	end
	CheckPlayCrashListener = function(evt)
		self:onReplayErrorOccurred(CheckPlay.RESULT_ID.kCrash, {msg="lua_crash"})
	end
	GlobalEventDispatcher:getInstance():addEventListener("lua_crash", CheckPlayCrashListener)

	if _G.isCheckPlayModeActive and not hasRedefine then
		doInjectCode()
		hasRedefine = true
	end


---------------------------------------------------------------
	if(false and isLocalDevelopMode) then
		if(_shareLib) then
			_shareLib.enabled(true)
			_shareLib.clear()
		end
		require("hecore.ReuseAnimationCtrl").enabled = true
		require("hecore.ReuseAnimationCtrl"):clean()
	end
	if(false and isLocalDevelopMode) then
		require("hecore/profiler"):clearMap()
	end

end

function CheckPlayScene:__startReplay()
	if self.replayResourceIsReady and self.replayIsStarting then -- 一次回放，__startReplay方法可能进来多次，但只会运行一次setReplay
		--printx( 1 , "CheckPlayScene:__startReplay   self:setReplay( self.replayPLayMode )   " ,  self.replayPLayMode )
		self:setReplay( self.replayPLayMode )
	end
end

function CheckPlayScene:startReplay(pLayMode)
	Director:sharedDirector():pushScene(self)
	if pLayMode == CheckPlayScenePLayMode.kNormal then
		self.snapshotModeEnable = false
	elseif pLayMode == CheckPlayScenePLayMode.kSnapshot then
		self.snapshotModeEnable = true
	elseif pLayMode == CheckPlayScenePLayMode.kResume then
		self.snapshotModeEnable = false
	elseif pLayMode == CheckPlayScenePLayMode.kReview then
		self.snapshotModeEnable = false
	end
	
	self.replayPLayMode = pLayMode
	self.replayIsStarting = true
	self:__startReplay()
end

local last = 0

function CheckPlayScene:startCheckReplay()
	self.isCheckReplay = true
	last = os.clock()
	self.onReplayEndHandler = function()

		local function endReplay()
			
			if self.isCheckReplay and CheckPlay then
				CheckPlay:checkResult(CheckPlay.RESULT_ID.kNotEnd, {} , self.gameBoardLogic)
			end
			self:endReplay()
		end
		setTimeOut(endReplay, 0.1)
		-- self.gameBoardLogic:setGamePlayStatus(GamePlayStatus.kEnd)
	end
	self.replayIsStarting = true
	self:__startReplay()
	Director:sharedDirector():pushScene(self)
end

function CheckPlayScene:loadExtraResource( levelConfig, callback )
	-- body
	local fileList = levelConfig:getDependingSpecialAssetsList()
	self.fileList = fileList
	local loader = FrameLoader.new()
	local function callback_afterResourceLoader()
		loader:removeAllEventListeners()
		callback()
	end
	for i,v in ipairs(fileList) do loader:add(v, kFrameLoaderType.plist) end
	loader:addEventListener(Events.kComplete, callback_afterResourceLoader)
	loader:load()
end

function CheckPlayScene:usePropCallback(propId, usePropType, expireTime , isRequireConfirm, ...)
	self.usePropType = usePropType

	local realItemId = propId
	if self.usePropType == UsePropsType.EXPIRE then  realItemId = ItemType:getRealIdByTimePropId(propId) end
	
	if not isRequireConfirm then -- use directly
		local function sendUseMsgSuccessCallback()
			self.propList:confirm(propId)
			self.gameBoardView:useProp(realItemId, isRequireConfirm)
			self.useItem = true
		end
		sendUseMsgSuccessCallback()
		return true
	else -- can be canceled, must kill the process before use
		
		if self:checkPropEnough(usePropType, propId) then
			self.needConfirmPropId = propId
			-- self.needConfirmPropIsTempProperty = true
			self.gameBoardView:useProp(realItemId, isRequireConfirm)
			return true
		else
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(730311)))
			return false
		end
	end
end

function CheckPlayScene:confirmPropUsed(pos, successCallback)

	-- Previous Must Recorded The Used Prop
	assert(self.needConfirmPropId)

	-- Send Server User This Prop Message
	local function onUsePropSuccess()
		self.propList:confirm(self.needConfirmPropId, pos)
		self.needConfirmPropId 			= false
		self.useItem = true
		if successCallback and type(successCallback) == 'function' then
			successCallback()
		end
	end
	onUsePropSuccess()
end

function CheckPlayScene:checkPropEnough(usePropType, propId)
	return true
end

function CheckPlayScene:addTmpPropNum( ... )
	-- body
	-- self.propList:addFakeAllProp(999)
end

local function resovlePos(pos)
	local params = nil
	if type(pos) == "string" then
		 params = string.split(pos, ",")
	end
	if params and #params > 1 then
		return tonumber(params[1]), tonumber(params[2])
	else
		return 0, 0
	end
end

local function formatReplaySteps(replaySteps, version)
	if tonumber(version) == 2 then
		local ret = {}
		if replaySteps then
			for _, v in ipairs(replaySteps) do
				local params = string.split(v, ":")
				if params[1] == "p" then
					local x1, y1 = resovlePos(params[3])
					local x2, y2 = resovlePos(params[4])
					table.insert(ret, {prop = tonumber(params[2]), x1 = x1, y1 = y1, x2 = x2, y2 = y2})
				else
					local x1, y1 = resovlePos(params[1])
					local x2, y2 = resovlePos(params[2])
					table.insert(ret, {x1 = x1, y1 = y1, x2 = x2, y2 = y2})
				end
			end
		end
		-- if _G.isLocalDevelopMode then printx(0, "formatReplaySteps:", table.tostring(ret)) end
		return ret
	else
		return replaySteps
	end
end

function CheckPlayScene:setReplay( playMode )
	-- body
	local records = self.replayRecords
	self.gameBoardLogic.replaySteps = formatReplaySteps(records.replaySteps, records.ver)
	self.gameBoardLogic:ReplayStart(playMode)
	self.gameBoardLogic:onGameInit()
	self.gameBoardLogic:setWriteReplayOff()

	--[[
	self.gameBoardLogic.dragonBoatData = records.dragonBoatData
	self.gameBoardLogic.summerWeeklyData = records.summerWeeklyData
	local dropPropConfig = records.dragonBoatPropConfig
	if type(dropPropConfig) == "table" then
		self.gameBoardLogic.dragonBoatPropConfig = LevelDropPropConfig:createWithProps(dropPropConfig.propList, dropPropConfig.totalWeight)
	end
	]]

	if self.snapshotModeEnable then
		CheckPlay:loadLocalReplaySS()
		self.gameBoardLogic:setSnapshotModeEnable()
	end
end

function CheckPlayScene:onPauseBtnTapped(...)
	assert(#{...} == 0)
	self:pause()
	local function onQuitCallback()
		self:endReplay()
	end

	local function onClosePanelBtnTappedCallback()
		self.quitDcData = nil
		self:continue()
		if self.quitDcData then self.quitDcData = nil end
	end

	local function onReplayCallback()
		onQuitCallback()
		local scene = CheckPlayScene:create(self.levelId, self.replayRecords)
		scene:startReplay()
	end

	local mode = QuitPanelMode.QUIT_LEVEL
	if LevelType.isActivityLevelType(self.levelType) then
		mode = QuitPanelMode.NO_REPLAY
	end
	local quitPanel = QuitPanel:create(mode)
	quitPanel:setOnReplayBtnTappedCallback(onReplayCallback)
	quitPanel:setOnQuitGameBtnTappedCallback(onQuitCallback)
	quitPanel:setOnClosePanelBtnTapped(onClosePanelBtnTappedCallback)
	quitPanel:popout()
end

function CheckPlayScene:passLevel(levelId, score, star, stageTime, coin, targetCount, opLog, bossCount, ...)
	self:replayResult(levelId, score, star, coin, targetCount, bossCount)
end

function CheckPlayScene:failLevel(levelId, score, star, stageTime, coin, targetCount, opLog, isTargetReached, failReason, ...)
	self:replayResult(levelId, score, star, coin, targetCount, bossCount)
end

function CheckPlayScene:onReplayErrorOccurred(errorId, error)
	if _G.isLocalDevelopMode then printx(0, ">> onReplayErrorOccurred:", table.tostring(error)) end
	if self.isCheckReplay then
		self.gameBoardLogic.replayError = error
		local function endReplay()
			
			if self.isCheckReplay and CheckPlay then
				CheckPlay:checkResult(errorId , {} , self.gameBoardLogic)
			end
			self:endReplay()
		end
		setTimeOut(endReplay, 0.1)
	end
end

function CheckPlayScene:endReplay()
	local runningScene = Director:sharedDirector():getRunningScene()
	if runningScene == self then
		if __use_low_effect then 
			FrameLoader:unloadImageWithPlists(self.fileList, true)
		end
		Director:sharedDirector():popScene()
	end
end

function CheckPlayScene:onReplayEnd()
	if type(self.onReplayEndHandler) == "function" then
		self.onReplayEndHandler()
	end
end

function CheckPlayScene:replayResult( levelId, score, star, coin, targetCount, bossCount )
	local ret = {}
	ret.levelId = levelId
	ret.totalScore = score
	ret.star = star
	ret.coin = coin
	ret.bossCount = bossCount or 0
	ret.targetCount = targetCount or 0

	if _G.isLocalDevelopMode then printx(0, "=====================Check Play Result=====================") end
	if _G.isLocalDevelopMode then printx(0, "=====================   Ver   1.0.1   =====================") end
	if _G.isLocalDevelopMode then printx(0, table.tostring(ret)) end
	if _G.isLocalDevelopMode then printx(0, "===========================================================") end


	he_log_error("****************************end:" .. os.clock() - last)

	local function endReplay()

		if self.isCheckReplay and CheckPlay then
			local retCode = CheckPlay:checkReplayReusltData(ret)
			CheckPlay:checkResult(retCode, ret , self.gameBoardLogic)
		end
		self:endReplay()
	end
	setTimeOut(endReplay, 0.1)
end

function CheckPlayScene:addStep(levelId, score, star, isTargetReached, isAddStepCallback, ...)
	
	local scheduleId 
	local function callback( ... )
		-- body
		if scheduleId then 
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleId)
		end

		if self.gameBoardLogic.replayStep <= #self.gameBoardLogic.replaySteps then 
			isAddStepCallback(true)
			self:setPauseBtnEnable(true)
		else
			isAddStepCallback(false)
		end
	end
	scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(callback, 0, false)
end

-------------------------
--显示加时间面板
-------------------------
function CheckPlayScene:showAddTimePanel(levelId, score, star, isTargetReached, addTimeCallback, ...)
	self:addStep(levelId, score, star, isTargetReached, addTimeCallback)
end

-------------------------
--显示加兔兔导弹面板
-------------------------
function CheckPlayScene:showAddRabbitMissilePanel( levelId, score, star, isTargetReached, isAddPropCallback )
	-- body
	self:addStep( levelId, score, star, isTargetReached, isAddPropCallback)
end

function CheckPlayScene:addTemporaryItem(itemId, itemNum, fromGlobalPosition, ...)
	self.propList:addTemporaryItem(itemId, itemNum, fromGlobalPosition)
end

function CheckPlayScene:addTimeProp(propId, num, fromGlobalPosition, activityId, text)
	local propMeta = MetaManager:getInstance():getPropMeta(propId)
	if propMeta and propMeta.expireTime then
		local expireTime = os.time() * 1000 + propMeta.expireTime
		self.propList:addTimeProp(propId, num, expireTime, fromGlobalPosition, nil, text)
	end
	StageInfoLocalLogic:getPropsInGame(UserManager.getInstance().user.uid, self.levelId, {propId})
end

function CheckPlayScene:dispose()
	StageInfoLocalLogic:clearStageInfo( UserManager.getInstance().user.uid )
	if CheckPlayCrashListener then
		GlobalEventDispatcher:getInstance():removeEventListener("lua_crash", CheckPlayCrashListener)
		CheckPlayCrashListener = nil
	end
	GamePlaySceneUI.dispose(self)
end