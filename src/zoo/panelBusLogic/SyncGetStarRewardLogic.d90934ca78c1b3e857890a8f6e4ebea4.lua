require "zoo.net.SyncManager"
require "zoo.panelBusLogic.BuyEnergyLogic"

require "zoo.panelBusLogic.GetStarRewardsLogic"


SyncGetStarRewardLogic = class()

function SyncGetStarRewardLogic:init(rewardId)
	self.rewardId = rewardId
end

function SyncGetStarRewardLogic:start(onSuccessCallback, onFailCallback, onCancelCallback)
	self:createAnimation(onCancelCallback)
	self.listening = true
	self:sync(onSuccessCallback, onFailCallback)
end

function SyncGetStarRewardLogic:sync(onSuccessCallback, onFailCallback)
	local function onSuccess(evt)
		if self.listening then self:get(onSuccessCallback, onFailCallback) end
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

function SyncGetStarRewardLogic:get(onSuccessCallback, onFailCallback)
	local logic = GetStarRewardsLogic:create(self.rewardId)
	local function onSuccess(event)
		if self.listening then
			self.listening = false
			self:removeAnimation()
			if onSuccessCallback then onSuccessCallback(event) end
		end
	end
	local function onFail(event)
		if self.listening then
			self.listening = false
			self:removeAnimation()
			if onFailCallback then onFailCallback(event) end
		end
	end
	logic:setSuccessCallback(onSuccess)
	logic:setFailCallback(onFail)
	logic:start(false)
end

function SyncGetStarRewardLogic:createAnimation(cancelCallback)
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
			if cancelCallback then cancelCallback() end
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

function SyncGetStarRewardLogic:removeAnimation()
	-- if self.schedule then
	-- 	Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule)
	-- 	self.schedule = nil
	-- end
	if self.animation then self.animation:removeFromParentAndCleanup(true) end
	if self.layer then PopoutManager:sharedInstance():remove(self.layer) end
end

function SyncGetStarRewardLogic:create(rewardId)
	local logic = SyncGetStarRewardLogic.new()
	logic:init(rewardId)
	return logic
end
