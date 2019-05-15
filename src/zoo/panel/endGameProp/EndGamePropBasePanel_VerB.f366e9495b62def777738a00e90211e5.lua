require "zoo.panel.endGameProp.EndGamePropBasePanel"
local LotteryLogic = require 'zoo.panel.endGameProp.lottery.LotteryLogic'

EndGamePropBasePanel_VerB = class(EndGamePropBasePanel)

function EndGamePropBasePanel_VerB:ctor()
	local skinMode = self:checkTestGroup()
	self.skinMode = skinMode
	self.showFuuuTipMode = false
end

function EndGamePropBasePanel_VerB:init()

    --require('zoo.panel.endGameProp.lottery.BuyDiamondObserver'):addObserver(self)


	self.ui = self:buildInterfaceGroup(self:getUIGroupName())
	BasePanel.init(self, self.ui)

	--基础UI
	self.closeBtn = self.ui:getChildByName("closeBtn")
	self.msgLabel = self.ui:getChildByName("msgLabel")
	self.msgLabelPh = self.ui:getChildByName("msgLabelph")
	self.msgLabelPh:setVisible(false)

	self.countdownLabel = self.ui:getChildByName("countdownLabel")
	self.countdownLabel:setScale(1.3)
	self.countdownLabel:setAnchorPoint(ccp(0.5, 0.5))
	self.countdownLabel:setPositionY(self.countdownLabel:getPositionY() - 45)

	self.ui:getChildByName('labelPh'):setVisible(false)
	self.buyButtonUI = self.ui:getChildByName("buyBtn")
	self.useButtonUI = self.ui:getChildByName("useBtn")
	self.lotteryBtnUI = self.ui:getChildByName('lotteryBtn')
	self.animPh = self.ui:getChildByName("animPh")
	self.moneyBar = self.ui:getChildByName("moneyBar")
	self.moneyBar:setVisible(false)
	self.msgLabel_new1 = self.ui:getChildByName("msgLabel_new1")
	self.msgLabel_new2 = self.ui:getChildByName("msgLabel_new2")

	self.msgLabel_new1:setString( Localization:getInstance():getText("add.step.panel.msg.txt.fuuu1") )
	self.msgLabel_new2:setString( Localization:getInstance():getText("add.step.panel.msg.txt.fuuu2") )

	self.msgLabel_new1:setVisible(false)
	self.msgLabel_new2:setVisible(false)

	self.msgIcon_1 = self.ui:getChildByName("msgIcon_1")
	self.msgIcon_2 = self.ui:getChildByName("msgIcon_2")

	self.msgIcon_label1 = self.msgIcon_1:getChildByName("numLabel")
	self.msgIcon_label2 = self.msgIcon_2:getChildByName("numLabel")

	self.msgIcon_1:getChildByName("icon"):removeFromParentAndCleanup(true)
	self.msgIcon_2:getChildByName("icon"):removeFromParentAndCleanup(true)

	self.msgIcon_1:setVisible(false)
	self.msgIcon_2:setVisible(false)

	self.ios_ali_link = self.ui:getChildByName('ios_ali_link')
	self.ios_ali_link:setVisible(false)

	self.useTipLabel = self.ui:getChildByName("use_tip")
	self.useTipLabel:setVisible(false)

	--动画
	if not self.animalAnimetionCreator then
		self.animalAnimetionCreator = EndGamePropBasePanelNormalAnimalAnimetionCreator
	end

	local anim , animOffX , animOffY , autoScale = self.animalAnimetionCreator:createAnime(self.propId)
	self:createAnime( anim , animOffX , animOffY , autoScale )
	self.cryingAnimation:setScale( self.cryingAnimation:getScale() * 1.3 )
	self.cryingAnimation:setPositionX( self.cryingAnimation:getPositionX() - 25 )
	self.cryingAnimation:setPositionY( self.cryingAnimation:getPositionY() + 15 )


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

		if self.propId == ItemType.ADD_FIVE_STEP then
			local uid = UserManager:getInstance().uid
			if self.lastGameIsFUUU then
					--printx( 1 , "   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  222  " , self.lastGameIsFUUU )
					if self.fuuuData then

						self.msgLabel:setVisible(false)
						self.msgLabel_new1:setVisible(true)
						self.msgLabel_new2:setVisible(true)
						self.msgIcon_1:setVisible(true)
						self.msgIcon_2:setVisible(true)

						local iconIndex = 1
						local targetTooMuch = false

						local function buildTargetIcon(k1,k2,k3,diff)

							if iconIndex > 2 then 
								targetTooMuch = true
								return 
							end
							iconIndex = iconIndex + 1

							if not (k1 and k2 and k3) then 
								targetTooMuch = true
								return 
							end

							printx( 1 , "   FUUUManager:getTargetIconByFuuuType ~~~  k1:" , k1 , " k2:" , k2 , " k3:" , k3 , " diff:" , diff)
							local iconContainner = Layer:create()
							local targetIcon = FUUUManager:getTargetIconByFuuuType( k2 , k3 )
							if not targetIcon then
								targetTooMuch = true
								return 
							end
							--targetIcon:setPositionXY( self["msgIconPos_" .. tostring(iconIndex - 1)].x , self["msgIconPos_" .. tostring(iconIndex - 1)].y )
							local _baseScale = 1.2
							targetIcon:setScale(_baseScale)
							self["msgIcon_" .. tostring(iconIndex - 1)]:addChildAt( targetIcon , 0 )
							self["msgIcon_label" .. tostring(iconIndex - 1)]:setText(tostring(diff))
							--self["msgIcon_label" .. tostring(iconIndex - 1)]:setString(tostring(diff))


							local actionArray = CCArray:create()
							actionArray:addObject( CCDelayTime:create(0.5) )
							actionArray:addObject( CCEaseSineOut:create( CCScaleTo:create(0.2 , _baseScale * 1.8 ,  _baseScale * 1.8 ) ) )
							actionArray:addObject( CCEaseSineOut:create( CCScaleTo:create(0.2 , _baseScale * 0.8 ,  _baseScale * 0.8 ) ) )
							actionArray:addObject( CCEaseSineOut:create( CCScaleTo:create(0.2 , _baseScale * 1.1 ,  _baseScale * 1.1 ) ) )
							actionArray:addObject( CCEaseSineOut:create( CCScaleTo:create(0.2 , _baseScale ,  _baseScale ) ) )
							actionArray:addObject( CCCallFunc:create(function()
								                     	self.cryingAnimation.animNode:playByIndex(0)
								                     	if self.buyButton then
								                     		self.buyButton:useBubbleAnimation()
								                     	end
									                end))
							local seq 	= CCSequence:create(actionArray)
							self["msgIcon_" .. tostring(iconIndex - 1)]:runAction(seq)
						end

						--printx( 1 , "   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  333  " , #self.fuuuData )
						for ka,va in ipairs(self.fuuuData) do

							--test need remove late
							if va.isFuuuDone then

								local _k1 = va.ty
								local _k2 = nil
								local _k3 = nil
								local _diff = nil

								--printx( 1 , "   !!!!!!!!!!!!!!!!!!!   333.1  okey1 = " , va.okey1 , "  okey2 = " , va.okey2)
								if va.okey1 then _k2 = va.okey1 end
								if va.okey2 then 
									_k3 = va.okey2 
									_diff = va.tv - va.cv
									if _diff > 0 then
										buildTargetIcon(_k1 , _k2 , _k3 , _diff)
									end
								elseif va.cld then
									for kb,vb in ipairs(va.cld) do
										_k3 = vb.k2
										_diff = vb.tv - vb.cv
										if _diff > 0 then
											buildTargetIcon(_k1 , _k2 , _k3 , _diff)
										end
									end
								else
									--printx( 1 , "  !!!!!!!!!!!!!!!!!!!   333.2 " , table.tostring(va)  )
									_k3 = 0
									if va.tv > 0 then
										_diff = va.tv - va.cv
									else
										_diff = va.cv
									end
									
									if _diff > 0 then
										buildTargetIcon(_k1 , _k2 , _k3 , _diff)
									else
										targetTooMuch = true
									end
								end
							end	
						end

						--printx( 1 , "   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  444  " , iconIndex , targetTooMuch )

						if iconIndex == 2 then
							self.msgIcon_1:setPositionX( self.msgIcon_1:getPositionX() + 40 )
							self.msgLabel_new1:setPositionX( self.msgLabel_new1:getPositionX() + 40 )
							self.msgLabel_new2:setPositionX( self.msgLabel_new2:getPositionX() - 40 )
						end

						--test need remove late
						if targetTooMuch then
							self.msgLabel_new1:setVisible(false)
							self.msgLabel_new2:setVisible(false)
							self.msgIcon_1:setVisible(false)
							self.msgIcon_2:setVisible(false)

							self.msgLabel:setVisible(true)
							self.msgLabel:setString(Localization:getInstance():getText("add.step.panel.msg.txt.new"))
						else
							self.showFuuuTipMode = true
						end
					else
						self.msgLabel:setString(Localization:getInstance():getText("add.step.panel.msg.txt.new"))
					end
			else
				self.msgLabel:setString(Localization:getInstance():getText("add.step.panel.msg.txt.new"))
			end
		else
			self.msgLabel:setString(Localization:getInstance():getText("add.step.panel.msg.txt."..self.propId))
		end
	end

	if self.showFuuuTipMode then
		self.cryingAnimation.animNode:stop()
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
	printx( 101 , "   EndGamePropBasePanel_VerB:init  propNum = " .. tostring(propNum))
	local propNeedBuy = false
	if self.levelType == GameLevelType.kOlympicEndless or self.levelType == GameLevelType.kMidAutumn2018 then
		propNum = 0
	end

	--test need remove late
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
		self.buyButton.groupNode:stopAllActions()
		self.countdownLabel:setPositionX(521)

	end


	LotteryLogic:setLotteryTime(Localhost:time())
	self.lotteryMode = self:calcLotteryMode()


	if self.lotteryMode then
		if self.lotteryBtnUI then
			self.lotteryBtn = 	GroupButtonBase:create(self.lotteryBtnUI)
			self.lotteryBtn:useBubbleAnimation()
			self.lotteryBtn:ad(DisplayEvents.kTouchTap, function ( ... )
				if self.isDisposed then return end
				self:onLotteryBtnTapped()
			end)

			local dot = getRedNumTip()
			dot:setScale(1/0.6)
			dot:setPosition(ccp(230, 60))
			self.lotteryBtnUI:addChild(dot)
			self.lotteryBtnDot = dot

			self:refreshLotteryBtn()
		end
	else
		if self.lotteryBtnUI then
			self.lotteryBtnUI:setVisible(false)
		end
	end

	--[[
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
	]]

	if self.hasPreBuff and PreBuffLogic:isActOn() then
		self:hideNormalBubble()
		if self.ui:getChildByName('prebuff') then
			local grade = PreBuffLogic:getBuffGradeAndConfig()

			local style = PreBuffLogic:getStyle() or 1

			local targetIconGroup = 'icon00' .. style

			for k = 1, 2 do
				local otherIconGroup = 'icon00' .. k
				if otherIconGroup == targetIconGroup then
					for i=1,5 do
						self.ui:getChildByName('prebuff'):getChildByName(otherIconGroup):getChildByName(tostring(i)):setVisible(i == grade)
					end
				else
					self.ui:getChildByName('prebuff'):getChildByName(otherIconGroup):removeFromParentAndCleanup(true)
				end
			end

			local prebuffUI=self.ui:getChildByName('prebuff')
			prebuffUI:setScale(0)
			local arr = CCArray:create()
			arr:addObject(CCDelayTime:create(0.2))
			arr:addObject(CCScaleTo:create(0.3, 1))
			prebuffUI:runAction(CCSequence:create(arr))
			local arr2 = CCArray:create()
			arr2:addObject(CCDelayTime:create(0.5))
			arr2:addObject(CCScaleTo:create(0.05, 1.2))
			arr2:addObject(CCScaleTo:create(0.05, 1.0))
			arr2:addObject(CCScaleTo:create(0.05, 1.2))
			arr2:addObject(CCScaleTo:create(0.05, 1.0))
			local iconUI = prebuffUI:getChildByName(targetIconGroup)
			iconUI:runAction(CCSequence:create(arr2))

		end
	else
		if self.ui:getChildByName("prebuff") then
			self.ui:getChildByName("prebuff"):setVisible(false)
		end
	end

	if not propNeedBuy then 
		--非购买的加五步 倒计时处理再这里 购买的时候~在对应平台的加五步面板init里
		self:updateCountdownShow()
	end

	require('zoo.panel.endGameProp.lottery.BuyDiamondObserver'):addObserver(self)
    require('zoo.panel.endGameProp.lottery.CashObserver'):addObserver(self)

    self:handleActCountdownParty()
	return propNeedBuy
end


function EndGamePropBasePanel_VerB:calcLotteryMode( )

	local propNum = EndGamePropManager.getInstance():getItemNum(self.propId)
	local topLevel = UserManager.getInstance().user:getTopLevelId()
	local isAddStepProp = (self.propId == ItemType.ADD_FIVE_STEP)
	local isSupportedLevelType = table.exist({
		GameLevelType.kMainLevel, 
		GameLevelType.kHiddenLevel,
	}, self.levelType)

	
	if LotteryLogic:getLeftFreeDrawCount() > 0 and isAddStepProp and isSupportedLevelType and topLevel > 20 then
		return LotteryLogic.MODE.kFREE
	end

	if propNum <= 0 and topLevel > 20 and isAddStepProp and isSupportedLevelType then
		return LotteryLogic.MODE.kNORMAL
	end
end

function EndGamePropBasePanel_VerB:hideNormalBubble()
	self.ui:getChildByName("msgIcon_1"):setVisible(false)
	self.ui:getChildByName("msgIcon_2"):setVisible(false)
	self.ui:getChildByName("msgLabel_new1"):setVisible(false)
	self.ui:getChildByName("msgLabel_new2"):setVisible(false)
	self.ui:getChildByName("msgLabel"):setVisible(false)
	self.ui:getChildByName("use_tip"):setVisible(false)
	self.ui:getChildByName("_bubble"):setVisible(false)
end

function EndGamePropBasePanel_VerB:handleActCountdownParty()
	if CountdownPartyManager.getInstance():isActivitySupport() then
		local effLv = CountdownPartyManager.getInstance():getEffectLevelId()
		if effLv and self.levelId and effLv == self.levelId then 
			local mainLogic = GameBoardLogic:getCurrentLogic()
			if mainLogic then 
				local actCollectionNum = mainLogic.actCollectionNum
				if actCollectionNum and actCollectionNum > 0 then 
					local actCountdownPartyUI = self:buildInterfaceGroup("act_countdown_party_add5/act_countdown_party_part")
					local ActCollectionAddFivePart = require 'zoo.localActivity.CountdownParty.ActCollectionAddFivePart'
					self.actCountdownParty = ActCollectionAddFivePart:create(actCountdownPartyUI, actCollectionNum)
					self.ui:addChild(self.actCountdownParty)
					local size = self.actCountdownParty:getGroupBounds().size
					local uiSize = self:getGroupBounds().size
					self.actCountdownParty.ui:setPosition(ccp((uiSize.width - size.width)/2, size.height))
				end
			end
		end 
	end

--    if Qixi2018CollectManager.getInstance():isActivitySupport() then
--		local effLv = Qixi2018CollectManager.getInstance():getEffectLevelId()
--		if effLv and self.levelId and effLv == self.levelId then 
--			local mainLogic = GameBoardLogic:getCurrentLogic()
--			if mainLogic then 
--				local actCollectionNum = mainLogic.actCollectionNum
--				if actCollectionNum and actCollectionNum > 0 then 
--					local actCountdownPartyUI = self:buildInterfaceGroup("act_countdown_party_add5/act_countdown_party_part")
--					local ActCollectionAddFivePart = require 'zoo.localActivity.Qixi2018.Qixi2018CollectAddFivePart'
--					self.actCountdownParty = ActCollectionAddFivePart:create(actCountdownPartyUI, actCollectionNum)
--					self.ui:addChild(self.actCountdownParty)
--					local size = self.actCountdownParty:getGroupBounds().size
--					local uiSize = self:getGroupBounds().size
--					self.actCountdownParty.ui:setPosition(ccp((uiSize.width - size.width)/2, size.height))
--				end
--			end
--		end 
--	end

    if Thanksgiving2018CollectManager.getInstance():isActivitySupport() then
		local effLv = Thanksgiving2018CollectManager.getInstance():getEffectLevelId()
		if effLv and self.levelId and effLv == self.levelId then 
			local mainLogic = GameBoardLogic:getCurrentLogic()
			if mainLogic then 
				local actCollectionNum = mainLogic.actCollectionNum
				if actCollectionNum and actCollectionNum > 0 then 
					local actCountdownPartyUI = self:buildInterfaceGroup("act_countdown_party_add5/act_countdown_party_part")
					local ActCollectionAddFivePart = require 'zoo.localActivity.Thanksgiving2018.Thanksgiving2018CollectAddFivePart'
					self.actCountdownParty = ActCollectionAddFivePart:create(actCountdownPartyUI, actCollectionNum)
					self.ui:addChild(self.actCountdownParty)
					local size = self.actCountdownParty:getGroupBounds().size
					local uiSize = self:getGroupBounds().size
					self.actCountdownParty.ui:setPosition(ccp((uiSize.width - size.width)/2, size.height))
				end
			end
		end 
	end
end

function EndGamePropBasePanel_VerB:onLotteryBtnTapped( showGuide )


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


			self:useProp(rewardItem.itemId, function ( ... )
				
				if self.isDisposed then return end

				if self.onUseTappedCallback then
					self.onUseTappedCallback(rewardItem.itemId, UsePropsType.NORMAL, true)
				end

				self:remove(false)

			end)

		end

	end)
	panel:popout()



end

function EndGamePropBasePanel_VerB:refreshLotteryBtn( ... )
	-- if _G.isLocalDevelopMode then printx(101, "  " , debug.traceback() ) end
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
		self.lotteryBtnDot:setNum(LotteryLogic:getLeftFreeDrawCount())
		if LotteryLogic:getLeftFreeDrawCount() > 0 then
			color = kGroupButtonColorMode.green
		end
	end
	local groupBoundsSize = self.lotteryBtn.groupNode:getGroupBounds().size
	if _G.isLocalDevelopMode then printx(101, "refreshLotteryBtn groupBoundsSize width =  " , groupBoundsSize.width  ) end
	self.lotteryBtnDot:setPositionX(groupBoundsSize.width /2 )

	local propIcon = self.lotteryBtn.groupNode:getChildByPath('propIcon')
	if propIcon then
		propIcon:setPositionX( -groupBoundsSize.width/2 -70)
	end

	self.lotteryBtn:setColorMode(color)

end

function EndGamePropBasePanel_VerB:getUIGroupName()
	return "newAddStepPanel_newDrak"
end

function EndGamePropBasePanel_VerB:checkTestGroup()
	return "drak"
end


function EndGamePropBasePanel_VerB:reBecomeTopPanel( ... )
	-- body
	if EndGamePropBasePanel.reBecomeTopPanel then
		EndGamePropBasePanel.reBecomeTopPanel(self, ...)
	end

	if self.lotteryBtn then
	end
end

function EndGamePropBasePanel_VerB:popout()
	if _G.isLocalDevelopMode then printx(0, 'EndGamePropBasePanel_VerB:popout()') end

	local function callback()
		self:updateFuuuTargetShow(true)
		self:popoutFinishCallback()

		if EndGamePropManager.getInstance():getItemNum(self.propId) <= 0 then
  			RealNameManager:addConsumptionLabelToPanel(self, false)
  		end
	end
	if type(self.onPanelWillPopout) == "function" then
		self.onPanelWillPopout(self)
	end

	local function doPopout( ... )
		if self.isDisposed then return end
		self.panelPopRemoveAnim:popout(callback, true , true)
	end

	doPopout()

end

function EndGamePropBasePanel_VerB:dispose( ... )
	EndGamePropBasePanel.dispose(self, ...)
    require('zoo.panel.endGameProp.lottery.BuyDiamondObserver'):removeObserver(self)
    require('zoo.panel.endGameProp.lottery.CashObserver'):removeObserver(self)
    LotteryLogic:setLotteryTime()
end

function EndGamePropBasePanel_VerB:onCashNumChange( ... )
end

function EndGamePropBasePanel_VerB:onDiamondChanged( ... )
    if self.isDisposed then return end
    self:refreshLotteryBtn()
end


function EndGamePropBasePanel_VerB:popoutFinishCallback()
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


end


local function memoryOriPos( node )
	if not node then return end
	if not node._oriPos then
		local pos = node:getPosition()
		node._oriPos = ccp(pos.x, pos.y)
	end
end

function EndGamePropBasePanel_VerB:onCountdownComplete(showAnime)
	if self.isDisposed then return end
	self.countdownLabel:setVisible(false)

	local buyUseBtnFixY = 45
	local moneyBarFixY = 25
	local lotteryBtnFixY = 0
	local iosAliLinkFixY = 0
	local quickPayLabelFix = 0


	if self.lotteryBtn then

		memoryOriPos(self.lotteryBtn)

		buyUseBtnFixY = 95
		moneyBarFixY = 95
		lotteryBtnFixY = -55
		lotteryBtnFixX = 0
		iosAliLinkFixY = 95
		quickPayLabelFix = 95

		local propNum = EndGamePropManager.getInstance():getItemNum(self.propId)
		if self.lotteryMode == LotteryLogic.MODE.kFREE and propNum > 0 then
			lotteryBtnFixX = 16
		end

		if self.lotteryBtn and self.lotteryBtn.groupNode and self.lotteryBtn.groupNode.parent ~= nil then
			self.lotteryBtn:setPositionY(self.lotteryBtn._oriPos.y + lotteryBtnFixY)
			-- self.lotteryBtn:setPositionX(self.lotteryBtn._oriPos.x + lotteryBtnFixX)
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

	local iosLink = self.ui:getChildByName('ios_ali_link')
	if iosLink then
		memoryOriPos(iosLink)
		iosLink:setPositionY(iosLink._oriPos.y + iosAliLinkFixY)
	end

	local quickPayLabel = self.ui:getChildByName('labelAliQuickPay')
	if quickPayLabel then
		memoryOriPos(quickPayLabel)
		quickPayLabel:setPositionY(quickPayLabel._oriPos.y + quickPayLabelFix)
	end
end