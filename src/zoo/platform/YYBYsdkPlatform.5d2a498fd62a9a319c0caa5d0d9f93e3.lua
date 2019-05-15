YYBYsdkPlatform = {}

YYBYsdkPlatform.hasUpdate=false
YYBYsdkPlatform.isByPatch=false

local mgr = nil

local status, msg = xpcall(function()
        mgr = luajava.bindClass("com.happyelements.android.animal.ysdklibrary.YYBSelfUpdate"):getInstance()
    end, __G__TRACKBACK__)

printx(-99,"YYBYsdkPlatform()" .. tostring(mgr))

--检查应用宝是否有更新包
function YYBYsdkPlatform:checkUpdate()
    local callback = luajava.createProxy("com.happyelements.android.InvokeCallback", {
        onSuccess = function (result)

            YYBYsdkPlatform.hasUpdate = true
            YYBYsdkPlatform.isByPatch = result
            YYBYsdkPlatform.patchSize = tonumber(result)

            printx(0,"YYBYsdkPlatform:checkUpdate() onSuccess()" .. table.tostring(YYBYsdkPlatform.isByPatch),YYBYsdkPlatform.patchSize)

            -- if YYBYsdkPlatform and YYBYsdkPlatform:isUpdateBySelf() then
            --     YYBYsdkPlatform:startUpdate()
            --     return
            -- end
        end,
        onError = function (code, errMsg)
        end,
        onCancel = function ()
        --已是最新版本
        end
    });

    local _ = mgr and mgr:checkUpdate(callback)
end

--是否启动自更新
function YYBYsdkPlatform:isUpdateBySelf()
    local isEnabled = MaintenanceManager:getInstance():isEnabledInGroup('YYBSelfUpdatePatch', 'A1', UserManager:getInstance().uid)
    printx(0,"YYBYsdkPlatform:isUpdateBySelf() isEnabled:" ..tostring(isEnabled) .."-up & patch:".. tostring(YYBYsdkPlatform.hasUpdate) .. "-" .. tostring(YYBYsdkPlatform.isByPatch))
	return isEnabled and YYBYsdkPlatform.hasUpdate and YYBYsdkPlatform.isByPatch
end

--执行自更新
function YYBYsdkPlatform:startUpdate()
    --拉起应用宝进行增量更新，这里不额外处理回调逻辑
    local completeCallback = luajava.createProxy("com.happyelements.android.InvokeCallback", {
        onSuccess = function (result)
            printx(0,"YYBYsdkPlatform:completeCallback onSuccess()" .. table.tostring(result))
        end,
        onError = function (code, errMsg)
            printx(0,"YYBYsdkPlatform:completeCallback onError()" .. tostring(code).. tostring(errMsg))
        end,
        onCancel = function ()
        end
    });
    local progressCallback = luajava.createProxy("com.happyelements.android.InvokeCallback", {
        onSuccess = function (result)
            --进度百分数
            printx(0,"YYBYsdkPlatform:progressCallback progress:" .. tostring(result))
        end,
        onError = function (code, errMsg)
        end,
        onCancel = function ()
        end
    });
    printx(0,"YYBYsdkPlatform:startUpdate()",tostring(mgr),tostring(mgr.startUpdate))
    local _ = mgr and mgr:startUpdate(completeCallback,progressCallback)
end