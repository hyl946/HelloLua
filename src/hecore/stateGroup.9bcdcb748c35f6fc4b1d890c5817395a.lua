StateGroup = class()

function StateGroup:ctor()
	self.map = {}
end

function StateGroup:set(k, v)
	self.map[k] = v
end

function StateGroup:get(k)
	local r = self.map[k]
	if r == nil then r = false end
	return r
end

function StateGroup:actived()
	local r = false
	for _, v in pairs(self.map) do
		r = r or v
	end
	return r
end
