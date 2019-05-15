local reuseAnimationCtrl = {}

reuseAnimationCtrl.enabled = false

reuseAnimationCtrl.totalReusedTimes = 0
reuseAnimationCtrl.totalCachedTimes = 0

reuseAnimationCtrl.categoryPool = {} --category, name, instance

reuseAnimationCtrl.CATEGORY = table.const
{
	DISPLAYABLE = 1,
	FRAMES = 2,
	ANIMATE = 3,
}


function reuseAnimationCtrl:getInstancePool(name, category)
	assert(name)
	assert(category)

	local namePool = self.categoryPool[category]
	if(namePool == nil) then
		namePool = {}
		self.categoryPool[category] = namePool
	end

	local instancePool = namePool[name]
	if(instancePool == nil) then
		instancePool = {}
		namePool[name] = instancePool
	end

	return instancePool;
end

function reuseAnimationCtrl:query(name, category)
	assert(name)
	assert(category)

	if(not self.enabled) then
		return nil
	end

	local instancePool = self:getInstancePool(name, category)
	local size = #instancePool
	if(size > 0) then
		local instance = instancePool[size]

		if(category == self.CATEGORY.DISPLAYABLE) then
			table.remove(instancePool, size)
		end

		self:restoreInstance(instance)

		self.totalReusedTimes = self.totalReusedTimes + 1
		printex("[R]: " ..
			self.totalReusedTimes .. "/" .. 
			self.totalCachedTimes .. "/" .. 
			category .. ", " .. 
			name, PRINT_CHANNEL.display)

		return instance
	end

--[[
	for instance, v in pairs(instancePool) do
		if(instance) then
			if(category == self.CATEGORY.DISPLAYABLE) then
				instancePool[instance] = nil
			end

			self:restoreInstance(instance)

			self.totalReusedTimes = self.totalReusedTimes + 1
			printex("[R]: " ..
				self.totalReusedTimes .. "/" .. 
				self.totalCachedTimes .. "/" .. 
				category .. ", " .. 
				name, PRINT_CHANNEL.display)

			return instance
		end
	end
]]

	return nil
end


function reuseAnimationCtrl:pushback(instance)
	if(not self.enabled) then
		return
	end

	local name = instance.__name
	local category = instance.__category
	local initialState = instance.__initialState

	assert(name)
	assert(category)
	assert(initialState)

	local instancePool = self:getInstancePool(name, category)

--[[
	if(instancePool[instance]) then
		if _G.isLocalDevelopMode then printx(0, "========		duplicate instance pushback		========") end
		if _G.isLocalDevelopMode then printx(0, "========		last traceback		========") end
		if _G.isLocalDevelopMode then printx(0, instance.__pushTrace) end
		if _G.isLocalDevelopMode then printx(0, "========		current traceback		========") end
		if _G.isLocalDevelopMode then printx(0, debug.traceback()) end
		if _G.isLocalDevelopMode then printx(0, "time elasped: " .. (os.time() - instance.__pushTime)) end
		debug.debug()
	end

	instance.__pushTrace = debug.traceback()
	instance.__pushTime = os.time()
]]

--[[
	assert(instancePool[instance] == nil)
	instancePool[instance] = 1
]]

	instancePool[#instancePool + 1] = instance
	self:correctInstance(instance)

	self.totalCachedTimes = self.totalCachedTimes + 1
--	printex("[C]: " .. self.totalCachedTimes .. ", " .. name, PRINT_CHANNEL.display)

end

function reuseAnimationCtrl:correctInstance(instance)
	local category = instance.__category

	if(category == self.CATEGORY.DISPLAYABLE) then
		instance:retain()
		instance:removeFromParentAndCleanup(false)
		instance:setBatchNode(nil)
	elseif(category == reuseAnimationCtrl.CATEGORY.FRAMES) then
		for i = 1, #instance do
			instance[i]:retain()
		end
	elseif(category == reuseAnimationCtrl.CATEGORY.ANIMATE) then
		instance:retain()
	else
		assert(false)
	end
end

function reuseAnimationCtrl:restoreInstance(instance)
	local category = instance.__category
	local initialState = instance.__initialState

	if(category == self.CATEGORY.DISPLAYABLE) then
		instance:autorelease()
		HeDisplayUtil:setRotationX(instance, initialState.getRotationX)
		HeDisplayUtil:setRotationY(instance, initialState.getRotationY)
		instance:setScaleX(initialState.getScaleX)
		instance:setScaleY(initialState.getScaleY)
		instance:setSkewX(initialState.getSkewX)
		instance:setSkewY(initialState.getSkewY)
		instance:setOpacity(initialState.getOpacity)
		instance:setColor(initialState.color)
		instance:setVisible(true)
	elseif(category == reuseAnimationCtrl.CATEGORY.FRAMES) then
	elseif(category == reuseAnimationCtrl.CATEGORY.ANIMATE) then
	else
		assert(false)
	end
end


function reuseAnimationCtrl:initializeInstance(instance, name, category)
	assert(instance)
	assert(name)
	assert(category)

	if(not self.enabled) then
		return
	end

	instance.__name = name
	instance.__category = category
	instance.__initialState = {}

	local initialState = instance.__initialState

	if(category == self.CATEGORY.DISPLAYABLE) then
		initialState.getRotationX = HeDisplayUtil:getRotationX(instance)
		initialState.getRotationY = HeDisplayUtil:getRotationY(instance)
		initialState.getScaleX = instance:getScaleX()
		initialState.getScaleY = instance:getScaleY()
		initialState.getSkewX = instance:getSkewX()
		initialState.getSkewY = instance:getSkewY()
		initialState.getOpacity = instance:getOpacity()
		initialState.color = instance:getColor()
	elseif(category == reuseAnimationCtrl.CATEGORY.FRAMES) then
	elseif(category == reuseAnimationCtrl.CATEGORY.ANIMATE) then
	else
		assert(false)
	end

end

function reuseAnimationCtrl:clean()
	for category, namePool in pairs(self.categoryPool) do
		for name, instancePool in pairs(namePool) do
			for i = 1, #instancePool do
				self:freeInstance(instancePool[i])
			end
		end
	end

	self.categoryPool = {}
end

function reuseAnimationCtrl:freeInstance(instance)
	local category = instance.__category

	if(category == self.CATEGORY.DISPLAYABLE) then
		instance:release()
	elseif(category == reuseAnimationCtrl.CATEGORY.FRAMES) then
		for i = 1, #instance do
			instance[i]:release()
		end
	elseif(category == reuseAnimationCtrl.CATEGORY.ANIMATE) then
		instance:release()
	else
		assert(false)
	end
end

return reuseAnimationCtrl
