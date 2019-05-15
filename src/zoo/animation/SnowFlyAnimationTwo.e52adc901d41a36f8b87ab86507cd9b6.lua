SnowFlyAnimationTwo = class(CocosObject)
local visibleSize = Director.sharedDirector():getVisibleSize()
local visibleOrigin = Director.sharedDirector():getVisibleOrigin()
local snow_x_limit = 30
function SnowFlyAnimationTwo:create()
	local s = SnowFlyAnimationTwo.new(CCNode:create())
	s:init()
	return s
end

function SnowFlyAnimationTwo:init()
	self:setPosition(ccp(visibleOrigin.x + visibleSize.width / 2,
	 visibleOrigin.y + visibleSize.height / 2))

	local sp = Sprite:createWithSpriteFrameName("spring_snow")
	self.texture = sp:getTexture()
	self.sp = sp

 --    local touchLayer = LayerColor:create()
 --    touchLayer:ignoreAnchorPointForPosition(false)
	-- touchLayer.lIndex = 1
 --    touchLayer:setAnchorPoint(ccp(0.5, 0.5))
 --    touchLayer:setColor(ccc3(0,0,0))
 --    touchLayer:changeWidthAndHeight(visibleSize.width, visibleSize.height)
 --  	touchLayer:setOpacity(255)
 --  	self:addChild(touchLayer)

	self.mainSprite = SpriteBatchNode:createWithTexture(self.texture)
	self:addChild(self.mainSprite)

	self:createSnowBG()
end

local function createSnowOne( pos )
	local s = Sprite:createWithSpriteFrameName("spring_snow")
	s:setAnchorPoint(ccp(1, 1))
	-- s:runAction(CCRepeatForever:create(CCRotateBy:create(4,360)))
	s:setPosition(ccp(pos.x, pos.y))
	s:setOpacity(0)
	local r = snow_x_limit
	local time = 2
	local randomValue = math.random()
	local k = randomValue > 0.5 and 1 or -1
	local delayTime = randomValue * 4
	local posList  = {
	{x = -1/2 * k, y = -2},
	{x = 0, y = -4},
	{x = 2/2 * k, y = -8},
	{x = 0, y = -12},
	}
	-- {x = 0, y = 0},
	-- {x = -1 * k, y = -2},
	-- {x = 0, y = -4},
	-- {x = 1 * k, y = -6},
	-- {x = 0, y = -8},
	-- {x = -1 * k, y = -10},
	-- {x = 0, y = -12},
	-- {x = 1 * k, y = -14},
	-- }
	local points = CCPointArray:create(#posList)
	for k = 1, #posList do 
		local item = posList[k]
		points:addControlPoint(ccp(pos.x + item.x * r, pos.y + item.y * r))
	end
	local move_action = CCCardinalSplineTo:create(4*time, points, 0)

	local fadeArray = CCArray:create()
	fadeArray:addObject(CCFadeIn:create(0.5 * time))
	fadeArray:addObject(CCDelayTime:create(2.5*time))
	fadeArray:addObject(CCFadeOut:create(time))
	fadeout_action = CCSequence:create(fadeArray )

	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(delayTime))
	arr:addObject(CCSpawn:createWithTwoActions(fadeout_action, move_action))
	arr:addObject(CCMoveTo:create(time * 0.1, ccp(pos.x, pos.y)))

	s:runAction(CCRepeatForever:create(CCSequence:create(arr)))

	s:setScale(0.3 + k * randomValue * 0.1)
	return s
end

function SnowFlyAnimationTwo:createSnowLine( o_x, o_y )
	local num = 12
	for k = 1, num do 
		local x = math.random(-1.4, 1) * snow_x_limit * 5
		local y = (1-k) * 2 * snow_x_limit
		local snow = createSnowOne(ccp(o_x + x, o_y + y))
		self.mainSprite:addChild(snow)
	end
end

function SnowFlyAnimationTwo:createSnowBG()
	local pos = {
		{x = -visibleSize.width/3, y = 2 * visibleSize.height / 3},
		{x = 0, y = 2 *visibleSize.height/3},
		{x = visibleSize.width/3, y = 2 *visibleSize.height/3},
		{x = -visibleSize.width/3, y = 0},
		{x = 0, y = 0},
		{x = visibleSize.width/3, y = 0},
	}

	for k = 1,#pos do 
		local tmp = pos[k]
		self:createSnowLine(tmp.x, tmp.y)
	end
end

function SnowFlyAnimationTwo:createWithParticle()
	local s = SnowFlyAnimationTwo.new(CCParticleSnow:create())
	s:initParticle()
	return s
end

function SnowFlyAnimationTwo:initParticle()
	self.refCocosObj:setLife(60)
	self.refCocosObj:setSpeed(15)
	self.refCocosObj:setTotalParticles(80)
	self.refCocosObj:setStartSize(28)
	self.refCocosObj:setStartSizeVar(5)
	self.refCocosObj:setEmissionRate(80 / 60) -- 开始出现均匀点儿

	-- self.refCocosObj:setRadialAccel(-380)
	-- self.refCocosObj:setRadialAccelVar(0)

	-- self.refCocosObj:setTangentialAccel(45)
	-- self.refCocosObj:setTangentialAccelVar(0)

	-- self.refCocosObj:setAngle(90)
	-- self.refCocosObj:setAngleVar(-45)

	self.refCocosObj:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("spring_snow"))

	-- local blendFunc = ccBlendFunc()
	-- blendFunc.src = GL_SRC_ALPHA
	-- blendFunc.dst = GL_DST_ALPHA
	-- self.refCocosObj:setBlendFunc(blendFunc)
end

function SnowFlyAnimationTwo:dispose()
	if self.sp then 
		self.sp:dispose()
	end

	CocosObject.dispose(self)
end