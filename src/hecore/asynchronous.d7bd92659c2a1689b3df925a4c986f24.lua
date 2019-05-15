local ENABLED = false

local asynchronous = {}
asynchronous.__index = asynchronous

function asynchronous:new(threshold)
	local p = {}
	setmetatable(p, asynchronous)

	p.threshold = threshold
	p.tick = 0
	p.breakMark = false

	return p
end

function asynchronous:startFrame()
	self.time = os.clock()
end

function asynchronous:updateFrame()
	self.tick = self.tick + 1

	local continue = not self.breakMark
	self.breakMark = false

	local time = os.clock()
	local elapsed = time - self.time
	if(ENABLED and elapsed > self.threshold) then
		continue = false
	end

	return continue
end

function asynchronous:getTick()
	return self.tick
end

function asynchronous:breakFrame()
	self.breakMark = true
end

return asynchronous