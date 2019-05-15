
local ExtraNum = class(BasePanel)
function ExtraNum:create()
	local panel = ExtraNum.new()
	panel:init()
	return panel
end

function ExtraNum:onAddToStage( 	 )
	if self.isDisposed then return end



	local wSize = Director:sharedDirector():getWinSize()
	local pos1 = self:convertToNodeSpace(ccp(0, 0))
	local pos2 = self:convertToNodeSpace(ccp(wSize.width, wSize.height))
	self.ui:changeWidthAndHeight(pos2.x - pos1.x, pos2.y - pos1.y)
	self.ui:setPosition(ccp(pos1.x, pos1.y))
	self.anim:setPosition(ccp(120 - pos1.x, - pos1.y))
	-- CommonTip:showTip(tostring(pos1.y))
end

function ExtraNum:init()

	local touchDelay = 0.5
	local wSize = CCSizeMake(960, 1480)
	local mask = LayerColor:create()
	mask:changeWidthAndHeight(wSize.width, wSize.height)
	mask:setColor(ccc3(0, 0, 0))
	mask:setOpacity(180)
	mask:setPosition(ccp(0, -1480))
	mask:setTouchEnabled(true, 0, true)

	local arr = CCArray:create()
	mask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(touchDelay), CCCallFunc:create(beginSetTouch)))
	mask.layerSprite = layerSprite
	
	self.ui = mask

	self.ui.onAddToStage = function ( ... )

		self:onAddToStage()

	end

	BasePanel.init(self, self.ui)

	self:runAnimation()
end

function ExtraNum:runAnimation()
    local anim = ArmatureNode:create("2017SummerWeekly/interface/guideExtraNum", true)
    anim:playByIndex(0, 1)
    anim:setPosition(ccp(120, 1480))
    self.ui:addChild(anim)

	local contest = self
	local function onAnimFinished()
		local function onTouch(evt)
			contest:close()
		end
		self.ui:ad(DisplayEvents.kTouchTap, onTouch)
	end
	anim:addEventListener(ArmatureEvents.COMPLETE, onAnimFinished)
	self.anim = anim
end

function ExtraNum:close()
	if not self.isDisposed then
		self:removeFromParentAndCleanup(true)
		if self.closeCallback then
			self.closeCallback()
		end
	end
end

function ExtraNum:setCloseCallback( callback )
	self.closeCallback = callback
end

return ExtraNum