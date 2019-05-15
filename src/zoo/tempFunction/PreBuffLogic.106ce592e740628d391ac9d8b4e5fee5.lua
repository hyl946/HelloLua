local RANDOM_BIRD = 1
local LINE = 2
local WRAP = 3
local FIRECRACKER = 8

local function time2day(ts)
    ts = ts or Localhost:timeInSec()
    local utc8TimeOffset = 57600 -- (24 - 8) * 3600
    local oneDaySeconds = 86400 -- 24 * 3600
    local dayStart = ts - ((ts - utc8TimeOffset) % oneDaySeconds)
    return (dayStart + 8*3600)/24/3600
end



local PRE_BUFF_CLASS = 
{
    C01 = 1,
    C02 = 2,
    C03 = 3,
    C04 = 4,
    C05 = 5,
    C06 = 6,
    C07 = 7,
    C08 = 8,
    C09 = 9,
    C10 = 10,
}

local neg_inf = -999999

local _config = {
    
    [PRE_BUFF_CLASS.C01] = {
        max = 5,
        buffs = 
        {
            {buff = {RANDOM_BIRD}, count = 1},
            {buff = {RANDOM_BIRD, LINE},  count = 2}, 
            {buff = {RANDOM_BIRD, LINE, WRAP},  count = 3}, 
            {buff = {RANDOM_BIRD, LINE, WRAP, FIRECRACKER},  count = 4}, 
            {buff = {RANDOM_BIRD, RANDOM_BIRD, LINE, WRAP, FIRECRACKER},  count = 5}, 
        }, 
        canFuuu = true,
    }, 

    [PRE_BUFF_CLASS.C02] = {
        max = 5,
        buffs = 
        {
            {buff = {RANDOM_BIRD}, count = 1},
            {buff = {RANDOM_BIRD, LINE},  count = 2}, 
            {buff = {RANDOM_BIRD, LINE, WRAP},  count = 3}, 
            {buff = {RANDOM_BIRD, LINE, LINE, WRAP},  count = 4}, 
            {buff = {RANDOM_BIRD, LINE, LINE, WRAP, WRAP},  count = 5}, 
        }, 
        canFuuu = true,
    }, 

    [PRE_BUFF_CLASS.C03] = {
        max = 5,
        buffs = 
        {
            {buff = {FIRECRACKER}, count = 1},
            {buff = {FIRECRACKER, LINE},  count = 2}, 
            {buff = {FIRECRACKER, LINE, WRAP},  count = 3}, 
            {buff = {FIRECRACKER, LINE, LINE, WRAP},  count = 4}, 
            {buff = {FIRECRACKER, LINE, LINE, WRAP, WRAP},  count = 5}, 
        }, 
        canFuuu = true,
    }, 

    [PRE_BUFF_CLASS.C04] = {
        max = 3,
        buffs = 
        {
            {buff = {RANDOM_BIRD}, count = 1},
            {buff = {RANDOM_BIRD, LINE},  count = 2}, 
            {buff = {RANDOM_BIRD, LINE, WRAP},  count = 3}, 
        }, 
        canFuuu = true,
    }, 

    [PRE_BUFF_CLASS.C05] = {
        max = 3,
        buffs = 
        {
            {buff = {FIRECRACKER}, count = 1},
            {buff = {FIRECRACKER, LINE},  count = 2}, 
            {buff = {FIRECRACKER, LINE, WRAP},  count = 3}, 
        }, 
        canFuuu = true,
    },
    
    [PRE_BUFF_CLASS.C06] = {
        max = 5,
        buffs = 
        {
            {buff = {RANDOM_BIRD}, count = 1},
            {buff = {RANDOM_BIRD, LINE},  count = 2}, 
            {buff = {RANDOM_BIRD, LINE, WRAP},  count = 3}, 
            {buff = {RANDOM_BIRD, LINE, WRAP, FIRECRACKER},  count = 4}, 
            {buff = {RANDOM_BIRD, RANDOM_BIRD, LINE, WRAP, FIRECRACKER},  count = 5}, 
        }, 
        canFuuu = false,
    }, 

    [PRE_BUFF_CLASS.C07] = {
        max = 5,
        buffs = 
        {
            {buff = {RANDOM_BIRD}, count = 1},
            {buff = {RANDOM_BIRD, LINE},  count = 2}, 
            {buff = {RANDOM_BIRD, LINE, WRAP},  count = 3}, 
            {buff = {RANDOM_BIRD, LINE, LINE, WRAP},  count = 4}, 
            {buff = {RANDOM_BIRD, LINE, LINE, WRAP, WRAP},  count = 5}, 
        }, 
        canFuuu = false,
    }, 

    [PRE_BUFF_CLASS.C08] = {
        max = 5,
        buffs = 
        {
            {buff = {FIRECRACKER}, count = 1},
            {buff = {FIRECRACKER, LINE},  count = 2}, 
            {buff = {FIRECRACKER, LINE, WRAP},  count = 3}, 
            {buff = {FIRECRACKER, LINE, LINE, WRAP},  count = 4}, 
            {buff = {FIRECRACKER, LINE, LINE, WRAP, WRAP},  count = 5}, 
        }, 
        canFuuu = false,
    }, 

    [PRE_BUFF_CLASS.C09] = {
        max = 3,
        buffs = 
        {
            {buff = {RANDOM_BIRD}, count = 1},
            {buff = {RANDOM_BIRD, LINE},  count = 2}, 
            {buff = {RANDOM_BIRD, LINE, WRAP},  count = 3}, 
        }, 
        canFuuu = false,
    }, 

    [PRE_BUFF_CLASS.C10] = {
        max = 3,
        buffs = 
        {
            {buff = {FIRECRACKER}, count = 1},
            {buff = {FIRECRACKER, LINE},  count = 2}, 
            {buff = {FIRECRACKER, LINE, WRAP},  count = 3}, 
        }, 
        canFuuu = false,
    },
}

PreBuffLogic = {}

local buffUpgradeOnLastPlay = false
local buffUpgradeOnLastPlayForLevelInfo = false
local buffDisappear = false
local oldLevel = 0
local version_FromS = nil
function PreBuffLogic:loadLevelInfoSkeletonAssert()

    FrameLoader:loadArmature('tempFunctionRes/PreBuff002/showAction', 'showAction', 'showAction')
    FrameLoader:loadArmature('tempFunctionRes/PreBuff002/showAction_level0', 'showAction_level0', 'showAction_level0')
    FrameLoader:loadArmature('tempFunctionRes/PreBuff002/showAction_dis', 'showAction_dis', 'showAction_dis')
    FrameLoader:loadArmature('tempFunctionRes/PreBuff002/showAction_tips', 'showAction_tips', 'showAction_tips')
    FrameLoader:loadImageWithPlist("tempFunctionRes/PreBuff002/PreBuff002Png.plist")

end



function PreBuffLogic:unloadLevelInfoSkeletonAssert()
        
    ArmatureFactory:remove('showAction', 'showAction')
    ArmatureFactory:remove('showAction_level0', 'showAction_level0')
    ArmatureFactory:remove('showAction_dis', 'showAction_dis')
    ArmatureFactory:remove('showAction_tips', 'showAction_tips')
    FrameLoader:unloadImageWithPlists("tempFunctionRes/PreBuff002/PreBuff002Png.plist",true)

end

function PreBuffLogic:getBuffUpgradeOnLastPlay()
    return buffUpgradeOnLastPlay
end

function PreBuffLogic:getBuffDisappear()
    return buffDisappear
end
function PreBuffLogic:setBuffUpgradeOnLastPlay(value)
    buffUpgradeOnLastPlay = value
end

function PreBuffLogic:getBuffUpgradeOnLastPlayForLevelInfo()
    return buffUpgradeOnLastPlayForLevelInfo
end



function PreBuffLogic:getOldGrade()
    return oldLevel
end

function PreBuffLogic:setOldGrade( oldLevel_ )
    oldLevel = oldLevel_ 
end



function PreBuffLogic:setBuffUpgradeOnLastPlayForLevelInfo(value)
    if buffUpgradeOnLastPlayForLevelInfo and  not value then
        buffDisappear = true
    end
    buffUpgradeOnLastPlayForLevelInfo = value
end
function PreBuffLogic:doBuffDisappear()
    buffDisappear = false
end
function PreBuffLogic:updateUserDefKey()

    local key = self:getKey() 
    CCUserDefault:sharedUserDefault():setStringForKey( self:getKey() , time2day() )
    CCUserDefault:sharedUserDefault():flush()
    -- buffDisappear = false
end

function PreBuffLogic:willShowLevel0( levelId )

    if not self:checkEnableBuff( levelId ) then
        return false
    end
    local buffLevel = self:getBuffGradeAndConfig()
    if buffLevel > 0 then
        return false
    end
    local uid = '12345'
    if UserManager and UserManager:getInstance().user then
        uid = UserManager:getInstance().user.uid or '12345'
    end
    local dayIndex = CCUserDefault:sharedUserDefault():getStringForKey( self:getKey() , 0 )
    if tonumber(dayIndex) == tonumber(time2day()) then
        return false
    end
    return true
end



function PreBuffLogic:readVersionConfig( ... )
    local key = 'NewBuffFeature'
    PreBuffLogic:updateDataInfo() 
    if MaintenanceManager:getInstance():isEnabled(key) or __WIN32 then
        local extra = MaintenanceManager:getInstance():getExtra( key ) or ''
        if __WIN32 then
            -- extra = '100,2,2018-01-01 10:00:00,2018-06-06 23:59:59'
        end

        local version, style, y1, m1, d1, h1, min1, s1, y2, m2, d2, h2, min2, s2 = string.match(extra, "(%d+),(%d+),(%d%d%d%d)-(%d+)-(%d+) (%d+):(%d+):(%d+),(%d%d%d%d)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
        if version_FromS then
            version = version_FromS
        end
        if version and style and y1 and m1 and d1 and h1 and min1 and s1 and y2 and m2 and d2 and h2 and min2 and s2 then
            -- printx( 1 , "PreBuffLogic:readVersionConfig  self.versionData 11111111111111111111111111111111111" , debug.traceback() )
            self.versionData = {
                version = tonumber(version) or -1, -- 讲道理 %d匹配出来的, 应该会一定成功
                style = tonumber(style) or -1,
                beginTime = os.time({year = tonumber(y1) or 1970, month = tonumber(m1) or 1, day = tonumber(d1) or 1, hour = tonumber(h1) or 0, min = tonumber(min1) or 0, sec = tonumber(s1) or 0}),
                endTime = os.time({year = tonumber(y2) or 1970, month = tonumber(m2) or 1, day = tonumber(d2) or 1, hour = tonumber(h2) or 0, min = tonumber(min2) or 0, sec = tonumber(s2) or 0}),
            }
            return
        end

        local version, style, y1, m1, d1, y2, m2, d2 = string.match(extra, "(%d+),(%d+),(%d%d%d%d)-(%d+)-(%d+),(%d%d%d%d)-(%d+)-(%d+)")
        if version_FromS then
            version = version_FromS
        end
        if version and y1 and m1 and d1 and y2 and m2 and d2 then
            -- printx( 1 , "PreBuffLogic:readVersionConfig  self.versionData 22222222222222222222222222222222222" , debug.traceback())
            self.versionData = {
                version = tonumber(version) or -1, -- 讲道理 %d匹配出来的, 应该会一定成功
                style = tonumber(style) or -1,
                beginTime = os.time({year = tonumber(y1) or 1970, month = tonumber(m1) or 1, day = tonumber(d1) or 1}),
                endTime = os.time({year = tonumber(y2) or 1970, month = tonumber(m2) or 1, day = tonumber(d2) or 1}),
            }
        end

    end
end

function PreBuffLogic:getFilePath()
    if self:isActEnabled() then
        local uid = UserManager:getInstance().user.uid or '12345'
        return HeResPathUtils:getUserDataPath() .. '/pre_buff_xxl_new' .. uid .. '_v_' .. self.versionData.version 
    else
        return HeResPathUtils:getUserDataPath() .. '/pre_buff_xxl_new' .. uid .. '_error'
    end
end

--在活动期间, 但活动数据未必下载好了
function PreBuffLogic:isActEnabled( ... )

    -- printx( 102 , "PreBuffLogic:isActEnabled  self.versionData =" , table.tostring(self.versionData) ) 
    if self.versionData then
        local version = self.versionData.version or -1
        if version <= 0 then
            return false
        end

        local style = self.versionData.style or -1
        if style ~= 1 and style ~= 2 then 
            return false 
        end

        local beginTime = self.versionData.beginTime or 0
        local endTime = self.versionData.endTime or 0
        local now = Localhost:timeInSec()
        return now >= beginTime and now <= endTime
    end
    return false
end

function PreBuffLogic:getActEndTimeLeft()
    if self.versionData then
        local endTime = self.versionData.endTime or 0
        local now = Localhost:timeInSec()
        return endTime- now 
    end
    return 0
end



function PreBuffLogic:init()

    self:readVersionConfig()

    self:lazyInitData()
end

function PreBuffLogic:lazyInitData( ... )

    if self.__lazyInited then
        return
    end

    if not self:isActEnabled() then
        return
    end

    if not self.data then
        local file = io.open(self:getFilePath(), "r")
        if file then
            local data = file:read("*a") 
            file:close()
            self.data = table.deserialize(data) or {}
        else
            self.data = {}
        end
    end
    if not self.data.currentPoint then
        self.data.currentPoint = 0
        self.data.userClass = 0
        self.data.lastGrade = 0
        self.data.lastPoint = 0
        self.data.lastLevelId = 0
        self:flushData()
    else
        -- debug.debug()
        -- 初始化的时候把这几个值重置
        self.data.lastGrade = PreBuffLogic:getBuffGradeAndConfig()
        self.data.lastPoint = self.data.currentPoint
        self.data.lastLevelId = 0
        self:flushData()
    end

    self.__lazyInited = true
end



function PreBuffLogic:updateDataInfo() 
    local info = table.deserialize(UserManager:getInstance().preBuff or '{}') or {}
    local isEmpty = false
    info = info or {}
    info.currentPoint = info.energy or 0
    info.userClass = info.group or 0
    info.grade = info.grade or 0
    if not UserManager:getInstance().preBuff then
        isEmpty = true
    end

    if not isEmpty then
        PreBuffLogic:initFromActData( info ) 
    end
end

function PreBuffLogic:initFromActData(data) 

    self:lazyInitData()

    if not self.data then
        self.data = {}
    end
    self.data.currentPoint = data.currentPoint
    self.data.userClass = data.userClass
    -- seld.data.grade = data.grade
    -- self.data.lastGrade = PreBuffLogic:getBuffGradeAndConfig()
    -- self.data.lastPoint = data.currentPoint
    self:flushData()
end

function PreBuffLogic:getCurrentPoint()

    self:lazyInitData()

    if self:isActEnabled() then
        return self.data.currentPoint
    end
    return 0
end

function PreBuffLogic:addEnergy(count, levelId)

    self:lazyInitData()

    if not self:isActEnabled() then
        return
    end

    local buffUpgrade = false
    local config = PreBuffLogic:getBuffConfig()
    if not config then 
        return buffUpgrade 
    end
    local _max = config.max
    local oldGrade, _ = PreBuffLogic:getBuffGradeAndConfig()
    self.data.currentPoint = self.data.currentPoint + count
    if self.data.currentPoint > _max then
        self.data.currentPoint = _max
    elseif self.data.currentPoint < 0 then
        self.data.currentPoint = 0
    end
    local newGrade, _ = PreBuffLogic:getBuffGradeAndConfig()
    buffUpgrade = (newGrade > oldGrade)

    if newGrade == 0 then
        self.data.lastGrade = 0
        self.data.lastPoint = 0
    end
    
    self.data.lastLevelId = levelId

    -- self.data.lastGrade = newGrade    

    self:flushData()

    -- if __WIN32 then
    --     buffUpgrade = true
    -- end


    return buffUpgrade, oldGrade
end

function PreBuffLogic:getLastGrade()

    self:lazyInitData()

    if not self:isActEnabled() then
        return 0
    end

    return self.data.lastGrade
end

function PreBuffLogic:getVersion( ... )
    if self:isActEnabled() then
        return self.versionData.version
    end
end

function PreBuffLogic:getLastLevelId(clear)

    self:lazyInitData()

    if not self:isActEnabled() then
        return 0
    end

    local ret = self.data.lastLevelId
    if clear then
        self.data.lastLevelId = 0
        self:flushData()
    end
    return ret
end

function PreBuffLogic:getLastPoint()

    self:lazyInitData()

    if not self:isActEnabled() then
        return 0
    end
    -- return self.data.lastPoint
    return math.max(self.data.currentPoint - 1, 0)
end

function PreBuffLogic:updateLastPointAndGrade()

    self:lazyInitData()

    if not self:isActEnabled() then
        return
    end

    self.data.lastGrade = PreBuffLogic:getBuffGradeAndConfig()
    self.data.lastPoint = PreBuffLogic:getCurrentPoint()
    PreBuffLogic:flushData()
end

--获取buff等级
function PreBuffLogic:getBuffGradeAndConfig()

    if not self:isActEnabled() then
        return 0, {}
    end
    local config = PreBuffLogic:getBuffConfig()
    if not config then 
        return 0, {}
    end
    local grade = 0
    for i, v in ipairs(config.buffs) do
        if self.data.currentPoint >= v.count then
            grade = i
        end
    end
    local destConfig = {}
    local _config = PreBuffLogic:getBuffConfig()
    if grade > 0 then
        if _config.buffs[grade] then
            for k, v in ipairs(_config.buffs[grade].buff) do
                table.insert(destConfig, {buffType = v, createType = InitBuffCreateType.PRE_BUFF_ACTIVITY})
            end
        end
    end
    return grade, destConfig
end

function PreBuffLogic:getDescription( destConfig )
    local descriptionTable = {}
    for _, v in ipairs(destConfig or {}) do
        if v.buffType then
            table.insert(descriptionTable, v.buffType)
        end
    end
    table.sort(descriptionTable)
    local description = table.concat(descriptionTable, ' ')
    return description
end

function PreBuffLogic:getBuffInfos( ... )
    local grade, destConfig = self:getBuffGradeAndConfig()
    local description = self:getDescription(destConfig)
    return grade, destConfig, description
end

function PreBuffLogic:getDescriptionByUserClassAndGrade(userClass, grade )
    if userClass and _config[userClass] then
        if _config[userClass].buffs then
            if grade and _config[userClass].buffs[grade] then
                local buff = _config[userClass].buffs[grade].buff
                if buff then
                    table.sort(buff)
                    return table.concat(buff, ' ')
                end
            end
        end
    end
end

function PreBuffLogic:getMaxBuffGradeAndConfig(typeClass)
    local destConfig = {}
    local maxGrade = 1
    local config = _config[typeClass] or {}
    maxGrade = config.max or maxGrade
    if config.buffs[maxGrade] then
        for k, v in ipairs(config.buffs[maxGrade].buff) do
            table.insert(destConfig, {buffType = v})
        end
    end
    return maxGrade, destConfig
end

function PreBuffLogic:getBuffGradeAndConfigByClassGrade(typeClass, buffGrade)
    local destConfig = {}
    local maxGrade = buffGrade
    local config = _config[typeClass]
    if config.buffs[maxGrade] then
        for k, v in ipairs(config.buffs[maxGrade].buff) do
            table.insert(destConfig, {buffType = v})
        end
    end
    return maxGrade, destConfig
end

function PreBuffLogic:getBuffConfig()

    if not self:isActEnabled() then
        return nil
    end

    if not self.data or not self.data.userClass then
        return nil
    end
    return _config[self.data.userClass]
end

function PreBuffLogic:hasData( ... )
    -- body
end

function PreBuffLogic:flushData()

    if not self:isActEnabled() then
        return 
    end


    local filePath = self:getFilePath()
    local tmpName = filePath .. "." .. os.time()
    local file = io.open(tmpName, "w")
    if not file then return end
    local success = file:write(table.serialize(PreBuffLogic.data))
    if success then
        file:flush()
        file:close()
        os.remove(filePath)
        os.rename(tmpName, filePath)
    else
        file:close()
        os.remove(tmpName)
    end
end

function PreBuffLogic:getActSource( ... )
    local style = self:getStyle()

    local actSource
    if style == 1 then
        actSource = 'PreBuff001/Config.lua'
    elseif style == 2 then
        actSource = 'PreBuff002/Config.lua'
    end
    return actSource
end

function PreBuffLogic:getStyle( ... )

    if self:isActEnabled() then
        return self.versionData.style
    end
end

function PreBuffLogic:getBeginTime( ... )

    if self:isActEnabled() then
        return self.versionData.beginTime
    end
    return 0
end

function PreBuffLogic:getEndTime( ... )

    if self:isActEnabled() then
        return self.versionData.endTime
    end
    return 0
end
local skeletonLoadOrRemoveFlag = 0
function PreBuffLogic:logSkeletonLoadOrRemove( opr )
    if opr == "load" then
        if skeletonLoadOrRemoveFlag == 0 then
            skeletonLoadOrRemoveFlag = 1
        end
    elseif opr == "remove" then
        if skeletonLoadOrRemoveFlag == 1 then
            skeletonLoadOrRemoveFlag = 0
        end
    end
    
end

function PreBuffLogic:getSkeletonLoadOrRemoveLog()
    return skeletonLoadOrRemoveFlag
end

function PreBuffLogic:getInitFlyAnimSkeletonSourceName( ... )
    if self:getStyle() == 1 then
        return 'skeleton/BuffInitFlyInAnimation001'
    end
    return 'skeleton/BuffInitFlyInAnimation002'
end

function PreBuffLogic:canUseFUUU(  )
    local userClass = self:getUserClass()
    if userClass and _config[userClass] then
        return _config[userClass].canFuuu
    end
    return true
end

--对应的活动部分是否加载完成
function PreBuffLogic:isActOn()

    self:lazyInitData()

    if not self:isActEnabled() then
        return false
    end

    local actSource = self:getActSource()
    if not actSource then
        return false
    end

    local config
    for _,v in pairs(ActivityUtil:getActivitys()) do
        -- print(v.source)
        if v.source == actSource then
            config = require ('activity/'..v.source)
        end
    end
    local isInited = false
    if self.data and self.data.userClass and self.data.userClass ~= 0 then
        isInited = true
    end
    local isActOn = config 
    isActOn = isActOn and config.isSupport() 
    printx(102 , "function PreBuffLogic:isActOn() isActOn = " , isActOn )
    isActOn = isActOn and isInited
    printx(102 , "function PreBuffLogic:isActOn() isActOn = " , isActOn )
        
    return config and config.isSupport() and isInited
end

function PreBuffLogic:getKey(  )
    local uid = '12345'
    if UserManager and UserManager:getInstance().user then
        uid = UserManager:getInstance().user.uid or '12345'
    end
    -- local dayIndex = time2day()
    local key = "preBuffLogic.cache.data.2018.12.19." .. uid
    return key 
end

function PreBuffLogic:checkEnableBuffForLevelSuccess( levelId )
    if self.passLevelID == nil then
        return false
    end
    if levelId == nil then
        return false
    end
    return self.passLevelID == levelId
end

function PreBuffLogic:checkEnableBuff( levelId , ignoreActState )
    local topLevelId = tonumber(UserManager:getInstance().user:getTopLevelId())
    local scoreRef = UserManager:getInstance():getUserScore( levelId )
    if (PreBuffLogic:isActOn() or ignoreActState) and ( not scoreRef or scoreRef.star == 0 ) then
        if LevelType:isMainLevel(levelId) and topLevelId == levelId then
            return true
        elseif LevelType:isHideLevel(levelId) then
            return true
        end
    end
    return false
end


function PreBuffLogic:onPassLevel(levelId, newStar, isGuideLevel , result , failReason)

    self.passLevelID = nil
    local oldLevelScoreRef  = UserManager:getInstance():getUserScore(levelId)
    local oldStar = 0
    if oldLevelScoreRef then
        oldStar = oldLevelScoreRef.star
    end

    local isSuccess = (newStar > 0)
    local buffCount = 0
    local buffUpgrade = false
    local oldGrade = 0

    local topLevelId = UserManager:getInstance().user:getTopLevelId()


    if PreBuffLogic:checkEnableBuff( levelId , (not isSuccess) ) then
        local isJumpedLevel = JumpLevelManager:getInstance():hasJumpedLevel( levelId )
        local isAFHLevel = UserManager:getInstance():hasAskForHelpInfo(levelId)
        
        -- 是否升星
        local isUpgrade = (newStar > oldStar)
        -- 代打 跳关成功过关都给+1，所以不算isNewSuccess
        -- 其他普通关卡oldStar == 0就算是isNewSuccess
        local isNewSuccess = (oldStar == 0 and not isAFHLevel and not isJumpedLevel)

        if isSuccess then
            if isNewSuccess then
                -- buffCount = 2
                buffCount = 1 -- 虽然数值改之后，代码可以精简，但是考虑到数值改变的可能性，还是不精简了
            else
                if isUpgrade then
                    buffCount = 1
                else
                    buffCount = 0
                end
            end
        else
            buffCount = neg_inf
            local http = OpNotifyOffline.new(true)
            http:load( OpNotifyOfflineType.kSetPreBuffActivityEnergy , 0 )
        end

        buffUpgrade, oldGrade = PreBuffLogic:addEnergy(buffCount, levelId)
        DcUtil:activity({category = 'Buff', sub_category = 'Buff_stage_end', t1 = oldGrade, t2 = GamePlayContext:getInstance():getIdStr() , t3 = result , t4 = failReason } )
    end

    if buffUpgrade then
        self.passLevelID = levelId
    end
    self:setOldGrade( oldGrade )
    self:setBuffUpgradeOnLastPlay(buffUpgrade)
    self:setBuffUpgradeOnLastPlayForLevelInfo(buffUpgrade)



    return buffUpgrade
end

local upgradeAnimationPlaying = false

function PreBuffLogic:getUpgradeAnimationPlaying()
    return upgradeAnimationPlaying
end

function PreBuffLogic:getUserClass( ... )
    if self.data and self.data.userClass then
        return self.data.userClass
    end
end

function PreBuffLogic:getMaxGrade( ... )
    -- body
    local userClass = self:getUserClass()
    if userClass and _config[userClass] and _config[userClass].max then
        return _config[userClass].max
    end
    return 1
end

function PreBuffLogic:__playBuffUpgradeAnimation( callback )
    
    if PopoutManager:sharedInstance():haveWindowOnScreen_ForPreBuff()
            or HomeScene:sharedInstance().ladyBugOnScreen then
        if callback then callback() end
        return
    end
    self:setBuffUpgradeOnLastPlay(false)

    ----[[
    local newGrade, _, newDescription = self:getBuffInfos()
    local oldGrade = newGrade - 1
    local oldDescription = newDescription
    local userClass = self:getUserClass()
    oldDescription = self:getDescriptionByUserClassAndGrade(userClass, oldGrade) or oldDescription


    local curClassMaxGrade = self:getMaxGrade()

    if not (newGrade > 0 and newGrade <= curClassMaxGrade ) then
        if callback then callback() end
        return
    end

    local skeletonSourceName = self:getInitFlyAnimSkeletonSourceName()
    FrameLoader:loadArmature( skeletonSourceName )
    PreBuffLogic:logSkeletonLoadOrRemove( "load" )

    local UIHelper = require 'zoo.panel.UIHelper'
    


    local buffAnimePanelClass = class(BasePanel)

    function buffAnimePanelClass:create()
        local instance = buffAnimePanelClass.new()
        -- instance:loadRequiredResource('activity/PreBuff002/res/panel.json')
        instance:init()
        return instance
    end

    function buffAnimePanelClass:init()
        local ui = Layer:create()
        BasePanel.init(self, ui)
    end

    function buffAnimePanelClass:dispose()
        if skeletonAnime and skeletonAnime:getParent() and not skeletonAnime.isDisposed then
            skeletonAnime:stop()
            skeletonAnime:removeFromParentAndCleanup(true)
        end

        if PreBuffLogic:getSkeletonLoadOrRemoveLog() == "load" then
            FrameLoader:unloadArmature( skeletonSourceName , true)
            PreBuffLogic:logSkeletonLoadOrRemove( "remove" )
        end

        BasePanel.dispose(self)
    end

    local panel = buffAnimePanelClass:create()

    -- printx( 1 , "PreBuffLogic:playBuffUpgradeAnimation ~~~~~~~~~~~~~~~~ newGrade" , newGrade , "oldGrade" , oldGrade )

    

    local skeletonAnimeName = "BuffInitFlyInAnimation/BuffUpgrade_Holder"
    
    local skeletonAnime = ArmatureNode:create( skeletonAnimeName )
    
    
    local newCon = skeletonAnime:getCon('buffIconNew')
    local oldCon = skeletonAnime:getCon('buffIconOld')

    local UIHelper = require 'zoo.panel.UIHelper'

    local newIconSpriteFrame = 'prebuff_icon_res/sp/' .. newDescription .. '0000'
    local newIcon = UIHelper:createSpriteFrame('ui/prebuff_icons.json', newIconSpriteFrame)
    if newIcon then
        newIcon:setPosition(ccp(105, 105))
        newCon:addChild(newIcon.refCocosObj)
    end

    local oldIconSpriteFrame = 'prebuff_icon_res/sp/' .. oldDescription .. '0000'
    local oldIcon = UIHelper:createSpriteFrame('ui/prebuff_icons.json', oldIconSpriteFrame)
    if oldIcon then
        oldIcon:setPosition(ccp(105, 105))
        oldCon:addChild(oldIcon.refCocosObj)
    end

    local playUI = Director:sharedDirector():getRunningScene()
    local layer = playUI.guideLayer
    local wSize = Director:sharedDirector():getWinSize()
    local trueMask = LayerColor:create()
    trueMask:changeWidthAndHeight(wSize.width, wSize.height)
    trueMask:setTouchEnabled(true, 0, true)
    trueMask:setOpacity(180)

    skeletonAnime:setPositionXY( wSize.width / 2 , wSize.height * 0.2 * -1 )
    -- skeletonAnime:setPositionXY( wSize.width / 2 , 0 )

    skeletonAnime:ad(ArmatureEvents.COMPLETE, function ( ... )
        -- body
        if newIcon and (not newIcon.isDisposed) then
            newIcon:dispose()
        end

        if oldIcon and (not oldIcon.isDisposed) then
            oldIcon:dispose()
        end
    end)

    skeletonAnime:playByIndex(0)
    skeletonAnime:update(0.001) -- 此处的参数含义为时间
    upgradeAnimationPlaying = true
    --[[
    local slot_new = skeletonAnime:getSlot( "buffIconNew" )
    
    local emptySprite1 = Sprite:createEmpty()
    local icon1 = ArmatureNode:create( "BuffInitFlyInAnimation/AddBuff_" .. tostring(newGrade) .. "_icon" )
    emptySprite1:addChild( icon1 )
    emptySprite1:setAnchorPoint(ccp(0, 1))

    slot_new:setDisplayImage( emptySprite1.refCocosObj )

    local slot_old = skeletonAnime:getSlot( "buffIconOld" )
    
    local emptySprite2 = Sprite:createEmpty()
    local icon2 = ArmatureNode:create( "BuffInitFlyInAnimation/AddBuff_" .. tostring(oldGrade) .. "_icon" )
    emptySprite2:addChild( icon2 )
    emptySprite2:setAnchorPoint(ccp(0, 1))

    slot_old:setDisplayImage( emptySprite2.refCocosObj )
    ]]

    -- HomeScene:sharedInstance():addChild( trueMask )
    -- HomeScene:sharedInstance():addChild( skeletonAnime )

    panel.ui:addChild( skeletonAnime )
    PopoutManager:sharedInstance():add( panel , true , false , nil , nil , 200)
    
    --]]

    setTimeOut( function ()  
                    upgradeAnimationPlaying = false
                    local currentScene = Director:sharedDirector():getRunningSceneLua()

                    -- printx( 1 , "PreBuffLogic:playBuffUpgradeAnimation !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  " , debug.traceback())

                    if currentScene:is(HomeScene) and currentScene == playUI then -- 如果还在HomeScene上

                        if panel and panel:getParent() and not panel.isDisposed then
                            PopoutManager:sharedInstance():remove(panel)
                        end
                        
                        --[[
                        if skeletonAnime and skeletonAnime:getParent() and not skeletonAnime.isDisposed then
                            skeletonAnime:stop()
                            skeletonAnime:removeFromParentAndCleanup(true)
                        end

                        if trueMask and trueMask:getParent() and not trueMask.isDisposed then
                            trueMask:removeFromParentAndCleanup(true)
                        end

                        -- FrameLoader:unloadArmature( skeletonSourceName , true )
                        if PreBuffLogic:getSkeletonLoadOrRemoveLog() == "load" then
                            FrameLoader:unloadArmature( skeletonSourceName , true)
                            PreBuffLogic:logSkeletonLoadOrRemove( "remove" )
                        end
                        ]]

                        if callback then callback() end 
                    else

                        if panel and panel:getParent() and not panel.isDisposed then
                            PopoutManager:sharedInstance():remove(panel)
                        end

                        --[[
                        if skeletonAnime and skeletonAnime:getParent() and not skeletonAnime.isDisposed then
                            skeletonAnime:stop()
                            skeletonAnime:removeFromParentAndCleanup(true)
                        end

                        if trueMask and trueMask:getParent() and not trueMask.isDisposed then
                            trueMask:removeFromParentAndCleanup(true)
                        end

                        if PreBuffLogic:getSkeletonLoadOrRemoveLog() == "load" then
                            FrameLoader:unloadArmature( skeletonSourceName , true)
                            PreBuffLogic:logSkeletonLoadOrRemove( "remove" )
                        end
                        ]]

                        if callback then callback() end 
                    end
                
                end , 5.5 )
end

function PreBuffLogic:playBuffUpgradeAnimation( callback , passedLevelId )
    local function doAnime()
        -- local currentScene = Director:sharedDirector():getRunningSceneLua()
        -- if currentScene:is(HomeScene) then
            self:__playBuffUpgradeAnimation( callback )
        -- end
    end

    local hasUpgrade = self:getBuffUpgradeOnLastPlay()
    if not hasUpgrade then
        if callback then callback() end
        return
    end
    local delaytime = 0.3
    if MetaManager.getInstance():isMaxLevelAreaId( passedLevelId ) and passedLevelId ~= UserManager:getInstance().user:getTopLevelId() then
        delaytime = 1.4
    else
        delaytime = 0.1
    end
    setTimeOut( function () 
            pcall( doAnime )
        end , delaytime )
end

function PreBuffLogic:popActPanel(closeCallback, fromLevelId)


    local function finish()
        if closeCallback then
            closeCallback()
        end
    end

    -- printx( 1 , "PreBuffLogic:popActPanel   111")

    if GameGuide:isNoPreBuffLevel(fromLevelId) then
        -- return finish()
    end
    -- printx( 1 , "PreBuffLogic:popActPanel   222")

    local actSource = self:getActSource()
    if not actSource then
        return finish()
    end
    -- printx( 1 , "PreBuffLogic:popActPanel   333")

    local icon = table.find(HomeScene:sharedInstance().activityIconButtons or {}, function (v) return v.source == actSource end)
    if not icon then 
        return finish()
    end
    -- printx( 1 , "PreBuffLogic:popActPanel   444")
    local parent = icon:getParent()
    if not parent then
        return finish()
    end
    -- printx( 1 , "PreBuffLogic:popActPanel   555")

    local buffGrade = PreBuffLogic:getBuffGradeAndConfig()

    local fly = ParticleSystemQuad:create("particle/fly.plist")
    fly:setVisible(false)
    fly:setAutoRemoveOnFinish(true)

    local function afterFly()
        -- buffIcon:removeFromParentAndCleanup(true)
        fly:removeFromParentAndCleanup(true)
        ActivityUtil:getActivitys(function( activitys )
            local currentScene = Director:sharedDirector():getRunningSceneLua()
            if currentScene ~= HomeScene:sharedInstance() then 
                return 
            end
            -- printx( 1 , "PreBuffLogic:popActPanel   777")
            local source = actSource
            local version = nil
            for k,v in pairs(ActivityUtil:getActivitys() or {}) do
                if v.source == source then
                    version = v.version
                    break
                end
            end
            if version then
                ActivityData.new({source=source,version=version}):start(true, false, nil, nil, closeCallback)
            end
        end)
    end

    local node = HomeScene:sharedInstance().worldScene.levelToNode[fromLevelId]
    if not node then
        return
    end
    -- printx( 1 , "PreBuffLogic:popActPanel   666")

    local dstPos = icon:getParent():convertToWorldSpace(icon:getPosition())
    dstPos.x = dstPos.x + 20
    dstPos.y = dstPos.y - 40
    local srcPos = node:getParent():convertToWorldSpace(node:getAnimationCenter())
    srcPos.x = srcPos.x
    srcPos.y = srcPos.y

    local p1 = ccp(100, 0)
    local p2 = ccp(180, 0.85*(dstPos.y - srcPos.y))
    local bezierConfig = ccBezierConfig:new()
    bezierConfig.controlPoint_1 = ccp(srcPos.x +  p1.x, srcPos.y +  p1.y)
    bezierConfig.controlPoint_2 = ccp(srcPos.x +  p2.x, srcPos.y +  p2.y)
    bezierConfig.endPosition = dstPos
    local bezierAction_1 = CCEaseInOut:create(CCBezierTo:create(1, bezierConfig), 1.8)
    local sequenceArr = CCArray:create()
    sequenceArr:addObject(CCDelayTime:create(0.5))
    local function playParticle()
        fly:setVisible(true)
    end
    sequenceArr:addObject(CCCallFunc:create(playParticle))
    sequenceArr:addObject(bezierAction_1)
    sequenceArr:addObject(CCCallFunc:create(afterFly))
    fly:runAction(CCSequence:create(sequenceArr))
    fly:setPositionXY(srcPos.x, srcPos.y)
    local scene = Director:sharedDirector():getRunningSceneLua()
    scene:addChild(fly)
end