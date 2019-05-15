ItemViewUtils = class{}
local kCharacterAnimationTime = 1/30
function ItemViewUtils:buildLight(iceLevel, gameModeId)	--冰层
	if iceLevel == 0 then return nil end;

	if gameModeId == GameModeTypeId.OLYMPIC_HORIZONTAL_ENDLESS_ID then
		return ItemViewUtils:buildOlympicIce(iceLevel)
	end

	local sp = Sprite:createWithSpriteFrameName(string.format("ice_light_%d.png",iceLevel))
	if gameModeId ~= GameModeTypeId.SEA_ORDER_ID and iceLevel == 3 then
		sp:setOpacity(239)
	end
	return sp
end

function ItemViewUtils:buildLighttAction(oldIceLevel, callback)
	if not oldIceLevel or oldIceLevel > 3 or oldIceLevel < 1 then 
		oldIceLevel = 1
	end

	local sprite = Sprite:createWithSpriteFrameName("ice_light_"..oldIceLevel.."_0000.png")
	local frames = SpriteUtil:buildFrames("ice_light_"..oldIceLevel.."_%04d.png", 0, 19)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	local function onRepeatFinishCallback_Ice()
		sprite:dp(Event.new(Events.kComplete, nil, sprite));
		sprite:removeFromParentAndCleanup(true);
		if callback then callback() end
	end
	sprite:play(animate, 0, 1, onRepeatFinishCallback_Ice)
	return sprite;
end

function ItemViewUtils:buildTileBlocker( state, isReverseSide )
	-- body
	local tileBlocker = TileBlocker:create(state, isReverseSide)
	return tileBlocker

end

function ItemViewUtils:buildDoubleSideTileBlocker( state, isReverseSide )
	-- body
	local tileBlocker = TileDoubleSideBlocker:create(state, isReverseSide)
	return tileBlocker

end

function ItemViewUtils:buildMonsterFootAnimation(boardView, callback )
	-- body
	local time = 1.5
	local container = Sprite:createEmpty()
	
	local function animationCallback()
		if callback then callback() end
	end

	local function animationStart( ... )
		-- body
		local bright = Sprite:createWithSpriteFrameName("foot_bright")
		local dark = Sprite:createWithSpriteFrameName("foot_dark")
		container:addChild(dark)
		container:addChild(bright)

		bright:setScale(2.349)
		local arr_bright = CCArray:create()
		arr_bright:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(time * 5/35), CCScaleTo:create(time * 5/35, 1.175)))
		arr_bright:addObject(CCDelayTime:create(time * 3/35))
		arr_bright:addObject(CCScaleTo:create(time * 4/35, 1.41))
		arr_bright:addObject(CCScaleTo:create(time * 5/35, 1.175))
		arr_bright:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(time * 18/35), CCScaleTo:create(time * 18/35, 2)) )
		bright:runAction(CCSequence:create(arr_bright))

		dark:setScale(3.156)
		local arr_dark = CCArray:create()
		arr_dark:addObject(CCScaleTo:create(time * 5/35, 1.578))
		arr_dark:addObject(CCScaleTo:create(time * 8/35, 1.736))
		arr_dark:addObject(CCScaleTo:create(time * 7/35, 1.578))
		arr_dark:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create( time * 15/35), CCScaleTo:create(time * 15/35, 2)) )
		arr_dark:addObject(CCCallFunc:create(animationCallback))
		dark:runAction(CCSequence:create(arr_dark))

		boardView:viberate()

	end

	container:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1.5), CCCallFunc:create(animationStart)))

	return container
end

local kOlympicIceOffsetByLevel = {}
kOlympicIceOffsetByLevel[1] = {x = -5, y = -6}
kOlympicIceOffsetByLevel[2] = {x = -4.5, y = -15}
function ItemViewUtils:buildOlympicIce(iceLevel)
	if iceLevel < 1 or iceLevel > 2 then 
		assert(false, "iceLevel="..tostring(iceLevel))
		return nil
	end
	local node = Sprite:createEmpty()
	local str_temp = string.format("ZQ_ice_lv%d_0000",iceLevel)
	local sprite = Sprite:createWithSpriteFrameName(str_temp)
	node:setTexture(sprite:getTexture())
	node:addChild(sprite)
	local offsetPos = kOlympicIceOffsetByLevel[iceLevel]
	if offsetPos then
		sprite:setPosition(ccp(offsetPos.x, offsetPos.y))
	end
	return node
end

function ItemViewUtils:buildOlympicIceDecAction(iceLevel, callback)
	if iceLevel < 1 or iceLevel > 2 then
		assert(false, iceLevel)
		return nil
	end
	local animateNode = Sprite:createEmpty()
	local pattern = "ZQ_ice_lv"..tostring(iceLevel).."_%04d"
	--local pattern = "olympic_ice_lv"..tostring(iceLevel).."_%04d"
	local sprite = Sprite:createWithSpriteFrameName(string.format(pattern, 0))
	local length = 0
	if iceLevel == 2 then 
		length = 25 
	elseif iceLevel == 1 then 
		length = 25 
	end
	local frames = SpriteUtil:buildFrames(pattern, 0, length)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	local function onRepeatFinishCallback_Ice()
		animateNode:removeFromParentAndCleanup(true);
		if callback then callback() end
	end
	sprite:play(animate, 0, 1, onRepeatFinishCallback_Ice)
	local offsetPos = kOlympicIceOffsetByLevel[iceLevel]
	if offsetPos then
		sprite:setPosition(ccp(offsetPos.x, offsetPos.y))
	end
	animateNode:addChild(sprite)
	animateNode:setTexture(sprite:getTexture())
	return animateNode;	
end

function ItemViewUtils:buildLockAction()
	local pattern = "Lock%04d.png"
	local sprite = Sprite:createWithSpriteFrameName("Lock0001.png")

	local frames = SpriteUtil:buildFrames(pattern, 0, 39)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	local function onRepeatFinishCallback_Lock()
		sprite:dp(Event.new(Events.kComplete, nil, sprite));
		sprite:removeFromParentAndCleanup(true);
	end
	sprite:play(animate, 0, 1, onRepeatFinishCallback_Lock)
	return sprite;
end

function ItemViewUtils:buildSnowAction(snowLevel)
	local pattern = string.format("frosting%d", snowLevel)
	local str_temp = "%04d.png"
	pattern = pattern..str_temp
	local sprite = Sprite:createWithSpriteFrameName(string.format("frosting%d0000.png", snowLevel))

	local frames = SpriteUtil:buildFrames(pattern, 0, GamePlayConfig_SnowDeleted_Action_Count[snowLevel])
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)

	local function onRepeatFinishCallback_Snow()
		sprite:dp(Event.new(Events.kComplete, nil, sprite))
		sprite:removeFromParentAndCleanup(true);
	end
	sprite:play(animate, 0, 1, onRepeatFinishCallback_Snow)
	return sprite
end

function ItemViewUtils:buildCrystal(colortype, hasActCollection)
	if colortype == 0 then return nil end;
	local colorIndex = AnimalTypeConfig.convertColorTypeToIndex(colortype)
	local str_temp = string.format("CrystalBall%02d.png", colorIndex)
	local sp = Sprite:createWithSpriteFrameName(str_temp)
	if hasActCollection then 
		local actCollectIcon = Sprite:createWithSpriteFrameName("item_act_collection.png")
		actCollectIcon:setPosition(ccp(52, 18))
		sp:addChild(actCollectIcon)
		sp.actCollectIcon = actCollectIcon
	end
	return sp;
end

function ItemViewUtils:buildGift(colortype)
	if colortype == 0 then return nil end
	local colorIndex = AnimalTypeConfig.convertColorTypeToIndex(colortype)
	local str_temp = string.format("gift%d.png", colorIndex)
	return Sprite:createWithSpriteFrameName(str_temp)
end

function ItemViewUtils:buildSnow(snowLevel)
	if snowLevel == 0 then return nil end;

	local str_temp = string.format("frosting%d.png",snowLevel)
	return Sprite:createWithSpriteFrameName(str_temp);
end

function ItemViewUtils:buildLocker(cageLevel)
	if cageLevel == 0 then return nil end;
	local str_temp = string.format("Lock%d.png",cageLevel)
	return Sprite:createWithSpriteFrameName(str_temp);
end

function ItemViewUtils:buildBeanpod(itemShowType)
	return TileBeanpod:create(itemShowType)
end

function ItemViewUtils:buildAnimalStatic(colortype)
	local colorIndex = AnimalTypeConfig.convertColorTypeToIndex(colortype)
	if _G.kStaticAnimalUseHDRes then
		local str_temp = GamePlayResourceConfig:getStaticItemHDSpriteName(colorIndex)
		local sprite = Sprite:createWithSpriteFrameName(str_temp)
		-- sprite:setScale(72/84) -- 放大1.03倍

		local spriteNode = Sprite:createEmpty()
		spriteNode:setTexture(sprite:getTexture())
		spriteNode:setCascadeOpacityEnabled(true)
		spriteNode.colorIndex = colorIndex
		spriteNode:addChild(sprite)
		return spriteNode
	else
		local str_temp = GamePlayResourceConfig:getStaticItemSpriteName(colorIndex)
		local sprite = Sprite:createWithSpriteFrameName(str_temp)
		sprite.colorIndex = colorIndex
		return sprite
	end
end

function ItemViewUtils:buildWrapLineEffectLineAnimate(name, specialType)
	local animate = nil
	if name then
		local timePerFrame = 1 / 35
		animate = TileCharacter:createCharactorSprite(name, specialType)
		if not animate then return end

		local finalScaleX = 2.12
		local finalScaleY = 1.77
  		if specialType == AnimalTypeConfig.kColumn then
  			finalScaleX = 1.77
			finalScaleY = 2.12
  		end

		local function onAnimComplete()
			animate:removeFromParentAndCleanup(true)
		end
		animate:setVisible(false)

		local actionSeq = CCArray:create()
		actionSeq:addObject(CCDelayTime:create(3*timePerFrame))
		actionSeq:addObject(CCShow:create())
		actionSeq:addObject(CCScaleTo:create(3*timePerFrame, 1.72))
		actionSeq:addObject(CCScaleTo:create(2*timePerFrame, 1.65))
		actionSeq:addObject(CCDelayTime:create(6*timePerFrame))
		actionSeq:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(4*timePerFrame), CCScaleTo:create(4*timePerFrame, finalScaleX, finalScaleY)))
		actionSeq:addObject(CCCallFunc:create(onAnimComplete))
		animate:runAction(CCSequence:create(actionSeq))
	end
	return animate
end

local buildAnimalDestroyEffect_names = table.const {
	"animal_explode_"..tostring(1).."_%04d",
	"animal_explode_"..tostring(2).."_%04d",
	"animal_explode_"..tostring(3).."_%04d",
	"animal_explode_"..tostring(4).."_%04d",
	"animal_explode_"..tostring(5).."_%04d",
	"animal_explode_"..tostring(6).."_%04d",
}
local buildAnimalDestroyEffect_names1 = table.const {
	string.format(buildAnimalDestroyEffect_names[1], 0),
	string.format(buildAnimalDestroyEffect_names[2], 0),
	string.format(buildAnimalDestroyEffect_names[3], 0),
	string.format(buildAnimalDestroyEffect_names[4], 0),
	string.format(buildAnimalDestroyEffect_names[5], 0),
	string.format(buildAnimalDestroyEffect_names[6], 0),
}

function ItemViewUtils:buildAnimalDestroyEffect(colorIndex, callback)
	colorIndex = tonumber(colorIndex) 
	if not colorIndex or colorIndex < 1 or colorIndex > 6 then
		colorIndex = 1 -- force set 1
	end
	local pattern = buildAnimalDestroyEffect_names[colorIndex] --"animal_explode_"..tostring(colorIndex).."_%04d"
	local destroySprite = Sprite:createWithSpriteFrameName(buildAnimalDestroyEffect_names1[colorIndex]) --string.format(pattern, 0))

	destroySprite:setOpacity(0)
	local frames = SpriteUtil:buildFrames(pattern, 0, 17)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)	

	local container = Sprite:createEmpty()
	container:setTexture(destroySprite:getTexture())

	local function onRepeatFinishCallback_DestroyEffect()
		container:removeFromParentAndCleanup(true)
		if callback then callback() end
	end 
	destroySprite:play(CCSequence:createWithTwoActions(CCFadeIn:create(0), animate), 0, 1, onRepeatFinishCallback_DestroyEffect)
	-- destroySprite:setPosition(ccp(-12, 10))

	container:addChild(destroySprite)
	return container
end

function ItemViewUtils:buildTotemsTileHighLight()
	local sprite = Sprite:createWithSpriteFrameName("tile_light_totems_0000")
	local spriteAnimate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("tile_light_totems_%04d", 0, 5), 1/15)
	sprite:runAction(CCRepeatForever:create(spriteAnimate))
	sprite:setPosition(ccp(0, -1))
	
	local node = Sprite:createEmpty()
	node:setTexture(sprite:getTexture())
	node:addChild(sprite)
	return node
end

function ItemViewUtils:buildMixTileHighLight(callback)
	local sprite = Sprite:createWithSpriteFrameName("tile_light_special")
	sprite:setOpacity(0)

	local function onActionFinished()
		sprite:removeFromParentAndCleanup(true)
		if type(callback) == "function" then callback() end
	end
	local actionSeq = CCArray:create()
	actionSeq:addObject(CCFadeTo:create(3*kCharacterAnimationTime, 128))
	actionSeq:addObject(CCFadeTo:create(10*kCharacterAnimationTime, 0))
	actionSeq:addObject(CCCallFunc:create(onActionFinished))
	sprite:runAction(CCSequence:create(actionSeq))
	return sprite
end

function ItemViewUtils:buildWarnningTileHighLight()
	local sprite = Sprite:createWithSpriteFrameName("olympic_high_light")
	sprite:setOpacity(0)
	-- sprite:setScale(1.1)
	local array = CCArray:create()
	array:addObject(CCFadeIn:create(6/24))
	array:addObject(CCFadeOut:create(6/24))
	-- array:addObject(CCDelayTime:create(0.1))
	sprite:runAction(CCRepeatForever:create(CCSequence:create(array)))
	sprite:setPosition(ccp(1, -1))

	local node = Sprite:createEmpty()
	node:setTexture(sprite:getTexture())	
	node:addChild(sprite)
	return node
end

function ItemViewUtils:buildFurball(furballType)
	local name
	if furballType == GameItemFurballType.kGrey then
		name = "ball_grey"
	elseif furballType == GameItemFurballType.kBrown then
		name = "ball_brown"
	end
	local furballsprite = TileCuteBall:create(name)
	return furballsprite
end

function ItemViewUtils:buildSand(sandLevel)
	local sprite = TileSand:createIdleSand()
	return sprite
end

function ItemViewUtils:buildSelectBorder()
	local view = Sprite:createWithSpriteFrameName("animal_selected_border_0000")
	local frames = SpriteUtil:buildFrames("animal_selected_border_%04d", 0, 30)
	local animate = SpriteUtil:buildAnimate(frames, 1 / 30)
	view:play(animate)
	return view
end

function ItemViewUtils:buildMonsterFrosting(frostingType)
	local view = TileMonsterFrosting:create(frostingType)
	return view
end

function ItemViewUtils:createQuestionMark(colortype)
	if colortype == 0 then return nil end
	local view = TileQuestionMark:create(colortype)
	return view
end

function ItemViewUtils:buildScrollBackGround(boderInfo)
	local view = Sprite:createWithSpriteFrameName("tile_center.png")

	local function createSprite(frameName, x, y, scaleX, scaleY, rotation)
		local sprite = Sprite:createWithSpriteFrameName(frameName)
		sprite:setAnchorPoint(ccp(0, 0))
		sprite:setPosition(ccp(x, y))
		sprite:setScaleX(scaleX)
		sprite:setScaleY(scaleY)
		sprite:setRotation(rotation)
		return sprite
	end 

	if boderInfo and type(boderInfo) == "table" then 
		for k,v in pairs(boderInfo) do
			view:addChild(createSprite(unpack(v)))
		end
	end

	return view
end




