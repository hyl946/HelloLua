local enabled = false and isLocalDevelopMode
_G._performanceFunctionsEnabled = false

local performance = {}
performance.__index = performance

function performance:new()
	local p = {}
	setmetatable(p, performance)
	
	p.tick = 0
	p.total = 0
	p.longList = {}

	return p
end

function performance:start()
	if(not enabled) then return end

	self.time = os.clock()
end

function performance:finish(message)
	if(not enabled) then return end

	if(self.time) then
		local t = os.clock()
		local elapsed = math.ceil((t - self.time) * 1000)

		self.tick = self.tick + 1
		self.total = self.total + elapsed

		if(#self.longList > 0) then
			for i = 1, #self.longList do
				if(elapsed > self.longList[i]) then
					table.insert(self.longList, i, elapsed)
					break
				end
			end

			while(#self.longList > 10) do
				table.remove(self.longList, #self.longList)
			end
		else
			self.longList[1] = elapsed
		end

		if(message) then
			he_log_info("PERFORMANCE::" .. message)
			-- he_log_info(message)
			he_log_info(self.total / self.tick)
			local top = ""
			for i = 1, #self.longList do
				top = top .. self.longList[i] .. ", "
			end
			he_log_info(top)
		end

	end
end

return performance
