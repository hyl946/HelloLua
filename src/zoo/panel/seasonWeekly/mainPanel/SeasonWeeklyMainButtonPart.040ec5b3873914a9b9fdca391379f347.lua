require "zoo.panel.seasonWeekly.mainPanel.SeasonWeeklyMainButton"
local NpcTigger = require 'zoo.panel.seasonWeekly.mainPanel.NpcTigger'

local buttonState = {
	kCanPlay = 1,
	kCanAddFree = 2,
	kCanBuyWithRMB = 3,
	kCanBuyWithHappyWindCoin = 4,
	kUnavailable = 5
}

SeasonWeeklyMainButtonPart = class(BasePanel)
function SeasonWeeklyMainButtonPart:create( rootGroupName , resJson , adDecision )
	local panel = SeasonWeeklyMainButtonPart.new()
	panel.resJson = resJson
    if resJson then panel:loadRequiredResource( resJson ) end
    panel.adDecision = adDecision
    panel:init( rootGroupName ) 
    return panel
end

function SeasonWeeklyMainButtonPart:init( rootGroupName )
	self.ui = self:buildInterfaceGroup( rootGroupName )
	BasePanel.init(self, self.ui)

	local playButton = self.ui:getChildByName("playButton")
	local buyButton = self.ui:getChildByName("buyButton")


	self.state = buttonState.kUnavailable
	self:initButton( playButton , buyButton )
end

function SeasonWeeklyMainButtonPart:updatePlayCountInfo()
	if self.isDisposed then return end

	if SeasonWeeklyRaceManager:getInstance():canGetFreePlay() then

		if SeasonWeeklyRaceManager:getInstance():getLeftMainLevelCountToAddWeeklyPlayCount() == 0 then
			self:setPlayCount(tostring(2))
		else
			self:setPlayCount(tostring(1))
		end

	end
end

function SeasonWeeklyMainButtonPart:initButton(  playButton , buyButton )
	local _self = self

	self.playButton = SeasonWeeklyMainButton:create( playButton )

	self.buyButton = ButtonIconNumberBase:create( buyButton )
	self.buyButton:setIconByFrameName('ui_images/ui_image_coin_icon_small0000')
	self.buyButton:setString(Localization:getInstance():getText("weekly.race.panel.rabbit.button2"))
end

function SeasonWeeklyMainButtonPart:onButtonTapped()

	if RankRaceMgr:getInstance():isEnabled() then
		CommonTip:showTip(localize('rank.race.enabled.alert'))
		return
	end

	SeasonWeeklyRaceManager:getInstance():checkTopLevelUserGetAllPlayCount()

	self.playButton:rma()
	self.buyButton:rma()

	if self.state == buttonState.kCanPlay then

		self:dispatchEvent(Event.new(SeasonWeeklyEvents.kPlayWeeklyLevel))

	elseif self.state == buttonState.kCanAddFree then

		CommonTip:showTip(localize('season.s4.can.get.play.count', {n = tostring(self.__needPlayCount or 2)}), "positive")
		self:updateMainButton()

	elseif self.state == buttonState.kUnavailable then

	elseif self.state == buttonState.kCanBuyWithRMB then
		self:dispatchEvent(Event.new(SeasonWeeklyEvents.kBuyWithRMB))
	elseif self.state == buttonState.kCanBuyWithHappyWindCoin then
		self:dispatchEvent(Event.new(SeasonWeeklyEvents.kBuyWithHappyWindCoin))
	end
end

function SeasonWeeklyMainButtonPart:onBuyButtonTapped()

	--RemoteDebug:uploadLog("RRR   SeasonWeeklyMainButtonPart:onBuyButtonTapped  self.state = " , self.state)

	if self.state == buttonState.kCanBuyWithRMB then
		self:dispatchEvent(Event.new(SeasonWeeklyEvents.kBuyWithRMB))
	elseif self.state == buttonState.kCanBuyWithHappyWindCoin then
		self:dispatchEvent(Event.new(SeasonWeeklyEvents.kBuyWithHappyWindCoin))
	end
end

function SeasonWeeklyMainButtonPart:updateMainButton()

	if self.isDisposed then return end

	self.playButton:setNumberVisible(false)
	self.playButton:setVisible(true)
	--self.playButton:setColorMode(kGroupButtonColorMode.green)
	self.playButton:setShadowVisible(false)

	self.buyButton:setVisible(false)
	self.buyButton:setColorMode(kGroupButtonColorMode.blue)


	if SeasonWeeklyRaceManager:getInstance():getLeftPlay() > 0 then
		--去闯关
		if not self.bubbleAnim then
			self.bubbleAnim = self.playButton:useBubbleAnimation(0.05)
		end
		self.playButton:setShadowVisible(true)
		self.playButton:setNumberVisible(true)
		self.playButton:setNumber(SeasonWeeklyRaceManager:getInstance():getLeftPlay())
		self.playButton:setString(Localization:getInstance():getText("weekly.race.panel.start.btn"))
		self.playButton:setColorMode(kGroupButtonColorMode.green)

		self.state = buttonState.kCanPlay
	elseif SeasonWeeklyRaceManager:getInstance():canGetFreePlay() then
		--无闯关次数，可免费获得次数
		if self.bubbleAnim then
			self.bubbleAnim:cancelBubbleAnimation()
			self.bubbleAnim = nil
		end
		self.playButton:setString(Localization:getInstance():getText("weekly.race.panel.start.btn"))--"次数不足"
		--self.playButton:setColorMode(kGroupButtonColorMode.grey)
		self.playButton:setColorMode(kGroupButtonColorMode.blue)

		self.state = buttonState.kCanAddFree
	elseif SeasonWeeklyRaceManager:getInstance():getLeftBuyCount() > 0 then
		--无闯关次数，不可免费获得次数，但可购买次数

		self.playButton:setColorMode(kGroupButtonColorMode.green)


		if self.bubbleAnim then
			self.bubbleAnim:cancelBubbleAnimation()
			self.bubbleAnim = nil
		end

		local function showWindmillPay()
			self.playButton:setVisible(false)
			self.buyButton:setVisible(true)
			self.buyButton:setNumber(SeasonWeeklyRaceManager:getInstance():getBuyQCash())

			self.state = buttonState.kCanBuyWithHappyWindCoin
		end

		local function showAndroidRmbPay()
			local mark = Localization:getInstance():getText("buy.gold.panel.money.mark")
			local text = Localization:getInstance():getText("weekly.race.panel.rabbit.button2")
			local rmb = SeasonWeeklyRaceManager:getInstance():getBuyRmb()
			self.playButton:setString(string.format("%s%0.2f %s", mark, rmb, text))
			self.playButton:setColorMode(kGroupButtonColorMode.blue)

			self.state = buttonState.kCanBuyWithRMB
		end

	    if __ANDROID then
	    	--BroadcastManager:getInstance():showTestTip("decision = " .. tostring(self.adDecision))
	        if self.adDecision == IngamePaymentDecisionType.kPayWithWindMill then
	            showWindmillPay()
	        else
	            showAndroidRmbPay()
	        end
	    else
	        showWindmillPay()
	    end
	else

		self.playButton:setColorMode(kGroupButtonColorMode.green)

		if self.bubbleAnim then
			self.bubbleAnim:cancelBubbleAnimation()
			self.bubbleAnim = nil
		end
		self.playButton:setString(Localization:getInstance():getText("weeklyrace.summer.panel.desc22")) --"次数已用完"
		--self.playButton:setColorMode(kGroupButtonColorMode.grey)
		self.playButton:setEnabled(false)

		self.state = buttonState.kUnavailable
	end

	local function addButtonListener()
		if self.isDisposed then 
			return
		end
		
		self.playButton:rma()
		self.buyButton:rma()

		self.playButton:addEventListener( DisplayEvents.kTouchTap , function () self:onButtonTapped() end )
		self.buyButton:addEventListener( DisplayEvents.kTouchTap , function () self:onButtonTapped() end )
	end
	
	addButtonListener()
end

function SeasonWeeklyMainButtonPart:setPlayCount( num )

	self.__needPlayCount = num
end
