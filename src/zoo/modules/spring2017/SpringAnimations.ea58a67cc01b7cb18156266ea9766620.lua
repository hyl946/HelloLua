---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-12-26 17:07:22
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2017-09-01 15:18:53
---------------------------------------------------------------------------------------
local SpringDengLong = class(Sprite)

function SpringDengLong:create()
	local node = SpringDengLong.new(CCSprite:create())
	node:init()
	return node
end

function SpringDengLong:init()
	self.builder = InterfaceBuilder:createWithContentsOfFile("flash/spring2017/in_game.json")
	self.ui = self.builder:buildGroup("spring2017_ingame/denglong")
	self:addChild(self.ui)

	local highLight = self.ui:getChildByName("hightlight")
	local zOrder = highLight:getZOrder()
	local size = highLight:getGroupBounds().size
	local origin = highLight:getGroupBounds().origin
	highLight:removeFromParentAndCleanup(false)

	-- local lh = LayerColor:createWithColor(ccc3(255, 0, 0), 300, 500)
	-- lh:addChild(hightlight)
	-- lh:setPosition(ccp(-150, -250))

	self.clippingWidth = size.width
	self.clippingHeight = size.height

	local maskSprite = Sprite:createWithSpriteFrameName("spring2017_ingame/clipping_mask0000")
	maskSprite:setAnchorPoint(ccp(0.5, 1))
	maskSprite:ignoreAnchorPointForPosition(false)
	local maskSize = maskSprite:getContentSize()
	-- local mask = LayerColor:createWithColor(ccc3(255, 0, 0), clippingWidth, clippingHeight)
	-- mask:setAnchorPoint(ccp(0.5, 1))
	-- mask:ignoreAnchorPointForPosition(false)
	local clippingNode = ClippingNode.new(CCClippingNode:create(maskSprite.refCocosObj))
    clippingNode:setAlphaThreshold(0.1)
    clippingNode:addChild(highLight)
    clippingNode:setInverted(false)

	-- local clippingNode = SimpleClippingNode:create()
	-- clippingNode:setContentSize(CCSizeMake(size.width, 0))
	-- clippingNode:setRecalcPosition(true)
	clippingNode:getStencil():setPosition(ccp(self.clippingWidth/2, 0))
	clippingNode:setPosition(ccp(origin.x, origin.y))

	highLight:setPosition(ccp(0, size.height))

	clippingNode:setAnchorPoint(ccp(0, 0))
	self.ui:addChildAt(clippingNode, zOrder)

	self.clippingNode = clippingNode

	local lightLineMask = self.ui:getChildByName("light_line_mask")
	lightLineMask:setOpacity(255)
	local maskGb = lightLineMask:getGroupBounds()
	local maskZOrder = lightLineMask:getZOrder()
	lightLineMask:removeFromParentAndCleanup(false)
	local lightLineClippingNode = ClippingNode.new(CCClippingNode:create(lightLineMask.refCocosObj))
    lightLineClippingNode:setAlphaThreshold(0.1)
    -- lightLineClippingNode:addChild(lh)
    -- lh:setPosition(ccp(0, -200))
    local lightLine = Sprite:createWithSpriteFrameName("spring2017_ingame/denglong_light_line0000")
    lightLineClippingNode:addChild(lightLine)
    lightLine:setPositionX(maskGb.size.width/2)
    lightLine:setPositionY(0)
	lightLineClippingNode:getStencil():setPosition(ccp(-1, maskGb.size.height))
    lightLineClippingNode:setPosition(ccp(maskGb.origin.x, maskGb.origin.y)) 
    self.lightLine = lightLine
    self.ui:addChildAt(lightLineClippingNode, maskZOrder)
    self.lightLineClippingNode = lightLineClippingNode

	self.numLabel = self.ui:getChildByName("num")
	self.numLabel:changeFntFile("flash/spring2017/fnt/spring_festival.fnt")
	self.numLabel:setPreferredSize(100, 36)

	self:setNum(0)
	self:setPercent(0)
end

function SpringDengLong:setNum(num)
	num = num or 0
	self.numLabel:setString(tostring(num))
	local size = self.numLabel:getContentSize()
	self.numLabel:setPositionX(75 - size.width/2)
end

function SpringDengLong:setPercent(percent, animTime)
	-- 0.2 - 0.9
	local realScaleH = 0
	if percent <= 0 then
		realScaleH = 0
	elseif percent >= 1 then
		realScaleH = 1
	else
		realScaleH = 0.25 + 0.65 * percent
	end
	local posY = self.clippingHeight * realScaleH
	self.clippingNode:getStencil():stopAllActions()
	self.lightLine:stopAllActions()
	local lightLineOffsetY = -31 
	if animTime and animTime > 0 then
		local oriPos = self.clippingNode:getStencil():getPositionY()
		self.lightLine:setPositionY(oriPos + lightLineOffsetY)
		self.clippingNode:getStencil():runAction(CCMoveBy:create(animTime, ccp(0, posY - oriPos)))
		self.lightLine:runAction(CCMoveBy:create(animTime, ccp(0, posY - oriPos)))
	else
		self.clippingNode:getStencil():setPositionY(posY)
		self.lightLine:setPositionY(posY + lightLineOffsetY)
	end
end

local SpringChichenMother = class(CocosObject)

local ChickenStatusType = {
	kNone = 0,
	kIdle = 1,
	kHit = 2,
	kCast = 3,
}

function SpringChichenMother:create()
	local node = SpringChichenMother.new(CCNode:create())
	node:init()
	return node
end

function SpringChichenMother:init()
	FrameLoader:loadArmature("skeleton/chicken_mother_spring2017")
	local node = ArmatureNode:create("mother_chicken")
	node:playByIndex(0, 1)   
	node:update(0.001)
	node:stop()
	self:addChild(node)
	self.animNode = node
	-- TODO
	self.denglongNode = SpringDengLong:create()

	self.statusType = ChickenStatusType.kNone

	self:playIdle()

	local castButton = LayerColor:createWithColor(ccc3(255, 0, 0), 200, 80)
	castButton:setTouchEnabled(true, 0, true)
	castButton:setOpacity(255 * 0.75)

	local label = TextField:create("放大招:99", nil, 36)
	label:setAnchorPoint(ccp(0.5,0.5))
	label:setPositionX(100)
	label:setPositionY(40)
	castButton.label = label
	castButton:addChild(label)
	self.castButton = castButton
	self:addChild(castButton)
	self:setCastCount(18)
end

function SpringChichenMother:setCastCount(count)
	self.castButton.label:setString("放大招:"..tostring(count))
end

function SpringChichenMother:addDenglongToChild(slot)
	if slot and self.denglongNode and self.denglongNode.refCocosObj then
		local armature = slot:getCCChildArmature()
		if armature then
			local denglongSlot = armature:getCCSlot("denglong")
			if denglongSlot then
				self.denglongNode.refCocosObj:removeFromParentAndCleanup(false)
				self.denglongNode.refCocosObj:setPosition(ccp(-2, 219))
				local display = tolua.cast(denglongSlot:getCCDisplay(),"CCSprite")
				display:addChild(self.denglongNode.refCocosObj)
			end
		end
	end
end

function SpringChichenMother:playIdle()
	self.statusType = ChickenStatusType.kIdle

	self.animNode:rma()
	self.animNode:stop()
	self.animNode:playByIndex(0, 0)
	self.animNode:update(0.001)
	self:addDenglongToChild(self.animNode:getSlot("idle"))
end

function SpringChichenMother:playHit(onFinished)
	if self.statusType == ChickenStatusType.kHit or self.statusType == ChickenStatusType.kCast then
		return false
	end
	self.statusType = ChickenStatusType.kHit

	self.animNode:rma()
	self.animNode:stop()
	self.animNode:playByIndex(1, 1)
	self.animNode:update(0.001)
	self:addDenglongToChild(self.animNode:getSlot("hit"))

	local function completeCallback()
		self.statusType = ChickenStatusType.kNone
		if type(onFinished) == "function" then onFinished() end
	end
	self.animNode:addEventListener(ArmatureEvents.COMPLETE, completeCallback)
	return true
end

function SpringChichenMother:playCast(onFinished, onCast, addChicken)
	self.statusType = ChickenStatusType.kCast

	self.animNode:rma()
	self.animNode:stop()
	self.animNode:playByIndex(2, 1)
	self.animNode:update(0.01)
	self:addDenglongToChild(self.animNode:getSlot("cast"))
	
	local function completeCallback()
		self.statusType = ChickenStatusType.kNone
		if type(onFinished) == "function" then onFinished() end
	end
	self.animNode:addEventListener(ArmatureEvents.COMPLETE, completeCallback)
	local function eventCallback(evt)
		if evt then
			if evt.data.frameLabel == "playCast" then
				if type(onCast) == "function" then onCast() end
			elseif evt.data.frameLabel == "addChicken" then
				if type(addChicken) == "function" then addChicken() end
			end
		end
	end
	self.animNode:addEventListener(ArmatureEvents.BONE_FRAME_EVENT, eventCallback)
end

function SpringChichenMother:setCollectPercent(value, animTime)
	if self.denglongNode then
		self.denglongNode:setPercent(value, animTime)
	end
end

function SpringChichenMother:setTotalNum(num)
	if self.denglongNode then
		self.denglongNode:setNum(num)
	end
end

function SpringChichenMother:getFireworksPosition()
	local firework1 = self:convertToWorldSpace(ccp(-55, -50)) 
	local firework2 = self:convertToWorldSpace(ccp(115, 60)) 
	local firework3 = self:convertToWorldSpace(ccp(300, -35)) 
	return {firework1, firework2, firework3}
end

function SpringChichenMother:getCollectPosition()
	return self:convertToWorldSpace(ccp(115, -130))
end

SpringAnimations = class()

function SpringAnimations:createChicken(id)
	id = id or 1
	FrameLoader:loadArmature("skeleton/chickens_spring2017")
	local node = ArmatureNode:create(string.format("spring_chicken_%d", id))
	node:playByIndex(0, 1)   
	node:update(0.01)
	node:stop()
	node:playByIndex(0, 1)
	
	local function changeAnim()
		node:playByIndex(1, 0)
		node:update(0.01)
	end
	-- node:addEventListener(ArmatureEvents.COMPLETE, completeCallback)

	local function eventCallback(evt)
		if evt and evt.data.frameLabel == "change" then
			changeAnim()
		end
	end
	node:addEventListener(ArmatureEvents.BONE_FRAME_EVENT, eventCallback)
	return node
end

function SpringAnimations:createChickenMother()
	return SpringChichenMother:create()
end

function SpringAnimations:createDengLong()
	return SpringDengLong:create()
end

function SpringAnimations:createEffectExplore( callback )
	local node = CocosObject.new(CCNode:create())

	local function onRepeatFinishCallback()
		node:removeFromParentAndCleanup(true)
		if callback then callback() end
	end
	local sprite, animate = SpriteUtil:buildAnimatedSprite(1/30, "spring_effect_explore_%04d", 0, 17)
	sprite:play(animate, 0, 1, onRepeatFinishCallback, true)
	sprite:setPosition(ccp(-5, 3))
	node:addChild(sprite)

	-- FrameLoader:loadArmature("skeleton/chickens_spring2017")

	-- local node = ArmatureNode:create("spring_effect_explore")
	-- node:playByIndex(0, 0)   
	-- node:update(0.001)
	-- node:stop()

	return node
end

function SpringAnimations:createChangeEffect(fromPos, toPos, flyEndCallback, animCompleteCallback, autoRemove)
	local anim = CocosObject.new(CCNode:create())
	FrameLoader:loadArmature("skeleton/chickens_spring2017")
	-- local node = ArmatureNode:create("spring_effect_explore")
	-- node:playByIndex(0, 0)   
	-- node:update(0.001)
	-- node:stop()
	-- node:setPosition(ccp(toPos.x-3, toPos.y+10))
	-- node:setVisible(false)
	-- anim:addChild(node)
	local toPosX = toPos.x
	local toPosY = toPos.y

	local flySprite = Sprite:createWithSpriteFrameName("spring2017_ingame/flySprite0000")
	flySprite:setPosition(ccp(fromPos.x, fromPos.y))
	local rotation = angleFromPoint(fromPos, toPos) + 180
	flySprite:setRotation(rotation)
	anim:addChild(flySprite)

	local actSeq = CCArray:create()
	actSeq:addObject(CCMoveTo:create(0.4, ccp(toPos.x, toPos.y)))
	local function onFlyEnd()
		if type(flyEndCallback) == "function" then flyEndCallback() end
		-- node:setVisible(true)
		-- node:playByIndex(0, 1)
		local function completeCallback()
			if autoRemove then anim:removeFromParentAndCleanup(true) end
			if type(animCompleteCallback) == "function" then animCompleteCallback() end
		end
		-- node:addEventListener(ArmatureEvents.COMPLETE, completeCallback)
		local node = self:createEffectExplore(completeCallback)
		node:setPosition(ccp(toPosX, toPosY))
		anim:addChild(node)
	end
	actSeq:addObject(CCCallFunc:create(onFlyEnd))
	actSeq:addObject(CCHide:create())
	flySprite:runAction(CCSequence:create(actSeq))

	return anim
end