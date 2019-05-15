require "zoo.panel.ReplayRecordGuidePanel"

------
ReplayRecordButtonLogic = class()

function ReplayRecordButtonLogic:ctor()
end

function ReplayRecordButtonLogic:create(button)
	local logic = ReplayRecordButtonLogic.new()
	logic.button = button
	return logic
end

function ReplayRecordButtonLogic:dispose()
	self.button = nil
end

function ReplayRecordButtonLogic:startRecord(onSuccess, onFail)
	if onSuccess then onSuccess(data) end
end

function ReplayRecordButtonLogic:stopRecord(onSuccess, onFail)
	if onSuccess then onSuccess(data) end
end

function ReplayRecordButtonLogic:onRecordTimeOut()
	self.button:onStopRecordButtonTapped()
end
-------

IOSReplayRecordButtonLogic = class(ReplayRecordButtonLogic)

function IOSReplayRecordButtonLogic:ctor()
end

function IOSReplayRecordButtonLogic:create(button)
	local logic = IOSReplayRecordButtonLogic:new()
	logic.button = button
	return logic
end

function IOSReplayRecordButtonLogic:startRecord(onSuccess, onFail)
	local function onStartRecordSuccess( data )
		-- if _G.isLocalDevelopMode then printx(0, "~~~IOSReplayRecordButtonLogic:startRecord") end
		if onSuccess then onSuccess(data) end
	end
	local function onStartRecordFailed( data )
		if onFail then onFail(data) end
	end

	local callback = WaxSimpleCallback:createSimpleCallbackDelegate(onStartRecordSuccess, onStartRecordFailed)
	ReplayManager:getInstance():startRecord(callback)
end

function IOSReplayRecordButtonLogic:stopRecord(onSuccess, onFail)
	local function stopSuccess(data)
		self.stopRecordCallback = nil
		if onSuccess then onSuccess(data) end
	end
	local function stopFailed(data)
		self.stopRecordCallback = nil
		if onFail then onFail(data) end
	end

	local callback = WaxSimpleCallback:createSimpleCallbackDelegate(stopSuccess, stopFailed)
	ReplayManager:getInstance():stopRecord(callback)
end

function IOSReplayRecordButtonLogic:onRecordTimeOut()
	local function callback( ... )
		local recordTimeout = CCUserDefault:sharedUserDefault():getBoolForKey("replaykit.record.timeout")
		if not recordTimeout then
			local function tipCallback()
				GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kShowReplayRecordPreview))
			end
			CommonTip:showTip(Localization:getInstance():getText("record.time.up.tip"), "positive", tipCallback)
			CCUserDefault:sharedUserDefault():setBoolForKey("replaykit.record.timeout", true)
		else
			GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kShowReplayRecordPreview))
		end
		local dcData = { 
			game_type = "stage",
			game_name = "2016_spring_festival",
			category = "record",
			sub_category = "spring_festival_record_success",
			t1 = 2,
		}
		DcUtil:log(109, dcData)
	end
	self.button:onStopRecordButtonTapped(callback)
end
-------------------------------------------------------

ReplayRecordButton = class(CocosObject)

local kRecordTimeLimit = 61 

ReplayRecordButtonState = {
	kWaiting = 0,
	kRecording = 1,
	kProcessing = 2,
}

function ReplayRecordButton:ctor()
	self.buttonState = ReplayRecordButtonState.kWaiting
	self.buttonLogic = nil
end

function ReplayRecordButton:create()
	local button = ReplayRecordButton.new(CCNode:create())
	button:init()
	return button
end

function ReplayRecordButton:init()
    local builder = LayoutBuilder:createWithContentsOfFile("ui/replay_record_button.json")
    self.ui = builder:build("record_button/recordBtn")
    self:addChild(self.ui)
    local processingIcon = self.ui:getChildByName("processing")
    if processingIcon then
    	local bounds = processingIcon:getGroupBounds()
    	processingIcon:setAnchorPoint(ccp(0.5, 0.5))
		processingIcon:ignoreAnchorPointForPosition(false)
		processingIcon:setPosition(ccp(bounds.origin.x + bounds.size.width/2, bounds.origin.y + bounds.size.height/2))
    end
  
    self:updateState(ReplayRecordButtonState.kWaiting)

    local newflag = CCUserDefault:sharedUserDefault():getBoolForKey("replaykit.record.newflag")
    if newflag then
    	self.ui:getChildByName("new_flag"):setVisible(false)
    	self.isNewFlagVisible = false
    else
    	self.isNewFlagVisible = true
    end

    self.ui:setTouchEnabled(true)

    if __IOS then
	    self.buttonLogic = IOSReplayRecordButtonLogic:create(self)
	else
	    self.buttonLogic = ReplayRecordButtonLogic:create(self)
	end
end

function ReplayRecordButton:onStartRecordButtonTapped(callback)
	local dcData = { 
		game_type = "stage",
		game_name = "2016_spring_festival",
		category = "record",
		sub_category = "spring_festival_click_record",
	}
	DcUtil:log(109, dcData)

	if self.isNewFlagVisible then
		CCUserDefault:sharedUserDefault():setBoolForKey("replaykit.record.newflag", true)
    	self.ui:getChildByName("new_flag"):setVisible(false)
    	self.isNewFlagVisible = false
	end

	-- 第一次录屏弹出引导面板
	self:updateState(ReplayRecordButtonState.kProcessing)

	local function startRecord()
		local function onStartRecordSuccess(data)
			local dcData = { 
				game_type = "stage",
				game_name = "2016_spring_festival",
				category = "record",
				sub_category = "spring_festival_record_start",
			}
			DcUtil:log(109, dcData)

			self:updateState(ReplayRecordButtonState.kRecording)
			if callback then callback() end
		end
		local function onStartRecordFailed(data)
			self:updateState(ReplayRecordButtonState.kWaiting)
			if callback then callback() end
		end
		self.buttonLogic:startRecord(onStartRecordSuccess, onStartRecordFailed)
	end
	local replayGuided = CCUserDefault:sharedUserDefault():getBoolForKey("replaykit.record.guide")
	if not replayGuided then
		local guidePanel = ReplayRecordGuidePanel:create()
		guidePanel:popout(startRecord, startRecord)
		CCUserDefault:sharedUserDefault():setBoolForKey("replaykit.record.guide", true)
	else
		startRecord()
	end
end

function ReplayRecordButton:onStopRecordButtonTapped(callback)
	self:stopRecordTimer()
	self:updateState(ReplayRecordButtonState.kProcessing)
	local function stopSuccess(data)
		self:updateState(ReplayRecordButtonState.kWaiting)
		if callback then callback() end
	end
	local function stopFailed(data)
		self:updateState(ReplayRecordButtonState.kWaiting)
		if callback then callback() end
	end
	self.buttonLogic:stopRecord(stopSuccess, stopFailed)
end

function ReplayRecordButton:clearState()
	self.ui:getChildByName("record_flag"):stopAllActions()
	self.ui:getChildByName("record_time"):stopAllActions()
	self.ui:getChildByName("processing"):stopAllActions()

	self.ui:getChildByName("record_flag"):setVisible(false)
	self.ui:getChildByName("record_time"):setVisible(false)
	self.ui:getChildByName("waiting"):setVisible(false)
	self.ui:getChildByName("recording"):setVisible(false)
	self.ui:getChildByName("processing"):setVisible(false)
end

function ReplayRecordButton:setWaitingState()
	self.ui:getChildByName("waiting"):setVisible(true)
end

function ReplayRecordButton:setRecordingState()
	self.ui:getChildByName("recording"):setVisible(true)
	self.ui:getChildByName("record_flag"):setVisible(true)
	self.ui:getChildByName("record_time"):setVisible(true)
	self.ui:getChildByName("record_time"):setVisible(true)
	self.ui:getChildByName("record_time"):setString("00:00")
	local flagActions = CCArray:create()
	flagActions:addObject(CCDelayTime:create(0.5))
	flagActions:addObject(CCFadeOut:create(0))
	flagActions:addObject(CCDelayTime:create(0.5))
	flagActions:addObject(CCFadeIn:create(0))
	self.ui:getChildByName("record_flag"):runAction(CCRepeatForever:create(CCSequence:create(flagActions)))

	self:startRecordTimer()
end

function ReplayRecordButton:setProcessingState()
	self.ui:getChildByName("processing"):setVisible(true)
	self.ui:getChildByName("processing"):runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCDelayTime:create(4/30), CCRotateBy:create(0, 45))))
end

function ReplayRecordButton:updateState(state)
	if self.ui and not self.ui.isDisposed then
		self.ui:removeEventListenerByName(DisplayEvents.kTouchTap)
		self:clearState()
		if state == ReplayRecordButtonState.kProcessing then
			self:setProcessingState()
		elseif state == ReplayRecordButtonState.kRecording then
			self:setRecordingState()
			local function onButtonTapped(evt)
				local function callback( ... )
					local dcData = { 
						game_type = "stage",
						game_name = "2016_spring_festival",
						category = "record",
						sub_category = "spring_festival_record_success",
						t1 = 1,
					}
					DcUtil:log(109, dcData)
					GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kShowReplayRecordPreview))
				end
				self:onStopRecordButtonTapped(callback)
			end
    		self.ui:addEventListener(DisplayEvents.kTouchTap, onButtonTapped)
		else
			self:setWaitingState()
			local function onButtonTapped(evt)
				self:onStartRecordButtonTapped()
			end
    		self.ui:addEventListener(DisplayEvents.kTouchTap, onButtonTapped)
		end
		self.buttonState = state
	end
end

function ReplayRecordButton:isRecording()
	if not self.isDisposed then
		return self.buttonState == ReplayRecordButtonState.kRecording
	else
		return false
	end
end

function ReplayRecordButton:updateRecordTime()
	local curTime = os.time()
	self.recordTime = self.recordTime + (curTime - self.lastTimestamp)
	self.lastTimestamp = curTime
	local leftTime = kRecordTimeLimit - self.recordTime

	local displayTime = leftTime - 1
	if displayTime < 0 then displayTime = 0 end
	local minutes = math.floor(displayTime / 60)
	local seconds = displayTime % 60
	self.ui:getChildByName("record_time"):setString(string.format("%02d:%02d", minutes, seconds))

	if leftTime <= 0 then
		self.buttonLogic:onRecordTimeOut()
	end
end

function ReplayRecordButton:stopRecordTimer()
	self.recordTime = 0
	self.lastTimestamp = 0

	if self.ui and not self.ui.isDisposed then
		self.ui:getChildByName("record_time"):stopAllActions()
	end
end

function ReplayRecordButton:resumeRecordTimer()
	self.lastTimestamp = os.time()

	if self.ui and not self.ui.isDisposed then
		local function updateRecordTime()
			self:updateRecordTime()
		end
		self.ui:getChildByName("record_time"):runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCCallFunc:create(updateRecordTime), CCDelayTime:create(0.5))))
	end
end

function ReplayRecordButton:pauseRecordTimer()
	local curTime = os.time()
	self.recordTime = self.recordTime + (curTime - self.lastTimestamp)
	self.lastTimestamp = curTime

	if self.ui and not self.ui.isDisposed then
		self.ui:getChildByName("record_time"):stopAllActions()
	end
end

function ReplayRecordButton:startRecordTimer(time)
	self.recordTime = 0
	self.lastTimestamp = os.time()
	
	if self.ui and not self.ui.isDisposed then
		local function updateRecordTime()
			self:updateRecordTime()
		end
		self.ui:getChildByName("record_time"):runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCCallFunc:create(updateRecordTime), CCDelayTime:create(0.5))))
	end
end

function ReplayRecordButton:dispose()
	self.buttonLogic:dispose()
	self.buttonLogic = nil

	CocosObject.dispose(self)
end

return ReplayRecordButton