
HideAndShowButton = class(BaseUI)

function HideAndShowButton:ctor()
end

function HideAndShowButton:init()
	BaseUI.init(self,self.ui)

	self:addChild(self.ui)
    self.reddot = ResourceManager:sharedInstance():buildGroup('home_scene_icon/common_res/icon_reddot_small')
	self.ui:addChild(self.reddot)
	self.reddot:setPosition(ccp(35, 30))
	self:setRedDotVisible(false)
end

function HideAndShowButton:setRedDotVisible(isVisible)
	if self.reddot then 
		self.reddot:setVisible(isVisible)
	end
end

function HideAndShowButton:ad(eventName, listener, context)
	self:setEnable(true)
	self.ui:addEventListener(eventName, listener, context)
end

function HideAndShowButton:getGroupBounds()
	return self.ui:getGroupBounds()
end

function HideAndShowButton:setEnable(isEnable)
	if not isEnable then isEnable = false end 
	self.ui:setTouchEnabled(isEnable, 0, true)
	self.ui:setButtonMode(isEnable)
end

function HideAndShowButton:setVisible(isVisible)
	if not isVisible then isVisible = false end
	self.ui:setVisible(isVisible)	
end

function HideAndShowButton:getPositionInWorldSpace()
	return self.ui:getPositionInWorldSpace()
end

function HideAndShowButton:playAni(endCallback)
	local seqArr = CCArray:create()
	seqArr:addObject(CCScaleTo:create(2/24, 0.5, 2))
	seqArr:addObject(CCScaleTo:create(2/24, 1))
	seqArr:addObject(CCScaleTo:create(1/24, 0.8))
	seqArr:addObject(CCScaleTo:create(1/24, 1.1))
	seqArr:addObject(CCScaleTo:create(2/24, 1))
	seqArr:addObject(CCDelayTime:create(2/24))
	seqArr:addObject(CCCallFunc:create(function ()
		if endCallback then 
			endCallback()
		end
	end))
	self.ui:runAction(CCSequence:create(seqArr))
end

function HideAndShowButton:getFlyToPosition()
	return self:getPositionInWorldSpace()
end

function HideAndShowButton:getFlyToSize()
	local size = self.ui:getGroupBounds().size
	size.width, size.height = size.width / 2, size.height / 2
	return size
end

function HideAndShowButton:removeTip()
	if self.tip and not self.tip.isDisposed then
		self.tip:removeFromParentAndCleanup(true)
		self.tip = nil
	end
end

function HideAndShowButton:playtip(tipStr)
end

function HideAndShowButton:create(ui)
	local btn = HideAndShowButton.new()
	btn.ui = ui
	btn:init()
	return btn
end