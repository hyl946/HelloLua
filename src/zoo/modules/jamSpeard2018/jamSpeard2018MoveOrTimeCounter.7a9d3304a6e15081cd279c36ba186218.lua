
JamSpeard2018MoveOrTimeCounter = class(MoveOrTimeCounter)

function JamSpeard2018MoveOrTimeCounter:create(panelStyle, levelId, counterType, count)
	local newCounter = JamSpeard2018MoveOrTimeCounter.new()
	newCounter:init(panelStyle, levelId, counterType, count)
	return newCounter
end

function JamSpeard2018MoveOrTimeCounter:init(panelStyle, levelId, counterType, count)
	self.oldString = ''
	self.ui = ResourceManager:sharedInstance():buildGroup(panelStyle)
	local function onTouchBegin(evt) 
		self:shake()
	end
	local uisize = self.ui:getGroupBounds().size
	local uipos = self.ui:getPosition()
	self.ui:setPosition(ccp(uipos.x-uisize.width/2, uipos.y))
	self.ui:ad(DisplayEvents.kTouchBegin, onTouchBegin)
	self.ui:setTouchEnabled(true)
	BaseUI.init(self, self.ui)
	self.bgHighlight = self.ui:getChildByName("bgHighlight")
	if self.bgHighlight then
		self.bgHighlight:setVisible(false)
	end
	self.bg = self.ui:getChildByName('bg')

	self.counterType = counterType
	self.count = count
	self.levelId = levelId
	self.fntFile = "fnt/steps_cd.fnt"

	self.label = nil
	if self.counterType == MoveOrTimeCounterType.MOVE_COUNT then
		self.label	= LabelBMMonospaceFont:create(80, 90, 45, self.fntFile)
		self.label:setPositionY(-100)
--        self.label:setPositionX(80)
	else
		assert(false)
	end

    local bgWidth = 232
	self.label.setToParentCenterHorizontal = function (context)
		local labelWidth = context:getContentSize().width
		context:setPositionX( 75 - labelWidth/2 )
	end

	self.ui:addChild(self.label)
	self.label:setAnchorPoint(ccp(0,1))

	if self.counterType == MoveOrTimeCounterType.MOVE_COUNT then
		self:setCount(self.count)
	end

    self.label:setToParentCenterHorizontal()
end


function JamSpeard2018MoveOrTimeCounter:animateString( newString, animate )
	if self.isDisposed then return end

	local playAnimation = animate
	-- local playAnimation = true
	-- if self.counterType == MoveOrTimeCounterType.TIME_COUNT then playAnimation = false end

	if playAnimation then self:fadeOutLabel() end
	self.label:setString(newString)
	if string.len(self.oldString) ~= string.len(newString) then
		self.label:setToParentCenterHorizontal()
	end

	self.oldString = newString
	if playAnimation then
		self:fadeInLabel()
		self.label:setVisible(false)
	end
end


function JamSpeard2018MoveOrTimeCounter:playAddMovesEffect( from,to,callback )
	local secondFrame = 24
	local numMoveFrame = 5

	if (tonumber(to) or 0) - (tonumber(from) or 0) >= 15 then
		numMoveFrame = 3
	end

    local CurScale = self:getScale()

	local actions = CCArray:create()
	actions:addObject(CCScaleTo:create(1/secondFrame, CurScale*1.05,CurScale*1.05))
	actions:addObject(CCScaleTo:create(1/secondFrame, CurScale*1.00,CurScale*1.00))
	self.ui:runAction(CCTargetedAction:create(
		self.refCocosObj,
		CCSequence:create(actions)
	))

	local stencil = LayerColor:create()
	stencil:setContentSize(CCSizeMake(300,self.label:getContentSize().height))
	stencil:ignoreAnchorPointForPosition(false)
	stencil:setAnchorPoint(ccp(0,1))
	stencil:setPositionY(self.label:getPositionY())

	local clippingNode = ClippingNode.new(CCClippingNode:create(stencil.refCocosObj))
	stencil:dispose()
	self.ui:addChild(clippingNode)

	local function createLabel( ... )
		local label = LabelBMMonospaceFont:create(80, 90, 45, "fnt/pre_prop.fnt")
		
		local setString = label.setString
		label.setString = function( l,text )
			setString(l,text)

			self:animateString(text,false)

			label:setAnchorPoint(self.label:getAnchorPoint())
			label:setPositionX(self.label:getPositionX())
			label:setPositionY(self.label:getPositionY() - 8)
		end

		clippingNode:addChild(label)
		return label
	end

	local function runHighlightBgAnim( ... )
		if not self.bgHighlight then
			return
		end
		local actions = CCArray:create()
		actions:addObject(CCFadeTo:create(numMoveFrame/2/secondFrame,0.5 * 255))
		actions:addObject(CCFadeTo:create(numMoveFrame/2/secondFrame,1.0 * 255))
		self.bgHighlight:runAction(CCSequence:create(actions))
	end
	local function runShowHighlightBgAnim( ... )
		if not self.bgHighlight then
			return
		end
		local actions = CCArray:create()
		actions:addObject(CCShow:create())
		actions:addObject(CCFadeIn:create(3/secondFrame))
		self.bgHighlight:runAction(CCSequence:create(actions))
	end
	local function runHideHighlightBgAnim( ... )
		if not self.bgHighlight then
			return
		end
		local actions = CCArray:create()
		actions:addObject(CCDelayTime:create(3/secondFrame))
		actions:addObject(CCFadeOut:create(3/secondFrame))
		actions:addObject(CCHide:create())
		self.bgHighlight:runAction(CCSequence:create(actions))
	end

	local function runAddNumAnim( topSprite,bottomSprite,needPlayMove )
		if needPlayMove then
			topSprite:setVisible(false)
			local actions = CCArray:create()
			actions:addObject(CCCallFunc:create(function( ... )
				topSprite:setPositionY(topSprite:getPositionY() + 40)
			end))
			actions:addObject(CCDelayTime:create(1/secondFrame))
			actions:addObject(CCShow:create())
			actions:addObject(CCMoveBy:create((numMoveFrame - 1)/secondFrame,ccp(0,-40)))
			topSprite:runAction(CCSequence:create(actions))

			if bottomSprite then
				local actions = CCArray:create()
				actions:addObject(CCMoveBy:create((numMoveFrame - 1)/secondFrame,ccp(0,-40)))
				actions:addObject(CCHide:create())
				bottomSprite:runAction(CCSequence:create(actions))
			end
		end
	end
	local function runStarAnim( ... )
		local effect = PropsAnimation:createAdd3EffectAnim()
		local x = self.label:getPositionX() + self.label:getGroupBounds().size.width / 2
		local y = self.label:getPositionY() - self.label:getGroupBounds().size.height/2
		effect:setPositionX(x)
		effect:setPositionY(y)
		self.ui:addChild(effect)
		effect:play(11/secondFrame)
		effect:addEventListener(Events.kComplete,function( ... )
			effect:removeFromParentAndCleanup(true)
		end)		
	end

	local topAnimLabel = createLabel()
	local bottomAnimLabel = createLabel()

	local actions = CCArray:create()
	actions:addObject(CCCallFunc:create(function( ... )
		runShowHighlightBgAnim()

		runStarAnim()
	end))
	actions:addObject(CCDelayTime:create(3/secondFrame))
	for i=from+1,to do
		local topString = tostring(i)
		local bottomString = tostring(i-1)
		actions:addObject(CCCallFunc:create(function( ... )
			topAnimLabel:setString(topString)
			bottomAnimLabel:setString(bottomString)
			self.label:setString("")
		end))

		local topChars = topAnimLabel:iterateString(topString)
		local bottomChars = bottomAnimLabel:iterateString(bottomString)

		for i=#topChars,1,-1 do
			local needPlayMove = topChars[i] ~= bottomChars[i]
			actions:addObject(CCCallFunc:create(function( ... )
				local topCharSprite = topAnimLabel.charsLabel[i]
				local bottomCharSprite = bottomAnimLabel.charsLabel[i]
				runAddNumAnim(topCharSprite,bottomCharSprite,needPlayMove)
				runHighlightBgAnim()
			end))
		end
		actions:addObject(CCDelayTime:create(numMoveFrame/secondFrame))
	end
	actions:addObject(CCCallFunc:create(function( ... )
		runHideHighlightBgAnim()

		runStarAnim()
	end))
	actions:addObject(CCDelayTime:create(11/secondFrame))
	actions:addObject(CCCallFunc:create(function( ... )
		clippingNode:removeFromParentAndCleanup(true)
	end))
	actions:addObject(CCDelayTime:create(0))
	actions:addObject(CCCallFunc:create(function( ... )
		callback()
	end))

	self.ui:runAction(CCSequence:create(actions))
end