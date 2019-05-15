require 'zoo.account.AccountBindingLogic'
require 'zoo.scenes.component.HomeScene.iconButtons.BindAccountButton'

local PushBindingPanels = require ('zoo.panel.PushBindingPanels')

PushBindingLogic = class(HomeScenePopoutAction)

local function uid()
    return UserManager:getInstance().user.uid or '12345'
end


function _readFile()
    local path = HeResPathUtils:getUserDataPath() .. "/pushBinding" .. uid()
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

function _writeToFile(data)
    local path = HeResPathUtils:getUserDataPath() .. "/pushBinding" .. uid() 
    Localhost:safeWriteStringToFile(table.serialize(data), path)
end

local function getBool(key, default)
    local data = _readFile()
    if data[key] ~= nil then
        return data[key]
    end

    return default
end

local function getInt(key, default)
    local data = _readFile()
    if data[key] ~= nil then
        return tonumber(data[key])
    end

    return default
end

local function getString(key, default)
    local data = _readFile()
    if data[key] ~= nil then
        return tostring(data[key])
    end

    return default
end

local function setBool(key, value)
    local data = _readFile()
    data[key] = value
    _writeToFile(data)
end

local function setInt(key, value)
    local data = _readFile()
    data[key] = value
    _writeToFile(data)
end

local function setString(key, value)
    local data = _readFile()
    data[key] = value
    _writeToFile(data)
end

function PushBindingLogic:getLocalBool(key, default)
    return getBool(key, default)
end

function PushBindingLogic:getLocalInt(key, default)
    return getInt(key, default)
end

function PushBindingLogic:getLocalString(key, default)
    return getString(key, default)
end

function PushBindingLogic:writeLocalBool(key, default)
    setBool(key, default)
end

function PushBindingLogic:writeLocalInt(key, default)
    setInt(key, default)
end

function PushBindingLogic:writeLocalString(key, value)
    setString(key, value)
end

function PushBindingLogic:getDailyPopKey()
    local date = os.date('*t', Localhost:timeInSec())
    local key = string.format('_%s_%s_%s_', date.year, date.month, date.day)
    return key
end

local function hasQQandPhoneAuth()
    return PlatformConfig:hasAuthConfig(PlatformAuthEnum.kPhone) and PlatformConfig:hasAuthConfig(PlatformAuthEnum.kQQ)
end

local function hasOnlyQQAuth()
    return PlatformConfig:hasAuthConfig(PlatformAuthEnum.kQQ, true) and not PlatformConfig:hasAuthConfig(PlatformAuthEnum.kPhone)
end

local function hasOnlyPhoneAuth()
    return PlatformConfig:hasAuthConfig(PlatformAuthEnum.kPhone) and not PlatformConfig:hasAuthConfig(PlatformAuthEnum.kQQ)
end

---------------------------------------------------------------------------------------------------------------------------------
local function hasOnly360Auth()
   if PlatformConfig:hasAuthConfig(PlatformAuthEnum.k360) then
      return true
   end

   return false
end

local function hasBindAuthType(authType)
    return UserManager:getInstance().profile:getSnsInfo(authType) ~= nil
end

local function hasBind360()
   return UserManager:getInstance().profile:getSnsUsername(PlatformAuthEnum.k360) ~= nil
end

local function hasPhoneAuth()
   return PlatformConfig:hasAuthConfig(PlatformAuthEnum.kPhone)
end

local function hasBindedPhone()
    return UserManager:getInstance().profile:getSnsUsername(PlatformAuthEnum.kPhone) ~= nil
end

local function hasQQAuth()
    return PlatformConfig:hasAuthConfig(PlatformAuthEnum.kQQ, true)
end

local function hasBindedQQ()
    return UserManager:getInstance().profile:getSnsUsername(PlatformAuthEnum.kQQ) ~= nil
end

function PushBindingLogic:_getDecisionForGuest()
    local panelCls, panelData, hasAward = false, false, false
    if MetaManager:getInstance():pushLogicEnable() then
        local panel, data, hasIcon
        if hasOnly360Auth() and not hasBind360() then --360平台只推荐360一种绑定方式
            data = {pf = "360"}
            panelCls, panelData, hasAward = PushBindingPanels.T360Panel, data, true
        else
            panelCls, panelData, hasAward = PushBindingLogic:_getDecisionForLoginUser() --对于非360平台，走的逻辑和已登录玩家的逻辑是一样的
        end
    end

    return panelCls, panelData, hasAward
end

function PushBindingLogic:_decisionByBindType( bindType, cycleNoAwardFlag )
    local panelCls, panelData, hasAward = false, false, false

    if hasOnly360Auth() and bindType ~= PlatformAuthEnum.k360 then
        return panelCls, panelData, hasAward
    end

    local pushBindName = PlatformConfig:getPlatformAuthName(bindType)
    for k, v in pairs(PushBindingPanels) do
        if bindType == v.loginType then
            panelCls = v
            panelData = {pf = pushBindName}
            hasAward = (cycleNoAwardFlag ~= true)
            break
        end
    end
    if panelCls then
        PushBindingLogic.pushData.curDecisionType = pushBindName
    end
    if _G._UploadDebugLog then RemoteDebug:uploadLogWithTag("_decisionByBindType", bindType, pushBindName, not panelCls) end
    return panelCls, panelData, hasAward
end

function PushBindingLogic:getAllValidPushBindTypes()
    local ret = {}
    local allPushBindTypes = MetaManager:getInstance():getAllPushBindTypes()
    for _, authType in ipairs(allPushBindTypes) do
        if PlatformConfig:hasAuthConfig(authType) then
            table.insert(ret, authType)
        end
    end
    -- 360平台只推360登录
    if PlatformConfig:isPlatform(PlatformNameEnum.k360) then
        ret = {}
        if table.exist(ret, PlatformAuthEnum.k360) then
            ret = {PlatformAuthEnum.k360}
        end
    end
    return ret
end

function PushBindingLogic:_getDecisionForLoginUser()
    local panelCls, panelData, hasAward = false, false, false
    local metaMgr = MetaManager:getInstance()
    if metaMgr:pushLogicEnable() then
        local allPushBindTypes = PushBindingLogic:getAllValidPushBindTypes()
        local pushBindName = metaMgr:getPushBindType()
        if _G._UploadDebugLog then RemoteDebug:uploadLogWithTag("getDecision1", pushBindName, table.tostring(allPushBindTypes)) end
        if pushBindName and pushBindName ~= "none" then
            local pushBindType = PlatformConfig:getPlatformAuthByName(pushBindName)
            if not pushBindType or not PlatformConfig:hasAuthConfig(pushBindType) then
                -- 不支持推荐的绑定方式，直接不推荐了
                if _G._UploadDebugLog then RemoteDebug:uploadLogWithTag("getDecision2", pushBindType, "不支持推荐的绑定方式，直接不推荐了") end
            elseif hasBindAuthType(pushBindType) then
                -- 判断其他推荐的绑定方式
                for _, authType in ipairs(allPushBindTypes) do
                    if authType ~= pushBindType and not hasBindAuthType(authType) then
                        local pushName = PlatformConfig:getPlatformAuthName(authType)
                        if pushName and not PushBindingLogic:getAnotherPushPopFlag(pushName, false) then
                            PushBindingLogic.pushData.inPushAnotherLastPopHandle[pushName] = true
                            panelCls, panelData = PushBindingLogic:_decisionByBindType( authType )
                            hasAward = false
                        end
                        break
                    end
                end
                if _G._UploadDebugLog then RemoteDebug:uploadLogWithTag("getDecision3", panelCls, table.tostring(panelData), hasAward) end
            else
                -- 返回推荐的绑定方式
                panelCls, panelData, hasAward = PushBindingLogic:_decisionByBindType( pushBindType )
                if _G._UploadDebugLog then RemoteDebug:uploadLogWithTag("getDecision4", panelCls, table.tostring(panelData), hasAward) end
            end
        else
            -- 暂时不考虑这一块逻辑，不会配置none
            local notBindTypes = {}
            for _, authType in ipairs(allPushBindTypes) do
                if not hasBindAuthType(authType) then
                    table.insert(notBindTypes, authType)
                end
            end
            if _G._UploadDebugLog then RemoteDebug:uploadLogWithTag("getDecision5", "notBindTypes", table.tostring(notBindTypes)) end
            if #notBindTypes == 1 then
                local pushBindName = PlatformConfig:getPlatformAuthName(notBindTypes[1])
                local popFlagKey = "none_push_last_pop_"..tostring(pushBindName).."_flag"
                if pushBindName and not getBool(popFlagKey, false) then
                    PushBindingLogic.pushData.inNoneLastPopHandle[pushBindName] = true
                    panelCls, panelData = PushBindingLogic:_decisionByBindType( notBindTypes[1] )
                    hasAward = false
                end
                if _G._UploadDebugLog then RemoteDebug:uploadLogWithTag("getDecision6", panelCls, table.tostring(panelData), hasAward) end
            elseif #notBindTypes > 1 then
                -- 有多种绑定方式，周期性推荐
                panelCls, panelData, hasAward = PushBindingLogic:_getDecisionWithMutiBindTypes(notBindTypes)
                if _G._UploadDebugLog then RemoteDebug:uploadLogWithTag("getDecision7", panelCls, table.tostring(panelData), hasAward) end
            end
        end
    end
    return panelCls, panelData, hasAward
end

function PushBindingLogic:_getDecisionWithMutiBindTypes(notBindTypes)
    local panelCls, panelData, hasAward = false, false, false
    if not notBindTypes then return panelCls, panelData, hasAward end
    -- 有多种绑定方式，周期性推荐
    local cycleNoAwardFlag = false
    local isInAwardCycle = PushBindingLogic:getAwardTimeLeft() > 0
    local cfgLogicAwardFlag = PushBindingLogic:logicHasAwardByCfg(nil)
    if isInAwardCycle and cfgLogicAwardFlag then
        -- 在上次绑定奖励期间
        local lastPushType = PlatformConfig:getPlatformAuthByName(getString("last_popout_decision_type", "phone"))
        if table.exist(notBindTypes, lastPushType) then
            panelCls, panelData, hasAward = PushBindingLogic:_decisionByBindType( lastPushType )
        end
        if _G._UploadDebugLog then RemoteDebug:uploadLogWithTag("MutiBindTypes1", lastPushType, panelCls, table.tostring(panelData), hasAward) end
    else
        local lastPopTime = getInt("last_popout_decision_time", 0)
        if Localhost:getDayStartTimeByTS(lastPopTime) ~= Localhost:getDayStartTimeByTS(Localhost:timeInSec()) then--在无奖励期间，当天无强弹
            local lastPushType = nil
            if PushBindingLogic:inCycleForcePop() then --一轮中，无奖励期间 根据上一次的判断计算这次的判断
                cycleNoAwardFlag = true
                lastPushType = PlatformConfig:getPlatformAuthByName(getString("last_popout_decision_type", "phone"))
                if _G._UploadDebugLog then RemoteDebug:uploadLogWithTag("MutiBindTypes21") end
            else --新一轮开始,首次推送与上次不同
                lastPushType = PlatformConfig:getPlatformAuthByName(getString("last_cycle_decision_type", "phone"))
                if _G._UploadDebugLog then RemoteDebug:uploadLogWithTag("MutiBindTypes22") end
            end
            local pushIndex = table.indexOf(notBindTypes, lastPushType) or 0
            pushIndex = pushIndex + 1
            if pushIndex > #notBindTypes then pushIndex = 1 end
            panelCls, panelData, hasAward = PushBindingLogic:_decisionByBindType( notBindTypes[pushIndex], cycleNoAwardFlag )
        end
        if _G._UploadDebugLog then RemoteDebug:uploadLogWithTag("MutiBindTypes2", lastPushType, cycleNoAwardFlag, panelCls, table.tostring(panelData), hasAward) end
    end
    return panelCls, panelData, hasAward
end

function PushBindingLogic:getPhoneShowShift()
    return PushBindingLogic:getPushShowShift(PlatformAuthEnum.kPhone, 0)
end

function PushBindingLogic:getQQShowShift()
    return PushBindingLogic:getPushShowShift(PlatformAuthEnum.kQQ, 0)
end

function PushBindingLogic:getPopoutDecision()
    local panelCls, panelData, hasAward = false, false, false
    local unLockLevel = MetaManager:getInstance():getPushBindUnlockLevel()
    if UserManager:getInstance().user:getTopLevelId() < unLockLevel then
        panelCls, panelData, hasAward = false, false, false
    else
        if _G.sns_token then
            -- RemoteDebug:uploadLogWithTag("getPopoutDecision_ForLoginUser")
            panelCls, panelData, hasAward = PushBindingLogic:_getDecisionForLoginUser()
        else
            -- RemoteDebug:uploadLogWithTag("getPopoutDecision_ForGuest")
            panelCls, panelData, hasAward = PushBindingLogic:_getDecisionForGuest()
        end
    end
    return panelCls, panelData, hasAward
end

function PushBindingLogic:initData()
    MetaManager:getInstance():parsePushBindLogic()
    if PushBindingLogic.pushData == nil then PushBindingLogic.pushData = {} end
    PushBindingLogic.pushData.inNoneLastPopHandle = {}
    PushBindingLogic.pushData.inPushAnotherLastPopHandle = {}
    if hasOnly360Auth() then
        PushBindingLogic.in360Logic = true
    end

--    PushBindingLogic:checkAddAwardIcon()
    PushBindingLogic.isDataInit = true
end

function PushBindingLogic:logicHasAwardByCfg(pushBindType)--根据当前配置，计算是否有奖励
    local hasAward = true
    if MetaManager:getInstance():isPushNone() and (pushBindType ~= PlatformAuthEnum.k360) then
        local pushTypes = MetaManager:getInstance():getAllPushBindTypes()
        local noRewardEnable = true
        for _, v in pairs(pushTypes) do
            if hasBindAuthType(v) then
                hasAward = false
                break
            end
            if PlatformConfig:hasAuthConfig(v) and MetaManager:getInstance():isPushRewardEnable(v) then
                noRewardEnable = false
            end
        end
        if hasAward and noRewardEnable then
           hasAward = false
        end
    end
    if hasAward and pushBindType then
        if not MetaManager:getInstance():isPushRewardEnable(pushBindType) then
            hasAward = false
        end
    end
    return hasAward
end

function PushBindingLogic:isValidPushBindPanel(panel)
    for k, v in pairs(PushBindingPanels) do
        if v == panel then return true end
    end
    return false
end

function PushBindingLogic:checkAddAwardIcon()
    -- if _G.isLocalDevelopMode then printx(0, "iii-------------------0") end

    local pushPanel, _, hasAwardIcon = PushBindingLogic:getPopoutDecision()
    local logicHasIcon = false
    local isValidPanel = PushBindingLogic:isValidPushBindPanel(pushPanel)
    -- if _G.isLocalDevelopMode then printx(0, "iii-------------------1") end
    if isValidPanel then
        local cfgLogicAwardFlag = PushBindingLogic:logicHasAwardByCfg(pushPanel.loginType)
        -- if _G.isLocalDevelopMode then printx(0, "iii-------------------2") end
        if not cfgLogicAwardFlag then
            -- RemoteDebug:uploadLogWithTag("checkAddAwardIcon1", cfgLogicAwardFlag, logicHasIcon)
            logicHasIcon = false
        elseif PushBindingLogic:getAwardTimeLeft(true, pushPanel, hasAwardIcon) > 0 then 
            -- if _G.isLocalDevelopMode then printx(0, "iii-------------------3") end
            -- RemoteDebug:uploadLogWithTag("checkAddAwardIcon2", cfgLogicAwardFlag, logicHasIcon)
            logicHasIcon = true
        else
            -- if _G.isLocalDevelopMode then printx(0, "iii-------------------4") end
            if PushBindingLogic:inCycleForcePop() then
                -- if _G.isLocalDevelopMode then printx(0, "iii-------------------5") end
            else
                -- if _G.isLocalDevelopMode then printx(0, "iii-------------------6") end
                setInt("bindingAwardCycleStart", Localhost:timeInSec())
                logicHasIcon = true
            end
            -- RemoteDebug:uploadLogWithTag("checkAddAwardIcon3", cfgLogicAwardFlag, logicHasIcon)
        end
    end
    if _G._UploadDebugLog then RemoteDebug:uploadLogWithTag("checkAddAwardIcon", isValidPanel, hasAwardIcon, logicHasIcon) end
    -- if _G.isLocalDevelopMode then printx(0, "iii-------------------7", tostring(hasAwardIcon), tostring(logicHasIcon)) end
--    hasAwardIcon = hasAwardIcon and logicHasIcon
    hasAwardIcon = hasAwardIcon
    if hasAwardIcon then
        if isValidPanel then
            PushBindingLogic.pushData.pushBindType = pushPanel.loginType
        end
        -- RemoteDebug:uploadLogWithTag("checkAddAwardIcon4", cfgLogicAwardFlag, logicHasIcon)
        -- if _G.isLocalDevelopMode then printx(0, "iii-------------------12", PushBindingLogic.pushData.pushBindType) end
        PushBindingLogic:addBindAccountAwardIcon()
    end
end

function PushBindingLogic:inCycleForcePop()
    -- if _G.isLocalDevelopMode then printx(0, "popCount-------------------" .. PushBindingLogic:getNoAwardForcePopoutNum() .. "   " ..  MetaManager:getInstance():getPushBindCycle()) end
    local hasPopNum = PushBindingLogic:getNoAwardForcePopoutNum()
    local cyclePopNum = MetaManager:getInstance():getPushBindCycle()
    if hasPopNum < cyclePopNum then
        return true
    elseif hasPopNum == cyclePopNum then
        local lastDay = 0
        local lastPushType = PlatformConfig:getPlatformAuthName(getString("last_cycle_decision_type", "phone"))
        local allPushBindTypes = PushBindingLogic:getAllValidPushBindTypes()
        if lastPushType and not table.exist(allPushBindTypes, lastPushType) then
            -- 不再可用的推荐绑定
            lastPushType = nil
        end
        local notBindTypes = {}
        for _, authType in ipairs(allPushBindTypes) do
            if not hasBindAuthType(authType) then
                table.insert(notBindTypes, authType)
            end
        end
        -- 上次没有推荐或是已绑定，还有其他可绑定方式
        if (not lastPushType or hasBindAuthType(lastPushType)) and #notBindTypes > 0 then
            lastDay = 1
        end
        return hasPopNum < cyclePopNum + lastDay
    end

    return false
end

function PushBindingLogic:setNonePushPopFlag(pushName, value)
    local key = "none_push_last_pop_"..tostring(pushName).."_flag"
    setBool(key, (value == true))
end

function PushBindingLogic:getNonePushPopFlag(pushName, default)
    local key = "none_push_last_pop_"..tostring(pushName).."_flag"
    return getBool(key, (default == true))
end

function PushBindingLogic:setAnotherPushPopFlag(pushName, value)
    local key = "another_push_last_pop_"..tostring(pushName).."_flag"
    setBool(key, (value == true))
end

function PushBindingLogic:getAnotherPushPopFlag(pushName, default)
    local key = "another_push_last_pop_"..tostring(pushName).."_flag"
    return getBool(key, (default == true))
end

function PushBindingLogic:canForcePop()
    if not PushBindingLogic.isDataInit then
        PushBindingLogic:initData()
    end

    if getBool(PushBindingLogic:getDailyPopKey(), false) then
        return false
    end

    local panelName, data, hasAwardIcon = PushBindingLogic:getPopoutDecision()
    if not panelName then 
        return false
    end

    local popOutFlag = PushBindingLogic:isValidPushBindPanel(panelName)

    if not popOutFlag then
        return false
    end

    if RealNameManager:isHomeSceneOpen() and RealNameManager:isCounterEnough() then
        local bRealName = RealNameManager:setLocalSwitch()
        if bRealName then popOutFlag = false end
    end

    local bHaveSVIPActivity = SVIPGetPhoneManager:getInstance():CurIsHaveIcon()
    -- 不弹实名认证手机部分
    if bHaveSVIPActivity then
        return false
    end

    return popOutFlag
end

function PushBindingLogic:tryPopout(endCallback, byClk)
    local function onLogicEnd(popFlag)
        if endCallback ~= nil then endCallback(popFlag) end
    end

    if not PushBindingLogic.isDataInit then
        PushBindingLogic:initData()
        
        local shanyan = require('zoo.util.ShanYanCtrl')
        shanyan:init()
    end

    if not byClk and not getBool(PushBindingLogic:getDailyPopKey(), false) then 
        PushBindingLogic:addNoAwardForcePopoutNum() 
    end
    PushBindingLogic:checkAddAwardIcon()

    if not byClk then
        if getBool(PushBindingLogic:getDailyPopKey(), false) then
            onLogicEnd()
            return
        end
    end



    local panelName, data, hasAwardIcon = PushBindingLogic:getPopoutDecision()
    if _G._UploadDebugLog then RemoteDebug:uploadLogWithTag("tryPopout0_"..tostring(panelName)) end
    if not panelName then 
        onLogicEnd() 
        return
    end
    
    local popOutFlag = false
    if _G._UploadDebugLog then RemoteDebug:uploadLogWithTag("tryPopout1_"..tostring(popOutFlag)) end
    if PushBindingLogic:isValidPushBindPanel(panelName) then
        popOutFlag = true
        if PushBindingLogic:getAwardTimeLeft() < 0 and not PushBindingLogic:inCycleForcePop()  then
            PushBindingLogic:getAwardTimeLeft(true, panelName, hasAwardIcon) --看是否触发了新的周期    
        end
    end

    if _G._UploadDebugLog then RemoteDebug:uploadLogWithTag("tryPopout2_"..tostring(popOutFlag)) end
    if not byClk then 
        if popOutFlag then--如果有绑定账号强弹就执行轮换逻辑
            if RealNameManager:isHomeSceneOpen() and RealNameManager:isCounterEnough() then
                local bRealName = RealNameManager:setLocalSwitch()
                if bRealName then popOutFlag = false end
            end
        else
            if not PushBindingLogic:isTodayForcePopout() then 
                RealNameManager:setLocalSwitch(true)
            end
        end
        if _G._UploadDebugLog then RemoteDebug:uploadLogWithTag("tryPopout3_"..tostring(popOutFlag)) end
    end

    if popOutFlag then
        setString("last_popout_decision_type", PushBindingLogic.pushData.curDecisionType)
        setInt("last_popout_decision_time", Localhost:timeInSec())
        PushBindingLogic:setLocalDataPopFlag()
        local pushBindName = PlatformConfig:getPlatformAuthName(panelName.loginType)
        if PushBindingLogic.pushData.inNoneLastPopHandle[pushBindName] then
            PushBindingLogic:setNonePushPopFlag(pushBindName, true)
        end
        if PushBindingLogic.pushData.inPushAnotherLastPopHandle[pushBindName] then
            PushBindingLogic:setAnotherPushPopFlag(pushBindName, true)
        end

        if not byClk then 
            PushBindingLogic:addCycleAllForcePopNum()
        else
            if PushBindingLogic:getCycleAllForcePopNum() < 1 then
                PushBindingLogic:addCycleAllForcePopNum()
            end
        end

        if byClk then
            PushBindingLogic.pushData.pushBindPanel = panelName:create(data)
            PushBindingLogic.pushData.pushBindPanel:popout(onLogicEnd)
        end
    else
        onLogicEnd()
    end
end

function PushBindingLogic:updatePanelCountDown(timeStr)
    if PushBindingLogic.pushData ~= nil and PushBindingLogic.pushData.pushBindPanel ~= nil then
        PushBindingLogic.pushData.pushBindPanel:updaetTimeTf(timeStr)
    end
end

function PushBindingLogic:cancelPushBindAward()
    if PushBindingLogic.pushData and PushBindingLogic.pushData.pushBindPanel ~= nil then
        PushBindingLogic.pushData.pushBindPanel:cancelPushBindAward()
    end
end

function PushBindingLogic:addBindAccountAwardIcon()

    local bHaveSVIPActivity = SVIPGetPhoneManager:getInstance():CurIsHaveIcon()
    -- 不弹实名认证手机部分
    if bHaveSVIPActivity then
        return
    end

    -- if _G.isLocalDevelopMode then printx(0, "iii-------------------13") end
    if PushBindingLogic.pushData.icon == nil and HomeScene:hasInited() then
        local homeScene = HomeScene:sharedInstance()
    -- if _G.isLocalDevelopMode then printx(0, "iii-------------------14") end
        if homeScene ~= nil then
    -- if _G.isLocalDevelopMode then printx(0, "iii-------------------15") end
            local is360, timeLeft, pushType = PushBindingLogic.in360Logic, PushBindingLogic:getAwardTimeLeft(), PushBindingLogic.pushData.pushBindType
            local icon = BindAccountButton:create(is360, timeLeft, pushType)
            if icon then 
                PushBindingLogic.pushData.icon = icon
                -- homeScene.leftRegionLayoutBar:addItem(PushBindingLogic.pushData.icon)
                homeScene:addIcon(PushBindingLogic.pushData.icon)
                PushBindingLogic.pushData.icon.wrapper:ad(DisplayEvents.kTouchTap, function()
                    if PushBindingLogic.pushData.icon and not PushBindingLogic.pushData.icon.isDisposed then
                        PushBindingLogic:tryPopout(nil, true)
                    end
                end)
            end
        end
    end
end

function PushBindingLogic:removeBindAccountIcon()
    if PushBindingLogic.pushData.icon ~= nil and not PushBindingLogic.pushData.icon.isDisposed then
        local homeScene = HomeScene:sharedInstance()
        if homeScene ~= nil then
            PushBindingLogic.pushData.icon:stopTimer()
            homeScene:removeIcon(PushBindingLogic.pushData.icon, true)
            -- homeScene.leftRegionLayoutBar:removeItem(PushBindingLogic.pushData.icon)
            PushBindingLogic.pushData.icon = nil
        end
    end
end

function PushBindingLogic:checkRemovePanelAndIcon(bindType)
    if PushBindingLogic.pushData ~= nil and PushBindingLogic.pushData.pushBindType == bindType then
       if PushBindingLogic.pushData.pushBindPanel ~= nil and PushBindingLogic.pushData.pushBindPanel.loginType == bindType then
            PushBindingLogic.pushData.pushBindPanel:onCloseBtnTapped()
       end

       PushBindingLogic:removeBindAccountIcon()
   end
end

function PushBindingLogic:removePanelIfHas()
    if PushBindingLogic.pushData ~= nil and PushBindingLogic.pushData.pushBindPanel ~= nil then
        PushBindingLogic.pushData.pushBindPanel:onCloseBtnTapped()
    end
end

function PushBindingLogic:getLocalRewardInfo()
    return getString("bindingAwardCfg", "")
end

function PushBindingLogic:getCurCycleTime(initFlag, hasAwardIcon)
    local curCycleTime = getInt("bindingAwardCycleStart", 0)
    local curCyclePopNum = getInt(PushBindingLogic:getCycleNoAwardForcePopKey(), 0)
    -- if _G.isLocalDevelopMode then printx(0, "time-------------------0") end
    if initFlag and (curCycleTime < 1 or 
                     curCyclePopNum >= MetaManager:getInstance():getPushBindCycle() or
                     (hasAwardIcon ~= nil and not hasAwardIcon)) then
        -- if _G.isLocalDevelopMode then printx(0, "time-------------------1", tostring(initFlag), tostring(curCycleTime), tostring(curCyclePopNum), tostring(MetaManager:getInstance():getPushBindCycle())) end
        local hostTime = Localhost:timeInSec()
        setInt("bindingAwardCycleStart", hostTime)
        if PushBindingLogic.in360Logic then
            setString("bindingAwardCfg", MetaManager:getInstance():getPushBind360Reward())
        else
            setString("bindingAwardCfg", MetaManager:getInstance():getPushBindPhoneReward())
        end
        curCycleTime = hostTime
        setInt(PushBindingLogic:getCycleNoAwardForcePopKey(), 0)
        setInt(PushBindingLogic:getAllCycleForcePopKey(), 0)
        -- if _G.isLocalDevelopMode then printx(0, "newCycle------------------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!") end
        return math.ceil(curCycleTime), true
    end

    return math.ceil(curCycleTime), false
end

function PushBindingLogic:resetData()
    _writeToFile({})
end

function PushBindingLogic:updatePushShowShift(pushType)
    if not pushType then return end
    local pushName = PlatformConfig:getPlatformAuthName( pushType )
    if pushName then
        setString("last_cycle_decision_type", pushName) 
        setString("last_popout_decision_type", pushName)
        local key = "last_cycle_"..pushName.."_shift"
        if getInt(key, 1) == 1 then
            setInt(key, 0)
        else
            setInt(key, 1)
        end
    end
end

function PushBindingLogic:getPushShowShift(pushType, default)
    if not pushType then return 0 end
    local pushName = PlatformConfig:getPlatformAuthName( pushType )
    if pushName then
        local key = "last_cycle_"..pushName.."_shift"
        return getInt(key, default or 0)
    end
    return default
end

function PushBindingLogic:getAwardTimeLeft(initFlag, panelName, hasAwardIcon)
    local curCycleTime, newCycle = PushBindingLogic:getCurCycleTime(initFlag, hasAwardIcon)
    if newCycle then
        local pushType = nil
        if PushBindingLogic:isValidPushBindPanel(panelName) then
            pushType = panelName.loginType
        end
        self:updatePushShowShift(pushType)
    end
    if curCycleTime ~= nil then return curCycleTime + 86400 - Localhost:timeInSec() end
    return -1 -- 默认情况下不开启
end

function PushBindingLogic:getPushBindType()
    if PushBindingLogic.pushData ~= nil and PushBindingLogic.pushData.pushBindType ~= nil then return PushBindingLogic.pushData.pushBindType end
    return -1
end

function PushBindingLogic:getPushBindAward(bindType)
    local pushBindType = PushBindingLogic:getPushBindType()
    if _G.isLocalDevelopMode then printx(0, "acc-----------------------pushBindType", pushBindType) end
    local itemID, num, rewardId
    if pushBindType == bindType then
        local rewardStr = MetaManager:getInstance():getPushBindReward(bindType)
        rewardId = MetaManager:getInstance():getPushBindRewardId(bindType)
        if rewardStr ~= nil then
            local rewardAry = string.split(rewardStr, ":")
            itemID = tonumber(rewardAry[1])
            num = tonumber(rewardAry[2])
        end
    end

    return itemID, num, rewardId
end

function PushBindingLogic:getCycleStartDay()
    local curCycleTime = PushBindingLogic:getCurCycleTime(false)
    return Localhost:getDayStartTimeByTS(curCycleTime)
end

function PushBindingLogic:getAllCycleForcePopKey()
    return "bindingForcePop" .. getInt("bindingAwardCycleStart", 0) .. "All"
end

function PushBindingLogic:getCycleAllForcePopNum()
    return getInt(PushBindingLogic:getAllCycleForcePopKey(), 0)
end

function PushBindingLogic:addCycleAllForcePopNum()
    local curForcePop = PushBindingLogic:getCycleAllForcePopNum()
    -- if _G.isLocalDevelopMode then printx(0, "add all pop num------------------------old:", curForcePop) end
    -- if _G.isLocalDevelopMode then printx(0, debug.traceback()) end
    setInt(PushBindingLogic:getAllCycleForcePopKey(), curForcePop + 1)
    -- if _G.isLocalDevelopMode then printx(0, "add all pop num------------------------new:", PushBindingLogic:getCycleAllForcePopNum()) end
end

function PushBindingLogic:getCycleNoAwardForcePopKey()
    return "bindingForcePop" .. getInt("bindingAwardCycleStart", 0)
end

function PushBindingLogic:getNoAwardForcePopoutNum()
    return getInt(PushBindingLogic:getCycleNoAwardForcePopKey(), 0)
end

function PushBindingLogic:addNoAwardForcePopoutNum()
    local curForcePop = PushBindingLogic:getNoAwardForcePopoutNum()
    -- if _G.isLocalDevelopMode then printx(0, "addNoAwardForcePopoutNum----------------------", curForcePop) end
    setInt(PushBindingLogic:getCycleNoAwardForcePopKey(), curForcePop + 1)
    -- if _G.isLocalDevelopMode then printx(0, "addNoAwardForcePopoutNum----------------------",  getInt(PushBindingLogic:getCycleNoAwardForcePopKey(), 0)) end
end

function PushBindingLogic:setLocalDataPopFlag()
    PushBindingLogic:setTodayPopFlag()
end

function PushBindingLogic:setTodayPopFlag()
    setBool(PushBindingLogic:getDailyPopKey(), true)
end

function PushBindingLogic:runPopAddFriendPanelLogic(dcSource, qqCallback)
    local numberOfFriendsBeforeSync = FriendManager.getInstance():getFriendCount()
    local function onBindQQSuccess()
        DcUtil:UserTrack({category = 'login', sub_category = 'login_qq_success_source', t1 = dcSource})
        local function onSyncQQFriendSuccess()
            local numberOfFriendsAfterSync = FriendManager.getInstance():getFriendCount()
            if numberOfFriendsAfterSync == 0 then
                CommonTip:showTip(localize("add.friend.panel.add.qq.tip4"), "positive", nil, 2)
                return
            end

            if numberOfFriendsBeforeSync >= FriendManager:getInstance():getMaxFriendCount() then
                CommonTip:showTip(localize("add.friend.panel.add.qq.tip1", {num = numberOfFriendsAfterSync}), "positive", nil, 2)
                return
            end

            if numberOfFriendsAfterSync >= FriendManager:getInstance():getMaxFriendCount() then
                CommonTip:showTip(localize("add.friend.panel.add.qq.tip3", {num = numberOfFriendsAfterSync}), "positive", nil, 2)
            else
                CommonTip:showTip(localize("add.friend.panel.add.qq.tip2", {num = numberOfFriendsAfterSync}), "positive", nil, 2)
            end
            GlobalEventDispatcher:getInstance():removeEventListener(SyncSnsFriendEvents.kSyncSuccess, onSyncQQFriendSuccess)
        end
        local function onSyncQQFriendFailed()
            CommonTip:showTip("同步QQ好友失败！", "negative",nil, 2)
            GlobalEventDispatcher:getInstance():removeEventListener(SyncSnsFriendEvents.kSyncFailed, onSyncQQFriendFailed)
        end

        GlobalEventDispatcher:getInstance():addEventListener(SyncSnsFriendEvents.kSyncSuccess, onSyncQQFriendSuccess)
        GlobalEventDispatcher:getInstance():addEventListener(SyncSnsFriendEvents.kSyncFailed, onSyncQQFriendFailed)
        if qqCallback then qqCallback() end
    end
    local function onBindQQFail()
        if qqCallback then qqCallback() end
    end
    local function onBindQQCancel()
        if qqCallback then qqCallback() end
    end

    -- local function goBindQQ()
    --     AccountBindingLogic:bindNewSns(PlatformAuthEnum.kQQ, onBindQQSuccess, onBindQQFail, onBindQQCancel, AccountBindingSource.PUSH_BINDING_LOGIC, hasReward)
    -- end
    -- if hasBindedQQ() or not PlatformConfig:hasAuthConfig(PlatformAuthEnum.kQQ, true) then
        createAddFriendPanel("recommend")
    -- else
    --     goBindQQ()
    -- end
end

function PushBindingLogic:runChooseFriendLogic(chooseFriendFunc, dcSource)
    local friendCount = FriendManager:getInstance():getFriendCount()
    if friendCount == 0 then
        if WXJPPackageUtil.getInstance():isWXJPPackage() then 
            CommonTip:showTip(localize("wxjp.nofriend.warning.tip"), "negative",nil, 2)
        else
            PushBindingLogic:runPopAddFriendPanelLogic(dcSource)
        end
    else
        if chooseFriendFunc and type(chooseFriendFunc) == 'function' then
            chooseFriendFunc()
        end
    end
end

function PushBindingLogic:profileCustomized()
    return UserManager:getInstance().profile.customProfile == true
end

function PushBindingLogic:extraInfoEdited()
    if UserManager:getInstance().profile ~= nil and
       (UserManager:getInstance().profile.gender == nil or UserManager:getInstance().profile.gender == 0) and
       -- (UserManager:getInstance().profile.age == nil or UserManager:getInstance().profile.age == 0) and
       -- (UserManager:getInstance().profile.constellation == nil or UserManager:getInstance().profile.constellation == 0) and
       (UserManager:getInstance().profile.location == nil or UserManager:getInstance().profile.location == '') and
       (UserManager:getInstance().profile.birthDate == nil or UserManager:getInstance().profile.birthDate == '') then
       return false
   end

   return true
end

function PushBindingLogic:isTodayForcePopout()
    local lastPopTime = getInt("last_popout_decision_time", 0)
    return Localhost:getDayStartTimeByTS(lastPopTime) == Localhost:getDayStartTimeByTS(Localhost:timeInSec()) 
end

