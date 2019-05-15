

local RewardCtrl = class()

RewardCtrl.State = {
	kNormal = 1,
	kAvailable = 2
}

RewardCtrl.ExtraState = {
	kNone = 0,
	kNormal = 1,
	kTimeOut = 2,
}

function RewardCtrl:ctor( ui )
	self.ui = ui

	if (not self.ui) or self.ui.isDisposed then return end

	self.anim = self.ui:getChildByName('anim')

	self.flag2 = self.anim:getChildByName('flag2')
	self.flag1 = self.anim:getChildByName('flag1')
	self.num = self.ui:getChildByName('num')
	self.holder = self.ui:getChildByName('holder')
	self.light = self.anim:getChildByName('light')

	self.holder:setAnchorPointCenterWhileStayOrigianlPosition()
	self.num:changeFntFile('fnt/event_default_digits.fnt')

	local scale = 1.35

	self.num:setScale(scale)
	self.num:setPositionY(self.num:getPositionY() - 8)

	self.grayNum = BitmapText:create('', 'fnt/event_default_digits.fnt')
	self.grayNum:setScale(scale)
	self.ui:addChild(self.grayNum)
	self.grayNum:setVisible(false)

	local pos = self.num:getPosition()
	self.grayNum:setPosition(ccp(pos.x, pos.y))

	local anchor = self.num:getAnchorPoint()
	self.grayNum:setAnchorPoint(ccp(anchor.x, anchor.y))

	self.state = RewardCtrl.State.kNormal
	self.extraState = RewardCtrl.ExtraState.kNone

	self:refresh()
end

function RewardCtrl:refresh( ... )
	if (not self.ui) or self.ui.isDisposed then return end

	self:stopAvailableAnim()


	if self.state == RewardCtrl.State.kNormal then
		self.light:setVisible(false)
	elseif self.state == RewardCtrl.State.kAvailable and self.extraState ~= RewardCtrl.ExtraState.kTimeOut then
		self.light:setVisible(true)
		self:playAvailableAnim()
	else
		self.light:setVisible(false)
	end

	if self.extraState == RewardCtrl.ExtraState.kNone then
		self.flag1:setVisible(false)
		self.flag2:setVisible(false)
		if self.rewardIcon then
			self.rewardIcon:clearAdjustColorShader()
		end

		self.grayNum:setVisible(false)
		self.num:setVisible(true)

	elseif self.extraState == RewardCtrl.ExtraState.kNormal then
		self.flag1:setVisible(false)
		self.flag2:setVisible(true)
		if self.rewardIcon then
			self.rewardIcon:clearAdjustColorShader()
		end
		self.grayNum:setVisible(false)
		self.num:setVisible(true)

	elseif self.extraState == RewardCtrl.ExtraState.kTimeOut then
		self.flag2:setVisible(false)
		self.flag1:setVisible(true)
		if self.rewardIcon then
			self.rewardIcon:adjustColor(0, -1, 0, 0)
			self.rewardIcon:applyAdjustColorShader()
		end
		self.grayNum:setVisible(true)
		self.num:setVisible(false)
	end
end

function RewardCtrl:setReward( reward )
	self.reward = reward
	if self.rewardIcon then
		self.rewardIcon:removeFromParentAndCleanup(true)
		self.rewardIcon = nil
	end

	local sp = ResourceManager:sharedInstance():buildItemSprite(self.reward.itemId)
	local frameName = sp.frameName
	sp:dispose()

	self.rewardIcon = SpriteColorAdjust:createWithSpriteFrameName(frameName)

	self.holder:setOpacity(0)

	local index = self.ui:getChildIndex(self.holder)
	local pos = self.holder:getPosition()
	pos = ccp(pos.x, pos.y)

	self.rewardIcon:setAnchorPoint(ccp(0.5, 0.5))
	self.rewardIcon:setPosition(pos)

	self.ui:addChildAt(self.rewardIcon, index)
	
	local text = tostring('x'..reward.num)

	self.num:setText(text)
	self.grayNum:setText(text)

	local rightX = 183

	self.num:setPositionX(rightX-self.num:getContentSize().width*self.num:getScaleX())
	self.grayNum:setPositionX(rightX-self.grayNum:getContentSize().width*self.grayNum:getScaleX())

end

function RewardCtrl:setState( newState )
	if self.state ~= newState then
		self.state = newState
		self:refresh()
	end
end

function RewardCtrl:setExtraState( newState )
	if self.extraState ~= newState then
		self.extraState = newState
		self:refresh()
	end
end

function RewardCtrl:playAvailableAnim( ... )
	if (not self.ui) or self.ui.isDisposed then return end

  	local deltaTime = 0.9
    local scale = 1
    local animations = CCArray:create()
    animations:addObject(CCScaleTo:create(deltaTime, 0.98/scale, 1.03*scale))
    animations:addObject(CCScaleTo:create(deltaTime, 1.01*scale, 0.96/scale))
    animations:addObject(CCScaleTo:create(deltaTime, 0.98/scale,1.03*scale))
    animations:addObject(CCScaleTo:create(deltaTime, 1.01*scale, 0.96/scale))
    self.anim:runAction(CCRepeatForever:create(CCSequence:create(animations)))
end

function RewardCtrl:stopAvailableAnim( ... )
	if (not self.ui) or self.ui.isDisposed then return end

	self.anim:stopAllActions()
end

return RewardCtrl