

-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月 1日 20:00:53
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com
--

require "zoo.scenes.component.HomeScene.item.CloudButton"
require "zoo.data.UserManager"

---------------------------------------------------
-------------- CoinButton
---------------------------------------------------

assert(not CoinButton)
assert(CloudButton)

CoinButton = class(CloudButton)

function CoinButton:init(belongScene, ...)

	-- Get Resource
	self.ui			= ResourceManager:sharedInstance():buildGroup("newCoinButton")
	assert(self.ui)

	-- -----------------
	-- Init Base Class
	-- -----------------
	CloudButton.init(self, self.ui)

	-- -------------
	-- Get UI Resource
	-- ----------------
	self.blueBubbleItemRes		= self.ui:getChildByName("bubbleItem")
	self.labelPlaceholder 		= self.ui:getChildByName("label")
	self.coinIcon			= self.blueBubbleItemRes:getChildByName("placeHolder")

	assert(self.blueBubbleItemRes)
	assert(self.labelPlaceholder)
	assert(self.coinIcon)

	------------
	-- Init UI
	-- --------
	self.labelPlaceholder:setVisible(false)

	-- Scale Small
	local config 	= UIConfigManager:sharedInstance():getConfig()
	local uiScale	= config.homeScene_uiScale
	self:setScale(uiScale)

	-------------------
	-- Create UI Component
	-- -----------------
	self.bubbleItem	= HomeSceneBubbleItem:create(self.blueBubbleItemRes)

	-- Clipping The Bubble
	local stencil		= LayerColor:create()
	stencil:setColor(ccc3(255,0,0))
	stencil:changeWidthAndHeight(132, 71.85 + 30)
	stencil:setPosition(ccp(0, -71.85))
	local cppClipping	= CCClippingNode:create(stencil.refCocosObj)
	local luaClipping	= ClippingNode.new(cppClipping)
	stencil:dispose()
	
	self.ui:addChild(luaClipping)
	self.bubbleItem:removeFromParentAndCleanup(false)
	luaClipping:addChild(self.bubbleItem)


	local charWidth		= 35
	local charHeight	= 35
	local charInterval	= 16
	local fntFile		= "fnt/hud.fnt"
	if _G.useTraditionalChineseRes then fntFile = "fnt/zh_tw/hud.fnt" end
	self.label = BitmapText:create('', fntFile)
	self.label:setAnchorPoint(ccp(0.5,0.5))
	self.label:setPreferredSize(95, 35)
	self.label:setPositionXY(56, -88)
	self.ui:addChild(self.label)
	--------------
	---- Data
	-------------
	self.belongScene	= belongScene
	self.userRef		= UserManager.getInstance().user
	self.coin 		= self.userRef:getCoin()
	self.displayedCoin	= false
	assert(self.coin)

	local energyLabelKey	= "coin.bubble"
	local energyLabelValue	= Localization:getInstance():getText(energyLabelKey, {ten_thousand = ""})
	self.energyLabelValue	= energyLabelValue

	-- ----------
	-- Update View
	-- -----------
	self:updateView()

	-------------------------------
	-- Update View Then Data Change
	-- -------------------
	if self.belongScene then
		self.belongScene:addEventListener(HomeSceneEvents.USERMANAGER_COIN_CHANGE, self.onCoinDataChange, self)
	end
	-- ---------------------------------
	-- Add Event Listener
	-- ---------------------------------
	local function onTapped(event)
		self:onTapped(event)
	end

	self.ui:setTouchEnabled(true, 0, true)
	self.ui:addEventListener(DisplayEvents.kTouchTap, onTapped)
end

function CoinButton:onTapped(event, ...)
	assert(#{...} == 0)

	if self.onTappedCallback then
		self.onTappedCallback()
	end
end

function CoinButton:setOnTappedCallback(onTappedCallback, ...)
	assert(type(onTappedCallback) == "function")
	assert(#{...} == 0)

	self.onTappedCallback = onTappedCallback
end

function CoinButton:playHighlightAnim(...)
	assert(#{...} == 0)

	--local highlightRes = ResourceManager:sharedInstance():buildGroup("coinHighlightWrapper")
	local highlightRes = ResourceManager:sharedInstance():buildSprite("coinHighlightWrapper")
	self.bubbleItem:playHighlightAnim(highlightRes)
end

function CoinButton:getFlyToPosition()
	local pos = self.coinIcon:getPosition()
	local size = self.coinIcon:getGroupBounds().size
	return self.blueBubbleItemRes:convertToWorldSpace(ccp(pos.x + size.width / 2, pos.y - size.height / 2))
end

function CoinButton:getFlyToSize()
	local size = self.coinIcon:getGroupBounds().size
	size.width, size.height = size.width, size.height
	return size
end

function CoinButton:getBubbleItemRes( ... )
	return self.blueBubbleItemRes
end

function CoinButton:playBubbleSkewAnim(...)
	assert(#{...} == 0)

	self.bubbleItem:playBubbleSkewAnim()
end

function CoinButton:centerLabel(...)
end

function CoinButton.onCoinDataChange(event, ...)
	assert(event)
	assert(event.name == HomeSceneEvents.USERMANAGER_COIN_CHANGE)
	assert(event.context)
	assert(#{...} == 0)

	local self = event.context

	local newCoin = UserManager.getInstance().user:getCoin()
	self:setNumber(newCoin)

	if _G.isLocalDevelopMode then printx(0, "CoinButton:onCoinDataChange Called !") end
	if _G.isLocalDevelopMode then printx(0, "New Coin: " .. newCoin) end
	--debug.debug()
end

function CoinButton:updateView(...)
	assert(#{...} == 0)

	if self.displayedCoin ~= self.coin then
		self.displayedCoin = self.coin

		local coinString = false

		if self.coin > 100000 then
			local intNum, floatNum = math.floor(self.coin / 10000), math.floor((self.coin % 10000) / 100) --小数部分取小数点后两位
			-- if floatNum % 10 == 0 then floatNum = math.floor((floatNum + 1) / 10) end --被10整除显示小数点后1位,+1是为了防止float做除法整除部分有误差
			if floatNum > 0 then
				local floatPart = string.sub(tostring(floatNum / 100.0), 2)
				coinString = intNum .. floatPart .. self.energyLabelValue
			else
				coinString = intNum .. self.energyLabelValue
			end
		else
			coinString = tostring(self.coin)
		end

		self.label:setString(coinString)
	end
end

function CoinButton:setNumber(number, ...)
	assert(number)
	assert(#{...} == 0)

	if self.coin == number then
		return
	else
		self.coin = number
		--self:updateView()
	end
end

function CoinButton:create(belongScene, ...)
	local newCoinButton = CoinButton.new()
	newCoinButton:init(belongScene)
	return newCoinButton
end
