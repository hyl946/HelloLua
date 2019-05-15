require "hecore.luaJavaConvert"

local kSmsDest = "10658077016622"
local locals = {title="提示", confirmLabel="确认购买", cancelLabel="取消购买", succeedMsg="购买成功！", failMsg="购买失败！"}
local kSmsUtil

MdoPay = class()

function MdoPay:purchaseItem(itemId, itemAmount, itemPrice, realAmount, callback)
	he_log_info("MdoPay:purchaseItem:" .. " itemId:" .. itemId .. " ,itemAmount:" ..  itemAmount .. " ,itemPrice:" .. itemPrice  ..  " ,realAmount:" .. realAmount )
    
	if not kSmsUtil then kSmsUtil = luajava.bindClass("com.happyelements.hellolua.share.SmsUtil") end
	local item = MetaManager:getGoodPayCodeMeta(itemId)
	local channelID = ""
	local androidPlatformName = StartupConfig:getInstance():getPlatformName()

	if androidPlatformName == "duoku" then channelID = "622009"
	elseif androidPlatformName == "baiduapp" then channelID = "622001"
	elseif androidPlatformName == "91" then channelID = "622006" end

	local dest = kSmsDest
	local code = item.MDOPayCode .. channelID
	
	local alert = luaJavaConvert.table2Map(locals)
	alert:put("alert", item.MDOText)
	--if _G.isLocalDevelopMode then printx(0, "MdoPay:iteminfo"..table.tostring(item)) end
	local buyCallback = luajava.createProxy("com.happyelements.android.InvokeCallback", {
        onSuccess = function (result)
        	local result = luaJavaConvert.map2Table(result)
        	result.channelId = channelID
            callback(SnsCallbackEvent.onSuccess, result)
        end,
        onError = function (code, errMsg)
            callback(SnsCallbackEvent.onCancel)
        	he_log_error("++++ buy.failed:"..tostring(code).."-"..errMsg)
        end,
        onCancel = function ()
            callback(SnsCallbackEvent.onCancel)
        end
    });

	kSmsUtil:sendAnimalTextMessage(dest, code, alert, buyCallback)
end

function MdoPay:testPurchaseItem()
end
