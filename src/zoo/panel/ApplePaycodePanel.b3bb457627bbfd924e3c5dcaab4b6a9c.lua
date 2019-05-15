if __IOS then
	require "zoo.util.IosPayment"
end
require "zoo.panel.basePanel.BasePanel"

ApplePaycodePanel = class(BasePanel)

local productMetas = {
	{id = 21, cash = 449, discount = 1, extraCash = 0, goodsId = 223, price = 30,iapPrice = 30,
		productId = "com.happyelements.animal.gold.cn.21", priceLocale = "CN"},
	{id = 22, cash = 463, discount = 1, extraCash = 0, goodsId = 222, price = 30,iapPrice = 30,
		productId = "com.happyelements.animal.gold.cn.22", priceLocale = "CN"},
	{id = 23, cash = 167, discount = 1, extraCash = 0, goodsId = 220, price = 6,iapPrice = 6,
		productId = "com.happyelements.animal.gold.cn.23", priceLocale = "CN"},
	{id = 24, cash = 189, discount = 1, extraCash = 0, goodsId = 221, price = 6,iapPrice = 6,
		productId = "com.happyelements.animal.gold.cn.24", priceLocale = "CN"},
	{id = 25, cash = 101, discount = 1, extraCash = 0, goodsId = 225, price = 3,iapPrice = 3,
		productId = "com.happyelements.animal.gold.cn.25", priceLocale = "CN"},
	{id = 26, cash = 86, discount = 1, extraCash = 0, goodsId = 224, price = 3,iapPrice = 3,
		productId = "com.happyelements.animal.gold.cn.26", priceLocale = "CN"},
	{id = 27, cash = 119, discount = 1, extraCash = 0, goodsId = 227, price = 1,iapPrice = 1,
		productId = "com.happyelements.animal.gold.cn.27", priceLocale = "CN"},
	{id = 28, cash = 158, discount = 1, extraCash = 0, goodsId = 226, price = 1,iapPrice = 1,
		productId = "com.happyelements.animal.gold.cn.28", priceLocale = "CN"},
}
local currMetaIdx = CCUserDefault:sharedUserDefault():getIntegerForKey("appley.paycode.panel.index")

function ApplePaycodePanel:create()
	local panel = ApplePaycodePanel.new()
	panel:init()
	return panel
end

function ApplePaycodePanel:init()
	self:loadRequiredResource(PanelConfigFiles.panel_apple_paycode)

	local ui = self:buildInterfaceGroup("ApplePaycodePanel/panel")
	BasePanel.init(self, ui)

	self.alignBg = ui:getChildByName("bg3")
	self.alignBgSize = self.alignBg:getGroupBounds(ui).size
	self.alignBgSize = {width = self.alignBgSize.width, height = self.alignBgSize.height}

	local text1 = ui:getChildByName("text1")
	text1:setString(Localization:getInstance():getText("apple.paycode.panel.text1"))
	local text2 = ui:getChildByName("text2")
	text2:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCCallFunc:create(function()
			local hour, min, sec = ApplePaycodePanel:getCountDown()
			text2:setString(string.format("%02d:%02d:%02d", hour, min, sec))
		end), CCDelayTime:create(1))))

	text2:setString(Localization:getInstance():getText("apple.paycode.panel.text2", {h = string.format("%02d", 24),
		m = string.format("%02d", 0), s = string.format("%02d", 0)}))
	local text3 = ui:getChildByName("text3")
	self.text3 = text3

	self.items = {}
	for i = 1, 3 do
		local elem = ui:getChildByName("item"..tostring(i))
		local bubble = elem:getChildByName("bg")
		local item = elem:getChildByName("item")
		item:setVisible(false)
		local num = elem:getChildByName("num")
		table.insert(self.items, {bubble = bubble, item = item, num = num, ui = elem,
			originPos = {x = elem:getPositionX(), y = elem:getPositionY()}})
	end

	self.pluses = {}
	for i = 1, 3 do
		local plus = ui:getChildByName("plus"..tostring(i))
		table.insert(self.pluses, plus)
	end

	self.positions = {}
	for i = 1, 2 do
		local position = ui:getChildByName("pos"..tostring(i))
		position:setVisible(false)
		table.insert(self.positions, position)
	end

	local close = ui:getChildByName("close")
	close:setTouchEnabled(true)
	close:setButtonMode(true)
	close:addEventListener(DisplayEvents.kTouchTap, function()
			self:onCloseBtnTapped()
		end)

	self.discountLine = LayerColor:create()
	self.discountLine:setColor(ccc3(255, 0, 0))
	ui:addChild(self.discountLine)

	local btnBuy = ButtonNumberBase:create(ui:getChildByName("btn1"))
	btnBuy:setString(Localization:getInstance():getText("apple.paycode.panel.btn.buy"))
	btnBuy:setColorMode(kGroupButtonColorMode.blue)
	btnBuy:addEventListener(DisplayEvents.kTouchTap, function()
			self:buyBtnTapped()
		end)
	self.btnBuy = btnBuy
	local btnRefresh = GroupButtonBase:create(ui:getChildByName("btn2"))
	btnRefresh:setString(Localization:getInstance():getText("apple.paycode.panel.btn.refresh"))
	btnRefresh:addEventListener(DisplayEvents.kTouchTap, function()
			self:refresh()
		end)
	self.btnRefresh = btnRefresh

	self:refresh()

	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()
end

function ApplePaycodePanel:buyBtnTapped()
	local productMeta = productMetas[currMetaIdx]
	local function onSuccess()
		CommonTip:showTip(Localization:getInstance():getText("apple.paycode.panel.buy.success"), "positive")
		local productMeta = productMetas[currMetaIdx]
		if productMeta then
			local goodsMeta = MetaManager:getInstance():getGoodMeta(productMeta.goodsId)
			local valueCalculator = GainAndConsumeMgr.getInstance():getPayValueCalculator(goodsMeta.items, productMeta.iapPrice * 100, DcPayType.kRmb)
			for __, v in pairs(goodsMeta.items) do
				UserManager:getInstance():addReward(v)
				UserService:getInstance():addReward(v)
				local value = valueCalculator:getItemSellPrice(v.itemId)
				GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kTrunk, v.itemId, v.num, DcSourceType.kIosPayCode, nil, nil, DcPayType.kRmb, value, productMeta.goodsId)
			end

			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

			HomeScene:sharedInstance():checkDataChange()

			for i,v in ipairs(goodsMeta.items) do
		        local anim = FlyItemsAnimation:create({v})
		        local bounds = self.items[i].icon:getGroupBounds()
		        anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
		        anim:play()
		    end
		end
		self:onCloseBtnTapped()
	end
	local function onFail()
		CommonTip:showTip(Localization:getInstance():getText("apple.paycode.panel.buy.fail"))
		self.btnBuy:setEnabled(true)
	end
	local function onCancel()
		CommonTip:showTip(Localization:getInstance():getText("apple.paycode.panel.buy.cancel"))
		self.btnBuy:setEnabled(true)
	end
	self.btnBuy:setEnabled(false)
	if __IOS then
		IosPayment:buy(productMeta.productId, productMeta.iapPrice, productMeta.priceLocale, productMeta.id, onSuccess, onFail, dcDispatcher)
	else
		onFail()
		self:onCloseBtnTapped()
	end
end

function ApplePaycodePanel:refresh()
	currMetaIdx = currMetaIdx % #productMetas + 1
	local productMeta = productMetas[currMetaIdx]
	if not productMeta then return end
	local goodsMeta = MetaManager:getInstance():getGoodMeta(productMeta.goodsId)

	local counter = 0
	for i, v in ipairs(self.items) do
		if v.icon and not v.icon.isDisposed then
			v.icon:removeFromParentAndCleanup(true)
			v.icon = nil
		end
		local itemMeta = goodsMeta.items[i]
		if not itemMeta then break end
		local itemId = itemMeta.itemId
		local icon
		if itemId == 2 then
			icon = ResourceManager:sharedInstance():buildGroup("stackIcon")
		else
			if ItemType:isTimeProp(itemId) then
				itemId = ItemType:getRealIdByTimePropId(itemId)
			end
			icon = ResourceManager:sharedInstance():buildItemGroup(itemId)
		end
		local size = icon:getGroupBounds().size
		size = {width = size.width, height = size.height}
		local iSize = v.item:getGroupBounds(v.ui).size
		local scale = math.min(iSize.width / size.width, iSize.height / size.height)
		icon:setScale(scale)
		icon:setPositionX(v.item:getPositionX() + (iSize.width - size.width * scale) / 2)
		icon:setPositionY(v.item:getPositionY() - (iSize.height - size.height * scale) / 2)
		v.ui:addChildAt(icon, v.ui:getChildIndex(v.item))
		v.icon = icon

		v.num:setText('x'..tostring(itemMeta.num))
		v.num:setScale(1.3)
		size = v.num:getContentSize()
		v.num:setPositionX(v.bubble:getPositionX() + v.bubble:getGroupBounds(v.ui).size.width - size.width * 1.3 - 20)

		v.ui:removeAllEventListeners()
		v.ui:setTouchEnabled(true)
		v.ui:addEventListener(DisplayEvents.kTouchTap, function()
				self:loadRequiredResource(PanelConfigFiles.panel_apple_paycode)
				local content = self:buildInterfaceGroup("ApplePaycodePanel/tip")
				content:getChildByName("title"):setString(Localization:getInstance():getText("prop.name."..tostring(itemId)))
				local desc = content:getChildByName("desc")
				local originSize = desc:getDimensions()
				desc:setDimensions(CCSizeMake(originSize.width, 0))
				desc:setString(Localization:getInstance():getText("level.prop.tip."..tostring(itemId), {n = "\n", replace1 = 1}))
				tipInstance = BubbleTip:create(content)
				tipInstance:show(v.ui:getGroupBounds())
			end)

		counter = counter + 1
	end

	if counter == 2 then
		self.items[1].ui:setPositionXY(self.positions[1]:getPositionX(), self.positions[1]:getPositionY())
		self.items[1].ui:setScale(1.2)
		self.items[2].ui:setPositionXY(self.positions[2]:getPositionX(), self.positions[2]:getPositionY())
		self.items[2].ui:setScale(1.2)
		self.items[3].ui:setVisible(false)
		self.pluses[1]:setVisible(false)
		self.pluses[2]:setVisible(false)
		self.pluses[3]:setVisible(true)
	else
		self.items[1].ui:setPositionXY(self.items[1].originPos.x, self.items[1].originPos.y)
		self.items[1].ui:setScale(1)
		self.items[2].ui:setPositionXY(self.items[2].originPos.x, self.items[2].originPos.y)
		self.items[2].ui:setScale(1)
		self.items[3].ui:setVisible(true)
		self.pluses[1]:setVisible(true)
		self.pluses[2]:setVisible(true)
		self.pluses[3]:setVisible(false)
	end

	self.text3:setDimensions(CCSizeMake(0, 0))
	self.text3:setString(Localization:getInstance():getText("apple.paycode.panel.text3", {num = tostring(goodsMeta.rmb / 100)}))
	local size = self.text3:getContentSize()
	self.text3:setPositionX(self.alignBg:getPositionX() + (self.alignBgSize.width - size.width) / 2)
	local angle = math.atan(-size.height / size.width)
	self.discountLine:setContentSize(CCSizeMake(size.width / math.cos(angle), 5))
	self.discountLine:setRotation(-(angle * 5 / 7) * 180 / math.pi)
	self.discountLine:setPosition(ccp(self.text3:getPositionX(), self.text3:getPositionY() - 10))
	if _G.isLocalDevelopMode then printx(0, self.discountLine:getPositionX(), self.discountLine:getPositionY()) end

	self.btnBuy:setNumber(Localization:getInstance():getText("apple.paycode.panel.btn.buy.num", {num = tostring(goodsMeta.discountRmb / 100)}))
end

function ApplePaycodePanel:popout()
	PopoutQueue:sharedInstance():push(self)
end

function ApplePaycodePanel:popoutShowTransition()
	self.allowBackKeyTap = true
end

function ApplePaycodePanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

-- 这几个函数仅逻辑，没有UI的事，没需要的话不要创建面板
function ApplePaycodePanel:getCountDown()
	local prevCountdown = tonumber(CCUserDefault:sharedUserDefault():getStringForKey("appley.paycode.panel.time")) or 0
	local back = prevCountdown
	if prevCountdown == 0 then prevCountdown = Localhost:time() end
	local now = Localhost:time()
	while prevCountdown + 86400000 < now do
		prevCountdown = prevCountdown + 86400000
	end
	if back ~= prevCountdown then
		CCUserDefault:sharedUserDefault():setStringForKey("appley.paycode.panel.time", tostring(prevCountdown))
		CCUserDefault:sharedUserDefault():flush()
	end
	local delta = prevCountdown + 86400000 - Localhost:time()
	return math.floor(delta / 3600000), math.floor(delta / 60000 % 60), math.floor(delta / 1000 % 60)
end

function ApplePaycodePanel:getPayInfo()
	return productMetas[currMetaIdx]
end

function ApplePaycodePanel:getNewPayInfo()
	currMetaIdx = currMetaIdx % #productMetas + 1
	CCUserDefault:sharedUserDefault():setIntegerForKey("appley.paycode.panel.index", currMetaIdx)
	CCUserDefault:sharedUserDefault():flush()
	return self:getPayInfo()
end