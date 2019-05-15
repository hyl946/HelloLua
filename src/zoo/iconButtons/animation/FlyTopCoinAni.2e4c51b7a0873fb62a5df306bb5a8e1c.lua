
local FlyTopBaseAni = require "zoo.iconButtons.animation.FlyTopBaseAni"

FlyTopCoinAni = class(FlyTopBaseAni)

local kAnimationTime = 1/30

--目前最多5个飞的
local AniOriPosConfig = {
	[1] = {x = 0, y = 0},
	[2] = {x = -10, y = -5},
	[3] = {x = 8, y = -5},
	[4] = {x = -5, y = 10},
	[5] = {x = 10, y = 5},
}

function FlyTopCoinAni:ctor()
end

function FlyTopCoinAni:getIconBtnTop()
	return HomeScene:sharedInstance().coinButton
end

function FlyTopCoinAni:getHighLightRes()
	return "home_top_bar_ani/cells/white_coin0000"
end

function FlyTopCoinAni:createAnimation(_finishCallback, _reachCallback)
	local animation = {}
	local iconBtnTopCoin = self:getIconBtnTop()
	local numMax = math.min(5, self.num)
	local coinAnis = {}
	for i=1,numMax do
		local coinAni = ArmatureNode:create("home_top_bar_s_ani/coin_silver")
		coinAni:update(0.001)
		coinAni:stop()
		self.container:addChild(coinAni)
		coinAni:setPosition(ccp(AniOriPosConfig[i].x or 0, AniOriPosConfig[i].y or 0))
		coinAni:setVisible(false)
		table.insert(coinAnis, coinAni)
	end

	local function onStart(coinAni)
		if self.isDisposed then return end
		if coinAni then coinAni:play("silver2", 0) end
	end

	local function onReach(coinAni)
		if self.isDisposed then return end
		if coinAni then coinAni:setVisible(false) end	
		if _reachCallback then _reachCallback() end
	end

	local function onFinish()
		if self.isDisposed then return end
		if _finishCallback then _finishCallback() end
	end

	local context = self
	function animation:play()
		local arr = CCArray:create()
		for i=1,numMax do
			if i ~= 1 then 
				arr:addObject(CCDelayTime:create(kAnimationTime * 3))
			end
			arr:addObject(CCCallFunc:create(function ()
				coinAnis[i]:setVisible(true)
				coinAnis[i]:play("silver1")
				coinAnis[i]:addEventListener(ArmatureEvents.COMPLETE, function ()
					local flyToConfig = {
						duration = 0.8,
						sprites = {coinAnis[i]},
						dstPosition = iconBtnTopCoin:getFlyToPosition(),
						dstSize = iconBtnTopCoin:getFlyToSize(),
						direction = false,
						delayTime = 0,
						startCallback = onStart,
						reachCallback = onReach,	
					}
					if i == numMax then
						flyToConfig.finishCallback = onFinish
					end
					BezierFlyToAnimation:create(flyToConfig) 
				end)
			end))
		end
		context:runAction(CCSequence:create(arr))
	end

	return animation
end

function FlyTopCoinAni:create(num)
	local ani = FlyTopCoinAni.new(CCNode:create())
	ani:init(num)
	return ani
end