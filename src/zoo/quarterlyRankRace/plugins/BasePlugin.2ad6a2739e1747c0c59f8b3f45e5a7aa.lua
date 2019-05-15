_G.BasePlugin = class(Layer)

function BasePlugin:ctor( config )
	self:initLayer()
end

function BasePlugin:onPluginInit( ... )
	if self.isDisposed then return false end
	return true
end

function BasePlugin:callAncestors( methodName, ... )

	if self.isDisposed then return end
	local node = self:getParent()
	while node do
		if node[methodName] then
			if node[methodName](node, ...) then
				return true
			end
		end
		node = node:getParent()
	end
	return false
end