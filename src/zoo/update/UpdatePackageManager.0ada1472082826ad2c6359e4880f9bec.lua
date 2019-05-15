--[[
TODO 旧版逻辑:废弃
WifiAutoDownloadManager
UpdateNewVersionPanel
InstallAlertPanel

UpdatePackageLogic
]]--

local MainActivityHolder = nil
local ApplicationHelper = nil
local PackageUtils = nil
local DownloadUtil = nil
local HttpUtil = nil
local FileUtils = nil

if __ANDROID then
	MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder')
	ApplicationHelper = luajava.bindClass("com.happyelements.android.ApplicationHelper")
	PackageUtils = luajava.bindClass("com.happyelements.android.utils.PackageUtils")
	DownloadUtil = luajava.bindClass("com.happyelements.android.utils.DownloadUtil")
	HttpUtil = luajava.bindClass("com.happyelements.android.utils.HttpUtil")
	FileUtils =  luajava.bindClass("com.happyelements.android.utils.FileUtils")
end

local UpdatePackageUtil = require "zoo.update.UpdatePackageUtil"
local UpdatePackageModel = require "zoo.update.UpdatePackageModel"
local UpdatePackageProgress = require "zoo.update.UpdatePackageProgress"

local Alert = require "zoo.panel.Alert"

local MAX_PATCH_ERROR_TIMES = 1

--用途: 管理 大版本更新过程中 新包的下载逻辑
UpdatePackageManager = class()

--是否输出日志
local isLog = false
--isLog = true

local all = ""
local function log(...)
	if not isLog then return end

	-- local debugList={"40731","39950","41152","39562","37910"}
	-- if not table.includes(debugList,UserManager:getInstance().uid) then
		-- do return end
	-- end
	-- if not  _G.isLocalDevelopMode then return end
	local t = {...}
	local s = ""
	for i,v in ipairs(t) do
		s = s .. tostring(v)
	end
	all=  all .. s.."\n"
	-- printx(0,"UpdatePackageManager:" .. table.tostring(t).." \n-- "..debug.traceback())
	RemoteDebug:uploadLogWithTag('t---Up()'.. tostring(t[1]) ,table.tostring(t) .. " -- "..debug.traceback())
end

local instance

function UpdatePackageManager:getInstance( )
	if not instance then
		instance = UpdatePackageManager.new()
		-- if isLog then log("UpdatePackageManager:getInstance()class:"..tostring(UpdatePackageManager).."-ref:" .. tostring(instance)) end
	end
	return instance
end

-- 是否采用新版逻辑。
function UpdatePackageManager:enabled()
	-- 旧版 newUpdate1807 开关锁定为 useOld ，保持旧版。
	-- local isUseOld = MaintenanceManager:getInstance():isEnabledInGroup('newUpdate1807', 'useOld', UserManager:getInstance().uid)
	-- if isUseOld then
	-- 	return false
	-- end

	-- 等待需要开放新更新流程时候，增加此开关 newUpdate1808, isOpen,hepatch;1
	local isOpen = MaintenanceManager:getInstance():isEnabledInGroup('newUpdate1808', 'isOpen', UserManager:getInstance().uid)
	return isOpen
end

UpdatePackageManager.States = {
	kUnstart = 'UpdatePackageManager.States.kUnstart',              --当前没有下载线程，但本地可能已经一部分下载文件了，上一次没下完
	kPreDownloading = 'UpdatePackageManager.States.kPreDownloading',  --当前在下载准备
	kDownloading = 'UpdatePackageManager.States.kDownloading',  --当前有下载线程
	kFinish = 'UpdatePackageManager.States.kFinish',            --当前updateInfo中指明的包已下载完
	kError = 'UpdatePackageManager.States.kError'
}

local URL_DOWNLOAD_ROOT = "http://downloadapk.manimal.happyelements.cn/"
local isTfApk = DcUtil:getSubPlatform() and string.len(DcUtil:getSubPlatform()) == 2
if isTfApk then
	URL_DOWNLOAD_ROOT = "http://apk.manimal.happyelements.cn/"
end

local URL_CALUTRON = "http://patch.happyelements.cn/api?id=3"

local cacheMd5 = {}

--不支持更新的平台
local noSupportPlatforms = {
	PlatformNameEnum.kCMCCMM,
	PlatformNameEnum.kCMCCMM_JS,
	PlatformNameEnum.kCMCCMM_ZJ,
	PlatformNameEnum.kCUCCWO,
	PlatformNameEnum.k189Store,
	PlatformNameEnum.kCMGame,
	PlatformNameEnum.kHEMM,
	PlatformNameEnum.kMobileMM,
}

local function dc(sub_category,params)
	params = params or {}
	if type(params) ~="table" then
		local t = {t0 = params}
		params = t
	else
		for k,v in pairs(params) do
			if type(v) =="table" then
				for kk,vv in pairs(v) do
					params[tostring(k) .. "_" .. tostring(kk)]=vv
				end
				params[k]=nil
			end
		end
	end
	params.size = params.size or tostring(UpdatePackageModel:getInstance().totalSize)
	params.sub_category = sub_category
	params.category = params.category or "newUpdate"
	params.isZombie = UpdatePackageModel:getInstance():isZombie()
	params.tVersion = tostring(UpdatePackageManager:getInstance().targetVersion)
	params.vNow = tostring(_G.bundleVersion)
	params.isWifi = NetworkUtil:getNetworkStatus() == NetworkUtil.NetworkStatus.kWifi

	if sub_category=="start_download"
		or sub_category=="show_update_confirm"
		or sub_category=="download_completed" then
		params.isInGameDownload = UpdatePackageManager:getInstance():isInGameDownload()
	end

	if isLog then log("dc",table.tostring(params)) end
	if params.category == "newUpdate" then
		DcUtil:UserTrackWithType(params, AcType.kExpire90Days)
	else
		DcUtil:UserTrack(params)
	end

end

function UpdatePackageManager:reset( )
	if isLog then log("reset()0") end

	self.nowSize = 0
	self.totalSize = 0

	self.errorTimes = 0
	self.justPatchErrorTimes = 0

	self:clearThread()

	local updateInfo = UserManager:getInstance().updateInfo or {}
	if updateInfo and updateInfo.type==1 and
		(not self.targetVersion or not self.apkPath or self.targetVersion~=updateInfo.version) then
		self.targetVersion = tostring(updateInfo.version) or ''
		
		local dir = FileUtils:getApkDownloadPath(MainActivityHolder.ACTIVITY:getContext())
		local apkName = UpdatePackageUtil:getApkName(nil,true)
		self.apkPath = string.format('%s/%s', dir, apkName)
		self.installedApkPath = MainActivityHolder.ACTIVITY:getContext():getApplicationInfo().sourceDir
		if isLog then log("reset()installedApkPath",self.installedApkPath,table.tostring(updateInfo)) end
	end

	-- initState
	self:setState(UpdatePackageManager.States.kUnstart)
end

function UpdatePackageManager:ctor( )
	if isLog then log("ctor()0") end

	if not __ANDROID then
		return
	end

	local model = UpdatePackageModel:getInstance()
	if UpdatePackageModel.justChangeVersion then
		local function onChangeVersion()
			dc("just_change_version",UpdatePackageModel.justChangeVersion)
			UpdatePackageModel.justChangeVersion=nil
		end
		setTimeOut(onChangeVersion,0.1)
	end

	self:reset()

	local function onProcess(progress, total)
		-- if isLog then log('onProcess()', progress, total) end
		self.nowSize = tonumber(progress)
		self.totalSize = tonumber(total)

		self:setState(UpdatePackageManager.States.kDownloading)
		local _ = self.onProcessCB and self.onProcessCB(progress, total)

		if progress and progress>0 and total and total>0 then
			self:setHomeIconText("ing", math.floor(progress * 100 / total))
		end
	end

	-- initDownloadCallback
	local function onSuccess()
		if isLog then log("onSuccess()"..tostring(self.hasSuccess)) end
		if self.hasSuccess then
			return
		end
		dc("download_completed",{isPatch=false})

		self.hasSuccess=true
		self:clearThread()

		onProcess(self.totalSize, self.totalSize)
		self:setState(UpdatePackageManager.States.kFinish)

		local updateInfo = UserManager:getInstance().updateInfo or {}
		local version = tostring(updateInfo.version) or ''

		self.justSuccess = true

		if self.progressPanel then
			self.progressPanel:onClose()
			self:_toInstall(true,0)
			self.progressPanel=nil
		end
		if Director:sharedDirector():run() == HomeScene:sharedInstance() then
			if not PopoutManager:sharedInstance():haveWindowOnScreen() then
				self:_toInstall(true,1)
			end
		end
		self:setHomeIconText("ready")
	end

	local function onError( code )
		if isLog then log("onError()") end
		if self.state == UpdatePackageManager.States.kError then
			return
		end

		self:clearThread()
		self.errorTimes=(self.errorTimes or 0)+1

		dc("download_error",{isPatch=false})
		DownloadUtil:remove()
		self.downloadManagerState=nil

		self:setState(UpdatePackageManager.States.kError)
		-- self:reset()
	end

	local function onSuccessCB()
		setTimeOut(onSuccess,0.1)
	end

	local function onErrorCB( code )
		if isLog then log("onErrorCB()",code) end
		setTimeOut(onError,0.1)
	end

	self.downloadCallback = {
		onSuccess = onSuccessCB,
		onError = onErrorCB,
		onProcess = onProcess,
	}

	self:checkState()

	if self.state == UpdatePackageManager.States.kDownloading then
		local _downloadCallback = luajava.createProxy("com.happyelements.android.utils.DownloadApkCallback", {
			onSuccess = onSuccess,
			onProcess = onProcess,
		})
		DownloadUtil:regTimer(_downloadCallback)
	end
	
	-- event
	local function addOB()
		GlobalEventDispatcher:getInstance():addEventListener(NetworkUtil.Events.kNetworkStatusChange, function ( ... )
			self:onNetworkChanged()
		end)

		GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kSceneNoPanel,function()
			if isLog then log("kGlobalEvents.kSceneNoPanel"..tostring(self.justSuccess),self.noWifiAlert) end
			if self.noWifiAlert or self.progressPanel then
				return
			end
			--加延时，因为从游戏场景退出时，会先发 kSceneNoPanel 再发 kReturnFromGamePlay。需要延时，来判断是否游戏场景退出
			setTimeOut(function()
				self:onEnter()
				end,0.1)
		end)

		GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kReturnFromGamePlay, function(evt)
			if isLog then log("kGlobalEvents.kReturnFromGamePlay",table.tostring(evt)) end
			local levelID = evt and evt.data and evt.data.id or 0
			local isSuperLevel = LevelType:isWeeklyRaceLevel(levelID)
			self:_onReturnFromGamePlay(isSuperLevel)
		end)
	end
	
	setTimeOut(addOB,1)
end

function UpdatePackageManager:checkState( )
	if isLog then log("checkState()") end

	local state = UpdatePackageManager.States.kUnstart

	if self:isInGameDownload() then
		if self.downloadApkThread or self.downloadPatchThread then
			state = UpdatePackageManager.States.kDownloading
		end
	    if UpdatePackageUtil:isApkExist() then
			state = UpdatePackageManager.States.kFinish
	    end
	else
		local isDownloading
		local systemDownloadID = UpdatePackageModel:getInstance():getDownloadID()
		if systemDownloadID and systemDownloadID>=0 then
			self.downloadManagerState = DownloadUtil:isEnabled() and DownloadUtil:getDownloadState(systemDownloadID)
			-- null0
	        -- DownloadManager.STATUS_PENDING,
	        -- DownloadManager.STATUS_RUNNING,
	        -- DownloadManager.STATUS_PAUSED,
	        -- DownloadManager.STATUS_SUCCESSFUL,
	        -- DownloadManager.STATUS_FAILED
	        isDownloading = self.downloadManagerState == 1 or self.downloadManagerState == 2
			if isLog then log("checkState()state"..tostring(self.downloadManagerState).."-"..tostring(isDownloading)) end
			if isDownloading then
				state = UpdatePackageManager.States.kDownloading
			end
		end
		
		if not isDownloading and UpdatePackageUtil:isApkDownloadSuccess() then
			state = UpdatePackageManager.States.kFinish
		end
	end
	
	self:setState(state)
end

function UpdatePackageManager:onNetworkChanged( ... )
	if isLog then log("onNetworkChanged",self:hasUpdate(),self:isFinish(),self:isInGameDownload(),NetworkUtil:getNetworkStatus(),self.state) end
	if not self:hasUpdate() then
		return
	end
	if self:isFinish() then
		return
	end
	if not self:isInGameDownload() then
		return
	end

	if NetworkUtil:getNetworkStatus() == NetworkUtil.NetworkStatus.kWifi then
		if self:isDownloading() then
			self:cancelDownload()
			self:checkState()
		else
			self:_startDownload()
		end
	end
end

function UpdatePackageManager:onClickIcon()
	if not __ANDROID then
		return
	end

	self:checkState()

	if self:isFinish() then
		self:_toInstall(false,1)

	elseif self:isDownloading() then
		if NetworkUtil:getNetworkStatus() == NetworkUtil.NetworkStatus.kWifi then
			dc("show_progress_panel",1)
			self:showProgressPanel()
		end
	elseif NetworkUtil:getNetworkStatus()==NetworkUtil.NetworkStatus.kNoNetwork then
		-- Alert:create("没有网络，请联网重试")
	else
		self:startDownload()
	end
end

--进入home场景。刚启动游戏、退出关卡、最小化后恢复、关闭弹框等
--刚进入游戏，第一次执行到Pop弹框队列
function UpdatePackageManager:onEnter(afterPopCallback)
	if isLog then log("UpdatePackageManager:onEnterFromHome()_self:canForcePop():" .. tostring(self:canForcePop()),NetworkUtil:getNetworkStatus()) end

	if not self:canForcePop() then
		return afterPopCallback and afterPopCallback()
	end

	self.afterPopCallback = afterPopCallback

	local isCurScene = Director:sharedDirector():run() == HomeScene:sharedInstance()
	local isEmptyPop = not PopoutManager:sharedInstance():haveWindowOnScreen()
	if isLog then log("UpdatePackageManager:onEnterFromHome()" .. tostring(isCurScene)..tostring(isEmptyPop),self.justSuccess) end
	if not isCurScene or not isEmptyPop then
		return
	end

	if isLog then log("onEnterFromHome()1") end
	if self.justSuccess then
		self:_toInstall(true,2)
		return
	end
	if self:isFinish() then
		if isLog then log("onEnterFromHome()2-0",
			"self.justReturnFromSuperLevel:" .. tostring(self.justReturnFromSuperLevel),
			"getTodayLevelCount:" .. tostring(UpdatePackageModel:getInstance():getTodayLevelCount())) end

		if UpdatePackageModel:getInstance():notifiFirstInstall() then
			if isLog then log("onEnterFromHome()2-01-notifiFirstInstall()") end
			self:_toInstall(true,4)
		end
		
		if isLog then log("onEnterFromHome()2-1") end
		
		self:setHomeIconText("ready")
		if not self.justReturnFromSuperLevel and UpdatePackageModel:getInstance():getTodayLevelCount()<1 then
			return
		end
		if isLog then log("onEnterFromHome()2-2") end

		if UpdatePackageModel:getInstance():notifiInstall() then
			if isLog then log("onEnterFromHome()2-3") end
			self:_toInstall(false,3)
		end
		return
	end

	if isLog then log("onEnterFromHome()3") end
	if self:canStart() then
		if isLog then log("onEnterFromHome()4-"..tostring(UpdatePackageModel:getInstance():getTodayLevelCount())) end
		local isTooManyError = self.state == UpdatePackageManager.States.kError and self.errorTimes-self.justPatchErrorTimes>=3
		if not isTooManyError then
			self:startDownload(true)
		end
	end
	if self.justReturnFromGamePlay then
		self.justReturnFromGamePlay=false
	end

	self.alreadyFirstOnEnter = true
end

function UpdatePackageManager:canForcePop()
	if not __ANDROID then
		return false
	end
	if not self:hasUpdate() then
		return false
	end
	
	-- if self.alreadyFirstOnEnter then
	-- 	return false
	-- end

	-- if self:isFinish() then
	-- 	self:setHomeIconText("ready")
	-- 	return false
	-- end
	return true
end

function UpdatePackageManager:setHomeIconText(...)
	if not HomeScene:sharedInstance().updateVersionButton then
		return
	end
	local t={...}
	-- if isLog then log("setHomeIconText",unpack(t)) end
	HomeScene:sharedInstance().updateVersionButton:setText(unpack(t))
end

--退出游戏 isSuperLevel 周赛等特殊关卡，直接触发更新逻辑，不参与计数
function UpdatePackageManager:_onReturnFromGamePlay(isSuperLevel)
	if isLog then log("onReturnFromGamePlay()"..tostring(isSuperLevel)) end
	if not self:hasUpdate() then
		return
	end
	self.justReturnFromGamePlay=true
	self.justReturnFromSuperLevel=isSuperLevel
	if not isSuperLevel then
		self:onMainLevelEnd()
	end
end

function UpdatePackageManager:onMainLevelEnd()
	if isLog then log("onMainLevelEnd()") end
	UpdatePackageModel:getInstance():onMainLevelEnd()
end

function UpdatePackageManager:hasUpdate()
	if not __ANDROID then
		return false
	end
	-- if isLog then log("hasUpdate()0-enabled") end
	if not UpdatePackageManager:enabled() then
		return false
	end
	-- if isLog then  log("hasUpdate()0-hasPackageUpdate()"..tostring(NewVersionUtil:hasPackageUpdate())) end
	if not NewVersionUtil:hasPackageUpdate() then 
		return false
	end
	return true
end

function UpdatePackageManager:canStart()
	-- if isLog then log("hasUpdate()0-isZombieBreak-"..tostring(self.justReturnFromGamePlay)..tostring(self.justReturnFromSuperLevel)) end
	if UpdatePackageModel:getInstance():isZombieBreak(self.justReturnFromGamePlay and self.justReturnFromSuperLevel) then
		return false
	end
	-- if isLog then log("hasUpdate()0-getTopLevelId..isZombieBreak_NO") end
	if not self:isEngoughLevel() then
		return false
	end
	return true
end

function UpdatePackageManager:isEngoughLevel()
	return UserManager.getInstance().user:getTopLevelId() >= 40
end

function UpdatePackageManager:canShowIcon()
	return self:hasUpdate() and self:canStart()
end

function UpdatePackageManager:startDownload(isAutoStart)
	if isLog then log("startDownload()"..tostring(self.state),tostring(isAutoStart)) end

	self.justPatchErrorTimes = 0

	if self:isFinish() then
		self:_toInstall(true,99)
		return false
	end
	-- if isLog then log("startDownload()0") end
	if self:isDownloading() then
		if isLog then log("startDownload()isDownloading") end
		return false
	end
	-- if isLog then log("startDownload()1") end
	if not self:hasUpdate() then
		return false
	end
	-- if isLog then log("startDownload()2") end
	if not self:canStart() then
		return false
	end
	-- if isLog then log("startDownload()3") end

	if YYBYsdkPlatform and YYBYsdkPlatform:isUpdateBySelf() then
		self:_showYYBAlert()
		return true
	end

	-- if isLog then log("startDownload()4") end

	local net = NetworkUtil:getNetworkStatus()
	local function onCheckDownload()
		self:setHomeIconText("zero")

		if net == NetworkUtil.NetworkStatus.kWifi then
			dc("start_download",isAutoStart and 1 or 0)
			if not isAutoStart or not self.alreadyFirstOnEnter then
				if not self.progressPanel then
					dc("show_progress_panel",isAutoStart and 0 or 2)
					self:showProgressPanel()
				end
			end
			self:_startDownload()

		elseif net == NetworkUtil.NetworkStatus.kMobileNetwork then
			if self.totalSize and self.totalSize>0 then
				dc("show_update_confirm",isAutoStart and 0 or 2)
				self:_showNotWifiAlert(not isAutoStart)
			else
				self:_checkSizeAndNotifi()
			end
		end
	end
	
	self:_checkPatch(onCheckDownload)

	if net == NetworkUtil.NetworkStatus.kWifi then
		if not isAutoStart or not self.alreadyFirstOnEnter then
			dc("show_progress_panel",isAutoStart and 0 or 2)
			self:showProgressPanel()
		end
	end
end

function UpdatePackageManager:_checkSizeAndNotifi()
	if isLog then log("_checkSizeAndNotifi()",self.patchUrl,self.isPatchError,self.totalSize) end

	local function sizeCallback()
		self:setHomeIconText("zero")

		self.waitSizeCallback = nil
		dc("show_update_confirm",0)
		self:_showNotWifiAlert()
	end

	if self.totalSize and self.totalSize>0 then
		sizeCallback()
		return
	end

	self.totalSize = 0
	self.waitSizeCallback=nil

	local function getSizeByDownload()
		--预下载方式获取实际大小有时会有问题，强制返回固定值
		self.totalSize = 111222344
		sizeCallback()

		--预下载方式获取实际大小
		--self.waitSizeCallback = sizeCallback
		--dc("start_download",2)
		--self:_startDownloadToCheckSize()
	end

	if not self.patchUrl or self.isPatchError then
		local sizeUrl = UpdatePackageUtil:getSizeUrl()
		if isLog then log("checkSizeUrl()",sizeUrl) end
		if not sizeUrl or string.len(sizeUrl)<=1 then
			getSizeByDownload()
			return
		end

		local function onCheckSizeResponse(response)
			if response.httpCode == 200 then
				self.totalSize = tonumber(response.body)
				sizeCallback()
			else
				getSizeByDownload()
			end
		end

		local request = HttpRequest:createGet(sizeUrl)
		request:setConnectionTimeoutMs(2 * 1000)
		request:setTimeoutMs(30 * 1000)
		HttpClient:getInstance():sendRequest(onCheckSizeResponse, request)
	else
		getSizeByDownload()
	end
end

function UpdatePackageManager:_startDownloadToCheckSize()
	local isDownloadFullApk = not self.patchUrl or self.isPatchError

	local javaModifyVer = MainActivityHolder.ACTIVITY:getLatestModify()
	if not javaModifyVer or javaModifyVer<8 then
		--旧版预下载方式获取实际大小有时会有无法终止的问题，新版java修复并增加downloadToCheckSize方法，旧版强制返回固定值
		self.totalSize = isDownloadFullApk and 115194516 or 24068096
		local _ = self.waitSizeCallback and self.waitSizeCallback()
		return
	end

	if isLog then log("_startDownloadToCheckSize()fullApk:"..tostring(isDownloadFullApk),"self.patchUrl:"..tostring(self.patchUrl),"self.isPatchError:"..tostring(self.isPatchError)) end

	local function onProcessWaitSize ( total )
		if isLog then log("onProcessWaitSize",total) end
		self.totalSize = tonumber(total)
		local _ = self.waitSizeCallback and self.waitSizeCallback()
	end

	local function onErrorPatchSize( )
		if isLog then log("onProcessWaitSize",self.totalSize) end
		self.patchUrl=nil
		self.isPatchError=true
		self:_startDownloadToCheckSize()
	end

	local url = isDownloadFullApk and UpdatePackageUtil:getApkUrl() or self.patchUrl
	local cbs = {
		onWaitSize = onProcessWaitSize,
		onError = isDownloadFullApk and self.downloadCallback.onError or onErrorPatchSize
	}
	local downloadSizeCallback = luajava.createProxy("com.happyelements.android.utils.DownloadApkCallback",cbs)
	HttpUtil:downloadToCheckSize(url, downloadSizeCallback)
end

function UpdatePackageManager:_checkPatch(callback)
	if isLog then log("_checkPatch()"..tostring(NetworkUtil:getNetworkStatus())) end
	if self.isPatchError then
		callback()
		return
	end

	local isEnabled = MaintenanceManager:getInstance():isEnabledInGroup('newUpdate1808', 'hepatch', UserManager:getInstance().uid)
	if isLog then log("_checkPatch()isEnabled:"..tostring(isEnabled)) end
	isEnabled = true
	if not isEnabled then
		callback()
		return
	end
	self.patchUrl = nil
	local updateInfo = UserManager:getInstance().updateInfo or {}
	local version = updateInfo.version or ''
	local md5 = updateInfo.md5	or ''
	local savePath = UpdatePackageUtil:getApkPath(version)
	local appName = nil
	local hepatch = require("hepatch")
	local oldMd5 = hepatch and self.installedApkPath and hepatch.md5ZipWithoutComment(self.installedApkPath) or ""

	local checkPatch = MaintenanceManager:getInstance():isEnabledInGroup('hepatch', 'A1', UserManager:getInstance().uid)
	checkPatch = checkPatch and not UpdatePackageUtil:isThirdLink()
	checkPatch = checkPatch and type(md5) == "string" and md5 ~= "" and type(oldMd5) == "string" and oldMd5 ~= ""

	if not checkPatch then
		if isLog then log("checkPatch()not_checkPatch " .. tostring(oldMd5) .. "-" .. tostring(md5)) end

		callback()
		return
	end

	self.state = UpdatePackageManager.States.kPreDownloading

	local function onCheckPatchResponse(response)
		if isLog then log("onCheckPatchResponse()" .. table.tostring(response)) end

		self.state = UpdatePackageManager.States.kUnstart

		if response.httpCode ~= 200 then
			callback()
			return
		end
		local msg = table.deserialize(response.body)
		if not (msg and msg.data and type(msg.data.url) == "string" and msg.data.url ~= "") then
			callback()
			return
		end

		self.patchUrl = msg.data.url
		callback(self.patchUrl)
	end

	local calutronRequestUrl = URL_CALUTRON.."&md5old="..oldMd5.."&md5new="..md5
	local request = HttpRequest:createGet(calutronRequestUrl)
	request:setConnectionTimeoutMs(2 * 1000)
	request:setTimeoutMs(30 * 1000)
	HttpClient:getInstance():sendRequest(onCheckPatchResponse, request)
end

function UpdatePackageManager:isInGameDownload()
	if isLog then log("isInGameDownload()","self.waitSizeCallback&self.patchUrl",self.waitSizeCallback,self.patchUrl) end
	if self.waitSizeCallback or self.patchUrl then
		return true
	end
	local updateInfo = UserManager:getInstance().updateInfo or {}
	local isSysDownload = updateInfo.downloadCategory and updateInfo.downloadCategory==1
	if not isSysDownload then
		return true
	end
	local switch = MaintenanceManager:getInstance():isEnabledInGroup('newUpdate1808', 'isSysDownload', UserManager:getInstance().uid)
	if not switch then
		return true
	end
	isSysDownload = DownloadUtil:isEnabled()
	return not isSysDownload
end

function UpdatePackageManager:_startDownload()
	if isLog then log("_startDownload()") end

	self:setState(UpdatePackageManager.States.kPreDownloading)

	if self.noWifiAlert then
		self.noWifiAlert:onClose()
		self.noWifiAlert=nil
	end

	local updateInfo = UserManager:getInstance().updateInfo or {}
	local version = updateInfo.version or ''
	local md5 = updateInfo.md5	or ''
	local savePath = UpdatePackageUtil:getApkPath(version)
	local appName = nil
	local hepatch = require("hepatch")
	local oldMd5 = hepatch and self.installedApkPath and hepatch.md5ZipWithoutComment(self.installedApkPath) or ""

	local isInGameDownload = self:isInGameDownload()

	if isInGameDownload then
		HttpUtil:setNotificationVisible(true)
	end

	local delayTime = 0
	if self.downloadManagerState and self.downloadManagerState>0 then
		DownloadUtil:remove()
		self.downloadManagerState=nil
		if NetworkUtil:getNetworkStatus()~= NetworkUtil.NetworkStatus.kWifi then
			delayTime = 0.3
		end 
	end

	local onProcess = self.downloadCallback.onProcess

	local function onStart ( downloadID )
		if isLog then log("onStart",downloadID) end
		UpdatePackageModel:getInstance():saveDownloadID(downloadID)
	end

	local function downloadFullPackage()
        -- ToastTip:create("开始下载完整包:"..(isInGameDownload and "游戏内下载" or "系统下载"))
		local url = UpdatePackageUtil:getApkUrl()
		if isLog then log("downloadFullPackage()" ,isInGameDownload,url) end
		local cbs = {
			onSuccess = self.downloadCallback.onSuccess,
			onError = self.downloadCallback.onError,
			onProcess = self.downloadCallback.onProcess,
			onStart = onStart
		}

		if isInGameDownload then
			local downloadCallback = luajava.createProxy("com.happyelements.android.utils.NewDownloadApkCallback", cbs)
			self.downloadApkThread = HttpUtil:newDownloadApk(url, savePath, appName, downloadCallback)
		else
			local downloadCallback = luajava.createProxy("com.happyelements.android.utils.DownloadApkCallback", cbs)
			DownloadUtil:download(url, savePath,downloadCallback)
		end
		
		UpdatePackageModel:onStartDownload({
			isInGameDownload = isInGameDownload,
			isFullPackage = true,
			size = self.totalSize
			})

		self:setHomeIconText("ing", 0)
	end


	if not self.patchUrl or self.isPatchError then
		setTimeOut(downloadFullPackage,delayTime)
	else
		local tempApkSavePath = savePath .. ".origin"
		local patchUrl = self.patchUrl
		if isLog then log("hepatch_patchUrl " .. patchUrl) end

		local patchName = _G.packageName.."."..oldMd5.."_"..md5..".patch"
		local patchSavePath = FileUtils:getApkDownloadPath(MainActivityHolder.ACTIVITY:getContext()).."/"..patchName

		local function onPatchError()
			if isLog then log("onPatchError()") end

			if FileUtils:isExist(tempApkSavePath) then
				HeFileUtils:removeFile(tempApkSavePath)
			end
			if FileUtils:isExist(patchSavePath) then
				HeFileUtils:removeFile(patchSavePath)
			end

			HttpUtil:setNotificationVisible(false)

			self.totalSize=0
			self.isPatchError=true
			self.isForceShowSize=true
			self.justPatchErrorTimes = self.justPatchErrorTimes+1

			local net = NetworkUtil:getNetworkStatus()
			if net == NetworkUtil.NetworkStatus.kWifi then
				downloadFullPackage()
			else
				self:_checkSizeAndNotifi()
			end
		end

		local function onErrorPatch(code)
			if isLog then log("hepatch_load_patch_errorCode:" .. tostring(code),"url: " .. patchUrl) end
			dc("download_error",{isPatch=true})

			self.totalSize=0
			local net = NetworkUtil:getNetworkStatus()
			if net == NetworkUtil.NetworkStatus.kWifi then
				onPatchError()
			else
				--4G下载patch失败，自动重试一次，再次失败则下载完整包
				self.justPatchErrorTimes = self.justPatchErrorTimes+1
				if isLog then log("hepatch_onPatchError " .. self.justPatchErrorTimes) end
				
				if self.justPatchErrorTimes<=MAX_PATCH_ERROR_TIMES then
					dc("start_download",3)
					HttpUtil:setNotificationVisible(false)
					self:_startDownload()
				else
					onPatchError()
				end
			end
		end

		local function onSuccessPatchCheck(...)
			if isLog then log("hepatch_onSuccessPatch000()",onProcess,self.totalSize, self.totalSize) end
			self.lastPatchProgress=nil

			dc("download_completed",{isPatch=true})

			onProcess(self.totalSize, self.totalSize)

			HttpUtil:updateDownloadApkNotification(100)

			local fail = true

			local function onSuccessPatchEnd(commit)
				if HeFileUtils:moveFile(tempApkSavePath, savePath) then
					if isLog then log("hepatch_update.apk_success.commit",tostring(commit).."-path:"..tostring(savePath)) end
					fail = false
					HeFileUtils:removeFile(patchSavePath)
					self.downloadCallback.onSuccess()
				else
					onPatchError()
				end
			end

			if isLog then log("hepatch_begin_patch") end
			local result = hepatch.patch(self.installedApkPath, patchSavePath, tempApkSavePath)
			if result == 0 then
				if isLog then log("hepatch_begin_verify md5") end
				local function  doVerify()
					local verify = hepatch.md5ZipWithoutComment(tempApkSavePath)
					if verify == md5 then
						local function getApkSource()
							if __ANDROID then
								local context = MainActivityHolder.ACTIVITY:getContext()
					  			local comment = ApplicationHelper:getApkSource(context)
					  			if comment then
					  				return HeDisplayUtil:urlEncode(comment)
								end
							end
							return nil
						end
						local apkSource = getApkSource()
						if isLog then log("apkSource:" .. tostring(apkSource)) end
						if apkSource and string.len(apkSource)==2 then
							if hepatch.addZipComment(tempApkSavePath, apkSource) == 0 then
								onSuccessPatchEnd(apkSource)
							else
								if isLog then log("hepatch.addZipComment_failed.apkSource:" .. tostring(apkSource)) end
							end
						else
							onSuccessPatchEnd()
						end
					else
						if isLog then log("hepatch_verify_failed:"..tostring(verify)) end
					end
				end
				doVerify()
			else
				if isLog then log("hepatch.patch()failed:"..tostring(result)) end
			end

			if fail then
				if isLog then log("hepatch_failed","remove patch and full download.") end
				onPatchError()
			end
		end

		local function onSuccessPatch(...)			
			setTimeOut(onSuccessPatchCheck,0.1)
		end

		local function onProcessPatch(progress, total)
			if self.lastPatchProgress and self.lastPatchProgress>progress then
				return
			end
			self.lastPatchProgress=progress
			self.downloadCallback.onProcess(progress, total)
		end

		local cbs = {
			onSuccess = onSuccessPatch,
			onError = onErrorPatch,
			onProcess = onProcessPatch
		}
		local downloadPatchCallback = luajava.createProxy("com.happyelements.android.utils.DownloadApkCallback",cbs)

		if isInGameDownload then
			self.downloadPatchThread = HttpUtil:downloadPatch(patchUrl, patchSavePath, downloadPatchCallback)
		else
			DownloadUtil:download(patchUrl, patchSavePath, downloadPatchCallback)
		end

		UpdatePackageModel:onStartDownload({
			isInGameDownload = isInGameDownload,
			isFullPackage = false,
			size = self.totalSize
			})
	end
end

function UpdatePackageManager:clearThread()
	self.downloadApkThread=nil
	self.downloadPatchThread=nil
end

function UpdatePackageManager:cancelDownload()
	--系统下载 取消
	DownloadUtil:remove()

	--游戏内下载 取消
	if self.downloadApkThread then
		HttpUtil:interruptDownloadThread(self.downloadApkThread)
		self.downloadApkThread = nil
	end

	--下载 补丁 取消
	if self.downloadPatchThread then
		HttpUtil:interruptDownloadThread(self.downloadPatchThread)
		self.downloadPatchThread=nil
	end
	--隐藏 下载通知
	HttpUtil:setNotificationVisible(false)
end

function UpdatePackageManager:onExitInstall()
	self.isExitInstall = true
	self:_toInstall(true)
end

function UpdatePackageManager:_toInstall(forceInstall,source)
	if isLog then log("_toInstall"..tostring(forceInstall)..source) end

	if YYBYsdkPlatform and YYBYsdkPlatform:isUpdateBySelf() then
		self:_showYYBAlert(self.isExitInstall)
		return true
	end

	self.justSuccess = nil
	self:setHomeIconText("ready")
	local installSource = forceInstall and source or 3
	local function onOK()
		dc("install_apk", installSource)
		local apkPath = UpdatePackageUtil:getApkPath()
		PackageUtils:installApk(
			MainActivityHolder.ACTIVITY:getContext(), 
			apkPath
		)
	end

	if forceInstall then
		onOK()
		UpdatePackageModel:getInstance():notifiInstall()
	else
		dc("show_install_confirm", source-1)

		local function onClickOK(  )
			dc("click_install_confirm",0)
			onOK()
		end

		local function onClickCancel(  )
			dc("click_install_confirm",1)
		end

		local params={}
		params.isConfirm = true
		params.info = "版本已下载完成，是否安装？"
		params.strOK = "安装"
		params.strCancel = "取消"
		params.okCallback = onClickOK
		params.cancelCallback = onClickCancel
		Alert:create(params)
	end
end

function UpdatePackageManager:_showYYBAlert(forceInstall)
	if isLog then log("UpdatePackageManager:_showYYBAlert()",forceInstall) end

	local function toInstallByYYB()
		YYBYsdkPlatform:startUpdate()
	end

	if forceInstall then
		dc("install_by_yyb",0)
		toInstallByYYB()

	else
		local net = NetworkUtil:getNetworkStatus()
		if net == NetworkUtil.NetworkStatus.kWifi then
			local function onClickOK(  )
				dc("install_by_yyb",{t0 = 1,size = YYBYsdkPlatform.patchSize})
				toInstallByYYB()
			end

			local function onClickCancel(  )
				dc("install_by_yyb",{t0 = 2,size = YYBYsdkPlatform.patchSize})
			end

			local params={}
			params.isConfirm = true
			params.info = "好消息！现在可以下载新版本了！"
			params.title = "可以更新啦!!"
			params.strOK = "更新"
			params.strCancel = "取消"
			params.okCallback = onClickOK
			params.cancelCallback = onClickCancel
			local alert = Alert:create(params)

		elseif net == NetworkUtil.NetworkStatus.kMobileNetwork then
			local function onClickOK(  )
				dc("install_by_yyb",{t0 = 3,size = YYBYsdkPlatform.patchSize})
				toInstallByYYB()
			end

			local function onClickCancel(  )
				dc("install_by_yyb",{t0 = 4,size = YYBYsdkPlatform.patchSize})
			end

			local params={}
			params.isConfirm = true
			params.info = "当前为3G/4G网络，是否消耗流量下载更新？"
			if YYBYsdkPlatform.patchSize and YYBYsdkPlatform.patchSize>1 then
				params.tip = "补丁大小: " .. math.floor(YYBYsdkPlatform.patchSize/1024/1024*100)/100 .. "M"
			end
			params.strOK = "下载"
			params.strCancel = "取消"
			params.okCallback = onClickOK
			params.cancelCallback = onClickCancel
			local alert = Alert:create(params)
		end

	end

end

function UpdatePackageManager:_showNotWifiAlert(force)
	if isLog then log("UpdatePackageManager:showNotWifiAlert()",
		"self.noWifiAlert:" .. tostring(self.noWifiAlert),
		"self.justPatchErrorTimes:" .. tostring(self.justPatchErrorTimes),
		"-self.justReturnFromSuperLevel:"..tostring(self.justReturnFromSuperLevel),
		"-force:"..tostring(force),
		"-self.isForceShowSize"..tostring(self.isForceShowSize)) end

	force = force or self.isForceShowSize

	self.totalSize=self.totalSize or 0
	
    if not force then
    	local canShowTip = UpdatePackageModel:getInstance():notifiFirst4G()
	    if canShowTip then
		    if isLog then log('_showNotWifiAlert()checkFirstTip',canShowTip,"-"..table.tostring(data)) end
		else
    		if self.justReturnFromSuperLevel or UpdatePackageModel:getInstance():getTodayLevelCount()>=1 then
				canShowTip = UpdatePackageModel:getInstance():notifi4G()
			else
			    if isLog then log('_showNotWifiAlert()not_enough_level' ,UpdatePackageModel:getInstance():getTodayLevelCount(),"-"..table.tostring(data)) end
    		end
    	end
		if not canShowTip or self.noWifiAlert then
		    if isLog then log('_showNotWifiAlert()canT_tip' ,UpdatePackageModel:getInstance():getTodayLevelCount(),"-"..table.tostring(data)) end
			return
		end
    end

	local function onCloseAlert()
		if self.afterPopCallback then
			self.afterPopCallback()
			self.afterPopCallback = nil
		end

		self.noWifiAlert = nil
	end

	local showSize = math.floor(self.totalSize/1024/1024*100)/100

    if isLog then log('_showNotWifiAlert()do:' ,self.hadNotWifiAlertShow,self.justPatchErrorTimes,self.justPatchErrorTimes) end
	if self.hadNotWifiAlertShow and self.justPatchErrorTimes and self.justPatchErrorTimes>0 then
		local function onClickOK(  )
			dc("click_download_fail",{t0 = 0,size = showSize})
			self:_startDownload(5)
		end

		local function onClickCancel(  )
			dc("click_download_fail",{t0 = 1,size = showSize})
		end

		local params={}
		params.isConfirm = true
		params.info = "网络中断，是否重新下载"
		
		if showSize>1 then
			params.tip = "补丁大小: " .. showSize .. "M"
		end
		params.strOK = "下载"
		params.strCancel = "取消"
		params.okCallback = onClickOK
		params.cancelCallback = onClickCancel
		local alert = Alert:create(params)
		return
	end
		
	local function showSizeAlert()
		if isLog then log("UpdatePackageManager:showNotWifiAlert()showSizeAlert()") end
		local function onClickOK(  )
			dc("click_download_4g",{t0 = 0,size = showSize})
			self:_startDownload(4)
			onCloseAlert()
		end

		local function onClickCancel(  )
			dc("click_download_4g",{t0 = 1,size = showSize})
			onCloseAlert()
			self.hadNotWifiAlertShow=false
		end

		local params={}
		params.isConfirm = true
		params.info = "当前为3G/4G网络，是否消耗流量下载更新？"
		
		if showSize>1 then
			params.tip = "补丁大小: " .. showSize .. "M"
		end
		params.strOK = "下载"
		params.strCancel = "取消"
		params.okCallback = onClickOK
		params.cancelCallback = onClickCancel

		local alert = Alert:create(params)
		self.noWifiAlert=alert
	end
	showSizeAlert()
	self.hadNotWifiAlertShow=true
end

function UpdatePackageManager:showProgressPanel()
	if self.progressPanel then
		return
	end
	self.progressPanel = UpdatePackageProgress:create()
	self.progressPanel.closeCallback = function ()
		dc("close_progress_panel",{tNow = self.nowSize,tTotal = self.totalSize})
		self.progressPanel = nil
		if self.afterPopCallback then
			self.afterPopCallback()
			self.afterPopCallback = nil
		end
	end
end

function UpdatePackageManager:isFinish( ... )
	if YYBYsdkPlatform and YYBYsdkPlatform:isUpdateBySelf() then
		return self:isEngoughLevel()
	end
	return self.state == UpdatePackageManager.States.kFinish
end

function UpdatePackageManager:setState(value)
	-- if isLog then log("setState()"..tostring(value)) end
	self.state = value
end

function UpdatePackageManager:isDownloading( ... )
	return self.state == UpdatePackageManager.States.kDownloading or self.state == UpdatePackageManager.States.kPreDownloading
end

function UpdatePackageManager:setProgressCallback( fn )
	self.onProcessCB = fn
	local _ = fn and fn(self.nowSize,self.totalSize)
end

function UpdatePackageManager:getApkPath(version)
	return UpdatePackageUtil:getApkPath(version)
end

return UpdatePackageManager