require "zoo.panel.basePanel.BasePanel"

RemindAskingEnergyPanel = class(BasePanel)

function RemindAskingEnergyPanel:create(energyPanel, posY)
	local panel = RemindAskingEnergyPanel.new()
	panel:_init(energyPanel, posY)
	return panel
end

function RemindAskingEnergyPanel:_init(energyPanel, posY)
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	self.energyPanel = energyPanel

	self:loadRequiredResource(PanelConfigFiles.AskForEnergyPanel)

	self.panel = self:buildInterfaceGroup("remindaskingenergypanel")
	self:init(self.panel)

	local bg = self.panel:getChildByName("bg")
	local itemBg = self.panel:getChildByName("itemBg")
	local title = self.panel:getChildByName("title")
	local itemTitle = self.panel:getChildByName("itemTitle")
	local item = self.panel:getChildByName("item")
	local num = self.panel:getChildByName("num")
	local desc = self.panel:getChildByName("desc")
	self.button = self.panel:getChildByName("button")

	local sSize = bg:getGroupBounds().size
	local pSize = energyPanel:getGroupBounds().size
	local pScale = energyPanel:getScaleX()
	self:setPositionX(self:getHCenterInScreenX())
	self:setPositionY(posY + 100 - vSize.height - vOrigin.y)

	local builder = InterfaceBuilder:create("flash/gameguide/guideelem.json")
	local group = builder:buildGroup("guide_info_panelS")
	local newBg = group:getChildByName("_bg")
	local newBg2 = group:getChildByName("_bg2")
	newBg:removeFromParentAndCleanup(false)
	newBg2:removeFromParentAndCleanup(false)
	group:dispose()
	local index = self.panel:getChildIndex(bg)
	local size = bg:getGroupBounds().size
	newBg:setPreferredSize(CCSizeMake(size.width, size.height))
	newBg2:setPreferredSize(CCSizeMake(size.width - 34, size.height - 34))
	self.panel:addChildAt(newBg2, index)
	self.panel:addChildAt(newBg, index)
	bg:removeFromParentAndCleanup(true)

	title:setString(Localization:getInstance():getText("energy.panel.remind.asking.title",
		{max = MetaManager:getInstance():getDailyMaxReceiveGiftCount()}))
	itemTitle:setString(Localization:getInstance():getText("energy.panel.remind.asking.itemdesc"))
	desc:setString(Localization:getInstance():getText("energy.panel.remind.asking.desc",
		{friend = FriendManager:getInstance():getFriendCount(), n = '\n'}))
	self.button:getChildByName("text"):setString(Localization:getInstance():getText("energy.panel.remind.asking.button"))

	num:setText('x'..tostring(MetaManager:getInstance():getDailyMaxReceiveGiftCount() -
		UserManager:getInstance():getDailyData():getReceiveGiftCount()))
	local nSize = num:getContentSize()
	num:setPositionX(itemBg:getPositionX() + itemBg:getGroupBounds().size.width - nSize.width - 20)
	builder = InterfaceBuilder:create("flash/common/properties.json")
	local icon = builder:buildGroup("Prop_10012")
	icon:setPositionXY(item:getPositionX(), item:getPositionY())
	index = self.panel:getChildIndex(item)
	self.panel:addChildAt(icon, index)
	item:removeFromParentAndCleanup(true)

	local function onClick()
		createAddFriendPanel("recommend")
		self:onCloseBtnTapped()
	end
	self.button:setTouchEnabled(true)
	self.button:addEventListener(DisplayEvents.kTouchTap, onClick)

	self.anim = CommonSkeletonAnimation:createTutorialMoveIn2()
	self.anim:stop()
	self:addChild(self.anim)
	self.removeDirection = "remove"
	self:scaleAccordingToResolutionConfig()
	self:setPositionX(self:getHCenterInScreenX())
end

function RemindAskingEnergyPanel:popout(position)
	PopoutManager:sharedInstance():add(self, false, true)
	if position then
		local pos = self.panel:convertToNodeSpace(ccp(position.x, position.y))
		self.anim:setScaleX(-1)
		self.anim:setPositionXY(pos.x - 50, pos.y + 125)
		self.removeDirection = "left"
	else
		local pos1 = self.button:getPosition()
		local size = self.button:getGroupBounds().size
		pos1.x, pos1.y = pos1.x + size.width * 0.8, pos1.y - size.height
		local pos2 = self.panel:convertToWorldSpace(ccp(pos1.x, pos1.y))
		local pos = self:convertToNodeSpace(ccp(pos2.x, pos2.y))
		self.anim:setPositionXY(pos.x + 50, pos.y + 125)
		self.removeDirection = "right"
	end
	local posX, posY = self.panel:getPositionX(), self.panel:getPositionY()
	self.panel:setPositionX(-1300)
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(0.2))
	arr:addObject(CCEaseBackOut:create(CCMoveTo:create(0.3, ccp(posX, posY))))
	local function enableClose() self.allowBackKeyTap = true end
	arr:addObject(CCCallFunc:create(enableClose))
	self.panel:stopAllActions()
	self.panel:runAction(CCSequence:create(arr))
	self.anim:playByIndex(0)
	local arr2 = CCArray:create()
	arr2:addObject(CCDelayTime:create(2.2))
	local function onStop() self.anim:stop() end
	arr2:addObject(CCCallFunc:create(onStop))
	self.anim:stopAllActions()
	self.anim:runAction(CCSequence:create(arr2))
end

function RemindAskingEnergyPanel:remove()
	local function onAllOver() PopoutManager:sharedInstance():remove(self) end
	if self.removeDirection == "remove" then
		self.anim:removeFromParentAndCleanup(true)
	elseif self.removeDirection == "left" then
		self.anim:runAction(CCMoveBy:create(0.2, ccp(-1000, 0)))
	elseif self.removeDirection == "right" then
		self.anim:runAction(CCMoveBy:create(0.2, ccp(1000, 0)))
	end
	local arr = CCArray:create()
	arr:addObject(CCEaseBackIn:create(CCMoveBy:create(0.1, ccp(-1000, 0))))
	arr:addObject(CCCallFunc:create(onAllOver))
	self.panel:stopAllActions()
	self.panel:runAction(CCSequence:create(arr))
end

function RemindAskingEnergyPanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	self:remove()
end