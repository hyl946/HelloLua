require 'zoo.dc.DcValidate'
require "zoo.util.DcVersionManager"
require "zoo.config.NetworkConfig"

DcUtil = {}

local subAcTypes = {AcType.kInstall, AcType.kDnu, AcType.kUp, AcType.kActive, AcType.kReg, AcType.kAppInfo, AcType.kCancelDnu, AcType.kCancelReg}

local metaInfo = MetaInfo:getInstance()
local startTime = nil
local viralId = nil
local isNew = 0
local equipment = "nocrack"
local idfa = ""
local serialNumber = metaInfo:getDeviceSerialNumber()
local androidId = metaInfo:getUdid()
local platformName = StartupConfig:getInstance():getPlatformName()
local googleAid = ""
local subPlatform = nil;
local javaVersion = 0

local function getUdidRemainder(baseNum)
  local udid = MetaInfo:getInstance():getUdid()
  if udid then
    local subStr = string.sub(udid, -5)
    if subStr then
      local numUid = tonumber(subStr, 16) or 0
      return numUid % baseNum
    end
  end
  return 0
end

local function getServer()
	if StartupConfig:getInstance():getServer() ~= "0" then
		subPlatform = StartupConfig:getInstance():getServer()
	end
end
pcall(getServer)

local function getApkSource()
	if __ANDROID then
		local MainActivityHolder = luajava.bindClass("com.happyelements.android.MainActivityHolder")
		local ApplicationHelper = luajava.bindClass("com.happyelements.android.ApplicationHelper")
		local context = MainActivityHolder.ACTIVITY:getContext()
		if ApplicationHelper.getApkSource then
  			local comment = ApplicationHelper:getApkSource(context)
  			if comment then
  				subPlatform = HeDisplayUtil:urlEncode(comment)
			end
		end
		javaVersion = MainActivityHolder.ACTIVITY:getLatestModify()
	end
end
if not subPlatform then
	pcall(getApkSource)
end

local function getChinaMobileChannelId()
	if __ANDROID then
		local MainActivityHolder = luajava.bindClass("com.happyelements.android.MainActivityHolder")
		local IAPPayment = luajava.bindClass("com.happyelements.android.operatorpayment.iap.IAPPayment")
		local context = MainActivityHolder.ACTIVITY:getContext()
		if IAPPayment.loadChannelID then
			subPlatform = IAPPayment:loadChannelID(context)
		end
	end
end
if not subPlatform and (platformName == "cmccmm" or platformName == "cmccmm_js" or platformName == "cmccmm_zj") then
	pcall(getChinaMobileChannelId)
end

local function getValidSubPlatform(acType, subPlat)
	if string.len(subPlat) < 32 then
		return subPlat
	end

	if acType == 1 or acType == 2 then
		return subPlat
	end
	return nil
end

local function getStageState( levelId )

	-- DiffAdjustQAToolManager:print( 1 , "getStageState  levelId:" , levelId )

	if not levelId or levelId <= 0 then
		return -1
	end

	local userScore = UserService.getInstance():getUserScore( levelId )

	-- DiffAdjustQAToolManager:print( 1 , "getStageState  userScore:" , userScore )
	-- printx( 1 , "getStageState  ------------  levelId" , levelId, " userScore =" , userScore )
	-- printx( 1 , debug.traceback() )

	if LevelType:isMainLevel( levelId ) then
		if userScore == nil then
			return 0
		elseif userScore.star == 0 then
			return 1
		else
			return 2
		end
	elseif LevelType:isHideLevel( levelId ) then
		return 3
	else
		return 4
	end

	return -1
end

function DcUtil:tryGetStageState( levelId )
	local r = getStageState( levelId )
	-- DiffAdjustQAToolManager:print( 1 , "DcUtil:tryGetStageState  levelId:" , levelId , "r =" , r )
	-- printx( 1 , "DcUtil:tryGetStageState FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF " , r)
	return r
end

if __IOS then 
	idfa = AppController:getAdvertisingIdentifier() or "" 
end
if metaInfo:isJailbreak() then
	equipment = "crack"
end
if metaInfo:isNewInstalled() then
  isNew = 1
end

local function array2Table(arr)
	if arr then
		local result = {}
	  	local len = arr:size()
	  	for i = 1, len do
	    	result[#result + 1] = arr:get(i - 1)
	  	end
  		return result
  	end
  	return nil
end

local function getAppInfo()
	local appInfos = nil
	pcall(function()
			if __ANDROID then
				local ApplicationHelper = luajava.bindClass("com.happyelements.android.ApplicationHelper")
				if ApplicationHelper.getAppInfo then
		  			local array = ApplicationHelper:getAppInfo()
		  			appInfos =  array2Table(array);
				end
			end
		end)
	return appInfos
end

local function getRunningApp()
	local apps = nil
	pcall(function()
			if __ANDROID then
				local ApplicationHelper = luajava.bindClass("com.happyelements.android.ApplicationHelper")
				if ApplicationHelper.getRunningApp then
		  			apps = ApplicationHelper:getRunningApp()
				end
			end
		end)
	return apps
end

local function getAndroidMemory()
	local memory = 0
	pcall(function()
			if __ANDROID then
				local displayUtil = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")
				if displayUtil then
					memory = displayUtil:getSysMemory()
				end
			end
		end)
	return memory
end

-- percent: 0到100
local function isSample(percent)
	if isLocalDevelopMode then return true end
	local uuid = MetaInfo:getInstance():getUdid()
	local tail = string.sub(string.lower(uuid), -4)
	local tailInt = tonumber(tail, 16)
	local fullRange = math.pow(16, 4)
	local sampleRange = math.floor(fullRange * (percent / 100))
	if tailInt and type(tailInt) == "number" and tailInt <= sampleRange then
		return true
	else
		return false
	end
end

--存打点到本地文件，下次登录上传
local function saveLogToLocal( ... )
	if PrepackageUtil:isPreNoNetWork() then return end
	HeDCLog:getInstance():saveLogToLocal()
end

local kNeedNetworkTypeAcType = {1, 2, 9, 71, 72, 102, 103, 101}
local function dc_log_send(acType, data)
	if PrepackageUtil:isPreNoNetWork() or (__WIN32 and _G.launchCmds and _G.launchCmds.mcts) then return end
	
	data._src = "ct"
	data.utc_diff = __g_utcDiffSeconds or 0
	data.platform = platformName
	if UserManager and UserManager:hadInited() then
		if not table.indexOf(subAcTypes, acType) then
			data.level = UserManager:getInstance().user:getTopLevelId()
			data.star = UserManager:getInstance().user:getStar()
		end
		data.ogid = UserManager:getInstance():getUID()
		data.ai_flag = HEAICore and HEAICore:getUserGroupId() or 0
	end

	if subPlatform then
        local validSubPlatform = getValidSubPlatform(acType, subPlatform)
        if validSubPlatform then
		    data.sub_platform = validSubPlatform
        end
	end

	if GameBoardLogic then
		local currentLogic = GameBoardLogic:getCurrentLogic()
		-- 在弹出重玩面板时的打点不应带上本关的种子信息
		if currentLogic and not currentLogic.onReplayPanelShow then
			data.seed_value = LevelDifficultyAdjustManager:getAISeedValue()
			data.event_id = LevelDifficultyAdjustManager:getAIEventID()
			data.algorithm_tag = LevelDifficultyAdjustManager:getAIAlgorithmTag()

			if not LevelDifficultyAdjustManager:getAIColorProbs() then 
				local isAISpecial = false 
				if data.seed_value and (data.seed_value == -1 or data.seed_value == -2) then
					isAISpecial = true 
				end
				if currentLogic:difficultyAdjustActivated() then
					if isAISpecial then
						data.algorithm_tag = data.algorithm_tag and data.algorithm_tag..'_fuuu' or 'ai_err'
					else
						data.algorithm_tag = "offline-fuuu"
					end
				else
					if not isAISpecial then
						data.algorithm_tag = "offline"
					end
				end
			end
		end
	end

	if not data.networktype and table.exist(kNeedNetworkTypeAcType, acType) then
		require "zoo.util.NetworkUtil"
		data.networktype = NetworkUtil:getNetworkInfo()
		data.network_state = NetworkUtil:getNetworkStatus()
	end
	if acType == 101 then
		data.minor_version = ResourceLoader.getCurVersion()
		if LevelMapManager then
			data.level_config_md5 = LevelMapManager.getInstance():getLevelUpdateVersion()
		end

		if data.category == "payment" then
			data.playId = data.playId or GamePlayContext:getInstance():getIdStr()
		end
	end
	if acType == 102 then -- 暂定只在102号点增加该字段
		data.obtain_scene = UserContext and UserContext:getPlayLevelState() or "out_level"
	end

	--version may be nil
	data.version = DcVersionManager.getInstance():getVersion(acType, data.category, data.sub_category)

	table.each(data, function (v, k)
	if (type(v) ~= "string") then
		data[k] = tostring(v)
	end
	end)

	HeDCLog:getInstance():send(acType, data)
end

local function acquireDailyQuota(typo)
	local key = "AcType_k" ..tostring(typo)
	local ddata = Localhost:readLocalDailyData()
	if ddata[key] then return false end

	ddata[key] = 1
	Localhost:writeLocalDailyData(nil, ddata)
	return true
end

-- doSampling: 是否是概率打点（抽样） 概率10%
local function send(acType, data, doSampling)
	-- printx(11, "=======================================")
	-- printx(11, "===========  DcUtil:log  ==============")
	-- printx(11, "=======================================")
	-- printx(11, "acType", acType)
	-- printx(11, "doSampling", doSampling)
	-- printx(11, "data", table.tostringByKeyOrder(data))

	if not doSampling then
		doSampling = false
	end
	if data.sub_category and string.starts(data.sub_category, "G_") then
		if isSample(10) then
			dc_log_send(acType, data)
		else
			return
		end
	elseif doSampling then
		if isSample(10) then
			if data.sub_category then
				data.sub_category = 'G_'..data.sub_category
			end
			dc_log_send(acType, data)
		else
			return
		end
	else
		dc_log_send(acType, data)
	end
end

function DcUtil:getSubPlatform()
	return subPlatform
end

function DcUtil:getJavaVersion()
	return javaVersion
end

--激活打点
function DcUtil:install()
	if metaInfo:isNewInstalled() then
		send(AcType.kInstall, {
			equipment = equipment,
			install_key = metaInfo:getInstallKey(),
			category = "first_open",
			idfa = idfa,
			serial_number = serialNumber,
			android_id  = androidId,
			google_aid = googleAid,
			})
		if subPlatform then
			DcUtil:active(subPlatform)
		end
	end
end

--广告激活打点
function DcUtil:active(channel_id)
	send(AcType.kActive, {
		install_key = metaInfo:getInstallKey(),
		idfa = idfa,
		serial_number = serialNumber,
		android_id  = androidId,
		google_aid = googleAid,
		channel_id = channel_id,
		})
end

--广告注册打点
function DcUtil:reg(channel_id, isCancel)
	local data = {
		install_key = metaInfo:getInstallKey(),
		idfa = idfa,
		serial_number = serialNumber,
		android_id  = androidId,
		google_aid = googleAid,
		channel_id = channel_id,
	}
	if isCancel then 
		data.is_cancel = 1
		send(AcType.kCancelReg, data)
	else
		send(AcType.kReg, data)
	end
end

--新用户打点
function DcUtil:newUser(isCancel)
	if isCancel and not _G.dcNewUser then
		return
	end
	local data = {
		equipment = equipment,
		networktype = metaInfo:getNetworkInfo(),
		carrier = metaInfo:getNetOperatorName(),
		install_key = metaInfo:getInstallKey(),
		idfa = idfa,
		serial_number = serialNumber,
		android_id  = androidId,
		google_aid = googleAid,
		md5 = ResourceLoader.getCurVersion(),
		imei = metaInfo:getImei(),
		imsi = metaInfo:getImsi(),
		browser = metaInfo:getBrowserUserAgent(),
	}
	if isCancel then 
		data.is_cancel = 1
		_G.dcNewUser = false
		send(AcType.kCancelDnu, data)
	else
		_G.dcNewUser = true
		send(AcType.kDnu, data)
	end
	if subPlatform then
		DcUtil:reg(subPlatform, isCancel)
	end
end

--登陆打点
function DcUtil:dailyUser()
	local totalMemory = 0
	local cmOptimalType = nil
    local smsUdidRemainder = 0
    if __IOS then
		totalMemory = NSProcessInfo:processInfo():physicalMemory() or 0
    elseif __ANDROID then
    	totalMemory = getAndroidMemory()
    	cmOptimalType = AndroidPayment.getInstance().cmOptimalType
    	smsUdidRemainder = getUdidRemainder(100)
    end
    local operator = nil
    if __ANDROID then
    	operator = AndroidPayment.getInstance():getOperator()
    end

	totalMemory = math.floor(totalMemory / (1024 * 1024))

	local uid = UserManager:getInstance().user.uid or '12345'
	local key = 'last_login_time_'..tostring(uid)

	local data = {
		equipment = equipment,
		networktype = metaInfo:getNetworkInfo(),
		carrier = metaInfo:getNetOperatorName(),
		install_key = metaInfo:getInstallKey(),
		idfa = idfa,
		serial_number = serialNumber,
		android_id  = androidId,
		google_aid = googleAid,
		md5 = ResourceLoader.getCurVersion(),
		imei = metaInfo:getImei(),
		imsi = metaInfo:getImsi(),
		deviceMemory = totalMemory,
		iccid = metaInfo:getIccid(),
		last_login_time = CCUserDefault:sharedUserDefault():getStringForKey(key),
		cm_optimal = cmOptimalType,
		insideVersion = _G.getInsideVersion(),
		udid_remainder = smsUdidRemainder,
		operator = operator,
	}
	CCUserDefault:sharedUserDefault():setStringForKey(key, os.date("%Y-%m-%d %H:%M:%S", Localhost:timeInSec()))

	if _G.sns_token and _G.sns_token.openId then 
		local pfName = PlatformConfig:getPlatformAuthName()
		if pfName then
			data.sns_id = pfName .. "_" .. _G.sns_token.openId
		else
			data.sns_id = _G.sns_token.openId
		end
	end
	
	send(AcType.kDau,data)
end

function DcUtil:logLocation()
end

--ingame打点
function DcUtil:logInGame()
	if not acquireDailyQuota(AcType.kIngame) then return end
	local function getType(url)
		local isDefault, isSns, isCustomized = 1,2,3
        if not url then url = '' end
        if url == '' or tonumber(url) ~= nil then
            return isDefault
        elseif string.starts(url, 'http://animal-10001882.image.myqcloud.com/') then
            return isCustomized
        else
            return isSns
        end
    end
    local headUrl = ''
    local userMgr = UserManager:getInstance()
    if userMgr.profile then
    	headUrl = userMgr.profile.headUrl
    end
    local operator = nil
    if __ANDROID then
    	operator = AndroidPayment.getInstance():getOperator()
    end
    local loginDays = userMgr:getContinuousLogonDays()
    local user = userMgr.user

    local maxHiddenLevelId = LevelMapManager.getInstance():getMaxHiddenLevelId()
    local userScores = userMgr:getScoreRef()
    local hideLevelStars = {}
    -- 一次遍历，降低复杂度
    for i,v in ipairs(userScores) do
		if v.levelId > LevelConstans.HIDE_LEVEL_ID_START and v.levelId <= maxHiddenLevelId then
			hideLevelStars[v.levelId] = v.star
		end
	end
	local hideLevelStarsDc = ""
    for levelId = LevelConstans.HIDE_LEVEL_ID_START+1, maxHiddenLevelId do
    	local star = hideLevelStars[levelId] or 0
    	if star > 0 then
	    	hideLevelStarsDc = hideLevelStarsDc .. star
	    else
	    	local branchId = MetaModel:sharedInstance():getHiddenBranchIdByHiddenLevelId(levelId)
	    	if branchId and not MetaModel:sharedInstance():isHiddenBranchCanOpen( branchId ) then
	    		hideLevelStarsDc = hideLevelStarsDc .. 9 -- 未开放或解锁的关卡
	    	else
	    		hideLevelStarsDc = hideLevelStarsDc .. 0 -- 解锁但是没有过关的关卡
	    	end
	    end
    end
    hideLevelStars = nil

    local topPassedLevelId = userMgr:getTopPassedMainLevelId()
    local tophidestar = userMgr:getOpenedHiddenLevelStars()
    local normalTotalStar = LevelMapManager.getInstance():getTotalStar(_G.kMaxLevels)
	local hiddenTotalStar = (LevelMapManager.getInstance():getMaxHiddenLevelId() - LevelConstans.HIDE_LEVEL_ID_START) * 3
	send(AcType.kIngame, {
		is_new = isNew,
		happy_coin = user:getCash(),
		game_coin = user:getCoin(),
		energy = user:getEnergy(),
		hideStar = user:getHideStar(),
		hide_stage_state = hideLevelStarsDc,
		topstar = LevelMapManager.getInstance():getTotalStar(topPassedLevelId),
		tophidestar = tophidestar,
		totalstar = normalTotalStar + hiddenTotalStar,
		friend_num = #userMgr.friendIds,
		google_aid = googleAid,
		item_id_10011 = userMgr:getUserPropNumber(10011),
		item_id_10004 = userMgr:getUserPropNumber(10004),
		item_id_10001 = userMgr:getUserPropNumber(10001),
		item_id_10010 = userMgr:getUserPropNumber(10010),
		item_id_10012 = userMgr:getUserPropNumber(10012),
		item_id_10013 = userMgr:getUserPropNumber(10013),
		item_id_10014 = userMgr:getUserPropNumber(10014),
		item_id_10002 = userMgr:getUserPropNumber(10002),
		item_id_10003 = userMgr:getUserPropNumber(10003),
		item_id_10005 = userMgr:getUserPropNumber(10005),
		item_id_10007 = userMgr:getUserPropNumber(10007),
		item_id_10015 = userMgr:getUserPropNumber(10015),
		item_id_10018 = userMgr:getUserPropNumber(10018),
		item_id_10058 = userMgr:getUserTimePropNumber(10058),
		item_id_10059 = userMgr:getUserTimePropNumber(10059),
		item_id_10060 = userMgr:getUserTimePropNumber(10060),
		item_id_10061 = userMgr:getUserTimePropNumber(10061),
		item_id_10062 = userMgr:getUserTimePropNumber(10062),
		item_id_10063 = userMgr:getUserTimePropNumber(10063),
		itme_id_10064 = userMgr:getUserTimePropNumber(10064),
		item_id_10069 = userMgr:getUserTimePropNumber(10069),
		item_id_10070 = userMgr:getUserTimePropNumber(10070),
		itme_id_10071 = userMgr:getUserTimePropNumber(10071),
		itme_id_10078 = userMgr:getUserPropNumber(10078),
		itme_id_10079 = userMgr:getUserTimePropNumber(10079),
		itme_id_10091 = userMgr:getUserTimePropNumber(10091),
		itme_id_10092 = userMgr:getUserTimePropNumber(10092),
		itme_id_10093 = userMgr:getUserTimePropNumber(10093),

		tree_level = FruitTreePanelModel:sharedInstance():getTreeLevel(),
		level = user:getTopLevelId(),
		have_skip = #UserManager.getInstance():getJumpLevelInfo() > 0,
		avatar_type = getType(headUrl),
		operator = operator,
		login_days = loginDays,
		wifi_auto_state = require('zoo.data.WifiAutoDownloadManager'):getDcState(),
		asfHelpedCount = userMgr.subsTotalBeHelpedCount,
		asfLiveCount = #userMgr:getAskForHelpInfo(),
		achievement_progress = Achievement:getProgressString(),
		achievement_progress_real = Achievement:getProgressString(true),
		achievement_score = Achievement:getState().score,
		level_speed = GameSpeedManager:getGameSpeedSwitch(),
	})
end


function DcUtil:memoryWarning(warning)

	local memoryWarningEnabled = MaintenanceManager:getInstance():isEnabled("MemoryMonitoring", false)
	if(not(warning) and not(memoryWarningEnabled)) then 
		return
 	end


	local physicalMemory = 0
	local appUsedRam = 0
	local sysAvailableRam = 0
	local lowSystemMemory = 0
	if __IOS then
    	physicalMemory = NSProcessInfo:processInfo():physicalMemory() or 0
		physicalMemory = physicalMemory / (1024 * 1024)

		appUsedRam = AppController:getUsedMemory() / (1024)	-- MB
		sysAvailableRam = AppController:getTotalMemory()

	elseif __ANDROID then
		local disp = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")
		if(disp) then
	    	physicalMemory = disp:getSysMemory()
	 		physicalMemory = physicalMemory / (1024 * 1024)

			appUsedRam = disp:getAppUsedMemory() / (1024)	-- MB
			sysAvailableRam = physicalMemory

			if(disp:getSysLowMemory(0.5, 64)) then
				lowSystemMemory = 1
			end
		end
	else
	end

	local msg = {
		category = 'memoryMonitoring',
		deviceMemory = "" .. physicalMemory,
		availableMemory = "" .. sysAvailableRam,
		usedMemory = "" .. appUsedRam,
		luaMemory = "" .. (collectgarbage("count") / 1024),
		androidLowSystemMemory = "" .. lowSystemMemory,

	}

	if(warning) then
		msg.sub_category = "warning"
	else
		msg.sub_category = "monitoring"
	end
	send(AcType.kExpire30Days,msg)
end

function DcUtil:restoreHomeScene(tElapsed)
	-- local msg = {
	-- 	category = 'Performance',
	-- 	sub_category = "RestoreHomeScene",
	-- 	cost = tElapsed,

	-- }
	-- send(AcType.kUserTrack,msg)
end

--choose graphic quality
function DcUtil:startChooseGraphicQuality(where)
	local msg = {
		category = 'ImageQuality',
		sub_category = "start_imageQuality",
		where = where,

	}
	send(AcType.kUserTrack,msg)
end
function DcUtil:selectGraphicQuality(changed, quality)
	local msg = {
		category = 'ImageQuality',
		sub_category = "select_imageQuality",
		changed = changed,
		quality = quality,

	}
	send(AcType.kUserTrack,msg)
end
function DcUtil:restartSelectGraphicQuality(immediately)
	local msg = {
		category = 'ImageQuality',
		sub_category = "restart_imageQuality",
		immediately = immediately,

	}
	send(AcType.kUserTrack,msg)
end


--每五分钟调用一次
function DcUtil:online()
	send(AcType.kOnline, {
		equipment = equipment,
		networktype = metaInfo:getNetworkInfo(),
		})
end

--公司游戏内部推广
function DcUtil:promotion(category, channelId)
	send(AcType.kPromotion, {
		category = category,
		channel_id = channelId,
		idfa = idfa,
		})
end

--新手引导第step步完成
function DcUtil:tutorialStep(step)
	send(AcType.kTutorialStep, {
		step = step,
		})
end

--新手引导完成
function DcUtil:tutorialFinish()
	send(AcType.kTutorialFinish, {})
end

--加载转化打点
function DcUtil:up(step)
	if not startTime then
		startTime = os.time()
		viralId = metaInfo:getInstallKey() .. "_" .. startTime
	end

	send(AcType.kUp, {
		viral_id = viralId,
		step = step,
		is_new = isNew,
		interval = (os.time() - startTime) * 1000,
		install_key = metaInfo:getInstallKey(),
		}, true)
end

local function _logWrongCurrentStage(v)
	local function _log()
		if isSample(1) then
			if math.ceil(v) ~= v then
				local _trace = debug.traceback
				he_log_error('wrongcurrentstage:' .. toString(v) .. '\n' .. _trace)
			end
		end
	end
	pcall(_log)
end

--用户升级
function DcUtil:logLevelUp(level)
	send(AcType.kLevelUp, {
		lv1 = level - 1,
		lv2 = level,
		module = "level",
		source = "level",
		})
end

--首次闯关
function DcUtil:logFirstLevelGame(currentStage, stageMode, win, useItem, stageTime, gemCount)
	local result = 0;
	if win then
		result = 1;
	end
	send(AcType.kFirstLevel, {
		stage_first = "stage_first",
		result = result,
		current_stage = currentStage,
		meta_level_id = LevelMapManager.getInstance():getMetaLevelId(currentStage),
		stage_mode = stageMode,
		use_item = useItem,
		stage_time = stageTime,
		gem_count = gemCount,
		high_stage = UserManager:getInstance().user:getTopLevelId(),
		})
	_logWrongCurrentStage(currentStage)
end

--首次闯关前每次闯关
function DcUtil:logBeforeFirstWin(currentStage, stageMode, win, useItem, stageTime, gemCount)

	if UserService:isSyncingLocal() then
		return
	end

	local result = 0;
	if win then
		result = 1;
	end
	send(AcType.kBeforeWin, {
		stage_first = "stage_first",
		result = result,
		current_stage = currentStage,
		meta_level_id = LevelMapManager.getInstance():getMetaLevelId(currentStage),
		stage_mode = stageMode,
		use_item = useItem,
		stage_time = stageTime,
		gem_count = gemCount,
		high_stage = UserManager:getInstance().user:getTopLevelId(),
		})
	_logWrongCurrentStage(currentStage)
end

--fb newsfeed
function DcUtil:logSendNewsFeed(type,viral_id,src)
	send(AcType.kViralSend, {
		type = type,
		viral_id = viral_id,
		src = src,
		})
end

--fb sendRequest
function DcUtil:logSendRequest(type,viral_id,src)
	send(AcType.kViralSend, {
		type = type,
		viral_id = viral_id,
		src = src,
		})
end

--launcher from fb
function DcUtil:logViralActivate(type,viral_id,src)
	send(AcType.kViralActivate, {
		type = type,
		viral_id = viral_id,
		src = src,
		})
end

--开始关卡
-- ！！！：概率20%
function DcUtil:logStageStart(currentStage, totalPlayed, preItems, hasDropBuff)
	if isSample(20) then
		local hasPreItem = 0
		local preItemIds = nil
		if type(preItems) == "table" and #preItems > 0 then 
			hasPreItem = 1 
			preItemIds = table.concat(preItems, "_")
		end
		dc_log_send(AcType.kUserTrack, {
			category = 'stage',
			sub_category = 'stage_start',
			current_stage = currentStage,
			meta_level_id = LevelMapManager.getInstance():getMetaLevelId(currentStage),
			current_play = totalPlayed,
			pre_item = hasPreItem,
			pre_item_id = preItemIds,
			magical_drop = hasDropBuff,
			playId = GamePlayContext:getInstance():getIdStr(),
			})
	end
	_logWrongCurrentStage(currentStage)
end

--中途退出关卡
function DcUtil:logStageQuit(currentStage, score, star, isRestart, stageTime, leftMoves , useItem , stageState , failCount1 , failCount2 , failCountHistoryMax)
	local dcDatas = DcUtil:buildStageEndDcData( "stage_quit" , currentStage, score, star, 0, stageTime, leftMoves , useItem , stageState , failCount1 , failCount2 , failCountHistoryMax)
	dcDatas.category = "stage"
	dcDatas.sub_category = "stage_quit"
	dcDatas.restart_level = isRestart
	send(AcType.kUserTrack, dcDatas)
end

--结束关卡
function DcUtil:logStageEnd(currentStage, score, star, failReason, stageTime, leftMoves , useItem , stageState , failCount1 , failCount2 , failCountHistoryMax, originTotalTargetCount, targetCount)
	local dcDatas = DcUtil:buildStageEndDcData( "stage_end" , currentStage, score, star, failReason, stageTime, leftMoves , useItem , stageState , failCount1 , failCount2 , failCountHistoryMax, originTotalTargetCount, targetCount)
	dcDatas.category = "stage"
	dcDatas.sub_category = "stage_end"

	if StarBank then
		dcDatas.star_bank_state = StarBank.state
		dcDatas.star_bank_id = StarBank.triggerUniqueId
		dcDatas.saved_coins = StarBank.curWm
	end

	send(AcType.kUserTrack, dcDatas)
end

--好友代打中途退出关卡
function DcUtil:logFriendHelpStageQuit(currentStage, score, star, isRestart, stageTime, leftMoves , useItem , stageState , failCount1 , failCount2 , failCountHistoryMax , helpedUid)
	local dcDatas = DcUtil:buildStageEndDcData( "friend_help_stage_quit" , currentStage, score, star, 0, stageTime, leftMoves , useItem , stageState , failCount1 , failCount2 , failCountHistoryMax)
	dcDatas.category = "stage"
	dcDatas.sub_category = "stage_quit"
	dcDatas.restart_level = isRestart
	dcDatas.helpedUid = helpedUid
	send(AcType.kUserTrack, dcDatas)
end

--好友代打结束关卡
function DcUtil:logFriendHelpStageEnd(currentStage, score, star, failReason, stageTime, leftMoves , useItem , stageState , failCount1 , failCount2 , failCountHistoryMax, helpedUid)
	
	local dcDatas = DcUtil:buildStageEndDcData( "friend_help_stage_end" , 
		currentStage, score, star, failReason, stageTime, leftMoves , useItem , stageState , failCount1 , failCount2 , failCountHistoryMax, originTotalTargetCount, targetCount)
	dcDatas.category = "stage"
	dcDatas.sub_category = "stage_end"
	dcDatas.helpedUid = helpedUid

	send(AcType.kUserTrack, dcDatas)
end

function DcUtil:buildStageEndDcData( dcType , currentStage, score, star, failReason, stageTime, leftMoves , useItem , stageState , failCount1 , failCount2 , failCountHistoryMax, originTotalTargetCount, targetCount)
	stageTime = stageTime or 0

	local playContext = GamePlayContext:getInstance()
	local result = playContext.levelInfo.lastPlayResult

	local missionId = nil
	if MissionManager then
		local missionIds = MissionManager:getInstance():getMissionIdOnLevel(currentStage)

		if missionIds and #missionIds > 0 then
			missionId = missionIds[1]
		end
	end

	-- local high_stage = UserManager:getInstance():getUserRef():getRealTopLevelId()
	local high_stage = UserManager:getInstance():getUserRef():getTopLevelId()
	local userId = UserManager.getInstance().uid
	local totalPlayed = FUUUManager:getLevelTotalPlayed(currentStage)

	local usedProps = 0
	local usedPropLogStr = nil
	local stepProgressLogStr = nil

	StageInfoLocalLogic:addStepProgressData( userId )

	
	local newTotalStar = UserManager:getInstance():getUserRef():getTotalStar()
	local oldTotalStar = playContext.userInfo.totalTrunkStar + playContext.userInfo.totalHideStar

	local oldStar = playContext.levelInfo.oldStar
	if playContext.levelInfo.scoreRefIsNil then
		oldStar = -1
	end

	local stageInfo = StageInfoLocalLogic:getStageInfo( userId )
	if stageInfo then
		if type(stageInfo.stepProgressDataList) == "table" and #stageInfo.stepProgressDataList > 0 then

			stepProgressLogStr = ""
			for i, v in ipairs(stageInfo.stepProgressDataList) do

				local stepProgress = v

				local str = string.format("%s_%s_%s", stepProgress.idx , stepProgress.theCurMoves , stepProgress.progressStr or "")
				if i == 1 then
					stepProgressLogStr = str
				else
					stepProgressLogStr = stepProgressLogStr..";"..str
				end
			end

		end

		if type(stageInfo.propLogForDc) == "table" and #stageInfo.propLogForDc > 0 then
			
			usedProps = 1
			usedPropLogStr = ""
			for i, v in ipairs(stageInfo.propLogForDc) do

				local usePropLogData = v

				local str = string.format("%s_%s_%s", usePropLogData.idx , usePropLogData.theCurMoves , usePropLogData.propId or "")
				if i == 1 then
					usedPropLogStr = str
				else
					usedPropLogStr = usedPropLogStr..";"..str
				end
			end

		end

	end
	local addFiveUse = nil
	local orderComplete = nil
	local realCostMove = -1
	local boardLogic = GameBoardLogic:getCurrentLogic()
	if stageInfo then
		if type(stageInfo.addFiveLogForDc) == "table" and #stageInfo.addFiveLogForDc > 0 then
			addFiveUse = table.concat(stageInfo.addFiveLogForDc, ",")
		end
		if boardLogic then
			local levelTargetPanel = boardLogic.PlayUIDelegate and boardLogic.PlayUIDelegate.levelTargetPanel
			
			--[[
			if levelTargetPanel and levelTargetPanel:getNumberOfTargets() > 0 then
				local logDatas = {}
				local targetsData = stageInfo.targetsData
				for i = 1, levelTargetPanel:getNumberOfTargets() do
					local item = levelTargetPanel["c"..i]
					local targetsData = stageInfo.targetsData or {}
					if item and targetsData[i] then
						local leftNum = tonumber(item.itemNum) or 0
						local totalNum = targetsData[i].tNum or 0
						if totalNum > 0 then
							table.insert(logDatas, math.floor((totalNum - leftNum) * 100 / totalNum))
						end
					end
				end
				orderComplete = table.concat(logDatas, "_")
			end
			]]
			realCostMove = boardLogic.realCostMove or -1
		end
	end

	local targetCount2 = nil
	if targetCount and LevelType:isMoleWeekLevel( currentStage ) then
		local vals = string.split(targetCount, ",")
		targetCount = vals[1]
		targetCount2 = vals[2]
	end

	local usedItems = stageInfo and stageInfo.propLogForDc
	local levelSeed = 0
	local vseedStr = nil
	local colorFuuuResult = false
	local stageStartTime = nil
	
	if boardLogic then
		stageStartTime = boardLogic.stageStartTime
		levelSeed = boardLogic.randomSeed

		local b1 = false
		local b2 = false
		if boardLogic.initAdjustData then
			vseedStr = GameInitDiffChangeLogic:createVirtualSeedDataStr( boardLogic.initAdjustData )
			b1 = true
		end

		if boardLogic.difficultyAdjustData 
			and boardLogic.difficultyAdjustData.mode == ProductItemDiffChangeMode.kAIAddColor then
			b2 = true
		end

		if b1 or b2 then
			colorFuuuResult = true
		end
	end

	local isResumeLevel = false
	local replayData = ReplayDataManager:getCurrLevelReplayData()
	if replayData and ( replayData.isResumeReplay or replayData.isSectionResumeReplay ) then
		isResumeLevel = true
	end

	local strategyID = LevelDifficultyAdjustManager:getStrategyIDListByDCString()
	local strategyReason = LevelDifficultyAdjustManager:getStrategyDataListByDCString()
	local userInterference = false
	if (strategyID and strategyID ~= "") then userInterference = true end
	local tutorialLevel = false
	if boardLogic and boardLogic.useGuideRandomSeed then
		tutorialLevel = true
	end

	local originScore = -999999999
	local originStar = -1
	if boardLogic then
		originScore = boardLogic.oringinTotalScore
		local _levelMeta = LevelMapManager:getMeta( currentStage )
		if _levelMeta then
			originStar = _levelMeta:getStar( originScore )
		end
	end

	-- if dcType == "stage_end" and star > 0 then
	-- 	local dcTestDatas = {
	-- 		current_stage = currentStage,
	-- 		meta_level_id = LevelMapManager.getInstance():getMetaLevelId(currentStage),
	-- 		originScore = originScore , 
	-- 		originStar = originStar ,
	-- 		fixedScore = score,
	-- 		fixedStar = star,
	-- 	}

	-- 	dcTestDatas.category = "stage"
	-- 	dcTestDatas.sub_category = "stage_passed"
	-- 	send(AcType.kExpire30Days, dcTestDatas)
	-- end

	local tmp = _G.kUserLocationUpdateData or {}
	local tmpLocation= UserManager:getInstance():getUserLocation() or {}

	if stageTime and stageTime < 0 then
		stageTime = 0
	end

	--
--


	local failCountBeaforPassLevel = -1
	if currentStage == GamePlayContext:getInstance().levelInfo.currTopLevelId then
		failCountBeaforPassLevel = GamePlayContext:getInstance().levelInfo.currTopLevelFailCount

		if result then
			failCountBeaforPassLevel = failCountBeaforPassLevel - 1
		end
	end

	local costStepsSeq, leftStepsSeq, interveneSeqUsed, repeatSeq = LevelDifficultyAdjustManager:getDcAIInterveneInfo()
	
	local fuuuOverView = "none"
	local fuuuAverageValue = -1

	if strategyID then
		local strategyData = LevelDifficultyAdjustManager:getStrategyReplayDataByStrategyID( 
															LevelDifficultyAdjustManager:getCurrStrategyID() 
															)
		if strategyData and strategyData.mode >= 4 and strategyData.mode <= 5 then
			fuuuOverView = GamePlayContext:getInstance():getFuuuOverviewDcStr() or "none"
			fuuuAverageValue = GamePlayContext:getInstance():getFuuuOverviewAvg() or -1
		end
	end
	
	local dcDatas = {
		result = result ,
		current_stage = currentStage,
		-- current_play = totalPlayed, 废弃，由 total_count 替代
		meta_level_id = LevelMapManager.getInstance():getMetaLevelId(currentStage),
		score = score,
		level_star = star,
		originScore = originScore , 
		originStar = originStar ,
		
		new_star = star ,
		old_star = oldStar ,
		new_total_star = newTotalStar ,
		old_total_star = oldTotalStar ,
		
		fail_reason = failReason,
		stage_time = math.ceil(stageTime),
		mission_id = missionId,
		t1 = currentStage,
		left_moves = leftMoves or 0,
		useItem = useItem,
		use_item = usedProps,
		--target_num = orderComplete,
		effects_num = nil,
		supplement_item = addFiveUse,
		--item_state = usedPropIds,
		stage_state = stageState,
		
		stage_mode = DcDataHelper:getStageModeByLevelId( currentStage ),
		play_type = playContext.levelInfo.playType,
		level_type = playContext.levelInfo.levelType,
		
		skiped_stage = playContext:getData("isJumpedLevelWhenStart") ,
		helped_stage = playContext:getData("isHelpedLevelWhenStart") ,
		energy_level = playContext.userInfo.energy ,
		max_energy_level = playContext.userInfo.maxEnergy ,
		
		location_province = tmpLocation.province ,
		location_city = tmpLocation.city ,
		location_district = tmpLocation.district ,
		
		-- stage_state = getStageState(currentStage),
		high_stage = high_stage,

		-- sum = failCount1,
		sum2 = failCount2, -- 这个字段是仅前端维护的首次过关前失败次数，每一关都有值
		-- sum3 = failCountHistoryMax,
		-- sum4 = failCountsVer4,
		fail_count = failCountBeaforPassLevel , -- 这个字段是前后端一起维护的首次过关前失败次数，且只有在topLevel关有值
		cont_fail_count = FUUUManager:getLevelContinuousFailNum(currentStage) , --开发中，要改为前后端一起维护
		start_level_total_count = FUUUManager:getLevelTotalPlayed(currentStage) , --开发中，要改为前后端一起维护
		end_level_total_count = ( GamePlayContext:getInstance():getTotalEndLevelCount() or 0 ) + 1 , --取值时，EndLevelCount还没有+1，所以要手动+1

		totalTarget = originTotalTargetCount,
		addTarget = targetCount,
		addTarget2 = targetCount2,
		playId = playContext:getIdStr(),
		playInfo = playContext:getPlayInfoDCStr(),
		seed = levelSeed,
		VirtualMode = vseedStr,
		realCostMove = realCostMove,
		stepTargetProgress = stepProgressLogStr,
		usePropLog = usedPropLogStr,
		colorFuuuResult = colorFuuuResult ,
		replayModeWhenStart = playContext.replayModeWhenStart ,

		strategyID = strategyID ,
		strategyReason = strategyReason ,
		strategyUnactivateReason = LevelDifficultyAdjustManager:getLastUnactivateReason() ,
		tagInfo = UserTagModel:getInstance():encodeTagToString() ,
		tagValueInfo = UserTagModel:getInstance():encodeTagToString(true) ,
		isResumeLevel = isResumeLevel ,
		-- AI seed logging
		stage_start_time = stageStartTime,
		stage_end_time = Localhost:timeInSec(),
		user_interference = userInterference,
		tutorial_level = tutorialLevel,

		cost_steps_seq = costStepsSeq,
		left_steps_seq = leftStepsSeq, 
		intervene_seq_used = interveneSeqUsed,  
		repeat_seq = repeatSeq,

		fuuu_overview = fuuuOverView,
		fuuu_average = fuuuAverageValue,

		intervene_seq_rec = LevelDifficultyAdjustManager:getDcAIColorProbsRec(),
		play_id_create_time = GamePlayContext:getInstance().preStartContext and GamePlayContext:getInstance().preStartContext.playIdCreateTime,
		ai_seed_first_get_time = GamePlayContext:getInstance().aiSeedFirstGetTime,
	}
	-- DiffAdjustQAToolManager:print( 1 , "DcUtil:stage_end 1 " , tostring(dcDatas.strategyID) , "2" , tostring(dcDatas.strategyReason) , "3" , tostring(dcDatas.strategyUnactivateReason) )
	_logWrongCurrentStage(currentStage)

	--[[
	local playinfo = GamePlayContext:getInstance():getPlayInfoDCObj()
	if playinfo then
		for k,v in pairs(playinfo) do
			dcDatas[k] = v
		end
	end
	]]
	--printx(1 , "DC  Stage End -------------------------------------  " , table.tostring(dcDatas))
	return dcDatas
end

--支付限额相关 支付完成后 客户端的 支付类型id 当前日限额 当前月限额数据 当前购买的数量 读取到的最大日限额 读取到的最大月限额 
function DcUtil:paymentLimitBuyComplete( paymentType,daily, monthly, price  , daily_Max , monthly_Max  )

	local dcData = {
			category = 'jslog',
			sub_category = 'limitbuycomp',
			paymentType = paymentType ,
			daily=daily, 
			monthly=monthly,
			price=price,
			daily_Max=daily_Max ,
			monthly_Max=monthly_Max,
			imsiid = MetaInfo:getInstance():getImsi(),
		}
	send(AcType.kExpire30Days, dcData)

end

function DcUtil:logOpLog(levelId, score, stageTime, targetCount, opLog)

	local opLogStr = nil

	if opLog then

		if type(opLog) == "table" then

			local str_json = table.serialize(opLog)
			printx( 1 , "DcUtil:logOpLog  str_json len =" , string.len(str_json)  )
			--[[
			local str_base64 = HeMathUtils:base64Encode(str_json, string.len(str_json))
			printx( 1 , "DcUtil:logOpLog  str_base64 len =" , string.len(str_base64)  )


			local str_amf = amf3.encode( opLog )
			printx( 1 , "DcUtil:logOpLog  str_amf len =" , string.len(str_amf)  )
			local str_amf_base64 = mime.b64(str_amf)
			printx( 1 , "DcUtil:logOpLog  str_amf_base64 len =" , string.len(str_amf_base64)  )

			local str_json_amf = amf3.encode( str_json )
			printx( 1 , "DcUtil:logOpLog  str_json_amf len =" , string.len(str_json_amf)  )
			local str_json_amf_base64 = mime.b64(str_json_amf)
			printx( 1 , "DcUtil:logOpLog  str_json_amf_base64 len =" , string.len(str_json_amf_base64)  )

			local str_zip = compress(str_json)
			printx( 1 , "DcUtil:logOpLog  str_zip len =" , string.len(str_zip)  )
			]]
			opLogStr = str_zip

		elseif type(opLog) == "string" then
			opLogStr = HeMathUtils:base64Encode(opLog, string.len(opLog))
		end
	end

	local dcData = {
			category = 'oplog',
			sub_category = 'passlevel',
			levelId=levelId, 
			meta_level_id = LevelMapManager.getInstance():getMetaLevelId(levelId),
			score=score, 
			stageTime=stageTime,
			targetCount=targetCount,
			opLog = opLogStr,
			curMd5 = ResourceLoader.getCurVersion(), 	-- game version
			curConfigMd5 = LevelMapManager.getInstance():getLevelUpdateVersion(), -- level update version
		}
	send(AcType.kExpire30Days, dcData)
end

--新增记录用户主动退出
function DcUtil:newLogUserStageQuit(dcData)
	send(AcType.kFuuu, dcData)
end

--微信发送邀请码
function DcUtil:sendInvitation(invitecode)
	send(AcType.kUserTrack, {
		category = 'wechat',
		sub_category = 'invite',
		invite_code = invitecode
		})
end

--微信过关分享
function DcUtil:shareFeed(source_item,currentStage,share_feed)
	send(AcType.kUserTrack, {
		category = 'wechat',
		sub_category = 'share',
		source = source_item,
		current_stage = currentStage,
		meta_level_id = LevelMapManager.getInstance():getMetaLevelId(currentStage),
		feed = share_feed,
		})
	_logWrongCurrentStage(currentStage)
end

--发送加好友请求
function DcUtil:sendInviteRequest(invitecode)
	send(AcType.kUserTrack, {
		category = 'request',
		sub_category = 'invite',
		invite_code = invitecode,
		})
end


--发送请求向好友索要精力
function DcUtil:requestEnergy(friendId,currentStage)
	send(AcType.kUserTrack, {
		category = 'request',
		sub_category = 'energy_ask',
		friend_Id = friendId,
		current_stage = currentStage,
		meta_level_id = LevelMapManager.getInstance():getMetaLevelId(currentStage),
		}, true)
	_logWrongCurrentStage(currentStage)
end

--发送邀请解锁云
function DcUtil:requestUnLockCloud(lockCloudId,friendId)
	send(AcType.kUserTrack, {
		category = 'request',
		sub_category = 'unLockCloud',
		lockCloudId = lockCloudId,
		friend_Id = friendId,
		}, true)
end

--接受加好友的邀请
function DcUtil:confirmInvite(friendId)
	send(AcType.kUserTrack, {
		category = 'messageCenter',
		sub_category = 'inviteConfirm',
		friend_Id = friendId,
		})
end

--接受好友精力请求，给好友精力
function DcUtil:energyGive(friendId,itemId)
	send(AcType.kUserTrack, {
		category = 'messageCenter',
		sub_category = 'energy_give',
		friend_Id = friendId,
		item_Id = itemId,
		}, true)
end

--回赠好友精力
function DcUtil:energySendBack(friendId,itemId)
	send(AcType.kUserTrack, {
		category = 'messageCenter',
		sub_category = 'energy_sendBack',
		friend_Id = friendId,
		item_Id = itemId,
		}, true)
end

--确认接受好友赠送精力
function DcUtil:energy_receive(friendId,itemId)
	send(AcType.kUserTrack, {
		category = 'messageCenter',
		sub_category = 'energy_receive',
		friend_Id = friendId,
		item_Id = itemId,
		}, true)
end

--删除好友
function DcUtil:delete(friendId)
	send(AcType.kUserTrack, {
		category = 'messageCenter',
		sub_category = 'delete',
		friend_Id = friendId,
		})
end

--豌豆荚点击邀请
function DcUtil:wdjClick()
	send(AcType.kUserTrack, {
		category = 'wandoujia',
		sub_category = 'click',
		})
end

--豌豆荚邀请完成
function DcUtil:wdjInvite(inviteCount)
	send(AcType.kUserTrack, {
		category = 'wandoujia',
		sub_category = 'invite',
		invite_count = inviteCount,
		})
end

--通过豌豆荚邀请进入
function DcUtil:wdjEnter()
	send(AcType.kUserTrack, {
		category = 'wandoujia',
		sub_category = 'enter',
		})
end


--查找附近的人
function DcUtil:addFriendSearch(itemNum)
	send(AcType.kUserTrack,{
		category = 'add_friend',
		sub_category = 'search',
		item_num = itemNum,
		}, true)
end

--发送添加好友请求
function DcUtil:addFiendNear()
	send(AcType.kUserTrack,{
		category = 'add_friend',
		sub_category = 'add_near',
		}, true)
end

-- 摇一摇
function DcUtil:addFriendShake(itemNum)
	send(AcType.kUserTrack,{
		category = 'add_friend',
		sub_category = 'shake',
		item_num = itemNum,
		}, true)
end

-- 摇一摇好友的申请
function DcUtil:addFriendShakeNear()
	send(AcType.kUserTrack,{
		category = 'add_friend',
		sub_category = 'add_shake',
		}, true)
end

-- 摇一摇两个人互相加为好友
function DcUtil:addFriendShakeConfirm()
	send(AcType.kUserTrack,{
		category = 'add_friend',
		sub_category = 'confim_shake',
		}, true)
end

-- 摇一摇取消重试
function DcUtil:addFriendShakeCancel()
	send(AcType.kUserTrack,{
		category = 'add_friend',
		sub_category = 'cancel_shake',
		}, true)
end

-- 二维码加好友
function DcUtil:addFriendQRCode(type)
	send(AcType.kUserTrack, {
		category = "add_friend",
		sub_category = "add_friend_qrcode",
		type= type,
		}, true)
end

-- 二维码发送到微信（Mitalk）成功
function DcUtil:qrCodeSendToWechatTapped()
	send(AcType.kUserTrack, {
		category = "add_friend",
		sub_category = "add_friend_qrcode_click_send",
		}, true)
end

-- 点击扫码按钮
function DcUtil:qrCodeClickScan()
	send(AcType.kUserTrack, {
		category = "add_friend",
		sub_category = "add_friend_qrcode_click_scan",
		})
end

-- 活动打点
function DcUtil:UserTrack(data, doSampling)
	send(AcType.kUserTrack,data, doSampling)
end
function DcUtil:UserTrackWithType(data, type, doSampling)
	send(type,data, doSampling)
end

function DcUtil:openCanonPromoPanel()
	send(AcType.kUserTrack,{
		category = 'activity',
		sub_category = 'click_prom_warrior_banner',
		})
end

function DcUtil:clickCanonDownload()
	send(AcType.kUserTrack,{
		category = 'activity',
		sub_category = 'click_download_warrior',
		})
end

function DcUtil:getCanonReward(id)
	send(AcType.kUserTrack,{
		category = 'activity',
		sub_category = 'get_prom_warrior_reward',
		reward_id = id,
		})
end

function DcUtil:weeklyRaceClick(id)
	send(AcType.kUserTrack,{
		category = 'weeklyrace',
		sub_category = 'click_weekly_race_icon',
		icon_id = id,
		})
end

function DcUtil:weeklyRaceBegin()
	send(AcType.kUserTrack,{
		category = 'weeklyrace',
		sub_category = 'click_weekly_race_begin_btn'
		})
end

function DcUtil:weeklyRaceInfo(id)
	send(AcType.kUserTrack,{
		category = 'weeklyrace',
		sub_category = 'click_weekly_race_info',
		info_id = id,
		})
end

function DcUtil:weeklyRaceExceedReward()
	send(AcType.kUserTrack,{
		category = 'weeklyrace',
		sub_category = 'get_weekly_race_exceed_reward'
		})
end

function DcUtil:weeklyRaceGemReward()
	send(AcType.kUserTrack,{
		category = 'weeklyrace',
		sub_category = 'get_weekly_race_gem_reward'
		})
end

function DcUtil:weeklyRaceExchangeBtn(id)
		send(AcType.kUserTrack,{
		category = 'weeklyrace',
		sub_category = 'click_weekly_race_exchange_btn',
		click_place = id
		})
end

function DcUtil:weeklyRaceExchangeReward(id)
		send(AcType.kUserTrack,{
		category = 'weeklyrace',
		sub_category = 'get_weekly_race_exchange_reward',
		exchange_id = id
		})
end

function DcUtil:fruitPick(fruitType, fruitLevel, treeLevel)
	send(AcType.kUserTrack,{
		category = 'fruittree',
		sub_category = 'get_fruit',
		fruit_type = fruitType,
		fruit_level = fruitLevel,
		tree_level = treeLevel
		}, true)
end

function DcUtil:fruitRegenerate(fruitType, fruitLevel, treeLevel)
	send(AcType.kUserTrack,{
		category = 'fruittree',
		sub_category = 'drop_fruit',
		fruit_type = fruitType,
		fruit_level = fruitLevel,
		tree_level = treeLevel
		}, true)
end

function DcUtil:fruitSpeed(count, fruitType, fruitLevel, treeLevel)
	send(AcType.kUserTrack,{
		category = 'fruittree',
		sub_category = 'speed_up',
		fruit_type = fruitType,
		fruit_level = fruitLevel,
		tree_level = treeLevel,
		item_num = count
		}, true)
end

function DcUtil:fruitTreeUpgrade(treeLevel , fruit_type , count)
	if not fruit_type then
		fruit_type = 0
	end

	send(AcType.kUserTrack,{
		category = 'fruittree',
		sub_category = 'upgrade_tree',
		tree_level = treeLevel ,
		fruit_type = fruit_type,
		item_num = count
		}, true)
end

function DcUtil:openMeilukePromoPanel()
	send(AcType.kUserTrack,{
		category = 'activity',
		sub_category = 'click_prom_meiluke_banner',
		})
end

function DcUtil:clickMeilukeDownload()
	send(AcType.kUserTrack,{
		category = 'activity',
		sub_category = 'click_download_meiluke',
		})
end

function DcUtil:getMeilukeReward(id)
	send(AcType.kUserTrack,{
		category = 'activity',
		sub_category = 'get_prom_meiluke_reward',
		reward_id = id,
		})
end

function DcUtil:useQixiFreePreProps(id)
	send(AcType.kUserTrack,{
		category = 'activity',
		sub_category = 'use_free_pre_props',
		props_id = id,
		})
end

function DcUtil:getQixiReward(id)
	send(AcType.kUserTrack,{
		category = 'activity',
		sub_category = 'get_magpie_festival_reward',
		reward_id = id,
		})
end

function DcUtil:collectQixiBird(count)
	send(AcType.kUserTrack,{
		category = 'activity',
		sub_category = 'collect_the_magpie',
		num = count,
		})
end

function DcUtil:logWeeklyRaceActivity(subCategory, params)
	assert(type(subCategory) == "string")
	local sendDatas = {category = 'weeklyrace', sub_category = subCategory}
	if type(params) == "table" then
		for k, v in pairs(params) do
			sendDatas[k] = v
		end
	end
	-- if _G.isLocalDevelopMode then printx(0, "logWeeklyRaceActivity", table.tostring(sendDatas)) end
	send(AcType.kUserTrack, sendDatas)
end

function DcUtil:clickExchangePanel(clickPlace)
	send(AcType.kUserTrack,{
		category = 'weeklyrace',
		sub_category = 'weeklyrace',
		click_place = clickPlace
		})
end

function DcUtil:pushActivityClick(index)
	send(AcType.kUserTrack, {
		category = "activity",
		sub_category = "click_qukankan"..tostring(index)})
end

function DcUtil:getCDKeyReward( key )
	send(AcType.kUserTrack, {
		category = "cdKey",
		sub_category = "get_cdkey_reward",
		cdkey_content=key
	})
end

function DcUtil:logBuyGoldItem(index, type, doSampling)
	send(AcType.kUserTrack, {
		category = "buy",
		sub_category = "push_button",
		id = index, 
		type1 = type,
	}, doSampling)
end

--点击广告icon
function DcUtil:clickAdVideoIcon()
	send(AcType.kUserTrack,{
		category = 'activity',
		sub_category = 'push_ad_icon'
		})
end

-- 点击"观看广告"按钮
function DcUtil:playAdVideoIcon()
	send(AcType.kUserTrack,{
		category = 'activity',
		sub_category = 'push_ad_watch'
		})
end

-- 点击"领取奖励"按钮
function DcUtil:getAdVideoReward()
	send(AcType.kUserTrack,{
		category = 'activity',
		sub_category = 'push_ad_award'
		})
end

function DcUtil:requestAdVideo( videoId )
	-- body
	send(AcType.kUserTrack,{
		category = 'activity',
		sub_category = 'request_ad',
		video_id = videoId
		})
end

function DcUtil:requestSuccessAdVideo( videoId )
	-- body
	send(AcType.kUserTrack,{
		category = 'activity',
		sub_category = 'request_ad_success',
		video_id = videoId
		})
end

function DcUtil:requestFailAdVideo( videoId )
	-- body
	send(AcType.kUserTrack,{
		category = 'activity',
		sub_category = 'request_ad_fail',
		video_id = videoId
		})
end

--推送召回的87号点在玩家退出时打不上 导致数据不准 所以typeId为11 12 13不打87号点
--@deprecated 前端87号点BI无法精确统计 不打了 
--@new 产品要看，所以重新加回来
-- ps: 之所以说统计不准，推测应该是因为推送是反复设置、反复取消的。
-- 反复的+1-1之后可能产生比较大的误差。
function DcUtil:sendLocalNotify(typeId, timeStamp, numOfTimes)
	-- if typeId == 11 or typeId == 12 or typeId == 13 then 
	-- 	return
	-- end
	-- local userId = UserManager:getInstance().user.uid
	-- if not userId then
	-- 	userId = "12345" 
	-- end
	-- local finalId = userId.."-"..timeStamp.."-"..typeId
	-- send(AcType.kViralSend, {
	-- 	category = 'noti',
	-- 	sub_category = 'noti_send_local',
	-- 	type = "notification",
	-- 	viral_id = finalId,
	-- 	src = "local",
	-- 	num_of_times = numOfTimes,
	-- 	})
end

function DcUtil:logAndroidAddFiveStepsTest(actType, currentStage, buttonType, popType, userType, propId, lastFuuuLogID)
	send(AcType.kUserTrack,{
		category = 'ui',
		sub_category = actType,
		current_stage  = currentStage,
		button_type = buttonType,
		pop_type = popType,
		user_type = userType,
		prop_id = propId,
		fuuu_id = lastFuuuLogID,
	})
	_logWrongCurrentStage(currentStage)
end

function DcUtil:logIosAddFiveStepsTest(actType, currentStage, topLevel, buttonType, userType, lastFuuuLogID, fuuuTarget, popType)
	send(AcType.kUserTrack,{
		category = 'ui',
		sub_category = actType,
		current_stage  = currentStage,
		level = topLevel,
		button_type = buttonType,
		user_type = userType,
		fuuu_id = lastFuuuLogID,
		target = fuuuTarget,
		pop_type = popType,
	})
	_logWrongCurrentStage(currentStage)
end

function DcUtil:gameFailedFuuu(fuuuLogID , levelId , gameModeType , result , progress , score , gameDefiniteFinish)
	local totalPlayed = FUUUManager:getLevelTotalPlayed(levelId)
	send(AcType.kUserTrack,{
		category = "stage",
		sub_category = "game_failed_fuuu",
		id  = fuuuLogID,
		currLevel = levelId,
		current_stage  = levelId,
		meta_level_id = LevelMapManager.getInstance():getMetaLevelId(levelId),
		current_play  = totalPlayed,
		game_mode = gameModeType,
		result = result,
		progress = progress,
		score = score,
		definite_failed = gameDefiniteFinish or false,
		playId = GamePlayContext:getInstance():getIdStr(),
	}, true)
end

--点击主界面上的星星图标
function DcUtil:starIconClick( ... )
	-- body
	send(AcType.kUserTrack, {
		category = 'ui',
		sub_category = 'click_main_ui_star_button',
		})
end

--点击快速选关界面上“查看四星和隐藏关”的小牌子
function DcUtil:fourStarGuideIconClick( ... )
	-- body
	send(AcType.kUserTrack, {
		category = 'ui',
		sub_category = 'click_see_fourstar_and_hidden',
		})
end

--点击四星引导 “炫耀一下”按钮
function DcUtil:shareAllFourStarClick( ... )
	-- body
	send(AcType.kUserTrack, {
		category = 'ui',
		sub_category = 'click_share_all_fourstar',
		})
end

function DcUtil:ladybugOnMainTrunkClick( ... )
	-- body
	send(AcType.kUserTrack, {
		category = 'ui',
		sub_category = 'click_ladybug_on_vine',
		})
end

--点击所有乱七八糟能点的图标
function DcUtil:iconClick(subCategory)
	-- if not __IOS then return end
	-- BI要求全平台打上
	send(AcType.kUserTrack, {
		category = "Ui",
		sub_category = subCategory,
		}, true)
end

function DcUtil:activity( params )
	-- body
	send(AcType.kActivity, params)
end

-- 任务系统创建新任务
function DcUtil:missionLogicCreateMission(missionType)
	send(AcType.kUserTrack, {
		category = "job",
		sub_category = "get_job",
		t1 = missionType,
		})
end

-- 任务系统任务完成
function DcUtil:missionLogicFinishMission(missionType)
	send(AcType.kUserTrack, {
		category = "job",
		sub_category = "finish_job",
		t1 = missionType,
		})
end

-- 任务系统任务被刷新掉
function DcUtil:missionLogicRefreshMission(missionType)
	send(AcType.kUserTrack, {
		category = "job",
		sub_category = "refresh_job",
		t1 = missionType,
		})
end

-- 任务系统任务生成失败
function DcUtil:missionCreateFail(errType)
	send(AcType.kUserTrack, {
		category = "job",
		sub_category = "fail_job",
		id = errType
		})
end

-- 领取精力成功
function DcUtil:timeMachineGetEnergy()
	send(AcType.kUserTrack, {
		category = "activity",
		sub_category = "Time_Machine_get_energy",
		})
end
--播放送精力动画
function DcUtil:timeMachineShowEnergy()
	send(AcType.kUserTrack, {
		category = "activity",
		sub_category = "Time_Machine_show_energy",
		})
end

-- 点击任务系统icon图标按钮
function DcUtil:timeMachineLook(page)
	send(AcType.kUserTrack, {
		category = "activity",
		sub_category = "Time_Machine_look",
		t1 = page
		})
end

-- 点击任务系统icon图标按钮
function DcUtil:timeMachineClickShare()
	send(AcType.kUserTrack, {
		category = "activity",
		sub_category = "Time_Machine_click_share",
		})
end

-- 点击任务系统icon图标按钮
function DcUtil:timeMachineShareSuccess()
	send(AcType.kUserTrack, {
		category = "activity",
		sub_category = "Time_Machine_suc_share",
		})
end

-- 点击任务系统icon图标按钮
function DcUtil:missionIconTapped()
	send(AcType.kUserTrack, {
		category = "job",
		sub_category = "click_icon",
		})
end

-- 周赛点击“发送到微信群”（Mitalk）
function DcUtil:seasonWeeklyShareTapped()
	send(AcType.kUserTrack, {
		category = "weeklyrace",
		sub_category = "weeklyrace_winter_2016_ask_friend",
		})
end

-- 周赛成功发送信息到微信（Mitalk）
function DcUtil:seasonWeeklyShareSucceed()
	send(AcType.kUserTrack, {
		category = "weeklyrace",
		sub_category = "weeklyrace_winter_2016_ask_success",
		})
end

-- 周赛的次数链接，从链接进入游戏
function DcUtil:seasonWeeklyClickLink()
	send(AcType.kUserTrack, {
		category = "weeklyrace",
		sub_category = "weeklyrace_winter_2017_ewm",
		})
end

-- 周赛点击炫耀按钮
function DcUtil:clickShareQrCodeBtn(id, t1, t2)
	send(AcType.kUserTrack, {
		category = "weeklyrace",
		sub_category = "weeklyrace_spring_2018_show_bnt",
		t1 = t1,
		t2 = t2,
		})
end

-- 周赛成功分享炫耀图
function DcUtil:doShareQrCodeSuccess(id, sub_category, t1, t2)
	send(AcType.kUserTrack, {
		category = "weeklyrace",
		sub_category = sub_category,
		t1 = t1,
		t2 = t2,
		})
end

-- 周赛每周排名炫耀点击炫耀按钮
function DcUtil:clickWeeklyRankShareBtn()
	send(AcType.kUserTrack, {
		category = "weeklyrace",
		sub_category = "weeklyrace_spring_2018_share",
		})
end

-- 周赛每周排名炫耀成功分享炫耀图
function DcUtil:doShareWeeklyRankSuccess()
	send(AcType.kUserTrack, {
		category = "weeklyrace",
		sub_category = "weeklyrace_spring_2018_share_success",
		})
end

function DcUtil:enterGameViaWeeklyRaceQrCode(t1)
	send(AcType.kUserTrack, {
		category = "weeklyrace",
		sub_category = "weeklyrace_spring_2018_ingame",
		t1 = t1
	})
end

-- 周赛通过扫码或者链接获得的收集物个数
function DcUtil:sendWeeklyRaceItemNum(itemNum, piecesNum)
	send(AcType.kUserTrack, {
		category = "weeklyrace",
		sub_category = "weeklyrace_spring_2018_ewm_gem",
		t1 = itemNum,
		t2 = piecesNum
	})
end

function DcUtil:loginException(subCategory)
	send(AcType.kUserTrack, {
		category = "Abnormal",
		sub_category = subCategory,
		})
end

function DcUtil:log(acType, data, doSampling)
	send(acType, data, doSampling)
end

--存打点到本地文件，下次登录上传
function DcUtil:saveLogToLocal( ... )
	saveLogToLocal()
end

function DcUtil:userInfo( data )
	local moreData = {
		carrier = metaInfo:getNetOperatorName(),
	}

	for k,v in pairs(data) do
		moreData[k] = v
	end

	send(AcType.kUserInfo, moreData)
end

function DcUtil:appInfo()
	if not __ANDROID then return end
	local appInfos = getAppInfo()
	if appInfos then
		local time = Localhost:timeInSec()
		for i, v in ipairs(appInfos) do
			send(AcType.kAppInfo, {
				app_name = v:getAppName(),
				package_name = v:getPackageName(),
				version_name = v:getVersionName(),
				info_time = time,
			})
		end
	end
end

function DcUtil:runningApp()
	if not __ANDROID then return end
	local apps = getRunningApp()
	if apps then
		send(AcType.kAppInfo, {
			type = 2,
			apps = apps,
		})
	end
end

function DcUtil:qqUserFri( data )
	local moreData = {
		carrier = metaInfo:getNetOperatorName(),
	}

	for k,v in pairs(data) do
		moreData[k] = v
	end

	send(AcType.kQQUserFri, moreData)
end

function DcUtil:Exposure( data )
	send(AcType.kExposure, data)
end

function DcUtil:androidSalesPromotion(type, grade, goodsId)
	send(AcType.kUserTrack, {
		category = "activity",
		sub_category = "android_rmb_promotion",
		type = type,
		grade = grade,
		goods_id = goodsId,
		})
end

function DcUtil:forceUploadReplayData(datastr , info , ver , level , passed , score , currTime , stepsNum)
	DcUtil:uploadReplayData("force_upload_replay", datastr , info , ver , level , passed , score , currTime , stepsNum)
end

function DcUtil:uploadReplayData(subCategory, datastr , info , ver , level , passed , score , currTime , stepsNum, dcData)
	local data1 = {
		category = "replay",
		sub_category = subCategory,
		datastr = datastr,
		info = info,
		ver = ver,
		replayLevel = level,
		meta_level_id = LevelMapManager.getInstance():getMetaLevelId(level),
		passed = passed,
		score = score,
		currTime = currTime,
		stepsNum = stepsNum,
	}
	if type(dcData) == "table" then
		for k, v in pairs(dcData) do
			data1[k] = v
		end
	end
	send(AcType.kExpire30Days, data1)
end

function DcUtil:uploadReplaySnapshotsData(datastr , level , rid)
	send(AcType.kUserTrack, {
		category = "replaySS",
		sub_category = "ss",
		datastr = datastr,
		lvId = level,
		rid = rid,
		})
end

--gainType
--无购买0 风车币购买1 人民币购买2
WeeklyRaceTimeGainType = table.const{
	kNoPay = 0,
	kHappyCoin = 1,
	kRmb = 2,
}
function DcUtil:payWeeklyRaceTimePanel(gainType)
	send(AcType.kUserTrack, {
		category = "ui",
		sub_category = "panel_gain_weeklyrace_time",
		buy = gainType,
		})
end

--panelId
--普通解锁 1 任务解锁 2  推送召回解锁 3
UnlockPanelType = table.const{
	kNormal = 1,
	kTask = 2,
	kRecall = 3,
}
function DcUtil:payUnlockCloudPanel(panelId)
	send(AcType.kUserTrack, {
		category = "ui",
		sub_category = "panel_unlock",
		panel_id = panelId,
		})
end

function DcUtil:payMarkPrisePanel(goodsId)
	send(AcType.kUserTrack, {
		category = "ui",
		sub_category = "panel_sign_promotion",
		goods_id = goodsId,
		})
end

function DcUtil:payManualOnlinePayCheckPanel(checkTimes, fcClick)
	send(AcType.kUserTrack, {
		category = "payment",
		sub_category = "panel_polling ",
		times = checkTimes,
		fc = fcClick,
		})
end

function DcUtil:triggerGuideProp(item_id, item_name , currentStage , high_stage)
	send(AcType.kUserTrack, {
		category = "tutorial",
		sub_category = "item_condition",
		item_id = item_id,
		item_name = item_name,
		current_stage = currentStage,
		meta_level_id = LevelMapManager.getInstance():getMetaLevelId(currentStage),
		high_stage = high_stage,
		},
		true)
	_logWrongCurrentStage(currentStage)
end

function DcUtil:showPrePropGuide()
	send(AcType.kUserTrack, {
		category = "guide",
		sub_category = "G_energy_guide_use",
		})
end

function DcUtil:clickPrePropGuide()
	send(AcType.kUserTrack, {
		category = "guide",
		sub_category = "G_energy_guide",
		})
end

function DcUtil:showAutoUseEnergyBottle(t1)
	send(AcType.kUserTrack, {
		category = "stage",
		sub_category = "G_trigger_energy",
		t1 = t1 ,
		})
end

function DcUtil:clickAutoUseEnergyBottle(t1)
	send(AcType.kUserTrack, {
		category = "stage",
		sub_category = "G_use_trigger_energy",
		t1 = t1 ,
		})
end

function DcUtil:adsIOSClick( p, doSampling )
	p = p or {}
	p.category = "click"

	send(AcType.kAdsIOSClick, p, doSampling)
end

function DcUtil:adsIOSReward( p )
	p = p or {}
	p.category = "reward"
	send(AcType.kAdsIOSReward, p)
end

function DcUtil:adsIOSLoad( p )
	p = p or {}
	p.category = "load"
	send(AcType.kAdsIOSLoad, p)
end

function DcUtil:endGameForActivity(subCategory, levelId, buttonType, panelType)
	if LevelType:isMoleWeekLevel(levelId) then 
		local params = {
			game_type = "stage",
			game_name = "",
			category = "weeklyrace2018",
			sub_category = "weeklyrace2018_"..subCategory,
			t1 = levelId,
			t2 = buttonType,
			t3 = panelType or 0,
		}

        send( AcType.kUserTrack, params )
	end
end

function DcUtil:AddFiveForMoleWeek( params )
    send( AcType.kUserTrack, params )
end

function DcUtil:popCrashResumePanel(levelId , selfUid , selfUdid , dataUid , dataUdid , md5 )
	send(AcType.kExpire90Days, {
		category = "crash_resume",
		sub_category = "crash_resume_pop",
		meta_level_id = LevelMapManager.getInstance():getMetaLevelId(levelId),
		t1 = levelId,
		t2 = selfUid,
		t3 = selfUdid,
		t4 = dataUid,
		t5 = dataUdid,
		t6 = md5,
		})
end


function DcUtil:crashResumeFailed(reason , levelId , selfUid , selfUdid , dataUid , dataUdid , md5, otherInfo)
	if _G.isLocalDevelopMode then printx(1, "DcUtil:crashResumeFailed   -----------------------  ", reason) end
	-- printx(11, "============ +++ +++ crashResumeFailed +++ +++, ", reason, levelId, selfUid, dataUid, otherInfo, debug.traceback())
	
	if not otherInfo then otherInfo = "none" end 	--无附加信息

	send(AcType.kExpire90Days, {
		category = "crash_resume",
		sub_category = "crash_resume_failed",
		meta_level_id = LevelMapManager.getInstance():getMetaLevelId(levelId),
		t1 = reason,
		t2 = levelId,
		t3 = selfUid,
		t4 = selfUdid,
		t5 = dataUid,
		t6 = dataUdid,
		t7 = md5,
		t8 = otherInfo,
		})
end

function DcUtil:crashResumeStart(levelId , totalSteps , selfUid , selfUdid , dataUid , dataUdid , md5 )
	send(AcType.kUserTrack, {
		category = "crash_resume",
		sub_category = "crash_resume_start",
		meta_level_id = LevelMapManager.getInstance():getMetaLevelId(levelId),
		t1 = levelId,
		t2 = totalSteps,
		t3 = selfUid,
		t4 = selfUdid,
		t5 = dataUid,
		t6 = dataUdid,
		t7 = md5,
		})
end

function DcUtil:crashResumeEnd(result , levelId , finSteps , selfUid , selfUdid , dataUid , dataUdid , md5 , totalSteps )
	send(AcType.kExpire90Days, {
		category = "crash_resume",
		sub_category = "crash_resume_end",
		meta_level_id = LevelMapManager.getInstance():getMetaLevelId(levelId),
		t1 = result,
		t2 = levelId,
		t3 = finSteps,
		t4 = selfUid,
		t5 = selfUdid,
		t6 = dataUid,
		t7 = dataUdid,
		t8 = md5,
		t9 = totalSteps,
		})
end

function DcUtil:crashResumeHasNoNetwork(levelId , selfUid , selfUdid , dataUid , dataUdid , md5 )
	send(AcType.kExpire90Days, {
		category = "crash_resume",
		sub_category = "crash_resume_noNet",
		meta_level_id = LevelMapManager.getInstance():getMetaLevelId(levelId),
		t1 = levelId,
		t2 = selfUid,
		t3 = selfUdid,
		t4 = dataUid,
		t5 = dataUdid,
		t6 = md5,
		})
end

function DcUtil:crashResumeDeleteFileFailed( idStr )
	send(AcType.kExpire90Days, {
		category = "crash_resume",
		sub_category = "deleteFileFailed",
		t1 = idStr,
		})
end

function DcUtil:levelDifficultyAdjustActivated(
	levelId , userGroup , mode , ds , seed , activationTag , activationTagTopLevelId , 
	activationTagEndTime , diff , propSeed , reason , realCostMove , hasProgressData , replayMode , isAIGroup )

	if not seed then seed = 0 end
	if not mode then mode = 0 end
	if not ds then ds = 0 end
	if not userGroup then userGroup = 0 end

	local uid = UserManager:getInstance():getUID()
	local useNewColorLogic = false
	if MaintenanceManager:getInstance():isEnabledInGroup("LevelDifficultyAdjust" , "NewColor" , uid) then
		useNewColorLogic = true
	end

	local playId = GamePlayContext:getInstance():getIdStr()
	-- RemoteDebug:logWithLuaPrint( "RRR" , "DcUtil:levelDifficultyAdjustActivated  userGroup =" , userGroup )
	
	send(AcType.kUserTrack, {
		category = "LevelDifficultyAdjust",
		sub_category = "try_activate",
		meta_level_id = LevelMapManager.getInstance():getMetaLevelId(levelId),
		t0 = 2,
		t1 = levelId,
		t2 = userGroup,
		t3 = mode,
		t4 = ds,
		t5 = seed,
		t6 = activationTag,
		t7 = activationTagTopLevelId,
		t8 = activationTagEndTime,
		t9 = diff,
		t10 = useNewColorLogic,
		t11 = propSeed,
		t12 = playId,
		t13 = reason,
		t14 = realCostMove,
		t15 = hasProgressData,
		t16 = replayMode , 
		t17 = isAIGroup
		})
end

function DcUtil:DifficultyAdjustUnactivate( levelId , reason )
	--[[
	local meta = LevelMapManager.getInstance():getMeta(levelId)
	if meta then
		levelMd5 = LevelDifficultyAdjustManager:getMD5ByLevelMeta(meta)
	end

	local playId = GamePlayContext:getInstance():getIdStr()

	send(AcType.kActivity, {
		category = "LevelDifficultyAdjust",
		sub_category = "unactivate",
		t1 = levelId,
		t2 = levelMd5,
		t3 = reason,
		t4 = playId,
		})
	--]]
end

function DcUtil:AIColorAdjustUnactivate( levelId , reason , datas )

	local meta = LevelMapManager.getInstance():getMeta(levelId)
	if meta then
		levelMd5 = LevelDifficultyAdjustManager:getMD5ByLevelMeta(meta)
	end

	local playId = GamePlayContext:getInstance():getIdStr()

	send(AcType.kActivity, {
		category = "LevelDifficultyAdjust",
		sub_category = "AIColorUnactivate",
		meta_level_id = LevelMapManager.getInstance():getMetaLevelId(levelId),
		t1 = levelId,
		t2 = levelMd5,
		t3 = playId,
		t4 = reason,
		t5 = datas,
		})
	
end


function DcUtil:DifficultyAdjustActivated( levelId , seed , levelMd5 )
	
	-- send(AcType.kActivity, {
	-- 	category = "LevelDifficultyAdjust",
	-- 	sub_category = "uniq_key",
	-- 	t1 = levelId,
	-- 	t2 = seed,
	-- 	t3 = levelMd5,
	-- 	t4 = GamePlayClientVersion,
	-- 	})
end

function DcUtil:DifficultyAdjustTestLog( levelId , fuuuCount2 , fuuuCount3 , topLevelFailCount , diff  , doActivationStrategy)
	
	send(AcType.kActivity, {
		category = "LevelDifficultyAdjust",
		sub_category = "testLog",
		meta_level_id = LevelMapManager.getInstance():getMetaLevelId(levelId),
		t1 = levelId,
		t2 = fuuuCount2,
		t3 = fuuuCount3,
		t4 = topLevelFailCount,
		t5 = diff,
		t6 = doActivationStrategy,
		})
end

function DcUtil:UseTagLog( source , activationTag , activationTagTopLevelId , activationTagEndTime , activationTagchange )
	
	send(AcType.kUserTrack, {
		category = "Tag",
		sub_category = "UserTagBean",
		t1 = source,
		t2 = activationTag,
		t3 = activationTagTopLevelId,
		t4 = activationTagEndTime,
		t5 = activationTagchange,
		})
end

function DcUtil:DifficultyTagLog( source , topLevelTag , positionTag , continuousTag )
	
	send(AcType.kUserTrack, {
		category = "Tag",
		sub_category = "DifficultyTagBean",
		t1 = source,
		t2 = topLevelTag,
		t3 = positionTag,
		t4 = continuousTag,
		})
end

function DcUtil:LevelPositionTagLog( source , area , endTime )
	
	send(AcType.kUserTrack, {
		category = "Tag",
		sub_category = "levelPositionTag",
		t1 = source,
		t2 = area,
		t3 = endTime,
		})
end

function DcUtil:LevelUpTagLog( source , levelup , levelupchange , endTime )
	
	send(AcType.kUserTrack, {
		category = "Tag",
		sub_category = "levelUpTag",
		t1 = source,
		t2 = levelup,
		t3 = levelupchange,
		t4 = endTime,
		})
end

function DcUtil:ItemTagLog( source , datalist )

	if not datalist or #datalist == 0 then return end

	local str = ""
	for k,v in pairs(datalist) do
		str = str .. tostring(v.first) .. "_" .. tostring(v.second) .. ";"
	end
	
	send(AcType.kUserTrack, {
		category = "Tag",
		sub_category = "ItemTag",
		t1 = source,
		t2 = str,
		})
end

function DcUtil:VirtualSeedEnabled( levelId , oringinMode , selectMode , patternIndex , ar , ac , failedreason)
	if true then return end --不需要这个点了，节约BI储存空间
	local playId = GamePlayContext:getInstance():getIdStr()
	
	send(AcType.kUserTrack, {
		category = "VirtualSeed",
		sub_category = "enabled",
		meta_level_id = LevelMapManager.getInstance():getMetaLevelId(levelId),
		t1 = playId,      --打关唯一id
		t2 = levelId,     --关卡id
		t3 = oringinMode, --预期启用组合  1直线 2爆炸 3直线&直线 4直线&爆炸 5魔力鸟 6爆炸&爆炸 7魔力鸟&直线 8魔力鸟&爆炸 9魔力鸟&魔力鸟
		t4 = selectMode,  --实际启用组合  0没有可用组合 1直线 2爆炸 3直线&直线 4直线&爆炸 5魔力鸟 6爆炸&爆炸 7魔力鸟&直线 8魔力鸟&爆炸 9魔力鸟&魔力鸟
		t5 = patternIndex,--组合子类型，见表格
		t6 = ar,          --组合A点的坐标R，见表格
		t7 = ac,          --组合A点的坐标C，见表格
		t8 = failedreason,          
		})
end

function DcUtil:VirtualSeedPassed( levelId , reason )
	if true then return end --不需要这个点了，节约BI储存空间
	local playId = GamePlayContext:getInstance():getIdStr()
	
	send(AcType.kUserTrack, {
		category = "VirtualSeed",
		sub_category = "passed",
		meta_level_id = LevelMapManager.getInstance():getMetaLevelId(levelId),
		t1 = playId,   --打关唯一id
		t2 = levelId,  --关卡id
		t3 = reason,   --1开关未打开 2本次随机未成功 3距离上一次成功启用策略的间隔不足三次 4首次过关前失败次数超过10次
					   --99满足1~4但是引导关 
		})
end

function DcUtil:levelStrategyLog(params)
	send(AcType.kUserTrack, params)
end


function DcUtil:UpdateUseTag( source , tagTopLevelId , datas )
	
	local dcObj = {}

	dcObj.category = "UserTag"
	dcObj.sub_category = "tag_update"
	dcObj.t1 = source
	dcObj.t2 = tagTopLevelId

	if datas then
		for k,v in pairs(datas) do
			dcObj["t" .. tostring(k)] = v
		end
	end

	send(AcType.kUserTag, dcObj)
end

function DcUtil:autoAddFriendFailReason(errCode)
	send(AcType.kUserTrack, {
		category = "AutoAddFriend",
		sub_category = "fail_reason",
		errCode = errCode, 
		})
end

function DcUtil:dcForWeekly(subCategory, levelId, cloudNum, gemCloudNum, dazhaoRate, targetNum, buyState)
	send(AcType.kUserTrack, {
		category = "weeklyrace",
		sub_category = subCategory,
		t1 = levelId,
		t2 = cloudNum,
		t3 = gemCloudNum,
		t4 = dazhaoRate,
		t5 = targetNum,
		t6 = buyState,
	})
end

function DcUtil:dcForOppoLaunch(params)
	send(AcType.kUserTrack, params)
end


--结束关卡
function DcUtil:logMoleWeekStageEnd()

    local redNum = 0
    local yellowNum = 0
    local bossCount = 0
    local ClearWaterBox = 0
    local level = 0

    local boardLogic = GameBoardLogic:getCurrentLogic()
	if boardLogic and boardLogic.PlayUIDelegate then
        redNum = boardLogic.digJewelCount:getValue() or 0
        yellowNum = boardLogic.yellowDiamondCount:getValue() or 0
        bossCount = boardLogic:getBossCount()  or 0
        ClearWaterBox = boardLogic.magicTileDemolishedNum or 0
        level = boardLogic.level
    end
    
	local dcData = {
        game_type = "stage",
        game_name = "",
        category = "weeklyrace2018",
        sub_category = "weeklyrace2018_stage_end",
        t1 = level,
        t2 = redNum,
        t3 = yellowNum,
        t4 = bossCount,
        t5 = ClearWaterBox,
    }

	send(AcType.kUserTrack, dcData)
end

function DcUtil:dcForManualOrderCheck(subCategory, ...)
	local dcData = {
    	category = "pay_auto_query",
    	sub_category = subCategory,
	}
	local params = {...}
	local paramsNum = #params
	if paramsNum > 0 then 
		for i=1,paramsNum do
			dcData["t"..i] = params[i]
		end
	end

	send(AcType.kUserTrack, dcData)
end

function DcUtil:dcForUserTrack(params)
	send(AcType.kUserTrack, params)
end

function DcUtil:dcWarpEngine( curLevelId , count , rcount , addcount , raddcount , idstr )
	send(AcType.kUserTrack, {
		category = "WarpEngine",
		sub_category = "Boom",
		meta_level_id = LevelMapManager.getInstance():getMetaLevelId(curLevelId),
		t1 = curLevelId ,
		t2 = count,
		t3 = rcount,
		t4 = addcount,
		t5 = raddcount,
		t6 = idstr,
	})
end


--我的星星打点 - 各界面的展示
--	t1:展示界面，0=主线，1=隐藏，2=四星，3=星星排行
function DcUtil:openStarAchWIthID( tabid )
	-- if not __IOS then return end
	-- BI要求全平台打上
	send(AcType.kUserTrack, {
		category = "Ui",
		sub_category = "G_my_star_panel",
		t1 = tabid ,
		})
	if _G.isLocalDevelopMode then printx(100, "Ui G_my_star_panel tabid= ",tabid ) end
end

--我的星星打点 - 点击跳转至对应区域/关卡
--t1:界面，0=主线，1=隐藏，2=四星；t2:当前区域首关关卡id，或对应当关id	
function DcUtil:clickFlowerNodeInStarAch( tabid ,levelID)
	-- if not __IOS then return end
	-- BI要求全平台打上
	send(AcType.kUserTrack, {
		category = "Ui",
		sub_category = "G_my_star_panel_click",
		t1 = tabid ,
		t2 = levelID ,
		})
	if _G.isLocalDevelopMode then printx(100, "Ui G_my_star_panel_click tabid= levelID =",tabid ,levelID ) end
end


--我的星星打点 - 点击去补星按钮
function DcUtil:clickMoreStarPanelBtn()
	-- if not __IOS then return end
	-- BI要求全平台打上
	send(AcType.kUserTrack, {
		category = "Ui",
		sub_category = "G_my_star_panel_farmstar",
		})
	if _G.isLocalDevelopMode then printx(100, "Ui G_my_star_panel_farmstar  " ) end
end

--我的星星打点 - 领取星星奖励
--		item_id：领取的奖励的id
function DcUtil:clickGetStarRewardsLogic( reward  )
	-- if not __IOS then return end
	-- BI要求全平台打上
	send(AcType.kUserTrack, {
		category = "Ui",
		sub_category = "my_star_get_reward",
		reward  = reward  ,
		})

	if _G.isLocalDevelopMode then printx(100, "Ui my_star_get_reward = ", reward  ) end
end

function DcUtil:switchGameSpeed( spd , isFPSWarning )
	send( AcType.kUserTrack , {
		category = "GameSetting",
		sub_category = "click_switch_speed",
		level_speed  = spd  ,
		playId = GamePlayContext:getInstance():getIdStr() ,
		-- setByFPSWarning  = isFPSWarning or false  ,
		})
end

function DcUtil:groupTest()
	local _uid = tostring( UserManager:getInstance():getUID() )

	local function doDC( maintenanceName )

		if not MaintenanceManager:getMaintenanceFeature( maintenanceName ) then
			return
		end

		local groupIndex = 0
		-- WTF123 = true
		for i = 1 , 3 do
			if MaintenanceManager:getInstance():isEnabledInGroup(maintenanceName , "G" .. tostring(i) , _uid ) then
				groupIndex = i
				break
			end
		end

		local levelDifficultyAdjustV2Group = 0
		for i = 1 , 15 do
			if MaintenanceManager:getInstance():isEnabledInGroup("LevelDifficultyAdjustV2" , "A" .. tostring(i) , _uid) then
				levelDifficultyAdjustV2Group = i
				break
			end
		end

		local currWeighValue , version = MaintenanceManager:getInstance():getUserWeighValue( maintenanceName , _uid )

		-- local rangeMap = self:getGroupChildRangeMap( maintenanceName )

		----[[
		send(AcType.kExpire7Days, {
			category = "TEST",
			sub_category = "orthogonal_group_3",
			t1  = maintenanceName  , --TestSwitch开关
			t2  = version  , --版本，此参数由所有child拼接后md5得来，只要权重参数变更就将生成新version
			t3  = _uid , --用户当前的uid
			t4  = currWeighValue , --用户当前的“分组权重值”
			t5  = groupIndex  ,  --用户当前的分组（G1~G3,第一个满足条件即返回）
			t6  = levelDifficultyAdjustV2Group  ,
			})
		--]]

		-- printx( 1 , "FFFFFFFFFFFFFFFFFFF??????????????  "  )
		-- printx( 1 , "maintenanceName =" , maintenanceName , "version =" , version , "groupIndex =" , groupIndex ,"currWeighValue =" , currWeighValue  )
		-- RemoteDebug:uploadLogWithTag( "group222" , maintenanceName , version , groupIndex , currWeighValue) 
	end
	
	doDC( "TestSwitch2" )
	-- doDC( "TestSwitch2" )
	
end

function DcUtil:levelSpeedMonitoring( resultData )

	local uid = tostring( UserManager:getInstance():getUID() )

	if MaintenanceManager:getInstance():isEnabledInGroup("LevelSpeedMonitoring" , "ON" , uid) then
		
		send(AcType.kExpire7Days, {
			category = "LevelSpeedMonitoring",
			sub_category = "PassLevel",
			meta_level_id = LevelMapManager.getInstance():getMetaLevelId(resultData.level),
			t1  = resultData.level  , --关卡id
			t2  = resultData.detectionCycle  , --检测周期
			t3  = resultData.failureThreshold  , --失败阀值
			t4  = resultData.maxCCount  , --单关内最大允许连续失败次数
			t5  = resultData.maxTCount  , --单关内最大允许累计失败次数
			
			t6  = resultData.totalCycleCount  , --总检测次数
			t7  = resultData.maxContinuousCount  , --最大连续检测失败次数
			t8  = resultData.failedCount  , --检测失败累计次数
			t9  = resultData.failedRate  , --失败次数占比

			t10  = resultData.averageTotalFPS  , --总平均FPS
			t11  = resultData.averageMaxContinuousFPS  , --最大连续失败次数期间的平均FPS
			t12  = resultData.averageFailedFPS  , --所有失败检测循环的平均FPS

			t13  = resultData.averageTotalDiff  , --总的平均差值（偏离预期的比例）
			t14  = resultData.averageMaxContinuousDiff  , --最大连续失败次数期间的平均差值
			t15  = resultData.averageFailedDiff  , --所有失败检测循环的平均差值
			})

	end
end

function DcUtil:gameLauncherContextWarning( sub_category , timePass , FPS , datas )
	
	local dataStr = nil
	--[[
	RemoteDebug:uploadLogWithTag( "DcUtil" , "gameLauncherContextWarning --- " , sub_category , datas )
	if datas then
		for k,v in pairs(datas) do
			RemoteDebug:uploadLogWithTag( "DcUtil222" , "k" , k , "v" , v)
		end
		-- dataStr = mime.b64( table.serialize( datas ) ) --serialize可能报错，暂时不用
	end
	]]

	send(AcType.kExpire7Days, {
		category = "LauncherWarning",
		sub_category = sub_category,
		t1  = TimerUtil.initTime  ,
		t2  = timePass  , 
		t3  = FPS , 
		t4  = dataStr , 
		})

	
end

function DcUtil:sendSnapshotDC( levelId , isWin , ranSeeds , finalScore , gamereplay , ver , groupTag )
	send(AcType.kSnapshotPassLevel, {
		levelId = levelId,
		isWin = isWin,
		ranSeeds  = ranSeeds  ,
		finalScore  = finalScore  , 
		gamereplay  = gamereplay , 
		ver  = ver , 
		groupTag = groupTag ,
		})
end

local insideVersion = getInsideVersion()
if insideVersion ~= '' then
	he_log_error("grey_test, inside = " .. tostring(insideVersion))
end

--一锤过关小木槌引导打点
function DcUtil:timelyHammerGuide(levelId)
	send(AcType.kUserTrack, {
		category = 'propinstruct',
		sub_category = 'propinstruct_2018',
		meta_level_id = LevelMapManager.getInstance():getMetaLevelId(levelId),
		t1 = levelId,
		})
end


function _simpleCallServer(host, s, callback)
  	local function onResponse(response)
  		if callback then
  			callback(response)
  		end
    end

    -- print(host)
    -- print(s)
    -- debug.debug()

	-- local host = NetworkConfig.dynamicHost .. "animalEnvironment"
	-- local host = '10.130.137.236/animalEnvironment'
	local request = HttpRequest:createPost(NetworkConfig.dynamicHost .. host)
	request:setConnectionTimeoutMs(3 * 1000)
	request:setTimeoutMs(30 * 1000)
	request:addHeader("Content-Type: application/json")
	request:setPostData(s, #s)
	HttpClient:getInstance():sendRequest(onResponse, request)

end

pcall(_simpleCallServer, 'animalEnvironment', '', 
	function(response)
		if response.httpCode == 200 then 
			print(response.body)
			local r = table.deserialize(response.body)
			if r.devEnv == 'true' or r.devEnv == true then
				HeDCLog:setSendOriginalDc(true)
			end
		end
	end)

