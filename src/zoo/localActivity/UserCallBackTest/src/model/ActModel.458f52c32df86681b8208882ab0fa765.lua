local ActModel = class()

--[[
	活动Model的基类
	初始化 init 【需继承重写】
	持有活动主面板mainPanel，记录mainPanel弹出次数
	读写活动对应的本地历史数据
	读写活动对应的每日数据
]]


------------------------------------------------------------------
--actKey  值为活动根目录的名称，区分大小写
--config  活动的Config
--http    活动的请求实现，默认传 ActHttp.lua 文件尾返回的对象
--constants 活动的一些常数，目前(2016-06-22)在关卡活动中有用到
------------------------------------------------------------------
function ActModel:init(actKey, config, http, constants)
	self.actKey = actKey
	self.config = config
	self.http = http
	self.constants = constants
	self:initDatas()
	self:resetDatas()
end

---------------------------------------
--初始化历史数据和每日数据的存储文件名
---------------------------------------
function ActModel:initDatas( ... )
	self.keyLocalDailyData = "activity_" .. self.config.actId .. "localDailyData.ds"
	self.keyLocalData = "activity_" .. self.config.actId .. "localData.ds"
end

function ActModel:resetDatas( ... )
	self.mainPanel = nil
end


------------------------------------------------------
--活动的mainPanel生成后，需要写入到model
------------------------------------------------------
function ActModel:setMainPanel(panel)
	self.mainPanel = panel
	self:addPanelCreateCount(1)
end

function ActModel:addPanelCreateCount(num)
	local addNum = num or 1
	local todayPopNum = self:getLocalDailyDataByKey("popPanelTimeCount", 0)
	local popNum = self:getLocalDataByKey("popPanelTimeCount", 0)
	self:writeLocalDailyDataByKey("popPanelTimeCount", todayPopNum + addNum)
	self:writeLocalDataByKey("popPanelTimeCount", popNum + addNum)
end

--------------------------------------------------------
--mainPanel在今天弹出的次数
--------------------------------------------------------
function ActModel:getTodayPanelPouNum( ... )
	local todayPopNum = self:getLocalDailyDataByKey("popPanelTimeCount", 0)
	return todayPopNum
end

--------------------------------------------------------
--mainPanel在活动期间弹出的次数
--------------------------------------------------------
function ActModel:getPanelPopNum( ... )
	local popNum = self:getLocalDataByKey("popPanelTimeCount", 0)
	return popNum
end

function ActModel:getMainPanel()
	return self.mainPanel
end

-----以下------读写每日数据----------------
function ActModel:getRawDailyData( ... )
	local data = {}
	data.writeTime = Localhost:timeInSec()
	data.popPanelTimeCount = 0
	return data
end

function ActModel:readLocalDailyData(userID)
	local uid = userID or UserManager.getInstance().uid or "nilUid"
	local key = uid .. "_" .. self.keyLocalDailyData
	local dailyData = Localhost:readFromStorage(key)

	if type(dailyData) ~= "table" then
		dailyData = self:getRawDailyData()
		self:writeLocalDailyData(dailyData, uid)
	else
		local writeDay = self.config.getDayStartTimeByTS(dailyData.writeTime)
		local today = self.config.getDayStartTimeByTS(Localhost:timeInSec())
		if writeDay ~= today then
			dailyData = self:getRawDailyData()
			self:writeLocalDailyData(dailyData, uid)
		end
	end

	return dailyData
end

function ActModel:writeLocalDailyData(dailyData, userID)
	local uid = userID or UserManager.getInstance().uid or "nilUid"
	local key = uid .. "_" .. self.keyLocalDailyData
	Localhost:writeToStorage(dailyData, key)
end

function ActModel:getLocalDailyDataByKey(key, defaultValue)
	local dailyData = self:readLocalDailyData()
	if dailyData and dailyData[key] ~= nil then
		return dailyData[key]
	end

	return defaultValue
end

function ActModel:writeLocalDailyDataByKey(key, value)
	local dailyData = self:readLocalDailyData()
	dailyData[key] = value
	self:writeLocalDailyData(dailyData)
end
-----以上------读写每日数据----------------

-----以下------读写活动期间存储数据----------------
function ActModel:readLocalData(userID)
	local uid = userID or UserManager.getInstance().uid or "nilUid"
	local key = uid .. "_" .. self.keyLocalData
	local localData = Localhost:readFromStorage(key)

	if type(localData) ~= "table" then
		localData = {}
	end

	return localData
end

function ActModel:writeLocalData(localData, userID)
	local uid = userID or UserManager.getInstance().uid or "nilUid"
	local key = uid .. "_" .. self.keyLocalData
	Localhost:writeToStorage(localData, key)
end

function ActModel:getLocalDataByKey(key, defaultValue)
	local localData = self:readLocalData()
	if localData and localData[key] ~= nil then
		return localData[key]
	end

	return defaultValue
end

function ActModel:writeLocalDataByKey(key, value)
	local localData = self:readLocalData()
	localData[key] = value
	self:writeLocalData(localData)
end
-----以上------读写活动期间存储数据----------------


return ActModel