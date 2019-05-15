require "zoo.payment.PayPanelRePay"
local PayPanelRePay_VerB = require 'zoo.payment.repay.PayPanelRePay_VerB'
local Common = require 'zoo.payment.repay.Common'



local RePayABTestMgr = {}

function RePayABTestMgr:isNew( ... )
	if self.isNewType == nil then
		local uid = UserManager:getInstance().uid
		if MaintenanceManager:getInstance():isEnabledInGroup("RepayNewPanelFeature" , "A1" , uid) 
				or MaintenanceManager:getInstance():isEnabledInGroup("RepayNewPanelFeature" , "B1" , uid) then
			self.isNewType = true
		else
			self.isNewType = false
		end
	end
	return self.isNewType
end

function RePayABTestMgr:isOld( ... )
	return not self:isNew()
end

function RePayABTestMgr:isNewB()
	if self.isNewTypeB == nil then
		local uid = UserManager:getInstance().uid
		if MaintenanceManager:getInstance():isEnabledInGroup("RepayNewPanelFeature" , "A1" , uid) then
			self.isNewTypeB = true
		else
			self.isNewTypeB = false
		end
	end
	return self.isNewTypeB
end

-- function RePayABTestMgr:createRePayPanelAsync( params, callback )
-- 	if type(callback) ~= 'function' then return end
-- 	if self:isNew() then
-- 		local convertParams = {
-- 			params[1], 			--peDispatcher
-- 			params[2], 			--goodsIdInfo
-- 			params[4], 			--repayChooseTable
-- 		}

-- 		PaymentNetworkCheck.getInstance():check(function( ... )
-- 			callback(PayPanelRePay_VerB:create(unpack(convertParams), true))
-- 	    end, function ()
-- 			callback(PayPanelRePay_VerB:create(unpack(convertParams), false))
-- 	    end)
-- 	else
-- 		callback(PayPanelRePay:create(unpack(params)))
-- 	end
-- end

function RePayABTestMgr:getRepayChooseTable( repayChooseTable, onlyThirdpartyT1 )
	if repayChooseTable == nil then
		return nil
	end

	if onlyThirdpartyT1 == nil then
		onlyThirdpartyT1 = false
	end

	if self:isOld() then
		return repayChooseTable
	else
		local thirdPartPaymentTable = AndroidPayment.getInstance().thirdPartyPayment
		local tmp = PaymentManager:getInstance():filterRepayPayment(thirdPartPaymentTable)
		local newRepayChooseTable = {}
		if onlyThirdpartyT1 then
			for index, payType in ipairs(tmp) do
				if Common:isT1(payType) then
					table.insert(newRepayChooseTable, payType)
				end
			end
		else
			newRepayChooseTable = tmp
		end

		local smsEnabled, smsReason = PaymentManager:getInstance():checkSmsPayEnabled()
		local smsLimitType = PaymentManager:getInstance():getSmsPaymentLimitType()

		local defaultSmsPay = PaymentManager:getInstance():getDefaultSmsPayment()
		if (not onlyThirdpartyT1) and smsEnabled and defaultSmsPay ~= Payments.UMPAY then
			table.insert(newRepayChooseTable, defaultSmsPay)
		end

		for index, payType in ipairs(repayChooseTable) do
			table.insertIfNotExist(newRepayChooseTable, payType)
		end

		return newRepayChooseTable
	end
end


function RePayABTestMgr:process( lastPayType, repayChooseTable, callback )

	lastPayType = Common:getOriPayment(lastPayType)

	local function __hasSms(repayChooseTable)
		return table.find(repayChooseTable, function ( v )
			return not Common:isThirdParty(v)
		end) ~= nil
	end

	local function __hasThirdParty(repayChooseTable)
		return table.find(repayChooseTable, function ( v )
			return Common:isThirdParty(v)
		end) ~= nil
	end

	local function __hadOtherThirdParty(repayChooseTable)
		return table.find(repayChooseTable, function ( v )
			return Common:isThirdParty(v) and v ~= lastPayType
		end) ~= nil
	end

	local function __process( isConnected )

		local resultType 
		local tip 

		if Common:isThirdParty(lastPayType) then
			if isConnected then
				if __hadOtherThirdParty(repayChooseTable) then
					resultType = 1
					tip = 'payment_repay_txt1'
				else
					if __hasSms(repayChooseTable) then
						resultType = 1
						tip = 'payment_repay_txt9'
					else
						if self:isNewB() then
							resultType = 1
							tip = 'payment_repay_txt3'
						else
							resultType = 2
							tip = 'payment_repay_txt3'
						end
					end
				end
			else
				if __hasSms(repayChooseTable) then
					resultType = 1
					tip = 'payment_repay_txt10'
				else
					if self:isNewB() then
						resultType = 1
						tip = 'payment_repay_txt4'
					else
						resultType = 2
						tip = 'payment_repay_txt4'
					end
				end
			end
		else
			if __hasSms(repayChooseTable) then
				if __hasThirdParty(repayChooseTable) then
					if isConnected then
						resultType = 1
						tip = 'payment_repay_txt1'
					else
						resultType = 1
						tip = 'payment_repay_txt2'
					end
				else
					if self:isNewB() then
						resultType = 1
						tip = 'payment_repay_txt3'
					else
						resultType = 2
						tip = 'payment_repay_txt3'
					end
				end
			else
				--我觉得这个逻辑走不进来
				if __hasThirdParty(repayChooseTable) then
					if isConnected then
						resultType = 1
						tip = 'payment_repay_txt1'
					else
						resultType = 1
						tip = 'payment_repay_txt4'
					end
				else
					if self:isNewB() then
						resultType = 1
						tip = 'payment_repay_txt3'
					end
				end
			end
		end

		if tip then
			tip = localize(tip)
		end

		if callback then
			callback(resultType, tip, isConnected)
		end
	end 

	PaymentNetworkCheck.getInstance():check(function( ... )
		__process(true)
    end, function ()
		__process(false)
    end)
end


return RePayABTestMgr