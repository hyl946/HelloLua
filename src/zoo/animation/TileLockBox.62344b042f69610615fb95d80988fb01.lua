require "zoo.common.view.AnimationNumberText" 

TileLockBox = class(CocosObject)

local kCharacterAnimationTime = 1/24

function TileLockBox:create(lockHeadNum , rup , rdown , rleft , rright , isActive)
	local s = TileLockBox.new(CCNode:create())
	s:init(lockHeadNum , rup , rdown , rleft , rright , isActive)
	return s
end

function TileLockBox:init(lockHeadNum , rup , rdown , rleft , rright , isActive)
	self.body_normal = Sprite:createWithSpriteFrameName("lockBox_body_normal")
	self:addChild(self.body_normal)

	self.rope_up = Sprite:createWithSpriteFrameName("lockBox_rope_vertical_down")
	self.rope_up:setPosition(ccp(0,17))
	self:addChild(self.rope_up)

	self.rope_down = Sprite:createWithSpriteFrameName("lockBox_rope_vertical_up")
	self.rope_down:setPosition(ccp(0,-17))
	self:addChild(self.rope_down)

	self.rope_left = Sprite:createWithSpriteFrameName("lockBox_rope_horizon_right")
	self.rope_left:setPosition(ccp(-17,0))
	self:addChild(self.rope_left)

	self.rope_right = Sprite:createWithSpriteFrameName("lockBox_rope_horizon_left")
	self.rope_right:setPosition(ccp(17,0))
	self:addChild(self.rope_right)


	self.rope_up_light = Sprite:createWithSpriteFrameName("lockBox_rope_vertical_down_light")
	self.rope_up_light:setPosition(ccp(0,17))
	self:addChild(self.rope_up_light)

	self.rope_down_light = Sprite:createWithSpriteFrameName("lockBox_rope_vertical_up_light")
	self.rope_down_light:setPosition(ccp(0,-17))
	self:addChild(self.rope_down_light)

	self.rope_left_light = Sprite:createWithSpriteFrameName("lockBox_rope_horizon_right_light")
	self.rope_left_light:setPosition(ccp(-17,0))
	self:addChild(self.rope_left_light)

	self.rope_right_light = Sprite:createWithSpriteFrameName("lockBox_rope_horizon_left_light")
	self.rope_right_light:setPosition(ccp(17,0))
	self:addChild(self.rope_right_light)


	if lockHeadNum and lockHeadNum > 0 then
		self.showLockHead = true

		self.lockHead = Layer:create()
		
		self.lockHeadBG = Sprite:createWithSpriteFrameName("lockBox_lock_normal")
		self.lockHeadBG:setPosition( ccp( 3 , -20 ) )
		self.lockHead:addChild(self.lockHeadBG)

		self.lockHeadBG_light = Sprite:createWithSpriteFrameName("lockBox_lock_normal_light")
		self.lockHeadBG_light:setPosition( ccp( 3 , -20 ) )
		self.lockHead:addChild(self.lockHeadBG_light)
		
		self:addChild(self.lockHead)
		self.lockHead:setPosition( ccp( 0 , 15 ))

		local numStr = tostring(lockHeadNum)

		if string.len(numStr) == 1 then
			numStr = "0" .. numStr
		end
		
		local num1 = tonumber( string.sub(numStr , -3 , -2) )
		local num2 = tonumber( string.sub(numStr , -1 ) )

		self.numText1 = AnimationNumberText:create( num1 )
		self.numText2 = AnimationNumberText:create( num2 )

		self.numText1:setScale(0.5)
		self.numText2:setScale(0.5)

		self.numText1:setPosition( ccp(-8,-21) )
		self.numText2:setPosition( ccp(8,-21) )

		self.lockHead:addChild(self.numText1)
		self.lockHead:addChild(self.numText2)

		self.lockHeadBG_light:setVisible(false)
	end

	self.rup = rup
	self.rdown = rdown
	self.rleft = rleft
	self.rright = rright

	self.rope_up:setVisible(rup)
	self.rope_down:setVisible(rdown)
	self.rope_left:setVisible(rleft)
	self.rope_right:setVisible(rright)

	self.rope_up_light:setVisible(false)
	self.rope_down_light:setVisible(false)
	self.rope_left_light:setVisible(false)
	self.rope_right_light:setVisible(false)

	self.isActive = isActive

	if self.isActive then
		self:playActive()
	end
	
end

function TileLockBox:decreaseLockHeadNum()
	if self.numText1 and self.numText2 then
		local num1 = self.numText1:getNumber()
		local num2 = self.numText2:getNumber()

		local num = num1 * 10 + num2
		num = num - 1
		if num < 0 then num = 0 end

		self:setLockHeadNum(num)
	end
	
end

function TileLockBox:setLockHeadNum(num)
	local numStr = tostring(num)

	if string.len(numStr) == 1 then
		numStr = "0" .. numStr
	end
	
	local num1 = tonumber( string.sub(numStr , -3 , -2) )
	local num2 = tonumber( string.sub(numStr , -1 ) )

	self.numText1:setNumber(num1)
	self.numText2:setNumber(num2)
end

function TileLockBox:playActive(callback)

	--self.rope_up:setVisible(false)
	--self.rope_down:setVisible(false)
	--self.rope_left:setVisible(false)
	--self.rope_right:setVisible(false)

	self.rope_up_light:setVisible(self.rup)
	self.rope_down_light:setVisible(self.rdown)
	self.rope_left_light:setVisible(self.rleft)
	self.rope_right_light:setVisible(self.rright)

	local function getAct()
		local lightActArr = CCArray:create()
	    
	    --actArr:addObject( CCDelayTime:create( 5 ) )
	    lightActArr:addObject( CCFadeTo:create( 0.4 , 255 ) )
	    lightActArr:addObject( CCFadeTo:create( 0.4 , 0 ) )
	    lightActArr:addObject( CCDelayTime:create( 1 ) )

	    return lightActArr
	end
	

    self.rope_up_light:runAction( CCRepeatForever:create( CCSequence:create( getAct() ) ) )
    self.rope_down_light:runAction( CCRepeatForever:create( CCSequence:create( getAct() ) ) )
    self.rope_left_light:runAction( CCRepeatForever:create( CCSequence:create( getAct() ) ) )
    self.rope_right_light:runAction( CCRepeatForever:create( CCSequence:create( getAct() ) ) )

	if self.lockHead then

		--self.lockHeadBG:setVisible(false)
		self.lockHeadBG_light:setVisible(true)
		self.lockHeadBG_light:runAction( CCRepeatForever:create( CCSequence:create( getAct() ) ) )

		local animaTime1 = 0.05
		local animaRotate = 8
		local actArr = CCArray:create()
	    
	    --actArr:addObject( CCDelayTime:create( 5 ) )
	    actArr:addObject( CCEaseSineOut:create( CCRotateTo:create( animaTime1 , animaRotate ) ) )
	    actArr:addObject( CCEaseSineIn:create( CCRotateTo:create( animaTime1 , 0 ) ) )
	    actArr:addObject( CCEaseSineOut:create( CCRotateTo:create( animaTime1 , animaRotate*-1 ) ) )
	    actArr:addObject( CCEaseSineIn:create( CCRotateTo:create( animaTime1 , 0 ) ) )

	    actArr:addObject( CCEaseSineOut:create( CCRotateTo:create( animaTime1 , animaRotate ) ) )
	    actArr:addObject( CCEaseSineIn:create( CCRotateTo:create( animaTime1 , 0 ) ) )
	    actArr:addObject( CCEaseSineOut:create( CCRotateTo:create( animaTime1 , animaRotate*-1 ) ) )
	    actArr:addObject( CCEaseSineIn:create( CCRotateTo:create( animaTime1 , 0 ) ) )

	    actArr:addObject( CCDelayTime:create( 1 ) )

	    --actArr:addObject( CCCallFunc:create( function ()  end ) )
	    self.lockHead:runAction( CCRepeatForever:create( CCSequence:create(actArr) ) )
	end
	
	--[[

	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("flash/lock_box_res.plist")

	local function createSprite()
		return CocosObject.new(HESpriteColorAdjust:createWithSpriteFrameName("lockBox_rope_horizon_right"))
	end

	self.testSpr = createSprite()
	self:addChild(self.testSpr)

	local h, s, v = 80, 1, 1
	self.testSpr.refCocosObj:setHsv(h, s, v)
	self.testSpr.refCocosObj:applyAdjustColorShader()
	]]

end

function TileLockBox:playBreak(callback)

	local animeName = "box_body_break_%04d"	
	local spr_frames = SpriteUtil:buildFrames(animeName, 1, 25)
	local spr_animate = SpriteUtil:buildAnimate(spr_frames, kCharacterAnimationTime)
	
	self.body_normal:play(spr_animate, 0, 1, callback, false)
	self.body_normal:setPosition( ccp( 0 , -1 ) )

	self.rope_up:runAction(CCFadeOut:create(0.5))
	self.rope_down:runAction(CCFadeOut:create(0.5))
	self.rope_left:runAction(CCFadeOut:create(0.5))
	self.rope_right:runAction(CCFadeOut:create(0.5))

	self.rope_up_light:stopAllActions()
	self.rope_down_light:stopAllActions()
	self.rope_left_light:stopAllActions()
	self.rope_right_light:stopAllActions()

	self.rope_up_light:runAction(CCFadeOut:create(0.5))
	self.rope_down_light:runAction(CCFadeOut:create(0.5))
	self.rope_left_light:runAction(CCFadeOut:create(0.5))
	self.rope_right_light:runAction(CCFadeOut:create(0.5))

	if self.showLockHead then

		self.lockHead:runAction(CCFadeOut:create(0.35))
		self.lockHeadBG:runAction(CCFadeOut:create(0.35))

		self.lockHeadBG_light:stopAllActions()
		self.lockHeadBG_light:runAction(CCFadeOut:create(0.35))

		self.numText1:fadeOut()
		self.numText2:fadeOut()

		self.lockHead:runAction( CCEaseSineOut:create( CCMoveTo:create(0.35 , ccp(0, -5) ) ) )
		self.lockHeadBG_light:runAction( CCEaseSineOut:create( CCMoveTo:create(0.35 , ccp(0, -5) ) ) )
	end
end