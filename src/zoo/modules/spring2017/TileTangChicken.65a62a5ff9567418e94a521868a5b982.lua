---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-12-22 18:22:57
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2016-12-26 16:45:23
---------------------------------------------------------------------------------------
TileTangChicken = class(CocosObject)

function TileTangChicken:ctor()

end

function TileTangChicken:create(num)
	local node = TileTangChicken.new(CCNode:create())
	node:init(num)
	return node
end

function TileTangChicken:init(num)
	self.offsetY = 8

	self:playIdleAnim()
	self:setNum(num)
end

function TileTangChicken:setNum(num)
	if not self.numberLabel then
		local numberLabel = BitmapText:create("", "fnt/rising_score.fnt", -1, kCCTextAlignmentRight)
		numberLabel:setPreferredSize(200, 36)
		self:addChildAt(numberLabel, 2)
		self.numberLabel = numberLabel
	end
	self.numberLabel:setString(tostring(num))

	self.numberLabel:setAnchorPoint(ccp(1,0.5))
	self.numberLabel:setPositionX(40)
	self.numberLabel:setPositionY(-30 + self.offsetY)

	self.num = num
end

function TileTangChicken:playIdleAnim()
	if self.sprite then
		self.sprite:removeFromParentAndCleanup(true)
		self.sprite = nil
	end
	local sprite, anime = SpriteUtil:buildAnimatedSprite(1/30, "tang_chicken_idle_%04d", 0, 60)
	sprite:play(anime, 0, 0)
	sprite:setPositionY(self.offsetY)
	self.sprite = sprite
	self:addChildAt(sprite, 1)
end

function TileTangChicken:playDisappearAnim(playCollectAnimFunc,callback)
	local function buildAnimatedSprite( index,frameCount,repeatTimes,callback )

		if self.sprite then
			self.sprite:removeFromParentAndCleanup(true)
			self.sprite = nil
		end

		-- local sprite, anime = SpriteUtil:buildAnimatedSprite(1/30, "tang_chicken_disappear"..index.."_%04d", 0, frameCount)
		
		local frames = SpriteUtil:buildFrames("tang_chicken_disappear"..index.."_%04d", 0, frameCount, false)
		local sprite = Sprite.new(CCSprite:createWithSpriteFrame(frames[1]))

		local counter = 0
		local function onAnimateFinished()
			counter = counter + 1
			if counter >= repeatTimes then
				self.sprite:removeFromParentAndCleanup(true)
				self.sprite = nil
			end
			if callback then callback() end
		end

		local actions = CCArray:create()
		for i=1,repeatTimes do
			actions:addObject(SpriteUtil:buildAnimate(frames, 1/30))
			actions:addObject(CCCallFunc:create(onAnimateFinished))
		end
		sprite:runAction(CCSequence:create(actions))

		sprite:setAnchorPoint(ccp(0,1))
		if index == 1 then
			sprite:setPositionX(-62)
			sprite:setPositionY(96 + self.offsetY)		
		elseif index == 2 then
			sprite:setPositionX(-42)
			sprite:setPositionY(80 + self.offsetY)
		elseif index == 3 then
			sprite:setPositionX(-276)
			sprite:setPositionY(190 + self.offsetY)
		end

		self.sprite = sprite
		self:addChildAt(sprite, 1)
	end


	local function playDisappear3()
		buildAnimatedSprite(3,6,1,callback)
		self.numberLabel:runAction(CCFadeOut:create(6/30))
	end

	local function playDisappear2()

		local needFlyCount = math.min(5,self.num)

		local flyCount = 0
		local fromPos = self:convertToWorldSpace(ccp(-35 + 68/2,80 - 70/2))
		local function flyChicken( ... )
			flyCount = flyCount + 1

			playCollectAnimFunc(fromPos,flyCount == 1)

			self.numberLabel:setString(tostring(self.num - flyCount))

			if flyCount >= needFlyCount then
				playDisappear3()
			end
		end

		flyChicken()
		if self.num > 1 then
			buildAnimatedSprite(2,5,needFlyCount - 1,flyChicken)
		end
	end

	local function playDisappear1()
		buildAnimatedSprite(1,21,1,playDisappear2)
	end

	playDisappear1()
end