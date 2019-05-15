-- ThirdPayDiscountLabel = class()

-- function ThirdPayDiscountLabel:ctor()
	
-- end

-- function ThirdPayDiscountLabel:init()
-- 	self.pay_btn_xiaomi = self.ui:getChildByName("pay_btn_xiaomi")
-- 	self.pay_btn_xiaomi:setVisible(false)

-- 	self.pay_btn_other = self.ui:getChildByName("pay_btn_other")
-- 	self.pay_btn_other:setVisible(false)

-- 	self.pay_btn_we_ali = self.ui:getChildByName("pay_btn_we_ali")
-- 	self.pay_btn_we_ali:setVisible(false)
-- 	self.pay_btn_we_ali_no = self.ui:getChildByName("pay_btn_we_ali_no")
-- 	self.pay_btn_we_ali_no:setVisible(false)

-- 	self.pay_btn_we = self.ui:getChildByName("pay_btn_we")
-- 	self.pay_btn_we:setVisible(false)
-- 	self.pay_btn_we_no = self.ui:getChildByName("pay_btn_we_no")
-- 	self.pay_btn_we_no:setVisible(false)

-- 	self.pay_btn_wdj = self.ui:getChildByName("pay_btn_wdj")
-- 	self.pay_btn_wdj:setVisible(false)
-- 	self.pay_btn_wdj_no = self.ui:getChildByName("pay_btn_wdj_no")
-- 	self.pay_btn_wdj_no:setVisible(false)

-- 	self.pay_btn_tx = self.ui:getChildByName("pay_btn_tx")
-- 	self.pay_btn_tx:setVisible(false)
-- 	self.pay_btn_tx_no = self.ui:getChildByName("pay_btn_tx_no")
-- 	self.pay_btn_tx_no:setVisible(false)

-- 	self.pay_btn_ali = self.ui:getChildByName("pay_btn_ali")
-- 	self.pay_btn_ali:setVisible(false)
-- 	self.pay_btn_ali_no = self.ui:getChildByName("pay_btn_ali_no")
-- 	self.pay_btn_ali_no:setVisible(false)

-- 	self.pay_btn_360 = self.ui:getChildByName("pay_btn_360")
-- 	self.pay_btn_360:setVisible(false)
-- 	self.pay_btn_360_no = self.ui:getChildByName("pay_btn_360_no")
-- 	self.pay_btn_360_no:setVisible(false)

-- 	self.pay_btn_we_qq = self.ui:getChildByName("pay_btn_we_qq")
-- 	self.pay_btn_we_qq:setVisible(false)
-- 	self.pay_btn_we_qq_no = self.ui:getChildByName("pay_btn_we_qq_no")
-- 	self.pay_btn_we_qq_no:setVisible(false)

-- 	local thirdPartyPaymentTable = AndroidPayment.getInstance().thirdPartyPayment
-- 	if table.includes(thirdPartyPaymentTable, self.paymentType) then 
-- 		self.pay_btn_other:setVisible(true)
-- 	else
-- 		local payBtnKeyToShow = nil
-- 		local otherThirdPayNum = #self.otherPaymentTable
-- 		if otherThirdPayNum == 1 then 
-- 			for i,v in ipairs(self.otherPaymentTable) do
-- 				if v == Payments.CHINA_MOBILE or v == Payments.CHINA_UNICOM or v == Payments.CHINA_TELECOM or v == Payments.CHINA_MOBILE_GAME then 
-- 					payBtnKeyToShow = "pay_btn_other"
-- 				elseif v == Payments.WDJ then 
-- 					payBtnKeyToShow = "pay_btn_wdj"
-- 				elseif v == Payments.QQ then
-- 					payBtnKeyToShow = "pay_btn_tx"
-- 				-- elseif v == Payments.MI then
-- 				elseif v == Payments.QIHOO then
-- 					payBtnKeyToShow = "pay_btn_360"
-- 				elseif v == Payments.WECHAT then
-- 					payBtnKeyToShow = "pay_btn_we"
-- 				elseif v == Payments.ALIPAY then
-- 					payBtnKeyToShow = "pay_btn_ali"
-- 				end
-- 			end
-- 		else
-- 			local hasWeChat = false
-- 			local hasAli = false
-- 			local hasQQ = false
-- 			for i,v in ipairs(self.otherPaymentTable) do
-- 				if v == Payments.WECHAT then 
-- 					hasWeChat = true
-- 				elseif v == Payments.ALIPAY then 
-- 					hasAli = true
-- 				elseif v == Payments.QQ then 
-- 					hasQQ = true
-- 				end
-- 			end
-- 			if hasWeChat and hasAli then 
-- 				payBtnKeyToShow = "pay_btn_we_ali"
-- 			elseif hasWeChat and hasQQ then 
-- 				payBtnKeyToShow = "pay_btn_we_qq"
-- 			elseif hasWeChat then 
-- 				payBtnKeyToShow = "pay_btn_we"
-- 			elseif hasAli then 
-- 				payBtnKeyToShow = "pay_btn_ali"
-- 			else
-- 				payBtnKeyToShow = "pay_btn_other"
-- 			end
-- 		end

-- 		local finalBtnKey = payBtnKeyToShow
-- 		if self.noDiscount then 
-- 			finalBtnKey = payBtnKeyToShow .. "_no"
-- 		end

-- 		local payBtnToShow = self[finalBtnKey]
-- 		if payBtnToShow then 
-- 			payBtnToShow:setVisible(true)
-- 		else
-- 			payBtnToShow = self[payBtnKeyToShow]
-- 			if payBtnToShow then 
-- 				payBtnToShow:setVisible(true)
-- 			end
-- 		end
-- 	end
-- end

-- function ThirdPayDiscountLabel:create(ui, paymentType, otherPaymentTable, noDiscount)
-- 	local label = ThirdPayDiscountLabel.new()
-- 	label.ui = ui
-- 	label.paymentType = paymentType
-- 	label.otherPaymentTable = otherPaymentTable
-- 	label.noDiscount = noDiscount
-- 	label:init()
-- 	return label
-- end

