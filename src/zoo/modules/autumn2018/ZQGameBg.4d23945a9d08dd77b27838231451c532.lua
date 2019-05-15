
local UIHelper = require 'zoo.panel.UIHelper'

ZQGameBg = class(CocosObject)

local TopPartWidth = 960
local TopPartHeight = 637
local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()

function ZQGameBg:create()
	-- FrameLoader:loadImageWithPlist("flash/autumn2018/mid_autumn_bg.plist")
	UIHelper:loadArmature('skeleton/autumn2018/bg_moon_ani', "bg_moon_ani", "bg_moon_ani")
	UIHelper:loadArmature('skeleton/autumn2018/bg_water_ani', "bg_water_ani", "bg_water_ani")
	local bg = ZQGameBg.new(CCNode:create())
	bg:init()
	return bg
end

function ZQGameBg:init()
	self.scrollBgSpList = {}
	self.aniTable = {}
end

function ZQGameBg:initBg()
	local topSprite = Sprite:createWithSpriteFrameName("autumn_ingame_bg4")
	topSprite:setAnchorPoint(ccp(0.5, 0))
	topSprite:ignoreAnchorPointForPosition(false)
	-- local topSpritePosY = visibleSize.height / 2 - TopPartHeight
	topSprite:setPosition(ccp(0, self.topSpritePosY))
	self:addChild(topSprite)

	local moonAni = ArmatureNode:create("autumn_2018_moon/moon")
	moonAni:update(0.001)
	moonAni:stop()
	topSprite:addChild(moonAni:wrapWithBatchNode())
	moonAni:setPosition(ccp(425, 240))
	moonAni:play("moon")
	table.insert(self.aniTable, moonAni)

	local waterAni = ArmatureNode:create("autumn_2018_water/water")
	waterAni:update(0.001)
	waterAni:stop()
	topSprite:addChild(waterAni:wrapWithBatchNode())
	waterAni:setPosition(ccp(0, 125))
	waterAni:play("water")
	table.insert(self.aniTable, waterAni)

	local bridgeStartPosX = 0 
	for i=1,4 do
		local bgBridge = Sprite:createWithSpriteFrameName("autumn_ingame_bg2")
		bgBridge:setAnchorPoint(ccp(0, 0))
		bgBridge:setPosition(ccp(bridgeStartPosX, 20))
		topSprite:addChild(bgBridge)
		table.insert(self.scrollBgSpList, bgBridge)
		bridgeStartPosX = bridgeStartPosX + TopPartWidth - 1 -- 防止出现缝隙
	end

	local moonLightSp = Sprite:createWithSpriteFrameName("autumn_ingame_bg3")
	moonLightSp:setPosition(ccp(532, 80))
	topSprite:addChild(moonLightSp)

	local frontSp = Sprite:createWithSpriteFrameName("autumn_ingame_bg1")
	frontSp:setAnchorPoint(ccp(0, 0))
	frontSp:ignoreAnchorPointForPosition(false)
	local pos = topSprite:convertToNodeSpace(ccp(visibleOrigin.x, 0))
	frontSp:setPosition(ccp(pos.x, -33))
	topSprite:addChild(frontSp)

	local bottomSprite = Sprite:createWithSpriteFrameName("autumn_ingame_bg5")
	bottomSprite:setAnchorPoint(ccp(0.5, 1))
	bottomSprite:ignoreAnchorPointForPosition(false)
	bottomSprite:setPosition(ccp(0, self.topSpritePosY + 2))
	self:addChild(bottomSprite)
end

function ZQGameBg:doScroll(time, distanceX)
	if self.scrollBgSpList then
		local _distanceX = distanceX / 4
		for _, bgSprite in pairs(self.scrollBgSpList) do
			local pos = bgSprite:getPosition()
			if pos.x < -TopPartWidth then
				bgSprite:setPositionX(pos.x + TopPartWidth * 3 - 2)
			end
			bgSprite:runAction(CCMoveBy:create(time, ccp(_distanceX, 0)))
		end
	end
end

function ZQGameBg:removeAllBgSprites()
	for i, sprite in ipairs(self.scrollBgSpList) do
		sprite:removeFromParentAndCleanup(true)
	end
	self.scrollBgSpList = {}
end

function ZQGameBg:updateGameBgPosition(basePos)
	local topSpritePosY = self:convertToNodeSpace(ccp(0, basePos.y)).y
	local minY = visibleSize.height / 2 - TopPartHeight
	local posY = math.max(minY, topSpritePosY)
	self.topSpritePosY = posY

	self:initBg()

	return self:convertToWorldSpace(ccp(0, posY))
end

function ZQGameBg:dispose()
	for i,v in ipairs(self.aniTable) do
		v:stop()
		v:removeAllEventListeners()
		v:removeFromParentAndCleanup(true)
	end
	self.aniTable = nil

	-- FrameLoader:unloadImageWithPlists({"flash/autumn2018/mid_autumn_bg.plist"})
	UIHelper:unloadArmature('skeleton/autumn2018/bg_moon_ani', true)
	UIHelper:unloadArmature('skeleton/autumn2018/bg_water_ani', true)
	CocosObject.dispose(self)
end
