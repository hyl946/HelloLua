require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"

assert(not BagButton)


BagButton = class(IconButtonBase)

function BagButton:init()
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_s_i_bag')
    
	IconButtonBase.init(self, self.ui)
end

function BagButton:getFlyToPosition()
	local pos = self:getPosition()
	return ccp(pos.x, pos.y)
end

function BagButton:getFlyToSize()
	local size = self:getGroupBounds().size
	size.width, size.height = size.width / 2, size.height / 2
	return size
end

function BagButton:playHighlightAnim()
	self:stopAllActions()
	self:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(0.1, 1.5), CCScaleTo:create(0.4, 1)))
end

function BagButton:create()
	local instance = BagButton.new()
	instance:initShowHideConfig(ManagedIconBtns.BAG)
	instance:init()
	return instance
end