local BuyItem = require 'zoo.payment.repay.BuyItem'

local SpecialBuyItem = class(BuyItem)

SpecialBuyItem.resName = 'new.repay/specialBuyItem'
SpecialBuyItem.colorMode = kGroupButtonColorMode.green


function SpecialBuyItem:create(builder)
	local buyItem = SpecialBuyItem.new()
	buyItem:init(builder)
	return buyItem
end

function SpecialBuyItem:init( ... )
	BuyItem.init(self, ...)

	self.payName:changeFntFile('fnt/pay_name.fnt')
end

function SpecialBuyItem:setPayName( payName )
	self.payName:setText(payName)
	self.payName:setAnchorPointWhileStayOriginalPosition(ccp(0, 0.5))


	if utfstrlen(payName) >= 5 then
		self.payName:setScale(0.9)
	end
end

return SpecialBuyItem