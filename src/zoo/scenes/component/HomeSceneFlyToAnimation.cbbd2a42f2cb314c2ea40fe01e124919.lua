require "zoo.animation.FlyToAnimation"
require "zoo.util.ChanceUtils"

HomeSceneFlyToAnimation = class()

local instance = nil
function HomeSceneFlyToAnimation:sharedInstance()
	if not instance then instance = HomeSceneFlyToAnimation.new() end
	return instance
end

-- config = {
-- 	energyButton,
-- 	starButton,
-- 	coinButton,
-- 	bagButton,
-- }
function HomeSceneFlyToAnimation:init(config)
	self.energyButton = config.energyButton
	self.starButton = config.starButton
	self.coinButton = config.coinButton
	self.bagButton = config.bagButton
	self.goldButton = config.goldButton
end

-- config = {
--	flyDuration,
--	delayTime,
-- 	updateButton,
-- 	startCallback(coinSprite), -- may be nil
-- 	reachCallback(coinSprite), -- may be nil
-- 	finishCallback,
-- }
-- CAUTION: return nil while something wrong
-- CAUTION: add to parent before call play
function HomeSceneFlyToAnimation:coinStackAnimation(config)
	if not self.coinButton or self.coinButton.isDisposed then return end
	config.flyDuration, config.delayTime = config.flyDuration or 0.3, config.delayTime or 0.1
	local stack = ResourceManager:sharedInstance():buildGroup("stackIcon")
	local coinsInStack, counter = {}, 1
	local flyingCoins = {}
	while true do
		local coin = stack:getChildByName(tostring(counter))
		if coin then
			table.insert(coinsInStack, coin)
			local flyCoin = Sprite:createWithSpriteFrameName("homeSceneCoinIcon0000")
			local pos = coin:getPosition()
			local size = coin:getGroupBounds().size
			flyCoin:setPosition(ccp(pos.x + size.width / 2, pos.y - size.height / 2))
			flyCoin:setVisible(false)
			stack:addChild(flyCoin)
			table.insert(flyingCoins, flyCoin)
		else break end
		counter = counter + 1
	end
	local started = 2
	local function onStart(target)
		if coinsInStack[started] and not coinsInStack[started].isDisposed then coinsInStack[started]:setVisible(false) end
		if target and not target.isDisposed then target:setVisible(true) end
		if config.startCallback then config.startCallback(target) end
		started = started + 1
	end
	local function onReach(target)
		if target and not target.isDisposed then target:setVisible(false) end
		if self.coinButton and not self.coinButton.isDisposed then self.coinButton:playHighlightAnim() end
		if config.reachCallback then config.reachCallback(target) end
	end
	local function onFinish()
		while #flyingCoins > 0 do
			if not flyingCoins[1].isDisposed then
				flyingCoins[1]:removeFromParentAndCleanup(true)
			end
			table.remove(flyingCoins, 1)
		end
		-- 待再检查原因的线上BUG：父对象的C++对象（在Lua中的引用）被置空，但子对象正常使用，在调用从父对象移除时报错崩溃
		if not stack.isDisposed and stack.refCocosObj then
			if stack:getParent() and not stack:getParent().isDisposed and stack:getParent().refCocosObj then
				stack:removeFromParentAndCleanup(true)
			else
				stack:dispose()
			end
		end
		if config.updateButton and not self.coinButton.isDisposed then self.coinButton:updateView() end
		if config.finishCallback then config.finishCallback() end
	end
	local flyToConfig = {
		duration = config.flyDuration,
		sprites = flyingCoins,
		dstPosition = self.coinButton:getFlyToPosition(),
		dstSize = self.coinButton:getFlyToSize(),
		direction = true,
		delayTime = config.delayTime,
		startCallback = onStart,
		reachCallback = onReach,
		finishCallback = onFinish,
	}
	local ret = {}
	ret.sprites = stack
	ret.sprites.setPosition = function(self, pos)
		Layer.setPosition(self, ccp(pos.x - 59, pos.y + 77))
	end
	ret.sprites:setPosition(ccp(0, 0))
	ret.play = function(self)
		if not self.coinButton or self.coinButton.isDisposed or self.played then return false end
		self.played = true
		if coinsInStack[1] and not coinsInStack[1].isDisposed then coinsInStack[1]:setVisible(false) end
		if flyingCoins[1] and not flyingCoins[1].isDisposed then flyingCoins[1]:setVisible(true) end
		BezierFlyToAnimation:create(flyToConfig)
		return true
	end
	ret.coinButton = self.coinButton
	return ret
end

-- config = {
-- 	number,
--	flyDuration,
--	delayTime,
-- 	updateButton,
-- 	startCallback(coinSprite), -- may be nil
-- 	reachCallback(coinSprite), -- may be nil
-- 	finishCallback,
-- }
-- RETURN: a table containing all elements
-- CAUTION: return nil while something wrong
-- CAUTION: add to parent before call play
function HomeSceneFlyToAnimation:energyFlyToAnimation(config)
	if not self.energyButton or self.energyButton.isDisposed then return end
	config.number = config.number or 1
	config.flyDuration, config.delayTime = config.flyDuration or 0.3, config.delayTime or 0.1
	local energies = {}
	for i = 1, config.number do
		local energy = Sprite:createWithSpriteFrameName("homeSceneEner_j34i0000")
		energy:setVisible(false)
		table.insert(energies, energy)
	end
	energies[1]:setVisible(true)
	local function onStart(target)
		for k, v in ipairs(energies) do
			if v == target and energies[k + 1] and not energies[k + 1].isDisposed then
				energies[k + 1]:setVisible(true)
			end
		end
		if config.startCallback then config.startCallback(target) end
	end
	local function onReach(target)
		if target and not target.isDisposed then target:setVisible(false) end
		if self.energyButton and not self.energyButton.isDisposed then self.energyButton:playHighlightAnim() end
		if config.reachCallback then config.reachCallback(target) end
	end
	local function onFinish()
		while #energies > 0 do
			if not energies[1].isDisposed then
				energies[1]:removeFromParentAndCleanup(true)
			end
			table.remove(energies, 1)
		end
		if config.updateButton and not self.coinButton.isDisposed then self.energyButton:updateView() end
		if config.finishCallback then config.finishCallback() end
	end
	local flyToConfig = {
		duration = config.flyDuration,
		sprites = energies,
		dstPosition = self.energyButton:getFlyToPosition(),
		dstSize = self.energyButton:getFlyToSize(),
		direction = false,
		delayTime = config.delayTime,
		startCallback = onStart,
		reachCallback = onReach,
		finishCallback = onFinish,
	}
	local ret = {}
	ret.sprites = energies
	ret.play = function(self)
		if not self.energyButton or self.energyButton.isDisposed or self.played then return false end
		self.played = true
		BezierFlyToAnimation:create(flyToConfig)
		return true
	end
	ret.energyButton = self.energyButton
	return ret
end

-- config = {
-- 	number,
--	flyDuration,
--	delayTime,
-- 	updateButton,
-- 	startCallback(coinSprite), -- may be nil
-- 	reachCallback(coinSprite), -- may be nil
-- 	finishCallback,
-- }
-- RETURN: a table containing all elements
-- CAUTION: return nil while something wrong
-- CAUTION: add to parent before call play
function HomeSceneFlyToAnimation:goldFlyToAnimation(config)
	if not self.goldButton or self.goldButton.isDisposed then return end
	config.number = config.number or 1
	config.flyDuration, config.delayTime = config.flyDuration or 0.3, config.delayTime or 0.1
	local golds = {}
	for i = 1, config.number do
		local gold = Sprite:createWithSpriteFrameName("wheel0000")
		gold:setAnchorPoint(ccp(0, 1))
		gold:setVisible(false)
		table.insert(golds, gold)
	end
	golds[1]:setVisible(true)
	local function onStart(target)
		for k, v in ipairs(golds) do
			if v == target and golds[k + 1] and not golds[k + 1].isDisposed then
				golds[k + 1]:setVisible(true)
			end
		end
		if config.startCallback then config.startCallback(target) end
	end
	local function onReach(target)
		if target and not target.isDisposed then target:setVisible(false) end
		if self.goldButton and not self.goldButton.isDisposed then self.goldButton:playHighlightAnim() end
		if config.reachCallback then config.reachCallback(target) end
	end
	local function onFinish()
		while #golds > 0 do
			if not golds[1].isDisposed then
				golds[1]:removeFromParentAndCleanup(true)
			end
			table.remove(golds, 1)
		end
		if config.updateButton and not self.coinButton.isDisposed then self.goldButton:updateView() end
		if config.finishCallback then config.finishCallback() end
	end
	local flyToConfig = {
		duration = config.flyDuration,
		sprites = golds,
		dstPosition = self.goldButton:getFlyToPosition(),
		dstSize = self.goldButton:getFlyToSize(),
		direction = true,
		delayTime = config.delayTime,
		startCallback = onStart,
		reachCallback = onReach,
		finishCallback = onFinish,
	}
	local ret = {}
	ret.sprites = golds
	ret.play = function(self)
		if not self.goldButton or self.goldButton.isDisposed or self.played then return false end
		self.played = true
		BezierFlyToAnimation:create(flyToConfig)
		return true
	end
	ret.goldButton = self.goldButton
	return ret
end

function HomeSceneFlyToAnimation:playItemFlyToAnimation(config)
	assert(config.toPos)

	config.number = config.number or 1
	config.flyDuration, config.delayTime = config.flyDuration or 0.3, config.delayTime or 0.1
	local sprites = {}
	for i = 1, config.number do
		local sprite = config:createSprite()
		sprite:setVisible(false)
		table.insert(sprites, sprite)
	end
	sprites[1]:setVisible(true)
	local function onStart(target)
		for k, v in ipairs(sprites) do
			if v == target and sprites[k + 1] and not sprites[k + 1].isDisposed then
				sprites[k + 1]:setVisible(true)
			end
		end
		if config.startCallback then config.startCallback(target) end
	end
	local function onReach(target)
		if target and not target.isDisposed then target:setVisible(false) end
		if config.reachCallback then config.reachCallback(target) end
	end
	local function onFinish()
		while #sprites > 0 do
			if not sprites[1].isDisposed then
				sprites[1]:removeFromParentAndCleanup(true)
			end
			table.remove(sprites, 1)
		end
		if config.finishCallback then config.finishCallback() end
	end
	local flyToPos = ccp(config.toPos.x, config.toPos.y)
	local flyToSize = CCSizeMake(config.toSize.width, config.toSize.height)
	local flyToConfig = {
		duration = config.flyDuration,
		sprites = sprites,
		dstPosition = flyToPos,
		dstSize = flyToSize,
		direction = true,
		delayTime = config.delayTime,
		startCallback = onStart,
		reachCallback = onReach,
		finishCallback = onFinish,
	}
	
	local ret = {}
	ret.sprites = sprites
	ret.play = function(self)
		if self.played then return false end
		self.played = true
		BezierFlyToAnimation:create(flyToConfig)
		return true
	end
	return ret
end

-- config = {
-- 	goodsId,
-- 	propId,
-- 	number,
--	flyDuration,
--	delayTime,
-- 	showIcon,
-- 	startCallback(coinSprite), -- may be nil
-- 	reachCallback(coinSprite), -- may be nil
-- 	finishCallback,
-- }
-- RETURN: a table containing all elements
-- CAUTION: if there is propId, goodsId will be ignored
-- CAUTION: return nil while something wrong
-- CAUTION: add to parent before call play

local kAnimationTime = 1/30
function HomeSceneFlyToAnimation:jumpToBagAnimation(config)
	if not self.bagButton or self.bagButton.isDisposed then return end
	local scene = Director:sharedDirector():getRunningSceneLua()
	config.number = config.number or 1
	config.flyDuration, config.delayTime = config.flyDuration or 0.8, config.delayTime or 0.3
	if type(config.showIcon) ~= "boolean" then config.showIcon = true end
	local props = {}

	if config.items then
		for _,v in pairs(config.items) do
			for i=1,v.num do
				local prop = ResourceManager:sharedInstance():buildItemSprite(v.itemId)
				prop:setVisible(false)
				table.insert(props, prop)
			end
		end
	else
		for i = 1, config.number do
			local prop
			if config.propId then prop = ResourceManager:sharedInstance():buildItemSprite(config.propId)
			elseif config.goodsId then prop = ResourceManager:sharedInstance():getItemResNameFromGoodsId(config.goodsId)
			else return end
			prop:setVisible(false)
			table.insert(props, prop)
		end
	end
	props[1]:setVisible(true)

	local iconSprite = nil
	local iconSpWolrdPos = nil
	if config.showIcon then
		iconSprite = Sprite:createWithSpriteFrameName("home_fly_bag_ani/cells/fly_to_bag_icon0000")
		iconSprite:setPosition(self.bagButton:getFlyToPosition())
	end

	local function onStart(target)
		if config.showIcon and not iconSprite.isDisposed then 
			local bounds = iconSprite:getGroupBounds()
			iconSpWolrdPos = ccp(bounds:getMidX(), bounds:getMidY())
		end

		for k, v in ipairs(props) do
			if v == target and props[k + 1] and not props[k + 1].isDisposed then
				props[k + 1]:setVisible(true)
			end
		end
		if config.startCallback then config.startCallback(target) end
	end
	local function onReach(target)
		if target and not target.isDisposed then target:setVisible(false) end
		if config.showIcon then
			if not iconSprite.isDisposed then
				iconSprite:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(kAnimationTime * 3, 0.83), CCScaleTo:create(kAnimationTime * 6, 1)))
				
				if iconSpWolrdPos then 
					local whiteSp = Sprite:createWithSpriteFrameName("home_top_bar_ani/cells/white_coin0000")
					scene:addChild(whiteSp, SceneLayerShowKey.TOP_LAYER)
					whiteSp:setPosition(iconSpWolrdPos)

					local arr = CCArray:create()
					arr:addObject(CCSpawn:createWithTwoActions(
						CCScaleTo:create(kAnimationTime*12, 3.08),
						CCFadeTo:create(kAnimationTime*12, 0)
					))
					arr:addObject(CCCallFunc:create(function()
						whiteSp:removeFromParentAndCleanup(true)
					end))
					whiteSp:runAction(CCSequence:create(arr))
				end
			end
		end
		if config.reachCallback then config.reachCallback(target) end
	end
	local function onFinish()
		while #props > 0 do
			if not props[1].isDisposed then
				props[1]:removeFromParentAndCleanup(true)
			end
			table.remove(props, 1)
		end
		if config.showIcon then
			if not iconSprite.isDisposed then 
				local arr = CCArray:create()
				arr:addObject(CCDelayTime:create(kAnimationTime * 8))
				arr:addObject(CCScaleTo:create(kAnimationTime * 3, 1.05))
				arr:addObject(CCScaleTo:create(kAnimationTime * 2, 0.8))
				arr:addObject(CCScaleTo:create(kAnimationTime * 1, 0))
				arr:addObject(CCCallFunc:create(function ()
					iconSprite:removeFromParentAndCleanup(true)
				end))
				iconSprite:runAction(CCSequence:create(arr))
			end
		end
		if config.finishCallback then config.finishCallback() end
	end

	local jumpToConfig = {
		duration = config.flyDuration,
		sprites = props,
		icon = iconSprite,
		dstPosition = self.bagButton:getFlyToPosition(),
		dstSize = self.bagButton:getFlyToSize(),
		easeIn = true,
		delayTime = config.delayTime,
		startCallback = onStart,
		reachCallback = onReach,
		finishCallback = onFinish,
	}
	local ret = {}
	ret.sprites = props
	ret.play = function(self)
		if not self.bagButton or self.bagButton.isDisposed or self.played then return false end
		if jumpToConfig.icon then
			local icon = jumpToConfig.icon
			icon:setVisible(true)
			if not icon:getParent() then
				scene:addChild(icon, SceneLayerShowKey.TOP_LAYER)
			end
			icon:setScale(0)
			local arr = CCArray:create()
			arr:addObject(CCScaleTo:create(kAnimationTime * 2, 0.73))
			arr:addObject(CCScaleTo:create(kAnimationTime * 3, 1.16))
			arr:addObject(CCScaleTo:create(kAnimationTime * 3, 1))
			icon:runAction(CCSequence:create(arr))
		end
		self.played = true
		jumpToConfig.extendAction = CCSequence:createWithTwoActions(CCDelayTime:create(config.flyDuration - 0.1), CCFadeOut:create(0.1))
		JumpFlyToAnimation:create(jumpToConfig)
		return true
	end
	ret.bagButton = self.bagButton
	ret.onFinish = onFinish

	return ret
end

--this is old one
function HomeSceneFlyToAnimation:__jumpToBagAnimation(config)
	if not self.bagButton or self.bagButton.isDisposed then return end
	config.number = config.number or 1
	config.flyDuration, config.delayTime = config.flyDuration or 0.8, config.delayTime or 0.3
	if type(config.showIcon) ~= "boolean" then config.showIcon = true end
	local props = {}

	if config.items then
		for _,v in pairs(config.items) do
			for i=1,v.num do
				local prop = ResourceManager:sharedInstance():buildItemSprite(v.itemId)
				prop:setVisible(false)
				table.insert(props, prop)
			end
		end
	else
		for i = 1, config.number do
			local prop
			if config.propId then prop = ResourceManager:sharedInstance():buildItemSprite(config.propId)
			elseif config.goodsId then prop = ResourceManager:sharedInstance():getItemResNameFromGoodsId(config.goodsId)
			else return end
			prop:setVisible(false)
			table.insert(props, prop)
		end
	end
	props[1]:setVisible(true)

	local iconSprite = nil
	if config.showIcon then
		iconSprite = Sprite:createWithSpriteFrameName("bagButtonImage0000")
		iconSprite:setPosition(self.bagButton:getFlyToPosition())
	end

	local function onStart(target)
		for k, v in ipairs(props) do
			if v == target and props[k + 1] and not props[k + 1].isDisposed then
				props[k + 1]:setVisible(true)
			end
		end
		if config.startCallback then config.startCallback(target) end
	end
	local function onReach(target)
		if target and not target.isDisposed then target:setVisible(false) end
		if config.showIcon then
			if not iconSprite.isDisposed then
				iconSprite:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(0.1, 1.5), CCScaleTo:create(0.4, 1)))
			end
		end
		if config.reachCallback then config.reachCallback(target) end
	end
	local function onFinish()
		while #props > 0 do
			if not props[1].isDisposed then
				props[1]:removeFromParentAndCleanup(true)
			end
			table.remove(props, 1)
		end
		if config.showIcon then
			local function removeSelf()
				if not iconSprite.isDisposed then
					iconSprite:removeFromParentAndCleanup(true)
				end
			end
			local function onDelayOver()
				if not iconSprite.isDisposed then
					iconSprite:runAction(CCSequence:createWithTwoActions(CCFadeOut:create(0.2), CCCallFunc:create(removeSelf)))
				end
			end
			if not iconSprite.isDisposed then
				iconSprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.2), CCCallFunc:create(onDelayOver)))
			end
		end
		if config.finishCallback then config.finishCallback() end
	end

	local jumpToConfig = {
		duration = config.flyDuration,
		sprites = props,
		icon = iconSprite,
		dstPosition = self.bagButton:getFlyToPosition(),
		dstSize = self.bagButton:getFlyToSize(),
		easeIn = true,
		delayTime = config.delayTime,
		startCallback = onStart,
		reachCallback = onReach,
		finishCallback = onFinish,
	}
	local ret = {}
	ret.sprites = props

	ret.play = function(self)
		if not self.bagButton or self.bagButton.isDisposed or self.played then return false end
		if jumpToConfig.icon then
			local icon = jumpToConfig.icon
			icon:setVisible(true)
			icon:setOpacity(0)
			if not icon:getParent() then
				local scene = Director:sharedDirector():getRunningSceneLua()
				scene:addChild(icon, SceneLayerShowKey.TOP_LAYER)
			end
			icon:runAction(CCFadeIn:create(0.2))
		end
		self.played = true
		jumpToConfig.extendAction = CCSequence:createWithTwoActions(CCDelayTime:create(config.flyDuration - 0.1), CCFadeOut:create(0.1))
		JumpFlyToAnimation:create(jumpToConfig)
		return true
	end
	ret.bagButton = self.bagButton
	ret.onFinish = onFinish

	return ret
end


function HomeSceneFlyToAnimation:spritesJumpToGoldAnimation(config)
    if not self.goldButton or self.goldButton.isDisposed then return end
    local props = config.sprites
	config.number = config.number or 1
	config.flyDuration, config.delayTime = config.flyDuration or 0.5, config.delayTime or 0.3

	local function onStart(target)
--		props:setVisible(true)
		if config.startCallback then config.startCallback(target) end
	end
	local function onReach(target)
		if target and not target.isDisposed then target:setVisible(false) end
		if self.goldButton and not self.goldButton.isDisposed then self.goldButton:playHighlightAnim() end
		if config.reachCallback then config.reachCallback(target) end
	end
	local function onFinish()
		while #props > 0 do
			if not props[1].isDisposed then
				props[1]:removeFromParentAndCleanup(true)
			end
			table.remove(props, 1)
		end

		if config.updateButton and not self.goldButton.isDisposed then self.goldButton:updateView() end
		if config.finishCallback then config.finishCallback() end
	end

    local GoldPos = self.goldButton:getFlyToPosition()
    local goldSprite = Sprite:createWithSpriteFrameName("wheel0000")
    local size = goldSprite:getContentSize()
    GoldPos = ccp( GoldPos.x+size.width/2, GoldPos.y-size.height/2 ) 
    goldSprite:dispose()

	local flyToConfig = {
		duration = config.flyDuration,
		sprites = props,
		dstPosition = GoldPos,
		dstSize = self.goldButton:getFlyToSize(),
		direction = true,
		delayTime = config.delayTime,
		startCallback = onStart,
		reachCallback = onReach,
		finishCallback = onFinish,
	}

	local ret = {}
	ret.sprites = props
	ret.play = function(self)
		if not self.goldButton or self.goldButton.isDisposed or self.played then return false end
		self.played = true
		BezierFlyToAnimation:create(flyToConfig)
		return true
	end
	ret.goldButton = self.goldButton
	return ret
end

-- config = {
-- 	goodsId,
-- 	propId,
-- 	number,
--	flyDuration,
--	delayTime,
-- 	startCallback(coinSprite), -- may be nil
-- 	reachCallback(coinSprite), -- may be nil
-- 	finishCallback,
-- }
-- RETURN: a table containing all elements
-- CAUTION: if there is propId, goodsId will be ignored
-- CAUTION: return nil while something wrong
-- CAUTION: add to parent before call play
function HomeSceneFlyToAnimation:spritesJumpToBagAnimation(config)
	if not self.bagButton or self.bagButton.isDisposed then return end
	local props = config.sprites
	config.flyDuration, config.delayTime = config.flyDuration or 0.8, config.delayTime or 0.3

	local iconSprite = Sprite:createWithSpriteFrameName("home_fly_bag_ani/cells/fly_to_bag_icon0000")

	iconSprite:setPosition(self.bagButton:getFlyToPosition())

	local function onStart(target)
		if config.startCallback then config.startCallback(target) end
	end
	local function onReach(target)
		if target and not target.isDisposed then target:setVisible(false) end
		if not iconSprite.isDisposed then
			iconSprite:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(0.1, 1.5), CCScaleTo:create(0.4, 1)))
		end
		if config.reachCallback then config.reachCallback(target) end
	end
	local function onFinish()
		if config.isFinished then
			return
		end
		config.isFinished=true
		while #props > 0 do
			if not props[1].isDisposed then
				props[1]:removeFromParentAndCleanup(true)
			end
			table.remove(props, 1)
		end
		local function removeSelf()
			if not iconSprite.isDisposed then
				iconSprite:removeFromParentAndCleanup(true)
			end
		end
		local function onDelayOver()
			if not iconSprite.isDisposed then
				iconSprite:runAction(CCSequence:createWithTwoActions(CCFadeOut:create(0.2), CCCallFunc:create(removeSelf)))
			end
		end
		if not iconSprite.isDisposed then
			iconSprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.2), CCCallFunc:create(onDelayOver)))
		end
		if config.finishCallback then config.finishCallback() end
	end

	local jumpToConfig = {
		duration = config.flyDuration,
		sprites = props,
		icon = iconSprite,
		dstPosition = self.bagButton:getFlyToPosition(),
		dstSize = self.bagButton:getFlyToSize(),
		easeIn = true,
		delayTime = config.delayTime,
		startCallback = onStart,
		reachCallback = onReach,
		finishCallback = onFinish,
	}
	local ret = {}
	ret.sprites = props

	ret.play = function(self)
		if not self.bagButton or self.bagButton.isDisposed or self.played then return false end
		if jumpToConfig.icon then
			local icon = jumpToConfig.icon
			icon:setVisible(true)
			icon:setOpacity(0)
			if not icon:getParent() then
				local scene = Director:sharedDirector():getRunningSceneLua()
				scene:addChild(icon, SceneLayerShowKey.TOP_LAYER)
			end
			icon:runAction(CCFadeIn:create(0.2))
		end
		self.played = true
		jumpToConfig.extendAction = CCSequence:createWithTwoActions(CCDelayTime:create(config.flyDuration - 0.1), CCFadeOut:create(0.1))
		JumpFlyToAnimation:create(jumpToConfig)
		return true
	end
	ret.bagButton = self.bagButton
	ret.onFinish = onFinish

	return ret
end

local coinConfigs = {
	{scale = 1, dPosition = ccp(28, 5),},
	{scale = 1, dPosition = ccp(8, 10),},
	{scale = 1, dPosition = ccp(13, -5),},
	{scale = 1, dPosition = ccp(-2, 0),},
	{scale = 1, dPosition = ccp(13, -25),},
}
function HomeSceneFlyToAnimation:levelNodeCoinAnimation(position, finishCallback, parent, reachCallback)
	if not self.coinButton or self.coinButton.isDisposed then return false end
	if not position then return false end
	parent = parent or HomeScene:sharedInstance()
	if not parent or parent.isDisposed then return false end
	local coins = {}
	for k, v in ipairs(coinConfigs) do
		local coin = Sprite:createWithSpriteFrameName("homeSceneCoinIcon0000")
		if coin then
			coin:setAnchorPoint(ccp(0.5, 0.5))
			coin:setScale(v.scale)
			coin:setPosition(ccp(position.x + v.dPosition.x, position.y + v.dPosition.y))
			coin:setOpacity(0)
			table.insert(coins, coin)
		end
	end
	local counter = 1
	local function onReach()
		if coins[counter] and not coins[counter].isDisposed then
			coins[counter]:setVisible(false)
			counter = counter + 1
		end
		if not self.coinButton.isDisposed and self.coinButton.playHighlightAnim then
			self.coinButton:playHighlightAnim()
		end
		if reachCallback then
			reachCallback()
		end
	end
	local function onFinish()
		while #coins > 0 do
			if not coins[1].isDisposed then
				coins[1]:removeFromParentAndCleanup(true)
			end
			table.remove(coins, 1)
		end
		if finishCallback then finishCallback() end
	end
	local config = {
		duration = 0.3,
		sprites = coins,
		dstPosition = self.coinButton:getFlyToPosition(),
		dstSize = self.coinButton:getFlyToSize(),
		direction = true,
		delayTime = 0.1,
		reachCallback = onReach,
		finishCallback = onFinish,
	}
	for k, v in ipairs(coins) do
		local sequence = CCArray:create()
		sequence:addObject(CCDelayTime:create((k - 1) * config.delayTime))
		sequence:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(0.2), CCEaseBackOut:create(CCMoveBy:create(0.4, ccp(0, -30)))))
		if k == 1 then
			local function playFlyToAnim() BezierFlyToAnimation:create(config) end
			sequence:addObject(CCCallFunc:create(playFlyToAnim))
		end

		v:runAction(CCSequence:create(sequence))
		parent:addChild(v, SceneLayerShowKey.TOP_LAYER)
	end

	GamePlayMusicPlayer:playEffect(GameMusicType.kGetRewardCoin)

	return true
end

function HomeSceneFlyToAnimation:levelNodeStarAnimation()
	if not self.starButton or self.starButton.isDisposed then return end
end

function HomeSceneFlyToAnimation:levelNodeEnergyAnimation(position, finishCallback, parent)
	if not self.energyButton or self.energyButton.isDisposed then return false end
	if not position then return false end
	parent = parent or HomeScene:sharedInstance()
	if not parent or parent.isDisposed then return false end
	local coins = {}
	local energy = Sprite:createWithSpriteFrameName("homeSceneEner_j34i0000")
	if not energy then return end
	energy:setAnchorPoint(ccp(0.5, 0.5))
	energy:setPosition(ccp(position.x, position.y))
	local function onFinish()
		if not energy.isDisposed then
			energy:removeFromParentAndCleanup(true)
		end
		energy = nil
		if not self.energyButton.isDisposed and self.energyButton.playHighlightAnim then
			self.energyButton:playHighlightAnim()
		end
		if finishCallback then finishCallback() end
		GamePlayMusicPlayer:playEffect(GameMusicType.kAddEnergy)
	end
	local config = {
		duration = 0.3,
		sprites = {energy},
		dstPosition = self.energyButton:getFlyToPosition(),
		dstSize = self.energyButton:getFlyToSize(),
		direction = false,
		delayTime = 0.1,
		finishCallback = onFinish,
	}
	local sequence = CCArray:create()
	sequence:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(0.2), CCEaseBackOut:create(CCMoveBy:create(0.4, ccp(0, -30)))))
	local function playFlyToAnim() 
		BezierFlyToAnimation:create(config) 
	end
	sequence:addObject(CCCallFunc:create(playFlyToAnim))
	energy:runAction(CCSequence:create(sequence))
	parent:addChild(energy, SceneLayerShowKey.TOP_LAYER)

	return true
end

local propConfigs = {
	{scale = 1, position = ccp(0, 0),},
	{scale = 1, position = ccp(0, 0),},
	{scale = 1, position = ccp(0, 0),},
}
function HomeSceneFlyToAnimation:levelNodeJumpToBagAnimation(props, position, finishCallback, parent)
	if not props or not position then return false end
	if #props <= 0 then -- nothing played, finish next frame
		local function onFinish() if finishCallback then finishCallback() end end
		setTimeOut(onFinish, 1 / 60)
		return true
	end
	if not self.bagButton or self.bagButton.isDisposed then return false end
	parent = parent or HomeScene:sharedInstance()
	if not parent or parent.isDisposed then return false end
	local icons = {}
	for k, v in ipairs(props) do
		local prop = ResourceManager:sharedInstance():buildItemSprite(v)
		if prop then
			local index = k
			if k > #propConfigs then index = k % #propConfigs end
			prop:setAnchorPoint(ccp(0.5, 0.5))
			prop:setScale(propConfigs[index].scale)
			prop:setPosition(ccp(position.x + propConfigs[index].position.x, position.y + propConfigs[index].position.y))
			prop:setOpacity(0)
			table.insert(icons, prop)
		end
	end

	local iconSprite = Sprite:createWithSpriteFrameName("home_fly_bag_ani/cells/fly_to_bag_icon0000")
	iconSprite:setPosition(self.bagButton:getFlyToPosition())
	local iconSpPos = nil

	local counter = 1
	local function onReach()
		if icons[counter] and not icons[counter].isDisposed then
			icons[counter]:setVisible(false)
			counter = counter + 1
		end
		iconSprite:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(kAnimationTime * 3, 0.83), CCScaleTo:create(kAnimationTime * 6, 1)))
		if iconSpPos then 
			local whiteSp = Sprite:createWithSpriteFrameName("home_top_bar_ani/cells/white_coin0000")
			parent:addChild(whiteSp, SceneLayerShowKey.TOP_LAYER)
			whiteSp:setPosition(iconSpPos)

			local arr = CCArray:create()
			arr:addObject(CCSpawn:createWithTwoActions(
				CCScaleTo:create(kAnimationTime*12, 3.08),
				CCFadeTo:create(kAnimationTime*12, 0)
			))
			arr:addObject(CCCallFunc:create(function()
				whiteSp:removeFromParentAndCleanup(true)
			end))
			whiteSp:runAction(CCSequence:create(arr))
		end
		GamePlayMusicPlayer:playEffect(GameMusicType.kGetRewardProp)	
	end
	local function onFinish()
		while #icons > 0 do
			if not icons[1].isDisposed then
				icons[1]:removeFromParentAndCleanup(true)
			end
			table.remove(icons, 1)
		end

		if not iconSprite.isDisposed then 
			local arr = CCArray:create()
			arr:addObject(CCDelayTime:create(kAnimationTime * 8))
			arr:addObject(CCScaleTo:create(kAnimationTime * 3, 1.05))
			arr:addObject(CCScaleTo:create(kAnimationTime * 2, 0.8))
			arr:addObject(CCScaleTo:create(kAnimationTime * 1, 0))
			arr:addObject(CCCallFunc:create(function ()
				iconSprite:removeFromParentAndCleanup(true)
			end))
			iconSprite:runAction(CCSequence:create(arr))
		end
		if finishCallback then finishCallback() end
	end
	local config = {
		duration = 0.8,
		sprites = icons,
		icon = iconSprite,
		dstPosition = self.bagButton:getFlyToPosition(),
		dstSize = self.bagButton:getFlyToSize(),
		easeIn = true,
		delayTime = 0.1,
		height = 100,
		reachCallback = onReach,
		finishCallback = onFinish,
	}
	for k, v in ipairs(icons) do
		local sequence = CCArray:create()
		sequence:addObject(CCDelayTime:create((k - 1) * config.delayTime))
		sequence:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(0.2), CCEaseBackOut:create(CCMoveBy:create(0.3, ccp(0, -30)))))
		if k == 1 then
			local function playFlyToAnim()
				config.extendAction = CCSequence:createWithTwoActions(CCDelayTime:create(0.7), CCFadeOut:create(0.1))
				JumpFlyToAnimation:create(config)
			end
			sequence:addObject(CCCallFunc:create(playFlyToAnim))
		end
		v:runAction(CCSequence:create(sequence))
		parent:addChild(v, SceneLayerShowKey.TOP_LAYER)
	end

	iconSprite:setScale(0)
	parent:addChild(iconSprite, SceneLayerShowKey.TOP_LAYER)
	local arr = CCArray:create()
	arr:addObject(CCScaleTo:create(kAnimationTime * 2, 0.73))
	arr:addObject(CCScaleTo:create(kAnimationTime * 3, 1.16))
	arr:addObject(CCScaleTo:create(kAnimationTime * 3, 1))
	iconSprite:runAction(CCSequence:create(arr))

	local bounds = iconSprite:getGroupBounds()
	iconSpPos = parent:convertToNodeSpace(ccp(bounds:getMidX(), bounds:getMidY())) 
	
	return true
end

--this is old one
function HomeSceneFlyToAnimation:__levelNodeJumpToBagAnimation(props, position, finishCallback, parent)
	if not props or not position then return false end
	if #props <= 0 then -- nothing played, finish next frame
		local function onFinish() if finishCallback then finishCallback() end end
		setTimeOut(onFinish, 1 / 60)
		return true
	end
	if not self.bagButton or self.bagButton.isDisposed then return false end
	parent = parent or HomeScene:sharedInstance()
	if not parent or parent.isDisposed then return false end
	local icons = {}
	for k, v in ipairs(props) do
		local prop = ResourceManager:sharedInstance():buildItemSprite(v)
		if prop then
			local index = k
			if k > #propConfigs then index = k % #propConfigs end
			prop:setAnchorPoint(ccp(0.5, 0.5))
			prop:setScale(propConfigs[index].scale)
			prop:setPosition(ccp(position.x + propConfigs[index].position.x, position.y + propConfigs[index].position.y))
			prop:setOpacity(0)
			table.insert(icons, prop)
		end
	end

	local iconSprite = Sprite:createWithSpriteFrameName("bagButtonImage0000")
	iconSprite:setPosition(self.bagButton:getFlyToPosition())

	local counter = 1
	local function onReach()
		if icons[counter] and not icons[counter].isDisposed then
			icons[counter]:setVisible(false)
			counter = counter + 1
		end
		iconSprite:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(0.1, 1.5), CCScaleTo:create(0.4, 1)))
		GamePlayMusicPlayer:playEffect(GameMusicType.kGetRewardProp)	
	end
	local function onFinish()
		while #icons > 0 do
			if not icons[1].isDisposed then
				icons[1]:removeFromParentAndCleanup(true)
			end
			table.remove(icons, 1)
		end
		local function removeSelf() iconSprite:removeFromParentAndCleanup(true) end
		local function onDelayOver()
			iconSprite:runAction(CCSequence:createWithTwoActions(CCFadeOut:create(0.2), CCCallFunc:create(removeSelf)))
		end
		iconSprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.2), CCCallFunc:create(onDelayOver)))
		if finishCallback then finishCallback() end
	end
	local config = {
		duration = 0.8,
		sprites = icons,
		icon = iconSprite,
		dstPosition = self.bagButton:getFlyToPosition(),
		dstSize = self.bagButton:getFlyToSize(),
		easeIn = true,
		delayTime = 0.1,
		height = 100,
		reachCallback = onReach,
		finishCallback = onFinish,
	}
	for k, v in ipairs(icons) do
		local sequence = CCArray:create()
		sequence:addObject(CCDelayTime:create((k - 1) * config.delayTime))
		sequence:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(0.2), CCEaseBackOut:create(CCMoveBy:create(0.3, ccp(0, -30)))))
		if k == 1 then
			local function playFlyToAnim()
				config.extendAction = CCSequence:createWithTwoActions(CCDelayTime:create(0.7), CCFadeOut:create(0.1))
				JumpFlyToAnimation:create(config)
			end
			sequence:addObject(CCCallFunc:create(playFlyToAnim))
		end
		v:runAction(CCSequence:create(sequence))
		parent:addChild(v, SceneLayerShowKey.TOP_LAYER)
	end
	iconSprite:setOpacity(0)
	parent:addChild(iconSprite, SceneLayerShowKey.TOP_LAYER)
	iconSprite:runAction(CCFadeIn:create(0.2))

	return true
end

-- RETURN: layer
-- CAUTION: return nil while something wrong
-- CAUTION: add to parent before call play
local coinNumber = 0
local chanceToFall = {2, 2, 3, 4, 4, 5, 6, 6, 6, 5, 4, 4, 3, 2, 2}
for k, v in ipairs(chanceToFall) do coinNumber = coinNumber + v end
function HomeSceneFlyToAnimation:createCoinRain(finishCallback)
	local randomTable = {}
	local function createFallingCoinAnim(index, fakeCoin, isEnergy)
		local wSize = Director:sharedDirector():getWinSize()
		local vSize = Director:sharedDirector():getVisibleSize()
		local vOrigin = Director:sharedDirector():getVisibleOrigin()

		local flyingCoin
		if isEnergy then flyingCoin = Sprite:createWithSpriteFrameName("homeSceneEner_j34i0000")
		else flyingCoin = Sprite:createWithSpriteFrameName("homeSceneCoinIcon0000") end
		local stackCoin = Sprite:createWithSpriteFrameName("asset/lying_coin0000")
		if not flyingCoin or not stackCoin then return end
		local size = stackCoin:getContentSize()
		randomTable[index] = randomTable[index] or 0
		local baseX = index * wSize.width / #chanceToFall - size.width / 2
		local randomX = math.random() * size.width / 2 - size.width / 5
		local baseY = randomTable[index] * size.height / 2 + size.height
		local randomY = math.random() * size.height / 3 - size.height / 3
		flyingCoin:setPositionX(baseX + randomX)
		flyingCoin:setPositionY(baseY + randomY + wSize.height)
		stackCoin:setPositionX(baseX + randomX)
		stackCoin:setPositionY(baseY + randomY)
		stackCoin:setVisible(false)
		local function afterFall()
			if flyingCoin or not flyingCoin.isDisposed then flyingCoin:setVisible(false) end
			if stackCoin and not stackCoin.isDisposed then
				stackCoin:setVisible(true)
				stackCoin:setAnchorPointWhileStayOriginalPosition(ccp(1, 0.5))
				stackCoin:runAction(CCSequence:createWithTwoActions(CCRotateTo:create(0.05, 10), CCRotateTo:create(0.05, 0)))
			end
		end
		local arr = CCArray:create()
		arr:addObject(CCEaseSineIn:create(CCMoveBy:create(0.6, ccp(0, -wSize.height))))
		arr:addObject(CCCallFunc:create(afterFall))
		if fakeCoin then
			stackCoin:dispose()
			stackCoin = nil
		else randomTable[index] = randomTable[index] + 1 end
		flyingCoin:runAction(CCSequence:create(arr))
		return flyingCoin, stackCoin
	end
	local counter = 1
	local layer = Layer:create()
	local lChanceToFall = {}
	for k, v in ipairs(chanceToFall) do lChanceToFall[k] = v end
	local state = 1
	local function generateCoin()
		local index = ChanceUtils:randomSelectByChance(lChanceToFall)
		local flyingCoin, stackCoin = createFallingCoinAnim(index, state % 3 ~= 1, state % 5 == 1)
		if not layer or layer.isDisposed or not flyingCoin then return end
		layer:addChild(flyingCoin)
		if state % 3 == 1 then
			if stackCoin then layer:addChild(stackCoin) end
			lChanceToFall[index] = lChanceToFall[index] - 1
			counter = counter + 1
		end
		state = state + 1
		if counter > coinNumber then
			layer:stopAllActions()
			if finishCallback then finishCallback() end
		end
	end
	layer:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCCallFunc:create(generateCoin), CCDelayTime:create(0.03))))
	GamePlayMusicPlayer:getInstance():playEffect(GameMusicType.kCoinTick, 100)
	return layer
end

-- RETURN: layer
-- CAUTION: return nil while something wrong
-- CAUTION: add to parent before call play
function HomeSceneFlyToAnimation:createGoldRain(finishCallback)
	local randomTable = {}
	local function createFallingCoinAnim(index, fakeCoin)
		local wSize = Director:sharedDirector():getWinSize()
		local vSize = Director:sharedDirector():getVisibleSize()
		local vOrigin = Director:sharedDirector():getVisibleOrigin()

		local flyingCoin = Sprite:createWithSpriteFrameName("ui_images/ui_image_coin_icon_small0000")
		local stackCoin = Sprite:createWithSpriteFrameName("lyingWheel_img0000")
		if not flyingCoin or not stackCoin then return end
		flyingCoin:setScale(1.3)
		local size = stackCoin:getContentSize()
		randomTable[index] = randomTable[index] or 0
		local baseX = index * wSize.width / #chanceToFall - size.width / 2
		local randomX = math.random() * size.width / 2 - size.width / 5
		local baseY = randomTable[index] * size.height / 2 + size.height
		local randomY = math.random() * size.height / 3 - size.height / 3
		flyingCoin:setPositionX(baseX + randomX)
		flyingCoin:setPositionY(baseY + randomY + wSize.height)
		stackCoin:setPositionX(baseX + randomX)
		stackCoin:setPositionY(baseY + randomY)
		stackCoin:setVisible(false)
		local function afterFall()
			if flyingCoin or not flyingCoin.isDisposed then flyingCoin:setVisible(false) end
			if stackCoin and not stackCoin.isDisposed then
				stackCoin:setVisible(true)
				stackCoin:setAnchorPointWhileStayOriginalPosition(ccp(1, 0.5))
				stackCoin:runAction(CCSequence:createWithTwoActions(CCRotateTo:create(0.05, 10), CCRotateTo:create(0.05, 0)))
			end
		end
		local arr = CCArray:create()
		arr:addObject(CCEaseSineIn:create(CCMoveBy:create(0.6, ccp(0, -wSize.height))))
		arr:addObject(CCCallFunc:create(afterFall))
		if fakeCoin then
			stackCoin:dispose()
			stackCoin = nil
		else randomTable[index] = randomTable[index] + 1 end
		flyingCoin:runAction(CCSequence:create(arr))
		return flyingCoin, stackCoin
	end
	local counter = 1
	local layer = Layer:create()
	local lChanceToFall = {}
	for k, v in ipairs(chanceToFall) do lChanceToFall[k] = v end
	local state = 1
	local function generateCoin()
		local index = ChanceUtils:randomSelectByChance(lChanceToFall)
		local flyingCoin, stackCoin = createFallingCoinAnim(index, state % 3 ~= 1)
		if not layer or layer.isDisposed or not flyingCoin then return end
		layer:addChild(flyingCoin)
		if state % 3 == 1 then
			if stackCoin then layer:addChild(stackCoin) end
			lChanceToFall[index] = lChanceToFall[index] - 1
			counter = counter + 1
		end
		state = state + 1
		if counter > coinNumber then
			layer:stopAllActions()
			if finishCallback then finishCallback() end
		end
	end
	layer:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCCallFunc:create(generateCoin), CCDelayTime:create(0.03))))
	GamePlayMusicPlayer:getInstance():playEffect(GameMusicType.kCoinTick, 100)
	return layer
end