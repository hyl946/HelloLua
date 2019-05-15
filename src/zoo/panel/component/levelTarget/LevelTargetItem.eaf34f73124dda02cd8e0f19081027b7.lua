require "zoo.panel.component.levelTarget.TargetNumberAnimation"

TargetItemFactory = class()

function TargetItemFactory.create(class, itemSprite, targetIndex, context)
	local item = class.new(itemSprite, targetIndex, context)
	item:init()

	local function onTouchBegin(evt)
		item:onTouchBegin(evt)
	end
	itemSprite:ad(DisplayEvents.kTouchBegin, onTouchBegin)
	context:addTouchList(itemSprite)
	return item
end

LevelTargetItem = class()

function LevelTargetItem:ctor(itemSprite, targetIndex, context)
	self.sprite = itemSprite
	self.targetIndex = targetIndex
	self.context = context
	self.shadowSprite = Layer:create()
	self.shadowSprite:setAnchorPoint(ccp(0,0))
end

function LevelTargetItem:create(itemSprite, targetIndex, context)
	-- local item = LevelTargetItem.new(itemSprite, targetIndex, context)
	-- item:init()

	-- local function onTouchBegin(evt)
	-- 	item:onTouchBegin(evt)
	-- end

	-- itemSprite:ad(DisplayEvents.kTouchBegin, onTouchBegin)
	-- itemSprite:setTouchEnabled(true)

	-- return item
end

function LevelTargetItem:getContentSize()
	return self.sprite:getContentSize()
end

function LevelTargetItem:setVisible(visible)
	self.shadowSprite:setVisible(visible)
	return self.sprite:setVisible(visible)
end

function LevelTargetItem:getPosition()
	return self.sprite:getPosition()
end

function LevelTargetItem:setPosition(pos)
	self.sprite:setPosition(pos)
	self.shadowSprite:setPosition(ccp(pos.x, pos.y))
end

function LevelTargetItem:getGroupBounds()
	return self.sprite:getGroupBounds()
end

function LevelTargetItem:getParent()
	return self.sprite:getParent()
end

function LevelTargetItem:rma()
	self.sprite:rma()
end
 
function LevelTargetItem:onTouchBegin(evt)

	if GamePlayContext:getInstance():getCurrentReplayMode() == ReplayMode.kReview then
		return
	end
	
	self:shakeObject()
	self.context:playLeafAnimation(true)
	self.context:playLeafAnimation(false)
	if not evt.target then return end
	local target = self.context.targets[self.targetIndex]
	if target then 
		if target.type == "order2" or target.type == "order3" then
			CommonTip:showTip(Localization:getInstance():getText("game.target.tips."..target.type..'.'..target.id, {num = self.itemNum}), "positive")
		end
	end
	he_log_info("auto_test_tap_target")

end

function LevelTargetItem:shakeSprite(sprite, startRotation, finishCallback )
    sprite:stopAllActions()
    sprite:setRotation(0)

    local original = sprite.original
    if not original then
    	original = sprite:getPosition() 
    	sprite.original = {x=original.x, y=original.y}
	end
    sprite:setPosition(ccp(original.x, original.y))

    local array = CCArray:create()
    local startTime = 0.35
    local function onShakeFinish()
    	if finishCallback then finishCallback() end
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
end

function LevelTargetItem:shakeObject( rotation )
	-- body
	if self.isShaking then return false end
	self.isShaking = true

	local function finish( ... )
		-- body
		self.isShaking = false
	end
	local direction = 1
    if math.random() > 0.5 then direction = -1 end

    rotation = rotation or 4
    local startRotation = direction * (math.random() * 0.5 * rotation + rotation)
	self:shakeSprite(self.sprite, startRotation, finish)
	self:shakeSprite(self.shadowSprite, startRotation)
	return true
end

function LevelTargetItem:shakeSpriteByCollect(sprite, finishCallback)
    sprite:stopAllActions()
    sprite:setRotation(0)

    local original = sprite.original
    if not original then
    	original = sprite:getPosition() 
    	sprite.original = {x=original.x, y=original.y}
	end
    sprite:setPosition(ccp(original.x, original.y))

    local array = CCArray:create()
    local timePerFrame = 1 / 24
    local function onShakeFinish()
    	if finishCallback then finishCallback() end
    end
    array:addObject(CCRotateTo:create(timePerFrame * 3, 6))
    array:addObject(CCRotateTo:create(timePerFrame * 4, -5))
    array:addObject(CCRotateTo:create(timePerFrame * 4, 3))
    array:addObject(CCRotateTo:create(timePerFrame * 3, -2.5))
    array:addObject(CCRotateTo:create(timePerFrame * 3, 2))
    array:addObject(CCRotateTo:create(timePerFrame * 3, 0))
    array:addObject(CCCallFunc:create(onShakeFinish))

    sprite:runAction(CCSequence:create(array))
end

function LevelTargetItem:shakeObjectByCollect()
	if self.isShaking then return false end
	self.isShaking = true

	local function finish( ... )
		self.isShaking = false
	end
	self:shakeSpriteByCollect(self.sprite, finish)
	self:shakeSpriteByCollect(self.shadowSprite, finish)
	return true
end

function LevelTargetItem:initContent()
	local content = self.sprite:getChildByName("content")
	if content then
	    local zOrder = content:getZOrder()
	    self.zOrder = 0--zOrder
		local contentPos = content:getPosition()
		local contentSize = content:getContentSize()

		self.iconSize = {x = contentPos.x, y = contentPos.y, width=contentSize.width, height=contentSize.height}
		content:removeFromParentAndCleanup(true)
	end
end

function LevelTargetItem:init()

	local spriteSize = self.sprite:getGroupBounds().size
	self.sprite:setContentSize(CCSizeMake(spriteSize.width, spriteSize.height))
	self.shadowSprite:setContentSize(CCSizeMake(spriteSize.width, spriteSize.height))
	self.sprite:setAnchorPoint(ccp(0,0))
	self.shadowSprite:setAnchorPoint(ccp(0,0))
	local pos = self.sprite:getPosition()
	self.shadowSprite:setPosition(ccp(pos.x,pos.y))
	self.context.attachSprite:addChild(self.shadowSprite)
	self:initContent()

	local fntFile	= "fnt/animal_num.fnt"
	local text = BitmapText:create("", fntFile, -1, kCCTextAlignmentRight)
	text.fntFile 	= fntFile
	text.hAlignment = kCCTextAlignmentRight
	text:setPosition(ccp(-39,  -94.45))
	text.offsetX = text:getPosition().x
	text:setAnchorPoint(ccp(0,1))
	text:setPreferredSize(80, 38)
	text:setAlignment(kCCTextAlignmentRight)
	text:setString("0")
	text:setScale(2)
	text:setOpacity(0)
	self.shadowSprite:addChild(text)
	self.label = text

	local finished = self:initFinishedIcon(self.sprite:getChildByName("finished"))
	self.finishedIcon = finished
	finished:removeFromParentAndCleanup(false)
	self.shadowSprite:addChild(finished)

    local highlight = self.sprite:getChildByName('highlight')
    highlight:setVisible(false)

	self.isFinished = false
end

function LevelTargetItem:initFinishedIcon(group)
	local finished = group
	local finished_icon = finished:getChildByName("icon")
	local finished_icon_big = finished:getChildByName("icon1")
	local finished_size = finished_icon:getContentSize()
	local finished_bg = finished:getChildByName("bg")
	finished:setVisible(false)
	-- local finishedPos = finished:getPosition()
	-- finished:setPosition(ccp(finishedPos.x + finished_size.width/2, finishedPos.y - finished_size.height/2))
	finished_icon:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
	finished_bg:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
	finished_icon_big:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))

	finished_icon_big:setVisible(false)
	finished_bg:setVisible(false)

	self.finished_icon = finished_icon
	self.finished_bg = finished_bg
	self.finished_icon_big = finished_icon_big

	return finished
end

function LevelTargetItem:reset()
	local finished = self.finishedIcon
	finished:setVisible(false)
	self.label:setVisible(true)
end

function LevelTargetItem:playFinishAnim(finishedUi, onShake)
	local bigIcon = finishedUi:getChildByName("icon1")
	local icon = finishedUi:getChildByName("icon")
	local holo = finishedUi:getChildByName("bg")

	local timePerFrame = 1 / 30

	bigIcon:stopAllActions()
	bigIcon:setScale(1.2)
	bigIcon:setOpacity(255)
	bigIcon:runAction(CCSpawn:createWithTwoActions(CCScaleTo:create(timePerFrame * 3, 0.4), CCFadeTo:create(timePerFrame * 3, 0)))

	icon:stopAllActions()
	icon:setScale(2.4)
	icon:setOpacity(0)
	local actSeq = CCArray:create()
	actSeq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(timePerFrame * 3, 0.8), CCFadeTo:create(timePerFrame * 3, 255)))
	local function callShake()
		if type(onShake) == "function" then onShake() end
	end
	actSeq:addObject(CCCallFunc:create(callShake))
	actSeq:addObject(CCScaleTo:create(timePerFrame * 2, 1))
	icon:runAction(CCSequence:create(actSeq))

	holo:stopAllActions()
	holo:setVisible(false)
	holo:setOpacity(255)
	holo:setScale(0.5)
	local holoActSeq = CCArray:create()
	holoActSeq:addObject(CCDelayTime:create(timePerFrame))
	holoActSeq:addObject(CCShow:create())
	holoActSeq:addObject(CCScaleTo:create(timePerFrame * 2, 1.6))
	holoActSeq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(timePerFrame * 5, 2), CCFadeTo:create(timePerFrame * 5, 255 * 0.3)))
	holoActSeq:addObject(CCHide:create())
	holo:runAction(CCSequence:create(holoActSeq))
end

function LevelTargetItem:finish()
	if self.isFinished then return end
	self.isFinished = true
	self.label:setVisible(false)
	local finished = self.finishedIcon
	finished:setVisible(true)

	local function onPlayShake()
		self:shake()
	end
	self:playFinishAnim(self.finishedIcon, onPlayShake)
end

function LevelTargetItem:shake()
	if self.isFinished then return end
	self:shakeObject()
	local icon = self.icon
	local label = self.label
	
	if icon then
		local sequence = CCArray:create()
		sequence:addObject(CCDelayTime:create((self.targetIndex-1) * 0.1))
		sequence:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.15, 1.6), CCFadeIn:create(0.15)))
		sequence:addObject(CCScaleTo:create(0.15, 1))
		icon:stopAllActions()
		icon:runAction(CCSequence:create(sequence))
	end
	if label then
		label:setOpacity(0)
		label:setScale(2)

		local labelSeq = CCArray:create()
		labelSeq:addObject(CCDelayTime:create(0.3 + (self.targetIndex-1) * 0.1))
		labelSeq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.15, 1), CCFadeIn:create(0.15)))
		label:stopAllActions()
		label:runAction(CCSequence:create(labelSeq))
	end
end

function LevelTargetItem:setContentIcon(icon, number )
	if self.icon then
		self.icon:removeFromParentAndCleanup(true)
	end
	self.icon = icon
	if self.icon and self.iconSize then
		local iconContentSize = self.iconSize
		local iconSize = self.icon:getContentSize()
		local y = iconContentSize.y - (iconContentSize.height)/2
		self.icon:setPosition(ccp(3, y - 3))
		self.icon:setOpacity(0)
		self.shadowSprite:addChildAt(icon, self.zOrder)
	end
	local label = self.label
	if number ~= nil and label then
		label:setString(tostring(number or 0))
		label:setOpacity(0)
		label:setScale(2)
	end
end

function LevelTargetItem:setTargetNumber(itemId, itemNum, animate, globalPosition )
	if self.isFinished then return end
	if not self.sprite.refCocosObj then return end

	-- local vs = Director:sharedDirector():getVisibleSize()
	-- local vo = Director:sharedDirector():getVisibleOrigin()
	-- globalPosition = ccp(vo.x + vs.width/2, vo.y + vs.height/2)
	if itemNum ~= nil then
		self.itemNum = itemNum

		if animate and globalPosition and self.icon then

			local cloned 

			local target = self.context.targets[self.targetIndex]

			if target and TargetNumberAnimation[target.type] and TargetNumberAnimation[target.type][itemId] then
				cloned = TargetNumberAnimation[target.type][itemId]()
				self.icon:getParent():getParent():addChild(cloned)
			else
				cloned = self.icon:clone(true)
			end

			local flyDestPos = ccp(
				self.icon:getPositionX() + self.icon:getParent():getPositionX(),
				self.icon:getPositionY() + self.icon:getParent():getPositionY()
			)

			local function _fly( ... )
				local tx, ty = flyDestPos.x, flyDestPos.y
				local function onIconScaleFinished()
					cloned:removeFromParentAndCleanup(true)
					self.animNode = nil
				end

				local function onIconMoveFinished()			
					if itemNum <= 0 then self:finish() end
					self.label:setString(tostring(itemNum or 0))
					self.context:playLeafAnimation(true)
					self.context:playLeafAnimation(false)
					self:shakeObjectByCollect()

					local standardScale = 1
					if cloned.getStandardScale then
						standardScale = cloned:getStandardScale()
					end

					local sequence = CCSpawn:createWithTwoActions(CCScaleTo:create(0.3, 2 * standardScale), CCFadeOut:create(0.3))
					cloned:setOpacity(255)
					cloned:runAction(CCSequence:createWithTwoActions(sequence, CCCallFunc:create(onIconScaleFinished)))
				end
				local moveTo = CCEaseSineInOut:create(CCMoveTo:create(0.5, ccp(tx, ty)))
				local moveOut = CCSpawn:createWithTwoActions(moveTo, CCFadeTo:create(0.5, 150))
				self.animNode = cloned
				cloned:runAction(CCSequence:createWithTwoActions(moveOut, CCCallFunc:create(onIconMoveFinished)))
				if cloned.playScaleAnim then
					cloned:playScaleAnim()
				end
			end

			local startPos = cloned:getParent():convertToNodeSpace(globalPosition)
			cloned:setPosition(startPos)
			if cloned.playAppearAnim then
				cloned:playAppearAnim(_fly)
			else
				_fly()
			end
		else
			if itemNum <= 0 then self:finish() end
			self.label:setString(tostring(itemNum or 0))
		end
	end
end

function LevelTargetItem:revertTargetNumber(itemId, itemNum )
	if itemNum ~= nil then
		self.itemNum = itemNum
		if itemNum > 0 then 				
			self:reset()
			self.isFinished = false 
		elseif itemNum <= 0 then 
			self:finish() 
		end
		self.label:setString(tostring(itemNum or 0))
	end
end

function LevelTargetItem:highlight(enable, showRaccoon)
    if _G.isLocalDevelopMode then printx(0, 'sprite.highlight') end
    if self.highlighted == nil then
        self.highlighted = false
    end

    if self.highlighted == true then
        if enable == true then 
            return 
        else
            -- disable highlight
            if _G.isLocalDevelopMode then printx(0, 'disable') end
            self.highlighted = false
            local highlight = self.sprite:getChildByName('highlight')
            highlight:stopAllActions()
            highlight:setVisible(false)
            
        end
    elseif self.highlighted == false then
        if not enable then 
            return 
        else
            if _G.isLocalDevelopMode then printx(0, 'enable') end
            self.highlighted = true
            local highlight = self.sprite:getChildByName('highlight')
            highlight:stopAllActions()
            highlight:setVisible(true)
            local array = CCArray:create()
            array:addObject(CCFadeTo:create(0.5, 125))
            array:addObject(CCFadeTo:create(0.5, 255))
            highlight:runAction(CCRepeatForever:create(CCSequence:create(array)))
            
            showRaccoon = false --禁用老版本引导
            if not showRaccoon then return end
            

            -- enable highlight
            local vs = Director:sharedDirector():getVisibleSize()
            local vo = Director:sharedDirector():getVisibleOrigin()
            local node = CommonSkeletonAnimation:createTutorialMoveIn()
            node:setScaleX(-1)
            local scene = Director:sharedDirector():getRunningScene()
            if not scene then return end
            local panelPosition = self:getParent():convertToWorldSpace(self.sprite:getPosition())
            -- local nodePos = ccp(panelPosition.x + 100, panelPosition.y)
            node:setAnchorPoint(ccp(0, 1))
            local nodePos = ccp(150, panelPosition.y)
            node:setPosition(nodePos)
            scene:addChild(node)
            node:setAnimationScale(0.3)
            local builder = InterfaceBuilder:create("flash/scenes/homeScene/homeScene.json")
            local tip = GameGuideUI:panelMini('venom.too.little.tips')
            -- tip:getChildByName('txt'):setString(Localization:getInstance():getText('venom.too.little.tips'))
            -- tip:getChildByName('bg'):setScaleX(-1)
            -- tip:getChildByName('bg'):setAnchorPoint(ccp(1, 1))
            local posTip = ccp(vo.x + vs.width / 2 - tip:getGroupBounds().size.width / 2, nodePos.y - 120)
            local tipStartPos = ccp(-500, nodePos.y - 120)
            tip:setPosition(tipStartPos)
            tip:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.3), CCEaseExponentialOut:create(CCMoveTo:create(0.3, posTip))))
            scene:addChild(tip)
            local function remove()
                if node and node.refCocosObj then node:runAction(
                        CCSequence:createWithTwoActions(
                            CCDelayTime:create(0.5),
                            CCCallFunc:create(
                                function () 
                                    if node and node.refCocosObj then 
                                        node:removeFromParentAndCleanup(true) 
                                    end 
                                end)
                        )
                    )  
                end
                if tip and tip.refCocosObj then 
                    tip:runAction(CCSequence:createWithTwoActions(
                        CCEaseExponentialIn:create(CCMoveTo:create(0.3, tipStartPos)),
                        CCCallFunc:create(
                            function () 
                                if tip and tip.refCocosObj then 
                                    tip:removeFromParentAndCleanup(true) 
                                end
                            end))
                    )  
                end
            end
            setTimeOut(remove, 5)
        end
    end
end

function LevelTargetItem:forceStopAnimation()
    if self.animNode and not self.animNode.isDisposed then
        self.animNode:removeFromParentAndCleanup(true)
        self.animNode = nil
    end
end