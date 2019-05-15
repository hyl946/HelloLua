require "zoo.panel.endGameProp.EndGamePropBasePanel"

EndGamePropOlympicPanel = class(EndGamePropBasePanel_VerB)


function EndGamePropOlympicPanel:create(levelId, levelType, propId, onUseCallback, onCancelCallback, useTipText)

	local panel = EndGamePropOlympicPanel.new()
	panel.levelId = levelId
	panel.propId = propId
	panel.levelType = levelType
	panel.onUseTappedCallback = onUseCallback
	panel.onCancelTappedCallback = onCancelCallback
	panel:loadRequiredResource(PanelConfigFiles.panel_add_step)

	panel.adDecision = decision
	panel.adPaymentType = paymentType
	panel.dcAndroidStatus = dcAndroidStatus
	panel.adRepayChooseTable = repayChooseTable

	panel.goodsId = pGoodsId
	panel.showType = pShowType

	local isFUUU , fuuuId = FUUUManager:lastGameIsFUUU(true)
	panel.lastGameIsFUUU = isFUUU
	panel.fuuuLogID = fuuuId

	panel:init() 
	if type(useTipText) == "string" then
		panel:setUseTipText(useTipText)
		panel:setUseTipVisible(true)
	end
	-- AddFiveStepABCTestLogic:dcLog("pop_add_5_steps", levelId, panel.actSource, propId)
	--EndGamePropABCTest.getInstance():dcLog("alert_add_5_steps", levelId, panel.actSource, propId, isFUUU)
	
	--panel:popout() 
	return panel
end

function EndGamePropOlympicPanel:init()

	EndGamePropBasePanel_VerB.init(self)

	if self.buyButton then
		self.buyButton.groupNode:stopAllActions()
	end
	if not self.useButton then
		self.useButtonUI:setVisible(true)
		self.useButton = EndGameUseButton:create(self.useButtonUI, self.propId)
		self:saveBtnScaleInfo(self.useButton)
		-- self.useButton:setColorMode(kGroupButtonColorMode.blue)
		self.useButton:addEventListener(DisplayEvents.kTouchTap, function (evt)
			self:onUseBtnTapped()
		end)
		self.buyButtonUI:setVisible(false)
		self.countdownLabel:setPositionX(541)
	end
	self.useButton:setNumber(1)
	-- self.useButton:setColorMode(kGroupButtonColorMode.blue)
	--self.useButton:setString(Localization:getInstance():getText("add.step.panel.use.btn.txt"))
	self.useButton:setString("免费使用")

	self.msgLabel:setString(Localization:getInstance():getText("add.step.panel.msg.txt.10077_free"))

	self:onCountdownComplete()
	self.actSource = EndGameButtonTypeAndroid.kPropEnough

	self.closeBtn:setVisible(false)
	self.closeBtn:setTouchEnabled(false)
	self.allowBackKeyTap = false

	return false
end

function EndGamePropOlympicPanel:setCloseBtnEnable()
	self.closeBtn:setVisible(true)
	self.closeBtn:setTouchEnabled(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function (evt)
		if self.onCancelTappedCallback then
			self.onCancelTappedCallback()
		end
	end)
end

function EndGamePropOlympicPanel:onUseBtnTapped()

	if self.onUseTappedCallback then
		self.onUseTappedCallback(usePropId, usePropType)
	end

	self:remove(false)
end

function EndGamePropOlympicPanel:popout()
	if _G.isLocalDevelopMode then printx(0, 'EndGamePropOlympicPanel:popout()') end
	local function callback()
		self:updateFuuuTargetShow(true)
		self:popoutFinishCallback()
	end
	self.panelPopRemoveAnim:popout(callback, true)
end

function EndGamePropOlympicPanel:popoutFinishCallback()
	EndGamePropBasePanel.popoutFinishCallback(self)
	self.allowBackKeyTap = false
end