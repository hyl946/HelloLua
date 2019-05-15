function simple_class()
	local class_type = {}
	class_type.__index = class_type

	class_type.new = function(...)
		local obj = {}
		setmetatable(obj, class_type)
		if obj.ctor then obj:ctor(...) end
		return obj
	end
	return class_type
end