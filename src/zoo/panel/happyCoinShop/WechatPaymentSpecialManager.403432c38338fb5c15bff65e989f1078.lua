
WechatPaymentSpecialManager = {}

local isEnable = false 
function WechatPaymentSpecialManager:checkHasWechatPayment(productInfo)
	for i,v in ipairs(productInfo) do
		if WechatPaymentSpecialManager:isWechatLike(v.productName) then 
			isEnable = true
			return 
		end
	end	
	isEnable = false 
end

function WechatPaymentSpecialManager:isEnable()
	return isEnable
end

function WechatPaymentSpecialManager:isEnableForBubbleShow()
	return isEnable and MaintenanceManager:getInstance():isEnabled("WechatPopOnly")
end

function WechatPaymentSpecialManager:isWechatLike(payType)
	local numPayTypes = {Payments.QQ, Payments.MIDAS, Payments.WECHAT}
	local productNamePayTypes = {"msdk", "wechat_2"}
	if type(payType) == "number" then 
		return table.includes(numPayTypes, payType)
	elseif type(payType) == "string" then 
		return table.includes(productNamePayTypes, payType)
	end
	return false
end