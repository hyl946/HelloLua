local FlyTopBaseAni = require "zoo.iconButtons.animation.FlyTopBaseAni"

FlyTopEnergyAni = class(FlyTopBaseAni)

local kAnimationTime = 1/30
function FlyTopEnergyAni:ctor()
end

function FlyTopEnergyAni:getIconBtnTop()
	return HomeScene:sharedInstance().energyButton
end

function FlyTopEnergyAni:getHighLightRes()
	return "home_top_bar_ani/cells/white_energy0000"
end

function FlyTopEnergyAni:createAnimation(_finishCallback, _reachCallback)
	local animation = {}
	local iconBtnTopEnergy = self:getIconBtnTop()
	local energyIcon = Sprite:createWithSpriteFrame(iconBtnTopEnergy:getIconGroup():getChildByName("bg"):displayFrame())
	energyIcon:setAnchorPoint(ccp(0.5, 0.5))
	self.container:addChild(energyIcon)

	local function onReach()
		if self.isDisposed then return end
		energyIcon:setVisible(false)	
		GamePlayMusicPlayer:playEffect(GameMusicType.kAddEnergy)
		if _reachCallback then _reachCallback() end
	end

	local function onFinish()
		if self.isDisposed then return end
		if _finishCallback then _finishCallback() end
	end

	local flyToConfig = {
		duration = 0.4,
		sprites = {energyIcon},
		dstPosition = iconBtnTopEnergy:getFlyToPosition(),
		dstSize = iconBtnTopEnergy:getFlyToSize(),
		direction = false,
		delayTime = 0.1,
		reachCallback = onReach,	
		finishCallback = onFinish,
	}

	function animation:play()
		energyIcon:setScaleX(0.34)
		energyIcon:setScaleY(0.24)
		local arr = CCArray:create()
		arr:addObject(CCSpawn:createWithTwoActions(
			CCScaleTo:create(kAnimationTime*5, 0.96, 0.82), 
			CCEaseBackOut:create(CCMoveBy:create(kAnimationTime*5, ccp(0, 30)))
		))
		arr:addObject(CCSpawn:createWithTwoActions(
			CCScaleTo:create(kAnimationTime*3, 0.65, 0.59), 
			CCEaseBackOut:create(CCMoveBy:create(kAnimationTime*3, ccp(0, -30)))
		))
		arr:addObject(CCScaleTo:create(kAnimationTime*2, 0.65))
		arr:addObject(CCDelayTime:create(kAnimationTime*10))
		arr:addObject(CCCallFunc:create(function() 
			BezierFlyToAnimation:create(flyToConfig) 
		end))
		energyIcon:runAction(CCSequence:create(arr))
	end
	return animation
end

function FlyTopEnergyAni:create(num)
	local ani = FlyTopEnergyAni.new(CCNode:create())
	ani:init(num)
	return ani
end