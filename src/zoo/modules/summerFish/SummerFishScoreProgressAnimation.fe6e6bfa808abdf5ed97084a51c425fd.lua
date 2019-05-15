---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-08-03 14:27:39
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2016-08-08 18:03:34
---------------------------------------------------------------------------------------

local kStarFactor = 24 * 3.1415926 / 180
local kMaskBeginWidth = 17
local kMaskEndWidth = 50

SummerFishScoreProgressAnimation = class(ScoreProgressAnimation)

function SummerFishScoreProgressAnimation:create(scoreProgress, pos , levelId ,showStar4 )
	-- body
	local s = SummerFishScoreProgressAnimation.new()
	s:init(scoreProgress, pos , levelId ,showStar4 )
	s:moveTo(0)
	return s
end

function SummerFishScoreProgressAnimation:init( scoreProgress, pos ,levelId ,showStar4 )
	-- body
	self.levelId = 0
	self.showStar4 = true
	self.scoreProgress = scoreProgress
	self.parent = scoreProgress.parent
	self.basePos = pos
	local parent = scoreProgress.parent
	self.levelSkinConfig = GamePlaySceneSkinManager:getConfig(GamePlaySceneSkinManager:getCurrLevelType())
	local ladybug = ResourceManager:sharedInstance():buildBatchGroup("sprite", 
		self.levelSkinConfig.ladybugAnimation)

	self.kPropListScaleFactor = 1
	if __isWildScreen then  self.kPropListScaleFactor = 0.92 end
	ladybug:setScale(self.kPropListScaleFactor)

	parent.displayLayer[GamePlaySceneTopAreaType.kItemBatch]:addChild(ladybug)
	ladybug:setPosition(ccp(pos.x, pos.y))
	self.ladybug = ladybug

	self.scriptID = -1
  	self.progress = 0

	self.starLevel = 0
	self.star1 = self:createDarkStar("star_1", 1)
  	self.star2 = self:createDarkStar("star_2", 2)
  	self.star3 = self:createDarkStar("star_3", 3)
--  	self.star4 = self:createDarkStar("star_4", 4)
    local container = self.ladybug:getChildByName("star_4")
    container:setVisible(false)

  	self.crown = self.ladybug:getChildByName('crown')

  	self.star1:setAnchorPoint(ccp(0.5, 0.5))
  	self.star2:setAnchorPoint(ccp(0.5, 0.5))
  	self.star3:setAnchorPoint(ccp(0.5, 0.5))

    if self.star4 then
  	    self.star4:setAnchorPoint(ccp(0.5, 0.5))
    end

    if self.crown then
  	    self.crown:setAnchorPoint(ccp(0.5, 0.5))
    end

  	self.isActivity = false --只改了这里。其他跟父类一样

    if self.crown then
  	    self.crown:setVisible(self.isActivity)
    end

  	self:initBg()
  	self:initAnimal()
  	self:initClippingProgress()

  	local pathNode = ladybug:getChildByName("path")
  	local offset = pathNode:getPosition()
  	local path = {}
  	for i,v in ipairs(pathNode.list) do
  		local p = v:getPosition()
  		path[i] = ccp(offset.x + p.x, offset.y + p.y)
  	end
  	pathNode:removeFromParentAndCleanup(true)

  	local spine = CardinalSpline.new(path, 0.25)
  	self.spine = spine

    self.fourStar_shining = self.ladybug:getChildByName('fourstar_shining')
    self.fourStar_shining:setVisible(false)
    self.fourthStar = self.ladybug:getChildByName('fourth_star')
    self.fourthStar:setVisible( false )
    if self.star4 then
    	 self.star4:setVisible( self.showStar4 )
    end
    

 --   self.fourthStar:setVisible( self.showStar4 )


    self.sunshine = self.ladybug:getChildByName('sunshine')
 --   self.sunshine:setVisible( self.showStar4 )
    self.sunshine:setVisible( false )

    self.sunshine:setAnchorPoint(ccp(0.5, 0.5))
    self.fourthStar:setAnchorPoint(ccp(0.5, 0.5))

    self.fourthStar:getChildByName('star_white'):setAnchorPoint(ccp(0.5, 1))
    self.fourthStar:getChildByName('star_normal'):setAnchorPoint(ccp(0.5, 1))

    self.leaf1 = self.ladybug:getChildByName('fourstar_leaves1')
    self.leaf2 = self.ladybug:getChildByName('fourstar_leaves2')
    self.leaf3 = self.ladybug:getChildByName('fourstar_leaves3')

    if self.leaf1 then
        self.leaf1:setVisible( false )
    end

    if self.leaf1 then
        self.leaf2:setVisible( false )
    end

    if self.leaf1 then
        self.leaf3:setVisible( false )
    end

    -- test
    -- local function test()
    --     self:playFourStarAnimation()
    -- end
    -- setTimeOut(test, 5)
end

local function createStarDustAnimation( parent, onAnimationFinished, r_base )
	r_base = r_base or 45
	for i = 1, 15 do	
		local angle = i * kStarFactor
		local r = r_base + math.random() * r_base * 0.25
		local x = 0 + math.cos(angle) * r
		local y = 0 + math.sin(angle) * r
		
		local sprite = nil
		if math.random() > 0.6 then sprite = Sprite:createWithSpriteFrameName("win_star_big0000")
		else sprite = Sprite:createWithSpriteFrameName("win_star_dust0000") end
		sprite:setPosition(ccp(0, 0))
		sprite:setScale(0)
		sprite:setOpacity(0)
		sprite:setRotation(math.random() * 360)

		local spawn = CCArray:create()
		spawn:addObject(CCFadeIn:create(0.1))
		spawn:addObject(CCMoveTo:create(0.2 + math.random() * 0.2, ccp(x, y)))
		spawn:addObject(CCScaleTo:create(0.4, math.random()*0.6 + 0.8))

		local sequence = CCArray:create()
		sequence:addObject(CCSpawn:create(spawn))
		sequence:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(0.3), CCScaleBy:create(0.3, 1)))

		if onAnimationFinished ~= nil then
			sequence:addObject(CCCallFunc:create(onAnimationFinished))
		else
			local function onMoveFinished( ) sprite:removeFromParentAndCleanup(true) end
			sequence:addObject(CCCallFunc:create(onMoveFinished))
		end

		sprite:runAction(CCSequence:create(sequence))
		parent:addChild(sprite)
	end
end


function SummerFishScoreProgressAnimation:showStar( star, starName )
	if not star then return end
	if self[starName] then return end
	
	local position = star:getPosition()
	local pos_ladybug = self.ladybug:getPosition()


    local AnimStartPath = ""
    local AnimNum = 0
    local offsetY = 0
    local offsetX = 0
    if star == self.star1 then
		AnimStartPath = "ladybug_summerfish_star1"
        AnimNum = 11
        offsetY = -22
        offsetX = 5
	elseif star == self.star2 then
		AnimStartPath = "ladybug_summerfish_star1"
        AnimNum = 11
        offsetY = -25
        offsetX = 5
	elseif star == self.star3 then
		AnimStartPath = "ladybug_summerfish_star3"
        AnimNum = 11
        offsetY = -30
        offsetX = 5
	end

	local shiningStars = Sprite:createWithSpriteFrameName( AnimStartPath.."0000" )
	local node = SpriteBatchNode:createWithTexture(shiningStars:getTexture())
	node:setPosition(ccp(position.x * self.kPropListScaleFactor + pos_ladybug.x + offsetX, position.y * self.kPropListScaleFactor + pos_ladybug.y + offsetY))
	-- self.ladybug:addChild(node)
	node:setScale(self.kPropListScaleFactor)
	self.parent.displayLayer[GamePlaySceneTopAreaType.kEffect]:addChild(node)

    shiningStars:setAnchorPoint(ccp(0.5,0.5))
    shiningStars:setScale(1.1)
    shiningStars:runAction(CCRepeat:create(SpriteUtil:buildAnimate(SpriteUtil:buildFrames(AnimStartPath.."%04d", 0, AnimNum), 1/30), 1))
    node:addChild(shiningStars)

    local overlay = Sprite:createWithSpriteFrameName("ladybug_sunshine0000")
    overlay:setAnchorPoint(ccp(0.5,0.5))
    overlay:setOpacity(0)
    overlay:setScale(0.6)
    overlay:runAction(CCRepeatForever:create(CCRotateBy:create(0.5, 120)))
    local fadeIn = CCSpawn:createWithTwoActions(CCFadeTo:create(0.25, 200), CCScaleTo:create(0.25, 2.4))
    local fadeOut = CCSpawn:createWithTwoActions(CCFadeOut:create(0.6), CCScaleTo:create(0.6, 2))
    overlay:runAction(CCSequence:createWithTwoActions(fadeIn, fadeOut))
    node:addChild(overlay)

    self.background:stopAllActions()
    self.background:setRotation(0)
    self.background:runAction(CCRepeat:create(CCSequence:createWithTwoActions(CCRotateBy:create(0.03,-1), CCRotateBy:create(0.03,1)), 2))

    --star dust
	createStarDustAnimation(node)

    self.animal:playStar()

	self[starName] = node

	if star == self.star1 then
		self.starLevel = 1
        self.star1:setVisible(false)
	elseif star == self.star2 then
		self.starLevel = 2
        self.star2:setVisible(false)
	elseif star == self.star3 then
		self.starLevel = 3
        self.star3:setVisible(false)
	end
end


function SummerFishScoreProgressAnimation:updateStarProgress( progress )
	if progress < 0 then progress = 0 end
	if progress > 1 then progress = 1 end
	if self.star1progress ~= nil and self.star2progress ~= nil and self.star3progress ~= nil then
		if progress >= self.star1progress and self.bigstar1 == nil then
			self:showStar(self.star1, "bigstar1")
		end

		if progress >= self.star2progress and self.bigstar2 == nil then
			self:showStar(self.star2, "bigstar2")
		end

		if progress >= self.star3progress and self.bigstar3 == nil then
			self:showStar(self.star3, "bigstar3")
		end
	end
end