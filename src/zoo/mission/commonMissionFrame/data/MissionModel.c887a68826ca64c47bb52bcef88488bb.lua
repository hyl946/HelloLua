require "zoo.mission.commonMissionFrame.data.MissionData"

MissionModel = class()

local model = nil 

function MissionModel:getInstance( ... )
	if model == nil then
		model = MissionModel.new()

		model:init()

		local platform = UserManager.getInstance().platform
		local uid = UserManager.getInstance().uid
		if not uid then uid = "12345" end
		
		model.missionDailyKey = "missionDailyDataKey_" .. tostring(platform) .. "_u_".. tostring(uid) .. ".ds"
		model.missionDailyData = Localhost:readFromStorage(model.missionDailyKey)
		if not model.missionDailyData then
			model.missionDailyData = {}
		end

		model.missionProgressDataKey = "missionProgressDataKey_" .. tostring(platform) .. "_u_".. tostring(uid) .. ".ds"
		model.missionProgressData = Localhost:readFromStorage(model.missionProgressDataKey)
		if not model.missionProgressData then
			model.missionProgressData = {}
		end
	end
	return model
end

function MissionModel:init() 
	self.missionList = {}
	self.lastPlayGameCache = {}
	self.missionDailyData = {}
	self.missionProgressData = {}
end

function MissionModel:addMission(id , sourceData)
	for k,v in pairs( self.missionList or {}) do
		if v.id == id then
			return MissionModelReturnCode.kSameMissionExist
		end
	end

	local mission = MissionData:create(sourceData) 

	if mission then
		table.insert( self.missionList , mission )
		return MissionModelReturnCode.kSuccess
	else
		return MissionModelReturnCode.kSourceDataIsUnlegal
	end
end

function MissionModel:removeMission(id)
	
	for k,v in pairs( self.missionList or {}) do
		if v:getId() == id then
			table.remove( self.missionList , k )
			--if _G.isLocalDevelopMode then printx(0,  table.tostring(self.missionList) ) end
			return MissionModelReturnCode.kSuccess
		end
	end
	return MissionModelReturnCode.kCannotFindMissionByID
end

function MissionModel:getMission(id)
	for k,v in pairs( self.missionList or {}) do
		if v:getId() == id then
			return v
		end
	end
	return nil
end

function MissionModel:getUnacceptableMissions()
	local list = {}
	for k,v in pairs( self.missionList or {}) do
		if v.missionState == MissionDataState.UNACCEPTED then 
			table.insert( list , v )
		end
	end

	return list
end

function MissionModel:getRunningMissions()
	local list = {}
	for k,v in pairs( self.missionList or {}) do
		if v.missionState == MissionDataState.STARTED 
			or v.missionState == MissionDataState.IN_PROGRESS then 
			table.insert( list , v )
		end
	end

	return list
end

function MissionModel:getCompletedMissions()
	local list = {}
	for k,v in pairs( self.missionList or {}) do
		if v.missionState == MissionDataState.COMPLETED then 
			table.insert( list , v )
		end
	end

	return list
end

function MissionModel:getRewardedMissions()
	local list = {}
	for k,v in pairs( self.missionList or {}) do
		if v.missionState == MissionDataState.REWARDED then 
			table.insert( list , v )
		end
	end

	return list
end

function MissionModel:getMissionsByContainConditions(conditionIds)

	local list = {}
	for k,v in pairs( self.missionList or {}) do

		local missionData = v
		local allConditions = {}
		local acceptConditions = missionData:getAcceptConditions()
		local completeConditions = missionData:getCompleteConditions()
		
		local k1,v1
		local k2,v2
		
		for k1,v1 in pairs( acceptConditions or {}) do
			table.insert( allConditions , v1 )
		end

		for k1,v1 in pairs( completeConditions or {}) do
			table.insert( allConditions , v1 )
		end

		if not conditionIds then
			conditionIds = {}
		end

		if type(conditionIds) ~= "table" then
			conditionIds = tonumber(conditionIds)
		end

		local needBreak = false
		for k1,v1 in pairs( allConditions or {}) do
			
			for k2,v2 in pairs( conditionsId or {}) do

				if v1:getId() == v2 then
					table.insert( list , missionData )
					needBreak = true
					break
				end

			end

			if needBreak then
				break
			end
		end
	end

	return list
end


function MissionModel:updateDataOnGameFinish(result , gameBoardLogic)
	self.lastPlayGameCache.result = result
	self.lastPlayGameCache.leftMoveToWin = gameBoardLogic.leftMoveToWin

	if gameBoardLogic.digJewelCount then
		self.lastPlayGameCache.digJewelCount = gameBoardLogic.digJewelCount:getValue()
	else
		self.lastPlayGameCache.digJewelCount = 0
	end
	
end

function MissionModel:getLastPlayGameCache()
	return self.lastPlayGameCache
end

function MissionModel:updateDataOnLogin(isOnline , isOAuth , loginInfo)

	local today = tostring( os.date("%x", Localhost:timeInSec()) )
	local yestoday = tostring( os.date("%x", Localhost:timeInSec() - tonumber(3600*24) ) )


	if self.missionDailyData[today] then

		if not self.missionDailyData[today].todayLoginCount then
			self.missionDailyData[today].todayLoginCount = 0
		end

		if not self.missionDailyData[today].todayOnLineLoginCount then
			self.missionDailyData[today].todayOnLineLoginCount = 0
		end

		self.missionDailyData[today].todayLoginCount = self.missionDailyData[today].todayLoginCount + 1

		if isOnline then
			self.missionDailyData[today].todayOnLineLoginCount = self.missionDailyData[today].todayOnLineLoginCount + 1
			self.missionDailyData[today].todayIsOnlineLogin = true
		end

		if self.missionDailyData[today].yestodayIsOnlineLogin then
			if isOnline and not self.missionDailyData[today].todayIsContinuousLogin then
				self.missionDailyData[today].continuousLoginDays = self.missionDailyData[yestoday].continuousLoginDays + 1
				self.missionDailyData[today].todayIsContinuousLogin = true
			end
		else
			if isOnline and not self.missionDailyData[today].todayIsContinuousLogin then
				self.missionDailyData[today].continuousLoginDays = 1
				self.missionDailyData[today].todayIsContinuousLogin = true
			end
		end
	else
		self.missionDailyData[today] = { 
				today = today , 
				todayLoginCount = 1 ,
				todayOnLineLoginCount = 0,
				todayIsOnlineLogin = false,
				todayIsContinuousLogin = false ,
				yestodayIsOnlineLogin = false,
				continuousLoginDays = 0 ,
				todayChecked = false,
			}

		if self.missionDailyData[yestoday] and self.missionDailyData[yestoday].todayIsOnlineLogin then
			self.missionDailyData[today].yestodayIsOnlineLogin = true
		end

		if isOnline then
			self.missionDailyData[today].todayOnLineLoginCount = 1
			self.missionDailyData[today].todayIsOnlineLogin = true
		end

		if self.missionDailyData[today].yestodayIsOnlineLogin then
			if isOnline then
				self.missionDailyData[today].continuousLoginDays = self.missionDailyData[yestoday].continuousLoginDays + 1
				self.missionDailyData[today].todayIsContinuousLogin = true
			else
				self.missionDailyData[today].continuousLoginDays = self.missionDailyData[yestoday].continuousLoginDays
			end
		else
			if isOnline then
				self.missionDailyData[today].continuousLoginDays = 1
				self.missionDailyData[today].todayIsContinuousLogin = true
			end
		end
	end

	Localhost:writeToStorage( self.missionDailyData , self.missionDailyKey )
end

function MissionModel:getMissionDailyData(timestamp)
	if not timestamp then
		timestamp = Localhost:timeInSec()
	end

	local date = tostring( os.date("%x", timestamp) )
	return self.missionDailyData[date]
end

function MissionModel:flushMissionDailyData()
	Localhost:writeToStorage( self.missionDailyData , self.missionDailyKey )
end

function MissionModel:setMissionProgressData(missionId , data)

	self.missionProgressData[missionId] = data
	Localhost:writeToStorage( self.missionProgressData , self.missionProgressDataKey )
	
end

function MissionModel:getMissionProgressData(missionId)
	return self.missionProgressData[missionId]
end

