RecallA2019Manager = class()

local instance = nil

local VERSION = "1_"	--本地缓存标识 每次换皮应更改 
local ACT_SOURCE = 'RecallA2019/Config.lua'
local ACT_ID = 1034

local kStorageFileName = "RecallA2019_"..VERSION
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

local function parseTime( str,default )
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local year, month, day, hour, min, sec = string.match(str,pattern)
    if year and month and day and hour and min and sec then
        return {
            year=tonumber(year),
            month=tonumber(month),
            day=tonumber(day),
            hour=tonumber(hour),
            min=tonumber(min),
            sec=tonumber(sec),
        }
    else
        return default
    end
end

RecallA2019Manager.taskType = {
    kFirstLogin = 1,
    kCompleteLevel = 2,
}

RecallA2019Manager.mainBeginTime = parseTime("2019-03-11 10:00:00")
RecallA2019Manager.mainEndTime = parseTime("2019-03-17 23:59:59")

function RecallA2019Manager.getInstance()
	if not instance then
		instance = RecallA2019Manager.new()
		instance:init()
	end
	return instance
end

--{
--    targetValue = 17986,
--    rewarded = false,
--    type = 1,
--    rewards = {
--        1 = {
--                num = 1,
--                itemId = 50050,
--        },
--    },
--    currentValue = 17986,
--    id = 21,
--  }

function RecallA2019Manager:init()

    self.callerInviteCode = 0 --临时记录是否绑定了账号

    self.bInitSaveFile = false
	self.startLevel = 0
    self.backTasks = {}

    self.isActStartPanelBubble = false
    self.isActMission = false

	self.uid = getUid()
	self.filePath = HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName .. self.uid .. kLocalDataExt

    self:readFromLocal()

--    if not self.bInitSaveFile then
    local ActInfo = getActInfo()
    if ActInfo and ActInfo.extra then
        local info  = table.deserialize( ActInfo.extra or {} )

        self.backTasks = table.clone( info.backTasks )

        self.bInitSaveFile = true
	    self:writeToLocal()
    end
--    end
end

function RecallA2019Manager:isActTask( levelID )

    if self:isActInMainTime() and not PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk)  then
        if self.bInitSaveFile then

            local topLevelId = UserManager:getInstance().user:getTopLevelId()
            local topPassedLevelId = UserManager:getInstance():getTopPassedLevel()

            if levelID == topLevelId and topLevelId ~= topPassedLevelId then
                return true
            else
                return false
            end
        end
    end

    return false
end

function RecallA2019Manager:isActInMainTime( ... )
    return (Localhost:timeInSec() > os.time2(RecallA2019Manager.mainBeginTime) and Localhost:timeInSec() <= os.time2(RecallA2019Manager.mainEndTime))
end

function RecallA2019Manager:getCutLevelIsCanShowMission( levelID )

    if not self:isActTask(levelID) then return false end

    for i,v in pairs(self.backTasks) do
        if v.type == RecallA2019Manager.taskType.kCompleteLevel then
            if  v.currentValue < v.targetValue then
                return true, v
            end
        end
    end

    return false
end

--设置是否激活任务
function RecallA2019Manager:setActMission( bAct, levelID )
    self.isActMission = bAct
    self.startLevel = levelID

    self.needShowGetRewardAnim = false --是否显示获奖动画
    self.needShowInfo = {}

    self:writeToLocal()
end

function RecallA2019Manager:getActMission( )
    return self.isActMission
end

--设置是否激活气泡
function RecallA2019Manager:setActStartPanelBubble( bAct )
    self.isActStartPanelBubble = bAct
    self:writeToLocal()
end

function RecallA2019Manager:getActStartPanelBubble( )
    return self.isActStartPanelBubble and self:isActInMainTime()
end

--根据关卡获取任务信息
function RecallA2019Manager:getMissonInfo()
    local bFind = false
    local info = {}

    for i,v in pairs(self.backTasks) do
        if v.type == RecallA2019Manager.taskType.kCompleteLevel then
            if  v.currentValue < v.targetValue then
                bFind = true
                info = table.clone(v)
                break
            end
        end
    end

    if bFind then
        local newInfo = table.clone(info)
        return newInfo
    else
        return
    end
end

--过关
function RecallA2019Manager:setLevelPass()
    for i,v in pairs(self.backTasks) do
        if v.type == RecallA2019Manager.taskType.kCompleteLevel then
            if v.currentValue < v.targetValue then
                if v.currentValue < v.targetValue then
                    v.currentValue = v.currentValue + 1
                end

                if v.currentValue == v.targetValue then
                    self.needShowGetRewardAnim = true
                    self.needShowInfo = table.clone(v)

                    self:updateActIconRewardFlag(true)
                end
                break
            end
        end
    end

    self:writeToLocal()
end

function RecallA2019Manager:updateActIconRewardFlag( bShow )
	local ret = table.find(ActivityUtil:getActivitys() or {},function(v)
		return v.source == ACT_SOURCE
	end)
	if ret then 
		ActivityUtil:setRewardMark(ACT_SOURCE, bShow)
	end
end

function RecallA2019Manager:readFromLocal()
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
			self.startLevel = data.startLevel or 0
            self.backTasks = data.backTasks or {}
            self.isActMission = data.isActMission or false
            self.isActStartPanelBubble = data.isActStartPanelBubble or false
		end
	end
end

function RecallA2019Manager:writeToLocal()
	local data = {}
	data.startLevel = self.startLevel
    data.bInitSaveFile = self.bInitSaveFile
	data.startLevel = self.startLevel
    data.backTasks = self.backTasks
    data.isActMission = self.isActMission
    data.isActStartPanelBubble = self.isActStartPanelBubble

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