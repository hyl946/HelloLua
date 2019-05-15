
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年10月23日 11:07:54
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "hecore.class"

---------------------------------------------------
-------------- OneSecondTimer
---------------------------------------------------

assert(not OneSecondTimer)
OneSecondTimer = class()

function OneSecondTimer:ctor()
end

function OneSecondTimer:init(...)
	assert(#{...} == 0)

	self.callback	= false
	self.started	= false

	self.scriptFunc = false
	self.scheduler = CCDirector:sharedDirector():getScheduler()
end

function OneSecondTimer:start(...)
	assert(#{...} == 0)
	-- assert(self.started == false)
	if self.started ~= true then
		self.started = true
		local function oneSecondTimer()
			self:oneSecondTimer()
		end
		self.scriptFunc = self.scheduler:scheduleScriptFunc(oneSecondTimer, 1, false)
	end
end

function OneSecondTimer:stop(...)
	assert(#{...} == 0)
	-- assert(self.started == true)

	if self.started == true then
		self.started = false
		self.scheduler:unscheduleScriptEntry(self.scriptFunc)
	end
end


function OneSecondTimer:setOneSecondCallback(callback, ...)
	assert(type(callback) == "function")
	assert(#{...} == 0)

	self.callback = callback
end

function OneSecondTimer:oneSecondTimer(delta, ...)
	assert(#{...} == 0)

	if self.callback then
		self.callback()
	end
end

function OneSecondTimer:create(...)
	assert(#{...} == 0)

	local newOneSecondTimer = OneSecondTimer.new()
	newOneSecondTimer:init()
	return newOneSecondTimer
end

---------------------------------
----	Test OneSecondTimer
----	----------------------
--
--local oneSecondTimer = OneSecondTimer:create()
--local index = 0
--
--local function oneSecondCallback()
--
--	index = index + 1
--	if _G.isLocalDevelopMode then printx(0, "one second reached !!" .. index) end
--end
--
--oneSecondTimer:setOneSecondCallback(oneSecondCallback)
--oneSecondTimer:start()
