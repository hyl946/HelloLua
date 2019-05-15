local SuperCls = require('zoo.ui.edit.DisplayInterface')


local TextFieldDisplay = class(SuperCls)

function TextFieldDisplay:ctor( ... )
end

function TextFieldDisplay:init( textField )
	if self.isDisposed then return end
	SuperCls.init(self)



	local label = textField

	self:setPosition(ccp(label:getPositionX(), label:getPositionY()))


	label:setAnchorPoint(ccp(0, 0))
	label:setPosition(ccp(0, 0))
	self:addChild(label)

	self.label = label


end

function TextFieldDisplay:setValue( str )
	if self.isDisposed then return end
	self.str = str
	str = TextUtil:ensureTextWidth( str, self.label:getFontSize(), self.label:getDimensions() )
	self.label:setString(str)
end

function TextFieldDisplay:getValue( ... )
	-- body
	return self.str or ''
end

function TextFieldDisplay:create( textField )
	local i = TextFieldDisplay.new()
	i:init(textField)
	return i
end

function TextFieldDisplay:getContentSize( ... )
	if self.isDisposed then return end
	return self.label:getContentSize()
end

return TextFieldDisplay