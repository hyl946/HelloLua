
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年10月11日 13:12:10
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

UserEnergyState	= 
{
	INFINITE		= 1,
	COUNT_DOWN_TO_RECOVER	= 2,
}

UserEnergyRecoverManagerEvents = {
	COUNT_DOWN_TIMER_REACHED = "UserEnergyRecoverManagerEvents.COUNT_DOWN_TIMER_REACHED"
}

function checkUserEnergyState(state, ...)
	assert(#{...} == 0)

	assert(state == UserEnergyState.INFINITE or
		state == UserEnergyState.COUNT_DOWN_TO_RECOVER)
end

---------------------------------------------------
-------------- UserEnergyRecoverManager
-------------- Used To Recover User's Energy Based On A CountDown Timer
---------------------------------------------------

local sharedInstance = nil

assert(not UserEnergyRecoverManager)

UserEnergyRecoverManager = class(EventDispatcher)

function UserEnergyRecoverManager:init(...)
	assert(#{...} == 0)

	-- because in current design, data don't dispatch a event
	-- so we create a timer to check data change in every frame
	-- if found current energy is not max value, start a countdown timer to add energy
	self.director	= CCDirector:sharedDirector()
	self.scheduler	= self.director:getScheduler()

	-- -------------------------------------------------
	-- Data About One Sceond Timer,
	-- Call self:oneSecondReached Each One Second Is Elapsed
	-- ----------------------------------------------------
	self.oneSecondTimerStarted	= false
	self.oneSecondTimerScheduled	= false

	-- -----------------------------------
	-- Data About Wait Time To Add One Energy
	-- ----------------------------------------
	
	local countDownSecond	= false
	local isRefresh		= false
	local maxEnergy		= false

	countDownSecond, isRefresh, maxEnergy = UserManager.getInstance():refreshEnergy()
	self.countDownSecond	= countDownSecond
	self.maxEnergy		= maxEnergy
	self.energy		= UserManager:getInstance().user:getEnergy()

	-- State
	self.energyState = UserEnergyState.COUNT_DOWN_TO_RECOVER

	--self.previousCheckTime		= os.time()
	--self.previousCountDownSecond	= self.countDownSecond
end

function UserEnergyRecoverManager.checkEnergyIsFullTimer(delta, ...)
	assert(delta)
	assert(#{...} == 0)

	local self = UserEnergyRecoverManager:sharedInstance()
	local isRefresh = false

	self.countDownSecond, isRefresh, self.maxEnergy = UserManager.getInstance():refreshEnergy()
	self.energy					= UserManager:getInstance().user:getEnergy()

	if isRefresh then
		-- Despatch Event
		local event = Event.new(UserEnergyRecoverManagerEvents.COUNT_DOWN_TIMER_REACHED)
		self:dispatchEvent(event)
	end

	----------------------------------------
	-- Check If Is In Energy Infinite State
	-- -------------------------------------
	local notConsumeEnergyBuff 		= UserManager:getInstance().userExtend:getNotConsumeEnergyBuff()
	local notConsumeEnergySecondNumber	= math.floor(tonumber(notConsumeEnergyBuff) / 1000) 

	-- Cur Time
	local curServerTime = math.floor(Localhost:time() / 1000)

	if curServerTime < notConsumeEnergySecondNumber then
		self.energyState 		= UserEnergyState.INFINITE
		self.infiniteEnergyRemainSecond	= notConsumeEnergySecondNumber - curServerTime
	else
		self.energyState 		= UserEnergyState.COUNT_DOWN_TO_RECOVER
		self.infiniteEnergyRemainSecond	= false
	end
end

function UserEnergyRecoverManager:isEnergyFull(...)
	assert(#{...} == 0)

	return UserManager:getInstance().user.isFull
end

function UserEnergyRecoverManager:getEnergyState(...)
	assert(#{...} == 0)

	checkUserEnergyState(self.energyState)
	if PublishActUtil:isGroundPublish() or PlatformConfig:isPlayDemo() then 
		self.energyState = UserEnergyState.INFINITE 
	end
	return self.energyState
end

function UserEnergyRecoverManager:getMaxEnergy(...)
	assert(#{...} == 0)

	return self.maxEnergy
end

function UserEnergyRecoverManager:getEnergy(...)
	assert(#{...} == 0)

	return self.energy
end

function UserEnergyRecoverManager:convertSecondToMinute(second, ...)
	assert(#{...} == 0)

	local minute = math.floor(second / 60)
	local leftSecond	= second - 60*minute

	return tostring(minute) .. ":" .. tostring(leftSecond)
end

function UserEnergyRecoverManager:addEnergy(deltaEnergy, ...)
	assert(type(deltaEnergy) == "number")
	assert(#{...} == 0)

	assert(deltaEnergy >= 0)

	UserManager:getInstance():refreshEnergy()

	-- Cur Energy
	local curEnergy 	= UserManager.getInstance().user:getEnergy()
	he_log_warning("staic max energy used !!")
	--local maxEnergyAllowed	= MetaManager.getInstance().global.user_energy_max_count
	
	local maxEnergyAllowed	= self:getMaxEnergy()

	-- New Energy
	local newEnergy = curEnergy + deltaEnergy


	if newEnergy > maxEnergyAllowed then
		newEnergy = maxEnergyAllowed
	end

	-- Set New Energy
	UserManager.getInstance().user:setEnergy(newEnergy)
end

function UserEnergyRecoverManager:getCountdownSecondRemain(...)
	assert(#{...} == 0)

	if self.energyState == UserEnergyState.INFINITE then
		return self.infiniteEnergyRemainSecond or 0

	elseif self.energyState == UserEnergyState.COUNT_DOWN_TO_RECOVER then
		return self.countDownSecond
	else
		if _G.isLocalDevelopMode then printx(0, "energyState: " .. self.energyState) end
		assert(false)
	end
end


function UserEnergyRecoverManager:sharedInstance(...)
	assert(#{...} == 0)

	if sharedinstance == nil then
		sharedinstance = UserEnergyRecoverManager.new()
		sharedinstance:init()
	end

	return sharedinstance
end

-------------------------------------------------------
----     Function To Get UserEnergyRecoverManager To Work
----------------------------------------------------------

function UserEnergyRecoverManager:startCheckEnergy(...)
	assert(#{...} == 0)

	-- Timer To Check If Energy Is Not Max
	self.checkEnergyTimer = self.scheduler:scheduleScriptFunc(UserEnergyRecoverManager.checkEnergyIsFullTimer, 1/2, false)
end
