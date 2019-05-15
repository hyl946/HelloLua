local IconProgressBar = require "zoo.iconButtons.view.IconProgressBar"
local EnergyInfiniteAni = require "zoo.iconButtons.animation.EnergyInfiniteAni"

IconBtnTopEnergy = class(IconBtnTopBase)

function IconBtnTopEnergy:ctor()
	self.curEnergy = 0
	self.totalEnergy = 0
	self.energyState = nil
	self.leftSeconds = 0
end

function IconBtnTopEnergy:init()
	self.ui	= ResourceManager:sharedInstance():buildGroup("home_top_bar/icon_btn_energy")
	IconBtnTopBase.init(self, self.ui)

	self.perFrameScheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function ()
		if self.isDisposed then return end
		self:onPerFrameCheck()
	end, 0.25, false)
	
	self:onPerFrameCheck()
	self:updateView()

	local context = self
	Notify:register("AchiUpgradeEvent", function ()
		UserEnergyRecoverManager.checkEnergyIsFullTimer(0.5)		--以前是每帧都检测刷新 这里改为成就升级时 主动调一次刷新
		context:updateView()
	end, self)
end

function IconBtnTopEnergy:onPerFrameCheck()
	local energyState = UserEnergyRecoverManager:sharedInstance():getEnergyState()
	if energyState == UserEnergyState.INFINITE then
		self:updateInfiniteShow()
	elseif energyState == UserEnergyState.COUNT_DOWN_TO_RECOVER then
		self:updateRecoverShow()
	else
		assert(false, "invalid energy state!")
	end
end

function IconBtnTopEnergy:updateInfiniteShow()
	if self.energyState ~= UserEnergyState.INFINITE then
		if not self.infiniteAnim then 
			self.infiniteAnim = EnergyInfiniteAni:create()
			self.infiniteAnim:setPosition(ccp(0, 0))
			self.mainUI:addChild(self.infiniteAnim)
		end
		self.energyState = UserEnergyState.INFINITE
	end
	self:updateCountdownShow()
end

function IconBtnTopEnergy:updateRecoverShow()
	if self.energyState ~= UserEnergyState.COUNT_DOWN_TO_RECOVER then
		if self.infiniteAnim then
			self.infiniteAnim:removeFromParentAndCleanup(true)
			self.infiniteAnim = nil
		end
		self.energyState = UserEnergyState.COUNT_DOWN_TO_RECOVER
	end
	self:updateCountdownShow()
end

function IconBtnTopEnergy:updateCountdownShow()
	if not self.countdownLabel then
		-- self.countdownLabel = BitmapText:create("", "fnt/energy_cd.fnt") 	--countDownNumber.fnt少字
		self.countdownLabel	= LabelBMMonospaceFont:create(30, 30, 15, "fnt/energy_cd.fnt") --countDownNumber.fnt少字
		self.countdownLabel:setAnchorPoint(ccp(0.5, 1))
		self.ui:addChild(self.countdownLabel)
		self.countdownLabel:setPosition(ccp(80, -48))
	end
	local secondToWait = UserEnergyRecoverManager:sharedInstance():getCountdownSecondRemain() or 0
	if self.leftSeconds ~= secondToWait then
		self.leftSeconds = secondToWait 
		if self.leftSeconds <= 0 then
			self.countdownLabel:setString("")
		else
			local secondStr = ""
			if self.energyState == UserEnergyState.INFINITE then
				secondStr = self:getCountdownStr(self.leftSeconds)
			elseif self.energyState == UserEnergyState.COUNT_DOWN_TO_RECOVER then
				secondStr = self:getCountdownStr(self.leftSeconds)
			else
				assert(false, "invalid energy state!")
			end
			self.countdownLabel:setString(secondStr)
		end
	end
end

function IconBtnTopEnergy:getCountdownStr(leftSeconds)
	local d = math.floor(leftSeconds / (3600 * 24))
	local h = math.floor(leftSeconds % (3600 * 24) / 3600)
	local m = math.floor(leftSeconds % (3600 * 24) % 3600 / 60)
	local s = math.floor(leftSeconds % (3600 * 24) % 3600 % 60)

	if self.energyState == UserEnergyState.INFINITE then
		timeStr = localize(string.format("%02d:%02d:%02d", d * 24 + h, m, s)) 
	else
		timeStr = localize(string.format("%02d:%02d后+1", m + h * 60, s))
	end
	
	return timeStr
end

function IconBtnTopEnergy:setCurEnergy(curEnergy)
	local changed = false
	if self.curEnergy ~= curEnergy then
		changed = true
	end
	self.curEnergy = curEnergy
	return changed
end

function IconBtnTopEnergy:setTotalEnergy(totalEnergy)
	local changed = false
	if self.totalEnergy ~= totalEnergy then
		changed = true
	end
	self.totalEnergy = totalEnergy
	return changed
end

function IconBtnTopEnergy:updateView()
	local curChange = self:setCurEnergy(UserManager.getInstance().user:getEnergy())
	local totalChange = self:setTotalEnergy(UserEnergyRecoverManager:sharedInstance():getMaxEnergy())
	if curChange or totalChange then
		if not self.progressBar then 
			self.progressBar = IconProgressBar:create(self.mainUI, self.curEnergy, self.totalEnergy, 0.3)
		else
			if totalChange then 
				self.progressBar:setCurNumber(self.curEnergy, true)
				self.progressBar:setTotalNumber(self.totalEnergy)
			else
				self.progressBar:setCurNumber(self.curEnergy)
			end
		end

		self:setLabel(self.curEnergy .. "/" .. self.totalEnergy)
	end
end

function IconBtnTopEnergy:getPlusIconWidth()
	return 22
end

function IconBtnTopEnergy:setTempEnergyState(state)
	--do nothing 
end

function IconBtnTopEnergy:dispose()
	Notify:unregister("AchiUpgradeEvent", self)
	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.perFrameScheduleId)
	self.perFrameScheduleId = nil
	BaseUI.dispose(self)
end

function IconBtnTopEnergy:create()
	local btn = IconBtnTopEnergy.new()
	btn:init()
	return btn
end