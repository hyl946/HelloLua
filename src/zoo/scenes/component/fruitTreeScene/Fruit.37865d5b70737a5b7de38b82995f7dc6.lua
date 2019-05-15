require "zoo.data.MetaManager"
require "zoo.scenes.component.HomeScene.item.HomeSceneItemProgressBar"
require "zoo.net.OnlineSetterHttp"
require "zoo.scenes.component.HomeSceneFlyToAnimation"
require "zoo.data.UserEnergyRecoverManager"

local BuyConfirmPanel = class(BasePanel)
function BuyConfirmPanel:create( needBuyCount,okCallback )
	local buyConfirmPanel = BuyConfirmPanel.new()
	buyConfirmPanel:loadRequiredResource(PanelConfigFiles.panel_fruit_tree)
	buyConfirmPanel:init(needBuyCount,okCallback)
	return buyConfirmPanel
end
function BuyConfirmPanel:unloadRequiredResource(  )
end
function BuyConfirmPanel:init( needBuyCount,okCallback )
	self.ui = self:buildInterfaceGroup("fruitTree/buyConfirmPanel")
	BasePanel.init(self,self.ui)

	local closeBtn = self.ui:getChildByName("closeBtn")
	closeBtn:setTouchEnabled(true)
	closeBtn:setButtonMode(true)
	closeBtn:addEventListener(DisplayEvents.kTouchTap,function( ... )
		self:remove()
	end)

	local text = self.ui:getChildByName("text")
	text:setVerticalAlignment(kCCVerticalTextAlignmentCenter)
	text:setString(Localization:getInstance():getText("fruit.tree.scene.no.speed.tip", {number = needBuyCount}))

	local button = GroupButtonBase:create(self.ui:getChildByName("button"))
	button:setString(Localization:getInstance():getText("fruit.tree.scene.no.speed.yes"))
	button:addEventListener(DisplayEvents.kTouchTap,function( ... )
		self:remove()
		if okCallback then
			okCallback()
		end
	end)

	local visibleSize = Director:sharedDirector():getVisibleSize()
	local size = self.ui:getChildByName("bg"):getGroupBounds().size
	self:setPositionY(-visibleSize.height/2 + size.height/2)
	self:setPositionX(visibleSize.width/2 - size.width/2)
end
function BuyConfirmPanel:remove( ... )
	PopoutManager:sharedInstance():remove(self)
end
function BuyConfirmPanel:popout( ... )
	PopoutManager:sharedInstance():add(self, false, false)
end

local PickConfirmPanel = class(BasePanel)
function PickConfirmPanel:create( isFullEnergy,addEnergy,okCallback )
	local pickConfirmPanel = PickConfirmPanel.new()
	pickConfirmPanel:loadRequiredResource(PanelConfigFiles.panel_fruit_tree)
	pickConfirmPanel:init(isFullEnergy,addEnergy,okCallback)
	return pickConfirmPanel
end
function PickConfirmPanel:unloadRequiredResource( ... )
end
function PickConfirmPanel:init(isFullEnergy,addEnergy,okCallback)
	self.ui = self:buildInterfaceGroup("fruitTree/pickConfirmPanel")
	BasePanel.init(self,self.ui)

	local text = self.ui:getChildByName("text")
	text:setVerticalAlignment(kCCVerticalTextAlignmentCenter)
	if isFullEnergy then
		text:setString(Localization:getInstance():getText("fruit.tree.scene.pick.energy.tip"))
	else
		text:setString("精力快满了~摘取该果实只能获得" .. tostring(addEnergy) .. "点精力~")
	end

	local okButton = GroupButtonBase:create(self.ui:getChildByName("ok"))
	okButton:setColorMode(kGroupButtonColorMode.orange)
	okButton:setString(Localization:getInstance():getText("fruit.tree.scene.pick.energy.yes"))
	okButton:addEventListener(DisplayEvents.kTouchTap,function( ... )
		self:remove()
		if okCallback then
			okCallback()
		end
	end)

	local cancelButton = GroupButtonBase:create(self.ui:getChildByName("cancel"))
	cancelButton:setString(Localization:getInstance():getText("fruit.tree.scene.pick.energy.no"))
	cancelButton:addEventListener(DisplayEvents.kTouchTap,function( ... )
		self:remove()
	end)

	local visibleSize = Director:sharedDirector():getVisibleSize()
	local size = self.ui:getChildByName("bg"):getGroupBounds().size
	self:setPositionY(-visibleSize.height/2 + size.height/2)
	self:setPositionX(visibleSize.width/2 - size.width/2)
end
function PickConfirmPanel:remove( ... )
	PopoutManager:sharedInstance():remove(self)
end
function PickConfirmPanel:popout( ... )
	PopoutManager:sharedInstance():add(self, false, false)
end


kFruitEvents = {
	kNormClicked = "kFruitEvents.kNormClicked",
	kSelectedCancel = "kFruitEvents.kSelectedCancel",
	kPick = "kFruitEvents.kPick",
	kRegenerate = "kFruitEvents.kRegenerate",
	kUpdate = "kFruitEvents.kUpdate",
	kCallMarket = "",
}

local kGrowTime = 1800000
local kFruitType = {
	kCoin = 0,
	kEnergy = 1,
	kGold = 2,
}

local builder

Fruit = class(CocosObject)
function Fruit:create(id, data)
	local fruit = Fruit.new()
	if not fruit:_init(id, data) then fruit = nil end
	return fruit
end

function Fruit:ctor()
	self:setRefCocosObj(CCNode:create())
end

function Fruit:dispose()
	
	if self.scheduler then
		Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
		self.scheduler = nil
	end

	if self.norm and not self.norm.isDisposed then self.norm:dispose() end
	if self.clicked and not self.clicked.isDisposed then  self.clicked:dispose() end
	CocosObject.dispose(self)
end

function Fruit:_init(id, data)
	-- data
	self.id = id
	self.fruitLogic = FruitLogic:create()

	-- get & create control
	builder = InterfaceBuilder:create(PanelConfigFiles.fruitTreeScene)
	self.norm = builder:buildGroup("normFruit")
	self.norm.fruit = self.norm:getChildByName("fruit")
	self.norm.progress = self.norm:getChildByName("progress")
	self.norm.level = self.norm:getChildByName("level")
	self.norm.progress = HomeSceneItemProgressBar:create(self.norm.progress, 30, 100)
	self.norm.levelPosY = self.norm.level:getPositionY()
	self.norm.progressPosY = self.norm.progress:getPositionY() + 10

	-- state
	self:refresh(data, "init")

	self:addChild(self.norm)

	-- event listener
		local function onRelease()
			self:dispatchEvent(Event.new(kFruitEvents.kNormClicked, nil, self))
		end
		self.norm:setTouchEnabled(true)
		self.norm:addEventListener(DisplayEvents.kTouchEnd, onRelease)

	return true
end

function Fruit:getId() return self.id end

function Fruit:refresh(data, source)
	-- data

	local oldLevel = FruitModel:sharedInstance():getFruitLevel(self.id)
	if data then FruitModel:sharedInstance():setData(self.id, data) end
	local nowLevel = FruitModel:sharedInstance():getFruitLevel(self.id)
	local newLevel = nowLevel
	local normFruit, clickedFruit
	local beforeFruit, afterFruit

	local function createStarAnim(star, beforeDelay, afterDelay)
		local sprite = star:getChildByName("sprite")
		sprite:setOpacity(0)
		local arr = CCArray:create()
		if beforeDelay then arr:addObject(CCDelayTime:create(beforeDelay)) end
		arr:addObject(CCFadeIn:create(0.3))
		arr:addObject(CCDelayTime:create(0.4))
		arr:addObject(CCFadeOut:create(0.3))
		if afterDelay then arr:addObject(CCDelayTime:create(afterDelay)) end
		sprite:runAction(CCRepeatForever:create(CCSequence:create(arr)))
		local scale = star:getScale()
		star:setScale(scale * 0.7)
		arr = CCArray:create()
		local arr1 = CCArray:create()
		if beforeDelay then arr:addObject(CCDelayTime:create(beforeDelay)) end
		arr1:addObject(CCRotateBy:create(1, 180))
		local arr2 = CCArray:create()
		arr2:addObject(CCScaleTo:create(0.3, scale))
		arr2:addObject(CCDelayTime:create(0.4))
		arr2:addObject(CCScaleTo:create(0.3, scale * 0.7))
		arr1:addObject(CCSequence:create(arr2))
		arr:addObject(CCSpawn:create(arr1))
		if afterDelay then arr:addObject(CCDelayTime:create(afterDelay)) end
		star:runAction(CCRepeatForever:create(CCSequence:create(arr)))
	end

	-- normal
	if self.norm and not self.norm.isDisposed then
		local name = FruitModel:sharedInstance():getFruitName(self.id)
		if not name then return end
		builder = InterfaceBuilder:createWithContentsOfFile(PanelConfigFiles.fruitTreeScene)
		local sprite = builder:buildGroup(name)
		local position = self.norm.fruit:getPosition()
		sprite:setPosition(ccp(position.x, position.y))
		self.norm:addChild(sprite)
		beforeFruit, afterFruit = self.norm.fruit, sprite

		if newLevel > 0 then
			local star1 = sprite:getChildByName("star1")
			local star2 = sprite:getChildByName("star2")
			if FruitModel:sharedInstance():needStarBlink(self.id) then
				createStarAnim(star1, 0.2, 0.6)
				createStarAnim(star2, 0.5, 0.3)
			else
				star1:setVisible(false)
				star2:setVisible(false)
			end
		end

		local star1 = beforeFruit:getChildByName("star1")
		local star2 = beforeFruit:getChildByName("star2")
		if star1 and star1:isVisible() then
			local sprite = star1:getChildByName("sprite")
			sprite:stopAllActions()
			star1:stopAllActions()
			star1:setVisible(false)
		end
		if star2 and star2:isVisible() then
			local sprite = star2:getChildByName("sprite")
			sprite:stopAllActions()
			star2:stopAllActions()
			star2:setVisible(false)
		end

		self:_playAnim(oldLevel, newLevel, self.norm, beforeFruit, afterFruit, source)
		
		self.norm.level:setText(FruitModel:sharedInstance():getLevelString(self.id))
		local rect = self.norm.level:getContentSize()
		self.norm.level:setPositionX(-rect.width / 2)
		local value, max = FruitModel:sharedInstance():getProgress(self.id)
		if not value or not max then
			self.norm.progress:setVisible(false)
			self.norm.level:setPositionY(self.norm.progressPosY)
		else
			self.norm.level:setPositionY(self.norm.levelPosY)
			self.norm.progress:setVisible(true)
			self.norm.progress:setTotalNumber(max)
			self.norm.progress:setCurNumber(value)
		end
	end

	-- clicked
	if self.clicked and not self.clicked.isDisposed then
		local name = FruitModel:sharedInstance():getFruitName(self.id)
		if not name then return end
		builder = InterfaceBuilder:create(PanelConfigFiles.fruitTreeScene)
		local sprite = builder:buildGroup(name)
		local position = self.clicked.fruit:getPosition()
		sprite:setPosition(ccp(position.x, position.y))
		self.clicked:addChild(sprite)
		beforeFruit, afterFruit = self.clicked.fruit, sprite

		if newLevel > 0 then
			local star1 = sprite:getChildByName("star1")
			local star2 = sprite:getChildByName("star2")
			if FruitModel:sharedInstance():needStarBlink(self.id) then
				createStarAnim(star1, 0.2, 0.6)
				createStarAnim(star2, 0.5, 0.3)
			else
				star1:setVisible(false)
				star2:setVisible(false)
			end
		end

		local star1 = beforeFruit:getChildByName("star1")
		local star2 = beforeFruit:getChildByName("star2")
		if star1 and star1:isVisible() then
			local sprite = star1:getChildByName("sprite")
			sprite:stopAllActions()
			star1:stopAllActions()
			star1:setVisible(false)
		end
		if star2 and star2:isVisible() then
			local sprite = star2:getChildByName("sprite")
			sprite:stopAllActions()
			star2:stopAllActions()
			star2:setVisible(false)
		end

		self:_playAnim(oldLevel, newLevel, self.clicked, beforeFruit, afterFruit, source)

		local regen, pick, speed = FruitModel:sharedInstance():getMethodVisibility(self.id)
		self.clicked.regen:setVisible(regen)
		self.clicked.pick:setVisible(pick)
		self.clicked.speed:setVisible(speed)
		if self.id>=0 then
			local count = FruitModel:sharedInstance():getAccelerateNeededCount(self.id)
			if count > 0 then
				self.clicked.speed.number:setString("x"..tostring(count))
			end
		end

		if self.clicked.regen:isVisible() and FruitModel:sharedInstance():getRegenShowAnim(self.id) then
			local arr = CCArray:create()
			arr:addObject(CCDelayTime:create(0.5))
			arr:addObject(CCScaleTo:create(0.75, 1.125))
			arr:addObject(CCScaleTo:create(0.75, 1))
			self.clicked.regen:runAction(CCRepeatForever:create(CCSequence:create(arr)))
			local text = TextField:create(Localization:getInstance():getText("fruit.tree.scene.regen.tip"),
				nil, 24, CCSizeMake(190, 0), kTextAlignment.kCCTextAlignmentLeft,
				kVerticalTextAlignment.kCCVerticalTextAlignmentTop)
			text:setPositionXY(self.clicked.regen:getPositionX() + 25, self.clicked.regen:getPositionY() + 150)
			if self.id == 5 then
				text:setPositionXY(self.clicked.regen:getPositionX() + 50, self.clicked.regen:getPositionY() + 150)
			end
			self.clicked:addChild( text )
		end

		local coin, energy, gold, amount = FruitModel:sharedInstance():getReward(self.id)
		self.clicked.icon2:setVisible(coin)
		self.clicked.icon3:setVisible(gold)
		self.clicked.icon4:setVisible(energy)
		self.clicked.reward:setString(amount)
		if FruitModel:sharedInstance():getGrowCount(self.id) < 5 then
			-- self.clicked.time:setVisible(true)
			self.clicked.time:setString(Localization:getInstance():getText("fruit.tree.scene.elapse", {time = FruitModel:sharedInstance():getUpdateTimerString(self.id), num = FruitModel:sharedInstance():getGrowCount(self.id) + 1}))
		else
			-- self.clicked.time:setVisible(false)
			self.clicked.time:setString(Localization:getInstance():getText("fruit.tree.scene.ripe.fruit", {n = '\n', number = FruitModel:sharedInstance():getFruitPickCount()}))
		end
	end

	-- addTimer
	if FruitModel:sharedInstance():getGrowCount(self.id)  < 5 then
		local function onTimeout() self:_onTimer() end
		if not self.scheduler then
			self.scheduler = Director:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, 0.5, false)
		end
	else
		if self.scheduler then
			Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
			self.scheduler = nil
		end
	end
end

function Fruit:_playAnim(oldLevel, newLevel, target, beforeSprite, afterSprite, source)
	if source == "update" then
		self:_playUpdateAnim(oldLevel, newLevel, target, beforeSprite, afterSprite, source)
	elseif source == "regenerate" then
		self:_playRegenAnim(target, beforeSprite, afterSprite, source)
	elseif source == "pick" then
		self:_playPickAnim(target, beforeSprite, afterSprite, source)
	else
		beforeSprite:removeFromParentAndCleanup(true)
		target.fruit = afterSprite
	end
end

function Fruit:_playUpdateAnim(oldLevel, newLevel, target, beforeSprite, afterSprite, source)
	if newLevel > oldLevel then
		self:_playUpdateSuccessAnim(target, beforeSprite, afterSprite, source)
	else
		self:_playUpdateFailAnim(target, beforeSprite, afterSprite, source)
	end
end

function Fruit:_playUpdateSuccessAnim(target, beforeSprite, afterSprite, source)
	builder = InterfaceBuilder:create(PanelConfigFiles.fruitTreeScene)
	local beforeSize = beforeSprite:getGroupBounds().size
	beforeSize = {width = beforeSize.width, height = beforeSize.height}
	local afterSize = afterSprite:getGroupBounds().size
	afterSize = {width = afterSize.width, height = afterSize.height}
	afterSprite:setScaleX(beforeSize.width / afterSize.width)
	afterSprite:setScaleY(beforeSize.height / afterSize.height)
	afterSprite:setVisible(false)
	beforeSprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.6), CCToggleVisibility:create()))
	local afterArr = CCArray:create()
	afterArr:addObject(CCDelayTime:create(0.6))
	afterArr:addObject(CCToggleVisibility:create())
	afterArr:addObject(CCEaseBackOut:create(CCScaleTo:create(0.2, 1)))
	afterSprite:runAction(CCSequence:create(afterArr))
	local mask = builder:buildGroup("fruitmask")
	local sprite = mask:getChildByName("sprite")
	mask:setPosition(ccp(afterSprite:getPositionX(), afterSprite:getPositionY()))
	local maskSize = mask:getGroupBounds().size
	maskSize = {width = maskSize.width, height = maskSize.height}
	mask:setScaleX(beforeSize.width / maskSize.width)
	mask:setScaleY(beforeSize.height / maskSize.height)
	sprite:setOpacity(0)
	target:addChild(mask)
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(0.5))
	arr:addObject(CCFadeIn:create(0.1))
	arr:addObject(CCDelayTime:create(0.1))
	arr:addObject(CCFadeOut:create(0.1))
	sprite:runAction(CCSequence:create(arr))
	mask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5), CCScaleTo:create(0.2, afterSize.width / maskSize.width, afterSize.height / maskSize.height)))
	local function playParticle()
		local particles = ParticleSystemQuad:create("particle/fruit_update.plist")
		particles:setAutoRemoveOnFinish(true)
		particles:setPosition(ccp(0, 40))
		target:addChild(particles)
	end
	afterSprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.6), CCCallFunc:create(playParticle)))
	local function onTimeOut()
		if beforeSprite.isDisposed or afterSprite.isDisposed or mask.isDisposed then return end
		beforeSprite:removeFromParentAndCleanup(true)
		mask:removeFromParentAndCleanup(true)
	end
	target.fruit = afterSprite
	setTimeOut(onTimeOut, 1)
end

function Fruit:_playUpdateFailAnim(target, beforeSprite, afterSprite, source)
	local text = TextField:create(Localization:getInstance():getText("fruit.tree.scene.upgrade.fail"), nil, 24, CCSizeMake(0, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
	local textSize = text:getContentSize()
	text:setPosition(ccp(0, 80))
	target:addChild(text)
	text:runAction(CCSpawn:createWithTwoActions(CCMoveBy:create(1, ccp(0, 80)), CCFadeOut:create(1)))
	local function onTimeOut()
		if text and not text.isDisposed then text:removeFromParentAndCleanup(true) end
	end
	setTimeOut(onTimeOut, 1)
	local arr = CCArray:create()
	arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, -18)))
    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, 15)))
    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, -12)))
    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, 9)))
    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, -4)))
    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, 2)))
    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
    afterSprite:runAction(CCSequence:create(arr))
    target.fruit = afterSprite
    beforeSprite:removeFromParentAndCleanup(true)
end

function Fruit:_playRegenAnim(target, beforeSprite, afterSprite, source)
	local function shake(sprite)
		local arr = CCArray:create()
		arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, -18)))
	    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
	    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, 15)))
	    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
	    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, -12)))
	    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
	    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, 9)))
	    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
	    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, -4)))
	    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
	    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, 2)))
	    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
	    sprite:runAction(CCSequence:create(arr))
	end
	shake(beforeSprite)
	beforeSprite:runAction(CCEaseBackIn:create(CCScaleTo:create(0.3, 0)))
	afterSprite:setScale(0)
	shake(afterSprite)
	afterSprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.3), CCEaseBackOut:create(CCScaleTo:create(0.3, 1))))

	local function onTimeOut()
		if beforeSprite.isDisposed or afterSprite.isDisposed then return end
		beforeSprite:removeFromParentAndCleanup(true)
		afterSprite:stopAllActions()
		afterSprite:setScale(1)
		afterSprite:setRotation(0)
	end
	target.fruit = afterSprite
	setTimeOut(onTimeOut, 1.2)
end

function Fruit:_playPickAnim(target, beforeSprite, afterSprite, source)
	local sprite = afterSprite:getChildByName("sprite")
	sprite:setOpacity(0)
	sprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.8), CCFadeIn:create(0.2)))
	beforeSprite:runAction(CCEaseBackIn:create(CCMoveBy:create(0.6, ccp(0, 100))))
	beforeSprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.4), CCScaleTo:create(0.2, 1.5)))
	sprite = beforeSprite:getChildByName("sprite")
	sprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.4), CCFadeOut:create(0.2)))

	local function onTimeOut()
		if beforeSprite.isDisposed or afterSprite.isDisposed then return end
		beforeSprite:removeFromParentAndCleanup(true)
		local sprite = afterSprite:getChildByName("sprite")
		sprite:setOpacity(255)
	end
	target.fruit = afterSprite
	setTimeOut(onTimeOut, 1)
end

function Fruit:_onTimer()
	if self.norm and not self.norm.isDisposed then
		local value, max = FruitModel:sharedInstance():getProgress(self.id)
		if not value or not max then self.norm.progress:setVisible(false)
		else
			self.norm.progress:setVisible(true)
			self.norm.progress:setTotalNumber(max)
			self.norm.progress:setCurNumber(value)
		end
	end
	if self.clicked and not self.clicked.isDisposed then
		if FruitModel:sharedInstance():getGrowCount(self.id) < 5 then
			self.clicked.time:setVisible(true)
			self.clicked.time:setString(Localization:getInstance():getText("fruit.tree.scene.elapse", {time = FruitModel:sharedInstance():getUpdateTimerString(self.id), num = FruitModel:sharedInstance():getGrowCount(self.id) + 1}))
		else
			self.clicked.time:setVisible(false)
		end
		local count = FruitModel:sharedInstance():getAccelerateNeededCount(self.id)
		if count > 0 and self.clicked.speed.number then
			self.clicked.speed.number:setString("x"..tostring(count))
		end
	end
	if FruitModel:sharedInstance():getNeedUpdate(self.id) then
		self:dispatchEvent(Event.new(kFruitEvents.kUpdate, nil, self))
		if self.scheduler then
			Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
			self.scheduler = nil
		end
	end
end

function Fruit:createClickedFruit(hasGuide, animDuration)
	if self.norm.isDisposed then return end

	-- get & create control
	builder = InterfaceBuilder:createWithContentsOfFile(PanelConfigFiles.fruitTreeScene)
	self.clicked = builder:buildGroup("clickedFruit")
	self.clicked.fruit = self.clicked:getChildByName("fruit")
	self.clicked.methodRing = self.clicked:getChildByName("methodRing")
	self.clicked.regen = self.clicked:getChildByName("regen")
	self.clicked.pick = self.clicked:getChildByName("pick")
	self.clicked.speed = self.clicked:getChildByName("speed")
	self.clicked.speed.number = self.clicked.speed:getChildByName("number")
	self.clicked.reward = self.clicked:getChildByName("reward")
	self.clicked.time = self.clicked:getChildByName("time")
	self.clicked.icon2 = self.clicked:getChildByName("icon2")
	self.clicked.icon3 = self.clicked:getChildByName("icon3")
	self.clicked.icon4 = self.clicked:getChildByName("icon4")

	-- state
	local function setMethodUI(ctrl, text)
		local name = {"regen", "pick", "speed"}
		for k, v in ipairs(name) do
			local icn = ctrl:getChildByName("icn_"..v)
			if icn and v ~= text then icn:removeFromParentAndCleanup(true) end
		end
		local size = ctrl:getChildByName('textSize')
		size:setVisible(false)

		local label = ctrl:getChildByName("text")
		if label then 
			-- label = TextField:createWithUIAdjustment(size, label)
			-- ctrl:addChild(label)

			label:changeFntFile("fnt/guoshu_gai_1.fnt")
			label:setText(Localization:getInstance():getText("fruit.tree.scene."..text))

			local box = {x=size:getPositionX(), y=size:getPositionY(), width=size:getContentSize().width*size:getScaleX(), height=size:getContentSize().height*size:getScaleY()}
			InterfaceBuilder:centerInterfaceInbox(label, box, true)
		end
	end
	setMethodUI(self.clicked.regen, "regen")
	setMethodUI(self.clicked.pick, "pick")
	setMethodUI(self.clicked.speed, "speed")

	local charWidth = 36
	local charHeight = 36
	local charInterval = 16
	local fntFile = "fnt/target_amount.fnt"
	local newLabel = LabelBMMonospaceFont:create(charWidth, charHeight, charInterval, fntFile)
	newLabel:setAnchorPoint(ccp(0,1))
	newLabel:setPositionX(self.clicked.speed.number:getPositionX())
	newLabel:setPositionY(self.clicked.speed.number:getPositionY())
	self.clicked.speed.number:removeFromParentAndCleanup(true)
	self.clicked.speed:addChild(newLabel)
	self.clicked.speed.number = newLabel
	self:refresh(nil, "init")
	local position = self:getPosition()
	local wPosition = self:getParent():convertToWorldSpace(ccp(position.x, position.y))
	self.clicked:setPosition(ccp(wPosition.x, wPosition.y))

	-- event listener
	local function onAnimFinish()
		local function onReleaseOutside(evt)
			local function isClickOutside(ui)
				if ui:isVisible() then
					local pos = ui:getPosition()
					local parent = ui:getParent()
					local position = parent:convertToWorldSpace(ccp(pos.x, pos.y))
					local distance = ccpDistance(position, evt.globalPosition)
					if distance < 75 then return false end
				end
				return true
			end
			local inside = true
			if self.clicked and self.clicked.regen and not self.clicked.regen.isDisposed then
				inside = inside and not isClickOutside(self.clicked.regen)
			end
			if self.clicked and self.clicked.regen and not self.clicked.regen.isDisposed then
				inside = inside and not isClickOutside(self.clicked.regen)
			end
			if self.clicked and self.clicked.regen and not self.clicked.regen.isDisposed then
				inside = inside and not isClickOutside(self.clicked.regen)
			end
			if not inside then self:_clickedOutside() end
		end

		if not self.clicked or self.clicked.isDisposed then return end
		if not hasGuide then self.clicked:setTouchEnabledWithMoveInOut(true) end
		self.clicked:addEventListener(DisplayEvents.kTouchEnd, onReleaseOutside)
		if self.clicked.isDisposed then return end
		local function onRegenerate()
			if RequireNetworkAlert:popout() then self:_regenerate() end
		end
		self.clicked.regen:setTouchEnabled(true)
		self.clicked.regen:addEventListener(DisplayEvents.kTouchTap, onRegenerate)
		local function onPick()
			if RequireNetworkAlert:popout() then self:_pick() end
		end
		self.clicked.pick:setTouchEnabled(true)
		self.clicked.pick:addEventListener(DisplayEvents.kTouchTap, onPick)
		local function onSpeed()
			if RequireNetworkAlert:popout() then self:_speed() end
		end
		self.clicked.speed:setTouchEnabled(true)
		self.clicked.speed:addEventListener(DisplayEvents.kTouchTap, onSpeed)
	end
	self:_clickedEnterAnim(self.clicked, animDuration or 0.3, onAnimFinish)

	return self.clicked
end

function Fruit:removeClickedFruit(animDuration)
	if not self.clicked or self.clicked.isDisposed then return end
	local function onAnimFinish()
		if self.clicked.isDisposed then return end
		self.clicked:removeAllEventListeners()
		self.clicked:removeFromParentAndCleanup(true)
	end
	self:_clickedExitAnim(self.clicked, animDuration, onAnimFinish)
end

function Fruit:_clickedEnterAnim(clicked, animDuration, callback)
	if clicked.methodRing and not clicked.methodRing.isDisposed then
		local scale = clicked.methodRing:getScale()
		clicked.methodRing:setScale(0)
		clicked.methodRing:runAction(CCScaleTo:create(animDuration, scale))
	end
	if clicked.regen and not clicked.regen.isDisposed then
		local pos1 = clicked.regen:getPosition()
		pos1 = {x = pos1.x, y = pos1.y}
		clicked.regen:setPosition(ccp(0, 0))
		clicked.regen:setScale(0)
		clicked.regen:runAction(CCSpawn:createWithTwoActions(CCScaleTo:create(animDuration, 1), CCMoveTo:create(animDuration, ccp(pos1.x, pos1.y))))
	end
	local pos2 = clicked.pick:getPosition()
	pos2 = {x = pos2.x, y = pos2.y}
	clicked.pick:setPosition(ccp(0, 0))
	clicked.pick:setScale(0)
	clicked.pick:runAction(CCSpawn:createWithTwoActions(CCScaleTo:create(animDuration, 1), CCMoveTo:create(animDuration, ccp(pos2.x, pos2.y))))
	local pos3 = clicked.speed:getPosition()
	pos3 = {x = pos3.x, y = pos3.y}
	clicked.speed:setPosition(ccp(0, 0))
	clicked.speed:setScale(0)
	clicked.speed:runAction(CCSpawn:createWithTwoActions(CCScaleTo:create(animDuration, 1), CCMoveTo:create(animDuration, ccp(pos3.x, pos3.y))))
	setTimeOut(callback, animDuration)
end

function Fruit:_clickedExitAnim(clicked, animDuration, callback)
	clicked.methodRing:runAction(CCScaleTo:create(animDuration, 0))
	clicked.regen:runAction(CCSpawn:createWithTwoActions(CCScaleTo:create(animDuration, 0), CCMoveTo:create(animDuration, ccp(0, 0))))
	clicked.pick:runAction(CCSpawn:createWithTwoActions(CCScaleTo:create(animDuration, 0), CCMoveTo:create(animDuration, ccp(0, 0))))
	clicked.speed:runAction(CCSpawn:createWithTwoActions(CCScaleTo:create(animDuration, 0), CCMoveTo:create(animDuration, ccp(0, 0))))
	setTimeOut(callback, animDuration)
end

function Fruit:setClickedFruitReleaseEnabled(enabled)
	if self.clicked and not self.clicked.isDisposed then
		self.clicked:setTouchEnabledWithMoveInOut(enabled)
	end
end

function Fruit:getClickedFruit()
	return self.clicked
end

function Fruit:_clickedOutside()
	self:dispatchEvent(Event.new(kFruitEvents.kSelectedCancel, nil, self))
end

function Fruit:_regenerate()
	local function onSuccess(data)
		if self.isDisposed then return end
		Cookie:getInstance():write(CookieKey.kHasFruitLevel6ShowOff .. self.id,false)
		
		self:refresh(data.fruit, "regenerate")
		self:dispatchEvent(Event.new(kFruitEvents.kRegenerate, nil, self))
		if self.clicked and not self.clicked.isDisposed then
			self.clicked.regen:setTouchEnabled(true)
			self:dispatchEvent(Event.new(kFruitEvents.kSelectedCancel, nil, self))
		end
	end
	local function onFail(err)
		if self.isDisposed then return end
		if self.clicked and not self.clicked.isDisposed then self.clicked.regen:setTouchEnabled(true) end
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err)))
	end
	if self.clicked and self.clicked.regen and not self.clicked.regen.isDisposed then
		self.clicked.regen:setTouchEnabled(false)
	end
	self.fruitLogic:regenerate(self.id, onSuccess, onFail)
end

function Fruit:_pick()
	local beforePickEnergy = 0
	local afterPickEnergy = 0

	local fType = FruitModel:sharedInstance():getType(self.id)
	
	local function onSuccess(data)
		if self.isDisposed then return end
		local scene = HomeScene:sharedInstance()
		if scene and not scene.isDisposed then scene:checkDataChange() end
		local anim
		if fType == kFruitType.kCoin then
			if data.reward.num and data.reward.num > 0 then 
				anim = FlyTopCoinAni:create(data.reward.num)
			end
		elseif fType == kFruitType.kEnergy then
			afterPickEnergy = UserManager:getInstance().user:getEnergy()
			anim = FlyTopEnergyAni:create(afterPickEnergy - beforePickEnergy)
		elseif fType == kFruitType.kGold then
			if data.reward.num and data.reward.num > 0 then 
				anim = FlyTopGoldAni:create(data.reward.num)
			end
		end
		if anim then 
			local position = self:getParent():convertToWorldSpace(self:getPosition())
			anim:setWorldPosition(position)
			anim:play()
		end
		Cookie:getInstance():write(CookieKey.kHasFruitLevel6ShowOff .. self.id,false)

		self:refresh(data.fruit, "pick")
		self:dispatchEvent(Event.new(kFruitEvents.kPick, nil, self))
		if self.clicked and not self.clicked.isDisposed then
			self.clicked.pick:setTouchEnabled(true)
			self:dispatchEvent(Event.new(kFruitEvents.kSelectedCancel, nil, self))
		end
	end
	local function onFail(err)
		if self.isDisposed then return end
		if self.clicked and not self.clicked.isDisposed then self.clicked.pick:setTouchEnabled(true) end
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err)))
	end
	local function pick()
		if self.isDisposed then return end
		if self.clicked and not self.clicked.isDisposed then self.clicked.pick:setTouchEnabled(false) end
		local scene = Director:sharedDirector():getRunningScene()

		beforePickEnergy = UserManager:getInstance().user:getEnergy()
		self.fruitLogic:pick(self.id, onSuccess, onFail)
	end


	if FruitModel:sharedInstance():getType(self.id) == kFruitType.kEnergy then
		local isFullEnergy,addEnergy = FruitModel:sharedInstance():askEnergyPick(self.id)	
		local _,_,_,rewardEnergy = FruitModel:sharedInstance():getReward(self.id)
		if isFullEnergy or addEnergy < (tonumber(rewardEnergy) or 0) then
			local panel = PickConfirmPanel:create(isFullEnergy,addEnergy,pick)
			panel:popout()
		else
			pick()
		end
	else
		pick()
	end
end

function Fruit:_speed()
	local function onPropNotEnough()
		local count = FruitModel:sharedInstance():getAccelerateNeededAdditionCount(self.id)
		local function gotoBuySpeed()
			local panel = PayPanelWindMill:create(29, nil, nil, tonumber(count))
			if panel then
				panel:setFeatureAndSource(DcFeatureType.kFruitTree, DcSourceType.kFruitSpeedUp)
				panel:popout() 
			end
		end

		local panel = BuyConfirmPanel:create(count,gotoBuySpeed)
		panel:popout()
	end
	local function onSuccess(data)
		if self.isDisposed then return end
		
		self:dispatchEvent(Event.new(kFruitEvents.kUpdate, nil, self))
		if self.clicked and not self.clicked.isDisposed then
			self.clicked.speed:setTouchEnabled(true)
			self:dispatchEvent(Event.new(kFruitEvents.kSelectedCancel, nil, self))
		end
	end
	local function onFail(err)
		if self.isDisposed then return end
		if self.clicked and not self.clicked.isDisposed then self.clicked.speed:setTouchEnabled(true) end
		if err == 730311 then -- prop not enough
			onPropNotEnough()
		else
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err)))
		end
	end
	local scene = Director:sharedDirector():getRunningScene()
	self.clicked.speed:setTouchEnabled(false)
	self.fruitLogic:instantUpgrade(self.id, onSuccess, onFail)
end

function Fruit:_playGrowAnim(fruitSprite, clickedFruitSprite)
	if self.playingAnim or not fruitSprite then return end
	self.playingAnim = true
	local before = self.norm.fruit
	local after = fruitSprite
	local beforeSize, afterSize = before:getGroupBounds().size, after:getGroupBounds().size
	local function playOldAnim(fruit)
		local sprite = fruit:getChildByName("sprite")
		sprite:setOpacity(255)
		local arr = CCArray:create()
		arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, -18)))
	    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
	    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, 15)))
	    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
	    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, -12)))
	    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
	    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, 9)))
	    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
	    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, -4)))
	    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
	    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, 2)))
	    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
		local scale = fruit:getScale() * (afterSize.width / beforeSize.width)
		arr:addObject(CCEaseBackOut:create(CCScaleTo:create(0.3, scale)))
		fruit:runAction(CCSequence:create(arr))
		sprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1.2), CCFadeOut:create(0.1)))
	end
	local function playNewAnim(fruit, isCallFunc)
		local sprite = fruit:getChildByName("sprite")
		sprite:setOpacity(0)
		local scale = fruit:getScale()
		fruit:setScale(scale * (afterSize.width / beforeSize.width))
		local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(1.2))
		arr:addObject(CCEaseBackOut:create(CCScaleTo:create(0.3, scale)))
		local function onFinish() self:_stopGrowAnim() end
		if isCallFunc then arr:addObject(CCCallFunc:create(onFinish)) end
		fruit:runAction(CCSequence:create(arr))
		sprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1.2), CCFadeIn:create(0.1)))
	end
	if self.norm and self.norm.fruit and not self.norm.fruit.isDisposed then
		playOldAnim(self.norm.fruit)
		playNewAnim(fruitSprite, true)
		self.norm.dstFruit = fruitSprite
	end
	if self.clicked and self.clicked.fruit and not self.clicked.fruit.isDisposed and clickedFruitSprite then
		if self.clicked.fruit and not self.clicked.fruit.isDisposed then
			playOldAnim(self.clicked.fruit)
			playNewAnim(clickedFruitSprite)
			self.clicked.dstFruit = clickedFruitSprite
		end
	end
end

function Fruit:_stopGrowAnim()
	if not self.playingAnim then return end
	local function setEndState(fruit)
		local sprite = fruit:getChildByName("sprite")
		fruit:stopAllActions()
		sprite:setOpacity(255)
		fruit:setRotation(0)
		fruit:setScale(1)
	end
	if self.norm and not self.norm.isDisposed then
		if self.norm.fruit and self.norm.dstFruit and not self.norm.fruit.isDisposed and not self.norm.dstFruit.isDisposed then
			self.norm.fruit:stopAllActions()
			setEndState(self.norm.dstFruit)
			self.norm.fruit:removeFromParentAndCleanup(true)
			self.norm.fruit = self.norm.dstFruit
		end
	end
	if self.clicked and not self.clicked.isDisposed then
		if self.clicked.fruit and self.clicked.dstFruit and not self.clicked.fruit.isDisposed and not self.clicked.dstFruit.isDisposed then
			self.clicked.fruit:stopAllActions()
			setEndState(self.clicked.dstFruit)
			self.clicked.fruit:removeFromParentAndCleanup(true)
			self.clicked.fruit = self.clicked.dstFruit
		end
	end
	self.playingAnim = false
end

FruitLogic = class()
function FruitLogic:create()
	local logic = FruitLogic.new()
	return logic
end

function FruitLogic:pick(id, successCallback, failCallback)
	local fruitType = FruitModel:getType(id)
	local fruitLevel = FruitModel:getLevel(id)
	local treeLevel = FruitModel:getTreeLevel()
	local function onSuccess(evt)
		if evt.data and evt.data.reward then
			if id == -1 then
				DcUtil:adsIOSReward({sub_category = "advfruit_reward",type_id = fruitType,level_id = fruitLevel})
			end

			FruitModel:sharedInstance():incPickCount(id==-1)
			local reward = evt.data.reward
			if type(reward) == "table" then
				UserManager:getInstance():addReward(reward)
				GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kFruitTree, reward.itemId, reward.num, DcSourceType.kFruitTreeReward)
			end
			Notify:dispatch("AchiEventDataUpdate",AchiDataType.kGetFruitAddCount, 1)
			_G.questEvtDp:dp(_G.QuestEvent.new(_G.QuestEventType.kAfterPickFruit))
		end
		DcUtil:fruitPick(fruitType, fruitLevel, treeLevel)
		
		FruitModel:sharedInstance():setData(id, evt.data and evt.data.fruit)

		if successCallback then successCallback(evt.data) end
		FruitTreeSceneLogic:updateFruit(evt.data and evt.data.fruit,id)
	end
	local function onFail(evt)
		if failCallback then failCallback(evt.data) end
	end
	if FruitModel:sharedInstance():canPick(id) then
		local http = PickFruitHttp.new(true)
		http:addEventListener(Events.kComplete, onSuccess)
		http:addEventListener(Events.kError, onFail)
		http:syncLoad(id, 0,0)
	end
end

function FruitLogic:regenerate(id, successCallback, failCallback)
    local regenCount = InciteManager:getCount(EntranceType.kTree,true)
    local isFastRegen = regenCount>0

	local fruitType = FruitModel:getType(id)
	local fruitLevel = FruitModel:getLevel(id)
	local treeLevel = FruitModel:getTreeLevel()
	local function onSuccess(evt)
		if id == -1 then
			if isFastRegen then
				local p = {sub_category = "advfruit_reborn_atonce"}
				DcUtil:adsIOSReward(p)
				
	            InciteManager:subCount( EntranceType.kTree ,true)
	        else
				local p = {sub_category = "advfruit_reborn_normal"}
				DcUtil:adsIOSReward(p)
	        end
		end
		DcUtil:fruitRegenerate(fruitType, fruitLevel, treeLevel)
		if successCallback then successCallback(evt.data) end
		FruitTreeSceneLogic:updateFruit(evt.data and evt.data.fruit,id)
	end
	local function onFail(evt)
		if failCallback then failCallback(evt.data) end
	end
	local http = PickFruitHttp.new(true)
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFail)
	-- print("VideoFruit:checkRegenerateVersion(id)000",id,VideoFruit:checkRegenerateVersion(id))
	http:load(id, 1,VideoFruit:checkRegenerateVersion(id))
end

function FruitLogic:instantUpgrade(id, successCallback, failCallback)
	local fruitType = FruitModel:getType(id)
	local fruitLevel = FruitModel:getLevel(id)
	local treeLevel = FruitModel:getTreeLevel()
	local enough, num = FruitModel:sharedInstance():getIsEnoughSpeedPropNumber(id)
	local function onSuccess()
		DcUtil:fruitSpeed(num, fruitType, fruitLevel, treeLevel)
		if successCallback then successCallback() end
	end
	local function onFail(evt)
		if failCallback then failCallback(evt.data) end
	end
	if enough == nil then onFail({data = 0}) end
	if enough then
		local tab = {}
		for i = 1, num do table.insert(tab, 10029) end
		local logic = UsePropsLogic:create(UsePropsType.NORMAL, 0, id, tab)
		logic:setFeatureAndSource(DcFeatureType.kFruitTree, DcSourceType.kFruitSpeedUp)
		logic:setSuccessCallback(onSuccess)
		logic:setFailedCallback(onFail)
		logic:start(true)
	else
		onFail({data = 730311})
	end
end

FruitModel = {}
local instance = nil
function FruitModel:sharedInstance()
	if not instance then
		instance = FruitModel
		instance:_init()
	end
	return instance
end

function FruitModel:_init()
	local meta = MetaManager:getInstance().fruits
	self.rewards = {}
	for k, v in ipairs(meta) do
		local reward, energy, coin, gold = v.reward
		for k, v in ipairs(reward) do
			if v.itemId == 2 then coin = v.num end
			if v.itemId == 4 then energy = v.num end
			if v.itemId == 14 then gold = v.num end
		end
		self.rewards[v.level] = {energy = energy, coin = coin, gold = gold, upgrade = v.upgrade}
	end
	meta = MetaManager:getInstance()
	self.growCycle = meta:getFruitGrowCycle()
	self.crowCount = meta:getCrowCountNum()
	self.data = {}
	local meta = MetaManager:getInstance().fruits_upgrade
	self.upgrade = {}
	for k, v in ipairs(meta) do self.upgrade[v.level] = v end
end

function FruitModel:dispose()
	self.data = nil
	self.rewards = nil
	instance = nil
end

function FruitModel:setData(id, data)
	self.data = self.data or {}
	self.data[id] = data
	if _G.isLocalDevelopMode then printx(100, "setData data = ",table.tostring(data)) end
end

function FruitModel:getFruitName(id)
	if id==-1 and (not self.data[id] or self.data[id].level==0) then
		return "fruit/fruit_ad_0"
	end
	if not self.data[id] then return nil end
	local data = self.data[id]
	return self:getFruitNameByLevelAndType(data.level,data.type,id)
end -- return nil by default

function FruitModel:getFruitNameByLevelAndType(level,fType,id)
	local strTypeMap = {}
	strTypeMap[kFruitType.kCoin] = "s"
	strTypeMap[kFruitType.kEnergy] = "e"
	strTypeMap[kFruitType.kGold] = "g"

	local strType = strTypeMap[fType] or ""
	if id==-1 then
		return "fruit/fruit_ad_"..strType .. "_" .. tostring(level)
	end
	if level==0 then
		return "fruit/fruit0"
	end
	return "fruit/fruit"..tostring(level)..strType
end

function FruitModel:getType(id)
	if not self.data[id] then return nil end
	local data = self.data[id]
	if data.level == 0 then return nil
	else return data.type end
end

function FruitModel:getLevel(id)
	if not self.data[id] then return 5 end
	local data = self.data[id]
	return tonumber(data.level)
end

function FruitModel:getFruitLevel(id)
	if not self.data[id] then return 0 end
	return self.data[id].level
end

function FruitModel:getGrowCount(id)
	if not self.data[id] then return 5 end
	local data = self.data[id]
	return tonumber(data.growCount)
end

function FruitModel:getLevelString(id)
	if not self.data[id] then return "" end
	local data = self.data[id]
	return Localization:getInstance():getText("fruit.tree.scene.level", {level = data.level})
end

function FruitModel:getProgress(id) -- return value, max
	if not self.data[id] then return nil, nil end
	if self.data[id].growCount >= self.crowCount then return nil, nil end
	local data = self.data[id]
	local timeStamp = data.updateTime
	local time = Localhost:time()
	return time - timeStamp, self.growCycle
end

function FruitModel:getMethodVisibility(id)
	if not self.data[id] then return false, false, false end
	local data = self.data[id]
	local regen, pick, speed = true, self:canPick(id), true
	if data.level <= 0 then regen, pick = false, false end
	--原生逻辑 果树等级5级 或者加速次数 大于等于5了 那么不能加速了
	if data.level >= 5 or data.growCount >= self.crowCount then speed = false end
	return regen, pick, speed

end

function FruitModel:getAccelerateNeededCount(id)
	local meta = MetaManager:getInstance():getPropMeta(10029)
	if not meta then return 0 end
	if not self.data[id] then return 0 end
	local data = self.data[id]
	local timeStamp = data.updateTime
	local time = Localhost:time()
	local remain = math.floor(self.growCycle - time + timeStamp)
	local neededCount = math.ceil(remain / (meta.value * 60000))
	if neededCount >= 3 then neededCount = 3 end
	return neededCount
end

function FruitModel:getAccelerateNeededAdditionCount(id)
	local meta = MetaManager:getInstance():getPropMeta(10029)
	if not meta then return 0 end
	if not self.data[id] then return 0 end
	local data = self.data[id]
	local timeStamp = data.updateTime
	local time = Localhost:time()
	local remain = math.floor(self.growCycle - time + timeStamp)
	local neededCount = math.ceil(remain / (meta.value * 60000))
	if neededCount >= 3 then neededCount = 3 end
	local hasCount = UserManager:getInstance():getUserPropNumber(10029)
	return neededCount - hasCount
end

function FruitModel:getReward(id) -- return isShowCoin, isShowEnergy, isShowGold, rewardNum
	if not self.data[id] then return false, false, false, "" end
	local data = self.data[id]
	if data.level == 0 then return false, false, false, "" end
	local buff = 1
	if self.upgrade and self.upgrade[self:getTreeLevel()] and self.upgrade[self:getTreeLevel()].plus then
		buff = (self.upgrade[self:getTreeLevel()].plus + 100) / 100
	end
	if data.type == kFruitType.kCoin then return true, false, false, tostring(self.rewards[data.level].coin * buff)
	elseif data.type == kFruitType.kEnergy then return false, true, false, tostring(self.rewards[data.level].energy)
	elseif data.type == kFruitType.kGold then return false, false, true, tostring(self.rewards[data.level].gold)
	else return false, false, false, "" end
end

function FruitModel:getUpdateTimerString(id)
	if not self.data[id] then return "" end
	local data = self.data[id]
	if data.growCount >= self.crowCount then return "" end
	local elapse = data.updateTime + self.growCycle - Localhost:time()
	local timestr = ""
	local minute = math.floor(math.floor(elapse / 1000) / 60)
	if elapse > 60000 then timestr = timestr..tostring(minute)..':' end
	timestr = timestr..tostring(math.floor((elapse - minute * 60000) / 1000))
	return timestr
end

function FruitModel:getNeedUpdate(id)
	if not self.data[id] then return false end
	local data = self.data[id]
	if data.growCount >= self.crowCount then return false end
	if data.updateTime + self.growCycle - Localhost:time() <= 0 then
		return true
	end
	return false
end

function FruitModel:incPickCount(skipPickCount)
	local picked = UserManager:getInstance():getDailyData().pickFruitCount
	local level = UserManager:getInstance():getUserExtendRef():getFruitTreeLevel()
	local meta = MetaManager:getInstance().fruits_upgrade
	local limit
	for k, v in ipairs(meta) do
		if v.level == level then
			limit = v.pickCount
			break
		end
	end
	if not limit then return end
	limit = limit + Achievement:getRightsExtra( "FruitGetCount" )
	if picked >= limit then UserManager:getInstance():getDailyData().pickFruitCount = limit return end

	if not skipPickCount then
		UserManager:getInstance():getDailyData().pickFruitCount = picked + 1
	end
end

function FruitModel:decPickCount()
	local picked = UserManager:getInstance():getDailyData().pickFruitCount
	if picked <= 0 then picked = 0 return end
	UserManager:getInstance():getDailyData().pickFruitCount = picked - 1
end

function FruitModel:canPick(id)
	if id==-1 then
		return true
	end
	local picked = UserManager:getInstance():getDailyData().pickFruitCount
	local level = UserManager:getInstance():getUserExtendRef():getFruitTreeLevel()
	local meta = MetaManager:getInstance().fruits_upgrade
	local limit
	for k, v in ipairs(meta) do
		if v.level == level then
			limit = v.pickCount
			break
		end
	end
	limit = limit + Achievement:getRightsExtra( "FruitGetCount" )
	if not limit then return false end
	if picked >= limit then UserManager:getInstance():getDailyData().pickFruitCount = limit return false end
	return true
end

function FruitModel:getIsEnoughSpeedPropNumber(id)
	if not self.data[id] then return nil end
	local data = self.data[id]
	if data.growCount >= self.crowCount then return nil end
	local elapse = data.updateTime + self.growCycle - Localhost:time()
	if elapse > self.growCycle then elapse = self.growCycle end
	local meta = MetaManager:getInstance():getPropMeta(10029)
	if not meta then return nil end
	local minute = meta.value
	local need = math.ceil(elapse / (minute * 60000))
	local have = UserManager:getInstance():getUserPropNumber(10029)
	if need > have then return false, need end
	return true, need
end

function FruitModel:askEnergyPick(id)
	if not self.data[id] then return false,0 end
	local data = self.data[id]
	if data.level <= 0 or data.type ~= kFruitType.kEnergy then return false,0 end
	
	if UserEnergyRecoverManager:sharedInstance():isEnergyFull() then
		return true,0
	else
		local energy = self.rewards[data.level].energy
		local maxEnergy = UserEnergyRecoverManager:sharedInstance():getMaxEnergy()
		local curEnergy = UserManager:getInstance().user:getEnergy()

		local addEnergy = math.min(energy,maxEnergy - curEnergy)

		return false,addEnergy
	end
end

function FruitModel:getTreeLevel()
	local extend = UserManager:getInstance():getUserExtendRef()
	if extend then return extend:getFruitTreeLevel()
	else return 1 end
end

function FruitModel:getFruitPickCount()
	local level = self:getTreeLevel()
	local dailyData = UserManager:getInstance():getDailyData()
	if not self.upgrade[level] or not self.upgrade[level].pickCount or not dailyData or not dailyData.pickFruitCount then return 0 end
	return self.upgrade[level].pickCount - dailyData.pickFruitCount + Achievement:getRightsExtra( "FruitGetCount" )
end

function FruitModel:getRegenShowAnim(id)
	if id == -1 then return false end
	if not self.data[id] then return false end
	local data = self.data[id]
	return data.growCount >= 3 and data.level == 1
end

function FruitModel:needStarBlink(id)
	if not self.data[id] then return false end
	local data = self.data[id]
	return data.growCount == 5
end