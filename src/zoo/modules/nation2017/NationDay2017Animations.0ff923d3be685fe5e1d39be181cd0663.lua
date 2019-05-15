---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2017-09-04 17:38:18
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2017-09-29 10:46:36
---------------------------------------------------------------------------------------
NationDay2017Animations = class()

local kAnimationTimePerFrame = 1/30

function NationDay2017Animations:loadRes()
	FrameLoader:loadArmature("flash/nationday2017/nationday2017_animations", "nationday2017_animations", "nationday2017_animations")
end

function NationDay2017Animations:unloadRes()
	FrameLoader:unloadArmature("flash/nationday2017/nationday2017_animations", true)
end

function NationDay2017Animations:createHippoAnime()
	local animation = CocosObject.new(CCNode:create())
	local node = ArmatureNode:create("nationday_hippo")
	node:playByIndex(0, 1)   
	node:update(0.001)
	node:stop()
	animation:addChild(node)
	node:playByIndex(0, 0)
	return animation
end

function NationDay2017Animations:createBigBangAnime(onBomb, onFinish)
	local kAnimationTimePerFrame = 1 / 24 -- override
	local vSize 	= CCDirector:sharedDirector():getVisibleSize()

	local container = Layer:create()
	local bombLayer = Layer:create()
	local flashLayer = LayerColor:createWithColor(ccc3(255, 255, 255), vSize.width, vSize.height)
	flashLayer:setOpacity(0)
	local fireLayer = Layer:create()
	container:addChild(bombLayer)
	container:addChild(flashLayer)
	container:addChild(fireLayer)

	FrameLoader:loadArmature("flash/nationday2017/nationday2017_bigbang", "nationday2017_bigbang", "nationday2017_bigbang")
	local node = ArmatureNode:create("nationday2017_bigbang")
	node:playByIndex(0, 1)   
	node:update(0.001)
	node:stop()
	node:setScale(2.5)
	node:setVisible(false)
	node:setPosition(ccp(vSize.width/2, vSize.height/2))
	fireLayer:addChild(node)

	local bombSprite = Sprite:createWithSpriteFrameName("nd2017_addfive")
	bombLayer:addChild(bombSprite)
	bombSprite:setAnchorPoint(ccp(0.5, 0))
	bombSprite:setPosition(ccp(vSize.width/2, vSize.height))

	local bombHeight = bombSprite:getContentSize().height

	local function onBombArrive()
		bombSprite:setVisible(false)

		local flashActSeq = CCArray:create()
		flashActSeq:addObject(CCFadeIn:create(kAnimationTimePerFrame))
		flashActSeq:addObject(CCDelayTime:create(2*kAnimationTimePerFrame))
		flashActSeq:addObject(CCFadeOut:create(kAnimationTimePerFrame))
		flashLayer:runAction(CCSequence:create(flashActSeq))

		node:addEventListener(ArmatureEvents.COMPLETE,function( evt )
			if onFinish then onFinish() end
			container:removeFromParentAndCleanup(true)
			setTimeOut(function()
				FrameLoader:unloadArmature("flash/nationday2017/nationday2017_bigbang", true)
			end, 0)
		end)
		node:setVisible(true)
		node:playByIndex(0, 1) 

		if onBomb then onBomb() end
	end

	local bombActSeq = CCArray:create()
	local moveAct = CCMoveTo:create(9*kAnimationTimePerFrame, ccp(vSize.width/2, vSize.height/2 - bombHeight / 2))
	local scaleAct = CCScaleTo:create(9*kAnimationTimePerFrame, 131/141, 172/141)
	bombActSeq:addObject(CCSpawn:createWithTwoActions(moveAct, scaleAct))
	bombActSeq:addObject(CCScaleTo:create(2*kAnimationTimePerFrame, 163/141, 126/141))
	bombActSeq:addObject(CCScaleTo:create(2*kAnimationTimePerFrame, 1, 1))
	bombActSeq:addObject(CCCallFunc:create(onBombArrive))
	bombSprite:runAction(CCSequence:create(bombActSeq))

	return container
end

function NationDay2017Animations:unloadBigBangRes()
	FrameLoader:unloadArmature("flash/nationday2017/nationday2017_bigbang", true)
end

function NationDay2017Animations:createStarBoxDispear(flyToPos, onFinish, playCollectAnimFunc, chickenNum)
	-- assert(flyToPos)
	flyToPos = flyToPos and {x=flyToPos.x-15, y=flyToPos.y+15} or {x=0,y=0}
	local animation = CocosObject.new(CCNode:create())
	local node = ArmatureNode:create("nationday_starbox_dispear")
	node:playByIndex(0, 1)   
	node:update(0.001)
	node:stop()
	node:setPosition(ccp(-45,36))
	animation:addChild(node)
	node:playByIndex(0, 1)

	if chickenNum and chickenNum < 10 then -- 显示个数
		for idx = chickenNum+1, 10 do
			local starSlot = node:getSlot("star_"..idx)
			local starDisplay = tolua.cast(starSlot:getCCDisplay(),"CCSprite")
			starDisplay:setOpacity(0)
		end
	end

	node:addEventListener(ArmatureEvents.BONE_FRAME_EVENT,function( evt )
		if evt.data.frameLabel == "flyToTarget" then
			local idx = 10
			local function flyFunc()
				for i = 1, 2 do
					local starSlot = node:getSlot("star_"..idx)
					local starDisplay = tolua.cast(starSlot:getCCDisplay(),"CCSprite")

					local curPos = ccp(starDisplay:getPositionX(), starDisplay:getPositionY())
					local tarPos = starDisplay:getParent():convertToNodeSpace(ccp(flyToPos.x, flyToPos.y))
					local deltaX = tarPos.x - curPos.x
					local deltaY = tarPos.y - curPos.y
					local bezierConfig = ccBezierConfig:new()
					bezierConfig.controlPoint_1 = ccp(curPos.x + deltaX/5, curPos.y + deltaY*5/4)
					bezierConfig.controlPoint_2 = ccp(curPos.x + deltaX, curPos.y + deltaY)
					bezierConfig.endPosition = tarPos
					local bezierAction = CCBezierTo:create(0.4, bezierConfig)
					local actArr = CCArray:create()
					actArr:addObject(CCSpawn:createWithTwoActions(bezierAction, CCScaleTo:create(0.4, 0.5)))
					actArr:addObject(CCFadeTo:create(0, 0))
					if idx == 1 then
						actArr:addObject(CCCallFunc:create(function() if onFinish then onFinish() end end))
					elseif idx == 10 then
						actArr:addObject(CCCallFunc:create(function() if playCollectAnimFunc then playCollectAnimFunc(nil, true) end end))
					end
					local acts = CCSequence:create(actArr)
					starDisplay:runAction(acts)
					idx = idx - 1
					if idx < 1 then return end
				end
				if idx > 0 then
					node:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1/60),CCCallFunc:create(flyFunc)))
				end
			end
			node:runAction(CCCallFunc:create(flyFunc))
		end
	end)
	return animation
end

local NationDay2017UfoObject = class(CocosObject)

function NationDay2017UfoObject:ctor()

end

function NationDay2017UfoObject:create(animName)
	local object = NationDay2017UfoObject.new(CCNode:create())
	object:init(animName)
	return object
end

function NationDay2017UfoObject:init(animName)
	local node = ArmatureNode:create(animName)
	node:playByIndex(0, 1)
	node:update(0.001)
	node:stop()
	node:setPosition(ccp(-222,115))

	node:addEventListener(ArmatureEvents.COMPLETE,function( evt )
		if self.onCompleteLitener then self.onCompleteLitener(evt) end
	end)
	node:addEventListener(ArmatureEvents.BONE_FRAME_EVENT,function( evt )
		if self.frameEventLitener then self.frameEventLitener(evt) end
	end)

	local replaceNode = Sprite:createEmpty()
	local targetIcon = Sprite:createWithSpriteFrameName("nationday_star_0000")
	local targetNumLabel = BitmapText:create("0", "fnt/scene_icon_lable.fnt", -1, kCCTextAlignmentCenter)
	targetIcon:setScale(0.9)
	targetIcon:setPosition(ccp(28, -30))
	targetNumLabel:setPosition(ccp(28, -69))
	replaceNode:addChild(targetIcon)
	replaceNode:addChild(targetNumLabel)

	local targetSlot = node:getSlot("target_ph")
	replaceNode.refCocosObj:retain()
	targetSlot:setDisplayImage(replaceNode.refCocosObj, true)

	self.targetNode = replaceNode
	self.targetNumLabel = targetNumLabel

	local replaceNode2 = Sprite:createEmpty()

	self.bombNumNode = Sprite:createEmpty()
	self.bombNumLabel = BitmapText:create("0", "fnt/target_remain2.fnt", -1, kCCTextAlignmentCenter)
	self.bombNumLabel:setPosition(ccp(11, -22))
	self.bombNumNode:addChild(self.bombNumLabel)

	local bombNumSlot = node:getSlot("num_ph")
	self.bombNumNode.refCocosObj:retain()
	bombNumSlot:setDisplayImage(self.bombNumNode.refCocosObj, true)

	self.node = node
	self:addChild(node)
end

function NationDay2017UfoObject:dispose()
	self.targetNode:dispose()
	self.bombNumNode:dispose()
	CocosObject.dispose(self)
end

function NationDay2017UfoObject:updateTargetNum(tNum)
	self.targetNumLabel:setText(tostring(tNum))
end

function NationDay2017UfoObject:updateBombNum(bNum)
	self.bombNumLabel:setText(tostring(bNum))
end

function NationDay2017UfoObject:addOnCompleteLitener(onCompleteLitener)
	self.onCompleteLitener = onCompleteLitener
end

function NationDay2017UfoObject:addFrameEventLitener(frameEventLitener)
	self.frameEventLitener = frameEventLitener
end

function NationDay2017Animations:createUFOIdle()
	local animation = NationDay2017UfoObject:create("nationday_ufo_idle")
	-- local handArmature = animation.node:getSlot("hand_ph"):getCCChildArmature()
 --    local bombSprite = tolua.cast(handArmature:getCCSlot("z_0"):getCCDisplay(), "CCSprite")
	-- bombSprite:setVisible(false)
	-- bombSprite:setOpacity(0)
	return animation
end

function NationDay2017Animations:createUFOLoad()
	local animation = NationDay2017UfoObject:create("nationday_ufo_load")
	return animation
end

function NationDay2017Animations:createUFOReady()
	local animation = NationDay2017UfoObject:create("nationday_ufo_ready")
	return animation
end

function NationDay2017Animations:createUFOFire()
	local animation = NationDay2017UfoObject:create("nationday_ufo_fire")
	return animation
end

function NationDay2017Animations:createCollectEffect()
	local animation = CocosObject.new(CCNode:create())
	local sprite, animate = SpriteUtil:buildAnimatedSprite(kAnimationTimePerFrame, "nd2017_star_arrive_%04d", 0, 16, false)
	local function onRepeatFinishCallback()
		animation:removeFromParentAndCleanup(true)
	end
	sprite:play(animate, 0, 1, onRepeatFinishCallback, false)
	animation:addChild(sprite)
	return animation
end

function NationDay2017Animations:createBuffAnimation(buffType, value, frameType, headUrl, flyToPos, onFinish)
	local kAnimationTimePerFrame = 1 / 24 -- override
	local offsetX = -50
	flyToPos = flyToPos and {x = flyToPos.x, y = flyToPos.y} or {x = 0, y = 0}
	frameType = frameType or 1
	local builder = InterfaceBuilder:createWithContentsOfFile("flash/nationday2017/nationday2017_ingame_ui.json")
	local animation = CocosObject.new(CCNode:create())
	local header = builder:buildGroup("nationday2017_ingame_ui/user_header_"..tostring(frameType))
	animation:addChild(header)

	local function onImageLoadFinishCallback(headImage)
		if header.isDisposed then return end
		local placeHolder = header:getChildByName('header_holder')
		local scale = placeHolder:getGroupBounds().size.width / headImage:getContentSize().width
		headImage:setScale(scale)
		headImage:setAnchorPoint(ccp(-0.5, 0.5))
		headImage:setPosition(ccp(placeHolder:getPositionX(), placeHolder:getPositionY()))
		header:addChildAt(headImage, placeHolder:getZOrder())
		header.headSprite = headImage.headSprite
		header.headBackground = headImage.headBackground
		placeHolder:removeFromParentAndCleanup(true)
	end
	HeadImageLoader:create(nil, headUrl, onImageLoadFinishCallback)

	local tipNode = nil
	if buffType == 1 then
		tipNode = builder:buildGroup("nationday2017_ingame_ui/tip_addmove")
		local icon = tipNode:getChildByName("icon")
		local replaceIcon = Sprite:createWithSpriteFrameName("nationday2017_ingame_ui/addmove_"..tostring(value).."0000")
		replaceIcon:setAnchorPoint(ccp(0, 1))
		replaceIcon:setPosition(ccp(icon:getPositionX(), icon:getPositionY()))
		replaceIcon.name = "icon"
		tipNode:addChildAt(replaceIcon, icon:getZOrder())
		icon:removeFromParentAndCleanup(true)
	elseif buffType == 2 then
		tipNode = builder:buildGroup("nationday2017_ingame_ui/tip_bomb")
		local numLabel = tipNode:getChildByName("num")
		numLabel:changeFntFile("flash/nationday2017/universe.fnt")
		numLabel:setScale(1.3)
		numLabel:setPositionY(numLabel:getPositionY() + 5)
		numLabel:setText("+"..tostring(value))
	end
	if tipNode then
		tipNode:setPosition(ccp(60+offsetX, 25))
		animation:addChild(tipNode)
	end
	header:setPosition(ccp(offsetX, 0))

	local function playFlyAnim()
		header:getChildByName("bg"):setVisible(false)
		header:getChildByName("border"):runAction(CCFadeOut:create(4*kAnimationTimePerFrame))
		if header.headSprite and header.headSprite.refCocosObj then header.headSprite:runAction(CCFadeOut:create(4*kAnimationTimePerFrame)) end
		if header.headBackground then header.headBackground:setVisible(false) end

		if tipNode then
			local icon = tipNode:getChildByName("icon")
			local wPos = tipNode:convertToWorldSpace(icon:getPosition())
			icon:removeFromParentAndCleanup(false)
			local nPos = animation:convertToNodeSpace(wPos)
			icon:setPosition(nPos)
			animation:addChild(icon)
			for _, s in ipairs(tipNode.list) do
				if type(s.runAction) == "function" then
					s:runAction(CCFadeOut:create(4*kAnimationTimePerFrame))
				end
			end

			local toPos = animation:convertToNodeSpace(ccp(flyToPos.x, flyToPos.y))
			local controlPoint = ccp(nPos.x + (toPos.x - nPos.x) * 0.3, toPos.y + 50)
			local bezierConfig = ccBezierConfig:new()
			bezierConfig.controlPoint_1 = ccp(nPos.x, nPos.y)
			bezierConfig.controlPoint_2 = controlPoint
			bezierConfig.endPosition = toPos
			local bezierAction = CCBezierTo:create(10*kAnimationTimePerFrame, bezierConfig)
			local function onAnimFinish()
				animation:removeFromParentAndCleanup(true)
				if onFinish then onFinish() end
			end

			local iconActSeq = CCArray:create()
			iconActSeq:addObject(bezierAction)
			iconActSeq:addObject(CCSpawn:createWithTwoActions(CCDelayTime:create(6*kAnimationTimePerFrame), CCFadeOut:create(4*kAnimationTimePerFrame)))
			iconActSeq:addObject(CCCallFunc:create(onAnimFinish))
			icon:runAction(CCSequence:create(iconActSeq))
		end
	end

	animation:setScale(0.6)
	local actSeq = CCArray:create()
	actSeq:addObject(CCScaleTo:create(5*kAnimationTimePerFrame, 1.07, 1.07))
	actSeq:addObject(CCScaleTo:create(2*kAnimationTimePerFrame, 1, 1))
	actSeq:addObject(CCDelayTime:create(7*kAnimationTimePerFrame))
	actSeq:addObject(CCCallFunc:create(playFlyAnim))

	animation:runAction(CCSequence:create(actSeq))

	return animation
end