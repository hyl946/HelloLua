require "zoo.model.LuaXml"
require "hecore.utils"

MaintenanceFeature = class()

MaintenanceModeType = {
	kDefault = "default",
	kGroup = "group",
	kOrthogonalGroup = "orthogonal_group"
}

MaintenanceFilterListType = {
	
	kWhite = "white",
	kBlack = "black",
}

function MaintenanceFeature:ctor()
	self.enable = false
end
function MaintenanceFeature:fromXML( src )
	self:fromLua(src)
end

function MaintenanceFeature:encode()
	local ret = {}
	ret.enable = self.enable
	ret.value = self.value
	ret.id = self.id
	ret.name = self.name
	ret.beginDate = self.beginDate
	ret.endDate = self.endDate
	ret.extra = self.extra
	ret.mode = self.mode
	ret.review = self.review
	ret.whitelist = self.whitelist

	if self.filterlist and #self.filterlist > 0 then
		ret.filterlist = tostring( self.filterlistMode ) .. ";"
		for i = 1 , #self.filterlist do
			if i == #self.filterlist then
				ret.filterlist = ret.filterlist .. tostring(self.filterlist[i])
			else
				ret.filterlist = ret.filterlist .. tostring(self.filterlist[i]) ..","
			end
		end
	end

	if self.groupChild then
		for k,v in ipairs(self.groupChild) do
			local datastr = ""
			if #v.modules == 1 then
				datastr = v.modules[1] .. ";" .. v.weigh
			else
				for i = 1 , #v.modules do
					if i == #v.modules then
						datastr = datastr .. v.modules[i]
					else
						datastr = datastr .. v.modules[i] .. ","
					end
				end
				datastr = datastr .. ";" .. v.weigh
			end
			ret["child" .. tostring(k)] = datastr
		end
	end
	return ret
end

function MaintenanceFeature:isInWhitelist()
	local whitelist = self.whitelist
	if whitelist then
		local uid = tonumber(UserManager:getInstance().uid) or 0
		local uids = whitelist:split(",")

		for _,ud in ipairs(uids) do
			if tonumber(ud) == uid then
				return true
			end 
		end
	end
	return false
end

function MaintenanceFeature:isInFilterlist()

	if self.cacheResult then
		return self.cacheResult.result
	end

	self.cacheResult = {}

	local filterlist = self.filterlist
	if filterlist and #filterlist > 0 then
		local uid = UserManager:getInstance().uid or "12345"

		for k,v in ipairs( filterlist ) do
			if tostring(v) == tostring(uid) then
				self.cacheResult.result = true
				return true
			end 
		end
	end
	self.cacheResult.result = false
	return false
end

function MaintenanceFeature:fromLua(src)
	if not src then return end
	self.enable = string.lower(tostring(src.enable)) == "true"
	self.value = src.value
	self.id = src.id
	self.name = src.name
	self.beginDate = src.beginDate
	self.endDate = src.endDate
	self.extra = src.extra
	self.mode = src.mode
	self.review = string.lower(tostring(src.review)) == "true"
	self.groupChild = {}
	self.totalGroupWeigh = 0
	self.whitelist = src.whitelist
	self.groupVersion = "watingForCreate"

	self.filterlist = {}
	self.filterlistMode = MaintenanceFilterListType.kWhite

	if src.filterlist then
		local filterlistArr = src.filterlist:split(";")
		if filterlistArr and #filterlistArr >= 2 then
			
			if tostring( filterlistArr[1] ) == MaintenanceFilterListType.kWhite then
				self.filterlistMode = MaintenanceFilterListType.kWhite
			elseif tostring( filterlistArr[1] ) == MaintenanceFilterListType.kBlack then
				self.filterlistMode = MaintenanceFilterListType.kBlack
			end

			local uidArr = tostring(filterlistArr[2]):split(",")

			if uidArr then
				for i = 1 , #uidArr do
					table.insert( self.filterlist , tostring(uidArr[i]) )
				end
			end
		end
	end

	if not self.mode then self.mode = MaintenanceModeType.kDefault end

	local modeInfo = nil
	if src.mode then
		modeInfo = src.mode:split(";")
	end

	local mode = nil
	local modeData = nil

	if modeInfo then
		mode = modeInfo[1]
		modeData = modeInfo[2]
	end

	self.modeValue = mode

	if self.modeValue then

		if self.modeValue == MaintenanceModeType.kGroup or self.modeValue == MaintenanceModeType.kOrthogonalGroup then
			
			if self.modeValue == MaintenanceModeType.kOrthogonalGroup then
				self.groupTail = 8 --kOrthogonalGroup模式锁死8位
				self.orthogonalVersion = modeData
				-- self.orthogonalVersion = "HEAISeeds25834c13e606f026934b3e39434901c81"

			else
				if not modeData then 
					self.groupTail = 4
				else
					self.groupTail = tonumber(modeData)
				end
			end

			local configChildrens = {}
			for i = 1 , 99 do
				if src["child" .. tostring(i)] then
					table.insert( configChildrens , src["child" .. tostring(i)] )
				end
				if src["c" .. tostring(i)] then
					table.insert( configChildrens , src["c" .. tostring(i)] )
				end
			end

			local totalChildStr = ""
			for k,v in ipairs(configChildrens) do
				totalChildStr = totalChildStr .. v
				local t1 = v:split(";")
				local modules = nil
				local weigh = nil

				if t1 then
					if t1[1] then
						modules = t1[1]:split(",")
					end

					if t1[2] then
						weigh = tonumber(t1[2]) or 0
					end
				end

				if modules and weigh then
					self.totalGroupWeigh = self.totalGroupWeigh + weigh
					table.insert( self.groupChild , { idx = k , modules = modules , weigh = weigh , weighT = self.totalGroupWeigh ,  enable = self.enable} )
				end
			end

			if self.modeValue == MaintenanceModeType.kOrthogonalGroup then

				local arr1 = totalChildStr:split(";")
				local fixStr = nil
				for k1 , v1 in ipairs(arr1) do
					local arr2 = v1:split(",")
					local mstr = nil
					for k2 , v2 in ipairs(arr2) do
						if not mstr then
							mstr = v2
						else
							mstr = mstr .. "+" .. v2
						end
					end
					if not fixStr then
						fixStr = mstr
					else
						fixStr = fixStr .. "_" .. mstr
					end
				end

				self.groupVersion = HeMathUtils:md5( fixStr )
				-- printx( 1 , "kOrthogonalGroup   groupVersion = " , fixStr , self.groupVersion )
			end

			-- self.groupTail = modeData
			--printx(1 , "groupTail  ===========================================   " , self.name ,src.mode, self.groupTail)

		-- elseif self.modeValue == MaintenanceModeType.kOrthogonalGroup then

			-- local flag = self.name


		end
	end
end

local instance = nil
MaintenanceManager = {}

local majorBundleVersion = _G.bundleVersion or "1.54"
local ver = string.split(majorBundleVersion, '.')
if #ver > 1 then
	majorBundleVersion = ver[1].."."..ver[2]
end

function MaintenanceManager:getInstance()
	if not instance then
		instance = MaintenanceManager
		instance.data = {}
		instance:readFromStorage()
	end
	return instance
end

function MaintenanceManager:initialize(onFinish)
	if PrepackageUtil:isPreNoNetWork() then return end
	self:onlineLoad(onFinish)
end

function MaintenanceManager:readFromStorage()
	local data = Localhost:readFromStorage("Maintenance.ds")
	self:fromLua(data)
end

function MaintenanceManager:writeToStorage()
	local data = {}
	for k,v in pairs(self.data) do
		table.insert(data, v:encode())
	end
	Localhost:writeToStorage(data, "Maintenance.ds")
end

--maybe without local serialize 
function MaintenanceManager:addFeatureOutside(feature)
	if not feature or not feature:is(MaintenanceFeature) then 
		assert(false, 'wrong feature!') 
	end

	if not self.ignoreClearFeatures then self.ignoreClearFeatures = {} end
	self.ignoreClearFeatures[feature.name] = true

	if not self.data then self.data = {} end
	self.data[feature.name] = feature 
end

function MaintenanceManager:clearFeatureDataWithoutIgnore()
	local data = {}
	if self.ignoreClearFeatures then
		for k,_ in pairs(self.ignoreClearFeatures) do
			data[k] = self.data[k]
		end
	end
	self.data = data
end

function MaintenanceManager:clearSingleFeature(featureName)
	if self.data then self.data[featureName] = nil end
end

function MaintenanceManager:onlineLoad(onFinish)
	local url = NetworkConfig.maintenanceURL
	local uid = UserManager.getInstance().uid or "12345"
	local params = string.format("?name=maintenance&uid=%s&_v=%s", uid, majorBundleVersion)
	if __IOS_FB then
  		params = string.format("?name=maintenance_mobile&uid=%s&_v=%s", uid, majorBundleVersion)
  	end
	url = url .. params
  	if _G.isLocalDevelopMode then printx(0, "MaintenanceManager:", url) end
	local request = HttpRequest:createGet(url)

  	local connection_timeout = 2

	if __WP8 then 
	   	connection_timeout = 5
	end

    request:setConnectionTimeoutMs(connection_timeout * 1000)
    request:setTimeoutMs(30 * 1000)
   
    local function onRegisterFinished( response )
    	if response.httpCode ~= 200 then 
    		if _G.isLocalDevelopMode then printx(0, "get maintenance config error") end	
    	else
    		local message = response.body
    		local metaXML = xml.eval(message)
    		local confList = xml.find(metaXML, "maintenance")
    		if confList then
	    		self:clearFeatureDataWithoutIgnore()
	    		self:fromXML(confList)
	    		self:writeToStorage()
	    		require "zoo.util.UpdateCheckUtils"
	    		UpdateCheckUtils:getInstance():run()
	    		GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kMaintenanceChange))

	    		--loading图片轮播开关
	            local value = MaintenanceManager:getInstance():isEnabled('introAutoPlay',  false)
	            CCUserDefault:sharedUserDefault():setIntegerForKey("logo.isAutoPlay", value and 1 or 0)
	            CCUserDefault:sharedUserDefault():flush()
	    	end
    	end
    	self:_updateUseLowQualitySwitch()
    	if onFinish then onFinish() end
    end

    HttpClient:getInstance():sendRequest(onRegisterFinished, request)
end

function MaintenanceManager:_updateUseLowQualitySwitch()
	if not __IOS then return end

	local mKey = "ios.use.low.quality.enable"
    local config = CCUserDefault:sharedUserDefault()
	local maintenance = self:getMaintenanceByKey("UseLowQualityEnable")
	if maintenance and maintenance.enable and type(maintenance.extra) == "string" then
		local udidList = string.split(maintenance.extra, ",")
		local inTestList = false
		local udid = MetaInfo:getInstance():getUdid()
		for _, v in pairs(udidList) do
			if v == udid then 
				inTestList = true 
				break 
			end
		end
		if inTestList then
	        config:setBoolForKey(mKey, true)
        	config:flush()
	    else
	        if config:getBoolForKey(mKey, false) == true then
		        config:setBoolForKey(mKey, false)
	        	config:flush()
	    	end
		end
    else
    	if config:getBoolForKey(mKey, false) == true then
	        config:setBoolForKey(mKey, false)
        	config:flush()
    	end
	end
end

function MaintenanceManager:fromXML( src )
	if _G.isLocalDevelopMode then printx(0, "MaintenanceManager:fromXML") end
	if src then self.version = src.version end
	self:fromLua(src)
end

function MaintenanceManager:checkPlatformAndVersion( config )
	local platforms = nil
	local curPlatform = StartupConfig:getInstance():getPlatformName()
	local curVersion = majorBundleVersion

	if config.platform == nil or config.version == nil then return true end

	if type(config.platform) ~= "table" then
		platforms = config.platform:split(",")
	else
		platforms = config.platform
	end

	local versions = nil
	if type(config.version) ~= "table" then
		versions = config.version:split(",")
	else
		versions = config.version
	end	

	local isCurPlatform = false

	if platforms then
		if (__ANDROID or __WIN32) and table.indexOf(platforms, "android_all") then
			isCurPlatform = true
		elseif platforms[1] == "default" or table.indexOf(platforms, curPlatform) ~= nil then
			isCurPlatform = true
		end
	end

	--最小版本支持
	local minVersion = nil
	local delVersion = {}

	for _,v in ipairs(versions) do
		local mins, mine = string.find(v, "min:")
		if mins then
			minVersion = tonumber(string.sub(v, mine+1))
		end

		local dels, dele = string.find(v, "del:")
		if dels then
			table.insert(delVersion, tonumber(string.sub(v, dele+1)))
		end
	end

	if minVersion then
		versions = {}
		local e = tonumber(curVersion) or 1.54
		for ver=minVersion,e+0.01,0.01 do
			if not table.indexOf(delVersion, ver) then
				table.insert(versions, string.format("%0.2f", ver))
			end
		end
	end

	--有确切的版本号优先
	local hasCurVersion = versions and table.indexOf(versions, curVersion) ~= nil
	local isDefaultVersion = versions and versions[1] == "default"
	local needCover = hasCurVersion or isDefaultVersion

	if not hasCurVersion and self.data[config.name] then
		needCover = false
	end

	return isCurPlatform and needCover
end

function MaintenanceManager:fromLua(src)
	if _G.isLocalDevelopMode then printx(0, "MaintenanceManager:fromLua") end
	if not src then return end
	for k,config in pairs(src) do
		if type(config) == "table" and self:checkPlatformAndVersion(config) then
			local feature = MaintenanceFeature.new()
			feature:fromLua(config)
			if feature ~= nil and feature.name ~= nil then
				self.data[feature.name] = feature
			end
		end		
	end
end

function MaintenanceManager:getMaintenanceByKey(key)
	return self.data and self.data[key] or nil
end

function MaintenanceManager:isInWhitelist( key )
	local maintenance = self:getMaintenanceByKey(key)
	if maintenance then
		return maintenance:isInWhitelist()
	end
	return false
end

function MaintenanceManager:isInFilterlist( key )
	local maintenance = self:getMaintenanceByKey(key)
	if maintenance then
		return maintenance:isInFilterlist()
	end
	return false
end

--defaultEnable有值时，默认返回defaultEnable
function MaintenanceManager:isEnabled(key, defaultEnable)

	--if key == "AuthenticationFeature" then return false end  --for test will remove later
	local maintenance = self:getMaintenanceByKey(key)
	local flag = false
	if maintenance then
		flag = maintenance.enable
		if not maintenance.review and maintenance:isInFilterlist() then
			if maintenance.filterlistMode == MaintenanceFilterListType.kWhite then
				flag = true
			elseif maintenance.filterlistMode == MaintenanceFilterListType.kBlack then
				flag = false
			end
		end
	elseif defaultEnable ~= nil then
		flag = defaultEnable
	end
	if key == "reviewVersion" then
		if _G.bundleVersion == majorBundleVersion then
			return flag
		end
		return false
	end
	if maintenance and maintenance.review and self:isEnabled("reviewVersion") then
		flag = not flag
	end
	return flag
end

function MaintenanceManager:isEnabledConsiderBeginAndEndDate(key, defaultEnable)
	local flag = false
	if self:isEnabled(key, defaultEnable) then
		local activityBeginTime = -1
		local activityEndTime = -1
		local maintenance = self:getMaintenanceByKey(key)
		if maintenance then
			if maintenance.beginDate then
				activityBeginTime = parseDateStringToTimestamp(maintenance.beginDate)
			end
			if maintenance.endDate then
				activityEndTime = parseDateStringToTimestamp(maintenance.endDate)
			end
		end
		-- activityBeginTime = parseDateStringToTimestamp("2019-02-20 02:59:59")	--test
		-- activityEndTime = parseDateStringToTimestamp("2019-03-28 18:59:59")	--test
		local nowTime = Localhost:timeInSec()
		if activityBeginTime and activityEndTime 
			and activityBeginTime <= nowTime 
			and activityEndTime >= nowTime
			then
			-- 时间符合
			flag = true
		end
	end
	return flag
end

function MaintenanceManager:getUserGroupModules( maintenanceName , uid)
	--注意，该方法已停止维护，可能并不支持最新的分组算法

	local function getModules(feature)

		local rangeMap = self:getGroupChildRangeMap( maintenanceName )

		if rangeMap then
			
			local blockNum = 10000
			local groupTail = feature.groupTail

			if groupTail and type(groupTail) == "number" then
				local str = "1"
				for i = 1 , groupTail do
					str = str .. "0"
				end

				blockNum = tonumber(str)
			end

			local _uid = tonumber(uid) or 0
			local userWeighValue = _uid % blockNum

			local testInfo = UserManager:getInstance():getTestInfo()
			if testInfo then
				
				local pars = string.split( testInfo , ";" )

				for k,v in ipairs(pars) do

					local arr = string.split( v , "_" )

					if arr[1] == "dummyUid" then
						_uid = tonumber(arr[2]) or 0
						userWeighValue = _uid % blockNum
					end
				end
			end
			
			for k,v in ipairs(rangeMap) do
				if userWeighValue >= v.startId and userWeighValue <= v.endId then
					return v.modules
				end
			end
		end

		return {}
	end

	local maintenanceFeature = self.data[maintenanceName]

	if maintenanceFeature then

		if not maintenanceFeature.review and maintenanceFeature:isInFilterlist() then
			if maintenanceFeature.filterlistMode == MaintenanceFilterListType.kWhite then
				--TO DO
				return {}
			elseif maintenanceFeature.filterlistMode == MaintenanceFilterListType.kBlack then
				return {}
			end
		end

		local result = getModules( maintenanceFeature )
		return result
	else
		return {}
	end
end

function MaintenanceManager:getMaintenanceFeature(maintenanceName)
	return self.data[maintenanceName]
end

function MaintenanceManager:getUserWeighValue( maintenanceName , uid )
	-- printx( 1 , "MaintenanceManager:getUserWeighValue  " , maintenanceName , uid )
	local _uid = tonumber(uid) or 0
	local groupVersion = "unknowVersion"

	local userWeighValue = -9999

	if _uid ~= 12345 and _uid ~= 0 and _uid <= 9999999999 then

		local feature = self:getMaintenanceFeature(maintenanceName)
		local orthogonalVersion = nil
		local tail = 8

		if feature then

			if not feature.groupVersion then
				feature.groupVersion = "unknowVersion"
			end
			groupVersion = feature.groupVersion
			if feature.groupTail and type(feature.groupTail) == "number" then
				tail = feature.groupTail
			end

			orthogonalVersion = feature.orthogonalVersion
		end

		local md5Str = nil
		if orthogonalVersion then
			md5Str = HeMathUtils:md5( tostring( orthogonalVersion ) .. tostring( _uid ) )
		else
			md5Str = HeMathUtils:md5( tostring( maintenanceName ) .. tostring( groupVersion ) .. tostring( _uid ) )
		end

		local md5StrTail = string.sub( md5Str , tail * -1 )
		
		if ( groupVersion == "unknowVersion" or groupVersion == "watingForCreate" ) and (not orthogonalVersion) then
			return userWeighValue , groupVersion
		end

		userWeighValue = 0 

		for i = 1 , tail do
			local s = string.sub( md5StrTail , i , i )
			local snum = 0
			if s == "a" then
				snum = 10
			elseif s == "b" then
				snum = 11
			elseif s == "c" then
				snum = 12
			elseif s == "d" then
				snum = 13
			elseif s == "e" then
				snum = 14
			elseif s == "f" then
				snum = 15
			else
				snum = tonumber(s)
			end

			local ws = (tail - i)
			local wsnum = 1
			for ia = 1 , ws do
				wsnum = wsnum * 16
			end

			userWeighValue = userWeighValue + (snum * wsnum)
		end
	end

	return userWeighValue , groupVersion
end

function MaintenanceManager:isEnabledInGroup( maintenanceName , moduleKey , uid)
	
	local function checkModuleEnable(feature)
		local rangeMap = self:getGroupChildRangeMap( feature.name )
		if rangeMap then
			local blockNum = 10000
			local groupTail = feature.groupTail

			local _uid = tonumber(uid) or 0
			local userWeighValue = -9999

			if feature.modeValue == MaintenanceModeType.kGroup then

				if groupTail and type(groupTail) == "number" then
					local str = "1"
					for i = 1 , groupTail do
						str = str .. "0"
					end

					blockNum = tonumber(str)
				end

				userWeighValue = _uid % blockNum
			elseif feature.modeValue == MaintenanceModeType.kOrthogonalGroup then
				userWeighValue = self:getUserWeighValue( feature.name , _uid )
			end

			local testInfo = tostring( UserManager:getInstance():getTestInfo() )
			local dummyGroupList = {}

			if testInfo then	
				local pars = string.split( testInfo , ";" )

				for k,v in ipairs(pars) do

					local arr = string.split( v , "_" )

					if arr[1] == "dummyUid" then
						_uid = tonumber(arr[2]) or 0
						if feature.modeValue == MaintenanceModeType.kGroup then
							userWeighValue = _uid % blockNum
						end
					elseif arr[1] == "dummyGroup" then
						local dg = { switchName = tostring(arr[2]) , groupIndex = tonumber(arr[3]) }
						table.insert( dummyGroupList , dg )
					end
				end
			end

			if dummyGroupList and #dummyGroupList > 0 then
				for k , v in ipairs(dummyGroupList) do
					if v.switchName == feature.name and v.groupIndex then
						if rangeMap[v.groupIndex] then
							local data = rangeMap[v.groupIndex]
							for k2,v2 in ipairs( data.modules ) do
								if v2 == moduleKey then
									return feature.enable
								end
							end
						end
						return false
					end
				end
			end 

			if feature.modeValue == MaintenanceModeType.kGroup then
				for k,v in ipairs(rangeMap) do
					--userWeighValue
					if userWeighValue >= v.startId and userWeighValue <= v.endId then
						for k2,v2 in ipairs( v.modules ) do

							if v2 == moduleKey then
								return feature.enable
							end
						end
						break
					end
				end
			elseif feature.modeValue == MaintenanceModeType.kOrthogonalGroup then
				if userWeighValue < 0 then
					return false
				end

				local totalGroupWeigh = feature.totalGroupWeigh
				local currWeigh = userWeighValue % totalGroupWeigh + 1

				for k1,v1 in ipairs(feature.groupChild) do
					if currWeigh > v1.weighT - v1.weigh and currWeigh <= v1.weighT then
						for k2,v2 in ipairs( v1.modules ) do
							if v2 == moduleKey then
								return feature.enable
							end
						end
						break
					end
				end
			end
		end
		return false
	end


	if maintenanceName then
		local maintenanceFeature = self.data[maintenanceName]

		if maintenanceFeature then

			if not maintenanceFeature.review and maintenanceFeature:isInFilterlist() then
				if maintenanceFeature.filterlistMode == MaintenanceFilterListType.kWhite then
					-- DiffAdjustQAToolManager:print( 1 , "MaintenanceManager:isEnabledInGroup 111" , maintenanceName , "true" )
					return true
				elseif maintenanceFeature.filterlistMode == MaintenanceFilterListType.kBlack then
					-- DiffAdjustQAToolManager:print( 1 , "MaintenanceManager:isEnabledInGroup 222" , maintenanceName , "false" )
					return false
				end
			end

			local result = checkModuleEnable( maintenanceFeature )
			-- DiffAdjustQAToolManager:print( 1 , "MaintenanceManager:isEnabledInGroup 333" , maintenanceName , result )
			return result
		else
			--RemoteDebug:uploadLog( "MaintenanceManager:isEnabledInGroup  maintenanceName " .. tostring(maintenanceName) .. "  has not exist !!" )
			-- DiffAdjustQAToolManager:print( 1 , "MaintenanceManager:isEnabledInGroup 444" , maintenanceName , "false" )
			return false
		end
	else
		-- 为了保证正交，不再支持这种方法，以前使用此特性的老开关已经迁移
		-- for k,v in pairs(self.data) do
		-- 	local r = checkModuleEnable( v )
		-- 	if r then return true end
		-- end
	end

	
	return false
end

function MaintenanceManager:getGroupChildRangeMap( maintenanceName )

	if not maintenanceName then return nil end

	if not self.groupChildRangeMap then
		self.groupChildRangeMap = {}
	end

	if self.groupChildRangeMap[maintenanceName] then
		return self.groupChildRangeMap[maintenanceName]
	end

	local feature = self.data[maintenanceName]
	local rangeMap = nil

	if feature and feature.modeValue then

		if feature.modeValue == MaintenanceModeType.kGroup then
			
			rangeMap = {}

			local totalWeigh = feature.totalGroupWeigh
			local blockNum = 10000

			if feature.groupTail and type(feature.groupTail) == "number" then
				local str = "1"
				for i = 1 , feature.groupTail do
					str = str .. "0"
				end
				blockNum = tonumber(str)
			end
			-- printx( 1 , "----------------------------~~~~!!!!!!")
			for k1,v1 in ipairs(feature.groupChild) do

				local currWeighValue = tonumber(   ( (v1.weighT - v1.weigh) / totalWeigh * blockNum )   )
				local nextWeighValue = tonumber(   ( v1.weighT / totalWeigh * blockNum ) - 1  )

				-- printx( 1 , "currWeighValue =" , currWeighValue , "nextWeighValue" , nextWeighValue )

				local moduleStr = ""

				for k2,v2 in ipairs( v1.modules ) do
					moduleStr = moduleStr .. tostring(v2) .. " "
				end

				if nextWeighValue < currWeighValue then
					rangeMap[k1] = { startId = -1 , endId = -1 , modules = v1.modules , str = moduleStr }
				elseif currWeighValue < 0 then
					if nextWeighValue < 0 then
						rangeMap[k1] = { startId = -1 , endId = -1 , modules = v1.modules , str = moduleStr }
					else
						rangeMap[k1] = { startId = 0 , endId = math.floor(nextWeighValue) , modules = v1.modules , str = moduleStr }
					end
				elseif currWeighValue >= (blockNum - 1) then
					rangeMap[k1] = { startId = -1 , endId = -1 , modules = v1.modules , str = moduleStr }
				else
					rangeMap[k1] = { startId = math.floor(currWeighValue) , endId = math.floor(nextWeighValue) , modules = v1.modules , str = moduleStr }
				end
			end

		elseif feature.modeValue == MaintenanceModeType.kOrthogonalGroup then

			rangeMap = {}

			local totalWeigh = feature.totalGroupWeigh
			local blockNum = 1
			-- printx( 1 , "feature.groupTail" , feature.groupTail , type(feature.groupTail) )
			if feature.groupTail and type(feature.groupTail) == "number" then
				local num = 1
				for i = 1 , feature.groupTail do
					blockNum = blockNum * 16
				end
			end
			-- printx( 1 , "MaintenanceManager:getGroupChildRangeMap  ----------------maintenanceName =" , maintenanceName , "blockNum" , blockNum , "totalWeigh" , totalWeigh)
			for k1,v1 in ipairs(feature.groupChild) do

				local currWeighValue = tonumber(   ( (v1.weighT - v1.weigh) / totalWeigh * blockNum )   )
				local nextWeighValue = tonumber(   ( v1.weighT / totalWeigh * blockNum ) - 1  )

				-- printx( 1 , "ipairs(feature.groupChild) k1" , k1 , "v1.weighT" , v1.weighT , "v1.weigh" , v1.weigh , "\n" , " currWeighValue =" , currWeighValue , "nextWeighValue" , nextWeighValue )

				local moduleStr = ""

				for k2,v2 in ipairs( v1.modules ) do
					moduleStr = moduleStr .. tostring(v2) .. " "
				end

				if nextWeighValue < currWeighValue then
					rangeMap[k1] = { startId = -1 , endId = -1 , modules = v1.modules , str = moduleStr }
				elseif currWeighValue < 0 then
					if nextWeighValue < 0 then
						rangeMap[k1] = { startId = -1 , endId = -1 , modules = v1.modules , str = moduleStr }
					else
						rangeMap[k1] = { startId = 0 , endId = math.floor(nextWeighValue) , modules = v1.modules , str = moduleStr }
					end
				elseif currWeighValue >= (blockNum - 1) then
					rangeMap[k1] = { startId = -1 , endId = -1 , modules = v1.modules , str = moduleStr }
				else
					rangeMap[k1] = { startId = math.floor(currWeighValue) , endId = math.floor(nextWeighValue) , modules = v1.modules , str = moduleStr }
				end
			end

		end
		
	end
	self.groupChildRangeMap[maintenanceName] = rangeMap

	return rangeMap
end



function MaintenanceManager:printGroupRange( maintenanceName )
	local feature = self.data[maintenanceName]
	local rangeMap = self:getGroupChildRangeMap( maintenanceName )

	if rangeMap then
		printx( -6 , "  maintenanceName = " , maintenanceName)
		if feature.modeValue == MaintenanceModeType.kGroup then
			printx( -6 , "  按uid尾号后" .. tostring(feature.groupTail) .. "位分组")	
		elseif feature.modeValue == MaintenanceModeType.kOrthogonalGroup then
			printx( -6 , "  按MD5后" .. tostring(feature.groupTail) .. "位分组")
		end

		for k3,v3 in ipairs( rangeMap ) do
			printx( -6 , "  group" .. tostring(k3) .. "   " ..  tostring(v3.startId) .. " ~ " .. tostring(v3.endId) .. "    modules: " .. v3.str )
		end
	end
	
	return rangeMap
end

function MaintenanceManager:getValue(key)
	local maintenance = self:getMaintenanceByKey(key)
	if maintenance then
		return maintenance.value
	else
		return nil
	end
end

-- since version 1.30, value = [0, 10000]
function MaintenanceManager:isAvailbleForUid(key, uid, threshold)
	local maintenance = self:getMaintenanceByKey(key)
	if maintenance and maintenance.enable then -- 开关已打开
		local uidEndWith = nil
		if maintenance.value ~= nil then 
			uidEndWith = tonumber(maintenance.value)
		end

		if uidEndWith == nil then -- uid无限制
			return true
		else -- 在灰度范围内
			uid = tonumber(uid) or 0
			threshold = tonumber(threshold) or 100
			return (uid % threshold) < uidEndWith
		end
	end
	return false
end

function MaintenanceManager:getExtra(key)
	local maintenance = self:getMaintenanceByKey(key)
	if maintenance then
		return maintenance.extra
	else
		return nil
	end
end

function MaintenanceManager:isInReview()
	if __ANDROID then
		return MaintenanceManager:getInstance():isEnabled("AndroidInReview", false)
	elseif __IOS then
		return MaintenanceManager:getInstance():isEnabled("reviewVersion", false)
	end
	return false
end