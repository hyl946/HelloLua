local TabShow = class()

function TabShow:create(ui, context)
	local tab = TabShow.new()
	tab.ui = ui
	tab.context = context
	return tab
end

function TabShow:init(ui)
	self.isActive = false
	self._isInited = true
end

function TabShow:setActive(v, byDefault)
	if self.isActive == nil or self.isActive ~= v then
		if not v then
			self:__toDeActive()
		else
			self:__toActive(byDefault)
		end
		self.isActive = v
	end
end

function TabShow:__toActive(byDefault)
	if not self._isInited then
		self:init()
	end
	
	self.ui:setVisible(true)
	self:refresh()
end

function TabShow:__toDeActive()
	self.ui:setVisible(false)
end

function TabShow:refresh()
	
end

function TabShow:dispose()
	if not self.ui or self.ui.isDisposed then return end
	
	if self.ui:getParent() then
		self.ui:removeFromParentAndCleanup(true)
	else
		self.ui:dispose()
	end
end

return TabShow