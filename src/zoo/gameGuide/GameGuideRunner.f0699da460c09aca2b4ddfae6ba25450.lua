require "zoo.gameGuide.GameGuideAnims"
require "zoo.gameGuide.GameGuideUI"
require 'zoo.gameGuide.IngamePropGuideManager'


GameGuideRunner = {}

local released = true -- 标志是否已经被调用释放函数，和瓢虫动画共同引起的栈溢出找出具体原因之前使用此方法暴力解决

function GameGuideRunner:runGuide(paras)

	local action = GameGuideData:sharedInstance():getRunningAction()
	local funcName = "run" .. string.upper(string.sub(action.type, 1, 1)) .. string.sub(action.type, 2)
	if type(self[funcName]) == "function" then
		printx( -5 , "   GameGuideRunner:runGuide  " , funcName)
		if GameSpeedManager:getGameSpeedSwitch() > 0 then
			GameSpeedManager:resuleDefaultSpeed()
		end
		self[funcName](self, paras)
	else
		assert(false, "Invalid game guide action type: "..tostring(action.type))
	end

end

function GameGuideRunner:removeGuide(paras)

	local guide = nil
	local guides = GameGuideData:sharedInstance():getGuides()
	local guideIndex = GameGuideData:sharedInstance():getGuideIndex()
	if guides and guideIndex then
		guide = guides[guideIndex]
	end
	printx( -5 , "   GameGuideRunner:removeGuide  " , guide)
	if GameSpeedManager:getGameSpeedSwitch() > 0 then
		GameSpeedManager:changeSpeedForFastPlay()
	end
	if guide and guide.appear then
		printx( -5 , "  " , table.tostring(guide) )
		for k,v in pairs(guide.appear) do
			if v.type == "continuousFailed" then
				local levelId = GameGuideData:sharedInstance():getLevelId()
				FUUUManager:clearContinuousFailuresForGuide(levelId , true)
			end
		end
	end

	local action = GameGuideData:sharedInstance():getRunningAction()
	local funcName = "remove" .. string.upper(string.sub(action.type, 1, 1)) .. string.sub(action.type, 2)
	if type(self[funcName]) == "function" then
		return self[funcName](self, paras)
	else
		assert(false, "Invalid game guide action type: "..tostring(action.type))
		return false, false
	end
end

function GameGuideRunner:runClickFlower()
	local action = GameGuideData:sharedInstance():getRunningAction()
	local scene = HomeScene:sharedInstance()
	local pos = scene:getPositionByLevel(action.para)
	local hand = GameGuideAnims:handclickAnim(action.handDelay, action.handFade)
	hand:setAnchorPoint(ccp(0, 1))
	hand:setPosition(ccp(pos.x + 10, pos.y - 80))
	if scene.worldScene.guideLayer then
		HomeScene:sharedInstance().worldScene.guideLayer:addChild(hand)
		released = false
	end
end

function GameGuideRunner:removeClickFlower()
	if released then return false, false end
	local scene = HomeScene:sharedInstance()
	released = true
	if scene.worldScene.guideLayer then
		scene.worldScene.guideLayer:removeChildren(true)
	end
	return true, true
end

function GameGuideRunner:runStartPanel(paras)
	if not paras or type(paras) ~= "table" then return end
	local action = GameGuideData:sharedInstance():getRunningAction()
	local hand = GameGuideAnims:handclickAnim(action.handDelay, action.handFade)
	hand:setAnchorPoint(ccp(0, 1))
	local startPanel = paras.actWin
	local pos = startPanel.levelInfoPanel.startButton:getPositionInScreen()
	local size = startPanel.levelInfoPanel.startButton:getGroupBounds().size
	if startPanel.levelInfoPanel.userGuideLayer then
		pos = startPanel.levelInfoPanel.userGuideLayer:convertToNodeSpace(pos)
		hand:setPosition(ccp(pos.x + 65, pos.y - 10))
		startPanel.levelInfoPanel.userGuideLayer:addChild(hand)
		GameGuideData:sharedInstance():setLayer(startPanel.levelInfoPanel.userGuideLayer)
		released = false
	end
end

function GameGuideRunner:removeStartPanel()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end

	return true, true
end

function GameGuideRunner:runCustomAction(paras)
	local action = GameGuideData:sharedInstance():getRunningAction()
	local func = action.func
	local function onComplete() GameGuide:sharedInstance():onGuideComplete() end
	if type(func) == 'function' then
		func(onComplete)
	else
		onComplete()
	end
end

function GameGuideRunner:removeCustomAction( ... )
	if released then return false, false end
	released = true
	return true, true
end


local function getRealPlistPath(path)
	local plistPath = path
	if __use_small_res then  
		plistPath = table.concat(plistPath:split("."),"@2x.")
	end

	return plistPath
end


function GameGuideRunner:runShowSnail()
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(getRealPlistPath("flash/gameguide/snail_guide_frames.plist"))
	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0.4
	action.maskFade = action.maskFade or 0.4
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local panel = GameGuideUI:panelS(playUI, action, true)
	local ox, oy = 0, 0
	local winSize = Director:sharedDirector():getWinSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
	local visibleSize = Director:sharedDirector():getVisibleSize()
	local groups = {}
	local roadMatrix = {
		{x=8,y=2, r=0}, {x=8,y=3,r=0}, {x=8,y=4,r=0}, {x=8,y=5,r=0}, {x=8,y=6,r=0}, 
		{x=3,y=7,r=90}, {x=4,y=7,r=90}, {x=5,y=7,r=90}, {x=6,y=7,r=90}, {x=7,y=7,r=90},
		{x=2,y=4,r=180}, {x=2,y=5,r=180}, {x=2,y=6,r=180}, 
		{x=3,y=3,r=270}, {x=4,y=3,r=270}, {x=5,y=3,r=270}, 	
	}
	local cornerMatrix = {{x=8,y=7,r=180}, {x=2,y=7,r=270}, {x=2,y=3,r=0}, {x=6,y=3,r=90}}
	local endMatrix = {{x=8, y=1, r=0, snail=true}, {x=6, y=4, r=0}}
	for k, v in pairs(roadMatrix) do
		local pos = playUI.gameBoardLogic:getGameItemPosInView(v.y, v.x)
		if layer then
			pos = layer:convertToNodeSpace(pos)
		end
		local sprite = Sprite:createWithSpriteFrameName('snail_guide_road_0000')
		sprite:setRotation(v.r)
		sprite:setPosition(pos)
		sprite:play(SpriteUtil:buildAnimate(SpriteUtil:buildFrames('snail_guide_road_%04d', 0, 21), 1/20))
		table.insert(groups, sprite)
	end
	for k, v in pairs(cornerMatrix) do
		local pos = playUI.gameBoardLogic:getGameItemPosInView(v.y, v.x)
		if layer then
			pos = layer:convertToNodeSpace(pos)
		end
		local sprite = Sprite:createWithSpriteFrameName('snail_guide_corner_0000')
		sprite:setRotation(v.r)
		sprite:setPosition(pos)
		sprite:play(SpriteUtil:buildAnimate(SpriteUtil:buildFrames('snail_guide_corner_%04d', 0, 21), 1/20))
		table.insert(groups, sprite)
	end
	for k, v in pairs(endMatrix) do
		local pos = playUI.gameBoardLogic:getGameItemPosInView(v.y, v.x)
		if layer then
			pos = layer:convertToNodeSpace(pos)
		end
		local sprite = Sprite:createWithSpriteFrameName('snail_guide_road_0000')
		sprite:setRotation(v.r)
		sprite:setPosition(pos)
		sprite:play(SpriteUtil:buildAnimate(SpriteUtil:buildFrames('snail_guide_road_%04d', 0, 21), 1/20))
		table.insert(groups, sprite)
		local sprite2 = Sprite:createWithSpriteFrameName('snail_guide_end_0000')
		sprite2:setRotation(v.r)
		sprite2:setPosition(pos)
		sprite2:play(SpriteUtil:buildAnimate(SpriteUtil:buildFrames('snail_guide_end_%04d', 0, 30), 1/20))
		table.insert(groups, sprite2)
		if v.snail then
			local sprite3 = Sprite:createWithSpriteFrameName('snail_guide_body_0000')
			sprite3:setRotation(v.r)
			sprite3:setPosition(pos)
			table.insert(groups, sprite3)
		end
	end

	local trueMask = GameGuideUI:mask(action.opacity, action.touchDelay, ccp(-300, -300), 0, false, 100, 100, false)
	trueMask.setFadeIn(action.maskDelay, action.maskFade)

	if playUI and playUI.gameBoardLogic then
		playUI.gameBoardLogic:stopEliminateAdvise()
		playUI.gameBoardView:focusOnItem(nil)
	end


	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)
		for k, v in pairs(groups) do
			v:setOpacity(0)
			v:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.maskDelay), CCFadeIn:create(0.3)))
			layer:addChild(v)
		end
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end
end

function GameGuideRunner:removeShowSnail()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(getRealPlistPath("flash/gameguide/snail_guide_frames.plist"))

	return true, true
end

function GameGuideRunner:runPopImage()
	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0.4
	action.maskFade = action.maskFade or 0.4
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local panel = GameGuideUI:panelS(playUI, action, true)

	-- if action.groupName then
	local ox, oy = 0, 0
	local winSize = Director:sharedDirector():getWinSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
	local visibleSize = Director:sharedDirector():getVisibleSize()
	if _G.isLocalDevelopMode then printx(0, 'winSize', winSize.width, winSize.height) end
	if _G.isLocalDevelopMode then printx(0, 'visibleSize', visibleSize.width, visibleSize.height) end
	-- debug.debug()

	local groups = {}

	for k, v in pairs(action.pics) do
		v.x = v.x or 0
		v.y = v.y or 0

		local extraScale = v.scale
		local group = ResourceManager:sharedInstance():buildGroup(v.groupName)


		if v.align == 'board' then -- 用棋盘网格对其
			local pos = playUI.gameBoardLogic:getGameItemPosInView(v.y, v.x)
			if layer then
				pos = layer:convertToNodeSpace(pos)
			end
			group:setPosition(pos)
			local scale = playUI.gameBoardView:getScale()
			group:setScale(scale * extraScale)
			table.insert(groups, group)
		else  ---------------------------- 用屏幕边缘、四角对其
			if v.align == 'top_center' then
				ox = visibleOrigin.x + visibleSize.width / 2
				oy = visibleOrigin.y + visibleSize.height
			elseif v.align == 'top_left' then
				ox = visibleOrigin.x
				oy = visibleOrigin.y + visibleSize.height
			elseif v.align == 'top_right' then
				ox = visibleOrigin.x + visibleSize.width
				oy = visibleOrigin.y + visibleSize.height
			elseif v.align == 'bottom_left' then
				ox = visibleOrigin.x
				oy = visibleOrigin.y
			elseif v.align == 'bottom_center' then
				ox = visibleOrigin.x + visibleSize.width / 2
				oy = visibleOrigin.y
			elseif v.align == 'bottom_right' then
				ox = visibleOrigin.x + visibleSize.width
				oy = visibleOrigin.y
			elseif v.align == 'left_center' then
				ox = visibleOrigin.x
				oy = visibleOrigin.y + visibleSize.height / 2
			elseif v.align == 'right_center' then
				ox = visibleOrigin.x + visibleSize.width
				oy = visibleOrigin.y + visibleSize.height / 2
			elseif v.align == 'screen_center' then
				ox = visibleOrigin.x + visibleSize.width / 2
				oy = visibleOrigin.y + visibleSize.height / 2  
			elseif v.align == "relative" then
				if v.baseOn and type(GameGuideRunner[v.baseOn]) == "function" then
					local basePos = GameGuideRunner[v.baseOn]()
					if basePos then
						ox, oy = basePos.x, basePos.y
					end
				end
			end

			local pos = ccp(ox + v.x, oy + v.y)
			if layer then
				pos = layer:convertToNodeSpace(pos)
			end
			group:setPosition(pos)
			group:setScale(extraScale)
			table.insert(groups, group)

		end
	end

	-- if _G.isLocalDevelopMode then printx(0, '11111111111', group:getGroupBounds().size.width) end

	local trueMask = GameGuideUI:mask(action.opacity, action.touchDelay, ccp(-300, -300), 0, false, 100, 100, false)
	trueMask.setFadeIn(action.maskDelay, action.maskFade)

	if playUI and playUI.gameBoardLogic then
		playUI.gameBoardLogic:stopEliminateAdvise()
		playUI.gameBoardView:focusOnItem(nil)
	end


	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)
		for k, v in pairs(groups) do
			local pos = ccp(v:getPositionX(), v:getPositionY())
			local wrapper = LayerColor:create()
			wrapper:addChild(v)
			local width = v:getGroupBounds().size.width
			local height = v:getGroupBounds().size.height
			v:setPositionX(-width/2)
			v:setPositionY(height/2)
			wrapper:setPosition(ccp(pos.x+width/2, pos.y-height/2))
			wrapper:setScale(3)
			wrapper:setVisible(false)
			wrapper:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.maskDelay), CCSequence:createWithTwoActions(CCShow:create(), CCScaleTo:create(0.3, 1))))
			layer:addChild(wrapper)
		end
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end

	-- if _G.isLocalDevelopMode then printx(0, '222222222222', group:getGroupBounds().size.width) end
	-- debug.debug()
end

function GameGuideRunner:removePopImage()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end

	return true, true
end

function GameGuideRunner:runGameSwap()
	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0.4
	action.maskFade = action.maskFade or 0.4
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer

	local hand = nil
	-- local streakPh = Layer:create()
	-- local schedId = nil
	-- local function callback()
	-- 	if _G.isLocalDevelopMode then printx(0, 'callback') end
	-- 	streakPh:removeChildren()
	-- 	if schedId then
	-- 		Director:sharedDirector():getScheduler():unscheduleScriptEntry(schedId)
	-- 		schedId = nil
	-- 	end
	-- 	local streak = CocosObject.new(CCMotionStreak:create(0.3, 1, 30, ccc3(255,255,255), 'materials/motion_streak.png'))
	-- 	streakPh:addChild(streak)
	-- 	schedId = Director:sharedDirector():getScheduler():scheduleScriptFunc(function() streak:setPosition(streakPh:convertToNodeSpace(ccp(hand:getPositionX(), hand:getPositionY()))) end, 0.01, false)
	-- end
	local panel = GameGuideUI:panelS(playUI, action)
	local from, to = playUI:getPositionFromTo(action.from, action.to)
	hand = GameGuideAnims:handslideAnim(from, to, action.handDelay, action.handFade, callback)
	-- local oldDispose = hand.dispose
	-- hand.dispose = function ()
	-- 	if schedId then
	-- 		Director:sharedDirector():getScheduler():unscheduleScriptEntry(schedId)
	-- 		schedId = nil
	-- 	end
	-- 	oldDispose(hand)
	-- end

	
	local text = nil
	if not action.cannotSkip then
		text = GameGuideUI:skipButton(Localization:getInstance():getText("tutorial.skip.step"), action)
	end

	local violationCount = 0
	local function violationCallback()
		violationCount = violationCount + 1
		-- printx( 3 , ' on violationCount', violationCount)
		if violationCount > 2 then
			if panel.ui and panel.ui.violation_text then
				panel.ui.violation_text:setVisible(true)
			else
				-- CommonTip:showTip('缺文本框', 'negative')
				if panel.ui:getChildByName('skiptext') then
					panel.ui:getChildByName('skiptext'):setString(localize('缺文本'))
				end
			end
		end
	end
	local trueMask = playUI:gameGuideMask(action.opacity, action.array, action.allow, false, violationCallback)
	trueMask.setFadeIn(action.maskDelay, action.maskFade)

    if playUI and playUI.gameBoardLogic then
        playUI.gameBoardLogic:stopEliminateAdvise()
        playUI.gameBoardView:focusOnItem(nil)
    end



	local wSize = Director:sharedDirector():getWinSize()
	local touchBlockerLayer = LayerColor:create()
	touchBlockerLayer:changeWidthAndHeight(wSize.width, wSize.height)
	touchBlockerLayer:setTouchEnabled(true, 0, true)
	touchBlockerLayer:setOpacity(0)

	local function onDelayOver()
		if touchBlockerLayer and touchBlockerLayer:getParent() and not touchBlockerLayer.isDisposed then
			touchBlockerLayer:removeFromParentAndCleanup(true)
		end
	end

	touchBlockerLayer:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.touchDelay), CCCallFunc:create(onDelayOver)))


	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)
		-- layer:addChild(streakPh)
		layer:addChild(hand)
		if text then layer:addChild(text) end
		layer:addChild(touchBlockerLayer)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end
end

function GameGuideRunner:removeGameSwap(paras)


	if paras and not paras.isSkip then
		local action = GameGuideData:sharedInstance():getRunningAction()

		if action.highlightEffect ~= nil then
			if action.highlightEffect.type == 'bomb' then
				GameGuide:sharedInstance().pauseBoardUpdateForBombEffect = true
				GameGuide:sharedInstance().pauseTime = action.highlightEffect.pauseTime or 3
			elseif action.highlightEffect.type == 'bird_line' then
				GameGuide:sharedInstance().pauseBoardUpdateForBirdLine = true
				GameGuide:sharedInstance().pauseTime = action.highlightEffect.pauseTime or 3
			elseif action.highlightEffect.type == 'ice' then
				GameGuide:sharedInstance().pauseBoardUpdateForIceEffect = true
				GameGuide:sharedInstance().pauseTime = action.highlightEffect.pauseTime or 3
			elseif action.highlightEffect.type == 'superBird' then
				GameGuide:sharedInstance().pauseBoardUpdateForSuperBird = true
				GameGuide:sharedInstance().pauseTime = action.highlightEffect.pauseTime or 3
			end
		end

		if action.highlightEffect and action.highlightEffect.type == 'bomb' and action.highlightEffect.effectArea then
			local playUI = Director:sharedDirector():getRunningScene()
			playUI.gameBoardView:showBombGuideEffect(action.highlightEffect.effectArea, action.highlightEffect.pauseTime or 3)
		elseif action.highlightEffect and action.highlightEffect.type == 'ice' and action.highlightEffect.effectArea then
			local playUI = Director:sharedDirector():getRunningScene()
			playUI.gameBoardView:showIceGuideEffect(action.highlightEffect.effectArea, action.highlightEffect.pauseTime or 3)
		end
	end


	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end

	return true, true
end

function GameGuideRunner:runShowObj()
	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0.3
	action.maskFade = action.maskFade or 0.3
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local wPos
	if action.index == math.floor(action.index) then
		local tile = playUI.levelTargetPanel:getLevelTileByIndex(action.index)
		local pos = tile:getPosition()
		local size = tile:getGroupBounds().size
		wPos = tile:getParent():convertToWorldSpace(ccp(pos.x, pos.y - size.height + 50))
	else
		local tile1 = playUI.levelTargetPanel:getLevelTileByIndex(math.floor(action.index))
		local tile2 = playUI.levelTargetPanel:getLevelTileByIndex(math.floor(action.index) + 1)
		pos = ccp(tile1:getPositionX() + (tile2:getPositionX() - tile1:getPositionX()) * (action.index - math.floor(action.index)),
			tile1:getPositionY() + (tile2:getPositionY() - tile1:getPositionY()) * (action.index - math.floor(action.index)))
		local size = tile1:getGroupBounds().size
		wPos = tile1:getParent():convertToWorldSpace(ccp(pos.x, pos.y - size.height + 50))
	end
	local trueMask = GameGuideUI:mask(action.opacity, action.touchDelay, ccp(wPos.x, wPos.y),
		nil, false, action.width or 1, action.height or 1, true)
	trueMask.setFadeIn(action.maskDelay, action.maskFade)
	local panel = GameGuideUI:panelS(playUI, action, true)


    if playUI and playUI.gameBoardLogic then
        playUI.gameBoardLogic:stopEliminateAdvise()
        playUI.gameBoardView:focusOnItem(nil)
    end

	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end
end

function GameGuideRunner:removeShowObj()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end

	return true, true
end

function GameGuideRunner:runShowHint()
	local action = GameGuideData:sharedInstance():getRunningAction()
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer

	action.animPosY = action.animPosY or 800
	action.animScale = action.animScale or 1
	action.animRotate = action.animRotate or 0
	action.animDelay = action.animDelay or 0
	action.panOrigin = action.panOrigin or ccp(-450, 600)
	action.panFinal = action.panFinal or ccp(150, 600)
	action.panDelay = action.panDelay or 0.5
	action.text = action.text or ""

	local sprite = Sprite:createEmpty()
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()

	sprite:setScale(action.animScale)
	sprite:setRotation(action.animRotate)
	if action.reverse then
		sprite:setScaleX(-action.animScale)
		sprite:setPositionX(180 * action.animScale)
	else
		sprite:setPositionX(vSize.width - 180 * action.animScale)
	end

	if type(action.animMatrixR) == "number" then
		sprite:setPositionY(playUI:getRowPosY(action.animMatrixR))
	else
		sprite:setPositionY(vOrigin.y + vSize.height - action.animPosY)
	end
	if not action.panelName then
		local anim = CommonSkeletonAnimation:createTutorialMoveIn()
		local function animPlay() sprite:addChild(anim) end
		sprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.animDelay), CCCallFunc:create(animPlay)))
	end
	local panel
	if action.panelName then
		panel = GameGuideUI:dialogue(nil, action, skipText)
	else
		panel = GameGuideUI:panelMini(action.text)
	end
	if type(action.panMatrixOriginR) == "number" then
		panel:setPosition(ccp(action.panOrigin.x, playUI:getRowPosY(action.panMatrixOriginR)))
	else
		panel:setPosition(ccp(action.panOrigin.x, vOrigin.y + vSize.height - action.panOrigin.y))
	end
	local function onComplete() GameGuide:sharedInstance():onGuideComplete() end
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(action.panDelay))
	if type(action.panMatrixFinalR) == "number" then
		array:addObject(CCEaseBackOut:create(CCMoveTo:create(0.2, ccp(action.panFinal.x, playUI:getRowPosY(action.panMatrixFinalR)))))
	else
		array:addObject(CCEaseBackOut:create(CCMoveTo:create(0.2, ccp(action.panFinal.x, vOrigin.y + vSize.height - action.panFinal.y))))
	end
	array:addObject(CCDelayTime:create(2.5))
	local function panFadeOut()
		if panel and not panel.isDisposed then
			local childrenList = {}
			panel:getVisibleChildrenList(childrenList)
			for __, v in pairs(childrenList) do
				v:runAction(CCFadeOut:create(0.5))
			end
		end
	end
	array:addObject(CCCallFunc:create(panFadeOut))
	array:addObject(CCDelayTime:create(0.5))
	array:addObject(CCCallFunc:create(onComplete))
	panel:runAction(CCSequence:create(array))

	if layer then
		layer:addChild(sprite)
		layer:addChild(panel)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end
end

function GameGuideRunner:removeShowHint()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end
	return true, true
end

function GameGuideRunner:runShowEliminate()
	local action = GameGuideData:sharedInstance():getRunningAction()
	action.r = action.r or 5
	action.c = action.c or 5
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer

	local anim = CommonSkeletonAnimation:createTutorialMoveIn2()
	anim.name = "animation"

	if layer then
		local pos = playUI:getGlobalPositionUnit(action.r, action.c)
		anim:setPosition(ccp(pos.x + 100, pos.y + 105))
		layer:addChild(anim)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end
end

function GameGuideRunner:removeShowEliminate()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		local anim = layer:getChildByName("animation")
		anim:stopAllActions()
		local function removeAll() layer:removeChildren(true) end
		anim:runAction(CCSequence:createWithTwoActions(CCMoveBy:create(0.5, ccp(300, 0)), CCCallFunc:create(removeAll)))
	end
	return true, true
end

function GameGuideRunner:runShowPropIconAnimation()

	local propIcon = nil
	local propCenterPos = nil
	local propToPos = nil
	local propBglightCallback = nil
	local leftPropList = GameBoardLogic:getCurrentLogic().PlayUIDelegate.propList.leftPropList

	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.touchDelay = action.touchDelay or 0
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local wSize = Director:sharedDirector():getWinSize()
	local trueMask = LayerColor:create()
	trueMask:changeWidthAndHeight(wSize.width, wSize.height)
	trueMask:setTouchEnabled(true, 0, true)
	trueMask:setOpacity(0)
	trueMask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.maskDelay), CCFadeTo:create(action.maskFade, action.opacity)))
	
	--local panel = GameGuideUI:panelL(action.text, true, action)

	if layer then
		layer:addChild(trueMask)
		--layer:addChild(panel)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end

	local propId = 10001
	if action.array and action.array.propId then propId = action.array.propId end

	local itemFound, itemIndex = leftPropList:findItemByItemID(propId)

	local icon , centerPos , to , bglightCallback = leftPropList:playAddGetPropAnimationStepOne(
			itemFound, itemIndex, nil , function () 

			end , action.array.propId , ""
		)
	propIcon = icon
	propCenterPos = centerPos and {x = centerPos.x, y = centerPos.y} or nil
	propToPos = to and {x = to.x, y = to.y} or nil
	propBglightCallback = bglightCallback

	local function onTouch() 
		--GameGuide:sharedInstance():onGuideComplete() 
		if trueMask.autoTimer then
			TimerUtil.removeAlarm(trueMask.autoTimer)
		end

		if not trueMask.isClosing then
			if propIcon then
				local centerPos = propCenterPos and ccp(propCenterPos.x, propCenterPos.y) or nil
				local toPos = propToPos and ccp(propToPos.x, propToPos.y) or nil
				leftPropList:playAddGetPropAnimationStepTwo( propIcon , centerPos , toPos , propBglightCallback ,
					function () 
						itemFound.animator:shake()
						GameGuide:sharedInstance():onGuideComplete()  
					end )
			end
		end
		trueMask.isClosing = true
	end
	local function onDelayOver() 
		if action.completeImmediatelyOnTouchBegin then
			trueMask:ad(DisplayEvents.kTouchBegin, onTouch) 
		else
			trueMask:ad(DisplayEvents.kTouchTap, onTouch) 
		end
	end
	trueMask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.touchDelay), CCCallFunc:create(onDelayOver)))
	trueMask.autoTimer = TimerUtil.addAlarm(function () 
			trueMask.autoTimer = nil
			onTouch()
		end, 2 , 1)
end

function GameGuideRunner:removeShowPropIconAnimation()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end
	return true, true
end

function GameGuideRunner:runShowInfoWithPropIconAnimation(paras)

	local propIcon = nil
	local propCenterPos = nil
	local propToPos = nil
	local propBglightCallback = nil
	local leftPropList = GameBoardLogic:getCurrentLogic().PlayUIDelegate.propList.leftPropList

	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.touchDelay = action.touchDelay or 0
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local wSize = Director:sharedDirector():getWinSize()
	local trueMask = LayerColor:create()
	trueMask:changeWidthAndHeight(wSize.width, wSize.height)
	trueMask:setTouchEnabled(true, 0, true)
	trueMask:setOpacity(0)
	trueMask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.maskDelay), CCFadeTo:create(action.maskFade, action.opacity)))
	

	local panel = GameGuideUI:panelS( playUI , action , true )

	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end

	
	local propId = 10001
	if action.array and action.array.propId then propId = action.array.propId end

	local itemFound, itemIndex = leftPropList:findItemByItemID(propId)

	local icon , centerPos , to , bglightCallback = leftPropList:playAddGetPropAnimationStepOne(
			itemFound, itemIndex, nil , function () 

			end , action.array.propId , ""
		)
	propIcon = icon
	propCenterPos = centerPos
	propToPos = to
	propBglightCallback = bglightCallback

	local function onTouch() 
		--GameGuide:sharedInstance():onGuideComplete() 
		if not trueMask.isClosing then
			if propIcon then
				leftPropList:playAddGetPropAnimationStepTwo( propIcon , propCenterPos , propToPos , propBglightCallback ,
					function () 
						itemFound.animator:shake()
						GameGuide:sharedInstance():onGuideComplete()  
					end )
			end
		end
		trueMask.isClosing = true
	end
	local function onDelayOver() 
		if action.completeImmediatelyOnTouchBegin then
			trueMask:ad(DisplayEvents.kTouchBegin, onTouch) 
		else
			trueMask:ad(DisplayEvents.kTouchTap, onTouch) 
		end
	end
	trueMask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.touchDelay), CCCallFunc:create(onDelayOver)))
end

function GameGuideRunner:removeShowInfoWithPropIconAnimation()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end
	return true, true
end

function GameGuideRunner:runBuyPreProp()

	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.touchDelay = action.touchDelay or 0
	local playUI = Director:sharedDirector():getRunningScene()

	if not playUI then
		GameGuide:sharedInstance():onGuideComplete()
		return
	end

	local layer = playUI.guideLayer
	local wSize = Director:sharedDirector():getWinSize()
	local trueMask = LayerColor:create()
	trueMask:changeWidthAndHeight(wSize.width, wSize.height)
	trueMask:setTouchEnabled(true, 0, true)
	trueMask:setOpacity(0)

	local propId = 10001

	if action.array and type(action.array) == "table" and #action.array > 0 then
		local rindex = math.random(#action.array)
		local d = action.array[ rindex ]
		if d.propId then propId = d.propId end

		if action.panelNameRandomList and type(action.panelNameRandomList) == "table" and #action.panelNameRandomList > 0 then
			action.panelName = action.panelNameRandomList[rindex]
		end
	end

	local panel = GameGuideUI:panelL(action.text, true, action)
	trueMask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.maskDelay), CCFadeTo:create(action.maskFade, action.opacity)))


	-- 爆炸与直线图标用pkm会变虚，用properties.png里的
	if action.panelName == "guide_dialogue_trigger_3" then
		local oldIcon = panel.ui:getChildByName("guide_dialogue_panel_common_ui/guide_dialogue_prop_icon_sprite_10007")
		oldIcon:setVisible(false)
		local newIcon = ResourceManager:sharedInstance():buildItemSprite(10007)
		newIcon:setCascadeOpacityEnabled(true)
		newIcon:setScale(0.9)
		newIcon:setPositionX(oldIcon:getPositionX()+5)
		newIcon:setPositionY(oldIcon:getPositionY()-10)
		panel.ui:addChild(newIcon)

		newIcon:setOpacity(0)
		newIcon:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.panDelay), CCFadeIn:create(action.panFade)))
	end

	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end

	-- local timePropId = ItemType:getTimePropItemByRealId(propId)
	-- local timePropCount = UserManager:getInstance():getUserTimePropNumber(timePropId)
	local timePropId = propId
	local timePropCount = UserManager:getInstance():getAllTimePropNumberWithRealItemID( propId )
	local timeProp = UserManager:getInstance():getTimePropsByRealItemId( propId )
	if timeProp and timeProp[1] then
		timePropId = timeProp[1].itemId
	end

	local isTimeProp = false
	local propCount = 0
	local usePropId = propId
	if timePropCount > 0 then
		isTimeProp = true
		propCount = timePropCount
		usePropId = timePropId
	else
		propCount = UserManager:getInstance():getUserPropNumber(propId)
	end

	local coinIcon = panel.ui:getChildByName('keepname_coinIcon')
	local priceBg = panel.ui:getChildByName('keepname_priceBg')
	local price = panel.ui:getChildByName('keepname_price')

	local useBtn
	local useBtnMFSY = panel.ui:getChildByName('keepname_useBtn_mfsy')
	local useBtnMFSYBCW = panel.ui:getChildByName('keepname_useBtn_mfsybcw')
	if useBtnMFSY then
		useBtn = GroupButtonBase:create(useBtnMFSY)
		useBtn:setString('免费使用')
	elseif useBtnMFSYBCW then
		useBtn = GroupButtonBase:create(useBtnMFSYBCW)
		useBtn:setString('免费使用并重玩')
	end
	local buyBtn
	local buyBtnGMBSY = panel.ui:getChildByName('keepname_buyBtn_gmbsy')
	if buyBtnGMBSY then
		buyBtn = GroupButtonBase:create(buyBtnGMBSY)
		buyBtn:setString('立即使用')
	end
	local buyTips = panel.ui:getChildByName('keepname_buyTips')
	if buyTips then
		buyTips:setRichText("购买1个道具开始游戏", "8C410F")
		buyTips:setScale(0.6)
	end

	if propCount > 0 then
		coinIcon:setVisible(false)
		priceBg:setVisible(false)
		price:setVisible(false)
		local numTip
		if isTimeProp then
			numTip = getRedNumTip()
		else
			numTip = getGreenNumTip()
		end
		numTip:setPosition(ccp(206, -368))
		numTip:setNum(propCount)
		panel.ui:addChild(numTip)
		LogicUtil.setLayerAlpha(numTip, 0)

		numTip:setOpacity(0)
		numTip:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.panDelay), CCCallFunc:create(function( ... )
			AnimationUtil.groupFadeIn(numTip, action.panFade)
		end)))

		useBtn:setVisible(true)
		buyBtn:setVisible(false)
		if buyTips then
			buyTips:setVisible(false)
		end

		panel.onCloseButtonTapped = function () 
			DcUtil:UserTrack({category = 'pregoods', sub_category = 'buy', t1 = 1})
			GameGuide:sharedInstance():onGuideComplete()
		end

		panel.onBuyButtonTapped = function () 
			local itemIds = {}
			local preitem = {}
			preitem.itemId = ItemType:getRealIdByTimePropId(usePropId)
			preitem.expireTime = Localhost:time()

			local winSize = CCDirector:sharedDirector():getWinSize()
			preitem.destXInWorldSpace = winSize.width / 2
			preitem.destYInWorldSpace = winSize.height / 2
			table.insert(itemIds , preitem)

			trueMask:removeAllEventListeners()
			trueMask.isDone = false

			if isTimeProp then
				local mainLogic = GameBoardLogic:getCurrentLogic()
				local current_stage = 0
				if mainLogic and mainLogic.level then current_stage = mainLogic.level end
				local usePropLogic = UsePropsLogic:create(UsePropsType.EXPIRE, current_stage, 0, {usePropId})
				usePropLogic:start()
				-- UserManager:getInstance():useTimeProp(usePropId)
			else
				local mainLogic = GameBoardLogic:getCurrentLogic()
				local current_stage = 0
				if mainLogic and mainLogic.level then current_stage = mainLogic.level end
				local usePropLogic = UsePropsLogic:create(UsePropsType.NORMAL, current_stage, 0, {usePropId})
				usePropLogic:start()
				-- UserManager:getInstance():setUserPropNumber(usePropId, UserManager:getInstance():getUserPropNumber(usePropId) - 1)
			end

			GameBoardLogic:getCurrentLogic().PlayUIDelegate.enterGameAnimPlayed = false
			GameBoardLogic:getCurrentLogic().PlayUIDelegate:useRemindPrepropCallback(itemIds, function ()

				if not trueMask.isDone then
					trueMask.isDone = true
					GameBoardLogic:getCurrentLogic().PlayUIDelegate.enterGameAnimPlayed = true
					GameGuide:sharedInstance():onGuideComplete()
				end

				if trueMask.timerId then
					TimerUtil.removeAlarm(trueMask.timerId)
					trueMask.timerId = nil
				end
			end)
			
			trueMask:setOpacity(0)
			panel:removeFromParentAndCleanup(true)
			trueMask.timerId = TimerUtil.addAlarm(function () 
				if not trueMask.isDone then
					trueMask.isDone = true
					trueMask.timerId = nil
					GameGuide:sharedInstance():onGuideComplete()
				end
			end, 8 , 1)

			if playUI.repeatGuideBtn then
				playUI.repeatGuideBtn:removeSelf()
			end

			DcUtil:UserTrack({category = 'pregoods', sub_category = 'buy', t1 = 2})
		end

	else

		useBtn:setVisible(false)
		buyBtn:setVisible(true)
		if buyTips then
			buyTips:setVisible(true)
		end
		price:setString(localize(action.panelName..'.keepname_price'))

		panel.onCloseButtonTapped = function () 
			DcUtil:UserTrack({category = 'pregoods', sub_category = 'buy', t1 = 1})
			GameGuide:sharedInstance():onGuideComplete()
		end


		panel.onBuyButtonTapped = function () 
			local itemIds = {}
			local preitem = {}
			preitem.itemId = propId
			preitem.expireTime = Localhost:time()
			--GamePropsType.kWrap_b
			--GamePropsType.kRefresh_b
			--GamePropsType.kAdd3_b
			local winSize = CCDirector:sharedDirector():getWinSize()
			preitem.destXInWorldSpace = winSize.width / 2
			preitem.destYInWorldSpace = winSize.height / 2
			table.insert(itemIds , preitem)

			trueMask:removeAllEventListeners()
			trueMask.isDone = false

			GameBoardLogic:getCurrentLogic().PlayUIDelegate.enterGameAnimPlayed = false
			GameBoardLogic:getCurrentLogic().PlayUIDelegate:useRemindPrepropCallback(itemIds, function ()

				if not trueMask.isDone then
					trueMask.isDone = true
					GameBoardLogic:getCurrentLogic().PlayUIDelegate.enterGameAnimPlayed = true
					GameGuide:sharedInstance():onGuideComplete()
				end

				if trueMask.timerId then
					TimerUtil.removeAlarm(trueMask.timerId)
					trueMask.timerId = nil
				end
			end)
			
			trueMask:setOpacity(0)
			panel:removeFromParentAndCleanup(true)
			trueMask.timerId = TimerUtil.addAlarm(function () 
				if not trueMask.isDone then
					trueMask.isDone = true
					trueMask.timerId = nil
					GameGuide:sharedInstance():onGuideComplete()
				end
			end, 8 , 1)

			if playUI.repeatGuideBtn then
				playUI.repeatGuideBtn:removeSelf()
			end

			local goodsIdList = { [10015] = 9 , [10018] = 8 , [10007] = 6, [10081] = 475, [10082] = 476 }
			if goodsIdList[propId] then
				local goodsId = goodsIdList[propId]
				local buyLogic = BuyLogic:create(goodsId, MoneyType.kCoin, DcFeatureType.kGuide, DcSourceType.kGuideBuyProp)
					buyLogic:getPrice()
					buyLogic:start( 1 , function () 
							local mainLogic = GameBoardLogic:getCurrentLogic()
							local current_stage = 0
							if mainLogic and mainLogic.level then current_stage = mainLogic.level end
							UserManager:getInstance():addUserPropNumber(propId, -1) --直接扣掉，不用发useProp，因为后端也没加到背包
							GainAndConsumeMgr.getInstance():consumeItem(DcFeatureType.kGuide, propId, 1, current_stage, nil, DcSourceType.kGuideBuyProp)
							
							Notify:dispatch("AchiEventDataUpdate",AchiDataType.kUsePropAddCount, 1)

							_G.questEvtDp:dp(_G.QuestEvent.new(_G.QuestEventType.kUsePreProps, {
								itemList = {propId},
							}))

							
							HomeScene:sharedInstance().coinButton:updateView()
							local function ones()

							end
							setTimeOut(ones, 2)

						end , function () end , true )
			end

			DcUtil:UserTrack({category = 'pregoods', sub_category = 'buy', t1 = 2})
		end
	end

	local mainLogic = GameBoardLogic:getCurrentLogic()
	local current_stage = 0
	if mainLogic and mainLogic.level then current_stage = mainLogic.level end
	local high_stage = UserManager:getInstance().user:getTopLevelId()

	local dcParam1 = 0
	local _t2 
	if propId == ItemType.ADD_THREE_STEP then
		_t2 = 0
		local datas = {}
		datas.t = "useProps"
		datas.uid = UserManager:getInstance():getUID()
		datas.itemList = {propId}
		if mainLogic then
			datas.levelId = mainLogic.level
		else
			datas.levelId = 0
		end
		Localhost:warpEngine( datas )
		dcParam1 = 2
	elseif propId == ItemType.INITIAL_2_SPECIAL_EFFECT then
		_t2 = 1
		dcParam1 = 1
	elseif propId == ItemType.INGAME_PRE_REFRESH then
		_t2 = 2
	elseif propId == ItemType.PRE_WRAP_BOMB then
		_t2 = 3
	elseif propId == ItemType.PRE_LINE_BOMB then
		_t2 = 4
	end

	DcUtil:UserTrack({category = 'pregoods', sub_category = 'pregoods_changelocation', t1 = 0, t2 = _t2})
	DcUtil:triggerGuideProp(propId, Localization:getInstance():getText("prop.name." .. tostring(propId)) , current_stage , high_stage)

	local dcParam2 = 2
	if propCount > 0 then
		dcParam2 = 1
	end
	DcUtil:UserTrack({category = 'pregoods', sub_category = 'canyu', t1 = dcParam1, t2 = dcParam2})
end

function GameGuideRunner:removeBuyPreProp()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end
	return true, true
end

function GameGuideRunner:runGuideWeeklyCloud()
	local function callback()
		GameGuide:sharedInstance():onGuideComplete() 
	end
	local action = GameGuideData:sharedInstance():getRunningAction()
	if not GamePlayContext:isResumeReplayMode() and action and action.rowDelta and action.itemId then 
	    local WeeklyGuidePanel = require "zoo.modules.weekly2017s1.WeeklyGuidePanel"
	    local panel = WeeklyGuidePanel:create(action.itemId, action.rowDelta, callback)
	    panel:popout()
	else
		callback()
	end
end

function GameGuideRunner:removeGuideWeeklyCloud()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end
	return true, true
end

function GameGuideRunner:runShowInfoNew()

	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.touchDelay = action.touchDelay or 0

	local autoClose = action.autoClose or 10
	local needBlockTouch = true 

	if action.needBlockTouch == true then
		needBlockTouch = true
	elseif action.needBlockTouch == false then
		needBlockTouch = false
	end

	local needHighlightTarget = false
	local tpye1 = nil
	local tpye2 = nil
	if action.highlightTarget and type(action.highlightTarget) == "table" and #action.highlightTarget >= 2 then
		needHighlightTarget = true
		tpye1 = action.highlightTarget[1]
		tpye2 = action.highlightTarget[2]
	end

	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local wSize = Director:sharedDirector():getWinSize()
	local trueMask = LayerColor:create()
	trueMask:changeWidthAndHeight(wSize.width, wSize.height)
	trueMask:setTouchEnabled(true, 0, needBlockTouch)
	trueMask:setOpacity(0)

	local panel = GameGuideUI:panelS( playUI , action )

	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end

	trueMask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.maskDelay), CCFadeTo:create(action.maskFade, action.opacity)))
	local function onTouch()
		if trueMask.autoTimer then
			TimerUtil.removeAlarm(trueMask.autoTimer)
		end 

		if needHighlightTarget then
			local mainLogic = GameBoardLogic:getCurrentLogic()
			if mainLogic and mainLogic.PlayUIDelegate then
		        mainLogic.PlayUIDelegate.levelTargetPanel:highlightTarget( tpye1 , tpye2 , false , false)
		    end
		end
		GameGuide:sharedInstance():onGuideComplete() 
	end
	local function onDelayOver() 
		trueMask:ad(DisplayEvents.kTouchBegin, onTouch) 

		if needHighlightTarget then
			local mainLogic = GameBoardLogic:getCurrentLogic()
			if mainLogic and mainLogic.PlayUIDelegate then
		        mainLogic.PlayUIDelegate.levelTargetPanel:highlightTarget( tpye1 , tpye2 , true , false)
		    end
		end
	end
	trueMask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.touchDelay), CCCallFunc:create(onDelayOver)))

	trueMask.autoTimer = TimerUtil.addAlarm(function () 
			trueMask.autoTimer = nil
			onTouch()
		end, autoClose , 1)
end

function GameGuideRunner:removeShowInfoNew()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end
	return true, true
end

function GameGuideRunner:runShowInfo()
	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.touchDelay = action.touchDelay or 0
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local wSize = Director:sharedDirector():getWinSize()
	local trueMask = LayerColor:create()
	trueMask:changeWidthAndHeight(wSize.width, wSize.height)
	trueMask:setTouchEnabled(true, 0, true)
	trueMask:setOpacity(0)
	trueMask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.maskDelay), CCFadeTo:create(action.maskFade, action.opacity)))
	local function onTouch() GameGuide:sharedInstance():onGuideComplete() end
	local function onDelayOver() 
		if action.completeImmediatelyOnTouchBegin then
			trueMask:ad(DisplayEvents.kTouchBegin, onTouch) 
		else
			trueMask:ad(DisplayEvents.kTouchTap, onTouch) 
		end
	end
	trueMask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.touchDelay), CCCallFunc:create(onDelayOver)))
	local panel = GameGuideUI:panelL(action.text, true, action)

	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end
end

function GameGuideRunner:removeShowInfo()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end
	return true, true
end

function GameGuideRunner:runClickTile( paras )
	-- body
	local action = GameGuideData:sharedInstance():getRunningAction()
	if paras and type(paras) == "table" and paras.r and paras.c then
		action.array[1].r = paras.r 
		action.array[1].c = paras.c 
	end

	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.touchDelay = action.touchDelay or 0

	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local trueMask = playUI:gameGuideMask(action.opacity, action.array, action.array[1], 1.5)
	trueMask.setFadeIn(action.maskDelay, action.maskFade)
    if playUI and playUI.gameBoardLogic then
        playUI.gameBoardLogic:stopEliminateAdvise()
        playUI.gameBoardView:focusOnItem(nil)
    end
	local panel = GameGuideUI:panelS(playUI, action)
	local hand = GameGuideAnims:handclickAnim(0.5, 0.3)
	local pos = playUI:getPositionFromTo(ccp(action.array[1].r, action.array[1].c), ccp(action.array[1].r, action.array[1].c))
    hand:setAnchorPoint(ccp(0, 1))
    hand:setPosition(pos)

	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)
		layer:addChild(hand)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end
end

function GameGuideRunner:removeClickTile( paras )
	-- body
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end

	return true, true
end

function GameGuideRunner:runShowTile(paras)
	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.touchDelay = action.touchDelay or 0
	if paras and type(paras) == "table" then
		if paras.wukongGuide == true then
			if type(paras.pos) == "table" and #paras.pos > 0 then
				action.array = {}
				local item = nil
				for ik, iv in pairs(paras.pos) do
					item = {}
					if iv.r then item.r = iv.r end
					if iv.c then item.c = iv.c end
					if iv.countR then item.countR = iv.countR else item.countR = 1 end
					if iv.countC then item.countC = iv.countC else item.countC = 1 end
					table.insert( action.array , item )
				end
			end
		end
	end

	if action.itemTypeId then
		local mainLogic = GameBoardLogic:getCurrentLogic()

		if not mainLogic then
			return false
		end

		local itemtype = action.itemTypeId

		local checkItem = nil
		local tr = nil
		local tc = nil
		for r = 1, #mainLogic.gameItemMap do
	 		for c = 1, #mainLogic.gameItemMap[r] do
	 			checkItem = mainLogic.gameItemMap[r][c]
	 			if checkItem and checkItem.ItemType == itemtype then
	 				tr = r
	 				tc = c
	 				break
	 			end
	 		end

	 		if tr and tc then break end
	 	end

	 	if tr and tc then
	 		action.array = {}
	 		local item = {}
			item.r = tr
			item.c = tc
			item.countR = 1
			item.countC = 1
			table.insert( action.array , item )
	 	end
	end

	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local trueMask = playUI:gameGuideMask(action.opacity, action.array, {action.array[1]})
	trueMask:removeAllEventListeners()
    if playUI and playUI.gameBoardLogic then
        playUI.gameBoardLogic:stopEliminateAdvise()
        playUI.gameBoardView:focusOnItem(nil)
    end
	local function onTouch(evt)
		if action.clickAndUse then

			local function check(r , c)
				local xy = { x = r , y = c }
				local pos = playUI:getPositionFromTo( xy , xy )
				if evt.globalPosition then
					-- print(evt.globalPosition.x, evt.globalPosition.y)
					if evt.globalPosition.x > pos.x-35 and evt.globalPosition.x < pos.x+35
					and evt.globalPosition.y > pos.y-35 and evt.globalPosition.y < pos.y+35 then
						GameGuide:sharedInstance():onGuideComplete()
						playUI.gameBoardView:onTouchBegan(pos.x, pos.y)
						playUI.gameBoardView:onTouchEnded(pos.x, pos.y)
						return true
					end
				end
				return false
			end

			if action.allowClickArea then
				local xy = { x = action.allowClickArea.r , y = action.allowClickArea.c }
				check( action.allowClickArea.r ,  action.allowClickArea.c )
			elseif action.allowClickGridList then
				for k,v in ipairs(action.allowClickGridList) do
					if check( v.r ,  v.c ) then
						break
					end
				end
			end
		else
			GameGuide:sharedInstance():onGuideComplete() 
		end
	end
	local function beginTouch() 
		if action.completeImmediatelyOnTouchBegin then
			trueMask:ad(DisplayEvents.kTouchBegin, onTouch) 
		else
			trueMask:ad(DisplayEvents.kTouchTap, onTouch) 
		end
	end
	trueMask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.touchDelay), CCCallFunc:create(beginTouch)))
	trueMask.setFadeIn(action.maskDelay, action.maskFade)

	if action.autoHide then

		local function autoHideCallback ()
			trueMask:removeAllEventListeners()
			GameGuide:sharedInstance():onGuideComplete() 
		end

		setTimeOut( autoHideCallback , action.autoHide )
	end

	local panel = nil
	if not action.noPanel then
		panel = GameGuideUI:panelS(playUI, action, true)
	end

	if layer then
		layer:addChild(trueMask)
		if panel then layer:addChild(panel) end
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end
end

function GameGuideRunner:removeShowTile()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end

	return true, true
end

--[[
function GameGuideRunner:runShowTileByItemType(paras)

end

function GameGuideRunner:removeShowTileByItemType()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end

	return true, true
end
]]

function GameGuideRunner:runShowUFO()
	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0.3
	action.maskFade = action.maskFade or 0.3
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local pos = playUI:getPositionFromTo(action.position, action.position)
	action.deltaY = action.deltaY or 70
	pos.y = pos.y + action.deltaY
	local trueMask = GameGuideUI:mask(action.opacity, action.touchDelay, ccp(pos.x, pos.y), 1, false, action.width, action.height, action.oval)
	trueMask.setFadeIn(action.maskDelay, action.maskFade)
	local panel = GameGuideUI:panelS(playUI, action, true)

    if playUI and playUI.gameBoardLogic then
        playUI.gameBoardLogic:stopEliminateAdvise()
        playUI.gameBoardView:focusOnItem(nil)
    end

	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end
end

function GameGuideRunner:removeShowUFO()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end


	return true, true
end

function GameGuideRunner:runMoveCount()
	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	-- local trueMask = playUI:gameGuideMask(action.opacity, action.array, {action.array[1]})
	action.opacity = action.opacity or 0xCC
	local pos = playUI:getMoveCountPos()
	action.posAdd = action.posAdd or ccp(0, 0)
	pos.x, pos.y = pos.x + action.posAdd.x, pos.y + action.posAdd.y
	local trueMask = GameGuideUI:mask(action.opacity, action.touchDelay, pos, nil, true, action.width, action.height)
	trueMask.setFadeIn(action.maskDelay, action.maskFade)
	local panel = GameGuideUI:panelS(playUI, action, true)

    if playUI and playUI.gameBoardLogic then
        playUI.gameBoardLogic:stopEliminateAdvise()
        playUI.gameBoardView:focusOnItem(nil)
    end
	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end
end

function GameGuideRunner:removeMoveCount()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end

	return true, true
end

function GameGuideRunner:runContinue()
	GameGuide:sharedInstance():onGuideComplete()
end

function GameGuideRunner:removeContinue()
end

function GameGuideRunner:runShowPreProp(paras)
	local scene = HomeScene:sharedInstance()
	if not scene then
		return
	end

	if not paras or type(paras) ~= "table" then return end
	local action = GameGuideData:sharedInstance():getRunningAction()
	
	local startPanel = paras.actWin

	action.opacity = action.opacity or 0xCC
	action.helpIcon = action.helpIcon or false
	action.preItemIndexs = action.preItemIndexs or {1}

	startPanel.levelInfoPanel:runShowPreProp(action)

	local layer = Layer:create()
	function layer:removePrePropGuideMask( ... )
		startPanel.levelInfoPanel:removeShowPreProp()
	end
	GameGuideData:sharedInstance():setLayer(layer)
	scene:addChild(layer, SceneLayerShowKey.POP_OUT_LAYER)

	layer:setTouchEnabled(true,-1,true)
	function layer:hitTestPoint( worldPosition, useGroupTest )
		return true
	end
	layer:addEventListener(DisplayEvents.kTouchTap,function( ... )
		GameGuide:sharedInstance():onGuideComplete(false,paras)
	end)

	released = false

end

function GameGuideRunner:removeShowPreProp()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		if layer.removePrePropGuideMask then
			layer:removePrePropGuideMask()
		end
		layer:removeChildren(true)
		layer:removeFromParentAndCleanup(true)
	end
	setTimeOut( function () 
		local para = {}
		para.actWin = GameGuide:sharedInstance().currPopPanel
		GameGuide:sharedInstance():tryRunNewGuide(para) end , 0.2)

	return true, true
end

function GameGuideRunner:runShowIngredient(paras)
	local startPanel = paras.actWin
	startPanel.levelInfoPanel:tryIngredientGuide(action)
	released = false
end

function GameGuideRunner:removeShowIngredient()
	if released then return false, false end
	released = true

	setTimeOut( function () 
		local para = {}
		para.actWin = GameGuide:sharedInstance().currPopPanel
		GameGuide:sharedInstance():tryRunNewGuide(para) end , 0.2)

	return true, true
end

function GameGuideRunner:runShowStartLevelButton(paras)
	--printx( -5 , "   GameGuideRunner:runShowStartLevelButton   ")

	if not paras or type(paras) ~= "table" then return end
	local action = GameGuideData:sharedInstance():getRunningAction()
	
	local startPanel = paras.actWin

	action.opacity = action.opacity or 0xCC
	action.helpIcon = action.helpIcon or false
	action.preItemIndexs = action.preItemIndexs or {1}
	action.showStartLevelButton = true
	
	--[[
	local layer = Layer:create()
	function layer:removeGuideMask( ... )
		--startPanel.levelInfoPanel:removeShowStartLevelButton()
	end

	GameGuideData:sharedInstance():setLayer(layer)
	scene:addChild(layer, SceneLayerShowKey.POP_OUT_LAYER)

	layer:setTouchEnabled(true,-1,true)
	function layer:hitTestPoint( worldPosition, useGroupTest )
		return true
	end

	layer:addEventListener(DisplayEvents.kTouchBegin,function( ... )
	--layer:addEventListener(DisplayEvents.kTouchTap,function( ... )
		GameGuide:sharedInstance():onGuideComplete(false,paras)
	end)
	]]

	--if _G.isLocalDevelopMode then printx(0, "TTT  TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT   " , table.tostring(action)) end
	----[[
	startPanel.levelInfoPanel:runShowStartButton( action , function ()
		GameGuide:sharedInstance():onGuideComplete(false,paras)
		startPanel.levelInfoPanel:removeShowStartButton()
	end)
	--]]

	--[[
	local layer = Layer:create()
	GameGuideData:sharedInstance():setLayer(layer)
	scene:addChild(layer, SceneLayerShowKey.POP_OUT_LAYER)
	layer:setTouchEnabled(true,-1,true)

	function layer:hitTestPoint( worldPosition, useGroupTest )
		return true
	end

	layer:addEventListener(DisplayEvents.kTouchBegin,function( ... )
		GameGuide:sharedInstance():onGuideComplete(false,paras)
		startPanel.levelInfoPanel:removeShowStartButton()
	end)
	]]


	released = false

end

function GameGuideRunner:removeShowStartLevelButton()
	if released then return false, false end
	released = true
	-- local layer = GameGuideData:sharedInstance():getLayer()
	-- if layer and not layer.isDisposed then
		-- if layer.removeGuideMask then
			-- layer:removeGuideMask()
		-- end
		-- layer:removeChildren(true)
		-- layer:removeFromParentAndCleanup(true)
	-- end
	return true, true
end

function GameGuideRunner:runStartInfo(paras)
	if not paras or type(paras) ~= "table" then return end
	local action = GameGuideData:sharedInstance():getRunningAction()
	local startPanel = paras.actWin
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.multRadius = action.multRadius or 1
	local scene = HomeScene:sharedInstance()
	local pos1 = startPanel.levelInfoPanel:getLevelTargetPosition()
	local pos2 = startPanel.levelInfoPanel:getPosition()
	local width = startPanel.levelInfoPanel.ui:getGroupBounds().size.width
	local wSize = Director:sharedDirector():getWinSize()
	local scale = startPanel:getScale()

	startPanel.rankListTouchEnabled = false

	local trueMask = GameGuideUI:mask(action.opacity, action.touchDelay, ccp(pos1.x, pos1.y), action.multRadius * scale)
	trueMask.setFadeIn(action.maskDelay, action.maskFade)

	local panel = GameGuideUI:panelS(nil, action, true)
	local layer = Layer:create()
	GameGuideData:sharedInstance():setLayer(layer)
	layer:addChild(trueMask)
	layer:addChild(panel)
	layer.startPanel = startPanel
	if scene then
		scene:addChild(layer, SceneLayerShowKey.POP_OUT_LAYER)
		released = false
	end
end

function GameGuideRunner:removeStartInfo()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		if layer.startPanel and not layer.startPanel.isDisposed then
			layer.startPanel.rankListTouchEnabled = true
		end
		layer:removeChildren(true)
		layer:removeFromParentAndCleanup(true)
	end
	return true, true
end

function GameGuideRunner:runClickPause()
	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.index = action.index or 1
	action.maskFade = action.maskFade or 0.3
	action.multRadius = action.multRadius or 1
	action.posAdd = action.posAdd or ccp(0, 0)

	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	local pos = playUI:getPositionByIndex(action.index)

	local pauseRes = playUI.topArea.pauseRes
	local pos = pauseRes:getPosition()
	pos = pauseRes:getParent():convertToWorldSpace(pos)
	local size = pauseRes:getGroupBounds().size

	local trueMask = GameGuideUI:mask(action.opacity, action.touchDelay, pos, action.multRadius, nil,nil,nil,nil, true)
	trueMask.setFadeIn(action.maskDelay, action.maskFade)
	-- trueMask:rma()
	trueMask:ad(DisplayEvents.kTouchBegin, function (evt)
		GameGuide:sharedInstance():onGuideComplete()
		pauseRes:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchTap, pauseRes, evt.globalPosition))
	end)
	-- local tl = LayerColor:createWithColor(ccc3(255, 0, 0), size.width, size.height)
	-- trueMask:addChild(tl)
	-- tl:setOpacity(0)
	-- tl:setPosition(ccp(pos.x - size.width/2, pos.y-size.height/2))
	-- tl:setTouchEnabled(true, 0, true)
	-- tl:ad(DisplayEvents.kTouchTap, function (evt)
	-- 	GameGuide:sharedInstance():onGuideComplete()
	-- 	pauseRes:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchTap, pauseRes, evt.globalPosition))
	-- end)
	-- tl:ad(DisplayEvents.kTouchEnd, function (evt)
	-- 	pauseRes:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchEnd, pauseRes, evt.globalPosition))

	-- end)
	-- tl:ad(DisplayEvents.kTouchBegin, function (evt)
	-- 	pauseRes:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchBegin, pauseRes, evt.globalPosition))
	-- end)

	local panel = GameGuideUI:panelS(playUI, action, true)
	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end
end

function GameGuideRunner:removeClickPause()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end

	return true, true
end

function GameGuideRunner:_runShowSpeedBtn(action, currPopPanel)
	-- local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.index = action.index or 1
	action.maskFade = action.maskFade or 0.3
	action.multRadius = action.multRadius or 1
	action.posAdd = action.posAdd or ccp(0, 0)

	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local vOrigin = Director:sharedDirector():getVisibleOrigin()

	-- local currPopPanel = GameGuideData:sharedInstance().currPopPanel
	if not currPopPanel then
		GameGuide:sharedInstance():onGuideComplete()
		return
	end
	currPopPanel.allowBackKeyTap = true
	local speedBtn = currPopPanel.speedBtn
	local pos = speedBtn:getPosition()

	if not speedBtn or speedBtn.isDisposed or not speedBtn:getParent() then
		GameGuide:sharedInstance():onGuideComplete()
		return
	end
	pos = speedBtn:getParent():convertToWorldSpace(pos)
	local size = speedBtn:getGroupBounds().size

	pos = ccp(pos.x, pos.y - 105)

	local trueMask = GameGuideUI:mask(action.opacity, action.touchDelay, pos, action.multRadius)
	trueMask.setFadeIn(action.maskDelay, action.maskFade)
	-- trueMask:rma()

	local tl = LayerColor:createWithColor(ccc3(255, 0, 0), size.width, size.height)
	tl:setOpacity(0)
	trueMask:addChild(tl)
	tl:setPosition(ccp(pos.x - size.width/2, pos.y-size.height/2))
	tl:setTouchEnabled(true, 0, true)
	tl:ad(DisplayEvents.kTouchTap, function (evt)
		GameGuide:sharedInstance():onGuideComplete()
		speedBtn:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchTap, speedBtn, evt.globalPosition))
	end)

	local txt1 = '点击这个按钮就可以改变'
	local txt2 = '关卡速度，最快可达2倍速~'

	if UserManager:getInstance():hasGuideFlag(kGuideFlags.SpeedBtn_1) then
		txt1 = '无限精力下使用关卡加速，'
		txt2 = '闯关变更快！'
	end

	local panel = GameGuideUI:panelS(playUI, action, true)
	panel:setPositionX(-60)
	panel:setPositionY(pos.y + 120)

	local t1,t2
	local len = #'guide_dialogue_text_dynamic_'
	for k,v in pairs(panel.ui.list) do
		if v.name and string.starts(v.name,'guide_dialogue_text_dynamic') then
			if not t1 then
				t1 = v
			else
				local tt1 = tonumber(string.sub(t1.name, len+1, #t1.name))
				local tt2 = tonumber(string.sub(v.name, len+1, #v.name))
				if tt1 < tt2 then
					t2 = v
				else
					t2 = t1
					t1 = v
				end
			end
		end
	end

	if t1 then
		t1:setText(txt1)
	end
	if t2 then
		t2:setText(txt2)
	end

	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end
end

function GameGuideRunner:runShowSpeedBtn()
	local playUI = Director:sharedDirector():getRunningScene()
	local action = GameGuideData:sharedInstance():getRunningAction()

	local currPopPanel = GameGuideData:sharedInstance().currPopPanel
	if not currPopPanel then
		GameGuide:sharedInstance():onGuideComplete()
		return
	end
	currPopPanel.allowBackKeyTap = false

	playUI:runAction(CCCallFunc:create(function ()
		self:_runShowSpeedBtn(action, currPopPanel)
	end))
end

function GameGuideRunner:removeShowSpeedBtn()
	if released then return false, false end
	released = true

	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end

	if not UserManager:getInstance():hasGuideFlag(kGuideFlags.SpeedBtn_1) then
		UserLocalLogic:setGuideFlag( kGuideFlags.SpeedBtn_1 )
		CCUserDefault:sharedUserDefault():setStringForKey("speed.btn.guide.time", tostring(Localhost:timeInSec()))
	else
		UserLocalLogic:setGuideFlag( kGuideFlags.SpeedBtn_2 )
	end

	return true, true
end

function GameGuideRunner:runTempProp()
	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.index = action.index or 1
	action.maskFade = action.maskFade or 0.3
	action.multRadius = action.multRadius or 1
	action.posAdd = action.posAdd or ccp(0, 0)

	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	local pos = playUI:getPositionByIndex(action.index)
	local trueMask = GameGuideUI:mask(action.opacity, action.touchDelay, ccp(pos.x + action.posAdd.x, pos.y + action.posAdd.y), action.multRadius)
	trueMask.setFadeIn(action.maskDelay, action.maskFade)

    if playUI and playUI.gameBoardLogic then
        playUI.gameBoardLogic:stopEliminateAdvise()
        playUI.gameBoardView:focusOnItem(nil)
    end
	local panel = GameGuideUI:panelS(nil, action, true)
	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end
end

function GameGuideRunner:removeTempProp()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
		layer:removeFromParentAndCleanup(true)
	end

	return true, true
end

function GameGuideRunner:runGiveProp()
	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.maskPos = action.maskPos or ccp(0, 0)
	action.opacity = action.opacity or 0xCC
	action.radius = action.radius or 80
	action.index = action.index or 1
	local playUI = Director:sharedDirector():getRunningScene()

	local itemId = action.propId

	local item = playUI.propList:findItemByItemID(itemId).item
	local itemPos = item:getParent():convertToWorldSpace(item:getPosition())

	local size = playUI.propList:findItemByItemID(itemId).item:getGroupBounds().size
	local pos = ccp(itemPos.x - 50 + size.width / 2, itemPos.y - 20 + size.height / 2)
	local layer = Layer:create()
	local trueMask = GameGuideUI:mask(action.opacity, action.touchDelay, pos, 1.5, false, nil, nil, false)
	trueMask.setFadeIn(action.maskDelay, action.maskFade)

    if playUI and playUI.gameBoardLogic then
        playUI.gameBoardLogic:stopEliminateAdvise()
        playUI.gameBoardView:focusOnItem(nil)
    end
	local panel = GameGuideUI:panelS(nil, action, true)
	GameGuideData:sharedInstance():setLayer(layer)
	layer.success = false
	local position = trueMask:getPosition()
	layer:addChild(trueMask)
	layer:addChild(panel)
	layer.panel = panel

	if playUI.guideLayer then
		playUI.guideLayer:addChild(layer)
		released = false
	end
end

function GameGuideRunner:removeGiveProp()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	local action = GameGuideData:sharedInstance():getRunningAction()
	local playUI = Director:sharedDirector():getRunningScene()
	local propId = action.tempPropId
	local num = action.count
	local pos = layer.panel:convertToWorldSpace(ccp(action.panImage[1].x, action.panImage[1].y))

	playUI:addTemporaryItem(propId, num, pos)
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
		layer:removeFromParentAndCleanup(true)
	end

	return true, true
end

function GameGuideRunner:runShowProp()
	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.maskPos = action.maskPos or ccp(0, 0)
	action.opacity = action.opacity or 0xCC
	action.radius = action.radius or 80
	action.index = action.index or 1
	
	local playUI = Director:sharedDirector():getRunningScene()
	if not playUI:is(NewGamePlaySceneUI) then
		return 
	end
	local offsetX = action.offsetX or 0
	local offsetY = action.offsetY or 0

	local itemId = action.propId

	local itemCenterPos = playUI.propList:getItemCenterPositionById(itemId)
	if not itemCenterPos then return end

	local pos = ccp(itemCenterPos.x + offsetX , itemCenterPos.y + offsetY)
	local layer = Layer:create()
	local skipClick = false
	if action.clickAndUse then
		skipClick = true
	end
	local trueMask = GameGuideUI:mask(action.opacity, action.touchDelay, pos, 1.5, false, nil, nil, false, skipClick)
	trueMask.setFadeIn(action.maskDelay, action.maskFade)

	pos = {x = pos.x, y = pos.y}
	if action.clickAndUse then

		local function setAddEventListener()
			trueMask:ad(DisplayEvents.kTouchTap, function (evt) 
					if evt.globalPosition then
						-- print(evt.globalPosition.x, evt.globalPosition.y)
						if evt.globalPosition.x > pos.x-50 and evt.globalPosition.x < pos.x+50
						and evt.globalPosition.y > pos.y-50 and evt.globalPosition.y < pos.y+50 then
							GameGuide:sharedInstance():onGuideComplete()
							playUI.propList.leftPropList.controller:onTouchBegin(evt)
							playUI.propList.leftPropList.controller:onTouchEnd(evt)
						end
					end
				end)
		end

		if action.touchDelay and action.touchDelay > 0 then
			setTimeOut( setAddEventListener , action.touchDelay )
		else
			setAddEventListener()
		end
		
	end


    if playUI and playUI.gameBoardLogic then
        playUI.gameBoardLogic:stopEliminateAdvise()
        playUI.gameBoardView:focusOnItem(nil)
    end
	local panel = GameGuideUI:panelS(nil, action, true)
	GameGuideData:sharedInstance():setLayer(layer)
	layer.success = false
	local position = trueMask:getPosition()
	layer:addChild(trueMask)
	layer:addChild(panel)

	if playUI.guideLayer then
		playUI.guideLayer:addChild(layer)
		released = false
	end
end

function GameGuideRunner:removeShowProp()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
		layer:removeFromParentAndCleanup(true)
	end

	return true, true
end

function GameGuideRunner:baseOnZQTargetLanterns()
	local playUI = Director:sharedDirector():getRunningScene()
    if playUI and playUI.olympicTopNode then
        local targetLanterns = playUI.olympicTopNode.targetLanterns
        -- local targetLayer = playUI.olympicTopNode.targetLayer
        if targetLanterns and not targetLanterns.isDisposed and targetLanterns.batchNode then
        	local lanternNum = targetLanterns.lanternNum
        	local tPos = ccp(0, 0)
        	local rtPos = targetLanterns.batchNode:convertToWorldSpace(ccp(tPos.x, tPos.y))
        	local lbPos = targetLanterns.batchNode:convertToWorldSpace(ccp(tPos.x - 115 * lanternNum, tPos.y - 155))
        	local contentSize = {width = rtPos.x - lbPos.x, height = rtPos.y - lbPos.y}
        	return {x = lbPos.x, y = lbPos.y}, contentSize
        end
    end
    return nil
end

function GameGuideRunner:runShowCustomizeArea()
	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.maskPos = action.maskPos or ccp(0, 0)
	action.opacity = action.opacity or 0xCC
	action.radius = action.radius or 80
	action.index = action.index or 1
	local playUI = Director:sharedDirector():getRunningScene()

	local offsetX = action.offsetX
	local offsetY = action.offsetY

	local baseOnPos, baseOnSize = nil, nil
	if action.baseOn and type(GameGuideRunner[action.baseOn]) == "function" then
		baseOnPos, baseOnSize = GameGuideRunner[action.baseOn]()
		if _G.isLocalDevelopMode then printx(0, "baseOnPos, baseOnSize = ", table.tostring(baseOnPos), table.tostring(baseOnSize)) end
	end
	local pos = nil
	if baseOnPos then 
		pos = ccp(baseOnPos.x  + offsetX, baseOnPos.y + offsetY) 
	else
	 	pos = ccp(action.position.x + offsetX, action.position.y + offsetY)
	end
	local maskWidth, maskHeight = action.width, action.height
	if baseOnSize then
		maskWidth, maskHeight = baseOnSize.width, baseOnSize.height
	end
	local layer = Layer:create()
	local trueMask = GameGuideUI:mask(action.opacity, action.touchDelay, pos, nil, true, maskWidth, maskHeight, false)
	trueMask.setFadeIn(action.maskDelay, action.maskFade)

    if playUI and playUI.gameBoardLogic then
        playUI.gameBoardLogic:stopEliminateAdvise()
        playUI.gameBoardView:focusOnItem(nil)
    end
	local panel = GameGuideUI:panelS(playUI, action, true)
	GameGuideData:sharedInstance():setLayer(layer)
	layer.success = false
	local position = trueMask:getPosition()
	layer:addChild(trueMask)
	layer:addChild(panel)

	if playUI.guideLayer then
		playUI.guideLayer:addChild(layer)
		released = false
	end
end

function GameGuideRunner:removeShowCustomizeArea()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
		layer:removeFromParentAndCleanup(true)
	end

	return true, true
end



function GameGuideRunner:runShowUnlock()
	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.maskPos = action.maskPos or ccp(0, 0)
	action.opacity = action.opacity or 0xCC
	action.radius = action.radius or 80
	action.index = action.index or 1
	local playUI = Director:sharedDirector():getRunningScene()
	local vo = Director:sharedDirector():getVisibleOrigin()
	local vs = Director:sharedDirector():getVisibleSize()

	local worldScene = HomeScene:sharedInstance().worldScene

	local cloudId = action.cloudId

	local layer = Layer:create()
	GameGuideData:sharedInstance():setLayer(layer)
	if playUI and playUI.guideLayer then
		playUI.guideLayer:addChild(layer)
		released = false
	end

	worldScene:setTouchEnabled(false)
	layer.clicked = false
	layer.success = false

	local function callback()
		worldScene:setTouchEnabled(true)
		if not layer or layer.isDisposed then
			return
		end

		local cloud
		for k, v in pairs(worldScene.lockedClouds) do
			if v.id == cloudId and not v.isCachedInPool then
				cloud = v
				break
			end
		end
		if cloud == nil or cloud.isDisposed then 
			GameGuide:sharedInstance():onGuideComplete()
			layer.clicked = true
			layer.success = true
			return 
		end

		local visible = false
		if cloud and cloud.lockedCloud and cloud.lockedCloud.hand then
			visible = cloud.lockedCloud.hand:isVisible()
			cloud.lockedCloud.hand:setVisible(false)
		end
		
		local cloudPos = cloud:getParent():convertToWorldSpace(cloud:getPosition())

		local lock = cloud.lock
		local pos
		if lock and not lock.isDisposed and lock:getParent() then
			local lockPos = lock:getParent():convertToWorldSpace(lock:getPosition())
			pos = ccp(lockPos.x, lockPos.y)
		else
			pos = ccp(vo.x + vs.width / 2, cloudPos.y - cloud:getGroupBounds().size.height/2)
		end
		local trueMask = GameGuideUI:mask(action.opacity, action.touchDelay, pos, 2, false, 5, 2, false, true)
		local posT = {x = pos.x, y = pos.y}
		local function onTouchTap(evt)
			local dx, dy = evt.globalPosition.x, evt.globalPosition.y
			layer.clicked = true
			layer.success = true
			if math.abs(ccpDistance(ccp(dx, dy), ccp(posT.x, posT.y))) <= 128 then -- 128是遮罩圆形的半径				
				local event = {name = DisplayEvents.kTouchTap}
				cloud:dispatchEvent(event)
			end
			if cloud and cloud.lockedCloud and cloud.lockedCloud.hand then
				visible = cloud.lockedCloud.hand:isVisible()
				cloud.lockedCloud.hand:setVisible(visible)
			end
			GameGuide:sharedInstance():onGuideComplete()
		end
		trueMask:removeAllEventListeners()
		trueMask:ad(DisplayEvents.kTouchTap, onTouchTap)

		trueMask.setFadeIn(action.maskDelay, action.maskFade)
		local panel = GameGuideUI:panelS(nil, action, true)
		local position = trueMask:getPosition()
		layer:addChild(trueMask)
		layer:addChild(panel)

		local hand = GameGuideAnims:handclickAnim(0, 0)
        hand:setAnchorPoint(ccp(0, 1))
        hand:setPosition(pos)
        layer:addChild(hand)
	end

	local function onMoveCloudLockToCenter()
		setTimeOut( function () callback() end , 1 )
	end

	worldScene:moveCloudLockToCenter(cloudId, onMoveCloudLockToCenter)
end

function GameGuideRunner:removeShowUnlock()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
		layer:removeFromParentAndCleanup(true)
	end
	return layer.clicked, layer.success
end


function GameGuideRunner:runUsePropTip( ... )
	local action = GameGuideData:sharedInstance():getRunningAction()
	local propId = GameGuideData:sharedInstance():getUsePropId()

	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer

	if not playUI:is(GamePlaySceneUI) then
	end

	local highlightItem = playUI:showUsePropTipGuide(propId)
	if not highlightItem then
	end

	local wSize = Director:sharedDirector():getWinSize()
	local trueMask = LayerColor:create()
	trueMask:changeWidthAndHeight(wSize.width, wSize.height)
	trueMask:setTouchEnabled(true, 0, true)
	trueMask:setOpacity(action.opacity)
	-- trueMask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.maskDelay), CCFadeTo:create(action.maskFade, action.opacity)))
	layer:addChild(trueMask)

	function trueMask:hitTestPoint( worldPosition,useGroupTest )
		if playUI.gameBoardView:hitTestPoint(worldPosition,useGroupTest) then
			return false
		end
		if playUI.propList.layer:hitTestPoint(worldPosition,useGroupTest) then
			return false
		end
		return true
	end

	if action.panelName then
		FrameLoader:loadArmature( "skeleton/props_tutorial_animation" )

		if propId == 10005 or propId == 10019 or propId == 10027 then
			if not action.oriPanelName then
				action.oriPanelName = action.panelName
			end
			action.panelName = action.oriPanelName
		end

		local panel = GameGuideUI:dialogue(nil, action, true)

		local anim = CommonSkeletonAnimation:createPropsTutorialAnimation(propId)
		if not anim then
			anim = CommonSkeletonAnimation:createPropsTutorialAnimation(
				PropsModel.kTempPropMapping[tostring(propId)]
			)
		end
		if anim then
			local placeholder = panel.ui:getChildByName("ui_commons/ui_fontsize_rect")
			placeholder:setVisible(false)
			anim:setPositionX(placeholder:getPositionX())
			anim:setPositionY(placeholder:getPositionY())
			anim:playAnimation()
			panel.ui:addChild(anim)
		end

		if propId == 10005 or propId == 10019 or propId == 10027 then

			Notify:register("GuideEventShowMagicItem", function ( isColumn )
				Notify:unregister("GuideEventShowMagicItem")
				if anim.isDisposed or panel.ui.isDisposed then
					return
				end

				anim:removeFromParentAndCleanup(true)
				panel:removeFromParentAndCleanup(true)

				local subfix = isColumn and "_1" or "_2"
				action.panelName = action.panelName..subfix

				local panel = GameGuideUI:dialogue(nil, action, true)
				local anim = CommonSkeletonAnimation:createPropsTutorialAnimation(propId)
				if not anim then
					anim = CommonSkeletonAnimation:createPropsTutorialAnimation(
						PropsModel.kTempPropMapping[tostring(propId)]
					)
				end
				if anim then
					local placeholder = panel.ui:getChildByName("ui_commons/ui_fontsize_rect")
					placeholder:setVisible(false)
					anim:setPositionX(placeholder:getPositionX())
					anim:setPositionY(placeholder:getPositionY())
					anim:playByIndex(isColumn and 1 or 2)
					panel.ui:addChild(anim)
				end
				local visibleSize = Director:sharedDirector():getVisibleSize()
				local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
				local topHeight = visibleOrigin.y + visibleSize.height - playUI:getRowPosY(0.25)

				panel:setPositionX(visibleOrigin.x + visibleSize.width/2)
				panel:setPositionY(visibleOrigin.y + visibleSize.height - topHeight/2)
				panel:setScale(math.min(1,topHeight/250))

				layer:addChild(panel)

			end)
		end

		local visibleSize = Director:sharedDirector():getVisibleSize()
		local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
		local topHeight = visibleOrigin.y + visibleSize.height - playUI:getRowPosY(0.25)

		panel:setPositionX(visibleOrigin.x + visibleSize.width/2)
		panel:setPositionY(visibleOrigin.y + visibleSize.height - topHeight/2)
		panel:setScale(math.min(1,topHeight/250))

		layer:addChild(panel)
	end

	-- playUI:addChild(highlightItem, SceneLayerShowKey.POP_OUT_LAYER)
	
	playUI:addChild(highlightItem)
	GameGuideData:sharedInstance():setLayer(layer)

	function layer:removeUsePropTipGuide( ... )
		playUI:removeUsePropTipGuide()

		highlightItem:removeFromParentAndCleanup(true)
	end

	released = false
end

function GameGuideRunner:removeUsePropTip( ... )
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
		layer:removeUsePropTipGuide()
	end
	return true,true
end

function GameGuideRunner:runUseMagicPropTip()
	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.touchDelay = action.touchDelay or 0
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local wSize = Director:sharedDirector():getWinSize()
	local trueMask = LayerColor:create()
	trueMask:changeWidthAndHeight(wSize.width, wSize.height)
	trueMask:setTouchEnabled(true, 0, true)
	trueMask:setOpacity(0)
	trueMask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.maskDelay), CCFadeTo:create(action.maskFade, action.opacity)))

	local canTouch = false
	local function onTouch() end--GameGuide:sharedInstance():onGuideComplete() end
	local function onDelayOver()
		canTouch = true
		if action.completeImmediatelyOnTouchBegin then
			trueMask:ad(DisplayEvents.kTouchBegin, onTouch) 
		else
			trueMask:ad(DisplayEvents.kTouchTap, onTouch) 
		end
	end
	trueMask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.touchDelay), CCCallFunc:create(onDelayOver)))

	local panel = GameGuideUI:panelL(action.text, true, action)
	local text = GameGuideUI:skipButton(Localization:getInstance():getText("tutorial.skip.step"), action)
	layer:addChild(trueMask)
	layer:addChild(panel)

	local propId = action.propId
	local highlightItem = playUI:showPropItemGuide(propId,true)
	if highlightItem then
		layer:addChild(highlightItem)
	end

	local hand_out = nil

	local from, to = playUI:getPositionFromTo(action.from, action.to)
	local propPos = highlightItem:getCenterPosition()
	propPos = {x = propPos.x, y = propPos.y}

	local itemSize = highlightItem.ui:getGroupBounds().size

	panel:setPosition(ccp(propPos.x - 420, propPos.y + 400))

	local touchLayer = LayerColor:createWithColor(ccc3(255,0,0), 120, 120)
	touchLayer:setTouchEnabled(true, -1, true)
	touchLayer:setOpacity(0)
	touchLayer:setPosition(ccp(propPos.x - itemSize.width / 2, propPos.y - itemSize.height / 2))
	touchLayer:addEventListener(DisplayEvents.kTouchTap, function ( ... )
		if not canTouch then return end
		
		if not highlightItem.ui.upProp then
			GameGuide:sharedInstance():onGuideComplete()
			return
		end
		
		touchLayer:rma()
		hand_out:removeFromParentAndCleanup(true)
		highlightItem.showUpLeftProp()
		panel:removeFromParentAndCleanup(true)
		trueMask:removeFromParentAndCleanup(true)

		highlightItem.ui.upProp:setVisible(true)
		highlightItem.ui.leftProp:setVisible(true)

		local useBrushProp = propId == 10005
		local trueMask = playUI:gameGuideMask(action.opacity, action.array, action.allow, false, onTouch,useBrushProp)
		trueMask:setTouchEnabled(true, 0, true)

		if playUI and playUI.gameBoardLogic then
	        playUI.gameBoardLogic:stopEliminateAdvise()
	        playUI.gameBoardView:focusOnItem(nil)
	    end

	    local actionx = table.clone(action)
	    actionx.panelName = action.panelName2

		local panel = GameGuideUI:panelS(playUI, actionx)
		

		local playUI = Director:sharedDirector():getRunningScene()
	    if playUI and playUI.gameBoardLogic then
	        playUI.gameBoardLogic:stopEliminateAdvise()
	        playUI.gameBoardView:focusOnItem(nil)
	    end

	    layer:addChildAt(trueMask, 0)

	    local prop = (action.direction == "row") and highlightItem.ui.upProp or highlightItem.ui.leftProp
	    local wPos = prop:convertToWorldSpace(prop:getPosition()) -- ccp(propPos.x+28, propPos.y-30)
	    prop:removeFromParentAndCleanup(false)
	    prop:setPosition(layer:convertToNodeSpace(wPos))
		layer:addChildAt(prop, 0)
		layer.prop = prop

		if prop.touchLayer then
			prop.touchLayer:setTouchEnabled(false)
			prop.touchLayer:rma()
		end
	    
		layer:addChild(panel)

	    local from, to = playUI:getPositionFromTo(action.from, action.to)
	    local propPos = highlightItem:getCenterPosition()

	    local pos = propPos
	    if action.direction == "row" then
	    	pos = ccp(pos.x - 150, pos.y)
	    else
	    	pos = ccp(pos.x, pos.y + 150)
	    end

	    local hand = GameGuideAnims:handUsePropAnim(pos,from, to)
		layer:addChild(hand)

		 Notify:register("GuideEventShowMagicItem", function ( ... )
			if hand.isDisposed then
				Notify:unregister("GuideEventShowMagicItem")
				return 
			end
			hand:runOnlySlide()
			highlightItem.item:use(nil, true)
		end)
	end)
	highlightItem:addChild(touchLayer)

	highlightItem.ui.upProp:setVisible(false)
	highlightItem.ui.leftProp:setVisible(false)

	hand_out = GameGuideAnims:handclickAnim()
	hand_out:setScale(0.8)
	hand_out:setPosition(ccp(propPos.x, propPos.y))
	layer:addChild(hand_out)
	layer:addChild(text)

    function layer:removePropItemGuide( ... )
    	playUI:removePropItemGuide()
    end

	GameGuideData:sharedInstance():setLayer(layer)
	released = false
end

function GameGuideRunner:removeUseMagicPropTip()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	layer:removePropItemGuide()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end
	return true, true
end

function GameGuideRunner:runUseGiftTip( ... )
	local action = GameGuideData:sharedInstance():getRunningAction()
	local propId = action.propId
	
	action.maskDelay = action.maskDelay or 0.4
	action.maskFade = action.maskFade or 0.4
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer

	local highlightItem = playUI:showPropItemGuide(propId,true)
	if not highlightItem then
		-- error
	end

	local panel = GameGuideUI:panelS(playUI, action)
	local text = GameGuideUI:skipButton(Localization:getInstance():getText("tutorial.skip.step"), action)
	-- local violationCount = 0
	-- local function violationCallback()
	-- 	violationCount = violationCount + 1
	-- 	printx( 3 , ' on violationCount', violationCount)
	-- 	if violationCount > 2 then
	-- 		if panel.ui and panel.ui.violation_text then
	-- 			panel.ui.violation_text:setVisible(true)
	-- 		else
	-- 			-- CommonTip:showTip('缺文本框', 'negative')
	-- 			if panel.ui:getChildByName('skiptext') then
	-- 				panel.ui:getChildByName('skiptext'):setString(localize('缺文本'))
	-- 			end
	-- 		end
	-- 	end
	-- end

	local useBrushProp = propId == 10005
	local trueMask = playUI:gameGuideMask(action.opacity, action.array, action.allow, false, violationCallback,useBrushProp)
	trueMask.setFadeIn(action.maskDelay, action.maskFade)

	local playUI = Director:sharedDirector():getRunningScene()
    if playUI and playUI.gameBoardLogic then
        playUI.gameBoardLogic:stopEliminateAdvise()
        playUI.gameBoardView:focusOnItem(nil)
    end

    -- 
	layer:addChild(trueMask)
	layer:addChild(panel)
	layer:addChild(text)
	if highlightItem then
		layer:addChild(highlightItem)
	end

    local from, to = playUI:getPositionFromTo(action.from, action.to)
    local propPos = highlightItem:getCenterPosition()
    local hand = GameGuideAnims:handUsePropAnim(propPos,from, to)
	layer:addChild(hand)

    local itemIsSelect = false
    local hitTestPoint = trueMask.hitTestPoint
    function trueMask:hitTestPoint(worldPosition, useGroupTest)
    	if not itemIsSelect and highlightItem:hitTestPoint(worldPosition, useGroupTest) then
    		return false
    	else
    		return hitTestPoint(self,worldPosition, useGroupTest)
    	end
    end

    function layer:removePropItemGuide( ... )
    	playUI:removePropItemGuide()
    end

    highlightItem.selectCallback = function( ... )
    	itemIsSelect = true 
    	hand:runOnlySlide()
    end

	GameGuideData:sharedInstance():setLayer(layer)
	released = false
end

function GameGuideRunner:removeUseGiftTip( ... )
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	layer:removePropItemGuide()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end
	return true, true
end

local function skipButton(skipText, onTouch)
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	local layer = LayerColor:create()
	layer:setOpacity(0)
	layer:changeWidthAndHeight(200, 80)
	layer:setPosition(ccp(0, vOrigin.y + vSize.height - 50))
	layer:setTouchEnabled(true, 0, true)
	layer:ad(DisplayEvents.kTouchTap, onTouch)
	layer:setOpacity(0)

	local text = TextField:create(skipText, nil, 32)
	text:setPosition(ccp(50, 25))
	text:setColor(ccc3(136, 255, 136))
	text:setOpacity(0)
	text:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0), CCFadeIn:create(0)))
	layer:addChild(text)

	return layer
end

local function getPanelAction(finalPos, panelName)
	local action = {}
	action.panFade = 0.2
	action.panDelay = 0.2
	if not finalPos then
		action.panelName = panelName
		action.panHorizonAlign = "winX"
		action.panPosX = -110
		return action
	end
	if finalPos.x < 400 then
		action.panelName = panelName .. '_R'

		if finalPos.x < 130 then
			action.panAlign = "winY"
			action.panPosY = finalPos.y 
			action.panHorizonAlign = "winX"
			action.panPosX = finalPos.x + 50
		else
			action.panAlign = "winY"
			action.panPosY = finalPos.y 
			action.panHorizonAlign = "winX"
			action.panPosX = finalPos.x
		end
		
	else
		action.panelName = panelName

		if finalPos.x > 550 then
			action.panAlign = "winY"
			action.panPosY = finalPos.y
			action.panHorizonAlign = "winX"
			action.panPosX = finalPos.x - 50
		else
			action.panAlign = "winY"
			action.panPosY = finalPos.y 
			action.panHorizonAlign = "winX"

			action.panPosX = finalPos.x
			
		end
	end
	-- if __WIN32 then
	-- 	action.panelName = panelName
	-- end
	return action
end

local function clickInBound(globalPosition, x, y, width, height)
	print(globalPosition.x, globalPosition.y, x, y, x+width, y-height)
	return globalPosition.x > x and globalPosition.x < x + width
		and globalPosition.y > y and globalPosition.y < y + height
end

local function initStrongPropStepOne(action, playUI, layer)
	local panelName1 = action.panelName1
	local vs = Director:sharedDirector():getVisibleSize()
	local vo = Director:sharedDirector():getVisibleOrigin()
	local panel = GameGuideUI:panelS(playUI, {panelName = panelName1, panAlign="viewY", panHorizonAlign="viewX", panPosY=vs.height/2+200, panPosX=-30, panDelay=0.2, panFade=0.2}, false)
	local mask = LayerColor:create()
	local propId = action.array.propId
	mask:ignoreAnchorPointForPosition(false)
	mask:setAnchorPoint(ccp(0, 0))
	mask:setOpacity(200)
	mask:setContentSize(CCSizeMake(960, 1800))
	mask:setPosition(ccp(0, 0))
	mask:setTouchEnabled(true,0, true)
	mask:ad(DisplayEvents.kTouchTap, function()  end)
	return mask, panel
end

local function createStep4Panel(playUI, panelName, panPosX, panPosY)
	local vs = Director:sharedDirector():getVisibleSize()
	local vo = Director:sharedDirector():getVisibleOrigin()
	if panPosX > vo.x+vs.width - 230 then
		panPosX = vo.x+vs.width - 230
	elseif panPosX < vo.x + 230 then
		panPosX = vo.x+230
		panelName = panelName .. '_R'
	end
	if panPosY > vo.y+vs.height-300 then
		panPosY = vo.y+vs.height-300
	end
	return GameGuideUI:panelS(playUI, {panelName = panelName, panAlign="winY", panHorizonAlign="winX", panPosY=panPosY, panPosX=panPosX, panDelay=0.2, panFade=0.2}, false)
end
local function createStep3Panel(playUI, panelName, panPosX, panPosY)
	local vs = Director:sharedDirector():getVisibleSize()
	local vo = Director:sharedDirector():getVisibleOrigin()
	if panPosX > vo.x+vs.width - 230 then
		panPosX = vo.x+vs.width - 230
	elseif panPosX < vo.x + 230 then
		panPosX = vo.x+230
		panelName = panelName .. '_R'
	end
	if panPosY > vo.y+vs.height-330 then
		panPosY = vo.y+vs.height-330
	end

	return GameGuideUI:panelS(playUI, {panelName = panelName, panAlign="winY", panHorizonAlign="winX", panPosY=panPosY, panPosX=panPosX, panDelay=0.2, panFade=0.2}, false)
end
local function createStep2Panel(playUI, finalPos, panelName)
	return GameGuideUI:panelS(playUI, getPanelAction(finalPos, panelName), false)
end
local function reverseHandIfNeeded(hand, pos1, pos2)
	local maxX = 0
	if pos1 then
		maxX = math.max(maxX, pos1.x)
	end
	if pos2 then
		maxX = math.max(maxX, pos2.x)
	end
	local vs = Director:sharedDirector():getVisibleSize()
	local vo = Director:sharedDirector():getVisibleOrigin()
	if maxX > vo.x+vs.width-80 then
		hand:setScaleX(-1)
	end
end

function GameGuideRunner:runGuidePropStrongHammer()
	local action = GameGuideData:sharedInstance():getRunningAction()
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local propId = action.array.propId
	local mask, panel = initStrongPropStepOne(action, playUI, layer)
	local panelName2 = action.panelName2
	local panelName3 = action.panelName3

	local data, current_count = IngamePropGuideManager:getInstance():getHammerData()

	if layer then
		layer:addChild(mask)
		layer:addChild(panel)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end

	local function finishGuide(denied)
		DcUtil:UserTrack({category='prop', sub_category='use_prop_guide', itemId=propId, type=(denied and 1 or 2), gift=(denied and -1 or 0), current_stage = GameGuideData:sharedInstance():getLevelId(), times =(denied and current_count or current_count+1)})
		IngamePropGuideManager:getInstance():onFinishGuide(propId, 'strong', GameGuideData:sharedInstance():getLevelId(), denied)
		GameGuide:sharedInstance():onGuideComplete()
	end

	local function hammerStepThree()
		if not data then
			return finishGuide(true)
		end
		local pos = GameBoardLogic:getCurrentLogic():getGameItemPosInView(data.r, data.c)
		local newmask = GameGuideUI:mask(200, 0, ccp(pos.x-35, pos.y-35), 0, true, 70, 70, false, true)
		local hand = GameGuideAnims:handclickAnim(0, 0)
		reverseHandIfNeeded(hand, pos)
		local panel3 = createStep3Panel(playUI, panelName3, pos.x, pos.y)
		layer:addChild(newmask)
		layer:addChild(hand)
		layer:addChild(panel3)
		hand:setPosition(ccp(pos.x, pos.y))
		pos = {x = pos.x, y = pos.y}
		newmask:ad(DisplayEvents.kTouchTap, function (evt) 
				if evt.globalPosition then
					print(evt.globalPosition.x, evt.globalPosition.y)
					if evt.globalPosition.x > pos.x-35 and evt.globalPosition.x < pos.x+35
					and evt.globalPosition.y > pos.y-35 and evt.globalPosition.y < pos.y+35 then
						GameBoardLogic:getCurrentLogic():useProps(GamePropsType.kHammer , data.r, data.c , nil , nil , UsePropsType.FAKE)
						playUI.propList:addFakeItemForReplay(propId, -1, false)
						finishGuide()
					end
				end
			end)
		layer:addChild(skipButton('跳过', function () finishGuide() end))
		IngamePropGuideManager:getInstance():clearHammerData()
	end

	local function onStepThree()	
		hammerStepThree()
	end

	local function onStepTwo()
		mask:removeFromParentAndCleanup(true)
		panel:removeFromParentAndCleanup(true)
		mask = nil
		panel = nil
		local leftPropList = GameBoardLogic:getCurrentLogic().PlayUIDelegate.propList.leftPropList
		local itemFound, itemIndex = leftPropList:findItemByItemID(propId)
		if itemFound then
			if layer then
				local finalPos = leftPropList:ensureItemInSight(itemFound, 0.3)
				local panel2 = createStep2Panel(playUI, finalPos, panelName2)
				local size = itemFound.item:getGroupBounds().size
				local newMask = GameGuideUI:mask(200, 0, ccp(finalPos.x-size.width/2, finalPos.y-size.height/2), 0, true, size.width, size.height, false, false)
				newMask:stopAllActions()
				newMask:rma()
				-- save the value in table
				finalPos = {x = finalPos.x, y = finalPos.y}
				size = {width = size.width, height = size.height} 
				local function onTouchTap(evt)
					if clickInBound(evt.globalPosition, finalPos.x-size.width/2, finalPos.y-size.height/2, size.width, size.height) then
						newMask:removeFromParentAndCleanup(true)
						panel2:removeFromParentAndCleanup(true)
						if propId ~= 10010 then
							itemFound:use()
						end
						newMask = nil
						panel2 = nil
						onStepThree()
					end
				end
				newMask:ad(DisplayEvents.kTouchTap, onTouchTap)
				layer:addChild(newMask)
				layer:addChild(panel2)
				-- panel2:setPosition(layer:convertToNodeSpace(finalPos))
			end
		end
	end

	local function onUseTapped()
		playUI.propList:addFakeItemForReplay(propId, 1, false)
		onStepTwo()
	end

	local function onCancelTapped()
		finishGuide(true)
	end
	local useBtn = GroupButtonBase:create(panel.ui:getChildByName('keepname_useBtn'))
	useBtn:setString('免费试用')
	useBtn:ad(DisplayEvents.kTouchTap, onUseTapped)

	local cancelBtn = GroupButtonBase:create(panel.ui:getChildByName('keepname_cancelBtn'))
	cancelBtn:setString('不用，谢谢')
	cancelBtn:ad(DisplayEvents.kTouchTap, onCancelTapped)
	cancelBtn:setColorMode(kGroupButtonColorMode.blue)


	return true, true
end

function GameGuideRunner:runGuidePropStrongForceSwapIngredient()
	local action = GameGuideData:sharedInstance():getRunningAction()
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local propId = action.array.propId
	local mask, panel = initStrongPropStepOne(action, playUI, layer)
	local panelName2 = action.panelName2
	local panelName3 = action.panelName3

	local data, current_count = IngamePropGuideManager:getInstance():getSwapIngredientData()

	if layer then
		layer:addChild(mask)
		layer:addChild(panel)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end

	local function finishGuide(denied)
		local leftPropList = GameBoardLogic:getCurrentLogic().PlayUIDelegate.propList.leftPropList
		local itemFound, itemIndex = leftPropList:findItemByItemID(propId)
		if itemFound then
			leftPropList.propListAnimation.controller:callCancelPropUseCallback(propId, true)
		end
		IngamePropGuideManager:getInstance().forceSwapCallback = nil
		DcUtil:UserTrack({category='prop', sub_category='use_prop_guide', itemId=propId, type=(denied and 1 or 2), gift=(denied and -1 or 0), current_stage = GameGuideData:sharedInstance():getLevelId(), times =(denied and current_count or current_count+1)})
		IngamePropGuideManager:getInstance():onFinishGuide(propId, 'strong', GameGuideData:sharedInstance():getLevelId(), denied)
		GameGuide:sharedInstance():onGuideComplete()
	end
	local function swapStepThree()
		if not data then
			return finishGuide()
		end

		local countR, countC = 1, 1
		if data.swap.r == data.middle.r then
			countR = 1
			countC = 2
		else
			countR = 2
			countC = 1
		end
		local _r = math.max(data.swap.r, data.middle.r)
		local _c = math.min(data.swap.c, data.middle.c)
		local holes = {r=_r, c=_c, countR = countR, countC = countC}
		local trueMask = playUI:gameGuideMask(200, {holes}, holes, false, nil)
		local from, to = playUI:getPositionFromTo({x=data.middle.r, y=data.middle.c}, {x=data.swap.r, y=data.swap.c})
		local hand = GameGuideAnims:handslideAnim(from, to, 0, 0, nil)
		reverseHandIfNeeded(hand, from, to)
		local panel3 = createStep3Panel(playUI, panelName3, from.x, from.y)
		layer:addChild(trueMask)
		layer:addChild(hand)
		layer:addChild(panel3)
		layer:addChild(skipButton('跳过', function () finishGuide() end))
		IngamePropGuideManager:getInstance().forceSwapCallback = function()
			IngamePropGuideManager:getInstance():clearSwapIngredientData()
			finishGuide()
		end

	end

	local function onStepThree()	
		swapStepThree()
	end

	local function onStepTwo()
		mask:removeFromParentAndCleanup(true)
		panel:removeFromParentAndCleanup(true)
		mask = nil
		panel = nil
		local leftPropList = GameBoardLogic:getCurrentLogic().PlayUIDelegate.propList.leftPropList
		local itemFound, itemIndex = leftPropList:findItemByItemID(propId)
		if itemFound then
			if layer then
				local finalPos = leftPropList:ensureItemInSight(itemFound, 0.3)
				local panel2 = createStep2Panel(playUI, finalPos, panelName2)
				local size = itemFound.item:getGroupBounds().size
				local newMask = GameGuideUI:mask(200, 0, ccp(finalPos.x-size.width/2, finalPos.y-size.height/2), 0, true, size.width, size.height, false, false)
				newMask:stopAllActions()
				newMask:rma()
				-- save the value in table
				finalPos = {x = finalPos.x, y = finalPos.y}
				size = {width = size.width, height = size.height} 
				local function onTouchTap(evt)
					if clickInBound(evt.globalPosition, finalPos.x-size.width/2, finalPos.y-size.height/2, size.width, size.height) then
						newMask:removeFromParentAndCleanup(true)
						panel2:removeFromParentAndCleanup(true)
						if propId ~= 10010 then
							itemFound:use()
						end
						newMask = nil
						panel2 = nil
						onStepThree()
					end
				end
				newMask:ad(DisplayEvents.kTouchTap, onTouchTap)
				layer:addChild(newMask)
				layer:addChild(panel2)
				-- panel2:setPosition(layer:convertToNodeSpace(finalPos))
			end
		end
	end

	local function onUseTapped()
		playUI.propList:addFakeItemForReplay(propId, 1, false)
		onStepTwo()
	end

	local function onCancelTapped()
		finishGuide(true)
	end
	local useBtn = GroupButtonBase:create(panel.ui:getChildByName('keepname_useBtn'))
	useBtn:setString('免费试用')
	useBtn:ad(DisplayEvents.kTouchTap, onUseTapped)

	local cancelBtn = GroupButtonBase:create(panel.ui:getChildByName('keepname_cancelBtn'))
	cancelBtn:setString('不用，谢谢')
	cancelBtn:ad(DisplayEvents.kTouchTap, onCancelTapped)
	cancelBtn:setColorMode(kGroupButtonColorMode.blue)

	return true, true
end

function GameGuideRunner:runGuidePropStrongForceSwapSpecial()
	local action = GameGuideData:sharedInstance():getRunningAction()
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local propId = action.array.propId
	local mask, panel = initStrongPropStepOne(action, playUI, layer)
	local panelName2 = action.panelName2
	local panelName3 = action.panelName3
	local panelName4 = action.panelName4

	local data, current_count = IngamePropGuideManager:getInstance():getSwapData()

	if layer then
		layer:addChild(mask)
		layer:addChild(panel)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end

	local function finishGuide(denied)
		local leftPropList = GameBoardLogic:getCurrentLogic().PlayUIDelegate.propList.leftPropList
		local itemFound, itemIndex = leftPropList:findItemByItemID(propId)
		if itemFound then
			leftPropList.propListAnimation.controller:callCancelPropUseCallback(propId, true)
		end
		IngamePropGuideManager:getInstance().swapCallback = nil
		IngamePropGuideManager:getInstance().forceSwapCallback = nil
		DcUtil:UserTrack({category='prop', sub_category='use_prop_guide', itemId=propId, type=(denied and 1 or 2), gift=(denied and -1 or 0), current_stage = GameGuideData:sharedInstance():getLevelId(), times =(denied and current_count or current_count+1)})
		IngamePropGuideManager:getInstance():onFinishGuide(propId, 'strong', GameGuideData:sharedInstance():getLevelId(), denied)
		GameGuide:sharedInstance():onGuideComplete()
	end
	local function stepFour()
		if not data then
			return finishGuide(true)
		end
		local other_r, other_c = data.other.r, data.other.c
		local countR, countC = 1, 1
		if data.middle.r == other_r then
			countR = 1
			countC = 2
		else
			countR = 2
			countC = 1
		end
		local _r = math.max(other_r, data.middle.r)
		local _c = math.min(other_c, data.middle.c)
		local holes = {r=_r, c=_c, countR = countR, countC = countC}
		local trueMask = playUI:gameGuideMask(200, {holes}, holes, false, nil)
		local from, to = playUI:getPositionFromTo({x=data.middle.r, y=data.middle.c}, {x=other_r, y=other_c})
		local hand = GameGuideAnims:handslideAnim(from, to, 0, 0, nil)
		reverseHandIfNeeded(hand, from, to)
		local panel4 = createStep4Panel(playUI, panelName4, from.x, from.y)
		layer:addChild(trueMask)
		layer:addChild(hand)
		layer:addChild(panel4)
		layer:addChild(skipButton('跳过', function () finishGuide() end))
		IngamePropGuideManager:getInstance().swapCallback = function()
			IngamePropGuideManager:getInstance():clearSwapData()
			finishGuide()
		end
	end
	local function swapStepThree()
		if not data then
			return finishGuide(true)
		end
		local data = IngamePropGuideManager:getInstance():getSwapData()
		local countR, countC = 1, 1
		if data.swap.r == data.middle.r then
			countR = 1
			countC = 2
		else
			countR = 2
			countC = 1
		end
		local _r = math.max(data.swap.r, data.middle.r)
		local _c = math.min(data.swap.c, data.middle.c)
		local holes = {r=_r, c=_c, countR = countR, countC = countC}
		local trueMask = playUI:gameGuideMask(200, {holes}, holes, false, nil)
		local from, to = playUI:getPositionFromTo({x=data.middle.r, y=data.middle.c}, {x=data.swap.r, y=data.swap.c})
		local hand = GameGuideAnims:handslideAnim(from, to, 0, 0, nil)
		reverseHandIfNeeded(hand, from, to)
		local panel3 = createStep3Panel(playUI, panelName3, from.x, from.y)
		layer:addChild(trueMask)
		layer:addChild(hand)
		layer:addChild(panel3)
		layer:addChild(skipButton('跳过', function () finishGuide() end))

		IngamePropGuideManager:getInstance().forceSwapCallback = function()
			trueMask:removeFromParentAndCleanup(true)
			hand:removeFromParentAndCleanup(true)
			panel3:removeFromParentAndCleanup(true)
			stepFour()
		end

	end

	local function onStepThree()	
		swapStepThree()
	end

	local function onStepTwo()
		mask:removeFromParentAndCleanup(true)
		panel:removeFromParentAndCleanup(true)
		mask = nil
		panel = nil
		local leftPropList = GameBoardLogic:getCurrentLogic().PlayUIDelegate.propList.leftPropList
		local itemFound, itemIndex = leftPropList:findItemByItemID(propId)
		if itemFound then
			if layer then
				local finalPos = leftPropList:ensureItemInSight(itemFound, 0.3)
				local panel2 = createStep2Panel(playUI, finalPos, panelName2)
				local size = itemFound.item:getGroupBounds().size
				local newMask = GameGuideUI:mask(200, 0, ccp(finalPos.x-size.width/2, finalPos.y-size.height/2), 0, true, size.width, size.height, false, false)
				newMask:stopAllActions()
				newMask:rma()
				-- save the value in table
				finalPos = {x = finalPos.x, y = finalPos.y}
				size = {width = size.width, height = size.height}
				local function onTouchTap(evt)
					if clickInBound(evt.globalPosition, finalPos.x-size.width/2, finalPos.y-size.height/2, size.width, size.height) then
						newMask:removeFromParentAndCleanup(true)
						panel2:removeFromParentAndCleanup(true)
						if propId ~= 10010 then
							itemFound:use()
						end
						newMask = nil
						panel2 = nil
						onStepThree()
					end
				end
				newMask:ad(DisplayEvents.kTouchTap, onTouchTap)
				layer:addChild(newMask)
				layer:addChild(panel2)
				-- panel2:setPosition(layer:convertToNodeSpace(finalPos))
			end
		end
	end

	local function onUseTapped()
		playUI.propList:addFakeItemForReplay(propId, 1, false)
		onStepTwo()
	end

	local function onCancelTapped()
		finishGuide(true)
	end
	local useBtn = GroupButtonBase:create(panel.ui:getChildByName('keepname_useBtn'))
	useBtn:setString('免费试用')
	useBtn:ad(DisplayEvents.kTouchTap, onUseTapped)

	local cancelBtn = GroupButtonBase:create(panel.ui:getChildByName('keepname_cancelBtn'))
	cancelBtn:setString('不用，谢谢')
	cancelBtn:ad(DisplayEvents.kTouchTap, onCancelTapped)
	cancelBtn:setColorMode(kGroupButtonColorMode.blue)

	return true, true
end

function GameGuideRunner:runGuidePropStrongBrush()
	local action = GameGuideData:sharedInstance():getRunningAction()
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local propId = action.array.propId
	local mask, panel = initStrongPropStepOne(action, playUI, layer)
	local panelName2 = action.panelName2
	local panelName3 = action.panelName3
	local panelName4 = action.panelName4

	local from_to, current_count = IngamePropGuideManager:getInstance():getBrushData()

	if layer then
		layer:addChild(mask)
		layer:addChild(panel)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end


	local function finishGuide(denied)
		local leftPropList = GameBoardLogic:getCurrentLogic().PlayUIDelegate.propList.leftPropList
		local itemFound, itemIndex = leftPropList:findItemByItemID(propId)
		if itemFound then
			leftPropList.propListAnimation.controller:callCancelPropUseCallback(propId, true)
		end
		IngamePropGuideManager:getInstance().swapCallback = nil
		IngamePropGuideManager:getInstance().propUsedCallback = nil
		DcUtil:UserTrack({category='prop', sub_category='use_prop_guide', itemId=propId, type=(denied and 1 or 2), gift=(denied and -1 or 0), current_stage = GameGuideData:sharedInstance():getLevelId(), times =(denied and current_count or current_count+1)})
		IngamePropGuideManager:getInstance():onFinishGuide(propId, 'strong', GameGuideData:sharedInstance():getLevelId(), denied)
		GameGuide:sharedInstance():onGuideComplete()
	end



	local function brushStepThree()
		if not from_to then
			finishGuide()
			return 
		end
		if layer then
			local from, to = playUI:getPositionFromTo({x=from_to.from.r, y=from_to.from.c}, {x=from_to.to.r, y=from_to.to.c})
			local hand = GameGuideAnims:handclickAnim(0, 0)
			reverseHandIfNeeded(hand, from, to)
			local holes = {}
			table.insert(holes, {r=from_to.from.r, c=from_to.from.c, countR=1, countC=1})
			table.insert(holes, {r=from_to.to.r, c=from_to.to.c, countR=1, countC=1})
			
			local _countR, _countC = 1, 1
			if from_to.from.r == from_to.to.r then
				_countR = 1
				_countC = 2
			else
				_countR = 2
				_countC = 1
			end
			local allow = {r=from_to.to.r, c=from_to.from.c, countR=_countR, countC=_countC}
			local trueMask = playUI:gameGuideMask(200, holes, allow, false, nil)
			local panel3 = createStep3Panel(playUI, panelName3, from.x, from.y)
			layer:addChild(trueMask)
			layer:addChild(hand)
			layer:addChild(panel3)
			layer:addChild(skipButton('跳过', function () finishGuide() end))
			hand:setPosition(GameBoardLogic:getCurrentLogic():getGameItemPosInView(from_to.animal.r, from_to.animal.c))
			IngamePropGuideManager:getInstance().propUsedCallback = function()
				hand:removeFromParentAndCleanup(true)
				panel3:removeFromParentAndCleanup(true)
				local from, to = playUI:getPositionFromTo({x=from_to.from.r, y=from_to.from.c}, {x=from_to.to.r, y=from_to.to.c})
				hand = GameGuideAnims:handslideAnim(from, to, 0, 0, nil)
				reverseHandIfNeeded(hand, from, to)
				layer:addChild(hand)
				local panel4 = createStep4Panel(playUI, panelName4, from.x, from.y)
				layer:addChild(panel4)
				IngamePropGuideManager:getInstance().swapCallback = function()
					IngamePropGuideManager:getInstance():clearBrushData()
					finishGuide()
				end
			end

			if playUI and playUI.gameBoardLogic then
		        playUI.gameBoardLogic:stopEliminateAdvise()
		        playUI.gameBoardView:focusOnItem(nil)
		    end
		end

	end

	local function onStepThree()	
		brushStepThree()
	end

	local function onStepTwo()
		mask:removeFromParentAndCleanup(true)
		panel:removeFromParentAndCleanup(true)
		mask = nil
		panel = nil
		local leftPropList = GameBoardLogic:getCurrentLogic().PlayUIDelegate.propList.leftPropList
		local itemFound, itemIndex = leftPropList:findItemByItemID(propId)
		if itemFound then
			if layer then
				local finalPos = leftPropList:ensureItemInSight(itemFound, 0.3)
				local panel2 = createStep2Panel(playUI, finalPos, panelName2)
				local size = itemFound.item:getGroupBounds().size
				local newMask = GameGuideUI:mask(200, 0, ccp(finalPos.x-size.width/2, finalPos.y-size.height/2), 0, true, size.width, size.height, false, false)
				local touchMinX = finalPos.x-size.width/2
				local touchMaxX = touchMinX+size.width
				local touchMinY = finalPos.y-size.height/2
				local touchMaxY = touchMinY-size.height
				newMask:stopAllActions()
				newMask:rma()
				-- save the value in table
				finalPos = {x = finalPos.x, y = finalPos.y}
				size = {width = size.width, height = size.height}
				local function onTouchTap(evt)
					if clickInBound(evt.globalPosition, finalPos.x-size.width/2, finalPos.y-size.height/2, size.width, size.height) then
						newMask:removeFromParentAndCleanup(true)
						panel2:removeFromParentAndCleanup(true)
						if propId ~= 10010 then
							itemFound:use()
						end
						newMask = nil
						panel2 = nil
						onStepThree()
					end
				end
				newMask:ad(DisplayEvents.kTouchTap, onTouchTap)
				layer:addChild(newMask)
				layer:addChild(panel2)
				-- panel2:setPosition(layer:convertToNodeSpace(finalPos))
			end
		end
	end

	local function onUseTapped()
		playUI.propList:addFakeItemForReplay(propId, 1, false)
		onStepTwo()
	end

	local function onCancelTapped()
		finishGuide(true)
	end
	local useBtn = GroupButtonBase:create(panel.ui:getChildByName('keepname_useBtn'))
	useBtn:setString('免费试用')
	useBtn:ad(DisplayEvents.kTouchTap, onUseTapped)

	local cancelBtn = GroupButtonBase:create(panel.ui:getChildByName('keepname_cancelBtn'))
	cancelBtn:setString('不用，谢谢')
	cancelBtn:ad(DisplayEvents.kTouchTap, onCancelTapped)
	cancelBtn:setColorMode(kGroupButtonColorMode.blue)


	return true, true
end

function GameGuideRunner:runGuidePropStrongBroom()
	local action = GameGuideData:sharedInstance():getRunningAction()
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local propId = action.array.propId
	local mask, panel = initStrongPropStepOne(action, playUI, layer)
	local panelName2 = action.panelName2
	local panelName3 = action.panelName3

	local row, current_count = IngamePropGuideManager:getInstance():getBroomData()

	if layer then
		layer:addChild(mask)
		layer:addChild(panel)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end

	local function finishGuide(denied)
		DcUtil:UserTrack({category='prop', sub_category='use_prop_guide', itemId=propId, type=(denied and 1 or 2), gift=(denied and -1 or 0), current_stage = GameGuideData:sharedInstance():getLevelId(), times =(denied and current_count or current_count+1)})
		IngamePropGuideManager:getInstance():onFinishGuide(propId, 'strong', GameGuideData:sharedInstance():getLevelId(), denied)
		GameGuide:sharedInstance():onGuideComplete()
	end

	local function broomStepThree()
		if row > 0 then
			local pos = GameBoardLogic:getCurrentLogic():getGameItemPosInView(row, 1)
			local width = GameBoardLogic:getCurrentLogic():getGameItemPosInView(1, 10).x-GameBoardLogic:getCurrentLogic():getGameItemPosInView(1, 1).x
			local height = GameBoardLogic:getCurrentLogic():getGameItemPosInView(3, 1).y-GameBoardLogic:getCurrentLogic():getGameItemPosInView(1, 1).y
			width = math.abs(width)
			height = math.abs(height)
			local newmask = GameGuideUI:mask(200, 0, ccp(pos.x-35, pos.y-35), 0, true, width, height, false, true)
			local hand = GameGuideAnims:handclickAnim(0, 0)
			reverseHandIfNeeded(hand, pos)
			local panel3 = createStep3Panel(playUI, panelName3, pos.x, pos.y)
			layer:addChild(newmask)
			layer:addChild(hand)
			layer:addChild(panel3)
			hand:setPosition(GameBoardLogic:getCurrentLogic():getGameItemPosInView(row, 9))
			newmask:ad(DisplayEvents.kTouchTap, function (evt) 
					if evt.globalPosition then
						print(evt.globalPosition.x, evt.globalPosition.y)
						if evt.globalPosition.x > pos.x-35 and evt.globalPosition.x < pos.x-35+width
						and evt.globalPosition.y > pos.y-35 and evt.globalPosition.y < pos.y-35+height then
							GameBoardLogic:getCurrentLogic():useProps(GamePropsType.kBroom , row, 1, nil , nil , UsePropsType.FAKE)
							playUI.propList:addFakeItemForReplay(propId, -1, false)
							finishGuide()
						end
					end
				end)
		else
			finishGuide()
		end
	end

	local function onStepThree()
		broomStepThree()
	end

	local function onStepTwo()
		mask:removeFromParentAndCleanup(true)
		panel:removeFromParentAndCleanup(true)
		mask = nil
		panel = nil
		local leftPropList = GameBoardLogic:getCurrentLogic().PlayUIDelegate.propList.leftPropList
		local itemFound, itemIndex = leftPropList:findItemByItemID(propId)
		if itemFound then
			if layer then
				local finalPos = leftPropList:ensureItemInSight(itemFound, 0.3)
				local panel2 = createStep2Panel(playUI, finalPos, panelName2)
				local size = itemFound.item:getGroupBounds().size
				local newMask = GameGuideUI:mask(200, 0, ccp(finalPos.x-size.width/2, finalPos.y-size.height/2), 0, true, size.width, size.height, false, false)
				newMask:stopAllActions()
				newMask:rma()
				-- save the value in table
				finalPos = {x = finalPos.x, y = finalPos.y}
				size = {width = size.width, height = size.height}
				local function onTouchTap(evt)
					if clickInBound(evt.globalPosition, finalPos.x-size.width/2, finalPos.y-size.height/2, size.width, size.height) then
						newMask:removeFromParentAndCleanup(true)
						panel2:removeFromParentAndCleanup(true)
						if propId ~= 10010 then
							-- itemFound:use()
						end
						newMask = nil
						panel2 = nil
						onStepThree()
					end
				end
				newMask:ad(DisplayEvents.kTouchTap, onTouchTap)
				layer:addChild(newMask)
				layer:addChild(panel2)
				-- panel2:setPosition(layer:convertToNodeSpace(finalPos))
			end
		end
	end

	local function onUseTapped()
		playUI.propList:addFakeItemForReplay(propId, 1, false)
		onStepTwo()
	end

	local function onCancelTapped()
		finishGuide(true)
	end
	local useBtn = GroupButtonBase:create(panel.ui:getChildByName('keepname_useBtn'))
	useBtn:setString('免费试用')
	useBtn:ad(DisplayEvents.kTouchTap, onUseTapped)

	local cancelBtn = GroupButtonBase:create(panel.ui:getChildByName('keepname_cancelBtn'))
	cancelBtn:setString('不用，谢谢')
	cancelBtn:ad(DisplayEvents.kTouchTap, onCancelTapped)
	cancelBtn:setColorMode(kGroupButtonColorMode.blue)


	return true, true
end

function GameGuideRunner:runGuidePropStrongRefresh()
	local action = GameGuideData:sharedInstance():getRunningAction()
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local propId = action.array.propId
	local mask, panel = initStrongPropStepOne(action, playUI, layer)
	local panelName2 = action.panelName2

	local data, current_count = IngamePropGuideManager:getInstance():getTwoStepsData(propId)

	if layer then
		layer:addChild(mask)
		layer:addChild(panel)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end

	local function finishGuide(denied)
		DcUtil:UserTrack({category='prop', sub_category='use_prop_guide', itemId=propId, type=(denied and 1 or 2), gift=(denied and -1 or 0), current_stage = GameGuideData:sharedInstance():getLevelId(), times =(denied and current_count or current_count+1)})
		IngamePropGuideManager:getInstance():onFinishGuide(propId, 'strong', GameGuideData:sharedInstance():getLevelId(), denied)
		GameGuide:sharedInstance():onGuideComplete()
	end


	local function onStepTwo()
		mask:removeFromParentAndCleanup(true)
		panel:removeFromParentAndCleanup(true)
		mask = nil
		panel = nil
		local leftPropList = GameBoardLogic:getCurrentLogic().PlayUIDelegate.propList.leftPropList
		local itemFound, itemIndex = leftPropList:findItemByItemID(propId)
		if itemFound then
			if layer then
				local finalPos = leftPropList:ensureItemInSight(itemFound, 0.3)
				local panel2 = createStep2Panel(playUI, finalPos, panelName2)
				local size = itemFound.item:getGroupBounds().size
				local newMask = GameGuideUI:mask(200, 0, ccp(finalPos.x-size.width/2, finalPos.y-size.height/2), 0, true, size.width, size.height, false, false)
				newMask:stopAllActions()
				newMask:rma()
				-- save the value in table
				finalPos = {x = finalPos.x, y = finalPos.y}
				size = {width = size.width, height = size.height}
				local function onTouchTap(evt)
					if clickInBound(evt.globalPosition, finalPos.x-size.width/2, finalPos.y-size.height/2, size.width, size.height) then
						newMask:removeFromParentAndCleanup(true)
						panel2:removeFromParentAndCleanup(true)
						itemFound:use(true)
						newMask = nil
						panel2 = nil
						finishGuide()
					end
				end
				newMask:ad(DisplayEvents.kTouchTap, onTouchTap)
				layer:addChild(newMask)
				layer:addChild(panel2)
				-- panel2:setPosition(layer:convertToNodeSpace(finalPos))
			end
		end
	end

	local function onUseTapped()
		playUI.propList:addFakeItemForReplay(propId, 1, false)
		onStepTwo()
	end

	local function onCancelTapped()
		finishGuide(true)
	end
	local useBtn = GroupButtonBase:create(panel.ui:getChildByName('keepname_useBtn'))
	useBtn:setString('免费试用')
	useBtn:ad(DisplayEvents.kTouchTap, onUseTapped)

	local cancelBtn = GroupButtonBase:create(panel.ui:getChildByName('keepname_cancelBtn'))
	cancelBtn:setString('不用，谢谢')
	cancelBtn:ad(DisplayEvents.kTouchTap, onCancelTapped)
	cancelBtn:setColorMode(kGroupButtonColorMode.blue)

	return true, true
end

function GameGuideRunner:runGuidePropStrongTwoSteps()
	local action = GameGuideData:sharedInstance():getRunningAction()
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local propId = action.array.propId
	local mask, panel = initStrongPropStepOne(action, playUI, layer)
	local panelName2 = action.panelName2
	local panelName3 = action.panelName3

	local data, current_count = IngamePropGuideManager:getInstance():getTwoStepsData(propId)

	if layer then
		layer:addChild(mask)
		layer:addChild(panel)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end

	local function finishGuide(denied)

		DcUtil:UserTrack({category='prop', sub_category='use_prop_guide', itemId=propId, type=(denied and 1 or 2), gift=(denied and -1 or 0), current_stage = GameGuideData:sharedInstance():getLevelId(), times =(denied and current_count or current_count+1)})
		IngamePropGuideManager:getInstance():onFinishGuide(propId, 'strong', GameGuideData:sharedInstance():getLevelId(), denied)
		GameGuide:sharedInstance():onGuideComplete()
	end


	local function onStepTwo()
		mask:removeFromParentAndCleanup(true)
		panel:removeFromParentAndCleanup(true)
		mask = nil
		panel = nil
		local leftPropList = GameBoardLogic:getCurrentLogic().PlayUIDelegate.propList.leftPropList
		local itemFound, itemIndex = leftPropList:findItemByItemID(propId)
		if itemFound then
			if layer then
				local finalPos = leftPropList:ensureItemInSight(itemFound, 0.3)
				local panel2 = createStep2Panel(playUI, finalPos, panelName2)
				local size = itemFound.item:getGroupBounds().size
				local newMask = GameGuideUI:mask(180, 0, ccp(finalPos.x-size.width/2 + 30, finalPos.y-size.height/2), 0, true, size.width, size.height, false, false)
				newMask:stopAllActions()
				newMask:rma()
				-- save the value in table
				finalPos = {x = finalPos.x, y = finalPos.y}
				size = {width = size.width, height = size.height}
				local function onTouchTap(evt)
					if clickInBound(evt.globalPosition, finalPos.x-size.width/2, finalPos.y-size.height/2, size.width, size.height) then
						newMask:removeFromParentAndCleanup(true)
						panel2:removeFromParentAndCleanup(true)
						if propId == 10055 then
							itemFound:use()
							-- GameBoardLogic:getCurrentLogic().boardView:useRandomBird()
							-- playUI.propList:addFakeItemForReplay(propId, -1, false)
							GameBoardLogic:getCurrentLogic().boardView.interactionController.currentState:handleComplete()
						else
							GameBoardLogic:getCurrentLogic():useProps(propId , nil, nil, nil , nil , UsePropsType.FAKE)
							playUI.propList:addFakeItemForReplay(propId, -1, false)
						end
						newMask = nil
						panel2 = nil
						finishGuide()
					end
				end
				newMask:ad(DisplayEvents.kTouchTap, onTouchTap)
				layer:addChild(newMask)
				layer:addChild(panel2)
			end
		end
	end

	local function onUseTapped()
		playUI.propList:addFakeItemForReplay(propId, 1, false)
		onStepTwo()
	end

	local function onCancelTapped()
		finishGuide(true)
	end
	local useBtn = GroupButtonBase:create(panel.ui:getChildByName('keepname_useBtn'))
	useBtn:setString('免费试用')
	useBtn:ad(DisplayEvents.kTouchTap, onUseTapped)

	local cancelBtn = GroupButtonBase:create(panel.ui:getChildByName('keepname_cancelBtn'))
	cancelBtn:setString('不用，谢谢')
	cancelBtn:ad(DisplayEvents.kTouchTap, onCancelTapped)
	cancelBtn:setColorMode(kGroupButtonColorMode.blue)

	return true, true
end

function GameGuideRunner:removeGuidePropStrongGeneral()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
		-- layer:removeFromParentAndCleanup(true)
	end
	return layer.clicked, layer.success
end

function GameGuideRunner:removeGuidePropStrongHammer()
	return self:removeGuidePropStrongGeneral()
end
function GameGuideRunner:removeGuidePropStrongBrush()
	return self:removeGuidePropStrongGeneral()
end
function GameGuideRunner:removeGuidePropStrongBroom()
	return self:removeGuidePropStrongGeneral()
end
function GameGuideRunner:removeGuidePropStrongForceSwapSpecial()
	return self:removeGuidePropStrongGeneral()
end
function GameGuideRunner:removeGuidePropStrongForceSwapIngredient()
	return self:removeGuidePropStrongGeneral()
end
function GameGuideRunner:removeGuidePropStrongRefresh()
	return self:removeGuidePropStrongGeneral()
end
function GameGuideRunner:removeGuidePropStrongTwoSteps()
	return self:removeGuidePropStrongGeneral()
end



function GameGuideRunner:runGuidePropBarWeak()

	printx( -5 , "   GameGuideRunner:runGuidePropBar")
	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.touchDelay = action.touchDelay or 0

	local autoClose = action.autoClose or 10

	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local wSize = Director:sharedDirector():getWinSize()
	local trueMask = LayerColor:create()
	trueMask:changeWidthAndHeight(wSize.width, wSize.height)
	trueMask:setTouchEnabled(true, 0, false)
	trueMask:setOpacity(0)


	local leftPropList = GameBoardLogic:getCurrentLogic().PlayUIDelegate.propList.leftPropList
	
	local propId = 10001
	if action.array and action.array.propId then 
		propId = action.array.propId 
	elseif action.array.gudieAnyTimeProp == true then
		local timeProp , propIndex = leftPropList:findOneTimeProp()
		if timeProp then
			propId = timeProp.prop:findTimePropID()
		end
	end

	local itemFound, itemIndex = leftPropList:findItemByItemID(propId)
	if itemFound then
		local finalPos = leftPropList:ensureItemInSight(itemFound, 0.3)

		itemFound.item:getChildByName("bg_hint2"):setVisible(true)
		itemFound.item:getChildByName("bg_hint2"):setOpacity(255)

		local panelName = action.panelName

		if string.find(panelName , "_R") ~= nil then
			local si , ei = string.find(panelName , "_R")
			panelName = string.sub( panelName , 1 , si - 1 )
		end

		if string.find(panelName , "_L") ~= nil then
			local si , ei = string.find(panelName , "_L")
			panelName = string.sub( panelName , 1 , si - 1 )
		end

		local de = "left"
		printx( -5 , "  GameGuideRunner:runGuidePropBar  finalPos.x = " , finalPos.x)
		if finalPos.x < 400 then
			action.panelName = panelName .. "_L"

			if finalPos.x < 130 then
				action.panAlign = "winY"
				action.panPosY = finalPos.y + 230
				action.panHorizonAlign = "winX"
				action.panPosX = finalPos.x - 180
			else
				action.panAlign = "winY"
				action.panPosY = finalPos.y + 230
				action.panHorizonAlign = "winX"
				action.panPosX = finalPos.x - 220
			end
			
		else
			action.panelName = panelName .. "_R"

			if finalPos.x > 550 then
				action.panAlign = "winY"
				action.panPosY = finalPos.y + 230
				action.panHorizonAlign = "winX"
				action.panPosX = finalPos.x - 360
			else
				action.panAlign = "winY"
				action.panPosY = finalPos.y + 230
				action.panHorizonAlign = "winX"

				action.panPosX = finalPos.x - 300
				
			end
		end
	else
		action.panelName = action.panelName .. "_L"
		action.panHorizonAlign = "winX"
		action.panPosX = -110
	end

	--local panel = GameGuideUI:dialogue( playUI , action )
	printx( -5 , "  GameGuideRunner:runGuidePropBar  action.panelName = " , action.panelName)
	local panel = GameGuideUI:panelS( playUI , action )
	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end
	trueMask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.maskDelay), CCFadeTo:create(action.maskFade, action.opacity)))
	local function onTouch() 
		if trueMask.autoTimer then
			TimerUtil.removeAlarm(trueMask.autoTimer)
		end

		if itemFound and itemFound.item:getChildByName("bg_hint2") then
			itemFound.item:getChildByName("bg_hint2"):setVisible(false)
			itemFound.item:getChildByName("bg_hint2"):setOpacity(0)
		end
		GameGuide:sharedInstance():onGuideComplete() 

		if GameBoardLogic:getCurrentLogic() then
			GameBoardLogic:getCurrentLogic().triggerGuideProp = propId
		end
	end
	local function onDelayOver() trueMask:ad(DisplayEvents.kTouchBegin, onTouch) end
	trueMask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.touchDelay), CCCallFunc:create(onDelayOver)))

	trueMask.autoTimer = TimerUtil.addAlarm(function () 
			trueMask.autoTimer = nil
			onTouch()
		end, autoClose , 1)

	local mainLogic = GameBoardLogic:getCurrentLogic()
	local current_stage = 0
	if mainLogic and mainLogic.level then current_stage = mainLogic.level end
	local high_stage = UserManager:getInstance().user:getTopLevelId()

	--printx( -5 , "    DcUtil:triggerGuideProp   " , propId , Localization:getInstance():getText("prop.name." .. tostring(propId)) , current_stage , high_stage)

	DcUtil:triggerGuideProp(propId, Localization:getInstance():getText("prop.name." .. tostring(propId)), current_stage , high_stage)
	DcUtil:UserTrack({category='prop', sub_category='use_prop_guide', itemId=propId, type=1, current_stage = GameGuideData:sharedInstance():getLevelId()})
end

function GameGuideRunner:removeGuidePropBarWeak()
	if released then return false, false end
	released = true
	local action = GameGuideData:sharedInstance():getRunningAction()
	if action and action.array and action.array.propId and action.array.type then 
		IngamePropGuideManager:getInstance():onFinishGuide(action.array.propId, action.array.type, GameGuideData:sharedInstance():getLevelId())
	end
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end
	return true, true
end

function GameGuideRunner:runGuidePropStrongBack()
	local action = GameGuideData:sharedInstance():getRunningAction()
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local propId = action.array.propId
	-- local mask, panel = initStrongPropStepOne(action, playUI, layer)
	local panelName2 = action.panelName2
	local panelName3 = action.panelName3

	local highlightTarget = {"order4" , 3}
	local mainLogic = GameBoardLogic:getCurrentLogic()
	local pos 
	if mainLogic and mainLogic.PlayUIDelegate then
        pos = mainLogic.PlayUIDelegate.levelTargetPanel:highlightTarget( highlightTarget[1] , highlightTarget[2] , true , false)
    end

    if not pos then 
    	GameGuide:sharedInstance():onGuideComplete()
    	return
    end

	local panelName1 = action.panelName1
	local vs = Director:sharedDirector():getVisibleSize()
	local vo = Director:sharedDirector():getVisibleOrigin()
	local panel = GameGuideUI:panelS(playUI, {panelName = panelName1, panAlign="winY", panHorizonAlign="winX", panPosY=pos.y-170, panPosX=pos.x-50, panDelay=0.2, panFade=0.2}, false)

	local mask = GameGuideUI:mask(200, 0, ccp(pos.x - 60, pos.y-150), 0, true, 125, 150, false, false)

	-- local mask = LayerColor:create()
	local propId = action.array.propId
	-- mask:ignoreAnchorPointForPosition(false)
	-- mask:setAnchorPoint(ccp(0, 0))
	-- mask:setOpacity(0)
	-- mask:setContentSize(CCSizeMake(960, 1480))
	-- mask:setPosition(ccp(0, 0))

	local data, current_count = IngamePropGuideManager:getInstance():getTwoStepsData(propId)



	if layer then
		layer:addChild(mask)
		layer:addChild(panel)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end

	local function finishGuide(denied)
		DcUtil:UserTrack({category='prop', sub_category='use_prop_guide', itemId=propId, type=(denied and 1 or 2), gift=(denied and -1 or 0), current_stage = GameGuideData:sharedInstance():getLevelId(), times =(denied and current_count or current_count+1)})
		IngamePropGuideManager:getInstance():onFinishGuide(propId, 'strong', GameGuideData:sharedInstance():getLevelId(), denied)
		GameGuide:sharedInstance():onGuideComplete()
	end


	local function onStepTwo()
		mask:removeFromParentAndCleanup(true)
		panel:removeFromParentAndCleanup(true)
		mask = nil
		panel = nil
		local leftPropList = GameBoardLogic:getCurrentLogic().PlayUIDelegate.propList.leftPropList
		local itemFound, itemIndex = leftPropList:findItemByItemID(propId)
		if itemFound then
			if layer then
				local finalPos = leftPropList:ensureItemInSight(itemFound, 0.3)
				local panel2 = createStep2Panel(playUI, finalPos, panelName2)
				local size = itemFound.item:getGroupBounds().size
				local newMask = GameGuideUI:mask(200, 0, ccp(finalPos.x-size.width/2, finalPos.y-size.height/2), 0, true, size.width, size.height, false, false)
				newMask:stopAllActions()
				newMask:rma()
				-- save the value in table
				finalPos = {x = finalPos.x, y = finalPos.y}
				size = {width = size.width, height = size.height}
				local function onTouchTap(evt)
					if clickInBound(evt.globalPosition, finalPos.x-size.width/2, finalPos.y-size.height/2, size.width, size.height) then
						newMask:removeFromParentAndCleanup(true)
						panel2:removeFromParentAndCleanup(true)
						if propId ~= 10010 then
							itemFound:use()
						end
						newMask = nil
						panel2 = nil
						finishGuide()
					end
				end
				newMask:ad(DisplayEvents.kTouchTap, onTouchTap)
				layer:addChild(newMask)
				layer:addChild(panel2)
				-- panel2:setPosition(layer:convertToNodeSpace(finalPos))
			end
		end
	end

	local function onUseTapped()
		playUI.propList:addFakeItemForReplay(propId, 1, false)
		onStepTwo()
	end

	local function onCancelTapped()
		finishGuide(true)
	end
	local useBtn = GroupButtonBase:create(panel.ui:getChildByName('keepname_useBtn'))
	useBtn:setString('免费试用')
	useBtn:ad(DisplayEvents.kTouchTap, onUseTapped)

	local cancelBtn = GroupButtonBase:create(panel.ui:getChildByName('keepname_cancelBtn'))
	cancelBtn:setString('不用，谢谢')
	cancelBtn:ad(DisplayEvents.kTouchTap, onCancelTapped)
	cancelBtn:setColorMode(kGroupButtonColorMode.blue)

	return true, true
end

function GameGuideRunner:removeGuidePropStrongBack()
	return GameGuideRunner:removeGuidePropStrongGeneral()
end

function GameGuideRunner:playBuyPreProp(action, yesCallback, closeCallback, failReason)
	local maskDelay = 0.3
	local maskFade = 0.4
	local touchDelay = 1.1
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local wSize = Director:sharedDirector():getWinSize()
	local trueMask = LayerColor:create()
	trueMask:changeWidthAndHeight(wSize.width, wSize.height)
	trueMask:setTouchEnabled(true, 0, true)
	trueMask:setOpacity(0)

	local propId = 10001

	if action.array and type(action.array) == "table" and #action.array > 0 then
		local rindex = math.random(#action.array)
		local d = action.array[ rindex ]
		if d.propId then propId = d.propId end

		if action.panelNameRandomList and type(action.panelNameRandomList) == "table" and #action.panelNameRandomList > 0 then
			action.panelName = action.panelNameRandomList[rindex]
		end
	end

	-- print(table.tostring(action)) debug.debug()

	local panel = GameGuideUI:panelL(action.text, true, action)
	trueMask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(maskDelay), CCFadeTo:create(maskFade, 200)))


	-- 爆炸与直线图标用pkm会变虚，用properties.png里的
	if action.panelName == "guide_dialogue_trigger_3" then
		local oldIcon = panel.ui:getChildByName("guide_dialogue_panel_common_ui/guide_dialogue_prop_icon_sprite_10007")
		oldIcon:setVisible(false)
		local newIcon = ResourceManager:sharedInstance():buildItemSprite(10007)
		newIcon:setCascadeOpacityEnabled(true)
		newIcon:setScale(0.9)
		newIcon:setPositionX(oldIcon:getPositionX()+5)
		newIcon:setPositionY(oldIcon:getPositionY()-10)
		panel.ui:addChild(newIcon)

		newIcon:setOpacity(0)
		newIcon:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.panDelay), CCFadeIn:create(action.panFade)))
	end

	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)
	end

	local function removePanel()
		if trueMask then
			trueMask:removeFromParentAndCleanup(true)
			trueMask = nil
		end
		if panel then
			panel:removeFromParentAndCleanup(true)
			panel = nil
		end
	end

	local failReasonStr = nil
	-- if __WIN32 then
	-- 	failReason = 'refresh'
	-- end
	if failReason == 'refresh' then
		failReasonStr = '无法消除，再试一次吧'
	elseif failReason == 'venom' then
		failReasonStr = '毒液不足，再试一次吧'
	end

	if failReasonStr then
		panel.ui:getChildByName('keepname_t1'):setString(failReasonStr)
	else
		panel.ui:getChildByName('keepname_t1'):setString('遇到难关试试它~')
	end

	-- local timePropId = ItemType:getTimePropItemByRealId(propId)
	-- local timePropCount = UserManager:getInstance():getUserTimePropNumber(timePropId)
	local timePropId = propId
	local timePropCount = UserManager:getInstance():getAllTimePropNumberWithRealItemID( propId )
	local timeProp = UserManager:getInstance():getTimePropsByRealItemId( propId )
	if timeProp and timeProp[1] then
		timePropId = timeProp[1].itemId
	end
	

	local isTimeProp = false
	local propCount = 0
	local usePropId = propId
	if timePropCount > 0 then
		isTimeProp = true
		propCount = timePropCount
		usePropId = timePropId
	else
		propCount = UserManager:getInstance():getUserPropNumber(propId)
	end

	local coinIcon = panel.ui:getChildByName('keepname_coinIcon')
	local priceBg = panel.ui:getChildByName('keepname_priceBg')
	local price = panel.ui:getChildByName('keepname_price')
	
	local useBtn
	local useBtnMFSY = panel.ui:getChildByName('keepname_useBtn_mfsy')
	local useBtnMFSYBCW = panel.ui:getChildByName('keepname_useBtn_mfsybcw')
	if useBtnMFSY then
		useBtn = GroupButtonBase:create(useBtnMFSY)
		useBtn:setString('免费使用')
	elseif useBtnMFSYBCW then
		useBtn = GroupButtonBase:create(useBtnMFSYBCW)
		useBtn:setString('免费使用并重玩')
	end
	local buyBtn
	local buyBtnGMBSY = panel.ui:getChildByName('keepname_buyBtn_gmbsy')
	if buyBtnGMBSY then
		buyBtn = GroupButtonBase:create(buyBtnGMBSY)
		buyBtn:setString('购买并使用')
	end

	if propCount > 0 then
		coinIcon:setVisible(false)
		priceBg:setVisible(false)
		price:setVisible(false)
		local numTip
		if isTimeProp then
			numTip = getRedNumTip()
		else
			numTip = getGreenNumTip()
		end
		numTip:setPosition(ccp(206, -368))
		numTip:setNum(propCount)
		panel.ui:addChild(numTip)
		LogicUtil.setLayerAlpha(numTip, 0)

		numTip:setOpacity(0)
		numTip:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.panDelay), CCCallFunc:create(function( ... )
			AnimationUtil.groupFadeIn(numTip, action.panFade)
		end)))

		useBtn:setVisible(true)
		buyBtn:setVisible(false)

		panel.onCloseButtonTapped = function () 
			removePanel()
			if closeCallback then
				closeCallback()
			end
		end

		panel.onBuyButtonTapped = function () 
			removePanel()
			if yesCallback then
				yesCallback(propId)
			end
		end

	else

		useBtn:setVisible(false)
		buyBtn:setVisible(true)
		price:setString(localize(action.panelName..'.keepname_price'))

		panel.onCloseButtonTapped = function () 
			removePanel()
			if closeCallback then
				closeCallback()
			end
		end


		panel.onBuyButtonTapped = function () 
			removePanel()
			if yesCallback then
				yesCallback(propId)
			end
		end
	end

	

	local mainLogic = GameBoardLogic:getCurrentLogic()
	local current_stage = 0
	if mainLogic and mainLogic.level then current_stage = mainLogic.level end
	local high_stage = UserManager:getInstance().user:getTopLevelId()

	local _t2 
	if propId == ItemType.ADD_THREE_STEP then
		_t2 = 0
		local datas = {}
		datas.t = "useProps"
		datas.uid = UserManager:getInstance():getUID()
		datas.itemList = {propId}
		if mainLogic then
			datas.levelId = mainLogic.level
		else
			datas.levelId = 0
		end
		Localhost:warpEngine( datas )
	elseif propId == ItemType.INITIAL_2_SPECIAL_EFFECT then
		_t2 = 1
	elseif propId == ItemType.INGAME_PRE_REFRESH then
		_t2 = 2
	elseif propId == ItemType.PRE_WRAP_BOMB then
		_t2 = 3
	elseif propId == ItemType.PRE_LINE_BOMB then
		_t2 = 4
	end

	DcUtil:UserTrack({category = 'pregoods', sub_category = 'pregoods_changelocation', t1 = 1, t2 = _t2})
end

function GameGuideRunner:runShowNewPreProp(paras)
	local scene = Director:sharedDirector():getRunningSceneLua()
	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.touchDelay = action.touchDelay or 0

	local startPanel = (type(paras) == "table") and paras.actWin or nil
	if not startPanel or startPanel.panelName ~= 'startGamePanel' or startPanel.isDisposed then
		released = false
		GameGuide:sharedInstance():onGuideComplete()
		return
	end
	
	startPanel.levelInfoPanel:runNewShowPreProp(action)

	local layer = Layer:create()
	function layer:removeNewPrePropGuideMask( ... )
		startPanel.levelInfoPanel:removeNewShowPreProp()
	end
	GameGuideData:sharedInstance():setLayer(layer)
	scene:addChild(layer, SceneLayerShowKey.POP_OUT_LAYER)

	layer:setTouchEnabled(true,-1,true)
	function layer:hitTestPoint( worldPosition, useGroupTest )
		return true
	end
	layer:addEventListener(DisplayEvents.kTouchTap,function( ... )
		GameGuide:sharedInstance():onGuideComplete(false,paras)
	end)

	released = false
end

function GameGuideRunner:removeShowNewPreProp()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		if layer.removeNewPrePropGuideMask then
			layer:removeNewPrePropGuideMask()
		end
		layer:removeChildren(true)
		layer:removeFromParentAndCleanup(true)
	end
	return true, true
end

function GameGuideRunner:runInfiniteEnergy()
	
	if UserManager:getInstance().userExtend:getNewUserReward() == 0 then
		local function onGetRewardComplete(evt)
			-- UserManager:getInstance().userExtend:setNewUserReward(1)
			UserManager:getInstance().userExtend:setNewUserReward(1)
			UserService:getInstance().userExtend:setNewUserReward(1)
	        Localhost:flushCurrentUserData()

			local scene = HomeScene:sharedInstance()
			scene:checkDataChange()
			local logic = UseEnergyBottleLogic:create(ItemType.INFINITE_ENERGY_BOTTLE, DcFeatureType.kGuide, DcSourceType.kEnergyUse)
			logic:start(true)
			
		end
		
		local http = GetNewUserRewardsHttp.new()
		http:addEventListener(Events.kComplete, onGetRewardComplete)
		http:addEventListener(Events.kError, onGetRewardComplete)
		http:load(1)

		local action = GameGuideData:sharedInstance():getRunningAction()
		local playUI = Director:sharedDirector():getRunningScene()
		local layer = playUI.guideLayer
		local vOrigin = Director:sharedDirector():getVisibleOrigin()

		local btn = playUI.energyButton

		local pos = btn:getPosition()
		pos = btn:getParent():convertToWorldSpace(pos)
		pos = layer:convertToNodeSpace(pos)

		local boundSize = playUI.energyButton:getGroupBounds().size
		local trueMask =  GameGuideUI:mask(action.opacity, action.touchDelay, ccp(pos.x + boundSize.width/2, pos.y - boundSize.height/2), 1.25, false, 0, 0, false)

		trueMask.setFadeIn(action.maskDelay, action.maskFade)

		local panel = GameGuideUI:panelS(nil, action, true)
		panel:setPosition(ccp(pos.x - 170, pos.y - 20))

		if layer then
			layer:addChild(trueMask)
			layer:addChild(panel)
			GameGuideData:sharedInstance():setLayer(layer)
			released = false
		end
	end
end

function GameGuideRunner:removeInfiniteEnergy()

	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
		--layer:removeFromParentAndCleanup(true)
	end



	
	return true, true
end

function GameGuideRunner:moveOrTimeCounterPos()
	local playUI = Director:sharedDirector():getRunningScene()
	local moveOrTimeCounter = playUI.moveOrTimeCounter
	if moveOrTimeCounter and moveOrTimeCounter:getParent() then
		return moveOrTimeCounter:getParent():convertToWorldSpace(moveOrTimeCounter:getPosition())
	end
	return nil
end

function GameGuideRunner:levelTargetTilePos(para)
	para = para or 1
	local playUI = Director:sharedDirector():getRunningScene()
	local tile = playUI.levelTargetPanel:getLevelTileByIndex(para)
	if tile and tile:getParent() then
		local pos = tile:getPosition()
		return tile:getParent():convertToWorldSpace(tile:getPosition())
	end
	return nil
end
local bSkipAchieve = false

local ACH_ACT_TAG = 103
function GameGuideRunner:runShowAchieve()

	if AchiUIManager:hasGuide() then
		DcUtil:UserTrack({ category='ui', sub_category='G_achievement_tutorial', other='t1'})
		local playUI = Director:sharedDirector():getRunningScene()
		if not playUI then return end 
		local nextAction = CCCallFunc:create(function ()
			local action = GameGuideData:sharedInstance():getRunningAction()
			if not action then return end
			local layer = playUI.guideLayer
			if not playUI.achiBtn then AchiUIManager:createHomeIcon() end
			if playUI.achiBtn then
				local pos = playUI.achiBtn:convertToWorldSpace(ccp(46, -48))
				local trueMask =  GameGuideUI:mask(action.opacity, action.touchDelay, ccp(pos.x, pos.y), 1.3, false, 0, 0, false)
				trueMask.setFadeIn(action.maskDelay, action.maskFade)

				local panel = GameGuideUI:panelS(nil, action, true)
				panel:setPosition(ccp(pos.x + 70, pos.y - 100))

				local hand = GameGuideAnims:handclickAnim(0, 0)
		    	hand:setPosition(ccp(pos.x, pos.y))
	    		if layer then
					layer:addChild(trueMask)
					layer:addChild(panel)
					layer:addChild(hand)
					layer:addChild(skipButton('跳过', function () bSkipAchieve = true GameGuide:sharedInstance():onGuideComplete() end))
					GameGuideData:sharedInstance():setLayer(layer)
					released = false
				end
			end
		end)
		nextAction:setTag(ACH_ACT_TAG)
		playUI:runAction(nextAction)
	end
end

function GameGuideRunner:removeShowAchieve()

	local playUI = Director:sharedDirector():getRunningScene()
	playUI:stopActionByTag(ACH_ACT_TAG)
	if released then return false, false end
	released = true

	


	if not bSkipAchieve then AchiUIManager:openMainPanel(1, true) end
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end
	return true, true
end



function GameGuideRunner:runGuidePropBarMoleWeek_BossShow()
	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.touchDelay = action.touchDelay or 0

	local autoClose = action.autoClose or 10

	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local wSize = Director:sharedDirector():getWinSize()

    local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local gameBg = playUI.gameBgNode
	local gameBoardView = playUI.gameBoardView

    if not gameBoardView then
         GameGuide:sharedInstance():onGuideComplete()
         return
    end

	local posY = (10 - gameBoardView.startRowIndex) * GamePlayConfig_Tile_Width
	local gPos = gameBoardView:convertToWorldSpace(ccp(0, posY))

    local trueMask = GameGuideUI:mask(action.opacity, 0, ccp(0,gPos.y), 0, true, visibleSize.width, 400, false, false)

	local panel = GameGuideUI:panelS( playUI , action, true )
	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)

        panel:setPosition(ccp(visibleOrigin.x +295, gPos.y-378 ))

		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end
end

function GameGuideRunner:removeGuidePropBarMoleWeek_BossShow()
	if released then return false, false end
	released = true
	local action = GameGuideData:sharedInstance():getRunningAction()
	if action and action.array and action.array.propId and action.array.type then 
		IngamePropGuideManager:getInstance():onFinishGuide(action.array.propId, action.array.type, GameGuideData:sharedInstance():getLevelId())
	end
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end
	return true, true
end

function GameGuideRunner:runGuidePropBarMoleWeek_WaterBoxShow()

	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.touchDelay = action.touchDelay or 0

	local autoClose = action.autoClose or 10

	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local wSize = Director:sharedDirector():getWinSize()

    local mainLogic = GameBoardLogic:getCurrentLogic()
    local result = MoleWeeklyRaceLogic:getVisibleMagicTileLocation(mainLogic)

    local pos = ccp(1,1)
    if result then
        pos =  ccp( result.r, result.c )
    end


    --根据rc获取世界坐标
    local gameBoardView = playUI.gameBoardView
    local posX = (pos.y-1) * GamePlayConfig_Tile_Width
	local posY = (10-pos.x) * GamePlayConfig_Tile_Width
	local gPos = gameBoardView:convertToWorldSpace(ccp(posX, posY))

    local boardViewScale = gameBoardView:getScale()
    local CurCellWidth = GamePlayConfig_Tile_Width*boardViewScale
    local CurCellHeight = GamePlayConfig_Tile_Height*boardViewScale

    local trueMask = GameGuideUI:mask(action.opacity, 0, ccp(gPos.x, gPos.y -  CurCellHeight*2 ), 0, true, CurCellWidth*3, CurCellHeight*2, false, false)

	local panel = GameGuideUI:panelS( playUI , action, true )
	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)

        local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	    local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()

        local downPos = gPos.y-CurCellWidth/2-CurCellWidth*2
        if downPos - 407 < 0 then 
            downPos = gPos.y-CurCellWidth/2 + 10
        else
            downPos = downPos - 407
        end

        panel:setPosition(ccp(visibleOrigin.x +287, downPos ))

		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end
end

function GameGuideRunner:removeGuidePropBarMoleWeek_WaterBoxShow()
	if released then return false, false end
	released = true
	local action = GameGuideData:sharedInstance():getRunningAction()
	if action and action.array and action.array.propId and action.array.type then 
		IngamePropGuideManager:getInstance():onFinishGuide(action.array.propId, action.array.type, GameGuideData:sharedInstance():getLevelId())
	end
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end
	return true, true
end


function GameGuideRunner:runGuidePropBarMoleWeek_BossNotAliveShow()

	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.touchDelay = action.touchDelay or 0

	local autoClose = action.autoClose or 10

	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local wSize = Director:sharedDirector():getWinSize()

    local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()

    --根据rc获取世界坐标
    local gameBoardView = playUI.gameBoardView
	local gPos = gameBoardView:convertToWorldSpace(ccp(0, 0))

    local trueMask = GameGuideUI:mask(action.opacity, 0, ccp(0,0), 0, true, 0, 0, false, false)

	local panel = GameGuideUI:panelS( playUI , action, true )
	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)

        panel:setPosition( ccp(visibleOrigin.x + 288, gPos.y ))

		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end
end

function GameGuideRunner:removeGuidePropBarMoleWeek_BossNotAliveShow()
	if released then return false, false end
	released = true
	local action = GameGuideData:sharedInstance():getRunningAction()
	if action and action.array and action.array.propId and action.array.type then 
		IngamePropGuideManager:getInstance():onFinishGuide(action.array.propId, action.array.type, GameGuideData:sharedInstance():getLevelId())
	end
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end
	return true, true
end

function GameGuideRunner:runGuidePropBarMoleWeek_FindNewWaterBoxShow()

	printx( -5 , "   GameGuideRunner:runGuidePropBarMoleWeek_FindNewWaterBoxShow")
	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.touchDelay = action.touchDelay or 0

	local autoClose = action.autoClose or 10

	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local wSize = Director:sharedDirector():getWinSize()

    local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()

  
    --根据rc获取世界坐标
    local gameBoardView = playUI.gameBoardView
	local gPos = gameBoardView:convertToWorldSpace(ccp(0, 0))

    local trueMask = GameGuideUI:mask(action.opacity, 0, ccp(0,0), 0, true, 0, 0, false, false)

	local panel = GameGuideUI:panelS( playUI , action, true )
	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)

        panel:setPosition( ccp(visibleOrigin.x + 288, gPos.y ))

		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end
end

function GameGuideRunner:removeGuidePropBarMoleWeek_FindNewWaterBoxShow()
	if released then return false, false end
	released = true
	local action = GameGuideData:sharedInstance():getRunningAction()
	if action and action.array and action.array.propId and action.array.type then 
		IngamePropGuideManager:getInstance():onFinishGuide(action.array.propId, action.array.type, GameGuideData:sharedInstance():getLevelId())
	end
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end
	return true, true
end

function GameGuideRunner:runGuidePropBarMoleWeek_BigSkillShow()

	printx( -5 , "   GameGuideRunner:runGuidePropBarMoleWeek_BigSkillShow")
	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.touchDelay = action.touchDelay or 0

	local autoClose = action.autoClose or 10

	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local wSize = Director:sharedDirector():getWinSize()

    local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
    local EndPos = playUI.propList:getSpringItemGlobalPosition()

    local trueMask = GameGuideUI:mask(action.opacity, 0, ccp(EndPos.x-75,EndPos.y-75), 0, true, 150, 150, false, false)

	local panel = GameGuideUI:panelS( playUI , action, true )
	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)

        panel:setPosition(ccp(visibleOrigin.x +295 , EndPos.y+100 ))

		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end
end

function GameGuideRunner:removeGuidePropBarMoleWeek_BigSkillShow()
	if released then return false, false end
	released = true
	local action = GameGuideData:sharedInstance():getRunningAction()
	if action and action.array and action.array.propId and action.array.type then 
		IngamePropGuideManager:getInstance():onFinishGuide(action.array.propId, action.array.type, GameGuideData:sharedInstance():getLevelId())
	end
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end
	return true, true
end

function GameGuideRunner:runGuidePropBarMoleWeek_BigSkillBuyShow()
    --根据 showHint 函数改编
	local action = GameGuideData:sharedInstance():getRunningAction()
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer

	action.animPosY = action.animPosY or 800
	action.animScale = action.animScale or 1
	action.animRotate = action.animRotate or 0
	action.animDelay = action.animDelay or 0
--	action.panOrigin = action.panOrigin or ccp(-450, 600)
--	action.panFinal = action.panFinal or ccp(150, 600)
	action.panDelay = action.panDelay or 0.5
	action.text = action.text or ""

    local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
    local EndPos = playUI.propList:getSpringItemGlobalPosition()
    action.panOrigin = ccp(visibleOrigin.x -550 , EndPos.y-42.3+100/0.7 )
    action.panFinal = ccp(visibleOrigin.x + 184 , EndPos.y-42.3+100/0.7 )

	local sprite = Sprite:createEmpty()
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()

	sprite:setScale(action.animScale)
	sprite:setRotation(action.animRotate)
	if action.reverse then
		sprite:setScaleX(-action.animScale)
		sprite:setPositionX(180 * action.animScale)
	else
		sprite:setPositionX(vSize.width - 180 * action.animScale)
	end

	if type(action.animMatrixR) == "number" then
		sprite:setPositionY(playUI:getRowPosY(action.animMatrixR))
	else
		sprite:setPositionY(vOrigin.y + vSize.height - action.animPosY)
	end
	if not action.panelName then
		local anim = CommonSkeletonAnimation:createTutorialMoveIn()
		local function animPlay() sprite:addChild(anim) end
		sprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.animDelay), CCCallFunc:create(animPlay)))
	end
	local panel
	if action.panelName then
		panel = GameGuideUI:dialogue(nil, action, skipText)
	else
		panel = GameGuideUI:panelMini(action.text)
	end

	panel:setPosition(ccp(action.panOrigin.x, action.panOrigin.y))

	local function onComplete() GameGuide:sharedInstance():onGuideComplete() end
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(action.panDelay))
	array:addObject(CCEaseBackOut:create(CCMoveTo:create(0.2, ccp(action.panFinal.x, action.panFinal.y))))

	array:addObject(CCDelayTime:create(2.5))
	local function panFadeOut()
		if panel and not panel.isDisposed then
			local childrenList = {}
			panel:getVisibleChildrenList(childrenList)
			for __, v in pairs(childrenList) do
				v:runAction(CCFadeOut:create(0.5))
			end
		end
	end
	array:addObject(CCCallFunc:create(panFadeOut))
	array:addObject(CCDelayTime:create(0.5))
	array:addObject(CCCallFunc:create(onComplete))
	panel:runAction(CCSequence:create(array))

	if layer then
		layer:addChild(sprite)
		layer:addChild(panel)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end
end

function GameGuideRunner:removeGuidePropBarMoleWeek_BigSkillBuyShow()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end
	return true, true
end


function GameGuideRunner:runGuidePropBarMoleWeek_BossReLifeShow()

	printx( -5 , "   GameGuideRunner:nGuidePropBarMoleWeek_BossReLifeShow")
	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.touchDelay = action.touchDelay or 0

	local autoClose = action.autoClose or 10

	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local wSize = Director:sharedDirector():getWinSize()

    local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local gameBg = playUI.gameBgNode
	local gameBoardView = playUI.gameBoardView
	local posY = (10 - gameBoardView.startRowIndex) * GamePlayConfig_Tile_Width
	local gPos = gameBoardView:convertToWorldSpace(ccp(0, posY))

    local trueMask = GameGuideUI:mask(action.opacity, 0, ccp(0,gPos.y), 0, true, visibleSize.width, 180, false, false)

	local panel = GameGuideUI:panelS( playUI , action, true )
	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)

        panel:setPosition(ccp(visibleOrigin.x +295, gPos.y-378 ))

		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end
end

function GameGuideRunner:removeGuidePropBarMoleWeek_BossReLifeShow()
	if released then return false, false end
	released = true
	local action = GameGuideData:sharedInstance():getRunningAction()
	if action and action.array and action.array.propId and action.array.type then 
		IngamePropGuideManager:getInstance():onFinishGuide(action.array.propId, action.array.type, GameGuideData:sharedInstance():getLevelId())
	end
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end
	return true, true
end


function GameGuideRunner:runGuidePropBarMoleWeek_SkillShow()

	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.touchDelay = action.touchDelay or 0
    action.itemType = action.itemType or GameItemType.kYellowDiamondGrass
    action.itemWidth = action.itemWidth or 1
    action.itemHeight = action.itemHeight or 1
    action.guideWidth = action.guideWidth or 287

	local autoClose = action.autoClose or 10

	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local wSize = Director:sharedDirector():getWinSize()

    local mainLogic = GameBoardLogic:getCurrentLogic()
    local result = MoleWeeklyRaceLogic:getTargetLocationForGuide( mainLogic, action.SkillType )

    local pos = ccp(2,1)
    if result then
        pos =  ccp( result.r, result.c )
    end

     MoleWeeklyRaceLogic:setTargetLocationForGuideEnd( mainLogic, action.SkillType )

    --根据rc获取世界坐标
    local gameBoardView = playUI.gameBoardView
    local posX = (pos.y-1) * GamePlayConfig_Tile_Width
	local posY = (10-pos.x) * GamePlayConfig_Tile_Width
	local gPos = gameBoardView:convertToWorldSpace(ccp(posX, posY))
    local boardViewScale = gameBoardView:getScale()

    local CurCellWidth = GamePlayConfig_Tile_Width*boardViewScale
    local CurCellHeight = GamePlayConfig_Tile_Height*boardViewScale

    local trueMask = GameGuideUI:mask(action.opacity, 0, ccp( gPos.x , gPos.y  - action.itemHeight*CurCellWidth ), 0, true, action.itemWidth * CurCellWidth, action.itemHeight * CurCellHeight, false, false)

	local panel = GameGuideUI:panelS( playUI , action, true )
	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)

        local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	    local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()

        local GuideHeight = 407
        local downPos = gPos.y-CurCellWidth*action.itemHeight
        if downPos - GuideHeight < 0 then 
            downPos = gPos.y+10
            if downPos + GuideHeight > visibleOrigin.y + visibleSize.height then 
                downPos = gPos.y-CurCellWidth*action.itemHeight
            end
        else
            downPos = downPos - GuideHeight
        end

        panel:setPosition(ccp(visibleOrigin.x + action.guideWidth, downPos ))

		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end
end

function GameGuideRunner:removeGuidePropBarMoleWeek_SkillShow()
	if released then return false, false end
	released = true
	local action = GameGuideData:sharedInstance():getRunningAction()
	if action and action.array and action.array.propId and action.array.type then 
		IngamePropGuideManager:getInstance():onFinishGuide(action.array.propId, action.array.type, GameGuideData:sharedInstance():getLevelId())
	end
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end
	return true, true
end




function GameGuideRunner:runGuideMoleWeek_addStep()

	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.touchDelay = action.touchDelay or 0

	local autoClose = action.autoClose or 10

	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local wSize = Director:sharedDirector():getWinSize()

    local mainLogic = GameBoardLogic:getCurrentLogic()

    local gameBoardView = playUI.gameBoardView


    local pos =  ccp(0,0)
    local freeBtn = nil
    if PopoutManager:sharedInstance():haveWindowOnScreen() then
        local popoutPanel = PopoutManager:sharedInstance():getLastPopoutPanel()

        if popoutPanel.panelName == "MoleWeekAddFivePanel" then

            freeBtn = popoutPanel.freeBtn
            pos = freeBtn:getParent():convertToWorldSpace(freeBtn:getPosition())
        end
    end

    local trueMask = GameGuideUI:mask( action.opacity, 0, ccp( 0,0 ), 0, true, 0, 0, false, true)

    local function ClickCallback( evt )
        
        if freeBtn then
            if freeBtn:hitTestPoint(evt.globalPosition, true) then  
                local event = {name = DisplayEvents.kTouchTap}
                freeBtn:dispatchEvent(event)

                UserLocalLogic:setGuideFlag( kGuideFlags.MoleWeekAdd5Step )
                GameGuide:sharedInstance():onGuideComplete()
            end
        else
            GameGuide:sharedInstance():onGuideComplete()
        end
    end
    trueMask:ad(DisplayEvents.kTouchBegin, ClickCallback)

	local panel = GameGuideUI:panelS( playUI , action, false )
	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)

        local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	    local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()

        panel:setPosition(ccp(pos.x, pos.y - 90 -173 ))

		GameGuideData:sharedInstance():setLayer(layer)
		
        --手指
        local hand = GameGuideAnims:handclickAnim(action.maskDelay, action.maskFade)
	    hand:setAnchorPoint(ccp(0, 1))
	    hand:setPosition(ccp(pos.x, pos.y))
		layer:addChild(hand)

        released = false
	end
end

function GameGuideRunner:removeGuideMoleWeek_addStep()
	if released then return false, false end
	released = true
	local action = GameGuideData:sharedInstance():getRunningAction()
	if action and action.array and action.array.propId and action.array.type then 
		IngamePropGuideManager:getInstance():onFinishGuide(action.array.propId, action.array.type, GameGuideData:sharedInstance():getLevelId())
	end
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end
	return true, true
end


function GameGuideRunner:runGuideSheQu()

	local action = GameGuideData:sharedInstance():getRunningAction()
	action.maskDelay = action.maskDelay or 0
	action.maskFade = action.maskFade or 0.3
	action.touchDelay = action.touchDelay or 0

	local autoClose = action.autoClose or 10

	local playUI = Director:sharedDirector():getRunningScene()
	local scale = playUI.iconLayerScale or 1
	local layer = playUI.guideLayer
	local wSize = Director:sharedDirector():getWinSize()
    local settingBtn = playUI.settingButton
    local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local pos = settingBtn:getParent():convertToWorldSpace(settingBtn:getPosition())
	pos = layer:convertToNodeSpace(pos)

--    local trueMask = GameGuideUI:mask( action.opacity, 0, ccp( pos.x, pos.y-150 ), 0, true, 160, 160, false, true)

    local trueMask = GameGuideUI:mask(
    action.opacity, 
        0, 
        ccp( pos.x+86/scale, pos.y-61/scale ),
        1.3/scale, 
        false, 
        nil, 
        nil, 
        false,
        true
        )

    local function ClickCallback( evt )
        UserLocalLogic:setGuideFlag( kGuideFlags.SheQuGuide )
        GameGuide:sharedInstance():onGuideComplete()
    end
    trueMask:ad(DisplayEvents.kTouchBegin, ClickCallback)

	local panel = GameGuideUI:panelS( playUI , action, false )
	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)

        panel:setPosition( ccp(pos.x+404+80, pos.y-150 + 159 + 160 ) )

		GameGuideData:sharedInstance():setLayer(layer)
        released = false
	end
end

function GameGuideRunner:removeGuideSheQu()
	if released then return false, false end
	released = true
	local action = GameGuideData:sharedInstance():getRunningAction()
	if action and action.array and action.array.propId and action.array.type then 
		IngamePropGuideManager:getInstance():onFinishGuide(action.array.propId, action.array.type, GameGuideData:sharedInstance():getLevelId())
	end
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end
	return true, true
end

function GameGuideRunner:runGuideFriendSheQuCenter()
	print("GameGuideRunner:runGuideFriendSheQuCenter()")

	local playUI = Director:sharedDirector():getRunningScene()

	local layer = Layer:create()
	playUI:addChild(layer)

	GameGuideData:sharedInstance():setLayer(layer)
    released = false
	
	local function doShowPanel()
		local pos = ccp(600,700)
		--"friendsPanel"
		local panel = GameGuideData:sharedInstance().currPopPanel
		if panel and panel.friendRankingPage and panel.friendRankingPage.targetGuideItem then
			--FriendRankingItem
			local btn = panel.friendRankingPage.targetGuideItem.homeBtn

			if not btn or not btn:getParent() then
				print(" GameGuideRunner:runGuideFriendSheQuCenter()---------force quit!")
		        GameGuide:sharedInstance():onGuideComplete()
				return
			end

			pos = btn:getParent():convertToWorldSpace(btn:getPosition())
			pos.x = pos.x+35
			pos.y = pos.y-35
		end
		pos = layer:convertToNodeSpace(pos)
		-- print("---doShowPanel()",pos.x,pos.y,pos.y>800 and 1800 or 1000 )

		local action = GameGuideData:sharedInstance():getRunningAction()
		action.maskDelay = action.maskDelay or 0
		action.maskFade = action.maskFade or 0.3
		action.touchDelay = action.touchDelay or 0

	    local function ClickCallback( evt )
	        GameGuide:sharedInstance():onGuideComplete()
	    end

	    local trueMask = GameGuideUI:mask(
	    action.opacity, 
	        0, 
	        ccp(605,pos.y),
	        1.3, 
	        false, 
	        nil, 
	        nil, 
	        false,
	        true
	        )
	    trueMask:ad(DisplayEvents.kTouchBegin, ClickCallback)
		layer:addChild(trueMask)

		if panel and panel.friendRankingPage and panel.friendRankingPage.isSelfTargetItem then
			action.panelName = "guide_dialogue_friend_faq_self"
		end

		local panel = GameGuideUI:panelS( playUI , action, false )
	    panel:setPosition( ccp(-50, pos.y+300 ) )

		layer:addChild(panel)
	end

	layer:runAction(CCSequence:createWithTwoActions(
        CCDelayTime:create(0.1),
        CCCallFunc:create(function()
        	doShowPanel()
	    end)
    ))
end

function GameGuideRunner:removeGuideFriendSheQuCenter()
	print("GameGuideRunner:removeGuideFriendSheQuCenter()")

	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and (not layer.isDisposed) then
		layer:removeFromParentAndCleanup(true)
	end
	return true, true
end

function GameGuideRunner:runGudieAnim( paras )
	if type(paras) ~= 'table' then return end
	local panel = paras.actWin
	if (not panel) or panel.isDisposed then return end

	panel:runAction(CCCallFunc:create(function ( ... )
		if panel.isDisposed then return end


		local action = GameGuideData:sharedInstance():getRunningAction()

		local anchorNodePath = action.anchorNodePath
		local skeletonRes = action.skeletonRes
		local armatureName = action.armatureName
		local offset = action.offset or ccp(0, 0)

		local anchorNode = panel:getChildByPath(anchorNodePath)
		local bounds = anchorNode:getGroupBounds()
		local pos = ccp(bounds:getMidX(), bounds:getMidY())


		local trueMask = GameGuideUI:mask(action.opacity or 200, action.touchDelay or 2, pos, action.radius, false, 0, 0, false)
		panel:addChild(trueMask)
		trueMask:ignoreAnchorPointForPosition(false)
		-- trueMask.setFadeIn(action.maskDelay or 0.1, action.maskFade or 0.1)

		local vOrigin = Director:sharedDirector():getVisibleOrigin()
		local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
  		layoutUtils.setNodeRelativePos(trueMask, layoutUtils.MarginType.kLEFT, 0)
		layoutUtils.setNodeRelativePos(trueMask, layoutUtils.MarginType.kBOTTOM,  -vOrigin.y)
		trueMask:setScale(1/panel:getScaleX())


		local UIHelper = require 'zoo.panel.UIHelper'
		local anim = UIHelper:createArmature2(skeletonRes, armatureName)
		anim:playByIndex(0, 1)
		anim.name = '__GuideAnim'
		
		pos = trueMask:convertToNodeSpace(pos)
		anim:setPosition(ccp(pos.x + offset.x, pos.y + offset.y))
		trueMask:addChild(anim)


		local inputLayer = Layer:create()
		-- local inputLayer = LayerColor:create()
		-- inputLayer:setColor(ccc3(0, 0, 23))
		inputLayer:setAnchorPoint(ccp(0.5, 0.5))
		inputLayer:ignoreAnchorPointForPosition(false)
		inputLayer:changeWidthAndHeight(bounds.size.width, bounds.size.height)
		inputLayer:setPosition(pos)
		trueMask:addChild(inputLayer)
		inputLayer:setTouchEnabled(true, 0, true)
		inputLayer:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
			if action.handler then
				GameGuide:sharedInstance():onGuideComplete()
				action.handler()
				-- action.handler = nil
			end
		end))

		inputLayer:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(5), CCCallFunc:create(function ( ... )
			if inputLayer and (not inputLayer.isDisposed) then
				GameGuide:sharedInstance():onGuideComplete()
			end
		end)))

		GameGuideData:sharedInstance():setLayer(trueMask)

		released = false
	end))

end

function GameGuideRunner:removeGudieAnim( paras )
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and (not layer.isDisposed) then
		layer:removeFromParentAndCleanup(true)
	end
	return true, true
end



--春节大招引导
function GameGuideRunner:runGuideSpringFestival2019UseSkill()
    --根据 showHint 函数改编
	local action = GameGuideData:sharedInstance():getRunningAction()
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer

	action.animPosY = action.animPosY or 800
	action.animScale = action.animScale or 1
	action.animRotate = action.animRotate or 0
	action.animDelay = action.animDelay or 0
	action.panDelay = action.panDelay or 0.5
	action.text = action.text or ""

    local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
    local EndPos = playUI.propList:getSpringItemGlobalPosition()
    action.panOrigin = ccp(visibleOrigin.x -630 , EndPos.y-42.3+550/0.7 )
    action.panFinal = ccp(visibleOrigin.x + 50 , EndPos.y-42.3+550/0.7 )

	local sprite = Sprite:createEmpty()
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()

	sprite:setScale(action.animScale)
	sprite:setRotation(action.animRotate)
	if action.reverse then
		sprite:setScaleX(-action.animScale)
		sprite:setPositionX(180 * action.animScale)
	else
		sprite:setPositionX(vSize.width - 180 * action.animScale)
	end

	if type(action.animMatrixR) == "number" then
		sprite:setPositionY(playUI:getRowPosY(action.animMatrixR))
	else
		sprite:setPositionY(vOrigin.y + vSize.height - action.animPosY)
	end
	if not action.panelName then
		local anim = CommonSkeletonAnimation:createTutorialMoveIn()
		local function animPlay() sprite:addChild(anim) end
		sprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.animDelay), CCCallFunc:create(animPlay)))
	end

    local rightPropList = GameBoardLogic:getCurrentLogic().PlayUIDelegate.propList.rightPropList

    local worldPos = ccp(0,0)
    local  rect = CCSize(0,0)
    if rightPropList then
        local rightPropPos = rightPropList:getPosition()

        worldPos = rightPropList:getParent():convertToWorldSpace( ccp(rightPropPos.x-170/0.7,rightPropPos.y+65/0.7) )

        local worldPos2 = rightPropList:getParent():convertToWorldSpace( ccp(rightPropPos.x-170/0.7+420,rightPropPos.y+65/0.7+230) )
        rect = {width = worldPos2.x - worldPos.x, height = worldPos2.y - worldPos.y}
    end

    local trueMask = GameGuideUI:mask(180, 0.2, ccp( worldPos.x,worldPos.y ), 0, true, rect.width, rect.height, false, true)

	local panel = GameGuideUI:dialogue(nil, action, Localization:getInstance():getText("game.guide.panel.skip.text") )
	panel:setPosition(ccp(action.panOrigin.x, action.panOrigin.y))

	local function onComplete() GameGuide:sharedInstance():onGuideComplete() end
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(action.panDelay))
	array:addObject(CCEaseBackOut:create(CCMoveTo:create(0.2, ccp(action.panFinal.x, action.panFinal.y))))
	array:addObject(CCDelayTime:create(2.5))

	local function panFadeOut()
		if panel and not panel.isDisposed then
			local childrenList = {}
			panel:getVisibleChildrenList(childrenList)
			for __, v in pairs(childrenList) do
				v:runAction(CCFadeOut:create(0.5))
			end
		end
	end
	panel:runAction(CCSequence:create(array))

    local function onTouchTap(evt)
        local array = CCArray:create()
		array:addObject(CCCallFunc:create(panFadeOut))
    	array:addObject(CCDelayTime:create(0.5))
    	array:addObject(CCCallFunc:create(onComplete))
	    panel:runAction(CCSequence:create(array))
	end

    local function addTouchEvent(evt)
	    trueMask:removeAllEventListeners()
	    trueMask:ad(DisplayEvents.kTouchTap, onTouchTap)
    end
	trueMask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(2), CCCallFunc:create(addTouchEvent)))

	if layer then
        layer:addChild(trueMask) 
		layer:addChild(sprite)
		layer:addChild(panel)
		GameGuideData:sharedInstance():setLayer(layer)
		released = false
	end
end

function GameGuideRunner:removeGuideSpringFestival2019UseSkill()
	if released then return false, false end
	released = true
	local layer = GameGuideData:sharedInstance():getLayer()
	if layer and not layer.isDisposed then
		layer:removeChildren(true)
	end
	return true, true
end