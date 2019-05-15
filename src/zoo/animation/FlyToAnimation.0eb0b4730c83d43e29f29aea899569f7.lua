require "zoo.ResourceManager"

-- config = {
-- 	duration,
-- 	sprites = {},
-- 	delayTime,
-- 	distance,
-- 	extendAction,
-- 	startCallback,
-- 	reachCallback,
-- 	finishCallback,
-- }
RiseFadeOutAnimation = class()
function RiseFadeOutAnimation:create(config)
	if not config.sprites or #config.sprites <= 0 or not config.duration or config.duration <= 0 then return end
	config.delayTime = config.delayTime or 0
	config.distance = config.distance or 100
	local counter = #config.sprites
	for k, v in ipairs(config.sprites) do
		local sequence = CCArray:create()
		sequence:addObject(CCDelayTime:create(config.delayTime * (k - 1)))
		local function onStart() if config.startCallback then config.startCallback(v) end end
		sequence:addObject(CCCallFunc:create(onStart))
		local spawn = CCArray:create()
		spawn:addObject(CCMoveBy:create(config.duration, ccp(0, config.distance)))
		spawn:addObject(CCFadeOut:create(config.duration))
		if config.extendAction then 
			local extendActionCopy = config.extendAction:copy()
			spawn:addObject(extendActionCopy) 
			extendActionCopy:release()
		end
		sequence:addObject(CCSpawn:create(spawn))
		local function onReach()
			counter = counter - 1
			if config.reachCallback then config.reachCallback(v) end
			if counter == 0 and config.finishCallback then config.finishCallback() end
		end
		sequence:addObject(CCCallFunc:create(onReach))
		v:runAction(CCSequence:create(sequence))
	end
end

-- config = {
-- 	duration,
-- 	sprites = {},
-- 	dstPosition,
-- 	dstSize,
-- 	direction = (left = true/right = false),
-- 	delayTime,
-- 	extendAction,
-- 	startCallback,
-- 	reachCallback,
-- 	finishCallback,
-- }
BezierFlyToAnimation = class()
function BezierFlyToAnimation:create(config)
	if not config.sprites or #config.sprites <= 0 or not config.duration or config.duration <= 0 then return end
	config.delayTime = config.delayTime or 0
	config.direction = config.direction or false
	config.dstPosition = config.dstPosition or ccp(0, 0)
	local counter = #config.sprites
	for k, v in ipairs(config.sprites) do
		local sequence = CCArray:create()
		sequence:addObject(CCDelayTime:create(config.delayTime * (k - 1)))
		local function onStart() if config.startCallback then config.startCallback(v) end end
		sequence:addObject(CCCallFunc:create(onStart))
		local parent = v:getParent()
		local position = parent:convertToNodeSpace(config.dstPosition)
		local distance = ccpDistance(position, v:getPosition())
		local spawn = CCArray:create()
		spawn:addObject(CCEaseSineOut:create(HeBezierTo:create(config.duration, ccp(position.x, position.y), config.direction, distance * 0.1)))
		if config.dstSize then
			local size = v:getGroupBounds().size
			spawn:addObject(CCScaleBy:create(config.duration, config.dstSize.width / size.width, config.dstSize.height / size.height))
		end
		if config.extendAction then 
			local extendActionCopy = config.extendAction:copy()
			spawn:addObject(extendActionCopy) 
			extendActionCopy:release()
		end
		sequence:addObject(CCSpawn:create(spawn))
		local function onReach()
			counter = counter - 1
			if config.reachCallback then config.reachCallback(v) end
			if counter == 0 and config.finishCallback then config.finishCallback() end
		end
		sequence:addObject(CCCallFunc:create(onReach))
		v:runAction(CCSequence:create(sequence))
	end
end

-- config = {
-- 	duration,
-- 	sprites = {},
-- 	dstPosition,
-- 	dstSize,
-- 	easeIn, -- boolean
-- 	delayTime,
-- 	height,
-- 	extendAction,
-- 	startCallback,
-- 	reachCallback,
-- 	finishCallback,
-- }
JumpFlyToAnimation = class()
function JumpFlyToAnimation:create(config)
	if _G.isLocalDevelopMode then printx(0, "JumpFlyToAnimation:create") end
	if not config.sprites or #config.sprites <= 0 or not config.duration or config.duration <= 0 then return end
	config.delayTime = config.delayTime or 0
	config.dstPosition = config.dstPosition or ccp(0, 0)
	config.height = config.height or 100
	local counter = #config.sprites
	local time = 0
	for k, v in ipairs(config.sprites) do
		local sequence = CCArray:create()
		if config.easeIn and counter > 1 then
			sequence:addObject(CCDelayTime:create(time))
			time = time + math.cos((k - 1) / (counter - 1) * math.pi / 2) * config.delayTime
		else
			sequence:addObject(CCDelayTime:create(config.delayTime * (k - 1)))
		end
		local function onStart() if config.startCallback then config.startCallback(v) end end
		sequence:addObject(CCCallFunc:create(onStart))
		local spawn = CCArray:create()
		local position = v:getPosition()
		local parent = v:getParent()
		local inPosition = parent:convertToNodeSpace(config.dstPosition)
		spawn:addObject(CCEaseBackIn:create(CCMoveBy:create(config.duration, ccp(0, inPosition.y - position.y))))
		spawn:addObject(CCMoveBy:create(config.duration, ccp(inPosition.x - position.x, 0)))
		if config.dstSize then
			local size = v:getGroupBounds().size
			spawn:addObject(CCScaleBy:create(config.duration, config.dstSize.width / size.width, config.dstSize.height / size.height))
		end
		if config.extendAction then
			local extendActionCopy = config.extendAction:copy()
			spawn:addObject(extendActionCopy) 
			extendActionCopy:release()
		end
		sequence:addObject(CCSpawn:create(spawn))
		local function onReach()
			counter = counter - 1
			if config.reachCallback then config.reachCallback(v) end
			if counter == 0 and config.finishCallback then config.finishCallback() end
		end
		sequence:addObject(CCCallFunc:create(onReach))
		v:runAction(CCSequence:create(sequence))
	end
end