
MarkPriseBuyButton = class(ButtonIconNumberBase)
function MarkPriseBuyButton:create(groupNode)
	local button = MarkPriseBuyButton.new(groupNode)
	button:init(groupNode)
	button.isNewStyle = true
	button.buttonStyle = ButtonStyleType.TypeBAA
	return button
end

function MarkPriseBuyButton:init(groupNode)
	ButtonIconNumberBase.buildUI(self)
	self.discount = groupNode:getChildByName("discount")
	self.dcNumber = self.discount:getChildByName("num")
	self.dcText = self.discount:getChildByName("text")

	-- self.oriNumber = groupNode:getChildByName("oriNumber")
	-- self.redLine = groupNode:getChildByName("redLine")
	-- if not self.oriNumber or not self.redLine then return end
	-- self.oriNumber:setVisible(false)
	-- self.redLine:setVisible(false)

	-- self.oriNumberLabel = self.oriNumber:getChildByName("number")
	-- local numberSize = self.oriNumber:getChildByName("numberSize")
	-- local size = numberSize:getContentSize()
	-- local position = numberSize:getPosition()
	-- local scaleX = numberSize:getScaleX()
	-- local scaleY = numberSize:getScaleY()
	-- self.oriNumberRect = {x=position.x, y=position.y, width=size.width*scaleX, height=size.height*scaleY}
	-- numberSize:removeFromParentAndCleanup(true)
end

function MarkPriseBuyButton:setOriNumber(str)
	local delStyle = nil
	local delColor = nil
	local numColor = nil
	delStyle = delStyle or 2
	delColor = delColor or hex2ccc3("D31D0E")
	numColor = numColor or hex2ccc3("0458D7")
	self:setDelNumber( str , numColor ,delStyle ,delColor )

	-- if not self.oriNumber or not self.redLine then return end
	-- self.oriNumber:setVisible(true)
	-- self.redLine:setVisible(true)
	-- local oriNumberLabel = self.oriNumberLabel
	-- if oriNumberLabel and oriNumberLabel.refCocosObj then
	-- 	if self.isStaticNumberLabel then oriNumberLabel:setString(str)
	-- 	else
	-- 		oriNumberLabel:setText(str)
	-- 		InterfaceBuilder:centerInterfaceInbox( oriNumberLabel, self.oriNumberRect )
	-- 	end
	-- end
	
end

function MarkPriseBuyButton:setOriNumberAlignment(alignment)
	-- if not self.oriNumber then return end
	-- self:setTextAlignment(self.oriNumberLabel, self.oriNumberRect, alignment, self.isStaticNumberLabel)
end

function MarkPriseBuyButton:setDiscount(number, text)
	if number <= 0 or number == 10 then
		self.dcNumber:setVisible(false)
		self.dcText:setVisible(false)
		self.discount:setVisible(false)
		self.dcNumber:setText(number)
	else
		self.dcNumber:setVisible(true)
		self.dcText:setVisible(true)
		self.discount:setVisible(true)
		self.dcNumber:setText(number)
		self.dcText:setText(text)
		self.dcNumber:setScale(2.5)
		self.dcText:setScale(1.7)
	end
end

function MarkPriseBuyButton:getDiscount(number)
	return self.dcNumber:getString(), self.dcText:getString()
end

function MarkPriseBuyButton:rmbPosAdjust()
	-- local xDelta = -50
	-- local function callback()
	-- 	if self.numberLabel.isDisposed then return end
		
	-- 	local posX1 = self.numberLabel:getPositionX()
	-- 	local posX2 = self.oriNumber:getPositionX()
	-- 	local posX3 = self.redLine:getPositionX()
	-- 	self.numberLabel:setPositionX(posX1 + xDelta)
	-- 	self.oriNumber:setPositionX(posX2 + xDelta)
	-- 	self.redLine:setPositionX(posX3 + xDelta)
	-- end

	-- HomeScene:sharedInstance():runAction(CCCallFunc:create(callback))
end