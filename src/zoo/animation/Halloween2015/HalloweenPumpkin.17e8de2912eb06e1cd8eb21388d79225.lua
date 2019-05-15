HalloweenPumpkin = class(LayerColor)

function HalloweenPumpkin:ctor()
	self.castAnimationShow = false
end

function HalloweenPumpkin:init()
	LayerColor.initLayer(self)	
	local builder = InterfaceBuilder:createWithContentsOfFile("ui/HalloweenPumpkin.json")
	local ui = builder:buildGroup("HalloweenPumpkin")
	self.ui = ui

	local spriteRect = self.ui:getGroupBounds()
	self.uiSize = {width = spriteRect.size.width, height = spriteRect.size.height}
	self:changeWidthAndHeight(self.uiSize.width, self.uiSize.height)
	self:setAnchorPoint(ccp(0.5, 0.15))
	self:addChild(self.ui)
	self.ui:setPosition(ccp(0, self.uiSize.height))
	self:setOpacity(0)

	--百分比数字
	self.h_percent_label = self.ui:getChildByName("h_percent_label")
	self.h_percent_label:setString("0%")
	--闪烁的星星
	self.h_star_group = self.ui:getChildByName("h_star_group")

	for i=1,3 do
		local star = self.h_star_group:getChildByName("star"..i)
		star:setOpacity(0)
		local originScale = star:getScaleX()
		star:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
		local seqArr = CCArray:create()
		local spwanArr1 = CCArray:create()
		local spwanArr2 = CCArray:create()
		spwanArr1:addObject(CCFadeTo:create(1, 255))
		spwanArr1:addObject(CCScaleTo:create(1, originScale))
		spwanArr2:addObject(CCFadeTo:create(1, 100))
		spwanArr2:addObject(CCScaleTo:create(1, originScale/2))
		seqArr:addObject(CCSpawn:create(spwanArr1))
		seqArr:addObject(CCSpawn:create(spwanArr2))
		star:runAction(CCRepeatForever:create(CCSequence:create(seqArr)))
	end

	--背景上的蓝光和黄光
	self.h_blue_light = self.ui:getChildByName("h_blue_light")
	self.h_yellow_light = self.ui:getChildByName("h_yellow_light")
	self.h_yellow_light:setVisible(false)
	self.h_yellow_light:setOpacity(100)

	--中间流动的水相关
	self.h_middle_water = self.ui:getChildByName("h_middle_water")
	local bubble = Sprite:createWithSpriteFrameName("boss_pumpkin_bubble_0000.png")
	local bubble_frames = SpriteUtil:buildFrames("boss_pumpkin_bubble_%04d.png", 0, 30)
	local bubble_animate = SpriteUtil:buildAnimate(bubble_frames, 1/24)
	bubble:play(bubble_animate, 0, 0, nil, false)
	bubble:setPosition(ccp(45, 40))
	self.h_middle_water:addChild(bubble)

	self.pumpkin_mask_1 = Sprite:createWithSpriteFrameName("boss_pumpkin_mask_1.png")
	self.pumpkin_mask_1:setAnchorPoint(ccp(0, 1))
	self.pumpkin_mask_2 = Sprite:createWithSpriteFrameName("boss_pumpkin_mask_2.png")
	self.pumpkin_mask_2:setAnchorPoint(ccp(0, 1))

	local parent = self.h_middle_water:getParent()
	local childIndex = parent:getChildIndex(self.h_middle_water)
	local pos = self.h_middle_water:getPosition()
	local posX = pos.x
	local posY = pos.y
	local contentSize = self.h_middle_water:getContentSize()
	self.maxPercentHeight = contentSize.height

	self.h_middle_water:removeFromParentAndCleanup(false)
	local clipingnode_1 = ClippingNode.new(CCClippingNode:create(self.pumpkin_mask_1.refCocosObj))
    clipingnode_1:setAlphaThreshold(0.1)
    clipingnode_1:addChild(self.h_middle_water)
    self.h_middle_water:setPosition(ccp(0, 0))
    self.clipingnode_stencil_1 = clipingnode_1:getStencil()
    self.clipingnode_stencil_1:setPosition(ccp(0, -self.maxPercentHeight))

    local clipingnode_2 = ClippingNode.new(CCClippingNode:create(self.pumpkin_mask_2.refCocosObj))
	clipingnode_2:setAlphaThreshold(0.1)
    clipingnode_2:addChild(clipingnode_1)
    clipingnode_1:setPosition(ccp(0, 0))
    local wave = Sprite:createWithSpriteFrameName("boss_pumpkin_water_0000.png")
	local wave_frames = SpriteUtil:buildFrames("boss_pumpkin_water_%04d.png", 0, 25)
	local wave_animate = SpriteUtil:buildAnimate(wave_frames, 1/24)
	wave:play(wave_animate, 0, 0, nil, false)
	local waveContainer = CocosObject:create()
	waveContainer:setAnchorPoint(ccp(0.5, 0.5))
	waveContainer:addChild(wave)
	clipingnode_2:addChild(waveContainer)
	self.waveContainer = waveContainer
	self.waveContainer_posX = wave:getContentSize().width/2
	self.waveContainer:setPosition(ccp(self.waveContainer_posX, -self.maxPercentHeight))
	self.waveContainer:setRotation(-1)
	
    parent:addChildAt(clipingnode_2, childIndex)
    clipingnode_2:setPosition(ccp(posX, posY))

    self.ui:setVisible(false)

    -- -----test------
    -- self:setTouchEnabled(true, 0, true)
    -- self:addEventListener(DisplayEvents.kTouchTap,function ()
	   -- 	local pumpkinExplode = PumpkinExplode:create(targetItemCount, itemEndPos, propCount, propEndPos)
	   --  pumpkinExplode:show(onFlyAnimFinish)
    -- end)
end

function HalloweenPumpkin:playComout(endCallback)
	local comout_sprite = Sprite:createWithSpriteFrameName("boss_pumpkin_comout_0000.png")
	local comout_frames = SpriteUtil:buildFrames("boss_pumpkin_comout_%04d.png", 0, 15)
	local comout_animate = SpriteUtil:buildAnimate(comout_frames, 1/24)
	local context = self
	comout_sprite:play(comout_animate, 0, 1, function ()
		if context.isDisposed then return end
		context.ui:setVisible(true)
		local pumpkinCenterWorldPos = self:convertToWorldSpace(ccp(self.uiSize.width / 2, self.uiSize.height - 105))
		HalloweenAnimation:getInstance():setPumpkinCenterWorldPos(pumpkinCenterWorldPos)
		if endCallback then 
			endCallback()
		end
	end, true)
	self:addChild(comout_sprite)
	comout_sprite:setPosition(ccp(self.uiSize.width / 2 + 0.5, self.uiSize.height - 23.5))
end

function HalloweenPumpkin:setPercent(percent, noAnim)
	if percent > 1 then percent = 1 end
	local realPercent = percent
	local defautPercent = 0.2
	if realPercent > defautPercent then
		defautPercent = realPercent
	end
	local height = self.maxPercentHeight * defautPercent
	local endPosY = -self.maxPercentHeight + height
	self.clipingnode_stencil_1:stopAllActions()

	-- if noAnim then 
	-- 	self.clipingnode_stencil_1:setPosition(ccp(0, endPosY))
	-- 	self.waveContainer:setPosition(ccp(self.waveContainer_posX, endPosY))
	-- else
        self.clipingnode_stencil_1:runAction(CCMoveTo:create(0.5, ccp(0, endPosY)))
        self.waveContainer:stopAllActions()
        self.waveContainer:runAction(CCMoveTo:create(0.5, ccp(self.waveContainer_posX, endPosY)))
	-- end

	local show_num = math.ceil(percent*100)
	self.h_percent_label:setString(show_num .. "%")
end

function HalloweenPumpkin:playReadyToCast(endCallback)
	if self.castAnimationShow then
		if endCallback then 
			endCallback()
		end 
		return 
	end
	self.castAnimationShow = true

	self:stopAllActions()
	self.h_yellow_light:stopAllActions()

	self.h_yellow_light:setVisible(true)
	self.h_blue_light:setVisible(false)

	local seqArr = CCArray:create()
	local spwanArr1 = CCArray:create()
	local spwanArr2 = CCArray:create()
	spwanArr1:addObject(CCMoveBy:create(0.5, ccp(0, 5)))
	spwanArr1:addObject(CCScaleTo:create(0.5, 1, 1.03))
	spwanArr2:addObject(CCEaseSineIn:create(CCMoveBy:create(0.3, ccp(0, -5))))
	spwanArr2:addObject(CCScaleTo:create(0.5, 1.05, 0.97))
	seqArr:addObject(CCSpawn:create(spwanArr1))
	seqArr:addObject(CCSpawn:create(spwanArr2))
	self:runAction(CCRepeatForever:create(CCSequence:create(seqArr)))

	local seqArr2 = CCArray:create()
	seqArr2:addObject(CCFadeTo:create(0.5, 255))
	seqArr2:addObject(CCFadeTo:create(0.5, 100))
	self.h_yellow_light:runAction(CCRepeatForever:create(CCSequence:create(seqArr2)))
	if endCallback then 
		endCallback()
	end
end

function HalloweenPumpkin:stopReadyToCast()
	self.castAnimationShow = false

	self:stopAllActions()
	self.h_yellow_light:stopAllActions()

	self.h_yellow_light:setVisible(false)
	self.h_blue_light:setVisible(true)
	self.h_yellow_light:setOpacity(100)

	self:setScaleX(1)
	self:setScaleY(1)

	self:setPosition(ccp(self.originPosX, self.originPosY))
end

function HalloweenPumpkin:showYellowLight()
	if self.castAnimationShow then return end

	self.h_yellow_light:stopAllActions()

	self.h_yellow_light:setVisible(true)
	self.h_blue_light:setVisible(false)

	local seqArr2 = CCArray:create()
	seqArr2:addObject(CCFadeTo:create(0.3, 255))
	seqArr2:addObject(CCFadeTo:create(0.3, 100))
	seqArr2:addObject(CCCallFunc:create(function ()
		self.h_yellow_light:setOpacity(100)
 		self.h_yellow_light:setVisible(false)
		self.h_blue_light:setVisible(true)
 	end))
	self.h_yellow_light:runAction(CCRepeatForever:create(CCSequence:create(seqArr2)))
end

function HalloweenPumpkin:adjustPostion(posX)
	self.originPosX = posX - self.uiSize.width/2
	self.originPosY = -40
	self:setPosition(ccp(self.originPosX, self.originPosY))
end

function HalloweenPumpkin:create()
	local pumpkinBoss = HalloweenPumpkin.new()
	pumpkinBoss:init()
	return pumpkinBoss
end