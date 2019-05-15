--=====================================================
-- DTPromotionBanner
-- by zhijian.li
-- (c) copyright 2009 - 2016, www.happyelements.com
-- All Rights Reserved. 
--=====================================================
-- filename:  DTPromotionBanner.lua
-- author:    zhijian.li
-- e-mail:    zhijian.li@happyelements.com
-- created:   2016/11/29
-- descrip:   2016双十二活动 商店风车币促销ui组件
--=====================================================

DTPromotionBanner = class(BaseUI)

function DTPromotionBanner:ctor()
	
end

function DTPromotionBanner:init()
	self.builder = InterfaceBuilder:createWithContentsOfFile(PanelConfigFiles.buy_gold_items)
	self.ui = self.builder:buildGroup("2016_double_twelve/adProBar")
	BaseUI.init(self, self.ui)

	self.levelUI = self.ui:getChildByName("level")
	self.iconUI = self.ui:getChildByName("targetIconPlaceHolder")
	self.iconUI:setOpacity(0)
	self.numUI = self.ui:getChildByName("num")

	local data = DTPromotionManager.getInstance():getAndroidPromotionData() 
	if data then 
		self.goldPirce = data.goldPirce
		self.itemId = data.itemId
		self.itemNum = data.itemNum
		if self.goldPirce and self.itemId and self.itemNum then
			self.levelUI:setText(self.goldPirce)
			local posOri = self.levelUI:getPosition()
			local posX, posY = self:getLevelPosAdjust(self.goldPirce)
			self.levelUI:setPositionXY(posOri.x + posX, posOri.y + posY)
			self.numUI:setText(self.itemNum)
			self:initItemIcon()
		else
			return false 
		end
	else
		return false
	end

	DcUtil:activity{game_type = "share", game_name = "DoubleTwelve", category = "other", sub_category = "DoubleTwelve2016_android_trigger", t2=self.goldPirce}
	return true
end

function DTPromotionBanner:getLevelPosAdjust(goldPrice)
	local posX = 0
	local posY = 0
	if not goldPrice then return posX, posY end
	goldPrice = tonumber(goldPrice)
	if goldPrice == DTAndroidGoldLevel.kLv1 then 
		posX = 20
		posY = 2
	end

	return posX, posY
end

function DTPromotionBanner:initItemIcon()
	local builder = InterfaceBuilder:create(PanelConfigFiles.properties)
	self.iconSprite = builder:buildGroup("Prop_"..tostring(self.itemId))
	local iSize = self.iconUI:getGroupBounds().size
	local sSize = self.iconSprite:getGroupBounds().size
	self.iconSprite:setScale(iSize.height / sSize.height)
	local holderIndex = self.ui:getChildIndex(self.iconUI)
	self.iconSprite:setPositionXY(self.iconUI:getPositionX(), self.iconUI:getPositionY())
	self.ui:addChildAt(self.iconSprite, holderIndex)
end

function DTPromotionBanner:getUISize()
	return self.ui:getGroupBounds().size
end

function DTPromotionBanner:addReward(endCallback)
	local bounds = self.iconSprite:getGroupBounds()
	local posX = bounds:getMidX()
	local posY = bounds:getMidY()

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

function DTPromotionBanner:create()
	local banner = DTPromotionBanner.new()
	if banner:init() then 
		return banner
	else
		return nil 
	end
end


