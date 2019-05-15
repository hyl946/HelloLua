
LimitItemGuidePanel = class(BasePanel)

function LimitItemGuidePanel:create( reward )
	local panel = LimitItemGuidePanel.new()
	panel:loadRequiredResource("ui/panel_limit_guide.json")
	panel:init(reward)
	return panel
end

function LimitItemGuidePanel:init( reward )
	self.ui = self:buildInterfaceGroup("panel")
	BasePanel.init(self,self.ui)

	local visibleSize =  Director:sharedDirector():getVisibleSize()

	local darkLayer = LayerColor:create()
	darkLayer:setOpacity(255 * 0.83)
	darkLayer:setContentSize(visibleSize)
	darkLayer:setPositionY(-visibleSize.height)
	self:addChildAt(darkLayer,0)

	local itemId = ItemType:getRealIdByTimePropId(reward.itemId)
	local num = reward.num

	local bubble = self.ui:getChildByName("bubble")

	local bubbleSprite = Sprite:createEmpty()
	bubbleSprite:setPositionX(bubble:getPositionX())
	bubbleSprite:setPositionY(bubble:getPositionY())
	bubbleSprite:setCascadeOpacityEnabled(true)
	self.ui:addChild(bubbleSprite)
	for k,v in pairs(bubble:getChildrenList()) do
		v:removeFromParentAndCleanup(false)
		v:setCascadeOpacityEnabled(true)
		bubbleSprite:addChild(v)
	end

	local icon = ResourceManager:sharedInstance():buildItemSprite(itemId)
	icon:setCascadeOpacityEnabled(true)
	icon:setAnchorPoint(ccp(0.5,0.5))
	bubbleSprite:addChild(icon)

	local numLabel = BitmapText:create("x" .. num, "fnt/event_default_digits.fnt")
	numLabel:setAnchorPoint(ccp(0,0.5))
	numLabel:setPositionX(10)
	numLabel:setPositionY(-30)
	bubbleSprite:addChild(numLabel)

	local titleLabel = BitmapText:create(localize("prop.name." .. itemId) ,"fnt/prop_optimize.fnt")
	titleLabel:setPositionY(110)
	titleLabel:setPositionX(-5)
	titleLabel:setAnchorPoint(ccp(0.5,0))
	bubbleSprite:addChild(titleLabel)

	self.bubble = bubbleSprite
	self.shine = self.ui:getChildByName("shine")

	self.ui:setPositionX(visibleSize.width/2)
	self.ui:setPositionY(-visibleSize.height/2)

	FrameLoader:loadArmature( "skeleton/props_tutorial_animation" )
	local anim = CommonSkeletonAnimation:createPropsTutorialAnimation(itemId)
	anim:setPositionX(-330/2)
	anim:setPositionY(236/2)

	self.propsAnim = Sprite:createEmpty()
	self.propsAnim:setCascadeOpacityEnabled(true)
	self.propsAnim:addChild(anim)
	self.propsAnim:setPositionY(-210)
	self.ui:addChild(self.propsAnim)

	function self.propsAnim:playAnimation( ... )
		anim:playAnimation()
	end

	self:runAnimation()

	self:runAction(CCSequence:createWithTwoActions(
		CCDelayTime:create(6),
		CCCallFunc:create(function( ... )
			if self.callback then
				self.callback()
			end
			self:remove()
		end)
	))

	self.ui:setTouchEnabled(true)
	function self.ui:hitTestPoint( worldPosition,useGroupTest )
		return true
	end
	self.ui:addEventListener(DisplayEvents.kTouchTap,function( ... )
		if self.callback then
			self.callback()
		end
		self:remove()
	end)
end

function LimitItemGuidePanel:runAnimation( ... )
	local actions = CCArray:create()

	self.bubble:setOpacity(255 * 0.05)
	self.bubble:setScale(0.674)

	actions:addObject(CCSpawn:createWithTwoActions(
		CCFadeIn:create(5/24),
		CCScaleTo:create(5/24,1.256,1.256)
	))
	actions:addObject(CCScaleTo:create(3/24,1.0,1.0))

	self.bubble:runAction(CCSequence:create(actions))

	-- self.bubble:setVisible(false)

	-- self.shine:setVisible(false)

	local shine1 = self.shine:getChildByName("1")
	local shine2 = self.shine:getChildByName("2")
	local shine3 = self.shine:getChildByName("3")

	for k,v in pairs({shine1,shine2,shine3}) do
		v:setAnchorPoint(ccp(0.5,0.5))
		v:setPositionX(0)
		v:setPositionY(0)
	end

	shine1:setScale(0)
	shine1:runAction(CCSpawn:createWithTwoActions(
		CCScaleTo:create(16/24,1,1),
		CCFadeTo:create(16/24,255 * 0.26)
	))

	shine2:setOpacity(255*0.45)
	shine2:runAction(CCRepeatForever:create(
		CCRotateBy:create(115/24,360)
	))

	shine3:runAction(CCSpawn:createWithTwoActions(
		CCFadeOut:create(7/24),
		CCScaleTo:create(7/24,2,2)
	))

	self.shine:runAction(CCScaleTo:create(7/24,2,2))

	self.propsAnim:setOpacity(255 * 0.05)
	self.propsAnim:setScale(0.945)
	local actions = CCArray:create()
	actions:addObject(CCSpawn:createWithTwoActions(
		CCFadeTo:create(5/24,255),
		CCScaleTo:create(5/24,1.05,1.05)
	))
	actions:addObject(CCScaleTo:create(4/24,1.00,1.00))
	actions:addObject(CCCallFunc:create(function( ... )
		self.propsAnim:playAnimation()
	end))
	self.propsAnim:runAction(CCSequence:create(actions))

end

function LimitItemGuidePanel:setFinishCallback( callback )
	self.callback = callback
end


function LimitItemGuidePanel:popout( ... )
	PopoutManager:sharedInstance():add(self, false, false)
end

function LimitItemGuidePanel:remove( ... )
	PopoutManager:sharedInstance():remove(self)
end