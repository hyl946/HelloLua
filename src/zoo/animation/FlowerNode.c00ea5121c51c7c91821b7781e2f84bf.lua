require "zoo.animation.Flowers"

FlowerNode = class(Sprite)

kFlowerType = {
    kNormal = 1,
    kHidden = 2,
    kJumped = 3,
    kFourStar = 4,
	kAskForHelp = 5,
}

local kFlowerSpriteZOrder = {
	kFlower = 10,
	kStars = 20,
	kLabel = 30,
}

function FlowerNode:ctor()
	self.flower = nil
	self.stars = nil
	self.label = nil
end

function FlowerNode:create(flowerType, levelId, starNum, autoGray)
	local node = FlowerNode.new(CCSprite:create())
	node:init(flowerType, levelId, starNum, autoGray)
	return node
end

--------------------------------------------------------------------------------------
function FlowerNode:createStars(flowerType, starNum ,levelId)
	starNum = starNum or 0
	local stars = Sprite:createEmpty()
	-- local isStar4Level = MetaModel:sharedInstance():isStar4Level(levelId)
	-- --是否显示空的四星
	-- local hasEmptyStar4 = isStar4Level and 3 == starNum 

    if starNum > 0 then
        local starTexture = nil
        local mutiTexture = false

        -- four star shell
        if flowerType == kFlowerType.kFourStar  then
        	for i=starNum+1,4 do
            	local starShell = Sprite:createWithSpriteFrameName("flowerStar0".."0000")
            	starShell:setPosition(ccp((i - (4 + 1)/2) * 24, -2))
                stars:addChild(starShell)
	        end
        end

        for i = 1, starNum do
            local star = nil
            if flowerType == kFlowerType.kNormal or  flowerType == kFlowerType.kFourStar then
                star = Sprite:createWithSpriteFrameName("flowerStar"..i.."0000")
            elseif flowerType == kFlowerType.kHidden then
                star = Sprite:createWithSpriteFrameName("hiddenFlowerStar"..i.."0000")
            end

            if star then
            	if flowerType == kFlowerType.kFourStar then
					star:setPosition(ccp((i - (4 + 1)/2) * 24, 0))
            	else
            		star:setPosition(ccp((i - (starNum + 1)/2) * 24, 0))
            	end
                stars:addChild(star)
                if not starTexture then 
                	starTexture = star:getTexture() 
            	elseif not mutiTexture and starTexture ~= star:getTexture() then
            		mutiTexture = true
            	end
            end
        end

        if not mutiTexture and starTexture then
        	stars:setTexture(starTexture)
        end
    elseif starNum <= 0 then 
        if flowerType == kFlowerType.kFourStar then
        	for i=1,4 do
            	local starShell = Sprite:createWithSpriteFrameName("flowerStar0".."0000")
            	starShell:setPosition(ccp((i - (4 + 1)/2) * 24, -2))
                stars:addChild(starShell)
	        end
        end
    end
	return stars
end

function FlowerNode:createFlower(flowerType, starNum , levelId,autoGray)
	starNum = starNum or 0
	if starNum < 1 then starNum = 1 end
    local flower = nil
    if flowerType == kFlowerType.kNormal then
        flower = Sprite:createWithSpriteFrameName(kFlowers["flowerStar"..starNum].."0000")
    elseif flowerType == kFlowerType.kHidden then
        if (not autoGray ) or UserManager:getInstance():isHiddenLevelCanPlay(levelId) then
			flower = Sprite:createWithSpriteFrameName(kFlowers["hiddenFlower"..starNum].."0000")
		else
			flower = Sprite:createWithSpriteFrameName(kFlowers["hiddenFlowerGray"].."0000")
		end

    elseif flowerType == kFlowerType.kJumped then
        flower = Sprite:createWithSpriteFrameName(kFlowers.jumpedFlower.."0000")
    elseif flowerType == kFlowerType.kFourStar  then
		if (not autoGray ) or levelId <= UserManager.getInstance().user:getTopLevelId() then
			flower = Sprite:createWithSpriteFrameName(kFlowers["flowerStar"..starNum].."0000")
		else
			flower = Sprite:createWithSpriteFrameName(kFlowers["flowerStarGray"].."0000")
		end
	elseif flowerType == kFlowerType.kAskForHelp then
		flower = Sprite:createWithSpriteFrameName(kFlowers.askForHelpFlower.."0000")
    end
    return flower
end

------------------------------------------------------------------------------------
function FlowerNode:addFlowerAndStars(flowerType, starNum ,levelId, autoGray)
	if self.flower then
		self.flower:removeFromParentAndCleanup(true)
		self.flower = nil
	end
	local sizeFlower = nil
	self.flower = FlowerNode:createFlower(flowerType, starNum , levelId ,autoGray)
	if self.flower then
		self:addChildAt(self.flower, kFlowerSpriteZOrder.kFlower)
		sizeFlower = self.flower:getContentSize()

		-- local lc = LayerColor:createWithColor(ccc3(0, 0, 255), sizeFlower.width, sizeFlower.height)--size.width, size.height)
		-- lc:setAnchorPoint(ccp(0.5, 0.5))
		-- lc:ignoreAnchorPointForPosition(false)
		-- self:addChild(lc)
	end

	if self.stars then 
		self.stars:removeFromParentAndCleanup(true) 
		self.stars = nil
	end
	self.stars = FlowerNode:createStars(flowerType, starNum ,levelId )
	if self.stars then
		local starPosY = -65
		if sizeFlower then 
			local sizeStarHeight = 23
			starPosY = -55 - sizeStarHeight / 2
		end
		self.stars:setPosition(ccp(0, starPosY))
		self:addChildAt(self.stars, kFlowerSpriteZOrder.kStars)
	end
end

function FlowerNode:addLabel(flowerType, levelId, faceName)
	if self.label then
		self.label:removeFromParentAndCleanup(true)
		self.label = nil
	end
	local isHiddenLevel = false
	local levelIdStr = tostring(levelId)
	if flowerType == kFlowerType.kHidden then
		isHiddenLevel = true
		if levelId >= LevelConstans.HIDE_LEVEL_ID_START then
			levelIdStr = "+"..tostring(levelId - LevelConstans.HIDE_LEVEL_ID_START)
		else
			levelIdStr = "+"..tostring(levelId)
		end
	end
	faceName = faceName or "Georgia"
	self.label = BitmapText:create(levelIdStr, getGlobalDynamicFontMap(faceName), -1, kCCTextAlignmentCenter)
	self.label:setPreferredSize(30, 35)
	-- if isHiddenLevel then
 --    	self.label:setPosition(ccp(-1, -2))
	-- else
 --    	self.label:setPosition(ccp(0, -2))
	-- end
    if WorldSceneShowManager:getInstance():isInAcitivtyTime() then
        self.label:setPosition(ccp(0, -5))
    else    
    	self.label:setPosition(ccp(0, -15))
    end
	self:addChildAt(self.label, kFlowerSpriteZOrder.kLabel)
end

function FlowerNode:init(flowerType, levelId, starNum,autoGray)
    starNum = starNum or 0
    autoGray = autoGray or false
    self:addFlowerAndStars(flowerType, starNum , levelId ,autoGray)
    if levelId then
    	self:addLabel(flowerType, levelId)
    end
	-- local lc = LayerColor:createWithColor(ccc3(0, 255, 0), 20, 20)--size.width, size.height)
	-- lc:setAnchorPoint(ccp(0.5, 0.5))
	-- lc:ignoreAnchorPointForPosition(false)
	-- self:addChildAt(lc, 99)
end

function FlowerNode:dispose()
	self.stars = nil
	self.flower = nil
	self.label = nil
	Sprite.dispose(self)
end

---------------------------------------------------------------------------
FlowerNodeUtil = class()

function FlowerNodeUtil:createWithSize(flowerType, levelId, starNum, size , autoGray)
	assert(size ~= nil, "createWithSize : size cannot be nil")
	local node = Layer:create()
	node:changeWidthAndHeight(size.width, size.height) 
	node:setAnchorPoint(ccp(0, 1))
	node:ignoreAnchorPointForPosition(false)

	-- local lc = LayerColor:createWithColor(ccc3(255, 255, 0), size.width, size.height)
	-- lc:setAnchorPoint(ccp(0, 0))
	-- lc:ignoreAnchorPointForPosition(false)
	-- node:addChild(lc)

	local flowerNode = FlowerNode:create(flowerType, levelId, starNum,autoGray)
	flowerNode:setPosition(ccp(size.width/2, size.height/2))
    node.flowerNode = flowerNode
	node:addChild(flowerNode)

	-- local lc = LayerColor:createWithColor(ccc3(255, 0, 0), 10, 10)--size.width, size.height)
	-- lc:setAnchorPoint(ccp(0.5, 0.5))
	-- lc:ignoreAnchorPointForPosition(false)
	-- lc:setPosition(ccp(size.width / 2, size.height / 2))
	-- node:addChild(lc)
	return node
end

function FlowerNodeUtil:createJumpedFlowerWithIngredientCount(flowerType, levelId, starNum, size, count)
    local node = FlowerNodeUtil:createWithSize(flowerType, levelId, starNum, size)
    local num = BitmapText:create('x'..(count or 0), getGlobalDynamicFontMap('SkipLevel'), -1, kCCTextAlignmentLeft)
    num:setScale(0.8)
    num:setAnchorPoint(ccp(0, 0))
    local icon = Sprite:createWithSpriteFrameName('flower_ingredient0000')
    icon:setScale(0.35)
    node:addChild(num)
    node:addChild(icon)
    local x = 40
    local y = 35
    num:setPosition(ccp(x + 15, y - 20))
    icon:setPosition(ccp(x, y))
    return node
end
