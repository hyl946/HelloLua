local FlyTopBaseAni = require "zoo.iconButtons.animation.FlyTopBaseAni"

FlyTopEnergyBottleAni = class(FlyTopBaseAni)

local kAnimationTime = 1/30
function FlyTopEnergyBottleAni:ctor()
end

function FlyTopEnergyBottleAni:init(itemType, num)
	self.itemType = itemType

	FlyTopBaseAni.init(self, num)
end

function FlyTopEnergyBottleAni:getIconBtnTop()
	return HomeScene:sharedInstance().energyButton
end

function FlyTopEnergyBottleAni:getHighLightRes()
	return "home_top_bar_ani/cells/white_energy0000"
end

function FlyTopEnergyBottleAni:createAnimation(_finishCallback, _reachCallback)
	local animation = {}
	local iconBtnTopEnergy = self:getIconBtnTop()

	local energyIcon
	local function onReach()
		if self.isDisposed then return end
		energyIcon:setVisible(false)	
		if _reachCallback then _reachCallback() end
	end

	local function onFinish()
		if self.isDisposed then return end
		self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(kAnimationTime*15), CCCallFunc:create(function()
			if _finishCallback then _finishCallback() end
			end)
		))
	end

	if self.itemType == ItemType.SMALL_ENERGY_BOTTLE then
		energyIcon = ResourceManager:sharedInstance():getItemResNameFromGoodsId(12)
	elseif self.itemType == ItemType.MIDDLE_ENERGY_BOTTLE then
		energyIcon = ResourceManager:sharedInstance():getItemResNameFromGoodsId(17)
	elseif self.itemType == ItemType.LARGE_ENERGY_BOTTLE then
		energyIcon = ResourceManager:sharedInstance():getItemResNameFromGoodsId(18)
	elseif self.itemType == ItemType.INFINITE_ENERGY_BOTTLE then
		energyIcon = ResourceManager:sharedInstance():buildItemSprite(ItemType.INFINITE_ENERGY_BOTTLE)
	else 
		function animation:play()
			onFinish()
		end 
		return animation
	end
	energyIcon:setAnchorPoint(ccp(0.5, 0.5))
	self.container:addChild(energyIcon)

	local flyToConfig = {
		duration = 0.5,
		sprites = {energyIcon},
		dstPosition = iconBtnTopEnergy:getFlyToPosition(),
		dstSize = iconBtnTopEnergy:getFlyToSize(),
		direction = true,
		delayTime = 0.1,
		reachCallback = onReach,	
		finishCallback = onFinish,
	}

	function animation:play()
		BezierFlyToAnimation:create(flyToConfig) 
	end
	return animation
end

function FlyTopEnergyBottleAni:create(itemType, num)
	local ani = FlyTopEnergyBottleAni.new(CCNode:create())
	ani:init(itemType, num)
	return ani
end