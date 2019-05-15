--[[
 * 
 * @date    2017-12-12 11:46:54
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

StarBankCoinItem = class(BasePanel)

function StarBankCoinItem:ctor()
	
end

function StarBankCoinItem:create(payType)
	local instance = StarBankCoinItem.new()
	instance:loadRequiredResource("ui/StarBankCoinItem.json")
	instance:init(payType)
	return instance
end

local function wrapText(textUI)
	local label = textUI:getChildByName('label')
	local size = textUI:getChildByName('size')
	local text = TextField:createWithUIAdjustment(size, label)
	textUI:addChild(text)
	textUI.getGroupBounds = function(node, ancestor)
		return text:getGroupBounds(addChild)
	end
	return text
end

local function createBitmapText( label )
	local text = BitmapText:create("", "fnt/tutorial_white.fnt")

	local anchor = label:getAnchorPoint()
	local pos = label:getPosition()
	local color = label:getColor()
	local parent = label:getParent()
	local index = parent:getChildIndex(label)

	text:setAnchorPoint(ccp(anchor.x, anchor.y))
	text:setPosition(ccp(pos.x, pos.y))
	text:setColor(color)
	parent:addChildAt(text, index)

	text:setScale(25.0/35)

	label:removeFromParentAndCleanup(true)

	return text
end

function StarBankCoinItem:init(payType)
	self.ui = self:buildInterfaceGroup("StarBankCoinItem/itemPanel")
	BasePanel.init(self, self.ui)

	self.payType = payType

	local config = StarBank:getConfig()
	self.goodsId = config.goodsId

	local meta = MetaManager.getInstance():getGoodMeta(self.goodsId)
	local price = meta.thirdRmb / 100
	local coinNum = tostring(StarBank.curWm or meta.items[1].num)

	self.buyBtn =  GroupButtonBase:create(self.ui:getChildByName('btn'))
	self.buyBtn:ad(DisplayEvents.kTouchTap, function ()
		StarBank:buy(true, payType)
		self.buyBtn:setEnabled(false)
		setTimeOut(function ( ... )
			if self.isDisposed then return end
			self.buyBtn:setEnabled(true)
		end, 3)
	end)

	self:playBtnAnim()

	local buyConfig = {}

	local currencySymbol, isLongSymbol = BuyHappyCoinManager:getCurrencySymbol(buyConfig.priceLocale or 'cny')
	local showPrice = buyConfig.iapPrice or price

	if isLongSymbol then 
		self.buyBtn:setString(string.format("%s%.0f", currencySymbol, showPrice))
	else
		self.buyBtn:setString(string.format("%s%.2f", currencySymbol, showPrice))
	end

	local coinNumT = self.ui:getChildByName("coinNum")
	local num = TextField:createWithUIAdjustment(coinNumT:getChildByName('ph'), coinNumT:getChildByName('num'))
	coinNumT:addChild(num)
	num:setString(coinNum)

	local time = self.ui:getChildByName("time")
	local text = TextField:createWithUIAdjustment(time:getChildByName('ph'), time:getChildByName('text'))
	time:addChild(text)
	self.timeText = text

	local ori_price = createBitmapText(self.ui:getChildByName('ori_price'))
	local price = createBitmapText(self.ui:getChildByName('price'))
	local delete_line = self.ui:getChildByName('delete_line')

	ori_price:setText('原价：')

	if buyConfig.iapPrice then
		local discountP = buyConfig.iapPrice * 10 / self:getDiscountNum(config.goodsId)
		price:setText(string.format('%s%.2f', currencySymbol, discountP))
	else
		price:setText(string.format('%s%.2f', currencySymbol, self:getOriPrice(config.goodsId) / 100.0 ))
	end

	ori_price:setAnchorPointWhileStayOriginalPosition(ccp(1, 0.5))
	price:setAnchorPointWhileStayOriginalPosition(ccp(0, 0.5))

	ori_price:setScale(ori_price:getScale() * 0.95)
	price:setScale(price:getScale() * 1.05)

	local discountContainerUI = self.ui:getChildByName('btn'):getChildByName('discount')
	local discountUI = discountContainerUI:getChildByName('discount')
	local discountNum = self:getDiscountNum(config.goodsId)

	self.discountUI = discountUI
	self.discountContainerUI = discountContainerUI

	if discountNum >= 10 then
		discountUI:setVisible(false)
	else
		local discountNumUI = self.discountUI:getChildByName("num")
		if not self.isf then
			discountNumUI:changeFntFile('fnt/discount55.fnt')
			discountNumUI:setRotation(28)
			discountNumUI:setAnchorPoint(ccp(0.5, 0.5))
		end
		discountNum = string.format('%0.1f', discountNum)

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
			discountTextUI:setText('折')
		end
		discountTextUI:setScale(1.14)
		if is then
			discountTextUI:setPosition(ccp(-28, -4))
		else
			discountTextUI:setPosition(ccp(-22, -5))
		end
		
		self.isf = true

		self.discountUI:runAction(CCSequence:createWithTwoActions(
			CCDelayTime:create(48/24.0),
			CCCallFunc:create(function ( ... )
				self:playDiscountAnim()
			end)
		))
	end

	for _,c in ipairs({"blue","green","orange","purple","gold"}) do
		self.ui:getChildByName(c):setVisible(config.color == c)
	end

	Notify:register("StarBankUpdateStateEvent", self.updateState, self)
	self:updateState()

	self:setScale(0.98)
end

function StarBankCoinItem:getDiscountNum( goodsId )
	local discountNum = self:getPrice(goodsId) * 10 / self:getOriPrice(goodsId)
	return discountNum
end

function StarBankCoinItem:playDiscountAnim( ... )
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

function StarBankCoinItem:getGiftItems(goodsId)
	return MetaManager.getInstance():getGoodMeta(goodsId).items
end

function StarBankCoinItem:getPrice(goodsId)
	return MetaManager.getInstance():getGoodMeta(goodsId).thirdRmb
end

function StarBankCoinItem:getOriPrice(goodsId)
	return MetaManager.getInstance():getGoodMeta(goodsId).rmb
end

function StarBankCoinItem:playBtnAnim( ... )
	if self.isDisposed then return end
	local btn = self.ui:getChildByName('btn')
	local sx = btn:getScaleX()
	local sy = btn:getScaleY()

	btn:runAction(CCRepeatForever:create(
		CCSequence:createWithTwoActions(
			CCScaleTo:create(20/24.0, 0.819/0.773*sx, sy),
			CCScaleTo:create(20/24.0, sx, sy)
		)
	))
end

function StarBankCoinItem:updateState()
	if self.isDisposed then return end
	local str,color = StarBank:getLeftTimeStrCol()
	self.timeText:setString(str)
	if color.r == 255 then
		color = ccc3(96, 191, 104)
	end
	self.timeText:setColor(color)
end

function StarBankCoinItem:dispose( ... )
	BasePanel.dispose(self)
	Notify:unregister("StarBankUpdateStateEvent", self)
end

StarBankBuySuccessPanel = class(BasePanel)

function StarBankBuySuccessPanel:ctor( ... )
	-- body
end

function StarBankBuySuccessPanel:create( isWindmillPanel ,closeCallBack)
	local panel = StarBankBuySuccessPanel.new()
	panel:loadRequiredResource("ui/StarBankCoinItem.json")
	panel:init(isWindmillPanel , closeCallBack)
	return panel
end

function StarBankBuySuccessPanel:init( isWindmillPanel ,closeCallBack)
	FrameLoader:loadArmature('skeleton/StarBank', 'StarBank', 'StarBank')
	self.ui = self:buildInterfaceGroup("StarBankCoinItem/BuySuccessPanel")
	BasePanel.init(self, self.ui)
	self.closeCallBack = closeCallBack

	self.btn = GroupButtonBase:create(self.ui:getChildByName('btn'))
	if isWindmillPanel then
		self.btn.groupNode:setTouchEnabled(false)
		self.btn.groupNode:setTouchEnabled(true,-2,true)
	end
	self.btn:ad(DisplayEvents.kTouchTap, function ( ... )
		self:onCloseBtnTapped()
	end)
	self.btn:setString("确定")

	local config = StarBank:getConfig()

	local animNode = ArmatureNode:create("StarBank/"..config.color)
	animNode:playByIndex(0)
	-- animNode:update(0.001) 
	-- animNode:stop()
	-- animNode:unscheduleUpdate()
	self.ui:addChild(animNode)
	animNode:setPosition(ccp(200, -400))

	local slot = animNode:getSlot('wmnum')
    local wmnum = BitmapText:create(tostring(StarBank.buyWindMillNumber or 0), 'fnt/race_rank.fnt', 0)
    wmnum:setAnchorPoint(ccp(0.5, 0.5))
    local sprite = Sprite:createEmpty()
    sprite:addChild(wmnum)
    if StarBank.curWm >= 1000 then
    	local size = wmnum:getContentSize()
    	wmnum:setScale(150/size.width)
	end
    wmnum:setPosition(ccp(60, -18))
    slot:setDisplayImage(sprite.refCocosObj)
end

function StarBankBuySuccessPanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self, true)

	if StarBank.state == StarBankState.kCool then
		StarBank:closeStarBankEntry()
		if self.closeCallBack and type(self.closeCallBack) == 'function' then
	    	self.closeCallBack()
	    end
	end
	FrameLoader:unloadArmature( 'skeleton/StarBank', true )
end

function StarBankBuySuccessPanel:popout()
	self.allowBackKeyTap = true
    PopoutManager:sharedInstance():add(self, true, false)

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