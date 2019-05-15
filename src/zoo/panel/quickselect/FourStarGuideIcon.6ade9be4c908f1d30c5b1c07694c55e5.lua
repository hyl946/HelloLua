require "zoo.panel.quickselect.FourStarGuidePanel"
FourStarGuideIcon = class(Layer)
FourStarGuideEvent = {
	kCloseAllStarGuidePanel = "closeAllStarGuidePanel",
	kReturnQuickSelectPanel = "returnQuickSelectPanel",
}

function FourStarGuideIcon:create( panel )
	-- body
	local s = FourStarGuideIcon.new()
	s:initLayer()
	s:init(panel)
	return s
end

function FourStarGuideIcon:init( panel )
	-- body
	self.panel = panel
	FrameLoader:loadArmature("skeleton/ladybug_four_star_guide_animation")
	local node = ArmatureNode:create("rgtr")
	self.mainAnimation = node
	self:addChild(node)
	self.mainAnimation:playByIndex(0, 1)
	local function animationCallback( ... )
		-- body
		self:addSelfAction()
	end
	self.mainAnimation:addEventListener(ArmatureEvents.COMPLETE, animationCallback)

	local function onTouchTap( evt )
		-- body
		self:onTouchTap()
	end

	self:setTouchEnabled(true, 0 , true)
	self:addEventListener(DisplayEvents.kTouchTap, onTouchTap)
end


function FourStarGuideIcon:addSelfAction( ... )
	-- body
	local arr = CCArray:create()
	arr:addObject(CCRotateTo:create(1/3, -6))
	arr:addObject(CCRotateTo:create(1/2, 0))
	arr:addObject(CCRotateTo:create(1/2, 4.3))
	arr:addObject(CCRotateTo:create(1, 0))
	local action = CCRepeatForever:create(CCSequence:create(arr))
	self.mainAnimation:runAction(action)
end

function FourStarGuideIcon:onTouchTap( ... )
	-- body
	DcUtil:fourStarGuideIconClick()
	self.panel:setVisible(false)

	local function onReturnCallback( evt )
		-- body
		self.panel:setVisible(true)
	end

	local function onCloseCallback( evt )
		-- body
		self.panel:onCloseBtnTapped()
	end

	local panel = FourStarGuidePanel:create()
	panel:popout()
	panel:addEventListener(FourStarGuideEvent.kReturnQuickSelectPanel, onReturnCallback)
	panel:addEventListener(FourStarGuideEvent.kCloseAllStarGuidePanel, onCloseCallback)
end

function FourStarGuideIcon:dispose( ... )
	-- body
	CocosObject.dispose(self)
	self.panel  = nil
end