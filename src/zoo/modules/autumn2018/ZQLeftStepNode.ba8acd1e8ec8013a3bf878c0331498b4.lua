
local LeftStepNode = class(CocosObject)

function LeftStepNode:create()
	local node = LeftStepNode.new(CCNode:create())
	node:init()
	return node
end

function LeftStepNode:init()
	-- local sprite = SpriteColorAdjust:createWithSpriteFrameName("left_step_flag_bg")
	local numberLabel = BitmapText:create("", "fnt/18midautumn_car.fnt", 200)
	numberLabel:setPreferredSize(60, 44)
	numberLabel:setVisible(false)

	self:addChild(numberLabel)
	self.numberLabel = numberLabel

	self.isNodeActive = true
	-- self:addChild(sprite)
	-- self.sprite = sprite
end

function LeftStepNode:playAddFiveEffect()
	local sprite = Sprite:createWithSpriteFrameName("ZQ_add_five_effect")
	sprite:setPosition(self.numberLabel:getPosition())
	local seq = CCArray:create()
	sprite:setScale(0.61)
	local animeFrame = 30
	seq:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(12/animeFrame, ccp(0, 40)), CCScaleTo:create(12/animeFrame, 1, 1)))
	seq:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(16/animeFrame, ccp(0, 10)), CCFadeOut:create(16/animeFrame)))
	seq:addObject(CCCallFunc:create(function() sprite:removeFromParentAndCleanup(true) end))
	sprite:runAction(CCSequence:create(seq))
	self:addChild(sprite)
end

function LeftStepNode:setLeftStep(step)
	if self.numberLabel then
		self.numberLabel:setString(tostring(step))
		if self.numSprite then
			self.numSprite:removeFromParentAndCleanup(true)
			self.numSprite = nil
		end

		self.numberLabel:setVisible(true)
		local size = self.numberLabel:getContentSize()
		self.numberLabel:setPosition(ccp(size.width / 2, size.height / 2))
		local renderTexture = CCRenderTexture:create(size.width, size.height)
		renderTexture:beginWithClear(255, 255, 255, 0)
		self.numberLabel:visit()
		renderTexture:endToLua()
		if __WP8 then renderTexture:saveToCache() end
		self.numberLabel:setVisible(false)
		local texture = renderTexture:getSprite():getTexture()
		if texture then
			local numSprite = SpriteColorAdjust:createWithTexture(texture) --HeTexture:createWithTexture(texture2d)
			numSprite:setScaleY(-1)
			numSprite:setPosition(ccp(0, 0))
			-- self.sprite:addChild(numSprite)
			self:addChild(numSprite)
			self.numSprite = numSprite
		end

		if not self.isNodeActive then
			self.numSprite:applyAdjustColorShader()
			self.numSprite:adjustColor(0,-1, 0, 0)
		end
	end
end

function LeftStepNode:playMoveAnimation1()
	-- self.sprite:stopAllActions()
	-- self.sprite:setPosition(ccp(0, 0))
	-- local moveAction = CCSequence:createWithTwoActions(CCMoveBy:create(14/24, ccp(-5, 0)), CCMoveBy:create(14/24, ccp(5, 0)))
	-- self.sprite:runAction(CCRepeatForever:create(moveAction))
end

function LeftStepNode:playMoveAnimation2()
	-- self.sprite:stopAllActions()
	-- self.sprite:setPosition(ccp(0, 0))
	-- local moveAction = CCSequence:createWithTwoActions(CCMoveBy:create(6/24, ccp(-5, 0)), CCMoveBy:create(6/24, ccp(5, 0)))
	-- self.sprite:runAction(CCRepeatForever:create(moveAction))
end

function LeftStepNode:stopMoveAnimation()
	-- self.sprite:stopAllActions()
	-- self.sprite:setPosition(ccp(0, 0))
end

function LeftStepNode:setNodeActived(isActive)
	if true or self.isNodeActive == isActive then -- 不存在灰色状态
		return
	end
	self.isNodeActive = isActive
	-- if self.sprite and self.sprite.refCocosObj then
	-- 	if isActive then
	-- 		self.sprite:clearAdjustColorShader()
	-- 	else
	-- 		self:stopMoveAnimation()
	-- 		self.sprite:applyAdjustColorShader()
	-- 		self.sprite:adjustColor(0,-1, 0, 0)
	-- 	end
	-- end
	if self.numSprite and self.numSprite.refCocosObj then
		if isActive then
			self.numSprite:clearAdjustColorShader()
		else
			self.numSprite:applyAdjustColorShader()
			self.numSprite:adjustColor(0,-1, 0, 0)
		end
	end
end

return LeftStepNode