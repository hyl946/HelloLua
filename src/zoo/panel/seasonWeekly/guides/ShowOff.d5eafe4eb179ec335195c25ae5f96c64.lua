local ShowOff = class(BasePanel)
function ShowOff:create(offset)
	local panel = ShowOff.new()
	panel:init(offset)
	return panel
end

function ShowOff:init(offset)
	self.offset = offset

	self.ui = Layer:create()
	BasePanel.init(self, self.ui)

	self.ui:runAction(CCCallFunc:create(function() self:runAnimation() end))
end

function ShowOff:runAnimation()
	local vSize = Director:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local pos = self.ui:convertToNodeSpace(ccp(visibleOrigin.x, visibleOrigin.y))

	local mask = LayerColor:create()
	mask:changeWidthAndHeight(vSize.width, vSize.height)
	mask:setColor(ccc3(0, 0, 0))
	mask:setOpacity(180)
	mask:setTouchEnabled(true, 0, true)
	mask:setPosition(pos)

	self.ui:addChild(mask)

	self.mask = mask

	self:adjustMask()

	local touchDelay = 4
	local arr = CCArray:create()
	self.ui:runAction(CCSequence:createWithTwoActions(
		CCDelayTime:create(touchDelay), 
		CCCallFunc:create(function()
			self:close()
		end
		)))

	-- anim
    local anim = ArmatureNode:create("2017SummerWeekly/interface/guideShowOff", true)
	if not anim then return end
    anim:playByIndex(0, 1)

	local offset = self.ui:convertToNodeSpace(self.offset)
	offset = ccp(offset.x - 356, offset.y + 690)
	anim:setPosition(ccp(offset.x, offset.y))
    self.ui:addChild(anim)
end

function ShowOff:close()
	if not self.isDisposed then
		self:removeFromParentAndCleanup(true)
	end
end

function ShowOff:adjustMask( ... )
	local wSize = Director:sharedDirector():getWinSize()
	local pos1 = self.ui:convertToNodeSpace(ccp(0, 0))
	local pos2 = self.ui:convertToNodeSpace(ccp(wSize.width, wSize.height))
	self.mask:changeWidthAndHeight(pos2.x - pos1.x, pos2.y - pos1.y)
	self.mask:setPosition(ccp(pos1.x, pos1.y))


end

return ShowOff