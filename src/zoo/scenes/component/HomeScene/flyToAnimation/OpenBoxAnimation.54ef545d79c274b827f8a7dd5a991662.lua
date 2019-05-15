require 'hecore.ui.PopoutManager'
require 'hecore.display.ArmatureNode'

local screen_size = Director:sharedDirector():getVisibleSize()
local screen_width = screen_size.width
local screen_height = screen_size.height

local function getPos(index, total)
	local row = math.ceil(total / 4)
	local numPerRow = math.floor(total / row)
	local rest = total - numPerRow*row
	local r1 = row - rest
	local r2 = rest
	local r = 1
	local c = 1
	if index > r1 * numPerRow then
		r = math.ceil((index - r1 * numPerRow)/(numPerRow+1)) + r1
		c = index - r1 * numPerRow-(r-r1-1)*(numPerRow+1)
	else
		r = math.ceil(index/numPerRow)
		c = index - (r-1)*(numPerRow)
	end
	local x, y = 0, 0
	if r > r1 then
		x = screen_width/2 + (c - (numPerRow+2)/2) * 150
	else
		x = screen_width/2 + (c - (numPerRow+1)/2) * 150
	end
	y = screen_height*3/5 - (r - (row+1)/2) * 128
	return ccp(x, y)
end

local function getDelay(index, total)
	return 0.5 + 0.1*(total - index)
end

GoodsFlyingAnimation = class(BasePanel)

-- specialItemsConfig = {
-- 	[itemId] = {
-- 		frameName = '', targetPos = ccp(0, 0)
-- 	}	
-- }

function GoodsFlyingAnimation:create(rewards, index, total, specialItemsConfig, showNum)
	local instance = GoodsFlyingAnimation.new()
	instance:init(rewards, index, total, specialItemsConfig, showNum)
	return instance
end

function GoodsFlyingAnimation:dispose()
	BasePanel.dispose(self)
end

function GoodsFlyingAnimation:init(rewards, index, total, specialItemsConfig, showNum)
	if specialItemsConfig == nil then
		specialItemsConfig = {}
	end

	local ui = Layer:create()
	self.ui = ui
	BasePanel.init(self, ui)

	local itemId = rewards[1].itemId
	if ItemType:isTimeProp(itemId) then
		itemId = ItemType:getRealIdByTimePropId(itemId)
	end

	local sprite 
	if specialItemsConfig[itemId] then
		if specialItemsConfig[itemId].frameName then
			sprite = Sprite:createWithSpriteFrameName(specialItemsConfig[itemId].frameName)
		else
			sprite = ResourceManager:sharedInstance():buildItemSprite(itemId)
		end
		sprite:setAnchorPoint(ccp(0, 1))
	else
		sprite = ResourceManager:sharedInstance():buildItemSprite(itemId)
	end
	
	local halo = Sprite:createWithSpriteFrameName('openbox_halo0000')

	self.sprite = sprite
	self.halo = halo

	self.ui:addChild(halo)
	self.ui:addChild(sprite)

	local spriteSize = sprite:getGroupBounds().size
	local spritePos = sprite:getPosition()
	sprite:setPositionX(spritePos.x - spriteSize.width/2)
	sprite:setPositionY(spritePos.y + spriteSize.height/2)
	halo:setAnchorPoint(ccp(0.5, 0.5))
	self.ui:setVisible(false)

	self.pos1 = ccp(screen_width/2+math.random(32)-16, -screen_height*2/5+math.random(32)-16)
	self.worldPos2 = getPos(index, total)
	self.localPos2 = ccp(self.worldPos2.x, self.worldPos2.y - screen_height)

	self.flyDelay = getDelay(index, total)

	if specialItemsConfig[itemId] then
		require "zoo.scenes.component.HomeScene.flyToAnimation.FlySpecialItemAnimation"
		self.flyAnim = FlySpecialItemAnimation:create(rewards[1], 
			specialItemsConfig[itemId].frameName, 
			specialItemsConfig[itemId].targetPos
		)
		self.flyAnim:setWorldPosition(ccp(self.worldPos2.x, self.worldPos2.y))
	else
		self.flyAnim = FlyItemsAnimation:create(rewards)
		self.flyAnim:setWorldPosition(ccp(self.worldPos2.x, self.worldPos2.y))
	end

	if showNum == true then
		local num = BitmapText:create('x' .. tonumber(rewards[1].num), "fnt/event_default_digits.fnt")
		sprite:addChild(num)
		num:setPositionX(100)
	end
end

function GoodsFlyingAnimation:move(cb)
	self.ui:setPosition(self.pos1)
	local waitBox = CCDelayTime:create(0.7)
	local show = CCCallFunc:create(
		function ()
			self.ui:setVisible(true)
		end
	)
	local moveTo = CCMoveTo:create(0.3, self.localPos2)

	local waitToFly = CCDelayTime:create(self.flyDelay)

	local finish = CCCallFunc:create(
		function()
			self.ui:setVisible(false)
			if cb then
				cb()
			end
		end
	)
	local array = CCArray:create()
	array:addObject(waitBox)
	array:addObject(show)
	array:addObject(moveTo)
	array:addObject(waitToFly)
	array:addObject(finish)
	local seq = CCSequence:create(array)
	self.ui:runAction(seq)
end

function GoodsFlyingAnimation:play(onFlyFinished)
	if onFlyFinished then
		self.flyAnim:setFinishCallback(onFlyFinished)
	end
	local function __fly()
		self:fly()
	end
	self:move(__fly)
end

function GoodsFlyingAnimation:fly()
	self.flyAnim:play()
end

BoxOpeningAnimation = class(BasePanel)

function BoxOpeningAnimation:create(boxRes)
	local instance = BoxOpeningAnimation.new()
	FrameLoader:loadArmature("skeleton/openbox_animation")
	instance:init(boxRes)
	return instance
end

function BoxOpeningAnimation:dispose()
	BasePanel.dispose(self)
	-- ArmatureFactory:remove('openbox_animation', 'openbox_animation')
	FrameLoader:unloadArmature('skeleton/openbox_animation', true)
end

function BoxOpeningAnimation:init(boxRes)
	local ui = Layer:create()
	self.ui = ui
	BasePanel.init(self, ui)

	self.boxRes = boxRes

	local node = ArmatureNode:create("box2")
	self.box2 = node
	self.ui:addChild(node)
	self.box2:setAnchorPoint(ccp(0.5, 0.5))
	self.box2:setPositionXY(screen_width/2, -screen_height*2/5)

	if boxRes then
		local slot = self.box2:getSlot('bg')
		boxRes:setAnchorPoint(ccp(0.5, 0.5))
		slot:setDisplayImage(boxRes)
	end
end

function BoxOpeningAnimation:play()
	self.box2:playByIndex(0)
end


OpenBoxAnimation = class(BasePanel)

function OpenBoxAnimation:create(rewards, boxRes, specialItemsConfig, showNum)
	local instance = OpenBoxAnimation.new()
	instance:loadRequiredResource("ui/openbox.json")
	instance:init(rewards, boxRes, specialItemsConfig, showNum)
	return instance
end

function OpenBoxAnimation:init(rewards, boxRes, specialItemsConfig, showNum)
	local ui = Layer:create()
	self.ui = ui
	BasePanel.init(self, ui)

	self.boxOpening = BoxOpeningAnimation:create(boxRes)
	self.ui:addChild(self.boxOpening)

	self.goodsFlying = {}

	for i = 1, #rewards do
		self.goodsFlying[i] = GoodsFlyingAnimation:create({rewards[i]}, i, #rewards, specialItemsConfig, showNum)
		self.ui:addChild(self.goodsFlying[i])
	end
end

function OpenBoxAnimation:close()
	PopoutManager:remove(self, true)
end

function OpenBoxAnimation:play()
	PopoutManager:add(self, true, false)

	local counter = 0
	local function __finish()
		counter = counter + 1
		if counter >= #self.goodsFlying then
			self:close()
			if self.finishCallback then
		 		self.finishCallback()
			end
		end
	end
	self.boxOpening:play()
	for i=1, #self.goodsFlying do
		self.goodsFlying[i]:play(__finish)
	end

	return self
end

function OpenBoxAnimation:setFinishCallback( finishCallback )
	self.finishCallback = finishCallback
	return self
end