

SpringMoveCounter = class(MoveOrTimeCounter)

function SpringMoveCounter:create( panelStyle, levelId, counterType, count )
	local counter = SpringMoveCounter.new()
	counter:init(panelStyle, levelId, counterType, count)
	return counter
end

function SpringMoveCounter:init(panelStyle, levelId, counterType, count)
	self.oldString = ''

	-- Get UI Resource
	self.ui = Layer:create()
	
	-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(
	-- 	SpriteUtil:getRealResourceName("flash/spring2017/in_game.plist")
	-- )

	self.bg = Sprite:createWithSpriteFrameName("nationday2017_movecounter_bg")
	self.bg:setAnchorPoint(ccp(0,1))
	-- self.bg:setPositionX(-self.bg:getContentSize().width/2)
	self.bg:setPositionY(-30)
	self.ui:addChild(self.bg)
	
	local function onTouchBegin(evt) 
		self:shake()
	end
	local uisize = self.ui:getGroupBounds().size
	local uipos = self.ui:getPosition()
	self.ui:setPosition(ccp(uipos.x-uisize.width/2, uipos.y))
	self.ui:ad(DisplayEvents.kTouchBegin, onTouchBegin)
	self.ui:setTouchEnabled(true)

	-- Init Base Class
	BaseUI.init(self, self.ui)


	self.counterType	= counterType
	self.count		= count
	self.levelId		= levelId
	self.fntFile		= "fnt/steps_cd.fnt"
	
	-- Center MonospaceBMLabel
	self.label	= LabelBMMonospaceFont:create(60, 70, 36, self.fntFile)
	self.label:setPositionY(-100)

	local bgWidth = self.bg:getContentSize().width
	function self.label:setToParentCenterHorizontal( ... )
		local labelWidth = self:getContentSize().width
		self:setPositionX(bgWidth/2 -labelWidth/2)
	end

	self.ui:addChild(self.label)
	self.label:setAnchorPoint(ccp(0,1))

	self:setCount(self.count)
end


function SpringMoveCounter:setStageNumber(stageNumber)

end

function SpringMoveCounter:shake()
    self:stopAllActions()
    self:setRotation(0)
    return true
end

function SpringMoveCounter:stopShaking()
	self.isShaking = false
end