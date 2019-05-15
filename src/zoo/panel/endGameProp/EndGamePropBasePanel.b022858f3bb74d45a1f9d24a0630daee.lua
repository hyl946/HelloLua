--=====================================================
-- EndGamePropBasePanel
-- by zhijian.li
-- (c) copyright 2009 - 2016, www.happyelements.com
-- All Rights Reserved. 
--=====================================================
-- filename:  EndGamePropBasePanel.lua
-- author:    zhijian.li
-- e-mail:    zhijian.li@happyelements.com
-- created:   2016/09/29
-- descrip:   最终加五步面板基类
--=====================================================
require "zoo.common.CountdownTimer"
require "zoo.panel.component.common.BubbleItem"
require "zoo.common.ItemType"
require "zoo.panel.component.addStepPanel.UseAddStepBtn"
require "zoo.panelBusLogic.BuyLogic"
require "zoo.panel.RequireNetworkAlert"
require 'hecore.sns.SnsProxy'
require 'zoo.panel.FreeFCashPanel'

require "zoo.panelBusLogic.IapBuyPropLogic"
require "zoo.panelBusLogic.AddFiveStepABCTestLogic"
require "zoo.util.FUUUManager"
require 'zoo.payment.WechatQuickPayLogic'
require "zoo.modules.olympic.OlympicAnimalAnimation"

require "zoo.panel.endGameProp.EndGamePropManager"
require "zoo.panel.endGameProp.EndGameComponent"
require "zoo.panel.endGameProp.EndGamePropBasePanelNormalAnimalAnimetionCreator"

EndGamePropBasePanel = class(BasePanel)
function EndGamePropBasePanel:ctor()
	



end

function EndGamePropBasePanel:init()
	self.ui = self:buildInterfaceGroup(self:getUIGroupName())
	BasePanel.init(self, self.ui)
	--基础UI
	self.closeBtn = self.ui:getChildByName("closeBtn")
	self.msgLabel = self.ui:getChildByName("msgLabel")
	self.msgLabelPh = self.ui:getChildByName("msgLabelph")
	self.msgLabelPh:setVisible(false)
	self.itemGroupUI = self.ui:getChildByName("itemGroup")
	if self.itemGroupUI then self.itemGroupUI:setVisible(false) end
	self.countdownLabel = self.ui:getChildByName("countdownLabel")
	self.countdownLabel:setScale(1.3)
	self.countdownLabel:setAnchorPoint(ccp(0.5, 0.5))
	self.countdownLabel:setPositionY(self.countdownLabel:getPositionY() - 45)
	self.ui:getChildByName('labelPh'):setVisible(false)
	self.buyButtonUI = self.ui:getChildByName("buyBtn")
	self.useButtonUI = self.ui:getChildByName("useBtn")
	self.animPh = self.ui:getChildByName("animPh")
	self.moneyBar = self.ui:getChildByName("moneyBar")
	self.moneyBar:setVisible(false)

	self.ios_ali_link = self.ui:getChildByName('ios_ali_link')
	self.ios_ali_link:setVisible(false)

	--道具图标
	local builder = InterfaceBuilder:create(PanelConfigFiles.properties)
	local sprite = builder:buildGroup("Prop_"..tostring(self.propId))
	local icon = self.ui:getChildByName("icon")
	local iSize = icon:getGroupBounds().size
	local sSize = sprite:getGroupBounds().size
	sprite:setScale(iSize.height / sSize.height)
	if EndGamePropManager.getInstance():isReviveProp(itemId) then
		sprite:setScale(sprite:getScale()*0.9)
	end
	sprite:setPositionXY(icon:getPositionX(), icon:getPositionY())
	self.ui:addChild(sprite)
	self.propIconSprite = sprite
	icon:removeFromParentAndCleanup(true)
	self.useTipLabel = self.ui:getChildByName("use_tip")
	self.useTipLabel:setVisible(false)

	--动画
	if not self.animalAnimetionCreator then
		self.animalAnimetionCreator = EndGamePropBasePanelNormalAnimalAnimetionCreator
	end

	local anim , animOffX , animOffY , autoScale = self.animalAnimetionCreator:createAnime(self.propId)
	self:createAnime( anim , animOffX , animOffY , autoScale )


	--显示文案
	local dimensions = self.msgLabel:getDimensions()
	self.msgLabel:setDimensions(CCSizeMake(dimensions.width, 0))
	if self.levelType == GameLevelType.kDigWeekly then
		self.msgLabel:setString(Localization:getInstance():getText('add.step.panel.msg.weekly.race'))
	elseif self.levelType == GameLevelType.kMayDay then
		self.msgLabel:setString(Localization:getInstance():getText('activity.dragonboat.fail.add.five'))
	elseif self.levelType == GameLevelType.kRabbitWeekly then
		self.msgLabel:setString(Localization:getInstance():getText('add.step.panel.msg.txt.10040.rabbit'))
	else
		self.msgLabel:setString(Localization:getInstance():getText("add.step.panel.msg.txt."..self.propId))
	end
	local size = self.msgLabel:getContentSize()
	local phSize = self.msgLabelPh:getGroupBounds().size
	self.msgLabel:setPositionY(self.msgLabelPh:getPositionY() - (phSize.height - size.height) / 2)

	--关闭按钮
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function ()
		self.closeBtn:setTouchEnabled(false)
		self:onCloseBtnTapped()
	end)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:setTouchEnabled(true)

	--面板弹出定位
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	local size = self:getGroupBounds().size
	self.panelPopRemoveAnim	= PanelPopRemoveAnim:create(self)
	local initX = self:getHCenterInScreenX()
	self.panelPopRemoveAnim:setPopHidePos(initX, size.height)
	self.panelPopRemoveAnim:setPopShowPos(0, (size.height - vSize.height) / 2 + vOrigin.y)

	local propNum = EndGamePropManager.getInstance():getItemNum(self.propId)
	printx( 1 , "   EndGamePropBasePanel:init  propNum = " .. tostring(propNum))
	local propNeedBuy = false
	if self.levelType == GameLevelType.kOlympicEndless or self.levelType == GameLevelType.kMidAutumn2018 then
		propNum = 0
	end
	if propNum > 0 then -- use
		self.useButton = EndGameUseButton:create(self.useButtonUI, self.propId)
		self:saveBtnScaleInfo(self.useButton)
		self.useButton:setNumber(propNum)
		-- self.useButton:setColorMode(kGroupButtonColorMode.blue)
		self.useButton:setString(Localization:getInstance():getText("add.step.panel.use.btn.txt"))
		self.useButton:addEventListener(DisplayEvents.kTouchTap, function (evt)
			self:onUseBtnTapped()
		end)
		self.buyButtonUI:setVisible(false)
		self.countdownLabel:setPositionX(541)
	else -- buy
		self.buyButton = EndGameBuyButton:create(self.buyButtonUI, self.propId)
		self:saveBtnScaleInfo(self.buyButton)
		self.buyButton:setColorMode(kGroupButtonColorMode.blue)
		-- self.buyButton.numberLabel:setPositionX(self.buyButton.numberLabel:getPositionX() - 20)
		self.buyButton:setString(Localization:getInstance():getText("add.step.panel.buy.btn.txt"))
		self.buyButton:addEventListener(DisplayEvents.kTouchTap, function ()
			self:onBuyBtnTapped()
		end)
		self.useButtonUI:setVisible(false)
		propNeedBuy = true
		AddFiveStepABCTestLogic:setPropNeedBuy(true)
		self.countdownLabel:setPositionX(521)
	end

	if not propNeedBuy then 
		--非购买的加五步 倒计时处理再这里 购买的时候~在对应平台的加五步面板init里
		self:updateCountdownShow()
	end
	return propNeedBuy
end

function EndGamePropBasePanel:updateCountdownShow()
	--倒计时初始化 要在初始化按钮之后
	if AddFiveStepABCTestLogic:needShowCountdown() then
		self:setCountdownSceond(10)
	else
		self:onCountdownComplete()
	end
end

function EndGamePropBasePanel:saveBtnScaleInfo(button)
	if self.BtnSourceScale == nil then
		self.BtnSourceScale = {}
	end
	local btnBGNode = button.groupNode
	local scaleX = btnBGNode:getScaleX()
	local scaleY = btnBGNode:getScaleY()
	self.BtnSourceScale[tostring(button)] = {ScaleX = scaleX , ScaleY = scaleY}
end

function EndGamePropBasePanel:getUIGroupName()
	if _G.isLocalDevelopMode then printx(101, "  " , debug.traceback() ) end
	return "newAddStepPanel"
end


function EndGamePropBasePanel:getJsonPath()
	return PanelConfigFiles.panel_add_step
end

function EndGamePropBasePanel:setUseTipText(text)
	if self.useTipLabel then
		self.useTipLabel:setString(tostring(text))
	end
end

function EndGamePropBasePanel:setUseTipVisible(isVisible)
	if self.useTipLabel then
		self.useTipLabel:setVisible(isVisible == true)
	end
end

function EndGamePropBasePanel:createAnime(anim , posDeltaX , posDeltaY , autoScale)
	local cryingAnimation = anim
	
	self.ui:addChild(cryingAnimation)
	self.cryingAnimation = cryingAnimation
	local aSize = self.cryingAnimation:getGroupBounds().size
	local pSize = self.animPh:getGroupBounds().size
	self.cryingAnimation:setPositionXY(
		self.animPh:getPositionX() + posDeltaX,
		self.animPh:getPositionY() + posDeltaY)
	if autoScale then
		self.cryingAnimation:setScale(pSize.height / aSize.height)
	end
	self.animPh:setVisible(false)
end

function EndGamePropBasePanel:onCloseBtnTapped()
	self:stopCountdown()
	local function hideFinishCallback()
		FUUUManager:clearLastFuuuID()
		if self.onCancelTappedCallback then
			self.onCancelTappedCallback()
		end
	end
	self.allowBackKeyTap = false
	self:remove(hideFinishCallback)
end

function EndGamePropBasePanel:onUseBtnTapped()
	local usePropType = UsePropsType.NORMAL
	local usePropId = self.propId
	local timeProps = UserManager:getInstance():getTimePropsByRealItemId(self.propId)
	if #timeProps > 0 then
		usePropType = UsePropsType.EXPIRE
		usePropId = timeProps[1].itemId
	end

	local function onSuccess()
		self:dcUseSuccess()

		local function onCallback()
			if self.onUseTappedCallback then
				self.onUseTappedCallback(usePropId, usePropType, self.isBuyAddFive)
			end
		end
		local pos = self.useButton:getPosition()
		pos = self.useButton:getParent():convertToWorldSpace(ccp(pos.x, pos.y))
		if EndGamePropManager.getInstance():isAddTimeProp(self.propId) then 
			self:addPropUseAnimation(pos, onCallback)
		else
			onCallback()
		end
		self:remove(false)
	end
	local function onFail(evt)
		local function resumeTimer()
			if self.isDisposed then return end
			local function onCountDown() self:countdownCallback() end
			if AddFiveStepABCTestLogic:needShowCountdown() then
				self:startCountdown(onCountDown)
			end
			self.useButton:setEnabled(true)
		end
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..evt.data), "negative", resumeTimer)
	end
	self.useButton:setEnabled(false)
	self:stopCountdown()
	local logic = UsePropsLogic:create(usePropType, self.levelId, 0, {usePropId})
	logic:setSuccessCallback(onSuccess)
	logic:setFailedCallback(onFail)
	logic:start(true)

	self:dcUseBtnClick()
end

function EndGamePropBasePanel:onBuyBtnTapped()
	self.buyButton:setEnabled(false)
	self:stopCountdown()
end

function EndGamePropBasePanel:onBuySuccess()
	if self.isDisposed then return end

	local function useAddStepSuccess()
		local function onCallback()
			if self.onUseTappedCallback then
				self.onUseTappedCallback(self.propId, UsePropsType.NORMAL, true)
			end
		end
		if self.isDisposed then return end
		local pos = self.buyButton:getPosition()
		pos = self.buyButton:getParent():convertToWorldSpace(ccp(pos.x, pos.y))
		if EndGamePropManager.getInstance():isAddTimeProp(self.propId) then 
			self:addPropUseAnimation(pos, onCallback)
		else
			onCallback()
		end

		self:remove(false)
	end

	self.onEnterForeGroundCallback = nil
	self:stopAllActions()
		
	local button = HomeScene:sharedInstance().goldButton
	if button then button:updateView() end

	self:useAfterBuy(useAddStepSuccess)
end

function EndGamePropBasePanel:onBuyFail(errorCode, errorMsg)
	if self.isDisposed then return end
	self.onEnterForeGroundCallback = nil
	self:stopAllActions()
	local function resumeTimer()
		if self.isDisposed then return end
		self:resumeTimer()
	end
	local function onCreateGoldPanel()
		local index = MarketManager:sharedInstance():getHappyCoinPageIndex()
		if index ~= 0 then
			local panel = createMarketPanel(index)
			panel:popout()
			panel:addEventListener(kPanelEvents.kClose, resumeTimer)
		else 
			resumeTimer() 
		end
	end
	if errorCode and errorCode == 730330 then -- not enough gold
		GoldlNotEnoughPanel:createWithTipOnly(onCreateGoldPanel)
	end
end

function EndGamePropBasePanel:onBuyCancel()
	if self.isDisposed then return end
	self.onEnterForeGroundCallback = nil
	self:stopAllActions()
	self:resumeTimer()
end

function EndGamePropBasePanel:useAfterBuy(useSucFunc, useFailFunc)
	self:useProp(self.propId, useSucFunc, useFailFunc)
end

function EndGamePropBasePanel:useProp(propId, useSucFunc, useFailFunc)
	if EndGamePropManager.getInstance():isAddTimeProp(propId) then 
		if useSucFunc then useSucFunc() end
		return
	end
	local function succFunc()
		if useSucFunc then useSucFunc() end
	end
	local function failFunc()
		if useFailFunc then useFailFunc() end
	end
	local logic = UsePropsLogic:create(UsePropsType.NORMAL, self.levelId, 0, {propId}, nil)
	logic:setSuccessCallback(succFunc)
	logic:setFailedCallback(failFunc)
	logic:start()
end

function EndGamePropBasePanel:resumeTimer()
	if self.isDisposed then return end
	local function onCountDown() self:countdownCallback() end
	if AddFiveStepABCTestLogic:needShowCountdown() then
		self:startCountdown(onCountDown)
	end
	if type(self.updateGoldNum) == "function" then
		self:updateGoldNum()
	end
	self.buyButton:setEnabled(true)
end

function EndGamePropBasePanel:addPropUseAnimation(pos, onAnimFinishedCallback )
	if EndGamePropManager.getInstance():isAddTimeProp(self.propId) then 
		local icon = ResourceManager:sharedInstance():buildItemSprite(self.propId)
		local scene = Director:sharedDirector():getRunningScene()
		local animation = PrefixPropAnimation:createAddTimeAnimation(icon, 0, onAnimFinishedCallback, nil, ccp(pos.x, pos.y + 90))
		scene:addChild(animation)
	end
end

function EndGamePropBasePanel:startCountdown(callback)
	local function callbackFunc()
		if self.second and type(self.second) == "number" then
			self.second = self.second - 1
		end
		callback(self.second)
	end
	if self.second and type(self.second) == "number" and self.second > 0 then
		callback(self.second)
		self.countdownLabel:stopAllActions()
		self.countdownLabel:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCDelayTime:create(1), CCCallFunc:create(callbackFunc))))
	end
end

function EndGamePropBasePanel:stopCountdown()
	self.countdownLabel:stopAllActions()
end

function EndGamePropBasePanel:setCountdownSceond(second)
	self.secondToCountdown = second
	self.countdownLabel:setText(tostring(second))
end

function EndGamePropBasePanel:countdownCallback()
	if self.second == 0 then
		self.countdownLabel:stopAllActions()
		self:onCountdownComplete(true)
	else
		self:setCountdownSceond(self.second)
	end
end

function EndGamePropBasePanel:onCountdownComplete(showAnime)
	if AddFiveStepABCTestLogic:needAutoClosePanel() == true then
		printx( 1 , "   EndGamePropBasePanel:onCountdownComplete   needAutoClosePanel")
		self:onCloseBtnTapped()
	else
		printx( 1 , "   EndGamePropBasePanel:onCountdownComplete   needNotAutoClosePanel")
		self.countdownLabel:setVisible(false)
		if not self.onCountdownCompleteAnimePlayed then
			local fixY = 45
			if self.buyButton and self.buyButton.groupNode and self.buyButton.groupNode.parent ~= nil then
				if showAnime then
					self.buyButton.groupNode:runAction(CCMoveTo:create(0.5, ccp(self.buyButton:getPositionX(), self.buyButton:getPositionY() + fixY)))
				else
					self.buyButton:setPositionY(self.buyButton:getPositionY() + fixY)
				end
			end

			if self.useButton and self.useButton.groupNode and self.useButton.groupNode.parent ~= nil then
				if showAnime then
					self.useButton.groupNode:runAction(CCMoveTo:create(0.5, ccp(self.useButton:getPositionX(), self.useButton:getPositionY() + fixY)))
				else
					self.useButton:setPositionY(self.useButton:getPositionY() + fixY)
				end
			end
			
			if self.propIconSprite then
				if showAnime then
					self.propIconSprite:runAction(CCMoveTo:create(0.5, ccp(self.propIconSprite:getPositionX(), self.propIconSprite:getPositionY() + fixY)))
				else
					self.propIconSprite:setPositionY(self.propIconSprite:getPositionY() + fixY)
				end
			end
			
		end
		self.onCountdownCompleteAnimePlayed = true
	end
end

function EndGamePropBasePanel:popoutFinishCallback()
	self.allowBackKeyTap = true
	local function countdownCallback() self:countdownCallback() end
	self.second = 10

	if AddFiveStepABCTestLogic:needShowCountdown() then
		self:startCountdown(countdownCallback)
	end

	if self.propId == 10004 then
		local propNum = UserManager:getInstance():getUserProp(self.propId) 
		if not propNum or propNum.num <= 0 then
			FreeFCashPanel:showWithOwnerCheck(self)
		end
	end
	if self.buyButton then 
		self.buyButton:useBubbleAnimation()
	end
end

function EndGamePropBasePanel:popout()
	if _G.isLocalDevelopMode then printx(0, 'EndGamePropBasePanel:popout()') end
	local function callback()
		--self:updateFuuuTargetShow(true)
		self:popoutFinishCallback()

		if EndGamePropManager.getInstance():getItemNum(self.propId) <= 0 then
  			RealNameManager:addConsumptionLabelToPanel(self, true)
  		end

	end
	self.panelPopRemoveAnim:popout(callback, true)
	
end

function EndGamePropBasePanel:removePopout()	
	--这个方法在PayPanelRePay里调用 对于加五步面板 不可以直接关闭 隐藏即可
	local container = self:getParent() and self:getParent():getParent()
	if container then
		container:setVisible(false)
	else
		self.ui:setVisible(false)
	end
end

function EndGamePropBasePanel:remove(animFinishCallback)
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	FreeFCashPanel:hideWithOwnerCheck(self)
	self.panelPopRemoveAnim:remove(animFinishCallback)
	--self:updateFuuuTargetShow(false)
end

function EndGamePropBasePanel:updateFuuuTargetShow(show)
	--[[
	-- if not MaintenanceManager:getInstance():isEnabled("IosFuuuAdd5Step") then return end
	if EndGamePropABCTest.getInstance():getFuuuShow(self.lastGameIsFUUU) then 
		local scene = Director:sharedDirector():getRunningScene()
		if scene.reorderTargetPanel and type(scene.reorderTargetPanel) == "function" then 
			scene:reorderTargetPanel(show)
		end
	end
	]]
end

function EndGamePropBasePanel:dcPanelShow()
	-- AddFiveStepABCTestLogic:dcLog("pop_add_5_steps", levelId, panel.actSource, propId)
	-- EndGamePropABCTest.getInstance():dcLog("alert_add_5_steps", levelId, panel.actSource, propId, isFUUU)
	DcUtil:endGameForActivity("5_steps_open", self.levelId, self.actSource, self.panelType)
	SeasonWeeklyRaceManager:dcForEndGameProp("weeklyrace_winter_5steps_open", self.levelId, self.levelType, self.actSource)
end

function EndGamePropBasePanel:dcUseBtnClick()
	-- AddFiveStepABCTestLogic:dcLog("click_add_5_steps" , self.levelId , self.actSource , self.propId)
	DcUtil:endGameForActivity("5_steps_use", self.levelId, self.actSource, self.panelType)
	EndGamePropABCTest.getInstance():dcLog("purchase_add_5_steps", self.levelId, self.actSource, self.propId, self.lastGameIsFUUU)
	SeasonWeeklyRaceManager:dcForEndGameProp("weeklyrace_winter_5steps_click", self.levelId, self.levelType, self.actSource)
end

function EndGamePropBasePanel:dcUseSuccess()
	-- AddFiveStepABCTestLogic:dcLog("buy_add_5_steps_success" , self.levelId , self.actSource , self.propId)
	DcUtil:endGameForActivity("5_steps_use_success", self.levelId, self.actSource, self.panelType)
	EndGamePropABCTest.getInstance():dcLog("purchase_add_5_steps_success", self.levelId, self.actSource, self.propId, self.lastGameIsFUUU)
	SeasonWeeklyRaceManager:dcForEndGameProp("weeklyrace_winter_5steps_success", self.levelId, self.levelType, self.actSource)
end

function EndGamePropBasePanel:dcBuyBtnTap()
	-- AddFiveStepABCTestLogic:dcLog("click_add_5_steps" , self.levelId , self.actSource , self.propId)
	DcUtil:endGameForActivity("5_steps_buy", self.levelId, self.actSource, self.panelType)
	EndGamePropABCTest.getInstance():dcLog("purchase_add_5_steps", self.levelId, self.actSource, self.propId, self.lastGameIsFUUU)
	SeasonWeeklyRaceManager:dcForEndGameProp("weeklyrace_winter_5steps_click", self.levelId, self.levelType, self.actSource)
end

function EndGamePropBasePanel:dcBuySuccess()
	-- AddFiveStepABCTestLogic:dcLog("buy_add_5_steps_success", self.levelId, self.actSource, self.propId)
	DcUtil:endGameForActivity("5_steps_buy_success", self.levelId, self.actSource, self.panelType)
	EndGamePropABCTest.getInstance():dcLog("purchase_add_5_steps_success", self.levelId, self.actSource, self.propId, self.lastGameIsFUUU)
	SeasonWeeklyRaceManager:dcForEndGameProp("weeklyrace_winter_5steps_success", self.levelId, self.levelType, self.actSource)
end