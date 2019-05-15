

FlyBaseAnimation = class(CocosObject)

-- function FlyBaseAnimation:create( num )
-- 	local coinStack = FlyBaseAnimation.new(CCNode:create())
-- 	coinStack:init(num)
-- 	return coinStack
-- end

function FlyBaseAnimation:dispose( ... )
	CocosObject.dispose(self)

	if self.isInHomeScene then
		self.homeSceneIconButton:setVisible(true)
	end 

	-- if self.iconButton and not self.isInHomeScene then
	-- 	self.iconButton:removeFromParentAndCleanup(true)
	-- end
end

function FlyBaseAnimation:init( num )
	local scene = Director:sharedDirector():getRunningScene()
	if not scene then
		return
	end

	self.scene = scene
	self.num = num
	self.isInHomeScene = self.scene:is(HomeScene)
	self.homeSceneIconButton = self:getHomeSceneIconButton()
	self.iconButton = self:createIconButton()

	local function onFinish( ... )
		if self.num > 0 then
			self:playAddNumberAnim(function( ... )
				self:onFinish()
			end)
		else
			self:onFinish()
		end
	end

	local function onReach( ... )
		self:playHighlightAnim()
	end

	self.animation = self:createAnimation(onFinish,onReach)
end

function FlyBaseAnimation:createIconButton( ... )
	local container = CocosObject:create()

	local iconButton = self.homeSceneIconButton.class:create()
	
	local icon = iconButton:getBubbleItemRes():getChildByName("placeHolder")
	local bounds = icon:getGroupBounds()

	local midX = bounds:getMidX()
	local midY = bounds:getMidY()

	iconButton:setPositionX(-midX)
	iconButton:setPositionY(-midY)
	container:addChild(iconButton)

	function container:getBubbleItemRes( ... )
		return iconButton:getBubbleItemRes()
	end

	if iconButton.setTempEnergyState then
		function container:setTempEnergyState( ... )
			iconButton:setTempEnergyState(...)
		end
	end

	iconButton:runAction(CCCallFunc:create(function( ... )
		local bounds = self.homeSceneIconButton:getGroupBounds()
		local pos = ccp(
			self.homeSceneIconButton:getPositionX(),
			self.homeSceneIconButton:getPositionY()
		)
		pos = HomeScene:sharedInstance().iconLayer:convertToWorldSpace(pos)
		pos = container:getParent():convertToNodeSpace(pos)
		container:setPositionX(pos.x + midX/HomeScene:sharedInstance().iconLayerScale)
		container:setPositionY(pos.y + midY/HomeScene:sharedInstance().iconLayerScale)
		container:setScale(1/HomeScene:sharedInstance().iconLayerScale)
	end))


	self:addChild(container)

	return container
end

function FlyBaseAnimation:getHomeSceneIconButton( ... )
	return nil
end

function FlyBaseAnimation:createAnimation( callback )
	return nil
end

function FlyBaseAnimation:setFinishCallback( finishCallback )
	self.finishCallback = finishCallback
end

function FlyBaseAnimation:onStart( ... )
	if self.isInHomeScene then
		self.homeSceneIconButton:setVisible(false)
	else
		self:playIconButtonShowAnim()
	end
end

function FlyBaseAnimation:onFinish( ... )
	if self.isInHomeScene then	
		if self.finishCallback then
			self.finishCallback()
		end	
		if self.isPopout then
			if self.scene and not self.scene.isDisposed then
				self.scene:superRemoveChild(self)
			end
		end
		self.homeSceneIconButton:setVisible(true)
	else
		self:playIconButtonHideAnim(function( ... )
			if self.finishCallback then
				self.finishCallback()
			end	
			if self.isPopout then
				if self.scene and not self.scene.isDisposed then
					self.scene:superRemoveChild(self)
				end
			end		
		end)
	end
end

function FlyBaseAnimation:setWorldPosition( worldPos )
	self.worldPos = worldPos
end

function FlyBaseAnimation:play( ... )
	if not self.scene or self.scene.isDisposed then
		if self.finishCallback then
			self.finishCallback()
		end	
		self:dispose()
		return
	end

	if not self:getParent() then
		self.isPopout = true
		-- PopoutManager:add(self,false,true,self.scene)
		self.scene:superAddChild(self)
	end
	if self.worldPos then
		self:setPosition(self:getParent():convertToNodeSpace(self.worldPos))
	end

	self:onStart()
	self.animation:play()
end


function FlyBaseAnimation:playIconButtonShowAnim( callback )
	self.iconButton:stopAllActions()
	
	self.iconButton:setVisible(true)
	self.iconButton:setScaleX(0.84)
	self.iconButton:setScaleY(0.84)

	local actions = CCArray:create()
	actions:addObject(CCScaleTo:create(3/24,1.12,1.12))
	actions:addObject(CCScaleTo:create(2/24,1.0,1.0))
	actions:addObject(CCCallFunc:create(function( ... )
		if callback then
			callback()
		end
	end))
	
	self.iconButton:runAction(CCSequence:create(actions))
end

function FlyBaseAnimation:playIconButtonHideAnim( callback )
	self.iconButton:stopAllActions()

	self.iconButton:setVisible(true)
	self.iconButton:setScaleX(1.0)
	self.iconButton:setScaleY(1.0)

	local actions = CCArray:create()
	actions:addObject(CCScaleTo:create(3/24,1.0,1.0))
	actions:addObject(CCScaleTo:create(2/24,0.64,0.64))
	actions:addObject(CCCallFunc:create(function( ... )
		if callback then
			callback()
		end
	end))

	self.iconButton:runAction(CCSequence:create(actions))
end

function FlyBaseAnimation:playHighlightAnim( ... )

	if not self.iconButton.shine then
		local bubble = self.iconButton:getBubbleItemRes():getChildByName("bubble")
		self.iconButton.shine = Sprite:createWithSpriteFrameName("bubbleShine0000")
		self.iconButton.shine:setAnchorPoint(ccp(0,0))
		self.iconButton.shine:setPositionX(-8)
		self.iconButton.shine:setPositionY(-8)
		bubble:addChild(self.iconButton.shine)
	end

	self.iconButton.shine:stopAllActions()
	self.iconButton.shine:setOpacity(0)
	self.iconButton.shine:setVisible(true)
	local actions = CCArray:create()
	actions:addObject(CCFadeTo:create(5/24,150/150 * 255))
	actions:addObject(CCFadeTo:create(5/24,100/150 * 255))
	actions:addObject(CCFadeTo:create(4/24,0/150 * 255))
	actions:addObject(CCCallFunc:create(function( ... )
		self.iconButton.shine:setVisible(false)
	end))
	self.iconButton.shine:runAction(CCSequence:create(actions))

	local icon = self.iconButton:getBubbleItemRes():getChildByName("placeHolder")
	iconBounds = icon:getGroupBounds()

	local animIcon = Sprite:createWithSpriteFrame(icon:getChildAt(0):displayFrame())
	animIcon:setAnchorPoint(ccp(0.5,0.5))
	local pos = self.iconButton:convertToNodeSpace(ccp(iconBounds:getMidX(),iconBounds:getMidY()))
	animIcon:setPositionX(pos.x)
	animIcon:setPositionY(pos.y)
	self.iconButton:addChild(animIcon)

	local actions = CCArray:create()
	actions:addObject(CCScaleTo:create(2/24,0.9,0.9))
	actions:addObject(CCSpawn:createWithTwoActions(
		CCScaleTo:create(6/24,1.3,1.3),
		CCFadeTo:create(6/24,0.55)
	))
	actions:addObject(CCSpawn:createWithTwoActions(
		CCScaleTo:create(5/24,1.0,1.0),
		CCFadeTo:create(5/24,1.0)
	))
	actions:addObject(CCCallFunc:create(function( ... )
		animIcon:removeFromParentAndCleanup(true)
	end))
	animIcon:runAction(CCSequence:create(actions))
end

function FlyBaseAnimation:playAddNumberAnim( callback )

	local fntFile = "fnt/star_entrance.fnt"
	if _G.__use_small_res then
		fntFile = "fnt/star_entrance@2x.fnt"
	end
	local animLabel = CocosObject.new(CCLabelBMFont:create("+"..tostring(self.num),fntFile))
	animLabel:setAnchorPoint(ccp(0.5,0.5))
	-- animLabel:setPositionX(self.iconButton:getLabelPlaceholderPos().x + self.iconButton:getLabelPlaceholderSize().width/2)
	-- animLabel:setPositionY(self.iconButton:getLabelPlaceholderPos().y)
	local bounds = self.iconButton:getBubbleItemRes():getGroupBounds()
	local wordPos = ccp(bounds:getMidX(),bounds:getMinY() + 30)
	local localPos = self.iconButton:convertToNodeSpace(wordPos)
	animLabel:setPositionX(localPos.x)
	animLabel:setPositionY(localPos.y)
	self.iconButton:addChild(animLabel)

	local actions = CCArray:create()
	actions:addObject(CCMoveBy:create(10/24,ccp(0,20)))
	actions:addObject(CCSpawn:createWithTwoActions(
		 CCFadeOut:create(8/24),
		 CCMoveBy:create(8/24,ccp(0,10))
	))
	actions:addObject(CCCallFunc:create(function( ... )
		animLabel:removeFromParentAndCleanup(true)

		if callback then
			callback()
		end
	end))
	animLabel:runAction(CCSequence:create(actions))
end


function FlyBaseAnimation:setScale( scale )
end

function FlyBaseAnimation:setScaleX( scaleX )
end

function FlyBaseAnimation:setScaleY( scaleY )
end