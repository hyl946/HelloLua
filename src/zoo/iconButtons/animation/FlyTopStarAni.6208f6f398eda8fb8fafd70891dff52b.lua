local FlyTopBaseAni = require "zoo.iconButtons.animation.FlyTopBaseAni"

FlyTopStarAni = class(FlyTopBaseAni)

local kAnimationTime = 1/30
function FlyTopStarAni:ctor()
end

function FlyTopStarAni:init(num, starsWorldPos)
	self.starsWorldPos = starsWorldPos
	FlyTopBaseAni.init(self, num)
end

function FlyTopStarAni:getIconBtnTop()
	return HomeScene:sharedInstance().starButton
end

function FlyTopStarAni:getHighLightRes()
	return "home_top_bar_ani/cells/white_star0000"
end

local motionStreakUseTexture = nil
function FlyTopStarAni:getMotionStreakUseTexture()
	if not motionStreakUseTexture then
		local sprite = Sprite:createWithSpriteFrameName("home_top_bar_ani/cells/tail_star0000")
		local renderTexture = CCRenderTexture:create(36, 110)
		renderTexture:beginWithClear(255, 255, 255, 0)
		sprite:setPosition(ccp(18, 55))
		sprite:visit()
		sprite:dispose()
		renderTexture:endToLua()
		if __WP8 then renderTexture:saveToCache() end
		renderTexture:retain()

		motionStreakUseTexture = renderTexture:getSprite():getTexture():getTexture()
		motionStreakUseTexture:setAntiAliasTexParameters()
	end
	return motionStreakUseTexture
end

function FlyTopStarAni:buildMotionStreak(fade, stroke)
	fade = fade or 0.3
	stroke = stroke or 32
	local texture2d = self:getMotionStreakUseTexture()
	local motionStreakObj = CCMotionStreak:create(fade, 10, stroke, ccc3(255, 255, 255), texture2d)
	local motionStreak = CocosObject.new(motionStreakObj)
    return motionStreak
end

function FlyTopStarAni:createAnimation(_finishCallback, _reachCallback)
	local animation = {}
	local starIcons = {}
	local iconBtnTopStar = self:getIconBtnTop()

	for i=1, #self.starsWorldPos do
		local motionStreak = self:buildMotionStreak(0.3, 35)
		self.container:addChild(motionStreak) 

		local starIcon = Sprite:createWithSpriteFrame(iconBtnTopStar:getIconGroup():getChildByName("bg"):displayFrame())
		starIcon:setAnchorPoint(ccp(0.5, 0.5))
		starIcon:setScale(0.3)
		starIcon.motionStreak = motionStreak
		self.container:addChild(starIcon)
		starIcon:setPosition(self:convertToNodeSpace(self.starsWorldPos[i]))
		
		table.insert(starIcons, starIcon)
	end

	local function onReach(starIcon)
		if self.isDisposed then return end
		starIcon:setVisible(false)	
		if _reachCallback then _reachCallback() end
	end

	local function onFinish()
		if self.isDisposed then return end
		if _finishCallback then _finishCallback() end
	end

	local flyToConfig = {
		duration = 0.5,
		sprites = starIcons,
		dstPosition = iconBtnTopStar:getFlyToPosition(),
		dstSize = iconBtnTopStar:getFlyToSize(),
		direction = false,
		delayTime = 0.15,
		reachCallback = onReach,	
		finishCallback = onFinish,
	}

	local context = self
	function animation:play()
		context:runAction(CCSequence:createWithTwoActions(
			CCDelayTime:create(kAnimationTime*20),
			CCCallFunc:create(function ()
				context:scheduleUpdateWithPriority(function ()
					if context.isDisposed then return end
					for i,v in ipairs(starIcons) do
						local pos = v:getPosition()
						v.motionStreak:setPosition(ccp(pos.x, pos.y))
					end
				end, 0)
				BezierFlyToAnimation:create(flyToConfig) 		
			end)
			))
	end

	return animation
end

function FlyTopStarAni:create(num, starsWorldPos)
	local ani = FlyTopStarAni.new(CCNode:create())
	ani:init(num, starsWorldPos)
	return ani
end