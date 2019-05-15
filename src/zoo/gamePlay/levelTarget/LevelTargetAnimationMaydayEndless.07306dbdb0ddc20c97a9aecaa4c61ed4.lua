------------------------------------------------
--class LevelTargetAnimationMaydayEndless
------------------------------------------------
LevelTargetAnimationMaydayEndless = class(LevelTargetAnimationOtherMode)
function LevelTargetAnimationMaydayEndless:setTargetNumber( itemType, itemId, itemNum, animate, globalPosition, rotation, percent )
	-- body
	if itemId == 2 then
		self.c2:setTargetNumber(itemId, itemNum, animate, globalPosition)
	else
		self.targetNum = itemNum
		self.c1:setTargetNumber(itemId, itemNum, animate, globalPosition)
		self:__setAnimTextNum(itemNum)
	end
end

function LevelTargetAnimationMaydayEndless:revertTargetNumber( itemType, itemId, itemNum )
	if itemId == 0 then
		self.c1:revertTargetNumber(itemId, itemNum)
	elseif itemId == 2 then 
		self.c2:revertTargetNumber(itemId, itemNum)
	end
end

function LevelTargetAnimationMaydayEndless:__setAnimTextNum( num )
	if type(num) == 'number' then
		for _, text in ipairs(self.anim_texts) do
			if num >=1000 then 
				text:setScale(0.8)
				text:setPosition(ccp(64/2-1, 6))
			end
			text:setText(num)
		end
	end
end

function LevelTargetAnimationMaydayEndless:initGameModeTargets()
	self:createTargets(2,4)  
	self.targetNum = 0
    self.c1 = TargetItemFactory.create(EndlessMayDayTargetItem, self.levelTarget:getChildByName("c1"), 1, self)
	self:initTargetDecoration()
    self:updateTargets()
end

---------------------以下是复写的方法---------------------
-- function LevelTargetAnimationMaydayEndless:shake()
-- end

function LevelTargetAnimationMaydayEndless:playLeafAnimation()
end

function LevelTargetAnimationMaydayEndless:setPosX(posX)
	local size = self.levelTarget:getContentSize()
	local winsize = CCDirector:sharedDirector():getWinSize()
	local vSize = CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local posX = visibleOrigin.x + vSize.width/2 - size.width/2 * self:getTargetScale() + 150 * self:getTargetScale()
	self.levelTarget:setPositionX(posX)
	self.attachSprite:setPositionX(posX)
	self.bgSprite:setPositionX(posX)
end

---------------------以下是新加的方法---------------------
local WeeklyExtraTarget = require "zoo.modules.weekly2017s1.WeeklyExtraTarget"
local WeeklyFriendTarget = require "zoo.modules.weekly2017s1.WeeklyFriendTarget"
local WeeklyExtraTargetBar = require "zoo.modules.weekly2017s1.WeeklyExtraTargetBar"

local WeeklyTargetPosType = {
	k1st = 1,
	k2nd = 2,
}

local WeeklyTargetType = {
	kExtra = 1,
	kFriend = 2,
}

function LevelTargetAnimationMaydayEndless:initTargetDecoration()
	self.extraTargetBar = WeeklyExtraTargetBar:create()
	self.levelTarget:addChild(self.extraTargetBar)
	self.extraTargetBar:setVisible(false)
	self.extraTargetBar:runAction(CCCallFunc:create(function ()
		self.extraTargetBar:setVisible(true)
		local vSize = CCDirector:sharedDirector():getVisibleSize()
		local vOrigin = CCDirector:sharedDirector():getVisibleOrigin()
		local posExtraTarget = self.levelTarget:convertToNodeSpace(ccp(vSize.width/2, vSize.height + vOrigin.y))
		self.extraTargetBar:setPosition(ccp(posExtraTarget.x, posExtraTarget.y))
	end))

	self.c1:setVisible(false)
	self.levelTarget:getChildByName("headIcon"):setVisible(false)

	FrameLoader:loadArmature('skeleton/weekly_2018s1_target', 'weekly_2018s1_target', 'weekly_2018s1_target')

	--头像
	self.need_dispose = {}
	self.anim_texts = {}

	--自己
	self.meTarget = Layer:create()
	self.targetDecoration_normal = ArmatureNode:create('2018_s1_target_anim/ani_float')
	self.targetDecoration_speed_up = ArmatureNode:create('2018_s1_target_anim/ani_speedup')
	self.targetDecoration_get = ArmatureNode:create('2018_s1_target_anim/ani_light')

	for index, animNode in ipairs({self.targetDecoration_normal, self.targetDecoration_speed_up}) do
		local headCon2 = animNode:getCon('head2')
		local headCon2Layer = Layer:create()
		headCon2Layer:ignoreAnchorPointForPosition(false)
		headCon2Layer:setAnchorPoint(ccp(0.5, 0.5))
		headCon2Layer:setContentSize(CCSizeMake(100, 100))
		--把头像加到骨骼动画上
		local function headImageCallback( head )

		end

		local profile = UserManager:getInstance().profile
		local head = HeadImageLoader:create(profile.uid, profile.headUrl, headImageCallback)
		head.name = "head"

		local headCon = animNode:getCon('head')
		local maskedHead = Layer:create()
		local size = headCon:getContentSize()
		local sx = headCon:getScaleX()
		local sy = headCon:getScaleY()
		local headSize = head:getContentSize()
		head:setScaleX(sx * size.width / headSize.width)
		head:setScaleY(sy * size.height / headSize.height)

		headCon2Layer:setScaleX(sx * size.width / headSize.width)
		headCon2Layer:setScaleY(sy * size.height / headSize.height)

		if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName('h0') then
			local defaultHead = Sprite:createWithSpriteFrameName('h0')
			defaultHead:setScaleX(sx * size.width / 100)
			defaultHead:setScaleY(sy * size.height / 100)
			maskedHead:addChild(defaultHead)
		end

		maskedHead:addChild(head)
		maskedHead:setPositionX(sx * size.width/2)
		maskedHead:setPositionY(sy * size.height/2)

		headCon2Layer:setPositionX(sx * size.width/2)
		headCon2Layer:setPositionY(sy * size.height/2)

		headCon:addChild(maskedHead.refCocosObj)
		headCon2:addChild(headCon2Layer.refCocosObj)

		table.insert(self.need_dispose, maskedHead)
		table.insert(self.need_dispose, headCon2Layer)

		--把收集物的数量加上
		local fntFile	= "fnt/target_amount.fnt"
		local text = BitmapText:create("0", fntFile, -1, kCCTextAlignmentRight)
		text:setAnchorPoint(ccp(0.5, 0))
		text:setPositionX(64/2-1)

		table.insert(self.anim_texts, text)
		table.insert(self.need_dispose, text)

		local textCon = animNode:getCon('label')
		textCon:addChild(text.refCocosObj)

		animNode:update(0.001)

		self.meTarget:addChild(animNode)
		animNode:setPosition(ccp(8, -68))

		headImageCallback(head)
	end

	self.levelTarget:addChild(self.meTarget)
	self.meTarget:setPosition(ccp(0, 24))

	local iconCon = self.targetDecoration_normal:getCon('aa')
	iconCon:addChild(self.targetDecoration_get.refCocosObj)
	self.targetDecoration_get:setPosition(ccp(28, 60))

	self:playNormal()

	self.isFirstFriendTarget = true

	self.bgContainer = Layer:create()
	
	self.levelTarget:addChildAt(self.bgContainer, 0)

	local __oldDispose = self.levelTarget.dispose
	self.levelTarget.dispose = function (...)
		__oldDispose(...)
		for _, head in ipairs(self.need_dispose) do
			head:dispose()
		end
	end

	self.c1:setShakeExtraDelegate(function ()
		self:playGet()
	end)
end

function LevelTargetAnimationMaydayEndless:updateTargets()
	LevelTargetAnimationOtherMode.updateTargets(self)
	self.c1:setVisible(false)
end

function LevelTargetAnimationMaydayEndless:playNormal()
	self.targetDecoration_speed_up:setVisible(false)
	self.targetDecoration_get:setVisible(false)
	self.targetDecoration_normal:setVisible(true)

	self.targetDecoration_normal:rma()
	self.targetDecoration_get:rma()
	self.targetDecoration_speed_up:rma()

	if self.targetDecoration_normal and not self.targetDecoration_normal.isDisposed then 
		self.targetDecoration_normal:playByIndex(0, 0)
	end
end

function LevelTargetAnimationMaydayEndless:playGet()
	-- self.targetDecoration_normal:setVisible(false)
	self.targetDecoration_get:setVisible(true)
	-- self.targetDecoration_speed_up:setVisible(false)

	self.targetDecoration_normal:rma()
	self.targetDecoration_get:rma()
	self.targetDecoration_speed_up:rma()

	if self.targetDecoration_get and not self.targetDecoration_get.isDisposed then 
		self.targetDecoration_get:removeAllEventListeners()
		self.targetDecoration_get:addEventListener(ArmatureEvents.COMPLETE, function ()
			self:playNormal()
		end)
		self.targetDecoration_get:playByIndex(0, 1)	
	end

end

function LevelTargetAnimationMaydayEndless:playSpeedUp()
	self.targetDecoration_normal:setVisible(false)
	self.targetDecoration_get:setVisible(false)
	self.targetDecoration_speed_up:setVisible(true)

	self.targetDecoration_normal:rma()
	self.targetDecoration_get:rma()
	self.targetDecoration_speed_up:rma()

	if self.targetDecoration_speed_up and not self.targetDecoration_speed_up.isDisposed then 
		self.targetDecoration_speed_up:removeAllEventListeners()
		self.targetDecoration_speed_up:addEventListener(ArmatureEvents.COMPLETE, function ()
			self:playNormal()
		end)
		self.targetDecoration_speed_up:playByIndex(0, 1)	
	end
end

function LevelTargetAnimationMaydayEndless:setTargetContainer(containerLayer)
	self.containerLayer = containerLayer
end

function LevelTargetAnimationMaydayEndless:createTarget(targetInfo, targetType, targetPosType, isNext)
	local target = nil
	if targetType == WeeklyTargetType.kExtra then 
		target = WeeklyExtraTarget:create(targetInfo)
	elseif targetType == WeeklyTargetType.kFriend then 
		target = WeeklyFriendTarget:create(targetInfo)
	end
	if target then 
		target.targetType = targetType
		target.targetPosType = targetPosType
		local pos = self:getTargetPos(targetType, targetPosType, isNext)
		self.levelTarget:addChildAt(target, 1)
		target:setPosition(ccp(pos.x, pos.y))
		if not isNext then 
			self:playTargetFloat(target)
		end
	end

	return target
end

--bonus阶段会隐藏额外超越目标
function LevelTargetAnimationMaydayEndless:setExtraTargetInvisible()
	if self.extraTargetBar and not self.extraTargetBar.isDisposed then 
		self.extraTargetBar:setVisible(false)
	end
	if self.firstTarget and not self.firstTarget.isDisposed and self.firstTarget.targetType == WeeklyTargetType.kExtra then 
		self.firstTarget:setVisible(false)
	end
	if self.secondTarget and not self.secondTarget.isDisposed and self.secondTarget.targetType == WeeklyTargetType.kExtra then 
		self.secondTarget:setVisible(false)
	end
end

function LevelTargetAnimationMaydayEndless:addTargets(isNext)
	local mainLogic = GameBoardLogic:getCurrentLogic()
	if mainLogic and mainLogic.theGamePlayStatus and mainLogic.theGamePlayStatus == GamePlayStatus.kBonus then 
		--bonus阶段不再生成新的超越目标
		return 
	end

	local extraInfo = SeasonWeeklyRaceManager.getInstance():getNextExtraTargetInfo(self.targetNum)
	local friendInfo 
	if extraInfo then 
		friendInfo = SeasonWeeklyRaceManager.getInstance():getNextPassFriendInfo(self.targetNum, extraInfo.level)
	else
		friendInfo = SeasonWeeklyRaceManager.getInstance():getNextPassFriendInfo(self.targetNum)
	end
	if not isNext then 
		--首次添加（初始化）
		if extraInfo then 
			self.firstTarget = self:createTarget(extraInfo, WeeklyTargetType.kExtra, WeeklyTargetPosType.k1st, isNext)
		end
		if friendInfo then 
			if self.firstTarget then 
				self.secondTarget = self:createTarget(friendInfo, WeeklyTargetType.kFriend, WeeklyTargetPosType.k2nd, isNext)
			else
				self.firstTarget = self:createTarget(friendInfo, WeeklyTargetType.kFriend, WeeklyTargetPosType.k1st, isNext)
			end
		end
	else
		if self.firstTarget and self.firstTarget.needMove then 
			local firstTargetType = self.firstTarget.targetType
			if self.secondTarget then 
				local secondTargetType = self.secondTarget.targetType
				if self.secondTarget.needMove then 
					--两个一起被超越 创建next 1号位和2号位
					if extraInfo then 
						self.firstTargetNext = self:createTarget(extraInfo, WeeklyTargetType.kExtra, WeeklyTargetPosType.k1st, isNext)
						if friendInfo then 
							self.secondTargetNext = self:createTarget(friendInfo, WeeklyTargetType.kFriend, WeeklyTargetPosType.k2nd, isNext)
						end
					elseif friendInfo then 
						self.firstTargetNext = self:createTarget(friendInfo, WeeklyTargetType.kFriend, WeeklyTargetPosType.k1st, isNext)
					end
				else
					--1号位被超越 2号位补到1号位 创建next 2号位
					if firstTargetType == WeeklyTargetType.kExtra then 
						if extraInfo then 
							self.secondTargetNext = self:createTarget(extraInfo, WeeklyTargetType.kExtra, WeeklyTargetPosType.k2nd, isNext)
						end
					elseif firstTargetType == WeeklyTargetType.kFriend then 
						if friendInfo then 
							self.secondTargetNext = self:createTarget(friendInfo, WeeklyTargetType.kFriend, WeeklyTargetPosType.k2nd, isNext)
						end
					end
				end
			else
				--2号位空着  创建next 1号位和2号位
				if extraInfo then 
					self.firstTargetNext = self:createTarget(extraInfo, WeeklyTargetType.kExtra, WeeklyTargetPosType.k1st, isNext)
					if friendInfo then 
						self.secondTargetNext = self:createTarget(friendInfo, WeeklyTargetType.kFriend, WeeklyTargetPosType.k2nd, isNext)
					end
				elseif friendInfo then 
					self.firstTargetNext = self:createTarget(friendInfo, WeeklyTargetType.kFriend, WeeklyTargetPosType.k1st, isNext)
				end
			end
		end
	end
end

function LevelTargetAnimationMaydayEndless:getTargetPos(targetType, targetPosType, isNext)
	local deltaX, deltaY
	if targetType == WeeklyTargetType.kExtra then
		deltaY = -55
	elseif targetType == WeeklyTargetType.kFriend then 
		deltaY = -50
	end

	if targetPosType == WeeklyTargetPosType.k1st then 
		if isNext then 
			deltaX = -950
		else
			deltaX = -150
		end
	elseif targetPosType == WeeklyTargetPosType.k2nd then
		if isNext then
			deltaX = -1100
		else
			deltaX = -300
		end
	end

	return {x = deltaX, y = deltaY}
end

function LevelTargetAnimationMaydayEndless:playTargetFloat(target)
	if not target or target.isDisposed then return end
	target:playAnim()
end

function LevelTargetAnimationMaydayEndless:playTargetMove(friendTarget, moveTime, moveDelta, endCallback)
	if not friendTarget or friendTarget.isDisposed then return end
	friendTarget:stopAllActions()
	friendTarget:runAction(CCSequence:createWithTwoActions(CCMoveBy:create(moveTime, ccp(moveDelta, 0)), CCCallFunc:create(function ()
		if endCallback then endCallback() end
	end)))
end

function LevelTargetAnimationMaydayEndless:playPassTarget(endCallback)
	if self.isDisposed then return end
	--添加下一个超越目标（可能没有）
	self:addTargets(true)
	local curFirstTarget = self.firstTarget
	local nextFirstTarget = self.firstTargetNext
	local curSecondTarget = self.secondTarget
	local nextSecondTarget = self.secondTargetNext
	self.firstTarget = nil
	self.firstTargetNext = nil
	self.secondTarget = nil
	self.secondTargetNext = nil

	if not nextFirstTarget and not nextSecondTarget then 
		if not curSecondTarget or (curSecondTarget and curSecondTarget.needMove) then 
			if self.meTarget then 
				--后续没有目标了 自己前进至屏幕正中
				local moveTime = 1.6
				local moveDelta = -120 
				self.c1.icon:runAction(CCMoveBy:create(moveTime, ccp(moveDelta, 0)))
				self.meTarget:runAction(CCMoveBy:create(moveTime, ccp(moveDelta, 0)))
			end
		end
	end

	if curFirstTarget and curFirstTarget.needMove then 
		local moveTime1 = 1.6
		local moveDelta1 = 800 
		curFirstTarget:setBubbleTipVisible(false)
		self:playTargetMove(curFirstTarget, moveTime1, moveDelta1, function ()
			if self.isDisposed then return end
			curFirstTarget:removeFromParentAndCleanup(true)
			curFirstTarget = nil
			if endCallback then endCallback() end 
		end)
		
		if curFirstTarget.targetType == WeeklyTargetType.kExtra then 
			self.extraTargetBar:showGetTarget()
		end

		if curSecondTarget then 
			if curSecondTarget.needMove then
				curSecondTarget:setBubbleTipVisible(false)
				self:playTargetMove(curSecondTarget, moveTime1, moveDelta1, function ()
					if self.isDisposed then return end
					curSecondTarget:removeFromParentAndCleanup(true)
					curSecondTarget = nil
					-- if endCallback then endCallback() end 
				end)

				if curSecondTarget.targetType == WeeklyTargetType.kExtra then 
					self.extraTargetBar:showGetTarget()
				end
			else
				local moveTime2 = 1.6
				local moveDelta2 = 150 
				curSecondTarget:setBubbleTipVisible(false)
				self:playTargetMove(curSecondTarget, moveTime2, moveDelta2, function ()
					if self.isDisposed then return end
					curSecondTarget:setBubbleTipVisible(true)
					self.firstTarget = curSecondTarget
					curSecondTarget = nil
					-- if endCallback then endCallback() end 
				end)
			end
		end

		if nextFirstTarget then 
			self:playTargetMove(nextFirstTarget, moveTime1, moveDelta1, function ()
				if self.isDisposed then return end
				self.firstTarget = nextFirstTarget
				self:playTargetFloat(nextFirstTarget)
			end)
		end

		if nextSecondTarget then 
			self:playTargetMove(nextSecondTarget, moveTime1, moveDelta1, function ()
				if self.isDisposed then return end
				self.secondTarget = nextSecondTarget
				self:playTargetFloat(nextSecondTarget)
			end)
		end

		--播放自身潜艇动画
		self:playSpeedUp()
		--背景滚动
		local gamePlaySceneUI = GameBoardLogic:getCurrentLogic().PlayUIDelegate
		if gamePlaySceneUI and gamePlaySceneUI.gameBgNode then 
			gamePlaySceneUI.gameBgNode:startScroll(moveDelta1, moveTime1)
		end
	end
end

function LevelTargetAnimationMaydayEndless:handlePassFriendTarget(endCallback)
	if self.targetNum > 0 then 
		if self.secondTarget then 
			if self.targetNum >= self.secondTarget:getTargetNum() then 
				self.firstTarget.needMove = true
				self.secondTarget.needMove = true
				self:playPassTarget(endCallback)
				return true
			end
		end
		if self.firstTarget then 
			if self.targetNum >= self.firstTarget:getTargetNum() then 
				self.firstTarget.needMove = true
				self:playPassTarget(endCallback)
				return true
			end
		end
	end
	return false
end
