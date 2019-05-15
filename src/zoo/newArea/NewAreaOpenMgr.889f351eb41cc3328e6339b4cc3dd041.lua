
NewAreaOpenMgr = class()

local instance = nil

local OnlineCheckState = {
	kNeed = 1,
	kNot = 2,
}

function NewAreaOpenMgr.getInstance()
	if not instance then
        instance = NewAreaOpenMgr.new()
        instance:init()
    end
    return instance
end

local function parseTime(str, default)
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local year, month, day, hour, min, sec = string.match(str, pattern)
    if year and month and day and hour and min and sec then
        return {
            year=tonumber(year),
            month=tonumber(month),
            day=tonumber(day),
            hour=tonumber(hour),
            min=tonumber(min),
            sec=tonumber(sec),
        }
    else
        return default
    end
end

function NewAreaOpenMgr:init()
	self.countdownAreaId = {}
	--主线
	self.unlockData = {}
	--隐藏关
	self.hideUnlockData = {}
	--四星调整
	self.fourStarUnlockData = {}

	--包含 level_area.id(40000+)  four_star_adjust.id(50000+)  hide_area.id
	self.onlineUnlockInfo = UserManager:getInstance().onlineStartAreaIds

	--读取本地解锁时间配置
	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	local mainUnlockConfig, topAreaId = MetaManager.getInstance():getAreaUnlockTimeInfo(topLevelId)
	local hideUnlockConfig = MetaManager.getInstance():getHideUnlockTimeInfo()
	local fourStarUnlockConfig = MetaManager.getInstance():getFourStarUnlockTimeInfo()

	--用9999关的配置校验
	local maxAreaId = nil
	for i,v in ipairs(mainUnlockConfig) do
		if v.maxLevel == 9999 then 
			maxAreaId = v.id
			break
		end
	end
	local serverDataEffective = false
	if table.includes(self.onlineUnlockInfo, maxAreaId) then 
		--产品保证 隐藏关和四星关的倒计时解锁 与主线关同步 所以以主线关为准校验
		serverDataEffective = true
	end

	local function getCheckState(id)
		local checkState
		if serverDataEffective then 
			if table.includes(self.onlineUnlockInfo, id) then 
				checkState = OnlineCheckState.kNeed
			else
				checkState = OnlineCheckState.kNot
			end
		else
			checkState = OnlineCheckState.kNeed
		end
		return checkState
	end

	--本地有有效的主线关倒计时解锁数据 --主线
	if #mainUnlockConfig > 0 then 
		table.sort(mainUnlockConfig, function(a,b)
        	return a.id < b.id
		end)
		for i,v in ipairs(mainUnlockConfig) do
			if v.maxLevel ~= 9999 then 
				local data = {}
				data.id = v.id
				data.minLevel = v.minLevel
				data.maxLevel = v.maxLevel
				data.unlockTime = os.time2(parseTime(v.startTime))
				data.checkState = getCheckState(v.id)
				data.minVer = v.minVer
				table.insert(self.unlockData, data)
				if v.id > topAreaId then 
					--标记的top区域以上的 只处理一个  
					data.isNext = true
					break
				end
			end
		end
	end

	--隐藏关
	if #hideUnlockConfig > 0 then 	
		for i,v in ipairs(hideUnlockConfig) do
			local data = {}
			data.id = v.id
			data.startTime = v.startTime
			data.continueLevels = v.continueLevels
			data.hideLevelRange = v.hideLevelRange
			data.unlockTime = os.time2(parseTime(v.startTime))
			data.checkState = getCheckState(v.id)
			table.insert(self.hideUnlockData, data)
		end
	end

	--四星关调整
	if #fourStarUnlockConfig > 0 then 
		for i,v in ipairs(fourStarUnlockConfig) do
			if v.top then 
				local data = {}
				data.id = v.id
				data.levels = v.levels
				data.unlockTime = os.time2(parseTime(v.startTime))
				data.checkState = getCheckState(v.id)
				table.insert(self.fourStarUnlockData, data)

				self:fourStarUpdate(v.levels)
			end
		end
	end
end

function NewAreaOpenMgr:updateLocalData(id)
	self.onlineUnlockInfo = table.removeValue(self.onlineUnlockInfo, id)
end

function NewAreaOpenMgr:flushLocalData()
	UserManager.getInstance().onlineStartAreaIds = self.onlineUnlockInfo
    UserService.getInstance().onlineStartAreaIds = self.onlineUnlockInfo
    if NetworkConfig.writeLocalDataStorage then 
    	Localhost:getInstance():flushCurrentUserData()
    else 
    	if _G.isLocalDevelopMode then 
    		printx(0, "Did not write user data to the device.") 
    	end 
    end
end

function NewAreaOpenMgr:getCountdownStr(endTime)
	local now = Localhost:timeInSec()
	local deltaInSec = endTime - now

	local d = math.floor(deltaInSec / (3600 * 24))
	local h = math.floor(deltaInSec % (3600 * 24) / 3600)
	local m = math.floor(deltaInSec % (3600 * 24) % 3600 / 60)
	local s = math.floor(deltaInSec % (3600 * 24) % 3600 % 60)

	local isOver = deltaInSec <= 0
	local timeStr 
	if d > 0 then 
		timeStr = localize(string.format("%d天%d小时", d, h))
	else
		timeStr = localize(string.format("%02d:%02d:%02d", h, m, s))
	end
	return timeStr, isOver
end

function NewAreaOpenMgr:getTimeDesc(endTime)
	local m = tonumber(os.date("%m", endTime))
	local d = tonumber(os.date("%d", endTime))
	local h = tonumber(os.date("%I", endTime))
	local amORpm = os.date("%p", endTime)
	local timeDes = ""
	if amORpm == "am" or amORpm == "AM" then 
		if h == 12 or (h > 0 and h < 5) then 
			timeDes = "凌晨"
		elseif h >= 5 and h < 9 then
			timeDes = "早"
		elseif h >= 9 and h < 12 then
			timeDes = "上午"
		end
	elseif amORpm == "pm" or amORpm == "PM" then
		if h == 12 then 
			timeDes = "中午"
		elseif h > 0 and h < 7 then 
			timeDes = "下午"
		elseif h >=7 and h < 12 then 
			timeDes = "晚"
		end
	end
	return string.format("%d月%d日%s%d点", m, d, timeDes, h)
end

--------------------------------------------主线--------------------------------------------
function NewAreaOpenMgr:getShowTopLevel(isCountdownOver)
	local countdownAreaId = self:getCurCountdownArea()
	if not isCountdownOver and countdownAreaId then 
		return MetaManager.getInstance():getLevelAreaById(countdownAreaId - 1).maxLevel, 550
	else
		return MetaManager.getInstance():getMaxNormalLevelByLevelArea(), 650
	end
end

--考虑到主线关倒计时解锁情况 获得当前可打最高关
function NewAreaOpenMgr:getCanPlayTopLevel()
	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	local curCountdownArea 
	for i,v in ipairs(self.unlockData) do
		if not v.isNext and topLevelId < v.minLevel and
			v.checkState == OnlineCheckState.kNeed then
			curCountdownArea = v 
			break
		end 
	end
	if curCountdownArea then
		return MetaManager.getInstance():getLevelAreaById(curCountdownArea.id - 1).maxLevel
	else
		return MetaManager.getInstance():getMaxNormalLevelByLevelArea()
	end
end

--当前可打的应倒计时区域 是否倒计时结束
function NewAreaOpenMgr:isCurCountdownAreaOver()
	local countdownAreaId = self:getCurCountdownArea()
	if countdownAreaId then
		local endTime = self:getCountdownEndTime(countdownAreaId)
		local _, isOver = self:getCountdownStr(endTime)
		return isOver, countdownAreaId
	end
	return true, nil
end

function NewAreaOpenMgr:getLocalTopLevel()
	local isOver, countdownAreaId = self:isCurCountdownAreaOver()
	if isOver then
		return MetaManager.getInstance():getMaxNormalLevelByLevelArea()
	else
		return MetaManager.getInstance():getLevelAreaById(countdownAreaId - 1).maxLevel
	end
end

function NewAreaOpenMgr:getCurCountdownArea()
	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	for i,v in ipairs(self.unlockData) do
		if not v.isNext and topLevelId < v.minLevel then 
			return v.id
		end
	end
end

function NewAreaOpenMgr:getNextCountdownArea()
	local now = Localhost:timeInSec()
	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	local topLevelPassed = UserManager.getInstance():hasPassed(topLevelId)
	for i,v in ipairs(self.unlockData) do
		if topLevelPassed and v.isNext == true then
			return v.id
		end
	end
end

function NewAreaOpenMgr:checkNextCountdownAreaVersionAvailable()
	local ver = tonumber(string.split( tostring(_G.bundleVersion) , ".")[2])
	for i,v in ipairs(self.unlockData) do
		if v.isNext == true then 
			if v.minVer and v.minVer > ver then
				return false
			end
		end
	end
	return true
end

function NewAreaOpenMgr:getCountdownEndTime(areaId)
	for i,v in ipairs(self.unlockData) do
		if v.id == areaId then 
			return v.unlockTime
		end
	end
end

function NewAreaOpenMgr:insertCountdownAreaId(areaId)
	table.insert(self.countdownAreaId, areaId)
end

function NewAreaOpenMgr:isCountdownArea(areaId)
	return table.includes(self.countdownAreaId, areaId)
end

function NewAreaOpenMgr:isMaxLevelCountdown(maxLevel)
	for i,v in ipairs(self.unlockData) do
		if v.maxLevel == maxLevel and v.checkState == OnlineCheckState.kNeed then
			return true
		end
	end
	return false
end

function NewAreaOpenMgr:setMainAreaCheckOver(areaId)
	self:updateLocalData(areaId)

	--四星关也一起解了
	for i,v in ipairs(self.fourStarUnlockData) do
		self:updateLocalData(v.id)

		v.checkState = OnlineCheckState.kNot
		self:fourStarUpdate(v.levels)
	end
	--隐藏关也一起解了
	for i,v in ipairs(self.hideUnlockData) do
		self:updateLocalData(v.id)
		v.checkState = OnlineCheckState.kNot
		self:hideAreaUpdate(v.id)
	end

	self:flushLocalData()
end

function NewAreaOpenMgr:onlineUnlockCheck(areaId, successCallback)
	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	local topLevelPassed = UserManager.getInstance():hasPassed(topLevelId)
	if topLevelPassed then 
		local onlineCheck = false
		for i,v in ipairs(self.unlockData) do
			if v.id == areaId and v.checkState == OnlineCheckState.kNeed then 
				onlineCheck = true
				break
			end
		end

		local function onSuccess()
			self:setMainAreaCheckOver(areaId)
			if successCallback then successCallback() end
	    end
	    local function onFail(evt)
	        if evt and evt.data then
	        	if evt.data == -6 or evt.data == -2 then 
	        		CommonTip:showTip(localize('当前区域解锁需联网~请联网后再试吧~'), 'negative')
	        	else
	            	CommonTip:showTip(localize('error.tip.'..tostring(evt.data)), 'negative')
	            end
	        else
	        	CommonTip:showTip(localize('当前区域解锁需联网~请联网后再试吧~'), 'negative')
	        end
	    end

	    if onlineCheck then
		    RequireNetworkAlert:callFuncWithLogged(function ()
			    local http = OpNotifyHttp.new(true)
			    http:ad(Events.kComplete, onSuccess)
			    http:ad(Events.kError, onFail)
			    http:syncLoad(OpNotifyType.kOnlineUnlockArea, areaId)	
		    end)
		else
			if successCallback then successCallback() end
		end
    else
    	if successCallback then successCallback() end
    end
end

--------------------------------------------隐藏关--------------------------------------------
function NewAreaOpenMgr:getHideAreaEndTime(areaId)
	for i,v in ipairs(self.hideUnlockData) do
		if v.id == areaId then 
			return v.unlockTime
		end
	end
end

function NewAreaOpenMgr:isOnlineCheckHideArea(areaId)
	for i,v in ipairs(self.hideUnlockData) do
		if v.id == areaId and v.checkState == OnlineCheckState.kNeed then
			return true
		end
	end
	return false
end

function NewAreaOpenMgr:isOnlineCheckHideAreaLevel(levelId)
	local areaId = MetaModel:sharedInstance():getHiddenBranchIdByHiddenLevelId(levelId)
	if areaId then 
		return self:isOnlineCheckHideArea(areaId), areaId
	else
		return false 
	end
end

function NewAreaOpenMgr:isHideAreaCountdownIng(areaId)
	if self:isOnlineCheckHideArea(areaId) then
		local now = Localhost:timeInSec()
		local endTime = self:getHideAreaEndTime(areaId)
		if now < endTime then
			return true 
		end
	end
	return false
end

function NewAreaOpenMgr:hideAreaUpdate(areaId)
end

function NewAreaOpenMgr:setHideAreaCheckOver(areaId)
	self:updateLocalData(areaId)
	for i,v in ipairs(self.hideUnlockData) do
		if v.id == areaId then 
			v.checkState = OnlineCheckState.kNot
			self:hideAreaUpdate(areaId)
		end
	end

	--四星关也一起解了
	for i,v in ipairs(self.fourStarUnlockData) do
		self:updateLocalData(v.id)
		v.checkState = OnlineCheckState.kNot
		self:fourStarUpdate(v.levels)
	end

	self:flushLocalData()
end

function NewAreaOpenMgr:hideAreaUnlockCheck(areaId, successCallback, failCallback) 
	local function onSuccess()
		self:setHideAreaCheckOver(areaId)
		if successCallback then successCallback() end
    end
    local function onFail(evt)
        if evt and evt.data then
        	if evt.data == -6 or evt.data == -2 then 
        		CommonTip:showTip(localize('当前隐藏关解锁需联网~请联网后再试吧~'), 'negative')
        	else
            	CommonTip:showTip(localize('error.tip.'..tostring(evt.data)), 'negative')
            end
        else
        	CommonTip:showTip(localize('当前隐藏关解锁需联网~请联网后再试吧~'), 'negative')
        end
        if failCallback then failCallback() end
    end
    RequireNetworkAlert:callFuncWithLogged(function ()
	    local http = OpNotifyHttp.new(true)
	    http:ad(Events.kComplete, onSuccess)
	    http:ad(Events.kError, onFail)
	    http:syncLoad(OpNotifyType.kOnlineUnlockHide, areaId)	
    end)
end

--------------------------------------------四星调整--------------------------------------------
function NewAreaOpenMgr:getFourStarEndTime(groupId)
	for i,v in ipairs(self.fourStarUnlockData) do
		if v.id == groupId then 
			return v.unlockTime
		end
	end
end

function NewAreaOpenMgr:isOnlineCheckFourStar(levelId)
	for i,v in ipairs(self.fourStarUnlockData) do
		if table.includes(v.levels, levelId) and v.checkState == OnlineCheckState.kNeed then 
			return true, v.id
		end
	end
	return false
end

function NewAreaOpenMgr:fourStarUpdate(levels)
	local starButtonUpdate = false
	for i,v in ipairs(levels) do
		local meta = LevelMapManager.getInstance():getMeta(v)
		if meta then 
			starButtonUpdate = true
			meta:updateScoreTargets()

			local levelConfig = LevelDataManager.sharedLevelData():getLevelConfigByID(v)
			if levelConfig then
				levelConfig:updateScoreTargets(meta)
			end
		end
	end
	if starButtonUpdate then 
		local homeScene = HomeScene:sharedInstance()
		if homeScene and homeScene.starButton and (not homeScene.starButton.isDisposed) then
			homeScene.starButton:updateView()
		end
	end
end

function NewAreaOpenMgr:setFourStarCheckOver(groupId)
	self:updateLocalData(groupId)
	for i,v in ipairs(self.fourStarUnlockData) do
		if v.id == groupId then 
			v.checkState = OnlineCheckState.kNot

			self:fourStarUpdate(v.levels)
		end
	end

	--隐藏关也一起解了
	for i,v in ipairs(self.hideUnlockData) do
		self:updateLocalData(v.id)
		v.checkState = OnlineCheckState.kNot
		self:hideAreaUpdate(v.id)
	end

	self:flushLocalData()
end

function NewAreaOpenMgr:fourStarUnlockCheck(groupId, successCallback, failCallback) 
	local now = Localhost:timeInSec()
	local endTime = self:getFourStarEndTime(groupId)
	if now >= endTime then 
		local function onSuccess()
			self:setFourStarCheckOver(groupId)
			if successCallback then successCallback() end
	    end
	    local function onFail(evt)
	        -- if evt and evt.data then
	        -- 	if evt.data == -6 or evt.data == -2 then 
	        -- 		CommonTip:showTip(localize('当前关卡四星限制解锁需联网~请联网后再试吧~'), 'negative')
	        -- 	else
	        --     	CommonTip:showTip(localize('error.tip.'..tostring(evt.data)), 'negative')
	        --     end
	        -- else
	        -- 	CommonTip:showTip(localize('当前关卡四星限制解锁需联网~请联网后再试吧~'), 'negative')
	        -- end
	        if failCallback then failCallback() end
	    end

	    local http = OpNotifyHttp.new(true)
	    http:ad(Events.kComplete, onSuccess)
	    http:ad(Events.kError, onFail)
	    http:syncLoad(OpNotifyType.kOnlineUnlockFourStar, groupId)	
	else
		if failCallback then failCallback() end
	end
end