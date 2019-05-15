ChildrensDayGameBg = class(SpriteBatchNode)

function ChildrensDayGameBg:ctor()
	self.totalHeight = 0
	self.spriteHeights = {}
	self.spriteList = {}
	self.visibleHeight = 1280
end

function ChildrensDayGameBg:create()
	FrameLoader:loadImageWithPlist("materials/childrensday_game_bg.plist")
	local texture = Sprite:createWithSpriteFrameName("childrensday_bg_01"):getTexture()
	local bg = ChildrensDayGameBg.new(CCSpriteBatchNode:createWithTexture(texture))
	bg:init()
	return bg
end

function ChildrensDayGameBg:init()
	local posY = 0
	for i=1,10 do
		local sprite = Sprite:createWithSpriteFrameName(string.format("childrensday_bg_%02d", i-1))
		sprite:setAnchorPoint(ccp(0, 1))
		sprite:ignoreAnchorPointForPosition(false)

		sprite:setPositionY(posY)
		self:addChild(sprite)

		local height = sprite:getContentSize().height - 2 -- 防止出现裂缝
		posY = posY - height

		self.totalHeight = self.totalHeight + height
		self.spriteHeights[i] = height
		self.spriteList[i] = sprite
	end
end

function ChildrensDayGameBg:updateSprites(deltaY)
	for id, sprite in ipairs(self.spriteList) do
		sprite:setPositionY(sprite:getPositionY() + deltaY)
		if sprite:getPositionY() - self.spriteHeights[id] > 0 then
			sprite:setPositionY(sprite:getPositionY() - self.totalHeight)
			sprite:setVisible(false)
		elseif sprite:getPositionY() <= -self.visibleHeight then
			sprite:setPositionY(sprite:getPositionY() + self.totalHeight)
			sprite:setVisible(false)
		else
			sprite:setVisible(true)
		end
	end
end

function ChildrensDayGameBg:stopScroll()
	self:unscheduleUpdate()
end

function ChildrensDayGameBg:startScroll(deltaY, time)
	time = time or 0

	self:stopScroll()

	local leftDeltaY = deltaY
	if time <= 0 then
		self:updateSprites(deltaY)
		self:stopScroll()
	else
		local movePerSec = deltaY / time
		local totalDt = 0
		local function updateFunc(dt)
			totalDt = totalDt + dt
			local moveY = movePerSec * dt
			moveY = math.abs(moveY) < math.abs(leftDeltaY) and moveY or leftDeltaY
			self:updateSprites(moveY)
			leftDeltaY = leftDeltaY - moveY
			if totalDt >= time then
				self:stopScroll()
			end
		end
		self:scheduleUpdateWithPriority(updateFunc, 0)
	end
end

function ChildrensDayGameBg:startScrollForever(speed)
	assert(type(speed) == "number")
	if speed == 0 then return end

	self:stopScroll()

	local movePerFrame = speed * 1 / 60
	local function updateFunc(dt)
		self:updateSprites(movePerFrame)
	end
	self:scheduleUpdateWithPriority(updateFunc, 0)
end

function ChildrensDayGameBg:dispose()
	self.spriteList = nil
	self.spriteHeights = nil
	self:stopScroll()
	SpriteBatchNode.dispose(self)
end