
TileQuestionMark = class(CocosObject)

local kCharacterAnimationTime = 1/30

function TileQuestionMark:create(colorType)
	colorType = AnimalTypeConfig.convertColorTypeToIndex(colorType)
	local node = TileQuestionMark.new(CCNode:create())
	node.name = "question_mark"

	local goldBg = Sprite:createWithSpriteFrameName("question_mark_gold_0000")
	goldBg:setPositionY(-1)
	node:addChild(goldBg)
	goldBg:runAction(
		CCRepeatForever:create(CCSequence:createWithTwoActions(
			CCScaleTo:create(1, 0.9), CCScaleTo:create(1, 1)
			))
		)

	local question_mark = Sprite:createWithSpriteFrameName("question_mark_"..colorType)
	question_mark.name = "tile_question_mark"
	-- question_mark:setScaleY(2)
	node:addChild(question_mark)
	node.mark = question_mark

	return node
end

function TileQuestionMark:getBgLight(callback)
	local sprite = Sprite:createWithSpriteFrameName("question_mark_light")
	sprite:setScale(0.5)
	local function local_callback( ... )
		-- body
		if callback then callback() end
	end 
	local actionList = CCArray:create()
	actionList:addObject(CCScaleTo:create(2/24, 1))
	actionList:addObject(CCFadeOut:create(7/24))
	actionList:addObject(CCCallFunc:create(local_callback))
	sprite:runAction(CCSequence:create(actionList))
	return sprite
end

function TileQuestionMark:getFgLight( callback )
	-- body
	local sprite = Sprite:createWithSpriteFrameName("question_mark_star")
	sprite:setScale(0.48)
	local function local_callback( ... )
		-- body
		if callback then callback() end
	end 
	local actionList = CCArray:create()
	actionList:addObject(CCScaleTo:create(2/24, 0.88))
	actionList:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(7/24), CCScaleTo:create(7/24, 1.4)))
	actionList:addObject(CCCallFunc:create(local_callback))
	sprite:runAction(CCSequence:create(actionList))
	return sprite
end