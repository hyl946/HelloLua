
UserCallbackManager = class()

local instance = nil

local ACT_SOURCE = 'UserCallBackTest/Config.lua'

UserCallbackManager.UserGroup = table.const{ --废弃
    kGroupOld = 1,          --原版
    kGroupNewN11 = 2,           --buff
    kGroupNewN12 = 3,           --buff
    kGroupNewN21 = 4,           --buff
    kGroupNewN22 = 5,           --buff
    kGroupNewN31 = 6,           --buff
    kGroupNewN32 = 7,           --buff
    kGroupNewN41 = 8,           --buff
    kGroupNewN42 = 9,           --buff
    kGroupNewN51 = 10,          --buff
    kGroupNewN52 = 11,          --buff
    kGroupNewN61 = 12,          --buff
    kGroupNewN62 = 13,          --buff
}

local VERSION = "1_"    --本地缓存标识 每次换皮应更改 
local kStorageFileName = "callbackManager"..VERSION
local kLocalDataExt = ".ds"

function UserCallbackManager.getInstance()
    if not instance then
        instance = UserCallbackManager.new()
        instance:init()
    end
    return instance
end

local function getUid()
    local uid = '12345'
    if UserManager and UserManager:getInstance().user then
        uid = UserManager:getInstance().user.uid or '12345'
    end
    uid = tostring(uid)
    return uid
end

function UserCallbackManager:getActivityEndTime()

    if self.ActivityEndTime then
        if self.ActivityEndTime > 10000000000 then
            return math.floor( self.ActivityEndTime / 1000 )
        end

        return self.ActivityEndTime
    end

    return 0
end



function UserCallbackManager:init()
    self.buffEndTime = 0
    self.buffTimeLevel = 0 --有时间限制的BUFF等级

    self.buffStartLevel = 0
    self.buffEndLevel = 0

    self.ActivityEndTime = 0

    self.userGroup = 0
    self.rewardTimes = {}

    self:InitUserGroup()

    self.uid = getUid()
    self.filePath = HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName .. self.uid .. kLocalDataExt

    self:readFromLocal()
    self:InitBuffInfo( self.userGroup, self.rewardTimes, self.buffStartLevel  )
end

function UserCallbackManager:InitUserGroup()

    local uid = getUid()
    if MaintenanceManager:getInstance():isEnabledInGroup('ReturnUsersRetentionTest', 'N11', uid) then 
        self.Group = UserCallbackManager.UserGroup.kGroupNewN11
    elseif MaintenanceManager:getInstance():isEnabledInGroup('ReturnUsersRetentionTest', 'N12', uid) then
        self.Group = UserCallbackManager.UserGroup.kGroupNewN12
    elseif MaintenanceManager:getInstance():isEnabledInGroup('ReturnUsersRetentionTest', 'N21', uid) then
        self.Group = UserCallbackManager.UserGroup.kGroupNewN21
    elseif MaintenanceManager:getInstance():isEnabledInGroup('ReturnUsersRetentionTest', 'N22', uid) then
        self.Group = UserCallbackManager.UserGroup.kGroupNewN22
    elseif MaintenanceManager:getInstance():isEnabledInGroup('ReturnUsersRetentionTest', 'N31', uid) then
        self.Group = UserCallbackManager.UserGroup.kGroupNewN31
    elseif MaintenanceManager:getInstance():isEnabledInGroup('ReturnUsersRetentionTest', 'N32', uid) then
        self.Group = UserCallbackManager.UserGroup.kGroupNewN32
    elseif MaintenanceManager:getInstance():isEnabledInGroup('ReturnUsersRetentionTest', 'N41', uid) then
        self.Group = UserCallbackManager.UserGroup.kGroupNewN41
    elseif MaintenanceManager:getInstance():isEnabledInGroup('ReturnUsersRetentionTest', 'N42', uid) then
        self.Group = UserCallbackManager.UserGroup.kGroupNewN42
    elseif MaintenanceManager:getInstance():isEnabledInGroup('ReturnUsersRetentionTest', 'N51', uid) then
        self.Group = UserCallbackManager.UserGroup.kGroupNewN51
    elseif MaintenanceManager:getInstance():isEnabledInGroup('ReturnUsersRetentionTest', 'N52', uid) then
        self.Group = UserCallbackManager.UserGroup.kGroupNewN52
    elseif MaintenanceManager:getInstance():isEnabledInGroup('ReturnUsersRetentionTest', 'N61', uid) then
        self.Group = UserCallbackManager.UserGroup.kGroupNewN61
    elseif MaintenanceManager:getInstance():isEnabledInGroup('ReturnUsersRetentionTest', 'N62', uid) then
        self.Group = UserCallbackManager.UserGroup.kGroupNewN62
    else
        self.Group = UserCallbackManager.UserGroup.kGroupOld
    end
end

function UserCallbackManager:getMetaUserGroup() --这里是本地计算的
    return self.Group
end

function UserCallbackManager:getUserGroup() --这里是服务器发来的
    return self.userGroup
end

function UserCallbackManager:isActivitySupport()
--   if __WIN32 then 
--      return true
--   end

--  local ret = table.find(ActivityUtil:getActivitys() or {},function(v)
--      return v.source == ACT_SOURCE
--  end)
--  if not ret then 
--      return false 
--  end

    return true
end

function UserCallbackManager:InitActivityStartEndTime( EndTime )

    if self.ActivityEndTime then
        if self.ActivityEndTime ~= EndTime then
            self.userGroup = 0
            self.buffStartLevel = 0
            self.rewardTimes = 0
            self.ActivityEndTime = 0
        end
    end

    self.ActivityEndTime = tonumber(EndTime)
end

function UserCallbackManager:readFromLocal()
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
            self.userGroup = data.userGroup or 0
            self.buffStartLevel = data.buffStartLevel 
            self.rewardTimes = data.rewardTimes or 0
            self.ActivityEndTime = data.ActivityEndTime or 0
        end
    end
end

function UserCallbackManager:writeToLocal()
    local data = {}
    data.userGroup = self.userGroup
    data.buffStartLevel = self.buffStartLevel
    data.rewardTimes = self.rewardTimes
    data.ActivityEndTime = self.ActivityEndTime

    local content = amf3.encode(data)
    local file = io.open(self.filePath, "wb")
    -- assert(file, "DragonBuffManager persistent file failure " .. kStorageFileName)
    if not file then return end
    local success = file:write(content)
   
    if success then
        file:flush()
        file:close()
    else
        file:close()
    end
end

function UserCallbackManager:CheckActiveBuffTime( )
    local day = 1
    local bCanUse = false
    local BuffEndTime = 0

    local curTime = Localhost:time() 
    if self.userGroup == 1 then
        for i,v in ipairs(self.rewardTimes) do

            if i > 2 then
                break
            end

            local sighday = v.first
            local sightime = v.second
            if sightime + 60*60*1000 >= curTime then
                day = sighday
                bCanUse = true
                BuffEndTime = sightime + 60*60*1000
            end
        end
    elseif self.userGroup == 2 then
        local ToplevelId = UserManager:getInstance().user:getTopLevelId()
        if ToplevelId >= self.buffStartLevel and ToplevelId<=self.buffStartLevel +15 then
            bCanUse = true
        end
    elseif self.userGroup == 3 then
        for i,v in ipairs(self.rewardTimes) do

            if i > 3 then
                break
            end

            local sighday = v.first
            local sightime = v.second
            if sightime + 60*60*1000 >= curTime then
                day = sighday
                bCanUse = true
                BuffEndTime = sightime + 60*60*1000
            end
        end
    end
    
    return day, bCanUse, BuffEndTime
end

function UserCallbackManager:InitBuffInfo( group, rewardTimes, levelId )

    local activityData = LocalBox:getData( LocalBoxKeys.Activity_UserCallBackTest )

    if not activityData then activityData = {} end
    
    activityData.flag = true
    activityData.endTime = self:getActivityEndTime()
    -- activityData.realEndTime = realEndTime
    LocalBox:setData( LocalBoxKeys.Activity_UserCallBackTest , activityData )

    if true then return end
    self.userGroup = group or 1
    self.rewardTimes = rewardTimes or {}
    self.buffStartLevel = levelId or 1

    local Day, bCanUse, BuffEndTime = self:CheckActiveBuffTime()

    if bCanUse then
        if self.userGroup == 1 then
            self:setBuffEndTime( BuffEndTime, 5)
        elseif self.userGroup == 2 then
            self:setBuffEndLevel( self.buffStartLevel )
        elseif self.userGroup == 3 then
            local BuffLevel = 3 + Day - 1
            self:setBuffEndTime( BuffEndTime, BuffLevel )
        end
    end

    self:writeToLocal()

    self:updateBuffCountdownIcon()
    
end

function UserCallbackManager:openStartLevelPanel(endCallback)
    local levelId = UserManager:getInstance().user:getTopLevelId()
    -- local startGamePanel = StartGamePanel:create(levelId, GameLevelType.kMainLevel)
    -- startGamePanel:popout(false)

    local startLevelLogic = StartLevelLogic:create(nil, levelId, GameLevelType.kMainLevel, {}, false, {}, StartLevelType.kCommon)
    startLevelLogic:start(true, NewStartLevelLogic:getStartLevelCostEnergyType())

    --重新可以强弹
    local action = AutoPopout:getAction( UserCallBackPopoutAction.id )
    if action then
        action:resetPopFlag()
    end
    

    self:updateBuffCountdownIcon()

    if endCallback then endCallback() end
end

function UserCallbackManager:isTopLevel(levelId)
    local topLevel = UserManager:getInstance().user:getTopLevelId()
    return topLevel and levelId == topLevel
end

function UserCallbackManager:setBuffEndTime(buffEndTime, buffTimeLevel)
    self.buffEndTime = buffEndTime
    if self.ActivityEndTime and self.ActivityEndTime ~= 0 and self.buffEndTime > self.ActivityEndTime then
        self.buffEndTime = self.ActivityEndTime
    end
    self.buffTimeLevel = buffTimeLevel
    self.buffEndLevel = 0
    self.buffStartLevel = 0

    self:updateBuffCountdownIcon()
end

function UserCallbackManager:setBuffEndLevel( buffStartLevel)
    self.buffEndLevel = buffStartLevel + 15
    self.buffStartLevel = buffStartLevel
    self.buffEndTime = 0
    self.buffTimeLevel = 0

    self:updateBuffCountdownIcon()
end

function UserCallbackManager:getCurHaveCallBackBuff()

    local CurTIme = Localhost:time()
    if CurTIme > self.ActivityEndTime then
        return false
    end

    if self.buffStartLevel > 0 and #self.rewardTimes > 0 then
         local levelId = UserManager:getInstance().user:getTopLevelId()
         if levelId >=self.buffStartLevel and levelId <= self.buffEndLevel then
            --关卡BUFF
            local CanUseBuff, CanUseBuffLevel = self:getLevelCanUseBuff( levelId )
            return CanUseBuff
         end
    elseif self.buffEndTime > 0 then

        local levelId = UserManager:getInstance().user:getTopLevelId()
        local topPassedLevel = UserManager.getInstance():getTopPassedLevel()

        if self:getBuffLeftSeconds() > 0  and levelId ~= topPassedLevel then
            return true
        end
    end

    return false
end

function UserCallbackManager:getBuffLeftSeconds()
    local seconds = self.buffEndTime - Localhost:time()
    return seconds < 0 and 0 or seconds/1000
end

function UserCallbackManager:getLevelCanUseBuff( CurPlayLevelID ) --方案2的获取

    local bCanUseBuff = false
    local canUseBuffLevel = 0
    local levelId = UserManager:getInstance().user:getTopLevelId()
    local topPassedLevel = UserManager.getInstance():getTopPassedLevel()

    if levelId == CurPlayLevelID and levelId ~= topPassedLevel then
        bCanUseBuff = true
    end

    if CurPlayLevelID >=self.buffStartLevel and CurPlayLevelID <= self.buffEndLevel then

        if CurPlayLevelID - self.buffStartLevel <= 5-1 then
            canUseBuffLevel = 3
        elseif CurPlayLevelID - self.buffStartLevel <= 10-1 then
            canUseBuffLevel = 4
        elseif CurPlayLevelID - self.buffStartLevel <= 15-1 then
            canUseBuffLevel = 5
        end

        return bCanUseBuff, canUseBuffLevel
    end

    return bCanUseBuff, canUseBuffLevel
end

function UserCallbackManager:updateBuffCountdownIcon()

    local bCurHaveBuff = self:getCurHaveCallBackBuff()
    if bCurHaveBuff == false then
        return
    end

    local BuffCountdownIcon = require 'zoo.localActivity.UserCallback.BuffCountdownIcon'

    local levelId = UserManager:getInstance().user:getTopLevelId()
    local topPassedLevel = UserManager.getInstance():getTopPassedLevel()
    local topLevelNode = HomeScene:sharedInstance().worldScene.levelToNode[levelId]

    local function getIconPos( pos )
        local WorldPos = HomeScene:sharedInstance().worldScene.scaleTreeLayer1:convertToWorldSpace( pos )

        local ButtonLayerPos = HomeScene:sharedInstance().worldScene.iconButtonLayer:convertToNodeSpace(ccp(WorldPos.x, WorldPos.y))

        return ButtonLayerPos
    end


    if self.userGroup == 1 then 

        if self:getBuffLeftSeconds() > 0  and levelId ~= topPassedLevel then 
            local bShowTime = true
            local BuffLevel = self.buffTimeLevel

            if topLevelNode then 

                if self.buffCountdownIcon then
                    self.buffCountdownIcon:removeFromParentAndCleanup(true)
                    self.buffCountdownIcon = nil
                end

                local upTip = Localization:getInstance():getText("callback_Introduce1", { num = 5, n = '\n'})
                self.buffCountdownIcon = BuffCountdownIcon:create( BuffLevel, bShowTime, upTip )
                local pos = topLevelNode:getPosition()
    --          HomeScene:sharedInstance().worldScene.scaleTreeLayer1:addChild(self.buffCountdownIcon2)
    --          self.buffCountdownIcon2:setPosition(ccp(pos.x + 50, pos.y - 125))

                local ButtonLayerPos = getIconPos( ccp(pos.x + 50, pos.y - 125) )
                HomeScene:sharedInstance().worldScene.iconButtonLayer:addChild(self.buffCountdownIcon)
                self.buffCountdownIcon:setPosition(ccp(ButtonLayerPos.x, ButtonLayerPos.y))
            end
        end

    elseif self.userGroup == 2 then 

        local CurTIme = Localhost:time()
        if CurTIme > self.ActivityEndTime then
            return
        end

        if #self.rewardTimes == 0 then
            return
        end

        local bShowTime = false
        local StartLevel = self.buffStartLevel

        local LevelNode = nil
        local LevelNode2 = nil
        local LevelNode3 = nil
        if levelId - StartLevel < 5 then
            LevelNode = HomeScene:sharedInstance().worldScene.levelToNode[levelId]
            LevelNode.StartLevel = levelId
            LevelNode.EndLevel = StartLevel + 5 -1
            local bCanUseBuff, BuffLevel = self:getLevelCanUseBuff(LevelNode.StartLevel)
            LevelNode.BuffLevel = BuffLevel

            LevelNode2 = HomeScene:sharedInstance().worldScene.levelToNode[ LevelNode.EndLevel + 1]
            LevelNode2.StartLevel = LevelNode.EndLevel + 1
            LevelNode2.EndLevel = LevelNode2.StartLevel + 5 -1
            local bCanUseBuff, BuffLevel = self:getLevelCanUseBuff(LevelNode2.StartLevel)
            LevelNode2.BuffLevel = BuffLevel

            LevelNode3 = HomeScene:sharedInstance().worldScene.levelToNode[LevelNode2.EndLevel+1]
            LevelNode3.StartLevel = LevelNode2.EndLevel+1
            LevelNode3.EndLevel = LevelNode3.StartLevel + 5 -1
            local bCanUseBuff, BuffLevel = self:getLevelCanUseBuff(LevelNode3.StartLevel)
            LevelNode3.BuffLevel = BuffLevel

            if topPassedLevel == levelId then
                LevelNode = nil
            end

        elseif levelId - StartLevel < 10 then
            LevelNode = HomeScene:sharedInstance().worldScene.levelToNode[levelId]
            LevelNode.StartLevel = levelId
            LevelNode.EndLevel = StartLevel + 10 -1
            local bCanUseBuff, BuffLevel = self:getLevelCanUseBuff(LevelNode.StartLevel)
            LevelNode.BuffLevel = BuffLevel

            LevelNode2 = HomeScene:sharedInstance().worldScene.levelToNode[ LevelNode.EndLevel+1]
            LevelNode2.StartLevel = LevelNode.EndLevel+1
            LevelNode2.EndLevel = LevelNode2.StartLevel + 5 - 1
            local bCanUseBuff, BuffLevel = self:getLevelCanUseBuff(LevelNode2.StartLevel)
            LevelNode2.BuffLevel = BuffLevel

            if topPassedLevel == levelId then
                LevelNode = nil
            end

        elseif levelId - StartLevel < 15 then
            LevelNode = HomeScene:sharedInstance().worldScene.levelToNode[levelId]

            LevelNode.StartLevel = levelId
            LevelNode.EndLevel = StartLevel + 15 -1
            local bCanUseBuff, BuffLevel = self:getLevelCanUseBuff(LevelNode.StartLevel)
            LevelNode.BuffLevel = BuffLevel

            if topPassedLevel == levelId then
                LevelNode = nil
            end
        end

        if self.buffCountdownIcon then
            self.buffCountdownIcon:removeFromParentAndCleanup(true)
            self.buffCountdownIcon = nil
        end
        if self.buffCountdownIcon2 then
            self.buffCountdownIcon2:removeFromParentAndCleanup(true)
            self.buffCountdownIcon2 = nil
        end
        if self.buffCountdownIcon3 then
            self.buffCountdownIcon3:removeFromParentAndCleanup(true)
            self.buffCountdownIcon3 = nil
        end

        local function getBuffNum( BuffLevel )
            
            local num = 0

            if BuffLevel == 3 then
                num = 3
            elseif BuffLevel == 4 then
                num = 4
            elseif BuffLevel == 5 then
                num = 5
            end

            return num
        end

        if LevelNode then 

            local BuffNum = getBuffNum( LevelNode.BuffLevel )

            local upTip = ""
            if LevelNode.StartLevel ~=  LevelNode.EndLevel then
                upTip = Localization:getInstance():getText("callback_Introduce2", { level1 = LevelNode.StartLevel, level2 = LevelNode.EndLevel, num = BuffNum})
            else
                upTip = Localization:getInstance():getText("callback_Introduce3", { level2 = LevelNode.EndLevel, num = BuffNum})
            end

            self.buffCountdownIcon = BuffCountdownIcon:create(  LevelNode.BuffLevel, bShowTime, upTip )
            local pos = LevelNode:getPosition()
--          HomeScene:sharedInstance().worldScene.scaleTreeLayer1:addChild(self.buffCountdownIcon2)
--          self.buffCountdownIcon2:setPosition(ccp(pos.x + 50, pos.y - 125))

            local ButtonLayerPos = getIconPos( ccp(pos.x + 50, pos.y - 125) )
            HomeScene:sharedInstance().worldScene.iconButtonLayer:addChild(self.buffCountdownIcon)
            self.buffCountdownIcon:setPosition(ccp(ButtonLayerPos.x, ButtonLayerPos.y))
        end

        if LevelNode2 then 

            local BuffNum = getBuffNum( LevelNode2.BuffLevel )
            local upTip = ""
            if LevelNode2.StartLevel ~=  LevelNode2.EndLevel then
                upTip = Localization:getInstance():getText("callback_Introduce2", { level1 = LevelNode2.StartLevel, level2 = LevelNode2.EndLevel, num = BuffNum})
            else
                upTip = Localization:getInstance():getText("callback_Introduce3", { level2 = LevelNode2.EndLevel, num = BuffNum})
            end
            self.buffCountdownIcon2 = BuffCountdownIcon:create( LevelNode2.BuffLevel, bShowTime, upTip )
            local pos = LevelNode2:getPosition()
--          HomeScene:sharedInstance().worldScene.scaleTreeLayer1:addChild(self.buffCountdownIcon2)
--          self.buffCountdownIcon2:setPosition(ccp(pos.x + 50, pos.y - 125))

            local ButtonLayerPos = getIconPos( ccp(pos.x + 50, pos.y - 125) )
            HomeScene:sharedInstance().worldScene.iconButtonLayer:addChild(self.buffCountdownIcon2)
            self.buffCountdownIcon2:setPosition(ccp(ButtonLayerPos.x, ButtonLayerPos.y))
        end

        if LevelNode3 then 

            local BuffNum = getBuffNum( LevelNode3.BuffLevel )
            local upTip = ""
            if LevelNode3.StartLevel ~=  LevelNode3.EndLevel then
                upTip = Localization:getInstance():getText("callback_Introduce2", { level1 = LevelNode3.StartLevel, level2 = LevelNode3.EndLevel, num = BuffNum})
            else
                upTip = Localization:getInstance():getText("callback_Introduce3", { level2 = LevelNode3.EndLevel, num = BuffNum})
            end
            self.buffCountdownIcon3 = BuffCountdownIcon:create(  LevelNode3.BuffLevel, bShowTime, upTip )
            local pos = LevelNode3:getPosition()
--          HomeScene:sharedInstance().worldScene.scaleTreeLayer1:addChild(self.buffCountdownIcon2)
--          self.buffCountdownIcon2:setPosition(ccp(pos.x + 50, pos.y - 125))

            local ButtonLayerPos = getIconPos( ccp(pos.x + 50, pos.y - 125) )
            HomeScene:sharedInstance().worldScene.iconButtonLayer:addChild(self.buffCountdownIcon3)
            self.buffCountdownIcon3:setPosition(ccp(ButtonLayerPos.x, ButtonLayerPos.y))
        end

    elseif self.userGroup == 3 then 

        if self:getBuffLeftSeconds() > 0 and levelId ~= topPassedLevel then 
            local bShowTime = true
            local BuffLevel = self.buffTimeLevel
            
            if topLevelNode then 
                
                if self.buffCountdownIcon then
                    self.buffCountdownIcon:removeFromParentAndCleanup(true)
                    self.buffCountdownIcon = nil
                end

                local upTip = Localization:getInstance():getText("callback_Introduce1", { num = BuffLevel, n = '\n'})
                self.buffCountdownIcon = BuffCountdownIcon:create( BuffLevel, bShowTime, upTip )
                local pos = topLevelNode:getPosition()
    --          HomeScene:sharedInstance().worldScene.scaleTreeLayer1:addChild(self.buffCountdownIcon2)
    --          self.buffCountdownIcon2:setPosition(ccp(pos.x + 50, pos.y - 125))

                local ButtonLayerPos = getIconPos( ccp(pos.x + 50, pos.y - 125) )
                HomeScene:sharedInstance().worldScene.iconButtonLayer:addChild(self.buffCountdownIcon)
                self.buffCountdownIcon:setPosition(ccp(ButtonLayerPos.x, ButtonLayerPos.y))
            end
        end
    end

end

function UserCallbackManager:hasReward(  )
    local userCallbackActInfo = UserManager:getInstance().userCallbackActInfo
    if userCallbackActInfo and userCallbackActInfo.rewardFlag and userCallbackActInfo.rewardFlag > 0 then
        return true
    end
    return false
end

function UserCallbackManager:shouldShowIcon( isInit )

    local userCallbackActInfo = UserManager:getInstance().userCallbackActInfo

    local ret = false
    ret = userCallbackActInfo ~= nil and userCallbackActInfo.see 
    -- local config = require("zoo/localActivity/UserCallBackTest/Config.lua")
    -- if config then
    --     local isOk = false
    --     if config.isSupport then
    --         isOk = config.isSupport()
    --     end
    --     ret = ret and isOk
    -- end
    return ret

end

function UserCallbackManager:getActInfo()
    self.info = {
        [3009] = "UserCallBackTest/Config.lua",
        [81] = "UserCallBack/Config.lua",
    }
    local actInfo 
    for k, v in pairs(UserManager:getInstance().actInfos or {}) do
        if self.info[v.actId] then
            actInfo = v
            break
        end
    end

    return actInfo
end