require "zoo.baseUI.ViewGroupLayout"

--------------- ScrollGameBg_V ---------------
ScrollGameBg_V = class(CocosObject)

function ScrollGameBg_V:ctor()
	self.spriteList = {}
	self.visibleRect = {x = 0, y = 0, width = 720, height = 1280}
	self.fixPos = 2  -- 防止出现裂缝
	self.scrollScheduleId = nil
end

function ScrollGameBg_V:createSpriteList()
	return {}
end

function ScrollGameBg_V:setVisibleRect(x, y, width, height)
	if x then self.visibleRect.x = x end
	if y then self.visibleRect.y = y end
	if width then self.visibleRect.width = width end
	if height then self.visibleRect.height = height end
end

function ScrollGameBg_V:init()
	local posY = self.visibleRect.y
	local spriteList = self:createSpriteList()
	if spriteList and #spriteList > 0 then
		self.recycleStart = self.recycleStart or 1
		self.recycleEnd = self.recycleEnd or #spriteList
	end

	for i, sprite in ipairs(spriteList) do
		sprite:setAnchorPoint(ccp(0, 1))
		sprite:ignoreAnchorPointForPosition(false)
		sprite:setPositionY(posY)
		self:addChild(sprite)
		
		local height = sprite:getContentSize().height
		posY = posY - height + self.fixPos
		table.insert(self.spriteList, sprite)
	end
end

function ScrollGameBg_V:updateSprites(deltaY)
	if deltaY > 0 then
		local spritesAddToLast = {}
		local spritesToRemove = {}
		for i, sprite in ipairs(self.spriteList) do
			sprite:setPositionY(sprite:getPositionY() + deltaY)
			if sprite:getPositionY() - sprite:getContentSize().height > self.visibleRect.y then
				if sprite.isRecycleDisplay then
					table.insert(spritesAddToLast, sprite)
				else
					table.insert(spritesToRemove, sprite)
				end
			end
		end
		for _, sprite in ipairs(spritesToRemove) do
			table.removeValue(self.spriteList, sprite)
			sprite:removeFromParentAndCleanup(true)
		end
		local lastSprite = self.spriteList[#self.spriteList]
		if lastSprite then
			for _, sprite in ipairs(spritesAddToLast) do
				table.removeValue(self.spriteList, sprite)
				table.insert(self.spriteList, sprite)
				sprite:setPositionY(lastSprite:getPositionY() - lastSprite:getContentSize().height + self.fixPos)
				lastSprite = sprite
			end
		end
	elseif deltaY < 0 then
		local spritesAddToHead = {}
		local spritesToRemove = {}
		for i = #self.spriteList, 1, -1 do
			local sprite = self.spriteList[i]
			sprite:setPositionY(sprite:getPositionY() + deltaY)
			if sprite:getPositionY() <= (self.visibleRect.y - self.visibleRect.height) then
				if sprite.isRecycleDisplay then
					table.insert(spritesAddToHead, sprite)
				else
					table.insert(spritesToRemove, sprite)
				end
			end
		end
		for _, sprite in ipairs(spritesToRemove) do
			table.removeValue(self.spriteList, sprite)
			sprite:removeFromParentAndCleanup(true)
		end
		local headSprite = self.spriteList[1]
		if headSprite then
			for _, sprite in ipairs(spritesAddToHead) do
				table.removeValue(self.spriteList, sprite)
				table.insert(self.spriteList, 1, sprite)
				sprite:setPositionY(headSprite:getPositionY() + sprite:getContentSize().height - self.fixPos)
				headSprite = sprite
			end
		end
	end
end

function ScrollGameBg_V:stopScroll()
	self:unscheduleUpdate()
end

function ScrollGameBg_V:startScroll(deltaY, time)
	time = time or 0

	self:stopScroll()

	local leftDeltaY = deltaY
	if time <= 0 then
		self:updateSprites(deltaY)
		self:stopScroll()
	else
		local movePerSec = deltaY / time
		local totalDt = 0
		local function updateFunc(dt)
			totalDt = totalDt + dt
			local moveY = movePerSec * dt
			moveY = math.abs(moveY) < math.abs(leftDeltaY) and moveY or leftDeltaY
			self:updateSprites(moveY)
			leftDeltaY = leftDeltaY - moveY
			if totalDt >= time then
				self:stopScroll()
			end
		end
		self:scheduleUpdateWithPriority(updateFunc, 0)
	end
end

function ScrollGameBg_V:startScrollForever(speed)
	assert(type(speed) == "number")
	if speed == 0 then return end

	self:stopScroll()

	local movePerFrame = speed * 1 / 60
	local function updateFunc(dt)
		self:updateSprites(movePerFrame)
	end
	self:scheduleUpdateWithPriority(updateFunc, 0)
end

function ScrollGameBg_V:dispose()
	self.spriteList = nil
	self:stopScroll()
	CocosObject.dispose(self)
end

--------------- ScrollGameBg_H ---------------
ScrollGameBg_H = class(CocosObject)

function ScrollGameBg_H:ctor()
	self.spriteList = {}
	self.visibleRect = {x = 0, y = 0, width = 720, height = 1480}
	self.fixPos = 2  -- 防止出现裂缝
	self.scrollScheduleId = nil
end

--to be overrided
function ScrollGameBg_H:createSpriteList()
	return {}
end

-- function ScrollGameBg_H:setVisibleRect(x, y, width, height)
-- 	if x then self.visibleRect.x = x end
-- 	if y then self.visibleRect.y = y end
-- 	if width then self.visibleRect.width = width end
-- 	if height then self.visibleRect.height = height end
-- end

function ScrollGameBg_H:init()
	local posX = self.visibleRect.x
	local spriteList = self:createSpriteList()
	-- if spriteList and #spriteList > 0 then
	-- 	self.recycleStart = self.recycleStart or 1
	-- 	self.recycleEnd = self.recycleEnd or #spriteList
	-- end

	for i, sprite in ipairs(spriteList) do
		sprite:setAnchorPoint(ccp(0, 0))
		sprite:ignoreAnchorPointForPosition(false)
		sprite:setPositionX(posX)
		self:addChild(sprite)
		local width = sprite:getContentSize().width
		posX = posX - width + self.fixPos
		table.insert(self.spriteList, sprite)
	end
end

function ScrollGameBg_H:updateSprites(deltaX)
	if deltaX > 0 then
		local spritesAddToLast = {}
		local spritesToRemove = {}
		for i, sprite in ipairs(self.spriteList) do
			sprite:setPositionX(sprite:getPositionX() + deltaX)
			if sprite:getPositionX() - sprite:getContentSize().width > self.visibleRect.x then
				if sprite.isRecycleDisplay then
					table.insert(spritesAddToLast, sprite)
				else
					table.insert(spritesToRemove, sprite)
				end
			end
		end
		for _, sprite in ipairs(spritesToRemove) do
			table.removeValue(self.spriteList, sprite)
			sprite:removeFromParentAndCleanup(true)
		end
		local lastSprite = self.spriteList[#self.spriteList]
		if lastSprite then
			for _, sprite in ipairs(spritesAddToLast) do
				table.removeValue(self.spriteList, sprite)
				table.insert(self.spriteList, sprite)
				sprite:setPositionX(lastSprite:getPositionX() - lastSprite:getContentSize().width + self.fixPos)
				lastSprite = sprite
			end
		end
	elseif deltaX < 0 then
		local spritesAddToHead = {}
		local spritesToRemove = {}
		for i = #self.spriteList, 1, -1 do
			local sprite = self.spriteList[i]
			sprite:setPositionX(sprite:getPositionX() + deltaX)
			if sprite:getPositionX() <= (self.visibleRect.x - self.visibleRect.width) then
				if sprite.isRecycleDisplay then
					table.insert(spritesAddToHead, sprite)
				else
					table.insert(spritesToRemove, sprite)
				end
			end
		end
		for _, sprite in ipairs(spritesToRemove) do
			table.removeValue(self.spriteList, sprite)
			sprite:removeFromParentAndCleanup(true)
		end
		local headSprite = self.spriteList[1]
		if headSprite then
			for _, sprite in ipairs(spritesAddToHead) do
				table.removeValue(self.spriteList, sprite)
				table.insert(self.spriteList, 1, sprite)
				sprite:setPositionX(headSprite:getPositionX() + sprite:getContentSize().width - self.fixPos)
				headSprite = sprite
			end
		end
	end
end

function ScrollGameBg_H:stopScroll()
	self:unscheduleUpdate()
end

function ScrollGameBg_H:startScroll(deltaX, time)
	time = time or 0

	self:stopScroll()

	local leftDeltaX = deltaX
	if time <= 0 then
		self:updateSprites(deltaX)
		self:stopScroll()
	else
		local movePerSec = deltaX / time
		local totalDt = 0
		local function updateFunc(dt)
			totalDt = totalDt + dt
			local moveX = movePerSec * dt
			moveX = math.abs(moveX) < math.abs(leftDeltaX) and moveX or leftDeltaX
			self:updateSprites(moveX)
			leftDeltaX = leftDeltaX - moveX
			if totalDt >= time then
				self:stopScroll()
			end
		end
		self:scheduleUpdateWithPriority(updateFunc, 0)
	end
end

function ScrollGameBg_H:startScrollForever(speed)
	assert(type(speed) == "number")
	if speed == 0 then return end

	self:stopScroll()

	local movePerFrame = speed * 1 / 60
	local function updateFunc(dt)
		self:updateSprites(movePerFrame)
	end
	self:scheduleUpdateWithPriority(updateFunc, 0)
end

function ScrollGameBg_H:dispose()
	self.spriteList = nil
	self:stopScroll()
	CocosObject.dispose(self)
end

-------- WeeklyScrollGameBg_H --------
WeeklyScrollGameBg_H = class(ScrollGameBg_H)

function WeeklyScrollGameBg_H:create()
	FrameLoader:loadImageWithPlist("materials/weekly_game_bg/weekly_2018_s1.plist")
	local sp = Sprite:createWithSpriteFrameName("2018_s1_bg_back")
	local texture = sp:getTexture()
	local bg = WeeklyScrollGameBg_H.new(CCSpriteBatchNode:createWithTexture(texture))
	bg:init()
	sp:dispose()
	return bg
end

function WeeklyScrollGameBg_H:createSpriteList()
	self.fixPos = 0.4
	local spriteList = {}
	local spSourceList = {{name = "2018_s1_bg_mid", scrollSpeedRate = 0.5, scrollPosY = 500},
							{name = "2018_s1_bg_fore", scrollSpeedRate = 1, scrollPosY = 410},}
	for k,v in pairs(spSourceList) do
		if not spriteList[k] then spriteList[k] = {} end
		for i = 1, 3 do
			local sprite = Sprite:createWithSpriteFrameName(v.name)
			sprite.isRecycleDisplay = true
			sprite.scrollSpeedRate = v.scrollSpeedRate
			sprite.scrollPosY = v.scrollPosY
			table.insert(spriteList[k], sprite)
		end
	end

	return spriteList
end

function WeeklyScrollGameBg_H:init()
	local visibleSize =  Director:sharedDirector():getVisibleSize()
	self.visibleRect = {x = 0, y = 0, width = visibleSize.width, height = visibleSize.height}

	local scale = 1
	local adjustY = 0
	local ratio = visibleSize.height / visibleSize.width
	if ratio > 1280/720 then
		scale = visibleSize.width / 720
		-- adjustY = -100 + (ratio - 1280/720) / (1480/720 - 1280/720) * 100
	else
		scale = visibleSize.height / 1280
		-- adjustY = -100
	end
	scale = math.max(scale, 0.81)
	self.spScale = scale

	local posX = self.visibleRect.x 
	local bgBack = Sprite:createWithSpriteFrameName("2018_s1_bg_back")
	bgBack:setAnchorPoint(ccp(0.5, 0.5))
	bgBack:setScale(scale)
	bgBack:ignoreAnchorPointForPosition(false)
	bgBack:setPositionX(posX)
	self:addChild(bgBack)

	local spriteList = self:createSpriteList()
	for k,v in pairs(spriteList) do
		local scrollPosX = posX
		if not self.spriteList[k] then self.spriteList[k] = {} end
		for i, sprite in ipairs(v) do
			sprite:setAnchorPoint(ccp(0.5, 0.5))
			sprite:setScale(scale)
			sprite:ignoreAnchorPointForPosition(false)
			sprite:setPosition(ccp(scrollPosX, sprite.scrollPosY*scale))
			self:addChild(sprite)
			local width = sprite:getContentSize().width * scale
			scrollPosX = scrollPosX - width + self.fixPos
			table.insert(self.spriteList[k], sprite)
		end
	end
end

function WeeklyScrollGameBg_H:updateSprites(deltaX)
	if deltaX > 0 then
		for k,v in pairs(self.spriteList) do
			local spritesAddToLast = {}
			local spritesToRemove = {}
			for i, sprite in ipairs(v) do
				sprite:setPositionX(sprite:getPositionX() + deltaX * sprite.scrollSpeedRate)
				if sprite:getPositionX() - self.spScale * sprite:getContentSize().width/2 > self.visibleRect.width/2 then
					if sprite.isRecycleDisplay then
						table.insert(spritesAddToLast, sprite)
					else
						table.insert(spritesToRemove, sprite)
					end
				end
			end
			for _, sprite in ipairs(spritesToRemove) do
				table.removeValue(v, sprite)
				sprite:removeFromParentAndCleanup(true)
			end
			local lastSprite = v[#v]
			if lastSprite then
				for _, sprite in ipairs(spritesAddToLast) do
					table.removeValue(v, sprite)
					table.insert(v, sprite)
					sprite:setPositionX(lastSprite:getPositionX() - lastSprite:getContentSize().width * self.spScale + self.fixPos)
					lastSprite = sprite
				end
			end
		end
	elseif deltaX < 0 then
		for k,v in pairs(self.spriteList) do
			local spritesAddToHead = {}
			local spritesToRemove = {}
			for i = #v, 1, -1 do
				local sprite = v[i]
				sprite:setPositionX(sprite:getPositionX() + deltaX * sprite.scrollSpeedRate)
				if sprite:getPositionX() + self.spScale * sprite:getContentSize().width/2 <= - self.visibleRect.width/2 then
					if sprite.isRecycleDisplay then
						table.insert(spritesAddToHead, sprite)
					else
						table.insert(spritesToRemove, sprite)
					end
				end
			end
			for _, sprite in ipairs(spritesToRemove) do
				table.removeValue(v, sprite)
				sprite:removeFromParentAndCleanup(true)
			end
			local headSprite = v[1]
			if headSprite then
				for _, sprite in ipairs(spritesAddToHead) do
					table.removeValue(v, sprite)
					table.insert(v, 1, sprite)
					sprite:setPositionX(headSprite:getPositionX() + sprite:getContentSize().width * self.spScale - self.fixPos)
					headSprite = sprite
				end
			end
		end
	end
end