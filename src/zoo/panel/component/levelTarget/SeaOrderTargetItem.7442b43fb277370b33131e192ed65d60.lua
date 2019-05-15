SeaOrderTargetItem = class(LevelTargetItem)

function SeaOrderTargetItem:getAnimation(itemId, itemNum, globalPosition, rotation)
	local panel = self.sprite
	local context = self.context

	local scene = Director:sharedDirector():getRunningScene()
    if not scene then return end

	


    --根据关卡类型不同创建不用更多海洋生物
    local CurLevelType = 0
    local mainLogic = GameBoardLogic:getCurrentLogic()
    local SunmerFish3x3GetNum = 1
	if mainLogic then
        local levelID = mainLogic.level
        CurLevelType = LevelType:getLevelTypeByLevelId( levelID )
        SunmerFish3x3GetNum = mainLogic.SunmerFish3x3GetNum
    end

    if CurLevelType == GameLevelType.kSummerFish then
        FrameLoader:loadArmature('skeleton/summerSeaAnim')
    else
        FrameLoader:loadArmature('skeleton/sea_animal_animation')
    end

	local vo = Director:sharedDirector():getVisibleOrigin()
	local vs = Director:sharedDirector():getVisibleSize()
	local node = nil
	local anchorPoint = ccp(0, 0) 
	local scale = 1
	local nodeWidth = 0
	local offsetX = 0
	local duration = 0
	local aPartDelay = 2
    local FlyDelayTime = 0.5
    local nodePosOffset = ccp(0,0)

	if itemId == GameItemOrderType_SeaAnimal.kPenguin then
		node = ArmatureNode:create('penguin')
		if rotation == 0 then
			anchorPoint = ccp(0.5, 0.75)
		elseif rotation == 90 then
			anchorPoint = ccp(0.5, 0.75)
		end
		nodeWidth = 70 * 2
		offsetX = -100
		scale = 140 / node:getGroupBounds().size.height
		duration = 1.9 -- old : 2.7
		aPartDelay = 1.2
	elseif itemId == GameItemOrderType_SeaAnimal.kSeaBear then
		node = ArmatureNode:create('seabear')
		if rotation == 0 then
			anchorPoint = ccp(1/6, 5/6)
		end
		nodeWidth = 70 * 3
		offsetX = -80
		scale = 210 / node:getGroupBounds().size.height
		duration = 1.5 -- old : 2.1
		aPartDelay = 1
	elseif itemId == GameItemOrderType_SeaAnimal.kSeal then
		node = ArmatureNode:create('seadog')
		if rotation == 0 then
			anchorPoint = ccp(1/6, 3/4) 
		elseif rotation == -90 then
			anchorPoint = ccp(1/6, 1/4)
		end
		nodeWidth = 70 * 3
		offsetX = -200
		scale = 140 / node:getGroupBounds().size.height
		duration = 1.4 -- old : 2
		aPartDelay = 1.3
	--TODO 四周年
	elseif itemId == GameItemOrderType_SeaAnimal.kMistletoe then
        if CurLevelType == GameLevelType.kSummerFish then
            node = ArmatureNode:create('2018SunmerSea/sea11')
		    anchorPoint = ccp(1/2, 1/2)
		    nodeWidth = 70
		    offsetX = 0
		    scale = 1
            rotation = 0
            FlyDelayTime = 0.5
            aPartDelay = 0.5
        else
		    node = ArmatureNode:create('2016_ShengDan_Mistletoe/Mistletoe')
		    anchorPoint = ccp(1/2, 1/2)
		    nodeWidth = 70
		    offsetX = 0
		    scale = 1
        end
	elseif itemId == GameItemOrderType_SeaAnimal.kElk then

        if CurLevelType == GameLevelType.kSummerFish then
            node = ArmatureNode:create('2018SunmerSea/sea22')
		    anchorPoint = ccp(1/4, 3/4)
		    nodeWidth = 70 * 2
		    offsetX = -80
		    scale = 1
            rotation = 0
            FlyDelayTime = 0.5
            aPartDelay = 0.5
        else
		    node = ArmatureNode:create('2016_ShengDan_Mistletoe/elk_anim')
		    anchorPoint = ccp(1/4, 3/4)
		    nodeWidth = 70 * 2
		    offsetX = -130
		    scale = 1
        end
	elseif itemId == GameItemOrderType_SeaAnimal.kScaf_H then

        if CurLevelType == GameLevelType.kSummerFish then
            node = ArmatureNode:create('2018SunmerSea/sea12')
		    anchorPoint = ccp(1/4,1/2)
		    nodeWidth = 70 * 2
		    offsetX = -100
		    scale = 1
            rotation = 0
            FlyDelayTime = 0.5
            aPartDelay = 0.5
            nodePosOffset = ccp( 8/0.7, 26/0.7 )
        else
		    node = ArmatureNode:create('2016_ShengDan_Mistletoe/snowman')
		    anchorPoint = ccp(1/2,3/4)
		    nodeWidth = 70 * 2
		    offsetX = -100
		    scale = 1
        end
    elseif itemId == GameItemOrderType_SeaAnimal.kScaf_V then

        if CurLevelType == GameLevelType.kSummerFish then
            node = ArmatureNode:create('2018SunmerSea/sea21')
		    anchorPoint = ccp(1/2,3/4)
		    nodeWidth = 70*2
		    offsetX = -100
		    scale = 1
            rotation = 0
            FlyDelayTime = 0.5
            aPartDelay = 0.5
            nodePosOffset = ccp( 32/0.7, 32/0.7 )
        else
		    node = ArmatureNode:create('2016_ShengDan_Mistletoe/snowman')
		    anchorPoint = ccp(1/2,3/4)
		    nodeWidth = 70 * 2
		    offsetX = -100
		    scale = 1
        end
	elseif itemId == GameItemOrderType_SeaAnimal.kSea_3_3 then
        if CurLevelType == GameLevelType.kSummerFish then
            node = ArmatureNode:create('2018SunmerSea/sea33')
		    if rotation == 0 then
			    anchorPoint = ccp(1/6, 5/6)
		    end
		    nodeWidth = 222
		    offsetX = -141
		    scale = 1
		    duration = 1.5 -- old : 2.1
		    aPartDelay = 0.5
            rotation = 0
            FlyDelayTime = 0.5
        else
		    node = ArmatureNode:create('seabear')
		    if rotation == 0 then
			    anchorPoint = ccp(1/6, 5/6)
		    end
		    nodeWidth = 70 * 3
		    offsetX = -80
		    scale = 210 / node:getGroupBounds().size.height
		    duration = 1.5 -- old : 2.1
		    aPartDelay = 1
        end
	else 
		return 
	end


    local function onIconScaleFinished()
		if node and not node.isDisposed then
			if _G.isLocalDevelopMode then printx(0, 'removed') end
			node:removeFromParentAndCleanup(true)
            self.animNode = nil
		end
	end 

    local function onIconMoveFinished()		
    
        local CurShowNum = tonumber( self.label:getString() )
        if CurShowNum < itemNum then
            itemNum = CurShowNum
        end

		self.label:setString(tostring(itemNum or 0))
		context:playLeafAnimation(true)
		context:playLeafAnimation(false)
		self:shakeObject()
		local sequence = CCSpawn:createWithTwoActions(CCScaleTo:create(0.3, scale * 2), CCFadeOut:create(0.3))
		node:setOpacity(255)
		node:runAction(CCSequence:createWithTwoActions(sequence, CCCallFunc:create(onIconScaleFinished)))
	end 

    local csize = node:getGroupBounds().size
    if itemId == GameItemOrderType_SeaAnimal.kSea_3_3 and CurLevelType == GameLevelType.kSummerFish then
	    node:setContentSize(CCSizeMake(210,210))
        node:setPosition(ccp(globalPosition.x,globalPosition.y-15))
    else
        node:setContentSize(CCSizeMake(csize.width, csize.height))
        node:setPosition( ccp(globalPosition.x+nodePosOffset.x,globalPosition.y+nodePosOffset.y) )
    end
	if rotation ~= 0 then
		node:setRotation(-rotation)
	end
	node:setScale(scale)
	if duration > 0 then
		node:playByIndex(0, 1, duration)
	else
		node:playByIndex(0)
	end
	node:setAnimationScale(0.875)
	node:setAnchorPoint(anchorPoint)
--    node:setPosition(globalPosition)
    scene:addChild(node)


    if itemId == GameItemOrderType_SeaAnimal.kSea_3_3 and CurLevelType == GameLevelType.kSummerFish then

        local action = GameBoardActionDataSet:createAs(
                GameActionTargetType.kGameItemAction,
                GameItemActionType.kSummerFish_33_FlyObject,
                nil,
                nil,
                GamePlayConfig_MaxAction_time
            )
        action.completeCallback = onIconMoveFinished
        action.node = node
        action.globalPosition = globalPosition
        action.nodeWidth = nodeWidth
        action.offsetX = offsetX
        action.aPartDelay = aPartDelay
        action.FlyDelayTime = FlyDelayTime
        action.icon = self.icon
        action.SunmerFish3x3GetNum = SunmerFish3x3GetNum
        action.csize = csize

        if mainLogic then
            mainLogic:addGlobalCoreAction(action)
        else
            onIconMoveFinished()
        end
    else
        --其他海洋生物
	    local scale = 30 / math.max(node:getGroupBounds().size.width, node:getGroupBounds().size.height)

	    -- 防止动画飞出屏幕
	    local moveOffsetX = 0
	    local moveOffsetY = 0
	    if globalPosition.x > ( vo.x + vs.width - nodeWidth) then
		    moveOffsetX = offsetX
	    end

        if globalPosition.x - nodeWidth/2 < vo.x then
		    moveOffsetX = offsetX * (-1)
	    end

	    local a = CCArray:create()
	    a:addObject(CCDelayTime:create(FlyDelayTime))
	    -- a:addObject(CCRotateBy:create(0.2, rotation))
	    a:addObject(CCSpawn:createWithTwoActions(CCRotateBy:create(0.2, rotation), CCMoveBy:create(0.2, ccp(moveOffsetX, moveOffsetY))))
	    a:addObject(CCDelayTime:create(aPartDelay))	--2
	    a:addObject(CCCallFunc:create(
		    function ()
			    local centerPos = ccp(node:getGroupBounds():getMidX(), node:getGroupBounds():getMidY())
			    centerPos = node:convertToNodeSpace(centerPos)
			    local realAnchorPoint = ccp(centerPos.x/csize.width, centerPos.y/csize.height)
			    node:setAnchorPointWhileStayOriginalPosition(realAnchorPoint)
		    end
	    ))
	    -- local destPos = panel.icon:getPosition()
        local destPos = self.icon:getParent():convertToWorldSpace(self.icon:getPosition())
	    local b = CCArray:create()
	    b:addObject(CCEaseSineInOut:create(CCMoveTo:create(0.5, ccp(destPos.x, destPos.y))))
	    b:addObject(CCFadeTo:create(0.5, 150))
	    b:addObject(CCScaleTo:create(0.5, scale))
	    a:addObject(CCSpawn:create(b))
	    a:addObject(CCCallFunc:create(onIconMoveFinished))
	    node:runAction(CCSequence:create(a))
    end

    return node
end

function SeaOrderTargetItem:getGafAnimation(itemId, itemNum, globalPosition, rotation)
	local panel = self.sprite
	local context = self.context

	local scene = Director:sharedDirector():getRunningScene()
    if not scene then return end

	local vo = Director:sharedDirector():getVisibleOrigin()
	local vs = Director:sharedDirector():getVisibleSize()
	local node = gAnimatedObject:createWithFilename("gaf/fourth_anniversary/fourth_anniversary.gaf")
	local anchorPoint = ccp(0, 0) 
	local scale = 1
	local nodeWidth = 0
	local offsetX = 0
	local duration = 0
	local aPartDelay = 1.4

	if itemId == GameItemOrderType_SeaAnimal.kMistletoe then
		node:playSequence("cake4_ready", false, true, 1)
		nodeWidth = 70
		scale = 1
	elseif itemId == GameItemOrderType_SeaAnimal.kElk then
		node:playSequence("cake1_ready", false, true, 1)
		offsetX = 35
		nodeWidth = 70 * 2
		scale = 1
	elseif itemId == GameItemOrderType_SeaAnimal.kScarf then
		if rotation ~= 0 then
			node:playSequence("cake3_ready", false, true, 1)
			offsetX = 50
		else 
			node:playSequence("cake2_ready", false, true, 1)
		end
		nodeWidth = 70 * 2
		scale = 1
	elseif itemId == GameItemOrderType_SeaAnimal.kSea_3_3 then
		node:playSequence("cake4_ready", false, true, 1)
		offsetX = 70
		nodeWidth = 70 * 3
		scale = 1
	else 
		return 
	end
	local csize = node:getGroupBounds().size
	node:setContentSize(CCSizeMake(csize.width, csize.height))
	node:setScale(scale)
	node:start()
	--node:setAnimationScale(0.875)
	--node:setAnchorPoint(anchorPoint)
    node:setPosition(ccp(globalPosition.x + offsetX, globalPosition.y))
    scene:addChild(node)

	local scale = 30 / math.max(node:getGroupBounds().size.width, node:getGroupBounds().size.height)

	local function onIconScaleFinished()
		if node and not node.isDisposed then
			if _G.isLocalDevelopMode then printx(0, 'removed') end
			node:removeFromParentAndCleanup(true)
            self.animNode = nil
		end
	end 

	local function onIconMoveFinished()		

        local CurShowNum = tonumber( self.label:getString() )
        if CurShowNum < itemNum then
            itemNum = CurShowNum
        end
        	
		self.label:setString(tostring(itemNum or 0))
		context:playLeafAnimation(true)
		context:playLeafAnimation(false)
		self:shakeObject()
		onIconScaleFinished()
	end 

	-- 防止动画飞出屏幕
	local moveOffsetX = 0
	local moveOffsetY = 0
	--[[if globalPosition.x > ( vo.x + vs.width - nodeWidth) then
		moveOffsetX = offsetX
	end]]

	local a = CCArray:create()
	a:addObject(CCDelayTime:create(0.5))
	a:addObject(CCMoveBy:create(0.2, ccp(moveOffsetX, moveOffsetY)))
	a:addObject(CCDelayTime:create(aPartDelay))
    local destPos = self.icon:getParent():convertToWorldSpace(self.icon:getPosition())
	local b = CCArray:create()
	b:addObject(CCEaseSineInOut:create(CCMoveTo:create(0.5, ccp(destPos.x, destPos.y))))
	b:addObject(CCFadeTo:create(0.5, 150))
	b:addObject(CCScaleTo:create(0.5, scale))
	a:addObject(CCSpawn:create(b))
	a:addObject(CCCallFunc:create(onIconMoveFinished))
	node:runAction(CCSequence:create(a))
    return node
end

function SeaOrderTargetItem:setTargetNumber(itemId, itemNum, animate, globalPosition, rotation )

    --根据关卡类型不同创建不用更多海洋生物
    local CurLevelType = 0
    local mainLogic = GameBoardLogic:getCurrentLogic()
	if mainLogic then
        local levelID = mainLogic.level
        CurLevelType = LevelType:getLevelTypeByLevelId( levelID )
    end

	if self.isFinished then return end
	if not self.sprite.refCocosObj then return end
	if itemNum ~= nil then
		self.itemNum = itemNum
		if itemNum <= 0 then self:finish() end

		if animate and globalPosition and self.icon then
            if rotation ~= nil then -- 目标是海洋生物
            	if itemId >= 4 then 
                    if CurLevelType == GameLevelType.kSummerFish then
                        self.animNode = self:getAnimation(itemId, self.itemNum, globalPosition, rotation)
                    else
            		    self.animNode = self:getGafAnimation(itemId, self.itemNum, globalPosition, rotation)
                    end
            	else
					self.animNode = self:getAnimation(itemId, self.itemNum, globalPosition, rotation)
				end
            else -- 目标不是海洋生物
                local cloned = self.icon:clone(true)
                local targetPos = self.sprite:getParent():convertToNodeSpace(globalPosition)
                local position = cloned:getPosition()
                local tx, ty = position.x, position.y
                local function onIconScaleFinished()
                    cloned:removeFromParentAndCleanup(true)
                    self.animNode = nil
                end 
                local function onIconMoveFinished()       
                    self.label:setString(tostring(self.itemNum or 0))
                    self.context:playLeafAnimation(true)
                    self.context:playLeafAnimation(false)
                    self:shakeObject()
                    local sequence = CCSpawn:createWithTwoActions(CCScaleTo:create(0.3, 2), CCFadeOut:create(0.3))
                    cloned:setOpacity(255)
                    cloned:runAction(CCSequence:createWithTwoActions(sequence, CCCallFunc:create(onIconScaleFinished)))
                end 
                local moveTo = CCEaseSineInOut:create(CCMoveTo:create(0.5, ccp(tx, ty)))
                local moveOut = CCSpawn:createWithTwoActions(moveTo, CCFadeTo:create(0.5, 150))
                cloned:setPosition(targetPos)
                cloned:runAction(CCSequence:createWithTwoActions(moveOut, CCCallFunc:create(onIconMoveFinished)))
                self.animNode = cloned
            end
		else
			self.label:setString(tostring(self.itemNum or 0))
		end
	end
end


function SeaOrderTargetItem:getDropNum( num )
    if num > 99 then
        num = 99
    end
    local num1 = 0
    local num2 = 0
    if num < 10 then
        num1 = 0
        num2 = num
    else
        num2 = num%10
        num1 = (num - num2)/10
    end

    return num1, num2
end