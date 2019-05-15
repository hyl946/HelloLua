--[[
 * StarBank
 * @date    2017-12-11 15:02:33
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

require "zoo.panel.StarBank.StarBankDescPanel"

StarBankPanel = class(BasePanel)

function StarBankPanel:ctor( ... )
	-- body
end

function StarBankPanel:create( isPassLevel, closeCallBack)
	local panel = StarBankPanel.new()
	panel:loadRequiredResource("ui/star_bank_new.json")
	panel:init(isPassLevel, closeCallBack)
	return panel
end

function StarBankPanel:init( isPassLevel, closeCallBack)
	self.isPassLevel = isPassLevel
	self.closeCallBackFunc = closeCallBack

	self.ui = self:buildInterfaceGroup("StarBank/panel")
	BasePanel.init(self, self.ui)
	self.panelLuaName = "StarBankPanel"
	self.closeBtn = self.ui:getChildByName("close")
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function ()
		self:onCloseBtnTapped()
	end)
	self.closeBtn:setTouchEnabled(true)

	self.descBtn = self.ui:getChildByName("descBtn")
	self.descBtn:addEventListener(DisplayEvents.kTouchTap, function ()
		local panel = StarBankDescPanel:create()
		panel:popout()
	end)
	self.descBtn:setTouchEnabled(true)
	self:initBtn()

	for i=1,3 do
		local t = "tips"..i
		self[t] = TextField:createWithUIAdjustment(self.ui:getChildByName("tipsph"..i), self.ui:getChildByName("tips"..i))
		self.ui:addChild(self[t])
	end

	self:createBank()

    self:updateState()

    Notify:register("StarBankUpdateStateEvent", self.updateState, self)

    if _G.isLocalDevelopMode then
    	local btn = StarBankUnitTest:createTestButton("测试", hex2ccc3("FF0000"), 12, 60, 30)
		btn:addEventListener(DisplayEvents.kTouchTap, function()
			Notify:dispatch( "StarBankUnitTestEventInit")
		end)
		self.ui:addChild(btn)
    end
end

function StarBankPanel:initBtn()
	local btnwrap = self.ui:getChildByName('btn')

	local time = btnwrap:getChildByName("time")
	self.timeTxt = TextField:createWithUIAdjustment(time:getChildByName('ph'), time:getChildByName('time'))
    time:addChild(self.timeTxt)

   	local btn = GroupButtonBase:create(btnwrap:getChildByName("btn"))
	btn:ad(DisplayEvents.kTouchTap, function ( ... )
		self:onTouchBtn()
	end)

	local zhe = btnwrap:getChildByName("zhe")
	self.ori = btnwrap:getChildByName("ori")
	self.ori:setScale(0.6)
	self.zhe = zhe
	self.line = btnwrap:getChildByName("line")

	-- local array = CCArray:create()
	-- array:addObject(CCRotateTo:create(2/24.0, -9.2))
	-- array:addObject(CCRotateTo:create(3/24.0, 14.7))
	-- array:addObject(CCRotateTo:create(2/24.0, -11.2))
	-- array:addObject(CCRotateTo:create(2/24.0, 0))
	-- array:addObject(CCDelayTime:create(65/24.0))
	-- local scaleAction = CCSequence:create(array)
	-- self.zhe:runAction(CCRepeatForever:create(scaleAction))

	self.btn = btn
end

function StarBankPanel:setCloseDcType(t)
	self.closeDcType = t
end

function StarBankPanel:onCloseBtnTapped()
	StarBank:removePanel(self.closeDcType or -1, 1)
  	if self.closeCallBackFunc and type(self.closeCallBackFunc) == 'function' then
    	self.closeCallBackFunc()
    end
end

function StarBankPanel:remove()
	self.allowBackKeyTap = false
	Notify:unregister("StarBankUpdateStateEvent", self)
	PopoutManager:sharedInstance():remove(self, true)
	FrameLoader:unloadArmature('skeleton/StarBankNewAddStar', true)
end

function StarBankPanel:onTouchBtn()
	local state = StarBank.state
	if state == StarBankState.kEmpty or state == StarBankState.kNewBank then
		StarBank:removePanel()
	elseif state == StarBankState.kNotFullCanBuy 
		or state == StarBankState.kFullCanBuy
		or state == StarBankState.kCool
	then
		StarBank:buy()
		self.btn:setEnabled(false)
		setTimeOut(function ( ... )
			if self.isDisposed then return end
			self.btn:setEnabled(true)
		end, 3)
	end
end

local colors = {
	"blue",
	"green",
	"orange",
	"purple",
	"gold",
}

function StarBankPanel:updateTime()
	if self.isDisposed then return end
	local str,color = StarBank:getLeftTimeStrCol()
	self.timeTxt:setString(str)
	self.timeTxt:setColor(color)
end

function StarBankPanel:getDiscountNum( goodsId )
	local discountNum = self:getPrice(goodsId) * 10 / self:getOriPrice(goodsId)
	return string.format('%0.1f', discountNum)
end

function StarBankPanel:getPrice(goodsId)
	return MetaManager.getInstance():getGoodMeta(goodsId).thirdRmb / 100
end

function StarBankPanel:getOriPrice(goodsId)
	return MetaManager.getInstance():getGoodMeta(goodsId).rmb / 100
end

function StarBankPanel:playDiscountAnim( ... )
	if self.isDisposed then return end
	local array = CCArray:create()
	array:addObject(CCRotateTo:create(2/24.0, -9.2))
	array:addObject(CCRotateTo:create(3/24.0, 14.7))
	array:addObject(CCRotateTo:create(2/24.0, -11.2))
	array:addObject(CCRotateTo:create(2/24.0, 0))
	array:addObject(CCDelayTime:create(65/24.0))
	local scaleAction = CCSequence:create(array)
	self.discountContainerUI:runAction(CCRepeatForever:create(scaleAction))
end

function StarBankPanel:setDiscount(config)
	local discountNum = self:getDiscountNum(config.goodsId)

	if not self.discountUI then
		local discountContainerUI = self.ui:getChildByName('btn'):getChildByName('zhe')
		local discountUI = discountContainerUI:getChildByName('discount')

		self.discountUI = discountUI
		self.discountContainerUI = discountContainerUI
		self:playDiscountAnim()
	end

	if tonumber(discountNum) >= 10 then
		self.discountUI:setVisible(false)
	else
		local discountNumUI = self.discountUI:getChildByName("num")
		if not self.isf then
			discountNumUI:changeFntFile('fnt/discount55.fnt')
			discountNumUI:setRotation(28)
			discountNumUI:setAnchorPoint(ccp(0.5, 0.5))
		end

		local is = tonumber(discountNum) * 10 % 10 == 0
		if is then
			discountNumUI:setText(math.ceil(tonumber(discountNum)))
			discountNumUI:setScale(0.7)
		else
			discountNumUI:setText(discountNum)
			discountNumUI:setScale(0.47)
		end
		
		discountNumUI:setPosition(ccp(-52, 2))

		local discountTextUI = self.discountUI:getChildByName("text")

		if not self.isf then
			discountTextUI:setRotation(30)
		end
		discountTextUI:setScale(1.14)
		if is then
			discountTextUI:setPosition(ccp(-28, -4))
		else
			discountTextUI:setPosition(ccp(-22, -5))
		end
		
		self.isf = true
		discountTextUI:setText(Localization:getInstance():getText("buy.gold.panel.discount"))
	end
end

function StarBankPanel:updateState(pstate, state, isPassLevel)
	if self.isDisposed then return end
	local config = StarBank:getConfig()
	local state = StarBank.state
	local isFull = state == StarBankState.kFullCanBuy

	if isFull then
		self:updateTime()
	end

	self.timeTxt:setVisible(isFull)

	if pstate == StarBankState.kFullCanBuy and state == StarBankState.kCool then
		isFull = true
	end

	if not config then
		config = {}
	end

	if isPassLevel == nil then
		isPassLevel = self.isPassLevel
	end
	self:setBankState(state, config, isPassLevel)

	self.zhe:setVisible(isFull)
	self.ori:setVisible(isFull)
	self.line:setVisible(isFull)

	--button
	if state == StarBankState.kEmpty or state == StarBankState.kNewBank then
		self.btn:setString("知道了")
		self.btn:setColorMode(kGroupButtonColorMode.green)
	else
		if config and config.goodsId then
			local productMeta = MetaManager.getInstance():getProductMetaByID(config.goodsId)
			local priceLocale = nil

			local currencySymbol, isLongSymbol = BuyHappyCoinManager:getCurrencySymbol(priceLocale or 'cny')
			local showPrice = self:getPrice(config.goodsId)
			local oriPrice = self:getOriPrice(config.goodsId)

			self.ori:setText(string.format("原价：%s%.2f", currencySymbol, oriPrice))

			self:setDiscount(config)

			if isLongSymbol then
				self.btn:setString(string.format("%s%.0f", currencySymbol, showPrice))
			else
				self.btn:setString(string.format("%s%.2f", currencySymbol, showPrice))
			end
		end
		self.btn:setColorMode(kGroupButtonColorMode.blue)
	end

	local btnEnabled = state == StarBankState.kEmpty 
					or state == StarBankState.kNewBank 
					or state == StarBankState.kNotFullCanBuy
					or isFull

	self.btn:setEnabled(btnEnabled)

	local btn = self.ui:getChildByName('btn'):getChildByName("btn")

	if not btn.anim and state == StarBankState.kFullCanBuy then
		local sx = btn:getScaleX()
		local sy = btn:getScaleY()

		btn:runAction(CCRepeatForever:create(
			CCSequence:createWithTwoActions(
				CCScaleTo:create(20/24.0, 0.819/0.773*sx, sy),
				CCScaleTo:create(20/24.0, sx, sy)
			)
		))
		btn.anim = true
	end

	--tips
	local function SetString( key, p)
		local count = 0
		local tips = nil
		local txttips = nil
		for i=1,3 do
			local k = key.."_"..i
			local txt = localize(k, p)
			local ltips = self["tips"..i]
			if txt ~= k then
				count = count + 1
				tips = ltips
				txttips = txt

				ltips:setString(txt)

				local size = ltips:getGroupBounds().size
				local tipbg = self.ui:getChildByName("tipbg")
				local bgsize = tipbg:getPreferredSize()
				
				local intal = 60
				if bgsize.width < size.width + intal then
					local tsize = CCSizeMake(size.width + intal, bgsize.height)
					tipbg:setPreferredSize(tsize)
					local x = (tsize.width-bgsize.width)/2
					tipbg:setPositionX(tipbg:getPositionX() - x)
					self.tipPosx = x
				end

				ltips:setPositionX(ltips:getPositionX() - (self.tipPosx or 0))
				ltips:setPositionY(ltips:getPositionY() - 10)
				ltips:setVisible(true)
			else
				ltips:setVisible(false)
			end
		end
		if count == 1 and tips and tips.uiAdjustData and txttips then
			tips.uiAdjustData.hAlignment = kCCTextAlignmentCenter
			tips:setString(txttips)
		end
	end

	if state == StarBankState.kEmpty then
		SetString( "star.bank.desc1", {num = config.min})
	elseif state == StarBankState.kNotEnoughBuy then
		SetString( "star.bank.desc2", {num = config.min})
	elseif state == StarBankState.kNotFullCanBuy then
		SetString("star.bank.desc3", {num = config.max})
	elseif state == StarBankState.kFullCanBuy then
		SetString("star.bank.desc4")
	elseif state == StarBankState.kNewBank then
		SetString("star.bank.desc5", {num = config.min})
	end
end

function StarBankPanel:layout()
	local winSize = CCDirector:sharedDirector():getVisibleSize()

	local w = 720
	local h = 1280

	local r = winSize.height / h
	if r < 1.0 then
		self:setScale(r)
	end

	local x = self:getHCenterInParentX()
	local y = self:getVCenterInParentY()
	self:setPosition(ccp(x, y))

	local container = self:getParent()
	if container then
		container = container:getParent()
	end
	if container and container.darkLayer then
		container.darkLayer:setOpacity(200)
	end
end

function StarBankPanel:popoutShowTransition()
    self.allowBackKeyTap = true
    self:layout()
end

function StarBankPanel:popout()
	self.allowBackKeyTap = true
	PopoutQueue:sharedInstance():push(self, true, false)
end

function StarBankPanel:playAnimation( preStarNum, starNum, gainWm, pstate, cstate )
	printx(10, preStarNum, starNum, gainWm, pstate, cstate)

	local showStar = preStarNum
	for index=1,3 do
		self:setSlotVisible("star"..index, index <= starNum)
	end

	local maxStar = starNum > 3 and 3 or starNum
	for index = 1, 3 do
		local isShow = index > preStarNum and index <= maxStar
		for i=1,6 do
			local w = "wind"..index.."_"..i
			self:setSlotVisible(w, isShow)
		end
	end

	local anim = StarBank.state - 1

	if pstate == cstate and  StarBank.state == StarBankState.kFullCanBuy then
		anim = 4
	end

	self.animNode:play(tostring(anim))
	self.animNode:update(0.001)
	self.animNode:stop()
	self.animNode:setVisible(false)

	if anim ~= 4 then
		local slot = self.animNode:getSlot('coinnumber')
	    local coinnumber = self.builder:buildGroup("StarBank/coinnumber")
	    coinnumber:setAnchorPoint(ccp(0.5, 0.5))
	    local sprite = Sprite:createEmpty()
	    sprite:addChild(coinnumber)
	    self.coinnumber = coinnumber
	    coinnumber:setPosition(ccp(-35, -10))

	    self.addStarNum = TextField:createWithUIAdjustment(coinnumber:getChildByName("ph"), coinnumber:getChildByName("number"))
	    self.addStarNum:setString("+"..gainWm)
	    coinnumber:addChild(self.addStarNum)
	    slot:setDisplayImage(sprite.refCocosObj)

	    local delaytime = 0.4
	    self.addStarNum:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delaytime), CCFadeOut:create(0.1)))
	    coinnumber:getChildByName("coin"):runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delaytime), CCFadeOut:create(0.1)))
	else
		self:setSlotVisible("coinnumber", false)
	end

	local title = self.ui:getChildByName("title")
	self.ui:getChildByName("btn"):setVisible(false)
	title:setVisible(false)

	self.descBtn:setVisible(false)
	self.closeBtn:setVisible(false)
	self.ui:getChildByName("tipbg"):setVisible(false)
	for i=1,3 do
		self["tips"..i]:setOpacity(0)
	end

	local showStatic = pstate == cstate
	if showStatic and cstate == StarBankState.kFullCanBuy then
		-- showStatic = false
	end

	for i=1,4 do
		self:setSlotVisible("staticcoin"..i, showStatic)
	end

	local function fadeInFinished()
		local container = self:getParent()
		if container then
			container = container:getParent()
		end
		if container and container.darkLayer then
			container.darkLayer:setOpacity(200)
		end

		if StarBank.state == StarBankState.kFullCanBuy then
			self:runFullAction(preStarNum, starNum, gainWm, anim, pstate, cstate)
		else
			local function finishCallback( ... )
				self:onCloseBtnTapped()
			end

			self.animNode:setVisible(true)
			self.animNode:play(tostring(anim))
			self.animNode:addEventListener(ArmatureEvents.COMPLETE, finishCallback)

			self.ui:setTouchEnabled(true,0,true)
			self.ui:addEventListener(DisplayEvents.kTouchTap, function ( ... )
				self.animNode:unscheduleUpdate()
				local scheduleObj = CocosObject:create()
				
				scheduleObj:scheduleUpdateWithPriority(
					function()
						if self.animNode.isDisposed then return end
						self.animNode.refCocosObj:advanceTime(1/20)
					end
					,1)
				self.animNode:addChild(scheduleObj)
			end)
		end
	end
	-- self:popout()
	self.allowBackKeyTap = false
	-- PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false, fadeInFinished)
	PopoutManager:sharedInstance():add(self, true, false)
	self:layout()
	fadeInFinished()
end

function StarBankPanel:runFullAction(preStarNum, starNum, gainWm, anim, pstate, cstate)
	local title = self.ui:getChildByName("title")
	local descBtn = self.descBtn:getChildByName("s")
	title:setVisible(true)
	title:setOpacity(0)
	self.descBtn:setVisible(true)
	descBtn:setOpacity(0)

	local step1time = 0
	local step4time = 0.5
	local step5time = 0

	local function step5()
		local tipbg = self.ui:getChildByName("tipbg")
		tipbg:setVisible(true)
		for i=1,3 do
			self["tips"..i]:setOpacity(0)
			self["tips"..i]:runAction(CCFadeIn:create(step5time))
		end
		self.closeBtn:setVisible(true)
		self.closeBtn:getChildByName("_bg"):setOpacity(0)
		self.closeBtn:getChildByName("_bg"):runAction(CCFadeIn:create(step5time))
		self.allowBackKeyTap = true
	end

	local runStep4Action
	runStep4Action = function (ui)
		local children = ui:getChildrenList()
		for _,ch in ipairs(children) do
			if ch.refCocosObj.setOpacity then
				ch:setOpacity(0)
				ch:runAction(CCFadeIn:create(step4time))
			end
			runStep4Action(ch)
		end
	end

	local function step4()
		local btn = self.ui:getChildByName("btn")
		btn:setVisible(true)

		-- runStep4Action(btn)

		local children = btn:getChildrenList()
		children[1]:stopAllActions()
		-- children[1]:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(step4time), CCCallFunc:create(step5)))
	end

	local finish = CCCallFunc:create(function()
		
	end)
	title:runAction(CCSequence:createWithTwoActions(CCFadeIn:create(step1time), CCCallFunc:create(finish)))
	descBtn:runAction(CCFadeIn:create(step1time))

	self.animNode:setVisible(true)
	self.animNode:play(tostring(anim))
	self.animNode:addEventListener(ArmatureEvents.COMPLETE, step4)
	step5()
end

function StarBankPanel:createBank()
	FrameLoader:loadArmature('skeleton/StarBankNewAddStar', "StarBankNewAddStar", "StarBankNewAddStar")
	local animNode = ArmatureNode:create("Starbank/AddStar")
	animNode:playByIndex(0)
	animNode:update(0.001)
	animNode:stop()
	-- animNode:unscheduleUpdate()
	self.ui:addChild(animNode)
	animNode:setPosition(ccp(200, -500))
	self.animNode = animNode
end

function StarBankPanel:setBankState( state, config, isPassLevel )
	if self.isInitBank then return end
	self.isInitBank = true

	if not isPassLevel then
		self.animNode:gotoAndStopByIndex((state - 1) * 2, 0.042)
	end

	self:setSlotVisible("bow1", config.color == "blue")
	self:setSlotVisible("bow2", config.color == "green")
	self:setSlotVisible("bow3", config.color == "orange")
	self:setSlotVisible("bow4", config.color == "purple")
	self:setSlotVisible("bow5", config.color == "gold")

	if not isPassLevel then
		for index=1,3 do
			self:setSlotVisible("star"..index, false)
		end
		
		if state ~= StarBankState.kFullCanBuy then
			for i=1,4 do
				self:setSlotVisible("staticcoin"..i, false)
			end
		end
	end

	local slot = self.animNode:getSlot('num')
    local wmnum = BitmapText:create(tostring(StarBank.curWm), 'fnt/piggybank.fnt', 0)
    wmnum:setAnchorPoint(ccp(0.5, 0.5))
    local sprite = Sprite:createEmpty()
    sprite:addChild(wmnum)
    wmnum:setPosition(ccp(98, -114))
    slot:setDisplayImage(sprite.refCocosObj)
end

function StarBankPanel:setSlotVisible( slotName, visible )
	local slot = self.animNode:getSlot(slotName)
	if slot and not visible then
		local sprite = Sprite:createEmpty()
	    slot:setDisplayImage(sprite.refCocosObj)
	end
end