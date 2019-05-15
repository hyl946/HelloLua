---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-08-01 18:47:32
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2016-08-08 22:03:47
---------------------------------------------------------------------------------------
OlympicGameBg = class(SpriteBatchNode)

local loopBGWidth = 1125
local loopBGHeight = 394

function OlympicGameBg:create()
	FrameLoader:loadImageWithPlist("flash/olympic/game_bg_olympic.plist")
	local texture = Sprite:createWithSpriteFrameName("olympic_game_bg_bottom"):getTexture()
	local bg = OlympicGameBg.new(CCSpriteBatchNode:createWithTexture(texture))
	bg:init()
	return bg
end

function OlympicGameBg:init()
	self.bgSpriteList = {}
	
	self:addGameBgSprites()
end

function OlympicGameBg:buildGameBg()
	local sprite = Sprite:createEmpty()
	local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local bottomSprite = Sprite:createWithSpriteFrameName("olympic_game_bg_bottom")
	local size = bottomSprite:getContentSize()
	if not self.bottomSpritePosY then self.bottomSpritePosY = (size.height - visibleSize.height) / 2 end
	bottomSprite:setPosition(ccp(0, self.bottomSpritePosY)) -- (1280 - 916) / 2
	sprite:addChild(bottomSprite)

	local topSprite = Sprite:createWithSpriteFrameName("olympic_game_bg_top")
	topSprite:setAnchorPoint(ccp(0.5, 0))
	topSprite:ignoreAnchorPointForPosition(false)
	local topSize = topSprite:getContentSize()

	if not self.topSpritePosY then self.topSpritePosY = visibleSize.height / 2 - topSize.height end
	topSprite:setPosition(ccp(0, self.topSpritePosY))
	sprite:addChild(topSprite)

	if not self.topSpriteHeight then self.topSpriteHeight = topSize.height end
	if not self.topSpriteWidth then self.topSpriteWidth = topSize.width end
	if not self.minPositionX then self.minPositionX = -topSize.width end

	sprite:setTexture(topSprite:getTexture())
	return sprite
end

function OlympicGameBg:buildGameBgBottom()
	local sprite = Sprite:createEmpty()
	local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local bottomSprite = Sprite:createWithSpriteFrameName("olympic_game_bg_bottom")
	local size = bottomSprite:getContentSize()
	if not self.bottomSpritePosY then self.bottomSpritePosY = (size.height - visibleSize.height) / 2 end
	bottomSprite:setPosition(ccp(0, self.bottomSpritePosY + 0)) -- (1280 - 916) / 2
	return bottomSprite
end

function OlympicGameBg:buildGameBgTop()
	local sprite = Sprite:createEmpty()
	local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()

	local topSprite = Sprite:createWithSpriteFrameName("olympic_game_bg_top")
	topSprite:setAnchorPoint(ccp(0.5, 0))
	topSprite:ignoreAnchorPointForPosition(false)
	local topSize = topSprite:getContentSize()

	if not self.topSpritePosY then self.topSpritePosY = visibleSize.height / 2 - topSize.height end
	topSprite:setPosition(ccp(0, self.topSpritePosY + 0))
	--sprite:addChild(topSprite)

	if not self.topSpriteHeight then self.topSpriteHeight = topSize.height end
	if not self.topSpriteWidth then self.topSpriteWidth = topSize.width end
	if not self.minPositionX then self.minPositionX = -topSize.width end

	return topSprite
end

function OlympicGameBg:doScroll(time, distanceX)
	if self.bgSpriteList then
		for _, bgSprite in pairs(self.bgSpriteList) do
			local pos = bgSprite:getPosition()
			if pos.x < self.minPositionX then
				bgSprite:setPositionX(pos.x + loopBGWidth * 3 - 2)
			end
			bgSprite:runAction(CCMoveBy:create(time, ccp(distanceX, 0)))
		end
	end
end

function OlympicGameBg:addGameBgSprites()

	--[[
	local posX = 0
	for i = 1, 4 do
		local gameBgSprite = self:buildGameBg()
		gameBgSprite:setPositionX(posX)
		self:addChild(gameBgSprite)
		table.insert(self.bgSpriteList, gameBgSprite)
		posX = posX + loopBGWidth - 2 -- 防止出现缝隙
	end
	]]

	local gameBgSprite = self:buildGameBgBottom()
	gameBgSprite:setPositionX(posX)
	self:addChild(gameBgSprite)



	local posX = 0
	for i = 1, 4 do
		local gameBgSprite = self:buildGameBgTop()
		gameBgSprite:setPositionX(posX)
		self:addChild(gameBgSprite)
		table.insert(self.bgSpriteList, gameBgSprite)
		posX = posX + loopBGWidth - 2 -- 防止出现缝隙
	end


end

function OlympicGameBg:removeAllBgSprites()
	for i, sprite in ipairs(self.bgSpriteList) do
		sprite:removeFromParentAndCleanup(true)
	end
	self.bgSpriteList = {}
end

function OlympicGameBg:updateGameBgPosition(basePos)
	local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()

	local topSpritePosY = self:convertToNodeSpace(ccp(0, basePos.y)).y
	local minY = visibleSize.height / 2 - self.topSpriteHeight
	local posY = math.max(minY, topSpritePosY)
	self.topSpritePosY = posY

	self:removeAllBgSprites()
	self:addGameBgSprites()

	return self:convertToWorldSpace(ccp(0, posY))
end

function OlympicGameBg:runScroll()

end

function OlympicGameBg:dispose()
	CocosObject.dispose(self)
	FrameLoader:unloadImageWithPlists({"flash/olympic/game_bg_olympic.plist"})
end