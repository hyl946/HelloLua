local UIHelper = require 'zoo.panel.UIHelper'

local function mask(opacity, touchDelay, position, radius, clickCallback)
	touchDelay = touchDelay or 0
	local wSize = CCDirector:sharedDirector():getWinSize()
	local mask = LayerColor:create()
	mask:changeWidthAndHeight(wSize.width, wSize.height)
	mask:setColor(ccc3(0, 0, 0))
	mask:setOpacity(opacity)
	mask:setPosition(ccp(0, 0))
	local node
	node = Sprite:createWithSpriteFrameName("circle0000")
	radius = radius or 1
	node:setScale(radius)
	node:setPosition(ccp(position.x, position.y))
	local blend = ccBlendFunc()
	blend.src = GL_ZERO
	blend.dst = GL_ONE_MINUS_SRC_ALPHA
	node:setBlendFunc(blend)
	mask:addChild(node)
	local layer = CCRenderTexture:create(wSize.width, wSize.height)
	layer:setPosition(ccp(wSize.width / 2, wSize.height / 2))
	layer:begin()
	mask:visit()
	layer:endToLua()
	mask:dispose()
	local layerSprite = layer:getSprite()
	local obj = CocosObject.new(layer)
	local trueMaskLayer = Layer:create()
	trueMaskLayer:addChild(obj)
	trueMaskLayer:setTouchEnabled(true, 0, true)
	local function onTouch(evt) 
		if clickCallback then
			clickCallback(evt.globalPosition)
		end
	end

	local function beginSetTouch() trueMaskLayer:ad(DisplayEvents.kTouchBegin, onTouch) end
	local arr = CCArray:create()
	trueMaskLayer:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(touchDelay), CCCallFunc:create(beginSetTouch)))
	trueMaskLayer.setFadeIn = function(maskDelay, maskFade)
		layerSprite:setOpacity(0)
		layerSprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(maskDelay), CCFadeIn:create(maskFade)))
	end	
	trueMaskLayer.layerSprite = layerSprite
	return trueMaskLayer
end


local UserReviewGuide = {}

function UserReviewGuide:createGuide_1( ... )
	local guide = UserReviewGuide:create('user_review.ui/guide-1', 'user.review.anim/anim-1')
	return guide
end

function UserReviewGuide:createGuide_2( ... )
	local guide = UserReviewGuide:create('user_review.ui/guide-2', 'user.review.anim/anim-2')
	return guide
end

function UserReviewGuide:createGuide_3( ... )
	local guide = UserReviewGuide:create('user_review.ui/guide-3', 'user.review.anim/anim-2')
	return guide
end

function UserReviewGuide:create( res1, res2 )
	local ui = UIHelper:createUI('ui/user_review.json', res1)
	local anim = UIHelper:createArmature2('skeleton/user_review_anim', res2)
	ui:addChild(anim)
	anim:playByIndex(0, 0)
	anim.name = 'animal'
	return ui
end

function UserReviewGuide:popGuide( guide, guideLayer, position, radius, doAction, closeGuideHandler, offset)
	local guideContainer = Layer:create()
	local mask = mask(200, 0, position, radius, function ( clickPosition )

		if closeGuideHandler then
			closeGuideHandler()
		else
			GameGuide:sharedInstance():onGuideComplete()
		end
		local dx = position.x - clickPosition.x
		local dy = position.y - clickPosition.y

		local dist = math.sqrt(dx * dx + dy * dy)
		if dist < 100 then
			if doAction then 
				doAction() 
			end
		end

	end)
	guideContainer:addChild(mask)
	guideContainer:addChild(guide)
	guideLayer:addChild(guideContainer)
	offset = offset or ccp(0, 0)
	guide:setPosition(ccp(position.x + offset.x, position.y + offset.y))
	guideContainer.name = 'UserReviewGuide'

	UserReviewGuide:playGuideAppearAnim(guide)
end

local animalPos

function UserReviewGuide:cacheAnimalPos( guide )
	-- body
	animalPos = guide:getChildByName('animal'):getPosition()
	animalPos = ccp(animalPos.x, animalPos.y)
	animalPos = guide:convertToWorldSpace(animalPos)
end



function UserReviewGuide:playGuideAppearAnim( guide )
	local dialog = guide:getChildByName('dialog')
	dialog:setScale(0)	
	dialog:runAction(UIHelper:sequence{
		CCDelayTime:create(0.7),
		CCScaleTo:create(0.5, 1, 1),
	})

	local animal = guide:getChildByName('animal')

	if animalPos then
		local oldPos = animal:getPosition()
		oldPos = ccp(oldPos.x, oldPos.y)
		animalPos = guide:convertToNodeSpace(animalPos)
		animal:setPosition(animalPos)
		animalPos = nil
		animal:runAction(UIHelper:sequence{
			CCDelayTime:create(0),
			CCMoveTo:create(0.5, oldPos),
		})
	else
		UIHelper:move(animal, 720, 0)
		animal:runAction(UIHelper:sequence{
			CCDelayTime:create(0.5),
			CCMoveBy:create(0.5, ccp(-720, 0)),
		})
	end
end

function UserReviewGuide:runGuide_1( guideLayer )

	local panel = GameGuideData:sharedInstance().currPopPanel
	if panel and panel.getUserReviewBtnPos then
		local pos = panel:getUserReviewBtnPos()
		if pos then
			local guide = UserReviewGuide:createGuide_1()
			UserReviewGuide:popGuide(guide, guideLayer, pos, 1.5, function ( ... )
				if panel and panel.clickUserReviewBtn then
					panel:clickUserReviewBtn()
				end
			end)
			return true
		end
	end
end


function UserReviewGuide:tryShowGuide_1( pos, size, doAction, done )
	local guide = UserReviewGuide:createGuide_1()
	local curScene = Director:sharedDirector():getRunningSceneLua()
	local guideLayer = curScene.guideLayer

	UserReviewGuide:popGuide(guide, guideLayer, pos, 1.4, function ( ... )

		

		if doAction then doAction() end
	end, function ( ... )
		if guideLayer and (not guideLayer.isDisposed) then
			guideLayer:removeChildren(true)
		end
		if done then done() end
	end, ccp(size.width/2, -size.height/2))

    UserLocalLogic:setGuideFlag( kGuideFlags.kUserReview_1 )

end

return UserReviewGuide