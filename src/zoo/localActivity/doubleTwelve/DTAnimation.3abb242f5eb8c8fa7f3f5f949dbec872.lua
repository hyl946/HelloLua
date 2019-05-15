--=====================================================
-- DTAnimation
-- by zhijian.li
-- (c) copyright 2009 - 2016, www.happyelements.com
-- All Rights Reserved. 
--=====================================================
-- filename:  DTAnimation.lua
-- author:    zhijian.li
-- e-mail:    zhijian.li@happyelements.com
-- created:   2016/11/21
-- descrip:   2016双十二活动 部分动画
--=====================================================

DTAnimation = {}

function DTAnimation:getActivityIcon()
	for k,v in pairs(HomeScene:sharedInstance().activityIconButtons or {}) do
		if v.source == "Double12/Config.lua" then
			return v
		end
	end
end

function DTAnimation:createMoveAnim()
	local activityIcon = self:getActivityIcon()
	if not activityIcon then
		return
	end

	local iconAnim = Sprite:createWithSpriteFrame(activityIcon.icon:displayFrame())--:buildIcon()

	local anim = CocosObject:create()

	local arrowAnim 
	if DTActivityManager.getInstance():getTriggerGoldChest() then
		arrowAnim = ArmatureNode:create("dt_animation/gold_box")
	elseif DTActivityManager.getInstance():getTriggerSilverChest() then
		arrowAnim = ArmatureNode:create("dt_animation/silver_box")
	end
	
	iconAnim:setAnchorPoint(ccp(0.5,0.5))

	function iconAnim:playShowAnim( ... )
		self:setScaleX(0)
		self:setScaleY(0)

		self:runAction(CCScaleTo:create(0.1,self.scaleX,self.scaleY))
	end

	function iconAnim:playHideAnim( ... )
		local actions = CCArray:create()

		actions:addObject(CCScaleTo:create(0.1,self.scaleX * 1.2,self.scaleY * 1.2))
		actions:addObject(CCScaleTo:create(0.2,0,0))

		self:runAction(CCSequence:create(actions))
	end


	anim:addChild(iconAnim)
	anim:addChild(arrowAnim)

	anim:setVisible(false)
	function anim:play( callback )
		if activityIcon.isDisposed then
			if callback then
				callback()
			end
			return
		end
		self:setVisible(true)

		local bounds = activityIcon:getGroupBounds()
		local localPos = self:convertToNodeSpace(ccp(bounds:getMidX(),bounds:getMidY()))
		iconAnim:setPosition(localPos)

		local iconBounds =  iconAnim:getGroupBounds()
		iconAnim:setScaleX(bounds.size.width/iconBounds.size.width)
		iconAnim:setScaleY(bounds.size.height/iconBounds.size.height)
		
		iconAnim.scaleX = iconAnim:getScaleX()
		iconAnim.scaleY = iconAnim:getScaleY()
		iconAnim:playShowAnim()

		local t = 10/24

		local actions = CCArray:create()
		actions:addObject(CCMoveTo:create(t,localPos))
		actions:addObject(CCCallFunc:create(function( ... )
			self:setVisible(false)
			iconAnim:playHideAnim()
			if callback then
				callback()
			end
		end))
		arrowAnim:runAction(CCSequence:create(actions))

		local actions = CCArray:create()
		actions:addObject(CCFadeTo:create(t,255 * 0.3))
		actions:addObject(CCScaleTo:create(t, 0.2))
		arrowAnim:runAction(CCSpawn:create(actions))

	end

	return anim
end

function DTAnimation:playAnim(parentPanel)
	local anim = CocosObject:create()

	local icon = nil
	if DTActivityManager.getInstance():getTriggerGoldChest() then
		icon = ArmatureNode:create("dt_animation/goldenbox")
	elseif DTActivityManager.getInstance():getTriggerSilverChest() then
		icon = ArmatureNode:create("dt_animation/silverbox")
	end

	if icon then
		icon:setPositionX(160)
		icon:setPositionY(-850)
		anim:addChild(icon)

		local moveAnim = self:createMoveAnim()
		if moveAnim then
			moveAnim:setPositionX(343)
			moveAnim:setPositionY(-980)
			parentPanel.ui:addChild(moveAnim)
		end
		icon:addEventListener(ArmatureEvents.COMPLETE, function ()
			icon:removeFromParentAndCleanup(true)
			if moveAnim then
				moveAnim:play()
			end
		end)
		icon:playByIndex(0)

		parentPanel.ui:addChild(anim)
	end
	DTActivityManager.getInstance():reset()
end
