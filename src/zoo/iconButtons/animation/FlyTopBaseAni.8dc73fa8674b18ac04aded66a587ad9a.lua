
local FlyTopBaseAni = class(CocosObject)
local kAnimationTime = 1/30
function FlyTopBaseAni:ctor()
end

function FlyTopBaseAni:init(num)
	local scene = Director:sharedDirector():getRunningScene()
	if not scene then return end

	self.scene = scene
	self.num = num or 0
	self.isInHomeScene = self.scene:is(HomeScene)
	self.iconBtnTop = self:getIconBtnTop()
	self.tempIconBtnTop = self:createTempIconBtnTop()

	local function onFinish()
		if self.num > 0 then
			self:playAddNumberAni(function()
				self:onFinish()
			end)
		else
			self:onFinish()
		end
	end
	local function onReach()
		self:playHighlightAni()
	end

	self.container = CocosObject:create()
	self:addChild(self.container)

	self.animation = self:createAnimation(onFinish, onReach)
end

function FlyTopBaseAni:getIconBtnTop()
	assert(false, "must be overrided")
end

function FlyTopBaseAni:createAnimation(onFinish, onReach)
	assert(false, "must be overrided")
end

--better to override
function FlyTopBaseAni:getHighLightRes()
end

function FlyTopBaseAni:createTempIconBtnTop()
	local tempIconBtnTop = self.iconBtnTop.class:create()
	tempIconBtnTop:setVisible(false)
	tempIconBtnTop:runAction(CCCallFunc:create(function ()
		local iconBtnParent = self.iconBtnTop:getParent()
		local iconBtnScale = self.iconBtnTop:getScale()
		local iconBtnPos = self.iconBtnTop:getPosition()
		local pos = iconBtnParent:convertToWorldSpace(iconBtnPos)
		pos = self:convertToNodeSpace(pos)
		tempIconBtnTop:setVisible(true)
		tempIconBtnTop:setPosition(ccp(pos.x, pos.y))
		tempIconBtnTop:setScale(1/HomeScene:sharedInstance().iconLayerScale)
	end))
	self:addChild(tempIconBtnTop)

	return tempIconBtnTop
end

function FlyTopBaseAni:setWorldPosition(worldPos)
	self.startWorldPos = worldPos
end

function FlyTopBaseAni:setFinishCallback(finishCallback)
	self.finishCallback = finishCallback
end

function FlyTopBaseAni:setScale(scale)
	self.container:setScale(scale)
end

function FlyTopBaseAni:setScaleX(scaleX)
	self.container:setScaleX(scaleX)
end

function FlyTopBaseAni:setScaleY(scaleY)
	self.container:setScaleY(scaleY)
end

function FlyTopBaseAni:onStart()
	if self.isInHomeScene then
		self.iconBtnTop:setVisible(false)
	else
		self:playIconBtnTopShowAni()
	end
end

function FlyTopBaseAni:onFinish()
	self.iconBtnTop:updateView()
	if self.isInHomeScene then	
		if self.finishCallback then
			self.finishCallback()
		end	
		if self.addedOnScene then
			if self.scene and not self.scene.isDisposed then
				self.scene:superRemoveChild(self)
			end
		end
		self.iconBtnTop:setVisible(true)
	else
		self:playIconBtnTopHideAni(function()
			if self.finishCallback then
				self.finishCallback()
			end	
			if self.addedOnScene then
				if self.scene and not self.scene.isDisposed then
					self.scene:superRemoveChild(self)
				end
			end		
		end)
	end
end

function FlyTopBaseAni:playIconBtnTopShowAni(callback)
	if callback then callback() end
end

function FlyTopBaseAni:playIconBtnTopHideAni(callback)
	if callback then callback() end
end

function FlyTopBaseAni:playAddNumberAni(callback)
	local numLabel = BitmapText:create("+"..tostring(self.num), "fnt/star_entrance.fnt")
	numLabel:setAnchorPoint(ccp(0.5,0.5))

	local bounds = self.tempIconBtnTop:getBarGroup():getGroupBounds()
	local worldPos = ccp(bounds:getMidX(),bounds:getMinY() + 20)
	local localPos = self.tempIconBtnTop:convertToNodeSpace(worldPos)
	numLabel:setPositionX(localPos.x)
	numLabel:setPositionY(localPos.y)
	self.tempIconBtnTop:addChild(numLabel)

	local arr = CCArray:create()
	arr:addObject(CCMoveBy:create(kAnimationTime*10,ccp(0,20)))
	arr:addObject(CCSpawn:createWithTwoActions(
		 CCFadeOut:create(kAnimationTime*8),
		 CCMoveBy:create(kAnimationTime*8, ccp(0,10))
	))
	arr:addObject(CCCallFunc:create(function()
		numLabel:removeFromParentAndCleanup(true)
		if callback then callback() end
	end))
	numLabel:runAction(CCSequence:create(arr))
end

function FlyTopBaseAni:playHighlightAni()
	local iconGroup = self.tempIconBtnTop:getIconGroup()
	local iconGroupBounds = iconGroup:getGroupBounds()

	local aniIcon
	local aniIconRes = self:getHighLightRes()
	if aniIconRes then
		aniIcon = Sprite:createWithSpriteFrameName(aniIconRes)
	else
		aniIcon = Sprite:createWithSpriteFrame(iconGroup:getChildByName("bg"):displayFrame())
	end
	aniIcon:setAnchorPoint(ccp(0.5,0.5))
	local pos = self.tempIconBtnTop:convertToNodeSpace(ccp(iconGroupBounds:getMidX(),iconGroupBounds:getMidY()))
	aniIcon:setPosition(ccp(pos.x, pos.y))
	self.tempIconBtnTop:addChild(aniIcon)

	local arr = CCArray:create()
	arr:addObject(CCScaleTo:create(kAnimationTime*2, 0.9, 0.9))
	arr:addObject(CCSpawn:createWithTwoActions(
		CCScaleTo:create(kAnimationTime*6, 1.5, 1.5),
		CCFadeTo:create(kAnimationTime*6, 0.55)
	))
	arr:addObject(CCSpawn:createWithTwoActions(
		CCScaleTo:create(kAnimationTime*5, 1.0, 1.0),
		CCFadeTo:create(kAnimationTime*5, 1.0)
	))
	arr:addObject(CCCallFunc:create(function()
		aniIcon:removeFromParentAndCleanup(true)
	end))
	aniIcon:runAction(CCSequence:create(arr))
end

function FlyTopBaseAni:play()
	if not self.scene or self.scene.isDisposed then
		if self.finishCallback then
			self.finishCallback()
		end	
		self:dispose()
		return
	end

	if not self:getParent() then
		self.addedOnScene = true
		self.scene:superAddChild(self)
	end
	if self.startWorldPos then
		self:setPosition(self:getParent():convertToNodeSpace(self.startWorldPos))
	end

	self:onStart()
	self.animation:play()
end

function FlyTopBaseAni:dispose()
	CocosObject.dispose(self)

	if self.isInHomeScene then
		self.iconBtnTop:setVisible(true)
	end 
end

return FlyTopBaseAni