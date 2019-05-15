local CommonLogic = class()

function CommonLogic:create(ui)
	local logic = CommonLogic.new()
	logic.ui = ui
	logic:initData()
	logic:initUI()
end

function CommonLogic:initData()
	self.maxKeyCount = 4
	self.manager = SeasonWeeklyRaceManager:getInstance()
	self.lottery = self.manager.lottery
	self.manager:updateGotExtraTargetNum()
	self.localKey = 'week.race.2017.'..UserManager:getInstance():getUID()
	self.isHaveShow = CCUserDefault:sharedUserDefault():getBoolForKey(self.localKey, false)
end

function CommonLogic:initUI()
	self.ui.info1 = self.ui.ui:getChildByName("info1")
	self.ui.info2 = self.ui.ui:getChildByName("info2")
	self.ui.key1 = self.ui.ui:getChildByName("key1")
	self.ui.key3 = self.ui.ui:getChildByName("key3")
	self.ui.reward1 = self.ui.ui:getChildByName("reward1")
	self.ui.reward2 = self.ui.ui:getChildByName("reward2")
	self.ui.reward3 = self.ui.ui:getChildByName("reward3")
	self.ui.reward4 = self.ui.ui:getChildByName("reward4")
	self.ui.key1_tf = self.ui.ui:getChildByName("key1_tf")
	self.ui.bar = self.ui.ui:getChildByName("bar")
	self.ui.tip1 = self.ui.ui:getChildByName("tip1")
	self.ui.tip2 = self.ui.ui:getChildByName("tip2")
	self.ui.tip1_tf = self.ui.ui:getChildByName("tip1_tf")
	self.ui.tip2_tf = self.ui.ui:getChildByName("tip2_tf")
	self.ui.tip3_tf = self.ui.ui:getChildByName("tip3_tf")
	self.ui.tip5 = self.ui.ui:getChildByName("_bubble")
	self.ui.moneyBar = self.ui.ui:getChildByName("moneyBar")
	self.ui.icon = self.ui.ui:getChildByName("icon")
	self.ui.bg = self.ui.ui:getChildByName("bg")

	self.ui.bg:setScaleX(500)
	self.ui.bg:setScaleY(500)
	self.ui.bg:setPosition(ccp(-1000, 1000))
	self.ui.info1:changeFntFile('fnt/2017winterweek3.fnt')
	self.ui.info1:setText('您当前拥有：')
	self.ui.info2:changeFntFile('fnt/2017winterweek3.fnt')
	self.ui.info2:setText('获得钥匙后可抽取：')
	self.ui.tip1_tf:changeFntFile('fnt/register2.fnt')
	self.ui.tip1_tf:setText('马上就能拿到钥匙了，继续闯关吧！')
	self.ui.tip2_tf:changeFntFile('fnt/register2.fnt')
	self.ui.tip2_tf:setText('获得的奖励将会暂存，关卡结算后一起发放！')
	self.ui.tip3_tf:changeFntFile('fnt/register2.fnt')
	self.ui.tip3_tf:setText('继续闯关创造更高成绩吧！')
	self.ui.key1_tf:changeFntFile('fnt/2017winterweek3.fnt')
	self.ui.key1_tf:setText('x'..self.manager:getLeftExtraTargetNum())
	if self.manager:getGotExtraTargetNum() < self.maxKeyCount then
		local targetNum = GameBoardLogic:getCurrentLogic().digJewelCount:getValue()
		local targetInfo = self.manager:getNextExtraTargetInfo(targetNum)
		local txt = self.ui.bar:getChildByName('txt')
		txt:changeFntFile('fnt/real_name.fnt')
		txt:setText(targetNum..'/'..targetInfo.itemNum)
		txt:setScale(1.3)

		local bg = self.ui.bar:getChildByName('bg')
		local progressMask = Sprite:createWithSpriteFrameName('week_race_end_game/pro_mc0000')
		--progressMask:setPosition(ccp(0, -1))
  		local progressClippingNode = ClippingNode.new(CCClippingNode:create(progressMask.refCocosObj))
		bg:addChild(progressClippingNode)
		
		progressClippingNode:setPosition(ccp(191, 25))
		progressClippingNode:setInverted(false)
		progressClippingNode:setAnchorPoint(ccp(0, 0))
		progressClippingNode:ignoreAnchorPointForPosition(false)
		progressClippingNode:setAlphaThreshold(0.5)

		local progressSprite = Sprite:createWithSpriteFrameName('week_race_end_game/pro_mc0000')
		progressClippingNode:addChild(progressSprite)
		progressSprite:setPositionX((targetNum / targetInfo.itemNum - 1) * 374)
	end

	for i = 1, 4 do
		local rewardItem = self.ui['reward'..i]
		local item = rewardItem:getChildByName('item')
		local reward = self.lottery.rewards[i]
		local rewardIcon = self:getRewardIcon(reward)
		rewardItem.reward = reward
		rewardIcon:setScale(0.8)
		rewardItem:getChildByName('get'):setVisible(false)
		rewardIcon:setPosition(ccp(80, -18))
		item:addChild(rewardIcon)
	end

	for i = 1, 4 do
		local layer = Layer:create()
		layer:setPosition(ccp(214 + ((i + 1) % 2) * 318, -686 - math.floor((i - 1) / 2) * 238))
		layer.skeleton = self:getBoxSkeleton()
		layer:addChild(layer.skeleton)
		layer:setTouchEnabled(true)
		layer:setVisible(false)
		layer:ad(DisplayEvents.kTouchTap, function()
			if self.manager:getLeftExtraTargetNum() > 0 then
				self:openBox(i)
				self.manager:setUseExtraTargetNum(1)
				self.ui.key1_tf:setText('x'..self.manager:getLeftExtraTargetNum())
				self:addHand()
			else
				CommonTip:showTip(localize("weeklyrace.winter.lottery.tip1"), "negative")
			end
		end)
		self.ui:addChild(layer) 
		self.ui['box'..i] = layer

		local boxReward = self.lottery:getBoxReward(i)
		if boxReward then
			self:openBox(i, true)
		end
	end

	self.ui.all_btn = GroupButtonBase:create(self.ui.ui:getChildByName("all_btn"))
    self.ui.all_btn:setString("开启")
    self.ui.all_btn:setColorMode(kGroupButtonColorMode.green)
	self.ui.all_btn:ad(DisplayEvents.kTouchTap, function()
		for num = 1, self.manager:getLeftExtraTargetNum() do 
			for i = 1, 4 do
				if not self.lottery:getBoxReward(i) then 
					self:openBox(i)
					self.manager:setUseExtraTargetNum(1)
					self.ui.key1_tf:setText('x'..self.manager:getLeftExtraTargetNum())
					break
				end
			end
		end
		self:addHand()
	end)

	if self.manager:getLeftExtraTargetNum() <= 0 then
		self:setState(3)
	else
		if self.manager:getGotExtraTargetNum() == self.manager:getLeftExtraTargetNum() then 
			self:setState(1)
		else
			self:setState(2)
		end
	end
end

function CommonLogic:setState(state)
	local function delayVisible()
		local function doAction(ui, time)
			ui:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(time), CCCallFunc:create(function()
				ui:setVisible(true)
			end)))
		end
		doAction(self.ui.reward1, 0.2)
		doAction(self.ui.reward2, 0.4)
		doAction(self.ui.reward3, 0.6)
		doAction(self.ui.reward4, 0.8)
	end

	local function setBoxsState(bVisible)
		for i = 1, 4 do 
			self.ui['box'..i]:setVisible(bVisible)
		end
	end

	if state == 1 then 
		self.ui.info1:setVisible(true)
		self.ui.info2:setVisible(false)
		self.ui.key1:setVisible(true)
		self.ui.key3:setVisible(false)
		self.ui.reward1:setVisible(false)
		self.ui.reward2:setVisible(false)
		self.ui.reward3:setVisible(false)
		self.ui.reward4:setVisible(false)
		self.ui.key1_tf:setVisible(true)
		self.ui.bar:setVisible(false)
		self.ui.icon:setVisible(not self.isHaveShow)
		self.ui.tip1:setVisible(false) 
		self.ui.tip2:setVisible(not self.isHaveShow)
		self.ui.tip5:setVisible(false)
		self.ui.all_btn:setVisible(false)
		self.ui.rewardSkeleton = self:getRewardSkeleton()
		self.ui:addChild(self.ui.rewardSkeleton)
		self.ui.msgLabel_new1:setVisible(false)
		self.ui.msgLabel_new2:setVisible(false)
		self.ui.msgLabel:setVisible(false)
		self.ui.countdownLabel:setVisible(false)
		self.ui.buyButtonUI:setVisible(false)
		self.ui.useButtonUI:setVisible(false)
		self.ui.cryingAnimation:setVisible(false)
		self.ui.moneyBar:setVisible(false)
		self.ui.closeBtn:setVisible(false)
		self.ui.tip1_tf:setVisible(false)
		self.ui.tip2_tf:setVisible(false)
		self.ui.tip3_tf:setVisible(false)
	elseif state == 2 then
		self.ui.info1:setVisible(true)
		self.ui.info2:setVisible(false)
		self.ui.key1:setVisible(true)
		self.ui.key3:setVisible(false)
		if not self.ui.reward1:isVisible() then 
			delayVisible()
		end
		self.ui.bar:setVisible(false)
		self.ui.tip1:setVisible(false)
		self.ui.tip2:setVisible(false)
		self.ui.tip5:setVisible(false)
		self.ui.all_btn:setVisible(true)
		self.ui.icon:setVisible(false)
		self.ui.msgLabel_new1:setVisible(false)
		self.ui.msgLabel_new2:setVisible(false)
		self.ui.msgLabel:setVisible(false)
		self.ui.countdownLabel:setVisible(false)
		self.ui.buyButtonUI:setVisible(false)
		self.ui.useButtonUI:setVisible(false)
		self.ui.cryingAnimation:setVisible(false)
		self.ui.moneyBar:setVisible(false)
		self.ui.closeBtn:setVisible(false)
		self.ui.tip1_tf:setVisible(false)
		self.ui.tip2_tf:setVisible(true)
		self.ui.tip3_tf:setVisible(false)
		setBoxsState(true)
		self:addHand()
	elseif state == 3 then
		if not self.ui.reward1:isVisible() then 
			delayVisible()
		end
		if self.manager:getGotExtraTargetNum() < self.maxKeyCount then
			self.ui.bar:setVisible(true)
			self.ui.key3:setVisible(true)
		end	
		setBoxsState(false)
		self.ui.tip1:setVisible(true)
		self.ui.tip2:setVisible(false)
		self.ui.tip5:setVisible(false)
		self.ui.all_btn:setVisible(false)
		self.ui.msgLabel_new1:setVisible(false)
		self.ui.msgLabel_new2:setVisible(false)
		self.ui.msgLabel:setVisible(false)
		self.ui.countdownLabel:setVisible(false)
		self.ui.buyButtonUI:setVisible(false)
		self.ui.useButtonUI:setVisible(false)
		self.ui.cryingAnimation:setVisible(false)
		local propNum = EndGamePropManager.getInstance():getItemNum(self.ui.propId)
		if propNum > 0 then
			self.ui.useButtonUI:setVisible(true)
			self.ui.useButton:useBubbleAnimation()
		else
			self.ui.buyButtonUI:setVisible(true)
			if (not self.ui.adDecision) or (self.ui.adDecision == IngamePaymentDecisionType.kPayWithWindMill) then
				self.ui.moneyBar:setVisible(true)
			end
		end 
		self.ui.closeBtn:setVisible(true)
		if self.manager:getGotExtraTargetNum() < self.maxKeyCount then
			self.ui.tip1_tf:setVisible(true)
			self.ui.tip3_tf:setVisible(false)
		else
			self.ui.tip1_tf:setVisible(false)
			self.ui.tip3_tf:setVisible(true)
		end
		self.ui.tip2_tf:setVisible(false)

		if self.manager.isGotFreeProp then
			self.ui.icon:setVisible(true)
			self.ui.tip1:setVisible(true) 
			self.manager.isGotFreeProp = false
		else
			self.ui.icon:setVisible(false)
			self.ui.tip1:setVisible(false)
		end

		if self.manager:getGotExtraTargetNum() == 0 then 
			self.ui.info1:setVisible(false)
			self.ui.key1:setVisible(false)
			self.ui.key1_tf:setVisible(false)
			self.ui.info2:setVisible(true)
		else
			self.ui.info1:setVisible(true)
			self.ui.key1:setVisible(true)
			self.ui.key1_tf:setVisible(true)
			self.ui.info2:setVisible(false)
		end

		if self.manager:getGotExtraTargetNum() >= self.maxKeyCount then
			self.ui.useButtonUI:setPositionY(self.ui.useButtonUI:getPositionY() + 20)
			self.ui.buyButtonUI:setPositionY(self.ui.buyButtonUI:getPositionY() + 20)
			self.ui.moneyBar:setPositionY(self.ui.moneyBar:getPositionY() + 20)
		end
	end
end

function CommonLogic:openBox(i, bStop)
	local box = self.ui['box'..i]
	local reward
	if bStop then
		reward = self.lottery:getBoxReward(i)
		box.skeleton:playByIndex(1, 1)
	else
		reward = self.lottery:getNextBoxReward(i)
		box.skeleton:playByIndex(0, 1)
		ReplayDataManager:updateGamePlayContext()
		DcUtil:UserTrack({category = "weeklyrace", 
			sub_category = "weeklyrace_spring_2018_stage_reward", 
			level_id = GamePlayContext:getInstance().levelInfo.levelId,
			prop_id = reward.id,
			num = reward.num})
	end
	
	local rewardIcon = self:getRewardIcon(reward)
	rewardIcon:setPosition(ccp(-20, 210))
	box:addChild(rewardIcon)
	box:setTouchEnabled(false)

	for i = 1, 4 do
		local rewardItem = self.ui['reward'..i]
		if rewardItem.reward.index == reward.index then
			rewardItem:getChildByName('get'):setVisible(true)
			break
		end
	end
end

function CommonLogic:getRewardSkeleton()
	local function finishCallback()
		if not self.isHaveShow then
			self.ui.ui:setTouchEnabled(true)
			self.ui.ui:ad(DisplayEvents.kTouchTap, function()
				CCUserDefault:sharedUserDefault():setBoolForKey(self.localKey, true)
				self.isHaveShow = true
				self.ui.ui:setTouchEnabled(false)
				self.ui.rewardSkeleton:play(2, 1)
				self.playIndex = 2 
			end) 
		else
			if self.playIndex == 1 then
				self.ui.rewardSkeleton:play(2, 1)
				self.playIndex = 2 
			else
				self.ui:removeChild(self.ui.rewardSkeleton)

				if self.manager:getLeftExtraTargetNum() > 0 then 
					self:setState(2)
				else
					self:setState(3)
				end
			end
		end
	end

	FrameLoader:loadArmature("flash/weekly/week_race_end_game_skeleton", "week_race_end_game_skeleton", "week_race_end_game_skeleton")
	local sprite = ArmatureNode:create("week_race_end_game/lottery1")
	for i = 1, 4 do
		local item = sprite:getCon('item'..i)
		local reward = self.lottery.rewards[i]
		local rewardIcon = self:getRewardIcon(reward, true)
		rewardIcon:setPosition(ccp(140, 125))
		item:addChild(rewardIcon.refCocosObj)
	end
	sprite:addEventListener(ArmatureEvents.COMPLETE, finishCallback)
	sprite:play(1, 1)
	sprite:update(0.001)
	sprite:setPosition(ccp(232, -560))
	self.playIndex = 1
	return sprite
end

function CommonLogic:getBoxSkeleton()
	local function finishCallback()
		if self.manager:getLeftExtraTargetNum() <= 0 then
			self.ui:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1), CCCallFunc:create(function()
				self:setState(3)
			end)))
		end
	end
	FrameLoader:loadArmature("flash/weekly/week_race_end_game_skeleton", "week_race_end_game_skeleton", "week_race_end_game_skeleton")
	local sprite = ArmatureNode:create("week_race_end_game/lottery2")
	sprite:addEventListener(ArmatureEvents.COMPLETE, finishCallback)
	sprite:gotoAndStop('begin')
	sprite:update(0.001)
	return sprite
end

function CommonLogic:getRewardIcon(reward, bRotation)
	local layer = Layer:create()
	local icon = ResourceManager:sharedInstance():buildItemSprite(reward.id)
	icon:setScale(1.3)
	icon:setAnchorPoint(ccp(0.5, 0.5))
	layer:addChild(icon)
	local bitmapText = BitmapText:create('x' .. reward.num, 'fnt/level_seq_n_energy_cd.fnt')
	bitmapText:setScale(1.5)
	if bRotation then bitmapText:setRotation(-18) end
	bitmapText:setPosition(ccp(50, -40))
	layer:addChild(bitmapText)
	return layer
end

function CommonLogic:addHand()
	if self.ui.hand then 
		self.ui:removeChild(self.ui.hand)
		self.ui.hand = nil
	end

	if self.manager:getLeftExtraTargetNum() > 0 then 
		for i = 1, 4 do
			if not self.lottery:getBoxReward(i) then
				local box = self.ui['box'..i]
				local hand = GameGuideAnims:handclickAnim(delay, fade)
				hand:setPosition(ccp(box:getPositionX() - 10, box:getPositionY() + 140))
				self.ui.hand = hand
				self.ui:addChild(self.ui.hand)
				break
			end
		end
	end
end

WeekRaceEndGamePropIosPanel = class(EndGamePropIosPanel_VerB_old)

function WeekRaceEndGamePropIosPanel:create(levelId, levelType, propId, onUseCallback, onCancelCallback, useTipText, onPanelWillPopout)
    local panel = WeekRaceEndGamePropIosPanel.new()
    panel:loadRequiredResource("flash/weekly/week_race_end_game_panel.json")
    panel:initData(levelId, levelType, propId, onUseCallback, onCancelCallback, useTipText, onPanelWillPopout)
end

function WeekRaceEndGamePropIosPanel:onCashNumChange( ... )
	-- body
end

function WeekRaceEndGamePropIosPanel:getUIGroupName()
	return "week_race_end_game/panel"
end

function WeekRaceEndGamePropIosPanel:onCountdownComplete()
end

function WeekRaceEndGamePropIosPanel:popout()
	CommonLogic:create(self)
	self:setScale(1)
    self:setPositionXY(0, 0)
    UIUtils:adjustUI(self, 0)

	self:updateFuuuTargetShow(true)
	self:popoutFinishCallback()

	if type(self.onPanelWillPopout) == "function" then
		self.onPanelWillPopout(self)
	end

	PopoutManager:sharedInstance():add(self, true)

	local vs = Director:sharedDirector():getVisibleSize()
    local vo = Director:sharedDirector():getVisibleOrigin()
    local pos = ccp(vo.x + vs.width - 50, vo.y + vs.height - 50)
    self.closeBtn:setPosition(self:convertToNodeSpace(pos))

    if EndGamePropManager.getInstance():getItemNum(self.propId) <= 0 then
		RealNameManager:addConsumptionLabelToPanel(self, false)
	end
end


WeekRaceEndGamePropAndroidPanel = class(EndGamePropAndroidPanel_VerB_old)

function WeekRaceEndGamePropAndroidPanel:create(levelId, levelType, propId, onUseCallback, onCancelCallback, useTipText, onPanelWillPopout)
    local pGoodsId = nil
	local pShowType = nil 
	local animalCreator = nil

	local function popoutPanel(decision, paymentType, dcAndroidStatus, otherPaymentTable, repayChooseTable)
		if levelType == GameLevelType.kSpring2017 then
			decision = IngamePaymentDecisionType.kPayWithWindMill
		end
		
		local panel = WeekRaceEndGamePropAndroidPanel.new()
    	panel:loadRequiredResource("flash/weekly/week_race_end_game_panel.json")
		panel.levelId = levelId
		panel.propId = propId
		panel.levelType = levelType
		panel.onUseTappedCallback = onUseCallback
		panel.onCancelTappedCallback = onCancelCallback
		panel.onPanelWillPopout = onPanelWillPopout
		
		panel.adDecision = decision
		panel.adPaymentType = paymentType
		panel.dcAndroidStatus = dcAndroidStatus
		panel.adRepayChooseTable = repayChooseTable

		panel.goodsId = pGoodsId
		panel.showType = pShowType

		local isFUUU , fuuuId , fuuuData = FUUUManager:lastGameIsFUUU(true)
		panel.lastGameIsFUUU = isFUUU
		panel.fuuuLogID = fuuuId
		panel.fuuuData = fuuuData

		panel.animalAnimetionCreator = animalCreator

		panel:init() 
		if type(useTipText) == "string" then
			panel:setUseTipText(useTipText)
			panel:setUseTipVisible(true)
		end

		panel:dcPanelShow()

		self.isFUUU = isFUUU
		self.levelId = levelId

		CommonLogic:create(panel)
		panel:popout() 
	end
 
	pGoodsId, pShowType = EndGamePropManager.getInstance():getAndroidBuyGoodsId(propId, levelId)
	PaymentManager.getInstance():getBuyItemDecision(popoutPanel, pGoodsId)
end


function WeekRaceEndGamePropAndroidPanel:onCashNumChange( ... )
	-- body
end

function WeekRaceEndGamePropAndroidPanel:getUIGroupName()
	return "week_race_end_game/panel"
end

function WeekRaceEndGamePropAndroidPanel:onCountdownComplete()
end

function WeekRaceEndGamePropAndroidPanel:popout()
	self:setScale(1)
    self:setPositionXY(0, 0)
    UIUtils:adjustUI(self, 0)

	self:updateFuuuTargetShow(true)
	self:popoutFinishCallback()
	self.allowBackKeyTap = false

	if type(self.onPanelWillPopout) == "function" then
		self.onPanelWillPopout(self)
	end

	PopoutManager:sharedInstance():add(self, true)

	local vs = Director:sharedDirector():getVisibleSize()
    local vo = Director:sharedDirector():getVisibleOrigin()
    local pos = ccp(vo.x + vs.width - 50, vo.y + vs.height - 50)
    self.closeBtn:setPosition(self:convertToNodeSpace(pos))

    if EndGamePropManager.getInstance():getItemNum(self.propId) <= 0 then
		RealNameManager:addConsumptionLabelToPanel(self, false)
	end
end
