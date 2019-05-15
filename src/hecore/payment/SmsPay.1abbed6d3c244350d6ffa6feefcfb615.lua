-- bubble require dc class
-- require "bubble.counter.CountManager"

require "hecore.luaJavaConvert"

local cTable = {
    {"1", "刷新", "30000807400101", "140121023049", "3"}, 
    {"2", "后退1步", "30000807400102", "140121023050", "2"}, 
    {"3", "强制交换", "30000807400103", "140121023051", "9"}, 
    {"5", "魔法棒", "30000807400104", "140121023052", "10"}, 
    {"7", "小木锤", "30000807400105", "140121023053", "4"}, 
    -- {"6", "小木锤打折版", "30000807400106", "140121023054", "2"}, 
    {"4", "加5步", "30000807400107", "140121023055", "6"}, 
    {"24", "游戏加5步", "30000807400107", "140121023055", "4"},
    {"33", "游戏加5步打折", "30000807400108", "140121023056", "4"}, 
    -- {"9", "中级精力瓶", "30000807400109", "140121023057", "3"}, 
    -- {"10", "中级精力瓶打折版", "30000807400110", "140121023058", "1"}, 
    {"18", "高级精力瓶", "30000807400111", "140121023059", "18"}, 
    {"10001", "60风车币", "30000807400112", "140121023060", "6"}, 
    {"10002", "125风车币", "30000807400113", "140121023061", "12"}, 
    {"10003", "300风车币", "30000807400114", "140121023062", "28"}, 
    {"19", "新区域解锁1", "30000807400115", "140121023063", "1"},
    {"20", "新区域解锁2", "30000807400115", "140121023063", "1"}, 
    {"21", "新区域解锁3", "30000807400115", "140121023063", "1"}, 
    {"22", "新区域解锁4", "30000807400115", "140121023063", "1"}, 
    {"26", "新区域解锁5", "30000807400115", "140121023063", "1"}, 
    {"27", "新区域解锁6", "30000807400115", "140121023063", "1"}, 
    {"32", "新区域解锁7", "30000807400115", "140121023063", "1"}, 
    {"41", "新区域解锁8", "30000807400115", "140121023063", "1"}, 
    {"42", "新区域解锁9", "30000807400115", "140121023063", "1"}, 
    {"44", "新区域解锁10", "30000807400115", "140121023063", "1"}, 
    {"54", "新区域解锁11", "30000807400115", "140121023063", "1"},
    {"56", "新区域解锁12", "30000807400115", "140121023063", "1"}, 
    {"64", "新区域解锁13", "30000807400115", "140121023063", "1"}, 
    {"69", "新区域解锁14", "30000807400115", "140121023063", "1"},
    {"70", "精力值加到40永久", "30000807400116", "140121023064", "29"}
}

local itemDict = {}

local function createItemDict()
    for i ,v in ipairs(cTable) do 
        itemDict[tonumber(v[1])] = {
            id = v[1],
            props = v[2],
            mmPayCode = v[3], 
            uniPayCode = v[4], 
            price = v[5],
        }
    end
end

createItemDict()

SmsPay = class()

function SmsPay:purchaseItem(itemId, itemAmount, itemPrice, realAmount, callback)
    he_log_info("SmsPay:purchaseItem:" .. " itemId:" .. itemId .. " ,itemAmount:" ..  itemAmount .. " ,itemPrice:" .. itemPrice  ..  " ,realAmount:" .. realAmount )
    
    -- TODO get user coin number
    -- local coin1 = SecretInteger.getNumber(user.cash);

	if not self.smsPayment then 
		self.smsPayment = luajava.bindClass("com.happyelements.android.operatorpayment.OPPaymentClient")
	end

	local buyCallback = luajava.createProxy("com.happyelements.android.InvokeCallback", {
        onSuccess = function (result)
            callback(luaJavaConvert.map2Table(result))
            -- callback(false)
        end,
        onError = function (code, errMsg)
            -- TODO pop payment failure message
            -- system.toast("Payment failure.")
            callback(false)
        	he_log_error("++++ buy.failed:"..tostring(code).."-"..errMsg)    
        end,
        onCancel = function ()
            callback("cancel")
        end
    });

    local item = itemDict[tonumber(itemId)]

    if item then
        item.money = item.price -- * 1
        self.smsPayment:buy(luaJavaConvert.table2Map(item), buyCallback)
    else
        local function confirmCallBack()
            -- TODO  display confirm payment panel
            -- RechargeManager.sharedManager():showPanel()
        end 

        local function cancelCallback()           
        end

        -- TODO do not exist item logic.
        -- show error panel or somthing.
        -- local scene = Director:sharedDirector():getRunningScene();
    end
end

function SmsPay:testPurchaseItem()
    if not self.test_purchase_item then
        self.test_purchase_item = 1
    elseif self.test_purchase_item > 16 then
        self.test_purchase_item = 1
    end

    local itemId = self.test_purchase_item
    if _G.isLocalDevelopMode then printx(0, "Info - Keypad Callback: payment purchaseItem[" .. tostring(itemId) .. "]") end

    self:purchaseItem(itemId, 1, 1, 1, 
        function(code) 
            if not code then
                code = "nil"
            end
            if _G.isLocalDevelopMode then printx(0, "Info - Keypad Callback: payment code[" .. tostring(code) .. "], purchaseItem[" .. tostring(itemId) .. "]") end
        end
    )
    self.test_purchase_item = itemId + 1
end
