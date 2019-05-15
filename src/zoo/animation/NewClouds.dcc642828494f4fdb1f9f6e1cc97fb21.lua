NewClouds = class(Layer)

local armatureHasLoaded = false

function NewClouds:create(state , cloudId)
	local cloud = NewClouds.new()
	Layer.initLayer( cloud )
	cloud:initCloudAnimation(state , cloudId)
	return cloud
end

function NewClouds:initCloudAnimation(state , cloudId)
	if not armatureHasLoaded then 
		armatureHasLoaded = true 
		FrameLoader:loadArmature("skeleton/world_scene_animation")
	end
	self:rebuildArmature(cloudId)
	self:changeState( state , false , cloudId )
end

function NewClouds:rebuildArmature(cloudId)
	local lock_bg = nil
	local lock_fg = nil

	local function reinitTouchLayer(armatureType)
		if self.touchLayer then 
			self.touchLayer:setTouchEnabled(false)
			self.touchLayer:removeAllEventListeners()
			self.touchLayer:removeFromParentAndCleanup(true) 
			self.touchLayer = nil
		end
		self.touchLayer = LayerColor:create()
		self.touchLayer:setOpacity(0)
		self.touchLayer:setColor((ccc3(0,0,0)))
		local layerWidth = 400
		local layerHeight = 200
		local posXDelta = 0
		local posYDelta = 10
		if armatureType == 4 then 
			layerHeight = 300
			posYDelta = 20
		elseif armatureType == 3 then 
			layerHeight = 280
			posXDelta = 15
			posYDelta = -90
		elseif armatureType == 2 then 
			layerHeight = 280
			posXDelta = 15
			posYDelta = -90
		end
		local posX = -layerWidth/2 + posXDelta
		local posY = -layerHeight/2 + posYDelta
		self.touchLayer:setContentSize(CCSizeMake(layerWidth, layerHeight))
		self.touchLayer:setPosition(ccp(posX, posY))
		self:addChild(self.touchLayer)
		self.touchLayer:setTouchEnabled(true, 0, true)
	end

	local function clearBgAndFg()
		if self.bg and not self.bg.isDisposed then
			self.bg:stop()
			self.bg:removeFromParentAndCleanup(true)
		end

		if self.fg and not self.fg.isDisposed then
			self.fg:stop()
			self.fg:removeFromParentAndCleanup(true)
		end

		self:stopCountDown()
	end

	if not self.fg or not self.bg or self.fg.isDisposed or self.bg.isDisposed then
		self.armatureType = 0
	end

	if self.touchLayer then 
		self.touchLayer:setTouchEnabled(true, 0, true)
	end
		
	cloudId = tonumber(cloudId)
	if NewAreaOpenMgr.getInstance():isCountdownArea(cloudId) then 
		if self.armatureType == 4 then return false end
		lock_bg = ArmatureNode:create("worldSceneAreaCloud4/CloudBG")
		lock_fg = ArmatureNode:create("worldSceneAreaCloud/CloudFG")
		lock_bg:setPositionXY(0, 0)
		lock_fg:setPositionXY(0, -60)
		self.armatureType = 4
		clearBgAndFg()
	elseif cloudId == PLANET_CLOUD_ID_1 then
		if self.armatureType == 2 then return false end
		lock_bg = ArmatureNode:create("worldSceneAreaCloud2/CloudBG")
		lock_fg = ArmatureNode:create("worldSceneAreaCloud2/CloudFG")
		lock_bg:setPositionXY(0,-45)
		lock_fg:setPositionXY(0,-45)
		self.armatureType = 2
		clearBgAndFg()
	elseif cloudId == PLANET_CLOUD_ID_2 then
		if self.armatureType == 3 then return false end
		lock_bg = ArmatureNode:create("worldSceneAreaCloud3/CloudBG")
		lock_fg = ArmatureNode:create("worldSceneAreaCloud3/CloudFG")
		lock_bg:setPositionXY(0,-45)
		lock_fg:setPositionXY(0,-45)
		self.armatureType = 3
		clearBgAndFg()
	else
		if self.armatureType == 1 then return false end
		lock_bg = ArmatureNode:create("worldSceneAreaCloud/CloudBG")
		lock_fg = ArmatureNode:create("worldSceneAreaCloud/CloudFG")
		lock_bg:setPositionXY(0,0)
		lock_fg:setPositionXY(0,0)
		self.armatureType = 1
		clearBgAndFg()
	end

	self.bg = lock_bg
	self.fg = lock_fg

	self:addChild(self.bg)
	self:addChild(self.fg)

    if self.armatureType == 4 then 
    	self:initCountdown(cloudId)
    end

    reinitTouchLayer(self.armatureType)

    self.hand = GameGuideAnims:handclickAnim(0, 0)
    --self.hand:setScale(0.8)
    --self.hand:setScaleX(self.hand:getScaleX()*-1)
    self:addChild(self.hand)
    self.hand:setPosition(ccp(0, -10))

	return true
end

function NewClouds:initCountdown(cloudId)
	local endTime = NewAreaOpenMgr.getInstance():getCountdownEndTime(cloudId)
	local _, isOver = NewAreaOpenMgr.getInstance():getCountdownStr(endTime)
	if isOver then
		if self.fg then 
	    	self.fg:stop()
	    	self.fg:setVisible(false)
    	end
    	self.isCountdownOver = true
		HomeScene:sharedInstance().worldScene:updateTopScrollRange(true) 
	else
		if not self.areaCountdownTip then 
		    self.areaCountdownTip = BitmapText:create('', 'fnt/unlocknew2.fnt')
		    self.areaCountdownTip:setScale(1.1)
		    self.areaCountdownTip:setAnchorPoint(ccp(0, 0.5))
		    self:addChild(self.areaCountdownTip)
		    self.areaCountdownTip:setPosition(ccp(-30, 20))

		    local tip1 = BitmapText:create('倒计时', 'fnt/unlocknew.fnt')
		    tip1:setColor((ccc3(0x00, 0x66, 0x99)))
		    tip1:setAnchorPoint(ccp(1, 0.5))
		    self:addChild(tip1)
		    tip1:setPosition(ccp(-35, 20))
		    self.areaCountdownTip1 = tip1

		    local tip2 = BitmapText:create('', 'fnt/unlocknew.fnt')
		    tip2:setAnchorPoint(ccp(0.5, 0.5))
		    local timeDesc = NewAreaOpenMgr.getInstance():getTimeDesc(endTime)
	   	 	tip2:setRichText("新关来袭，[#0099FF]"..timeDesc.."[/#] 统一开放", "006699")
	   	 	
		    self:addChild(tip2)
		    tip2:setPosition(ccp(10, 70))
		    self.areaCountdownTip2 = tip2
		end 
		local function onTick()
			if self.isDisposed then return end
		    local timeStr, isOver = NewAreaOpenMgr.getInstance():getCountdownStr(endTime)
		    if isOver then 
		    	HomeScene:sharedInstance().worldScene:updateTopScrollRange(true) 
		    	if self.state and self.state ~= LockedCloudState.WAIT_TO_OPEN and self.fg then 
			    	self.fg:stop()
			    	self.fg:setVisible(false)
		    	end
		    	self.isCountdownOver = true
		    	self:stopCountDown()
		    	if self.state and self.state == LockedCloudState.WAIT_TO_OPEN then
		    		self:updateHandShow(cloudId)
		    	end
		    else
		    	self.areaCountdownTip:setText(timeStr)
		    end
		end
		self.oneSecondTimer = OneSecondTimer:create()
	    self.oneSecondTimer:setOneSecondCallback(function ()
	        onTick()
	    end)
	    onTick()
	    if self.oneSecondTimer then
	    	self.oneSecondTimer:start()
	    end
	end
end

function NewClouds:stopCountDown()
	if self.oneSecondTimer then 
		self.oneSecondTimer:stop()
		self.oneSecondTimer = nil
	end
	if self.areaCountdownTip then 
		self.areaCountdownTip:removeFromParentAndCleanup(true)
	end
	self.areaCountdownTip = nil

	if self.areaCountdownTip1 then 
		self.areaCountdownTip1:removeFromParentAndCleanup(true)
	end
	self.areaCountdownTip1 = nil

	if self.areaCountdownTip2 then 
		self.areaCountdownTip2:removeFromParentAndCleanup(true)
	end
	self.areaCountdownTip2 = nil
end

function NewClouds:playCountdownAni()
	if self.areaCountdownTip then 
		if not self.isCountdownAniPlay then 
			self.isCountdownAniPlay = true
			local arr = CCArray:create()
			arr:addObject(CCScaleTo:create(0.2, 1.2))
			arr:addObject(CCScaleTo:create(0.2, 1.1))
			arr:addObject(CCScaleTo:create(0.2, 1.2))
			arr:addObject(CCScaleTo:create(0.2, 1.1))
			arr:addObject(CCCallFunc:create(function ()
				self.isCountdownAniPlay = false
			end))
			self.areaCountdownTip:stopAllActions()
			self.areaCountdownTip:runAction(CCSequence:create(arr))
		end
	end
end

function NewClouds:startFloatAnim()
end

function NewClouds:stopFloatAnim()
end

function NewClouds:changeState(state, forceChange, cloudId)
	if self.isDisposed then return end

	local planetType = false
	if NewLockedCloud:isPlanetTypeByID(cloudId) then
		planetType = true
	end

	if state == LockedCloudState.WAIT_TO_OPEN then
		local topLevelId = UserManager.getInstance().user:getTopLevelId()
		local minLevel = (cloudId - 40000 - 1) * 15
		if minLevel < topLevelId then
			assert(false, "unexcept state change:"..tostring(minLevel).."-"..tostring(topLevelId))
		end
	end

	local armatureChanged = self:rebuildArmature(cloudId)
	if self.state == state and not forceChange and not armatureChanged then
		return
	end

	if state == LockedCloudState.STATIC then
		self.bg:play("normal" , 0)
		self.bg:setVisible(true)
    	self.fg:stop()
    	self.fg:setVisible(false)
        self:updateHandShow(cloudId, true)

        if self.armatureType == 4 then 
		    local endTime = NewAreaOpenMgr.getInstance():getCountdownEndTime(cloudId)
			local _, isOver = NewAreaOpenMgr.getInstance():getCountdownStr(endTime)
			if not isOver then
	        	self.fg:setVisible(true)
	    		self.fg:play("normalWithLock" , 0)
	    	end
        end
	elseif state == LockedCloudState.WAIT_TO_OPEN then
        local unlockFriends = UserManager:getInstance():getUnlockFriendUidsWithNPC(cloudId)
        local canFriendUnlock = (#unlockFriends >= 3)
        local canTimeUnlock = UserManager:getInstance():canUnlockAreaByTime(cloudId)
        local logic = UnlockLevelAreaLogic:create(cloudId)
        local canStarUnlock = logic:ifHasEnoughStar()

		self.bg:setVisible(true)
		self.bg:play("normal" , 0)
		self.fg:setVisible(true)
    	self.fg:play("normalWithLock" , 0)

    	if self.armatureType ~= 4 then 
        	self:updateHandShow(cloudId)
        else
        	self:updateHandShow(cloudId, true)
        end
	elseif state == LockedCloudState.OPENING then
		self.bg:setVisible(true)
		self.bg:play("onBreak" , 1)
		self.fg:setVisible(true)
    	self.fg:play("onBreak" , 1)
        self:updateHandShow(cloudId, true)
        if self.touchLayer then self.touchLayer:setTouchEnabled(false) end
        if self.armatureType == 4 then 
        	self:stopCountDown()
        end
	end
	self.state = state
end

function NewClouds:updateHandShow(cloudId, forceHide)
	if self.hand then 
		if forceHide then 
			self.hand:setVisible(false)
		else
	        local unlockFriends = UserManager:getInstance():getUnlockFriendUidsWithNPC(cloudId)
	        local canFriendUnlock = (#unlockFriends >= 3)
	        local canTimeUnlock = UserManager:getInstance():canUnlockAreaByTime(cloudId)
	        local logic = UnlockLevelAreaLogic:create(cloudId)
	        local canStarUnlock = logic:ifHasEnoughStar()
	        self.hand:setVisible(canFriendUnlock or canTimeUnlock or canStarUnlock)
		end
	end
end

function NewClouds:dispose()
	self:stopCountDown()
	Layer.dispose(self)
end