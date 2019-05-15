local RecordController = require('zoo.gamePlay.review.RecordController')

local dcInfo = {}

local Context = class()

function Context:ctor( ... )
	self.paused = true
	self.recording = false
	self.cachedSpeedSwitch = GameSpeedManager:getGameSpeedSwitch()
	self.savedPath = savedPath
	self.endPanel = nil
end

function Context:setQuitWithoutEndPanel( quitWithoutEndPanel )
	self.quitWithoutEndPanel = quitWithoutEndPanel
end

function Context:getQuitWithoutEndPanel( ... )
	return self.quitWithoutEndPanel
end

function Context:setEndPanel( endPanel )
	self.endPanel = endPanel
end

function Context:getEndPanel( ... )
	return self.endPanel
end

function Context:isPaused( ... )
	return self.paused
end

function Context:setPaused( paused )
	self.paused = paused
end

function Context:setGameBoardLogic( logic )
	self.mainLogic = logic
end

function Context:getPlayUIDelegate( ... )
	if self.mainLogic then
		return self.mainLogic.PlayUIDelegate
	end
end

function Context:setSavedPath( savedPath )
	self.savedPath = savedPath
end

function Context:getSavedPath( ... )
	local ret = self.savedPath
	self.savedPath = nil
	return ret
end

function Context:getGameBoardLogic( ... )
	return self.mainLogic
end

function Context:setMenu( menu )
	self.menu = menu
end

function Context:setRecordingMenu( recordingMenu )
	self.recordingMenu = recordingMenu
end

function Context:getMenu( ... )
	return self.menu
end

function Context:getRecordingMenu( ... )
	return self.recordingMenu
end

function Context:setRecording( recording )
	self.recording = recording
end

function Context:isRecording( ... )
	return self.recording
end

local UserReviewLogic = {}

function UserReviewLogic:test( ... )
	local replayData = ReplayDataManager:readLastSuccessReplayCache()
	-- Localhost:safeWriteStringToFile( table.tostring(replayData) , HeResPathUtils:getUserDataPath() .. "/" .. 'debug.rep')
	if replayData and replayData.level then
		require "zoo.panelBusLogic.NewStartLevelLogic"
		local newStartLevelLogic = NewStartLevelLogic:create(nil, replayData.level, {}, false, {})
		newStartLevelLogic:startWithReplay(ReplayMode.kReview, replayData)
	else
		-- CommonTip:showTip('巧妇难为无米之炊 没有replayData播个毛线')
	end
end

function UserReviewLogic:onWaitingNextStep( mainLogic, nextStepDelegate, errorHandler)
	local nextStepType, nextStepDetails = self:getNextStepInfo(mainLogic)


	local err, msg = self:checkScoreError(mainLogic)
	if err then
		if errorHandler then errorHandler('score exception!' .. msg) end
		return
	end

	if nextStepType == 'swap' then
		local canSwap = mainLogic:SwapedItemAndMatch(
			nextStepDetails[1], 
			nextStepDetails[2], 
			nextStepDetails[3], 
			nextStepDetails[4], 
			false)
		if canSwap and (not (MaintenanceManager:getInstance():isEnabled("userreviewerror") and mainLogic.theCurMoves <= 15 )  ) then
			self:tryDoNextStep(nextStepDelegate)
		else
			if errorHandler then errorHandler("can't swap!") end
		end
	elseif nextStepType == 'prop' then
		local canUse = mainLogic:isUsePropsValid(
			nextStepDetails[1],
			nextStepDetails[3],
			nextStepDetails[4],
			nextStepDetails[5],
			nextStepDetails[6]
		)

		if canUse then
			self:tryDoNextStep(nextStepDelegate)
		else
			if errorHandler then errorHandler("can't use prop " .. nextStepDetails[1]) end
		end
	end
end

function UserReviewLogic:tryDoNextStep( nextStepDelegate )
	if not self.context then return end
	if self.context:isPaused() then
		self.nextStepDelegate = nextStepDelegate
	else
		self:doNextStep(nextStepDelegate)
	end
end

function UserReviewLogic:doNextStep( nextStepDelegate, finishCallback )
	if not self.context then return end

	local nextStepType, nextStepDetails = self:getNextStepInfo(self.context:getGameBoardLogic())
	if nextStepType == 'swap' then
		self:showSwapAnimation(nextStepDetails, function ( ... )
			if nextStepDelegate then nextStepDelegate() end
			if finishCallback then finishCallback() end
		end)
	else

		setTimeOut(function ( ... )
			if nextStepDelegate then nextStepDelegate() end
			if finishCallback then finishCallback() end
		end, 1)
		
	end
end

function UserReviewLogic:showSwapAnimation(nextStepDetails, finishCallback )
	if not self.context then return end
	local playUIDelegate = self.context:getPlayUIDelegate()

	if not playUIDelegate then

		return
	end

	local r1, c1, r2, c2 = nextStepDetails[1], nextStepDetails[2], nextStepDetails[3], nextStepDetails[4]

	local p1 = self:getBoardViewTilePos(playUIDelegate, 9 - (r1 - 0.5), c1 - 0.5)
	local p2 = self:getBoardViewTilePos(playUIDelegate, 9 - (r2 - 0.5), c2 - 0.5)
	local from = p1
	local to = p2
	local handAnim = GameGuideAnims:handslideAnim(from, to)
	playUIDelegate.otherElementsLayer:addChild(handAnim)

	setTimeOut(function ( ... )
		if playUIDelegate and (not playUIDelegate.isDisposed) then
			playUIDelegate.otherElementsLayer:removeChild(handAnim, true)
			if finishCallback then finishCallback() end
		end
	end, 3)
end

function UserReviewLogic:getBoardViewTilePos(gamePlaySceneUI, tileR, tileC )
	local gameBoardView = gamePlaySceneUI.gameBoardView
	local posY = (tileR) * 70
	local posX = (tileC) * 70
	local gPos = gameBoardView:convertToWorldSpace(ccp(posX, posY))
	local lPos = gamePlaySceneUI:convertToNodeSpace(gPos)
	return lPos
end

function UserReviewLogic:checkScoreError( mainLogic )
	-- body
	if not GamePlayContext:getInstance().replayData then return true, 'no replay data' end
	if not GamePlayContext:getInstance().replayData.scoreLogs then return true, 'no score logs' end

	local desireScore = GamePlayContext:getInstance().replayData.scoreLogs['n' .. mainLogic.replayStep] or -61
	local score = mainLogic.totalScore or 0

	local err = not table.exist(GamePlayContext:getInstance().replayData.scoreLogs, score)
	return err, "can't find score " .. score
end

function UserReviewLogic:onStartLevel( mainLogic )
	if not GamePlayContext:getInstance().replayData then return end
	self.context = Context.new()
	self.context:setGameBoardLogic(mainLogic)

	RecordController:getInstance():setStartRecordCallback(function ( ... )
		self:afterStartRecordSuccess()
	end, function ( err, errMsg )
		self:afterStartRecordFail(err, errMsg)
	end)
	RecordController:getInstance():setStopRecordCallback(function ( savedPath )
		self:afterStopRecordSuccess(savedPath)
	end, function ( ... )
		self:afterStopRecordFail(...)
	end)
end

function UserReviewLogic:afterStartRecordSuccess( ... )
	if not self.context then return end
	if self.context:getMenu() then
		self.context:getMenu():setVisible(false)
		self:onMenuCommand(self.context:getMenu(), 'startReplay')
	end

	if self.context:getRecordingMenu() then
		self.context:getRecordingMenu():setVisible(true)
		self.context:getRecordingMenu():startRecordingAnim()
	end

	self.context:setRecording(true)

end

function UserReviewLogic:afterStartRecordFail( err, errMsg )
	CommonTip:showTip('录屏开启失败')
end

function UserReviewLogic:afterStopRecordSuccess( savedPath )
	if not self.context then return end
	if self.context:getMenu() then
		self.context:getMenu():setVisible(true)
	end

	if self.context:getRecordingMenu() then
		self.context:getRecordingMenu():setVisible(false)
		-- self.context:getRecordingMenu():stopRecordingAnim()
	end
	self.context:setRecording(false)

	if savedPath then
		self.context:setSavedPath(savedPath)
		local panel = self.context:getEndPanel()
		if panel then
			panel:setSavedPath(self.context:getSavedPath())
		end
	end
end

function UserReviewLogic:afterStopRecordFail( ... )
end

function UserReviewLogic:getNextStepInfo( mainLogic )
	local r1 = mainLogic.replaySteps[mainLogic.replayStep].x1
	local c1 = mainLogic.replaySteps[mainLogic.replayStep].y1
	local r2 = mainLogic.replaySteps[mainLogic.replayStep].x2
	local c2 = mainLogic.replaySteps[mainLogic.replayStep].y2
	local propId = mainLogic.replaySteps[mainLogic.replayStep].prop
	local propsUseType = mainLogic.replaySteps[mainLogic.replayStep].pt
    if not propId then
		return 'swap', {r1, c1, r2, c2}
	else
		return 'prop', {propId, propsUseType, r1, c1, r2, c2}
	end
end

local function getWorldCenter( ... )
	-- body
	local vs = Director:sharedDirector():getVisibleSize()
	local vo = Director:sharedDirector():getVisibleOrigin()

	return ccp(vo.x + vs.width/2, vo.y + vs.height/2)
end

function UserReviewLogic:attachMenu( gamePlaySceneUI )

	-- 录制前显示的菜单
	self:attachMenu_1(gamePlaySceneUI)


	-- 录制中显示的菜单
	self:attachMenu_2(gamePlaySceneUI)
	
end

function UserReviewLogic:attachMenu_1( gamePlaySceneUI )
	local UserReviewMenu = require 'zoo.gamePlay.review.UserReviewMenu'
	local menu = UserReviewMenu:create()
	menu.name = "UserReviewMenu"
	gamePlaySceneUI:superAddChild(menu)
	local lPos = self:getBoardViewTilePos(gamePlaySceneUI, -0.5, 4.5)
	menu:setPositionY(lPos.y)
	local center = getWorldCenter()
	center = gamePlaySceneUI:convertToNodeSpace(center)
	menu:setPositionX(center.x)
	menu:setDelegate(self)
	menu:setIsPlaying(false)
	menu:setSpeed(GameSpeedManager:getGameSpeedSwitch())
	self.context:setMenu(menu)
	menu:tryShowGuide_2()
end

function UserReviewLogic:attachMenu_2( gamePlaySceneUI )
	local UserReviewRecordingMenu = require 'zoo.gamePlay.review.UserReviewRecordingMenu'
	local menu = UserReviewRecordingMenu:create()
	menu.name = 'UserReviewRecordingMenu'
	gamePlaySceneUI:superAddChild(menu)
	local lPos = self:getBoardViewTilePos(gamePlaySceneUI, gamePlaySceneUI.gameBoardView.startRowIndex + gamePlaySceneUI.gameBoardView.rowCount - 1 + 0.24, 4.5)
	menu:setPositionY(lPos.y)
	local center = getWorldCenter()
	center = gamePlaySceneUI:convertToNodeSpace(center)
	menu:setPositionX(15)
	menu:findChildByName('logo'):setPositionX(center.x)
	menu:setDelegate(self)
	menu:setName(UserManager:getInstance().profile:getDisplayName())
	menu:reset()
	menu:setVisible(false)
	self.context:setRecordingMenu(menu)
end

function UserReviewLogic:detachMenu( gamePlaySceneUI )

	-- detach menu 1		
	local menu = gamePlaySceneUI:getChildByName("UserReviewMenu")
	if menu then
		menu:setDelegate(nil)
		gamePlaySceneUI:superRemoveChild(menu, true)
	end

	-- detach menu 2
	local menu = gamePlaySceneUI:getChildByName("UserReviewRecordingMenu")
	if menu then
		menu:setDelegate(nil)
		gamePlaySceneUI:superRemoveChild(menu, true)
	end

	if self.context then
		self.context:setMenu(nil)
		self.context:setRecordingMenu(nil)
	end
end

function UserReviewLogic:onReplayError( ... )
	if not self.context then return end
	local mainLogic = self.context:getGameBoardLogic()
	local curMoves = 0
	if mainLogic then
		curMoves = mainLogic.theCurMoves or 0
	end
	DcUtil:UserTrack({category='video', sub_category='video_exit', 
		t1 = dcInfo.t1, 
		t2 = dcInfo.t2,
		t3 = dcInfo.t3,
		t4 = curMoves,
	}, false)


	setTimeOut(function ( ... )
		if not self.context then return end
		local gamePlaySceneUI = self.context:getPlayUIDelegate()
		if self.context:isRecording() then
			local menu = gamePlaySceneUI:getChildByName("UserReviewRecordingMenu")
			self:onMenuCommand(menu, 'stopRecord')
		else
			local menu = gamePlaySceneUI:getChildByName("UserReviewMenu")
			self:onMenuCommand(menu, 'close')
		end
	end, 0.1)
end

function UserReviewLogic:onMenuCommand(menu, message )
	if not self.context then return end
	lua_switch(message){
		close = function ( ... )
			local scene = Director:sharedDirector():run()
			if scene.name == 'GamePlaySceneUI' then

				menu:setVisible(false)
				self.context:setQuitWithoutEndPanel(true)

				ReplayDataManager:onPassLevel( ReplayDataEndType.kQuit , 0)

				if scene.endReplay then
					scene:endReplay()
				end
			end
		end,
		startRecord = function ( ... )

			local mainLogic = self.context:getGameBoardLogic()
			local curMoves = 0
			if mainLogic then
				curMoves = mainLogic.theCurMoves or 0
			end

			DcUtil:UserTrack({category='video', sub_category='video_record_button', 
				t1 = dcInfo.t1, 
				t2 = dcInfo.t2,
				t3 = dcInfo.t3,
				t4 = curMoves,
			}, false)

			self:onMenuCommand(menu, 'stopReplay')

			if self.context:getRecordingMenu() then
				self.context:getRecordingMenu():reset()
			end

			RecordController:getInstance():startRecord()
		end,
		stopRecord = function ( ... )
			if self.context:getRecordingMenu() then
				self.context:getRecordingMenu():stopRecordingAnim()
			end
			if self.context:getMenu() then
				self:onMenuCommand(self.context:getMenu(), 'stopReplay')
			end


			local UserReviewEndPanel = require 'zoo.gamePlay.review.UserReviewEndPanel'
			local panel = UserReviewEndPanel:create()
			panel:setDelegate(self)
			panel:popout()
			self.context:setEndPanel(panel)


			local playUIDelegate = self.context:getPlayUIDelegate()
			if playUIDelegate then
				playUIDelegate:onReplayEnd()
			end



			setTimeOut(function ( ... )
				RecordController:getInstance():stopRecord()
			end, 0.5)
			
			DcUtil:UserTrack({category='video', sub_category='video_pause_button', 
				t1 = dcInfo.t1, 
				t2 = dcInfo.t2,
				t3 = dcInfo.t3,
				t4 = curMoves,
			}, false)


		end,
		startReplay = function ( ... )
			menu:setIsPlaying(true)
			self.context:setPaused(false)
			if self.nextStepDelegate then
				self:doNextStep(self.nextStepDelegate)
				self.nextStepDelegate = nil
			end
		end,
		stopReplay = function ( ... )
			menu:setIsPlaying(false)
			self.context:setPaused(true)
		end,
		speedDown = function ( ... )
			-- body
			local speed = GameSpeedManager:getGameSpeedSwitch()
			speed = speed - 1
			speed = math.clamp(speed, 0, 2)
			GameSpeedManager:setGameSpeedSwitch(speed)
			GameSpeedManager:changeSpeedForFastPlay()
			menu:setSpeed(speed)
		end,
		speedUp = function ( ... )
			-- body
			local speed = GameSpeedManager:getGameSpeedSwitch()
			speed = speed + 1
			speed = math.clamp(speed, 0, 2)
			GameSpeedManager:setGameSpeedSwitch(speed)
			GameSpeedManager:changeSpeedForFastPlay()
			menu:setSpeed(speed)
		end,

		quitReplay = function ( ... )
			local curScene = Director:sharedDirector():run()
			if curScene.name == 'GamePlaySceneUI' then
				Director:sharedDirector():popScene()
				self.context = nil

				HomeScene:sharedInstance():runAction(CCCallFunc:create(function ( ... )
					require('zoo.quest.actions.PlayLevelAction'):doAction({GameLevelType.kMainLevel}, true)
				end))
			end
		end,

		replayAgain = function ( ... )
			UserReviewLogic:test()
		end
	}
end


function UserReviewLogic:cacheDCInfo( t1, t2, t3 )
	dcInfo.t1 = t1
	dcInfo.t2 = t2
	dcInfo.t3 = t3
end

function UserReviewLogic:onReplayEnd( ... )
	if not self.context then return end

	GameSpeedManager:setGameSpeedSwitch(self.context.cachedSpeedSwitch)


	if self.context:getQuitWithoutEndPanel() then
		self:onMenuCommand(nil, 'quitReplay')
	else

		local UserReviewEndPanel = require 'zoo.gamePlay.review.UserReviewEndPanel'
		local panel = UserReviewEndPanel:create()
		panel:setDelegate(self)
		panel:popout()
		self.context:setEndPanel(panel)

		setTimeOut(function ( ... )
			if not self.context then return end
			if self.context:isRecording() then
				RecordController:getInstance():stopRecord()
			end
		end, 0.5)		
	end

end


function UserReviewLogic:isEnabled( ... )
	if __WIN32 then return true end

	if __IOS then
		if AppController:getSystemVersion() < 10 then return false end
	end

	local mainSwitch = MaintenanceManager:getInstance():isEnabled("videoRecord")

	if mainSwitch then

		local value = MaintenanceManager:getInstance():getValue('videoRecord') or 150
		local topLevel = UserManager.getInstance().user:getTopLevelId() or 0


		return (tonumber(topLevel) or 0) > (tonumber(value) or 0)
	end

	return false
end


return UserReviewLogic