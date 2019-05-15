local UIHelper = require 'zoo.panel.UIHelper'
local FindingTheWayUI = {}
local FTWLocalLogic = require 'zoo.localActivity.FindingTheWay.FindingTheWayLocalLogic'

local function commonAnimLogic( anim )
	-- body
	function anim:show( callback )
		if self.isDisposed then return end
		if not self.hide_pos then return end
		if not self.show_pos then return end
		self:stopAllActions()
		self:runAction( CCSequence:createWithTwoActions(  CCMoveTo:create(0.2, self.show_pos), CCCallFunc:create(callback)  ))
	end

	function anim:hide( callback )
		if self.isDisposed then return end
		if not self.hide_pos then return end
		if not self.show_pos then return end
		self:stopAllActions()
		self:runAction( CCSequence:createWithTwoActions(  CCMoveTo:create(0.2, self.hide_pos), CCCallFunc:create(callback)  ))
	end
end

function FindingTheWayUI:createSuccessTitle( num )
	local anim = UIHelper:createArmature2('skeleton/finding_the_way', 'package.anim.ftw/levelTop')
	local numberLabel = BitmapText:create("x" .. num, "fnt/target_remain2.fnt")
	local con = anim:getCon('holder')
	con:addChild(numberLabel.refCocosObj)
	-- numberLabel:setScale(7)
	numberLabel:setPosition(ccp(150, 50))
	numberLabel:setAnchorPoint(ccp(0, 0.5))
	numberLabel:setScale(1.2)
	numberLabel:dispose()

	return anim

end

function FindingTheWayUI:createAddLevelUI(levelId)
	local anim = UIHelper:createArmature2('skeleton/finding_the_way', 'package.anim.ftw/addLevel')
	local numberLabel = BitmapText:create("x" .. FTWLocalLogic:getFunnyPropNum(levelId), "fnt/target_remain2.fnt")
	numberLabel:setScale(1.2)
	numberLabel:setAnchorPoint(ccp(0, 0.5))
	numberLabel:setPositionY(38.3/2 - 9)
	numberLabel:setPositionX(-7)
	local holder = anim:getCon('holder')
	holder:addChild(numberLabel.refCocosObj)
	numberLabel:dispose()
	commonAnimLogic(anim)
	return anim
end

function FindingTheWayUI:createAddStarUI()
	local anim = UIHelper:createArmature2('skeleton/finding_the_way', 'package.anim.ftw/addStar')

	local holder = anim:getCon('holder')
	local float_holder = anim:getCon('float_holder')


	local numberLabel = BitmapText:create("x18", "fnt/target_remain2.fnt")
	local floatNumberLabel = BitmapText:create("+3", "fnt/shengxingchanzi.fnt")

	holder:addChild(numberLabel.refCocosObj)
	float_holder:addChild(floatNumberLabel.refCocosObj)

	numberLabel:setScale(1.2)
	numberLabel:setAnchorPoint(ccp(0, 0.5))
	numberLabel:setPositionY(38.3/2 - 9)
	numberLabel:setPositionX(-7)


	-- floatNumberLabel:setScale(0.8)
	floatNumberLabel:setAnchorPoint(ccp(0.5, 0.5))
	floatNumberLabel:setPositionXY(2.35 + 25,  40)

	function anim:playAnim( baseNum, deltaNum, startWorldPos, callback )
		if self.isDisposed then return end
		anim:playByIndex(0, 1)
		anim:rma()
		anim:ad(ArmatureEvents.COMPLETE, function ( ... )
			if self.isDisposed then return end
			if callback then callback() end
		end)
		numberLabel:setText('x' .. baseNum)
		numberLabel:setScaleX(math.min(1,  55 / numberLabel:getContentSize().width ))
		floatNumberLabel:setText('+' .. deltaNum)


		numberLabel:setNumWithAnim(baseNum + deltaNum, 1)

		local counter = math.min(deltaNum, 8)

		for i = 1, math.min(deltaNum, 8) do
			self:_flyProp(startWorldPos)
		end
	end

	local oldDispose = anim.dispose

	function anim:dispose( ... )
		oldDispose(self, ...)
		numberLabel:dispose()
		floatNumberLabel:dispose()
	end

	function anim:_flyProp( startWorldPos, callback )
		if self.isDisposed then return end
		-- body
		local sp = Sprite:createWithSpriteFrameName('package.ftw.cm/prop0000')
		sp:setAnchorPoint(ccp(0.5, 0.5))
		anim:addChild(sp)

		local unit_scale = 0.5
		local s1 = 35/70
		local s2 = 115/70
		local s3 = 100/70
		local s4 = 1

		local pos = anim:convertToNodeSpace(startWorldPos)
		sp:setPositionXY(pos.x + (math.random() - 0.5) * 80, pos.y + (math.random() - 0.5) * 80)

		local array_scale = CCArray:create()
		array_scale:addObject(CCScaleTo:create(6/30, s2 * unit_scale, s2 * unit_scale))
		array_scale:addObject(CCScaleTo:create(10/30, s3 * unit_scale, s3 * unit_scale))
		array_scale:addObject(CCScaleTo:create(9/30, s4 * unit_scale, s4 * unit_scale))

		local array = CCArray:create()
		sp:setScale(unit_scale * s1)

		array:addObject(CCSpawn:createWithTwoActions(
			CCJumpTo:create(0.5, ccp(-60, 30), 100 + math.random() * 32, 1),
			CCSequence:create(array_scale)
		))

		array:addObject(CCCallFunc:create(function ( ... )
			if self.isDisposed then return end
			if sp and (not sp.isDisposed) then
				sp:removeFromParentAndCleanup(true)
			end
			sp = nil
			if callback then callback() end
		end))
		sp:runAction(CCSequence:create(array))
	end
	commonAnimLogic(anim)

	return anim
end

return FindingTheWayUI