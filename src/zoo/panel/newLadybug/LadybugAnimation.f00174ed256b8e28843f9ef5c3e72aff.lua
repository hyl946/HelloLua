local function createArmature( name )
    local anim = ArmatureNode:create(name)
    anim:unscheduleUpdate()

    local scheduleNode = CocosObject:create()
    anim:addChild(scheduleNode)
    scheduleNode:scheduleUpdateWithPriority(function( dt )
        anim.refCocosObj:advanceTime(math.min(1/30,dt))
    end,0)

    return anim
end

local isPlayingAnim = false

local LadybugAnimation = class(Layer)

function LadybugAnimation:create( showRewardIcon, delay )
	local anim = LadybugAnimation.new()
	anim:initLayer()
	anim:__init(showRewardIcon, delay)
	return anim
end

function LadybugAnimation:isPlayingAnim( ... )
	return isPlayingAnim
end

function LadybugAnimation:__init( showRewardIcon, delay)

	self.showRewardIcon = showRewardIcon
	self.delay = delay

	FrameLoader:loadArmature("skeleton/newladybug", 'newladybug', 'newladybug')

	self.boxAnimNode = createArmature('new.lady.bug.anim/disapper')
	self.lightAnimNode = createArmature('new.lady.bug.anim/light')

	self:addChild(self.boxAnimNode)
	self:addChild(self.lightAnimNode)

	self.lightAnimNode:setVisible(false)
	self.lightAnimNode:setScale(0.219)


end

function LadybugAnimation:setLadybugIcon( icon )
	self.icon = icon
end

function LadybugAnimation:setNoticeButton( button )
	self.noticeButton = button
end

function LadybugAnimation:play( ... )
	local curScene = Director:sharedDirector():getRunningScene()
	if (not curScene) or (not curScene:is(HomeScene)) then

		return
	end

	if (not self.noticeButton) or self.noticeButton.isDisposed then
		return
	end

	if (not self.icon) or self.icon.isDisposed then
		return
	end

	local noticeBounds = self.noticeButton:getGroupBounds()
	local iconBounds = self.icon.rewardIcon:getGroupBounds()

	if curScene and curScene.worldScene and curScene.worldScene.frontItemLayer then
		curScene.worldScene.frontItemLayer:addChild(self)
	else
		return
	end

	-- curScene:addChild(self)

	isPlayingAnim = true

	curScene:runAction(CCCallFunc:create(function ( ... )
		if self.isDisposed then
			self:onAnimFinish()
			return
		end

		local curScene = Director:sharedDirector():getRunningScene()
		if (not curScene) or (not curScene:is(HomeScene)) then
			self:onAnimFinish()
			return
		end

		
		local pos = ccp(noticeBounds:getMidX(), noticeBounds:getMidY())
		pos = self:convertToNodeSpace(pos)
		self.boxAnimNode:setPosition(ccp(pos.x, pos.y))


		local pos2 = ccp(iconBounds:getMidX(), iconBounds:getMidY())
		pos2 = self:convertToNodeSpace(pos2)
		self.lightAnimNode:setPosition(ccp(pos2.x, pos2.y))


		self.boxAnimNode:addEventListener(ArmatureEvents.COMPLETE, function ( ... )
			if self.isDisposed then 
				self:onAnimFinish()
				return 
			end

			require "zoo.scenes.component.HomeScene.flyToAnimation.FlySpecialItemAnimation"


			local pos = self:convertToWorldSpace(pos)
			local pos2 = ccp(iconBounds:getMidX(), iconBounds:getMidY())

			local flyAnim = FlySpecialItemAnimation:create(
				{itemId=-1, num=1}, 
				'new.lady.bug.sp/ladybuy.box.sym0000', 
				ccp(pos2.x, pos2.y),
				false
			)
			flyAnim:setWorldPosition(ccp(pos.x, pos.y))

			flyAnim:setFinishCallback(function ( ... )
				if self.isDisposed then 
					self:onAnimFinish()
					return 
				end

				if self.showRewardIcon then

					if self.iconShowCallback then
						self.iconShowCallback()
					end

					self.lightAnimNode:setVisible(true)
					self.lightAnimNode:addEventListener(ArmatureEvents.COMPLETE, function ( ... )
						if self.isDisposed then 
							self:onAnimFinish()
							return 
						end
						self:removeFromParentAndCleanup(true)
						self:onAnimFinish()

					end)

					self.lightAnimNode:playByIndex(0)
				else
					self:removeFromParentAndCleanup(true)
					self:onAnimFinish()					
				end

			end)

			flyAnim:play()
		end)

		

		if self.delay then
			self:setVisible(false)
			self:runAction(CCSequence:createWithTwoActions(
				CCDelayTime:create(self.delay), 
				CCCallFunc:create(function ( ... )
					if self.isDisposed then return end
					self:setVisible(true)
					self.boxAnimNode:playByIndex(0, 1)
				end)
			))

		else
			self.boxAnimNode:playByIndex(0, 1)
		end

	end))

	
end

function LadybugAnimation:dispose( ... )
	Layer.dispose(self, ...)
    ArmatureFactory:remove('newladybug', 'newladybug')
end

function LadybugAnimation:setIconShowCallback( callback )
	self.iconShowCallback = callback
end

function LadybugAnimation:onAnimFinish( ... )
	isPlayingAnim = false
	if not PopoutManager:haveWindowOnScreen() then

		if _G.isStartPanelAutoPopoutForWorldScene then
		--	【下一关优化】下一关是瓢虫目标，当前关过关关闭结束界面，弹出下一关开始界面
			HomeScene:sharedInstance().worldScene:startLevel(UserManager:getInstance().user:getTopLevelId())
		end

	end
end

return LadybugAnimation
