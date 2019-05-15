local BaseInterface = class(LayerColor)

function BaseInterface:ctor( ... )
	self._slots = {}
	self._block = 0
	self._to_add = {}
	self._to_delete = {}
end

function BaseInterface:init( ... )
	if self.isDisposed then return end
	self:initLayer()
end

function BaseInterface:_update_solts()

	if self._block > 0 then
		return
	end

	for _, connect in ipairs(self._to_add) do
		table.insert(self._slots, connect)
	end

	self._to_add = {}

	for _, connect in ipairs(self._to_delete) do
		local _, index = table.find(self._slots, function(v) 
			return v.signalName == connect.signalName and v.instance == connect.instance and v.func == connect.func
		end)
		table.remove(self._slots, index)
	end

	self._to_delete = {}
end

function BaseInterface:signal( signalName, ... )
	if self.isDisposed then return end

	if self._block <= 0 then
		self:_update_solts()
	end

	self._block = self._block + 1

	for _, connect in ipairs(self._slots) do
		if connect.instance.isDisposed then
			self:disconnect(connect.signalName, connect.instance. connect.func)
		elseif signalName == connect.signalName then
			connect.func(connect.instance, ...)
		end
	end

	self._block = self._block - 1

	if self._block <= 0 then
		self:_update_solts()
	end
end

function BaseInterface:connect( signalName, instance, func)
	if self.isDisposed then return end

	if not signalName then return end
	if not instance then return end
	if not func then return end

	local connect = {
		signalName = signalName, 
		instance = instance, 
		func = func, 
	}

	table.insert(self._to_add, connect)

	self:_update_solts()

end

function BaseInterface:disconnect( signalName, instance, func )
	if self.isDisposed then return end

	if not signalName then return end
	if not instance then return end
	if not func then return end

	local connect = {
		signalName = signalName, 
		instance = instance, 
		func = func, 
	}

	table.insert(self._to_delete, connect)

	self:_update_solts()

end

function BaseInterface:is_connect( signalName, instance, func )
	if self.isDisposed then return end

	self:_update_solts()

	local connect = {
		signalName = signalName, 
		instance = instance, 
		func = func, 
	}

	local ret = table.find(self._slots, function(v) 
		return v.signalName == connect.signalName and v.instance == connect.instance and v.func == connect.func
	end)

	--todo check _to_add or _to_delete

	return ret ~= nil
end

function BaseInterface:dispose( ... )
	self:_update_solts()
	LayerColor.dispose(self)
end

return BaseInterface