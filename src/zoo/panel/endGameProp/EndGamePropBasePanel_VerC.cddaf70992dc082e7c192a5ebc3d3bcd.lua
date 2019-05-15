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

local LotteryLogic = require 'zoo.panel.endGameProp.lottery.LotteryLogic'
local BuyAddTwoStepLogic = require 'zoo.panel.endGameProp.lottery.BuyAddTwoStepLogic'
local TradeUtils = require 'zoo.panel.endGameProp.lottery.TradeUtils'




local UIHelper = require 'zoo.panel.UIHelper'
local AnimationPlayer = require 'zoo.panel.endGameProp.anim.AnimationPlayer'
local PropertyTrack = require 'zoo.panel.endGameProp.anim.PropertyTrack'
local FuncTrack = require 'zoo.panel.endGameProp.anim.FuncTrack'

local EndGamePropTipFactory = require 'zoo.panel.endGameProp.EndGamePropTipFactory'
local EndGamePropGoodsPlate = require 'zoo.panel.endGameProp.EndGamePropGoodsPlate'

local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'

local RES_ARROW_BG =  "ui/temp/black_radial.json"

local validLevelType = {
	GameLevelType.kMainLevel, 
	GameLevelType.kHiddenLevel,
    GameLevelType.kSpring2019,
	-- GameLevelType.kFourYears,
}

EndGamePropBasePanel_VerC = class(BasePanel)

function EndGamePropBasePanel_VerC:ctor()
	self.showFuuuTipMode = false
end

function EndGamePropBasePanel_VerC:create( ... )
	-- body
	local panel = EndGamePropBasePanel_VerC.new()
	panel.propId = ItemType.ADD_FIVE_STEP
	panel:loadRequiredResource('ui/panel_add_step.json')
	panel:init()
	return panel
end

function EndGamePropBasePanel_VerC:onBuyBtnTapped()
	if self.isDisposed then return end
	self.buyButton:setEnabled(false)
	self:stopCountdown()
end

function EndGamePropBasePanel_VerC:getAliQuickLabel()
	if self.isDisposed then return end
	return self.ui:getChildByPath('funnyAnimLayer/labelAliQuickPay')
end

function EndGamePropBasePanel_VerC:onBuySuccess()
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

		self.dc_result = 'buy'
		self:remove(false)
	end

	self.onEnterForeGroundCallback = nil
	self:stopAllActions()
		
	local button = HomeScene:sharedInstance().goldButton
	if button then button:updateView() end

	self:useAfterBuy(useAddStepSuccess)
end

function EndGamePropBasePanel_VerC:resumeTimer()
	if self.isDisposed then return end
	local function onCountDown() self:countdownCallback() end
	if AddFiveStepABCTestLogic:needShowCountdown() then
		self:startCountdown(onCountDown)
	end
	if type(self.updateGoldNum) == "function" then
		self:updateGoldNum()
	end
	if self.buyButton then
		self.buyButton:setEnabled(true)
	end

	self:updatePackDiscountPlate()
end

function EndGamePropBasePanel_VerC:addPropUseAnimation(pos, onAnimFinishedCallback )
	if EndGamePropManager.getInstance():isAddTimeProp(self.propId) then 
		local icon = ResourceManager:sharedInstance():buildItemSprite(self.propId)
		local scene = Director:sharedDirector():getRunningScene()
		local animation = PrefixPropAnimation:createAddTimeAnimation(icon, 0, onAnimFinishedCallback, nil, ccp(pos.x, pos.y + 90))
		scene:addChild(animation)
	end
end

function EndGamePropBasePanel_VerC:startCountdown(callback)
	if self.isDisposed then return end
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


function EndGamePropBasePanel_VerC:countdownCallback()
	if self.isDisposed then return end
	if self.second == 0 then
		self.countdownLabel:stopAllActions()
		self:onCountdownComplete(true)
	else
		self:setCountdownSceond(self.second)
	end
end


function EndGamePropBasePanel_VerC:setCountdownSceond(second)
	if self.isDisposed then return end
	self.secondToCountdown = second
	self.countdownLabel:setText(tostring(second))
end

function EndGamePropBasePanel_VerC:onBuyFail(errorCode, errorMsg)
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

function EndGamePropBasePanel_VerC:onBuyCancel()
	if self.isDisposed then return end
	self.onEnterForeGroundCallback = nil
	self:stopAllActions()
	self:resumeTimer()
end



function EndGamePropBasePanel_VerC:stopCountdown()
	if self.isDisposed then return end
	self.countdownLabel:stopAllActions()
end


function EndGamePropBasePanel_VerC:useAfterBuy(useSucFunc, useFailFunc)
	self:useProp(self.propId, useSucFunc, useFailFunc)
end

function EndGamePropBasePanel_VerC:useProp(propId, useSucFunc, useFailFunc)
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


function EndGamePropBasePanel_VerC:remove(animFinishCallback)
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	FreeFCashPanel:hideWithOwnerCheck(self)
	--self:updateFuuuTargetShow(false)

	setTimeOut(function ( ... )
		if self.isDisposed then return end

		PopoutManager:sharedInstance():remove(self)
		Notify:dispatch('CloseGiftPackEndgamePanelEvent')
		
		if animFinishCallback then animFinishCallback() end
		
		self:dcAddStep()

	end, 0.1)

	
end

function EndGamePropBasePanel_VerC:dcAddStep( ... )
	if self.tipData then
		local dcInfo = {}
		for index, v in ipairs(self.tipData) do
			if index < self.tipIndex then
				table.insert(dcInfo, tostring(v.type))
			else
				table.insert(dcInfo, tostring(0))
			end
		end
		local other = table.concat(dcInfo, '_')
		-- DcUtil:UserTrack({category='ui', sub_category='add_five_step', other = other, result = self.dc_result})
	end
end



function EndGamePropBasePanel_VerC:initArrowBtn()
	local isOK = MaintenanceManager:getInstance():isEnabledInGroup('add5', 'fold', UserManager:getInstance().uid)
	if not isOK and not __WIN32 then
		return
	end

	local vSize = Director:sharedDirector():ori_getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()

	local cx = 400
	-- --棋盘和藤蔓中间的空白
	-- local ty = -((vSize.height-550)*0.3+20) - self:getPositionY()

	--任务按钮上方
	local ty = 180

    local anim = gAnimatedObject:createWithFilename('gaf/two_arrow_up/arrow_up_motion.gaf')
    anim:setPosition(ccp(cx, ty))
    anim:setScale(1.7)
    anim:setLooped(true)
    anim:start()
    self:addChildAt(anim,-1)
    self.animArrow = anim

    local function doFold(event)
    	local isFold = not self.isFold
    	if not self.ui.baseY then
	    	self.ui.baseY = self.ui:getPositionY()
			UIHelper:setCascadeOpacityEnabled(self.ui)

			self.animalLayer.baseScale = self.animalLayer:getScale()

			local pos = self:getPosition()

		    local builder = InterfaceBuilder:createWithContentsOfFile(RES_ARROW_BG)
		    local ui = builder:buildGroup('blackRadial/black_radial')
		    self:addChildAt(ui,-2)
		    local size = ui:getGroupBounds().size
		    local sw = vSize.width/size.width*1.1
		    local sh = vSize.height/size.height*1.15
		    local tw = sw * size.width
		    local th = sh * size.height
		    ui:setScaleX(sw)
		    ui:setScaleY(sh)
		    ui:setPosition(ccp((-pos.x-(tw-vSize.width)*0.5)/self.panelScale,(-pos.y+(th-vSize.height)*0.5)/self.panelScale+vOrigin.y))
		    self.backBg = ui

		    self.backBg.top = ui:getChildByName("top")
		    self.backBg.btm = ui:getChildByName("btm")
		    self.backBg.top:setOpacity(0)
		    self.backBg.btm:setOpacity(0)

		    self.backBlack:ad(DisplayEvents.kTouchBegin, function(event)
		        self.doFold()
		    end)
	    end

    	self.isFold = isFold
    	self.animArrow:setRotation(isFold and 180 or 0)

    	local time = 0.3

    	-- self.ui:stopAllActions()
    	-- self.ui:runAction(CCSpawn:createWithTwoActions(
    	-- 	CCMoveTo:create(time,ccp(0,isFold and self.ui.baseY+300 or self.ui.baseY)),
    	-- 	CCFadeTo:create(time,isFold and 0 or 255)
    	-- 	))

    	local th = vSize.height/self.panelScale
    	self.ui:stopAllActions()
    	self.ui:runAction(CCMoveTo:create(time,ccp(0,isFold and self.ui.baseY+th or self.ui.baseY)))

    	if GiftPack and GiftPack.endgamePanel then
    		if not GiftPack.endgamePanel.baseY then
	    		GiftPack.endgamePanel.baseX = GiftPack.endgamePanel:getPositionX()
	    		GiftPack.endgamePanel.baseY = GiftPack.endgamePanel:getPositionY()
	    	end
	    	GiftPack.endgamePanel:stopAllActions()
	    	GiftPack.endgamePanel:runAction(CCMoveTo:create(time,ccp(GiftPack.endgamePanel.baseX,isFold and GiftPack.endgamePanel.baseY+th or GiftPack.endgamePanel.baseY)))
	    end

    	-- self.backBg:stopAllActions()
    	-- self.backBg:runAction(CCFadeTo:create(time,isFold and 150 or 0))

    	local opt = isFold and 255 or 0
    	self.backBg.top:runAction(CCFadeTo:create(time,opt))
    	self.backBg.btm:runAction(CCFadeTo:create(time,opt))
    	
    	local opt = isFold and 90 or 150
    	self.backBlack:runAction(CCFadeTo:create(time,opt))

    	if isFold then
		    self.backBlack:setTouchEnabled(true, 0, true)
		    DcUtil:UserTrack({
				game_type='stage', 
				game_name='add_fs_hide', 
				category='click', 
				sub_category='up_click'
			})
    	else
		    self.backBlack:setTouchEnabled(false)
    		self.animalLayer:setVisible(true)

    		DcUtil:UserTrack({
				game_type='stage', 
				game_name='add_fs_hide', 
				category='click', 
				sub_category='down_click'
			})
    	end

  --   	self.animalLayer:stopAllActions()
  --   	self.animalLayer:runAction(CCSequence:createWithTwoActions(
  --   		CCScaleTo:create(time*0.8,isFold and 0.1 or self.animalLayer.baseScale),
  --   		CCCallFunc:create(function() self.animalLayer:setVisible(not isFold) end)
  --   		))

  --   	--button无法覆盖到按钮背景，背景单独处理
		-- local list = {"buyButtonUI","useButtonUI","lotteryBtnUI"}
		-- for i,v in ipairs(list) do
		-- 	for ii,vv in ipairs(self[v].list) do
		-- 		vv:stopAllActions()
		-- 		vv:runAction(CCFadeTo:create(time,isFold and 0 or 255))
		-- 	end
		-- end
		-- if self.packDiscountPlate then
		-- 	local list = {"cashBuyButton","hpCoinBuyButton"}
		-- 	for i,v in ipairs(list) do
		-- 		local node = self.packDiscountPlate:getChildByName(v)
		-- 		for ii,vv in ipairs(node.list) do
		-- 			vv:stopAllActions()
		-- 			vv:runAction(CCFadeTo:create(time,isFold and 0 or 255))
		-- 		end
		-- 	end
		-- end
    end

    self.doFold = doFold

    local btnW = 100
    local btnArrow = LayerColor:create()
    -- btnArrow:setAnchorPoint(ccp(0.5,0.5))
    btnArrow:setColor(ccc3(200, 20, 0))
    btnArrow:setOpacity(00)
    btnArrow:setContentSize(CCSizeMake(btnW, 100))
    btnArrow:setPosition(ccp(cx-btnW*0.5,ty-45))
    btnArrow:setTouchEnabled(true, 0, true)
    btnArrow:ad(DisplayEvents.kTouchBegin, doFold)
    self:addChildAt(btnArrow,-1)
    self.btnArrow = btnArrow
end

function EndGamePropBasePanel_VerC:init()

	UIHelper:loadArmature('skeleton/add_five_step_florid')
	self.tipData = EndGamePropTipFactory:getData(self)
	self.tipIndex = 1

	local groupName = self:getUIGroupName()

	self.ui = UIHelper:replaceLayer2LayerColor( self:buildInterfaceGroup( groupName ) )

	UIHelper:setCascadeOpacityEnabled(self.ui)
	BasePanel.init(self, self.ui)

	self:preProcessFunnyNodes()
	self.closeBtn = self.ui:getChildByName("closeBtn")

	self.countdownLabel = self.ui:getChildByName("countdownLabel")
	self.countdownLabel:setScale(1.3)
	self.countdownLabel:setAnchorPoint(ccp(0.5, 0.5))
	self.countdownLabel:setPositionY(self.countdownLabel:getPositionY() - 45)

	self.ui:getChildByName('labelPh'):setVisible(false)
	-- local isOpen = MaintenanceManager:getInstance():isEnabledInGroup('buyAdd5', 'newUI', UserManager:getInstance().uid)
	-- if isOpen then
		self.buyButtonUI = self.ui:getChildByPath("funnyAnimLayer/buyBtn")
		self.ui:getChildByName("buyBtnB"):setVisible(false)
	-- else
	-- 	self.buyButtonUI = self.ui:getChildByName("buyBtnB")
	-- 	self.ui:getChildByPath("funnyAnimLayer/buyBtn"):setVisible(false)
	-- end
	-- assert(self.buyButtonUI,"isOpen:"..tostring(isOpen))

	self.useButtonUI = self.ui:getChildByPath("funnyAnimLayer/useBtn")
	self.lotteryBtnUI = self.ui:getChildByPath('funnyAnimLayer/lotteryBtn')
	self.newLotteryBtnUI = self.ui:getChildByPath('funnyAnimLayer/newLotteryBtn')

	self.buy2StepBtnUI = self.ui:getChildByPath('funnyAnimLayer/buy_2_step')
	
	self.moneyBar = self.ui:getChildByPath("funnyAnimLayer/moneyBar")
	self.moneyBar:setVisible(false)

	self.ios_ali_link = self.ui:getChildByPath('funnyAnimLayer/ios_ali_link')
	self.ios_ali_link:setVisible(false)

	self.useTipLabel = self.ui:getChildByPath("funnyAnimLayer/use_tip")
	self.useTipLabel:setVisible(false)

	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, preventContinuousClick(function ()
		if self.isDisposed then return end
		self:onCloseBtnTapped()
	end, 0.2))
	self.closeBtn:setButtonMode(true)
	self.closeBtn:setTouchEnabled(true)

	local propNum = EndGamePropManager.getInstance():getItemNum(self.propId)
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

		-- local isOpen = MaintenanceManager:getInstance():isEnabledInGroup('buyAdd5', 'newUI', UserManager:getInstance().uid)
		-- if isOpen then
	        self.buyButton:setString(Localization:getInstance():getText("add.step.panel.use.btn.txt"))
	-- 	else

	--         if self.levelType == GameLevelType.kJamSperadLevel then

	--             --按尾号显示内容
	--             local my_uid = tonumber(UserManager:getInstance().user.uid or '12345')
	-- 	        if not my_uid then my_uid = 0 end
	-- 	        my_uid = my_uid % 10000 -- 保留后4位

	--             local IDIsFirst = false
	-- --            if my_uid >=0 and my_uid <= 4999 then
	-- --                --购买
	-- --                self.buyButton:setString(Localization:getInstance():getText("add.step.panel.buy.btn.txt"))
	-- --            else
	--                 --继续
	--                 self.buyButton:setString(Localization:getInstance():getText("add.step.panel.use.btn.txt"))
	-- --            end
	--         else
	-- 		    self.buyButton:setString(Localization:getInstance():getText("add.step.panel.buy.btn.txt"))
	--         end

	--     end

		self.buyButton:addEventListener(DisplayEvents.kTouchTap, function ()
			self:onBuyBtnTapped()
		end)
		self.useButtonUI:setVisible(false)
		propNeedBuy = true
		AddFiveStepABCTestLogic:setPropNeedBuy(true)
		self.buyButton.groupNode:stopAllActions()
		self.countdownLabel:setPositionX(521)

	end


	self.buy2StepMode = self:calcBuy2StepMode()

	if self.buy2StepMode then
		if self.buy2StepBtnUI then
			self.buy2StepBtnUI:setVisible(true)
			self.buy2StepBtn = EndGameBuyButton:create(self.buy2StepBtnUI, ItemType.ADD_2_STEP)			
			self.buy2StepBtn:useBubbleAnimation()
			self.buy2StepBtn:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
				if self.isDisposed then return end
				self:onTapBuy2StepBtn()
			end))

			self:refreshBuy2StepBtn()

		end

		local t1
		local t2

		local canBuy, becauseUsedAdd2Step = BuyAddTwoStepLogic:canBuy()
		if canBuy then
			t1 = 1
		else
			t1 = 2
			if becauseUsedAdd2Step then
				t2 = 1
			else
				t2 = 2
			end 
		end

		DcUtil:activity({
			game_type = 'stage',
			game_name = 'fs_add_two_steps',
			category = 'canyu',
			sub_category = 'view',
			playId = GamePlayContext:getInstance():getIdStr(),
			t1 = t1,
			t2 = t2,
		})

	else
		if self.buy2StepBtnUI then
			self.buy2StepBtnUI:setVisible(false)
		end
	end


	LotteryLogic:setLotteryTime(Localhost:time())

	self.lotteryMode = self:calcLotteryMode()

	if self.lotteryMode then

		if self.lotteryMode == LotteryLogic.MODE.kNEW then
			if self.lotteryBtnUI then
				self.lotteryBtnUI:setVisible(false)
			end

			if self.newLotteryBtnUI then
				self.lotteryBtn = ButtonIconNumberBase:createNewStyle(self.newLotteryBtnUI, ButtonStyleType.TypeABA)
				self.lotteryBtn._offsetFlag = true
				local params = self.lotteryBtn:getLayoutParams()
				params.textMargin = 0
				params.imageMargin = 0

				UIHelper:move(self.newLotteryBtnUI:getChildByPath('flag-1'), 20, 0)
				UIHelper:move(self.newLotteryBtnUI:getChildByPath('flag-3'), 20, 0)

				self.lotteryBtn:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
					if self.isDisposed then return end
					self:onLotteryBtnTapped()
				end))
				self.lotteryBtn:useBubbleAnimation()


				local lotteryIcon = UIHelper:createArmature2('skeleton/add_five_step_florid', 'florid.add.5/ZP')
				local lotteryIconHolder = self.newLotteryBtnUI:getChildByPath('flag-2')
				lotteryIconHolder:setVisible(false)
				local bounds = lotteryIconHolder:getGroupBounds(self.newLotteryBtnUI)
				local pos = ccp(bounds:getMidX(), bounds:getMidY())
				self.newLotteryBtnUI:addChild(lotteryIcon)
				lotteryIcon:setPosition(ccp(pos.x- 20, pos.y + 6))
				self.lotteryIcon = lotteryIcon


				self.add2stepIcon = ResourceManager:sharedInstance():buildItemSprite(ItemType.ADD_2_STEP)
				self.add1stepIcon = ResourceManager:sharedInstance():buildItemSprite(ItemType.ADD_1_STEP)
				self.add1stepIcon:setAnchorPoint(ccp(0.5, 0.5))
				self.add2stepIcon:setAnchorPoint(ccp(0.5, 0.5))

				self.add2stepIcon:setScale(0.95)
				self.add1stepIcon:setScale(0.95)

				self.newLotteryBtnUI:addChild(self.add2stepIcon)
				self.newLotteryBtnUI:addChild(self.add1stepIcon)

				self.add2stepIcon:setPosition(ccp(pos.x, pos.y))
				self.add1stepIcon:setPosition(ccp(pos.x, pos.y))

				self:refreshLotteryBtn()

			end

		else

			if self.newLotteryBtnUI then
				self.newLotteryBtnUI:setVisible(false)
			end
			if self.lotteryBtnUI then
				self.lotteryBtn = 	GroupButtonBase:create(self.lotteryBtnUI)
				self.lotteryBtn:useBubbleAnimation()
				self.lotteryBtn:ad(DisplayEvents.kTouchTap, function ( ... )
					if self.isDisposed then return end
					self:onLotteryBtnTapped()
				end)

				local dot = getRedNumTip()
				local defalutScale = 1/0.6
				defalutScale = defalutScale * ( 0.7/0.9) 
				dot:setScale( defalutScale )
				dot:setPosition(ccp(345, 52))
				self.lotteryBtnUI:addChild(dot)
				self.lotteryBtnDot = dot

				self:refreshLotteryBtn()
			end
		end
	else
		if self.lotteryBtnUI then
			self.lotteryBtnUI:setVisible(false)
		end

		if self.newLotteryBtnUI then
			self.newLotteryBtnUI:setVisible(false)
		end
	end

	require('zoo.panel.endGameProp.lottery.BuyDiamondObserver'):addObserver(self)
    require('zoo.panel.endGameProp.lottery.CashObserver'):addObserver(self)

    for _, v in ipairs{
    	-- 'msgLabelph',
    	-- 'msgIcon_1',
    	-- 'msgIcon_2',
    	-- 'msgLabel_new1',
    	-- 'msgLabel_new2',
    	-- 'msgLabel',
    	-- '_bubble',
    	-- 'prebuff',
    } do
    	self.ui:getChildByPath(v):setVisible(false)
   	end

	if not propNeedBuy then 
		self:updateCountdownShow()
	end

	-- self:onCountdownComplete()

	-- local isOpen = MaintenanceManager:getInstance():isEnabledInGroup('buyAdd5', 'newUI', UserManager:getInstance().uid)

	if self.propId == ItemType.ADD_FIVE_STEP then
		local str = ""
		if propNeedBuy then
			-- 购买+5
			local key = "add.step.panel.five.steps.tip.buy"
			str = Localization:getInstance():getText(key)
			if str == key then
				str = "购买加5步继续游戏"
			end
		else
			-- 使用+5
			local key = "add.step.panel.five.steps.tip.use"
			str = Localization:getInstance():getText(key)
			if str == key then
				str = "使用加5步继续游戏"
			end
		end
		self:getAliQuickLabel():setString(str)

	end

	--if callback then callback() end  
	local logic = GameBoardLogic:getCurrentLogic()
	local forbid = logic and logic.hasDropDownUFO
	forbid = forbid or logic.gameMode:is(ClassicMode)

	local hasdoneone = false
	if not forbid and GiftPack and not self.isClone then
		local function onclose(has5step)
			if has5step then
				PopoutManager:sharedInstance():remove(self)
				self:clone()
			end
		end

		require 'zoo.localActivity.Double112018.DoubleOneOneModel'
		hasdoneone = DoubleOneOneModel:tryCreateEndgamePanel(onclose, self)
		if not hasdoneone then
			GiftPack.currentlevel = self.levelId
			GiftPack:onAddFivePanelShow(self, onclose)
		end
	end

	if not hasdoneone then
		-- 是否有 +5 礼包的显示
		-- printx(11, "===== checkCanShowPackDiscountPlate =====")
		if self:checkCanShowPackDiscountPlate() and self.goodsPackID > 0 then
			self:checkCreatePackDiscountPlate()
		end
	end

	return propNeedBuy
end

local function PositionXSetter( context, PositionX )
	if (not context) or context.isDisposed then return end
	context:setPositionX(PositionX)
end

local function PositionYSetter( context, PositionY )
	if (not context) or context.isDisposed then return end
	context:setPositionY(PositionY)
end

local function OpacitySetter( context, Opacity )
	if (not context) or context.isDisposed then return end
	context:setOpacity(Opacity)
end

local function ScaleSetter( context, Scale )
	if (not context) or context.isDisposed then return end
	context:setScale(Scale)
end

local function ScaleXSetter( context, ScaleX )
	if (not context) or context.isDisposed then return end
	context:setScaleX(ScaleX)
end

local function ScaleYSetter( context, ScaleY )
	if (not context) or context.isDisposed then return end
	context:setScaleY(ScaleY)
end

function EndGamePropBasePanel_VerC:createAnimPlayer(state)
	if self.isDisposed then return end
		
	if self.animPlayer then
		self.animPlayer:removeFromParentAndCleanup(true)
	end

	-- 'use_tip',
	-- 	'lotteryBtn',
	-- 	'buyBtn',
	-- 	-- 'buyBtn/background',
	-- 	'useBtn',
	-- 	-- 'useBtn/background',
	-- 	'labelAliQuickPay',
	-- 	'lotteryBtn',
	-- 	-- 'lotteryBtn/background',
	-- 	'moneyBar',
	-- 	'ios_ali_link',


	self.animPlayer = AnimationPlayer:create()
	self.animPlayer:setTarget(self.ui)
	self:addChild(self.animPlayer)

	if state == 1 then

		self:createAnimalAnim(1)
		self:createBubbleAnim(1)

		UIHelper:centerAnchor(self.animPlayer:getTarget():getChildByPath('blackBg'))

		--背景层
		local bgScaleY = self.animPlayer:getTarget():getChildByPath('blackBg'):getScaleY()
		local bgYTrack = PropertyTrack.new()
		bgYTrack:setName('bgYTrack')
		bgYTrack:setPropertyAccessor(nil, ScaleYSetter)
		bgYTrack:setTargetPath('blackBg')
		bgYTrack:setFrameDataConfig({
			{index = 3, data = 0.359985 * bgScaleY},
			{index = 7, data = 1.099976 * bgScaleY},
			{index = 10, data = 1 * bgScaleY},
		})
		self.animPlayer:addTrack(bgYTrack)

		local bgScaleX = self.animPlayer:getTarget():getChildByPath('blackBg'):getScaleX()
		local bgXTrack = PropertyTrack.new()
		bgXTrack:setName('bgXTrack')
		bgXTrack:setPropertyAccessor(nil, ScaleXSetter)
		bgXTrack:setTargetPath('blackBg')
		bgXTrack:setFrameDataConfig({
			{index = 3, data = 0.359985 * bgScaleX},
			{index = 7, data = 1.099976 * bgScaleX},
			{index = 10, data = 1 * bgScaleX},
		})
		self.animPlayer:addTrack(bgXTrack)

		local bgOpacityTrack = PropertyTrack.new()
		bgOpacityTrack:setName('bgOpacityTrack')
		bgOpacityTrack:setPropertyAccessor(nil, OpacitySetter)
		bgOpacityTrack:setTargetPath('..')
		bgOpacityTrack:setFrameDataConfig({
			{index = 0, data = 0},
			{index = 3, data = 0},
			{index = 7, data = 255},
		})
		self.animPlayer:addTrack(bgOpacityTrack)



		--关闭按钮
		local closeBtnScaleTrack = PropertyTrack.new()
		closeBtnScaleTrack:setName('closeBtnScaleTrack')
		closeBtnScaleTrack:setPropertyAccessor(nil, ScaleSetter)
		closeBtnScaleTrack:setTargetPath('closeBtn')
		closeBtnScaleTrack:setFrameDataConfig({
			{index = 3, data = 0.359985},
			{index = 7, data = 1.099976},
			{index = 10, data = 1},
		})
		self.animPlayer:addTrack(closeBtnScaleTrack)

		local closeBtnOpacityTrack = PropertyTrack.new()
		closeBtnOpacityTrack:setName('closeBtnOpacityTrack')
		closeBtnOpacityTrack:setPropertyAccessor(nil, OpacitySetter)
		closeBtnOpacityTrack:setTargetPath('closeBtn')
		closeBtnOpacityTrack:setFrameDataConfig({
			{index = 0, data = 0},
			{index = 3, data = 0},
			{index = 7, data = 255},
		})
		self.animPlayer:addTrack(closeBtnOpacityTrack)


		--右下角按钮组
		UIHelper:setCascadeOpacityEnabled(self.ui:getChildByPath('funnyAnimLayer'))

		local funnyOpacityTrack = PropertyTrack.new()
		funnyOpacityTrack:setName('funnyOpacityTrack')
		funnyOpacityTrack:setTargetPath('funnyAnimLayer')
		funnyOpacityTrack:setPropertyAccessor(nil, OpacitySetter)

		funnyOpacityTrack:setFrameDataConfig({
			{index = 0, data = 0},
			{index = 3, data = 0},
			{index = 7, data = 255},
		})
		self.animPlayer:addTrack(funnyOpacityTrack)

		local funnyPosXTrack = PropertyTrack.new()
		funnyPosXTrack:setName('funnyPosXTrack')
		funnyPosXTrack:setTargetPath('funnyAnimLayer')
		funnyPosXTrack:setPropertyAccessor(nil, PositionXSetter)
		local posX = self.ui:getChildByPath('funnyAnimLayer'):getPositionX()
		funnyPosXTrack:setFrameDataConfig({
			{index = 5, data = posX + 347.4 - 326.15},
			{index = 9, data = posX + 322.8 - 326.15},
			{index = 12, data = posX + 343.5 - 326.15},
			{index = 15, data = posX},
		})
		self.animPlayer:addTrack(funnyPosXTrack)

		local funnyPosYTrack = PropertyTrack.new()
		funnyPosYTrack:setName('funnyPosYTrack')
		funnyPosYTrack:setTargetPath('funnyAnimLayer')
		funnyPosYTrack:setPropertyAccessor(nil, PositionYSetter)
		local posY = self.ui:getChildByPath('funnyAnimLayer'):getPositionY()
		funnyPosYTrack:setFrameDataConfig({
			{index = 5, data = posY - 619.4 + 587.4},
			{index = 9, data = posY - 582.45 + 587.4},
			{index = 12, data = posY - 590.45 + 587.4},
			{index = 15, data = posY},
		})
		self.animPlayer:addTrack(funnyPosYTrack)

		local funnyScaleTrack = PropertyTrack.new()
		funnyScaleTrack:setName('funnyScaleTrack')
		funnyScaleTrack:setTargetPath('funnyAnimLayer')
		funnyScaleTrack:setPropertyAccessor(nil, ScaleSetter)
		funnyScaleTrack:setFrameDataConfig({
			{index = 5, data = 0.36},
			{index = 9, data = 1.1},
			{index = 12, data = 0.9},
			{index = 15, data = 1},
		})
		self.animPlayer:addTrack(funnyScaleTrack)


		--小动物
		local animalAScaleTrack = PropertyTrack.new()
		animalAScaleTrack:setName('animalAScaleTrack')
		animalAScaleTrack:setTargetPath('animalLayer')
		animalAScaleTrack:setPropertyAccessor(nil, ScaleSetter)
		animalAScaleTrack:setFrameDataConfig({
			{index = 0, data = 0.39},
			{index = 5, data = 0.39},
			{index = 9, data = 1.19},
			{index = 12, data = 0.975},
			{index = 15, data = 1.084},
		})
		self.animPlayer:addTrack(animalAScaleTrack)

		local animalAOpacityTrack = PropertyTrack.new()
		animalAOpacityTrack:setName('animalAOpacityTrack')
		animalAOpacityTrack:setTargetPath('animalLayer')
		animalAOpacityTrack:setPropertyAccessor(nil, OpacitySetter)
		animalAOpacityTrack:setFrameDataConfig({
			{index = 0, data = 0},
			{index = 5, data = 0},
			{index = 9, data = 255},
		})
		self.animPlayer:addTrack(animalAOpacityTrack)


		--气泡
		local bubbleAOpacityTrack = PropertyTrack.new()
		bubbleAOpacityTrack:setName('bubbleAOpacityTrack')
		bubbleAOpacityTrack:setTargetPath('bubbleLayer')
		bubbleAOpacityTrack:setPropertyAccessor(nil, OpacitySetter)
		bubbleAOpacityTrack:setFrameDataConfig({
			{index = 0, data = 0},
			{index = 14, data = 0},
			{index = 20, data = 255},
		})
		self.animPlayer:addTrack(bubbleAOpacityTrack)

		local bubbleAFuncTrack = FuncTrack.new()
		bubbleAFuncTrack:setName('bubbleAFuncTrack')
		bubbleAFuncTrack:setTargetPath('bubbleLayer')
		bubbleAFuncTrack:setFrameDataConfig({
			{index = 14, data = function ( ctx )
				ctx.bubble:playByIndex(0)
			end},
		})
		self.animPlayer:addTrack(bubbleAFuncTrack)

		local animalAFuncTrack = FuncTrack.new()
		animalAFuncTrack:setName('animalAFuncTrack')
		animalAFuncTrack:setTargetPath('animalLayer')
		animalAFuncTrack:setFrameDataConfig({
			{index = 5, data = function ( ctx )
				if (not ctx) or ctx.isDisposed then return end
				if (not ctx.anim) or ctx.anim.isDisposed then return end
				ctx.anim:resume(0)
			end},
		})
		self.animPlayer:addTrack(animalAFuncTrack)

		local animFinishTrack = FuncTrack.new()
		animFinishTrack:setName('animFinishTrack')
		animFinishTrack:setTargetPath('animalLayer')
		animFinishTrack:setFrameDataConfig({
			{index = 26, data = function ( ctx )
				self.animPlaying = false
				self:popoutFinishCallback()
			end},
			{index = 50, data = function ( ... )
				if self.isDisposed then return end

				

			end}
		})
		self.animPlayer:addTrack(animFinishTrack)


	elseif state == 2 then

		local startIndex = 81

		self:createBubbleAnim(2)
		self.tipIndex = self.tipIndex + 1


		local animalBFuncTrack = FuncTrack.new()
		animalBFuncTrack:setName('animalBFuncTrack')
		animalBFuncTrack:setTargetPath('.')
		animalBFuncTrack:setFrameDataConfig({
			{index = 0, data = function ( ... )
				if self.isDisposed then return end
				if (not self.bubbleLayer) or (not self.bubbleLayer.bubble) then return end
				if self.bubbleLayer.bubble.isDisposed then return end
				self.bubbleLayer.bubble:playByIndex(0)
			end},
			{index = 82 - startIndex, data = function ( ctx )
				if self.isDisposed then return end
				self:createAnimalAnim(2)

				if (not self.animalLayer) or (not self.animalLayer.anim) then return end
				if self.animalLayer.anim.isDisposed then return end

				self.animalLayer.anim:resume(0)
			end},
			{index = 110 - startIndex, data = function ( ctx )
				if self.isDisposed then return end
				self:createBubbleAnim(3, self.tipIndex - 1)
				self.bubbleLayer.bubble:playByIndex(0, 0)
				-- for _, v in ipairs(self.iconAnims or {}) do
				-- 	v:setVisible(false)
				-- end
			end},
			{index = 115 - startIndex, data = function ( ctx )
				if self.isDisposed then return end
				-- for _, v in ipairs(self.iconAnims or {}) do
				-- 	if v.isDisposed then return end
				-- 	v:setVisible(true)
				-- 	v:playByIndex(0)
				-- end
			end},
			{index = 102 - startIndex, data = function ( ctx )
				if self.isDisposed then return end
				self:createAnimalAnim(3)

				if (not self.animalLayer) or (not self.animalLayer.anim) then return end
				if self.animalLayer.anim.isDisposed then return end

				self.animalLayer.anim:resume(0, 0)
			end}
		})
		self.animPlayer:addTrack(animalBFuncTrack)

		local animFinishTrack = FuncTrack.new()
		animFinishTrack:setName('animFinishTrack')
		animFinishTrack:setTargetPath('animalLayer')
		animFinishTrack:setFrameDataConfig({
			{index = 82 - startIndex, data = function ( ctx )
				self.animPlaying = false
			end},
		})
		self.animPlayer:addTrack(animFinishTrack)
	end

end

function EndGamePropBasePanel_VerC:getFunnyNodes( ... )
	local funnyGroupNodes = {
		'use_tip',
		'buyBtn',
		-- 'buyBtn/background',
		'useBtn',
		-- 'useBtn/background',
		'labelAliQuickPay',
		'lotteryBtn',
		'newLotteryBtn',
		'buy_2_step',
		-- 'lotteryBtn/background',
		'moneyBar',
		'ios_ali_link',
	}

	return funnyGroupNodes
end

function EndGamePropBasePanel_VerC:preProcessFunnyNodes( ... )

	local funnyAnimLayer = LayerColor:create()
	funnyAnimLayer.name = 'funnyAnimLayer'
	self.ui:addChild(funnyAnimLayer)
	self.funnyAnimLayer = funnyAnimLayer

	local bounds = {size = {width = 1, height = 1}, origin = {x = 0, y = 0}}

	if self.ui:getChildByPath('blackBg') then
		bounds = self.ui:getChildByPath('blackBg'):getGroupBounds(self.ui)
	end

	funnyAnimLayer:setPositionX(bounds.size.width/2)
	funnyAnimLayer:setPositionY(-bounds.size.height/2)

	local funnyGroupNodes = self:getFunnyNodes()
	for i, nodeName in ipairs(funnyGroupNodes) do
		if not string.find(nodeName, '/') then
			local node = self.ui:getChildByPath(nodeName)
			if node and (not node.isDisposed) then
				node:removeFromParentAndCleanup(false)
				funnyAnimLayer:addChild(node)
				UIHelper:move(node, -bounds.size.width/2, bounds.size.height/2)
			end
		end
	end

	local btns = {'buyBtn', 'useBtn', 'lotteryBtn', 'newLotteryBtn', 'buy_2_step'}

	local oldSetOpacity = LayerColor.setOpacity
	funnyAnimLayer.setOpacity = function ( _, opacity )
		oldSetOpacity(funnyAnimLayer, opacity)
		for _, v in ipairs(btns) do
			local node = self.ui:getChildByPath('funnyAnimLayer/' .. v)
			if node then
				node:getChildByPath('background'):setOpacity(opacity)
				local _shadow = node:getChildByPath('_shadow')
				if _shadow and _shadow.setOpacity then
					_shadow:setOpacity(opacity)
				end
			end
		end
	end
	
end


function EndGamePropBasePanel_VerC:saveBtnScaleInfo(button)
	if self.BtnSourceScale == nil then
		self.BtnSourceScale = {}
	end
	local btnBGNode = button.groupNode
	local scaleX = btnBGNode:getScaleX()
	local scaleY = btnBGNode:getScaleY()
	self.BtnSourceScale[tostring(button)] = {ScaleX = scaleX , ScaleY = scaleY}
end

function EndGamePropBasePanel_VerC:calcBuy2StepMode( ... )
	local enabled, mode = BuyAddTwoStepLogic:isEnabled()
	if enabled then
		local propNum = EndGamePropManager.getInstance():getItemNum(self.propId)
		local topLevel = UserManager.getInstance().user:getTopLevelId()
		local isAddStepProp = (self.propId == ItemType.ADD_FIVE_STEP)
		local isSupportedLevelType = table.exist({
			GameLevelType.kMainLevel, 
			GameLevelType.kHiddenLevel,
		}, self.levelType)

		if propNum <= 0 and isAddStepProp and isSupportedLevelType then
			return mode
		end
	end
end

function EndGamePropBasePanel_VerC:calcLotteryMode( )

	if BuyAddTwoStepLogic:isEnabled() then
		return
	end

	local propNum = EndGamePropManager.getInstance():getItemNum(self.propId)
	local topLevel = UserManager.getInstance().user:getTopLevelId()
	local isAddStepProp = (self.propId == ItemType.ADD_FIVE_STEP)
	local isSupportedLevelType = table.exist({
		GameLevelType.kMainLevel, 
		GameLevelType.kHiddenLevel,
	}, self.levelType)


	if not BuyAddTwoStepLogic:shouldDisableNewLottery() then
		if LotteryLogic:isNewEnable() and propNum <= 0 and topLevel > 20 and isAddStepProp and isSupportedLevelType then
			return LotteryLogic.MODE.kNEW
		end
	end
	
	if LotteryLogic:getLeftFreeDrawCount() > 0 and isAddStepProp and isSupportedLevelType and topLevel > 20 then
		return LotteryLogic.MODE.kFREE
	end

	if propNum <= 0 and topLevel > 20 and isAddStepProp and isSupportedLevelType then
		return LotteryLogic.MODE.kNORMAL
	end
end

function EndGamePropBasePanel_VerC:hideNormalBubble()
end

function EndGamePropBasePanel_VerC:findUnexpectedlyItemId( ... )
	local UnexpectedlyItemIds = {
		ItemType.ADD_2_STEP,
		ItemType.ADD_1_STEP,
	}

	for _, itemId in ipairs(UnexpectedlyItemIds) do
		local propNum = UserManager:getInstance():getUserPropNumber(itemId)
		if propNum > 0 then
			return itemId
		end
	end
end

function EndGamePropBasePanel_VerC:onLotteryBtnTapped( )

	local function useStepProp( itemId )
		self:useProp(itemId, function ( ... )
			if self.isDisposed then return end
			if self.onUseTappedCallback then
				self.onUseTappedCallback(itemId, UsePropsType.NORMAL, true, true)	--千万次地问为什么要给isBuyAddFive传true？？？不过不敢随便改，只能加参数了
			end
			self.dc_result = 'lottery'
			self:remove(false)
		end)
	end

	-- 如果背包有加1步 加2步 那么点击转盘按钮 相当于直接使用背包道具
	if self.lotteryMode == LotteryLogic.MODE.kNEW then
		local itemId = self:findUnexpectedlyItemId()
		if itemId then
			useStepProp(itemId)
			return
		end
	end

	local LotteryPanel = require 'zoo.panel.endGameProp.lottery.LotteryPanel'
	local panel = LotteryPanel:create(self.lotteryMode)
	panel:setGetRewardCallback(function ( rewardItem, isAddStep )
		-- body
		if self.isDisposed then return end
		
		self:refreshLotteryBtn()

		if not isAddStep then
			if self.onGetLotteryReward then
				self.onGetLotteryReward({rewardItem})
			end
		else
			useStepProp(rewardItem.itemId)
		end

	end)
	panel:popout()


	if self.lotteryMode == LotteryLogic.MODE.kNEW then

		if self._revertNewLotteryGuide then
			self._revertNewLotteryGuide()
			panel:popoutNewLotteryGuide_2()
			self._revertNewLotteryGuide = nil
		end

		local t1
		if LotteryLogic:getLeftNewDrawCount() > 0 then
			t1 = 1
		else
			t1 = 2
		end

		local t2 = UserManager:getInstance():getUserPropNumber(ItemType.VOUCHER)
		-- local t3 = LotteryLogic:getCurGameplayContextDrawCount()

		DcUtil:activity({
			game_type = 'stage',
			game_name = 'fs_new_lottery',
			category = 'canyu',
			sub_category = 'lottery_click',
			playId = GamePlayContext:getInstance():getIdStr(),
			t1 = t1,
			t2 = t2,
			-- t3 = t3,
		})


	end

end

function EndGamePropBasePanel_VerC:refreshLotteryBtn( ... )


	if self.isDisposed then return end
	if not self.lotteryBtnUI then return end

	self.lotteryMode = self:calcLotteryMode()

	if not self.lotteryMode then
		if self.lotteryBtn then
			self.lotteryBtn:setVisible(false)
			self.lotteryBtn:rma()
			self.lotteryBtn = nil
			self:onCountdownComplete()
		end
	end

	if not self.lotteryBtn then
		return
	end

	local color = kGroupButtonColorMode.blue

	if self.lotteryMode == LotteryLogic.MODE.kNORMAL then
		self.lotteryBtn:setString(localize('five.steps.lottery.btn1'))
		self.lotteryBtnDot:setNum(LotteryLogic:getLeftDrawCount())
		if LotteryLogic:getLeftDrawCount() > 0 then
			color = kGroupButtonColorMode.green
		end
	elseif self.lotteryMode == LotteryLogic.MODE.kFREE then
		self.lotteryBtn:setString(localize('five.steps.lottery.free.btn1'))

		-- local size = self.lotteryBtn.background:getContentSize()
		-- self.lotteryBtn:resizeBackground(size.width)

		self.lotteryBtnDot:setNum(LotteryLogic:getLeftFreeDrawCount())
		if LotteryLogic:getLeftFreeDrawCount() > 0 then
			color = kGroupButtonColorMode.green
		end
	elseif self.lotteryMode == LotteryLogic.MODE.kNEW then
		self.lotteryBtn:setString(localize('five.steps.lottery.btn1'))
		color = kGroupButtonColorMode.green
	end
	local groupBoundsSize = self.lotteryBtn.groupNode:getGroupBounds().size
	if self.lotteryBtnDot then
		self.lotteryBtnDot:setPositionX(groupBoundsSize.width /2 +38)
	end
	local propIcon = self.lotteryBtn.groupNode:getChildByPath('propIcon')
	if propIcon then
		propIcon:setPositionX( -groupBoundsSize.width/2 -100)
	end
	self.lotteryBtn:setColorMode(color)

	if self.lotteryMode == LotteryLogic.MODE.kNEW then
		if LotteryLogic:getLeftNewDrawCount() > 0 then
			-- self.lotteryBtn.groupNode:runAction(CCRepeatForever:create(UIHelper:sequence{
			-- 	CCScaleTo:create(25 / 30, 0.95, 0.95),
			-- 	CCScaleTo:create(25 / 30, 1, 1),
			-- }))
			self.lotteryIcon:playByIndex(1, 0)
		else
			self.lotteryIcon:playByIndex(0, 0)
			self.lotteryIcon:stop()
			-- self.lotteryBtn.groupNode:stopAllActions()
		end

		local unexpectedItemId = self:findUnexpectedlyItemId()
		if unexpectedItemId then
			self.newLotteryBtnUI:getChildByPath('flag-3'):setVisible(true)
			self.newLotteryBtnUI:getChildByPath('flag-1'):setVisible(false)
			self.lotteryIcon:setVisible(false)
			self.add1stepIcon:setVisible(ItemType.ADD_1_STEP == unexpectedItemId)
			self.add2stepIcon:setVisible(ItemType.ADD_2_STEP == unexpectedItemId)
			self.lotteryBtn:setIcon()
			self.lotteryBtn:setString('继续')
			self.lotteryBtn.label:setAnchorPointCenterWhileStayOrigianlPosition()
			self.lotteryBtn.label:setScale(1/0.8)
		else
			self.newLotteryBtnUI:getChildByPath('flag-1'):setVisible(true)
			self.newLotteryBtnUI:getChildByPath('flag-3'):setVisible(false)
			self.add1stepIcon:setVisible(false)
			self.add2stepIcon:setVisible(false)
			self.lotteryIcon:setVisible(true)
			self.lotteryBtn:setIconByFrameName('Prop_10117_inner0000')
			self.lotteryBtn.icon:setScale(0.6)
			self.lotteryBtn:setNumber(LotteryLogic:getNewCost())
			self.lotteryBtn:setString(localize('five.steps.lottery.btn1'))

			-- black magic 按钮标准化之后，偏偏又要定制里边的布局和显示
			if self.lotteryBtn.numberLabel then
				if not self.lotteryBtn.numberLabel._blackMagicY then
					self.lotteryBtn.numberLabel._blackMagicY = self.lotteryBtn.numberLabel:getPositionY() - 5
				end
				self.lotteryBtn.numberLabel:setPositionY(self.lotteryBtn.numberLabel._blackMagicY)
			end
		end
	end

end

function EndGamePropBasePanel_VerC:updateMoneyBarPos( ... )
	if self.isDisposed then return end
	if not self.moneyBar then return end
	local goldText = self.moneyBar:getChildByPath('goldText')
	local gold = self.moneyBar:getChildByPath('gold')
	local _coin = self.moneyBar:getChildByPath('_coin')
	local deltaX = 0
	-- body
	deltaX = 30
	goldText:setPositionX(0 + deltaX)
	_coin:setPositionX(goldText:getPositionX() + goldText:getContentSize().width + 9)
	gold:setPositionX(_coin:getPositionX() + _coin:getContentSize().width)

end

function EndGamePropBasePanel_VerC:getUIGroupName()
	return "newAddStepPanel_newDrak_new"
end

function EndGamePropBasePanel_VerC:checkTestGroup()
	return "drak"
end

function EndGamePropBasePanel_VerC:getJsonPath()
	return PanelConfigFiles.panel_add_step
end

function EndGamePropBasePanel_VerC:setUseTipText(text)
	if self.useTipLabel then
		self.useTipLabel:setString(tostring(text))
	end
end

function EndGamePropBasePanel_VerC:setUseTipVisible(isVisible)
	if self.useTipLabel then
		self.useTipLabel:setVisible(isVisible == true)
	end
end

function EndGamePropBasePanel_VerC:reBecomeTopPanel( ... )
	-- body
end

function EndGamePropBasePanel_VerC:updateFuuuTargetShow(show)
end

function EndGamePropBasePanel_VerC:updateCountdownShow()
	--倒计时初始化 要在初始化按钮之后
	if AddFiveStepABCTestLogic:needShowCountdown() then
		self:setCountdownSceond(10)
	else
		self:onCountdownComplete()
	end
end

function EndGamePropBasePanel_VerC:popout( bShowDark )

    if bShowDark == nil then bShowDark = true end

	if type(self.onPanelWillPopout) == "function" then
		self.onPanelWillPopout(self)
	end

	local function doPopout( ... )
		if self.isDisposed then return end

		self.bg = self.ui:getChildByPath('blackBg')
		local vSize = Director:sharedDirector():getVisibleSize()
		local vSizeOri = Director:sharedDirector():ori_getVisibleSize()
		local vOrigin = Director:sharedDirector():getVisibleOrigin()
		local size = self.bg:getGroupBounds().size
		-- self:setPosition(ccp(vOrigin.x + (vSize.width-size.width)/2, (size.height - vSize.height) / 2 + vOrigin.y))

		-- self:scaleAccordingToResolutionConfig()
		-- self:setPositionForPopoutManager()

		local fixY = 80
		self.panelScale = 1
        if __isWildScreen then  
			local minScale = math.min(vSize.width/size.width,vSize.height/size.height)
			minScale = minScale*0.8
			self.panelScale = minScale
			self:setScale(minScale)
			fixY = 40
			-- size = self:getGroupBounds().size
			size = self.bg:getGroupBounds().size

			self.bg:setScaleX(self.bg:getScaleX()/minScale)
			local tx = vOrigin.x +(vSize.width-size.width)/2
			tx = -tx/0.5
			self.bg:setPositionX(tx)
		end
		self:setPosition(ccp(vOrigin.x + (vSize.width-size.width)/2, (size.height - vSize.height) / 2 - vOrigin.y+fixY))

		PopoutManager:sharedInstance():add(self)

		local pos = self:getPosition()
	    local backBlack = LayerColor:create()
	    backBlack:setAnchorPoint(ccp(0,0))
	    backBlack:setOpacity(150)
	    backBlack:setContentSize(CCSizeMake(vSizeOri.width/self.panelScale, vSizeOri.height/self.panelScale*1.5))
	    backBlack:setPosition(ccp(-pos.x/self.panelScale,(-pos.y-vSizeOri.height-vOrigin.y)/self.panelScale))
	    self:addChildAt(backBlack,-10)
	    self.backBlack = backBlack

		local isSupportedLevelType = table.exist(validLevelType, self.levelType)

		if isSupportedLevelType then
			self.animPlaying = true
	    	self:createAnimPlayer(1)
	    	self.tipIndex = self.tipIndex + 1
			self.animPlayer:preStart(0)
			self.animPlayer:resume()
		end
	end

	doPopout()
end


function EndGamePropBasePanel_VerC:removePopout()	
	--这个方法在PayPanelRePay里调用 对于加五步面板 不可以直接关闭 隐藏即可
	local container = self:getParent() and self:getParent():getParent()
	if container then
		container:setVisible(false)
	else
		self.ui:setVisible(false)
	end
	self.dc_result = 'manual_exit'
	self:dcAddStep()
end

function EndGamePropBasePanel_VerC:dispose( ... )
	BasePanel.dispose(self, ...)
    require('zoo.panel.endGameProp.lottery.BuyDiamondObserver'):removeObserver(self)
    require('zoo.panel.endGameProp.lottery.CashObserver'):removeObserver(self)
    LotteryLogic:setLotteryTime()

	UIHelper:unloadArmature('skeleton/add_five_step_florid')

	if self.tipOne then
		self.tipOne:dispose()
	end
	if self.packDiscountPlate then
		self.packDiscountPlate:dispose()
	end

	if self.iconNeedDispose then
		for _, v in ipairs(self.iconNeedDispose) do
			v:dispose()
		end
	end

    InterfaceBuilder:unloadAsset(RES_ARROW_BG)
end




function EndGamePropBasePanel_VerC:dcPanelShow()
	DcUtil:endGameForActivity("5_steps_open", self.levelId, self.actSource, self.panelType)
	SeasonWeeklyRaceManager:dcForEndGameProp("weeklyrace_winter_5steps_open", self.levelId, self.levelType, self.actSource)
end

function EndGamePropBasePanel_VerC:dcUseBtnClick()
	DcUtil:endGameForActivity("5_steps_use", self.levelId, self.actSource, self.panelType)
	EndGamePropABCTest.getInstance():dcLog("purchase_add_5_steps", self.levelId, self.actSource, self.propId, self.lastGameIsFUUU)
	SeasonWeeklyRaceManager:dcForEndGameProp("weeklyrace_winter_5steps_click", self.levelId, self.levelType, self.actSource)
end

function EndGamePropBasePanel_VerC:dcUseSuccess()
	DcUtil:endGameForActivity("5_steps_use_success", self.levelId, self.actSource, self.panelType)
	EndGamePropABCTest.getInstance():dcLog("purchase_add_5_steps_success", self.levelId, self.actSource, self.propId, self.lastGameIsFUUU)
	SeasonWeeklyRaceManager:dcForEndGameProp("weeklyrace_winter_5steps_success", self.levelId, self.levelType, self.actSource)
end

function EndGamePropBasePanel_VerC:dcBuyBtnTap()
	DcUtil:endGameForActivity("5_steps_buy", self.levelId, self.actSource, self.panelType)
	EndGamePropABCTest.getInstance():dcLog("purchase_add_5_steps", self.levelId, self.actSource, self.propId, self.lastGameIsFUUU)
	SeasonWeeklyRaceManager:dcForEndGameProp("weeklyrace_winter_5steps_click", self.levelId, self.levelType, self.actSource)
end

function EndGamePropBasePanel_VerC:dcBuySuccess()
	DcUtil:endGameForActivity("5_steps_buy_success", self.levelId, self.actSource, self.panelType)
	EndGamePropABCTest.getInstance():dcLog("purchase_add_5_steps_success", self.levelId, self.actSource, self.propId, self.lastGameIsFUUU)
	SeasonWeeklyRaceManager:dcForEndGameProp("weeklyrace_winter_5steps_success", self.levelId, self.levelType, self.actSource)
end

function EndGamePropBasePanel_VerC:onCashNumChange( ... )
end

function EndGamePropBasePanel_VerC:onDiamondChanged( ... )
    if self.isDisposed then return end
    self:refreshLotteryBtn()
end


function EndGamePropBasePanel_VerC:popoutFinishCallback()
	if self.isDisposed then return end

	self:updateFuuuTargetShow(true)

	if EndGamePropManager.getInstance():getItemNum(self.propId) <= 0 then
		RealNameManager:addConsumptionLabelToPanel(self, false)
	end


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
	if self.buyButton and not self.showFuuuTipMode then 
		self.buyButton:useBubbleAnimation()
	end

    self.DropNum = 0

    self:createRecallA2019IconAlerts()
    self:createSpringFestival2019IconAlerts()
	self:createQuestIconAlerts()
	self:createCollectIconAlerts()
    self:createTurnTableIconAlerts()

	self:initArrowBtn()


	self.maskLayer = LayerColor:create()
    self.maskLayer.name = 'maskLayer'
    self.maskLayer:setColor(ccc3(0, 0, 0))
    self.maskLayer:setOpacity(200)
    self.maskLayer:ignoreAnchorPointForPosition(false)
    self.maskLayer:setAnchorPoint(ccp(0, 1))
    self.ui:addChild( self.maskLayer)
	local vSize = Director:sharedDirector():ori_getVisibleSize()
   	local maskWidth = UIHelper:convert2NodeSpace(self.ui, vSize.width)
   	local maskHeight = UIHelper:convert2NodeSpace(self.ui, vSize.height)

   	if math.abs(maskHeight - CCDirector:sharedDirector():getWinSize().height) <= 0.1 then
   		maskHeight = maskHeight + 100
   	end

    self.maskLayer:changeWidthAndHeight(maskWidth, maskHeight)
    self.maskLayer:setVisible(false)
    self.maskLayer:setTouchEnabled(true, nil, true)
    self.maskLayer:ad(DisplayEvents.kTouchTap, function ( ... )

    end)

    if self.lotteryMode == LotteryLogic.MODE.kNEW then
		if (not UserManager:getInstance():hasGuideFlag(kGuideFlags.FiveStepNewLottery)) then
			UserLocalLogic:setGuideFlag( kGuideFlags.FiveStepNewLottery)
			self:popoutNewLotteryGuide()
		end
	end

	BuyAddTwoStepLogic:reset()
end

function EndGamePropBasePanel_VerC:createTurnTableIconAlerts( ... )

	if self.isDisposed then return end
	if not TurnTable2019Manager.getInstance():getCurIsAct() then
		return
	end

    local levelPlayedCount = TurnTable2019Manager.getInstance().levelPlayedCount
    local canGetInfo = TurnTable2019Manager.getInstance():curLevelCanGet( self.levelId, levelPlayedCount )

	local ngLayer = Layer:create()
	local counter = self.DropNum

	local bCreateIcon = false
    local icon
    local text
  
    if canGetInfo.TicketType == 1 then
        icon = Sprite:createWithSpriteFrameName( 'TurnTable2019_MissionIcon/closeIcon20000' )
    elseif canGetInfo.TicketType == 2 then
        icon = Sprite:createWithSpriteFrameName( 'TurnTable2019_MissionIcon/closeIcon0000' )
    end

    bCreateIcon = true
    text = '如果现在放弃闯关将会失去抽奖券'

    if bCreateIcon then
        icon:setAnchorPoint(ccp(0, 0.5))
        icon:setPositionX(counter * 140)
        icon:setPositionY(57/0.7)
        ngLayer:addChild(icon)

		counter = counter + 1
		UIUtils:setTouchHandler(icon, function ( ... )
			if self.isDisposed then return end
			local tip = EndGamePropTipFactory.createQuestNormal(self, text)
			if not self:replaceTip(tip) then
				tip:dispose()
			end
        end)
    end

    self.DropNum = counter

	self.ui:addChild(ngLayer)
	layoutUtils.setNodeRelativePos(ngLayer, layoutUtils.MarginType.kLEFT, 10)
end

function EndGamePropBasePanel_VerC:createCollectIconAlerts( ... )

	if self.isDisposed then return end
	if not CollectStarsManager.getInstance():willShowAddStep( self.levelId )  then
		return
	end

	local counter = self.DropNum

	local mainLogic = GameBoardLogic:getCurrentLogic()
	local ngLayer = LayerColor:create()
	local task_id_t = {}
    local ScaleNum = 1
    if __isWildScreen then  
        local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	    ScaleNum = visibleSize.width/960
    end


	local ngView = UIHelper:createUI('ui/panel_add_step.json', 'collectstarfiveiconui')
	ngLayer:addChild(ngView)
	ngView:setPositionX(counter * 140*ScaleNum)
	-- ngView:setPositionY(145*ScaleNum)
	--上对齐
	ngView:setPositionY(153- ngView:getContentSize().height*ScaleNum )
    ngView:setScale(ScaleNum)
	UIUtils:setTouchHandler(ngView, function ( ... )
		if self.isDisposed then return end

		if self.tipState == 1 or self.tipState == 3 then

			-- local text = quest:getEndGameTipText()
			local tip = EndGamePropTipFactory.createScoreBuff(self)
			if self.tipState == 3 then
				tip:setTextColor(hex2ccc3('5C7AC0'))
			end
			if not self:replaceTip(tip) then
				tip:dispose()
			end
		end
	end)

	counter = counter + 1
	self.DropNum = counter
	self.ui:addChild(ngLayer)
	layoutUtils.setNodeRelativePos(ngLayer, layoutUtils.MarginType.kLEFT, 10)
	
end

function EndGamePropBasePanel_VerC:createQuestIconAlerts( ... )
	if self.isDisposed then return end
	if (require 'zoo.quest.QuestActLogic'):isActEnabled() then

		local mainLogic = GameBoardLogic:getCurrentLogic()

		local lQuset = _G.QuestManager:getInstance():getQuestsWithEndGameTip(self.levelId, self.levelType)
		local ngLayer = LayerColor:create()
		local counter = self.DropNum
		local task_id_t = {}

        local ScaleNum = 1
        if __isWildScreen then  
            local visibleSize = CCDirector:sharedDirector():getVisibleSize()
		    ScaleNum = visibleSize.width/960
	    end

		for i = 1, #lQuset do
			local quest = lQuset[i]
			if not quest:isFinished() then
				local tipNum = quest:getEndGameTip{gameBoardLogic = mainLogic}
				if tipNum then
					local ngView = UIHelper:createUI('flash/quest-icon.json', 'quest-icon-dir/end-game-icon')
                    ngView = UIHelper:replaceLayer2LayerColor(ngView)
					ngLayer:addChild(ngView)
					ngView:setPositionX(counter * 140*ScaleNum)
					ngView:setPositionY(145*ScaleNum)
                    ngView:setScale(ScaleNum)

					local questIcon = quest:createIcon()
					UIUtils:positionNode(ngView:getChildByPath('holder'), questIcon)
					UIHelper:setCenterText(ngView:getChildByPath('num'), tipNum, 'fnt/addfriend4.fnt')
					counter = counter + 1
					local _, _type = quest:getIdAndType()
					table.insert(task_id_t, _type)

					UIUtils:setTouchHandler(ngView, function ( ... )
						if self.isDisposed then return end

						if self.tipState == 1 or self.tipState == 3 then

							local text = quest:getEndGameTipText()
							local tip = EndGamePropTipFactory.createQuestNormal(self, text)
							if self.tipState == 3 then
								tip:setTextColor(hex2ccc3('5C7AC0'))
							end
							if not self:replaceTip(tip) then
								tip:dispose()
							end
						end
					end)
				end
			end
		end

        self.DropNum = counter


        local metaLevelId = LevelMapManager.getInstance():getMetaLevelId(self.levelId)
		DcUtil:UserTrack({category='taskact', sub_category='add5steps', current_stage = self.levelId, meta_level_id = metaLevelId, task_id = table.concat(task_id_t, '_')})

		self.ui:addChild(ngLayer)
		layoutUtils.setNodeRelativePos(ngLayer, layoutUtils.MarginType.kLEFT, 10)
	end
end


function EndGamePropBasePanel_VerC:createRecallA2019IconAlerts( ... )
	if self.isDisposed then return end

    local Mgr = RecallA2019Manager.getInstance()

    local info = Mgr:getMissonInfo( Mgr.startLevel )

	if Mgr:getActMission() and Mgr:isActInMainTime() and info and info.targetValue - info.currentValue == 1 then
		local ngLayer = Layer:create()
		local counter = self.DropNum

		local bCreateIcon = false
        local icon
        local text
  
        icon = Sprite:createWithSpriteFrameName( 'RecallA2019_MissionIcon/closeIcon0000' )
        bCreateIcon = true
        text = '如果现在放弃闯关将会失去抽奖券'

        if bCreateIcon then
            icon:setPositionX(counter * 140)
            icon:setPositionY(57/0.7)
            ngLayer:addChild(icon)

			counter = counter + 1
			UIUtils:setTouchHandler(icon, function ( ... )
				if self.isDisposed then return end
				local tip = EndGamePropTipFactory.createQuestNormal(self, text)
				if not self:replaceTip(tip) then
					tip:dispose()
				end
            end)
        end

        self.DropNum = counter

		self.ui:addChild(ngLayer)
		layoutUtils.setNodeRelativePos(ngLayer, layoutUtils.MarginType.kLEFT, 10)
	end
end

function EndGamePropBasePanel_VerC:createSpringFestival2019IconAlerts( ... )
	if self.isDisposed then return end
	if SpringFestival2019Manager.getInstance():getCurIsAct() then
        
        FrameLoader:loadImageWithPlist('flash/SpringFestival_2019/SpringFestivalRes_2019.plist')

        local Mgr = SpringFestival2019Manager.getInstance()

		local mainLogic = GameBoardLogic:getCurrentLogic()

        local star = 0
        if mainLogic then
            star = mainLogic.gameMode:getScoreStarLevel()
        end
        local CurLevelCanGetInfo = Mgr:getPassLevelCanGetInfo( true, star )
        local PiaoLevel = CurLevelCanGetInfo.TicketType
        local BagLevel = CurLevelCanGetInfo.luckyBagLevel
        local luckyBagDoubleNum = CurLevelCanGetInfo.luckyBagDoubleNum

		local ngLayer = Layer:create()
		local counter = self.DropNum

        local ScaleNum = 1
        if __frame_ratio and __frame_ratio < 1.4 then  
            local visibleSize = CCDirector:sharedDirector():getVisibleSize()
		    ScaleNum = visibleSize.width/960
	    end

		for i = 1, 2 do
            local bCreateIcon = false
            local icon
            local text
            if i==1 then
                if PiaoLevel > 0 then
                    icon = Sprite:createWithSpriteFrameName( 'SpringFestival_2019res/caipiao0000' )
                    text = '如果现在放弃闯关将会失去抽奖劵'

                    bCreateIcon = true
                end
            else
                --刷星1倍不显示
                if Mgr.LevelPlayType == 2 and luckyBagDoubleNum == 1 then   
                else
                    if BagLevel >=1 and BagLevel <= 4 then
                        icon = Sprite:createWithSpriteFrameName( 'SpringFestival_2019res/fudai10000' )

                        local DoubleLabel = BitmapText:create( luckyBagDoubleNum.."倍" ,"fnt/peg_year_chunjiejineng.fnt")
                        DoubleLabel:setAnchorPoint(ccp(0.5, 0.5))
                        DoubleLabel:setPosition(ccp(63,30+14/0.7))
                        DoubleLabel:setScale(0.6)
                        icon:addChild(DoubleLabel)

                        if luckyBagDoubleNum == 1 then
                            DoubleLabel:setVisible(false)
                        end

                        text = '如果现在放弃闯关将会失去蛋糕'
                        bCreateIcon = true
                    end
                end
            end

            if bCreateIcon and icon then
                icon:setAnchorPoint(ccp(0, 0.5))
                icon:setPositionX(counter * 140*ScaleNum)
                icon:setPositionY(57/0.7*ScaleNum)
                icon:setScale(ScaleNum)
                ngLayer:addChild(icon)

			    counter = counter + 1
			    UIUtils:setTouchHandler(icon, function ( ... )
				    if self.isDisposed then return end
				    local tip = EndGamePropTipFactory.createQuestNormal(self, text)
                    if self.tipState == 3 then
						tip:setTextColor(hex2ccc3('5C7AC0'))
					end
				    if not self:replaceTip(tip) then
					    tip:dispose()
				    end
                end)
            end
		end

        self.DropNum = counter

		self.ui:addChild(ngLayer)
		layoutUtils.setNodeRelativePos(ngLayer, layoutUtils.MarginType.kLEFT, 10)
	end
end

local function memoryOriPos( node )
	if not node then return end
	if not node._oriPos then
		local pos = node:getPosition()
		node._oriPos = ccp(pos.x, pos.y)
	end
end

function EndGamePropBasePanel_VerC:onCountdownComplete(showAnime)
	if self.isDisposed then return end
	self.countdownLabel:setVisible(false)


	local buyUseBtnFixY = 45
	local moneyBarFixY = 25
	local lotteryBtnFixX = 0
	local lotteryBtnFixY = 0
	local buy2StepBtnFixX = 0
	local buy2StepBtnFixY = 0
	local iosAliLinkFixY = 0
	local quickPayLabelFix = 0


	if self.lotteryBtn or self.buy2StepBtn then

		memoryOriPos(self.lotteryBtn)
		memoryOriPos(self.buy2StepBtn)

		buyUseBtnFixY = 95
		moneyBarFixY = 95
		lotteryBtnFixY = -55
		lotteryBtnFixX = 0
		iosAliLinkFixY = 95
		quickPayLabelFix = 95

		buy2StepBtnFixY = -55
		buy2StepBtnFixX = 0

		local propNum = EndGamePropManager.getInstance():getItemNum(self.propId)
		if self.lotteryMode == LotteryLogic.MODE.kFREE and propNum > 0 then
			lotteryBtnFixX = -10
			buy2StepBtnFixX = -10
		end

		if self.lotteryBtn and self.lotteryBtn.groupNode and self.lotteryBtn.groupNode.parent ~= nil then
			self.lotteryBtn:setPositionY(self.lotteryBtn._oriPos.y + lotteryBtnFixY)
			self.lotteryBtn:setPositionX(self.lotteryBtn._oriPos.x + lotteryBtnFixX)
		end

		if self.buy2StepBtn and self.buy2StepBtn.groupNode and self.buy2StepBtn.groupNode.parent ~= nil then
			self.buy2StepBtn:setPositionY(self.buy2StepBtn._oriPos.y + buy2StepBtnFixY)
			self.buy2StepBtn:setPositionX(self.buy2StepBtn._oriPos.x + buy2StepBtnFixX)
		end

	end

	if self.buyButton and self.buyButton.groupNode and self.buyButton.groupNode.parent ~= nil then
		memoryOriPos(self.buyButton)
		self.buyButton:setPositionY(self.buyButton._oriPos.y + buyUseBtnFixY)
	end

	if self.useButton and self.useButton.groupNode and self.useButton.groupNode.parent ~= nil then
		memoryOriPos(self.useButton)
		self.useButton:setPositionY(self.useButton._oriPos.y + buyUseBtnFixY)
	end
	
	if self.propIconSprite then
		memoryOriPos(self.propIconSprite)
		self.propIconSprite:setPositionY(self.propIconSprite._oriPos.y + buyUseBtnFixY)
	end

	if self.moneyBar then
		memoryOriPos(self.moneyBar)
		self.moneyBar:setPositionY(self.moneyBar._oriPos.y + moneyBarFixY)
	end

	local iosLink = self.ui:getChildByPath('funnyAnimLayer/ios_ali_link')
	if iosLink then
		memoryOriPos(iosLink)
		iosLink:setPositionY(iosLink._oriPos.y + iosAliLinkFixY)
	end

	local quickPayLabel = self.ui:getChildByPath('funnyAnimLayer/labelAliQuickPay')
	if quickPayLabel then
		memoryOriPos(quickPayLabel)
		quickPayLabel:setPositionY(quickPayLabel._oriPos.y + quickPayLabelFix)
	end
end


	-- local winSize = CCDirector:sharedDirector():getVisibleSize()
	-- local origin = CCDirector:sharedDirector():getVisibleOrigin()
	-- object:setPosition(ccp(winSize.width/2, winSize.height/2 + origin.y))
 --        object:playSequence("jump", true, true, ASSH_RESTART);
 --        object:start();

function EndGamePropBasePanel_VerC:createAnimalAnim( state )
	if self.isDisposed then return end


	if self.animalLayer then
		self.animalLayer:removeFromParentAndCleanup(true)
	end
		
	local resSuffix = ''

	local anim 
	if state == 1 then
		anim = gAnimatedObject:createWithFilename("gaf/add_step_animal/add_step_animal_a2" .. resSuffix .. ".gaf")
		-- anim = UIHelper:createArmature('florid.add.5/animal_a')
	elseif state == 2 then
		anim = gAnimatedObject:createWithFilename("gaf/add_step_animal/add_step_animal_b" .. resSuffix .. ".gaf")
		-- anim = UIHelper:createArmature('florid.add.5/animal_b')
	elseif state == 3 then
		anim = gAnimatedObject:createWithFilename("gaf/add_step_animal/add_step_animal_c" .. resSuffix .. ".gaf")
		-- anim = UIHelper:createArmature('florid.add.5/animal_c')
	end


	anim:playSequence("anim", state == 3, true, ASSH_RESTART)
	anim:start()
	-- anim:step()
	anim:pause()

	local animalLayer = LayerColor:create()

	if state == 2 or state == 3 then
		animalLayer:setScale(1.084)
	end

	animalLayer.name = 'animalLayer'
	self.ui:addChild(animalLayer)
	self.animalLayer = animalLayer
	animalLayer.anim = anim
	animalLayer:addChild(anim)
	anim:setPositionX(-150.8)

	anim:setPositionY(3)
	local animPh = self.ui:getChildByName("animPh")
	animPh:setVisible(false)
	local bounds = animPh:getGroupBounds(self.ui)
	self.animalLayer:setPositionX(bounds:getMidX())
	self.animalLayer:setPositionY(bounds.origin.y)


	if self.animalLayer then
		local oldSetOpacity = LayerColor.setOpacity
		self.animalLayer.setOpacity = function ( _, opacity )
			oldSetOpacity(self.animalLayer, opacity)
			-- self.animalLayer.anim:setOpacity(opacity)
		end
	end
end

function EndGamePropBasePanel_VerC:createBubbleAnim( state, specTipIndex )
	-- body
	if self.isDisposed then return end

	if self.bubbleLayer then
		self.bubbleLayer:removeFromParentAndCleanup(true)
	end

	local tip
	tip = EndGamePropTipFactory:createTip(self.tipData[specTipIndex or self.tipIndex])


	local bubble

	local _tipData = self.tipData[specTipIndex or self.tipIndex]
	if _tipData and _tipData.bubbleRes and _tipData.bubbleRes[state] then
		bubble	= UIHelper:createArmature('florid.add.5/' .. _tipData.bubbleRes[state])
	else
		if state == 1 then
			bubble	= UIHelper:createArmature('florid.add.5/bubble_a')
		elseif state == 2 then
			bubble	= UIHelper:createArmature('florid.add.5/bubble_b2')
		elseif state == 3 then
			bubble	= UIHelper:createArmature('florid.add.5/bubble_c2')
		end
	end

	local bubbleLayer = LayerColor:create()
	bubbleLayer.name = 'bubbleLayer'
	self.ui:addChildAt(bubbleLayer, 1)
	self.bubbleLayer = bubbleLayer

	bubbleLayer:addChild(bubble)

	bubble:setPositionX(23)
	bubble:setPositionY(-30)

	if self.tipOne and (not self.tipOne.isDisposed) then
		self.tipOne:dispose()
	end
	
	

	if state > 1 then
		if tip.setTextColor then
			tip:setTextColor(hex2ccc3('5C7AC0'))
		end
	end

	self.tipOne = tip

	self:onNewTip(self.tipOne, state, specTipIndex)

	if tip then

		local contentContainer = UIHelper:getCon(bubble, 'content')
		contentContainer:addChild(tip.refCocosObj)


		-- if state == 3 then

		-- 	if self.iconNeedDispose then
		-- 		for _, v in ipairs(self.iconNeedDispose) do
		-- 			v:dispose()
		-- 		end
		-- 	end

		-- 	self.iconNeedDispose = {}

		-- 	self.iconAnims = {}

		-- 	for _, icon in ipairs(tip.icons or {}) do
		-- 		local iconAnim = UIHelper:createArmature('florid.add.5/bubble_d')
		-- 		iconAnim:setScale(100/68.4921)
		-- 		-- table.insert(self.iconAnims, iconAnim)

		-- 		local px = icon:getPositionX()
		-- 		local py = icon:getPositionY()
		-- 		local pos = tip:convertToNodeSpace(icon:getParent():convertToWorldSpace(ccp(px, py)))

		-- 		icon:removeFromParentAndCleanup(false)
		-- 		tip:addChild(iconAnim)

				

		-- 		iconAnim:setPosition(pos)

		-- 		icon:setPositionX(159.45/2)
		-- 		icon:setPositionY(170.45/2)

		-- 		local iconContainer = UIHelper:getCon(iconAnim, '奖励')
		-- 		iconContainer:addChild(icon.refCocosObj)

		-- 		table.insert(self.iconNeedDispose, icon)

		-- 		tip:addChild(iconAnim)

		-- 		table.insert(self.iconAnims, iconAnim)


		-- 	end
		-- end
	end

	local animPh = self.ui:getChildByName("animPh")
	animPh:setVisible(false)
	local bounds = animPh:getGroupBounds(self.ui)
	local oldSetOpacity = LayerColor.setOpacity
	bubbleLayer.setOpacity = function ( _, opacity )
		oldSetOpacity(bubbleLayer, opacity)
		bubble:setOpacity(opacity)
	end
	self.bubbleLayer.bubble = bubble
	

	if self.bubbleLayer then
		local oldSetOpacity = LayerColor.setOpacity
		self.bubbleLayer.setOpacity = function ( _, opacity )
			oldSetOpacity(self.bubbleLayer, opacity)
			self.bubbleLayer.bubble:setOpacity(opacity)
		end
	end
end

function EndGamePropBasePanel_VerC:replaceTip( tip )
	if self.isDisposed then return end
	if self.tipOne and (not self.tipOne.isDisposed) then
		local tipOneCosObj = self.tipOne.refCocosObj
		local parent = tipOneCosObj:getParent()
		if parent then
			parent:removeChild(tipOneCosObj)
			self.tipOne:dispose()
			self.tipOne = tip
			parent:addChild(tip.refCocosObj)
			return true
		end
	end
end

function EndGamePropBasePanel_VerC:onNewTip( tip, state, specTipIndex )
	if self.isDisposed then return end
	self.tipState = state
end

function EndGamePropBasePanel_VerC:onCloseBtnTapped()
	if self.isDisposed then return end

	if self.animPlaying then return end

	local isSupportedLevelType = table.exist(validLevelType, self.levelType)

	if isSupportedLevelType then
		if self.tipData[self.tipIndex] then
			self.animPlaying = true
			self:createAnimPlayer(self.tipIndex)
			self.animPlayer:preStart(0.01)
			self.animPlayer:resume()
			return
		end
	end

	self:stopCountdown()
	local function hideFinishCallback()
		FUUUManager:clearLastFuuuID()
		if self.onCancelTappedCallback then
			self.onCancelTappedCallback()
		end
	end
	self.allowBackKeyTap = false
	self.dc_result = 'manual_exit'
	self:remove(hideFinishCallback)

end


function EndGamePropBasePanel_VerC:onUseBtnTapped()
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

		self.dc_result = 'use'
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

--------------------------------------------------------------------------------------------------------------------
--				+5礼包  PackDiscountPlate
--------------------------------------------------------------------------------------------------------------------
-- inDiscountState 用于区别是否是打折状态。 因为 iOS 和 Android 判断标准不一致，故需在各自面板自行判断。
-- iOS 和 Android 均已在 EndGamePropBasePanel_VerC:init 之前设置了 inDiscountState
function EndGamePropBasePanel_VerC:checkCanShowPackDiscountPlate()
	-- do return true end
	-- RemoteDebug:uploadLogWithTag("CHECK === canShowPackDiscountPlate. propID", self.propId)
	if self.propId ~= ItemType.ADD_FIVE_STEP then
		return false
	end

	self.goodsPackID = nil

	local keyName = "NewAdd5PackDiscount"
	local groupIDs = {"A1", "A2", "A3", "A4"}	-- 分组
	local goodsIDs = {588, 611, 612, 613}		-- 分组对应的GoodsID  
	--注意: 612，在EndGamePropGoodsPlate中写死，用不同的素材
	--注意: 613，因为配置里两种支付都有，在别处写死了用RMB支付

	local function getCurrGoodsID()
		local currGoodsID = 0

		for index = 1, #groupIDs do
			local groupID = groupIDs[index]
			local activityOpened = MaintenanceManager:getInstance():isEnabledInGroup(keyName, groupID, UserManager:getInstance().uid)
			-- printx(11, "group:", groupID, ". opened:", activityOpened)
			if activityOpened then
				currGoodsID = goodsIDs[index]
				break
			end
		end
		
		return currGoodsID
	end
	local packDiscountGoodsID = getCurrGoodsID()
	-- printx(11, "real packDiscountGoodsID:", packDiscountGoodsID)

	local propNum = EndGamePropManager.getInstance():getItemNum(self.propId) --包含了限时道具
	local alreadyHasProp = propNum > 0
	-- printx(11, " === EndGamePropBasePanel_VerC:canShowPackDiscountPlate ===")
	-- printx(11, "packDiscountGoodsID:", packDiscountGoodsID)
	-- printx(11, "inDiscountState:", self.inDiscountState)
	-- printx(11, "alreadyHasProp:", alreadyHasProp, propNum)
	-- RemoteDebug:uploadLogWithTag("packDiscountGoodsID, inDiscountState, alreadyHasProp", packDiscountGoodsID, self.inDiscountState, alreadyHasProp)
	
	if (packDiscountGoodsID > 0) and (not self.inDiscountState) and (not alreadyHasProp) then
		-- RemoteDebug:uploadLogWithTag("can show pack discount: TRUE")
		self.goodsPackID = packDiscountGoodsID
		return true
	end
	-- RemoteDebug:uploadLogWithTag("can show pack discount: FALSE")
	return false
end

-- iOS 和 Android 有不同的策略，各自判断处理
function EndGamePropBasePanel_VerC:checkCreatePackDiscountPlate()
	-- printx(11, "checkCreatePackDiscountPlate", debug.traceback())
	if self.isDisposed then return end
end

function EndGamePropBasePanel_VerC:addBottomAD(ad)
	ad.isBottomAD = true
	self.ui:addChild(ad)
	ad:setPositionXY(55,-550)
end

function EndGamePropBasePanel_VerC:createPackDiscountPlate()
	if self.isDisposed then return end

	local function onPackDiscountBuyBtnTapped()
		self:onPackDiscountBuyBtnTapped()
	end

	local plate = EndGamePropGoodsPlate.createPlate(self, self.goodsPackID, self.packDiscountUseHPCoin, onPackDiscountBuyBtnTapped)
	if plate then
		self:addBottomAD(plate)
		self.packDiscountPlate = plate
		added = true

		local dcParamT1 = 1
		local dcParamT2 = 0
		local goodsData = MetaManager.getInstance():getGoodMeta(self.goodsPackID)
		if self.packDiscountUseHPCoin then
			dcParamT1 = 2
			if goodsData then 
				if goodsData.discountQCash > 0 then
					dcParamT2 = goodsData.discountQCash 
				else
					dcParamT2 = goodsData.qCash 
				end
			end
		else
			if goodsData then dcParamT2 = goodsData.discountRmb end
		end
		DcUtil:UserTrack({category = 'fs_pack_add5', sub_category = 'canyu', t1 = dcParamT1, t2 = dcParamT2})
	end
end

function EndGamePropBasePanel_VerC:updatePackDiscountPlate()
	self:refreshPackDiscountPlate()
end

function EndGamePropBasePanel_VerC:refreshPackDiscountPlate()
	if self.isDisposed then return end

	if self.packDiscountPlate then
		EndGamePropGoodsPlate.refreshPlateView(self.packDiscountPlate, self.packDiscountUseHPCoin, self.goodsPackID)
		EndGamePropGoodsPlate.reEnableBtn(self.packDiscountPlate)
	end
end

------------ buy -----
function EndGamePropBasePanel_VerC:onPackDiscountBuyBtnTapped()
	if self.isDisposed then return end

	if self.packDiscountPlate then
		self:stopCountdown()

		DcUtil:UserTrack({category = 'fs_pack_add5', sub_category = 'click'})
	end
end

function EndGamePropBasePanel_VerC:onBuyPackDiscountByHappyCoin()
	if self.isDisposed then return end

	local function onBuySuccess()
		-- self:dcBuySuccess()
		
		if self.isDisposed then return end 
		self:onBuyPackDiscountSucceed()

		-- self.dcIosInfo:setResult(DCWindmillPayResult.kSuccess)
		-- PaymentIosDCUtil.getInstance():sendIosWindmillPayEnd(self.dcIosInfo)
	end

	local function onBuyFail(errorCode, errorMsg)
		self:onBuyPackDiscountFailed(errorCode, errorMsg)
	end

	local function onBuyCancel()
		self:onBuyCancel()
	end

	local goodsId = self.goodsPackID
	local logic = BuyLogic:create(goodsId, MoneyType.kGold, DcFeatureType.kPaymentPack, DcSourceType.kPaymentPackID..goodsId, self.buyExtraParam)
	logic:getPrice()
	logic:setCancelCallback(onBuyCancel)
	logic:start(1, onBuySuccess, onBuyFail)

	-- self:dcBuyBtnTap()
end

function EndGamePropBasePanel_VerC:onBuyPackDiscountFailed(errorCode, errorMsg)
	if self.isDisposed then return end
	self.onEnterForeGroundCallback = nil
	self:stopAllActions()

	local function resumeTimer()
		if self.isDisposed then return end
		self:resumeTimer()
	end

	local goldMarketPanel = nil
	local function buyGoldSuccess()
		if not goldMarketPanel or self.isDisposed or not self.goodsPrice then return end 
		-- local userCash = UserManager:getInstance().user:getCash()
		-- if userCash >= self.goodsPrice then 
			goldMarketPanel:onCloseBtnTapped()
			goldMarketPanel = nil
		-- end
	end

	local function onCreateGoldPanel()
        local index = MarketManager:sharedInstance():getHappyCoinPageIndex()
        if index ~= 0 then
            goldMarketPanel = createMarketPanel(index)
            goldMarketPanel:setBuyGoldSuccessFunc(buyGoldSuccess)
            goldMarketPanel:popout()
            goldMarketPanel:addEventListener(kPanelEvents.kClose, resumeTimer)
        else
        	resumeTimer()
        end
    end

	if errorCode and errorCode == 730330 then  -- not enough gold
		-- self.dcIosInfo:setResult(DCWindmillPayResult.kNoWindmill)
		-- PaymentIosDCUtil.getInstance():sendIosWindmillPayEnd(self.dcIosInfo)
		GoldlNotEnoughPanel:createWithTipOnly(onCreateGoldPanel)
	else
		-- self.dcIosInfo:setResult(DCWindmillPayResult.kFail, errorCode)
		-- PaymentIosDCUtil.getInstance():sendIosWindmillPayEnd(self.dcIosInfo)
		resumeTimer()
	end
end

function EndGamePropBasePanel_VerC:onBuyPackDiscountSucceed()
	if self.isDisposed then return end
	-- printx(11, "===== EndGamePropBasePanel_VerC:onBuyPackDiscountSucceed =====")

	self.onEnterForeGroundCallback = nil
	self:stopAllActions()
		
	local button = HomeScene:sharedInstance().goldButton
	if button then button:updateView() end

	if self.onUpdatePropBarDisplay then
		local goodsData = MetaManager.getInstance():getGoodMeta(self.goodsPackID)
		if goodsData and goodsData.items then
			for _, item in ipairs(goodsData.items) do
				self.onUpdatePropBarDisplay(item.itemId, item.num)
			end
		end
	end

	self:refreshViewAfterPackDiscountBought()
end

function EndGamePropBasePanel_VerC:refreshViewAfterPackDiscountBought()
	if self.isDisposed then return end
	-- printx(11, "===== +++ EndGamePropBasePanel_VerC:refreshViewAfterPackDiscountBought =====")

	if self.packDiscountPlate then
		self.packDiscountPlate:setVisible(false)
	end

	local propNum = EndGamePropManager.getInstance():getItemNum(self.propId)
	if self.levelType == GameLevelType.kOlympicEndless or self.levelType == GameLevelType.kMidAutumn2018 then
		propNum = 0
	end
	-- printx(11, "propNum:", propNum)
	if propNum > 0 then -- use
		if not self.useButton then
			self.useButton = EndGameUseButton:create(self.useButtonUI, self.propId)
			self:saveBtnScaleInfo(self.useButton)
			-- self.useButton:setColorMode(kGroupButtonColorMode.blue)
			self.useButton:setString(Localization:getInstance():getText("add.step.panel.use.btn.txt"))
			self.useButton:addEventListener(DisplayEvents.kTouchTap, function (evt)
				self:onUseBtnTapped()
			end)
		end
		self.useButton:setNumber(propNum)

		self.useButtonUI:setVisible(true)
		self.buyButtonUI:setVisible(false)
		if self.buyButton then
			self.buyButton:setVisible(false)
		end

		-- 这个countDown已经在代码中强制关闭了
		-- self.countdownLabel:setPositionX(541)
		self:refreshLotteryBtn()
		self:updateCountdownShow()	--考虑lotteryBtn，更新useBtn位置

		if self.moneyBar then
			self.moneyBar:setVisible(false)
		end
	else
		-- 不会有这种情况
		-- if type(self.updateGoldNum) == "function" then
		-- 	self:updateGoldNum()
		-- end
	end
	
end

function EndGamePropBasePanel_VerC:popoutNewLotteryGuide( ... )
	if self.isDisposed then return end
	local guidePanel = GameGuideUI:dialogue(nil, { panelName="guide_dialogue_lottery_1" }, false)
	guidePanel:setPosition(ccp(200, 300))
	guidePanel.name = 'guidePanel'
	self.ui:addChild(guidePanel)

	local bounds = self.newLotteryBtnUI:getGroupBounds(self.ui)
	local anchorPos = ccp(bounds:getMidX() - bounds.size.width + 60, bounds:getMidY() - bounds.size.height/2)

	guidePanel:setPosition(anchorPos)

	local vo = Director:sharedDirector():ori_getVisibleOrigin()
	layoutUtils.setNodeOriginPos(self.maskLayer, ccp(vo.x, vo.y))
	self.maskLayer:setVisible(true)


	


	local r1 = UIHelper:moveToTop(self.ui, {'maskLayer', 'funnyAnimLayer/newLotteryBtn', 'guidePanel'})




	local function endGuide( ... )
		if self.isDisposed then return end
		if r1 then 
			r1() 
			r1 = nil 
		end
		if guidePanel and (not guidePanel.isDisposed) then 
			guidePanel:removeFromParentAndCleanup(true) 
			guidePanel = nil
		end
		self.maskLayer:setVisible(false)
		if self.btnArrow then
			self.btnArrow:setVisible(true)
		end

		if self.maskLayer.skinBtn then
			self.maskLayer.skinBtn:removeFromParentAndCleanup(true)
			self.maskLayer.skinBtn = nil
		end

		self._revertNewLotteryGuide = nil
		self.allowBackKeyTap = true

	end


	self._revertNewLotteryGuide = endGuide

	local skinBtn = UIHelper:skipButton('跳过', endGuide)
	self.maskLayer:addChild(skinBtn)
	self.maskLayer.skinBtn = skinBtn

	layoutUtils.setNodeRelativePos(skinBtn, layoutUtils.MarginType.kLEFT, -35)
	layoutUtils.setNodeRelativePos(skinBtn, layoutUtils.MarginType.kTOP, -10)

	if self.btnArrow then
		self.btnArrow:setVisible(false)
	end

	self.allowBackKeyTap = false



	DcUtil:activity({
		game_type = 'stage',
		game_name = 'fs_new_lottery',
		category = 'guide',
		sub_category = 'guide_click',
		playId = GamePlayContext:getInstance():getIdStr(),
		t1 = self.levelId,
	})

end

function EndGamePropBasePanel_VerC:refreshBuy2StepBtn( ... )
	if self.isDisposed then return end
	if not self.buy2StepBtnUI then return end
	if not self.buy2StepBtn then return end

	local goodsId = BuyAddTwoStepLogic:getGoodsId(self.buy2StepMode)


	local unexpectedItemId = self:findUnexpectedlyItemId()
	if unexpectedItemId then
		self.buy2StepBtn:setIcon()
		self.buy2StepBtn:setString('继续')
		self.buy2StepBtn:setEnabledForColorOnly(true)
		self.buy2StepBtnUI:getChildByPath('flag'):setVisible(true)
		self.buy2StepBtnUI:getChildByPath('discountUI'):setVisible(false)
	elseif self.buy2StepMode == BuyAddTwoStepLogic.MODE.kGoldCash then
		self.buy2StepBtn:setIconByFrameName('ui_images/ui_image_coin_icon_small0000')
		self.buy2StepBtn:setString('继续')
		self.buy2StepBtn:setNumber(math.min(TradeUtils:getCashPrice(goodsId), 99))
		self.buy2StepBtn:setEnabledForColorOnly(BuyAddTwoStepLogic:canBuy())
		self.buy2StepBtnUI:getChildByPath('flag'):setVisible(BuyAddTwoStepLogic:canBuy())
		self.buy2StepBtnUI:getChildByPath('discountUI'):setVisible(false)
	elseif self.buy2StepMode == BuyAddTwoStepLogic.MODE.kRMB then
		self.buy2StepBtn:setIcon()
		self.buy2StepBtn:setString('继续')
		self.buy2StepBtn:setNumber( TradeUtils:formatPriceShow(TradeUtils:getRmbPrice(goodsId)))
		self.buy2StepBtn:setEnabledForColorOnly(BuyAddTwoStepLogic:canBuy())
		self.buy2StepBtnUI:getChildByPath('flag'):setVisible(BuyAddTwoStepLogic:canBuy())
		self.buy2StepBtnUI:getChildByPath('discountUI'):setVisible(false)
	elseif self.buy2StepMode == BuyAddTwoStepLogic.MODE.kRMB_WITH_FIRST_DISCOUNT then
		self.buy2StepBtn:setIcon()
		self.buy2StepBtn:setString('继续')
		self.buy2StepBtn:setNumber( TradeUtils:formatPriceShow(TradeUtils:getRmbPrice(goodsId)))
		self.buy2StepBtn:setEnabledForColorOnly(BuyAddTwoStepLogic:canBuy())
		self.buy2StepBtnUI:getChildByPath('flag'):setVisible(false)
		self.buy2StepBtnUI:getChildByPath('discountUI'):setVisible(true)
		local CommonViewLogic = require 'zoo.panel.store.views.CommonViewLogic'
		local goodsMeta = MetaManager.getInstance():getGoodMeta(goodsId)

		local discount = 0
		if goodsMeta.discountRmb > 0 then
			discount = math.ceil(goodsMeta.discountRmb / goodsMeta.rmb * 10) 
		end

		local discountUI = self.buy2StepBtnUI:getChildByPath('discountUI')
		if discount > 0 and discount < 10 then
			local discountNumUI = discountUI:getChildByPath('num')
			discountNumUI:setText(tostring(discount))
			discountNumUI:setScale(2.5)
			local discountTextUI = discountUI:getChildByPath('text')
			discountTextUI:setText(localize("buy.gold.panel.discount"))
			discountTextUI:setScale(1.7)
		else
			discountUI:setVisible(false)
		end
	elseif self.buy2StepMode == BuyAddTwoStepLogic.MODE.kRMB_ONCE_PER_DAY then
		self.buy2StepBtn:setIcon()
		self.buy2StepBtn:setString('继续')
		self.buy2StepBtn:setNumber( TradeUtils:formatPriceShow(TradeUtils:getRmbPrice(goodsId)))
		self.buy2StepBtn:setEnabledForColorOnly(BuyAddTwoStepLogic:canBuy() and BuyAddTwoStepLogic:canBuyInMode(self.buy2StepMode))
		self.buy2StepBtnUI:getChildByPath('discountUI'):setVisible(false)
		local CommonViewLogic = require 'zoo.panel.store.views.CommonViewLogic'
		local goodsMeta = MetaManager.getInstance():getGoodMeta(goodsId)

		local discount = 0
		if goodsMeta.discountRmb > 0 then
			discount = math.ceil(goodsMeta.discountRmb / goodsMeta.rmb * 10) 
		end
		local discountUI = self.buy2StepBtnUI:getChildByPath('discountUI')
		discountUI:setVisible(false)
		self.buy2StepBtnUI:getChildByPath('flag'):setVisible(BuyAddTwoStepLogic:canBuy() and BuyAddTwoStepLogic:canBuyInMode(self.buy2StepMode))
	end



end

function EndGamePropBasePanel_VerC:onTapBuy2StepBtn( ... )
	if self.isDisposed then return end

	


	local function useStepProp( itemId )
		self:useProp(itemId, function ( ... )
			if self.isDisposed then return end
			if self.onUseTappedCallback then
				self.onUseTappedCallback(itemId, UsePropsType.NORMAL, true)
			end
			self.dc_result = 'buy_2_step'
			self:remove(false)
		end, function ( ... )
			-- printx(61, 'use failed')
		end)
	end

	local itemId = self:findUnexpectedlyItemId()
	if itemId then
		useStepProp(itemId)
		return
	end


	if not BuyAddTwoStepLogic:canBuyInMode(self.buy2StepMode) then
		-- CommonTip:showTip('下次闯关才能使用哦~')
		CommonTip:showTip(localize('buy.two.step.disabled.' .. self.buy2StepMode))
		return
	end

	if not BuyAddTwoStepLogic:canBuy() then
		-- CommonTip:showTip('下次闯关才能使用哦~')
		CommonTip:showTip(localize'buy.two.step.disabled')
		return
	end

	self.buy2StepBtn:setEnabled(false)


	BuyAddTwoStepLogic:buy(self.buy2StepMode, function ( itemId )
		if self.isDisposed then return end
		self.buy2StepBtn:setEnabled(true)
		useStepProp(itemId)
	end, function ( ... )
		if self.isDisposed then return end
		self.buy2StepBtn:setEnabled(true)
	end, function ( ... )
		if self.isDisposed then return end
		self.buy2StepBtn:setEnabled(true)
	end, function ( ... )
		if self.isDisposed then return end
		if type(self.updateGoldNum) == "function" then
			self:updateGoldNum()
		end

		self.buy2StepBtn:setEnabled(true)

	end)

end

