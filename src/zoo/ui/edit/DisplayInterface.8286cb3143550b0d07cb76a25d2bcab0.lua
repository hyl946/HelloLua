local SuperCls = require('zoo.ui.edit.BaseInterface')


local DisplayInterface = class(SuperCls)

function DisplayInterface:ctor( ... )
end

function DisplayInterface:init( ... )
	if self.isDisposed then return end
	SuperCls.init(self)
end

function DisplayInterface:setValue( ... )
	-- body
end

function DisplayInterface:getValue( ... )
	-- body
end

return DisplayInterface