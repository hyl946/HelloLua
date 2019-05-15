---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2017-09-04 16:27:04
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2017-09-19 20:58:50
---------------------------------------------------------------------------------------
TileNationDayStarBox = class(CocosObject)

function TileNationDayStarBox:ctor()

end

function TileNationDayStarBox:create(num)
	local node = TileNationDayStarBox.new(CCNode:create())
	node:init(num)
	return node
end

function TileNationDayStarBox:init(num)
	self.offsetY = 8

	self.animationNode = CocosObject.new(CCNode:create())
	self:addChild(self.animationNode)
	self.numberNode = CocosObject.new(CCNode:create())
	self:addChild(self.numberNode)

	self:playIdleAnim()
	self:setNum(num)
end

function TileNationDayStarBox:setNum(num)
	if not self.numberLabel then
		local numberLabel = BitmapText:create("", "fnt/target_remain2.fnt", -1, kCCTextAlignmentRight)
		numberLabel:setPreferredSize(200, 36)
		self.numberNode:addChild(numberLabel)
		self.numberLabel = numberLabel
		self.numberLabel:setAnchorPoint(ccp(1,0.5))
		self.numberLabel:setPositionX(30)
		self.numberLabel:setPositionY(-30 + self.offsetY)
	end
	self.numberLabel:setString(tostring(num))
	self.num = num
end

function TileNationDayStarBox:playIdleAnim()
	if self.sprite then
		self.sprite:removeFromParentAndCleanup(true)
		self.sprite = nil
	end
	local sprite = Sprite:createWithSpriteFrameName("nationday_starbox")
	-- local sprite = Sprite:createEmpty()
	-- local bg = Sprite:createWithSpriteFrameName("nationday_starbox_bg")
	-- local front = Sprite:createWithSpriteFrameName("nationday_starbox_front")
	-- local starSprite = Sprite:createWithSpriteFrameName("nationday_star_0000")
	-- local frames = SpriteUtil:buildFrames("nationday_star_%04d", 0, 30)
	-- local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	-- starSprite:play(animate, 0, 0)

	-- local con = LayerColor:createWithColor(ccc3(255, 0, 0), 70, 70)
	-- con:setPosition(ccp(-35, -35))
	-- sprite:addChild(con)

	-- bg:setPosition(ccp(-1, 10))
	-- sprite:addChild(bg)
	-- starSprite:setPosition(ccp(-1, 5))
	-- starSprite:setScale(0.71)
	-- sprite:addChild(starSprite)
	-- front:setPosition(ccp(1, -23))
	-- sprite:addChild(front)
	-- sprite:setPositionY(self.offsetY - 8)

	local actionSeq = CCSequence:createWithTwoActions(CCMoveBy:create(0.7, ccp(0, 5)), CCMoveBy:create(0.7, ccp(0, -5)))
	sprite:runAction(CCRepeatForever:create(actionSeq))

	self.sprite = sprite
	self.animationNode:addChild(sprite)
end

function TileNationDayStarBox:playDisappearAnim(playCollectAnimFunc, onFinish, toPos, chickenNum)
	self.sprite:removeFromParentAndCleanup(true)
	self.sprite = nil

	local animation = NationDay2017Animations:createStarBoxDispear(toPos, onFinish, playCollectAnimFunc, chickenNum)
	self.sprite = animation
	animation:setPositionX(2)

	local leftNum = chickenNum or 0
	local descStep = leftNum / 5
	local function descNum()
		leftNum = leftNum - descStep
		if leftNum < 0 then leftNum = 0 end
		local showNum = math.floor(leftNum)
		self:setNum(showNum)
		if showNum > 0 then
			self.sprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.1), CCCallFunc:create(descNum)))
		end
	end
	self.sprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.1), CCCallFunc:create(descNum)))

	self.animationNode:addChild(animation)
end