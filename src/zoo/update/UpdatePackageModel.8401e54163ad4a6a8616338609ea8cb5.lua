--版本更新相关数据

local UpdatePackageModel = class()


local instance

function UpdatePackageModel:getInstance( )
    if not instance then
        instance = UpdatePackageModel.new()
    end
    return instance
end

function UpdatePackageModel:ctor()
    local data = UpdatePackageModel:_readData()
    local key = "version"
    local updateInfo = UserManager:getInstance().updateInfo or {}
    local version = updateInfo.version or ''
    if data[key]~= version then
        if data[key] and data[key]~="" then
            UpdatePackageModel.justChangeVersion=data
        end
        data={}
        data[key] = version
    end

    local sc = Localhost:timeInSec()
    local day = os.date("%j", sc)
    data["today"] = day

    if UserManager.getInstance():getTopPassedLevel() < kMaxLevels then
        --zombie test
        local lastLoginTime = UserManager:getInstance().lastLoginTime or 0
        lastLoginTime = math.floor(lastLoginTime*0.001)
        local sc = Localhost:timeInSec()
        if lastLoginTime and lastLoginTime>0 and sc-lastLoginTime>30*24*3600 then
            local key = "zombieTag"
            data[key] = 1
            data["zombieTestLoginTime"] = lastLoginTime
        end
    end

    -- RemoteDebug:uploadLogWithTag('t-UpdatePackageModel()' ,table.tostring(data).."-"..debug.traceback())

    self:_saveData(data)
end

function UpdatePackageModel:_dataKey()
    return "updatePackage_" .. tostring(UserManager:getInstance().uid or "0") ..".ds"
end

function UpdatePackageModel:_readData()
    return Localhost.getInstance():readFromStorage(self:_dataKey()) or {}
end

function UpdatePackageModel:_saveData(data)
    --RemoteDebug:uploadLogWithTag('t-UpdatePackageModel:_saveData()' ,table.tostring(data).."-"..debug.traceback())

    Localhost.getInstance():writeToStorage(data, self:_dataKey())
end

--一天只自动提示一次wifi下载
function UpdatePackageModel:notifiWifi()
    --去掉限制
    do return true end
    local data = UpdatePackageModel:_readData()
    local key = "last4gUpdateAlertDay"
    local sc = Localhost:timeInSec()
    local today = os.date("%j", sc)
    if data[key] and math.abs(today-data[key])<1 then
        return false
    end
    data[key] = today
    self:_saveData(data)
    return true
end

--当日主线关次数
function UpdatePackageModel:getTodayLevelCount()
    local data = UpdatePackageModel:_readData()
    local sc = Localhost:timeInSec()
    local day = os.date("%j", sc)
    local levelDayKey = "todayLevelCountDay"
    -- RemoteDebug:uploadLogWithTag('t-notifi4G()getTodayLevelCount'..tostring(data[levelDayKey]).."-"..day ,"-"..table.tostring(data))
    if data[levelDayKey] and data[levelDayKey] ~= day then
        data[levelDayKey]=day
        return 0
    end
    local levelCountKey = "todayLevelCount"
    local count = tonumber(data[levelCountKey] and data[levelCountKey] or 0)
    return count
end

-- 4g下，一天内累计玩1次主线关卡提示下载，2天最多弹一次，首次有新版本可以直接弹
function UpdatePackageModel:notifi4G()
    local data = UpdatePackageModel:_readData()
    -- RemoteDebug:uploadLogWithTag('t-notifi4G()day:'..tostring(today) ,"-"..table.tostring(data))
    if UpdatePackageModel:notifiFirst4G() then
        -- RemoteDebug:uploadLogWithTag('t-notifi4G()UpdatePackageModel:notifiFirst4G()' ,"-"..tostring(data[keyFirst]))
        return false
    end
    local sc = Localhost:timeInSec()
    local today = os.date("%j", sc)
    local key = "last4gUpdateAlertDay"
    if data[keyFirst]==today then
        return false
    end
    -- RemoteDebug:uploadLogWithTag('t-notifi4G()day:'..tostring(today) ,"-"..table.tostring(data))
    if data[key] and math.abs(today-data[key])<2 then
        return false
    end
    data[key] = today
    self:_saveData(data)
    return true
end

function UpdatePackageModel:notifiFirst4G()
    local data = UpdatePackageModel:_readData()
    local sc = Localhost:timeInSec()
    local today = os.date("%j", sc)
    local keyFirst = "first4gUpdateAlert"
    local key = "last4gUpdateAlertDay"
    if not data[keyFirst] then
        data[keyFirst]=today
        data[key] = today
        self:_saveData(data)
        return true
    end
    return false
end

-- 未安装或一天内累计玩1次任意关卡弹出安装提示，一天最多弹出一次安装面板。
function UpdatePackageModel:notifiInstall()
    local data = UpdatePackageModel:_readData()
    local key = "lastInstallAlertDay"
    local sc = Localhost:timeInSec()
    local today = os.date("%j", sc)
    -- RemoteDebug:uploadLogWithTag('t-notifiInstall()today'.. today ,sc.."-"..tostring(data[key]))
    if data[key] and math.abs(today-data[key])<1 then
        return false
    end
    data[key] = today
    self:_saveData(data)
    return true
end

-- 首次安装提示
function UpdatePackageModel:notifiFirstInstall()
    local data = UpdatePackageModel:_readData()
    local key = "lastInstallAlertDay"
    local sc = Localhost:timeInSec()
    local today = os.date("%j", sc)
    --RemoteDebug:uploadLogWithTag('t-notifiFirstInstall()today'.. today ,sc.."-"..tostring(data[key]))
    if data[key] then
        return false
    end
    data[key] = today
    self:_saveData(data)
    return true
end

--是否僵尸用户
function UpdatePackageModel:isZombie()
    local data = UpdatePackageModel:_readData()
    local key = "zombieTag"
    if not data[key] then
        return false
    end
    return true
end

--是否僵尸用户中断更新。僵尸用户玩3次主线关 或者 周赛 后开始更新
function UpdatePackageModel:isZombieBreak(isSuperLevel)
    if not UpdatePackageModel:isZombie() then
        return false
    end
    if isSuperLevel then
        return false
    end
    if UpdatePackageModel:getTodayLevelCount()>=3 then
        return false
    end
    return true
end

-- 主线关卡结束
function UpdatePackageModel:onMainLevelEnd()
    -- 累计今日玩主线关次数
    local data = UpdatePackageModel:_readData()
    local levelCountKey = "todayLevelCount"
    local key = "todayLevelCountDay"
    local sc = Localhost:timeInSec()
    local today = os.date("%j", sc)
    if not data[key] or data[key]~=today then
        data[key] = today
        data[levelCountKey] = 0
    end
    data[levelCountKey] = (data[levelCountKey] or 0)+1
    -- RemoteDebug:uploadLogWithTag('t-UpdatePackageModel()onLevelEnd()' ,table.tostring(data).."-"..debug.traceback())
    self:_saveData(data)
end

function UpdatePackageModel:saveDownloadID(id)
    local data = UpdatePackageModel:_readData()
    data["downloadID"] = id
    self:_saveData(data)
end

function UpdatePackageModel:getDownloadID()
    local data = UpdatePackageModel:_readData()
    return data["downloadID"]
end

function UpdatePackageModel:onStartDownload(info)
    local data = UpdatePackageModel:_readData()
    if info then
        for k,v in pairs(info) do
            data[k]=v
        end
    end
    -- data.lastDownloadStartInfo = info
    data.downloadStartCount = (data.downloadStartCount or 0)+1
    self:_saveData(data)
end

return UpdatePackageModel