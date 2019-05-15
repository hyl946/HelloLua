require "zoo.net.LevelType"

require "zoo.data.UserManager"
require "zoo.data.FriendManager"

require "zoo.net.UserLocalLogic"
require "zoo.net.UserExtendsLocalLogic"
require "zoo.net.StageInfoLocalLogic"
require "zoo.net.GoodsLocalLogic"
require "zoo.net.LevelAreaLocalLogic"

local kLocalDataExt = ".ds"
local kLastLoginUserConfigName = "login"..kLocalDataExt
local kDefaultConfigName = "conf"..kLocalDataExt
-- local kOpenIdConfigName = "openId" .. kLocalDataExt
local kUpdatedConfigName = "updatedConfig" .. kLocalDataExt
local kFriendsCacheDataName = "friendsCache" .. kLocalDataExt
local kLocalExtraDataName = "localExtraData" .. kLocalDataExt
local kLocalDailyDataName = "localDailyData" .. kLocalDataExt
local fullPathOfLocalData = HeResPathUtils:getUserDataPath()
local kPhoneListName = "phoneList" .. kLocalDataExt
local kSummerWeeklyMatchDataName = "summerWeekly.ver2"..kLocalDataExt
local kRankRaceDataName = "rankRaceDataName"..kLocalDataExt
local kUserMissionDataName = "userMission"..kLocalDataExt
local kAskForHelpDataName = "askForHelp"..kLocalDataExt
local kIosScoreReviewDataName = "ios_score_review"..kLocalDataExt


local instance = nil
Localhost = {}

function Localhost.getInstance()
	if not instance then instance = Localhost end
	return instance
end

function Localhost:requireLogin()
	local notLogin = not _G.kUserLogin
	local notRegistered = not Localhost:isUserRegistered()
	if NetworkConfig.useLocalServer and notLogin and notRegistered then return true
	else return false end
end
function Localhost:isUserRegistered()
	local uid = UserManager.getInstance().uid
	local sk = UserManager.getInstance().sessionKey
	if uid and sk and uid ~= sk then return true
	else return false end
end

--time
function Localhost:time()
	return Localhost:timeInSec() * 1000
end
-- add in version 1.20
function Localhost:timeInSec()
	local time = __g_utcDiffSeconds or 0
	return (os.time() + time)
end
-- since version 1.63
function Localhost:timeInMillis()
	local time = __g_utcDiffSeconds or 0
	return (HeTimeUtil:getCurrentTimeMillis() + time * 1000)
end

--获取当日开始时间 单位 s
function Localhost:getDayStartTimeByTS(ts)
	if ts ~= nil then
		local utc8TimeOffset = 57600
		local dayInSec = 86400
		return ts - ((ts - utc8TimeOffset) % dayInSec)
	end
	
	return 0
end

--获取今天开始时间 单位 s
function Localhost:getTodayStart()
	return Localhost:getDayStartTimeByTS(Localhost:timeInSec())
end

function Localhost:getDefaultConfig()
	local config = self:readFromStorage(kDefaultConfigName)
	if not config then config = {td=0, pl=0, gc=1} end
	if config.pl == nil then config.pl = 0 end --play CG by default.
	if config.gc == nil then config.gc = 1 end --enable game center by default.
	return config
end
function Localhost:saveTimeDiff( timeDiff )
	local timeDiff = timeDiff or 0
	if _G.isLocalDevelopMode then printx(0, "saveTimeDiff:", timeDiff) end
	local config = Localhost:getDefaultConfig() 
	config.td = timeDiff
	self:writeToStorage(config, kDefaultConfigName)
end
function Localhost:saveCgPlayed( played )
	local isPlayed = 0
	if played ~= nil then isPlayed = played end
	local config = Localhost:getDefaultConfig() 
	config.pl = played
	self:writeToStorage(config, kDefaultConfigName)
end
function Localhost:saveGmeCenterEnable( v )
	local enabled = 1
	if v ~= nil then enabled = v end
	local config = Localhost:getDefaultConfig() 
	config.gc = enabled
	self:writeToStorage(config, kDefaultConfigName)
end
function Localhost:saveGuestCreateTime(timeInSec)
	local config = Localhost:getDefaultConfig() 
	config.guestCreateTime = timeInSec
	self:writeToStorage(config, kDefaultConfigName)
end
function Localhost:getGuestCreateTime()
	local config = Localhost:getDefaultConfig() 
	return config.guestCreateTime
end

-- open Id
function Localhost:setCurrentUserOpenId( openId,accessToken,authorType )
	local uid = UserManager.getInstance().uid
	if uid then
		if _G.isLocalDevelopMode then printx(0, "setCurrentUserOpenId:uid="..tostring(uid)..",openId="..tostring(openId) .. ",accessToken="..tostring(accessToken)) end
		local fileName = self:getUserLocalKeyByUserID(uid)
		local userData = self:readFromStorage(fileName) or {}
		userData.openId = openId
		userData.accessToken = accessToken
		userData.authorType = authorType --SnsProxy:getAuthorizeType()
		--if _G.isLocalDevelopMode then printx(0, table.tostring(userData)) end
		self:writeToStorage(userData, fileName)
	else if _G.isLocalDevelopMode then printx(0, "setCurrentUserOpenId fail, userid is nil") end end
end

-- updated config
function Localhost:saveUpdatedGlobalConfig( cfg )
	if cfg and type(cfg) == "table" then
		self:writeToStorage(cfg, kUpdatedConfigName)
	end
end

function Localhost:getUpdatedGlobalConfig()
	local config = self:readFromStorage(kUpdatedConfigName)
	if not config then config = {} end
	return config
end

--login
function Localhost:getLastLoginUserConfig()
	local config = self:readFromStorage(kLastLoginUserConfigName)
	if not config then
		config = {uid=0}
	end
	if kIsMockLoginMode and type(kMockLoginData) == "table" then
		config = kMockLoginData
	end
	if _G.isLocalDevelopMode then printx(0, "getLastLoginUserConfig", config.uid, config.sk, config.time) end
	return config
end
function Localhost:setLastLoginUserConfig(uid, sessionKey, platform)
	if uid == nil then uid = 0 end
	local time = Localhost:time()
	-- local time = os.time() * 1000
	local config = {uid = uid, sk = sessionKey, time=time, p=platform}
	local defaultUdid = MetaInfo:getInstance():getUdid()
	if defaultUdid == sessionKey then
		if _G.isLocalDevelopMode then printx(0, "last login udid is the same as default") end
	end
	if _G.isLocalDevelopMode then printx(0, "lua setLastLoginUserConfig", tostring(uid), tostring(sessionKey)) end
	self:writeToStorage(config, kLastLoginUserConfigName)
end

--user info
function Localhost:getUserLocalKeyByUserID(uid)
	assert(uid, "userid should not nil")
	local platform = UserManager.getInstance().platform
	local key = tostring(platform) .. "_u_".. tostring(uid) .. kLocalDataExt
	return key
end
function Localhost:readCurrentUserData()
	local currUuid = kDeviceID
	local fileName = self:getUserLocalKeyByUserID(UserManager.getInstance().uid)
	local readData = self:readFromStorage(fileName)
	if readData then
		local readUuid = readData.uuid
		if currUuid == readUuid then return readData		
		else
			if _G.isLocalDevelopMode then printx(0, "Waining:Verify user data fail. invalid UUID!") end
			return nil
		end
	else 
		if _G.isLocalDevelopMode then printx(0, "Waining:Local user data not found!") end
		return nil
	end
end
function Localhost:readUserDataByUserID( uid )
	local currUuid = kDeviceID
	local fileName = self:getUserLocalKeyByUserID(uid)
	local readData = self:readFromStorage(fileName)
	if readData then
		--if _G.isLocalDevelopMode then printx(0, "flushCurrentUserData:"..table.tostring(readData.openId)) end
		local readUuid = readData.uuid
		if currUuid == readUuid then return readData		
		else
			if _G.isLocalDevelopMode then printx(0, "Waining:Verify user data fail. invalid UUID!") end
			return nil
		end
	else 
		if _G.isLocalDevelopMode then printx(0, "Waining:Local user data not found!") end
		return nil
	end
end

function Localhost:flushCurrentUserData()
	local uid = UserManager.getInstance().uid
	if uid then
		local fileName = self:getUserLocalKeyByUserID(uid)
		local userData = self:readFromStorage(fileName) or {}
		userData.user = UserService.getInstance():encode()
		userData.uuid = kDeviceID

		if _G.isLocalDevelopMode then printx(0, "flushCurrentUserData:"..table.tostring(userData.openId)) end
		if _G.isLocalDevelopMode then printx(0, table.tostring(userData.user.lastCheckTime)) end
		self:writeToStorage(userData, fileName)
	else if _G.isLocalDevelopMode then printx(0, "flushCurrentUserData fail, userid is nil") end end
end
function Localhost:flushSelectedUserData( userData )
	local fileName = self:getUserLocalKeyByUserID(UserManager.getInstance().uid)
	self:writeToStorage(userData, fileName)
end

function Localhost:readLastLoginUserData()
	local savedConfig = Localhost.getInstance():getLastLoginUserConfig()
	if savedConfig.uid ~= 0 then
		local uid = tostring(savedConfig.uid)
		local sessionKey = tostring(savedConfig.sk)
		local platform = tostring(savedConfig.p)
		local fileName = platform .. "_u_" .. uid .. kLocalDataExt
		return self:readFromStorage(fileName)
	end
	return nil
end

--friends
function Localhost:flushCurrentFriendsData()
	local fileName = self:getUserLocalKeyByUserID(UserManager.getInstance().uid)
	local userData = self:readFromStorage(fileName) or {}

	if not userData.user then
		if _G.isLocalDevelopMode then printx(0, "What? user data not found?") end
		userData.user = UserService.getInstance():encode()
	end

	userData.friends = FriendManager.getInstance():encode()
	self:writeToStorage(userData, fileName)
end

-- 
function Localhost:getLastLoginPhoneNumber( ... )
	local phoneList = self:readCachePhoneListData()
	if #phoneList > 0 then 
		return phoneList[1]
	else
		return ""
	end
end
function Localhost:readCachePhoneListData()
	return self:readFromStorage(kPhoneListName) or {}
end
function Localhost:writeCachePhoneListData(newPhoneNumber)
	local phoneList = self:readCachePhoneListData()
	if #phoneList > 0 and phoneList[1] == newPhoneNumber then 
		return
	end
	table.removeValue(phoneList,newPhoneNumber)
	table.insert(phoneList,1,newPhoneNumber)

	while #phoneList > 5 do
		table.remove(phoneList,#phoneList)
	end

	self:writeToStorage(phoneList,kPhoneListName)
end

-- local daily data
function Localhost:getLocalDailyDataKey(uid)
	return tostring(uid).."_"..kLocalDailyDataName
end

function Localhost:readLocalDailyData(uid, needRefresh)
	if needRefresh ~= false then needRefresh = true end
	local uid = uid or UserManager.getInstance().uid
	local dailyData = self:readFromStorage(Localhost:getLocalDailyDataKey(uid))

	local function resetDailyData()
		dailyData = {}
		dailyData.resetTime = Localhost:timeInSec()
		Localhost:writeLocalDailyData(uid, dailyData)
	end

	if type(dailyData) ~= "table" then
		resetDailyData()
	elseif needRefresh then
		local updateDate = os.date("*t", dailyData.resetTime)
		local curDate = os.date("*t", Localhost:timeInSec())

		if not (updateDate.year == curDate.year and updateDate.month == curDate.month and updateDate.day == curDate.day) then
			resetDailyData()
		end
	end
	return dailyData
end

function Localhost:writeLocalDailyData(uid, dailyData)
	if type(dailyData) ~= "table" then
		return
	end
	local uid = uid or UserManager.getInstance().uid
	self:writeToStorage(dailyData, Localhost:getLocalDailyDataKey(uid))
end

function Localhost:deleteLocalDailyData(uid)
	local filePath = fullPathOfLocalData.."/"..Localhost:getLocalDailyDataKey(uid)
   	os.remove(filePath)
end

-- 周赛数据
function Localhost:writeWeeklyMatchData(data)
	self:writeToStorage(data,kSummerWeeklyMatchDataName)
end

function Localhost:readWeeklyMatchData()
	return self:readFromStorage(kSummerWeeklyMatchDataName)
end

function Localhost:deleteWeeklyMatchData()
	local filePath = fullPathOfLocalData.."/"..kSummerWeeklyMatchDataName
   	os.remove(filePath)
end

function Localhost:writeRankRaceData(data)
	self:writeToStorage(data,kRankRaceDataName)
end

function Localhost:readRankRaceData()
	return self:readFromStorage(kRankRaceDataName)
end

function Localhost:deleteRankRaceData()
	local filePath = fullPathOfLocalData.."/"..kRankRaceDataName
   	os.remove(filePath)
end

-- 任务系统
function Localhost:deleteUserMissionData()
	local filePath = fullPathOfLocalData.."/"..kUserMissionDataName
   	os.remove(filePath)
end

-- 关卡本地数据
function Localhost:readLocalLevelData( uid )
	local filePath = "localLevelData_" .. tostring(uid)
	return self:readFromStorage(filePath) or {}
end
function Localhost:writeLocalLevelData( uid,data )
	local filePath = "localLevelData_" .. tostring(uid)
	self:writeToStorage(data,filePath)
end
function Localhost:readLocalLevelDataByLevelId( uid,levelId )
	return self:readLocalLevelData(uid)[tostring(levelId)] or {}
end
function Localhost:writeLocalLevelDataByLevelId( uid,levelId,levelData )
	local data = self:readLocalLevelData(uid)
	data[tostring(levelId)] = levelData

	self:writeLocalLevelData(uid,data)
end

-- 掩藏关卡本地数据
function Localhost:readLocalBranchData( uid )
	local filePath = "lcoalBranchData_" .. tostring(uid)
	return self:readFromStorage(filePath) or {}
end
function Localhost:readLocalBranchDataByBranchId( uid,branchId )
	return self:readLocalBranchData(uid)[tostring(branchId)] or {}
end
function Localhost:writeLocalLevelDataByBranchId( uid,branchId,branchData )
	local filePath = "lcoalBranchData_" .. tostring(uid)
	local data = self:readLocalBranchData(uid)
	data[tostring(branchId)] = branchData

	return self:writeToStorage(data,filePath)
end

--好友代打数据
function Localhost:writeAskForHelpData(data)
	local uid = UserManager.getInstance().uid or "12345"
    local path = tostring(uid) ..kAskForHelpDataName
	self:writeToStorage(data, path)
end
function Localhost:readAskForHelpData()
	local uid = UserManager.getInstance().uid or "12345"
    local path = tostring(uid) ..kAskForHelpDataName
	return self:readFromStorage(path)
end

--iOS评分数据
function Localhost:writeIOSScoreReviewData(data)
	self:writeToStorage(data, kIosScoreReviewDataName)
end
function Localhost:readIOSScoreReviewData()
	return self:readFromStorage(kIosScoreReviewDataName)
end

--将string中的内容以二进制的方式写入文件,
--	此方法先创建临时文件，将内容写入临时文件，
--	最后把临时文件move成正式文件
--	注意： **此方法仅限于文件内容较少，并且一次性写入的调用
function Localhost:writeToStorage(data, fileName)
	assert(data and fileName, "data and fileName should not be nil")
    if data and fileName then
    	local filePath = fullPathOfLocalData.."/"..fileName
        local am3data = amf3.encode(data)
        --TODO: encypt data
        self:safeWriteStringToFile(am3data, filePath)
    end
end

function Localhost:writeToStorageDebug(data, fileName)
	assert(data and fileName, "data and fileName should not be nil")
    if data and fileName then
    	local filePath = fullPathOfLocalData.."/"..fileName
        -- local am3data = amf3.encode(data)
        --TODO: encypt data
        self:safeWriteStringToFile(table.serialize(data), filePath)
    end
end

function Localhost:deleteLastLoginUserConfig()
	local filePath = fullPathOfLocalData.."/"..kLastLoginUserConfigName
	if _G.isLocalDevelopMode then printx(0, "delete local last login data") end
   	os.remove(filePath)
end
function Localhost:deleteUserDataByUserID( uid )
	local fileName = self:getUserLocalKeyByUserID(uid)
	local filePath = fullPathOfLocalData.."/"..fileName
	if _G.isLocalDevelopMode then printx(0, "delete local user data, uid:"..tostring(uid)) end
   	os.remove(filePath)
end
function Localhost:deleteGuideRecord()
	local filePath = fullPathOfLocalData.."/guiderec"
	if _G.isLocalDevelopMode then printx(0, "delete local guide data") end
   	os.remove(filePath)
end
function Localhost:deletePushRecord()
	local filePath = fullPathOfLocalData.."/pushrec"
	if _G.isLocalDevelopMode then printx(0, "delete local push data") end
   	os.remove(filePath)
end
function Localhost:deleteMarkPriseRecord()
	local filePath = fullPathOfLocalData.."/markprise"
	if _G.isLocalDevelopMode then printx(0, "delete local guide data") end
   	os.remove(filePath)
end
function Localhost:flushLocalExtraData(data)
	if data == nil then return end
	self:writeToStorage(data, kLocalExtraDataName)
end
function Localhost:readLocalExtraData()
	return self:readFromStorage(kLocalExtraDataName)
end
function Localhost:deleteLocalExtraData()
	if _G.isLocalDevelopMode then printx(0, "delete LocalExtraData") end
   	os.remove(kLocalExtraDataName)
end
function Localhost:safeWriteStringToFile(data, filePath)
    local tmpName = filePath .. "." .. os.time()
    local file = io.open(tmpName, "wb")
    assert(file, "persistent file failure " .. tmpName)
    if not file then return end

    local success = file:write(data)
   
    if success then
        file:flush()
        file:close()
        os.remove(filePath)
        os.rename(tmpName, filePath)
    else
        file:close()
        os.remove(tmpName)
        if _G.isLocalDevelopMode then printx(0, "write file failure " .. tmpName) end
    end        
end

function Localhost:readFromStorage( fileName )
	assert(fileName, "fileName should not be nil")
	if fileName then
		local filePath = fullPathOfLocalData.."/"..fileName
		local file = io.open(filePath, "rb")
		if file then
			local data = file:read("*a") 
			file:close()

			if data then
				local result = nil 
				local function decodeAmf3() result = amf3.decode(data) end
				--TODO: decypt data
				pcall(decodeAmf3)
				return result
				--return amf3.decode(data)
			end
		end
	end
	return nil
end

function Localhost:readFromStorageDebug(fileName)
	assert(fileName, "fileName should not be nil")
	if fileName then
		local filePath = fullPathOfLocalData.."/"..fileName
		local file = io.open(filePath, "rb")
		if file then
			local data = file:read("*a") 
			file:close()

			-- if data then
			-- 	local result = nil 
			-- 	local function decodeAmf3() result = amf3.decode(data) end
			-- 	--TODO: decypt data
			-- 	pcall(decodeAmf3)
			-- 	return result
			-- 	--return amf3.decode(data)
			-- end
			return table.deserialize(data)
		end
	end
	return nil
end

--
-- local service interface ---------------------------------------------------------
--

function Localhost:setImage(image)
	UserService.getInstance().user.image = image

	if NetworkConfig.writeLocalDataStorage then self:flushCurrentUserData()
	else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
	return true
end

local warpEngineLFN = "wa" .. "rpIn" .. "fo.re" .. "ast"
local warpEngineResult = nil
function Localhost:getWarp()
	return warpEngineResult , self.warpRpcount , self.warpRaddcount
end

function Localhost:setWarp(value)
	--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--

	warpEngineResult = value
end

function Localhost:doWarp( datas )

	local ldataPath = HeResPathUtils:getUserDataPath() .. "/" .. warpEngineLFN

	local function loadConfig()
		local filePath = HeResPathUtils:getUserDataPath() .. "/" .. "lev" .. "el_te" .. "st_upd" .. "ate"
		local file = io.open(filePath, "rb")
		if file then
			local content = file:read("*a") 
			file:close()
			if content then
				local config = nil
				pcall(function() config = table.deserialize(content) end)
				return config
			end
		end
		return nil
	end

	local function slevel( data )
		local ldata = {}

		ldata.sl = data
		ldata.up = {}
		ldata.log1 = {}
		ldata.ctime = self:timeInSec()

		-- printx( 1 , "Localhost:doWarp slevel ----------------------------------------  data.itemList =" , table.tostring(data.itemList) )
		if data.itemList and #data.itemList > 0 then
			for k,v in ipairs(data.itemList) do
				if v == ItemType.ADD_THREE_STEP or v == ItemType.TIMELIMIT_ADD_THREE_STEP then
					local pdata = {}
					pdata.t = "useProps"
					pdata.uid = data.uid
					pdata.itemList = {v}
					pdata.levelId = data.levelId
					table.insert( ldata.up , pdata ) 
				end
			end
		end

		local ldatastr = ReplayDataManager:rpEncode( ldata )

		if ldatastr then
			self:safeWriteStringToFile( ldatastr , ldataPath )
		end
	end

	local function doact( data )

		local hFile, err = io.open(ldataPath, "r")
		local datastr = nil
		if hFile and not err then
			datastr = hFile:read("*a")
			io.close(hFile)
		end

		local ldata = ReplayDataManager:rpDecode( datastr )

		if ldata and ldata.up then

			if data.t == "useProps" 
				and ldata.sl.levelId == data.levelId 
				and ( tostring(ldata.sl.uid) == tostring(data.uid) or tostring(ldata.sl.uid) == "12345" ) 
				then
					table.insert( ldata.up , data )
					local ldatastr = ReplayDataManager:rpEncode( ldata )
					if ldatastr then
						self:safeWriteStringToFile( ldatastr , ldataPath )
					end
			end
		end
	end

	local function plevel( data )
		self.warpRpcount = nil
		self.warpRaddcount = nil

		local hFile, err = io.open(ldataPath, "r")
		local datastr = nil
		if hFile and not err then
			datastr = hFile:read("*a")
			io.close(hFile)
		end

		local ldata = ReplayDataManager:rpDecode( datastr )

		if ldata and ldata.up and ldata.log1 
			and ldata.sl.levelId == data.levelId 
			and ( tostring(ldata.sl.uid) == tostring(data.uid) or tostring(ldata.sl.uid) == "12345" ) then

			local pcount = 0
			local addcount = 0

			local rpcount = 0
			local raddcount = 0
			for k,v in ipairs(ldata.log1) do
				pcount = pcount + 1
				addcount = addcount + v
			end

			for k,v in ipairs(ldata.up) do

				if v.itemList and v.itemList[1] then
					local pid = v.itemList[1]
					if pid == ItemType.ADD_FIVE_STEP or
						pid == ItemType.ADD_BOMB_FIVE_STEP or
						pid == ItemType.TIMELIMIT_48_ADD_BOMB_FIVE_STEP or
						pid == ItemType.ADD_FIVE_STEP_BY_BALLOON or
						pid == ItemType.TIMELIMIT_ADD_FIVE_STEP
					then
						rpcount = rpcount + 1
						raddcount = raddcount + 5
					elseif pid == ItemType.ADD_15_STEP then
						rpcount = rpcount + 1
						raddcount = raddcount + 15
					elseif pid == ItemType.ADD_1_STEP then
						rpcount = rpcount + 1
						raddcount = raddcount + 1
					elseif pid == ItemType.ADD_2_STEP then
						rpcount = rpcount + 1
						raddcount = raddcount + 2
					elseif pid == ItemType.ADD_FIVE_STEP_BY_ANIMAL then
						rpcount = rpcount + 1
						raddcount = raddcount + tonumber(v.addMovesCount)
					elseif pid == ItemType.ADD_THREE_STEP or pid == ItemType.TIMELIMIT_ADD_THREE_STEP then
						rpcount = rpcount + 1
						raddcount = raddcount + 3
					end

					-- local propMeta = MetaManager.getInstance():getPropMeta(pid)
				end
			end

			local pcountErr = pcount > rpcount
			local addcountErr = addcount > raddcount
			local __config = loadConfig()

			self.warpRpcount = rpcount
			self.warpRaddcount = raddcount
			warpEngineResult = nil

			local boxData = LocalBox:getData( "localBoxWarpDatas" ) or {}
			-- boxData.adjustInfo

			if pcountErr or addcountErr or __config or ldata.initS or boxData.hasData then
				local rpdata = ReplayDataManager:getCurrLevelReplayDataCopyWithoutSectionData()
				local idstr = rpdata.idStr

				-- DcUtil:dcWarpEngine( data.levelId , pcount , rpcount , addcount , raddcount , idstr )

				local datalist = {}
				rpdata.pcount = pcount
				rpdata.rpcount = rpcount
				rpdata.addcount = addcount
				rpdata.raddcount = raddcount

				local tableStr = table.serialize( rpdata ) 

				table.insert( datalist , HeMathUtils:base64Encode(tableStr, string.len(tableStr)) )

				SyncManager.getInstance():addAfterSyncHttp( 
					"uploadReplay" , 
					{datas = datalist} , 
					nil , 
					{allowMergers = false} 
				)

				warp = {}
				warp.levelId = data.levelId
				if pcountErr or addcountErr then
					warp.pcount = pcount
					warp.rpcount = rpcount
					warp.addcount = addcount
					warp.raddcount = raddcount
				end
				if ldata.initS then
					warp.initS = ldata.initSValue
				end
				if __config then
					warp.hasTC = true
				end

				if boxData.ccerr then
					warp.ccerr = boxData.ccerr
				end

				if boxData.tar1 then
					warp.tar1 = boxData.tar1
				end

				if boxData.tar2 then
					warp.tar2 = boxData.tar2
				end

				if boxData.adjustInfo then
					warp.adjustInfo = boxData.adjustInfo
				end

				Localhost:setWarp( warp )

				if _G.isLocalDevelopMode and DiffAdjustQAToolManager:getToolsEnabled() then 
					local countStr = "pcount:" .. tostring(pcount) .. " rpcount:" .. tostring(rpcount) .. " addcount:" .. tostring(addcount) .. " raddcount:" .. tostring(raddcount)
					local info = "WARP ENGINE ~~~~~ " .. countStr
					DiffAdjustQAToolManager:print( 1 , info )
					RemoteDebug:uploadLogWithTag( "WARP" , info)
				end
			end
		end

		-- printx( 1 , "doWarp ++++++++++++++++++++++++++++++++++++++++++++++++   " , table.tostring(ldata) )
		if HeFileUtils:exists( ldataPath ) then 
			return HeFileUtils:removeFile( ldataPath )
		end
	end

	if datas.t == "startLevel" then
		slevel( datas )
	elseif datas.t == "passLevel" then
		plevel( datas )
	else
		doact( datas )
	end
end

local warpEngineCheckFlag = false
local warpEngineEnable = false

function Localhost:getWarpEngineEnable()
	return warpEngineEnable
end

function Localhost:warpEngine( datas )
	if datas then

		if not warpEngineCheckFlag then
			warpEngineEnable = MaintenanceManager:isEnabledInGroup( "WarpEngine" , "ON_B" , UserManager:getInstance():getUID() )
			warpEngineCheckFlag = true

			if not warpEngineEnable then
				local ldataPath = HeResPathUtils:getUserDataPath() .. "/" .. warpEngineLFN
				if HeFileUtils:exists( ldataPath ) then 
					return HeFileUtils:removeFile( ldataPath )
				end
			end
		end

		local __dowarp = function () 
							self:doWarp( datas )
						end
		if warpEngineEnable then
			pcall( __dowarp )
			-- __dowarp()
		end
	end
end

--http://svn.happyelements.net/repos/svndata2/animal/java/trunk/animal-service/src/main/java/com/happyelements/animal/delegate/impl/LevelDelegateImpl.java
function Localhost:startLevel(levelId, gameMode, itemList, energyBuff, gameLevelType, requestTime, videoPropList) -- qixi
	itemList = itemList or {}
	local user = UserService.getInstance().user
	local uid = user.uid

	local updateTime = user:getUpdateTime()
	local now = Localhost:time()
	if type(requestTime) ~= "number" then requestTime = now end
	if requestTime < updateTime or requestTime > now then
		return false, ZooErrorCode.LEVEL_INVALID_REQUEST_TIME
	end

	--not hide level
	gameLevelType = gameLevelType or LevelType:getLevelTypeByLevelId(levelId)
	if gameLevelType == GameLevelType.kMainLevel then
		local topLevelId = user:getTopLevelId()
		if not PublishActUtil:isGroundPublish() then 
			if levelId > topLevelId then
				return false, ZooErrorCode.LEVEL_ID_INVALID_START_LEVEL
			end
		end
	end

	--TODO: implements Rabbt mode.
	--On local server mode, we don not verify Stage Info.
	StageInfoLocalLogic:initStageInfo(uid, levelId, itemList)

	local success,err = UserLocalLogic:startLevel( uid, levelId, gameMode, itemList, energyBuff, requestTime, gameLevelType, videoPropList)

	-- if activityEntry then
	-- 	success,err = UserLocalLogic:startActivityLevel( uid, levelId, gameMode, itemList, energyBuff, requestTime, activityEntry) -- qixi
	-- else
	-- 	success,err = UserLocalLogic:startLevel( uid, levelId, gameMode, itemList, energyBuff, requestTime, activityEntry)
	-- end
	if success then
		local datas = {}
		datas.t = "startLevel"
		datas.uid = uid
		datas.levelId = levelId
		datas.itemList = table.clone( itemList )
		self:warpEngine( datas )
	end
	
	return success,err
end

function Localhost:passLevel(levelId, score, flashStar, stageTime, coinAmount, targetCount, opLog, gameLevelType, requestTime)
	--todo: check if user used item.
	local useItem = 0
	local user = UserService.getInstance().user
	local uid = user.uid

	local updateTime = user:getUpdateTime()
	local now = Localhost:time()
	if type(requestTime) ~= "number" then requestTime = now end
	if requestTime < updateTime or requestTime > now then
		return {}, false, ZooErrorCode.LEVEL_INVALID_REQUEST_TIME
	end

	--旧版逻辑：只有选择了前置道具或者获得了礼盒，然后均不用的情况下才是1，其他都打0
	--local stageInfo = StageInfoLocalLogic:clearStageInfo(uid)
	--if stageInfo and not stageInfo:isEmpty() then useItem = 1 end

	if StageInfoLocalLogic:hasUsePropInLevel(uid) then 
		useItem = 1
	end
	--StageInfoLocalLogic:clearStageInfo(uid)


	local rewardItems, success, err

	gameLevelType = gameLevelType or LevelType:getLevelTypeByLevelId(levelId)
	if _G.isLocalDevelopMode then printx(0, "passLevel : gameLevelType", gameLevelType) end
	if gameLevelType == GameLevelType.kQixi then
		rewardItems, success, err = UserLocalLogic:updateActivityLevelScore(levelId, score, flashStar, useItem, stageTime, coinAmount, targetCount, opLog, gameLevelType, requestTime)
	elseif gameLevelType == GameLevelType.kMainLevel then

		if flashStar == 0 then
			local currTopLevelId = UserManager:getInstance().user:getTopLevelId()
			if currTopLevelId == levelId then
				UserTagAutomationManager:getInstance():checkTagHasChanged( UserTagDCSource.kPassLevel )
			end
		end

		rewardItems, success, err = UserLocalLogic:updateScore(levelId, score, flashStar, useItem, stageTime, coinAmount, opLog, requestTime)

	elseif gameLevelType == GameLevelType.kHiddenLevel then
		rewardItems, success, err = UserLocalLogic:updateHideLevelScore(levelId, score, flashStar, useItem, stageTime, coinAmount, opLog, requestTime)
	elseif gameLevelType == GameLevelType.kDigWeekly then
		rewardItems, success, err = UserLocalLogic:updateDiggerMatchLevelScore(levelId, score, flashStar, useItem, stageTime, targetCount, coinAmount, opLog, requestTime)
	elseif gameLevelType == GameLevelType.kMayDay then
		rewardItems, success, err = UserLocalLogic:updateMaydayEndlessLevelScore(levelId, score, flashStar, useItem, stageTime, targetCount, coinAmount, opLog, requestTime)
	elseif gameLevelType == GameLevelType.kRabbitWeekly then
		rewardItems, success, err = UserLocalLogic:updateRabbitWeeklyLevelScore(levelId, score, flashStar, stageTime, coinAmount, targetCount, opLog, gameLevelType, requestTime)
	elseif gameLevelType == GameLevelType.kTaskForRecall then 
		rewardItems, success, err = UserLocalLogic:updateRecallTaskLevelScore(levelId, score, flashStar, useItem, stageTime, targetCount, coinAmount, opLog, requestTime)
	elseif gameLevelType == GameLevelType.kTaskForUnlockArea then 
		rewardItems, success, err = UserLocalLogic:updateTaskForUnlockArealevelScore(levelId, score, flashStar, useItem, stageTime, targetCount, coinAmount, opLog, requestTime)
	elseif gameLevelType == GameLevelType.kSummerWeekly then
		rewardItems, success, err = UserLocalLogic:updateRabbitWeeklyLevelScore(levelId, score, flashStar, stageTime, coinAmount, targetCount, opLog, gameLevelType, requestTime)
	elseif gameLevelType == GameLevelType.kWukong then
		rewardItems, success, err = UserLocalLogic:updateMaydayEndlessLevelScore(levelId, score, flashStar, useItem, stageTime, targetCount, coinAmount, opLog, requestTime)
	elseif gameLevelType == GameLevelType.kOlympicEndless or gameLevelType == GameLevelType.kMidAutumn2018 then
		rewardItems, success, err = UserLocalLogic:updateMaydayEndlessLevelScore(levelId, score, flashStar, useItem, stageTime, targetCount, coinAmount, opLog, requestTime)
    elseif gameLevelType == GameLevelType.kMoleWeekly then
		rewardItems, success, err = UserLocalLogic:updateMoleWeeklyLevelScore(levelId, score, flashStar, useItem, stageTime, targetCount, coinAmount, opLog, requestTime)
	elseif gameLevelType == GameLevelType.kSpring2019 then
        rewardItems, success, err = UserLocalLogic:updateSpring2019LevelScore(levelId, score, flashStar, useItem, stageTime, targetCount, coinAmount, opLog, requestTime)
    elseif gameLevelType == GameLevelType.kSpring2017 or gameLevelType == GameLevelType.kSpring2018 
		or gameLevelType == GameLevelType.kFourYears or gameLevelType == GameLevelType.kYuanxiao2017 
		or gameLevelType == GameLevelType.kSummerFish or gameLevelType == GameLevelType.kJamSperadLevel 
		then
		-- 没有奖励
		rewardItems, success, err = {}, true--UserLocalLogic:updateMaydayEndlessLevelScore(levelId, score, flashStar, useItem, stageTime, targetCount, coinAmount, opLog, requestTime)		
	else
		assert(false, 'level type not supported')
	end

	if success then
		local datas = {}
		datas.t = "passLevel"
		datas.uid = uid
		datas.levelId = levelId
		datas.score = score
		datas.flashStar = flashStar
		-- datas.opLog = opLog
		self:warpEngine( datas )
	end
	LocalBox:clearData( "localBoxWarpDatas" )

	return rewardItems, success, err
end

function Localhost:passLevelAFH(levelId, score, flashStar, stageTime, coinAmount, targetCount, opLog, gameLevelType, requestTime)
	local useItem = 0
	local user = UserService.getInstance().user
	local uid = user.uid

	local updateTime = user:getUpdateTime()
	local now = Localhost:time()
	if type(requestTime) ~= "number" then requestTime = now end
	if requestTime < updateTime or requestTime > now then
		return {}, false, ZooErrorCode.LEVEL_INVALID_REQUEST_TIME
	end

	if StageInfoLocalLogic:hasUsePropInLevel(uid) then 
		useItem = 1
	end

	local rewardItems, success, err

	gameLevelType = gameLevelType or LevelType:getLevelTypeByLevelId(levelId)
	if _G.isLocalDevelopMode then printx(0, "passLevel : gameLevelType", gameLevelType) end
	if gameLevelType == GameLevelType.kMainLevel then
		rewardItems, success, err = UserLocalLogic:updateScoreAFH(levelId, score, flashStar, useItem, stageTime, coinAmount, opLog, requestTime)
	else
		assert(false, 'level type illegal')
		rewardItems, success, err = {}, false	
	end

	return rewardItems, success, err
end

function Localhost:useProps( itemType, levelId, gameMode, param, itemList, requestTime,returnType,returnItemId,returnExpireTime )
	local user = UserService.getInstance().user
	local uid = user.uid
	
	local updateTime = user:getUpdateTime()
	local now = Localhost:time()
	if type(requestTime) ~= "number" then requestTime = now end
	if requestTime < updateTime or requestTime > now then
		return false, ZooErrorCode.LEVEL_INVALID_REQUEST_TIME
	end

	if itemList and #itemList < 1 then return true end
	for i,itemId in ipairs(itemList) do
		local propMeta = MetaManager.getInstance():getPropMeta(itemId)
		local unlock = propMeta and propMeta.unlock or 1
		if levelId > 0 and levelId < unlock then
			return false, ZooErrorCode.USE_PROP_LEVEL_ERROR
		end
	end

	if itemType == 1 then
		StageInfoLocalLogic:subTempProps( uid, itemList )
	end

	if itemType == 3 then
		local succeed, err = ItemLocalLogic:hasEnoughTimeProps(uid, itemList)
		if succeed then
			ItemLocalLogic:useTimeProps(uid, itemList)
		else
			return false, err
		end
	end
	
	if itemType == 2 then
		local consumes = {}
		for i,itemId in ipairs(itemList) do
			local consume = ConsumeItem.new(itemId, 1)
			table.insert(consumes, consume)
		end

		local succeed, err = ItemLocalLogic:hasConsumes(uid, consumes)
		if succeed then
			succeed, err = ItemLocalLogic:consumes(uid, consumes)
			if not succeed then return false, err end
		else return false, err end

		local rewards = {}
		local accelerateOnce = false
		for i,itemId in ipairs(itemList) do
			local propMeta = MetaManager.getInstance():getPropMeta(itemId)
			local metareward = propMeta and propMeta.reward or 0
			local propValue = propMeta and propMeta.value or 0

			if metareward == PropRewardType.PROP_REWARD_TYPE_COIN then
				table.insert(rewards, RewardItemRef.new(ItemConstans.ITEM_COIN, propValue))
			elseif metareward == PropRewardType.PROP_REWARD_TYPE_ENERGY then
				table.insert(rewards, RewardItemRef.new(ItemConstans.ITEM_ENERGY, propValue))
			elseif metareward == PropRewardType.PROP_REWARD_TYPE_MOVE then
				StageInfoLocalLogic:addBuyMove(uid, propValue)
			elseif metareward == PropRewardType.PROP_REWARD_TYPE_GOLD_BEAN then
				local bean = ItemConstans.ITEM_TYPE_PROP * ItemConstans.ITEM_TYPE_RANGE + ItemConstans.PROP_GOLD_BEAN
				table.insert(rewards, RewardItemRef.new(bean, propValue))
			elseif metareward == PropRewardType.PROP_REWARD_TYPE_ACCELERATE_FURIT then
				if _G.isLocalDevelopMode then printx(0, "TODO: implements fruits service") end
			elseif metareward == PropRewardType.PROP_REWARD_TYPE_ENERGY_PLUS then
				UserExtendsLocalLogic:extraEenrgy(uid, propMeta)
			elseif metareward == PropRewardType.PROP_REWARD_TYPE_NOT_CONSUME_ENERGY then
				UserExtendsLocalLogic:notConsumeEnergyBuff(uid, propValue)
			end
		end
		ItemLocalLogic:rewards( uid, rewards, requestTime )
	end

	if returnType and returnItemId then
		if returnType == UsePropsType.TEMP then
			StageInfoLocalLogic:addTempProps(uid,returnItemId)
		elseif returnType == UsePropsType.EXPIRE and returnExpireTime then
			ItemLocalLogic:addTimeProp(uid, returnItemId, 1, returnExpireTime)
		elseif returnType == UsePropsType.NORMAL then
			--只会返回道具 
			ItemLocalLogic:addProp(uid,returnItemId,1)
		end
	end

	local datas = {}
	datas.t = "useProps"
	datas.uid = uid
	datas.itemList = itemList
	datas.levelId = levelId
	self:warpEngine( datas )

	return true
end

function Localhost:openGiftBlocker( levelId, itemList )
	local user = UserService.getInstance().user
	local uid = user.uid
	StageInfoLocalLogic:openGiftBlocker(uid, levelId, itemList)
	return true
end

function Localhost:getPropsInGame(actId, levelId, itemIds)
	local user = UserService.getInstance().user
	if StageInfoLocalLogic:getPropsInGame(user.uid, levelId, itemIds) then
		for _, propId in pairs(itemIds) do
			UserManager.getInstance():addTimeProp(propId, 1)
			UserService.getInstance():addTimeProp(propId, 1)
			
			GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kStagePlay, propId, 1, DcSourceType.kDrop, levelId)
		end
		if LevelType:isSummerMatchLevel( levelId ) then
			SeasonWeeklyRaceManager:getInstance():onDropPropInGame()
		else
			local evtData = {actId=actId, levelId=levelId, itemIds=itemIds}
			GlobalEventDispatcher:getInstance():dispatchEvent(Event.new("activity.incDropPropCount", evtData))
		end
		return true
	end
	return false
end

--
-- sync service data ---------------------------------------------------------
--
function Localhost:sellProps( itemID, num )
	local user = UserService.getInstance().user
	local uid = user.uid
	local propMeta = MetaManager.getInstance():getPropMeta(itemId)
	if not propMeta then return false end
	local sellPrice = propMeta.sell or 0
	if sellPrice < 1 then return false end
	consume = ConsumeItem.new(itemID, num)
	local succeed, err = ItemLocalLogic:hasConsume(uid, consume)
	if succeed then succeed, err = ItemLocalLogic:consume(uid, consume) end
	local rewardItem = RewardItemRef.new(ItemConstans.ITEM_COIN, sellPrice * num)
	return ItemLocalLogic:rewards( uid, {rewardItem} )
end


function Localhost:mark()
	local uid = UserService.getInstance().user.uid
	local markNum = UserManager.getInstance().mark.markNum
	UserService.getInstance().mark.markNum = markNum
	UserService.getInstance().mark.markTime = UserManager.getInstance().mark.markTime

	local markMeta = MetaManager.getInstance():getMarkByNum(markNum)
	if markMeta then ItemLocalLogic:rewards(uid, markMeta.rewards) end --reward coin, etc.

	if NetworkConfig.writeLocalDataStorage then self:flushCurrentUserData()
	else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

	return true
end
function Localhost:buy(goodsId , num , moneyType , targetId)
	local uid = UserService.getInstance().user.uid
	local goodsMeta = MetaManager.getInstance():getGoodMeta(goodsId)
	if not goodsMeta then return false, ZooErrorCode.CONFIG_ERROR end
	if num <= 0 then return false, ZooErrorCode.INVALID_PARAMS end

	if moneyType == 1 then
		if goodsMeta.coin <= 0 then return false, ZooErrorCode.CONFIG_ERROR end
		
		local propId = goodsMeta.items[1].itemId
		local consume = ConsumeItem.new(ItemConstans.ITEM_COIN, goodsMeta.coin * num)
		local succeed, err = ItemLocalLogic:hasConsume(uid, consume)
		if succeed then
			succeed, err = ItemLocalLogic:consume(uid, consume)
			if not succeed then return false, err end
		else return false, err end
		StageInfoLocalLogic:addTempProps(uid, propId)
		return true
	elseif moneyType == 2 then
		local price = GoodsLocalLogic:getCash( uid, goodsMeta )
		if price <= 0 then return false, ZooErrorCode.CONFIG_ERROR end

		local consume = ConsumeItem.new(ItemConstans.ITEM_CASH, price * num)
		local succeed, err = ItemLocalLogic:hasConsume(uid, consume)
		if succeed then
			succeed, err = ItemLocalLogic:consume(uid, consume)
			if not succeed then return false, err end
		else return false, err end
		GoodsLocalLogic:deliverGoods(uid, goodsMeta, num, targetId)
		return true
	end
end
function Localhost:ingame( id, orderId, channel, ingameType, detail )
	return GoodsLocalLogic:ingame( id, orderId, channel, ingameType, detail )
end

function Localhost:getNewUserRewards(id)
	return UserLocalLogic:getNewUserRewards(id)
end

function Localhost:unlockLevelArea(unlockType, friendUids)
	if _G.isLocalDevelopMode then printx(0, "Localhost:unlockLevelArea", unlockType, friendUids) end
	local user = UserService:getInstance().user
	local topLevelId = user:getTopLevelId()
	local levelIds = {}
	for i = 1, topLevelId do
		levelIds[i] = UserService:getInstance():getUserScore(i)
	end
	local checkFailed = false
	if #levelIds < topLevelId then if _G.isLocalDevelopMode then printx(0, "length not enough", #levelIds) end checkFailed = true end
	if not checkFailed then
		for k, v in pairs(levelIds) do
			if v.star < 1 and JumpLevelManager:getLevelPawnNum(v.levelId) <= 0 then
				if _G.isLocalDevelopMode then printx(0, "star less than one", k) end
				checkFailed = true
				break
			end
		end
	end

	if checkFailed then return false, ZooErrorCode.UNLOCK_AREA_ERROR_NOT_ALL_NEED_LEVEL_PASSED end

	if unlockType == 1 then -- star
		LevelAreaLocalLogic:unlcokLevelAreaByStar()
	elseif unlockType == 2 then -- gold
		LevelAreaLocalLogic:unlcokLevelAreaByGold()
	elseif unlockType == 3 then -- request friend
		LevelAreaLocalLogic:unlcokLevelAreaBySendRequest(friendUids)
	elseif unlockType == 4 then -- by friend
		LevelAreaLocalLogic:unlcokLevelAreaByFriendUids(friendUids)
	elseif unlockType == 6 then -- by animalfriends
		LevelAreaLocalLogic:unlcokLevelAreaByAnimals()
	elseif unlockType == 7 then -- by tasklevel
		LevelAreaLocalLogic:unlcokLevelAreaByTaskLevel()
	end
	return true
end

function Localhost:clearLastLoginUserData()
	-- 对于uid不变，SK发生变化的账号（OPPO切换），UserData需要用以同步离线数据，因此不能删除
	-- local savedConfig = Localhost.getInstance():getLastLoginUserConfig()
	-- if savedConfig then
 --        Localhost.getInstance():deleteUserDataByUserID(tostring(savedConfig.uid)) 
 --    end
    Localhost.getInstance():deleteLastLoginUserConfig()
    --Localhost.getInstance():deleteGuideRecord()
    Localhost.getInstance():deleteMarkPriseRecord()
    Localhost.getInstance():deletePushRecord()
    Localhost.getInstance():deleteWeeklyMatchData()
    Localhost.getInstance():deleteRankRaceData()
    Localhost.getInstance():deleteUserMissionData()
    Localhost.getInstance():deleteLocalExtraData()
    LocalNotificationManager.getInstance():cancelAllAndroidNotification()

    CCUserDefault:sharedUserDefault():setStringForKey(getDeviceNameUserInput(), "")
    CCUserDefault:sharedUserDefault():setIntegerForKey("thisWeekNoSelectAccount",0)
    CCUserDefault:sharedUserDefault():flush()

    _G.kDeviceID = UdidUtil:revertUdid()
end

function Localhost:canShowLoginRewardTip()
	-- local guestCreateTime = tonumber(Localhost.getInstance():getGuestCreateTime())
 --    local day = MetaManager.getInstance().global.showLoginRewardTipDay or 0
 --    if guestCreateTime and 
	--         calcDateDiff(os.date("*t", os.time()), os.date("*t", guestCreateTime)) >= day then
 --        return true
 --    else
 --    	return false
 --    end
 	return true  --加强绑定优化之后，游客首次登陆就符合推送显示奖励的本地开关
end

function Localhost:readUnlockLocalInfo()
	local platform = UserManager.getInstance().platform
	local uid = UserManager.getInstance().uid or "12345"
	local fileKey = "unlockLocalInfo.ds"
	--local fileKey = "unlockLocalInfo_" .. tostring(platform) .. "_u_".. tostring(uid) .. ".ds"

	local localData = Localhost:readFromStorage(fileKey)
	if not localData then
		localData = {}
		localData.lastBindSnsType = nil
		localData.lastBindAreaId = nil
		localData.guideHandOn45 = false
	end

	return localData
end

function Localhost:saveUnlockLocalInfo(localData)
	local fileKey = "unlockLocalInfo.ds"

	if not localData then
		local filePath = fullPathOfLocalData.."/"..fileKey
		os.remove(filePath)
	else
		--local platform = UserManager.getInstance().platform
		--local uid = UserManager.getInstance().uid or "12345"
		--local fileKey = "unlockLocalInfo_" .. tostring(platform) .. "_u_".. tostring(uid) .. ".ds"
		Localhost:writeToStorage( localData , fileKey )
	end
end

function Localhost:readFileData(fileName)
	local uid = UserManager.getInstance().uid or "12345"
    local path = HeResPathUtils:getUserDataPath() .. "/" .. fileName .. uid
    local hFile, err = io.open(path, "r")
    local text
    local data = {}
    if hFile and not err then
        text = hFile:read("*a")
        io.close(hFile)
        if type(text) == "string" and string.len(text) > 2 then
            data = table.deserialize(text)
        end
    end
    return data or {}
end

function Localhost:writeToFile(fileName, data)
	local uid = UserManager.getInstance().uid or "12345"
    local path = HeResPathUtils:getUserDataPath() .. "/" .. fileName .. uid
    Localhost:safeWriteStringToFile(table.serialize(data), path)
end

function Localhost:readDataByFileNameAndKey(fileName, key, default)
	local data = Localhost:readFileData(fileName)
	if data[key] ~= nil then 
		return data[key]
	end

	return default
end

function Localhost:writeDataByFileNameAndKey(fileName, key, value)
	local data = Localhost:readFileData(fileName)
	data[key] = value
	Localhost:writeToFile(fileName, data)
end