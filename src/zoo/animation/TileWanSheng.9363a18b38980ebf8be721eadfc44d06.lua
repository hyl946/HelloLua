
TileWanSheng = class(CocosObject)

local kCharacterAnimationTime = 1/30
local AnimationFrames = {24, 21, 5}

local allOffset = { x=1,y=4 }
local downOffset = {} --升级时的偏移
local upOffset = {}
local downNormalOffset = {} --普通状态的偏移
local upNormalOffset = {}
downOffset[1] = { x=1.47+allOffset.x,y=-13+allOffset.y}
downOffset[2] = { x=0.4+allOffset.x,y=-10+allOffset.y}
downOffset[3] = { x=1.47+allOffset.x,y=-13.5+allOffset.y}

upOffset[1] = { x=-1+allOffset.x,y=-15+allOffset.y}
upOffset[2] = { x=0.5+allOffset.x,y=-8+allOffset.y}
upOffset[3] = { x=0.9+allOffset.x,y=-3.84+allOffset.y}

downNormalOffset[1] = downOffset[1]
downNormalOffset[2] = downOffset[2]
downNormalOffset[3] = downOffset[3]

upNormalOffset[1] = upOffset[1]
upNormalOffset[2] = upOffset[2]
upNormalOffset[3] = { x=0.2+allOffset.x,y=-1.2+allOffset.y}

local middleOffset = {x=allOffset.x, y=-4+allOffset.y}


local wanshengLayerIndex = {
	upLayer = 1,	--上
	middleLayer = 2,	--中
	downLayer = 3,	--下
}

local function getSmallItemPath( itemType, attr, animalDef )
    local resPath = ""
    if itemType == TileConst.kAnimal then
        resPath = "Samllicon_inItem/item_"..itemType.."_"..animalDef..".png"
    elseif itemType == TileConst.kTotems then
        local ColorType = AnimalTypeConfig.getType(animalDef)

        local index = 0
        if ColorType == AnimalTypeConfig.kBlue then 
		    index = 1
        elseif ColorType == AnimalTypeConfig.kGreen then 
    	    index = 2
        elseif ColorType == AnimalTypeConfig.kOrange then 
    	    index = 3
        elseif ColorType == AnimalTypeConfig.kPurple then 
    	    index = 4
        elseif ColorType == AnimalTypeConfig.kRed then 
    	    index = 5
        elseif ColorType == AnimalTypeConfig.kYellow then 
    	    index = 6
        end
        resPath = "Samllicon_inItem/item_"..itemType.."_"..index..".png"
    elseif itemType ==  TileConst.kTurret then
        local level = WanShengLogic:getTurretLevel( attr )
        resPath = "Samllicon_inItem/item_"..itemType.."_"..level..".png"
    elseif itemType ==  TileConst.kSunFlask then
        local level = WanShengLogic:getSunFlaskLevel( attr )
        resPath = "Samllicon_inItem/item_"..itemType.."_"..level..".png"
    elseif itemType ==  TileConst.kColorFilter then
        local level = tonumber(attr)
        resPath = "Samllicon_inItem/item_"..itemType.."_"..level..".png"
    else
        resPath = "Samllicon_inItem/item_"..itemType..".png"
    end

    return resPath
end

function TileWanSheng:create( level, Config )
	local node = TileWanSheng.new(CCNode:create())
	node.name = "tile_wansheng"
	node.level = level
	node.targetLevel = level
    node.Config = table.clone( Config )
	node:init()
	return node
end

function TileWanSheng:init( bLevelUp,animationCallBack )

    if bLevelUp == nil then bLevelUp = false end
    
    local resDownPath = ""
    local resUpPath = ""

	-- body
	if self.level <= 2 then
        resDownPath = "wansheng_level"..self.level.."_down_0.png"
        resUpPath = "wansheng_level"..self.level.."_up_0.png"

	else
        resDownPath = "wansheng_level1_down_0.png"
        resUpPath = "wansheng_level3_normal_0.png"
	end

    local ShowLevel = self.level
    if ShowLevel >= 4 then
        ShowLevel = 3
    end
    if not self.mainDownSprite then
		local mainDownSprite = Sprite:createWithSpriteFrameName(resDownPath)
        mainDownSprite:setPosition( ccp(downNormalOffset[ShowLevel].x,downNormalOffset[ShowLevel].y) )
		self.mainDownSprite = mainDownSprite
		self:addChild(mainDownSprite)
    end

    if not self.mainMiddleSprite then
        local middleResPath = getSmallItemPath( self.Config.mType+1, self.Config.attr, self.Config.animalDef  )
        local mainMiddleSprite = Sprite:createWithSpriteFrameName( middleResPath )
        mainMiddleSprite:setPosition( ccp(middleOffset.x,middleOffset.y) )
		self.mainMiddleSprite = mainMiddleSprite
		self:addChild(mainMiddleSprite)
    end

    if not self.mainUpSprite then
        local mainUpSprite = Sprite:createWithSpriteFrameName(resUpPath)
        mainUpSprite:setPosition( ccp(upNormalOffset[ShowLevel].x,upNormalOffset[ShowLevel].y) )
		self.mainUpSprite = mainUpSprite
		self:addChild(mainUpSprite)
    end

--    self.mainUpSprite:stopAllActions()

    if bLevelUp then
        local AnimDownNum = 0
        local AnimUpnNum = 0
        if ShowLevel == 1 then
            AnimDownNum = 26
            AnimUpnNum = 26
        else
            AnimDownNum = 26
            AnimUpnNum = 29
        end

        local resDownStartPath = "wansheng_level"..ShowLevel.."_down_%d.png"
        local resUpStartPath = "wansheng_level"..ShowLevel.."_up_%d.png"

        local frames = SpriteUtil:buildFrames(resDownStartPath, 0, AnimDownNum)
	    local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		self.mainDownSprite:play(animate, 0, 1)
        self.mainDownSprite:setPosition( ccp(downOffset[ShowLevel].x,downOffset[ShowLevel].y) )

        local frames2 = SpriteUtil:buildFrames(resUpStartPath, 0, AnimUpnNum)
	    local animate2 = SpriteUtil:buildAnimate(frames2, kCharacterAnimationTime)
		self.mainUpSprite:play(animate2, 0, 1, animationCallBack)
        self.mainUpSprite:setPosition( ccp(upOffset[ShowLevel].x,upOffset[ShowLevel].y) )
    else
        if ShowLevel >= 3 then
            local frames = SpriteUtil:buildFrames("wansheng_level3_normal_%d.png", 0, 37 )
		    local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		    self.mainUpSprite:play(animate)
            self.mainDownSprite:setVisible(false)

            if self.level > 3 then
                local rotateTime = 0.05
  	            local rotateAngel = 11
  	            local seq = CCSequence:createWithTwoActions(CCRotateTo:create(rotateTime, -rotateAngel), CCRotateTo:create(rotateTime*2, rotateAngel))
                self.mainUpSprite:runAction(CCRepeatForever:create(seq))
            end
        else
            self.mainDownSprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(resDownPath))
            self.mainUpSprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(resUpPath))
        end

        local posIndex = ShowLevel
        if posIndex > 3 then
            posIndex = 3
        end
        self.mainDownSprite:setPosition( ccp(downNormalOffset[posIndex].x,downNormalOffset[posIndex].y) )
        self.mainUpSprite:setPosition( ccp(upNormalOffset[posIndex].x,upNormalOffset[posIndex].y) )
    end

    if ShowLevel >= 3 then
        self.mainDownSprite:setVisible(false)
    else
        self.mainDownSprite:setVisible(true)
    end
end

--升级动画播放完毕
function TileWanSheng:playIncreaseComplete( ... )

	-- body
	self.level = self.level + 1

	if self.targetLevel > self.level then
        --die
		self:_playIncreaseAnimation()
	else
		self.isPlaying = false
        self:init()
	end
end

--升级动画
function TileWanSheng:_playIncreaseAnimation( ... )
	-- body
	self.isPlaying = true
	local function animationCallBack( ... )
		-- body
		self:playIncreaseComplete()
	end

	if self.level < 3 then
		self:init(true,animationCallBack)
	else
		self:init()
		animationCallBack()
	end
end

--升级
function TileWanSheng:playIncreaseAnimation( times )
	-- body
	self.targetLevel = self.targetLevel + times
	if not self.isPlaying then
		self:_playIncreaseAnimation()
	end
end

--死亡动画
function TileWanSheng:playBrokenAnimation( callback )
    local frames = SpriteUtil:buildFrames("wansheng_level3_up_%d.png", 0, 10 )
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
    self.mainUpSprite:stopAllActions()
	self.mainUpSprite:play(animate,0,1,callback)
end

--飞特效
function TileWanSheng:createFlyAnimation( fromPos, toPos, callback)

    local rotation = 0
	if toPos.y - fromPos.y > 0 then
		rotation = math.deg(math.atan((toPos.x - fromPos.x)/(toPos.y - fromPos.y)))
	elseif toPos.y -fromPos.y < 0 then
		rotation = 180 + math.deg(math.atan((toPos.x - fromPos.x) / (toPos.y - fromPos.y)))
	else
		if toPos.x - fromPos.x > 0 then rotation = 90
		else
			rotation = -90
		end
	end

    local sprite = Sprite:createEmpty()
    sprite:setRotation(rotation)
	sprite:setPosition(fromPos)

    local sprite1
    local function FlyEndCallback()
        sprite1:stopAllActions()
        sprite1:setVisible(false)

        -- body
        local sprite2 = Sprite:createWithSpriteFrameName("wansheng_boom_0.png")
	    local frames = SpriteUtil:buildFrames("wansheng_boom_%d.png", 0, 19)
	    local animate = SpriteUtil:buildAnimate(frames, 1/24)
--        sprite2:setPosition(ccp(39/0.7,-3/0.7))
        sprite2:setScale(1.3)
	    sprite2:play(animate)

	    local actionList = CCArray:create()
        actionList:addObject(CCDelayTime:create(0.4))
	    actionList:addObject(CCCallFunc:create(callback))
	    sprite2:runAction(CCSequence:create(actionList))
        sprite:addChild(sprite2)
    end

	-- body
	sprite1 = Sprite:createWithSpriteFrameName("wansheng_fly_0.png")
    sprite1:setPosition(ccp(0,-34))
	local frames = SpriteUtil:buildFrames("wansheng_fly_%d.png", 0, 18)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	sprite1:play(animate)
    sprite:addChild(sprite1)

	local actionList = CCArray:create()
	actionList:addObject( CCEaseSineOut:create(CCMoveTo:create(0.3, toPos)) )	--0.4
--    actionList:addObject( CCMoveTo:create(0.4, toPos) )
	actionList:addObject(CCCallFunc:create(FlyEndCallback))
	sprite:runAction(CCSequence:create(actionList))

	return sprite
end