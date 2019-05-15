TileTransDoor = class(CocosObject)

local kCharacterAnimationTime = 1/30
local colorList = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"}
local function createAnimation(sprite, sprite_name, frameNum, animationTime, finishCallback)
	local frames = SpriteUtil:buildFrames(sprite_name, 0, frameNum)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	sprite:play(animate, 0, animationTime, finishCallback)
end

function TileTransDoor:create(color, transType, transDirection)
	-- body
	local node = TileTransDoor.new(CCNode:create())
	node:setRotation(rotation)
	node:initData(color, transType, transDirection)
	node:initView(transType)
	return node
end

function TileTransDoor:initData(color, transType, transDirection)
	self.color = colorList[color]
	self.rotation = (transDirection -1) * 90
	if transType == TransmissionType.kStart then
		self.position = ccp(-GamePlayConfig_Tile_Width/2 + 10, 0)
	else
		self.position = ccp(GamePlayConfig_Tile_Width/2 - 15, 0)
	end
end

function TileTransDoor:initView(transType)
	local door
	if transType == TransmissionType.kStart then
		door = Sprite:createWithSpriteFrameName("trans_door_in_0000")
		createAnimation(door, "trans_door_in_%04d", 41)
	else
		door = Sprite:createWithSpriteFrameName("trans_door_out_0000")
		createAnimation(door, "trans_door_out_%04d", 55)
	end
	door:setAnchorPoint(ccp(0.5, 0.5))
	door:setPosition(self.position)
	self:addChild(door)
	self.door = door

	local light = Sprite:createWithSpriteFrameName("trans_light_mask_0000")
	light:setVisible(false)
	light:setAnchorPoint(ccp(0.3, 0.5))
	light:setPosition(ccp(self.position.x + 7, self.position.y))
	self:addChild(light)
	self.light = light

	self:setRotation(self.rotation)
end

function TileTransDoor:playTransAnimation()
	local function callback()
		self.light:setVisible(false)
	end
	self.light:setVisible(true)
	createAnimation(self.light, "trans_light_mask_%04d", 18, 1, callback)
end