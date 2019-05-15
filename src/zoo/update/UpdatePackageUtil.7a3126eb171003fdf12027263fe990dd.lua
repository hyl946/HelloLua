
local UpdatePackageUtil = class()

--常量 配置 

local URL_DOWNLOAD_ROOT = "http://downloadapk.manimal.happyelements.cn/"
local isTfApk = DcUtil:getSubPlatform() and string.len(DcUtil:getSubPlatform()) == 2
if isTfApk then
    URL_DOWNLOAD_ROOT = "http://apk.manimal.happyelements.cn/"
end

local URL_CALUTRON = "http://patch.happyelements.cn/api?id=3"

local cacheMd5 = {}

--获取源站信息，从 apk 的注释获取，he 渠道为空
function UpdatePackageUtil:getApkSource()
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

--是否第三方渠道
function UpdatePackageUtil:isThirdLink()
    local result = false
    local updateInfo = UserManager:getInstance().updateInfo or {}
    result = isTfApk or updateInfo.updateUrl
    return result
end

function UpdatePackageUtil:getApkName( version,withMd5 )
    if not version then
        local updateInfo = UserManager:getInstance().updateInfo or {}
        version = tostring(updateInfo.version) or ''
    end
    local md5 = ""
    if withMd5 then
        local updateInfo = UserManager:getInstance().updateInfo or {}
        md5 = updateInfo.md5 and ("." .. tostring(updateInfo.md5)) or ''
    end
    local androidPlatformName = StartupConfig:getInstance():getPlatformName()
    local isMini = StartupConfig:getInstance():getSmallRes() and "mini." or ""
    local apkName = _G.packageName .. "." ..isMini.. tostring(version) .. tostring(md5) .. "." .. androidPlatformName .. ".apk"
    return apkName
end

--下载链接 官方
function UpdatePackageUtil:getApkOfficialUrl(version)
    local updateInfo = UserManager:getInstance().updateInfo or {}
    local t = tostring(updateInfo.md5)
    local apkName = self:getApkName(version)
    local apkUrl = URL_DOWNLOAD_ROOT .. "apk/" .. apkName .. "?t=" .. t
    return apkUrl
end

--下载链接。有些第三方渠道包，只有外部下载链接
function UpdatePackageUtil:getApkUrl(version)
    local updateInfo = UserManager:getInstance().updateInfo or {}
    local apkUrl = self:getApkOfficialUrl()

    if isTfApk then
        apkUrl = apkUrl .. "&source=" .. DcUtil:getSubPlatform()
    end
    if updateInfo.updateUrl then
        apkUrl = updateInfo.updateUrl
    end
    return apkUrl
end

--大小文件，仅官网CDN有此文件
function UpdatePackageUtil:getSizeUrl(apkUrl)
    if UpdatePackageUtil:isThirdLink() then
        return nil
    end
    if not apkUrl then
        apkUrl=UpdatePackageUtil:getApkUrl()
    end
    local sizeUrl = apkUrl:gsub("%.apk","%.size")
    return sizeUrl
end

--获取md5文件进行apk校验，仅官方CDN有这个文件
function UpdatePackageUtil:requestMd5( version, callback)
    if UpdatePackageUtil:isThirdLink() then return end
    
    local apkUrl = self:getApkOfficialUrl(version)
    local md5Url = apkUrl:gsub("%.apk","%.md5")
    local key = md5Url:gsub("%?t=.+$","")
    if cacheMd5[key] then
        if callback then
            callback(cacheMd5[key])
        end
        return
    end
    local function onCallback(response)
        if response.httpCode ~= 200 then 
            if showDebugTrace then printx(0, "get requestApkMd5 error code:" .. response.body) end
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

--目标版本apk是否已经存在
function UpdatePackageUtil:isApkExist( version )
    if not __ANDROID then
        return false
    end
    local FileUtils =  luajava.bindClass("com.happyelements.android.utils.FileUtils")
    return FileUtils:isExist(self:getApkPath(version))
end

--获取目标版本的本地保存路径
function UpdatePackageUtil:getApkPath( version )
    local FileUtils =  luajava.bindClass("com.happyelements.android.utils.FileUtils")
    local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder')
    local dir = FileUtils:getApkDownloadPath(MainActivityHolder.ACTIVITY:getContext())
    local apkName = self:getApkName(version,true)
    local apkPath = string.format('%s/%s', dir, apkName)
    return apkPath
end

--当前已装版本的apk路径
function UpdatePackageUtil:getInstalledApkPath()
    local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder')
    local apkPath = MainActivityHolder.ACTIVITY:getContext():getApplicationInfo().sourceDir
    return apkPath
end

-- 已经下载完毕
function UpdatePackageUtil:isApkDownloadSuccess()
    if not __ANDROID then
        return false
    end
    if not UpdatePackageUtil:isApkExist() then
        return false
    end

    local updateInfo = UserManager:getInstance().updateInfo or {}
    --printx(0,"UpdatePackageUtil:isApkDownloadSuccess()",updateInfo.md5)
    if not updateInfo.md5 then
        local DownloadUtil = luajava.bindClass("com.happyelements.android.utils.DownloadUtil")
        return DownloadUtil:isDownloadSuccess(self:getApkPath())
    end
    local curMd5 = HeMathUtils:md5File(self:getApkPath(version))
    --printx(0,"UpdatePackageUtil:isApkDownloadSuccess()",updateInfo.md5,curMd5)
    local isSuccess = updateInfo.md5 == curMd5
    return isSuccess
end

return UpdatePackageUtil