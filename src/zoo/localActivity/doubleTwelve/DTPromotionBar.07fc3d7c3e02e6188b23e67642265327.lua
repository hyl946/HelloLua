--=====================================================
-- DTPromotionBar 
-- by zhijian.li
-- (c) copyright 2009 - 2016, www.happyelements.com
-- All Rights Reserved. 
--=====================================================
-- filename:  DTPromotionBar.lua
-- author:    zhijian.li
-- e-mail:    zhijian.li@happyelements.com
-- created:   2016/11/21
-- descrip:   2016双十二活动 商店风车币促销ui组件
--=====================================================
DTPromotionBar = class(BaseUI)
function DTPromotionBar:ctor()
	
end

function DTPromotionBar:init()
	BaseUI.init(self, self.ui)
	self.barBg = self.ui:getChildByName("bg")
	local bgSize = self.barBg:getContentSize()
	self.bgSizeWidth = bgSize.width + 2
	self.bgSizeHeight = bgSize.height 

	self.lightPos = self.ui:getChildByName("lightPos")
	self.lightPos:setOpacity(0)

	self.label = self.ui:getChildByName("label")
	self.iconBg = self.ui:getChildByName("iconBg")
	self.countdown = self.ui:getChildByName("countdown")
	self.numLabel = self.ui:getChildByName("num")
end

function DTPromotionBar:showAnimation(moveTime, moveDelta)
	self:setVisible(true)
	self.barBg:setOpacity(0)
	local arr1 = CCArray:create()
	arr1:addObject(CCMoveBy:create(0, ccp(0, moveDelta)))
	arr1:addObject(CCEaseSineOut:create(CCMoveBy:create(moveTime, ccp(0, -moveDelta))))
	self.ui:runAction(CCSequence:create(arr1))

	local arr2 = CCArray:create()
	arr2:addObject(CCFadeTo:create(moveTime/2, 255))
	arr2:addObject(CCDelayTime:create(moveTime/2))
	arr2:addObject(CCCallFunc:create(function ()	
		if self.isDisposed then return end
		self:showLight()
	end))
	self.barBg:runAction(CCSequence:create(arr2))
end

function DTPromotionBar:hideAnimation(moveTime, moveDelta)
	local arr1 = CCArray:create()
	arr1:addObject(CCEaseSineOut:create(CCMoveBy:create(moveTime, ccp(0, moveDelta))))
	arr1:addObject(CCMoveBy:create(0, ccp(0, -moveDelta)))
	self.ui:runAction(CCSequence:create(arr1))

	local arr2 = CCArray:create()
	arr2:addObject(CCDelayTime:create(moveTime/2))
	arr2:addObject(CCFadeOut:create(moveTime/2))
	arr2:addObject(CCCallFunc:create(function ()
		self:setVisible(false)
	end))
	self.barBg:runAction(CCSequence:create(arr2))
end

function DTPromotionBar:showLight()
	self:setVisible(true)
	local lightMoveAni = LightMoveAnimation:create(self.bgSizeWidth, self.bgSizeHeight, 0.4, 70)
	self.lightPos:addChild(lightMoveAni)
	lightMoveAni:setPosition(ccp(self.bgSizeWidth/2, self.bgSizeHeight/2))
	lightMoveAni:play(function ()
		if self.isDisposed then return end
		lightMoveAni:removeFromParentAndCleanup(true)
	end)
end

function DTPromotionBar:updateData(data)
	self.goldLevel = data.goldLevel
	self.time = data.time / 1000
	self.itemId = data.itemId
	self.itemNum = data.itemNum

	self:updateRewardShow()
	self:startTimer()
end

function DTPromotionBar:updateRewardShow()
	if self.iconSprite then 
		self.iconSprite:removeFromParentAndCleanup(true)
		self.iconSprite = nil
		self.numLabel:setString("")
	end
	local builder = InterfaceBuilder:create(PanelConfigFiles.properties)
	local iconItemId = ItemType:getRealIdByTimePropId(self.itemId) 
	self.iconSprite = builder:buildGroup("Prop_"..tostring(iconItemId))
	local iSize = self.iconBg:getGroupBounds().size
	local sSize = self.iconSprite:getGroupBounds().size
	self.iconSprite:setScale(iSize.height / sSize.height)
	self.iconBg:addChild(self.iconSprite)
	self.iconSprite:setPositionXY(0, iSize.height)
	self.numLabel:setString("x".. self.itemNum)
end

function DTPromotionBar:startTimer(countdownTime)
	if self.timer then 
		self.timer:stop()
		self.timer = nil
	end
	local function onTick()
		if self.isDisposed then
			return
		end

		if self.countdownTime > 0 then
			self.countdown:setString(convertSecondToHHMMSSFormat(self.countdownTime))
			self.countdownTime = self.time - Localhost:timeInSec()
		else
			if self.timer.started == true then
				self.countdown:setString(convertSecondToHHMMSSFormat(0))
				self.timer:stop()
			end
			if self.parentView and self.parentView.cleanPromotionBarAndData then 
				self.parentView:cleanPromotionBarAndData()
			end
		end
	end
	self.countdownTime = self.time - Localhost:timeInSec()
	self.timer = OneSecondTimer:create()
	self.timer:setOneSecondCallback(onTick)
	self.timer:start()
	onTick()
end

function DTPromotionBar:addReward(endCallback)
	local bounds = self.iconSprite:getGroupBounds()
	local posX = bounds:getMidX()
	local posY = bounds:getMidY()

	DcUtil:activity{game_type = "share", game_name = "DoubleTwelve", category="other", sub_category="DoubleTwelve2016_ios", t2=self.itemId, num=self.itemNum, gold = self.goldLevel}

	if self.itemId == ItemType.GOLD then 
		local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
		local toWorldPosX = 190 + visibleOrigin.x
		local toWorldPosY = 65 + visibleOrigin.y

		local anim = FlyGoldToAnimation:create(self.itemNum, ccp(toWorldPosX - 150,toWorldPosY))
		anim:setWorldPosition(ccp(posX,posY))
		anim:setFinishCallback(function()
			local scene = Director.sharedDirector():getRunningScene()
			if scene then
				local animLabel = TextField:create("+" .. self.itemNum,"",30)
				animLabel:setAnchorPoint(ccp(0.5,0.5))
				animLabel:setPositionXY(toWorldPosX - 30 ,toWorldPosY)
				animLabel:setColor(ccc3(0x35,0x11,0x19))
				scene:addChild(animLabel)

				local actions = CCArray:create()
				actions:addObject(CCMoveBy:create(0.8,ccp(0,42)))
				actions:addObject(CCCallFunc:create(function()
					animLabel:removeFromParentAndCleanup(true)
				end))
				animLabel:runAction(CCSequence:create(actions))

				actions = CCArray:create()
				actions:addObject(CCDelayTime:create(0.4))
				actions:addObject(CCFadeOut:create(0.4))
				animLabel:runAction(CCSequence:create(actions))
			end
			local user = UserManager:getInstance():getUserRef()
			local serv = UserService:getInstance():getUserRef()
			user:setCash(user:getCash() + self.itemNum)
			serv:setCash(serv:getCash() + self.itemNum)

			if endCallback then endCallback() end
		end)
		anim:play()
	else
		local anim = FlyItemsAnimation:create({{itemId = self.itemId, num = self.itemNum}})
		anim:setScale(1.8)
		anim:setWorldPosition(ccp(posX, posY))
		anim:setFinishCallback(function()
			UserManager:getInstance():addUserPropNumber(self.itemId, self.itemNum)
            UserService:getInstance():addUserPropNumber(self.itemId, self.itemNum)

			if endCallback then endCallback() end
		end)
		anim:play()
	end
end

function DTPromotionBar:create(ui, parentView)
	local bar = DTPromotionBar.new()
	bar.ui = ui
	bar.parentView = parentView
	bar:init()
	return bar
end