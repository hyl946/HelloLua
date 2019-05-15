require "zoo.gamePlay.levelTarget.LevelTargetAnimationBase"

LevelTargetAnimationOrder = class(LevelTargetAnimationBase)

function LevelTargetAnimationOrder:create(topX, yDelta, noBatch)
	-- body
	local ret = LevelTargetAnimationOrder.new()
	ret:buildLevelTargets(topX, yDelta, noBatch)
	ret:buildLevelPanel()
	return ret
end

function LevelTargetAnimationOrder:getIconFullName( itemType, id )
	--[[
	if _G.IS_PLAY_YUANXIAO2017_LEVEL then
		-- 元宵节活动 银币显示成灯笼
		if itemType == "order4" and id == 2 then
			id = tostring(id) .."_yuanxiao_icon"
		end
	end]]

	local fullname = "target."..itemType
	fullname = fullname.."_"..id
	return fullname
end

function LevelTargetAnimationOrder:getIconFrameName(itemType, id, fname)

	local fullname = ""
	if fname then
		fullname = fname
	else
		fullname = self:getIconFullName(itemType, id)
	end
	local resname = nil
	if _G.IS_PLAY_YUANXIAO2017_LEVEL and fullname == "target.order4_2_yuanxiao_icon" then
		resname = fullname.."0000"
	else
		resname = fullname.." instance 10000"
	end
	return resname
end

function LevelTargetAnimationOrder:createIcon( itemType, id, width, height , fname)
	-- body
	local resname = self:getIconFrameName(itemType, id, fname)

	local layer = Sprite:createEmpty()
	layer:setCascadeOpacityEnabled(true)

	local sprite = Sprite:createWithSpriteFrameName(resname)
	local spriteSize = sprite:getContentSize()
	local scaleFactor = 0.5
	sprite.name = "content"
	sprite:setCascadeOpacityEnabled(true)
	sprite:setScale(scaleFactor)
	sprite:setAnchorPoint(ccp(0,0))
	layer.name = "icon"
	layer:addChild(sprite)
	layer:setContentSize(CCSizeMake(spriteSize.width*scaleFactor, spriteSize.height*scaleFactor))

	layer.clone = function( self, copyParentAndPos )
		local old = self:getChildByName("content")
		local cloned = old:clone(false)
		local result = Sprite:createEmpty()
		local size = self:getContentSize()
		result.name = "icon"
		result:setCascadeOpacityEnabled(true)
		
		cloned.name = "content"
		cloned:setCascadeOpacityEnabled(true)
		cloned:setScale(0.5)
		cloned:setAnchorPoint(ccp(0,0))
		result:addChild(cloned)
		result:setContentSize(CCSizeMake(size.width, size.height))
		if copyParentAndPos then
			local position = self:getPosition()
			local parent = self:getParent()
			if parent then
				local grandParent = parent:getParent()
				if grandParent then 
					local position_parent = parent:getPosition()
					result:setPosition(ccp(position.x + position_parent.x, position.y + position_parent.y))
					grandParent:addChild(result)
				end
			end
		end
		return result
	end
	return layer
end

function LevelTargetAnimationOrder:setTargetNumber( itemType, itemId, itemNum, animate, globalPosition, rotation, percent )
	for i=1,self.numberOfTargets do
		local item = self["c"..i]
		if item and item.itemId == itemId and item.itemType == itemType then
			item:setTargetNumber(itemId, itemNum, animate, globalPosition, rotation, percent)
		end

		--TODO 四周年
		if item and item.itemType == 'order6' and (itemId == 5 or itemId == 6 or itemId == 7 or itemId == 8 or itemId == 9 ) then
			item:setTargetNumber(itemId, itemNum, animate, globalPosition, rotation, percent)
		end
	end
end

function LevelTargetAnimationOrder:revertTargetNumber( itemType, itemId, itemNum )
	-- body
	for i=1,self.numberOfTargets do
		local item = self["c"..i]
		if item and item.itemId == itemId and item.itemType == itemType then
			item:revertTargetNumber(itemId, itemNum)
		end

		--TODO 四周年
		if item and item.itemType == 'order6' and (item.itemId == 5 or item.itemId == 6 or itemId == 7 or itemId == 8 or itemId == 9) then
			item:revertTargetNumber(4, itemNum, animate, globalPosition, rotation, percent)
		end
	end
end

function LevelTargetAnimationOrder:createTargets( from, to )
	-- body
	for i=from,to do
		self["c"..i] = self:buildTargetItem("c"..i, i)
	end
end

function LevelTargetAnimationOrder:initGameModeTargets( ... )
	-- body
	self:createTargets(1,4)
	self:updateTargets() 
end

function LevelTargetAnimationOrder:setNumberOfTargets( v, animationCallbackFunc, flyFinishedCallback , noAnimation)
	-- body
	if self.isInitialized then return end
	self.isInitialized = true

	v = v or 1
	if v < 1 then v = 1 end
	if v > 4 then v = 4 end

	self.numberOfTargets = v
	local delayBeforeTime = 0.5
	local delayTime = 1.6

	self:initGameModeTargets()

	local panel = self.panel
	local winSize = CCDirector:sharedDirector():getVisibleSize()
  	local panelSize = panel:getContentSize()
  	local x = (winSize.width - panelSize.width)/2
  	local y = (winSize.height+panelSize.height)/2
  	panel:setPosition(ccp(x, y + 180))
  	panel:fadeIn(delayBeforeTime)

  	--fadein target
	for i=1,self.numberOfTargets do
		local iconSrc = self["tile"..i].icon
		if iconSrc then 
			iconSrc:setOpacity(0)
			iconSrc:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delayBeforeTime), CCFadeIn:create(0.5)))
		end
	end
  	
  	local function onDelayFinished()
  		self.layer:rma()
		self.layer:setTouchEnabled(false)
  		self:flyTarget(animationCallbackFunc, flyFinishedCallback  , noAnimation)
  	end 
  	
  	local sequence = CCArray:create()
  	sequence:addObject(CCDelayTime:create(delayBeforeTime))
  	sequence:addObject(CCEaseQuarticBackOut:create(CCMoveTo:create(0.5, ccp(x, y)), 33, -106, 126, -67, 15))
  	sequence:addObject(CCDelayTime:create(delayTime))
  	sequence:addObject(CCCallFunc:create(onDelayFinished))

	panel:stopAllActions()
	panel:runAction(CCSequence:create(sequence))

	local function onTouchLayer( evt )		
		panel:stopAllActions()

		self.layer:rma()
		self.layer:setTouchEnabled(false)
		self:flyTarget(animationCallbackFunc, flyFinishedCallback , noAnimation)
	end

	self.layer:ad(DisplayEvents.kTouchTap, onTouchLayer)
	self.layer:setTouchEnabled(true, -10000, true)

	if noAnimation then
		onTouchLayer()
	end
end

function LevelTargetAnimationOrder:flyTarget( animationCallbackFunc, flyFinishedCallback , noAnimation)
	if self.isTargetFly then return end
	self.isTargetFly = true
	local panel = self.panel
	local function onAnimationFinished()
		self:dropLeaf()
  		if animationCallbackFunc ~= nil then animationCallbackFunc() end
  		self.panel:removeFromParentAndCleanup(true)
  	end

	local sequence = CCArray:create()
	sequence:addObject(CCDelayTime:create(0.4))
	sequence:addObject(CCCallFunc:create(onAnimationFinished))
	panel:stopAllActions()
	panel:fadeOut()
	panel:runAction(CCSequence:create(sequence))
	for i=1,self.numberOfTargets do
		local iconSrc = self["tile"..i].icon
		local iconDst = self["c"..i].icon
		if iconSrc and iconDst then
			self:flyCollectTarget(iconSrc, iconDst, i , noAnimation)
		end
	end

	if noAnimation then
		panel:stopAllActions()
		onAnimationFinished()
	end
end

function LevelTargetAnimationOrder:shake( ... )
	-- body
	for i=1,self.numberOfTargets do
  		self["c"..i]:shake()
  	end
end

function LevelTargetAnimationOrder:updateTargets( ... )
	-- body
	local v = self.numberOfTargets
	for i=1,4 do 
		if i <= v then 
			self["c"..i]:setVisible(true)
			self["tile"..i]:setVisible(true) 
		else 
			self["c"..i]:setVisible(false) 
			self["tile"..i]:setVisible(false)
			self["c"..i]:rma() 
		end
		self["c"..i]:reset()
	end
	self.time:setVisible(false)
	self.time:rma()
	self.timeBg:setVisible(false)
	self.time_label:setVisible(false)

	local targetSize = self.levelTarget:getContentSize()
	local itemSize = self.c1:getContentSize()
	local itemPosition = self.c1:getPosition()

	-- local tileContentSize = self.panelContent
	local tileSize = self.tile1:getContentSize()
	local tilePosition = self.tile1:getPosition()
	
	local gap, totalWidth = 10, itemSize.width
	local tileGap, tileTotalWidth = 2, tileSize.width

	if v == 4 then gap, tileGap = 10, 2
	elseif v == 3 then gap, tileGap = 20, 12
	elseif v == 2 then gap, tileGap = 30, 30 end

	totalWidth = gap * (v - 1) + itemSize.width * v
	tileTotalWidth = tileGap * (v - 1) + tileSize.width * v

	local offsetX = (targetSize.width - totalWidth) / 2
	local tileBounds = self.panel:getChildByName("content"):boundingBox()
	local tileOffsetX = tileBounds:getMidX() - tileTotalWidth/2

	for i=1,v do
		local itemX = (itemSize.width + gap) * (i - 1) + itemSize.width/2
		local item = self["c"..i]
		local targetContent = nil
		local targetID, targetNum, targetType

		if self.targets then targetContent = self.targets[i] end
		if targetContent then targetID, targetNum, targetType = targetContent.id, targetContent.num, targetContent.type end
		local icon = self:createIcon(targetType, targetID, item.iconSize.width, item.iconSize.height)
		item.itemId = targetID
		item.itemNum = targetNum
		item.itemType = targetType
		item:setContentIcon(icon, targetNum)
		item:setPosition(ccp(offsetX + itemX, itemPosition.y))

		local maunalAdjustPosX = -16

		local tileX = (tileSize.width + tileGap) * (i - 1) 
		local tile = self["tile"..i]
		local tileIcon = self:createIcon(targetType, targetID, item.iconSize.width, item.iconSize.height)
		tileIcon:setScale(1.6)
		tile:setContentIcon(tileIcon)
		tile:setPosition(ccp(tileOffsetX + tileX + maunalAdjustPosX, tilePosition.y))

		local tileArray = CCArray:create()
		tileArray:addObject(CCDelayTime:create(1.3 + i * 0.3))
		tileArray:addObject(CCScaleTo:create(0.3, 2.2))
		tileArray:addObject(CCScaleTo:create(0.3, 1.5))
		tileIcon:runAction(CCSequence:create(tileArray))
	end

	-- local array = CCArray:create()
	-- array:addObject(CCDelayTime:create(1.9))
	-- array:addObject(CCEaseElasticOut:create(CCScaleTo:create(1, 1.4)))
	local itemType = self:getTargetTypeByTargets()
	self.tip_label:setString(Localization:getInstance():getText(kLevelTargetTypeTexts[itemType]))
	-- self.tip_label:setScale(1)
	-- self.tip_label:stopAllActions()
	-- self.tip_label:runAction(CCSequence:create(array))

	local tipSize = self.tip_label:getContentSize()
	local tipPos = self.tip_label:getPosition()
	self.tip_label:setPosition(ccp(tipPos.x + tipSize.width/2, tipPos.y - tipSize.height/2))
end

function LevelTargetAnimationOrder:getTargetTypeBySelectItem( selectedItem )
	-- body
	return kLevelTargetType.order1
end

function LevelTargetAnimationOrder:getTargetTypeByTargets( ... )
	-- body
	if self.targets then
		local selectedItem = self.targets[1]
		if selectedItem then
			if selectedItem.type == kLevelTargetType.order2 or selectedItem.type == kLevelTargetType.order3 or selectedItem.type == kLevelTargetType.order5 then
				for k, v in ipairs(self.targets) do
					if v.type ~= selectedItem.type then return kLevelTargetType.order1 end
				end
			end
			return self:getTargetTypeBySelectItem(selectedItem)
		end
	end
	return nil
end

function LevelTargetAnimationOrder:getLevelTileByIndex( index )
	-- body
	return self["c"..index]
end

function LevelTargetAnimationOrder:forceStopAnimation()
    for i = 1, self.numberOfTargets do
        local item = self['c'..i]
        if item then
            item:forceStopAnimation()
        end
    end
end
