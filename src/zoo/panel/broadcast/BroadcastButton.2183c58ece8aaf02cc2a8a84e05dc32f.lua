require 'zoo.panel.broadcast.BroadcastManager'

BroadcastButton = class(BaseUI)

function BroadcastButton:create()
	local instance = BroadcastButton.new()
	instance:init()
	return instance
end

function BroadcastButton:init()
	local ui = Layer:create()
	local icon = Sprite:createWithSpriteFrameName('broadcastIconSymbol0000')
	icon:setAnchorPoint(ccp(0, 1))
	ui:addChild(icon)

	-- 惊叹号
	local mark = Sprite:createWithSpriteFrameName('broadcastIcon10000')
	mark:setAnchorPoint(ccp(0, 0))
	mark:setPosition(ccp(
		icon:getContentSize().width - 20,
		icon:getContentSize().height - 20
	))
	self.mark = mark
	icon:addChild(mark)

	self.mark:setVisible(false)


	ui:setTouchEnabled(true, 0, true, nil, true)
	ui:addEventListener(DisplayEvents.kTouchTap, function()
		Notify:dispatch("QuitNextLevelModeEvent")
		BroadcastManager:getInstance():reShowOne()
	end)

	BaseUI.init(self, ui)
	self:setVisible(false)

	self:update(BroadcastManager:getInstance():getReShowIDs())
end

function BroadcastButton:update(config, isPlayAnimation)
	self:setVisible(#config > 0)
	if #config > 0 and isPlayAnimation then
		self:playAnimation()
	end
end

function BroadcastButton:playAnimation()
	self.mark:stopAllActions()
	self.mark:setScale(17.55/22.05)
	self.mark:setVisible(true)

	local actionArray = CCArray:create()
	actionArray:addObject(CCFadeIn:create(0.000001))
	actionArray:addObject(CCScaleBy:create(5/24, 22.05/17.55))
	actionArray:addObject(CCScaleBy:create(3/24, 17.55/22.05))
	actionArray:addObject(CCScaleBy:create(2/24, 22.20/17.55))
	actionArray:addObject(CCScaleBy:create(3/24, 17.55/22.20))
	actionArray:addObject(CCDelayTime:create(10.0/24.0))
	actionArray:addObject(CCFadeOut:create(4/24))
	local action = CCSequence:create(actionArray)
	self.mark:runAction(action)

end