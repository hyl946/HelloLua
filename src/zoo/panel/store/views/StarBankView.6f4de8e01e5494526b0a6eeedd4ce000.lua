local UIHelper = require 'zoo.panel.UIHelper'
local CommonViewLogic = require 'zoo.panel.store.views.CommonViewLogic'



local NewStarBankCoinItem = class(BasePanel)

function NewStarBankCoinItem:ctor()
end

function NewStarBankCoinItem:create()
	local instance = NewStarBankCoinItem.new()
	instance:init()
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

function NewStarBankCoinItem:init()
	self.ui = UIHelper:createUI('ui/store.json', 'com.niu2x.store/star-bank')
	BasePanel.init(self, self.ui)

	local config = StarBank:getConfig()
	self.goodsId = config.goodsId

	local titleLabel = self.ui:getChildByPath('name')
	CommonViewLogic:setTitle(titleLabel, self.goodsId, 'fnt/libao5.fnt', 1.05)


	local meta = MetaManager.getInstance():getGoodMeta(self.goodsId)
	local price = meta.thirdRmb / 100
	local coinNum = tostring(StarBank.curWm or meta.items[1].num)

	self.button =  GroupButtonBase:create(self.ui:getChildByName('button'))
	self.button:setColorMode(kGroupButtonColorMode.blue)
	self.button:ad(DisplayEvents.kTouchTap, function ()
		self.button:setEnabled(false)

		self:callAncestors('onTapBuyButton')

		setTimeOut(function ( ... )
			if self.isDisposed then return end
			self.button:setEnabled(true)
		end, 3)
	end)

	-- self:playBtnAnim()

	local buyConfig = {}

	if __IOS then
		buyConfig = StoreManager:getInstance():getIosProductInfoByGoodsId(self.goodsId)
	end

	local currencySymbol, isLongSymbol = BuyHappyCoinManager:getCurrencySymbol(buyConfig.priceLocale or 'cny')
	local showPrice = buyConfig.iapPrice or price

	if isLongSymbol then 
		self.button:setString(string.format("%s%.0f", currencySymbol, showPrice))
	else
		self.button:setString(string.format("%s%.2f", currencySymbol, showPrice))
	end

	local coinNumT = self.ui:getChildByName("coinNum")
	local num = TextField:createWithUIAdjustment(coinNumT:getChildByName('ph'), coinNumT:getChildByName('num'))
	coinNumT:addChild(num)
	num:setString(coinNum)



	local discountUI = self.ui:getChildByPath('discountUI')
	CommonViewLogic:setDiscountRmbAndRmb(discountUI, self:getPrice(self.goodsId), self:getOriPrice(self.goodsId))

	for _,c in ipairs({"blue","green","orange","purple","gold"}) do
		self.ui:getChildByName(c):setVisible(config.color == c)
	end

	Notify:register("StarBankUpdateStateEvent", self.updateState, self)
	self:updateState()
	-- self:setScale(0.98)

	local anim = UIHelper:createArmature2('skeleton/store-anim', 'com.niu2x.store.anim/gift-2-light-anim')
	anim:playByIndex(0, 0)
	anim:setPositionY(-20)
	local flag = self.ui:getChildByPath('name')
	local flagIndex = self.ui:getChildIndex(flag)
	self.ui:addChildAt(anim, flagIndex)
	StarBank:updateLeftTime()
	--printx(61, 'StarBankView', StarBank.buyDeadline, StarBank.state)
	CommonViewLogic:setTimeAndBuyLimit(self.ui:getChildByPath('flag-2'), StarBank.buyDeadline, nil, nil, nil)
end


function NewStarBankCoinItem:playDiscountAnim( ... )
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

function NewStarBankCoinItem:getGiftItems(goodsId)
	return MetaManager.getInstance():getGoodMeta(goodsId).items
end

function NewStarBankCoinItem:getPrice(goodsId)
	return MetaManager.getInstance():getGoodMeta(goodsId).thirdRmb
end

function NewStarBankCoinItem:getOriPrice(goodsId)
	return MetaManager.getInstance():getGoodMeta(goodsId).rmb
end

function NewStarBankCoinItem:playBtnAnim( ... )
	if self.isDisposed then return end
	local btn = self.ui:getChildByName('button')
	local sx = btn:getScaleX()
	local sy = btn:getScaleY()

	btn:runAction(CCRepeatForever:create(
		CCSequence:createWithTwoActions(
			CCScaleTo:create(20/24.0, 0.819/0.773*sx, sy),
			CCScaleTo:create(20/24.0, sx, sy)
		)
	))
end

function NewStarBankCoinItem:updateState()
	if self.isDisposed then return end
end

function NewStarBankCoinItem:dispose( ... )
	BasePanel.dispose(self)
	StarBank:setBuyDelegate(false)
	Notify:unregister("StarBankUpdateStateEvent", self)
end




local StarBankView = class(Layer)

function StarBankView:create( itemData )
	local v = StarBankView.new()
	v:initLayer()
	v:initWithData()
	return v
end



function StarBankView:initWithData()
	self:initView()
end

function StarBankView:initView( ... )
	if self.isDisposed then return end

	StarBank:setCoinItemClass(NewStarBankCoinItem)

	StarBank:setBuyDelegate(function ( ... )
		self:buy(...)
	end)

	Notify:dispatch("StarBankEventCreateCoinItem", function ( ui )
		StarBank:setCoinItemClass(nil)
		self:addChild(ui)
		self.ui = ui
		return function ( ... )
			if self.isDisposed then return end
			self:callAncestors('removeStoreItem', self)
		end
	end, payType)
end

function StarBankView:buy( goodsId, success, fail, cancel, dcFeature, dcSource )
	if self.isDisposed then return end

	BuyGoodsLogic:getInstance():buy(goodsId, GoodsType.kItem, __IOS and StoreManager:getInstance():getIosProductInfoByGoodsId(goodsId), function ( ... )
		if self.isDisposed then 
			if _G.StoreManager:getInstance():getPanelInstance() then
				_G.StoreManager:getInstance():getPanelInstance():refreshGoldLabel()
			end
			if success then success() end
			return 
		end
		
		if success then success() end
		self:dp(Event.new('AfterBuySuccess', GoodsIdInfoObject:create(goodsId, GoodsType.kItem), self))
	end, function ( ... )
		-- body
		if fail then fail() end
	end, function ( ... )
		if cancel then cancel() end
	end, function ( payType )
		local payment = PaymentBase:getPayment(payType)
		if (goodsId == 485 or goodsId == 510 or goodsId == 614 or goodsId == 615) and payment.mode == PaymentMode.kSms then
			return false
		end
		return true
	end)

	-- local dcObj = BuyGoodsLogic:getInstance():getDcObj()
	-- if dcObj then
	-- 	RemoteDebug:uploadLogWithTag("dc", table.tostring(dcObj))
	-- end

end


function StarBankView:setEnabled( bEnabled )
	if self.isDisposed then return end
	if self.ui then
		self.ui.button:setEnabled(bEnabled)
	end
end

function StarBankView:onTapBuyButton( ... )
	if self.isDisposed then return end
	StarBank:buy(true)
end

return StarBankView

