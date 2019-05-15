
TileRandomProp = class(CocosObject)
local kCharacterAnimationTime = 1/30

-- function TileRandomProp:create(propId)
--     local node = TileRandomProp.new(CCNode:create())
--     node.name = "tile_random_prop"
--     node:createSprite(propId)
--     return node
-- end

-- function TileRandomProp:createSprite( propId )
--     self.bg = Sprite:createWithSpriteFrameName("weekly_ingame/tile_grass_1_0000")
--     self.bg:setPosition(ccp(-2.5, 9))
--     self:addChild(self.bg)
    
--     -- local prop = InterfaceBuilder:create(PanelConfigFiles.properties)
--     self.jewel = TileRandomProp:buildPropSprite(propId) 
--     self.jewel:setScale(0.7)
--     self:addChild(self.jewel)
-- end

-- function TileRandomProp:buildPropSprite(propId)
--     local mapPropId = TileRandomProp:mapPropId(propId)
--     local sprite = ResourceManager:sharedInstance():buildItemSprite(mapPropId)
--     if sprite then
--         sprite:ignoreAnchorPointForPosition(false)
--         sprite:setAnchorPoint(ccp(0.5, 0.5))
--     end
--     return sprite
-- end

-- function TileRandomProp:mapPropId(limitPropId)
--     local ret = limitPropId
--     if ItemType:isTimeProp(limitPropId) then
--         ret = ItemType:getRealIdByTimePropId( limitPropId )
--     end
--     return ret
-- end

-- function TileRandomProp:playDie(callback)
--     local time = 0.5
--     local jewel = self.jewel
--     if jewel then jewel:stopAllActions() jewel:setRotation(0) end
--     local function localCallback()
--         if jewel then jewel:removeFromParentAndCleanup(true) end
--     end 
--     local action_jump = CCJumpBy:create(time / 2, ccp(0, 0), GamePlayConfig_Tile_Width/5, 1)
--     local action_callback = CCCallFunc:create(localCallback)
--     local array = CCArray:create()
--     array:addObject(action_jump)
--     array:addObject(CCDelayTime:create(0.5))
--     array:addObject(action_callback)
--     local action_result = CCSequence:create(array)
--     jewel:runAction(action_result)
    
--     self:bgDisappear(callback)
-- end

-- function TileRandomProp:bgDisappear(callback)
-- 	local frames = SpriteUtil:buildFrames("weekly_ingame/tile_grass_1_%04d", 0, 22)
-- 	local anim = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
-- 	self.bg:stopAllActions()
-- 	self.bg:play(anim, 0, 1, callback)
-- end


function TileRandomProp:create(propId)
    local node = TileRandomProp.new(CCNode:create())
    node.name = "tile_random_prop"
    node:createSprite(propId)
    node:createFrontCloud(propId)
    return node
end

function TileRandomProp:createSprite( propId )
    self.bgCloud = Sprite:createWithSpriteFrameName("dig_cloud_b_0000")
    self:addChild(self.bgCloud)

    self.jewel = TileRandomProp:buildPropSprite(propId) 

    if GamePlayContext:isResumeReplayMode() then
        self.jewel:setScale(0.01)
    else
        self.jewel:setScale(0.7)
    end
    
    self:addChild(self.jewel)
end

function TileRandomProp:createFrontCloud()
    local nameStr = "dig_jewel_front_0000"
    self.frontCloud = Sprite:createWithSpriteFrameName(nameStr)
    self:addChild(self.frontCloud)
end

function TileRandomProp:buildPropSprite(propId)
    local mapPropId = TileRandomProp:mapPropId(propId)
    local sprite = ResourceManager:sharedInstance():buildItemSprite(mapPropId)
    if sprite then
        sprite:ignoreAnchorPointForPosition(false)
        sprite:setAnchorPoint(ccp(0.5, 0.5))
    end
    return sprite
end

function TileRandomProp:mapPropId(limitPropId)
    local ret = limitPropId
    if ItemType:isTimeProp(limitPropId) then
        ret = ItemType:getRealIdByTimePropId( limitPropId )
    end
    return ret
end

function TileRandomProp:playDie(callback)
    if self.frontCloud then self.frontCloud:removeFromParentAndCleanup(true) end

    local time = 0.5
    local jewel = self.jewel
    if jewel then jewel:stopAllActions() jewel:setRotation(0) end
    local function localCallback()
        if jewel then jewel:removeFromParentAndCleanup(true) end
    end 
    local action_jump = CCJumpBy:create(time / 2, ccp(0, 0), GamePlayConfig_Tile_Width/5, 1)
    local action_callback = CCCallFunc:create(localCallback)
    local array = CCArray:create()
    array:addObject(action_jump)
    array:addObject(CCDelayTime:create(0.5))
    array:addObject(action_callback)
    local action_result = CCSequence:create(array)
    jewel:runAction(action_result)
    self.bgCloud:setVisible(false)
    
    self:playCloudDisappearAnimation(callback)
end


function TileRandomProp:playCloudDisappearAnimation( afterAnimationCallback )
    local sprite_name = "dig_cloud_0000"
    local container = Sprite:createEmpty()
    container:setTexture(self.parentTexture)
    for k = 1, 8 do 
        local sprite = Sprite:createWithSpriteFrameName(sprite_name)
        local angle = (k-1) * 360/8   ----------角度
        local radian = angle * math.pi / 180
    
        sprite:setScale(0.8)
        sprite:setAnchorPoint(ccp(0.5,0.5))
        local time_spaw = 0.5
        local action_move_1 = CCMoveBy:create(time_spaw/2, ccp(math.sin(radian) * 2 *GamePlayConfig_Tile_Width/3 , math.cos(radian) * 2 *GamePlayConfig_Tile_Width/3  ))
        local action_scale = CCScaleTo:create(time_spaw/2,1)
        local action_spaw_1 = CCSpawn:createWithTwoActions(action_move_1, action_scale)
        
        local action_fadeout = CCFadeOut:create(time_spaw * 2)
        local action_move_2 = CCMoveBy:create(time_spaw * 2, ccp(math.sin(radian) * GamePlayConfig_Tile_Width/10 , math.cos(radian) * GamePlayConfig_Tile_Width/10  ))
        local action_scale_2 = CCScaleTo:create(time_spaw * 2, 0.5)
        local actionArray_spawn_2 = CCArray:create()
        actionArray_spawn_2:addObject(action_fadeout)
        actionArray_spawn_2:addObject(action_move_2)
        actionArray_spawn_2:addObject(action_scale_2)
        local action_spaw_2 = CCSpawn:create(actionArray_spawn_2)

        local actionArray = CCArray:create()
        actionArray:addObject(action_spaw_1)
        actionArray:addObject(action_spaw_2)

        sprite:runAction(CCSequence:create(actionArray))
        container:addChild(sprite)
    end
    local function callback( ... )
        container:removeFromParentAndCleanup(true)
        if afterAnimationCallback and type(afterAnimationCallback) == "function" then 
            afterAnimationCallback()
        end
    end

    self:addChildAt(container,0)
    container:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1.25), CCCallFunc:create(callback)))
end