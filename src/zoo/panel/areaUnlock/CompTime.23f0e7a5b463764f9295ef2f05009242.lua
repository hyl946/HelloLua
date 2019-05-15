local CompTime = class()

function CompTime:create(parentPanel, ui)
	local comp = CompTime.new()
	comp:init(parentPanel, ui)
	return comp
end

function CompTime:init(parentPanel, ui)
	self.parentPanel = parentPanel
	self.ui = ui

	self.timeUnlockBtn = GroupButtonBase:create(self.ui:getChildByName('timeUnlockBtn'))
	self.timeUnlockBtn:setString(localize('unlock.cloud.panel.use.friend.unlock'))
	self.timeUnlockBtn:setVisible(false)
	self.timeUnlockTxt =  BitmapText:create('', "fnt/unlock.fnt")
	self.timeUnlockTxt:setPositionXY(148, -67)
	self.ui:addChild(self.timeUnlockTxt)
	self.timeUnlockTxtTag =  BitmapText:create('', "fnt/unlock.fnt")
	self.timeUnlockTxtTag:setPositionXY(258, -69)
    self.timeUnlockTxtTag:setText(localize("time.unlock.area.countdown.tag.desc"))
    self.timeUnlockTxtTag:setVisible(false)
	self.ui:addChild(self.timeUnlockTxtTag)
	self:updateTimeUnlock()
end

function CompTime:getTimeCycleHour()
	local timeCycleHour
    local maintenance = MaintenanceManager:getInstance():getMaintenanceByKey("offlineTimeUnlockArea")
    if maintenance ~= nil then
    	local cfgHour = tonumber(maintenance.extra) or 12
    	timeCycleHour = cfgHour
    end
    timeCycleHour = timeCycleHour or 12
    return timeCycleHour
end

function CompTime:updateTimeUnlock()
    local maintenance = MaintenanceManager:getInstance():getMaintenanceByKey("offlineTimeUnlockArea")
    local timeCycleHour = self:getTimeCycleHour()
    local areaUnlockTime = 0
    if self.parentPanel.lockedCloudId == UserManager:getInstance().countdownAreaId then
		areaUnlockTime = math.floor(UserManager:getInstance().countdownUnlockTime / 1000)
	elseif UserManager:getInstance().countdownAreaId >= 0 then--说明这个时候的数据是后端的,并且当前云处于不可以解锁状态（关卡回退啥的），这个时候需要清空当前云的本地解锁数据
		Localhost:writeDataByFileNameAndKey(self.parentPanel.LOCAL_DATA_FILE, "area_" .. self.parentPanel.lockedCloudId .. "_unlock_time", nil)
    end
	if areaUnlockTime > 0 then
		Localhost:writeDataByFileNameAndKey(self.parentPanel.LOCAL_DATA_FILE, "area_" .. self.parentPanel.lockedCloudId .. "_unlock_time", areaUnlockTime)
	else
		areaUnlockTime = Localhost:readDataByFileNameAndKey(self.parentPanel.LOCAL_DATA_FILE, "area_" .. self.parentPanel.lockedCloudId .. "_unlock_time", 0)
	end
	local inUnlockCycle = areaUnlockTime ~= 0
	local canOffline = maintenance and maintenance.enable
	if inUnlockCycle or canOffline then--可以离线触发开始解锁
		if areaUnlockTime == 0 then--此时发送一个离线请求
			areaUnlockTime = Localhost:timeInSec() + timeCycleHour * 3600
			Localhost:writeDataByFileNameAndKey(self.parentPanel.LOCAL_DATA_FILE, "area_" .. self.parentPanel.lockedCloudId .. "_unlock_time", areaUnlockTime)
			self:sendOfflineStartCountDown(timeCycleHour)
			Localhost:writeDataByFileNameAndKey(self.parentPanel.LOCAL_DATA_FILE, "area_" .. self.parentPanel.lockedCloudId .. "_time_cycle", timeCycleHour)
		end
		-- RemoteDebug:log("aaa----------------------------------------2   unlockTime:" .. areaUnlockTime .. "  curTime:" .. Localhost:timeInSec())
		if areaUnlockTime <= Localhost:timeInSec() then --UI变换到立即解锁
			self:toTimeUnlockState()
		else--添加倒计时逻辑
			self:timeCountDown(areaUnlockTime)
		end
	else--不可以离线触发开始解锁
		self:sendOnlineStartCountDown(timeCycleHour)
	end
end

function CompTime:sendOfflineStartCountDown(timeCycleHour)
	local http = OpNotifyOffline.new()
	http:load(OpNotifyOfflineType.kUnlockAreaByTime, self.parentPanel.lockedCloudId .. "," .. timeCycleHour)
	UserManager:getInstance().countdownAreaId = self.parentPanel.lockedCloudId
	UserManager:getInstance().countdownUnlockTime = Localhost:time() + timeCycleHour * 3600 * 1000
end

function CompTime:sendOnlineStartCountDown(timeCycleHour)
	if self.ui == nil or self.ui.isDisposed then return end

	local areaUnlockTime
	local http = OpNotifyHttp.new()
	self.ui:getChildByName("bar"):getChildByName("bar2"):setVisible(false)
	self.ui:getChildByName("bar"):getChildByName("bar3"):setVisible(false)
	local function onSuccess(evt)
		if self.ui == nil or self.ui.isDisposed then return end
		self.ui:getChildByName("netDesc"):setString("")
		if evt.data ~= nil and evt.data.extra ~= nil then
			local uTimeMS = tonumber(evt.data.extra)
			if uTimeMS ~= nil then
				UserManager:getInstance().countdownUnlockTime = uTimeMS
				UserManager:getInstance().countdownAreaId = self.parentPanel.lockedCloudId
				areaUnlockTime = math.floor(uTimeMS / 1000)
				Localhost:writeDataByFileNameAndKey(self.parentPanel.LOCAL_DATA_FILE, "area_" .. self.parentPanel.lockedCloudId .. "_unlock_time", areaUnlockTime)
				self:timeCountDown(areaUnlockTime)
			end
			Localhost:writeDataByFileNameAndKey(self.parentPanel.LOCAL_DATA_FILE, "area_" .. self.parentPanel.lockedCloudId .. "_time_cycle", timeCycleHour)
		end
	end
	local function onFail(evt)
		if self.ui == nil or self.ui.isDisposed then return end
		local errcode = evt and evt.data or nil
		if errcode then
			if errcode == -2 or errcode == -6 or errcode == -7 or errcode == 101 then
				self.ui:getChildByName("netDesc"):setString(localize("time.unlock.area.offline.disable.desc"))
				self.ui:getChildByName("bar"):getChildByName("bar2"):setVisible(false)
				self.ui:getChildByName("bar"):getChildByName("bar3"):setVisible(false)
				self.timeUnlockTxt:setText(timeCycleHour .. ":00:00")
    			self.timeUnlockTxtTag:setVisible(true)
			else
				local scene = Director:sharedDirector():run()
				if  scene ~= nil and scene:is(HomeScene) then
					CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(errcode)), "negative")
				end
			end
		else
			self.ui:getChildByName("netDesc"):setString(localize("time.unlock.area.offline.disable.desc"))
			self.ui:getChildByName("bar"):getChildByName("bar2"):setVisible(false)
			self.ui:getChildByName("bar"):getChildByName("bar3"):setVisible(false)
			self.timeUnlockTxt:setText(timeCycleHour .. ":00:00")
    		self.timeUnlockTxtTag:setVisible(true)
		end
	end
    http:ad(Events.kComplete, onSuccess)
    http:ad(Events.kError, onFail)
	http:load(OpNotifyType.kUnlockAreaByTime, self.parentPanel.lockedCloudId)
end

function CompTime:toTimeUnlockState()
	-- RemoteDebug:log(debug.traceback())
	-- RemoteDebug:uploadLog()
	if self.ui == nil or self.ui.isDisposed then return end

	self.timeUnlockTxt:setText("00:00:00")
    self.timeUnlockTxtTag:setVisible(true)
	self.parentPanel:toTimeUnlockState()
	if not self.inTimeUnlockState then
		self.inTimeUnlockState = true
		self.timeUnlockBtn:setVisible(true)
		self.timeUnlockBtn:useBubbleAnimation(0.06)
		self.timeUnlockBtn:ad(DisplayEvents.kTouchTap, function () 
			if not self.timeUnlockBtn.inClk then
				self.timeUnlockBtn.inClk = true
				local function onSendUnlockMsgSuccess(event)
					local function onRemoveSelfFinish()
						self.parentPanel.unlockCloudSucessCallBack()
					end
					self.isUnlockSuccess = true
					self.parentPanel:remove(onRemoveSelfFinish)
				end

				local function onSendUnlockMsgFailed(errorCode)
					self.timeUnlockBtn.inClk = false
					if errorCode ~= nil and type(errorCode) == "number" then
						CommonTip:showTip(Localization:getInstance():getText("error.tip."..errorCode), "negative")
					end
				end

				local function onSendUnlockMsgCanceled(event)
					self.timeUnlockBtn.inClk = false
				end

				local logic = UnlockLevelAreaLogic:create(self.parentPanel.lockedCloudId)
				logic:setOnSuccessCallback(onSendUnlockMsgSuccess)
				logic:setOnFailCallback(onSendUnlockMsgFailed)
				logic:setOnCancelCallback(onSendUnlockMsgCanceled)
				logic:start(UnlockLevelAreaLogicUnlockType.TIME_UNLOCK, {})
			end
		end)
	end
end

function CompTime:timeCountDown(areaUnlockTime)
	if self.ui == nil or self.ui.isDisposed then return end
	
	if self.unlockTimeCountDownID == nil then
		if self.timeBar == nil then
		local SimpleBarCls = require 'zoo.ui.SimpleBar'
			local barUI = self.ui:getChildByName("bar")
			self.ui:getChildByName("bar"):getChildByName("bar2"):setVisible(true)
			self.ui:getChildByName("bar"):getChildByName("bar3"):setVisible(true)
	    	self.timeBar = SimpleBarCls:create(barUI:getChildByName("bar2"), barUI:getChildByName("bar3"), nil, 1)
			self.timeBar:setWidthMargin(75)
		end

		self.leftUnlockTime = areaUnlockTime - Localhost:timeInSec()
		local cycleHour = Localhost:readDataByFileNameAndKey(self.parentPanel.LOCAL_DATA_FILE, "area_" .. self.parentPanel.lockedCloudId .. "_time_cycle", 72)
		local cycleSec = cycleHour * 3600
		self.timeBar:setRate(1 - self.leftUnlockTime / cycleSec)
		local timeStr = convertSecondToHHMMSSFormat(self.leftUnlockTime)
    	self.timeUnlockTxt:setText(timeStr)
    	self.timeUnlockTxtTag:setVisible(true)
    	local function onTick()
    		if self.isDisposed then return end
			if self.leftUnlockTime <= 0 then return end
    	    self.leftUnlockTime = areaUnlockTime - Localhost:timeInSec()
			self.timeBar:setRate(1 - self.leftUnlockTime / cycleSec)
    	    if self.leftUnlockTime >= 0 then
    	        local timeStr = convertSecondToHHMMSSFormat(self.leftUnlockTime)
    	        self.timeUnlockTxt:setText(timeStr)
    	    end

    	    if self.leftUnlockTime <= 0 then 
    	    	self:stopTimer()
				self:toTimeUnlockState()
    	    end
    	end
    	self.unlockTimeCountDownID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTick, 1, false)
	end
end

function CompTime:stopTimer()
	if self.unlockTimeCountDownID ~= nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.unlockTimeCountDownID)
        self.unlockTimeCountDownID = nil
    end
end

return CompTime