

-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年10月23日 12:19:38
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.common.OneSecondTimer"

---------------------------------------------------
-------------- CountdownTimer
---------------------------------------------------

assert(not CountdownTimer)
CountdownTimer = class()

function CountdownTimer:ctor()
end

function CountdownTimer:init(initialCount, ...)
	assert(type(initialCount) == "number")
	assert(initialCount > 0)
	assert(#{...} == 0)

	self.started		= false
	self.count		= initialCount

	self.countdownCallback	= false

	-- One Second Timer
	self.oneSecondTimer	= OneSecondTimer:create()

	local function oneSecondCallback()
		self:oneSecondCallback()
	end

	self.oneSecondTimer:setOneSecondCallback(oneSecondCallback)
end

function CountdownTimer:oneSecondCallback(...)
	assert(#{...} == 0)

	assert(self.count > 0)
	self.count = self.count - 1

	if self.count <= 0 then
		--self.oneSecondTimer:stop()
		--self.started = false
		self:stop()
	end

	-- Call The Callback
	if self.countdownCallback then
		self.countdownCallback(self.count)
	end
end

function CountdownTimer:start(...)
	assert(#{...} == 0)

	assert(self.started == false)
	self.started = true
	self.oneSecondTimer:start()
end

function CountdownTimer:stop(...)
	assert(#{...} == 0)

	assert(self.started == true)
	self.started = false
	self.oneSecondTimer:stop()
end

function CountdownTimer:isStarted(...)
	assert(#{...} == 0)

	return self.started
end

function CountdownTimer:setCountdownCallback(countdownCallback, ...)
	assert(type(countdownCallback) == "function")
	assert(#{...} == 0)

	self.countdownCallback = countdownCallback
end

function CountdownTimer:create(initialCount, ...)
	assert(type(initialCount) == "number")
	assert(#{...} == 0)

	local newCountdownTimer = CountdownTimer.new()
	newCountdownTimer:init(initialCount)
	return newCountdownTimer
end

----------------------------------------
------ Test CountdownTimer
-------------------------------------
--
--local countdownTimer = CountdownTimer:create(20)
--
--local function countdownCallback(leftCount)
--	if _G.isLocalDevelopMode then printx(0, "left count is: " .. leftCount) end
--end
--countdownTimer:setCountdownCallback(countdownCallback)
--
--countdownTimer:start()
