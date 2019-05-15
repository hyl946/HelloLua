local kStarFactor = 24 * 3.1415926 / 180
local kMaskBeginWidth = 17
local kMaskEndWidth = 50

ScoreProgressAnimation = class()

function ScoreProgressAnimation:create(scoreProgress, pos , levelId ,showStar4 )
	-- body
	local s = ScoreProgressAnimation.new()
	s:init(scoreProgress, pos , levelId ,showStar4 )
	s:moveTo(0)
	return s
end

function ScoreProgressAnimation:init( scoreProgress, pos ,levelId ,showStar4 )
	-- body
	self.levelId = levelId
	self.showStar4 = showStar4
	self.scoreProgress = scoreProgress
	self.parent = scoreProgress.parent
	self.basePos = pos
	local parent = scoreProgress.parent
	self.levelSkinConfig = GamePlaySceneSkinManager:getConfig(GamePlaySceneSkinManager:getCurrLevelType())
	local ladybug = ResourceManager:sharedInstance():buildBatchGroup("sprite", 
		self.levelSkinConfig.ladybugAnimation)

	self.kPropListScaleFactor = 1
	if __isWildScreen then  self.kPropListScaleFactor = 0.92 end
	ladybug:setScale(self.kPropListScaleFactor)

	parent.displayLayer[GamePlaySceneTopAreaType.kItemBatch]:addChild(ladybug)
	ladybug:setPosition(ccp(pos.x, pos.y))
	self.ladybug = ladybug

	self.scriptID = -1
  	self.progress = 0

	self.starLevel = 0
	self.star1 = self:createDarkStar("star_1", 1)
  	self.star2 = self:createDarkStar("star_2", 2)
  	self.star3 = self:createDarkStar("star_3", 3)
  	self.star4 = self:createDarkStar("star_4", 4)

  	self.crown = self.ladybug:getChildByName('crown')

  	self.star1:setAnchorPoint(ccp(0.5, 0.5))
  	self.star2:setAnchorPoint(ccp(0.5, 0.5))
  	self.star3:setAnchorPoint(ccp(0.5, 0.5))

    if self.star4 then
  	    self.star4:setAnchorPoint(ccp(0.5, 0.5))
    end

    if self.crown then
  	    self.crown:setAnchorPoint(ccp(0.5, 0.5))
    end

  	self.isActivity = ( GamePlaySceneSkinManager:getCurrLevelType() == GameLevelType.kFourYears or
        GamePlaySceneSkinManager:getCurrLevelType() == GameLevelType.kSummerFish )

    if self.crown then
  	    self.crown:setVisible(self.isActivity)
    end

  	self:initBg()
  	self:initAnimal()
  	self:initClippingProgress()

  	local pathNode = ladybug:getChildByName("path")
  	local offset = pathNode:getPosition()
  	local path = {}
  	for i,v in ipairs(pathNode.list) do
  		local p = v:getPosition()
  		path[i] = ccp(offset.x + p.x, offset.y + p.y)
  	end
  	pathNode:removeFromParentAndCleanup(true)

  	local spine = CardinalSpline.new(path, 0.25)
  	self.spine = spine

    self.fourStar_shining = self.ladybug:getChildByName('fourstar_shining')
    self.fourStar_shining:setVisible(false)
    self.fourthStar = self.ladybug:getChildByName('fourth_star')
    self.fourthStar:setVisible( false )
    if self.star4 then
    	 self.star4:setVisible( self.showStar4 )
    end
    

 --   self.fourthStar:setVisible( self.showStar4 )


    self.sunshine = self.ladybug:getChildByName('sunshine')
 --   self.sunshine:setVisible( self.showStar4 )
    self.sunshine:setVisible( false )

    self.sunshine:setAnchorPoint(ccp(0.5, 0.5))
    self.fourthStar:setAnchorPoint(ccp(0.5, 0.5))

    self.fourthStar:getChildByName('star_white'):setAnchorPoint(ccp(0.5, 1))
    self.fourthStar:getChildByName('star_normal'):setAnchorPoint(ccp(0.5, 1))

    self.leaf1 = self.ladybug:getChildByName('fourstar_leaves1')
    self.leaf2 = self.ladybug:getChildByName('fourstar_leaves2')
    self.leaf3 = self.ladybug:getChildByName('fourstar_leaves3')

    if self.leaf1 then
        self.leaf1:setVisible( false )
    end

    if self.leaf1 then
        self.leaf2:setVisible( false )
    end

    if self.leaf1 then
        self.leaf3:setVisible( false )
    end

    -- test
    -- local function test()
    --     self:playFourStarAnimation()
    -- end
    -- setTimeOut(test, 5)
end

function ScoreProgressAnimation:createDarkStar( textKey, starIndex )
	-- body
	local container = self.ladybug:getChildByName(textKey)

    if not container then
        return
    end

	container.starIndex = starIndex



	local function onTouchTap(evt) 

		local globalPosition = evt.globalPosition

		local touchIndex = starIndex

		local minDistance = nil

		for i= 1 ,4 do
			local starNode = self["star"..i]			
			if starNode and starNode:getParent() then
				local nodeParent = starNode:getParent()
				local posStar =  starNode:getPosition()
				local posInWorld	= nodeParent:convertToWorldSpace(ccp(posStar.x, posStar.y))
				local posDistance = ccpDistance( posInWorld , globalPosition )
				if minDistance == nil then
					touchIndex = i
					minDistance = posDistance
				end
				if posDistance < minDistance then
					touchIndex = i
					minDistance = posDistance
				end
			end
		end

		if 4 == touchIndex and false == self.showStar4  then
			return
		end

		if self.showStarScoreIndex == touchIndex then
			return
		end
		self.showStarScoreIndex = touchIndex

		local score = self["star"..touchIndex.."score"] or 0
		local dark = self["star"..touchIndex]
		local light = self["bigstar"..touchIndex]
		if light then dark = light end
		local fntFile = "fnt/energy_cd.fnt"
		if _G.useTraditionalChineseRes then fntFile = "fnt/zh_tw/energy_cd.fnt" end
		local label = BitmapText:create(tostring(score), fntFile)
		local function onAnimationFinished() 
			label:removeFromParentAndCleanup(true) 
			self.showStarScoreIndex = nil 
		end
		local array = CCArray:create()
		array:addObject(CCEaseBackOut:create(CCMoveBy:create(0.3, ccp(0, 20)))) 
		array:addObject(CCDelayTime:create(0.5))
		array:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(0.5), CCMoveBy:create(0.3, ccp(0, 10))))
		array:addObject(CCCallFunc:create(onAnimationFinished))
		label:runAction(CCSequence:create(array))


		label:setPosition( dark:convertToWorldSpace(ccp(0, 0)) )
		
		local shake = CCArray:create()
		shake:addObject(CCMoveBy:create(0.05, ccp(-3, 0)))
		shake:addObject(CCMoveBy:create(0.1, ccp(6, 0)))
		shake:addObject(CCMoveBy:create(0.05, ccp(-3, 0)))
		dark:runAction(CCSequence:create(shake))

		local scene = Director:sharedDirector():getRunningScene()
		if scene then scene:addChild(label) end

	end
	

	-- local size = container:getGroupBounds().size
	-- local pos = container:getPosition()
	-- local x = pos.x + self.basePos.x - size.width/2
	-- local y = pos.y + self.basePos.y - size.height/2

	if 4 == starIndex and false == self.showStar4  then
		--不显示四星的时候 不可以点看分
	else
		container:addEventListener(DisplayEvents.kTouchTap, onTouchTap)
	end

	self.parent:addTouchList(container)
	return container
end

function ScoreProgressAnimation:initBg( ... )
    
	-- body
	local background = self.ladybug:getChildByName("background")
	local backgroundPos = background:getPosition()
  	local backgroundSize = background:getContentSize()

	background:removeFromParentAndCleanup(false)
	self.parent.displayLayer[GamePlaySceneTopAreaType.kBackground]:addChild(background)
  	background:setScale(self.kPropListScaleFactor)
  	background:setAnchorPoint(ccp(0,0.5))
  	local basePos = self.ladybug:getPosition()
	background:setPosition(ccp(basePos.x, basePos.y - self.kPropListScaleFactor * backgroundSize.height*0.5))
	self.background = background

    -- addpercentbg
    local addpercentbg = self.ladybug:getChildByName("addpercentbg")
    if addpercentbg then
	    local addpercentbgPos = addpercentbg:getPosition()
  	    local addpercentbgSize = addpercentbg:getContentSize()

	    addpercentbg:removeFromParentAndCleanup(false)
	    self.parent.displayLayer[GamePlaySceneTopAreaType.kBackground]:addChild(addpercentbg)
  	    addpercentbg:setScale(self.kPropListScaleFactor)
  	    addpercentbg:setAnchorPoint(ccp(0,0.5))
  	    local basePos = self.ladybug:getPosition()
	    addpercentbg:setPosition(ccp(basePos.x -25.6, basePos.y - self.kPropListScaleFactor * addpercentbgSize.height*0.5 - 50))

        addpercentbg:setVisible(false)
	    self.addpercentbg = addpercentbg
    end

end

function ScoreProgressAnimation:initAnimal( ... )
	-- body
	local animal = self.ladybug:getChildByName("lady_bug_icon")
  	local content = animal:getChildByName("bg")
  	content:setAnchorPoint(ccp(0.5, 0.5))
  	self.animal = animal

  	local animalStar = animal:getChildByName("light")
  	animalStar:setAnchorPoint(ccp(0.5, 0.5))
  	animalStar:setOpacity(0)
  	self.animalStar = animalStar

  	animal.playStar = function( self )
  		local star = self.animalStar
  		if star then
  			star:stopAllActions()
  			star:setOpacity(0)
  			star:runAction(CCSequence:createWithTwoActions(CCFadeIn:create(0.4), CCFadeOut:create(0.3)))
  		end  		
  	end

  	local shiningStars = animal:getChildByName("light_2")
    shiningStars:setAnchorPoint(ccp(0.5,0.5))
    shiningStars:setOpacity(150)
    shiningStars:runAction(CCRepeatForever:create(
  		SpriteUtil:buildAnimate(SpriteUtil:buildFrames("firefly_light%04d", 0, 25), 1/30)))
end

function ScoreProgressAnimation:initClippingProgress( )
	-- body
	local lightMask = self.ladybug:getChildByName("light_mask")
	local maskSize = lightMask:getContentSize()
  	local maskPos = lightMask:getPosition()
  	local spriteX = maskPos.x
  	local spriteY = maskPos.y
  	local spriteWidth = maskSize.width
  	local spriteHeight = maskSize.height 
  	kMaskBeginWidth = spriteX

  	lightMask:removeFromParentAndCleanup(false)
  	lightMask:setAnchorPoint(ccp(0,0))
  	lightMask:setPosition(ccp(0,0))
  	lightMask:runAction(CCRepeatForever:create(
  		CCSequence:createWithTwoActions(CCFadeTo:create(1, 230), CCFadeTo:create(1, 255))))

  	local stencilNode = CCLayerColor:create(ccc4(255,255,255,255), spriteWidth, spriteHeight)
	stencilNode:setAnchorPoint(ccp(0,0))
	self.stencilNode = stencilNode

  	local clip = ClippingNode.new(CCClippingNode:create(stencilNode))
  	clip.name = "clip"
  	clip:setAnchorPoint(ccp(0, 0))
  	local basePos = self.ladybug:getPosition()
	clip:setScale(self.kPropListScaleFactor)
  	clip:setPosition(ccp(basePos.x + spriteX * self.kPropListScaleFactor, 
  		basePos.y + (spriteY - spriteHeight) * self.kPropListScaleFactor))
	clip:addChild(lightMask)
	self.clip = clip
	self.parent.displayLayer[GamePlaySceneTopAreaType.kItem]:addChild(clip)
	
  	self.spriteWidth = spriteWidth
  	self.spriteHeight = spriteHeight
end

function ScoreProgressAnimation:dispose( ... )
	-- body
	if self.scriptID >= 0 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scriptID) 
		self.scriptID = -1
	end
	if self.ladybug then
		self.ladybug:removeFromParentAndCleanup(true)
	end

	if self.background then
		self.background:removeFromParentAndCleanup(true)
	end

	if self.clip then 
		self.clip:removeFromParentAndCleanup(true)
	end

	self.isDisposed = true

end

function ScoreProgressAnimation:reset( delayTime )
	self:moveTo(0)
	self.resetMoveOver = false
	delayTime = delayTime or 2.5
	local position = self.animal:getPosition()	
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(delayTime))
	arr:addObject(CCEaseSineOut:create(CCMoveTo:create(0.6, ccp(position.x, position.y))))
	arr:addObject(CCCallFunc:create(function ()
		self.resetMoveOver = true
	end))
	-- self.animal:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delayTime),CCEaseSineOut:create(CCMoveTo:create(0.6, ccp(position.x, position.y)))))
	self.animal:runAction(CCSequence:create(arr))
	self.animal:setPosition(ccp(position.x-100, position.y+20))

	if self.bigstar1 then self.bigstar1:removeFromParentAndCleanup(true) end
	if self.bigstar2 then self.bigstar2:removeFromParentAndCleanup(true) end
	if self.bigstar3 then self.bigstar3:removeFromParentAndCleanup(true) end
	if self.bigstar4 then self.bigstar4:removeFromParentAndCleanup(true) end
	self.bigstar1 = nil
	self.bigstar2 = nil
	self.bigstar3 = nil
	self.bigstar4 = nil
end

function ScoreProgressAnimation:isResetMoveOver()
	return self.resetMoveOver
end

function ScoreProgressAnimation:moveTo( progress )
	-- body
	if progress < 0 then progress = 0 end
	if progress > 1 then progress = 1 end

	if self.scriptID >= 0 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scriptID) 
		self.scriptID = -1
	end

	self.progress = progress
	local position = self.spine:calculatePosition(progress)
	local angle = self.spine:calculateAngle(progress)

	self.animal:stopAllActions()
	self.animal:setPosition(position)
	self.animal:setRotation(angle)
	self:updateMaskProgress(progress)	
end

function ScoreProgressAnimation:revertTo( progress )
	-- body
	self:moveTo(progress)
	progress = self.progress

	if self.star1progress ~= nil and self.star2progress ~= nil and self.star3progress ~= nil then
		if progress < self.star1progress and self.bigstar1 ~= nil then
			self.bigstar1:removeFromParentAndCleanup(true)
			self.bigstar1 = nil
			self.starLevel = 0
		end

		if progress < self.star2progress and self.bigstar2 ~= nil then
			self.bigstar2:removeFromParentAndCleanup(true)
			self.bigstar2 = nil
			self.starLevel = 1
		end

		if progress < self.star3progress and self.bigstar3 ~= nil then
			self.bigstar3:removeFromParentAndCleanup(true)
			self.bigstar3 = nil
			self.starLevel = 2
		end

		if self.star4progress and self.showStar4 then
			if progress < self.star4progress and self.bigstar4 ~= nil then
				self.bigstar4:removeFromParentAndCleanup(true)
				self.bigstar4 = nil
				self.starLevel = 3
			end

		end
		


	end

	self:updateStarProgress(progress)
end

function ScoreProgressAnimation:updateMaskProgress( progress )
	-- body
	local position = self.animal:getPosition()
	local width = position.x - kMaskBeginWidth
	local max = self.spriteWidth - kMaskEndWidth
	if width > max then width = max end
     -- 为什么是0.88？因为ScoreProgressBar里面的maxPercentage是0.88
     -- 就是说达到3星分数时，progress是0.88
	if progress >= 0.88 then width = self.spriteWidth end
	self.stencilNode:setContentSize(CCSizeMake(width, self.spriteHeight)) 
end

function ScoreProgressAnimation:updateStarProgress( progress )
	if progress < 0 then progress = 0 end
	if progress > 1 then progress = 1 end

	if self.star1progress ~= nil and self.star2progress ~= nil and self.star3progress ~= nil then

		if progress >= self.star1progress and self.bigstar1 == nil then
			self:showStar(self.star1, "bigstar1")
		end

		if progress >= self.star2progress and self.bigstar2 == nil then
			self:showStar(self.star2, "bigstar2")
		end

		if progress >= self.star3progress and self.bigstar3 == nil then
			self:showStar(self.star3, "bigstar3")
			if self.isActivity then self:showCrown() end
		end
		if self.showStar4 and self.star4progress then
			if progress >= self.star4progress and self.bigstar4 == nil then
				self:showStar(self.star4, "bigstar4")
			end
		end
		
	end

end

function ScoreProgressAnimation:animateTo( progress, duration , ... )
	-- body
	if self.progress == progress then return end

	local animal = self.animal
	if not animal then return end

	if self.scriptID >= 0 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scriptID) 
		self.scriptID = -1
	end

	local beginValue = self.progress
	local deltaValue = progress - self.progress
	self.progress = progress

	local totalTime = 0
	local context = self
	local function onUpdateAnimation( dt )
		if context.isDisposed or animal.isDisposed then 
			if context.scriptID >= 0 then CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(context.scriptID) end
			return 
		end

		totalTime = totalTime + dt
		local timePercent = totalTime / duration

		if timePercent > 1 then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(context.scriptID) 
			context.scriptID = -1

			local finalValue = beginValue + deltaValue
			local position = self.spine:calculatePosition(finalValue)
			animal:setPosition(position)
			self:updateMaskProgress(finalValue)
			self:updateStarProgress(finalValue)
		else
			local currentValue = beginValue + deltaValue * timePercent
			local position = self.spine:calculatePosition(currentValue)
			local angle = self.spine:calculateAngle(currentValue)
			animal:setPosition(position)
			animal:setRotation(angle)
			self:updateMaskProgress(currentValue)
			self:updateStarProgress(currentValue)
		end	
	end 
	self.scriptID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onUpdateAnimation,0.01,false)
end

function ScoreProgressAnimation:setStarPosition( star, progress )
	-- body
	if progress < 0 then progress = 0 end
	if progress > 1 then progress = 1 end
	local position = self.spine:calculatePosition(progress)
	star:setPosition(ccp(position.x, position.y))
end

function ScoreProgressAnimation:setStarsPosition( star1progress, star2progress, star3progress ,star4progress)	
	if star3progress > 0.88 then star3progress = 0.88 end

	self.star1progress = star1progress
	self.star2progress = star2progress
	self.star3progress = star3progress
	self.star4progress = star4progress

	self:setStarPosition(self.star1, star1progress)
	self:setStarPosition(self.star2, star2progress)
	self:setStarPosition(self.star3, star3progress)

	if star4progress then
		self:setStarPosition(self.star4, 1.0)
		star3progress = star4progress
	end

	if star3progress < 0 then star3progress = 0 end
	if star3progress > 1 then star3progress = 1 end
	local position = self.spine:calculatePosition(star3progress)
	self.crown:setPosition(ccp(position.x, position.y))
end

function ScoreProgressAnimation:setStarsScore( star1score, star2score, star3score ,star4score )
	self.star1score = star1score
	self.star2score = star2score
	self.star3score = star3score
	self.star4score = star4score
end

local function createStarDustAnimation( parent, onAnimationFinished, r_base )
	r_base = r_base or 45
	for i = 1, 15 do	
		local angle = i * kStarFactor
		local r = r_base + math.random() * r_base * 0.25
		local x = 0 + math.cos(angle) * r
		local y = 0 + math.sin(angle) * r
		
		local sprite = nil
		if math.random() > 0.6 then sprite = Sprite:createWithSpriteFrameName("win_star_big0000")
		else sprite = Sprite:createWithSpriteFrameName("win_star_dust0000") end
		sprite:setPosition(ccp(0, 0))
		sprite:setScale(0)
		sprite:setOpacity(0)
		sprite:setRotation(math.random() * 360)

		local spawn = CCArray:create()
		spawn:addObject(CCFadeIn:create(0.1))
		spawn:addObject(CCMoveTo:create(0.2 + math.random() * 0.2, ccp(x, y)))
		spawn:addObject(CCScaleTo:create(0.4, math.random()*0.6 + 0.8))

		local sequence = CCArray:create()
		sequence:addObject(CCSpawn:create(spawn))
		sequence:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(0.3), CCScaleBy:create(0.3, 1)))

		if onAnimationFinished ~= nil then
			sequence:addObject(CCCallFunc:create(onAnimationFinished))
		else
			local function onMoveFinished( ) sprite:removeFromParentAndCleanup(true) end
			sequence:addObject(CCCallFunc:create(onMoveFinished))
		end

		sprite:runAction(CCSequence:create(sequence))
		parent:addChild(sprite)
	end
end

function ScoreProgressAnimation:createFinishStarAnimation(position)
	local shiningStars = Sprite:createWithSpriteFrameName("ladybug_rotated_star0000")
	local node = SpriteBatchNode:createWithTexture(shiningStars:getTexture())
	node:setPosition(ccp(position.x, position.y))

    shiningStars:setAnchorPoint(ccp(0.5,0.5))
    shiningStars:setScale(0.6)
    shiningStars:runAction(CCRepeat:create(SpriteUtil:buildAnimate(SpriteUtil:buildFrames("ladybug_rotated_star%04d", 0, 11), 1/30), 1))
    node:addChild(shiningStars)

    local function onAnimationFinished()
    	node:removeFromParentAndCleanup(true)
    end 
    createStarDustAnimation(node, onAnimationFinished, 35)
    return node
end

function ScoreProgressAnimation:createFinsihExplodeStar( position )
	local win_star = ParticleSystemQuad:create("particle/win_star.plist")
	win_star:setAutoRemoveOnFinish(true)
	win_star:setPosition(ccp(position.x,position.y))
	return win_star
end

function ScoreProgressAnimation:createFinsihShineStar( position )
	local overlay = Sprite:createWithSpriteFrameName("win_star_shine0000")
	local container = SpriteBatchNode:createWithTexture(overlay:getTexture())
	container:setPosition(ccp(position.x, position.y))
	overlay:dispose()

	for i = 1, 5 do
		local win_star_shine = Sprite:createWithSpriteFrameName("win_star_shine0000")
		local x = math.random() * 100 - 40
		local y = math.random() * 100 - 40
		local fadeArray = CCArray:create()
		fadeArray:addObject(CCDelayTime:create(0.3 + math.random() * 0.5))
		fadeArray:addObject(CCFadeIn:create(0.2))
		fadeArray:addObject(CCFadeOut:create(0.3))
		
		win_star_shine:setPosition(ccp(x, y))
		win_star_shine:setOpacity(0)
		win_star_shine:setScale(math.random() * 0.5 + 0.4)
		win_star_shine:runAction(CCRepeatForever:create(CCRotateBy:create(0.5, 100)))
		win_star_shine:runAction(CCRepeatForever:create(CCSequence:create(fadeArray)))
		container:addChild(win_star_shine)
	end
	
	local delayTime = 0.5 + math.random()
	local spawn = CCSpawn:createWithTwoActions(CCFadeTo:create(0.1, 80), CCRotateBy:create(0.6, 360))
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(delayTime))
	array:addObject(spawn)
	array:addObject(CCFadeOut:create(0.1))
	
	return container
end

function ScoreProgressAnimation:showStar( star, starName )

    if not star then return end
	if self[starName] then return end
	
	local position = star:getPosition()
	local pos_ladybug = self.ladybug:getPosition()

	local shiningStars = Sprite:createWithSpriteFrameName("ladybug_rotated_star0000")
	local node = SpriteBatchNode:createWithTexture(shiningStars:getTexture())
	node:setPosition(ccp(position.x * self.kPropListScaleFactor + pos_ladybug.x, position.y * self.kPropListScaleFactor + pos_ladybug.y))
	-- self.ladybug:addChild(node)
	node:setScale(self.kPropListScaleFactor)
	self.parent.displayLayer[GamePlaySceneTopAreaType.kEffect]:addChild(node)

    shiningStars:setAnchorPoint(ccp(0.5,0.5))
    shiningStars:setScale(0.6)
    shiningStars:runAction(CCRepeat:create(SpriteUtil:buildAnimate(SpriteUtil:buildFrames("ladybug_rotated_star%04d", 0, 11), 1/30), 1))
    node:addChild(shiningStars)

    local overlay = Sprite:createWithSpriteFrameName("ladybug_sunshine0000")
    overlay:setAnchorPoint(ccp(0.5,0.5))
    overlay:setOpacity(0)
    overlay:setScale(0.6)
    overlay:runAction(CCRepeatForever:create(CCRotateBy:create(0.5, 120)))
    local fadeIn = CCSpawn:createWithTwoActions(CCFadeTo:create(0.25, 200), CCScaleTo:create(0.25, 2.4))
    local fadeOut = CCSpawn:createWithTwoActions(CCFadeOut:create(0.6), CCScaleTo:create(0.6, 2))
    overlay:runAction(CCSequence:createWithTwoActions(fadeIn, fadeOut))
    node:addChild(overlay)

    self.background:stopAllActions()
    self.background:setRotation(0)
    self.background:runAction(CCRepeat:create(CCSequence:createWithTwoActions(CCRotateBy:create(0.03,-1), CCRotateBy:create(0.03,1)), 2))

    --star dust
	createStarDustAnimation(node)

    self.animal:playStar()

	self[starName] = node

	if star == self.star1 then
		self.starLevel = 1
	elseif star == self.star2 then
		self.starLevel = 2
	elseif star == self.star3 then
		self.starLevel = 3
	elseif star == self.star4 then
		self.starLevel = 4
	end
end

function ScoreProgressAnimation:setBigStarVisible(starIndex, visible, ...)
	assert(type(starIndex) == "number")
	assert(type(visible) == "boolean")
	assert(#{...} == 0)

	local bigStarToControl		= false
	local smallStarToControl	= false

	if starIndex == 1 then
		bigStarToControl 	= self["bigstar1"]
		smallStarToControl	= self.star1
	elseif starIndex == 2 then
		bigStarToControl 	= self["bigstar2"]
		smallStarToControl	= self.star2
	elseif starIndex == 3 then
		bigStarToControl 	= self["bigstar3"]
		smallStarToControl	= self.star3
	elseif starIndex == 4 then -- four star level
		-- ignore
	end

	if bigStarToControl then
		bigStarToControl:setVisible(visible)
		smallStarToControl:setVisible(visible)
	end
end

function ScoreProgressAnimation:getStarLevel(...)
	assert(#{...} == 0)
	return self.starLevel
end

function ScoreProgressAnimation:getBigStarPosInWorldSpace(...)
	assert(#{...} == 0)

	local star1Pos	= self.star1:getPosition()
	local star2Pos	= self.star2:getPosition()
	local star3Pos	= self.star3:getPosition()
    local star4Pos  = self.fourthStar:getPosition()

	-- Convert To World Space
	local star1WorldPos = self.ladybug:convertToWorldSpace(ccp(star1Pos.x, star1Pos.y))
	local star2WorldPos = self.ladybug:convertToWorldSpace(ccp(star2Pos.x, star2Pos.y))
	local star3WorldPos = self.ladybug:convertToWorldSpace(ccp(star3Pos.x, star3Pos.y))
    local star4WorldPos = self.ladybug:convertToWorldSpace(ccp(star4Pos.x, star4Pos.y))

	return {star1WorldPos, star2WorldPos, star3WorldPos, star4WorldPos}
end

function ScoreProgressAnimation:getBigStarSize(...)
	assert(#{...} == 0)

	local shiningStars = Sprite:createWithSpriteFrameName("ladybug_rotated_star0000")
	shiningStars:setScale(0.4)
	local size = shiningStars:getGroupBounds().size
	size = {width = size.width, height = size.height}
	shiningStars:dispose()

	return size
end

function ScoreProgressAnimation:addScoreStar( globalPosition )
	local targetPosition = self.animal:convertToWorldSpace(ccp(0,0))
	local r = 16 + math.random() * 10
	local localPosition = globalPosition
	for i = 1, 10 do	
		if math.random() > 0.6 then
			local angle = i * 36 * 3.1415926 / 180
			local x = localPosition.x + math.cos(angle) * r
			local y = localPosition.y + math.sin(angle) * r
			local sprite = Sprite:createWithSpriteFrameName("game_collect_small_star0000")
			sprite:setPosition(ccp(localPosition.x, localPosition.y))
			sprite:setScale(math.random()*0.6 + 0.7)
			sprite:setOpacity(0)
			local moveTime = 0.3 + math.random() * 0.64
			local moveTo = CCMoveTo:create(moveTime, ccp(targetPosition.x, targetPosition.y))
			local function onMoveFinished( ) sprite:removeFromParentAndCleanup(true) end
			local moveIn = CCEaseElasticOut:create(CCMoveTo:create(0.25, ccp(x, y)))
			local array = CCArray:create()
			array:addObject(CCSpawn:createWithTwoActions(moveIn, CCFadeIn:create(0.25)))
			array:addObject(CCEaseSineIn:create(moveTo))
			array:addObject(CCCallFunc:create(onMoveFinished))
			sprite:runAction(CCSequence:create(array))

			local scene = Director:sharedDirector():getRunningScene()
			scene:addChild(sprite)
		end
	end
end

function ScoreProgressAnimation:playFourStarAnimation()

    self:animateTo(1, 0.5) -- ladybug moves to the end

    self.sunshine:setVisible(true)
    self.sunshine:setScale(0)
    self.fourthStar:setVisible(true)
    self.fourthStar:setScale(0)

    local starZOrder = self.fourthStar:getZOrder()

    local fourStarAnimationArray = CCArray:create()
    local waitTime = CCDelayTime:create(0.5)
    fourStarAnimationArray:addObject(waitTime)

    -- ladybug turns into a star
    local animalAction = CCTargetedAction:create(self.animal.refCocosObj,
                        CCSpawn:createWithTwoActions(
                            CCRotateBy:create(1, 360*4),
                            CCSequence:createWithTwoActions(CCDelayTime:create(0.7), CCScaleTo:create(0.3, 1.2))
                                                        )
                                                 )
    local fourthStarSunshineAction = CCTargetedAction:create(self.sunshine.refCocosObj,
                                        CCSpawn:createWithTwoActions(
                                            CCRotateBy:create(1, -480),
                                            CCSequence:createWithTwoActions(
                                                CCScaleTo:create(0.6, 1), CCScaleTo:create(0.4, 0)
                                                                            )
                                                                     )
                                                             )
    local fourthStarWhite = self.fourthStar:getChildByName('star_white')
    local fourthStarWhiteAction = CCTargetedAction:create(fourthStarWhite.refCocosObj, CCFadeOut:create(0.8))

    local fourthStarAction = CCTargetedAction:create(self.fourthStar.refCocosObj,
                                CCEaseBounceOut:create(CCSpawn:createWithTwoActions(CCRotateBy:create(1, -360), CCScaleTo:create(1, 1)))
                                                     )

    local spawnArray = CCArray:create()
    spawnArray:addObject(fourthStarSunshineAction)
    spawnArray:addObject(fourthStarWhiteAction)
    spawnArray:addObject(fourthStarAction)

    local function hideStar4()
    	if self.star4 then self.star4:setVisible(false) end
    	if self.bigstar4 then self.bigstar4:setVisible(false) end
    end

    local function hideStars()

        if self.star1 then self.star1:setVisible(false) end
        if self.star2 then self.star2:setVisible(false) end
        if self.star3 then self.star3:setVisible(false) end
        if self.star4 then self.star4:setVisible(false) end

        if self.bigstar1 then self.bigstar1:setVisible(false) end
        if self.bigstar2 then self.bigstar2:setVisible(false) end
        if self.bigstar3 then self.bigstar3:setVisible(false) end
        if self.bigstar4 then self.bigstar4:setVisible(false) end

    end

    local sequenceArray = CCArray:create()
    sequenceArray:addObject(CCCallFunc:create(hideStar4))
    sequenceArray:addObject(animalAction)
    sequenceArray:addObject(CCSpawn:create(spawnArray))
    sequenceArray:addObject(CCCallFunc:create(hideStars))
    local animalToStarAction = CCSequence:create(sequenceArray)

    fourStarAnimationArray:addObject(animalToStarAction)


    -- shining branch effect
    self.fourStar_shining:setVisible(true)
    -- local spriteWidth = self.fourStar_shining:getContentSize().width
    -- local spriteHeight = self.fourStar_shining:getContentSize().height
    -- local spriteX = self.fourStar_shining:getPositionX()
    -- local spriteY = self.fourStar_shining:getPositionY()
    -- local maskIndex = self.fourStar_shining:getZOrder()
    -- local parent = self.fourStar_shining:getParent()
    -- self.fourStar_shining:removeFromParentAndCleanup(false)

    -- self.fourStar_shining = SpriteColorAdjust:createWithSpriteFrameName('fourstar_shining0000')
    -- self.fourStar_shining:setAnchorPoint(ccp(0, 1))

    -- local maskNode = ClippingNode:create({size = {width = spriteWidth, height = spriteHeight}})
    -- -- local maskNode = LayerColor:create()
    -- -- maskNode:setContentSize(CCSizeMake(spriteWidth, spriteHeight))
    -- maskNode:setAnchorPoint(ccp(0, 0))
    -- maskNode:setPosition(ccp(spriteX, spriteY - spriteHeight))
    -- maskNode:addChild(self.fourStar_shining)
    -- self.fourStar_shining:setPosition(ccp(0, spriteHeight))
    -- local maskStencil = maskNode:getStencil()
    -- maskStencil:setPosition(ccp(spriteWidth + 10, 0))
    -- parent:addChildAt(maskNode, maskIndex)
    -- local maskAction = CCEaseExponentialIn:create(CCMoveBy:create(0.5, ccp(-spriteWidth - 20, 0)))
    local maskAction = CCEaseExponentialIn:create(CCFadeOut:create(0.5))
    local branchAction = CCTargetedAction:create(maskStencil, maskAction)


    -- creating shining stars on the tree branch
    for i=1, 30 do 
        local win_star_shine = Sprite:createWithSpriteFrameName("win_star_shine0000")
        if not self.win_star_shine_container then
        	self.win_star_shine_container = SpriteBatchNode:createWithTexture(win_star_shine:getTexture())
        end

        local choice = i % 6 + 1
        local pos = self.spine:getControlPointAtIndex(choice) or ccp(0, 0)
        local x = pos.x + math.random(-100, 10)
        local y = pos.y + math.random(-15, 20)
        local fadeArray = CCArray:create()
        fadeArray:addObject(CCDelayTime:create(math.random(0, 100)/100))
        fadeArray:addObject(CCFadeIn:create(0.3))
        fadeArray:addObject(CCDelayTime:create(math.random(10, 50)/100))
        fadeArray:addObject(CCFadeOut:create(0.4))
        
        win_star_shine:setPosition(ccp(x, y))
        win_star_shine:setOpacity(0)
        win_star_shine:setScale(math.random(20, 110) / 100)
        win_star_shine:runAction(CCRepeatForever:create(CCRotateBy:create(0.5, 100)))
        win_star_shine:runAction(CCRepeatForever:create(CCSequence:create(fadeArray)))
       	self.win_star_shine_container:addChild(win_star_shine)
    end
    self.win_star_shine_container:setScale(self.kPropListScaleFactor)
    local pos = self.ladybug:getPosition()
    self.win_star_shine_container:setPosition(ccp(pos.x, pos.y))
    self.parent.displayLayer[GamePlaySceneTopAreaType.kEffect]:addChild(self.win_star_shine_container)
    fourStarAnimationArray:addObject(branchAction)
    

    -- star effects
    local function createStarAction(delay)
        local smallScale = 0.3
        local largeScale = 1
        local duration = 1.3
        local scaleDuration = 0.7
        -- local ui = ResourceManager:sharedInstance():buildGroup("fourStar_starAnim")
        local ui = ResourceManager:sharedInstance():buildBatchGroup("sprite", "fourStar_starAnim")
        ui:setAnchorPoint(ccp(0.5, 1))
        local whiteStar = ui:getChildByName('star_white')
        whiteStar:setAnchorPoint(ccp(0.5, 1))
        local normalStar = ui:getChildByName('star_normal')
        normalStar:setAnchorPoint(ccp(0.5, 1))
        local sunshine = ui:getChildByName('sunshine')
        sunshine:setAnchorPoint(ccp(0.5, 1))
        local starHandle = ui:getChildByName('star_handle')
        whiteStar:setScale(smallScale)
        local whiteStarTmp = CCArray:create()
        whiteStarTmp:addObject(CCScaleTo:create(scaleDuration, largeScale))
        whiteStarTmp:addObject(CCFadeOut:create(scaleDuration))
        local whiteStarAction = CCTargetedAction:create(whiteStar.refCocosObj,
                                CCEaseExponentialOut:create(CCSpawn:create(whiteStarTmp))
                                                        )
        normalStar:setScale(smallScale)
        local normalStarTmp = CCArray:create()
        normalStarTmp:addObject(CCScaleTo:create(scaleDuration, largeScale))
        local normalStarAction = CCTargetedAction:create(normalStar.refCocosObj,
                                    CCEaseExponentialOut:create(CCSpawn:create(normalStarTmp))
                                                         )
        sunshine:setScale(0)
        sunshine:setAnchorPoint(ccp(0.5, 0.5))
        local sunshineTmp = CCArray:create()
        sunshineTmp:addObject(CCEaseExponentialOut:create(CCScaleTo:create(0.6, 1)))
        sunshineTmp:addObject(CCDelayTime:create(0.5))
        sunshineTmp:addObject(CCScaleTo:create(0.5, 0))
        local sequence = CCSequence:create(sunshineTmp)
        local rotate = CCRotateBy:create(1.3, 360)
        local sunshineAction = CCTargetedAction:create(sunshine.refCocosObj,
                                    CCSpawn:createWithTwoActions(sequence, rotate)
                                                         )
        ui:setRotation(90) -- left turn 90
        local uiAction = CCTargetedAction:create(ui.refCocosObj, 
                            CCSpawn:createWithTwoActions(
                                CCFadeIn:create(0.1),
                                CCEaseElasticOut:create(
                                    CCRotateBy:create(duration, -90)
                                                        )
                                                    )
                                                 )
        local actionBundleTmp = CCArray:create()-- delay time between stars
        actionBundleTmp:addObject(whiteStarAction)
        actionBundleTmp:addObject(normalStarAction)
        actionBundleTmp:addObject(sunshineAction)
        actionBundleTmp:addObject(uiAction)
        local function showStar()
            if ui and not ui.isDisposed then ui:setVisible(true) end
        end
        local retArray = CCArray:create()
        retArray:addObject(CCDelayTime:create(delay))
        retArray:addObject(CCCallFunc:create(showStar))
        retArray:addObject(CCSpawn:create(actionBundleTmp))
        local ret = CCSequence:create(retArray)
        return ui, ret
    end

    local spawnArray = CCArray:create()
    local delay = 0
    for i=3, 1, -1 do  -- the last star on top, the first on bottom
        local starAnim, action = createStarAction(delay)
        local starRes = self['star'..i]
        starRes:getParent():addChildAt(starAnim, starZOrder - 1)
        starAnim:setVisible(false)
        starAnim:setPosition(ccp(starRes:getPositionX(), starRes:getPositionY()))
        spawnArray:addObject(action)
        delay = delay + 0.3
    end
    fourStarAnimationArray:addObject(CCSpawn:create(spawnArray))

    -- creating leaves growing effect
    local leafArray = CCArray:create()
    for i=1,3 do 
        local leaf = self['leaf'..i]

        if not leaf then
            break
        end

        local function showLeaf()
            if leaf and not leaf.isDisposed then leaf:setVisible(true) end
        end
        local pos = nil
        if i % 2 == 0 then -- 2 goes here
            pos = ccp(-5, -20)
        else
            pos = ccp(0, 20) -- 1,3 goes here
        end
        local leafAction = CCTargetedAction:create(leaf.refCocosObj, CCSequence:createWithTwoActions(CCCallFunc:create(showLeaf),  CCMoveBy:create(0.8, pos)))
        leafArray:addObject(leafAction)
    end
    if leafArray:count() > 0 then 
    	fourStarAnimationArray:addObject(CCSpawn:create(leafArray))
    end

    self.ladybug:runAction(CCSequence:create(fourStarAnimationArray))
end

function ScoreProgressAnimation:showCrown()

    if not self.crown then
        return 
    end

	local resName = 'ladybug_rotated_coin0000'
	local sp = Sprite:createWithSpriteFrameName(resName)
	local frames, animate
	local aniName = 'ladybug_rotated_coin%04d'

	frames = SpriteUtil:buildFrames(aniName, 0, 11)
	animate = SpriteUtil:buildAnimate(frames, 1 / 12)
	local position = self.crown:getPosition()
	local pos_ladybug = self.ladybug:getPosition()
	sp:setPosition(ccp(position.x * self.kPropListScaleFactor + pos_ladybug.x, position.y * self.kPropListScaleFactor + pos_ladybug.y))
	sp:play(animate, 0, 1)

	self.parent.displayLayer[GamePlaySceneTopAreaType.kEffect]:addChild(sp)
end

function ScoreProgressAnimation:getStarWorldPos( starIndex )
	local star = self['star' .. starIndex]
	if star then
		local bounds = star:getGroupBounds()
		return ccp(bounds:getMidX(), bounds:getMidY())
	end
end