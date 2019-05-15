
HalloweenAnimation = class()

local _instance = nil

function HalloweenAnimation:getInstance()
	if not _instance then
		_instance = HalloweenAnimation.new()
	end

	return _instance
end

function HalloweenAnimation:init()
	self.pumpkinCenterWorldPos = nil
end

function HalloweenAnimation:dispose()
end

function HalloweenAnimation:getPumpkinCenterWorldPos()
	return self.pumpkinCenterWorldPos or ccp(0,0)
end

function HalloweenAnimation:setPumpkinCenterWorldPos(pos)
	self.pumpkinCenterWorldPos = pos
end

local function createSugarFlyAnim(duration)
	local sprite = Sprite:createWithSpriteFrameName("sugar_fly_0000.png")
	sprite:setAnchorPoint(ccp(0.5, 1))
    local frames = SpriteUtil:buildFrames("sugar_fly_%04d.png", 0, 18)
    local anim = SpriteUtil:buildAnimate(frames, duration/18)
    sprite:play(anim, 0, 1)
    return sprite
end

local function createSugarExplodeAnim(duration)
	local sprite = Sprite:createWithSpriteFrameName("sugar_explode_0000.png")
	sprite:setAnchorPoint(ccp(0.5, 0.5))
    local frames = SpriteUtil:buildFrames("sugar_explode_%04d.png", 0, 19)
    local anim = SpriteUtil:buildAnimate(frames, 1/24)
    sprite:play(anim, 0, 1, function ()
    	sprite:removeFromParentAndCleanup(true)
    end)
    return sprite
end

function HalloweenAnimation:playSugarFlyAnimation(startPos, endPos, duration, completeCallback, fromBossCast)
	local sf = createSugarFlyAnim(duration)
	local scene = Director:sharedDirector():getRunningScene()
	if not scene.halloweenSugarBatch then 
		scene.halloweenSugarBatch = CocosObject:create()
		scene.halloweenSugarBatch:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/halloween_2015.png"),100))
		scene:addChild(scene.halloweenSugarBatch)
	end

	sf:setPosition(startPos)

	if startPos.x ~= endPos.x then
		local rotation = math.atan((endPos.x - startPos.x) / math.abs(endPos.y - startPos.y)) * 180 / 3.14
		if fromBossCast then 
			sf:setRotation(-rotation)
		else
			sf:setRotation(rotation)
		end
	end
	if fromBossCast then 
		sf:setScale(-1)
	end

	scene.halloweenSugarBatch:addChild(sf)

	duration = duration or 0.8
	local move_action =CCEaseSineOut:create(CCMoveTo:create(duration, endPos))
	
	local actions = CCArray:create()

	actions:addObject(move_action)
	actions:addObject(CCCallFunc:create(
			function() 
				if completeCallback then
					completeCallback()
				end
				local sugarExplode = createSugarExplodeAnim(duration)
				scene.halloweenSugarBatch:addChild(sugarExplode)
				sugarExplode:setPosition(ccp(endPos.x, endPos.y))
				sf:removeFromParentAndCleanup(true)
			end))

	sf:runAction(CCSequence:create(actions))
end

function HalloweenAnimation:createGalaxyBackgruond()
	local bg = Sprite:createWithSpriteFrameName("magic_tile_halloween.png")
	bg.hide = function(hideCompleteCallback)
		bg:setScale(1)
		bg:runAction(CCSequence:createWithTwoActions(CCFadeOut:create(1), 
				CCCallFunc:create(function() 
						if hideCompleteCallback then
							hideCompleteCallback()
						end
					end)
			))
	end
	return bg
end

function HalloweenAnimation:setHalloweenGhost(halloweenGhost)
	self.halloweenGhost = halloweenGhost
end

function HalloweenAnimation:getHalloweenGhost()
	return self.halloweenGhost 
end

function HalloweenAnimation:getGhostChildIndex()
	local childIndex = nil
	if self.halloweenGhost then 
		local parent = self.halloweenGhost:getParent()
		if parent then
			childIndex = parent:getChildIndex(self.halloweenGhost) 
		end
	end
	return childIndex
end


