require "zoo.scenes.component.HomeScene.flyToAnimation.FlySpecialItemAnimation"

FlyItemToIconAnimation = class(FlyBaseAnimation)

function FlyItemToIconAnimation:create( num, spriteFrameName, icon, startWorldPos)
	local anim = FlyItemToIconAnimation.new(CCNode:create())
	anim:init(num, spriteFrameName, icon, startWorldPos)
	return anim
end

function FlyItemToIconAnimation:init( num, spriteFrameName, icon, startWorldPos )

	self.__num = num
	self.__spriteFrameName = spriteFrameName
	self.__icon = icon
	self.__startWorldPos = startWorldPos

	FlyBaseAnimation.init(self,num)

end

function FlyItemToIconAnimation:onStart( ... )
	self:playIconButtonShowAnim()
end

function FlyItemToIconAnimation:onFinish( ... )

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

function FlyItemToIconAnimation:getHomeSceneIconButton( ... )
	return self.__icon
end

function FlyItemToIconAnimation:createAnimation( callback,reachCallback )
	
	local bounds = self.__icon:getGroupBounds()
	local targetPos = ccp(bounds:getMidX(), bounds:getMidY())

	local animation = FlySpecialItemAnimation:create({
		itemId = 0, 
		num = self.__num
	}, self.__spriteFrameName, targetPos)

	animation:setWorldPosition(self.__startWorldPos)
	animation:setFinishCallback(callback)
	animation:setReachCallback(reachCallback)

	return animation
end

function FlyItemToIconAnimation:setScale( scale )
	self.container:setScale(scale)
end

function FlyItemToIconAnimation:setScaleX( scaleX )
	self.container:setScaleX(scaleX)
end

function FlyItemToIconAnimation:setScaleY( scaleY )
	self.container:setScaleY(scaleY)
end

function FlyItemToIconAnimation:createIconButton( ... )
	local container = CocosObject:create()

	local iconButton

	if type(self.homeSceneIconButton.copy) == 'function' then
		iconButton = self.homeSceneIconButton:copy()
	else
		iconButton = self.homeSceneIconButton.class:create()
	end

	self.__iconButtonCloned = iconButton
	
	local icon = iconButton


	local layoutUtils = require 'zoo.panel.happyCoinShop.utils'

	container:addChild(iconButton)

	local bounds = iconButton:getGroupBounds()
	local size = CCSizeMake(bounds.size.width, bounds.size.height)
	container:setContentSize(size)

	layoutUtils.setNodeOriginPos(iconButton, ccp(0, 0), container)

	iconButton:runAction(CCCallFunc:create(function( ... )
		local bounds = self.homeSceneIconButton:getGroupBounds()
		container:setPositionX(bounds.origin.x + bounds.size.width/2)
		container:setPositionY(bounds.origin.y + bounds.size.height/2)
	end))

	self:addChild(container)

	container:setAnchorPoint(ccp(0.5, 0.5))

	return container
end

function FlyItemToIconAnimation:playHighlightAnim( ... )
	-- local icon = self.__iconButtonCloned.wrapper
	-- iconBounds = icon:getGroupBounds()
	-- local animIcon = Sprite:createWithSpriteFrame(icon:getChildAt(0):displayFrame())
	-- animIcon:setAnchorPoint(ccp(0.5,0.5))
	-- local pos = self.iconButton:convertToNodeSpace(ccp(iconBounds:getMidX(),iconBounds:getMidY()))
	-- animIcon:setPositionX(pos.x)
	-- animIcon:setPositionY(pos.y)
	-- self.iconButton:addChild(animIcon)

	-- local actions = CCArray:create()
	-- actions:addObject(CCScaleTo:create(2/24,0.9,0.9))
	-- actions:addObject(CCSpawn:createWithTwoActions(
	-- 	CCScaleTo:create(6/24,1.3,1.3),
	-- 	CCFadeTo:create(6/24,0.55)
	-- ))
	-- actions:addObject(CCSpawn:createWithTwoActions(
	-- 	CCScaleTo:create(5/24,1.0,1.0),
	-- 	CCFadeTo:create(5/24,1.0)
	-- ))
	-- actions:addObject(CCCallFunc:create(function( ... )
	-- 	animIcon:removeFromParentAndCleanup(true)
	-- end))
	-- animIcon:runAction(CCSequence:create(actions))
end


function FlyItemToIconAnimation:playAddNumberAnim( callback )

	local fntFile = "fnt/star_entrance.fnt"
	if _G.__use_small_res then
		fntFile = "fnt/star_entrance@2x.fnt"
	end
	local animLabel = CocosObject.new(CCLabelBMFont:create("+"..tostring(self.num),fntFile))
	animLabel:setAnchorPoint(ccp(0.5,0.5))
	local bounds = self.__iconButtonCloned:getGroupBounds()
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