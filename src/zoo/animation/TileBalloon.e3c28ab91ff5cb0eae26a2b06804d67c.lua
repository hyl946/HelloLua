require "hecore.display.Director"
require "hecore.display.ParticleSystem"

kTileBalloonAnimation = { kNormal_s = 1,kNormal_m= 2, kNormal_l = 3, kRunaway = 4, kExplode = 5}
TileBalloon = class(CocosObject)

local kCharacterAnimationTime = 1/30
local kBalloonContentSize = 70

function TileBalloon:toString()
	-- return string.format("TileBalloon [%s]", self.name and self.name or "nil");
end

function TileBalloon:create(color, balloonFrom, constantPlayAlert)
	local node = TileBalloon.new(CCNode:create()) 
	node.color = color
	--绳子
	node.rope = Sprite:createWithSpriteFrameName("balloon_rope_0000.png")
	node.rope:setAnchorPoint(ccp(0, 1))
	node.rope:setPosition(ccp(-3.5, -24))   ----这个坐标，有更好地办法求吗
	node:addChild(node.rope)

	--光效
  	-- node.light = Sprite:createWithSpriteFrameName(node:getStrByColor().."_light.png")
  	node.light = Sprite:createWithSpriteFrameName("light_"..node:getStrByColor()..".png")
  	-- node.light:setPosition(ccp(2, 2))
  	node:addChild(node.light)
  	node.light:setVisible(false)

	--气球
  	-- local balloon = Sprite:createWithSpriteFrameName(node:getStrByColor().."_balloon.png")
  	local balloon = Sprite:createWithSpriteFrameName("balloon_"..node:getStrByColor()..".png")
  	-- balloon:setPosition(ccp(4, 0))
  	node:addChild(balloon)
  	node.balloon = balloon;
  	--数字
  	node.numberShowNode = CocosObject:create();
	node:addChild(node.numberShowNode);


	local frame = SpriteUtil:buildFrames("balloon_rope_%04d.png", 0, 50)
	local animate = SpriteUtil:buildAnimate(frame, kCharacterAnimationTime)
  	node.rope:play(animate)

  	if balloonFrom then
  		if constantPlayAlert then
  			node.constantPlayAlert = true
  		end
  		node.balloonFrom = balloonFrom
  		node:updateShowNumber(balloonFrom)
  	end
  	node.mainSprite = balloon
  
	return node
end

function TileBalloon:getStrByColor( ... )
	-- body
	local value = "";
	local color = self.color
	if color == AnimalTypeConfig.kBlue then value = "0000"
	elseif color == AnimalTypeConfig.kGreen then value = "0001"
	elseif color == AnimalTypeConfig.kOrange then value = "0002"
	elseif color == AnimalTypeConfig.kPurple then value = "0003"
	elseif color == AnimalTypeConfig.kRed then value = "0004"
	elseif color == AnimalTypeConfig.kYellow then value = "0005"
	else
		if _G.isLocalDevelopMode then printx(0, "not find the color, the color is :", self.color) end
	end

	return value
end

function TileBalloon:updateShowNumber( number )
	-- body
	local animation

	if number <= 0 then return end

	if self.constantPlayAlert then
		animation = kTileBalloonAnimation.kNormal_l
	else
		if number > 7 then
			animation = kTileBalloonAnimation.kNormal_s
		elseif number > 3 then
			animation = kTileBalloonAnimation.kNormal_m
		else
			animation = kTileBalloonAnimation.kNormal_l
		end
	end

	self:play(animation)

	number = 15 - number;
	if not self.numberSprite then
		self.numberSprite = Sprite:createWithSpriteFrameName("balloon_number_0000.png")
		self.numberShowNode:addChild(self.numberSprite)
	end
	
	local str = string.format("%04d", number);
	self.numberSprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("balloon_number_" ..str..".png"))
end

function TileBalloon:play(animation)
	if animation == kTileBalloonAnimation.kNormal_s then self:playNormalSmallAnimation()
	elseif animation == kTileBalloonAnimation.kNormal_m then self:playNormalMiddleAnimation()
	elseif animation == kTileBalloonAnimation.kNormal_l then self:playNormalLargeAnimation() 
	elseif animation == kTileBalloonAnimation.kRunaway then self:playRunawayAnimation() 
	elseif animation == kTileBalloonAnimation.kExplode then self:playExploreAnimation() end
end

function TileBalloon:playNormalSmallAnimation( ... )
	-- body
	if self.animationType and self.animationType == kTileBalloonAnimation.kNormal_s then return end

	self.animationType = kTileBalloonAnimation.kNormal_s
	if self.balloon then self.balloon:stopAllActions(); end
 	local action_scale_1 = CCScaleTo:create(0.5, 1)
 	local action_scale_2 = CCScaleTo:create(0.5, 0.9)
 	local action = CCRepeatForever:create(CCSequence:createWithTwoActions(action_scale_1, action_scale_2))
 	self.balloon:runAction(action)
end

function TileBalloon:playNormalMiddleAnimation( ... )
	-- body
	if self.animationType and self.animationType == kTileBalloonAnimation.kNormal_m then return end
	self.animationType = kTileBalloonAnimation.kNormal_m
	
	if self.balloon then self.balloon:stopAllActions(); end
 	
 	local action_scale_1 = CCScaleTo:create(0.4, 1.1)
 	local action_scale_2 = CCScaleTo:create(0.4, 1)
 	local action = CCRepeatForever:create(CCSequence:createWithTwoActions(action_scale_1, action_scale_2))
 	self.balloon:runAction(action)
end

function TileBalloon:playNormalLargeAnimation( ... )
	-- body
	if self.animationType and self.animationType == kTileBalloonAnimation.kNormal_l then return end
	self.animationType = kTileBalloonAnimation.kNormal_l
	
	if self.balloon then self.balloon:stopAllActions(); end
	if self.light then self.light:stopAllActions(); end
 	
 	local offsetScale = 1
 	local fadein_time = 0.3
 	local fadeout_time = 0.3
 	local action_scale_1 = CCScaleTo:create(fadein_time, 1.1)
 	local action_scale_2 = CCScaleTo:create(fadein_time, 1)
 	local action_ballon = CCRepeatForever:create(CCSequence:createWithTwoActions(action_scale_1, action_scale_2))
 	self.balloon:runAction(action_ballon)

 	self.light:setVisible(true)
 	self.light:setScale(offsetScale)
 	local action_scale_1 = CCScaleTo:create(fadein_time, 1.2)
 	local action_scale_2 = CCScaleTo:create(fadeout_time, 1.4)
 	local action_fade_in = CCFadeIn:create(fadein_time)
 	local action_fade_out = CCFadeOut:create(fadeout_time)
 	local action_spawn_in = CCSpawn:createWithTwoActions(action_scale_1, action_fade_in)
 	local action_spawn_out = CCSpawn:createWithTwoActions(action_scale_2, action_fade_out)
 	local action_resetScale = CCScaleTo:create(0.1, offsetScale)

 	local arry_action = CCArray:create();
 	arry_action:addObject(action_spawn_in)
 	arry_action:addObject(action_spawn_out)
 	arry_action:addObject(action_resetScale)
 	local action_light = CCRepeatForever:create(CCSequence:create(arry_action))
 	self.light:runAction(action_light);
end

function TileBalloon:playDestroyAnimation(  )
	-- body
	if self.animationType and self.animationType == kTileBalloonAnimation.kExplode then return end
	self.animationType = kTileBalloonAnimation.kExplode
	
	if self.balloon then self.balloon:stopAllActions(); end
	if self.light then self.light:stopAllActions();  self.light:setVisible(false) end

	local function callback( ... )
		-- body
		self.balloon:setVisible(false)
		self.rope:setVisible(false)
		self.numberShowNode:setVisible(false)
		self.bombAnimation = Sprite:createWithSpriteFrameName("balloon_bomb_0000.png")
		self:addChild(self.bombAnimation)

		local function afterComplete( ... )
			-- body
			self:dp(Event.new(Events.kComplete, nil, self))
		end
		local frame = SpriteUtil:buildFrames("balloon_bomb_%04d.png", 0, 10)
		local animate = SpriteUtil:buildAnimate(frame, kCharacterAnimationTime)
		self.bombAnimation:play(animate, 0, 1, afterComplete, true)
	end

	local action_scale = CCScaleTo:create(0.1, 1.5)
	local action_callfunc = CCCallFunc:create(callback)

  	self.balloon:runAction(CCSequence:createWithTwoActions(action_scale, action_callfunc))
end

function TileBalloon:playRunawayAnimation( scale , callback )
	-- body
	local local_scale = scale or 1;
	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local topHeight = visibleSize.height / local_scale
	local topWidth = visibleSize.width / local_scale
	
	if self.animationType and self.animationType == kTileBalloonAnimation.kRunaway then return end
	self.animationType = kTileBalloonAnimation.kRunaway

	self.numberShowNode:setVisible(false)
	self.balloon:stopAllActions();
	self.balloon:setScale(1.2)
	self.rope:setRotation(90)
	self.rope:setPosition(ccp(4, -18))
	local position = self:getPosition();

	self.light:stopAllActions();
	self.light:setVisible(false)
	local bezier
	if __PURE_LUA__ then
		bezier = ccBezierConfig:new()
	else
		bezier = ccBezierConfig()
	end
	bezier.controlPoint_1 = ccp(position.x - topWidth / 7, position.y + topHeight/5);
	bezier.controlPoint_2 = ccp(position.x + topWidth / 7, position.y + topHeight/5);
	bezier.endPosition = ccp(position.x, topHeight);
	local bezier_action = CCBezierTo:create(4, bezier)

	local function localcallback()
		if callback then callback() end
	end

	local action_spawn = CCSpawn:createWithTwoActions(bezier_action, CCFadeOut:create(4))
	local action_callback = CCCallFunc:create(localcallback)
	self:runAction(CCSequence:createWithTwoActions(action_spawn, action_callback))
end
