local SuperCls = require('zoo.ui.edit.BaseInterface')


local EditInterface = class(SuperCls)

function EditInterface:ctor( ... )
end

function EditInterface:init( ... )
	if self.isDisposed then return end
	SuperCls.init(self)
end

function EditInterface:notifyValueChange()
	self:signal('value_change', self:getValue())
end

function EditInterface:getValue( ... )
	return 'default value'
end

function EditInterface:setValue( v )
end

function EditInterface:onPopout( ... )
	-- body
end

function EditInterface:hide( ... )
	if self.isDisposed then return end
	if self.subMode then return end
	if self:getParent() then
		self:removeFromParentAndCleanup(false)

		self:signal('edit_hide')
	end
end

function EditInterface:setSubMode( subMode )
	-- body
	self.subMode = subMode
end

return EditInterface