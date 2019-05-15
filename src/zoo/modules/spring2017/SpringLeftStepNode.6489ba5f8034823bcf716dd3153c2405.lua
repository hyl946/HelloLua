---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-12-27 18:11:49
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2017-09-12 14:33:25
---------------------------------------------------------------------------------------
local LeftStepNode = class(CocosObject)

function LeftStepNode:create()
	local node = LeftStepNode.new(CCNode:create())
	node:init()
	return node
end

function LeftStepNode:init()
	local sprite = SpriteColorAdjust:createWithSpriteFrameName("nd2017_left_step_flag_bg")
	local numberLabel = BitmapText:create("", "fnt/race_rank.fnt", 200)
	numberLabel:setPreferredSize(60, 44)
	numberLabel:setVisible(true)

	-- self:addChild(numberLabel)
	self.numberLabel = numberLabel
	numberLabel:setPosition(ccp(22, 34))
	sprite:addChild(numberLabel)

	self.isNodeActive = true
	self:addChild(sprite)
	self.sprite = sprite
end

function LeftStepNode:setLeftStep(step)
	if self.numberLabel then
		self.numberLabel:setString(tostring(step))
		-- if self.numSprite then
		-- 	self.numSprite:removeFromParentAndCleanup(true)
		-- 	self.numSprite = nil
		-- end

		-- self.numberLabel:setVisible(true)
		-- local size = self.numberLabel:getContentSize()
		-- self.numberLabel:setPosition(ccp(size.width / 2, size.height / 2))
		-- local renderTexture = CCRenderTexture:create(size.width, size.height)
		-- renderTexture:beginWithClear(255, 255, 255, 0)
		-- self.numberLabel:visit()
		-- renderTexture:endToLua()
		-- self.numberLabel:setVisible(false)
		-- local texture = renderTexture:getSprite():getTexture()
		-- if texture then
		-- 	local numSprite = SpriteColorAdjust:createWithTexture(texture) --HeTexture:createWithTexture(texture2d)
		-- 	numSprite:setScaleY(-1)
		-- 	numSprite:setPosition(ccp(22, 34))
		-- 	self.sprite:addChild(numSprite)
		-- 	self.numSprite = numSprite
		-- end

		-- if not self.isNodeActive then
		-- 	self.numSprite:applyAdjustColorShader()
		-- 	self.numSprite:adjustColor(0,-1, 0, 0)
		-- end
	end
end

function LeftStepNode:playMoveAnimation1()
	self.sprite:stopAllActions()
	self.sprite:setPosition(ccp(0, 0))
	local moveAction = CCSequence:createWithTwoActions(CCMoveBy:create(14/24, ccp(-5, 0)), CCMoveBy:create(14/24, ccp(5, 0)))
	self.sprite:runAction(CCRepeatForever:create(moveAction))
end

function LeftStepNode:playMoveAnimation2()
	self.sprite:stopAllActions()
	self.sprite:setPosition(ccp(0, 0))
	local moveAction = CCSequence:createWithTwoActions(CCMoveBy:create(6/24, ccp(-5, 0)), CCMoveBy:create(6/24, ccp(5, 0)))
	self.sprite:runAction(CCRepeatForever:create(moveAction))
end

function LeftStepNode:stopMoveAnimation()
	self.sprite:stopAllActions()
	self.sprite:setPosition(ccp(0, 0))
end

function LeftStepNode:setNodeActived(isActive)
	if self.isNodeActive == isActive then
		return
	end
	self.isNodeActive = isActive
	if self.sprite and self.sprite.refCocosObj then
		if isActive then
			self.sprite:clearAdjustColorShader()
		else
			self:stopMoveAnimation()
			self.sprite:applyAdjustColorShader()
			self.sprite:adjustColor(0,-1, 0, 0)
		end
	end
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