

require "zoo.baseUI.BaseUI"

---------------------------------------------------
-------------- MoleWeeklyMoveOrTimeCounter
---------------------------------------------------

assert(not MoleWeeklyMoveOrTimeCounterType)
MoleWeeklyMoveOrTimeCounterType = {
	MOVE_COUNT	= 1,
	TIME_COUNT	= 2
}

assert(not MoleWeeklyMoveOrTimeCounter)
assert(BaseUI)

local MoleWeeklyMoveOrTimeCounter = class(BaseUI)

local function shakeObject( sprite, rotation )
	if sprite.isShaking then return false end

    sprite:stopAllActions()
    sprite:setRotation(0)

	sprite.isShaking = true

    local original = sprite.original
    if not original then
    	original = sprite:getPosition()
    	sprite.original = {x=original.x, y=original.y}
	end
    sprite:setPosition(ccp(original.x, original.y))

    local array = CCArray:create()
    local direction = 1
    if math.random() > 0.5 then direction = -1 end

    rotation = rotation or 4
    local startRotation = direction * (math.random() * 0.5 * rotation + rotation)
    local startTime = 0.35

    local function onShakeFinish()
    	sprite.isShaking = false
    end

    array:addObject(CCSpawn:createWithTwoActions(CCRotateTo:create(startTime*0.3, startRotation), CCMoveBy:create(0.05, ccp(0, 6))))
    array:addObject(CCSpawn:createWithTwoActions(CCRotateTo:create(startTime, -startRotation*2), CCMoveBy:create(0.05, ccp(0, -6))))
    array:addObject(CCRotateTo:create(startTime, startRotation * 1.5))
    array:addObject(CCRotateTo:create(startTime, -startRotation))
    array:addObject(CCRotateTo:create(startTime, startRotation))
    array:addObject(CCRotateTo:create(startTime, -startRotation*0.5))
    array:addObject(CCRotateTo:create(startTime, 0))
    array:addObject(CCCallFunc:create(onShakeFinish))

    sprite:runAction(CCSequence:create(array))
    return true
end
function MoleWeeklyMoveOrTimeCounter:shake()
	shakeObject(self, 2)
end

function MoleWeeklyMoveOrTimeCounter:stopShaking()
	if self.counterType == MoleWeeklyMoveOrTimeCounterType.TIME_COUNT 
			and not self.isShaking then
		return
	end
	self:stopAllActions()
	self:setRotation(0)
	self.isShaking = false
end

function MoleWeeklyMoveOrTimeCounter:init(panelStyle, levelId, counterType, count, ...)
	self.oldString = ''
	assert(type(levelId) == "number")
	assert(counterType == MoleWeeklyMoveOrTimeCounterType.MOVE_COUNT or counterType == MoleWeeklyMoveOrTimeCounterType.TIME_COUNT)
	assert(type(count) == "number")
	assert(#{...} == 0)

	-- Get UI Resource
	self.ui = ResourceManager:sharedInstance():buildGroup(panelStyle)
	assert(self.ui)
	local function onTouchBegin(evt) 
		self:shake()
		
		if DiffAdjustQAToolManager:getToolsEnabled() then

			DiffAdjustQAToolManager:openPanel()
		end
	end

	--[[
	local function onTouchEnd(evt) 
		local nowTime = os.time()
  		if nowTime - self.onTouchBeginTime > 1 then
  			if MaintenanceManager:getInstance():isEnabled("QAInLevelTools") then
		      local testui = DiffAdjustQAToolPanel:create()
		      testui:popout()
		    end
  		end
	end
	]]

	local uisize = self.ui:getGroupBounds().size
	local uipos = self.ui:getPosition()
	self.ui:setPosition(ccp(uipos.x-uisize.width/2, uipos.y))
	self.ui:ad(DisplayEvents.kTouchBegin, onTouchBegin)
	-- self.ui:ad(DisplayEvents.kTouchEnd, onTouchEnd)
	self.ui:setTouchEnabled(true)

	-- Init Base Class
	BaseUI.init(self, self.ui)

	-- ----------------
	-- Get UI Resource
	-- -----------------
	self.msgLabel		= self.ui:getChildByName("msgLabel")

	assert(self.msgLabel)

	self.bgHighlight = self.ui:getChildByName("bgHighlight")
	if self.bgHighlight then
		self.bgHighlight:setVisible(false)
	end

	self.bg = self.ui:getChildByName('bg')

	-- -------
	-- Data
	-- -------
	self.counterType	= counterType
	self.count		= count
	self.levelId		= levelId
	self.fntFile		= "fnt/steps_cd.fnt"

	-------------------
	-- Create UI Component
	-- --------------------
	
	-- Center MonospaceBMLabel
	self.label = false
	if self.counterType == MoleWeeklyMoveOrTimeCounterType.MOVE_COUNT then
		self.label	= LabelBMMonospaceFont:create(60, 70, 36, self.fntFile)
		self.label:setPositionY(-154 + 68)
	else
		assert(false)
	end

	self.label.setToParentCenterHorizontal = function (context)
		local parentSize = self.bg:getGroupBounds().size

		-- Get Self Size
		local selfSize = context:getGroupBounds().size

		-- Center Pos
		local deltaWidth = parentSize.width - selfSize.width
		local halfDeltaWidth = deltaWidth / 2

		-- Set Self Posiiton
		local oldAnchorPoint = context:getAnchorPoint()
		context:setAnchorPointWhileStayOriginalPosition(ccp(0,0))
		context:setPositionX(halfDeltaWidth)
		context:setAnchorPointWhileStayOriginalPosition(ccp(oldAnchorPoint.x, oldAnchorPoint.y))
	end

	self.ui:addChild(self.label)
	self.label:setAnchorPoint(ccp(0,1))

	-- -------------
	-- Update UI
	-- ------------

	if self.counterType == MoleWeeklyMoveOrTimeCounterType.MOVE_COUNT then
		local msgLabelTxtKey 	= "move.or.time.counter.step.txt"
		local msgLabelTxtValue	= Localization:getInstance():getText(msgLabelTxtKey, {})
		self.msgLabel:setString(msgLabelTxtValue)
		self:setCount(self.count)
	end
end

function MoleWeeklyMoveOrTimeCounter:dispose()
	if self.ui then
		self.ui:rma()
		self.ui = nil
	end
	BaseUI.dispose(self)
end

function MoleWeeklyMoveOrTimeCounter:setCount(count, playAnim, ...)
	assert(count)
	assert(#{...} == 0)

	self.count	= math.floor(count)
	self:updateView(playAnim)
end

function MoleWeeklyMoveOrTimeCounter:setInfinite()
	self.label:setString("∞")
end

----------------------------------
---------- Update View
----------------------------------

function MoleWeeklyMoveOrTimeCounter:updateView(playAnim, ...)
	assert(#{...} == 0)

	if self.counterType == MoleWeeklyMoveOrTimeCounterType.MOVE_COUNT then
		self:updateCountMoveView(playAnim)
	elseif self.counterType == MoleWeeklyMoveOrTimeCounterType.TIME_COUNT then
		self:updateCountTimeView(playAnim)
	else 
		assert(false)
	end
end

function MoleWeeklyMoveOrTimeCounter:updateCountTimeView(playAnim, ...)
	assert(#{...} == 0)
	-- Treate self.count As Second 
	-- Convert It To Minute
	--
	local minute = math.floor(self.count / 60)
	local second	= self.count - minute * 60

	if second < 10 then
		second = "0" .. second
	end
	
	local minuteString = false
	
	self:animateString(tostring(minute) .. ":" .. tostring(second), false)
end

function MoleWeeklyMoveOrTimeCounter:updateCountMoveView(playAnim, ...)
	assert(#{...} == 0)

	if self.isPlayAddMovesEffect then
		return
	end

	if self.addEffect then
		self.isPlayAddMovesEffect = true
		self:playAddMovesEffect(tonumber(self.oldString),self.count,function( ... )
			self:animateString(tostring(self.count), false)
			self.isPlayAddMovesEffect = false
		end)
	else
		self:animateString(tostring(self.count), true)
	end
end

function MoleWeeklyMoveOrTimeCounter:fadeOutLabel()
	if self.isDisposed then return end
	
	local beginTime, endTime = 0.15, 0.3
	
	local old = self.label:copyToCenterLayer()
	local function onAnimationFinish() 
		if self.isDisposed then return end
		old:removeFromParentAndCleanup(true) 
	end
	
	local removeArray = CCArray:create()
	removeArray:addObject(CCScaleTo:create(beginTime, 1.6))
	removeArray:addObject(CCScaleTo:create(endTime, 0))
	removeArray:addObject(CCCallFunc:create(onAnimationFinish))
	local oldIndex = self.ui:getChildIndex(self.label)
	self.ui:addChildAt(old, oldIndex)
	old:runAction(CCSequence:create(removeArray))

	local label = old:getChildByName("label")
	local charsLabel = label.charsLabel
	if charsLabel and #charsLabel > 0 then
		for i,v in ipairs(charsLabel) do
			v:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(beginTime), CCFadeOut:create(endTime)))
		end
	end
end
function MoleWeeklyMoveOrTimeCounter:fadeInLabel(delayTime)
	if self.isDisposed then return end

	delayTime = delayTime or 0.2
	local endTime = 0.3
	
	local old = self.label:copyToCenterLayer()
	old:setScale(1.6)
	local function onAnimationFinish() 
		if self.isDisposed then return end
		self.label:setVisible(true)
		old:removeFromParentAndCleanup(true) 
	end

	local removeArray = CCArray:create()
	removeArray:addObject(CCDelayTime:create(delayTime))
	removeArray:addObject(CCScaleTo:create(endTime, 1))
	removeArray:addObject(CCCallFunc:create(onAnimationFinish))
	local oldIndex = self.ui:getChildIndex(self.label)

	self.ui:addChild(old)
	old:runAction(CCSequence:create(removeArray))

	local label = old:getChildByName("label")
	local charsLabel = label.charsLabel
	if charsLabel and #charsLabel > 0 then
		for i,v in ipairs(charsLabel) do
			v:setOpacity(0)
			v:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delayTime), CCFadeIn:create(endTime)))
		end
	end
end
function MoleWeeklyMoveOrTimeCounter:animateString( newString, animate )
	if self.isDisposed then return end

	local playAnimation = animate
	-- local playAnimation = true
	-- if self.counterType == MoleWeeklyMoveOrTimeCounterType.TIME_COUNT then playAnimation = false end

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

function MoleWeeklyMoveOrTimeCounter:create(panelStyle, levelId, counterType, count, ...)
	assert(type(levelId) == "number")
	assert(counterType == MoleWeeklyMoveOrTimeCounterType.MOVE_COUNT or counterType == MoleWeeklyMoveOrTimeCounterType.TIME_COUNT)
	assert(type(count) == "number")
	assert(#{...} == 0)

	local newCounter = MoleWeeklyMoveOrTimeCounter.new()
	newCounter:init(panelStyle, levelId, counterType, count)
	return newCounter
end

function MoleWeeklyMoveOrTimeCounter:setStageNumber(stageNumber)
	local text = ""
	if type(stageNumber) == 'number' and stageNumber >= 0 then
		text = Localization:getInstance():getText('move.or.time.counter.next.stage', {num = stageNumber})
	elseif type(stageNumber) == 'string' and stageNumber == 'infinite' then
		text = Localization:getInstance():getText('move.or.time.counter.tip.endless.stage')
	end
	self.msgLabel:setString(text)
end


function MoleWeeklyMoveOrTimeCounter:playAddMovesEffect( from,to,callback )
	local secondFrame = 24
	local numMoveFrame = 5

	if (tonumber(to) or 0) - (tonumber(from) or 0) >= 15 then
		numMoveFrame = 3
	end

	local actions = CCArray:create()
	actions:addObject(CCScaleTo:create(1/secondFrame,1.05,1.05))
	actions:addObject(CCScaleTo:create(1/secondFrame,1.00,1.00))
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
		local label = LabelBMMonospaceFont:create(60, 70, 36, "fnt/pre_prop.fnt")
		
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

return MoleWeeklyMoveOrTimeCounter