InLevelDynamicDiffAdjustManager = class()

local function getCurrUid()
	return UserManager:getInstance():getUID() or "12345"
end

function InLevelDynamicDiffAdjustManager:create()
	local logic = InLevelDynamicDiffAdjustManager.new()
	logic:reset()
	return logic
end

function InLevelDynamicDiffAdjustManager:reset()
	self:clearIsPayUser()
	self:clearIsSatisfyPreconditions()
	self:clearTotalUsePropCount()
	self:clearThisPlayUsePropLog()
	self:clearAddStepPropCount()
	self:clearFailCounts()
	self:clearColorCountMap()
end

function InLevelDynamicDiffAdjustManager:getDataForReplayData()
	local datas = {}

	datas.k1 = self:getIsPayUser()
	datas.k2 = self:getIsSatisfyPreconditions()
	datas.k3 = self:getFailCounts()
	datas.k4 , datas.k5 = self:getTotalUsePropCount()
	datas.k6 = self:getThisPlayUsePropLog()
	datas.k7 = self:getAddStepPropCount()
	datas.k8 = self:getColorCountMap()

	return datas
end

function InLevelDynamicDiffAdjustManager:buildSelfByReplayData( datas )

	--printx(1 , "InLevelDynamicDiffAdjustManager:buildSelfByReplayData !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  datas =" , table.tostring(datas) ) 
	if datas then
		self:setIsPayUser( datas.k1 )
		self:setIsSatisfyPreconditions( datas.k2 )
		self:setFailCounts( datas.k3 )

		if datas.k5 then
			self:setTotalUsePropCount(datas.k5 , true)
		end

		self:setTotalUsePropCount(datas.k4)
		self:setThisPlayUsePropLog(datas.k6)
		self:setAddStepPropCount(datas.k7)
		if datas.k8 then
			self:setColorCountMap(datas.k8)
		end
	end
end


function InLevelDynamicDiffAdjustManager:updateToReplayData()
	local replayData = ReplayDataManager:getCurrLevelReplayData()

	if replayData then
		replayData.daManager = LevelDifficultyAdjustManager:getDAManager():getDataForReplayData()
		ReplayDataManager:flushReplayCache()
	end
	
end


---------------------------------------------------------------
--以下是单关内不会变的，replay不用，section用
function InLevelDynamicDiffAdjustManager:getIsPayUser()
	return self.isPayUser or false
end

function InLevelDynamicDiffAdjustManager:setIsPayUser( value )
	self.isPayUser = value
end

function InLevelDynamicDiffAdjustManager:clearIsPayUser()
	self.isPayUser = false
end

function InLevelDynamicDiffAdjustManager:getIsSatisfyPreconditions()
	return self.isSatisfyPreconditions or false
end

function InLevelDynamicDiffAdjustManager:setIsSatisfyPreconditions( value )
	self.isSatisfyPreconditions = value
end

function InLevelDynamicDiffAdjustManager:clearIsSatisfyPreconditions()
	self.isSatisfyPreconditions = false
end

function InLevelDynamicDiffAdjustManager:getFailCounts()
	return self.failCounts or 0
end

function InLevelDynamicDiffAdjustManager:setFailCounts( count )
	self.failCounts = count
end

function InLevelDynamicDiffAdjustManager:clearFailCounts()
	self.failCounts = 0
end
------------------------------------------------------------------


---------------------------------------------------------------
--以下是单关内会变的，replay用初始值，section用最终值

function InLevelDynamicDiffAdjustManager:getTotalUsePropCount()
	return self.totalUsePropCount or 0 , self.totalUsePropOringinCount
end

function InLevelDynamicDiffAdjustManager:setTotalUsePropCount( count , isOringinValue )
	self.totalUsePropCount = count
	if isOringinValue then
		self.totalUsePropOringinCount = count
	end
end

function InLevelDynamicDiffAdjustManager:clearTotalUsePropCount()
	self.totalUsePropCount = false
	self.totalUsePropOringinCount = nil
end
--------------------------------------------------------------------


---------------------------------------------------------------
--以下是单关内会变的，且没有初始值，只记录最终值。replay不用，section用最终值
function InLevelDynamicDiffAdjustManager:getThisPlayUsePropLog()
	return self.thisPlayUsePropLog or {}
end

function InLevelDynamicDiffAdjustManager:getThisPlayUsePropCount()
	if self.thisPlayUsePropLog then
		return #self.thisPlayUsePropLog
	end
	return 0
end

function InLevelDynamicDiffAdjustManager:setThisPlayUsePropLog( logList )
	self.thisPlayUsePropLog = logList
end

function InLevelDynamicDiffAdjustManager:addThisPlayUsePropLog( propId )
	if not self.thisPlayUsePropLog then self.thisPlayUsePropLog = {} end

	table.insert( self.thisPlayUsePropLog , propId )
end

function InLevelDynamicDiffAdjustManager:clearThisPlayUsePropLog()
	self.thisPlayUsePropLog = {}
end


function InLevelDynamicDiffAdjustManager:getAddStepPropCount()
	return self.addStepPropCount or 0
end

function InLevelDynamicDiffAdjustManager:setAddStepPropCount( count )
	self.addStepPropCount = count
end

function InLevelDynamicDiffAdjustManager:clearAddStepPropCount()
	self.addStepPropCount = 0
end


function InLevelDynamicDiffAdjustManager:getColorCountMap()
	return self.colorCountMap or {}
end

function InLevelDynamicDiffAdjustManager:setColorCountMap( dataMap )

	local datas = {}

	for k,v in pairs(dataMap) do
		datas[tonumber(k)] = v
	end

	self.colorCountMap = datas
end

function InLevelDynamicDiffAdjustManager:clearColorCountMap()
	self.colorCountMap = nil
end
----------------------------------------------------------------------













----------------------------------------------------------------------------------

function InLevelDynamicDiffAdjustManager:checkIsPayUser()

	--if __WIN32 then return true end

	--RemoteDebug:uploadLogWithTag("checkIsPayUser", "!!!!!!!!!!!!!!!!")

	-- if (__ANDROID or __WIN32) then
		--RemoteDebug:uploadLogWithTag("checkIsPayUser", "__ANDROID Localhost:time()" , Localhost:time(), "getLastPayTime()" , UserManager:getInstance():getUserExtendRef():getLastPayTime())
		
	-- end

	local lastPayFromNow = Localhost:time() - UserManager:getInstance():getUserExtendRef():getLastPayTime()
	--RemoteDebug:uploadLogWithTag("checkIsPayUser", "lastPayFromNow" , lastPayFromNow , "60 * 24 * 3600 * 1000" , 60 * 24 * 3600 * 1000 )
	if lastPayFromNow < 60 * 24 * 3600 * 1000 then

		--RemoteDebug:uploadLogWithTag("checkIsPayUser", "return 1")
		return true
	end


	if UserManager:getInstance().userExtend and UserManager:getInstance().userExtend.lastApplePayTime then
		local lastApplePayTime = tonumber(UserManager:getInstance().userExtend.lastApplePayTime) or 0
		local nowtime = Localhost:timeInSec()

		if nowtime - math.floor(lastApplePayTime / 1000) < 3600 * 24 * 60 then

			--RemoteDebug:uploadLogWithTag("checkIsPayUser", "return 2")
			return true
		end
	end

	--RemoteDebug:uploadLogWithTag("checkIsPayUser", "return 3")
	return false
end


function InLevelDynamicDiffAdjustManager:checkAdjustStrategyByPayUserV2(levelId)

	local totalUsePropCont = self:getTotalUsePropCount()

	local function createResultData( ds )
		return { levelId = levelId , mode = ProductItemDiffChangeMode.kAddColor , ds = ds , reason = "DiffAdjustV2A2" }
	end

	DiffAdjustQAToolManager:print( 1 , "InLevelDynamicDiffAdjustManager" , "checkAdjustStrategyByPayUserV2 levelId" , levelId , "totalUsePropCont" , totalUsePropCont,totalUsePropCont > 0 )
	-- RemoteDebug:uploadLogWithTag( "InLevelDynamicDiffAdjustManager" , "checkAdjustStrategyByPayUserV2 levelId" , levelId , "totalUsePropCont" , totalUsePropCont,totalUsePropCont > 0 )
	if totalUsePropCont > 0 then
		local ds = totalUsePropCont
		if ds > 5 then ds = 5 end
		return createResultData( ds )
	end

	return nil
end

function InLevelDynamicDiffAdjustManager:checkAdjustStrategyByPayUser(levelId , lockUserGroup)

	local userTestGroup = 0

	if lockUserGroup then
		userTestGroup = lockUserGroup
	else
		local uid = getCurrUid()
		for i = 1 , 9 do
			if MaintenanceManager:getInstance():isEnabledInGroup( "LevelDifficultyAdjustForPayUser" , "G" .. tostring(i) , uid ) then
				userTestGroup = i
				break
			end
		end
	end

	--RemoteDebug:uploadLog( "checkAdjustStrategyByPayUser" ,  "111  userTestGroup" , userTestGroup )
	
	if userTestGroup > 0 then

		local totalUsePropCont = self:getTotalUsePropCount()
		local addStepCount = self:getAddStepPropCount()
		local thisPlayUsePropCont = self:getThisPlayUsePropCount()
		local failCounts = self:getFailCounts()

		local function createResultData( ds , userTestGroup )
			return { levelId = levelId , mode = ProductItemDiffChangeMode.kAddColor , ds = ds , reason = "PayUserG" .. tostring(userTestGroup) }
		end

		-- RemoteDebug:uploadLog( "checkAdjustStrategyByPayUser" ,  "222  totalUsePropCont" , totalUsePropCont ,
		-- 	"thisPlayUsePropCont" , thisPlayUsePropCont , 
		-- 	"addStepCount" , addStepCount , "failCounts" , failCounts )

		if userTestGroup == 1 then

			if addStepCount > 0 then
				local ds = addStepCount
				if ds > 5 then ds = 5 end
				return createResultData( ds , userTestGroup ) , userTestGroup
			end

		elseif userTestGroup == 2 then

			if totalUsePropCont > 0 then
				local ds = totalUsePropCont
				if ds > 5 then ds = 5 end
				return createResultData( ds , userTestGroup ) , userTestGroup
			end

		elseif userTestGroup == 3 then

			if thisPlayUsePropCont > 0 then
				local ds = thisPlayUsePropCont
				if ds > 5 then ds = 5 end
				return createResultData( ds , userTestGroup ) , userTestGroup
			end

		elseif userTestGroup == 4 then

			if failCounts > 10 and totalUsePropCont >= 5 then
				return createResultData( 1 , userTestGroup ) , userTestGroup
			end

		elseif userTestGroup == 5 then

			if failCounts > 10 and totalUsePropCont >= 5 then
				return createResultData( 2 , userTestGroup ) , userTestGroup
			end

		elseif userTestGroup == 6 then

			if failCounts > 20 then
				return createResultData( 1 , userTestGroup ) , userTestGroup
			end

		elseif userTestGroup == 7 then

			if failCounts > 20 then
				return createResultData( 2 , userTestGroup ) , userTestGroup
			end

		elseif userTestGroup == 8 then

			if failCounts > 30 then
				return createResultData( 3 , userTestGroup ) , userTestGroup
			end

		elseif userTestGroup == 9 then

			if failCounts > 30 then
				return createResultData( 4 , userTestGroup ) , userTestGroup
			end
		end

		return nil , userTestGroup

	else
		return nil , userTestGroup
	end

end