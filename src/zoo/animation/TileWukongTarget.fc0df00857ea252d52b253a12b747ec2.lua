TileWukongTarget = class(CocosObject)

function TileWukongTarget:create()
    local instance = TileWukongTarget.new(CCNode:create())
    instance:init()
    return instance
end

function TileWukongTarget:init()

	self.sprite = Sprite:createWithSpriteFrameName("wukong_target_bg")
    -- self.sprite:setAnchorPoint(ccp(1/6 + 0.02, 3/4 - 0.025))
    --self.sprite:setPosition(ccp(70, -35))
    self:addChild(self.sprite)

    self.topLight = Sprite:createWithSpriteFrameName("wukong_target_side")
    self.bottomLight = Sprite:createWithSpriteFrameName("wukong_target_side")
    self.leftLight = Sprite:createWithSpriteFrameName("wukong_target_side")
    self.leftLight:setRotation( 90 )
    --self.leftLight:setRotation( 90 - ((rotation / math.pi) * 180) )
    self.rightLight = Sprite:createWithSpriteFrameName("wukong_target_side")
    self.rightLight:setRotation( 90 )

    self.topLight:setPosition( ccp(0,35) )
    self.topLight:setVisible(false)
    self:addChild(self.topLight)
    self.bottomLight:setPosition( ccp(0,-35) )
    self.bottomLight:setVisible(false)
    self:addChild(self.bottomLight)
    self.leftLight:setPosition( ccp(-35,0) )
    self.leftLight:setVisible(false)
    self:addChild(self.leftLight)
    self.rightLight:setPosition( ccp(35,0) )
    self.rightLight:setVisible(false)
    self:addChild(self.rightLight)
    --self:playAnim()

    self:playLoopAnimation(default)
end

function TileWukongTarget:setLightVisible(direction , visible)
	if direction == "top" then
		self.topLight:setVisible(visible)
	elseif direction == "bottom" then
		self.bottomLight:setVisible(visible)
	elseif direction == "left" then
		self.leftLight:setVisible(visible)
	elseif direction == "right" then
		self.rightLight:setVisible(visible)
	end
end

function TileWukongTarget:playLoopAnimation(animationType)
	if not animationType then animationType = "default" end

	local effTime = 1
	if animationType == "default" then
		--effTime = 0.3
		effTime = 0.75
	elseif animationType == "slow" then
		effTime = 1.5
	end

	local function runAnimation(tar)
		tar:runAction(
			CCRepeatForever:create(
				CCSequence:createWithTwoActions(
					CCFadeTo:create(effTime, 0),
					CCFadeTo:create(effTime, 255)
					)
				)
			)
	end

	self.topLight:stopAllActions()
	--self.topLight:setOpacity(0)
	self.bottomLight:stopAllActions()
	--self.bottomLight:setOpacity(0)
	self.leftLight:stopAllActions()
	--self.leftLight:setOpacity(0)
	self.rightLight:stopAllActions()
	--self.rightLight:setOpacity(0)

	runAnimation(self.topLight)
	runAnimation(self.bottomLight)
	runAnimation(self.leftLight)
	runAnimation(self.rightLight)
end

function TileWukongTarget:hideBG(callback)
    self.bg.hide(callback)
end

function TileWukongTarget:changeColor(color)
    if color == 'red' then
        if self.sprite then self.sprite:removeFromParentAndCleanup(true) end
        self:init(1)
    end
end

function TileWukongTarget:playAnim()
    if self.level == 1 then
        self.bg:setScale(1)
        self.bg:stopAllActions()
        local a = CCArray:create()
        a:addObject(CCFadeOut:create(0.5))
        a:addObject(CCDelayTime:create(0.5))
        a:addObject(CCFadeIn:create(0.5))
        a:addObject(CCDelayTime:create(0.5))
        self.sprite:runAction(CCRepeatForever:create(CCSequence:create(a)))
    else
        self.bg:stopAllActions()
        local seq = CCArray:create()
        seq:addObject(CCScaleTo:create(0.8, 1.01, 1))
        seq:addObject(CCScaleTo:create(0.8, 1, 1.01))
        self.bg:runAction(CCRepeatForever:create(CCSequence:create(seq)))
    end
end

function TileWukongTarget:createWaterAnim()
    local sprite = Sprite:createWithSpriteFrameName("halloween_water_0000.png")
    local frames = SpriteUtil:buildFrames("halloween_water_%04d.png", 0, 30)
    local anim = CCRepeatForever:create(SpriteUtil:buildAnimate(frames, 1/18))
    sprite:runAction(anim)
    return sprite
end
