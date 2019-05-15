require "zoo.panel.basePanel.BasePanel"
require "zoo.data.UserEnergyRecoverManager"

ConfirmBuyFullEnergyPanel = class(BasePanel)

function ConfirmBuyFullEnergyPanel:create(isEnteringLevel)
	local panel = ConfirmBuyFullEnergyPanel.new()
	panel:init(isEnteringLevel)
	return panel
end

function ConfirmBuyFullEnergyPanel:init(isEnteringLevel)
	self:loadRequiredResource(PanelConfigFiles.panel_confirm_buy_full_energy)
	local ui = self:buildInterfaceGroup("ConfirmBuyFullEnergyPanel/ConfirmBuyFullEnergyPanel")
	BasePanel.init(self, ui)

	local close = ui:getChildByName("close")
	close:setTouchEnabled(true)
	close:setButtonMode(true)
	close:addEventListener(DisplayEvents.kTouchTap, function() self:onCloseBtnTapped() end)

	local buyBtn = ButtonIconNumberBase:create(ui:getChildByName("button1"))
	buyBtn:setColorMode(kGroupButtonColorMode.blue)
	buyBtn:useBubbleAnimation()
	local icon = Sprite:createWithSpriteFrameName("common_icon/item/icon_coin_small0000")
	icon:setAnchorPoint(ccp(0, 1))
	buyBtn:setIcon(icon, true)
	buyBtn:setNumberAlignment(kButtonTextAlignment.center)
	if isEnteringLevel then
		buyBtn:setString(Localization:getInstance():getText("energy.panel.buy.continue.button.label"))
	else
		buyBtn:setString(Localization:getInstance():getText("energy.panel.buy.button.label"))
	end
	buyBtn:addEventListener(DisplayEvents.kTouchTap, function() self:buyEnergy() end)
	self.buyBtn = buyBtn

	local continueBtn = GroupButtonBase:create(ui:getChildByName("button2"))
	continueBtn:setString(Localization:getInstance():getText("energy.panel.continue.button.label"))
	continueBtn:useBubbleAnimation()
	continueBtn:addEventListener(DisplayEvents.kTouchTap, function() self:onCloseBtnTapped(true) end)
	self.continueBtn = continueBtn

	ui:getChildByName("desc"):setString(Localization:getInstance():getText("energy.panel.reconfirm.content"))
	self.time = ui:getChildByName("time")
	self.energy = ui:getChildByName("energy")
	local lightning = ui:getChildByName("lightning")
	local size = lightning:getContentSize()
	self.energyCenterPos = lightning:getPositionX() + size.width / 2
	self.discountTag = ui:getChildByName("tag")
	local good = MetaManager:getInstance():getGoodMeta(34)
	self.discountTag:getChildByName("num"):setString(tostring(math.ceil(good.discountQCash / good.qCash * 10)))
	self.discountTag:getChildByName("text"):setString(Localization:getInstance():getText("buy.gold.panel.discount"))

	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()
	local hit_area = ui:getChildByName("hit_area")
	local bg = LayerColor:create()
	bg:ignoreAnchorPointForPosition(false)
	bg:setAnchorPoint(ccp(0, 1))
	bg:setOpacity(128)
	bg:setContentSize(hit_area:getGroupBounds(ui).size)
	local vSize = Director:sharedDirector():getVisibleSize()
	bg:setContentSize(CCSizeMake(vSize.width / self:getScale(), bg:getContentSize().height))
	bg:setPositionX(-self:getPositionX() / self:getScale())
	ui:addChildAt(bg, 0)

	local size = close:getGroupBounds(ui).size
	close:setPositionX(math.min(close:getPositionX(), bg:getPositionX() + bg:getContentSize().width - size.width / 2))

	self.isEnteringLevel = isEnteringLevel
	self:runAction(CCRepeatForever:create(CCCallFunc:create(function() self:refresh(isEnteringLevel) end), CCDelayTime:create(0.3)))
end

function ConfirmBuyFullEnergyPanel:refresh(isEnteringLevel)
	local timeUnit = MetaManager:getInstance().global.user_energy_recover_time_unit / 1000
	timeUnit = timeUnit * FcmManager:getTimeScale()
	local consume = MetaManager:getInstance().global.user_energy_level_consume
	local maxEnergy = UserEnergyRecoverManager:sharedInstance():getMaxEnergy()
	local energy = UserEnergyRecoverManager:sharedInstance():getEnergy()
	local buyed = UserManager:getInstance():getDailyBoughtGoodsNumById(34)
	local good = MetaManager:getInstance():getGoodMeta(34)
	local price = buyed > 0 and good.qCash or good.discountQCash
	local normGood = good.qCash
	local discountGood = good.discountQCash
	self.energy:setText(tostring(energy)..'/'..tostring(maxEnergy))
	self.energy:setScale(1.3)
	local size = self.energy:getContentSize()
	self.energy:setPositionX(self.energyCenterPos - size.width * 1.3 / 2)

	self.buyBtn:setVisible(energy ~= maxEnergy or isEnteringLevel and energy < consume)
	self.buyBtn:setNumber(tostring(price * (maxEnergy - energy)))
	self.continueBtn:setVisible(energy == maxEnergy or isEnteringLevel and energy >= consume)
	self.discountTag:setVisible(energy ~= maxEnergy and buyed <= 0)
	if self.discountTag:isVisible() and self.buyBtn:isVisible() then
		local btnGb = self.buyBtn:getGroupBounds(self.ui)
		self.discountTag:setPositionX(btnGb.origin.x + btnGb.size.width - 35)
		self.discountTag:setPositionY(btnGb.origin.y + btnGb.size.height + 35)
	end

	local second = UserEnergyRecoverManager:sharedInstance():getCountdownSecondRemain()
	if energy < consume then
		second = second + (4 - energy) * timeUnit
		self.time:setString(string.format("%02d:%02d", math.floor(second / 60) % 60, math.ceil(second % 60))..
			Localization:getInstance():getText("energy.panel.time.to.five.energy.txt", {energy_number = consume}))
	elseif energy < maxEnergy then
		second = second + (maxEnergy - energy - 1) * timeUnit
		self.time:setString(Localization:getInstance():getText("energy.panel.reconfirm.desc", {time = (string.format("%02d:%02d:%02d", math.floor(second / 3600),
			math.floor(second / 60) % 60, math.ceil(second % 60)))}))
	else
		self.time:setString(Localization:getInstance():getText("energy.panel.energy.is.full"))
	end
end

function ConfirmBuyFullEnergyPanel:buyEnergy()
	local function startBuyLogic()
		if self.isDisableBuyBtn then return end
		self.isDisableBuyBtn = true

		self:stopAllActions()
		local good = MetaManager:getInstance():getGoodMeta(34)
		local buyed = UserManager:getInstance():getDailyBoughtGoodsNumById(34)
		local maxEnergy = UserEnergyRecoverManager:sharedInstance():getMaxEnergy()
		local energy = UserEnergyRecoverManager:sharedInstance():getEnergy()
		local neededCash = good.qCash * (maxEnergy - energy)
		if buyed <= 0 then
			neededCash = good.discountQCash * (maxEnergy - energy)
		end

		if UserManager:getInstance():getUserRef():getCash() < neededCash then
			local function createGoldPanel()
				local index = MarketManager:sharedInstance():getHappyCoinPageIndex()
				if index ~= 0 then
					local panel = createMarketPanel(index)
					panel:popout()
				end
			end
			GoldlNotEnoughPanel:createWithTipOnly(createGoldPanel)
			self.isDisableBuyBtn = false
		else

			local function onBuyEnergySuccessCallback()
				HomeScene:sharedInstance():checkDataChange()
				HomeScene:sharedInstance().energyButton:updateView()
				HomeScene:sharedInstance().goldButton:updateView()
				GamePlayMusicPlayer:playEffect(GameMusicType.kAddEnergy)
				if self.isDisposed then return end

				self.buyBtn:playFloatAnimation(
					'-'..tostring(self.buyBtn:getNumber()),
					function()
						if self and self.isDisposed == false then
							self:onCloseBtnTapped()
						end
					end
				)
			end

			local function onBuyEnergyFailCallback(evt)
				if self.isDisposed then return end
				
				self:runAction(CCRepeatForever:create(CCCallFunc:create(function() self:refresh(self.isEnteringLevel) end), CCDelayTime:create(0.3)))
				if type(evt) == 'table' and evt.data then 
					CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(evt.data)), "negative")
				else 
					local networkType = MetaInfo:getInstance():getNetworkInfo();
					local errorCode = tonumber(evt) or "-2";
					if networkType and networkType == -1 then 
						errorCode = "-6";
					end
					CommonTip:showTip(Localization:getInstance():getText("error.tip."..errorCode), "negative")
				end
				self.isDisableBuyBtn = false
			end

			local logic = BuyEnergyLogic:create(maxEnergy - energy)
			logic:start(true, onBuyEnergySuccessCallback, onBuyEnergyFailCallback)
		end
	end

	if PrepackageUtil:isPreNoNetWork() then
		PrepackageUtil:showInGameDialog()
		return 
	end

	startBuyLogic()
end

function ConfirmBuyFullEnergyPanel:popout()
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true

	RealNameManager:addConsumptionLabelToPanel(self, true)
end

function ConfirmBuyFullEnergyPanel:onCloseBtnTapped(isContinue)
	self.allowBackKeyTap = false
	self:dispatchEvent(Event.new(kPanelEvents.kClose, isContinue == true, self))
	PopoutManager:sharedInstance():remove(self)
end