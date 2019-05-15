
PayPanelDiscountUI = class(BaseUI)

function PayPanelDiscountUI:ctor()
	
end

function PayPanelDiscountUI:init()
	BaseUI.init(self, self.ui)	

	local discountNumUI = self.ui:getChildByName("num")
	discountNumUI:setText(self.discoutNum)
	discountNumUI:setScale(2.5)
	local discountTextUI = self.ui:getChildByName("text")
	discountTextUI:setScale(1.7)
	discountTextUI:setText(Localization:getInstance():getText("buy.gold.panel.discount"))
end

function PayPanelDiscountUI:create(ui, discoutNum)
	local discountUI = PayPanelDiscountUI.new()
	discountUI.ui = ui
	discountUI.discoutNum = discoutNum
	discountUI:init()
	return discountUI
end

