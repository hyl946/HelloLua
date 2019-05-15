require "zoo.panel.component.levelTarget.LevelTargetItem"

-------------------------------------------------------------------------------
--新的目标类型，主要用来填充并在满的时候关卡中释放，能产生对棋盘有影响的效果
--可以叫它填充目标
-------------------------------------------------------------------------------
FillTargetItem = class(LevelTargetItem)

function FillTargetItem:init()

    local pos = self.sprite:getPosition()
    self.bgSprite = Layer:create()
    -- self.bgSprite:setAnchorPoint(ccp(0,0))
    self:initFill()

    local spriteSize = self.sprite:getGroupBounds().size
    self.sprite:setContentSize(CCSizeMake(spriteSize.width, spriteSize.height))
    self.shadowSprite:setContentSize(CCSizeMake(spriteSize.width, spriteSize.height))
    self.bgSprite:setContentSize(CCSizeMake(spriteSize.width, spriteSize.height))

    self.sprite:setAnchorPoint(ccp(0,0))

    self.shadowSprite:setPosition(ccp(pos.x,pos.y))
    self.bgSprite:setPosition(ccp(pos.x,pos.y))

    self.context.attachSprite:addChild(self.shadowSprite)
    self.context.bgSprite:addChild(self.bgSprite)

    self:initContent()
    self.zOrder = 1
    local fntFile   = "fnt/target_amount.fnt"
    local text = BitmapText:create("", fntFile, -1, kCCTextAlignmentRight)
    text.fntFile    = fntFile
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
    self.percent = 0
end

function FillTargetItem:initFill( ... )
    local bg = self.sprite:getChildByName('bg')
    local pos_bg = bg:getPosition()
    -- fill anima
    local fill_bg = Sprite:createWithSpriteFrameName("hedgehog_target_bg_0000")
    self.fill_bg = fill_bg
    fill_bg:setScale(1.67)
    fill_bg:setAnchorPoint(ccp(0.5, 0.5))
    local board = bg:getChildByName("bg")
    local size = board:getContentSize()
    local pos = board:getPosition()
    local scale = self.sprite:getScale() * bg:getScale() * fill_bg:getScale()
    fill_bg:setPosition(ccp(pos_bg.x + pos.x + size.width/2, pos_bg.y + pos.y - size.height/2))
    fill_bg:setVisible(false)
    self.bgSprite:addChild(self.fill_bg)

    -- progress 
    local highlight = bg:getChildByName("highlight")
    highlight:setVisible(false)
    local h_size = highlight:getContentSize()
    local h_pos = highlight:getPosition()
    local h_index = self.sprite:getChildIndex(highlight)

    local progress = Sprite:createEmpty()
    self.progress = progress
    progress:setPositionXY(pos_bg.x + h_pos.x + h_size.width/2 , pos_bg.y + h_pos.y - h_size.height/2)
    -- self.shadowSprite:addChildAt(progress, -1)
    self.shadowSprite:addChild(progress)

    local p_bg = Sprite:createWithSpriteFrameName("hedgehog_target_other_0002")
    progress:addChild(p_bg)

    local p_mask = Sprite:createWithSpriteFrameName("hedgehog_target_other_0002")
    local clippingnode = ClippingNode.new(CCClippingNode:create(p_mask.refCocosObj))
    clippingnode:setAlphaThreshold(0.98)
    local p_bar = Sprite:createWithSpriteFrameName("hedgehog_target_other_0003")
    clippingnode:addChild(p_bar)
    progress:addChild(clippingnode)
    progress.bar = p_bar
    progress.distance = p_bg:getGroupBounds().size.height
    progress.bar:setPositionY(-progress.distance)
    local p_fg = Sprite:createWithSpriteFrameName("hedgehog_target_other_0004")
    progress:addChild(p_fg)
    self.progress = progress
    self:setProgressPercent(0)
end

function FillTargetItem:setPosition( pos )
    -- body
    self.sprite:setPosition(pos)
    self.shadowSprite:setPosition(ccp(pos.x, pos.y))
    self.bgSprite:setPosition(ccp(pos.x, pos.y))
end
function FillTargetItem:setProgressPercent( value )
    -- body
    if value < 0 then 
        value = 0
    elseif value > 1 then
        value = 1
    end
    self.progress.bar:stopAllActions()
    self.progress.bar:runAction(CCMoveTo:create(0.5,ccp(0, -self.progress.distance*(1- value))))
end

function FillTargetItem:shakeObject( rotation )
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
    self:shakeSprite(self.bgSprite, startRotation)
    return true
end


function FillTargetItem:playCollectAnimation( ... )
    -- body
    if self.playCollectAnimationing then return end
    local function _callback( ... )
        -- body
        self.playCollectAnimationing = false
        self.fill_bg:setVisible(false)
    end
    self.fill_bg:setVisible(true)
    self.playCollectAnimationing = true
    local frames = SpriteUtil:buildFrames("hedgehog_target_bg_%04d", 0, 20)
    local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
    self.fill_bg:play(animate, 0, 1, _callback)
end

function FillTargetItem:setTargetNumber(itemId, itemNum, animate, globalPosition, rotation, percent )
    if not self.sprite.refCocosObj then return end
    if itemNum ~= nil then
        -- 防止数字回滚
        -- 前提：反正该模式下，数字是单向增加的
        if itemNum >= self.itemNum then
            self.itemNum = itemNum
        end

        if percent > self.percent then
            self.percent = percent
        end

        if animate and globalPosition and self.icon then
            local cloned = self.icon:clone(true)
            -- local targetPos = self:convertToNodeSpace(globalPosition)
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
                self:playCollectAnimation()
                self:setProgressPercent(self.percent)
            end 
            local moveTo = CCEaseSineInOut:create(CCMoveTo:create(0.5, ccp(tx, ty)))
            local array = CCArray:create()

            if itemId == 1 then
            	cloned:setScale(0.3)
            	local scale_action = CCScaleTo:create(0.3, 1.5)
            	local index_x = math.random()
            	local index_y = math.random()
            	local jump_action = CCJumpBy:create(0.5, ccp(index_x * 2 * GamePlayConfig_Tile_Width, -index_y * 2* GamePlayConfig_Tile_Width), (1 + index_y) * GamePlayConfig_Tile_Width, 1)
            	array:addObject(CCSpawn:createWithTwoActions(scale_action, jump_action))
            	array:addObject(CCDelayTime:create(index_y))
            end
            array:addObject(CCSpawn:createWithTwoActions(moveTo, CCFadeTo:create(0.5, 150)))
            array:addObject(CCCallFunc:create(onIconMoveFinished))
            cloned:setPosition(targetPos)
            cloned:runAction(CCSequence:create(array))
            self.animNode = cloned
        else
            self.label:setString(tostring(itemNum or 0))
        end
    end
end

function FillTargetItem:releaseEnergyUpdate( value )
    -- body
    self.percent = value
    self:setProgressPercent(self.percent)
end

function FillTargetItem:releaseEnergy( topos, callback )
    -- body
    local timeS = 1.5
    local parent = self.shadowSprite
    local fill_pos = self.fill_bg:getPosition()
    local _x = fill_pos.x
    local _y = fill_pos.y

    local _off_x = -0   ---梦玉非要调
    local _off_y = 30
    --bg
    local bg = Sprite:createWithSpriteFrameName("hedgehog_target_other_0000")
    local function _removeBg( ... )
        -- body
        if bg then bg:removeFromParentAndCleanup(true) end
    end
    local arr_0 = CCArray:create()
    local action_1_scale = CCScaleTo:create(timeS/2, 1.5)
    local action_2_scale = CCScaleTo:create(timeS/2, 1)
    arr_0:addObject(CCSequence:createWithTwoActions(action_1_scale, action_2_scale)) 
    local arr_1 = CCArray:create()
    arr_1:addObject(CCFadeIn:create(timeS/4))
    arr_1:addObject(CCDelayTime:create(timeS/2))
    arr_1:addObject(CCFadeOut:create(timeS/4))
    arr_1:addObject(CCCallFunc:create(_removeBg))
    arr_0:addObject(CCSequence:create(arr_1))
    arr_0:addObject(CCRotateBy:create(timeS, 200))
    bg:runAction(CCSpawn:create(arr_0))
    bg:setPosition(ccp(_x, _y))
    parent:addChild(bg)

    --fg
    local fg = Sprite:createWithSpriteFrameName("hedgehog_target_other_0001")
    local function _removeFg( ... )
        -- body
        if fg then fg:removeFromParentAndCleanup(true) end
    end
    local arr = CCArray:create()
    -- arr:addObject(CCDelayTime:create(timeS/4))
    arr:addObject(CCFadeIn:create(timeS/2))
    arr:addObject(CCDelayTime:create(timeS/4))
    arr:addObject(CCFadeOut:create(timeS/4))
    arr:addObject(CCCallFunc:create(_removeFg))
    fg:runAction(CCSequence:create(arr))
    parent:addChild(fg)
    fg:setPosition(ccp(_x, _y))

    --apple
    local apple = Sprite:createWithSpriteFrameName("hedgehog_target_other_0005")
    local pos = self.fill_bg:getPositionInWorldSpace()
    apple:setPosition(ccp(pos.x ,pos.y))
    apple:setOpacity(0)

    local function _callback()
        if callback then callback() end
        if apple then apple:removeFromParentAndCleanup(true) end
    end

   
    GamePlayMusicPlayer:playEffect(GameMusicType.kHedgehogCrazy)

    local arr_2 = CCArray:create()
    arr_2:addObject(CCDelayTime:create(timeS/2))
    arr_2:addObject(CCFadeIn:create(timeS/4))
    arr_2:addObject(CCDelayTime:create(timeS/4))
    arr_2:addObject( CCEaseIn:create(CCJumpTo:create(timeS/2, ccp(topos.x + _off_x, topos.y + _off_y), 200, 1 ), 2))
    arr_2:addObject(CCCallFunc:create(_callback))
    local seq_1 = CCSequence:create(arr_2)
    local arr_3 = CCArray:create()
    arr_3:addObject(CCDelayTime:create(timeS/2))
    arr_3:addObject(CCScaleTo:create(timeS/4, 1.5))
    arr_3:addObject(CCScaleTo:create(timeS/4, 1.3))
    arr_3:addObject(CCScaleTo:create(timeS/2, 0.9))
    local seq_2 = CCSequence:create(arr_3)
    apple:runAction(CCSpawn:createWithTwoActions(seq_1, seq_2))
    local scene = Director.sharedDirector():getRunningScene()
    scene:addChild(apple)
end
