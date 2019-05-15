local Control = class(CocosObject)

function Control:create( ... )
	local node = Control.new(CCNode:create())
	node:initControl()
	return node
end

Control.MARGIN = {
	
} 

function Control:initControl( ... )
	self.minSize = CCSizeMake(0, 0)

	-- 左右上下
	-- 有点难
	-- self._anchor = {
	-- 	0, 0, 0, 0
	-- }

	-- self._margin = {
	-- 	0, 0, 0, 0
	-- }
end

function Control:setSize(size)
	self:setContentSize(size)
	self:dp(Event.new("size_changed"))
end

function Control:getSize()
	return self:getContentSize()
end

function Control:setMinSize( minSize )
	self.minSize = CCSizeMake(minSize.width, minSize.height)
	self:dp(Event.new("min_size_changed"))
end

function Control:getMinSize()
	return self.minSize
end

function Control:getFinalSize( ... )
	-- body
	local size = self:getSize()
	local minSize = self:getMinSize()

	return CCSizeMake(
		math.max(size.width, minSize.width),
		math.max(size.height, minSize.height)
	)
end

function Control:set( ... )
	-- body
end

return Control