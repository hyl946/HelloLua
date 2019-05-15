
TurnTable2019Manager = class()

local instance = nil

local luckyBagType = {
    None = 0,
    SilverBag = 1,
    GoldBag = 2,
}

local ACT_ID = 5007
local VERSION = 1
local kStorageFileName = "TurnTable2019_"..VERSION
local kLocalDataExt = ".ds"

local function getActInfo()
    local actInfo
    for k, v in pairs(UserManager:getInstance().actInfos or {}) do
        if v.actId == ACT_ID then
            actInfo = v
            break
        end
    end
    return actInfo    
end

local function getUid()
	local uid = '12345'
	if UserManager and UserManager:getInstance().user then
		uid = UserManager:getInstance().user.uid or '12345'
	end
	uid = tostring(uid)
	return uid
end

--转换时间戳 为本地时区结构
local function TimeToTable( time )
    local DayData

    if time then
        DayData = os.date("*t",time/1000)
    end

    if DayData then
        local year = DayData.year
        local month = DayData.month
        local day = DayData.day
        local hour = DayData.hour
        local min = DayData.min
        local sec = DayData.sec

        return {
            year=tonumber(year),
            month=tonumber(month),
            day=tonumber(day),
            hour=tonumber(hour),
            min=tonumber(min),
            sec=tonumber(sec),
        }
    else
        return {
            year=1988,month=1,day=1,hour=0,min=0,sec=0,
        }
    end
end

function TurnTable2019Manager.getInstance()
	if not instance then
		instance = TurnTable2019Manager.new()
		instance:init()
	end
	return instance
end

function TurnTable2019Manager:init()

    self.bInitSaveFile = false

    self.minLevel = 0
    self.maxLevel = 0
    self.startTime = TimeToTable()
    self.endTime = TimeToTable()

    self.uid = getUid()
	self.filePath = HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName .. self.uid .. kLocalDataExt

    self.CurIsAct = false --当前关是否激活了活动

    self:readFromLocal()

    local ActInfo = getActInfo()
    if ActInfo and ActInfo.extra then
        local info  = table.deserialize( ActInfo.extra or {} )
        self.minVer = tonumber(info.version)
        self.supportedPlatforms = info.plantform
        self.channel = info.channel
        self.minLevel = tonumber(info.minLevel)
        self.maxLevel = tonumber(info.maxLevel)
        self.lastPlayTopLevel = tonumber(info.lastPlayTopLevel)

        --转换开始结束时间
        self.startTime = TimeToTable(info.startTime)
        self.endTime = TimeToTable(info.endTime)

        self.bInitSaveFile = true
	    self:writeToLocal()
    end
end

function TurnTable2019Manager:isActInMainTime( ... )
    return (Localhost:timeInSec() > os.time2(self.startTime) and Localhost:timeInSec() <= os.time2(self.endTime))
end

function TurnTable2019Manager:getCurIsAct( ... )
    return self.CurIsAct
end

function TurnTable2019Manager:beforeInGame( levelID, startLevelType )

    local bAskForHelp = false
    if startLevelType == StartLevelType.kAskForHelp then
        bAskForHelp = true
    end

    self.levelId = levelID
    self.CurIsAct = true
    self.levelPlayedCount = self:getLevelPlayedCount( self.levelId )
    self.curLevelCanGetInfo = self:curLevelCanGet( levelID, levelPlayedCount )
end

function TurnTable2019Manager:reset()
    self.levelId = 0
    self.CurIsAct = false
    self.levelPlayedCount = 0
    self.curLevelCanGetInfo = {}
end

function TurnTable2019Manager:isSupportPkg( ... )
    if __WIN32 then return true end

    if not self.supportedPlatforms then return false end

    for i,v in ipairs(self.supportedPlatforms) do

        if v == "All" then
            return true
        end

        if PlatformConfig:isPlatform(v) then
            return true
        end
    end

    return false
end

function TurnTable2019Manager:isUnSupportPkg( ... )
	if _G.isPrePackage or __WP8 or
	   not self:isSupportPkg() then
		return true
	end

	return false
end

function TurnTable2019Manager:isVersionSupport( ... )
	local ver = tonumber(string.split(_G.bundleVersion, ".")[2])
	return ver >= self.minVer
end

function TurnTable2019Manager:isLevelSupport()
    local levelID = UserManager.getInstance().user:getTopLevelId()
    if self.maxLevel == -1 then
        return levelID >= self.minLevel
    else
	    return ( levelID >= self.minLevel and levelID <= self.maxLevel )
    end
end

--关卡气泡是否支持
function TurnTable2019Manager:isActivitySupportBeforeGame( levelID, startLevelType )

--    if true then return true end
    local bAskForHelp = false
    if startLevelType == StartLevelType.kAskForHelp then
        bAskForHelp = true
    end

    --代打无法获得奖励
    if bAskForHelp == nil then bAskForHelp = false end 
    if bAskForHelp then return false end 

    local isCanActive = self:GetLevelIsCanActive(levelID)

    if isCanActive and self:isSupport(levelID) then
        return true
    end

    return false
end

--关卡气泡是否支持
function TurnTable2019Manager:isActivitySupport( levelID )

--    代打不支持
    if AskForHelpManager:getInstance():isInMode() then return false end

    local isCanActive = self:GetLevelIsCanActive(levelID)

    if isCanActive and self:isSupport(levelID) then
        return true
    end

    return false
end

--活动是否支持
function TurnTable2019Manager:isSupport(levelID)
    if self:isActInMainTime() and self:isVersionSupport() and not self:isUnSupportPkg() and self:isLevelSupport() then
        return true
    end

    return false
end

--获取关卡奖励
function TurnTable2019Manager:curLevelCanGet( levelID, PlayCount )
    local curLevelCanGet = {}
    local ticketNum = self:getTicketDoubleNum( levelID )

    local levelPlayCount = PlayCount or self:getLevelPlayedCount(levelID)

    --首次关卡 得金卡
    if levelPlayCount == 0 then
        curLevelCanGet.TicketType = luckyBagType.GoldBag
    else
        curLevelCanGet.TicketType = luckyBagType.SilverBag
    end
    curLevelCanGet.ticketNum = ticketNum

    return curLevelCanGet
end

--当前版本的满级 传入指定等级 按指定等级算 不传为当前版本最高级
function TurnTable2019Manager:isFullLevel( maxLevelID )
    local bMaxLevel = false

    local configTopLevel
    if maxLevelID then
        configTopLevel = maxLevelID
    else
        configTopLevel = NewAreaOpenMgr.getInstance():getLocalTopLevel()
--         configTopLevel, topAdjustY = NewAreaOpenMgr.getInstance():getCanPlayTopLevel()
    end
    local userTopLevel = UserManager:getInstance().user.topLevelId
    local userTopLevelPassed = UserManager:getInstance():hasPassedLevelEx(userTopLevel)

    if userTopLevel > configTopLevel or (userTopLevel == configTopLevel and userTopLevelPassed) then --满级
        bMaxLevel = true
    end

	return bMaxLevel
end

--是否是最高关
function TurnTable2019Manager:GetLevelIsCanActive( levelId )
    if not self:isFullLevel() then
        --普通打最高关
        local userTopLevel = UserManager:getInstance().user.topLevelId
        local topPassLevel= UserManager.getInstance():getTopPassedLevel()

        if levelId == userTopLevel then
            return true
        end
    end

    return false
end

function TurnTable2019Manager:getTicketDoubleNum( levelId )

    --这里不包含刷星关 只计算主线top 活动 关卡
    local ticketNum = 0
    local doubleNum = 0

    if LevelType:isMainLevel(levelId) then
        local levelFlag ,isFirst = MetaManager:getInstance():getLevelDifficultFlag_ForStartPanel( levelId )

        if levelId >=0 and levelId <= 100 then
            if levelFlag == LevelDiffcultFlag.kNormal then
                ticketNum = 1
            elseif levelFlag == LevelDiffcultFlag.kDiffcult then
                ticketNum = 1
            elseif levelFlag == LevelDiffcultFlag.kExceedinglyDifficult then 
                ticketNum = 1
            end
        elseif levelId >=101 and levelId <= 400 then
             if levelFlag == LevelDiffcultFlag.kNormal then
                ticketNum = 2
            elseif levelFlag == LevelDiffcultFlag.kDiffcult then
                ticketNum = 4
            elseif levelFlag == LevelDiffcultFlag.kExceedinglyDifficult then 
                ticketNum = 4
            end
        elseif levelId >=401 then
             if levelFlag == LevelDiffcultFlag.kNormal then
                ticketNum = 4
            elseif levelFlag == LevelDiffcultFlag.kDiffcult then
                ticketNum = 6
            elseif levelFlag == LevelDiffcultFlag.kExceedinglyDifficult then 
                ticketNum = 9
            end
        end
    end

    -- printx(61, 'levelID', levelID, doubleNum)

    return ticketNum
end

function TurnTable2019Manager:getLevelPlayedCount( levelId )
    local playCount = 0
    if self.lastPlayTopLevel == levelId then
        playCount = 1
    end
	return playCount
end

function TurnTable2019Manager:setLevelPlayedCount( levelId )
    self.lastPlayTopLevel = levelId
    self:writeToLocal()
end

function TurnTable2019Manager:readFromLocal()
	local file, err = io.open(self.filePath, "rb")

	if file and not err then
		local content = file:read("*a")
		io.close(file)

        local data = nil
        local function decodeContent()
            data = amf3.decode(content)
        end
        pcall(decodeContent)

		if data and type(data) == "table" then
            self.bInitSaveFile = data.bInitSaveFile or false
            self.minVer = data.minVer or 0
            self.supportedPlatforms = data.supportedPlatforms or {}
            self.channel = data.channel or {}
            self.minLevel = data.minLevel or 0
            self.maxLevel = data.maxLevel or 0
            self.startTime = data.startTime or TimeToTable()
			self.endTime = data.endTime or TimeToTable()
            self.lastPlayTopLevel = data.lastPlayTopLevel or 1
		end
	end
end

function TurnTable2019Manager:writeToLocal()
	local data = {}

    data.bInitSaveFile = self.bInitSaveFile
	data.minVer = self.minVer
    data.supportedPlatforms = self.supportedPlatforms
    data.channel = self.channel
    data.minLevel = self.minLevel
    data.maxLevel = self.maxLevel
    data.startTime = self.startTime
    data.endTime = self.endTime
    data.lastPlayTopLevel = self.lastPlayTopLevel

	local content = amf3.encode(data)
    local file = io.open(self.filePath, "wb")
    if not file then return end
	local success = file:write(content)
   
    if success then
        file:flush()
        file:close()
    else
        file:close()
    end
end

---------------------------------------------- Revert (后退一步/断面恢复) -----------------------------------------
function TurnTable2019Manager:getDataForRevert()

	local TurnTable2019Data = {}

    TurnTable2019Data.levelID = self.levelID
    TurnTable2019Data.CurIsAct = self.CurIsAct
    TurnTable2019Data.curLevelCanGetInfo = self.curLevelCanGetInfo
    TurnTable2019Data.levelPlayedCount = self.levelPlayedCount

	return TurnTable2019Data
end

function TurnTable2019Manager:setByRevertData(TurnTable2019Data)
	if TurnTable2019Data then
        self.CurIsAct = TurnTable2019Data.CurIsAct or false
        self.curLevelCanGetInfo = TurnTable2019Data.curLevelCanGetInfo or {}
        self.levelID = TurnTable2019Data.levelID or 0
        self.levelPlayedCount = TurnTable2019Data.levelPlayedCount or 0
	end
end