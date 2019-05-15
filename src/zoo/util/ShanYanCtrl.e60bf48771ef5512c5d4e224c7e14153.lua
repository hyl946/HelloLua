local ShanYanCtrl = {}

local debugLog = _G.isLocalDevelopMode

if __ANDROID then
    local javaLatestModify = 0
    pcall(function()
        local MainActivityHolder = luajava.bindClass("com.happyelements.android.MainActivityHolder")
        javaLatestModify = MainActivityHolder.ACTIVITY:getLatestModify()
    end)

    if javaLatestModify<12 then
        if debugLog then print("ShanYanCtrl Not support old version:"..tostring(javaLatestModify)) end
        ShanYanCtrl.enabled = false
        ShanYanCtrl.init = function () end
        ShanYanCtrl.start = function () end
        -- ToastTip:create("无此功能")
        return ShanYanCtrl
    end
end

-- HttpsClient
local callbackUrl = HTTPS_ROOT_URL .. "quickPhoneVerify"

local APP_CFG = {
{"com.happyelements.1OSAnimal"   ,   "xPvArIju"   ,   "cCBuGEFx"},
-- {"com.happyelements.AndroidAnimal"   ,   "bVYKeU5K"   ,   " AKeopc5t"},
{"com.happyelements.AndroidAnimal"   ,   "KJMbkbkL"   ,   "3OuLvPzQ"},
{"com.tencent.tmgp.AndroidAnimal"   ,   "sGiQI4oY"   ,   "nkHTsRqs"},
{"com.happyelements.AndroidAnimal.ad"   ,   "46G28fJs"   ,   "GnmK2nMn"},
{"com.happyelements.AndroidAnimal.wdj"   ,   "0SwCln1Z"   ,   "6JcsBlED"},
{"com.happyelements.AndroidAnimal.mitalk"   ,   "Otljednj"   ,   "k7dyS2ld"},
{"com.happyelements.AndroidAnimal.jinli"   ,   "km0YeQWr"   ,   "Xv3GLssk"},
{"com.happyelements.AndroidAnimal.egame"   ,   "bbFkjuID"   ,   "zRFTQ6PA"},
{"com.happyelements.AndroidAnimal.doov"   ,   "OaZcObtE"   ,   "9pHViGIj"},
{"com.happyelements.AndroidAnimal.coolpad"   ,   "xpXhQ6tv"   ,   "vvt7GhGQ"},
{"com.happyelements.AndroidAnimal.mi"   ,   "rekXJ81L"   ,   " P97Zkm3b"},
{"com.happyelements.AndroidAnimal.qq"   ,   "lPZ0oYz3"   ,   "0vozGLhX"}
}

for i,v in ipairs(APP_CFG) do
    APP_CFG[v[1]] = v
end

function ShanYanCtrl:isEnabled()
    -- do return true end
    -- local isOpen = MaintenanceManager:getInstance():isEnabled('shanyan',  false)
    local isOpen = MaintenanceManager:getInstance():isEnabledInGroup('shanyan', 'open', UserManager:getInstance().uid)

    return isOpen
end

function ShanYanCtrl:getAppConfig()
    return APP_CFG[_G.packageName]
    -- return APP_CFG["com.happyelements.AndroidAnimal1"]
end

function ShanYanCtrl:getDebugInfo()
    local cfg  = ShanYanCtrl:getAppConfig()
    return tostring(_G.packageName) .. "-" .. tostring(cfg and cfg[2]) .. " - " ..tostring(cfg and cfg[3])
end

function ShanYanCtrl:log(...)
    local cfg = ShanYanCtrl:getAppConfig()

    local temp = {...}
    if debugLog then print("ShanYanCtrl:log",...) end
    -- Alert:create(msg)

    -- RemoteDebug:uploadLogWithTag('sy()'.. tostring(temp[1]) ,table.tostring(temp) .. "\n\n"
    --     ..tostring(_G.packageName) .. table.tostring(cfg) .. "\n\n\n"
    --     .. debug.traceback())
end

function ShanYanCtrl:init()
    if debugLog then ShanYanCtrl:log("ShanYanCtrl:init() Maintenance enabled:",ShanYanCtrl:isEnabled()) end

    if not ShanYanCtrl:isEnabled() then
        return
    end
    if ShanYanCtrl.isInited then
        return
    end
    ShanYanCtrl.isInited = true
    local cfg = ShanYanCtrl:getAppConfig()
    
	if __ANDROID then
        if debugLog then ShanYanCtrl:log("闪验初始化_安卓") end
	    local shanyan = luajava.bindClass("com.happyelements.android.ShanYanInterface")
	    shanyan = shanyan:getInstance()
	    shanyan:init(callbackUrl,cfg[2],cfg[3])

    elseif __IOS then
        if debugLog then ShanYanCtrl:log("闪验初始化_ios") end

        waxClass{"ShanYanInitCallbackDelegate", "NSObject", protocols = {"SimpleCallbackDelegate"}}
        ShanYanInitCallbackDelegate.onSuccess = function(target,result)
            if debugLog then ShanYanCtrl:log("ShanYanCtrl:init()result()",table.tostring(result)) end
        end

        ShanYanInterfaceBridge:initShanYan(cfg[2],cfg[3],ShanYanInitCallbackDelegate:init())
	end

end

function ShanYanCtrl:start(source,okCallback,errorCallback,cancelCallback)
    if debugLog then ShanYanCtrl:log("ShanYanCtrl:start()",source,ShanYanCtrl:isEnabled(),ShanYanCtrl.isInited) end

    ShanYanCtrl.loadingAnim = nil

    local function removeLoading()
        if not ShanYanCtrl.loadingAnim then return end
        ShanYanCtrl.loadingAnim:removeFromParentAndCleanup(true)
        ShanYanCtrl.loadingAnim = nil
    end

    local function onOtherWay(errTip)
        removeLoading()
        if debugLog then ShanYanCtrl:log("ShanYanCtrl:start()onOtherWay()",errTip) end
        if errTip then
            local text = {
                tip = "手机号获取失败，请使用验证码方式登录~",
                yes = "确定",
            }
            CommonTipWithBtn:showTip(text, "negative", errorCallback, nil, nil, true)

        else
            local _ = errorCallback and errorCallback()
        end
    end

    if not ShanYanCtrl:isEnabled() then
        onOtherWay()
        return
    end

    if source and source~=AccountBindingSource.PUSH_BIND_PANEL then
        onOtherWay()
        return
    end

    if not __ANDROID and not __IOS then
        if debugLog then
            ShanYanCtrl:log("闪验拉起失败.非安卓且非IOS . 此时使用其他号码登录" .. ShanYanCtrl:getDebugInfo())
        end

        onOtherWay()
        return
    end

    local shanyanData = nil
    local cfg = ShanYanCtrl:getAppConfig()

    local function onCallback(response)
        if debugLog then ShanYanCtrl:log("ShanYanCtrl:start()verify onCallback()",response.httpCode,response.body) end
        if response.httpCode ~= 200 then 
            if debugLog then
                ShanYanCtrl:log("闪验校验失败.后端失败. 此时使用其他号码登录" .. tostring(response.httpCode) .. "--" .. ShanYanCtrl:getDebugInfo())
            end
            onOtherWay("1000:"..tostring(response.httpCode))
        else
            local resp = table.deserialize(response.body)
            if resp and resp.code and resp.code == 200 then
                local phone = resp.phone
                local openId = resp.openId
                local accessToken = resp.accessToken
                local isPhoneBind = resp.isPhoneBind

                setTimeOut(function()
                    local _ = okCallback and okCallback(openId,phone,accessToken,isPhoneBind)
                end,0.01)

            else
                if debugLog then
                    ShanYanCtrl:log("闪验校验失败 后端失败. 此时使用其他号码登录" .. table.tostring(resp) .. "--" .. ShanYanCtrl:getDebugInfo())
                end
                onOtherWay("1000:" .. tostring(resp and resp.code or -2))

            end
        end
    end

    local function onVerifyPhone()
        if not shanyanData or not shanyanData.accessToken then
            if debugLog then ShanYanCtrl:log("onVerifyPhone() no shanyanData.accessToken",
                table.tostring(shanyanData)) end

            onOtherWay("1000:-1")
            return
        end

        local request = HttpRequest:createPost(callbackUrl)
        request:addPostValue("accessToken",tostring(shanyanData.accessToken))
        request:addPostValue("telecom",tostring(shanyanData.telecom))
        request:addPostValue("timestamp",tostring(shanyanData.timestamp))
        request:addPostValue("randoms",tostring(shanyanData.randoms))
        request:addPostValue("version",tostring(shanyanData.version))
        request:addPostValue("device",tostring(shanyanData.device))
        request:addPostValue("sign",tostring(shanyanData.sign))
        request:addPostValue("appId",tostring(cfg[2]))
        request:addPostValue("appKey",tostring(cfg[3]))
        request:addPostValue("deviceUdid",tostring(MetaInfo:getInstance():getUdid()))
        request:addPostValue("source",tostring(source))
        request:addPostValue("pf",tostring(StartupConfig:getInstance():getPlatformName()))
        request:addPostValue("uid",tostring(UserManager:getInstance().uid))
        
        request:setConnectionTimeoutMs(2000)
        request:setTimeoutMs(3000)
        HttpClient:getInstance():sendRequest(onCallback, request)
    end

    local scene = Director:sharedDirector():getRunningScene()
    ShanYanCtrl.loadingAnim = CountDownAnimation:createNetworkAnimation(scene)

    --成功
    local function onSuccess(result)
        removeLoading()
        shanyanData = result
        if debugLog then ShanYanCtrl:log("ShanYanCtrl:start()onSuccess()",table.tostring(shanyanData)) end

        if debugLog then
            ShanYanCtrl:log("闪验成功："..table.tostring(shanyanData))
        end

        setTimeOut(onVerifyPhone,0.01)

        DcUtil:UserTrack({
            category='login', 
            sub_category='login_flashphone_response',
            source = source,
            result = 0,
            telecom = shanyanData and shanyanData.telecom,
            device = device and shanyanData.device,
        })
    end
    --其他方式登录
    local function onPhoneCode(code, errMsg)
        if debugLog then ShanYanCtrl:log("ShanYanCtrl:start()onPhoneCode()",code, errMsg) end
        removeLoading()
        onOtherWay()
        DcUtil:UserTrack({
            category='login', 
            sub_category='login_flashphone_response',
            source = source,
            result = 1,
            errorcode = code,
            msg = errMsg,
        })
    end
    --失败
    local function onError(code, errMsg)
        if debugLog then ShanYanCtrl:log("ShanYanCtrl:start()onError()",code, errMsg) end
        local errData = table.deserialize(errMsg)

        removeLoading()

        onOtherWay(code~=-1 and tostring(code) or nil)

        DcUtil:UserTrack({
            category='login', 
            sub_category='login_flashphone_response',
            source = source,
            result = 2,
            errorcode = code,
            msg = errMsg,
        })
    end
    --取消
    local function onCancel()
        if debugLog then ShanYanCtrl:log("ShanYanCtrl:start()onCancel()") end
        removeLoading()

        if debugLog then
            ShanYanCtrl:log("闪验取消。")
        end

        DcUtil:UserTrack({
            category='login', 
            sub_category='login_flashphone_response',
            source = source,
            result = 3
        })
    end
    

    local function requestPhone()
        if ShanYanCtrl:_isInitialized() then
            if __ANDROID then
                ShanYanCtrl:_start_Android(onSuccess,onPhoneCode,onError,onCancel)
            elseif __IOS then
                ShanYanCtrl:_start_IOS(onSuccess,onPhoneCode,onError,onCancel)
            end

            DcUtil:UserTrack({
                category='login', 
                sub_category='login_flashphone_request', 
                source = source
            })
        else
            if debugLog then
                ShanYanCtrl:log("闪验拉起失败 .未初始化sdk. 此时使用其他号码登录" .. ShanYanCtrl:getDebugInfo())
            end
            onOtherWay()
        end
    end

    if not ShanYanCtrl.isInited then
        ShanYanCtrl:init()

        local time = 0
        local deltaTime = 0.1
        local checkFn = nil

        local function checkInitDone()
            if ShanYanCtrl:_isInitialized() then
                requestPhone()
                return
            end
            time = deltaTime+deltaTime
            if time<3 then
                onOtherWay()
                return
            end
            setTimeOut(checkFn,deltaTime)
        end
        checkFn = checkInitDone
        setTimeOut(checkFn,deltaTime)
    else
        requestPhone()
    end
end

function ShanYanCtrl:_isInitialized()
    if __ANDROID then
        local shanyan = luajava.bindClass("com.happyelements.android.ShanYanInterface"):getInstance()
        return shanyan:isInitialized()
    end
    if __IOS then
        return ShanYanInterfaceBridge:isInitialized()
    end
    return false
end

function ShanYanCtrl:_start_Android(onSuccess,onPhoneCode,onError,onCancel)
    local callback = luajava.createProxy("com.happyelements.android.ShanYanInvokeCallback", {
        onSuccess = function (result)
            --成功
            local data = table.deserialize(result)
            if debugLog then ShanYanCtrl:log("ShanYanCtrl:_start_Android()onSuccess()",table.tostring(result),table.tostring(data)) end
            onSuccess(data)
        end,
        onError = function (code, errMsg)
            --失败
            if debugLog then ShanYanCtrl:log("ShanYanCtrl:_start_Android()onError()",code, errMsg) end
            local errData = table.deserialize(errMsg)
            local isCancel = false
            local isOtherWay = false

            -- 1011    移动取消免密登录
            -- 1012    电信取消免密登录
            -- 1003    联通取消免密登录 {"code":"1","status":"100018","msg":"用户取消登录","obj":"xx","seq":"xx"}
            if code==1011 or code==1012 or (code == 1003 and errData and errData.status and errData.status == "100018") then
                isCancel = true
            end

            -- 1013 其他号码登录
            if code==1013 then
                isOtherWay = true
            end

            if debugLog then
                local logMsg = isCancel and "用户取消" or isOtherWay and "手工输入手机号验证码登录" or "错误，自动使用手机号登陆"
                ShanYanCtrl:log("闪验失败 . " .. logMsg .. " \n："..tostring(code) .. "\n" ..table.tostring(errMsg) .. ShanYanCtrl:getDebugInfo())
            end

            if isCancel then
                onCancel()

            elseif isOtherWay then
                onPhoneCode(code,errMsg)
            else
                onError(code,errMsg)
            end
        end,
        onCancel = function ()
            --其他方式登录
            if debugLog then ShanYanCtrl:log("ShanYanCtrl:_start_Android()onCancel()") end
            --这里应该改为关闭绑定比较好，java暂时把其他号码也写到这里了，下一版修复
            onPhoneCode()
        end
    });

    local shanyan = luajava.bindClass("com.happyelements.android.ShanYanInterface"):getInstance()
    shanyan:requestPhone(callback)
end

function ShanYanCtrl:_start_IOS(onSuccess,onPhoneCode,onError,onCancel)
    waxClass{"ShanYanSimpleCallbackDelegate", "NSObject", protocols = {"SimpleCallbackDelegate"}}
    ShanYanSimpleCallbackDelegate.onSuccess = function(target,result)
        if debugLog then ShanYanCtrl:log("ShanYanCtrl:_start_IOS()onSuccess()",result,table.tostring(result)) end
        onSuccess(result)
    end

    ShanYanSimpleCallbackDelegate.onFailed = function(target,result)
        if debugLog then ShanYanCtrl:log("ShanYanCtrl:_start_IOS()onFailed()",
            table.tostring(result),table.tostring(t1),table.tostring(t2),table.tostring(t3)) end
        if result.code == -1 then
            --点击自定义按钮：使用其他方式登录
            onPhoneCode()
        elseif result.code == 1011 then
            onCancel()
        else
            onError(result.code,result.message)
        end
    end

    ShanYanSimpleCallbackDelegate.onCancel = function(target,result)
        if debugLog then ShanYanCtrl:log("ShanYanCtrl:_start_IOS()onCancel()",table.tostring(result)) end
        onCancel()
    end

    ShanYanInterfaceBridge:requestPhone(ShanYanSimpleCallbackDelegate:init())
end


return ShanYanCtrl

