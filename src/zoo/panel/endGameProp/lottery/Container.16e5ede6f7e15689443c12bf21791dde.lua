local Control = require('zoo.panel.endGameProp.lottery.Control')

local Container = class(Control)

function Container:create( ... )
	local node = Container.new(CCNode:create())
	node:initContainer()
	return node
end

function Container:initContainer( ... )
	self:initControl()
end

function Container:addChildAt( ... )
	Control.addChildAt(self, ...)

	local child = select(1, ...)
	child:ad('min_size_changed', function ( ... )
		self:_layout()
	end)

	child:ad('size_changed', function ( ... )
		self:_layout()
	end)

	self:_layout()
end

function Container:_layout( ... )
	printx(61, self, '_layout' )

end

return Container