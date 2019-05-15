local UIHelper = require 'zoo.panel.UIHelper'

ZQAnimation = {}

function ZQAnimation:init()
	if self.initialized then return end
	self.initialized = true
	UIHelper:loadArmature('skeleton/autumn2018/lotus_ani', "lotus_ani", "lotus_ani")
	UIHelper:loadArmature('skeleton/autumn2018/add_5_ani', "add_5_ani", "add_5_ani")
	UIHelper:loadArmature('skeleton/autumn2018/bomb_ani', "bomb_ani", "bomb_ani")
	FrameLoader:loadImageWithPlist("flash/autumn2018/mid_autumn_target.plist")
end

function ZQAnimation:unloadRes()
	self.initialized = false
	UIHelper:unloadArmature('skeleton/autumn2018/lotus_ani', true)
	UIHelper:unloadArmature('skeleton/autumn2018/add_5_ani', true)
	UIHelper:unloadArmature('skeleton/autumn2018/bomb_ani', true)
	FrameLoader:unloadImageWithPlists({'flash/autumn2018/mid_autumn_target.plist'})
end

function ZQAnimation:createLotus()
	local container = Layer:create()

	local animation = ArmatureNode:create("autumn_2018_lotus/lotus")
	animation:update(0.001)
	-- animation:stop()
	animation:play("appear", 1)
	animation:addEventListener(ArmatureEvents.COMPLETE, function ()
		if animation and not animation.isDisposed then 
			animation:play("stand", 0)
		end
	end)

	container:addChild(animation:wrapWithBatchNode())
	container.body = animation

	return container
end

function ZQAnimation:createLotusBoom()
	local container = Layer:create()

	local animation = ArmatureNode:create("olympic_gold/goldBoom")
	animation:update(0.001)
	animation:stop()
	container:addChild(animation:wrapWithBatchNode())
	container.body = animation

	return container
end

local FlyConfig = {
	[1] = {scale = 2.5, delay = 0},
	[2] = {scale = 2.5, delay = 0.05},
	[3] = {scale = 1, 	delay = 0.1},
	[4] = {scale = 1, 	delay = 0.15},
	[5] = {scale = 1, 	delay = 0.2},
	[6] = {scale = 0.9, delay = 0.25},
	[7] = {scale = 0.8, delay = 0.3},
}
function ZQAnimation:playTailFlyEffect(container, fromPos, toPos)
	local function playBoomEff()
		local lightSp, animate = SpriteUtil:buildAnimatedSprite(1/30, "ZQ_fly_light_%04d", 0, 17)
		lightSp:setScale(1.2)
		container:addChild(lightSp)
		lightSp:setPosition(ccp(toPos.x - 3, toPos.y))
		lightSp:play(animate, 0, 1, function ()
			lightSp:removeFromParentAndCleanup(true)
		end)
	end
	for i=1,7 do
		local sp = Sprite:createWithSpriteFrameName("ZQ_fly_star")
		sp:setScale(FlyConfig[i].scale)
		sp:setRotation(math.random(0, 180))
		sp:setPosition(ccp(fromPos.x , fromPos.y))
		local controlPoint = ccp(toPos.x - (toPos.x - fromPos.x) / 2, toPos.y + 50)
		local bezierConfig = ccBezierConfig:new()
		bezierConfig.controlPoint_1 = fromPos
		bezierConfig.controlPoint_2 = controlPoint
		bezierConfig.endPosition = toPos
		local bezierAction = CCBezierTo:create(0.8, bezierConfig)

		local arr = CCArray:create()
		local arr1 = CCArray:create()
		arr:addObject(CCDelayTime:create(FlyConfig[i].delay))
		arr1:addObject(bezierAction)
		local rotateAngle = 0
		if toPos.x > fromPos.x then
			rotateAngle = 30
		elseif toPos.x < fromPos.x then 
			rotateAngle = -30
		end
		arr1:addObject(CCRotateBy:create(0.8, rotateAngle))
		arr:addObject(CCSpawn:create(arr1))
		arr:addObject(CCCallFunc:create(function() 
			sp:removeFromParentAndCleanup(true) 
			if i == 1 then 
				playBoomEff()
			end
			end))
		sp:runAction(CCSequence:create(arr))
		container:addChild(sp)
	end
end