require "zoo.replaykit.ReplayRecordButton"

ReplayRecordController = class()

function ReplayRecordController:ctor()
	self.recordButton = nil
	self.playScene = nil
end

function ReplayRecordController:create(playScene)
	local controller = ReplayRecordController.new()
	controller.playScene = playScene
	return controller
end

function ReplayRecordController.isReplaykitSupport()
	if __IOS then
		-- return ReplayManager:getInstance():isRecordAvailble()
		return false
	else
		return false
	end
end

function ReplayRecordController:addRecordButton(position)
	if self.playScene then
		self.recordButton = ReplayRecordButton:create()
		self.recordButton:setPosition(position)
		if self.playScene.extandLayer then
			self.playScene.extandLayer:addChild(self.recordButton)
		else
			self.playScene:addChild(self.recordButton)
		end
	end
end

function ReplayRecordController:stopWithoutPreview( ... )
	if self:isRecording() then
		local function callback()
			if __IOS then
				ReplayManager:getInstance():discardPreview(nil)
			end
		end
		self.recordButton:onStopRecordButtonTapped(callback)
	end
end

function ReplayRecordController:stopWithPreview( ... )
	if self:isRecording() then
		local function callback()
			local dcData = { 
				game_type = "stage",
				game_name = "2016_spring_festival",
				category = "record",
				sub_category = "spring_festival_record_success",
				t1 = 2,
			}
			DcUtil:log(109, dcData)
			GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kShowReplayRecordPreview))
		end
		self.recordButton:onStopRecordButtonTapped(callback)
	end
end

function ReplayRecordController:isRecording()
	return self.recordButton and self.recordButton:isRecording() 
end

function ReplayRecordController:hasPreview()
	if __IOS then
		return ReplayManager:getInstance():hasPreview()
	end
	return false
end

function ReplayRecordController:showPreview()
	if __IOS then
		local winSize 	= CCDirector:sharedDirector():getWinSize()
		local rect = ReplayManager:createCGRect_y_width_height(winSize.width / 2 + 195, winSize.height / 2 - 140, 0, 0)

		local function onSuccess(data)
			-- resume music
			if GamePlayMusicPlayer:getInstance().IsBackgroundMusicOPen then
				SimpleAudioEngine:sharedEngine():resumeBackgroundMusic()
			end

			local userActTypes = data and tostring(data.activityTypes) or ""
			-- if _G.isLocalDevelopMode then printx(0, "PreviewFinishCallback:onSuccess:", table.tostring(data.activityTypes)) end
			local dcData = { 
				game_type = "stage",
				game_name = "2016_spring_festival",
				category = "record",
				sub_category = "spring_festival_record_handle",
				actTypes = userActTypes,
			}
			DcUtil:log(109, dcData)
		end

		local function onFailed(err)
		end

		local onFinishCallback = WaxSimpleCallback:createSimpleCallbackDelegate(onSuccess, onFailed)

		local function onShowSuccess(data)
			-- pause music
			if GamePlayMusicPlayer:getInstance().IsBackgroundMusicOPen then
				SimpleAudioEngine:sharedEngine():pauseBackgroundMusic()
			end
		end

		local function onShowFailed(err)
		end
		local onShowCallback = WaxSimpleCallback:createSimpleCallbackDelegate(onShowSuccess, onShowFailed)
		ReplayManager:getInstance():showPreviewRect_completion_withCloseHandler(rect, onShowCallback, onFinishCallback)
	end
end

function ReplayRecordController:onEnterBackground()
	if self.recordButton and self.recordButton:isRecording() then
		self.recordButton:pauseRecordTimer()
	end
end

function ReplayRecordController:onEnterForeGround()
	if self.recordButton and self.recordButton:isRecording() then
		self.recordButton:resumeRecordTimer()
	end
end

function ReplayRecordController:dispose()
	self.playScene = nil
	self.recordButton = nil
end