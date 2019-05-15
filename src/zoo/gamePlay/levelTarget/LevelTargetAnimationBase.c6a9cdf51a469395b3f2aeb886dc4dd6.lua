LevelTargetAnimationBase = class()
function LevelTargetAnimationBase:ctor( ... )
	-- body
	local origin = Director:sharedDirector():getVisibleOrigin()
	local layer = Layer:create()
  	layer.name = "level target"
  	layer:setPosition(ccp(origin.x, origin.y))
  	self.layer = layer
end

function LevelTargetAnimationBase:dispose( ... )
	-- body
	for i=1,4 do
		self["c"..i]:rma()
	end
	self.time:rma()
end

function LevelTargetAnimationBase:create(topX, yDelta, noBatch)
	-- body
	local ret = LevelTargetAnimationBase.new()
	ret:buildLevelTargets(topX, yDelta, noBatch)
	ret:buildLevelPanel()
	return ret
end

function LevelTargetAnimationBase:createIcon( itemType, id, width, height )
	-- body
end

function LevelTargetAnimationBase:setTargets( targets, animationCallbackFunc, flyFinishedCallback  , noAnimation)
	-- body
	self.targets = targets
	self:setNumberOfTargets(#targets, animationCallbackFunc, flyFinishedCallback , noAnimation)
	StageInfoLocalLogic:initTargets(UserManager.getInstance().uid, targets)
end

function LevelTargetAnimationBase:getNumberOfTargets( ... )
	-- body
	return #self.targets
end

function LevelTargetAnimationBase:getLevelTileByIndex( index )
	-- body
end

function LevelTargetAnimationBase:getTargetTypeByIndex( index )
	if self.targets then
		local selectedItem = self.targets[index]
		if selectedItem then return selectedItem.type end
	end
	return nil
end

function LevelTargetAnimationBase:getTargetTypeByTargets( ... )
	-- body
end

function LevelTargetAnimationBase:setTargetNumber( itemType, itemId, itemNum, animate, globalPosition, rotation, percent )
	-- body
end

function LevelTargetAnimationBase:revertTargetNumber( itemType, itemId, itemNum )
	-- body
end

function LevelTargetAnimationBase:setPosX( posX, ... )
	-- body
	assert(type(posX))
	assert(#{...} == 0)
	local scale = self.levelTarget:getScale()
	local offsetX = 0 
	if scale ~= 1 then offsetX = 20 end
	self.levelTarget:setPositionX(posX + offsetX)
	self.attachSprite:setPositionX(posX + offsetX)
	self.bgSprite:setPositionX(posX + offsetX)
end

function LevelTargetAnimationBase:getTopContentSize( ... )
	-- body
	return self.levelTarget:getContentSize()
end

function LevelTargetAnimationBase:onTouchBegin( evt )
	-- body
	local pos = evt.globalPosition
	-- if _G.isLocalDevelopMode then printx(0, "touchBegin", pos.x, pos.y) end
	if self.touchList then 
		for k, v in pairs(self.touchList) do
			local hit = v:hitTestPoint(pos, true)
			if hit then
				v.isTouched = true
				v:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchBegin, v, pos))
			else
				v.isTouched = false
			end 
		end
	end
end

function LevelTargetAnimationBase:setTargetScale(scale)
	if self.levelTarget then 
		self.levelTarget:setScale(scale)
	end
	if self.attachSprite then 
		self.attachSprite:setScale(scale)
	end
	if self.bgSprite then 
		self.bgSprite:setScale(scale)
	end
end

function LevelTargetAnimationBase:getTargetScale()
	local scale
	if self.levelTarget then 
		scale = self.levelTarget:getScale()
	end
	return scale or 1
end

function LevelTargetAnimationBase:buildLevelTargets(x, yDelta, noBatch)
	local deltaY = yDelta or 0
	-- body
	local vSize = CCDirector:sharedDirector():getVisibleSize()
	self.levelSkinConfig = GamePlaySceneSkinManager:getConfig(GamePlaySceneSkinManager:getCurrLevelType())

  	local levelTarget
  	if noBatch then 
  		levelTarget = ResourceManager:sharedInstance():buildGroup(self.levelSkinConfig.levelTargets)
  	else
  		levelTarget = ResourceManager:sharedInstance():buildBatchGroup("batch", self.levelSkinConfig.levelTargets)
  	end

  	local attachSprite = Layer:create()--Sprite:createEmpty()
  	local bgSprite = Layer:create()

  	local kPropListScaleFactor = 0.93
    -- 为了在不同的分辨率下定位都一致，在此不再做两种scale了
  	-- if __isWildScreen then  kPropListScaleFactor = 0.93 end
  	levelTarget:setScale(kPropListScaleFactor)
  	attachSprite:setScale(kPropListScaleFactor)
  	bgSprite:setScale(kPropListScaleFactor)



  	local targetSize = levelTarget:getGroupBounds().size
  	levelTarget:setContentSize(CCSizeMake(targetSize.width, targetSize.height))
  	attachSprite:setContentSize(CCSizeMake(targetSize.width, targetSize.height))
  	bgSprite:setContentSize(CCSizeMake(targetSize.width, targetSize.height))

  	levelTarget:setPosition(ccp(x, vSize.height - deltaY))
  	attachSprite:setPosition(ccp(x, vSize.height - deltaY))
  	bgSprite:setPosition(ccp(x, vSize.height - deltaY))
  	
  	-- attachSprite:setAnchorPoint(ccp(0,0))
  	-- bgSprite:setAnchorPoint(ccp(0,0))

  	self.layer:addChild(bgSprite)
  	self.layer:addChild(levelTarget)
  	self.layer:addChild(attachSprite)

  	-- self.layer:setContentSize(CCSizeMake(vSize.width, vSize.height))
  	local function onTouch( evt )
  		-- body
  		self:onTouchBegin(evt)
  	end
  	self.touchList = {}
  	attachSprite:setTouchEnabled(true)
  	attachSprite:addEventListener(DisplayEvents.kTouchBegin, onTouch)

  	self.levelTarget = levelTarget
  	self.attachSprite = attachSprite
  	self.bgSprite = bgSprite
  	
  	local c1 = self.levelTarget:getChildByName("c1")
  	local content = c1:getChildByName("content")

  	self.time = self:buildTimeTargetItem()

  	self.flyOffsetY = content:getContentSize().height + c1:getContentSize().height + 7
  	self.flyOffsetX = content:getContentSize().width + c1:getContentSize().width/2

  	local leaf1 = levelTarget:getChildByName("leaf1")
  	local leaf1Pos = leaf1:getPosition()
  	local leaf2 = levelTarget:getChildByName("leaf2")
  	local leaf2Pos = leaf2:getPosition()

  	self.leftLeafPosition = {x=leaf1Pos.x, y=leaf1Pos.y+_G.__EDGE_INSETS.top}
  	self.rightLeafPosition = {x=leaf2Pos.x, y=leaf2Pos.y+_G.__EDGE_INSETS.top}
  	leaf1:removeFromParentAndCleanup(true)
  	leaf2:removeFromParentAndCleanup(true)

  	self.numberOfTargets = 4
  	self.targets = nil
end

function LevelTargetAnimationBase:getTargetCellSize( ... )
	-- body
	assert(#{...} == 0)
	assert(self.c1)
	local size = self.c1:getGroupBounds().size
	return size
end

function LevelTargetAnimationBase:buildLevelPanel( ... )
	-- body
	local winSize = CCDirector:sharedDirector():getVisibleSize()
  	local panel = ResourceManager:sharedInstance():buildGroup("level_target_panel")
  	local panelSize = panel:getGroupBounds().size
  	panel:setContentSize(CCSizeMake(panelSize.width, panelSize.height))
  	panel:setPosition(ccp((winSize.width - panelSize.width)/2, (winSize.height+panelSize.height)/2))
  	self.layer:addChild(panel)
  	self.panel = panel

  	panel.fadeIn = function ( self, delayBeforeTime )
  		delayBeforeTime = delayBeforeTime or 0
  		local panelChildren = {}
  		self:getVisibleChildrenList(panelChildren, {"icon"})
  		for i,child in ipairs(panelChildren) do
	  		child:setOpacity(0)
	  		child:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delayBeforeTime), CCFadeIn:create(0.5)))
	  	end
  	end
  	panel.fadeOut = function ( self )
  		local panelChildren = {}
  		self:getVisibleChildrenList(panelChildren, {"icon"})
  		for i,child in ipairs(panelChildren) do
  			child:stopAllActions()
	  		child:runAction(CCFadeOut:create(0.2))
	  	end
  	end

  	local tip_label = panel:getChildByName("tip_label")
  	local time_label = panel:getChildByName("time_label")


  	--stringKey, {level_number = self.levelId}
  	local tipSize = tip_label:getContentSize()
  	tip_label:setString("")
  	tip_label:setAnchorPoint(ccp(0.5, 0.5))

  	time_label.offsetX = time_label:getPosition().x
	time_label:setAlignment(kCCTextAlignmentCenter)
	time_label:setAnchorPoint(ccp(0.5, 0.5))
  	time_label:setString("0")

  	self.time_label = time_label
  	self.tip_label = tip_label

  	local content = panel:getChildByName("content")
  	content:setVisible(false)
  	-- local contentPos = panel:getPosition()
  	-- local contentSize = panel:getContentSize()
  	-- self.panelContent = {x=contentPos.x, y=contentPos.y, width=contentSize.width,height=contentSize.height}
  	-- content:removeFromParentAndCleanup(true)

  	local timeBg = panel:getChildByName("time_bg")
  	self.timeBg = timeBg

  	for i=1,4 do
  		self["tile"..i] = self:buildPanelTileItem("tile"..i, i)
  	end
end

function LevelTargetAnimationBase:buildPanelTileItem( targetName, index )
	-- body
	local sprite = self.panel:getChildByName(targetName)
	local spriteSize = sprite:getGroupBounds().size
	local content = sprite:getChildByName("content")
	local contentPos = content:getPosition()
	local contentSize = content:getContentSize()
	sprite:setContentSize(CCSizeMake(spriteSize.width, spriteSize.height))
	sprite.iconSize = {x = contentPos.x, y = contentPos.y, width=contentSize.width, height=contentSize.height}
	content:removeFromParentAndCleanup(true)

	local context = self
	sprite.setContentIcon = function( self, icon )
		if self.icon then
			self.icon:removeFromParentAndCleanup(true)
		end
		self.icon = icon		
		if self.icon and self.iconSize then
			local iconContentSize = self.iconSize
			local iconScale = self.icon:getScale()
			local iconSize = self.icon:getContentSize()
			local iconWidth = iconSize.width * iconScale
			local iconHeight = iconSize.height * iconScale
			local y = iconContentSize.y  - 42
			local x = iconContentSize.x + 42
			local offsetX, offsetY = 10, -4
			self.icon:setPosition(ccp(x + offsetX, y + offsetY))
			self:addChildAt(icon, 1)
		end
	end
	return sprite
end

function LevelTargetAnimationBase:buildTimeTargetItem( ... )
	-- body
	local sprite = self.levelTarget:getChildByName("time")
	return TargetItemFactory.create(TimeTargetItem, sprite, 0, self)
end

function LevelTargetAnimationBase:buildTargetItem( targetName, index )
	-- body
	local sprite = self.levelTarget:getChildByName(targetName)
	return TargetItemFactory.create(LevelTargetItem, sprite, index, self)
end

function LevelTargetAnimationBase:addTouchList( item )
	-- body
	if not self.touchList then self.touchList = {} end
	table.insertIfNotExist(self.touchList, item)
end

function LevelTargetAnimationBase:setNumberOfTargets( v, animationCallbackFunc, flyFinishedCallback , noAnimation)
	-- body
end

function LevelTargetAnimationBase:flyTarget( animationCallbackFunc, flyFinishedCallback , noAnimation)
	-- body
end

function LevelTargetAnimationBase:flyCollectTarget( iconSrc, iconDst, index , noAnimation)
	if noAnimation then return end
	-- body
	local position = iconDst:getPosition()
	position = iconDst:getParent():convertToWorldSpace(ccp(position.x, position.y))
	position = iconSrc:getParent():convertToNodeSpace(position)

	local animationTime = 0.5
	local spawn = CCArray:create()
	spawn:addObject(CCEaseSineInOut:create(CCMoveTo:create(animationTime, position)))
	spawn:addObject(CCScaleTo:create(animationTime, 1))

	local sequence = CCArray:create()
	sequence:addObject(CCDelayTime:create(index * 0.1))
	sequence:addObject(CCSpawn:create(spawn))
	sequence:addObject(CCFadeOut:create(0.15))
	iconSrc:runAction(CCSequence:create(sequence))
end

function LevelTargetAnimationBase:updateTargets( ... )
	-- body
end

function LevelTargetAnimationBase:shake( ... )
	-- body
end

function LevelTargetAnimationBase:dropLeaf( ... )
	-- body
	self:playLeafAnimation(true)
  	self:playLeafAnimation(false)
  	self:shake()
end

function LevelTargetAnimationBase:playLeafAnimation( isLeft )

    --关闭目标掉叶子
    if true then return false end

	-- body
	local position
	local offsetX, offsetY = 0, -200
	if isLeft then
		position = self.leftLeafPosition
		offsetX = -90
	else
		position = self.rightLeafPosition
		offsetX = 90
	end
	local maxLeaf = 1 + math.floor(math.random()*2)
	for i = 1, 3 do
		local leaf = Sprite:createWithSpriteFrameName("ingame_level_leaf0000")
		leaf:setPosition(ccp(position.x, position.y+20))
		leaf:setScale(0.5+math.random()*0.5)
		leaf:setRotation(math.random()*360)
		local function onLeafFinished( )
			leaf:removeFromParentAndCleanup(true)
		end 
		local fadeOutTime = math.random()*0.8 + 0.7
		local x = offsetX*0.3 + math.random()*offsetX*0.7
		local y = offsetY*0.5 + math.random()*offsetY*0.5
		local moveOut = CCMoveBy:create(fadeOutTime, ccp(x, y))

		local outArray = CCArray:create()
		outArray:addObject(CCFadeOut:create(fadeOutTime))
		outArray:addObject(CCEaseSineOut:create(moveOut))
		outArray:addObject(CCScaleTo:create(fadeOutTime, 0.5))

		local array = CCArray:create()
		array:addObject(CCDelayTime:create(math.random()*0.6 + 0.2))
		array:addObject(CCSpawn:create(outArray))
		array:addObject(CCCallFunc:create(onLeafFinished))
		leaf:runAction(CCSequence:create(array))
		leaf:runAction(CCRepeatForever:create(CCRotateBy:create(0.3, 50)))
		self.levelTarget:addChild(leaf)
	end
end

function LevelTargetAnimationBase:highlightTarget( itemType, itemId, enable, showRaccoon )
	-- body
	 for i=1,self.numberOfTargets do
        local item = self["c"..i]
        if _G.isLocalDevelopMode then printx(0, "setTargetNumber", item.itemId, item.itemType) end
        if item and item.itemId == itemId and item.itemType == itemType then
            item:highlight(enable, showRaccoon)
            return item:getParent():convertToWorldSpace(item:getPosition())
        end
    end
    return nil
end

function LevelTargetAnimationBase:forceStopAnimation()
 
end

function LevelTargetAnimationBase:shakeForFuuu()
	for i=1,self.numberOfTargets do
		local item = self["c"..i]
		item:shake()
	end
end

function LevelTargetAnimationBase:getTargets()
	local items = {}
	for i=1,self.numberOfTargets do
		local item = self["c"..i]
		if item and item.itemType then
			items[#items + 1] = {
				type = item.itemType .. "_" .. item.itemId,
				num = item.itemNum,
				sum = self.targets[i].num,
			}
		end
	end
	return items
end