SnowFlyAnimation = class(CocosObject)
local visibleSize = Director.sharedDirector():getVisibleSize()
local visibleOrigin = Director.sharedDirector():getVisibleOrigin()
local snow_x_limit = 30
function SnowFlyAnimation:create( ... )
	-- body
	local s = SnowFlyAnimation.new(CCNode:create())
	s:init()
	return s
end

function SnowFlyAnimation:init( ... )
	-- body
	self:setPosition(ccp(visibleOrigin.x + visibleSize.width / 2,
	 visibleOrigin.y + visibleSize.height / 2))

	local sp = Sprite:createWithSpriteFrameName("christmas_other_0001")
	self.texture = sp:getTexture()
	self.sp = sp

	self.mainSprite = SpriteBatchNode:createWithTexture(self.texture)
	self:addChild(self.mainSprite)

	self:createSnowBG()
end

local function createSnowOne( pos )
	-- body
	local s = Sprite:createWithSpriteFrameName("christmas_other_0001")
	s:setAnchorPoint(ccp(1, 1))
	s:runAction(CCRepeatForever:create(CCRotateBy:create(4,360)))
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
	local points = CCPointArray:create(#posList)
	for k = 1, #posList do 
		local item = posList[k]
		points:addControlPoint(ccp(pos.x + item.x * r, pos.y + item.y * r))
	end
	local move_action =CCCardinalSplineTo:create(4*time, points, 0)

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

function SnowFlyAnimation:createSnowLine( o_x, o_y )
	-- body
	local num = 10
	for k = 1, num do 
		local x = math.random() * snow_x_limit * 5
		local y = 2 * snow_x_limit  - (k - 1) * snow_x_limit * 2
		local snow = createSnowOne(ccp(o_x + x, o_y + y))
		self.mainSprite:addChild(snow)
	end
end

function SnowFlyAnimation:createSnowBG( ... )
	-- body
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

function SnowFlyAnimation:dispose( ... )
	-- body
	if self.sp then 
		self.sp:dispose()
	end

	CocosObject.dispose(self)
end