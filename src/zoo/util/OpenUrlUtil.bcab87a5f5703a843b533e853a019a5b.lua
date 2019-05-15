OpenUrlUtil = class()

-- schemeNotSupportedCallback: 如果url是一个不认识的Scheme，可以指定回调，在回调里面处理逻辑
function OpenUrlUtil:openUrl(url, schemeNotSupportedCallback)
    if __IOS then
        if UIApplication:sharedApplication():canOpenURL(NSURL:URLWithString(url)) then
            UIApplication:sharedApplication():openURL(NSURL:URLWithString(url))
        else
            if schemeNotSupportedCallback then
                schemeNotSupportedCallback()
            end
        end
    elseif __ANDROID then
        local success = luajava.bindClass("com.happyelements.android.utils.HttpUtil"):openUri(url)
        if not success then
            if schemeNotSupportedCallback then
                schemeNotSupportedCallback()
            end
        end
    elseif __WP8 then
        Wp8Utils:OpenUrl(url)
    end
end

function OpenUrlUtil:canOpenUrl(url)
   if __IOS then
        return UIApplication:sharedApplication():canOpenURL(NSURL:URLWithString(url))
    elseif __ANDROID then
        local status, result = pcall(function() return luajava.bindClass("com.happyelements.android.utils.HttpUtil"):canOpenUrl(url) end)
        return status and result
    end 
    return false
end

-- function OpenUrlUtil:openUrlScheme(url, alternativeUrl, schemeNotSupportedCallback)
--     if __IOS then
--         if UIApplication:sharedApplication():canOpenURL(url) then
--             UIApplication:sharedApplication():openURL(NSURL:URLWithString(url))
--         elseif alternativeUrl or schemeNotSupportedCallback then
--             if alternativeUrl then 
--                 OpenUrlUtil:openUrl(alternativeUrl) 
--             end

--             if schemeNotSupportedCallback then
--                 schemeNotSupportedCallback()
--             end
--         else 
--             UIApplication:sharedApplication():openURL(NSURL:URLWithString(url))
--         end
--     elseif __ANDROID then
--         local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder')
--         local uri = luajava.bindClass("android.net.Uri"):parse(url)
--         local intent = luajava.newInstance("android.content.Intent", "android.intent.action.VIEW", uri)
--         local resolveInfo = MainActivityHolder.ACTIVITY:getPackageManager():resolveActivity(intent, 64);
--         if resolveInfo then
--             MainActivityHolder.ACTIVITY:startActivity(intent)
--         elseif alternativeUrl or schemeNotSupportedCallback then
--             if alternativeUrl then 
--                 OpenUrlUtil:openUrl(alternativeUrl) 
--             end
--             if schemeNotSupportedCallback then
--                 schemeNotSupportedCallback()
--             end
--         else
--             -- 安卓平台这里不默认打开连接，因为可能引起崩溃
--         end
--     elseif __WP8 then
--         Wp8Utils:OpenUrl(url)
--     end
-- end
