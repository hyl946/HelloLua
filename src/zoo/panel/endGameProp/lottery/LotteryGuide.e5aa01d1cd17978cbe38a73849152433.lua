local function skipButton(skipText, onTouch)
	local layer = LayerColor:create()
	layer:setOpacity(0)
	layer:changeWidthAndHeight(200, 80)
	layer:ignoreAnchorPointForPosition(false)
	-- layer:setPosition(ccp(0, vOrigin.y + vSize.height - 50))
	layer:setTouchEnabled(true, 0, true)
	layer:ad(DisplayEvents.kTouchTap, onTouch)
	layer:setOpacity(0)
	layer:setAnchorPoint(ccp(0, 0))
	layer:setColor(ccc3(136, 255, 136))


	local text = TextField:create(skipText, nil, 32)
	text:setPosition(ccp(50, 25))
	text:setColor(ccc3(136, 255, 136))
	text:setOpacity(0)
	text:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0), CCFadeIn:create(0)))
	text:setAnchorPoint(ccp(0, 0))
	layer:addChild(text)

	return layer
end


local LotteryGuide = class(BasePanel)

function LotteryGuide:create(clonedUI)
    local panel = LotteryGuide.new()
    panel:loadRequiredResource("ui/lottery_guide.json")
    panel:init(clonedUI)
    return panel
end

function LotteryGuide:init(clonedUI)
    local ui = self:buildInterfaceGroup("add.step.lottery.guide/g1")
	BasePanel.init(self, ui)
	self.ui:addChild(clonedUI)


	local handAnim = GameGuideAnims:handclickAnim(0, 0)
	self.ui:addChild(handAnim)

end

function LotteryGuide:_close()

	if self.isDisposed then return end

	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function LotteryGuide:setWorldPosition( pos )
	self.worldPos = pos
end

function LotteryGuide:popout()
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true

	local parent = self:getParent()
	if parent then
		local pos = parent:convertToNodeSpace(self.worldPos)
		self:setPosition(pos)
	end

	local skinButton = skipButton('跳过', function ( ... )

		self:_close()

		if self.onSkipCallback then
			self.onSkipCallback()
		end
	end)

	self.ui:addChild(skinButton)


	local vOrigin = Director:sharedDirector():getVisibleOrigin()

	local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
	layoutUtils.setNodeRelativePos(skinButton, layoutUtils.MarginType.kLEFT, -35)
	layoutUtils.setNodeRelativePos(skinButton, layoutUtils.MarginType.kTOP,  -10)

	local container = self:getParent()
	if container then
		container = container:getParent()
	end
	if container and container.darkLayer then
		container.darkLayer:setOpacity(200)
	end

end

function LotteryGuide:onCloseBtnTapped( ... )
    self:_close()
end

function LotteryGuide:setSkipCallback( onSkip )
	self.onSkipCallback = onSkip
end

function LotteryGuide:setNextCallback( onNext )
	self.onNextCallback = onNext
end



function LotteryGuide:createGuide2( ... )
	local panel = LotteryGuide.new()
    panel:loadRequiredResource("ui/lottery_guide.json")
    panel:initGuide2()
    return panel
end

function LotteryGuide:initGuide2( ... )
	-- body
	local ui = self:buildInterfaceGroup("add.step.lottery.guide/g2")
	BasePanel.init(self, ui)
	self.text = self.ui:getChildByName('text')
	self.text:setString('点击任意处继续')
end

function LotteryGuide:createSkipBtn( ... )
	-- body

	local skinButton = skipButton('跳过', function ( ... )
		if self.isDisposed then return end

		self:removeFromParentAndCleanup(true)

		if self.onSkipCallback then
			self.onSkipCallback()
		end
	end)

	self.ui:addChild(skinButton)


	local vOrigin = Director:sharedDirector():getVisibleOrigin()

	local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
	layoutUtils.setNodeRelativePos(skinButton, layoutUtils.MarginType.kLEFT, -35)
	layoutUtils.setNodeRelativePos(skinButton, layoutUtils.MarginType.kTOP,  -10)


end

function LotteryGuide:createTouchLayer( notClose, sx, sy , hitTest)
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	local mask = Layer:create()
	mask:changeWidthAndHeight(vSize.width / sx, vSize.height / sy)
	-- mask:setColor(ccc3(0, 0, 0))
	-- mask:setOpacity(0)
	self.ui:addChildAt(mask, 0)

	local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
	layoutUtils.setNodeRelativePos(mask, layoutUtils.MarginType.kLEFT, 0)
	layoutUtils.setNodeRelativePos(mask, layoutUtils.MarginType.kTOP,  0)

	mask:setTouchEnabled(true, 0, true, hitTest)
	mask:ad(DisplayEvents.kTouchTap, function ( ... )

		if self.isDisposed then return end

		if not notClose then
			self:removeFromParentAndCleanup(true)
		end

		if self.onNextCallback then
			self.onNextCallback()
		end
	end)
end





function LotteryGuide:createGuide3( ... )
	local panel = LotteryGuide.new()
    panel:loadRequiredResource("ui/lottery_guide.json")
    panel:initGuide3()
    return panel
end

function LotteryGuide:initGuide3( ... )
	-- body
	local ui = self:buildInterfaceGroup("add.step.lottery.guide/g3")
	BasePanel.init(self, ui)

	local handAnim = GameGuideAnims:handclickAnim(0, 0)
	self.ui:addChild(handAnim)

end



return LotteryGuide
