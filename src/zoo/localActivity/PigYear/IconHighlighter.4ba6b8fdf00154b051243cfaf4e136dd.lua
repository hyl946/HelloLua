require "zoo.scenes.component.HomeScene.flyToAnimation.FlySpecialItemAnimation"

local IconHighlighter = class(Layer)

function IconHighlighter:create(icon, parent, childIndex)
	local anim = IconHighlighter.new(CCNode:create())
	anim:_init(icon, parent, childIndex)
	return anim
end

function IconHighlighter:_init(icon, parent, childIndex)
	self:initLayer()
	self.__icon = icon
	self._parentNode = parent
	self._childIndex = childIndex
	self:createIconButton()
end

function IconHighlighter:setSceneMode( sceneMode )
	-- body
	self.sceneMode = sceneMode
end

function IconHighlighter:get__icon( ... )
	return self.__icon
end

function IconHighlighter:createIconButton( ... )
	local container = CocosObject:create()
	local iconButton
	if type(self.__icon.copy) == 'function' then
		iconButton = self.__icon:copy()
	else
		iconButton = self.__icon.class:create()
	end
	self.__iconButtonCloned = iconButton
	local icon = iconButton
	local layoutUtils = require 'zoo.panel.happyCoinShop.utils'
	container:addChild(iconButton)
	local bounds = iconButton:getGroupBounds()
	local size = CCSizeMake(bounds.size.width, bounds.size.height)
	container:setContentSize(size)
	layoutUtils.setNodeOriginPos(iconButton, ccp(0, 0), container)
	-- iconButton:runAction(CCCallFunc:create(function( ... )
		
	-- end))
	self:addChild(container)
	container:setAnchorPoint(ccp(0.5, 0.5))
	self.iconContainer = container
end

function IconHighlighter:show( ... )
	if self.isDisposed then return end
	if not self.__icon then return end
	if self.__icon.isDisposed then return end
	
	self:setVisible(true)

	if self:getParent() then
	else
		if self.sceneMode  then
			Director:sharedDirector():run():superAddChild(self)
		else
			if self._childIndex then
				self._parentNode:addChildAt(self, self._childIndex)
			else
				self._parentNode:addChild(self)
			end
		end
		

		local bounds = self.__icon:getGroupBounds()
		-- container:setPositionX(bounds.origin.x + bounds.size.width/2)
		-- container:setPositionY(bounds.origin.y + bounds.size.height/2)

		local layoutUtils = require 'zoo.panel.happyCoinShop.utils'
		layoutUtils.setNodeCenterPos(self.iconContainer, ccp(bounds.origin.x + bounds.size.width/2, bounds.origin.y + bounds.size.height/2))

		if self.__iconButtonCloned then
			if self.__iconButtonCloned.getResList then
				for _, v in ipairs(self.__iconButtonCloned:getResList()) do
					TextureSceneConfig:rollbackByKey(v)
				end
			end
		end

	end

	self:playIconButtonShowAnim()
end

function IconHighlighter:hide( ... )
	if self.isDisposed then return end
	self:setVisible(false)
end

function IconHighlighter:remove( ... )
	if self.isDisposed then return end

	if self:getParent() then
		if self.sceneMode  then
			Director:sharedDirector():run():superRemoveChild(self, true)
		else
			self:removeFromParentAndCleanup(true)
		end
	else
		self:dispose()
	end
end


function IconHighlighter:playIconButtonShowAnim( callback )
	if self.isDisposed then return end
	self.iconContainer:stopAllActions()
	
	self.iconContainer:setVisible(true)
	self.iconContainer:setScaleX(0.84)
	self.iconContainer:setScaleY(0.84)

	local actions = CCArray:create()
	actions:addObject(CCScaleTo:create(3/24,1.12,1.12))
	actions:addObject(CCScaleTo:create(2/24,1.0,1.0))
	actions:addObject(CCCallFunc:create(function( ... )
		if callback then
			callback()
		end
	end))
	
	self.iconContainer:runAction(CCSequence:create(actions))
end

return IconHighlighter