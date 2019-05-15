--=====================================================
-- PaymentCheckManager
-- by zhijian.li
-- (c) copyright 2009 - 2016, www.happyelements.com
-- All Rights Reserved. 
--=====================================================
-- filename:  PaymentCheckManager.lua
-- author:    zhijian.li
-- e-mail:    zhijian.li@happyelements.com
-- created:   2016/10/20
-- descrip:   针对支付sdk没回调的情况下~主动发起订单结果查询
--=====================================================
require "zoo.payment.paycheck.PaymentCheckNode"

PaymentCheckManager = class()
local instance = nil

local NeedCheckPayment = table.const{
	Payments.WECHAT,
	Payments.WDJ,
	Payments.HUAWEI,
	Payments.QQ,
	Payments.QIHOO,
	Payments.QIHOO_WX,
	Payments.QIHOO_ALI,
	Payments.ALI_SIGN_PAY,
}

function PaymentCheckManager.getInstance()
	if not instance then
		instance = PaymentCheckManager.new()
		instance:init()
	end
	return instance
end

function PaymentCheckManager:init()
	self.needPayCheck = false
	self.payment = nil
	self.checkNode = nil
end

function PaymentCheckManager:setNeedPaymentCheck(needCheck)
	self.needPayCheck = needCheck
	if not needPayCheck then 
		self:reset()
	end
end

function PaymentCheckManager:getNeedPaymentCheck()
	return self.needPayCheck
end

function PaymentCheckManager:setPaymentCheck(payment)
	if not MaintenanceManager:getInstance():isEnabled("WechatCallbackFeature") then return end
	if not table.includes(NeedCheckPayment, payment.type) then return end

	self.needPayCheck = true
	self.payment = payment
	self.checkNode = PaymentCheckNode:create()
end

function PaymentCheckManager:startPaymentCheck()
	if not self.payment or not self.payment.data or not self.payment.data.goodsInfo then
		self:reset() 
		return
	end
	local goodsInfo = self.payment.data.goodsInfo
	local tradeId = goodsInfo.tradeId
	local function onSuccess()
		if self.payment then 
			self.payment:payCallback(PayStage.kOutServerCheck, PayResultType.kSuccess, nil)
		end
	end

	local function onFail(errCode, errMsg)
		if self.payment then 
			self.payment:payCallback(PayStage.kOutServerCheck, PayResultType.kError, {code = errCode, msg = errMsg})
		end
	end

	if self.needPayCheck and self.checkNode and not self.checkNode.isChecking then 
		setTimeOut(function ()
			if self.needPayCheck and self.checkNode then
				self.checkNode:startCheck(tradeId, onSuccess, onFail)
			else
				self:reset()
			end
		end, 1)
	end
end

function PaymentCheckManager:reset()
	self.needPayCheck = false
	self.payment = nil
	self.checkNode = nil
end