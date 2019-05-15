local BaseMarkPanel = MarkPanel

NationalDayMarkPanel = class(BaseMarkPanel)

function NationalDayMarkPanel:create( scaleOriginPosInWorld )
	local markPanel = NationalDayMarkPanel.new()
	markPanel:loadRequiredResource("ui/eggs/ten_one.json")
	markPanel:init(scaleOriginPosInWorld)
	return markPanel
end

function NationalDayMarkPanel:init( scaleOriginPosInWorld )
	BaseMarkPanel.init(self, scaleOriginPosInWorld)
	self.newCaptain:setVisible(false)
	self.trunkHead = Sprite:createWithSpriteFrameName('a/trunkHead0000')
	self.trunkHead:setVisible(false)
	self.ui:getChildByName('signed'):addChild(self.trunkHead)
	self:showTrunkHead()
	self.refreshData = self._refreshData
end

function NationalDayMarkPanel:getHCenterInParentX()
	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local selfWidth		= self:getGroupBounds().size.width

	local deltaWidth	= visibleSize.width - selfWidth
	local halfDeltaWidth	= deltaWidth / 2
	return halfDeltaWidth
end

function NationalDayMarkPanel:updateANewMark(finishCallback)
	if self.isDisposed then return end
	
	BaseMarkPanel.updateANewMark(self, finishCallback)

	if self.signed[self.signedDay - 1] then
		self.signed[self.signedDay - 1]:setVisible(true)
	else
		self.nodeOrigin:setVisible(true)
	end

	self:showTrunkHead()
end

function NationalDayMarkPanel:showTrunkHead()
	local lastSigned = self.signed[self.signedDay]

	if not lastSigned then
		lastSigned = self.nodeOrigin
	end

	if lastSigned then
		lastSigned:setVisible(false)
		local pos = lastSigned:getGroupBounds(lastSigned:getParent()).origin

		if lastSigned:getRotation() ~= 0 then
			pos.y = self.signed[self.signedDay-1]:getGroupBounds(lastSigned:getParent()).origin.y
		end

		self.trunkHead:setVisible(true)
		self.trunkHead:setAnchorPoint(ccp(0, 0))
		self.trunkHead:setPosition(ccp(pos.x, pos.y))
	end

	if self.signedDay >= 7 and self.signedDay <= 13 then
		self.trunkHead:setFlipX(true)
		self.trunkHead.deltaX = -8
	elseif self.signedDay >= 21 and self.signedDay <= 27 then
		self.trunkHead:setFlipX(true)
		self.trunkHead.deltaX = -8
	else
		self.trunkHead:setFlipX(false)
		self.trunkHead.deltaX = 0
	end
	self.trunkHead:setPositionX(self.trunkHead:getPositionX() + self.trunkHead.deltaX )
end

function NationalDayMarkPanel:_refreshData(...)
	BaseMarkPanel.refreshData(self, ...)
	self:showTrunkHead()
end

function NationalDayMarkPanel:playBoxOpen(index)
	local function BoxOpened()
		self.notSigned[index]:setVisible(false)
	end
	local pos = self.notSigned[index]:getPosition()
	self.notSigned[index]:setAnchorPoint(ccp(0.5, -1))
	local size = self.notSigned[index]:getGroupBounds().size
	self.notSigned[index]:setPosition(ccp(pos.x + size.width / 2, pos.y - 2 * size.height))
	self.notSigned[index]:runAction(CCSequence:createWithTwoActions(CCSkewTo:create(0.2, -5, 0), CCCallFunc:create(BoxOpened)))
end

-- MarkPanel = NationalDayMarkPanel


local BaseUpdateSuccessPanel = UpdateSuccessPanel

NationalDayUpdateSuccessPanel = class(BaseUpdateSuccessPanel)

function NationalDayUpdateSuccessPanel:create(rewards)
	local instance = NationalDayUpdateSuccessPanel.new()
	instance:loadRequiredResource(PanelConfigFiles.update_new_version_panel)
	FrameLoader:loadArmature("skeleton/NationalDay")
	FrameLoader:loadImageWithPlist("ui/eggs/ten_one.plist")
	instance:init(rewards)
	return instance
end

function NationalDayUpdateSuccessPanel:init(rewards)
	BaseUpdateSuccessPanel.init(self, rewards)
	self.animNode = ArmatureNode:create("national21321321/dgthj")
	self.ui:setVisible(false)
	self.animLayer = Layer:create()
	self:addChild(self.animLayer)
	self.animLayer:addChild(self.animNode)

	local buttonSlot = self.animNode:getSlot("anniu")
	local button = tolua.cast(buttonSlot:getCCDisplay(),"CCSprite")

	local inputLayer = Layer:create()
	inputLayer:setTouchEnabled(true, 0, true)
	inputLayer:registerScriptTouchHandler(function(eventType, x, y)
		local box = HeDisplayUtil:getNodeGroupBounds(button, nil, kHitAreaObjectTag)
		if box:containsPoint(ccp(x, y)) then
			inputLayer:setTouchEnabled(false)
			self:onOkTapped()
		end
		return true
	end)

	self:addChild(inputLayer)
	self.__rewards = rewards
end

function NationalDayUpdateSuccessPanel:dispose()
	FrameLoader:unloadImageWithPlists({'ui/eggs/ten_one.plist'})
	-- ArmatureFactory:remove('NationalDay', 'NationalDay')
	BaseUpdateSuccessPanel.dispose(self)
	FrameLoader:unloadArmature('skeleton/NationalDay', true)
end

function NationalDayUpdateSuccessPanel:play()
	self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.05), CCCallFunc:create(
		function()
			self.animNode:playByIndex(0, 1)
		end
	)))
end

function NationalDayUpdateSuccessPanel:popout()
	self.popoutShowTransition = function( ... )
		self:play()
	end
	local visibleSize = Director.sharedDirector():getVisibleSize()
	local bounds = self:getGroupBounds()
	self:setPositionY(-visibleSize.height/2 + bounds.size.height/2)
	BaseUpdateSuccessPanel.popout(self)
end

function NationalDayUpdateSuccessPanel:onOkTapped()
	self.confirm:setEnabled(false)
	local function onSuccess( evt )
        DcUtil:UserTrack({ category='update', sub_category='get_update_reward' })
	    UserManager.getInstance().updateRewards = nil
	    UserManager.getInstance().preRewards = nil
	    UserManager.getInstance().preRewardsFlag = true
	    if self.isDisposed then
	    	return
	    end
	    -- 注释掉因为暂时不用了 再启用请加打点
	    assert(false, "look at here!")
	    -- UserManager:getInstance():addRewards(self.items)
	    -- UserService:getInstance():addRewards(self.items)
	    HomeScene:sharedInstance():checkDataChange()
	    require "zoo.scenes.component.HomeScene.flyToAnimation.OpenBoxAnimation"
	    local boxRes = CCSprite:createWithSpriteFrameName('gift0000')
	    boxRes:retain()
		local animation = OpenBoxAnimation:create(self.__rewards, boxRes)
		animation:setFinishCallback(function() 
			self:onCloseBtnTapped()
		end)
		animation:play()
		self:setVisible(false)
	end
	local function onFail( evt ) 
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(evt.data)), "negative")
	   	UserManager.getInstance().updateRewards = nil
	   	UserManager.getInstance().preRewards = nil
	    UserManager.getInstance().preRewardsFlag = true
	    if self.isDisposed then
	    	return
	    end
		self:onCloseBtnTapped()
	end
	local function onCancel(evt)
	  	UserManager.getInstance().updateRewards = nil
	  	UserManager.getInstance().preRewards = nil
	    UserManager.getInstance().preRewardsFlag = true
	    if self.isDisposed then
	    	return
	    end
		self.confirm:setEnabled(true)
	end
	local http = GetUpdateRewardHttp.new(true)
	http:ad(Events.kComplete, onSuccess)
	http:ad(Events.kError, onFail)
	http:ad(Events.kCancel, onCancel)
	http:load()
end

-- UpdateSuccessPanel = NationalDayUpdateSuccessPanel