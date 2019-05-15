AliQuickPayPromoLogic = class()

local pf = StartupConfig:getInstance():getPlatformName()
local forcePopKey = "ali.mm.promo.pop"
local promo_duration = 12 * 3600
local main_key = 'AliKfPromoGlobalEnable'

local function now()
    return Localhost:time()
end

local function getConfigPath()
    return HeResPathUtils:getUserDataPath() .. '/ali_mm_promo_data_'..(UserManager:getInstance().user.uid or '0')..'_'..pf
end

local function writeConfig(data)
    local file = io.open(getConfigPath(),"w")
    if file then 
        file:write(table.serialize(data or {}))
        file:close()
    end
end

local function readConfig()
    local _config = nil

    local file = io.open(getConfigPath(), "r")
    if file then
        local data = file:read("*a") 
        file:close()
        if data then
            _config = table.deserialize(data) or {}
        end
    end

    if not _config then 
        _config = {}
        _config.isOver = false
        _config.started = false
        writeConfig(_config)
    end

    return _config
end

function AliQuickPayPromoLogic:initConfig()
    readConfig()
end

function AliQuickPayPromoLogic:isEntryEnabled()
    -- if __WIN32 then return true end -- test
    -- 主开关
    if not MaintenanceManager:getInstance():isEnabled(main_key) then
        return false
    end

    -- 已经看到活动的，无需再判断其他条件
    if AliQuickPayPromoLogic:isInPromotion() then
        printx( 3 , ' isEntryEnabled 11111111')
        return true
    end

    if UserManager:getInstance().user:getTopLevelId() < 23 then
        return false
    end    

    if not _G.kUserLogin then 
        printx( 3 , ' isEntryEnabled 22222222')
        return false 
    end -- 没登录没网就看不到

    if not UserManager:getInstance():isAliNeverSigned() then
        printx( 3 , ' isEntryEnabled 3333333')
        return false
    end 

    local key = ''
    local defaultPayment = PaymentManager:getInstance():getDefaultPayment()
    if defaultPayment == Payments.WECHAT or defaultPayment == Payments.QQ_WALLET then
        key = 'AliKfPromoEnableEntryWechat'
    elseif defaultPayment == Payments.ALIPAY then
        key = 'AliKfPromoEnableEntryAli'
    elseif PaymentManager:checkPaymentTypeIsSms(defaultPayment) then
        key = 'AliKfPromoEnableEntrySms'
    end
        
    if MaintenanceManager:getInstance():isEnabled(key) ~= true then
        printx( 3 , ' isEntryEnabled 4444444')
        return false
    end

    local num = MaintenanceManager:getInstance():getValue(key)
    if num == nil then num = 100 end
    num = tonumber(num)
    local uid = UserManager.getInstance().user.uid
    uid = tonumber(uid)
    if uid ~= nil then
        printx( 3 , ' isEntryEnabled 55555555 ', (uid % 100) < num)
        return (uid % 100) < num
    else
        printx( 3 , ' isEntryEnabled 6666666')
        return false
    end
end

function AliQuickPayPromoLogic:isForcePopEnabled()
    -- if __WIN32 then return false end -- test
    -- 主开关
    if not MaintenanceManager:getInstance():isEnabled(main_key) then
        return false
    end

    -- 已经强弹
    if AliQuickPayPromoLogic:getForcePopValue() == true then
        return false
    end

    if UserManager:getInstance().user:getTopLevelId() < 23 then
        return false
    end    

    if not _G.kUserLogin then return false end -- 没登录没网就看不到

    local key = ''
    local defaultPayment = PaymentManager:getInstance():getDefaultPayment()
    if defaultPayment == Payments.WECHAT or defaultPayment == Payments.QQ_WALLET then
        key = 'AliKfPromoEnableForcePopWechat'
    elseif defaultPayment == Payments.ALIPAY then
        key = 'AliKfPromoEnableForcePopAli'
    elseif PaymentManager:checkPaymentTypeIsSms(defaultPayment) then
        key = 'AliKfPromoEnableForcePopSms'
    end
    
    if MaintenanceManager:getInstance():isEnabled(key) ~= true then
        return false
    end

    local num = MaintenanceManager:getInstance():getValue(key)
    if num == nil then num = 100 end
    num = tonumber(num)
    local uid = UserManager.getInstance().user.uid
    uid = tonumber(uid)
    if uid ~= nil then
        return (uid % 100) < num
    else
        return false
    end
end

function AliQuickPayPromoLogic:startPromotion()
    local config = readConfig()
    config.isOver = false
    config.started = true
    writeConfig(config)
end

function AliQuickPayPromoLogic:endPromotion()
    local config = readConfig()
    config.isOver = true
    writeConfig(config)
end

function AliQuickPayPromoLogic:isInPromotion()
    local config = readConfig()
    if config.isOver == false and config.started == true then
        return true
    end
    return false
end

function AliQuickPayPromoLogic:setForcePopValue(value)
    CCUserDefault:sharedUserDefault():setBoolForKey(forcePopKey, value == true)
end

function AliQuickPayPromoLogic:getForcePopValue()
    return CCUserDefault:sharedUserDefault():getBoolForKey(forcePopKey, false)
end

function AliQuickPayPromoLogic:removeHomeSceneButton()
    local scene = HomeScene:sharedInstance()
    local button = scene.aliKfPromoButton
    if button and AliQuickPayPromoLogic:isEntryEnabled() then
        if scene.rightRegionLayoutBar:containsItem(scene.aliKfPromoButton) then
            scene.rightRegionLayoutBar:removeItem(scene.aliKfPromoButton)
            scene.aliKfPromoButton = nil
        end
    end
    AliQuickPayPromoLogic:endPromotion()
end


-- local inited = false
-- if not inited then
--     AliQuickPayPromoLogic:initConfig()
--     inited = true
-- end