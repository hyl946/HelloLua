local Common = {}

function Common:isThirdParty( payType )

	if __WIN32 then
		return payType == Payments.WECHAT or payType == Payments.ALIPAY
	end

	if table.includes({Payments.WO3PAY, Payments.TELECOM3PAY}, payType) then
		return false
	end
	
	local payment = PaymentBase:getPayment(payType)
	return payment.mode == PaymentMode.kThirdParty
end

function Common:isT1( payType )
	local payment = PaymentBase:getPayment(payType)
	return self:isThirdParty(payType) and payment:getPaymentLevel() == PaymentLevel.kLvOne
end

function Common:getOriPayment( paymentType )
	if paymentType == Payments.ALI_QUICK_PAY then 
		paymentType = Payments.ALIPAY
	elseif paymentType == Payments.ALI_SIGN_PAY then 
		paymentType = Payments.ALIPAY
	elseif paymentType == Payments.WECHAT_QUICK_PAY then 
		paymentType = Payments.WECHAT
	end
	return paymentType
end

return Common