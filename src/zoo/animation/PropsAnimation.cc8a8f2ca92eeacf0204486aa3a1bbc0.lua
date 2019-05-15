PropsAnimation = {}

local function sequence( ... )
	local actions = CCArray:create()
	for k,v in pairs({ ... }) do
		actions:addObject(v)
	end
	return CCSequence:create(actions)	
end

local function spawn( ... )
	local actions = CCArray:create()
	for k,v in pairs({ ... }) do
		actions:addObject(v)
	end
	return CCSpawn:create(actions)	
end 

local function target( cocosObj, action )
	return CCTargetedAction:create(cocosObj.refCocosObj,action)
end

local function frameTime( frame )
	return frame/24
end

local function particle( plistPath )
  	if not _G.__use_low_effect and not noParticle then 
		return ParticleSystemQuad:create(plistPath)
 	else
 		return CocosObject:create()
	end
end

local ICON_SHOE_TIME = 1
local FLY_FRAME = 9
local FRAME_TIME = 1 / GamePlayConfig_Action_FPS

local isLoaded = false
function PropsAnimation:lazyLoadRes( ... )
	if isLoaded then
		return
	end
	FrameLoader:loadArmature("skeleton/props_effect_animation")
	FrameLoader:loadArmature("skeleton/prop_line_animation")
	FrameLoader:loadArmature("skeleton/prop_hammer_animation")
	FrameLoader:loadArmature("skeleton/prop_arrow")
    FrameLoader:loadArmature("skeleton/SpeardAnim")
    FrameLoader:loadArmature("skeleton/prop_line_effect_animation")

	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(
		SpriteUtil:getRealResourceName("flash/props_effects.plist")
	)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(
		SpriteUtil:getRealResourceName("flash/props_stars.plist")
	)
	isLoaded = true
end

local armatures = {}

function PropsAnimation:createArmature( name )
	local animNode = ArmatureNode:create(name)
	animNode:playByIndex(0)
	animNode:update(0.001) 
	animNode:stop()

	animNode:unscheduleUpdate()
	table.insert(armatures,animNode)

	return animNode 
end

function PropsAnimation:updateAnimation( ... )
	if #armatures > 0 then
		local hasDisposeArmature = false
		for k,v in pairs(armatures) do
			if not v.isDisposed and v.refCocosObj then
				v.refCocosObj:advanceTime(FRAME_TIME)
			else
				hasDisposeArmature = true
			end
		end
		if hasDisposeArmature then
			armatures = table.filter(armatures,function( v )
				return not v.isDisposed and v.refCocosObj
			end)
		end
	end
end

local boardViewBackground = nil
function PropsAnimation:showHighlightBoardView( gamePlaySceneUI )
	self:hideHighlightBoardView(gamePlaySceneUI)

	local size = CCDirector:sharedDirector():getWinSize()
	local origin = CCDirector:sharedDirector():getVisibleOrigin()

	boardViewBackground = LayerColor:create()
	boardViewBackground:setOpacity(0.7 * 255)
	boardViewBackground:setContentSize(size)
	boardViewBackground:setPosition(ccp(0, 0))
	gamePlaySceneUI:addChild(boardViewBackground)

	gamePlaySceneUI:showTopBoardView()
end

function PropsAnimation:hideHighlightBoardView( gamePlaySceneUI )
	if boardViewBackground and not boardViewBackground.isDisposed then
		boardViewBackground:removeFromParentAndCleanup(true)
		boardViewBackground = nil
	end

	if not gamePlaySceneUI.isDisposed then
		gamePlaySceneUI:showNormalBoardView()
	end
end

function PropsAnimation:createFlyEffectAnim(animName, posList, onFlyEvent, delay)
	self:lazyLoadRes()

	local anim = CocosObject:create()

	local animNode = self:createArmature(animName)
	anim:addChild(animNode)
	
	local flyNum = #posList
	local counter = 0
	local function flyFinish( ... )
		counter = counter + 1
		if counter == flyNum then
    		anim:dispatchEvent(Event.new(Events.kComplete, nil, anim))
			anim:removeFromParentAndCleanup(true)
		end
	end

	animNode:addEventListener(ArmatureEvents.BONE_FRAME_EVENT,function( evt )
		if evt.data.frameLabel == "fly" then
			local origin = Director:sharedDirector():getVisibleOrigin()
			local flyTime = frameTime(FLY_FRAME)
			for i = 1, flyNum do
				local tail = onFlyEvent(i, ccp(0,0), animNode:convertToNodeSpace(ccpAdd(posList[i],origin)), flyTime)
				tail:addEventListener(Events.kComplete,flyFinish)
				animNode:addChildAt(tail,0)
				tail:play()
			end
		end
	end)

	function anim:play( ... )
		local t = delay or 0.6

		self:runAction(sequence(
			CCDelayTime:create(ICON_SHOE_TIME - t/2),
			CCCallFunc:create(function( ... )
				animNode:playByIndex(0,1,t,0)
			end)
		))
	end

	return anim
end

function PropsAnimation:createGiveBackAnim(animName, propId, callback, delay)
	self:lazyLoadRes()

	local anim = CocosObject:create()

	local animNode = self:createArmature(animName)
	anim:addChild(animNode)

	animNode:addEventListener(ArmatureEvents.BONE_FRAME_EVENT,function( evt )
		if evt.data.frameLabel == "fly" then
			local reward = {itemId = propId, num = 1}
			local anim = FlyItemsAnimation:create({reward})
			local nodePos = animNode:getPosition()
			local wPosition = animNode:getParent():convertToWorldSpace(ccp(nodePos.x - 50, nodePos.y + 45))
	        anim:setWorldPosition(ccp(wPosition.x, wPosition.y))
	        anim:setFinishCallback(callback)
	        anim:play()
		end
	end)

	function anim:play( ... )
		local t = delay or 0.6

		self:runAction(sequence(
			CCDelayTime:create(ICON_SHOE_TIME - t/2),
			CCCallFunc:create(function( ... )
				animNode:playByIndex(0,1,t,0)
			end)
		))
	end

	return anim
end

function PropsAnimation:createPrePropsAnim(assetName, toLinePos, toWrapPos, useBlueTailFirst)
	local toPosition
	if toLinePos and toWrapPos then
		toPosition = {toLinePos, toWrapPos}
	elseif toLinePos then
		toPosition = {toLinePos}
	elseif toWrapPos then
		toPosition = {toWrapPos}
	end

	local function onFlyEvent(index, fromPos, toPos, flyTime)
		if index == 1 and useBlueTailFirst then
			return self:createBlueTail(fromPos, toPos, flyTime)
		else
			return self:createYellowTail(fromPos, toPos, flyTime)
		end
	end

	return PropsAnimation:createFlyEffectAnim(assetName, toPosition, onFlyEvent)
end

function PropsAnimation:playWrapEffect( r,c,boardView,callback )
	self:lazyLoadRes()

	local itemView = boardView.baseMap[r][c]
	local gameBoardLogic = boardView.gameBoardLogic
	local itemPos = itemView:getBasePosition(c,r)
	local layer = itemView.getContainer(ItemSpriteType.kPropsEffect)

	local cells = {
		{1,3},
		{2,2},{2,3},{2,4},
		{3,1},{3,2},{3,3},{3,4},{3,5},
		{4,2},{4,3},{4,4},
		{5,3}
	}

	local stencil = CocosObject:create()
	for k,v in pairs(cells) do
		local row = v[1] - 3 + r
		local col = v[2] - 3 + c
		if row >= 1 and row <= 9 and col >= 1 and col <= 9 then
			if gameBoardLogic:isItemCanUsed(row,col) then
				local mask = LayerColor:create()
				mask:setContentSize(CCSizeMake(
					GamePlayConfig_Tile_Width,
					GamePlayConfig_Tile_Height
				))
				mask:ignoreAnchorPointForPosition(false)
				mask:setAnchorPoint(ccp(0.5,0.5))

				local maskPos = itemView:getBasePosition(col,row)
				mask:setPositionX(maskPos.x - itemPos.x)
				mask:setPositionY(maskPos.y - itemPos.y)
				stencil:addChild(mask)
			end
		end
	end


	local effect = ClippingNode.new(CCClippingNode:create(stencil.refCocosObj))
	stencil:dispose()

	-- local effect = CocosObject:create()
	-- effect:addChild(stencil)

	effect:setPositionX(itemPos.x)
	effect:setPositionY(itemPos.y)
	layer:addChild(effect)

	local animNode = self:createArmature("wrapEffect/anim")
	animNode:playByIndex(0,1,-1,0)
	effect:addChild(animNode)

	local bg = Sprite:createWithSpriteFrameName("props_animation_wrap_effect_background0000")
	local bgSize = bg:getContentSize()
	bg:setAnchorPoint(ccp(0.5,0.5))
	bg:setScaleX(358/bgSize.width)
	bg:setScaleY(358/bgSize.height)
	effect:addChild(bg)

	bg:setOpacity(0)
	bg:setScaleX(120/bgSize.width)
	bg:setScaleY(120/bgSize.height)
	bg:runAction(sequence(
		spawn(
			CCFadeTo:create(frameTime(5),0.67 * 255),
			CCScaleTo:create(frameTime(5),305/bgSize.width,305/bgSize.height)
		),
		spawn(
			CCFadeTo:create(frameTime(4),0.21 * 255),
			CCScaleTo:create(frameTime(4),358/bgSize.width,358/bgSize.height)
		),
		spawn(
			CCFadeTo:create(frameTime(4),0 * 255),
			CCScaleTo:create(frameTime(4),400/bgSize.width,bgSize.height)
		)
	))

	for k,v in pairs(cells) do
		local row = v[1] - 3 + r
		local col = v[2] - 3 + c
		if row >= 1 and row <= 9 and col >= 1 and col <= 9 then
			local itemView = boardView.baseMap[row][col]
			-- local item = itemView.itemSprite[ItemSpriteType.kItem]
			local item = itemView:getGameItemSprite()
			
			if item and item.refCocosObj then
				local oldScaleX,oldScaleY = item:getScaleX(),item:getScaleY()
				item:runAction(sequence(
					CCDelayTime:create(frameTime(7)),
					CCScaleTo:create(frameTime(2),1.2*oldScaleX,1.2*oldScaleY),
					CCScaleTo:create(frameTime(2),1.0*oldScaleX,1.0*oldScaleY)
				))
			end
		end
	end

	local starAnimInfo = {
		{ rotation=00,from={0,70},to={0,170} },
		{ rotation=-90,from={-70,0},to={-170,0}},
		{ rotation=90,from={70,0},to={170,0}},
		{ rotation=180,from={0,-70},to={0,-170}}
	}
	for k,v in pairs(starAnimInfo) do
		local stars,animate = SpriteUtil:buildAnimatedSprite(frameTime(1),"wrapEffect_stars%02d.png",0,14,false)
		stars:setAnchorPoint(ccp(0.5,0.5))
		stars:setRotation(v.rotation)
		stars:runAction(CCRepeatForever:create(animate))

		stars:setPositionX(v.from[1])
		stars:setPositionY(v.from[2])
		stars:setScale(0.3)
		stars:runAction(sequence(
			spawn(
				CCScaleTo:create(frameTime(7),1,1),
				CCMoveTo:create(frameTime(15),ccp(v.to[1],v.to[2]))
			),
			CCCallFunc:create(function( ... )
				stars:setVisible(false)
			end)
		))
		effect:addChild(stars)
	end

	effect:runAction(sequence(
		CCDelayTime:create(frameTime(15)),
		CCCallFunc:create(function( ... )
			effect:removeFromParentAndCleanup(true)

			if callback then
				callback()
			end
		end)
	))
end

-- +3
function PropsAnimation:createAdd3Anim( ... )
	local anim = self:createAddStepAnim("+3")
	local play = anim.play
	function anim:play( ... )
		self:runAction(sequence(
			CCDelayTime:create(ICON_SHOE_TIME),
			CCCallFunc:create(play)
		))
	end
	return anim
end


function PropsAnimation:createAdd1Anim( ... )
	return self:createAddStepAnim("+1")
end

function PropsAnimation:createAdd2Anim( ... )
	return self:createAddStepAnim("+2")
end

function PropsAnimation:createAdd5Anim( ... )
	return self:createAddStepAnim("+5")
end

function PropsAnimation:createAdd15Anim( ... )
	return self:createAddStepAnim("+15")
end

function PropsAnimation:createAddStepAnim( step )
	self:lazyLoadRes()

	local anim = CocosObject:create()
	local animNode = self:createArmature(step .. "/anim")
	anim:addChild(animNode)

	local function flyFinish( ... )
		anim:dispatchEvent(Event.new(Events.kComplete, nil, anim))
		anim:removeFromParentAndCleanup(true)
	end 

	local function fly( ... )
		local origin = Director:sharedDirector():getVisibleOrigin()
		local size = CCDirector:sharedDirector():getVisibleSize()
		
		local toPos = anim:convertToNodeSpace(ccp(
			origin.x + size.width - 100, 
			origin.y + size.height - 100
		))

		local tail = PropsAnimation:createYellowTail(
			ccp(0,0),
			toPos,
			0
		)
		anim:addChildAt(tail,0)

		tail:setAnchorPoint(ccp(0.8,0.5))
		tail:setScaleX(2*150/tail:getContentSize().width)
		tail:setScaleY(2*35/tail:getContentSize().height)
		tail:runAction(CCMoveTo:create(frameTime(FLY_FRAME),toPos))

		animNode:runAction(sequence(
			spawn(
				CCScaleTo:create(frameTime(3),400/280,415/280),
				CCSkewTo:create(frameTime(3),15.4,0)
			),
			spawn(
				CCScaleTo:create(frameTime(3),400/280,455/280),
				CCSkewTo:create(frameTime(3),30.7,0)
			),
			spawn(
				CCScaleTo:create(frameTime(3),220/280,225/280),
				CCSkewTo:create(frameTime(3),25,15),
				CCFadeTo:create(frameTime(3),0.5*255)
			)
		))

		animNode:runAction(sequence(
			CCMoveTo:create(frameTime(FLY_FRAME),toPos),
			CCCallFunc:create(flyFinish)
		))
	end

	function anim:play( ... )
		fly()
	end

	return anim
end

function PropsAnimation:createAdd3EffectAnim( ... )
	self:lazyLoadRes()

	local effect = CocosObject:create()

	local animNode = self:createArmature("+3Effect/anim")
	effect:addChild(animNode)
	function effect:play( duration )
		duration = duration or -1
		animNode:playByIndex(0,1,duration,0)
	end
	animNode:addEventListener(ArmatureEvents.COMPLETE,function( ... )
		effect:dispatchEvent(Event.new(Events.kComplete, nil, effect))
	end)

	return effect
end

-- 前置刷新道具
function PropsAnimation:createAddToBarAnim( toPos )
	self:lazyLoadRes()

	local anim = CocosObject:create()

	local animNode = self:createArmature("refresh/anim")
	anim:addChild(animNode)

	local function flyFinish( ... )
		anim:dispatchEvent(Event.new(Events.kComplete, nil, anim))
		anim:removeFromParentAndCleanup(true)
	end

	local function fly( ... )
		toPos = anim:convertToNodeSpace(toPos)

		local tail = PropsAnimation:createYellowTail(ccp(0,0),toPos,0)		
		tail:setAnchorPoint(ccp(0.8,0.5))
		tail:setScaleX(2*150/tail:getContentSize().width)
		tail:setScaleY(2*35/tail:getContentSize().height)
		tail:runAction(CCMoveTo:create(frameTime(FLY_FRAME),toPos))
		anim:addChildAt(tail,0)

		animNode:runAction(sequence(
			spawn(
				CCScaleTo:create(frameTime(4),60/75,60/75),
				CCSkewTo:create(frameTime(4),24.1,0)
			),
			spawn(
				CCScaleTo:create(frameTime(4),50/75,60/75),
				CCSkewTo:create(frameTime(4),45,0),
				CCFadeTo:create(frameTime(4),0.5*255)
			)
		))

		animNode:runAction(sequence(
			CCMoveTo:create(frameTime(FLY_FRAME),toPos),
			CCCallFunc:create(flyFinish)
		))

	end

	function anim:play( ... )
		self:runAction(sequence(
			CCDelayTime:create(ICON_SHOE_TIME),
			CCCallFunc:create(fly)
		))
	end

	return anim
end

function PropsAnimation:playAddToBarEffect( propItem,callback )
	self:lazyLoadRes()
	local item = propItem.item
	local bgAnim = self:createArmature("addToBarEffect/bgAnim")
	bgAnim:playByIndex(0,0)

	local bg_hint2 = item:getChildByName("bg_hint2")
	local boundingBox = bg_hint2:boundingBox()

	bgAnim:setPositionX(boundingBox:getMidX())
	bgAnim:setPositionY(boundingBox:getMidY())
	bgAnim:setPositionY(56)
	bgAnim:setScale(0.9)
	item:addChildAt(bgAnim,0)

	local starAnim = self:createArmature("addToBarEffect/starAnim")
	starAnim:playByIndex(0,0)
	starAnim:setPositionX(28)
	starAnim:setPositionY(56)
	item:addChild(starAnim)

	starAnim:runAction(sequence(
		CCDelayTime:create(1),
		CCCallFunc:create(function( ... )
			bgAnim:removeFromParentAndCleanup(true)
			starAnim:removeFromParentAndCleanup(true)
			if callback then
				callback()
			end
		end)
	))
end

--  

function PropsAnimation:createBlueTail( fromPos,toPos,flyTime )
	return self:createTail(fromPos,toPos,flyTime,"blue")
end

function PropsAnimation:createYellowTail( fromPos,toPos,flyTime )
	return self:createTail(fromPos,toPos,flyTime,"yellow")
end

function PropsAnimation:createTail(fromPos,toPos,time,color)
	self:lazyLoadRes()

	local sprite = Sprite:createWithSpriteFrameName("props_animation_".. color .. "_light0000")
	local function finish( ... )
    	sprite:dispatchEvent(Event.new(Events.kComplete, nil, sprite))
    	sprite:removeFromParentAndCleanup(true)
	end

	sprite:setAnchorPoint(ccp(0.5,0.5))
	sprite:setRotation(math.deg(math.atan2(fromPos.y-toPos.y,toPos.x-fromPos.x)))
	sprite:setPosition(fromPos)

	function sprite:play( ... )
		sprite:setOpacity(0)
		sprite:setScaleX(0.08)

		sprite:runAction(sequence(
			spawn(
				sequence(
					CCFadeTo:create(time * 0.1,1.0 * 255),
					CCFadeTo:create(time * 0.9,0.6 * 255)
				),
				sequence(
					CCScaleTo:create(time * 0.1,1.0,1.0),
					CCScaleTo:create(time * 0.8,0.8,0.8),
					CCScaleTo:create(time * 0.1,0.6,0.6)
				),
				CCMoveTo:create(time,toPos)
			),
			CCCallFunc:create(finish)
		))
	end

	-- local p = particle("particle/falling_star.plist")
	-- p:setRotation(90)
	-- p:setPosition(ccp(sprite:getContentSize().width/2,sprite:getContentSize().height/2))
	-- sprite:addChild(p)

	return sprite
end


-- 道具气泡选择高亮动画
function PropsAnimation:createSelectAnim( ... )
	self:lazyLoadRes()

	local anim = CocosObject:create()

	local animNode = self:createArmature("selectEffect/anim")
	animNode:setScale(0.9)
	anim.animNode = animNode
	anim:addChild(animNode)

	function anim:play( ... )
		animNode:playByIndex(0,0,-1,0)
	end

	return anim
end

-- 魔法棒 
function PropsAnimation:createLineAnim( gamePlaySceneUI )
	self:lazyLoadRes()

	local anim = CocosObject:create()

	local animNode = self:createArmature("prop_line_animation/anim")
	animNode:setPositionX(150)
	animNode:setPositionY(50)
	anim:addChild(animNode)

	local effectNode = self:createArmature("prop_line_animation/effect")
	effectNode:setVisible(false)
	anim:addChild(effectNode)

	local function finish( ... )
		if gamePlaySceneUI then
			PropsAnimation:hideHighlightBoardView(gamePlaySceneUI)
		end
		
		anim:dispatchEvent(Event.new(Events.kComplete, nil, anim))
		animNode:setVisible(false)

		local t = GamePlayConfig_LineBrush_EFFECT_CD/GamePlayConfig_Action_FPS

		effectNode:setVisible(true)
		effectNode:playByIndex(0,1,t,0)
		effectNode:addEventListener(ArmatureEvents.COMPLETE,function( ... )
			anim:removeFromParentAndCleanup(true)
		end)
	end

	function anim:play( ... )
		if gamePlaySceneUI then
			PropsAnimation:showHighlightBoardView(gamePlaySceneUI)
		end

		local t = GamePlayConfig_LineBrush_Animation_CD/GamePlayConfig_Action_FPS

		local tail = PropsAnimation:createBlueTail(
			ccp(animNode:getPositionX(),animNode:getPositionY()),
			ccp(0,0),
			0.6 * t
		)
		self:addChild(tail)
		tail:setVisible(false)

		animNode:addEventListener(ArmatureEvents.BONE_FRAME_EVENT,function( ... )
			tail:setVisible(true)
			tail:play()
		end)

		animNode:addEventListener(ArmatureEvents.COMPLETE,finish)
		animNode:playByIndex(0,1,t,0)
	end

	return anim
end


function PropsAnimation:playLineEffect( lineType, r,c,boardView,callback )
	self:lazyLoadRes()

	local itemView = boardView.baseMap[r][c]
	local gameBoardLogic = boardView.gameBoardLogic
	local itemPos = itemView:getBasePosition(c,r)
	local layer = itemView.getContainer(ItemSpriteType.kPropsEffect)

	local effect = CocosObject:create()
	effect:setPositionX(itemPos.x)
	effect:setPositionY(itemPos.y)
	layer:addChild(effect)

	effect:runAction(CCCallFunc:create(function( ... )
		local item = itemView:getGameItemSprite()
		if item and item.refCocosObj then
			local oldScaleX,oldScaleY = item:getScaleX(),item:getScaleY()
			item:runAction(sequence(
				CCScaleTo:create(frameTime(2),1.2*oldScaleX,1.2*oldScaleY),
				CCScaleTo:create(frameTime(4),1.0*oldScaleX,1.0*oldScaleY)
			))
		end
	end))

	local animNode = self:createArmature("lineEffect/anim")
	effect:addChild(animNode)
	animNode:playByIndex(0,1,-1,0)

	local move1 = Sprite:createWithSpriteFrameName("props_animation_line_effect_bg0000")
	effect:addChild(move1)
	local move2 = Sprite:createWithSpriteFrameName("props_animation_line_effect_bg0000")
	effect:addChild(move2)
	move1:setAnchorPoint(ccp(1,0.5))
	move2:setAnchorPoint(ccp(1,0.5))

	local function createStars( ... )
		local stars = CocosObject:create()

		local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("props_animation_star0000")
		
		local h = 5
		for i=1,h do
			for j=1,math.random(i,i+3) do
				local star = Sprite:createWithSpriteFrame(frame)

				star:setAnchorPoint(ccp(0.5,0.5))
				star:setPositionX((i - 4)*10+math.random(10))

				star:setPositionY(math.random(-35 * i/h,35 * i/h))

				star:setScale(math.random(50,100)/100)

				local t = math.random(10,20)/30
				star:runAction(CCRepeatForever:create(sequence(
					CCFadeIn:create(t),
					CCFadeOut:create(t)
				)))

				stars:addChild(star)
			end
		end

		return stars
	end

	local stars1 = createStars()
	local stars2 = createStars()

	-- local stars1,animate1 = SpriteUtil:buildAnimatedSprite(frameTime(1),"lineEffect_stars%02d.png",0,14,false)
	-- stars1:runAction(CCRepeatForever:create(animate1))
	-- stars1:setAnchorPoint(ccp(0.5,0.5))
	-- local stars2,animate2 = SpriteUtil:buildAnimatedSprite(frameTime(1),"lineEffect_stars%02d.png",0,14,false)
	-- stars2:runAction(CCRepeatForever:create(animate2))
	-- stars2:setAnchorPoint(ccp(0.5,0.5))


	effect:addChild(stars1)
	effect:addChild(stars2)


	local fromPos1,fromPos2
	local toPos1,toPos2
	if lineType == AnimalTypeConfig.kLine then
		move1:setRotation(0)
		move2:setRotation(180)
		
		local toCol = c + 1
		for i=9,c,-1 do
			if gameBoardLogic:isItemCanUsed(r,i) then
				toCol = i + 1
				break
			end
		end
		fromPos1 = itemView:getBasePosition(c+0.5,r)
		toPos1 = itemView:getBasePosition(toCol+0.5,r)

		local toCol = c - 1
		for i=1,c do
			if gameBoardLogic:isItemCanUsed(r,i) then
				toCol = i - 1
				break
			end
		end
		fromPos2 = itemView:getBasePosition(c-0.5,r)
		toPos2 = itemView:getBasePosition(toCol-0.5,r)
	else
		stars1:setRotation(-90)
		move1:setRotation(-90)
		stars2:setRotation(90)
		move2:setRotation(90)

		local toRow = r - 1
		for i=1,r do
			if gameBoardLogic:isItemCanUsed(i,c) then
				toRow = i - 1
				break
			end
		end
		fromPos1 = itemView:getBasePosition(c,r-0.5)
		toPos1 = itemView:getBasePosition(c,toRow-0.5)

		local toRow = r + 1
		for i=9,c,-1 do
			if gameBoardLogic:isItemCanUsed(i,c) then
				toRow = i + 1
				break
			end		
		end
		fromPos2 = itemView:getBasePosition(c,r + 0.5)
		toPos2 = itemView:getBasePosition(c,toRow + 0.5)
	end

	for k,v in pairs({fromPos1,fromPos2,toPos1,toPos2}) do
		v.x = v.x - itemPos.x
		v.y = v.y - itemPos.y
	end

	move1:setPosition(fromPos1)
	move2:setPosition(fromPos2)
	stars1:setPosition(fromPos1)
	stars2:setPosition(fromPos2)

	move1:setScaleX(0.1)
	move2:setScaleX(0.1)
	local moveActions = {}
	local starsActions = {}
	for k,v in pairs({ {fromPos1,toPos1},{fromPos2,toPos2} }) do
		local from = v[1]
		local to = v[2]
		table.insert(moveActions,spawn(
			CCMoveTo:create(frameTime(10),to),
			CCScaleTo:create(frameTime(10),ccpLength(ccpSub(from,to))/230,1),
			CCFadeTo:create(frameTime(15),0.5*255)
		))

		table.insert(starsActions,spawn(
			CCFadeIn:create(frameTime(2)),
			CCMoveTo:create(frameTime(15),to)
		))
	end

	effect:runAction(sequence(
		spawn(
			target(move1,moveActions[1]),
			target(move2,moveActions[2]),
			target(stars1,starsActions[1]),
			target(stars2,starsActions[2])
		),
		CCCallFunc:create(function( ... )
			effect:removeFromParentAndCleanup(true)
			if callback then
				callback()
			end
		end)
	))
end


-- 小木槌 
function PropsAnimation:createHammerAnim( viberateCallback,gamePlaySceneUI )
	self:lazyLoadRes()

	local anim = CocosObject:create()

	local animNode = self:createArmature("prop_hammer_animation/anim")
	anim:addChild(animNode)

	local function finish( ... )
		if gamePlaySceneUI then
			PropsAnimation:hideHighlightBoardView(gamePlaySceneUI)
		end

		anim:dispatchEvent(Event.new(Events.kComplete, nil, anim))
		anim:removeFromParentAndCleanup(true)
	end

	function anim:play( ... )
		if gamePlaySceneUI then
			PropsAnimation:showHighlightBoardView(gamePlaySceneUI)
		end

		local t = GamePlayConfig_Hammer_Animation_CD/GamePlayConfig_Action_FPS

		animNode:addEventListener(ArmatureEvents.BONE_FRAME_EVENT,function( ... )
			if viberateCallback then
				viberateCallback()
			end
		end)

		animNode:addEventListener(ArmatureEvents.COMPLETE,finish)
		animNode:playByIndex(0,1,t * 2,0)
	end

	return anim
end

-- 强制交换
function PropsAnimation:playSwapHintEffect( r,c,boardView )
	self:lazyLoadRes()

	local gameBoardLogic = boardView.gameBoardLogic
	local itemView = boardView.baseMap[r][c]
	local layer = itemView.getContainer(ItemSpriteType.kSpecial)
	
	local effect = CocosObject:create()
	layer:addChild(effect)

    for k,v in pairs({ {r-1,c},{r+1,c},{r,c+1},{r,c-1} }) do
        if gameBoardLogic:isItemInTile(v[1],v[2]) then
        	if gameBoardLogic:canUseForceSwap(r,c,v[1],v[2]) then
				local border = ItemViewUtils:buildSelectBorder()
				border:setPosition(itemView:getBasePosition(v[2],v[1]))
				border:setColor(ccc3(0xFF,0xFF,0x68))
				border:setOpacity(255 * 0.6)

				effect:addChild(border)
			end
        end
    end

	function effect:remove( ... )
		self:removeFromParentAndCleanup(true)
	end

	return effect
end

function PropsAnimation:playForceSwapEffect(r1,c1,r2,c2,boardView)
	self:lazyLoadRes()

	local itemView1 = boardView.baseMap[r1][c1]
	local itemView2 = boardView.baseMap[r2][c2]
	local itemPos1 = itemView1:getBasePosition(c1,r1)
	local itemPos2 = itemView2:getBasePosition(c2,r2)
	local layer = itemView1.getContainer(ItemSpriteType.kSpecial)

	local t1 = GamePlayConfig_ForceSwapAction_Move_CD/GamePlayConfig_Action_FPS
	local t2 = GamePlayConfig_ForceSwapAction_Effect_CD/GamePlayConfig_Action_FPS

	local topAnim = self:createArmature("forceSwapEffect/anim")
	topAnim:setPositionX(itemPos1.x/2 + itemPos2.x/2)
	topAnim:setPositionY(itemPos1.y/2 + itemPos2.y/2)
	topAnim:setRotation(90 * (r1 - r2))
	topAnim:playByIndex(0,1,t1 + t2 * 0.5,0)	
	layer:addChild(topAnim)

	topAnim:addEventListener(ArmatureEvents.COMPLETE,function( ... )
		topAnim:removeFromParentAndCleanup(true)
	end)


	local leftArrowSlot = topAnim:getSlot("leftArrow")
	local leftArrowDisplay = tolua.cast(leftArrowSlot:getCCDisplay(),"CCSprite")
	local rightArrowSlot = topAnim:getSlot("rightArrow")
	local rightArrowDisplay = tolua.cast(rightArrowSlot:getCCDisplay(),"CCSprite")

	local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("props_animation_star0000")
	for k,v in pairs({ leftArrowDisplay,rightArrowDisplay }) do
		for i=5,math.random(10,20) do
			local star = CCSprite:createWithSpriteFrame(frame)
			star:setAnchorPoint(ccp(0.5,0.5))
			star:setScale(math.random(50,100)/100)
			star:setPositionX(math.random(10,40))
			star:setPositionY(math.random(20,80))

			local t = math.random(10,50)/100
			star:runAction(CCRepeatForever:create(sequence(
				CCFadeIn:create(t),
				CCFadeOut:create(t)
			)))

			v:addChild(star)
		end
	end

	local layer = itemView1.getContainer(ItemSpriteType.kPropsEffect)
	for k,v in pairs({itemPos1,itemPos2}) do
		local effect = self:createArmature("lineEffect/anim")
		effect:setPosition(v)
		layer:addChild(effect)

		effect:setVisible(false)
		effect:runAction(sequence(
			CCDelayTime:create(t1),
			CCCallFunc:create(function( ... )
				effect:setVisible(true)
				effect:playByIndex(0,1,t2,0)
			end)
		))

		effect:addEventListener(ArmatureEvents.COMPLETE,function( ... )
			effect:removeFromParentAndCleanup(true)
		end)
	end


end


-- 小木槌 
function PropsAnimation:createJamSpeardHammerAnim( viberateCallback,gamePlaySceneUI )
	self:lazyLoadRes()

	local anim = CocosObject:create()

	local animNode = self:createArmature("jasSpeard_anim/Hummer")
	anim:addChild(animNode)

	local function finish( ... )
		if gamePlaySceneUI then
			PropsAnimation:hideHighlightBoardView(gamePlaySceneUI)
		end

		anim:dispatchEvent(Event.new(Events.kComplete, nil, anim))
		anim:removeFromParentAndCleanup(true)
	end

	function anim:play( ... )
		if gamePlaySceneUI then
			PropsAnimation:showHighlightBoardView(gamePlaySceneUI)
		end

		local t = GamePlayConfig_Hammer_Animation_CD/GamePlayConfig_Action_FPS

		animNode:addEventListener(ArmatureEvents.BONE_FRAME_EVENT,function( ... )
			if viberateCallback then
				viberateCallback()
			end
		end)

		animNode:addEventListener(ArmatureEvents.COMPLETE,finish)
		animNode:playByIndex(0,1,t * 2,0)
	end

	return anim
end

-- 横竖直线特效小火箭
function PropsAnimation:createLineEffectAnim(viberateCallback, gamePlaySceneUI, isColumn)
	self:lazyLoadRes()

	local assetName = "prop_line_effect_animation/LineEffectProps_Row"
	if isColumn then
		assetName = "prop_line_effect_animation/LineEffectProps_Column"
	end

	local anim = CocosObject:create()
	local animNode = self:createArmature(assetName)
	anim:addChild(animNode:wrapWithBatchNode())

	local function finish( ... )
		-- if gamePlaySceneUI then
		-- 	PropsAnimation:hideHighlightBoardView(gamePlaySceneUI)
		-- end

		if anim and not anim.isDisposed then
			anim:dispatchEvent(Event.new(Events.kComplete, nil, anim))
			anim:removeFromParentAndCleanup(true)
		end
	end

	function anim:play( ... )
		-- if gamePlaySceneUI then
		-- 	PropsAnimation:showHighlightBoardView(gamePlaySceneUI)
		-- end

		animNode:addEventListener(ArmatureEvents.BONE_FRAME_EVENT,function( ... )
			if viberateCallback then
				viberateCallback()
			end
		end)

		animNode:addEventListener(ArmatureEvents.COMPLETE,finish)
		animNode:setAnimationScale(1.7)
		animNode:playByIndex(0, 1)
	end

	return anim
end
