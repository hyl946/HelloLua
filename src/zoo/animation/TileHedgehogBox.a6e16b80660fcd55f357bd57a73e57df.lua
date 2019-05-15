TileHedgehogBox = class(CocosObject)
local kCharacterAnimationTime = 1/30

function TileHedgehogBox:create( ... )
	-- body
	local node = TileHedgehogBox.new(CCNode:create())
	node:init()
	node:setScale(0.9)
	return node
end

function TileHedgehogBox:init( ... )
	-- body
	FrameLoader:loadArmature("skeleton/hedgehog_V3_animation")

	local box = ArmatureNode:create("hedgehog_V3/box")
	box:playByIndex(0)
	--[[
	local sp = Sprite:createWithSpriteFrameName("hedgehog_box_0000")
	local frames = SpriteUtil:buildFrames("hedgehog_box_%04d", 0, 119)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	sp:play(animate)
	]]
	-- sp:setPositionX(-2)
	self.sp = box
	self:addChild(box)
end

function TileHedgehogBox:playOpenAnimation_Back( callback )
	-- body
	--[[
	local sp = self.sp
	local function animateCallback( ... )
		-- body
		sp:runAction(CCFadeOut:create(1))	
		if callback then callback() end
	end
	sp:stopAllActions()
	local frames = SpriteUtil:buildFrames("hedgehog_box_%04d", 0, 12)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	sp:play(animate, 0, 1, animateCallback)

	]]
	setTimeOut( function ()
		--self.sp:runAction(CCFadeOut:create(1))	
		if callback then callback() end
	end , 0.5 )

	GamePlayMusicPlayer:playEffect(GameMusicType.kHedgehogBoxOpen)
end

function TileHedgehogBox:playOpenAnimation(targetPos, callback )
	-- body
	local sp = TileHedgehogBoxOpenAnimation:create(targetPos, callback)
	local scene = Director.sharedDirector():getRunningScene()
	scene:addChild(sp)

	local origin = Director.sharedDirector():getVisibleOrigin()
	local size = Director.sharedDirector():getVisibleSize()
	sp:setPosition(ccp(origin.x + size.width/2, origin.y + size.height/2))

	local function delayPlayEffect( ... )
		-- body
		GamePlayMusicPlayer:playEffect(GameMusicType.kHedgehogBoxOpen)
	end
	-- setTimeOut( delayPlayEffect, 0.15)
	delayPlayEffect()
end

TileHedgehogBoxOpenAnimation = class(CocosObject)
function TileHedgehogBoxOpenAnimation:create(targetPos, callback )
	FrameLoader:loadArmature( "skeleton/childrensday_open_box", "childrensday_open_box", "childrensday_open_box" )
	-- body
	local node = TileHedgehogBoxOpenAnimation.new(CCNode:create())
	node:init(targetPos, callback)
	return node
end

function TileHedgehogBoxOpenAnimation:init(targetPos, callback)
	self.callback = callback
	self:initBg()
	self:initAnimation(targetPos)
end

function TileHedgehogBoxOpenAnimation:initBg( ... )
	-- body
	local size = Director.sharedDirector():getVisibleSize()
	local color_layer = LayerColor:create()
	color_layer:changeWidthAndHeight(size.width + 40, size.height + 40)
	color_layer:setPosition(ccp(-(size.width + 40)/2, -(size.height + 40)/2))
	color_layer:setOpacity(210)
	self:addChild(color_layer)
end

function TileHedgehogBoxOpenAnimation:createFlyToTargetPanelAnim(targetGlobalPos, callback)
	local config = {
		{posX=236.95, posY=35, scale=0.678, rotate=8.4},
		{posX=179.5, posY=53.5, scale=0.823, rotate=138.5},
		{posX=72.3, posY=38.7, scale=0.823, rotate=68.5},
		{posX=156, posY=89, scale=0.84, rotate=-48.9},
		{posX=501.4, posY=80.35, scale=0.728, rotate=-50.7},
		{posX=504.4, posY=63.25, scale=0.667, rotate=117.8},
		{posX=608, posY=38, scale=0.84, rotate=22},
		{posX=87.6, posY=52, scale=1.05, rotate=0},
		{posX=354.7, posY=56.8, scale=0.912, rotate=0},
		{posX=288, posY=50.5, scale=1, rotate=18.8},
	}
	local cl = Layer:create()
	self:addChild(cl)

	targetGlobalPos = targetGlobalPos or ccp(0, 0)
	local localTargetPos = cl:convertToNodeSpace(targetGlobalPos)
	localTargetPos = ccp(localTargetPos.x, localTargetPos.y + 50)

	local total = 0
	local function onAnimationFinish()
		total = total - 1
		if total <= 0 then
			self:removeFromParentAndCleanup(true)
			if type(callback) == "function" then
				callback()
			end
		end
	end
	local size = Director.sharedDirector():getVisibleSize()

	for i = 1, 10 do
		total = total + 1
		local sprite = Sprite:createWithSpriteFrameName("hedgehog_target_a")
		sprite:setAnchorPoint(ccp(0, 1))
		sprite:ignoreAnchorPointForPosition(false)
		sprite:setScale(config[i].scale)
		sprite:setPositionXY(config[i].posX + 23 - 360, -config[i].posY + 362 - 640)
		sprite:setRotation(config[i].rotate)
		cl:addChild(sprite)

		sprite:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))

		local actArr = CCArray:create()
		actArr:addObject(CCDelayTime:create(math.random(1, 8) / 10))
		actArr:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(0.2, localTargetPos), CCScaleTo:create(0.2, 0.6)))
		local function onCompleted()
			sprite:removeFromParentAndCleanup(true)
			onAnimationFinish()
		end
		actArr:addObject(CCCallFunc:create(onCompleted))
		sprite:runAction(CCSequence:create(actArr))
	end
end

function TileHedgehogBoxOpenAnimation:initAnimation(targetPos)
	local node = ArmatureNode:create( "Trojan" )
	node:playByIndex(0, 1)
	node:update(0.01)
	-- node:stop()
	self:addChild(node)

	for i = 1, 5 do
		local slot = node.refCocosObj:getCCSlot(string.format("图层 %d", i))
		if slot and slot:getCCChildArmature() then
			slot:getCCChildArmature():advanceTime(0.01)
		end
	end

	local function onAllAnimationCompleted()
		if type(self.callback) == "function" then self.callback() end
	end

	local function onCompleted()
		node:removeFromParentAndCleanup(true)
		self:createFlyToTargetPanelAnim(targetPos, onAllAnimationCompleted)
	end
	node:addEventListener(ArmatureEvents.COMPLETE, onCompleted)
	node:setPosition(ccp(-140, 0))
end


TileChristmasMeeting = class(CocosObject)
local animationScale = 1
function TileChristmasMeeting:create( callback )
	-- body
	local node = TileChristmasMeeting.new(CCNode:create())
	node:init(callback)
	return node
end

function TileChristmasMeeting:init( callback )
	-- body
	FrameLoader:loadArmature( "skeleton/christmas_animation", 
		"christmas_animation", "christmas_animation" )

	self.callback = callback
	self:initBg()
	
	self:initDc()
end

function TileChristmasMeeting:initBg( ... )
	-- body
	local size = Director.sharedDirector():getVisibleSize()
	local color_layer = LayerColor:create()
	color_layer:changeWidthAndHeight(size.width + 40, size.height + 40)
	color_layer:setPosition(ccp(-(size.width + 40)/2, -(size.height + 40)/2))
	color_layer:setOpacity(210)
	self:addChild(color_layer)
end


---dc= 邓超
function TileChristmasMeeting:initDc( ... )
	-- body
	local function downFunc( evt )
		-- body
		self:initSlbg()
		self:viberate()
		if self.dc then
			self.dc:removeAllEventListeners()
			self.dc:playByIndex(1, 1)
		end
	end
	local dc = ArmatureNode:create("christmas_dc")
	local size = dc:getGroupBounds().size
	dc:setAnimationScale(animationScale)
	dc:playByIndex(0, 1)
	dc:update(0.001)
	dc:stop()

	dc:playByIndex(0,1)
	self:addChild(dc)
	self = dc
	dc:setPositionX(-size.width/5)
	dc:addEventListener(ArmatureEvents.COMPLETE, downFunc)
end

function TileChristmasMeeting:viberate( delayTime )
	-- body
	self.originPos = ccp(self:getPositionX(), self:getPositionY())
	self.viberateDelay = delayTime or 0
	self.viberateCounter = GamePlayConfig_Viberate_Count
	local function viberateUpdate( ... )
		-- body
		self:viberateUpdate()
	end
	self.viberateScheduler = CCDirector:sharedDirector():getScheduler():
	scheduleScriptFunc(viberateUpdate, 0, false)
end

function TileChristmasMeeting:viberateUpdate()
	if self.viberateDelay == 0 and self.viberateCounter == -1 then 
		Director:getScheduler():unscheduleScriptEntry(self.viberateScheduler)
		self.viberateScheduler = nil
		return 
	end
	
	if self.viberateDelay == 0 then
		if self.viberateCounter == 0 then
			self:setPosition(self.originPos)
			self.viberateCounter = -1
			return
		else
			self.viberateCounter = self.viberateCounter - 1
			local posY = GamePlayConfig_Viberate_InitY * CCDirector:sharedDirector():getWinSize().height / (GamePlayConfig_Viberate_Count - self.viberateCounter)
			local bit = require("bit")
			if bit.band(self.viberateCounter, 0x1) == 0 then posY = -posY end
			self:setPosition(ccp(self.originPos.x, posY + self.originPos.y))
			self.viberateDelay = GamePlayConfig_Viberate_Delay
		end
	else
		self.viberateDelay = self.viberateDelay - 1
	end
end

function TileChristmasMeeting:initSlbg( ... )
	-- body
	local slbg = Sprite:createWithSpriteFrameName("christmas_other_0000")
	local _size = slbg:getGroupBounds().size
	local clipping = ClippingNode:create({size= _size}, slbg)
	self:addChild(clipping)

	clipping:setPosition(ccp(0, -3*_size.height/2))
	slbg:setPosition(ccp(_size.width/2, 3*_size.height/2))

	local time = 0.5
	clipping:runAction(CCMoveBy:create(time, ccp(0, _size.height)))

	local function finish_callback( ... )
		-- body
		if clipping then clipping:removeFromParentAndCleanup(true) end
		self:initSl()
	end
	local arr = CCArray:create()
	arr:addObject(CCMoveBy:create(time, ccp(0, -_size.height)))
	arr:addObject(CCFadeOut:create(time/5))
	arr:addObject(CCCallFunc:create(finish_callback))
	slbg:runAction(CCSequence:create(arr))

	local function createFlower( pos )
		-- body
		local flower = ArmatureNode:create("christmas_flower")
		local function flower_callback( ... )
			-- body
			if flower then flower:removeFromParentAndCleanup(true) end
		end 
		flower:setPosition(pos)
		flower:playByIndex(0, 1)
		flower:update(0.001)
		flower:stop()
		flower:playByIndex(0,1)
		flower:setRotation(47)
		flower:setScaleX(1.2)
		flower:setAnimationScale(animationScale)
		flower:addEventListener(ArmatureEvents.COMPLETE, flower_callback)
		self:addChild(flower)
	end

	local pos_o_x, pos_o_y = _size.width/2, -_size.height / 5
	local poslist = {{x = pos_o_x, y = pos_o_y}, 
	{x = pos_o_x + 4, y = pos_o_y + 77 }, 
	{x = pos_o_x - 27, y = pos_o_y + 130}}
	for k = 1, 3 do 
		setTimeOut(function( )
			-- body
			local _pos = poslist[k]
			createFlower(ccp(_pos.x, _pos.y))
		end, (k-1)* 0.3)
	end
	
end
---sl= 孙俪
function TileChristmasMeeting:initSl( ... )
	-- body
	local sl = ArmatureNode:create("christmas_sl")
	local index_dc = self:getChildIndex(self.dc)
	self:addChildAt(sl, index_dc + 1)
	local size = sl:getGroupBounds().size
	sl:setPositionX(size.width/2 - 20)
	sl:setAnimationScale(animationScale)

	sl:playByIndex(0, 1)
	sl:update(0.001)
	sl:stop()

	sl:playByIndex(0, 1)
	self.sl = sl
	local function finish_callback( ... )
		-- body
		self:initLoveHeart()
		self.sl:runAction(CCFadeOut:create(0.2))
		self.dc:runAction(CCFadeOut:create(0.2))
		self.sl:removeAllEventListeners()
		
	end
	sl:addEventListener(ArmatureEvents.COMPLETE, finish_callback)
end

function TileChristmasMeeting:initLoveHeart( ... )
	-- body
	local heart = ArmatureNode:create("christmas_boom")
	heart:setAnimationScale(animationScale)
	heart:playByIndex(0, 1)
	heart:update(0.001)
	heart:stop()
	heart:playByIndex(0, 1)

	local function finish_callback( ... )
		-- body
		heart:removeAllEventListeners()
		if self.callback then 
			self.callback()
		end
		self:removeFromParentAndCleanup(true)
	end
	heart:addEventListener(ArmatureEvents.COMPLETE, finish_callback)
	self:addChild(heart)
	self:viberate(25)
end
