GameSpeedManager = {}
GameSpeedManager.speedSwitchKey = "GameSpeedManager_speedSwitchKey"
GameSpeedManager.fpsWarningTipFlagKey = "GameSpeedManager_fpsWarningTip"
GameSpeedManager.filekey = "GameSpeedManager_data"

local detectionCycle = 3
local failureThreshold = 0.75
-- local maxCCount = 6
local maxCCount = 9999
-- local maxTCount = 12
local maxTCount = 99999

local globalData = {}
local levelData = {}

function GameSpeedManager:startLevel( levelId )
	levelData = {}

	levelData.inLevel = true

	levelData.levelId = levelId
	levelData.detectionCycle = detectionCycle
	levelData.failureThreshold = failureThreshold
	levelData.maxCCount = maxCCount
	levelData.maxTCount = maxTCount

	levelData.logList = {}
	levelData.maxContinuousFailedCount = 0
	levelData.totalFailedCount = 0
	levelData.FPS_inMaxContinuousFailedCycle = 0
	levelData.FPS_inTotalFailedCycle = 0
	levelData.FPS_inTotalCycle = 0
	levelData.FPS_failedCycleRate = 0

	levelData.DIFF_inMaxContinuousFailedCycle = 0
	levelData.DIFF_inTotalFailedCycle = 0
	levelData.DIFF_inTotalCycle = 0
	levelData.DIFF_failedCycleRate = 0

	self.fpsWarningTipFlag = self:getFPSWarningTipFlag()

	self:stopFPSWatcher()
	local speedScale = self:getSpeedScaleBySwitch()
	local targetFPS = 60 * speedScale
	self:startFPSWatcher( targetFPS )
end

function GameSpeedManager:endLevel()
	
	if not levelData or not levelData.inLevel then
		levelData = {}
		return
	end

	local totalCycleCount = #levelData.logList

	if totalCycleCount == 0 then return end

	local maxContinuousCount = 0
	local continuousCount = 0
	local failedCount = 0
	
	local totalDiff = 0	
	local continuousDiff = 0
	local maxContinuousDiff = 0	
	local failedDiff = 0	

	local totalFPS = 0	
	local continuousFPS = 0
	local maxContinuousFPS = 0	
	local failedFPS = 0	

	for k,v in ipairs( levelData.logList ) do

		totalFPS = totalFPS + v.fps
		totalDiff = totalDiff + v.diffRate

		if v.result then
			continuousCount = 0
			continuousFPS = 0
			continuousDiff = 0
		else
			failedCount = failedCount + 1
			failedFPS = failedFPS + v.fps
			failedDiff = failedDiff + v.diffRate

			continuousCount = continuousCount + 1
			continuousFPS = continuousFPS + v.fps
			continuousDiff = continuousDiff + v.diffRate

			if continuousCount > maxContinuousCount then
				maxContinuousCount = continuousCount
				maxContinuousFPS = continuousFPS
				maxContinuousDiff = continuousDiff
			end
		end
	end

	local resultData = {}

	resultData.totalCycleCount = totalCycleCount
	resultData.maxContinuousCount = maxContinuousCount
	resultData.failedCount = failedCount

	resultData.failedRate = failedCount / totalCycleCount

	resultData.averageTotalFPS = totalFPS / totalCycleCount
	resultData.averageMaxContinuousFPS = maxContinuousFPS / maxContinuousCount
	resultData.averageFailedFPS = failedFPS / failedCount

	resultData.averageTotalDiff = totalDiff / totalCycleCount
	resultData.averageMaxContinuousDiff = maxContinuousDiff / maxContinuousCount
	resultData.averageFailedDiff = failedDiff / failedCount

	resultData.level = levelData.levelId
	resultData.detectionCycle = levelData.detectionCycle
	resultData.failureThreshold = levelData.failureThreshold
	resultData.maxCCount = levelData.maxCCount
	resultData.maxTCount = levelData.maxTCount

	if not globalData["l" .. tostring(resultData.level)] then
		globalData["l" .. tostring(resultData.level)] = {}
	end

	table.insert( globalData["l" .. tostring(resultData.level)] , resultData )

	DcUtil:levelSpeedMonitoring( resultData )

	self:stopFPSWatcher()

	levelData = {}
end

function GameSpeedManager:changeSpeed( speedScale , pauseSoundEffects )

	local fps = math.abs( math.floor(speedScale * 60) )
	printx( -6 , "GameSpeedManager:changeSpeed ----------> speedScale:" .. tostring(speedScale) , "speedScale:" .. tostring(speedScale) )

	HeGameDefault:setFpsValue( fps )
	-- if(speedScale == 1)then
	-- 	CCDirector:sharedDirector():setRefreshInterval(0)
	-- else
	-- 	CCDirector:sharedDirector():setRefreshInterval(2)
	-- end

	if pauseSoundEffects then
		self.musicOpenWhenCrashResumePlay = GamePlayMusicPlayer:getInstance().IsMusicOpen
		
		if self.musicOpenWhenCrashResumePlay then
	        GamePlayMusicPlayer:getInstance():pauseSoundEffects()
	    end
	end
	
end

function GameSpeedManager:resuleDefaultSpeed()
	HeGameDefault:setFpsValue(60)
	self:stopFPSWatcher()

	if GamePlayContext:getInstance().inLevel then
		self:startFPSWatcher( 60 )
	end
	
	if self.musicOpenWhenCrashResumePlay then
		GamePlayMusicPlayer:getInstance():resumeSoundEffects()
	end

	self.musicOpenWhenCrashResumePlay = nil
end

function GameSpeedManager:changeDoubleSpeed()
	self:changeSpeed( 2  , false )
end

function GameSpeedManager:changeSpeedForFastPlay()
	local isTimeLevel = false
	if GamePlayContext:getInstance().theGamePlayType and GamePlayContext:getInstance().theGamePlayType == GameModeTypeId.CLASSIC_ID then
		isTimeLevel = true
	end
	if not isTimeLevel then
		local speedScale = self:getSpeedScaleBySwitch()
		local targetFPS = 60 * speedScale

		self:stopFPSWatcher()
		self:startFPSWatcher( targetFPS )

		self:changeSpeed( self:getSpeedScaleBySwitch()  , false )
	else
		self:resuleDefaultSpeed()
	end
end

function GameSpeedManager:changeSpeedForCrashResumePlay()
	self:changeSpeed( 50  , true )
end


function GameSpeedManager:getGameSpeedSwitch()
	if not self.currGameSpeedSwitch then
		self.currGameSpeedSwitch = LocalBox:getData( self.speedSwitchKey )
	end
	if type(self.currGameSpeedSwitch) ~= "number" then self.currGameSpeedSwitch = 0 end
	return self.currGameSpeedSwitch or 0
end

function GameSpeedManager:setGameSpeedSwitch( value , isFPSWarning )
	self.currGameSpeedSwitch = value
	LocalBox:setData( self.speedSwitchKey , value )
	DcUtil:switchGameSpeed( value , isFPSWarning )
	self.fpsWarningTipFlag = false
	LocalBox:setData( self.fpsWarningTipFlagKey , self.fpsWarningTipFlag , self.filekey )
end

function GameSpeedManager:getSpeedScaleBySwitch()
	if not self.currGameSpeedSwitch then
		self.currGameSpeedSwitch = self:getGameSpeedSwitch()
	end
	if type(self.currGameSpeedSwitch) ~= "number" then self.currGameSpeedSwitch = 0 end

	if self.currGameSpeedSwitch == 0 then
		return 1
	elseif self.currGameSpeedSwitch == 1 then
		return 1.25
	elseif self.currGameSpeedSwitch == 2 then
		return 1.5
	else
		return 1
	end
end

function GameSpeedManager:getFPSWarningTipFlag()
	if self.fpsWarningTipFlag == nil then
		self.fpsWarningTipFlag = LocalBox:getData( self.fpsWarningTipFlagKey , self.filekey )
	end
	
	return self.fpsWarningTipFlag or false
end

function GameSpeedManager:onFPSWarning()
	
	if self:getGameSpeedSwitch() == 0 then
		--本来就没有加速，所以也不需要降速
		return
	end

	if self.fpsWarningTipFlag then
		return
	end

	self:setGameSpeedSwitch( 0 , true )
	self.fpsWarningTipFlag = true --顺序敏感！！ fpsWarningTipFlag的赋值必须在setGameSpeedSwitch之后
	LocalBox:setData( self.fpsWarningTipFlagKey , self.fpsWarningTipFlag , self.filekey )
	self:resuleDefaultSpeed()

	local txt = Localization:getInstance():getText("game.speed.manager.fpsWarning.tips.in.level")
	CommonTip:showTip( txt , "negative" , nil , 3 )
end

function GameSpeedManager:stopFPSWatcher()
	if self.timerId then
		TimerUtil.removeAlarm( self.timerId )
	end
end

function GameSpeedManager:startFPSWatcher( theoreticalFPS  )

	-- self.fpsWarningTipFlag = false
	-- LocalBox:setData( self.fpsWarningTipFlagKey , self.fpsWarningTipFlag , self.filekey )

	self.theoreticalFPS = theoreticalFPS
	self.prevCheckTime = HeTimeUtil:getCurrentTimeMillis()
	self.prevCheckFrame = TimerUtil.frameId

	self.warningData = {}
	self.warningData.continuousFailedCount = 0
	self.warningData.totalFailedCount = 0

	if self.timerId then
		TimerUtil.removeAlarm( self.timerId )
	end

	local function check()
		self:onFPSWatcherCheck()
	end
	self.timerId = TimerUtil.addAlarm( check , detectionCycle , 0 )
end


function GameSpeedManager:onFPSWatcherCheck()
	local nowTime = HeTimeUtil:getCurrentTimeMillis()
	local nowFrame = TimerUtil.frameId

	local fps = ( nowFrame - self.prevCheckFrame ) / ( nowTime - self.prevCheckTime ) * 1000
	
	-- RemoteDebug:uploadLogWithTag( "FPS" , "fps:" .. tostring(fps) .. "  theoreticalFPS:" .. tostring(self.theoreticalFPS) .. "  rate:" .. tostring(fps / self.theoreticalFPS) )
	local checkResult = false
	if fps <= self.theoreticalFPS * failureThreshold then
		self.warningData.continuousFailedCount = self.warningData.continuousFailedCount + 1
		self.warningData.totalFailedCount = self.warningData.totalFailedCount + 1
		checkResult = false
	else
		self.warningData.continuousFailedCount = 0
		checkResult = true
	end

	local diffRate = ( self.theoreticalFPS - fps ) / self.theoreticalFPS
	if diffRate < 0 then diffRate = 0 end

	local checkData = { id = #levelData.logList + 1 , fps = fps , fpsT = self.theoreticalFPS , diffRate = diffRate , result = checkResult }
	table.insert( levelData.logList , checkData )

	if self.warningData.continuousFailedCount >= maxCCount or self.warningData.totalFailedCount >= maxTCount then
		-- TimerUtil.removeAlarm( self.timerId )
		self:onFPSWarning()
	end

	self.prevCheckTime = nowTime
	self.prevCheckFrame = nowFrame
end