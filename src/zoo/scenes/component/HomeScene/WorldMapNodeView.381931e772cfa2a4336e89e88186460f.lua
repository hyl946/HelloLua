
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年08月22日 10:55:38
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.panel.StartGamePanel"
require "hecore.ui.PopoutManager"
require "zoo.animation.Flowers"

---------------------------------------------------
-------------- WorldMapNodeView
---------------------------------------------------

assert(not WorldMapNodeViewEvents)

WorldMapNodeViewEvents = 
{
	-- When self.star Changed To 0 From -1
	FLOWER_OPENED_WITH_NO_STAR	= "WorldMapNodeViewEvents.FLOWER_OPENED_WITH_NO_STAR",

	-- When self.star Changed Frome 0 To 1,2,3,4
	FIRST_OPENED_WITH_STAR		= "WorldMapNodeViewEvents.FIRST_OPENED_WITH_STAR",

	-- When User Replay This Level And Get A New Star Level
	OPENED_WITH_NEW_STAR		= "WorldMapNodeViewEvents.OPENED_WITH_NEW_STAR",

	OPENED_WITH_JUMP				= "WorldMapNodeViewEvents.OPENED_WITH_JUMP",
}


assert(not WorldMapNodeView)
assert(BaseUI)

WorldMapNodeView = class(CocosObject)

function WorldMapNodeView:ctor(...)
	assert(#{...} == 0)
end

function WorldMapNodeView:init(isNormalFlower, levelId, playAnimLayer, bmFontBatchLayer, texture, ...)
	assert(isNormalFlower ~= nil)
	assert(type(isNormalFlower) == "boolean")
	assert(levelId)
	assert(playAnimLayer)
	assert(bmFontBatchLayer)
	assert(#{...} == 0)

	local sprite = CCSprite:create()
	self:setRefCocosObj(sprite)

	-- ----------------------------------------
	-- Set Texture For Used In CCSpriteBatchNode
	--------------------------------------------
	self.refCocosObj:setTexture(texture)

	-- Resource
	self.resourceManager	= ResourceManager:sharedInstance()

	---------------
	---- Data 
	----------------
	self.playAnimLayer	= playAnimLayer
	self.bmFontBatchLayer	= bmFontBatchLayer
	self.firstOpenWithStar	= nil
	self.isNormalFlower	= isNormalFlower
	self.levelId		= levelId
	self.levelDisplayName = tostring(LevelMapManager.getInstance():getLevelDisplayName(self.levelId))
	self.isJumpLevel = false
	self.isAskForHelp = false
	self.oldStar		= false
	self.star		= false
	self:setStar(-1, 0, false, false, false)

	self.childrenAddedToAnimLayer = {}

	self.flowerRes = false

	-- 删除节点时用来记录的变量
	self.levelIdLabel = nil
	self.shadowGlow = nil
	self.glowSprite = nil
end

function WorldMapNodeView:dispose()
	if self.levelIdLabel and not self.levelIdLabel.isDisposed then
		self.levelIdLabel:removeFromParentAndCleanup(true)
	end
	if self.shadowGlow and not self.shadowGlow.isDisposed then
		self.shadowGlow:removeFromParentAndCleanup(true)
	end
	if self.glowSprite and not self.glowSprite.isDisposed then
		self.glowSprite:removeFromParentAndCleanup(true)
	end

	CocosObject.dispose(self)
end


function WorldMapNodeView:setStar(star, ingredientCount, updateView, playAnimInLogic, animFinishCallback, ...)
	assert(type(star) == "number")
	assert(type(updateView) == "boolean")
	assert(type(playAnimInLogic) == "boolean")
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)
	
	assert(star >= -1)
	assert(star <= 4)

	if ingredientCount and ingredientCount > 0 then
		self.isJumpLevel = true
	else
		self.isJumpLevel = false
	end

	self.isAskForHelp = UserManager:getInstance():hasAskForHelpInfo(self:getLevelId())

	if self.star ~= star or self.isJumpLevel == true or self.isAskForHelp == true then
		self.oldStar 	= self.star
		self.star 		= star

		if not self.isNormalFlower and self.star >= 0 then
			MetaModel:sharedInstance():onOpenHiddenLevel(self.levelId)
		end

		if updateView then
			self:updateView(playAnimInLogic, animFinishCallback)
		else
			if animFinishCallback then
				animFinishCallback()
			end
		end
	else
		if animFinishCallback then
			animFinishCallback()
		end
	end
end

function WorldMapNodeView:getStar(...)
	assert(#{...} == 0)

	return self.star
end

function WorldMapNodeView:getFlowerRes(...)
	assert(#{...} == 0)

	return self.flowerRes
end

function WorldMapNodeView:getLevelId(...)
	assert(#{...} == 0)

	return self.levelId
end

function WorldMapNodeView:addChildToPlayAnimLayer(sprite, ...)
	assert(#{...} == 0)

	table.insert(self.childrenAddedToAnimLayer, sprite)

	local selfPosInPlayAnimLayer = self:getSelfPositionInPlayAnimLayer()

	local manualAdjustX = 3
	local manualAdjustY = 0

	sprite:setPosition(ccp(selfPosInPlayAnimLayer.x + manualAdjustX, selfPosInPlayAnimLayer.y + manualAdjustY))
	self.playAnimLayer:addChild(sprite)
end

function WorldMapNodeView:addLevelLabel(...)
	assert(#{...} == 0)

	if not self.isLevelLabelAdded then
		self.isLevelLabelAdded = true

		local selfPosInPlayAnimLayer = self:getSelfPositionInPlayAnimLayer()
		self.manualAdjustLabelPosX	= 0
		self.manualAdjustLabelPosY = -38
		
		local manualAdjustX = self.manualAdjustLabelPosX
		local manualAdjustY = self.manualAdjustLabelPosY

		self.levelIdLabel = self.bmFontBatchLayer:createLabel(self.levelDisplayName)
		self.levelIdLabel:setAnchorPoint(ccp(0.5, 0))

		self.levelIdLabel:setPosition(ccp(selfPosInPlayAnimLayer.x + manualAdjustX, selfPosInPlayAnimLayer.y + manualAdjustY ))
		self.bmFontBatchLayer:addChild(self.levelIdLabel)
	end
end

function WorldMapNodeView:cleanChildrenAddedToAnimLayer(...)
	assert(#{...} == 0)

	for k,v in ipairs(self.childrenAddedToAnimLayer) do
		v:removeFromParentAndCleanup(true)
	end

	self.childrenAddedToAnimLayer = {}
end

function WorldMapNodeView:updateView(playAnimInLogic, animFinishCallback, ...)
	assert(playAnimInLogic ~= nil)
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)
	-- Clean
	self:removeChildren(true)
	self.actCollectionIcon = nil
	self.flowerRes = false
	self:cleanChildrenAddedToAnimLayer()
	
	-----------------------------------
	------ Play Animation And 
	------- Create Display
	-----------------------------------
	if self.star == -1 then
		-- Flower Closed
		-- When User Not Reached This Level
		local flower = Sprite:createWithSpriteFrameName(kFlowers.flowerSeed.."0000")
		flower:setAnchorPoint(ccp(0.5, 1))
		self.flowerRes = flower
		self:addChild(flower)
	elseif self.star == 0 then
		-- Flower Open
		-- When User Stand On This Level , But Not Pass This Level
		if self.isJumpLevel then
			if playAnimInLogic then
				self:buildJumpedFlower()
				self:playJumpLevelFlowerAnimation(5, animFinishCallback)
			else
				self:buildJumpedFlower()
			end
		elseif self.isAskForHelp then		
			if playAnimInLogic then
				self:buildAskForHelpFlower()
				self:playAskForHelpFlowerAnimation(5, animFinishCallback)
			else
				self:buildAskForHelpFlower()
			end
		else
			if playAnimInLogic then
				self:playFlowerOpenAnimation(animFinishCallback)
			else
				self:buildOpenedFlower()
			end
		end
	elseif self.star >= 1 or  self.star <= 4 then
		-- Flower Has Star
		-- After User Finish This Level

		self.firstOpenWithStar = false

		if not self.firstEnterThere then
			self.firstEnterThere = true

			self.firstOpenWithStar = true
		end

		if playAnimInLogic then
			self:playFlowerOpenWithStarAnimation(animFinishCallback)
		else
			self:flowerOpenWithStar()
		end
	else
		assert(false)
	end

	--------------------
	--- Label
	-------------------
	
	self:addLevelLabel()
end

function WorldMapNodeView:playParticle()
	local particles = ParticleSystemQuad:create("particle/flower_glow.plist")
	particles:setAutoRemoveOnFinish(true)
	particles:setPosition(ccp(self:getPositionX(), self:getPositionY() - 70))
	self.playAnimLayer:addChild(particles)

	local arr = CCArray:create()
    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, -18)))
    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, 15)))
    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, -12)))
    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, 9)))
    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, -4)))
    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, 2)))
    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
    self:runAction(CCSequence:create(arr))
end

-------------------------------------------------
-------- Flower Open With No Star
-------- That's self.star = 0
-------------------------------------------------

function WorldMapNodeView:getSelfPositionInPlayAnimLayer(...)
	assert(#{...} == 0)

	-- Convert Self Position To self.playAnimLayer's Space
	local parent = self:getParent()
	assert(parent)
	local selfPos	= self:getPosition()
	local toWorldPos = parent:convertToWorldSpace(ccp(selfPos.x, selfPos.y))
	local toPlayAnimLayerPos = self.playAnimLayer:convertToNodeSpace(ccp(toWorldPos.x, toWorldPos.y))
	
	return toPlayAnimLayerPos
end

function WorldMapNodeView:playFlowerOpenAnimation(animFinishCallback, ...)
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)
	
	local glowAnimation = Flowers:buildGlowEffect(kFlowers.flowerStar0)
	self:addChildToPlayAnimLayer(glowAnimation)

	local function onAnimFinished()

		glowAnimation:removeFromParentAndCleanup(true)

		-- Use The Static Picture To Replace Animation
		self:buildOpenedFlower()

		if animFinishCallback then
			animFinishCallback()
		end

		self:dispatchEvent(Event.new(WorldMapNodeViewEvents.FLOWER_OPENED_WITH_NO_STAR, self.levelId))
	end
	glowAnimation:addEventListener(Events.kComplete, onAnimFinished)

	-- Play THe Anim
	glowAnimation:bloom()
end

function WorldMapNodeView:buildJumpedFlower()
	local flower = Sprite:createWithSpriteFrameName(kFlowers.jumpedFlower.."0000")
	flower:setAnchorPoint(ccp(0.5, 0.9))

	self.flowerRes = flower
	self:addChild(flower)
end

function WorldMapNodeView:playJumpLevelFlowerAnimation(count, callback)

	self.isJumpLevel = true
	local function changeToJumpedFlower()
		if self.flowerRes and self.flowerRes:getParent() then
			self.flowerRes:removeFromParentAndCleanup(true)
			self.flowerRes = nil
			self:buildJumpedFlower()
			local arr = CCArray:create()
			arr:addObject(CCScaleTo:create(0.1, 1.4))
			arr:addObject(CCScaleTo:create(0.1, 1))
			self.flowerRes:runAction(CCSequence:create(arr))
			local destPos = HomeScene:sharedInstance():convertToNodeSpace(self.flowerRes:getParent():convertToWorldSpace(self.flowerRes:getPosition()))
			destPos = ccp(destPos.x, destPos.y - 70 + kFlowerShineCircleAdjust.y)
			local shine = Sprite:createWithSpriteFrameName("flowerShineCircle0000")
			shine:setAnchorPoint(ccp(0.5, 0.5))
			HomeScene:sharedInstance():addChild(shine)
			shine:setPosition(destPos)
			shine:setOpacity(0)
			local arr2 = CCArray:create()
			arr2:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.3, 1.5), CCFadeTo:create(0.1, 230)))
			arr2:addObject(CCFadeOut:create(0.1))
			arr2:addObject(CCCallFunc:create(
				function () 
					if shine then 
						shine:removeFromParentAndCleanup(true) 
					end 
					if callback then callback() end
					self:dispatchEvent(Event.new(WorldMapNodeViewEvents.OPENED_WITH_JUMP, self.levelId))
				end))
			shine:runAction(CCSequence:create(arr2))
		else 
			if callback then callback() end
		end
	end	
	self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.3), CCCallFunc:create(changeToJumpedFlower)))
	self:playParticle()
end

----------------------------------------------------------------------
function WorldMapNodeView:buildAskForHelpFlower()
	local flower = Sprite:createWithSpriteFrameName(kFlowers.askForHelpFlower.."0000")
	flower:setAnchorPoint(ccp(0.5, 0.9))

	self.flowerRes = flower
	self:addChild(flower)
end

function WorldMapNodeView:playAskForHelpFlowerAnimation(count, callback)
	self.isAskForHelp = true
	local function changeToAskForHelpFlower()
		if self.flowerRes and self.flowerRes:getParent() then
			self.flowerRes:removeFromParentAndCleanup(true)
			self.flowerRes = nil
			self:buildAskForHelpFlower()
			local arr = CCArray:create()
			arr:addObject(CCScaleTo:create(0.1, 1.4))
			arr:addObject(CCScaleTo:create(0.1, 1))
			self.flowerRes:runAction(CCSequence:create(arr))
			local destPos = HomeScene:sharedInstance():convertToNodeSpace(self.flowerRes:getParent():convertToWorldSpace(self.flowerRes:getPosition()))
			destPos = ccp(destPos.x, destPos.y - 70 + kFlowerShineCircleAdjust.y)
			local shine = Sprite:createWithSpriteFrameName("flowerShineCircle0000")
			shine:setAnchorPoint(ccp(0.5, 0.5))
			HomeScene:sharedInstance():addChild(shine)
			shine:setPosition(destPos)
			shine:setOpacity(0)
			local arr2 = CCArray:create()
			arr2:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.3, 1.5), CCFadeTo:create(0.1, 230)))
			arr2:addObject(CCFadeOut:create(0.1))
			arr2:addObject(CCCallFunc:create(
				function () 
					if shine then 
						shine:removeFromParentAndCleanup(true) 
					end 
					if callback then callback() end
					self:dispatchEvent(Event.new(WorldMapNodeViewEvents.OPENED_WITH_JUMP, self.levelId))
				end))
			shine:runAction(CCSequence:create(arr2))
		else 
			if callback then callback() end
		end
	end	
	self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.3), CCCallFunc:create(changeToAskForHelpFlower)))
	self:playParticle()
end
---------------------------------------------------------------------
function WorldMapNodeView:buildOpenedFlower(...)
	assert(#{...} == 0)

	local selfPosInPlayAnimLayer = self:getSelfPositionInPlayAnimLayer()
	local flower = nil
	-- if self.isNormalFlower then
		flower = Sprite:createWithSpriteFrameName(kFlowers.flowerStar0.."0000")
	-- else -- 只在春节素材期间有！！！！！！
	-- 	flower = Sprite:createWithSpriteFrameName("hiddenFlowerAnim00000")
	-- end
	-- local flower = Sprite:createWithSpriteFrameName(kFlowers.flowerStar0.."0000")
	flower:setAnchorPoint(ccp(0.5, 1))

	assert(flower)
	self.flowerRes = flower
	self:addChild(flower)

	-------------------
	----- Background Animation
	--------------------------
	self.shadowGlow = Sprite:createWithSpriteFrameName("flowerShineCircle0000")
	self.shadowGlow:setVisible(false)
	
	self.glowSprite = Sprite:createWithSpriteFrameName("flowerShineCircle0000")

	local animationTime = 1
	local breatheLamp = CCArray:create()
	breatheLamp:addObject(CCScaleTo:create(animationTime, 1.15, 1)) 
	breatheLamp:addObject(CCDelayTime:create(0.3))
	breatheLamp:addObject(CCScaleTo:create(animationTime, 0.85, 0.7 )) 
	local seq = self.glowSprite:runAction(CCSequence:create(breatheLamp))


	self:addChildToPlayAnimLayer(self.shadowGlow)
	self:addChildToPlayAnimLayer(self.glowSprite)

	-- -----------------------------------------------
	-- Adjust Position After Added To Animation Layer
	-- ---------------------------------------------------
	local flowerSize = flower:getContentSize()
	
	local manualAdjustY = -20
	local manualAdjustX = -3

	-- Adjust Shadow Glow Pos
	local curPosX	= self.shadowGlow:getPositionX()
	local curPosY	= self.shadowGlow:getPositionY()
	local newPosX	= curPosX + manualAdjustX
	local newPosY	= curPosY - flowerSize.height / 2 + manualAdjustY + kFlowerShineCircleAdjust.y
	self.shadowGlow:setPosition(ccp(newPosX, newPosY))

	-- Adjust Glow Sprite Pos
	local curPosX = self.glowSprite:getPositionX()
	local curPosY = self.glowSprite:getPositionY()
	local newPosX = curPosX + manualAdjustX
	local newPosY = curPosY - flowerSize.height / 2 + manualAdjustY + kFlowerShineCircleAdjust.y
	self.glowSprite:setPosition(ccp(newPosX, newPosY))

	self.glowSprite:runAction(CCRepeatForever:create(seq))
end

--------------------------------------------------------
-------- Flower Open With Star
-------- That's self.star >= 1
----------------------------------------------------

function WorldMapNodeView:flowerOpenWithStar(...)
	assert(#{...} == 0)

	assert(self.star >=1 and self.star <=4)

	local flowerWithStar = false

	if self.isNormalFlower then
		flowerWithStar = Sprite:createWithSpriteFrameName(kFlowers["flowerStar"..self.star].."0000")
	else
		flowerWithStar = Sprite:createWithSpriteFrameName(kFlowers["hiddenFlower"..self.star].. "0000")
	end

	flowerWithStar:setAnchorPoint(ccp(0.5, 1))
	assert(flowerWithStar)
	self.flowerRes = flowerWithStar
	self:addChild(flowerWithStar)
	self:buildStar()
end

function WorldMapNodeView:playFlowerOpenWithStarAnimation(animFinishCallback, ...)
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)
	
	local glowAnimation = false

	if self.isNormalFlower then
		glowAnimation = Flowers:buildGlowEffect(kFlowers["flowerStar" .. self.star])
	else
		glowAnimation = Flowers:buildGlowEffect(kFlowers["hiddenFlower".. self.star])
	end

	self:addChildToPlayAnimLayer(glowAnimation)

	local function onAnimFinished()
		glowAnimation:removeFromParentAndCleanup(true)
		self:flowerOpenWithStar()

		self:playFlyingTopStarAni() 

		if animFinishCallback then
			animFinishCallback()
		end

		if self.firstOpenWithStar then
			self.firstOpenWithStar = false
			self:dispatchEvent(Event.new(WorldMapNodeViewEvents.FIRST_OPENED_WITH_STAR, self.levelId))
		end

		self:dispatchEvent(Event.new(WorldMapNodeViewEvents.OPENED_WITH_NEW_STAR, self.levelId))
	end

	glowAnimation:addEventListener(Events.kComplete, onAnimFinished)
	glowAnimation:bloom()
end

function WorldMapNodeView:playFlyingNewStarAnim()
	if not self.oldStar then self.oldStar = 0 end

	if self.oldStar >= 0 and self.oldStar <= 3 and self.oldStar ~= self.star then
		local flyStar = FlyStarAnimation:create(self.star - self.oldStar)
		local bounds = self:getGroupBounds()
		flyStar:setWorldPosition(ccp(bounds:getMidX(),bounds:getMinY()))
		flyStar:setFinishCallback(function ( ... )
			local homeScene = HomeScene:sharedInstance()
			if homeScene and homeScene.starButton and (not homeScene.starButton.isDisposed) then
				homeScene.starButton:updateView()
			end
		end)
		flyStar:play()
	end
end

function WorldMapNodeView:playFlyingTopStarAni()
	if not self.oldStar then self.oldStar = 0 end
	if self.oldStar >= 0 and self.oldStar <= 3 and self.oldStar ~= self.star then
		local starsWorldPos = {}
		for i=self.oldStar + 1, self.star do
			local star = self.stars[i]
			if star then 
				local starWordlPos = star:getParent():convertToWorldSpace(star:getPosition())
				table.insert(starsWorldPos, starWordlPos)
			else
				table.insert(starsWorldPos, ccp(0, 0))
			end
		end
		flyStarAni = FlyTopStarAni:create(self.star - self.oldStar, starsWorldPos)
		flyStarAni:play()
	end
end
---------------------------------------
---- Build Star
----------------------------------
function WorldMapNodeView:buildStar(...)
	assert(#{...} == 0)

	local stars = {}
	self.stars = stars
	--是否显示空的四星
	local hasEmptyStar4 = MetaModel:sharedInstance():shouldShowEmptyStar4( self.levelId ,self.star  )
	local leftMostX	= -(self.star * 22) / 2 + 10
	if hasEmptyStar4 then
		leftMostX = -( 4 * 22) / 2 + 10
	end
	self.starContainerPosY	= -138
	local starWidthPadding 	= 0
	local starSpriteFrameName = nil

	if self.isNormalFlower then
		starSpriteFrameName = "flowerStar"
	else
		starSpriteFrameName = "hiddenFlowerStar"
	end
	for index = 1, 4  do
		if self.star >= index or hasEmptyStar4 then
			local runningScene = Director:getRunningScene()
			local star  
			if hasEmptyStar4 and  index ==4 then
				star = Sprite:createWithSpriteFrameName(starSpriteFrameName .. 0 .. "0000")
				self.starContainerPosY = self.starContainerPosY - 2
				leftMostX = leftMostX + 2 
			else
				star = Sprite:createWithSpriteFrameName(starSpriteFrameName .. index .. "0000")
			end

			assert(star)

			star:setPositionX(leftMostX)
			star:setPositionY(self.starContainerPosY)

			local starWidth = star:getGroupBounds(self).size.width
			leftMostX = leftMostX + starWidth + starWidthPadding

			stars[#stars + 1] = star
			self:addChild(star)
		end
	end

end

function WorldMapNodeView:create(isNormalFlower, levelId, playAnimLayer, bmFontBatchLayer, texture, ...)
	assert(isNormalFlower ~= nil)
	assert(type(isNormalFlower) == "boolean")
	assert(levelId)
	assert(playAnimLayer)
	assert(bmFontBatchLayer)
	assert(#{...} == 0)

	local newWorldMapNodeView = WorldMapNodeView.new()
	newWorldMapNodeView:init(isNormalFlower, levelId, playAnimLayer, bmFontBatchLayer, texture)
	return newWorldMapNodeView
end

function WorldMapNodeView:getAnimationCenter()
	local pos = self:getPosition()
	return ccp(pos.x, pos.y - 80)
end