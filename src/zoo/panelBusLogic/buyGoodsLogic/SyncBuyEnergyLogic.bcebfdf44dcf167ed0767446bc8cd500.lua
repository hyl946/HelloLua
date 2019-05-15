require "zoo.net.SyncManager"
require "zoo.panelBusLogic.BuyEnergyLogic"

SyncBuyEnergyLogic = class()

function SyncBuyEnergyLogic:start(onSuccessCallback, onFailCallback, onExceptionCallback)
	self:createAnimation()
	self.listening = true
	self:sync(onSuccessCallback, onFailCallback, onExceptionCallback)
end

function SyncBuyEnergyLogic:sync(onSuccessCallback, onFailCallback, onExceptionCallback)
	local function onSuccess()
		if self.listening then self:buy(onSuccessCallback, onFailCallback, onExceptionCallback) end
	end
	local function onFail(evt)
		if self.listening then
			self.listening = false
			self:removeAnimation()
			if onFailCallback then onFailCallback(evt) end
		end
	end
	SyncManager:getInstance():sync(onSuccess, onFail)
end

function SyncBuyEnergyLogic:buy(onSuccessCallback, onFailCallback, onExceptionCallback)
	local curEnergy = UserManager.getInstance().user:getEnergy()
	--local maxEnergy = MetaManager.getInstance().global.user_energy_max_count
	local maxEnergy	= UserEnergyRecoverManager:sharedInstance():getMaxEnergy()

	local num = maxEnergy - curEnergy
	if num <= 0 then
		if onExceptionCallback then onExceptionCallback() end
		self:removeAnimation()
		return
	end
	local logic = BuyEnergyLogic:create(num)
	local function onSuccess(data)
		if self.listening then
			self.listening = false
			self:removeAnimation()
			if onSuccessCallback then onSuccessCallback(data) end
		end
	end
	local function onFail(errorCode)
		if self.listening then
			self.listening = false
			self:removeAnimation()
			if onFailCallback then onFailCallback(errorCode) end
		end
	end
	logic:start(false, onSuccess, onFail)
end

function SyncBuyEnergyLogic:createAnimation()
	local scene = Director:sharedDirector():getRunningScene()
	local wSize = Director:sharedDirector():getWinSize()
	local layer = LayerColor:create()
	layer:changeWidthAndHeight(wSize.width, wSize.height)
	layer:setOpacity(0)
	layer:setTouchEnabled(true, 0, true)
	PopoutManager:sharedInstance():add(layer, false, false)
	self.layer = layer
	local function onCloseButtonTap()
		if self.listening then
			self.listening = false
			self:removeAnimation()
		end
	end
	local function onTimeout()
		-- if self.schedule then
		-- 	Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule)
		-- 	self.schedule = nil
			if self.layer then self.layer.onKeyBackClicked = function() onCloseButtonTap() end end
			local animation = CountDownAnimation:createNetworkAnimation(scene, onCloseButtonTap)
			self.animation = animation
		-- end
	end
	onTimeout()
	-- self.schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, 1, false)
end

function SyncBuyEnergyLogic:removeAnimation()
	-- if self.schedule then
	-- 	Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule)
	-- 	self.schedule = nil
	-- end
	if self.animation then self.animation:removeFromParentAndCleanup(true) end
	if self.layer then PopoutManager:sharedInstance():remove(self.layer) end
end

function SyncBuyEnergyLogic:create()
	return SyncBuyEnergyLogic.new()
end
