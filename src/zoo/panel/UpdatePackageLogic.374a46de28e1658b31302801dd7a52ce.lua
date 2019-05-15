--用途: 管理 大版本更新过程中 新包的下载逻辑
local WifiAutoDownloadManager = require 'zoo.data.WifiAutoDownloadManager'

local showDebugTrace = _G.isLocalDevelopMode
showDebugTrace = false

local function log(...)
	if not showDebugTrace then return end
	local t = {...}
	RemoteDebug:uploadLogWithTag('t---Up()'.. tostring(t[1]) ,table.tostring(t) .. " -- "..debug.traceback())
end

local hepatch = nil

if __ANDROID then
	local status, msg = xpcall(function() hepatch = require("hepatch") end, __G__TRACKBACK__)
	if showDebugTrace then log(-99,"UpdatePackageLogic(  )" .. tostring(hepatch)) end
end

local developerIds = {
	'30386'
}

-- 洗包配置表
-- key是一个函数，判断是否满足洗包条件
-- value是一个函数，返回对应的下载地址
-- 目前只有一条配置  [cuccwo 放量] -> [he]
local DirectionalUpdateCfg = {
	[function ( ... )
		local key = 'WashBag'
		if MaintenanceManager:getInstance():isEnabled(key) then
			if PlatformConfig:isCUCCWOPlatform() then
				local uid = UserManager:getInstance():getUID()
				uid = tonumber(uid)
				if uid then
					local num = MaintenanceManager:getInstance():getValue(key)
					num = tonumber(num or -1) or - 1
					if uid % 100 <= num then
						local location = UserManager:getInstance():getUserLocation()
						if location then 
							if location.province == '上海' or location.provinceId == '310000' or location.city == '上海' then
								return false
							end
						end

						return true
					end
				end
			end
		end

		return false

	end] = function ( version, md5 )
		-- return string.format('http://downloadapk.manimal.happyelements.cn/apk/com.happyelements.AndroidAnimal.%s.he.apk?t=%s', version, md5)
		return 'http://animalmobile.happyelements.cn/download.jsp?platform=he'
	end,
}

local function dc(sub_category,params)
	params = params or {}
	params.sub_category = sub_category
	params.category = params.category or "updatePackage"

	local updateInfo = UserManager:getInstance().updateInfo or {}
	local version = tostring(updateInfo.version) or ''
	params.tVersion = version
	params.vNow = tostring(_G.bundleVersion)
	params.isWifi = NetworkUtil:getNetworkStatus() == NetworkUtil.NetworkStatus.kWifi

	if params.category == "updatePackage" then
		DcUtil:UserTrackWithType(params, AcType.kExpire90Days)
	else
		DcUtil:UserTrack(params)
	end
end

local function isDeveloper()
	local uid = '12345'
    if UserManager and UserManager:getInstance().user then
    	uid = UserManager:getInstance().user.uid or '12345'
    end
    return table.exist(developerIds, tostring(uid))
end

local DownloadUtils = require 'zoo.panel.DownloadUtils'


local UpdatePackageLogic = class()

UpdatePackageLogic.States = {
	kUnstart = 'UpdatePackageLogic.States.kUnstart',              --当前没有下载线程，但本地可能已经一部分下载文件了，上一次没下完
	kDownloading = 'UpdatePackageLogic.States.kDownloading',  --当前有下载线程
	kFinish = 'UpdatePackageLogic.States.kFinish',            --当前updateInfo中指明的包已下载完
	kError = 'UpdatePackageLogic.States.kError'
}


--当前状态是kDownloading时， 下面的值指明 是 自动开始的下载，还是手动开始的下载
UpdatePackageLogic.DownloadStates = {
	kAuto = 'UpdatePackageLogic.DownloadStates.kAuto',
	kManual = 'UpdatePackageLogic.DownloadStates.kManual',
}



--updateinfo是会缓存的，key是MD5+大版本号。
--每次重进游戏，检查updateinfo指明的新包是否下载完，是的话 状态置为 finish，否则置为ready。




--常量 配置 

local staticUrlRoot = "http://downloadapk.manimal.happyelements.cn/"
local isTfApk = DcUtil:getSubPlatform() and string.len(DcUtil:getSubPlatform()) == 2
if isTfApk then
	staticUrlRoot = "http://apk.manimal.happyelements.cn/"
end

local calutronUrl = "http://patch.happyelements.cn/api?id=3"


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

local function getApkSource()
	if __ANDROID then
		local MainActivityHolder = luajava.bindClass("com.happyelements.android.MainActivityHolder")
		local ApplicationHelper = luajava.bindClass("com.happyelements.android.ApplicationHelper")
		local context = MainActivityHolder.ACTIVITY:getContext()
		if ApplicationHelper.getApkSource then
  			local comment = ApplicationHelper:getApkSource(context)
  			if comment then
  				return HeDisplayUtil:urlEncode(comment)
			end
		end
	end
	return nil
end

local instance

function UpdatePackageLogic:getInstance( ... )
	if not instance then
		instance = UpdatePackageLogic.new()
	end
	return instance
end

function UpdatePackageLogic:ctor( ... )
	self:init()
end

function UpdatePackageLogic:init( ... )
	self.state = UpdatePackageLogic.States.kUnstart
	self.data = {}

	self.downloadState = nil

	GlobalEventDispatcher:getInstance():addEventListener(NetworkUtil.Events.kNetworkStatusChange, function ( ... )
		self:onNetworkChanged()
	end)


	WifiAutoDownloadManager:getInstance():ad(WifiAutoDownloadManager.Events.kStateChange, function ( ... )
		self:onTurnChange()
	end)

	if NewVersionUtil:hasPackageUpdate() then
		self:initState()
	end

	local onUserLogin
	onUserLogin = function ( ... )
		if NewVersionUtil:hasPackageUpdate() then
			self:initState()
		end
    	GlobalEventDispatcher:getInstance():rm(kGlobalEvents.kUserLogin, onUserLogin)
	end
	GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kUserLogin, onUserLogin)

	self:initDownloadCallback()
end

function UpdatePackageLogic:onTurnChange( ... )

	if not NewVersionUtil:hasPackageUpdate() then 
		return
	end

	if WifiAutoDownloadManager:getInstance():isTurnOn() then
		if NetworkUtil:getNetworkStatus() == NetworkUtil.NetworkStatus.kWifi then
			if not self:isDownloading() then
				self:autoStartDownload()
				self:refreshUI()
			end
		end
	else
		if self.downloadState == UpdatePackageLogic.DownloadStates.kAuto then --
			if self:isDownloading() then
				DownloadUtils:cancelDownload()
				self:initState()
				self:refreshUI()
				self:popoutUpdatePageagePanel()
			end
		end
	end
end

function UpdatePackageLogic:onNetworkChanged( ... )

	if not NewVersionUtil:hasPackageUpdate() then 
		return
	end
	

	if WifiAutoDownloadManager:getInstance():isTurnOn() then

		if self.downloadState == UpdatePackageLogic.DownloadStates.kAuto then --
			if NetworkUtil:getNetworkStatus() == NetworkUtil.NetworkStatus.kMobileNetwork then
				if self:isDownloading() then
					DownloadUtils:cancelDownload()
					self:initState()
					self:refreshUI()
					self:popoutUpdatePageagePanel()
				end
			end
		end


		if NetworkUtil:getNetworkStatus() == NetworkUtil.NetworkStatus.kWifi then
			if not self:isDownloading() then
				self:autoStartDownload()
				self:refreshUI()
			end
		end

	end
end

function UpdatePackageLogic:popoutUpdatePageagePanel( ... )

	if not self.__popout_flag then
		self.__popout_flag = true
		UpdatePageagePanel:popoutIfNotExist()
	end
end

function UpdatePackageLogic:initState( ... )
	local updateInfo = UserManager:getInstance().updateInfo or {}
	local version = tostring(updateInfo.version) or ''
	if self:isApkExist(version) then
		self:setState(UpdatePackageLogic.States.kFinish, {apkPath = self:getApkPath(version)})
	else
		self:setState(UpdatePackageLogic.States.kUnstart)
	end
end

function UpdatePackageLogic:setDownloadState( downloadState )
	self.downloadState = downloadState
end

function UpdatePackageLogic:isAutoState( ... )
	return self.downloadState == UpdatePackageLogic.DownloadStates.kAuto
end

function UpdatePackageLogic:getState( ... )
	return self.state
end

function UpdatePackageLogic:setState( state, data )
	self.state = state
	self.data = data
end

function UpdatePackageLogic:getData( ... )
	return self.data
end

function UpdatePackageLogic:isDownloadSupport(checkPlatformName)

	if __WIN32 then 
		return false
	end
	if not __ANDROID then 
		return true
	end


	for checkFunc, urlFunc in pairs(DirectionalUpdateCfg) do
		if checkFunc() then
			return true
		end
	end

  	local androidPlatformName = checkPlatformName or StartupConfig:getInstance():getPlatformName()

	for i, platform in ipairs(noSupportPlatforms) do
		if platform == androidPlatformName then
	    	return false
		end
	end
	return true
	
end

--根据版本号 拼接出一个官方下载链接，
--有些渠道包，只有外部下载链接，没有官方链接，但这个函数不考虑这点
function UpdatePackageLogic:getApkOfficialUrl(version)
	local updateInfo = UserManager:getInstance().updateInfo or {}
	local t = tostring(updateInfo.md5)
	local androidPlatformName = StartupConfig:getInstance():getPlatformName()
	local isMini = StartupConfig:getInstance():getSmallRes() and "mini." or ""
	local lpsChannel = self:getLpsChannel()
	local apkName = _G.packageName .. "." ..isMini.. tostring(version) .. "." .. androidPlatformName .. lpsChannel .. ".apk"
	local apkUrl = staticUrlRoot .. "apk/" .. apkName .. "?t=" .. t
	return apkUrl
end

function UpdatePackageLogic:getLpsChannel( ... )
	local result = ""
	if StartupConfig:getInstance():getPlatformName() == PlatformNameEnum.kSj then
		local channelId = AndroidPayment.getInstance():getChinaMobileChannelId()
		if channelId and channelId ~= "2200144172" then
			result = "."..channelId
		end
	end
	return result
end

function UpdatePackageLogic:getApkName( version )
	local updateInfo = UserManager:getInstance().updateInfo or {}
	local md5 = tostring(updateInfo.md5) or ''
	local androidPlatformName = StartupConfig:getInstance():getPlatformName()
	local isMini = StartupConfig:getInstance():getSmallRes() and "mini." or ""
	local lpsChannel = self:getLpsChannel()
	local apkName = _G.packageName .. "." ..isMini.. tostring(version) .. "." .. androidPlatformName ..lpsChannel.. ".apk"
	return apkName
end

function UpdatePackageLogic:getApkNameWithMd5( version )
	local updateInfo = UserManager:getInstance().updateInfo or {}
	local md5 = tostring(updateInfo.md5) or ''
	local androidPlatformName = StartupConfig:getInstance():getPlatformName()
	local isMini = StartupConfig:getInstance():getSmallRes() and "mini." or ""
	local lpsChannel = self:getLpsChannel()
	local apkName = _G.packageName .. "." ..isMini.. tostring(version) .. tostring(md5) .. "." .. androidPlatformName ..lpsChannel.. ".apk"
	return apkName
end



function UpdatePackageLogic:getApkUrl(version)
	local updateInfo = UserManager:getInstance().updateInfo or {}
	local t = tostring(updateInfo.md5) or ''

	for checkFunc, urlFunc in pairs(DirectionalUpdateCfg) do
		if checkFunc() then
			return urlFunc(version, t)
		end
	end

	local apkName = self:getApkName(version)
	local apkUrl = staticUrlRoot .. "apk/" .. apkName .. "?t=" .. t
	if isTfApk then
		apkUrl = apkUrl .. "&source=" .. DcUtil:getSubPlatform()
	end
	local updateUrl = updateInfo.updateUrl
	if updateUrl then
		apkUrl = updateUrl
	end

	return apkUrl
end

function UpdatePackageLogic:getMd5Url( version )

	local apkUrl = self:getApkUrl(version)
	local md5Url = apkUrl:gsub("%.apk","%.md5")
	return md5Url

end


local cacheMd5 = {}

function UpdatePackageLogic:requestMd5( version, callback)
	local md5Url = self:getMd5Url(version)
	local key = md5Url:gsub("%?t=.+$","")
	if cacheMd5[key] then
		if callback then
			callback(cacheMd5[key])
		end
		return
	end
    local function onCallback(response)
		if response.httpCode ~= 200 then 
			if showDebugTrace then log(0, "get requestApkMd5 error code:" .. response.body) end
			if callback then
				callback("")
			end
		else
			if callback then
				callback(response.body)
			end

			cacheMd5[key] = response.body
		end
    end
	local request = HttpRequest:createGet(md5Url)
  	local connection_timeout = 2
  	if __WP8 then 
    	connection_timeout = 5
  	end
    request:setConnectionTimeoutMs(connection_timeout * 1000)
    request:setTimeoutMs(30 * 1000)
    HttpClient:getInstance():sendRequest(onCallback, request)
end

function UpdatePackageLogic:needCheckMd5( ... )
	for checkFunc, urlFunc in pairs(DirectionalUpdateCfg) do
		if checkFunc() then
			return false
		end
	end
	return not self:isThirdLink()
end

--是否从第三方外链下载
function UpdatePackageLogic:isThirdLink( ... )
	if isDeveloper() then return false end
	local updateInfo = UserManager:getInstance().updateInfo or {}
	local updateUrl = updateInfo.updateUrl
	return isTfApk or updateUrl
end

function UpdatePackageLogic:getApkPath( version )
	local FileUtils =  luajava.bindClass("com.happyelements.android.utils.FileUtils")
	local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder')
	local dir = FileUtils:getApkDownloadPath(MainActivityHolder.ACTIVITY:getContext())
	local apkName = self:getApkNameWithMd5(version)
	local apkPath = string.format('%s/%s', dir, apkName)
	return apkPath
end

function UpdatePackageLogic:getInstalledApkPath()
	local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder')
	local apkPath = MainActivityHolder.ACTIVITY:getContext():getApplicationInfo().sourceDir
	return apkPath
end

function UpdatePackageLogic:isApkExist( version )
	if not __ANDROID then
		return false
	end
	local FileUtils =  luajava.bindClass("com.happyelements.android.utils.FileUtils")
	return FileUtils:isExist(self:getApkPath(version))
end

function UpdatePackageLogic:setRefeshCallback( callback )
	self.refreshCallback = callback
end

function UpdatePackageLogic:refreshUI( ... )
	if self.refreshCallback then
		self.refreshCallback()
		return true
	else
		return false
	end
end

function UpdatePackageLogic:__startDownload(downloadState)
	if not __ANDROID then return end
	if showDebugTrace then log(0,"UpdatePackageLogic:__startDownload "..tostring(downloadState)) end

	local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder')
	local isInited=false

	local updateInfo = UserManager:getInstance().updateInfo or {}
	local version = tostring(updateInfo.version) or ''
	
	local savePath = self:getApkPath(version)

	local md5 = updateInfo.md5	
	local appName = nil

	local onFail = function ( ... )
		UpdatePackageLogic:getInstance():setState(UpdatePackageLogic.States.kError)

		if self:isAutoState() then
			self:popoutUpdatePageagePanel()
		end


		if self.downloadCallback and self.downloadCallback.onFail then
			self.downloadCallback.onFail(...)
		end
	end

	local totalSize = 100

	local onProcess = function ( progress, total )
		UpdatePackageLogic:getInstance():setState(UpdatePackageLogic.States.kDownloading, {
			percentage = math.floor(progress * 100 / total)
		})

		if self.downloadCallback and self.downloadCallback.onProcess then
			self.downloadCallback.onProcess(progress, total)
		end

		totalSize = total
	end


	local onSuccess = function ( ... )
		onProcess(totalSize, totalSize)

		if self.downloadCallback and self.downloadCallback.onSuccess then
			self.downloadCallback.onSuccess(...)
		end
	end

	local function onStart()
		UpdatePackageLogic:getInstance():setState(UpdatePackageLogic.States.kDownloading, {
			percentage = 0 
		})

		self:setDownloadState(downloadState)
	end

	local function downloadFullPackage()

		self.isWaitPatch=nil

		local url = self:getApkUrl(version)

		if showDebugTrace then RemoteDebug:uploadLogWithTag('t---downloadFullPackage()', url.." -- "..debug.traceback()) end
		if showDebugTrace then log(0,"UpdatePackageLogic:downloadFullPackage()" .. debug.traceback()) end

		local function onFullPackageSuccess()
			dc("onSuccess",{isPatch = false})
			onSuccess()
		end
		
		isInited = DownloadUtils:download(url, savePath, appName, onFullPackageSuccess, onFail, onProcess)
		onStart()
	end

	local installedApkPath = self:getInstalledApkPath()
	local oldMd5 = hepatch and hepatch.md5ZipWithoutComment(installedApkPath) or ""

	local patchEnabled = MaintenanceManager:getInstance():isEnabledInGroup('hepatch', 'A1', UserManager:getInstance().uid)
	if showDebugTrace then log(0,"UpdatePackageLogic:__startDownload() package update detected " .. version .. " md5-" .. md5.."-oldMd5:"..tostring(oldMd5) .. "-" .. tostring(checkPatch)) end
	if showDebugTrace then RemoteDebug:uploadLogWithTag('t---UpdatePackageLogic:__startDownload() package update detected', version .. " md5-" .. md5.."-oldMd5:"..tostring(oldMd5) .. "-" .. tostring(checkPatch)) end
		
	local checkPatch = patchEnabled and __ANDROID and not self:isThirdLink()
	checkPatch = checkPatch and type(md5) == "string" and md5 ~= "" and type(oldMd5) == "string" and oldMd5 ~= ""


	local function onPatchError(msg)
		dc("onPatchError",{errorMsg = msg})
		downloadFullPackage()
	end

	if not checkPatch then
		downloadFullPackage()
		dc("downloadFullPackage",{patchEnabled = patchEnabled,tMd5 = tostring(md5),curMd5 = tostring(oldMd5),isThirdLink = tostring(self:isThirdLink())})
	else
		if self.isWaitPatch then
			return
		end
		self.isWaitPatch=true

		--calutron hediff 检测
		local function onCheckPatchResponse(response)
			if showDebugTrace then log(0,"hepatch UpdatePackageLogic:__startDownload() onCheckPatchResponse " .. table.tostring(response)) end

			if response.httpCode ~= 200 then
				onPatchError("onCheckPatchResponse"..tostring(response.httpCode))
				return
			end
			local msg = table.deserialize(response.body)
			if not (msg and msg.data and type(msg.data.url) == "string" and msg.data.url ~= "") then
				onPatchError("noPatchData")
				return
			end

			local patchUrl = msg.data.url
			if showDebugTrace then log(0,"hepatch patchUrl " .. patchUrl) end

			local patchName = _G.packageName.."."..oldMd5.."_"..md5..".patch"
			local FileUtils =  luajava.bindClass("com.happyelements.android.utils.FileUtils")
			local patchSavePath = FileUtils:getApkDownloadPath(MainActivityHolder.ACTIVITY:getContext()).."/"..patchName

			local function onErrorPatch(code)
				if showDebugTrace then log(0,"hepatch load patch error, errorCode: " .. tostring(code) .. ", url: " .. patchUrl) end
				onPatchError("downloadPatch"..tostring(code))
			end

			local function onSuccessPatch(...)
				local fail = true
				local tempApkSavePath = savePath .. ".origin"

				local function onSuccessPatchEnd(commit)
					if HeFileUtils:moveFile(tempApkSavePath, savePath) then
						dc("onSuccess",{isPatch = true})
						if showDebugTrace then log(0,"hepatch update.apk success.commit:"..tostring(commit).."-path:"..tostring(savePath)) end
						fail = false
						HeFileUtils:removeFile(patchSavePath)
						onSuccess()
					else
						onPatchError("HeFileUtils:moveFile()Faild")
					end
				end

				if showDebugTrace then log(0,"hepatch begin patch") end
				local result = hepatch.patch(self:getInstalledApkPath(), patchSavePath, tempApkSavePath)
				local errorMsg = ""
				if result == 0 then
					if showDebugTrace then log(0,"hepatch begin verify md5") end
					local function  doVerify()
						local verify = hepatch.md5ZipWithoutComment(tempApkSavePath)
						if verify == md5 then
							local apkSource = getApkSource()
							if showDebugTrace then log("0","apkSource:" .. tostring(apkSource)) end
							if apkSource and string.len(apkSource)==2 then
								if hepatch.addZipComment(tempApkSavePath, apkSource) == 0 then
									onSuccessPatchEnd(apkSource)
								else
									errorMsg = "hepatch.addZipComment failed.apkSource:" .. tostring(apkSource)
									if showDebugTrace then log(0,"hepatch.addZipComment failed.apkSource:" .. tostring(apkSource)) end
								end
							else
								onSuccessPatchEnd()
							end
						else
							errorMsg = "hepatch verify failed:"..tostring(verify)
							if showDebugTrace then log(0,"hepatch verify failed:"..tostring(verify)) end
						end
					end
					local _,_ = xpcall(doVerify, __G__TRACKBACK__)
				else
					errorMsg = "hepatch.patch failed"..tostring(result)
					if showDebugTrace then log(0,"hepatch.patch failed"..tostring(result)) end
				end

				if fail then
					if showDebugTrace then log(0,"hepatch.patch failed.remove patch and full download.") end

					if FileUtils:isExist(tempApkSavePath) then
						HeFileUtils:removeFile(tempApkSavePath)
					end
					if FileUtils:isExist(patchSavePath) then
						HeFileUtils:removeFile(patchSavePath)
					end
					local UpdatePackageErrorCode_PATCH_FAIL=20180502
					-- onError(UpdatePackageErrorCode_PATCH_FAIL)
					onPatchError(errorMsg)
				end
			end

			local downloadPatchCallback = luajava.createProxy("com.happyelements.android.utils.DownloadApkCallback", {
				onSuccess = onSuccessPatch,
				onError = onErrorPatch,
				-- onProcess = onProcess
			})
			local HttpUtil = luajava.bindClass("com.happyelements.android.utils.HttpUtil")
			HttpUtil:downloadPatch(patchUrl, patchSavePath, downloadPatchCallback)
			-- DownloadUtils:download(patchUrl, patchSavePath, appName, onSuccessPatch, onErrorPatch, onProcess)
		end

		local calutronRequestUrl = calutronUrl.."&md5old="..oldMd5.."&md5new="..md5
		local request = HttpRequest:createGet(calutronRequestUrl)
		request:setConnectionTimeoutMs(2 * 1000)
		request:setTimeoutMs(30 * 1000)
		HttpClient:getInstance():sendRequest(onCheckPatchResponse, request)

		isInited=true
	end

	return isInited
end

function UpdatePackageLogic:needShowProgress()
	if __ANDROID and NewVersionUtil:canOpenMarket() then
		return false
	end
	return true
end

function UpdatePackageLogic:autoStartDownload()

	if not NewVersionUtil:hasPackageUpdate() then 
		return false
	end

	local function showIcon()
		local homeScene = HomeScene:sharedInstance()
		if not homeScene or not homeScene.updateVersionButton then return end
		homeScene.updateVersionButton:setText("ready")
		homeScene.updateVersionButton:setVisible(true)
	end

	if YYBYsdkPlatform and YYBYsdkPlatform:isUpdateBySelf() then
		showIcon()
		return false
	end

	if __ANDROID and NewVersionUtil:canOpenMarket() then
		showIcon()
		return false
	end

	if not WifiAutoDownloadManager:getInstance():isTurnOn() then
		return false
	end

	if NetworkUtil:getNetworkStatus() ~= NetworkUtil.NetworkStatus.kWifi then
		return false
	end

	if UpdatePackageLogic:getInstance():isDownloading() then
		return false
	end

	if UpdatePackageLogic:getInstance():isFinish() then
		return false
	end


	local updateInfo = UserManager:getInstance().updateInfo or {}
	local version = tostring(updateInfo.version) or ''

	if self:needCheckMd5() then
		self:requestMd5(version)
	end

	if self:__startDownload(UpdatePackageLogic.DownloadStates.kAuto) then
		return true
	end

	return false
end

function UpdatePackageLogic:checkDownloadOutside()
	if YYBYsdkPlatform and YYBYsdkPlatform:isUpdateBySelf() then
		return true
	end
	if __ANDROID and NewVersionUtil:canOpenMarket() then
		return true
	end
	return false
end

function UpdatePackageLogic:manualStartDownload()
	if YYBYsdkPlatform and YYBYsdkPlatform:isUpdateBySelf() then
		YYBYsdkPlatform:startUpdate()
		return false
	end

	if __ANDROID and NewVersionUtil:canOpenMarket() then
		NewVersionUtil:openMarket()
		return false
	end

	if self:__startDownload(UpdatePackageLogic.DownloadStates.kManual) then
	end
	return true
end

function UpdatePackageLogic:setDownloadCallback( onSuccess, onFail, onProcess )
	self.downloadCallback = {
		onSuccess = onSuccess,
		onFail = onFail,
		onProcess = onProcess,
	}
end

function UpdatePackageLogic:initDownloadCallback( ... )
	
	local function onSuccess()
		local updateInfo = UserManager:getInstance().updateInfo or {}
		local version = tostring(updateInfo.version) or ''

		if self:needCheckMd5() then
			self:requestMd5(version, function ( md5 )
				UpdatePageagePanel:onDownloadSuccess(md5, self:getApkPath(version))
			end)
		else
			UpdatePageagePanel:onDownloadSuccess('', self:getApkPath(version))
		end
	end

	local function onError( code )
		UpdatePageagePanel:onDownloadError(code)
	end

	local function onProcess(progress, total)
		if showDebugTrace then log(61, 'onProcess', progress, total) end
		UpdatePageagePanel:onDownloadProgress(progress, total)
	end

	self:setDownloadCallback(onSuccess, onError, onProcess)

end

function UpdatePackageLogic:toInstallApk( )
	local PackageUtils = luajava.bindClass("com.happyelements.android.utils.PackageUtils")
	local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder')
	PackageUtils:installApk(
		MainActivityHolder.ACTIVITY:getContext(), 
		UpdatePackageLogic:getInstance():getData().apkPath
	)
end

function UpdatePackageLogic:forceDownloadFullPackage( )
	if UpdatePackageLogic:getInstance():isFinish() then
		self:toInstallApk()
		return false
	end

	if UpdatePackageLogic:getInstance():isDownloading() then
		return false
	end

	self.isForceDownloadFullPackage = true
	self:__startDownload(UpdatePackageLogic.DownloadStates.kManual)
end

function UpdatePackageLogic:isFinish( ... )
	return self:getState() == UpdatePackageLogic.States.kFinish
end

function UpdatePackageLogic:isDownloading( ... )
	return self:getState() == UpdatePackageLogic.States.kDownloading
end

return UpdatePackageLogic